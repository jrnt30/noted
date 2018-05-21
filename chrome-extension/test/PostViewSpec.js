// Load up fixtures from a custom path
jasmine.getFixtures().fixturesPath = 'base/test/fixtures';

// Custom event triggering mechanisms
function fireEvent(evtStr, el) {
  var evt = new Event(evtStr);
  el.dispatchEvent(evt);
}

describe('A post view', function() {
  var post, user, oldChrome;
  beforeEach(function() {
    oldChrome = TestHelpers.mockChromeStorage();
    user = new SB.User({
      name: 'Jonathan',
      email: 'j@example.com',
      serviceUrl: 'localhost'
    });
    post = new SB.Post({
      url: 'foo',
      title: 'bar',
      favIconUrl: 'baz'
    }, user, {});
    loadFixtures('post.html');
  });
  afterEach(function() {
    window.chrome = oldChrome;
  });

  it('should have a constructor that expects a Post', function() {
    var error;
    try {
      new SB.PostView();
    } catch (e) {
      error = e;
    } finally {
      expect(error).toBeDefined();
      expect(error.message).toBe('Post View requires a post!');
    }

    error = undefined;
    try {
      new SB.PostView('foo');
    } catch (e) {
      error = e;
    } finally {
      expect(error).toBeDefined();
      expect(error.message).toBe('Post View requires a post!');
    }

    error = undefined;
    try {
      new SB.PostView(post);
    } catch (e) {
      error = e;
    } finally {
      expect(error).toBeUndefined();
    }
  });

  it('should cache DOM objects on initialization', function() {
    var domSpy = spyOn(document, 'getElementById').and.callThrough();
    var postView = new SB.PostView(post);
    expect(domSpy).toHaveBeenCalled();
    expect(domSpy.calls.count()).toEqual(6);
  });

  it('should initialize values based on the tab', function() {
    var postView = new SB.PostView(post);
    expect($j('#title').val()).toEqual(post.title);
    expect($j('#favicon').attr('src')).toEqual(post.faviconUrl);
  });

  it('should update the post object when the title changes', function() {
    var postView = new SB.PostView(post);
    fireEvent('input', $j(postView.titleInput).val('foo')[0]);

    expect(post.title).toEqual('foo');
  });

  it('should update the post object when the description changes', function() {
    var postView = new SB.PostView(post);
    fireEvent('input', $j(postView.descriptionTextarea).val('foo')[0]);

    expect(post.description).toEqual('foo');
  });

  it('should try to submit a post when the post button is clicked', function() {
    var postView = new SB.PostView(post);
    var sendPostSpy = spyOn(post, 'sendPost');
    fireEvent('click', $j('#post')[0]);

    expect(sendPostSpy).toHaveBeenCalled();
  });

  it('should try to close the window on a successful post', function() {
    var spy = spyOn(window, 'close');

    var fakeServer = sinon.fakeServer.create();
    fakeServer.respondWith([200, {}, '']);

    var postView = new SB.PostView(post);
    fireEvent('click', $j('#post')[0]);

    fakeServer.respond();
    expect(spy).toHaveBeenCalled();
    fakeServer.restore();

  });

  it('should display an error on unsucessful post', function() {
    var fakeServer = sinon.fakeServer.create();
    fakeServer.respondWith([500, {}, 'It Broke.']);

    var postView = new SB.PostView(post);
    fireEvent('click', $j('#post')[0]);
    fakeServer.respond();
    fakeServer.restore();

    expect(postView.flashMessageEl.textContent).toEqual('Error: It Broke.');
  });
});
