express = require('express')
jadeBrowser = require('jade-browser')
socketio = require('socket.io')
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

  setupDB: =>
    @config = JSON.parse(fs.readFileSync(@opts.config))
    mongoose.connect @config.db

  setupHook: =>
    @hook = new EventEmitter2Mongo @config.db, delimiter: '::'
    GLOBAL.hook ||= @hook
    @hook.name = @opts.name || 'web'
    iam.setup @hook, port: @opts.port
    if @opts.debug then @hook.on '*', (data) => console.log @hook.event, data || ''

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
      @app.dynamicHelpers
        req: (req, _) => req
        params: (req, _) => req.params
      @app.use @layoutMiddleware

    @app.configure 'development', =>
      @app.use express.errorHandler({ dumpExceptions: true, showStack: true })

    @app.configure 'production', =>
      @app.use express.errorHandler()

    @app.listen @opts.port
    console.log "Express server listening on port %d in %s mode", @app.address().port, @app.settings.env

    @io = GLOBAL.io = socketio.listen @app
    models.connect @io
    if process.env.NODE_DISABLE_WS
      @io.set 'transports', ['htmlfile', 'xhr-polling', 'jsonp-polling']

  layoutMiddleware: (req, res, next) ->
    res.render 'layout.jade'

module.exports = WebServer
