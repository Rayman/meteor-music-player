Package.describe({
  summary: "A reactive music player with various backends"
});

Package.on_use(function (api, where) {
  api.add_files('music-player.js', 'client');
  api.export && api.export(['MusicPlayer'], 'client');
});

Package.on_test(function (api) {
  api.use('music-player');
  api.add_files('music-player_tests.js', 'client');
});
