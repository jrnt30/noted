var SB = window.SB || {};

SB.UserService = (function() {
  function getUserFromOptions(cb) {
    chrome.storage.sync.get({
      token: '',
      serviceUrl: env.SERVICE_DOMAIN
    },function(item) {
      var user = new SB.User(item);
      cb(user);
    });
  }

  return {
    getUserFromOptions: getUserFromOptions
  };
}());
