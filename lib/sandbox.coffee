vm = require 'vm'
fs = require 'fs'
CoffeeScript = require 'coffee-script'

# this isn't a super safe sandbox --
# just something to keep honest people from accidentaly stepping on the parent namespace
class Sandbox

  constructor: (consoleLog) ->
    @consoleLog = consoleLog || console.log

  run: (code, callback) ->
    js = CoffeeScript.compile code
    try
      result = vm.runInNewContext js, @buildContext(), 'sandbox.vm'
      callback null, result
    catch err
      callback err

  # objects to which we're willing to give access
  buildContext: =>
    config = JSON.parse(fs.readFileSync(__dirname + '/../config.json'))
    context =
      console: log: @consoleLog
    # load in the other libs
    for file in fs.readdirSync(__dirname + '/sandbox')
      if file.match(/\.coffee$/)
        name = file.substr 0, file.indexOf('.')
        require(__dirname + '/sandbox/' + name).init(context, config)
    context


module.exports = Sandbox
