Backbone.Model.prototype.get = (attr) ->
  if 'function' == typeof @[attr]
    @[attr]()
  else
    @attributes[attr]

Backbone.Model.prototype.computed = (attrs) ->
  for name, sources of attrs
    sources = [sources] unless _.isArray(sources)
    @linkAttrChange(attr, name) for attr in sources

Backbone.Model.prototype.linkAttrChange = (src, dest) ->
  @on "change:#{src}", =>
    changes = {}
    @changed[dest] = changes[dest] = ''
    @change changes: changes
