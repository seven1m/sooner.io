class app.models.queue extends Backbone.Model
  namespace: 'queue'

  initialize: ->
    Backbone.socket.on 'sync::refresh::queue', (data) =>
      @fetch() if data._id == @id
