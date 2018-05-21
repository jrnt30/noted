var saveOptions = function() {
  // var token = document.getElementById('token').value;
  var serviceUrl = document.getElementById('back-end').value;

  chrome.storage.sync.set({
    // token: token,
    serviceUrl: serviceUrl
  }, function() {
    window.close();
  });
};

var restoreOptions = function() {
  console.log("Calling restore options")
  console.log(env)
  chrome.storage.sync.get({
    // token: 'TEST_TOKEN',
    serviceUrl: env.SERVICE_DOMAIN,
  }, function(items) {
    // document.getElementById('token').value = items.token;
    document.getElementById('back-end').value = items.serviceUrl;
  });
};

document.addEventListener('DOMContentLoaded', restoreOptions);
document.getElementById('save').addEventListener('click', saveOptions);
