app.views.queues ?= {}

class app.views.queues.show extends Backbone.BoundView

  initialize: (options) ->
    super(options)
    @model.entries = new app.collections.queueEntries([], queue: @model, page: options.page)
    @model.entries.on 'error', console.log # FIXME
    @model.entries.fetch()
    @list = new app.views.queueEntries.list(collection: @model.entries)

  setParams: (opts) =>
    opts ?= {}
    @model.entries.setPage(opts.page || 1)
    @model.set 'query', if opts.query then JSON.parse(opts.query) else {}
    @model.set 'sort', if opts.sort then JSON.parse(opts.sort) else ["data.created", 1]
    @model.entries.fetch()

  queryAndSortAsParams: =>
    app.helpers.paramsString
      query: JSON.stringify(@model.get 'query')
      sort: JSON.stringify(@model.get 'sort')

  template: ->
    jade.render 'queues/show'

  bindings:
    name:
      selector: '#name'
    query:
      selector: '#query'
      converter: app.converters.json
    sort:
      selector: '#sort'
      converter: app.converters.json

  updateCount: =>
    html = app.helpers.pluralize @model.entries.count || 0, 'entry', 'entries', 'friendly'
    @$el.find('#count').html html

  bindFormSubmit: =>
    @$el.find('.btn.update-view').click (e) =>
      e.preventDefault()
      @model.entries.setPage(1)
      @model.entries.fetch()
      app.workspace.navigate "#{location.pathname.substring(1)}?#{@queryAndSortAsParams()}"
      @$el.find('.alert-error').hide()

  bindRefresh: =>
    @$el.find('#refresh').click (e) =>
      e.preventDefault()
      @model.entries.fetch()

  showError: =>
    @$el.find('.alert-error').show()

  render: ->
    super()
    @model.on 'error', @showError
    @bindFormSubmit()
    @bindRefresh()
    @updateCount()
    @model.entries.on 'change:count', @updateCount
    @list.render().$el.appendTo @$el.find('#entries')
    @
