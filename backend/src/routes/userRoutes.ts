import { Router } from "express"
import { UserController } from "../controller/userController"

const userRouter = Router();

userRouter.post("/create", UserController.create)

export default userRouter  