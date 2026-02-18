import express from 'express';
import userRouter from "./routes/userRoutes";
import eventRouter from "./routes/eventRoutes"

const app = express();

app.use(express.json());

app.use("/api/user", userRouter)
app.use("/api/events", eventRouter)

app.get("/health", (req, res) => {
    res.status(200).json({ status: 'ok' });
});

export default app
