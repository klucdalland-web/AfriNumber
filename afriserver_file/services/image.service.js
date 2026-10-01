var sharp = require('sharp');
var convert = require('heic-convert');

var MAX_DIMENSION = 2000; // px, côté le plus long
var JPEG_QUALITY = 82;

/**
 * Détecte HEIC/HEIF via mimetype ou signature ISO BMFF (ftyp…).
 */
function estHeic(buffer, mimetype) {
    if (mimetype === 'image/heic' || mimetype === 'image/heif') {
        return true;
    }

    if (!Buffer.isBuffer(buffer) || buffer.length < 12) {
        return false;
    }

    if (buffer.toString('ascii', 4, 8) !== 'ftyp') {
        return false;
    }

    var brands = buffer.toString('ascii', 8, Math.min(buffer.length, 24)).toLowerCase();
    return /heic|heif|mif1|msf1|heix|hevc|heim|heis/.test(brands);
}

async function convertirHeicEnJpeg(buffer) {
    var output = await convert({
        buffer: buffer,
        format: 'JPEG',
        quality: 0.9,
    });

    return Buffer.from(output);
}

/**
 * Compresse une image (JPEG/PNG/WebP/HEIC) en JPEG normalisé.
 * @param {Buffer} buffer
 * @param {string} [mimetype]
 */
async function compresserImage(buffer, mimetype) {
    try {
        var input = buffer;

        if (estHeic(buffer, mimetype)) {
            console.log('[Image] HEIC/HEIF détecté → conversion JPEG avant compression');
            input = await convertirHeicEnJpeg(buffer);
        }

        var output = await sharp(input, { limitInputPixels: 50000000 })
            .rotate() // applique l'orientation EXIF avant de la retirer
            .resize({
                width: MAX_DIMENSION,
                height: MAX_DIMENSION,
                fit: 'inside',
                withoutEnlargement: true,
            })
            .flatten({ background: '#ffffff' }) // PNG transparent -> fond blanc
            .jpeg({ quality: JPEG_QUALITY, mozjpeg: true })
            .toBuffer();

        return { buffer: output, mimetype: 'image/jpeg' };
    } catch (e) {
        console.error('[Image] Échec compression :', e.message);
        var err = new Error(
            'Image illisible ou format non pris en charge. Formats acceptés : JPEG, PNG, WebP, HEIC.'
        );
        err.status = 400;
        err.code = 'INVALID_IMAGE';
        throw err;
    }
}

module.exports = {
    compresserImage: compresserImage,
    estHeic: estHeic,
};
