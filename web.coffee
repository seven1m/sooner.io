express = require 'express'
routes = require './routes'
helpers = require './app/helpers'
socketio = require 'socket.io'
Hook = require('hook.io').Hook

mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/boomer-sooner'

app = module.exports = express.createServer()

app.configure ->
  app.set 'views', __dirname + '/app/views'
  app.set 'view engine', 'jade'
  app.set 'view options',
    layout: false
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.session
    secret: 'your secret here'
  app.use require('connect-assets')()
  app.use app.router
  app.use express.static(__dirname + '/public')
  app.helpers helpers
  app.dynamicHelpers
    req: (req, _) -> req
    params: (req, _) -> req.params

app.configure 'development', ->
  app.use express.errorHandler({ dumpExceptions: true, showStack: true })

app.configure 'production', ->
  app.use express.errorHandler()

require('express-resource-routes').init(app)

routes(app)

app.listen 3000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env

# Hook.io bridge
# note: I gave up on hook.js; this seems simpler
hook = new Hook
  name: 'web-server'

hook.connect
  'hook-host': process.env.HOOK_HOST || '127.0.0.1'
  'hook-port': process.env.HOOK_PORT || 5000

io = socketio.listen app
io.sockets.on 'connection', (socket) ->
  socket.on 'hook', (msg, data) ->
    hook.emit msg, data
  hook.on '*::*', (data) ->
    socket.emit 'hook', data


