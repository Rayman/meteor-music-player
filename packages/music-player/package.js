Package.describe({
  name: 'music-player',
  summary: 'A reactive music player with various backends',
  version: '0.2.0',
  git: 'https://github.com/Rayman/meteor-music-player.git'
});

Package.onUse(function(api) {
  api.versionsFrom('METEOR@0.9.4');

  api.use("coffeescript", "client");

  api.addFiles('music-player.coffee');
  api.addFiles('backend.coffee');
  
  api.export('MusicPlayer', ['client']);
});

Package.onTest(function(api) {
  api.use('tinytest');
  api.use('music-player');
  api.addFiles('music-player-tests.js');
});
