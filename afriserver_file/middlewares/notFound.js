var createError = require('http-errors');

function notFound(req, res, next) {
  next(createError(404));
}

module.exports = notFound;
