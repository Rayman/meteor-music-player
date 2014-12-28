class MusicPlayer
  constructor: (options = {}) ->
    @backends = options.backends ? [];

    @backend = new MusicPlayer.backend(); #start with dummy backend, prevents errors on load
    # console.log('constructor', this)

    @_statusDep = new Tracker.Dependency
    @_positionDep = new Tracker.Dependency

  load: (url, backend="soundcloud") ->
    if(@backend.name isnt backend)
      #"destroy/pause/deactivate" old backend
      #I'm just being polite here to call pause on the current backend, but we should maybe preserve
      #resources and do a little bit more cleaning before loading in the other backend
      do @pause

      #load new backend and play song
      @backends[backend] = new MusicPlayer.backends[backend]({parent: this, id: url}).init();
      @backend = @backends[backend]; #reference
    else
      @backend.load(url);
    return true;



  # Methods, these calls should all be wired to there respective backend call
  play: ->
    console.log "play"
    @backend.play();


  pause: ->
    console.log "pause #{ @pause }"
    @backend.pause();

  toggle: ->
    console.log "toggle"
    @backend.togglePause();

  mute: ->
    console.log "mute"
    throw new Error("Not implemented");

  next: ->
    console.log "next"
    throw new Error("Not implemented");

  prev: ->
    console.log "prev"
    throw new Error("Not implemented");

  seekTo: (pos) ->
    console.log "seekTo #{ pos }"
    @backend.seekTo(pos);

  setVolume: ->
    console.log "setVolume"
    throw new Error("Not implemented");

  # Getters
  getArtwork: -> #returns artwork url if available
    return @backend.artwork_url();

  getVolume: -> # returns the current volume, in the range of [0, 100].
    return 50;
    throw new Error("Not implemented");

  getDuration: -> # returns current sound duration in milliseconds.
    return @backend.getDuration();

  getPosition: -> # returns current sound position in milliseconds.
    @_positionDep.depend();
    return @backend.getPosition();

  getSounds: -> # returns the list of sound objects.
    throw new Error("Not implemented");

  getCurrentSound: -> # returns current sound object.
    throw new Error("Not implemented");

  getCurrentSoundIndex: -> # returns the index of current sound.
    throw new Error("Not implemented");

  getStatus: -> #get player state (MusicPlayer.PlayerState)
    @_statusDep.depend();
    return @backend.status();

  getTitle: -> #returns title of current song
    return @backend.title;

  isPaused: -> # whether the widget is paused.
    return true;
    throw new Error("Not implemented");

  getCurrentBackend: -> #get current backend in string, can be used for stuff
    return @backend.name;


MusicPlayer.PlayerState =
  LOADING:   0
  ENDED:     1
  PLAYING:   2
  PAUSED:    3
