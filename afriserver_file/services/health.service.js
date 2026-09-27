var healthRepository = require('../repositories/health.repository');

function check() {
  return healthRepository.getStatus();
}

module.exports = {
  check: check,
};
