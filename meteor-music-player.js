if (Meteor.isClient) {

  musicPlayer = new MusicPlayer({
    backends: 'youtube',
  });

  Template.player.isPaused = function () {
    return musicPlayer.isPaused();
  }

  Template.hello.events({
    'click input': function () {
      // template data, if any, is available in 'this'
      if (typeof console !== 'undefined')
        console.log("You pressed the button");
    }
  });
}
