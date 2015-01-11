if (Meteor.isClient) {

  // youtubeBackend = new MusicPlayer.backends.youtube({
  //
  // });

  musicPlayer = new MusicPlayer({
    backends: ['youtube','soundcloud']
  });

  Template.hello.events({
    'click [data-action="load"]': function () {
      var song = {url:"/tracks/293", backend:"soundcloud"};
      musicPlayer.addToQueue(song);
    },
    'click [data-action="loadYT"]': function() {
      var song = {url:"Of-lpfsBR8U", backend:"youtube"};
      musicPlayer.addToQueue(song)
    },
    'click [data-action="loadYT2"]': function() {
      var song = {url:"dFlE7_6hKUE", backend:"youtube"};
      musicPlayer.addToQueue(song);
    }
  });

  var dragging = false;

  Template.player.rendered =function () {
    var el = this.find('.player-slider input[type="range"]');
    el.addEventListener('input', function (e) {
      dragging = true;
    });
    el.addEventListener('change', function (e) {
      dragging = false;
      musicPlayer.seekTo(this.value);
    });

    Tracker.autorun(function () {
      var pos = musicPlayer.getPosition();
      if (!dragging)
        el.value = pos;
      });

    Tracker.autorun(function () {
      var dur = musicPlayer.getDuration();
      el.max = dur;
    });
  };

  Template.player.helpers({
    statusIs :  function (str) {
      var status = musicPlayer.getStatus();
      return status == str;
    },

    title :  function () {
      return musicPlayer.getTitle();
    },

    artwork_url :  function () {
      return musicPlayer.getArtwork();
    },

    duration :  function () {
      return musicPlayer.getDuration(true);
    },

    remaining :  function () {
      return musicPlayer.getRemaining();
    },

    status :  function() {
      return musicPlayer.getStatus();
    },

    queuedSongs: function() {
      return musicPlayer.getQueue();
    },

    //for example, disable some interface components while loading track
    isLoading: function() {
      return (musicPlayer.getStatus() === musicPlayer.PlayerState.LOADING);
    },

    getMuted: function() {
      return musicPlayer.getMuted();
    }
  });

  Template.player.events({
    'click .player-pause': function () {
      musicPlayer.pause();
    },
    'click .player-play': function () {
      musicPlayer.play();
    },
    'click .player-next': function () {
      musicPlayer.next();
    },
    'click .player-prev': function () {
      musicPlayer.prev();
    },
    'click .player-mute': function() {
      musicPlayer.mute();
    },
    'click .song-play': function() {
      musicPlayer.play(this.index);
    }
  });
}
