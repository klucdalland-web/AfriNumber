var sharp = require('sharp');

var MAX_DIMENSION = 2000; // px, côté le plus long
var JPEG_QUALITY = 82;

async function compresserImage(buffer) {
    try {
        var output = await sharp(buffer, { limitInputPixels: 50000000 })
            .rotate() // applique l'orientation EXIF avant de la retirer
            .resize({
                width: MAX_DIMENSION,
                height: MAX_DIMENSION,
                fit: 'inside',
                withoutEnlargement: true
            })
            .flatten({ background: '#ffffff' }) // PNG transparent -> fond blanc
            .jpeg({ quality: JPEG_QUALITY, mozjpeg: true })
            .toBuffer();

        return { buffer: output, mimetype: 'image/jpeg' };
    } catch (e) {
        var err = new Error('Image illisible ou format non pris en charge. Envoyez une photo en JPEG ou PNG.');
        err.status = 400;
        err.code = 'INVALID_IMAGE';
        throw err;
    }
}

module.exports = { compresserImage: compresserImage };