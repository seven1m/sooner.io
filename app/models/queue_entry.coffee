class app.models.queueEntry extends Backbone.Model
  namespace: 'queue_entry'

  initialize: ->
    Backbone.socket.on "sync::refresh::queue_entry", (data) =>
      @fetch() if data._id == @id
