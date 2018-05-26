var SB = window.SB || {};

SB.Post = (function() {
  function Post(tab, user, savedPost) {
    if(!tab || !user) {
      throw new Error('Must pass a tab and user to create a post!');
    }

    this.url = tab.url;
    this.title = savedPost.userTitle || tab.title;
    this.faviconUrl = tab.favIconUrl;
    this.description = savedPost.userDescription || '';
    this.user = user;
    this.tab = tab;

    this.successListeners = [];
    this.errorListeners = [];
  }

  Post.prototype.addSuccessListener = function(listener) {
    if(typeof listener == "function") {
      this.successListeners.push(listener);
    } else {
      throw new Error("Listener must be a function!");
    }
  };

  Post.prototype.addErrorListener = function(listener) {
    if(typeof listener == "function") {
      this.errorListeners.push(listener);
    } else {
      throw new Error("Listener must be a function!");
    }
  };

  Post.prototype.set = function(key, val) {
    this[key] = val;
    this.localSave();
  };

  Post.prototype.sendPost = function() {
    var req = new XMLHttpRequest();
    req.open('POST', this.user.serviceUrl, true);
    req.setRequestHeader('Content-Type', 'application/json');
    req.setRequestHeader('Authorization', "Bearer " + this.user.token);
    req.onload = this.afterPost.bind(this);
    req.send(JSON.stringify(this.getLinkJson()));
  };

  Post.prototype.afterPost = function(res) {
    if(res.target.status == 200) {
      this.onSuccess();
    } else {
      this.onError(res.target.responseText);
    }
  };

  Post.prototype.localSave = function() {
    SB.LocalStorage.set(this.url, this.getLinkJson());
  };

  Post.prototype.clearLocalSave = function() {
    SB.LocalStorage.remove(this.url);
  };

  Post.prototype.onSuccess = function() {
    this.clearLocalSave();

    this.successListeners.forEach(function(listener) {
      listener();
    });
  };

  Post.prototype.onError = function(error) {
    this.errorListeners.forEach(function(listener) {
      listener(error);
    });
  };

  Post.prototype.getLinkJson = function() {
    return {
      url: this.url,
      userTitle: this.title,
      userDescription: this.description,
    };
  };
  return Post;
}());
