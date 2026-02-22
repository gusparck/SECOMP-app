import { Request, Response } from "express";
import { EventService } from "./event.service";
import { createEventSchema, updateEventSchema, registerSchema } from "./event.dto";

const eventService = new EventService();

export const EventController = {
    async create(req: Request, res: Response) {
        try {
            if (!req.user) return res.status(401).json({ message: "Unauthorized" });

            const eventData = {
                ...req.body,
                organizerId: req.user.id,
            };

            const validation = createEventSchema.safeParse(eventData);

            if (!validation.success) {
                console.error("Erro de validação ao criar evento:", JSON.stringify(validation.error.format(), null, 2));
                return res.status(400).json({
                    message: "Dados de evento inválidos",
                    errors: validation.error.format(),
                });
            }

            const event = await eventService.createEvent(validation.data);
            return res.status(201).json(event);
        } catch (error) {
            console.error("Erro interno ao criar evento:", error);
            if (error instanceof Error && error.message === "ORGANIZER_NOT_FOUND") {
                return res.status(404).json({ message: "Organizador não encontrado" });
            }
            return res.status(500).json({ message: "Erro interno ao criar evento" });
        }
    },

    async list(req: Request, res: Response) {
        try {
            const page = parseInt((req.query.page as string) || "1");
            const limit = parseInt((req.query.limit as string) || "10");
            const search = (req.query.search as string) || undefined;

            let userId: string | undefined = undefined;
            if (req.query.user === 'me') {
                if (!req.user) return res.status(401).json({ message: "Unauthorized" });
                userId = req.user.id;
            }

            let organizerId: string | undefined = undefined;
            if (req.query.organizer === 'me') {
                if (!req.user) return res.status(401).json({ message: "Unauthorized" });
                organizerId = req.user.id;
            }

            let speakerId: string | undefined = undefined;
            if (req.query.speaker === 'me') {
                if (!req.user) return res.status(401).json({ message: "Unauthorized" });
                speakerId = req.user.id;
            }

            const currentUserId = req.user?.id;

            const result = await eventService.listEvents(page, limit, search, userId, organizerId, speakerId, currentUserId);
            return res.status(200).json(result);
        } catch (error) {
            return res.status(500).json({ message: "Erro ao listar eventos" });
        }
    },

    async getById(req: Request, res: Response) {
        try {
            const id = req.params.id as string;
            const event = await eventService.getEventById(id);
            return res.status(200).json(event);
        } catch (error) {
            return res.status(404).json({ message: "Evento não encontrado" });
        }
    },

    async update(req: Request, res: Response) {
        try {
            const id = req.params.id as string;
            const validation = updateEventSchema.safeParse(req.body);

            if (!validation.success) {
                return res.status(400).json({
                    message: "Dados inválidos",
                    errors: validation.error.format(),
                });
            }

            if (!req.user) return res.status(401).json({ message: "Unauthorized" });

            const updatedEvent = await eventService.updateEvent(
                id,
                validation.data,
                req.user.id,
                req.user.role
            );

            return res.status(200).json(updatedEvent);
        } catch (error) {
            if (error instanceof Error) {
                if (error.message === "FORBIDDEN") return res.status(403).json({ message: "Sem permissão" });
                if (error.message === "EVENT_NOT_FOUND") return res.status(404).json({ message: "Evento não encontrado" });
            }
            return res.status(500).json({ message: "Erro ao atualizar evento" });
        }
    },

    async delete(req: Request, res: Response) {
        try {
            const id = req.params.id as string;

            if (!req.user) return res.status(401).json({ message: "Unauthorized" });

            await eventService.deleteEvent(id, req.user.id, req.user.role);
            return res.status(204).send();
        } catch (error) {
            if (error instanceof Error) {
                if (error.message === "FORBIDDEN") return res.status(403).json({ message: "Sem permissão" });
                if (error.message === "EVENT_NOT_FOUND") return res.status(404).json({ message: "Evento não encontrado" });
            }
            return res.status(500).json({ message: "Erro ao deletar evento" });
        }
    },

    async register(req: Request, res: Response) {
        try {
            const validation = registerSchema.safeParse(req.body);

            if (!validation.success) {
                return res.status(400).json({ errors: validation.error.format() });
            }

            const { userId, eventId } = validation.data;
            await eventService.registerUser(userId, eventId);

            return res.status(200).json({ message: "Inscrição realizada com sucesso!" });
        } catch (error) {
            if (error instanceof Error) {
                switch (error.message) {
                    case "EVENT_NOT_FOUND": return res.status(404).json({ message: "Evento não encontrado" });
                    case "EVENT_FULL": return res.status(400).json({ message: "Evento lotado" });
                    case "ALREADY_REGISTERED": return res.status(409).json({ message: "Você já está inscrito" });
                }
            }
            return res.status(500).json({ message: "Erro interno" });
        }
    },

    async addSpeaker(req: Request, res: Response) {
        try {
            const { id } = req.params;
            const { registration } = req.body;

            if (!registration) {
                return res.status(400).json({ message: "Matrícula é obrigatória" });
            }

            const speaker = await eventService.addSpeaker(id as string, registration as string);
            return res.status(201).json(speaker);
        } catch (error: any) {
            if (error.message === "EVENT_NOT_FOUND") {
                return res.status(404).json({ message: "Evento não encontrado" });
            }
            if (error.message === "USER_NOT_FOUND") {
                return res.status(404).json({ message: "Usuário com esta matrícula não encontrado" });
            }
            if (error.message === "ALREADY_SPEAKER") {
                return res.status(400).json({ message: "Usuário já faz parte da equipe/palestrantes" });
            }
            return res.status(500).json({ message: "Erro ao adicionar integrante" });
        }
    },
    async checkIn(req: Request, res: Response) {
        try {
            const { id } = req.params;
            const { userId } = req.body;

            if (!userId) {
                return res.status(400).json({ message: "ID do usuário é obrigatório" });
            }

            if (!req.user) {
                return res.status(401).json({ message: "Unauthorized" });
            }

            const participant = await eventService.checkIn(id as string, userId, req.user.id, req.user.role);
            return res.status(200).json(participant);
        } catch (error: any) {
            if (error.message === "FORBIDDEN") {
                return res.status(403).json({ message: "Você não tem permissão para realizar check-in neste evento." });
            }
            if (error.message === "PARTICIPANT_NOT_FOUND") {
                return res.status(404).json({ message: "Participante não encontrado ou não inscrito." });
            }
            if (error.message === "ALREADY_CHECKED_IN") {
                return res.status(400).json({ message: "Participante já realizou check-in." });
            }
            return res.status(500).json({ message: "Erro ao realizar check-in" });
        }
    },
};
