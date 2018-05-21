var SB = window.SB || {};

SB.PostView = (function() {
  function PostView(post) {
    if(!post || !(post instanceof SB.Post)) {
      throw new Error('Post View requires a post!');
    }

    this.post = post;

    //Attach some listeners to the post data
    post.addSuccessListener(this.successfulPost.bind(this));
    post.addErrorListener(this.errorPosting.bind(this));

    // Cache DOM elements for easier lookup
    this.faviconImg = document.getElementById('favicon');
    this.urlInput = document.getElementById('url');
    this.titleInput = document.getElementById('title');
    this.descriptionTextarea = document.getElementById('description');
    this.flashMessageEl = document.getElementById('flash-message');
    this.postButton = document.getElementById('post');

    // Initialize DOM contents
    this.titleInput.value = this.post.title;
    this.descriptionTextarea.value = this.post.description;
    this.faviconImg.src = this.post.faviconUrl;

    //Add event listeners
    this.titleInput.addEventListener('input', this.updateTitle.bind(this));
    this.descriptionTextarea.addEventListener('input', this.updateDescription.bind(this));
    this.postButton.addEventListener('click', this.initiatePost.bind(this));
  }

  PostView.prototype.updateTitle = function updateTitle() {
    this.post.set('title', this.titleInput.value);
  };

  PostView.prototype.updateDescription = function updateDescription() {
    this.post.set('description', this.descriptionTextarea.value);
  };

  PostView.prototype.initiatePost = function initiatePost() {
    this.postButton.setAttribute('disabled', 'disabled');
    this.postButton.value = 'Posting...';
    this.post.sendPost();
  };

  PostView.prototype.successfulPost = function successfulPost() {
    window.close();
  };

  PostView.prototype.errorPosting = function errorPosting(errorMessage) {
    var msg = errorMessage;
    this.postButton.removeAttribute('disabled');
    this.postButton.value = 'Post';
    try {
      msg = JSON.parse(errorMessage).message;
    } catch(e) {}
    this.flashMessageEl.textContent = 'Error: ' + msg;
  };

  return PostView;
}());
