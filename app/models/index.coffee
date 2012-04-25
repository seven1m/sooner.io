fs = require 'fs'

for file in fs.readdirSync(__dirname)
  if file.match(/\.coffee$/) && !file.match(/index\.coffee/)
    name = file.substr 0, file.indexOf('.')
    exports[name] = require('./' + name)

exports.connect = (io) ->
  io.sockets.on 'connection', (socket) ->

    sync = (name, model) ->
      socket.on "#{name}:read", (data, callback) ->
        exports[name].find (err, records) ->
          callback null, records

    sync(name, model) for name, model of exports when name != 'connect'
