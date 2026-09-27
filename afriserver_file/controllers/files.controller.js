var filesService = require('../services/files.service');
var apiResponse = require('../utils/apiResponse');

function upload(req, res, next) {
  try {
    var payload = {
      nom_fichier: req.body && req.body.nom_fichier ? req.body.nom_fichier : null,
      type_fichier: req.body && req.body.type_fichier ? req.body.type_fichier : null,
      taille_fichier: req.body && req.body.taille_fichier ? req.body.taille_fichier : null,
    };

    var data = filesService.upload(payload);
    return apiResponse.success(
      res,
      'Fichier reçu. Conversion en attente.',
      data,
      201
    );
  } catch (err) {
    return next(err);
  }
}

function show(req, res, next) {
  try {
    var data = filesService.getById(req.params.id);
    return apiResponse.success(res, 'Détail du fichier.', data);
  } catch (err) {
    return next(err);
  }
}

module.exports = {
  upload: upload,
  show: show,
};
