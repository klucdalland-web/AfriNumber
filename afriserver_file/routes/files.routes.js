var express = require('express');
var filesController = require('../controllers/files.controller');

var router = express.Router();

router.post('/upload', filesController.upload);
router.get('/:id', filesController.show);

module.exports = router;
