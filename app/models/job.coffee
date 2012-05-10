class app.models.job extends Backbone.Model
  namespace: 'job'
  idAttribute: '_id'

  initialize: ->
    Backbone.socket.on 'sync::refresh::job', (data) =>
      @fetch() if data._id == @id

  nameWithDisabled: ->
    if @get 'enabled'
      @get 'name'
    else
      "#{@get 'name'} (disabled)"
