var apiResponse = require('../utils/apiResponse');
var multer = require('multer');

function errorHandler(err, req, res, next) {
  var status = err.status || err.statusCode || 500;
  var message = err.message || 'Erreur interne du serveur';

  if (err instanceof multer.MulterError) {
    status = 400;
    if (err.code === 'LIMIT_FILE_SIZE') {
      message = 'Fichier trop volumineux.';
    } else if (err.code === 'LIMIT_UNEXPECTED_FILE') {
      message =
        'Champ fichier invalide. Champs attendus : photopath, pieceavantpath, piecearrierepath.';
    } else {
      message = 'Erreur lors de l\'upload du fichier.';
    }
  } else if (err.code === 'INVALID_FILE_TYPE' || err.code === 'MISSING_IDPROFILE') {
    status = 400;
    message = err.message;
  }

  if (req.app.get('env') === 'development' && status >= 500) {
    return apiResponse.error(res, message, { stack: err.stack }, status);
  }

  return apiResponse.error(res, message, null, status);
}

module.exports = errorHandler;
