var SB = window.SB || {};

SB.LocalStorage = {
  set: function set(key, val) {
    var localLink = {};
    localLink[key] = val;
    chrome.storage.local.set(localLink, function() {
      if(chrome.runtime.lastError)
      {
          /* error */
          console.log("Error saving data to local storage");
          console.log(chrome.runtime.lastError.message);
          return;
      } else {
        console.log("Saved a local copy.");
      }
    });
  },

  get: function get(key, cb) {
    chrome.storage.local.get(key, function(obj) {
      if(cb) {
        console.log("Executing cb with");
        console.log(obj[key]);
        return cb(obj[key]);
      } else {
        console.log("No getter function defined");
        console.log(obj[key]);
      }
    });
  },

  remove: function remove(key) {
    chrome.storage.local.remove(key, function() {
      console.log("Removed locally saved link");
    });
  }
};
