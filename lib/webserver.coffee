express = require('express')
jadeBrowser = require('jade-browser')
socketio = require('socket.io')
_ = require('underscore')
EventEmitter2Mongo = require(__dirname + '/eventemitter2mongo')
mongoose = require('mongoose')
fs = require('fs')
iam = require(__dirname + '/iam')
models = require(__dirname + '/../models')

class WebServer
  constructor: (@opts) ->
    @setupDB()
    @setupServer()
    @setupHook()
    @watchExit()

  setupDB: =>
    @config = JSON.parse(fs.readFileSync(@opts.config))
    mongoose.connect @config.db

  setupHook: =>
    @hook = new EventEmitter2Mongo @config.db, delimiter: '::'
    GLOBAL.hook ||= @hook
    @hook.name = @opts.name || 'web'
    iam.setup @hook, port: @opts.port
    if @opts.debug then @hook.on '**', (data) => console.log 'DEBUG>>>', @hook.event, data || ''

    @bridgeEvent(ev) for ev in ['sync::**', 'cxn::**']

    @io.sockets.on 'connection', (socket) =>
      @bridgeEvent(ev, socket) for ev in ['sync::refresh::job', 'sync::refresh::run', 'sync::trigger::run', 'sync::stop::run', 'cxn::list-nodes']

    @hook.emit 'cxn::connected'

  # pass socket to bridge from browser to network
  # otherwise bridge from network to browser
  bridgeEvent: (ev, socket) =>
    if socket
      socket.on ev, _.bind(@hook.emit, @hook, ev)
    else
      @hook.on ev, (data) =>
        @io.sockets.emit @hook.event, data

  setupServer: =>
    @app = express()

    @app.configure =>
      @app.set 'views', __dirname + '/../app/templates'
      @app.set 'view engine', 'jade'
      @app.set 'view options',
        layout: false
      @app.use express.bodyParser()
      @app.use express.methodOverride()
      @app.use express.cookieParser()
      @app.use express.session
        secret: 'your secret here'
      @app.use require('connect-assets')(src: "#{__dirname}/../app")
      @app.use express.static(__dirname + '/../public')
      @app.use jadeBrowser('/js/templates.js', '**/*.jade', root: __dirname + '/../app/templates')
      @app.use (req, res, next) ->
        res.locals.req = (req, _) => req
        res.locals.params = (req, _) => req.params
        next()
      @app.use @layoutMiddleware

    @app.configure 'development', =>
      @app.use express.errorHandler({ dumpExceptions: true, showStack: true })

    @app.configure 'production', =>
      @app.use express.errorHandler()

    server = @app.listen @opts.port
    console.log "Express server listening on port %d in %s mode", server.address().port, @app.settings.env

    @io = GLOBAL.io = socketio.listen(server, {log: false})
    models.connect @io
    if process.env.NODE_DISABLE_WS
      @io.set 'transports', ['htmlfile', 'xhr-polling', 'jsonp-polling']

  layoutMiddleware: (req, res, next) ->
    res.render 'layout.jade'

  watchExit: =>
    process.on 'SIGINT', =>
      @hook.emit 'cxn::disconnected'
      process.exit()

module.exports = WebServer
