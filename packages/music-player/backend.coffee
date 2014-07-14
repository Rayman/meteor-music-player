class MusicPlayer.backend
  constructor: (options = {}) ->
    @name = "backend"

  # Methods
  play: ->
    throw new Error "Not implemented"

MusicPlayer.backends = {}

class MusicPlayer.backends.youtube extends MusicPlayer.backend
  constructor: (options = {}) ->
    @name = "youtube"

  init: (el) ->
    # Load the IFrame Player API code asynchronously.
    tag = document.createElement('script')
    tag.src = "https://www.youtube.com/player_api"
    firstScriptTag = document.getElementsByTagName('script')[0]
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)

    window.onYouTubePlayerAPIReady = =>
      @YT = window.YT

  play: ->
    console.log "play", @YT

class MusicPlayer.backends.soundcloud extends MusicPlayer.backend
  constructor: (options = {}) ->
    @name = "soundcloud"

  play: ->
    console.log "play"
