import { PrismaClient } from "../generated/prisma";
import * as bcrypt from "bcrypt";
import * as jwt from "jsonwebtoken";

const prisma = new PrismaClient();

interface CreateUserInput {
    name: string;
    email: string;
    password: string;
    registration: string; //matrícula
    course?: string | null | undefined;
    campus?: string | null | undefined;
}

interface LoginInput {
    email: string;
    password: string;
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

        const hashedPassword = await bcrypt.hash(data.password, 10);

        const createdUser = await prisma.user.create({
            data: {
                name: data.name,
                email: data.email,
                password: hashedPassword,
                registration: data.registration,
                course: data.course || null,
                campus: data.campus || null
            }
        })

        // Remove password from response
        const { password, ...userWithoutPassword } = createdUser;
        return userWithoutPassword;
    }

    async login(data: LoginInput) {
        const user = await prisma.user.findUnique({
            where: { email: data.email }
        });

        if (!user) {
            throw new Error("INVALID_CREDENTIALS");
        }

        const isPasswordValid = await bcrypt.compare(data.password, user.password);

        if (!isPasswordValid) {
            throw new Error("INVALID_CREDENTIALS");
        }

        const token = jwt.sign(
            { id: user.id, email: user.email },
            process.env.JWT_SECRET || "secomp_secret_key",
            { expiresIn: "7d" }
        );

        const { password, ...userWithoutPassword } = user;

        return { user: userWithoutPassword, token };
    }
}
