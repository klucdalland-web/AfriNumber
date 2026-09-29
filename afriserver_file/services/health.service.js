var config = require('../config');

function getStatus() {
    // Le stockage est distant (Storj) : on vérifie que la configuration est présente,
    // sans appel réseau, pour que la route de santé reste rapide.
    var storageConfigured = Boolean(
        config.storjEndpoint &&
        config.storjAccessKey &&
        config.storjSecretKey &&
        config.storjBucket
    );

    return {
        status: 'ok',
        timestamp: new Date().toISOString(),
        storageConfigured: storageConfigured,
    };
}

module.exports = {
    getStatus: getStatus,
};