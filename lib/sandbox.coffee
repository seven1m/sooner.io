vm = require 'vm'
CoffeeScript = require 'coffee-script'

# this isn't a super safe sandbox --
# just something to keep honest people from accidentaly crashing the whole server
class Sandbox

  constructor: (consoleLog) ->
    @consoleLog = consoleLog || console.log

  # transpiles coffeescript and runs the resulting code in a psuedo-sandbox
  run: (code) ->
    js = CoffeeScript.compile code
    try
      vm.runInNewContext js, @buildContext(), 'sandbox.vm'
    catch err
      @consoleLog err

  # objects to which we're willing to give access
  buildContext: =>
    console: log: @consoleLog


module.exports = Sandbox
