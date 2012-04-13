express = require('express')
routes = require(__dirname + '/../app/routes')
helpers = require(__dirname + '/../app/helpers')
socketio = require('socket.io')
require(__dirname + '/../assets/js/date')
EventEmitter2Mongo = require(__dirname + '/eventemitter2mongo')
resourceRoutes = require('express-resource-routes')
mongoose = require('mongoose')
fs = require('fs')
iam = require(__dirname + '/iam')

class WebServer
  constructor: (@opts) ->
    @setupDB()
    @setupServer()
    @setupHook()

  setupDB: =>
    @config = JSON.parse(fs.readFileSync(@opts.config))
    mongoose.connect @config.db

  setupHook: =>
    @hook = new EventEmitter2Mongo @config.db, delimiter: '::'
    GLOBAL.hook ||= @hook
    @hook.name = @opts.name || 'web'
    iam.setup @hook, port: @opts.port

    @bridgeEvent(ev, 'log') for ev in ['running-job', 'job-output', 'job-status', 'job-progress']
    @bridgeEvent(ev, 'cxn') for ev in ['connected', 'disconnected']
    @hook.on 'i-am', (data) =>
      @io.sockets.emit 'i-am', data

    @io.sockets.on 'connection', (socket) =>
      socket.on 'list-nodes', => @hook.emit 'list-nodes'

  bridgeEvent: (ev, pass) =>
    @hook.on ev, (data) =>
      @io.sockets.emit pass, @hook.event, data

  setupServer: =>
    @app = express.createServer()

    @app.configure =>
      @app.set 'views', __dirname + '/../app/views'
      @app.set 'view engine', 'jade'
      @app.set 'view options',
        layout: false
      @app.use express.bodyParser()
      @app.use express.methodOverride()
      @app.use express.cookieParser()
      @app.use express.session
        secret: 'your secret here'
      @app.use require('connect-assets')(src: "#{__dirname}/../assets")
      @app.use @app.router
      @app.use express.static(__dirname + '/../public')
      @app.helpers helpers
      @app.dynamicHelpers
        req: (req, _) => req
        params: (req, _) => req.params

    @app.configure 'development', =>
      @app.use express.errorHandler({ dumpExceptions: true, showStack: true })

    @app.configure 'production', =>
      @app.use express.errorHandler()

    resourceRoutes.init(@app)

    routes(@app)

    @app.listen @opts.port
    console.log "Express server listening on port %d in %s mode", @app.address().port, @app.settings.env

    @io = socketio.listen @app
    if process.env.NODE_DISABLE_WS
      @io.set 'transports', ['htmlfile', 'xhr-polling', 'jsonp-polling']

module.exports = WebServer
