class app.models.report extends Backbone.Model
  namespace: 'report'
  idAttribute: '_id'

  initialize: ->
    Backbone.socket.on 'sync::refresh::report', (data) =>
      @fetch() if data._id == @id
