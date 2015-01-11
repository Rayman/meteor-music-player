MusicPlayer.backends = {}

#dummy backend, preventing errors when no specific backend has been loaded
class MusicPlayer.backend
  constructor: (options = {}) ->
    @name = "backend"
    @_status = MusicPlayer.PlayerState.LOADING
    @_position = 0

  #Placeholder Methods
  pause: ->
    return;

  play: ->
    return;

  title: ->
    return;

  isPaused: ->
    return;

  getPosition: ->
    return;

  getDuration: ->
    return;

  getRemaining: ->
    return

  artwork_url: ->
    return;

  #Base class methods
  status: ->
    return _.invert(MusicPlayer.PlayerState)[@_status]?.toLowerCase()

  formatDuration: (duration, unit="ms") ->
    duration =moment.duration(duration, unit)
    time = moment.utc(duration.asMilliseconds())
    if duration.asHours >= 1
      return time.format('HH:mm:ss')
    else
      return time.format('mm:ss')

  destroy: ->
    #Removes current player backend and all associated parts


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
      videoId: ""
      events:
        'onReady' : @onReady #fires when player is really ready
        'onStateChange': @onPlayerStateChange
    @YouTube = new YT.Player 'youtube-embed', options

  _whilePlaying: => #callback for youtube api
    @daddy._positionDep.changed()
    if not @_metadata?
      @_metadata = @YouTube.getVideoData()
      if @_metadata?
            @daddy._metadataDep.changed()


  onReady: (event) =>
    @_status = MusicPlayer.PlayerState.ENDED #unstarted
    console.log "#{ @YouTube } YouTube player ready"
    @updatePlayer = setInterval(@_whilePlaying, 2000)
    @load @videoId

  onPlayerStateChange: (event) => #more fat arrows
    switch event.data
      when -1 then @_status = MusicPlayer.PlayerState.ENDED #unstarted
      when 0  then @_status = MusicPlayer.PlayerState.ENDED #ended
      when 1  then @_status = MusicPlayer.PlayerState.PLAYING #playing
      when 2  then @_status = MusicPlayer.PlayerState.PAUSED #paused
      when 3  then @_status = MusicPlayer.PlayerState.LOADING #buffering
      when 5  then @_status = MusicPlayer.PlayerState.LOADING #video cued
    @daddy._statusDep.changed()
    @daddy._durationDep.changed()
    return

  #if backend is already loaded
  load: (videoId) ->
    #clear metadata on load
    @_metadata = undefined

    @YouTube.loadVideoById videoId, 0, "large"
    @seekTo(0);
    @daddy._statusDep.changed()
    @daddy._durationDep.changed()

  play: ->
    @YouTube.playVideo()

  pause: ->
    @YouTube.pauseVideo()

  toggleMute: ->
    if @YouTube.isMuted()
      @YouTube.unMute()
    else
      @YouTube.mute()
    @daddy._statusDep.changed()

  getMuted: ->
    return @YouTube.isMuted()

  seekTo: (pos) ->
    @YouTube.seekTo(pos)

  title: ->
    return @_metadata.title ? ""

  getDuration: (formatted=false) -> #return raw value from backend or formatted (mm:ss)
    @daddy._durationDep.depend()
    if formatted
      return @formatDuration(@YouTube?.getDuration(),'s') #youtube returns duration in seconds
    else
      return @YouTube?.getDuration() #seconds

  getRemaining: ->
    d = @getDuration() - @getPosition()
    return @formatDuration(d,'s')

  getPosition: ->
    @daddy._positionDep.depend()
    return @YouTube?.getCurrentTime() #seconds

  destroy: ->
    clearInterval(@updatePlayer)
    @YouTube.destroy()


class MusicPlayer.backends.soundcloud extends MusicPlayer.backend
  constructor: (options = {}) ->
    @daddy = options.parent
    @songUrl = options.id
    @name = "soundcloud"

    @_metadata = {}
    @_duration = null

  init: ->
    loadScript "//connect.soundcloud.com/sdk.js", =>
      SC.initialize
        client_id: 'ceafa15d4779c3532c15ed862d3ad1c3'
      SC.whenStreamingReady =>
        @_loaded()
    return @

  _loaded: (e) ->
    #Player initialized, no song to play yet though
    @load @songUrl

  load: (url) ->
    if @sound?
      @sound.destruct()
    SC.get url, (res) =>
      @_metadata = res
      @daddy._metadataDep.changed()

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
      @seekTo 0
      do @play
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

  toggleMute: ->
    @sound.toggleMute()
    @daddy._statusDep.changed()


  getMuted: ->
    return @sound.muted

  seekTo: (pos) ->
    @sound.setPosition(pos)
    return @

  title: ->
    return @_metadata.title ? ""

  artwork_url: ->
    return @_metadata.artwork_url ? ""

  _whileplaying: (sound) =>
    if @_position isnt sound.position
      @_position = sound.position
      @daddy._positionDep.changed()

    if @_duration isnt sound.durationEstimate
      @_duration = sound.durationEstimate
      @daddy._durationDep.changed()

  getPosition: ->
    @daddy._positionDep.depend()
    return @_position ? 0;

  getDuration: (formatted=false) ->
    @daddy._durationDep.depend()

    if @_duration?
      if formatted
        return @formatDuration(@_duration,'ms')
      else
        return @_duration #seconds

    return @_metadata.duration

  getRemaining: ->
    d = @getDuration() - @getPosition()
    return @formatDuration(d,'ms')

  destroy: ->
    @pause();
    @sound.destruct();
