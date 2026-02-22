import { Router } from "express";
import { EventController } from "./event.controller";
import { authMiddleware, optionalAuthMiddleware, authorize } from "../auth/auth.middleware";

const eventRouter = Router();

// Public routes with optional auth
eventRouter.get("/", optionalAuthMiddleware, EventController.list);
eventRouter.get("/:id", optionalAuthMiddleware, EventController.getById);

// Protected routes (Admin or Professor for creation)
eventRouter.post("/", authMiddleware, authorize(["ADMIN", "PROFESSOR"]), EventController.create);

// Protected routes (Admin or Organizer - logic in controller/service handles ownership check)
eventRouter.put("/:id", authMiddleware, EventController.update);
eventRouter.delete("/:id", authMiddleware, EventController.delete);

// Registration
eventRouter.post("/register", authMiddleware, EventController.register);

// Team/Speakers
eventRouter.post(
    "/:id/speakers",
    authMiddleware,
    authorize(["ADMIN", "PROFESSOR"]),
    EventController.addSpeaker
);

// Check-in
eventRouter.post(
    "/:id/checkin",
    authMiddleware,
    authorize(["ADMIN", "PROFESSOR", "SPEAKER"]),
    EventController.checkIn
);

export default eventRouter;
