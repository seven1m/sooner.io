jasmine = require('jasmine-node')

jasmine.Matchers.prototype.toBeInstanceOf = (klass) ->
  this.actual instanceof klass
