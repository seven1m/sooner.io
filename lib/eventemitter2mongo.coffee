mongodb = require('mongodb')
EventEmitter2 = require('eventemitter2').EventEmitter2

class EventEmitter2Mongo extends EventEmitter2

  constructor: (mongoHost, mongoPort, dbName, options) ->
    defaultOptions =
      wildcard: yes
      delimiter: '.'
      maxListeners: 25
      collectionName: 'messages'
      collectionSize: 1000

    options ||= {}
    options[opt] ||= val for opt, val of defaultOptions

    super
      wildcard: options.wildcard
      delimiter: options.delimiter
      maxListeners: options.maxListeners

    @originalEmit = @emit
    @emit = @remoteEmit

    @server = new mongodb.Server mongoHost, mongoPort
    @db = new mongodb.Db dbName, @server

    @queue = []

    @db.open (err, client) =>
      if err then throw err
      client.createCollection options.collectionName, capped: yes, size: options.collectionSize, (err, collection) =>
        if err then throw err
        @collection = collection

        # find last message (we will ignore all up to this one)
        collection.find({}).sort('$natural': -1).limit(1).toArray (err, msgs) =>
          if err then throw err
          if last = msgs && msgs[0]
            listening = no
          else
            listening = yes

          # process messages queued up while we were waiting to connect
          while @queue.length > 0
            msg = @queue.shift()
            @emit.apply this, msg

          # we're all ready
          @originalEmit 'ready'

          # set up the tailable cursor
          collection.find {}, tailable: yes, (err, cursor) =>
            if err then throw err
            cursor.each (err, msg) =>
              if err then throw err

              if listening
                # emit that baby
                @originalEmit.apply this, msg.data

              # we're ready to listen if we're past the 'last' message
              if not listening && msg._id.equals(last._id)
                listening = yes

  remoteEmit: ->
    data = Array.prototype.slice.call(arguments, 0)
    if @collection
      # insert into mongo
      @collection.insert data: data
    else
      # queue locally until our mongo connection is ready
      @queue.push data

module.exports = EventEmitter2Mongo
