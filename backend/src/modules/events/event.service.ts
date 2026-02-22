import { prisma } from "../../lib/prisma";
import { CreateEventDTO, UpdateEventDTO } from "./event.dto";

export class EventService {
    async createEvent(data: CreateEventDTO) {
        // Validate organizer existence (optional if foreign key handles it, but good for explicit error)
        const organizer = await prisma.user.findUnique({
            where: { id: data.organizerId },
        });

        if (!organizer) {
            throw new Error("ORGANIZER_NOT_FOUND");
        }

        // Optional: Check for time conflicts
        // const conflict = await prisma.event.findFirst({ ... });

        return await prisma.event.create({
            data: {
                title: data.title,
                description: data.description || null,
                date: data.date,
                location: data.location || null,
                capacity: data.capacity,
                organizerId: data.organizerId,
            },
        });
    }

    async listEvents(page = 1, limit = 10, search?: string, userId?: string, organizerId?: string, speakerId?: string, currentUserId?: string) {
        const skip = (page - 1) * limit;
        const where: any = {};

        if (search) {
            where.title = { contains: search, mode: "insensitive" };
        }

        if (userId) {
            where.participants = {
                some: { userId: userId }
            };
        }

        if (organizerId) {
            where.organizerId = organizerId;
        }

        if (speakerId) {
            where.speakers = {
                some: { userId: speakerId }
            };
        }

        const [events, total] = await Promise.all([
            prisma.event.findMany({
                where,
                skip,
                take: limit,
                orderBy: { date: "asc" },
                include: {
                    organizer: {
                        select: { name: true, email: true },
                    },
                    _count: {
                        select: { participants: true },
                    },
                    ...(currentUserId ? {
                        participants: {
                            where: { userId: currentUserId },
                            select: { userId: true }
                        }
                    } : {})
                },
            }),
            prisma.event.count({ where }),
        ]);

        const formattedEvents = events.map((event: any) => {
            const isSubscribed = event.participants ? event.participants.length > 0 : false;
            // Optionally remove participants array so it doesn't leak unwanted objects
            delete event.participants;
            return {
                ...event,
                isSubscribed
            };
        });

        return {
            data: formattedEvents,
            meta: {
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit),
            },
        };
    }

    async getEventById(id: string) {
        const event = await prisma.event.findUnique({
            where: { id },
            include: {
                organizer: {
                    select: { name: true, email: true },
                },
                participants: {
                    include: {
                        user: {
                            select: {
                                id: true,
                                name: true,
                                email: true,
                                registration: true,
                                role: true,
                                course: true,
                                campus: true,
                            },
                        },
                    },
                },
                _count: {
                    select: { participants: true },
                },
                speakers: {
                    include: {
                        user: {
                            select: {
                                id: true,
                                name: true,
                                email: true,
                                registration: true,
                                role: true,
                                course: true,
                                campus: true,
                            },
                        },
                    },
                },
            },
        });

        if (!event) throw new Error("EVENT_NOT_FOUND");
        return event;
    }

    async updateEvent(id: string, data: UpdateEventDTO, userId: string, userRole: string) {
        const event = await prisma.event.findUnique({ where: { id } });

        if (!event) throw new Error("EVENT_NOT_FOUND");

        // Authorization check: Admin or the organizer can update
        if (userRole !== "ADMIN" && event.organizerId !== userId) {
            throw new Error("FORBIDDEN");
        }

        const updateData: any = { ...data };
        if (data.description !== undefined) updateData.description = data.description || null;
        if (data.location !== undefined) updateData.location = data.location || null;
        // Remove organizerId from update to avoid type error and logic issue (organizer shouldn't change easily)
        delete updateData.organizerId;

        return await prisma.event.update({
            where: { id },
            data: updateData,
        });
    }

    async deleteEvent(id: string, userId: string, userRole: string) {
        const event = await prisma.event.findUnique({ where: { id } });

        if (!event) throw new Error("EVENT_NOT_FOUND");

        // Authorization check: Admin or the organizer can delete
        if (userRole !== "ADMIN" && event.organizerId !== userId) {
            throw new Error("FORBIDDEN");
        }

        return await prisma.event.delete({ where: { id } });
    }

    // Kept from original implementation
    async registerUser(userId: string, eventId: string) {
        const event = await prisma.event.findUnique({
            where: { id: eventId },
            include: { _count: { select: { participants: true } } },
        });

        if (!event) throw new Error("EVENT_NOT_FOUND");

        if (event._count.participants >= event.capacity) {
            throw new Error("EVENT_FULL");
        }

        const alreadyRegistered = await prisma.eventParticipant.findUnique({
            where: {
                eventId_userId: {
                    eventId: eventId,
                    userId: userId,
                },
            },
        });

        if (alreadyRegistered) throw new Error("ALREADY_REGISTERED");

        return await prisma.eventParticipant.create({
            data: { userId, eventId },
        });
    }

    async addSpeaker(eventId: string, registration: string) {
        const event = await prisma.event.findUnique({
            where: { id: eventId },
        });

        if (!event) throw new Error("EVENT_NOT_FOUND");

        const user = await prisma.user.findUnique({
            where: { registration },
        });

        if (!user) throw new Error("USER_NOT_FOUND");

        // Check if already a speaker
        const existingSpeaker = await prisma.eventSpeaker.findUnique({
            where: {
                eventId_userId: {
                    eventId,
                    userId: user.id,
                },
            },
        });

        if (existingSpeaker) throw new Error("ALREADY_SPEAKER");

        return await prisma.eventSpeaker.create({
            data: {
                eventId,
                userId: user.id,
            },
            include: {
                user: {
                    select: {
                        id: true,
                        name: true,
                        email: true,
                        registration: true,
                    },
                },
            },
        });
    }

    async checkIn(eventId: string, userId: string, scannerUserId: string, scannerUserRole: string) {
        // Authorization check: Admin and Professor can check-in anywhere.
        // Speaker must be part of the EVENT.
        if (scannerUserRole === "SPEAKER" || scannerUserRole === "USER") {
            // "USER" isn't allowed to hit this route anyway due to `authorize`, but it's good practice.
            const isSpeaker = await prisma.eventSpeaker.findUnique({
                where: {
                    eventId_userId: {
                        eventId,
                        userId: scannerUserId,
                    },
                },
            });

            if (!isSpeaker) {
                throw new Error("FORBIDDEN");
            }
        }

        const participant = await prisma.eventParticipant.findUnique({
            where: {
                eventId_userId: {
                    eventId,
                    userId,
                },
            },
        });

        if (!participant) {
            throw new Error("PARTICIPANT_NOT_FOUND");
        }

        if (participant.checkedIn) {
            throw new Error("ALREADY_CHECKED_IN");
        }

        return await prisma.eventParticipant.update({
            where: {
                eventId_userId: {
                    eventId,
                    userId,
                },
            },
            data: {
                checkedIn: true,
            },
            include: {
                user: {
                    select: {
                        name: true,
                        registration: true,
                    },
                },
            },
        });
    }
}
