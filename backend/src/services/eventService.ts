import { PrismaClient } from "../generated/prisma";

const prisma = new PrismaClient();

interface CreateEventInput {
    title: string;
    description?: string | null | undefined;
    date: Date;
    location?: string | null | undefined;
    capacity: number;
    organizerId: string;
}

export class EventService {

    async createEvent(data: CreateEventInput) {
        const organizerExists = await prisma.user.findUnique({
            where: { id: data.organizerId }
        });

        if (!organizerExists) {
            throw new Error("ORGANIZER_NOT_FOUND");
        }

        const event = await prisma.event.create({
            data: {
                title: data.title,
                description: data.description ?? null,
                date: data.date,
                location: data.location ?? null,
                capacity: data.capacity,
                organizerId: data.organizerId
            }
        });
        return event;
    }

    async listEvents() {
        return await prisma.event.findMany({
            orderBy: { date: 'asc' },
            include: {
                organizer: {
                    select: { name: true, email: true }
                },
                _count: {
                    select: { participants: true }
                }
            }
        });
    }

    async registerUser(userId: string, eventId: string) {
        const event = await prisma.event.findUnique({
            where: { id: eventId },
            include: { _count: { select: { participants: true } } }
        });

        if (!event) throw new Error("EVENT_NOT_FOUND");

        if (event._count.participants >= event.capacity) {
            throw new Error("EVENT_FULL");
        }

        const alreadyRegistered = await prisma.eventParticipant.findUnique({
            where: {
                eventId_userId: {
                    eventId: eventId,
                    userId: userId
                }
            }
        });

        if (alreadyRegistered) throw new Error("ALREADY_REGISTERED");

        return await prisma.eventParticipant.create({
            data: { userId, eventId }
        });
    }
}