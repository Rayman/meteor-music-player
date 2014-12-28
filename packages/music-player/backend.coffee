MusicPlayer.backends = {}

#dummy backend, preventing errors when no specific backend has been loaded
class MusicPlayer.backend
  constructor: (options = {}) ->
    @name = "backend"
    @_status = MusicPlayer.PlayerState.LOADING
    @_position = 0

  # Methods
  pause: ->
    return;

  play: ->
    return;

  isPaused: ->
    return;

  getPosition: ->
    return;

  getDuration: ->
    return;

  artwork_url: ->
    return;

  status: ->
    return _.invert(MusicPlayer.PlayerState)[@_status].toLowerCase()



loadScript = (src, callback) ->
  tag = document.createElement('script')
  tag.src = src
  tag.addEventListener('load', callback)
  firstScriptTag = document.getElementsByTagName('script')[0]
  firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)



class MusicPlayer.backends.youtube extends MusicPlayer.backend
  constructor: (options = {}) ->
    @name = "youtube"
    @daddy = options.parent
    @videoId = options.id

    @YouTube = {}
    @_status = MusicPlayer.PlayerState.LOADING
    @daddy._statusDep.changed()

  init: (el) ->
    loadScript("https://www.youtube.com/iframe_api")

    window.onYouTubeIframeAPIReady = =>
      @_loaded()

    return @

  _loaded: =>
    options =
      height: '480'
      width: '640'
      videoId: @videoId
      events:
        'onStateChange': @onPlayerStateChange
    @YouTube = new YT.Player 'youtube-embed', options
    @_status = MusicPlayer.PlayerState.ENDED #unstarted
    @daddy._statusDep.changed()
    console.log "#{ @YouTube } YouTube player ready"

  #if backend is already loaded
  load: (videoId) ->
    @YouTube.loadVideoById videoId, 0, "large"

  onPlayerStateChange: (event) => #more fat arrows
    switch event.data
      when -1 then @_status = MusicPlayer.PlayerState.ENDED #unstarted
      when 0  then @_status = MusicPlayer.PlayerState.ENDED #ended
      when 1  then @_status = MusicPlayer.PlayerState.PLAYING #playing
      when 2  then @_status = MusicPlayer.PlayerState.PAUSED #paused
      when 3  then @_status = MusicPlayer.PlayerState.LOADING #buffering
      when 5  then @_status = MusicPlayer.PlayerState.LOADING #video cued
    @daddy._statusDep.changed()
    return

  play: ->
    @YouTube.playVideo()

  pause: ->
    @YouTube.pauseVideo()

  getDuration: ->
    @YouTube.getDuration()
    
  getPosition: ->
    @YouTube.getCurrentTime()


class MusicPlayer.backends.soundcloud extends MusicPlayer.backend
  constructor: (options = {}) ->
    @daddy = options.parent
    @songUrl = options.id
    @name = "soundcloud"


    #moved this dep to musicplayer class
    #@_status = MusicPlayer.PlayerState.LOADING
    #@_statusDep = new Tracker.Dependency

    @_metadata = {}
    @_metadataDep = new Tracker.Dependency

    #@_position = null
    #@_positionDep = new Tracker.Dependency

    @_duration = null
    @_durationDep = new Tracker.Dependency

  init: ->
    loadScript "//connect.soundcloud.com/sdk.js", =>
      SC.initialize
        client_id: 'ceafa15d4779c3532c15ed862d3ad1c3'
      SC.whenStreamingReady =>
        @_loaded()
    return @

  _loaded: (e) ->
    #@_status = MusicPlayer.PlayerState.ENDED
    #@daddy._statusDep.changed()
    #Player initialized, no song to play yet though
    @load @songUrl

  load: (url) ->
    SC.get url, (res) =>
      @_metadata = res
      @_metadataDep.changed()

    that = this
    SC.stream(url, {
      whileplaying: ->
        that._whileplaying(this)
      onfinish: ->
        that._status = MusicPlayer.PlayerState.ENDED
        that.daddy._statusDep.changed()
      onpause: ->
        that._status = MusicPlayer.PlayerState.PAUSED
        that.daddy._statusDep.changed()
      onplay: ->
        that._status = MusicPlayer.PlayerState.PLAYING
        that.daddy._statusDep.changed()
      onresume: ->
        that._status = MusicPlayer.PlayerState.PLAYING
        that.daddy._statusDep.changed()
      onstop: ->
        that._status = MusicPlayer.PlayerState.ENDED
        that.daddy._statusDep.changed()
    }, (sound) =>
      @sound = sound
      #Finally, song ready to play
      @_status = MusicPlayer.PlayerState.ENDED
      @daddy._statusDep.changed()
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

  seekTo: (pos) ->
    @sound.setPosition(pos)
    return @

  title: ->
    @_metadataDep.depend()
    return @_metadata.title ? ""

  artwork_url: ->
    @_metadataDep.depend()
    return @_metadata.artwork_url ? ""

  _whileplaying: (sound) =>
    if @_position isnt sound.position
      @_position = sound.position
      @daddy._positionDep.changed()

    if @_duration isnt sound.durationEstimate
      @_duration = sound.durationEstimate
      @_durationDep.changed()

  getPosition: ->
    return @_position ? 0;

  getDuration: ->
    @_durationDep.depend()
    @_metadataDep.depend()

    if @_duration?
      return @_duration
    return @_metadata.duration
