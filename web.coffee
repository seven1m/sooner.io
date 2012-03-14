express = require 'express'
routes = require './routes'
helpers = require './app/helpers'
socketio = require 'socket.io'
require __dirname + '/assets/js/date'
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
GLOBAL.hook = hook = new Hook
  name: 'web'

argv = require('optimist')
       .usage("Start a web process.\nUsage: $0")
       .alias('h', 'host')
       .describe('h', 'host ip address of main worker process')
       .alias('p', 'port')
       .describe('p', 'host port of main worker process, defaults to 5000')
       .default('port', 5000)
       .argv

if argv.host
  hook.connect
    'hook-host': argv.host
    'hook-port': argv.port

  io = socketio.listen app
  io.sockets.on 'connection', (socket) ->
    # bridge from hook.io to the browser on the specified event
    socket.on 'bridge', (event) ->
      hook.on event, ->
        socket.emit.apply socket, [event, this.event].concat(Array.prototype.slice.call(arguments, 0))
    # emit to the hook.io stream from the browser
    socket.on 'hook', (msg, data) ->
      hook.emit msg, data
    socket.on 'info', ->
      hook.emit 'query', type: 'hook', (err, results) ->
        socket.emit 'info', results
else
  console.log 'WARNING: no worker connection; run with --help'
