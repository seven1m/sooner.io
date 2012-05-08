class app.collections.queues extends Backbone.Collection
  model: app.models.queue
  namespace: 'queue'

  initialize: (models, options) ->
    Backbone.socket.on 'sync::refresh::queue', (data) =>
      @fetch()
    super(models, options)
