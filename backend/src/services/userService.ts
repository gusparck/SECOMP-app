import { PrismaClient } from "../generated/prisma";

const prisma = new PrismaClient();

interface CreateUserInput {
    name: string;
    email: string;
    password: string;
    registration: string; //matrícula
    course?: string;
    campus?: string;
}

export class UserService {
    // Criando usuário 
    async createUser(data: CreateUserInput) {
        const existingEmail = await prisma.user.findUnique({
            where: { email: data.email }
        })
        if (existingEmail) {
            throw new Error("E-mail já registrado no sistema.")
        }

        const existingRegistration = await prisma.user.findUnique({
            where: { registration: data.registration }
        })
        if (existingRegistration) {
            throw new Error("Número de matrícula inválido ou já utilizado.")
        }

        const defaultPassword = /^(?=.*[0-9])(?=.*[!@#$%^&*])[a-zA-Z0-9!@#$%^&*]{8,}$/;

        if (!defaultPassword.test(data.password)) {
            // Nota: Seria melhor realizar as verficações da estrutura de senha de forma mais ramificada?
            throw new Error("Senha inválida! Ela precisa ter no mínimo 8 caracteres, um número e um caracter especial (!@#$%^&*).");
        }


        /*const coursesICEA = ["Sistemas de Informação", "Engenharia Elétrica", "Engenharia da Computação", "Engenharia de Produção"];

        if (data.course && !coursesICEA.includes(data.course)) {
            throw new Error("Curso inválido. Preencha o campo com um curso do campus ICEA.")
        }*/


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
