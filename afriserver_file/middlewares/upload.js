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

function fileFilter(req, file, cb) {
    var ext = path.extname(file.originalname).toLowerCase();

    if (ALLOWED_MIME_TYPES[file.mimetype] && ALLOWED_EXTENSIONS[ext]) {
        return cb(null, true);
    }

    var err = new Error('Format non autorisé. Formats acceptés : jpg, jpeg, png, webp, heic, heif.');
    err.status = 400;
    err.code = 'INVALID_FILE_TYPE';
    return cb(err);
}

// Les fichiers restent en mémoire (req.files[champ][0].buffer), rien n'est écrit sur le disque
var upload = multer({
    storage: multer.memoryStorage(),
    limits: {
        fileSize: config.maxFileSize,
        files: FILE_FIELDS.length,
    },
    fileFilter: fileFilter,
});

module.exports = upload;
module.exports.FILE_FIELDS = FILE_FIELDS;
module.exports.fieldsMiddleware = upload.fields(FILE_FIELDS);