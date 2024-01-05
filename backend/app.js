var express = require('express');

var app = express();

var port = 3000;

var users = require('./router/user');

var index = require("./router/index");

var admin = require("./router/admin");

// const PORT  = process.env.APPLICATION_PORT

// app.listen(PORT, ()=>{
//     console.log("server is running at" + PORT);
// })

app.use(express.json());

app.use('/', index);

app.use('/user', users);

app.use('/admin', admin);

app.listen(port, (req, resp) =>{
    console.log('running on port ' + port);
})