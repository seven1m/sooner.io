require __dirname + '/helper'

fs = require('fs')
pg = require('pg')
childProcess = require('child_process')

describe 'Sandbox', ->

  #describe 'db', ->
    #context = {}
    #dbConnections =
      #foo: 'postgres://postgres@localhost/foo'
    #require(__dirname + '/../lib/sandbox/db')
      #.init(context, dbConnections: dbConnections)

    #describe 'connect()', ->
      #beforeEach ->
        #spyOn(pg, 'connect').andCallFake (_, cb) ->
          #cb null, jasmine.createSpy('pg.client')

      #it 'makes a connection object', ->
        #runs ->
          #context.db.connect 'foo', (err, client) ->
            #expect(err).toBeNull()
            #expect(client).toBeInstanceOf(context.connection)

    #describe 'connection', ->
      #connection = null
      #clientSpy = null

      #beforeEach ->
        #clientSpy = jasmine.createSpyObj 'pg.client', ['query']
        #connection = new context.connection clientSpy

      #describe 'query()', ->
        #it 'proxies through to the client object', ->
          #sql = 'select now() as when'
          #connection.query sql, ->
          #expect(clientSpy.query).toHaveBeenCalled()
          #expect(clientSpy.query.mostRecentCall.args[0]).toEqual sql

  #describe 'shell', ->
    #context = {}
    #shellCommands =
      #listDir: 'ls'
    #require(__dirname + '/../lib/sandbox/shell')
      #.init(context, shellCommands: shellCommands)

    #describe 'spawn()', ->
      #it 'calls childProcess.spawn()', ->
        #spyOn childProcess, 'spawn'
        #proc = context.shell.spawn 'listDir', ['/home']
        #expect(childProcess.spawn).toHaveBeenCalledWith 'ls', ['/home']

    #describe 'run()', ->
      #it 'executes the callback', ->
        #callback = jasmine.createSpy 'callback'
        #runs ->
          #context.shell.run 'listDir', [__dirname], callback
        #waits 100
        #runs ->
          #expect(callback).toHaveBeenCalled()

      #it 'runs the command and passes output to the callback', ->
        #results = []
        #runs ->
          #context.shell.run 'listDir', [__dirname], -> results = arguments
        #waitsFor (-> results[0] != undefined), null, 500
        #runs ->
          #expect(results[0]).toEqual(0)
          #expect(results[1]).toMatch(/sandboxSpec\.coffee/)

  describe 'curl', ->
    context = {}
    curlServers =
      foo: 'ftp://user:pass@host/path/'
    require(__dirname + '/../lib/sandbox/curl')
      .init(context, curlServers: curlServers)

    describe 'upload()', ->

      beforeEach ->
        spyOn(childProcess, 'spawn').andReturn
          stdout: on: ->
          stderr: on: ->
          on: ->
        cb = jasmine.createSpy('callback')

      it 'calls childProcess.spawn() with all the args', ->
        proc = context.curl.upload 'bar', 'foo', 'baz/boo', cb
        expect(childProcess.spawn).toHaveBeenCalledWith 'curl', ['-Q', '*MKD /path/baz', '-Q', '*MKD /path/baz/boo', '-T', fs.realpathSync(__dirname+'/../output/bar'), 'ftp://user:pass@host/path/baz/boo/']

      it 'does not allow source path outside of output dir', ->
        bad = -> context.curl.upload '../README.md', 'foo', null, cb
        expect(bad).toThrow('Invalid path.')

      it 'does not allow .. in destination', ->
        bad = -> context.curl.upload 'bar', 'foo', '../bar', cb
        expect(bad).toThrow('Invalid path.')

