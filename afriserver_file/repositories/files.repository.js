/**
 * Stub repository — I/O disque / DB à brancher plus tard.
 */
function saveUpload(meta) {
  return {
    id: null,
    nom_fichier: meta.nom_fichier || null,
    chemin_fichier: null,
    type_fichier: meta.type_fichier || null,
    taille_fichier: meta.taille_fichier || null,
  };
}

function findById(id) {
  return {
    id: id,
    nom_fichier: null,
    chemin_fichier: null,
    type_fichier: null,
    taille_fichier: null,
  };
}

module.exports = {
  saveUpload: saveUpload,
  findById: findById,
};
