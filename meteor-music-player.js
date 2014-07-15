if (Meteor.isClient) {

  youtubeBackend = new MusicPlayer.backends.youtube({

  });

  soundcloudBackend = new MusicPlayer.backends.soundcloud({

  })

  musicPlayer = new MusicPlayer({
    backends: 'youtube',
  });

  Template.player.statusIs = function (str) {
    var status = soundcloudBackend.status();
    console.log('status changed:', status);
    return status == str;
  }

  Template.player.events({
    'click player-pause': function () {
      soundcloudBackend.pause();
    },
    'click player-play': function () {
      soundcloudBackend.play();
    },
  });
}
