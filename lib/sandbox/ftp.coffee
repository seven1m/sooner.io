FTPClient = require 'ftp'

exports.init = (context, options) ->
  servers = options.ftpServers || {}

  class FTPConnection
    constructor: (connDetails, callback) ->
      client = new FTPClient(host: connDetails.host)
      @list = (path, cb) ->
        listing = []
        client.list path, (err, iter) ->
          if err
            cb(err)
          else
            iter.on 'entry', (entry) ->
              listing.push(entry)
            iter.on 'end', ->
              cb(null, listing)
      @mkdir = (name, cb) ->
        client.mkdir(name, cb)
      @put = (inStream, filename, cb) ->
        client.put(inStream, filename, cb)
      @get = (filename, cb) ->
        client.get(filename, cb)
      @end = ->
        client.end()
      client.on 'connect', =>
        client.auth connDetails.username, connDetails.password, (err) =>
          callback(err, @)
      client.connect()

  context.ftp =

    connect: (conn, callback) ->
      connDetails = servers[conn]
      if connDetails
        new FTPConnection connDetails, callback
      else
        throw "connection '#{conn}' not configured in config.json"
