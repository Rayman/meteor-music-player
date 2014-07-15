class MusicPlayer.backend
  constructor: (options = {}) ->
    @name = "backend"
    @_status

  # Methods
  play: ->
    throw new Error "Not implemented"

  isPaused: ->
    throw new Error "Not implemented"



MusicPlayer.backends = {}

MusicPlayer.PlayerState =
  LOADING:   0
  ENDED:     1
  PLAYING:   2
  PAUSED:    3

loadScript = (src, callback) ->
  tag = document.createElement('script')
  tag.src = src
  tag.addEventListener('load', callback)
  firstScriptTag = document.getElementsByTagName('script')[0]
  firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)



class MusicPlayer.backends.youtube extends MusicPlayer.backend
  constructor: (options = {}) ->
    @name = "youtube"
    @_status = MusicPlayer.PlayerState.LOADING

  init: (el) ->
    loadScript("https://www.youtube.com/player_api", @_loaded)

    window.onYouTubePlayerAPIReady = =>
      @_loaded()

  _loaded: ->
    console.log "YouTube player ready"

  play: ->
    console.log "play"



class MusicPlayer.backends.soundcloud extends MusicPlayer.backend
  constructor: (options = {}) ->
    @name = "soundcloud"

    @_status = MusicPlayer.PlayerState.LOADING
    @_statusDep = new Deps.Dependency

    @_metadata = {}
    @_metadataDep = new Deps.Dependency

    @_position = 0
    @_positionDep = new Deps.Dependency

  init: ->
    loadScript "//connect.soundcloud.com/sdk.js", =>
      SC.initialize
        client_id: 'ceafa15d4779c3532c15ed862d3ad1c3'
      SC.whenStreamingReady =>
        @_loaded()
    return @

  _loaded: (e) ->
    console.log "SoundCloud player ready"
    @_status = MusicPlayer.PlayerState.ENDED
    @_statusDep.changed()

  load: (url) ->
    SC.get url, (res) =>
      @_metadata = res
      @_metadataDep.changed()

    that = this
    SC.stream(url, {
      whileplaying: ->
        that.onPosition(this.position)
    }, (sound) =>
      sound.play()
      @sound = sound
    )

    return @

  play: ->
    @sound.play()
    return @

  pause: ->
    @sound.pause()
    return @

  toggle: ->
    @sound.togglePause()
    return @

  status: ->
    @_statusDep.depend()
    _.invert(MusicPlayer.PlayerState)[@_status].toLowerCase()

  title: ->
    @_metadataDep.depend()
    return @_metadata.title ? ""

  artwork_url: ->
    @_metadataDep.depend()
    return @_metadata.artwork_url ? ""

  onPosition: (pos) =>
    @_position = pos
    @_positionDep.changed()

  getPosition: ->
    @_positionDep.depend()
    return @_position
