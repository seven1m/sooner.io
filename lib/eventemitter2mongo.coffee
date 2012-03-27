mongodb = require('mongodb')
EventEmitter2 = require('eventemitter2').EventEmitter2

class EventEmitter2Mongo extends EventEmitter2

  constructor: (mongoHost, mongoPort, dbName, options) ->
    defaultOptions =
      wildcard: yes
      delimiter: '.'
      maxListeners: 25
      collectionName: 'messages'
      collectionMax: 1000
      docSize: 5 * 1024 # 5 KiB

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
      client.createCollection options.collectionName, capped: yes, size: options.collectionMax * options.docSize, max: options.collectionMax, (err, collection) =>
        if err then throw err
        @collection = collection

        # find last message (we will ignore all up to this one)
        collection.find({}).sort('$natural': -1).limit(1).toArray (err, msgs) =>
          if err then throw err
          @last = msgs && msgs[0]

          while @queue.length > 0
            msg = @queue.shift()
            @emit.apply this, msg

          @originalEmit 'ready'

          @tail()

  tail: ->
    if @last
      listening = no
    else
      listening = yes

    # set up the tailable cursor
    @cursor = @collection.find {}, tailable: yes, timeout: no
    clearInterval(@checkCursorTimeout) if @checkCursorTimeout
    @checkCursorTimeout = setInterval @checkCursor, 1000
    @cursor.each (err, msg) =>
      if err then throw err
      if msg
        if listening
          # emit that baby
          @originalEmit.apply this, msg.data

        # we're ready to listen if we're past the 'last' message
        if not listening && msg._id.equals(@last._id)
          listening = yes

        if listening then @last = msg

  checkCursor: =>
    if @cursor and @cursor.cursorId.toString() == '0'
      console.log 'cursor died, requerying...'
      @tail()

  remoteEmit: ->
    data = Array.prototype.slice.call(arguments, 0)
    if @collection
      # insert into mongo
      @collection.insert data: data
    else
      # queue locally until our mongo connection is ready
      @queue.push data

module.exports = EventEmitter2Mongo

#ee = new EventEmitter2Mongo 'localhost', 27017, 'boomer-sooner'

#ee.on 'foo', (data, iter) ->
  #console.log data, iter
  #ee.emit 'bar', data, iter
