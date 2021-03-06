const User = require('../models/userModel');
const Msg = require('../models/msgModel');
const express = require('express');
const validator = require('validator');
const bcrypt = require('bcrypt');
const Cryptr = require('Cryptr');
const dateAndTime = require('date-and-time');

// To transform msg timeStamp into meaningful date and time 
const transformDateAndTime = (timeStamp) => {
    const now = new Date();
    const diffDays = Math.floor(dateAndTime.subtract(now, timeStamp).toDays());
    const diffHours = Math.floor(dateAndTime.subtract(now, timeStamp).toHours());
    const diffMinutes = Math.floor(dateAndTime.subtract(now, timeStamp).toMinutes());
    if (diffDays < 1){
        // For same day messages
        if (diffHours < 1){
            if (diffMinutes < 1){
                return 'Now';
            }
            else if (diffMinutes === 1){
                // For same hour msgs
                return '1 min ago';
            } else {
                return `${diffMinutes} mins ago`;
            } 
        }
        else if (diffHours === 1){
            // For same hour msgs
            return '1 hour ago';
        } else if (diffHours < 12){
            return `${diffHours} hours ago`;
        } 
        return 'Today';
    }
    else if (diffDays === 1){
        // For older msgs
        return '1 day ago';
    } else if (diffDays < 7){
        return `${diffDays} days ago`;
    } 
    return '1 week ago';
}

// To sort the contacts according to the time of latest reply
const sortContactsByTime = (details) => {
    details.forEach((c) => {
        c.creationTime = Date.parse(c.latest_msg.createdAt);
    })
    details.sort((first, second) => {
        if (first.creationTime < second.creationTime) return 1;
        else if (first.creationTime > second.creationTime) return -1;
        return 0;
    })
    details.forEach((c) => {
        c.creationTime = undefined;
        c.latest_msg.createdAt = undefined;
    })
    return details;
}

require('dotenv').config({ path: './dev.env' }); // Env. var. file

const router = express.Router(); // Initializing router to handle user specific requests
const cryptr = new Cryptr(process.env.CRYPTR_SECRET);

router.get('/contacts/:username', async(req, res, next) => { // For getting all the contacts present
    console.log(`Recieved GET request on /contacts/${req.params.username}`)
    try {
        // For getting the details of the users in the contact list of a user
        const username = req.params.username;
        let user = await User.findOne({ username });
        if (!user){
            return res.send({error : "No such user exists!"})
        }

        let contactDetails = await User.find({ username: user.contacts })
            .select(['name', 'isProfileImageSet', 'profileImage', 'username']);

        contactDetails = contactDetails.map(c => {
            let temp = {...c }._doc;
            temp._id = undefined;
            return temp;
        });

        // Getting latest messages sent by users
        let details = [];

        for (let i = 0; i < contactDetails.length; i++) {
            let c = contactDetails[i];
            const users = [user.username, c.username];
            const msg = await Msg.findOne({ from: users, to: users }, [], { sort: { 'createdAt': -1 } });
            if (msg) {
                const msgDetails = {...msg }._doc;
                msgDetails.content = cryptr.decrypt(msgDetails.content);
                if (msgDetails.content.length > 30){
                    msgDetails.content = msgDetails.content.slice(0, 28) + '...';
                }

                msgDetails._id = undefined;
                msgDetails.__v = undefined;
                msgDetails.updatedAt = undefined;
                msgDetails.from = undefined;
                msgDetails.to = undefined;

                const date = new Date(msgDetails.createdAt);
                msgDetails.time = transformDateAndTime(date);
                // msgDetails.createdAt = undefined;

                c.latest_msg = {...msgDetails };
            } else {
                c.latest_msg = { content: "", time: "" };
            }
            details.push(c);
        };

        details = sortContactsByTime(details);

        res.send(details);
    } catch (err) {
        next(err);
    }
})

router.post('/register', async(req, res, next) => { // For registering a new user to database
    console.log('Recieved POST request on /register')
    try {
        const userData = req.body;
        userData.contacts = [];

        // Running some validations
        if (!validator.isEmail(userData.email)) {
            return res.send({ error: "Invalid email!" });
        } else if (userData.password.length <= 5) {
            return res.send({ error: "Password should be greater than 5 characters" });
        } 

        let existingUser = await User.findOne({ email: userData.email });
        if (existingUser) {
            return res.send({ error: "User with this email already exists!" });
        }
        
        existingUser = await User.findOne({username : userData.username});
        if (existingUser) {
            return res.send({ error: "User with this username already exists!" });
        }

        // Hashing the password before storing into DB
        userData.password = await bcrypt.hash(userData.password, 8);

        const newUser = new User(userData);
        await newUser.save();

        // Cleaning up unncessary data
        newUser.password = undefined;
        newUser.__v = undefined;

        // Sending filtered data back to client side
        res.send(newUser);
        // res.send(userData);
    } catch (err) {
        next(err);
    }
})

