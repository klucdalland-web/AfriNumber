require('dotenv').config();
var path = require('path');
var config = {
    env: process.env.NODE_ENV || 'development',
    port: parseInt(process.env.PORT || '3000', 10),
    storagePath: process.env.STORAGE_PATH ?
        path.resolve(process.env.STORAGE_PATH) : path.join(__dirname, '..', 'storage', 'uploads'),
    maxFileSize: parseInt(process.env.MAX_FILE_SIZE || String(5 * 1024 * 1024), 10),
    laravelBaseUrl: process.env.LARAVEL_BASE_URL || 'https://afriserver.onrender.com/api/v1',
    serviceSecretKey: process.env.SERVICE_SECRET_KEY,
};

module.exports = config;