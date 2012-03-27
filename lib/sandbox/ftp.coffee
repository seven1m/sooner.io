FTPClient = require 'ftp'

exports.init = (context, options) ->
  servers = options.ftpServers || {}

  class FTPConnection
    constructor: (connDetails, callback) ->
      client = new FTPClient(host: connDetails.host)
      @mkdir = (name, cb) ->
        client.mkdir(name, cb)
      @put = (inStream, filename, cb) ->
        client.put(inStream, filename, cb)
      @get = (filename, cb) ->
        client.get(filename, cb)
      client.auth connDetails.username, connDetails.password, (err) ->
        if err then throw err
        callback(@)

  context.ftp =

    connect: (conn, callback) ->
      connDetails = servers[conn]
      if connDetails
        new FTPConnection host: connDetails.host, callback
      else
        throw "connection '#{conn}' not configured in config.json"
