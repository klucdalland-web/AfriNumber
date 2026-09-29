/**
 * Stub repository — I/O disque / DB à brancher plus tard.
 */
function saveUploads(payload) {
  var list = payload.fichiers || [];

  return list.map(function (meta) {
    return {
      id: null,
      champ: meta.champ || null,
      nom_fichier: meta.nom_fichier || null,
      chemin_fichier: meta.chemin_fichier || null,
      type_fichier: meta.type_fichier || null,
      taille_fichier: meta.taille_fichier || null,
    };
  });
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
  saveUploads: saveUploads,
  findById: findById,
};
