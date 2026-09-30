var express = require('express');
var filesController = require('../controllers/files.controller');
var upload = require('../middlewares/upload');
var rateLimit = require('../middlewares/rateLimit');

var router = express.Router();

// Rate limit AVANT multer pour couper le spam tôt
router.post(
    '/upload',
    rateLimit.uploadRateLimiter,
    upload.fieldsMiddleware,
    filesController.upload
);
router.get('/:id', filesController.show);

module.exports = router;