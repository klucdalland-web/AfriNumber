var express = require('express');
var healthRoutes = require('./health.routes');
var filesRoutes = require('./files.routes');
var homeController = require('../controllers/home.controller');

var router = express.Router();

router.get('/', homeController.welcome);
router.use('/health', healthRoutes);
router.use('/files', filesRoutes);

module.exports = router;
