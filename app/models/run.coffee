class app.models.run extends Backbone.Model
  namespace: 'run'
  idAttribute: '_id'

  initialize: ->
    Backbone.socket.on 'sync::refresh::run', (data) =>
      if data._id == @id
        data = _.clone(data)
        if appendOutput = data.appendOutput
          delete data.appendOutput
          @attributes.output += appendOutput
          @change changes: {output: ''}
        @set(data)
