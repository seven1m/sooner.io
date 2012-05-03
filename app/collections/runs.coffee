class app.collections.runs extends Backbone.PaginatedCollection
  model: app.models.run
  namespace: 'run'

  initialize: (models, options) ->
    @job = options.job if options.job
    Backbone.socket.on 'sync::refresh::job', (data) =>
      if data._id == @job.id
        @fetch()
    super(models, options)

  parse: (resp) ->
    @count = resp.count
    @paginator.setCount(@count)
    resp.models

  fetch: ->
    super(data: jobId: @job.id)
