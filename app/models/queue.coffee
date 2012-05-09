class app.models.queue extends Backbone.Model
  namespace: 'queue'

  initialize: ->
    Backbone.socket.on 'sync::refresh::queue', (data) =>
      @fetch() if data._id == @id

  validate: (attrs) ->
    if attrs.query? and attrs.query == ''
      'invalid query'
    else if attrs.sort? and attrs.sort == ''
      'invalid sort'
    else
      null
