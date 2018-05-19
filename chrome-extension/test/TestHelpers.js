function noop() {}

window.TestHelpers = {
  mockChromeStorage: function() {
    var oldChrome = window.chrome;
    window.chrome = {
      storage: {
        local: {
          get: function(){
            return {
              token: 'token',
              serviceUrl: 'localhost'
            };
          },
          set: noop,
          remove: noop
        },
        sync: {
          get: noop
        }
      }
    };

    return oldChrome;
  }
}
