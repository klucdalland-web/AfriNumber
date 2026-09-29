var express = require('express');
var filesController = require('../controllers/files.controller');
var upload = require('../middlewares/upload');

var router = express.Router();

router.post('/upload', upload.fieldsMiddleware, filesController.upload);
router.get('/:id', filesController.show);

module.exports = router;