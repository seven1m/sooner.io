require __dirname + '/helper'

Sandbox = require '../lib/sandbox'
sandbox = new Sandbox()

pg = require('pg')

describe 'Sandbox', ->

  describe 'db', ->
    context = {}
    connections =
      foo: 'postgres://postgres@localhost/foo'
    require(__dirname + '/../lib/sandbox/db')
      .init(context, connections: connections)

    describe 'connect()', ->
      beforeEach ->
        spyOn(pg, 'connect').andCallFake (_, cb) ->
          cb null, jasmine.createSpy('pg.client')

      it 'makes a connection object', ->
        runs ->
          context.db.connect 'foo', (err, client) ->
            expect(err).toBeNull()
            expect(client).toBeInstanceOf(context.connection)

    describe 'connection', ->
      connection = null
      clientSpy = null

      beforeEach ->
        clientSpy = jasmine.createSpyObj 'pg.client', ['query']
        connection = new context.connection clientSpy

      describe 'query()', ->
        it 'proxies through to the client object', ->
          sql = 'select now() as when'
          connection.query sql, ->
          expect(clientSpy.query).toHaveBeenCalled()
          expect(clientSpy.query.mostRecentCall.args[0]).toEqual sql
