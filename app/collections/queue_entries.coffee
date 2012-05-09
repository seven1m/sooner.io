class app.collections.queueEntries extends Backbone.PaginatedCollection
  model: app.models.queueEntry
  namespace: 'queue_entry'

  initialize: (models, options) ->
    @queue = options.queue
    @params =
      query: '{}'
      sort: '["data.created",1]'
    Backbone.socket.on "sync::refresh::queue", (data) =>
      @fetch() if data.name == @queue.get('name')
    super(models, options)

  setQueryAndSort: (opts) =>
    @params.query = opts.query if opts.query
    @params.sort = opts.sort if opts.sort

  parse: (resp) ->
    @setCount(resp.count)
    @paginator.setCount(@count)
    resp.models

  setCount: (count) ->
    @count = count
    @trigger 'change:count', @count

  fetch: ->
    super
      data:
        queue: @queue.get('name')
        query: if @params.query then JSON.parse(@params.query)
        sort: if @params.sort then JSON.parse(@params.sort)
