express = require 'express'
routes = require './routes'
helpers = require './app/helpers'
socketio = require 'socket.io'
require __dirname + '/assets/js/date'
Hook = require('hook.io').Hook
fs = require "fs"

# setup db
config = JSON.parse(fs.readFileSync(__dirname + '/config.json'))
mongoose = require 'mongoose'
mongoose.connect "mongodb://#{config.db.host}/#{config.db.name}"

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

  hook.on '**::list-nodes', ->
    hook.emit 'i-am'
      name: hook.name
      host: hook['hook-host']
      port: hook['hook-port']

  # hack to work around hook.io bug
  hook.connect = ->
  hook.listen = ->

  io = socketio.listen app

  # bridge these events from hook io, for logging
  bridge = (ev) -> hook.on "*::#{ev}", (data) -> io.sockets.emit 'log', @event, data
  bridge(ev) for ev in ['running-job', 'job-output', 'job-complete', 'i-am', 'list-nodes', 'reload-jobs'] # do NOT include trigger-job (causes dupes for some reason)
  # bridge i-am responses
  hook.on '**::i-am', (data) -> io.sockets.emit 'i-am', data
  # bridge list-nodes queries and generic hook messages
  io.sockets.on 'connection', (socket) ->
    socket.on 'list-nodes', -> hook.emit 'list-nodes'
else
  console.log 'WARNING: no worker connection; run with --help'
