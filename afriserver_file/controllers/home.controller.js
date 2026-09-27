var apiResponse = require('../utils/apiResponse');

function welcome(req, res) {
  return apiResponse.success(res, 'AfriNumber file service.', {
    service: 'afriserver_file',
    endpoints: {
      health: 'GET /health',
      upload: 'POST /files/upload',
      show: 'GET /files/:id',
    },
  });
}

module.exports = {
  welcome: welcome,
};
