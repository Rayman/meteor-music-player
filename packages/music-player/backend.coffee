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
    loadScript("https://www.youtube.com/player_api", @loaded)

    window.onYouTubePlayerAPIReady = =>
      @loaded()

  loaded: ->
    console.log "YouTube player ready"

  play: ->
    console.log "play"



class MusicPlayer.backends.soundcloud extends MusicPlayer.backend
  constructor: (options = {}) ->
    @name = "soundcloud"
    @_status = MusicPlayer.PlayerState.LOADING
    @_statusDep = new Deps.Dependency

  init: ->
    loadScript "//connect.soundcloud.com/sdk.js", =>
      SC.initialize
        client_id: 'ceafa15d4779c3532c15ed862d3ad1c3'
      SC.whenStreamingReady =>
        @loaded()

  loaded: (e) ->
    console.log "SoundCloud player ready"
    @_status = MusicPlayer.PlayerState.ENDED
    @_statusDep.changed()

  play: ->
    console.log "play", this

    # stream track id 293
    SC.stream("/tracks/293", (sound) =>
      sound.play()
      @sound = sound
    )

  status: ->
    @_statusDep.depend()
    _.invert(MusicPlayer.PlayerState)[@_status].toLowerCase()
