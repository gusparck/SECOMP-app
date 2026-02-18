import { Router } from "express";
import { EventController } from "../controller/eventController";

const eventRouter = Router();

eventRouter.post("/", EventController.create);
eventRouter.get("/", EventController.list);
eventRouter.post("/register", EventController.register);

export default eventRouter;