import express from 'express';
import userRouter from "./routes/userRoutes";

const app = express();

app.use(express.json());

app.use("/api/user", userRouter)

app.get("/health", (req, res) => {
    res.status(200).json({ status: 'ok' });
});

export default app
