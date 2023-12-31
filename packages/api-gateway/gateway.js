const express = require("express");
const app = express();
const routes = require("./routes");
const PORT = 6790
const OpenAI = require("openai");

const openai = new OpenAI();


app.use(express.json());

app.use("/", routes)

app.listen(PORT, () => {
    console.log("Server started at " + PORT)
})