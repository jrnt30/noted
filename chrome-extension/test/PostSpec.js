describe('A Post', function() {
  it('should require a configuration object', function() {
    var error;
    try {
      new SB.Post();
    } catch (e) {
      error = e;
    } finally {
      expect(error).toBeDefined();
    }
  });

  it('should use a conf object to initialize values alongside defaults', function() {
    var user = new SB.User();
    var post = new SB.Post({
      url: 'foo',
      title: 'bar',
      favIconUrl: 'baz'
    }, user, {});

    expect(post.url).toBe('foo');
    expect(post.title).toBe('bar');
    expect(post.faviconUrl).toBe('baz');
    expect(post.description).toBe('');
    expect(post.user).toBe(user);
  });


  describe('Submission', function () {
    var post, fakeServer, user;

    beforeEach(function() {
      user = new SB.User({
        token: 'token',
        serviceUrl: 'localhost'
      });
      post = new SB.Post({
        url: 'foo',
        title: 'bar',
        faviconUrl: 'baz'
      }, user, {});

      fakeServer = sinon.fakeServer.create();
    });

    afterEach(function() {
      post = null;
      user = null;

      fakeServer.restore();
    });

    it('should have a getLinkJson method', function() {
      expect(post.getLinkJson).toBeDefined();
      expect(typeof post.getLinkJson).toBe('function');
    });

    it('should create a json version in accordance with the API spec', function() {
      var linkJson = post.getLinkJson();
      expect(linkJson).toEqual({
        url: post.url,
        userTitle: post.title,
        userDescription: post.description,
      });
    });

    it('should have a sendPost method', function() {
      expect(post.sendPost).toBeDefined();
      expect(typeof post.sendPost).toBe('function');
    });

    it('should have a stub onSuccess method', function() {
      expect(post.onSuccess).toBeDefined();
      expect(typeof post.onSuccess).toBe('function');
    });
    it('should have a stub onError method', function() {
      expect(post.onError).toBeDefined();
      expect(typeof post.onError).toBe('function');
    });

    it('should make an http request', function() {
      var spy = spyOn(post, 'afterPost');
      fakeServer.respondWith('foo');
      post.sendPost();
      fakeServer.respond();

      expect(spy).toHaveBeenCalled();
    });
    it('should call onSuccess if the request was successful', function() {
      var spy = spyOn(post, 'onSuccess');

      fakeServer.respondWith([200, {}, '']);
      post.sendPost();
      fakeServer.respond();

      expect(spy).toHaveBeenCalled();
    });

    it('should call onError if the response fails', function() {
      var spy = spyOn(post, 'onError');

      fakeServer.respondWith([500, {}, 'It broke.']);
      post.sendPost();
      fakeServer.respond();

      expect(spy).toHaveBeenCalled();
    });
  });
});
