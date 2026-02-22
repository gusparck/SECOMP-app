import express from 'express';
import userRouter from "./routes/userRoutes";
import eventRouter from "./modules/events/event.routes"

import morgan from "morgan";

const app = express();

app.use(morgan("dev"));
app.use(express.json());

app.use("/api/user", userRouter)
app.use("/api/events", eventRouter)

app.get("/health", (req, res) => {
    res.status(200).json({ status: 'ok' });
});

export default app
