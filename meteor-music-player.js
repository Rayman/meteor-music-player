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
      soundcloudBackend.load(url);
    },
  });

  Template.player.statusIs = function (str) {
    var status = soundcloudBackend.status();
    console.log('status', status);
    return status == str;
  };

  Template.player.title = function () {
    return soundcloudBackend.title();
  };

  Template.player.artwork_url = function () {
    return soundcloudBackend.artwork_url();
  };

  var dragging = false;
  Template.player.rendered = function () {
    var el = this.find('.player-slider input[type="range"]');
    el.addEventListener('input', function (e) {
      dragging = true;
    });
    el.addEventListener('change', function (e) {
      dragging = false;
      soundcloudBackend.seekTo(this.value);
    });

    Deps.autorun(function () {
      var pos = soundcloudBackend.getPosition();
      if (!dragging)
        el.value = pos;
    });

    Deps.autorun(function () {
      var dur = soundcloudBackend.getDuration();
      el.max = dur;
    });
  };

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
      console.log('pause', soundcloudBackend.pause);
      soundcloudBackend.pause();
    },
    'click .player-play': function () {
      console.log('play');
      soundcloudBackend.play();
    },
  });
}
