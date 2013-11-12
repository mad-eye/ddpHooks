Package.describe({
  summary: "Hooks for when a ddp client connects or disconnects."
});

Package.on_use(function (api, where) {
  api.use(['livedata', 'coffeescript', 'underscore'], ['server']);
  api.add_files(['ddpHooks.coffee'], ['server']);
});
