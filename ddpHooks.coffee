###
# DDP.onConnect takes a callback that is called when a DDP session is
# established.  It is passed the sessionId.
#
# TODO: Accept context
#
# DDP.onConnect can be called anywhere on the server.
# @params callback: (sessionId) ->
###
DDP.onConnect = (callback) ->
  unless typeof callback == 'function'
    throw new Error "Meteor.onConnect must be passed a function"
  connectCallbacks.push callback

###
# DDP.onDisconnect takes a sessionId (or session object or subscription object)
# It is called when that session disconnects, and it is passed a sessionId
# of the disconnecting session.
#
# XXX: This does not currently fire on server restarts (eg, hot code pushes).
#
# @param handle: either sessionId, session, or subscription.
# @param callback: (sessionId) ->
###
DDP.onDisconnect = (handle, callback) ->
  if typeof handle == 'string'
    sessionId = handle
  #presumably an object
  else if handle._session
    #this is a subscription
    sessionId = handle._session.id
  else if handle.server and handle.socket
    #This is a session
    sessionId = handle.id

  unless sessionId
    throw new Error "Need sessionId for disconnect callback"
  unless typeof callback == 'function'
    throw new Error "Meteor.onDisconnect must be passed a sessionId and a function"

  disconnectCallbacks[sessionId] ?= []
  disconnectCallbacks[sessionId].push callback

## Internal: store callbacks
connectCallbacks = []
_invokeConnectCallbacks = (sessionId) ->
  callback(sessionId) for callback in connectCallbacks

disconnectCallbacks = {}
_invokeDisconnectCallbacks = (sessionId) ->
  callbacks = disconnectCallbacks[sessionId]
  return unless callbacks
  callback(sessionId) for callback in callbacks
  delete disconnectCallbacks[sessionId]
  return

## Internal: poll and notice when sessions connect/disconnect.
existingSessionIds = []
INTERVAL = Meteor.settings.sessionInterval || 1000
Meteor.setInterval ->
  currentSessionIds = _.keys Meteor.server.sessions
  newSessionIds = _.difference currentSessionIds, existingSessionIds
  Meteor._debug "newSessions:", newSessionIds if newSessionIds.length > 0
  _invokeConnectCallbacks(sessionId) for sessionId in newSessionIds

  closedSessionIds = _.difference existingSessionIds, currentSessionIds
  Meteor._debug "closedSessions:", closedSessionIds if closedSessionIds.length > 0
  _invokeDisconnectCallbacks(sessionId) for sessionId in closedSessionIds

  existingSessionIds = currentSessionIds

, INTERVAL
