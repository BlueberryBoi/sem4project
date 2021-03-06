const express = require('express');
const cors = require('cors'); // For bypassing CORS policy
const mongoose = require('mongoose');
const userRouter = require('./routes/userRouter');
const msgRouter = require('./routes/msgRouter');

const app = express();
require('dotenv').config({ path: './dev.env' }); // Env. var. file

app.use(express.json());

// Using cors middleware
app.use(cors());

// Registering routers
app.use(userRouter);
app.use(msgRouter);

mongoose.connect(process.env.MONGO_URL, { useNewUrlParser: true, useUnifiedTopology: true }).then(
    () => {
        console.log('Connected to mongoDB database');
    }).catch((err) => {
    console.log('Error! :', err);
})

const server = app.listen(process.env.PORT || process.env.LOCALHOST_PORT, () => {
    console.log(`Server up on port ${process.env.PORT || process.env.LOCALHOST_PORT}`);
})

// For configuration of websockets