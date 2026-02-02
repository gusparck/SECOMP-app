import { UserService } from "../services/userService";
import { Request, Response } from "express";
import { z } from "zod";

const userService = new UserService();

const createUserSchema = z.object({
    name: z.string().min(1, "O nome é obrigatório."),
    email: z.string().email({ message: "Formato do e-mail é inválido" }),
    registration: z.string().min(1, "A matrícula é obrigatória."),
    password: z.string().regex(/^(?=.*[0-9])(?=.*[!@#$%^&*])[a-zA-Z0-9!@#$%^&*]{8,}$/,
        "Senha fraca: Precisa de 8 caracteres, número e símbolo especial."),
    course: z.string().optional(),
    campus: z.string().optional()
})

export const UserController = {
    async create(req: Request, res: Response) {
        try {
            const validation = createUserSchema.safeParse(req.body);

            if (!validation.success) {
                return res.status(400).json({
                    success: false,
                    message: "Campos obrigatórios faltando: nome, email, senha e matrícula são necessários.",
                    errors: validation.error.format()
                });
            }

            const data = validation.data;

            const userCreated = await userService.createUser(data);

            return res.status(201).json({
                success: true,
                message: "Usuário criado com sucesso.",
                data: userCreated
            });

        } catch (error) {
            if (error instanceof Error) {
                if (error.message === "CONFLICT") {
                    return res.status(409).json({
                        success: false,
                        message: "E-mail ou Matrícula já registrados no sistema."
                    });
                }

                return res.status(500).json({
                    success: false,
                    message: error.message
                });
            }
            return res.status(500).json({ success: false, message: "Erro interno." });
        }
    }
}