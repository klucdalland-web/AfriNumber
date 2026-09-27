var express = require('express');
var healthController = require('../controllers/health.controller');

var router = express.Router();

router.get('/', healthController.check);

module.exports = router;
