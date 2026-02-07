import { UserService } from "../services/userService";
import { Request, Response } from "express";
import { z } from "zod";

const userService = new UserService();

const createUserSchema = z.object({
    name: z.string().min(1, "O nome é obrigatório."),
    email: z.string().email({ message: "Formato do e-mail é inválido" }),
    registration: z.string().regex(/^\d{2}\.\d\.\d{4}$/, "Formato inválido. Use 00.0.0000"),
    password: z.string()
        .min(6, "Senha fraca")
        .regex(/[a-z]/, "Senha fraca")
        .regex(/[A-Z]/, "Senha fraca")
        .regex(/\d/, "Senha fraca")
        .regex(/[@$!%*?&]/, "Senha fraca"),
    course: z.string().optional(),
    campus: z.string().optional()
})

const loginUserSchema = z.object({
    email: z.string().email("E-mail inválido"),
    password: z.string().min(1, "Senha obrigatória")
});

export const UserController = {
    async create(req: Request, res: Response) {
        try {
            const validation = createUserSchema.safeParse(req.body);

            if (!validation.success) {
                return res.status(400).json({
                    success: false,
                    message: "Dados inválidos. Verifique os campos.",
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
    },

    async login(req: Request, res: Response) {
        try {
            const validation = loginUserSchema.safeParse(req.body);

            if (!validation.success) {
                return res.status(400).json({
                    success: false,
                    message: "Dados de login inválidos.",
                    errors: validation.error.format()
                });
            }

            const result = await userService.login(validation.data);

            return res.status(200).json({
                success: true,
                message: "Login realizado com sucesso.",
                data: result
            });

        } catch (error) {
            if (error instanceof Error) {
                if (error.message === "INVALID_CREDENTIALS") {
                    return res.status(401).json({
                        success: false,
                        message: "E-mail ou senha incorretos."
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