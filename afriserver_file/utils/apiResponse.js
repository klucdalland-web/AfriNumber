function success(res, message, data, status) {
  var code = status || 200;
  return res.status(code).json({
    success: true,
    message: message,
    data: data !== undefined ? data : null,
  });
}

function error(res, message, errors, status) {
  var code = status || 400;
  return res.status(code).json({
    success: false,
    message: message,
    errors: errors || null,
  });
}

module.exports = {
  success: success,
  error: error,
};
