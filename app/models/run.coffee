class app.models.run extends Backbone.Model
  namespace: 'run'
  idAttribute: '_id'

  initialize: ->
    @computed
      progressPercent: 'progress'
    Backbone.socket.on 'sync::refresh::run', (data) =>
      if data._id == @id
        data = _.clone(data)
        if appendOutput = data.appendOutput
          delete data.appendOutput
          @attributes.output ||= ''
          @attributes.output += appendOutput
          @change changes: {output: ''}
        @set(data)

  progressPercent: =>
    p = @get('progress')
    try
      Math.min(100, Math.round(p[0] / p[1] * 100))
    catch e
      0
