app.views.queues ?= {}

class app.views.queues.show extends Backbone.BoundView

  initialize: (options) ->
    super(options)
    @model.entries = new app.collections.queueEntries([], queue: @model, page: options.page)
    @model.entries.on 'error', console.log # FIXME
    @model.entries.fetch()
    @list = new app.views.queueEntries.list(collection: @model.entries)

  setQueryAndSort: (opts) =>
    @model.entries.setQueryAndSort(opts)

  setPage: (page) ->
    @model.entries.setPage(page)
    @model.entries.fetch()

  template: ->
    jade.render 'queues/show'

  bindings:
    name:
      selector: '.name'

  updateCount: =>
    html = app.helpers.pluralize @model.entries.count || 0, 'entry', 'entries', 'friendly'
    @$el.find('.count').html html

  render: ->
    super()
    @updateCount()
    @model.entries.on 'change:count', @updateCount
    @list.render().$el.appendTo @$el.find('#entries')
    @
