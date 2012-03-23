express = require 'express'
routes = require './routes'
helpers = require './app/helpers'
socketio = require 'socket.io'
require __dirname + '/assets/js/date'
EventEmitter2Mongo = require __dirname + '/lib/eventemitter2mongo'
fs = require "fs"
ifaces = require(__dirname + '/lib/ip').ifaces

opts = require('optimist')
       .usage("Start a web process.\nUsage: $0")
       .describe('port', 'port to run the web server')
       .default('port', 3000)
argv = opts.argv

if argv.help
  console.log opts.help()
  process.exit()

# setup db
config = JSON.parse(fs.readFileSync(__dirname + '/config.json'))
mongoose = require 'mongoose'
mongoose.connect "mongodb://#{config.db.host}/#{config.db.name}"

GLOBAL.hook = hook = new EventEmitter2Mongo config.db.host, config.db.port || 27017, config.db.name, delimiter: '::'
hook.name = argv.name || 'web'

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
  app.use require('connect-assets')(src: "#{__dirname}/assets")
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

app.listen argv.port
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env

hook.on 'list-nodes', ->
  hook.emit 'i-am'
    name: hook.name
    host: ifaces().join(', ')
    port: app.address().port

io = socketio.listen app
if process.env.NODE_DISABLE_WS
  io.set 'transports', ['htmlfile', 'xhr-polling', 'jsonp-polling']

# bridge these events from hook io
bridge = (ev, pass) -> hook.on ev, (data) -> io.sockets.emit pass, @event, data
bridge(ev, 'log') for ev in ['running-job', 'job-output', 'job-status']
bridge(ev, 'cxn') for ev in ['connected', 'disconnected']
hook.on 'i-am', (data) -> io.sockets.emit 'i-am', data

# bridge list-nodes queries from socket io
io.sockets.on 'connection', (socket) ->
  socket.on 'list-nodes', -> hook.emit 'list-nodes'