router.post('/login', async(req, res, next) => { // To login a user 
    console.log('Recieved POST request on /login');
    try {
        const userCredentials = req.body;
        // console.log(userCredentials);

        const user = await User.findOne({ username: userCredentials.username });

        if (!user) {
            return res.send({ error: "No user found with these credentials!" });
        }

        // Checking if the password is correct or not
        const isMatch = await bcrypt.compare(userCredentials.password, user.password);
        if (!(isMatch)) {
            return res.send({ error: "No user found with these credentials!" });
        }

        // Removing unnecessary information
        const temp = ['__v', 'password'];
        temp.forEach(item => user[item] = undefined);
        

        res.send(user);
        // res.send(userCredentials);
    } catch (err) {
        next(err);
    }
})

router.post('/addcontact', async(req, res, next) => { // Add a new contact to the contact list
    console.log('Recieved POST request on /addcontact');
    try {
        const username = req.body.username;
        const newContactUsername = req.body.contact_username;

        if (username === newContactUsername) {
            return res.send({ error: "Conatct username same as current user's username" });
        }

        const newUser = await User.findOne({ username : newContactUsername });
        if (!newUser) {
            return res.send({ error: "No such user exists!" });
        }

        const user = await User.findOne({ username });
        const alreadyPresent = user.contacts.filter(c => c === newContactUsername);

        if (alreadyPresent && alreadyPresent.length > 0) {
            return res.send({ error: "User already present in contacts list" });
        } else {
            user.contacts.push(newContactUsername);
        }
        await user.save();


        res.send({msg : "Contact added successfully!"});
    } catch (err) {
        next(err);
    }
})

router.get('/profile/:username', async(req, res, next) => { // Getting profile information of any user
    console.log('Recieved GET request on /profile/:username');
    try {
        const user = await User.findOne({ uid: req.params.uid })
            .select(['name', 'email', 'username', 'isProfileImageSet', 'profileImage', 'contacts']);

        if (!user) {
            res.send({ error: "No such user exists!" });
        }

        const userDetails = {...user }._doc;

        // No. of people user has chatted with
        userDetails.total_chats = userDetails.contacts.length;
        userDetails.contacts = undefined;
        userDetails._id = undefined;

        res.send(userDetails);
    } catch (err) {
        next(err);
    }
})

router.post('/profile', async(req, res, next) => { // Updating profile information
    console.log('Recieved POST request on /profile');
    try {
        const user = await User.findOneAndUpdate({ username: req.body.username }, req.body);

        if (!user) {
            return res.send({ error: "No such user exists!" });
        }

        res.send(user);
    } catch (err) {
        next(err);
    }
})

// TEST feature: username substring search
// Status: completed
router.get('/search/:substring', async(req, res, next) => { // Searching the usernames starting with substring
    try{
        const users = await User.find({username : {$regex : new RegExp(`^(${req.params.substring})`)}});

        const userDetails = users.map((user) => {
            let temp = {};
            temp.name = user.name;
            temp.username = user.username;
            temp.isProfileImageSet = user.isProfileImageSet;
            temp.profileImage = user.profileImage;
            return temp;
        })

        res.send(userDetails);
    } catch (err) {
        next(err);
    }
})

// TODO
// TEST feature : image upload
const multer = require('multer');
const sharp = require('sharp');

const uploadImage = multer({
    fileFilter(req, file, cb) {
        if (!file.originalname.match(/\.(png|jpg|jpeg)$/)) {
            cb(new Error('Please upload a valid file!'))
        }
        cb(undefined, true);
    }
})

router.post('/uploadimage', uploadImage.single('mypic'), async(req, res, next) => {
    console.log('Recieved POST request on /uploadimage')
    try{
        const buffer = await sharp(req.file.buffer).resize({ width: 250, height: 250 }).png().toBuffer();
        // const buffer = req.file.buffer;
        let imageBase64 = buffer.toString('base64');

        if (!buffer){
            return res.send({error : "Please upload a file!"})
        }

        const user = await User.findOneAndUpdate({username : req.body.username}, {isProfileImageSet: true, profileImage: imageBase64});
        if (!user){
            return res.send({error : "User not found!"})
        }

        res.send({msg : "Image saved successfully!"});
    } catch (err){
        next(err)
    }
})

router.get('/profileimage/:username', async(req, res, next) => {
    console.log(`Recieved GET request on /profileimage/${req.params.username}`);
    try{
        const user = await User.findOne({username: req.params.username});
        if (!user){
            return res.send({error : "No such user found!"})
        }

        // res.set('Content-Type', 'image/png')
        
        const imageSrc = "data:image/png;base64," + user.profileImage; // Source of image
        const image = "<img src=\"" + imageSrc + "\" >"; // HTML Image with source
        res.send(image)
    } catch (err) {
        next(err);
    }
})


// ENDS Here

module.exports = router;