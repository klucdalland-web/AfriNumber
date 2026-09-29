var crypto = require('crypto');
var axios = require('axios');
var config = require('../config');

async function notifierFinTraitement(idprofile) {
    var urlLaravel = `${config.laravelBaseUrl}/express/upload-complete`;

    if (!config.serviceSecretKey) throw new Error('SERVICE_SECRET_KEY manquant');

    // Le body est sérialisé une seule fois : c'est cette chaîne qui est signée ET envoyée
    var data = JSON.stringify({ profile_id: idprofile });

    var signature = crypto
        .createHmac('sha256', config.serviceSecretKey)
        .update(data)
        .digest('hex');

    var axiosConfig = {
        method: 'post',
        maxBodyLength: Infinity,
        url: urlLaravel,
        headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-Signature': signature
        },
        data: data // string brute, axios ne la re-sérialise pas
    };

    console.log(`[Express -> Laravel] Envoi de la notification pour le profil : ${idprofile}`);

    try {
        var response = await axios.request(axiosConfig);
        console.log('[Express -> Laravel] ✅ Réponse reçue :', JSON.stringify(response.data));
        return { ok: true, status: response.status };
    } catch (error) {
        var status = error.response ? error.response.status : null;
        var detail = error.response ? error.response.data : error.code;
        console.error('[Express -> Laravel] ❌ Erreur lors de la notification :', status, JSON.stringify(detail));
        return { ok: false, status: status };
    } finally {
        console.log(`[Express -> Laravel] Notification terminée pour le profil : ${idprofile}`);
    }
}

module.exports = { notifierFinTraitement: notifierFinTraitement };