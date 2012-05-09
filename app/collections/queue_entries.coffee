class app.collections.queueEntries extends Backbone.PaginatedCollection
  model: app.models.queueEntry
  namespace: 'queue_entry'

  initialize: (models, options) ->
    @queue = options.queue
    Backbone.socket.on "sync::refresh::queue", (data) =>
      @fetch() if data.name == @queue.get('name')
    super(models, options)

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
        query: @queue.get('query')
        sort: @queue.get('sort')
