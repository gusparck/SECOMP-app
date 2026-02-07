import { PrismaClient } from "../generated/prisma";

const prisma = new PrismaClient();

interface CreateUserInput {
    name: string;
    email: string;
    password: string;
    registration: string; //matrícula
    course?: string | null | undefined;
    campus?: string | null | undefined;
}

export class UserService {
    async createUser(data: CreateUserInput) {

        const existingEmail = await prisma.user.findUnique({
            where: { email: data.email }
        });
        if (existingEmail) {
            throw new Error("CONFLICT");
        }

        const existingRegistration = await prisma.user.findUnique({
            where: { registration: data.registration }
        });
        if (existingRegistration) {
            throw new Error("CONFLICT");
        }


        const createdUser = await prisma.user.create({
            data: {
                name: data.name,
                email: data.email,
                password: data.password,
                registration: data.registration,
                course: data.course || null,
                campus: data.campus || null
            }
        })
        return createdUser;
    }
}
