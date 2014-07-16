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
    return status == str;
  };

  Template.player.title = function () {
    return soundcloudBackend.title();
  };

  Template.player.artwork_url = function () {
    return soundcloudBackend.artwork_url();
  };

  Template.player.rendered = function () {
    var el = this.find('.player-slider input[type="range"]');

    Deps.autorun(function () {
      var pos = soundcloudBackend.getPosition();
      el.value = pos;
    });

    Deps.autorun(function () {
      var dur = soundcloudBackend.getDuration();
      el.max = dur;
    });
  };

  /*
  Deps.autorun(function () {
    var pos = soundcloudBackend.getPosition();
    // console.log(pos);
  });
  */

  Template.player.duration = function () {
    var duration =  soundcloudBackend.getDuration();
    duration = moment.duration(duration, 'ms');
    var time = moment.utc(duration.asMilliseconds());
    if (duration.asHours() >= 1) {
      return time.format('HH:mm:ss');
    } else {
      return time.format('mm:ss');
    }
  };

  Template.player.remaining = function () {
    var duration = soundcloudBackend.getDuration() - soundcloudBackend.getPosition();
    duration = moment.duration(duration, 'ms');
    var time = moment.utc(duration.asMilliseconds());
    if (duration.asHours() >= 1) {
      return time.format('HH:mm:ss');
    } else {
      return time.format('mm:ss');
    }
  };

  Template.player.events({
    'click .player-pause': function () {
      console.log('pause');
      soundcloudBackend.pause();
    },
    'click .player-play': function () {
      console.log('play');
      soundcloudBackend.play();
    },
  });
}
