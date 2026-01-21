import { UserService } from "../services/userService";
import { Request, Response } from "express"

const userService = new UserService;

export const UserController = {
    async create(req: Request, res: Response) {
        try {
            const { name, email, password, course, campus, registration } = req.body

            if (!name || !email || !password || !registration) {
                return res.status(400).json({
                    success: false,
                    message: "Campos obrigatórios faltando: nome, email, senha e matrícula são necessários."
                });
            }

            if (typeof name !== 'string' || typeof email !== 'string') {
                return res.status(400).json({
                    success: false,
                    message: "Os dados foram enviados no formato errado."
                });
            }

            const userCreated = await userService.createUser({ name, email, password, course, campus, registration })
            if (!userCreated) throw new Error("Falha ao criar usuário.")
            return res.status(201).json({
                success: true,
                message: "Usuário criado com sucesso.",
                data: userCreated
            })
        } catch (error) {
            if (error instanceof Error) {
                if (
                    error.message.includes("já cadastrado") ||
                    error.message.includes("já existe")
                ) {

                    return res.status(409).json({
                        success: false,
                        message: error.message,
                    });
                }

                return res.status(500).json({
                    success: false,
                    message: error.message,
                });
            }
            return res.status(500).json({
                success: false,
                message: "Erro interno do servidor",
            });
        }
    },
}   