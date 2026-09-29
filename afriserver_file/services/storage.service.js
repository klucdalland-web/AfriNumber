var { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
var config = require('../config');

var s3 = new S3Client({
    region: 'us-1',
    endpoint: config.storjEndpoint,
    forcePathStyle: true,
    credentials: {
        accessKeyId: config.storjAccessKey,
        secretAccessKey: config.storjSecretKey
    }
});
var EXTENSIONS = {
    'image/jpeg': '.jpg',
    'image/jpg': '.jpg',
    'image/png': '.png',
    'image/webp': '.webp',
    'image/heic': '.heic',
    'image/heif': '.heif'
};
async function envoyerDocument(idprofile, champ, buffer, mimetype) {
    var ext = EXTENSIONS[mimetype];
    if (!ext) throw new Error('Type de fichier non autorisé : ' + mimetype);

    var remotePath = `${idprofile}/${champ}${ext}`;

    await s3.send(new PutObjectCommand({
        Bucket: config.storjBucket,
        Key: remotePath,
        Body: buffer,
        ContentType: mimetype
    }));

    return remotePath;
}

module.exports = { envoyerDocument: envoyerDocument };