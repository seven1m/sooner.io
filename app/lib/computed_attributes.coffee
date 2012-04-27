Backbone.Model.prototype.get = (attr) ->
  if 'function' == typeof @[attr]
    @[attr]()
  else
    @attributes[attr]

Backbone.Model.prototype.computed = (attrs) ->
  for name, sources of attrs
    sources = [sources] unless _.isArray(sources)
    for attr in sources
      @on "change:#{attr}", =>
        @changed[name] = @[name]()
        @change()
