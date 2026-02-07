import { PrismaClient, Role } from '../src/generated/prisma';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
    const password = await bcrypt.hash('12345678', 10);

    const users = [
        {
            name: 'Aluno Teste',
            email: 'aluno@aluno.com',
            registration: '20240001',
            role: Role.USER,
            course: 'Ciência da Computação',
            campus: 'Ouro Preto',
        },
        {
            name: 'Professor Teste',
            email: 'professor@professor.com',
            registration: '10001',
            role: Role.PROFESSOR,
            course: 'Engenharia de Software',
            campus: 'Ouro Preto',
        },
        {
            name: 'Palestrante Teste',
            email: 'palestrante@palestrante.com',
            registration: '20001',
            role: Role.SPEAKER,
            course: null,
            campus: null,
        },
        {
            name: "Admin",
            email: "admin@admin.com",
            registration: "admin",
            role: Role.ADMIN,
            course: null,
            campus: null
        }
    ];

    for (const user of users) {
        const exists = await prisma.user.findUnique({
            where: { email: user.email },
        });

        if (!exists) {
            await prisma.user.create({
                data: {
                    ...user,
                    password,
                },
            });
            console.log(`Created user: ${user.email}`);
        } else {
            console.log(`User already exists: ${user.email}`);
        }
    }
}

main()
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
