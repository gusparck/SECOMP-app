import "dotenv/config";
import app from "./app";
import morgan from "morgan"; // Add this import

// Assuming 'app' from './app' is an Express application instance,
// we can add middleware to it here before it starts listening.
// If 'app' from './app' already has its middleware configured,
// this might be redundant or incorrectly placed depending on the internal structure of './app'.
// For this change, we'll add it here as requested.
app.use(morgan("dev")); // Add this middleware

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
});