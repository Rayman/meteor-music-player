Soundcloud = function (options) {
  this.client_id = options.client_id;
  this.base_url = 'https://api.soundcloud.com';
  this.headers = {
    "Accept": "application/json",
  }
}

Soundcloud.prototype.get = function (url, callback) {
  var url = this.base_url + url;

  var options = {
    params: {
      client_id: this.client_id,
    },
    headers: this.headers,
  };

  console.log('HTTP.get', url, options);
  HTTP.get(url, options, callback);
};

sc = new Soundcloud({
  client_id: 'ceafa15d4779c3532c15ed862d3ad1c3',
});

var scget = Meteor.wrapAsync(function (url, callback) {
  console.log('scget', arguments);
  sc.get('/tracks/293', function (err, result) {
    if (err)
      throw new Meteor.Error("Soundcloud failed:", err, data);
    else
      console.log(result);
      console.log('cb', callback);
      callback(err, result);
  });
});

Meteor.methods({
  "music-player/soundcloud": function (url) {
    //check(url, String);
    console.log('GET:', url);
    return Meteor.wrapAsync(scget)(url);
  },

  bar: function () {
    // .. do other stuff ..
    return "baz";
  }
});
