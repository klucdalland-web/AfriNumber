var filesService = require('../services/files.service');
var apiResponse = require('../utils/apiResponse');
var uploadMiddleware = require('../middlewares/upload');
var FILE_FIELDS = uploadMiddleware.FILE_FIELDS;
var storageService = require('../services/storage.service');
var imageService = require('../services/image.service');
const { notifierFinTraitement } = require('../services/notification.service');

var UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

async function upload(req, res, next) {
    try {
        var idprofile = req.body.idprofile;
        if (!idprofile || !UUID_RE.test(idprofile)) {
            return apiResponse.error(res, 'idprofile invalide (UUID attendu).', null, 400);
        }

        var files = req.files || {};
        var received = [];
        var missing = [];

        FILE_FIELDS.forEach(function(field) {
            var list = files[field.name];
            if (list && list[0]) {
                received.push({ champ: field.name, file: list[0] });
            } else {
                missing.push(field.name);
            }
        });

        if (missing.length > 0) {
            return apiResponse.error(
                res,
                'Fichiers manquants : ' + missing.join(', ') + '.', { missing: missing },
                400
            );
        }

        // 1. Compression puis envoi direct vers Storj (depuis la mémoire)
        var documents = await Promise.all(received.map(async function(item) {
            var image = await imageService.compresserImage(item.file.buffer, item.file.mimetype);
            console.log('[Upload] ' + item.champ + ' : ' + item.file.size + ' -> ' + image.buffer.length + ' octets');

            var remotePath = await storageService.envoyerDocument(
                idprofile, item.champ, image.buffer, image.mimetype
            );
            return { champ: item.champ, path: remotePath };
        }));

        // 2. Ensuite seulement, on prévient Laravel
        var result = await notifierFinTraitement(idprofile, documents);

        if (!result.ok) {
            if (result.status === 422 || result.status === 404) {
                return apiResponse.error(res, 'Profil introuvable ou invalide.', null, 400);
            }
            return apiResponse.error(res, 'Problème au niveau du serveur. Veuillez réessayer plus tard.', null, 500);
        }

        return apiResponse.success(
            res,
            'Fichiers reçus. Traitement en cours.', { idprofile: idprofile, champs: documents.map(function(d) { return d.champ; }) },
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