class MusicPlayer
  constructor: (options = {}) ->
    @backends = options.backends ? [];
    # console.log('constructor', this)

  # Methods
  play: ->
    console.log "play"

  pause: ->
    console.log "pause"

  toggle: ->
    console.log "toggle"

  mute: ->
    console.log "mute"

  next: ->
    console.log "next"

  prev: ->
    console.log "prev"

  seekTo: ->
    console.log "seekTo"

  setVolume: ->
    console.log "setVolume"

  # Getters
  getVolume: -> # returns the current volume, in the range of [0, 100].
    return 50;

  getDuration: -> # returns current sound duration in milliseconds.
    return 120;

  getPosition: -> # returns current sound position in milliseconds.
    return 50;

  getSounds: -> # returns the list of sound objects.
    throw new Error("Not implemented");

  getCurrentSound: -> # returns current sound object.
    throw new Error("Not implemented");

  getCurrentSoundIndex: -> # returns the index of current sound.
    throw new Error("Not implemented");

  isPaused: -> # whether the widget is paused.
    return true;
