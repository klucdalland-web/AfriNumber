var filesRepository = require('../repositories/files.repository');

function upload(payload) {
  var fichiers = filesRepository.saveUploads(payload || {});

  return {
    idprofile: payload.idprofile || null,
    dossier: payload.dossier || null,
    fichiers: fichiers,
    message: 'Conversion à implémenter.',
  };
}

function getById(id) {
  var fichier = filesRepository.findById(id);

  return {
    fichier: fichier,
    message: 'Conversion à implémenter.',
  };
}

module.exports = {
  upload: upload,
  getById: getById,
};
