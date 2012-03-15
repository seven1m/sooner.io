FTPClient = require 'ftp'

exports.init = (context, options) ->
  servers = options.ftpServers

  context.ftp =

    connect: (conn, callback) ->
      connHost = servers[conn]
      if connHost
        client = new FTPClient host: connHost
        client.on 'connect', callback
      else
        throw "connection '#{conn}' not configured in config.json"
