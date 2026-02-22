import { z } from "zod";

export const createEventSchema = z.object({
    title: z.string().min(3, "Título deve ter no mínimo 3 caracteres"),
    description: z.string().optional(),
    date: z.coerce.date().refine((date) => date > new Date(), {
        message: "A data do evento deve ser no futuro",
    }),
    location: z.string().optional(),
    capacity: z.coerce.number().min(1, "Capacidade deve ser maior que 0"),
    organizerId: z.string().uuid("ID do organizador inválido"),
});

export const updateEventSchema = createEventSchema.partial();

export const registerSchema = z.object({
    userId: z.string().uuid(),
    eventId: z.string().uuid(),
});

export type CreateEventDTO = z.infer<typeof createEventSchema>;
export type UpdateEventDTO = z.infer<typeof updateEventSchema>;
