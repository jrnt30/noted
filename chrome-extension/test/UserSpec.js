describe('A User', function(){
  it('should instantiate with defaults', function(){
    var emptyUser = new SB.User();
    expect(emptyUser.token).toBe('');
    expect(emptyUser.serviceUrl).toBe('');
  });
  it('should take a configuration object', function(){
    var user = new SB.User({
      token: 'token',
      serviceUrl: 'foo'
    });

    expect(user.token).toBe('token');
    expect(user.serviceUrl).toBe('foo');
  });
  it('should have an isComplete function', function(){
    var user = new SB.User();

    expect(user.isComplete).toBeDefined();
    expect(typeof user.isComplete).toBe('function');
  });
});
