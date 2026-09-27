var healthService = require('../services/health.service');
var apiResponse = require('../utils/apiResponse');

function check(req, res, next) {
  try {
    var data = healthService.check();
    return apiResponse.success(res, 'Service opérationnel.', data);
  } catch (err) {
    return next(err);
  }
}

module.exports = {
  check: check,
};
