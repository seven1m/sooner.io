express = require 'express'
routes = require './routes'
helpers = require './app/helpers'
socketio = require 'socket.io'
require __dirname + '/assets/js/date'
Hook = require('hook.io').Hook
fs = require "fs"
ifaces = require(__dirname + '/lib/ip').ifaces

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

opts = require('optimist')
       .usage("Start a web process.\nUsage: $0")
       .describe('host', 'host ip address of main worker process')
       .alias('h', 'host')
       .describe('port', 'host port of main worker process, defaults to 5000')
       .alias('p', 'port')
argv = opts.argv

if argv.help
  console.log opts.help()
  process.exit()

if argv.host
  hook.connect
    'hook-host': argv.host
    'hook-port': argv.port

  hook.on '**::list-nodes', ->
    hook.emit 'i-am'
      name: hook.name
      host: ifaces().join(', ')
      port: hook['hook-port']

  # hack to work around hook.io bug
  hook.connect = ->
  hook.listen = ->

  io = socketio.listen app

  # bridge these events from hook io, for logging
  bridge = (ev, pass) -> hook.on ev, (data) -> io.sockets.emit pass, @event, data
  bridge(ev, 'log') for ev in ['*::running-job', '*::job-output', '*::job-complete'] # do NOT include trigger-job (causes dupes for some reason)
  bridge(ev, 'cxn') for ev in ['connection::end', 'hook::connected']
  # bridge i-am responses
  hook.on '**::i-am', (data) -> io.sockets.emit 'i-am', data
  # bridge list-nodes queries and generic hook messages
  io.sockets.on 'connection', (socket) ->
    socket.on 'list-nodes', -> hook.emit 'list-nodes'
else
  console.log 'WARNING: no worker connection; run with --help'
