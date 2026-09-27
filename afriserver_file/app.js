var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');

var config = require('./config');
var indexRouter = require('./routes/index');
var notFound = require('./middlewares/notFound');
var errorHandler = require('./middlewares/errorHandler');

var app = express();

app.set('env', config.env);
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', indexRouter);

app.use(notFound);
app.use(errorHandler);

module.exports = app;
