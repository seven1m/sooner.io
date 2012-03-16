fs = require 'fs'
connect = require('mongoose/node_modules/mongodb').connect
config = JSON.parse(fs.readFileSync(__dirname + '/../config.json'))

exports.listCollections = (callback) ->
  connect "mongo://#{config.db.host}/#{config.db.name}", (err, db) ->
    if err then throw err
    db.collectionNames (err, names) ->
      if err then throw err
      names = (n.name.toString().replace(/^[^\.]+\./, '') for n in names)
      callback names
      db.close()
