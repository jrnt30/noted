describe('The User Service', function() {
  var oldChrome;
  beforeEach(function() {
    oldChrome = TestHelpers.mockChromeStorage();
  });

  afterEach(function() {
    window.chrome = oldChrome;
  });

  it('should have a getUserFromOptions method', function () {
    expect(SB.UserService.getUserFromOptions).toBeDefined();
    expect(typeof SB.UserService.getUserFromOptions).toBe('function');
  });

  it('should retrieve user data from the chrome storage api', function() {
    var getSpy = spyOn(chrome.storage.sync, 'get');
    SB.UserService.getUserFromOptions(function(){});
    expect(getSpy).toHaveBeenCalled();
  });

  it('should create a new user based on the returned values', function() {
    SB.UserService.getUserFromOptions(function(user) {
      expect(user).toBeDefined();
      expect(user.token).toBe('token');
      expect(user.serviceUrl).toBe('localhost');
    });
  });
});
