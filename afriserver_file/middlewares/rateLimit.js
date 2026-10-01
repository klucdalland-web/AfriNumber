var rateLimit = require('express-rate-limit');
var apiResponse = require('../utils/apiResponse');
var config = require('../config');

function secondesRestantes(req) {
    var resetTime = req.rateLimit && req.rateLimit.resetTime;
    if (resetTime instanceof Date) {
        return Math.max(1, Math.ceil((resetTime.getTime() - Date.now()) / 1000));
    }
    return Math.ceil(config.uploadRateLimitWindowMs / 1000);
}

/**
 * Limite les uploads KYC par IP.
 * Défaut : 10 requêtes / 15 minutes (surchargeable via env).
 */
var uploadRateLimiter = rateLimit({
    windowMs: config.uploadRateLimitWindowMs,
    max: config.uploadRateLimitMax,
    standardHeaders: true,
    legacyHeaders: false,
    handler: function(req, res) {
        var retryAfter = secondesRestantes(req);
        res.set('Retry-After', String(retryAfter));

        return apiResponse.error(
            res,
            'Trop de tentatives d\'upload. Réessayez plus tard.',
            { retry_after_seconds: retryAfter },
            429
        );
    },
});

module.exports = {
    uploadRateLimiter: uploadRateLimiter,
};
