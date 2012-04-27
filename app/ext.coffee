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

# set ModelBinder to set text() by default
Backbone.ModelBinder.prototype._origSetElValue = Backbone.ModelBinder.prototype._setElValue
Backbone.ModelBinder.prototype._setElValue = (el, convertedValue) ->
  if el.attr('type') || el.is('input') || el.is('select') || el.is('textarea')
    @_origSetElValue(el, convertedValue)
  else
    el.text(convertedValue)

class Backbone.BoundView extends Backbone.View
  initialize: ->
    @binder = new Backbone.ModelBinder
    @model.on 'destroy', @remove
  remove: =>
    @binder.unbind()
    super()
  render: =>
    @$el.html @template()
    @binder.bind @model, @el, @bindings
    @

class Backbone.PaginatedCollection extends Backbone.Collection
  initialize: (models, options) ->
    options ?= {}
    @paginator = new Paginator perPage: 10
    @setPage(options.page)
  setPage: (page) ->
    @paginator.setPage(page)
  fetch: (options) ->
    data =
      skip: @paginator.skip
      limit: @paginator.limit
    _.extend(data, options.data) if options && options.data
    super(data: data)
