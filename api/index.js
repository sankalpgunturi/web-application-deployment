const express = require('express');

const app = express();

app.get('/', async function(req, res) {
	res.send('Hello I am an API response! - Sankalp');
});

app.listen(process.env.PORT || 80);