Meteor Ddp Hooks
================

This small package allows you register callbacks for a ddp client connecting
and disconnecting.

### Usage

Register a connect callback:
```javascript
if (Meteor.isServer) {
  DDP.onConnect( function(sessionId) {
    //sessionId is the id of the Meteor Session object (cf livedata package)
    //for this ddp connection.  Access the full session object via
    //Meteor.server.sessions[sessionId]
    console.log("Session connected:", sessionId);
  });
}
```

Register a disconnect callback (currently just in a publish function):
```javascript
if (Meteor.isServer) {
  Meteor.publish('stuff', function() {
    self = this;
    //This will trigger when the DDP connection associated with this publish
    //function disconnects.  self refers to the Subscription object for this
    //publish.  You can also pass in a session object, or a sessionId.
    DDP.onDisconnect(self, function(sessionId) {
      console.log("Session disconnected:", sessionId);
    }); 
  });
}
```

In both cases, the `sessionId` is the same as `Meteor.connection_lastSessionId`.

By default, the server is polled every 1000ms for new/closed connections.  You can
set this via `Meteor.settings.sessionInterval`.
