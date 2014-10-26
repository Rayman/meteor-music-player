Package.describe({
  name: 'music-player',
  summary: 'A reactive music player with various backends',
  version: '0.2.0',
  git: 'https://github.com/Rayman/meteor-music-player.git'
});

Package.onUse(function(api) {
  api.versionsFrom('METEOR@0.9.4');

  api.use("coffeescript", "client");
  api.use("http", "server");

  api.addFiles('server.js',           'server');
  api.addFiles('music-player.coffee', 'client');
  api.addFiles('backend.coffee',      'client');

  api.export('MusicPlayer', ['client']);
});

Package.onTest(function(api) {
  api.use('tinytest');
  api.use('music-player');
  api.addFiles('music-player-tests.js');
});
