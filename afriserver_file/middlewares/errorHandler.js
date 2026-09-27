var apiResponse = require('../utils/apiResponse');

function errorHandler(err, req, res, next) {
  var status = err.status || err.statusCode || 500;
  var message = err.message || 'Erreur interne du serveur';

  if (req.app.get('env') === 'development' && status >= 500) {
    return apiResponse.error(res, message, { stack: err.stack }, status);
  }

  return apiResponse.error(res, message, null, status);
}

module.exports = errorHandler;
