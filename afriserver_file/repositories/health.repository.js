var fs = require('fs');
var config = require('../config');

function getStatus() {
  var storageReady = false;

  try {
    fs.accessSync(config.storagePath, fs.constants.W_OK);
    storageReady = true;
  } catch (err) {
    storageReady = false;
  }

  return {
    status: 'ok',
    timestamp: new Date().toISOString(),
    storagePath: config.storagePath,
    storageReady: storageReady,
  };
}

module.exports = {
  getStatus: getStatus,
};
