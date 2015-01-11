class MusicPlayer
  constructor: (options = {}) ->
    @backends = options.backends ? [];
    @queue = options.queue ? []; #load queue externally or use addtoqueue methods
    @playing = null;

    @backend = new MusicPlayer.backend(); #start with dummy backend, prevents errors on load
    # console.log('constructor', this)

    @_statusDep = new Tracker.Dependency
    @_positionDep = new Tracker.Dependency
    @_durationDep = new Tracker.Dependency
    @_metadataDep = new Tracker.Dependency
    @_queueDep = new Tracker.Dependency


  load: (song) ->
    if(@backend.name isnt song.backend)
      #"destroy/pause/deactivate" old backend
      do @backend.pause

      if song.backend not of @backends
        console.log "create new backend: #{ song.backend }"
        #load new backend and play song
        @backends[song.backend] = new MusicPlayer.backends[song.backend]({parent: this, id: song.url}).init();

      @backend = @backends[song.backend]; #reference
    else
      @backend.load(song.url)

    @playing = song.index;
    return true

  #adds a song object to the queue
  addToQueue: (song) -> #song Object
    if song.url? and song.backend?
      if not song.index
        song.index = @queue.length  #add to back of queue
      @queue.push(song)
      @_queueDep.changed()
    else
      return false

  #getter for queue object
  getQueue: ->
    @_queueDep.depend()
    return _.sortBy(@queue, (song) -> return song.index; );


  #backend related Methods - these calls should all be wired to there respective backend call
  play: (songIndex=undefined) -> #reverse from pause, or with a song defined load and play song
    if songIndex? and songIndex >=0
      song = _.find(@queue, (song) -> return song.index is songIndex; )
      @load(song)
    else
      if @playing isnt null
        @backend.play()
      else
        console.warn("nothing to play");

  pause: ->
    console.log "pause #{ @pause }"
    @backend.pause();

  toggle: ->
    console.log "toggle"
    @backend.togglePause()

  mute: ->
    console.log "mute"
    @backend.toggleMute()

  next: ->
    @play(@playing+1)

  prev: ->
    @play(@playing-1)

  seekTo: (pos) ->
    console.log "seekTo #{ pos }"
    @backend.seekTo(pos);

  setVolume: ->
    console.log "setVolume"
    throw new Error("Not implemented");

  # Getters
  getArtwork: -> #returns artwork url if available
    @_metadataDep.depend()
    return @backend.artwork_url();

  getVolume: -> # returns the current volume, in the range of [0, 100].
    return 50;
    throw new Error("Not implemented");

  getDuration: (formatted=false) -> # returns current sound duration in milliseconds.
    @_durationDep.depend();
    @_positionDep.depend();
    return @backend.getDuration(formatted);

  getRemaining: -> #get remaining time, formatted
    @_positionDep.depend()
    return @backend.getRemaining()

  getPosition: -> # returns current sound position in milliseconds.
    @_positionDep.depend();
    return @backend.getPosition();

  getSounds: -> # returns the list of sound objects.
    throw new Error("Not implemented");

  getCurrentSound: -> # returns current sound object.
    throw new Error("Not implemented");

  getCurrentSoundIndex: -> # returns the index of current sound.
    return @playing;

  getStatus: -> #get player state (MusicPlayer.PlayerState)
    @_statusDep.depend();
    return @backend.status();

  getTitle: -> #returns title of current song
    @_metadataDep.depend()
    return @backend.title();

  getMuted: -> #returns if player is currently muted
    @_statusDep.depend();
    return @backend.getMuted();

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
