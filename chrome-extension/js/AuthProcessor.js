
// Taken from the Auth0 Chrome example
// Responding to onMessage so that it can run in the background properly
chrome.runtime.onMessage.addListener(function (event) {
  if (event.type === 'authenticate') {

    // scope
    //  - openid if you want an id_token returned
    //  - offline_access if you want a refresh_token returned
    //  - profile if you want an additional claims like name, nickname, picture and updated_at.
    // device
    //  - required if requesting the offline_access scope.
    let options = {
      scope: 'openid profile offline_access',
      device: 'chrome-extension'
    };

    new Auth0Chrome(env.AUTH0_DOMAIN, env.AUTH0_CLIENT_ID)
      .authenticate(options)
      .then(function (authResult) {
        chrome.storage.sync.set({
          'authResult': authResult,
          'token': authResult.id_token
        });
      }).catch(function (err) {
        chrome.storage.sync.remove(['authResult', 'token']);
      });
  }
});
