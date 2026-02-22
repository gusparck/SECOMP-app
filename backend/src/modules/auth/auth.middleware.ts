import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

// Extend Request type to include user
declare global {
    namespace Express {
        interface Request {
            user?: {
                id: string;
                role: string;
            };
        }
    }
}

export const authMiddleware = (req: Request, res: Response, next: NextFunction) => {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
        return res.status(401).json({ message: "Token não fornecido" });
    }

    const [, token] = authHeader.split(" ");

    try {
        const secret = process.env.JWT_SECRET as string;
        if (!secret) throw new Error("JWT_SECRET not configured");

        const decoded = jwt.verify(token as string, secret) as any;

        req.user = {
            id: decoded.id,
            role: decoded.role
        };

        next();
    } catch (error) {
        return res.status(401).json({ message: "Token inválido" });
    }
};

export const optionalAuthMiddleware = (req: Request, res: Response, next: NextFunction) => {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
        return next();
    }

    const [, token] = authHeader.split(" ");

    try {
        const secret = process.env.JWT_SECRET as string;
        if (!secret) throw new Error("JWT_SECRET not configured");

        const decoded = jwt.verify(token as string, secret) as any;

        req.user = {
            id: decoded.id,
            role: decoded.role
        };
        next();
    } catch (error) {
        // Obsolete or invalid token, ignore but proceed Without user
        next();
    }
};

export const authorize = (roles: string[]) => {
    return (req: Request, res: Response, next: NextFunction) => {
        if (!req.user) {
            return res.status(401).json({ message: "Usuário não autenticado" });
        }

        if (!roles.includes(req.user.role)) {
            return res.status(403).json({ message: "Acesso negado" });
        }

        next();
    };
};
