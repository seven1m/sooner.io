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
    @model.entries.setQueryAndSort(opts)
    @model.set 'query', @model.entries.params.query
    @model.set 'sort', @model.entries.params.sort
    @model.entries.fetch()

  template: ->
    jade.render 'queues/show'

  bindings:
    name:
      selector: '#name'
    query:
      selector: '#query'
    sort:
      selector: '#sort'

  updateCount: =>
    html = app.helpers.pluralize @model.entries.count || 0, 'entry', 'entries', 'friendly'
    @$el.find('#count').html html

  bindForm: =>
    unless app.queueFormBound
      $(document).on 'click', '.btn.update-view', (e) =>
        e.preventDefault()
        params = app.helpers.paramsString
          query: $('#query').val()
          sort: $('#sort').val()
        app.workspace.navigate "#{location.pathname.substring(1)}?#{params}", true
      app.queueFormBound = yes

  render: ->
    super()
    @bindForm()
    @updateCount()
    @model.entries.on 'change:count', @updateCount
    @list.render().$el.appendTo @$el.find('#entries')
    @
