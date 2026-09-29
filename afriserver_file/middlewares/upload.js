var fs = require('fs');
var path = require('path');
var multer = require('multer');
var config = require('../config');

var FILE_FIELDS = [
    { name: 'photopath', maxCount: 1 },
    { name: 'pieceavantpath', maxCount: 1 },
    { name: 'piecearrierepath', maxCount: 1 },
];

var ALLOWED_MIME_TYPES = {
    'image/jpeg': true,
    'image/jpg': true,
    'image/png': true,
    'image/webp': true,
    'image/heic': true,
    'image/heif': true,
};

var ALLOWED_EXTENSIONS = {
    '.jpg': true,
    '.jpeg': true,
    '.png': true,
    '.webp': true,
    '.heic': true,
    '.heif': true,
};

if (!fs.existsSync(config.storagePath)) {
    fs.mkdirSync(config.storagePath, { recursive: true });
}



function resolveProfileDir(idprofile) {
    return path.join(config.storagePath, idprofile);
}

var storage = multer.diskStorage({
    destination: function(req, file, cb) {
        var idprofile = (req.body.idprofile);
        if (!idprofile) {
            var err = new Error(
                'Le champ idprofile est requis et doit être envoyé avant les fichiers.'
            );
            err.status = 400;
            err.code = 'MISSING_IDPROFILE';
            return cb(err);
        }

        var dir = resolveProfileDir(idprofile);
        try {
            fs.mkdirSync(dir, { recursive: true });
            req.uploadDir = dir;
            req.idprofile = idprofile;
            return cb(null, dir);
        } catch (e) {
            return cb(e);
        }
    },
    filename: function(req, file, cb) {
        var ext = path.extname(file.originalname).toLowerCase();
        cb(null, file.fieldname + ext);
    },
});

function fileFilter(req, file, cb) {
    var ext = path.extname(file.originalname).toLowerCase();
    var mimeOk = ALLOWED_MIME_TYPES[file.mimetype];
    var extOk = ALLOWED_EXTENSIONS[ext];

    if (mimeOk && extOk) {
        return cb(null, true);
    }

    var err = new Error(
        'Format non autorisé. Formats acceptés : jpg, jpeg, png, webp, heic, heif.'
    );
    err.status = 400;
    err.code = 'INVALID_FILE_TYPE';
    return cb(err);
}

var upload = multer({
    storage: storage,
    limits: { fileSize: config.maxFileSize },
    fileFilter: fileFilter,
});

module.exports = upload;
module.exports.FILE_FIELDS = FILE_FIELDS;
module.exports.fieldsMiddleware = upload.fields(FILE_FIELDS);
module.exports.resolveProfileDir = resolveProfileDir;