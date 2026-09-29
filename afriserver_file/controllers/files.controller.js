var filesService = require('../services/files.service');
var apiResponse = require('../utils/apiResponse');
var uploadMiddleware = require('../middlewares/upload');
var FILE_FIELDS = uploadMiddleware.FILE_FIELDS;
const { notifierFinTraitement } = require('../services/notification.service');

function mapFile(fieldName, file) {
    if (!file) {
        return null;
    }

    return {
        champ: fieldName,
        nom_fichier: file.originalname,
        chemin_fichier: file.path,
        type_fichier: file.mimetype,
        taille_fichier: file.size,
    };
}

async function upload(req, res, next) {
    try {
        var idprofile = req.body.idprofile;
        if (!idprofile) {
            return apiResponse.error(
                res,
                'Le champ idprofile est requis (lettres, chiffres, _ ou - uniquement).',
                null,
                400
            );
        }

        var files = req.files || {};
        var received = [];
        var missing = [];

        FILE_FIELDS.forEach(function(field) {
            var list = files[field.name];
            if (list && list[0]) {
                received.push(mapFile(field.name, list[0]));
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

        var payload = {
            idprofile: idprofile,
            dossier: req.uploadDir || null,
            fichiers: received,
        };

        const statusResult = await notifierFinTraitement(idprofile);

        if (!statusResult) {
            return apiResponse.error(
                res,
                'Probleme au niveau du serveur Veuillez reessayer plus tard.',
                null,
                500
            );
        }

        var data = filesService.upload(payload);
        return apiResponse.success(
            res,
            'Fichiers reçus. traitement en cours.',
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