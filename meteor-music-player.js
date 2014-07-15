if (Meteor.isClient) {

  youtubeBackend = new MusicPlayer.backends.youtube({

  });

  soundcloudBackend = new MusicPlayer.backends.soundcloud({

  }).init();

  musicPlayer = new MusicPlayer({
    backends: 'youtube',
  });

  Template.hello.events({
    'click button': function () {
      var url = "/tracks/293"
      console.log('loading', url);
      soundcloudBackend.load(url);
    },
  });

  Template.player.statusIs = function (str) {
    var status = soundcloudBackend.status();
    console.log('status changed:', status);
    return status == str;
  };

  Template.player.title = function () {
    return soundcloudBackend.title();
  };

  Template.player.artwork_url = function () {
    return soundcloudBackend.artwork_url();
  };

  Template.player.position = function () {
    return soundcloudBackend.getPosition();
  };

  Template.player.events({
    'click player-pause': function () {
      soundcloudBackend.pause();
    },
    'click player-play': function () {
      soundcloudBackend.play();
    },
  });
}
