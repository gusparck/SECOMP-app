import { Request, Response } from "express";
import { z } from "zod";
import { EventService } from "../services/eventService";

const eventService = new EventService();

const createEventSchema = z.object({
    title: z.string().min(3, { message: "O título deve ter no mínimo 3 caracteres" }),
    description: z.string().optional(),
    date: z.coerce.date({ message: "A data é obrigatória ou inválida" }),
    location: z.string().optional(),
    capacity: z.coerce.number().min(1, { message: "Capacidade deve ser maior que 0" }),
    organizerId: z.string().uuid({ message: "ID do organizador inválido" })
});

const registerSchema = z.object({
    userId: z.string().uuid(),
    eventId: z.string().uuid()
});

export const EventController = {
    async create(req: Request, res: Response) {
        try {
            const validation = createEventSchema.safeParse(req.body);

            if (!validation.success) {
                return res.status(400).json({
                    success: false,
                    message: "Dados inválidos",
                    errors: validation.error.format()
                });
            }

            const event = await eventService.createEvent(validation.data);
            return res.status(201).json({ success: true, data: event });

        } catch (error) {
            if (error instanceof Error && error.message === "ORGANIZER_NOT_FOUND") {
                return res.status(404).json({ success: false, message: "Organizador não encontrado." });
            }
            return res.status(500).json({ success: false, message: "Erro interno ao criar evento." });
        }
    },

    async list(req: Request, res: Response) {
        try {
            const events = await eventService.listEvents();
            return res.status(200).json({ success: true, data: events });
        } catch (error) {
            return res.status(500).json({ success: false, message: "Erro ao listar eventos." });
        }
    },

    async register(req: Request, res: Response) {
        try {
            const validation = registerSchema.safeParse(req.body);

            if (!validation.success) {
                return res.status(400).json({ success: false, errors: validation.error.format() });
            }

            const { userId, eventId } = validation.data;
            await eventService.registerUser(userId, eventId);

            return res.status(200).json({ success: true, message: "Inscrição realizada com sucesso!" });

        } catch (error) {
            if (error instanceof Error) {
                switch (error.message) {
                    case "EVENT_NOT_FOUND": return res.status(404).json({ message: "Evento não encontrado" });
                    case "EVENT_FULL": return res.status(400).json({ message: "Evento lotado" });
                    case "ALREADY_REGISTERED": return res.status(409).json({ message: "Você já está inscrito neste evento" });
                }
            }
            return res.status(500).json({ success: false, message: "Erro interno." });
        }
    }
};