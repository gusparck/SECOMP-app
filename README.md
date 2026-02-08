# SECOMP - Semana da Computação

App oficial da Semana da Computação.

## 🚀 Como Rodar o Projeto

### 1. Banco de Dados (Docker)
Execute o banco de dados PostgreSQL usando Docker Compose:
```bash
docker compose up -d db
```

### 2. Backend (Node.js/Express)
Em um terminal separado:
```bash
cd backend
npm install
# Rodar migrações (se necessário)
DATABASE_URL="postgresql://postgresSECOMP:postgresSECOMP2026@localhost:5438/secomp?schema=public" npx prisma migrate dev
# Rodar seed (popular banco)
DATABASE_URL="postgresql://postgresSECOMP:postgresSECOMP2026@localhost:5438/secomp?schema=public" npx prisma db seed
# Iniciar servidor
npm run dev
```
O servidor rodará em `http://localhost:3000`.

### 3. Frontend (Flutter)
Em outro terminal (com emulador Android rodando ou dispositivo conectado):
```bash
cd frontend
flutter pub get
flutter run
```
**Nota**: O app Android se conecta ao backend via `http://10.0.2.2:3000` (localhost do emulador).

## 🔑 Usuários de Teste (Senha: 12345678)
- **Aluno**: `aluno@aluno.com`
- **Professor**: `professor@professor.com`
- **Palestrante**: `palestrante@palestrante.com`
- **Admin**: `admin@admin.com`