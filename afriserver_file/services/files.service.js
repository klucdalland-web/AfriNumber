var filesRepository = require('../repositories/files.repository');

function upload(payload) {
  var fichier = filesRepository.saveUpload(payload || {});

  return {
    fichier: fichier,
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
