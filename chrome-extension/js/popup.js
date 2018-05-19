var SB = window.SB || {};

document.addEventListener('DOMContentLoaded', function () {
  SB.UserService.getUserFromOptions(function(currentUser) {
    if(currentUser.isComplete()) {
      //Show the UI
      document.getElementById('logged-in').style.display = "block";
      //Get tab specific information
      chrome.tabs.getSelected(function(tab) {
        SB.LocalStorage.get(tab.url, function(obj) {
          var savedPost = obj || {};
          var post = new SB.Post(tab, currentUser, savedPost);
          SB.postView = new SB.PostView(post);
        });
      });
    } else {
      //Show the not logged in message and update the link
      document.getElementById('not-logged-in').style.display = "block";
      document.getElementById('login').addEventListener('click', function(){
        chrome.runtime.sendMessage({
          type: "authenticate"
        });
      });
    }
  });
});
