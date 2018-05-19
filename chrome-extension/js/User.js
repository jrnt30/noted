var SB = window.SB || {};

SB.User = (function() {
  function User(obj) {
    this.serviceUrl = obj && obj.serviceUrl || '';
    this.token = obj && obj.token || '';
  }

  User.prototype.validToken = function validToken() {
    return this.token && jwt_decode(this.token).exp > Date.now() / 1000;
  }

  User.prototype.isComplete = function isComplete() {
    return this.serviceUrl && this.validToken();
  };

  return User;
}());
