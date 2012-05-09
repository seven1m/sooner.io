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
  obj = @
  while (i = src.indexOf('.')) > -1
    obj = obj[src.split('.')[0]]
    src = src.substring(i+1)

  obj.on "change:#{src}", =>
    changes = {}
    @changed[dest] = changes[dest] = true
    @change changes: changes
