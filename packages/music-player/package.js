Package.describe({
  summary: "A reactive music player with various backends"
});

Package.on_use(function (api, where) {
  api.use("coffeescript", "client");
  api.add_files('music-player.coffee', 'client');
  api.add_files('backend.coffee', 'client');

  api.export && api.export(['MusicPlayer'], 'client');

});

/*
Package.on_test(function (api) {
  api.use("coffeescript", "client");
  api.use('music-player');
  api.add_files('music-player_tests.coffee', 'client');
});
*/
