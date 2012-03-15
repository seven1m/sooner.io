Sandbox = require '../lib/sandbox'
sandbox = new Sandbox()

describe 'Sandbox', ->

  describe 'db', ->

    describe 'connect()', ->
      context = {}
      connections =
        foo: 'postgres://postgres@localhost/foo'
      require(__dirname + '/../lib/sandbox/db')
        .init(context, connections)
      db = context.db

      it 'makes a connection', ->
        runs ->
          db.connect 'foo', (err, client) ->
            expect(err).toBeDefined()
