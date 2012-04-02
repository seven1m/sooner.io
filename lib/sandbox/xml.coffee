xml2js = require 'xml2js'
fs = require 'fs'
basePath = fs.realpathSync(__dirname + '/../../output/')

exports.init = (context, options) ->

  stringToJSON = (string, callback) ->
    parser = new xml2js.Parser()
    parser.parseString string, (err, result) ->
      callback(err, result)

  fileToJSON = (path, callback) ->
    path = fs.realpathSync("#{basePath}/#{path}")
    if path.indexOf(basePath) == 0 and path.indexOf('..') == -1
      fs.readFile path, (err, data) ->
        if err then throw err
        stringToJSON data, callback
    else
      throw "Invalid path."

  context.xml =
    stringToJSON: stringToJSON
    fileToJSON: fileToJSON
