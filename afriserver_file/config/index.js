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

    // Rate limit upload (IP) — n'empêche pas le boot si absent
    uploadRateLimitWindowMs: parseInt(process.env.UPLOAD_RATE_LIMIT_WINDOW_MS || String(15 * 60 * 1000), 10),
    uploadRateLimitMax: parseInt(process.env.UPLOAD_RATE_LIMIT_MAX || '10', 10),

    // Stockage Storj (compatible S3)
    storjEndpoint: process.env.STORJ_ENDPOINT || 'https://gateway.storjshare.io',
    storjAccessKey: process.env.STORJ_ACCESS_KEY,
    storjSecretKey: process.env.STORJ_SECRET_KEY,
    storjBucket: process.env.STORJ_BUCKET,
};

// Le serveur refuse de démarrer si un secret obligatoire manque
['serviceSecretKey', 'storjAccessKey', 'storjSecretKey', 'storjBucket'].forEach(function(key) {
    if (!config[key]) {
        throw new Error('Variable de configuration manquante : ' + key);
    }
});

module.exports = config;