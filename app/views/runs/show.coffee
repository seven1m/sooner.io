app.views.runs ?= {}

class app.views.runs.show extends Backbone.BoundView

  initialize: (options) ->
    super(options)
    @model.on 'change', @refresh
    @model.on 'change:output', @updateOutput

  template: ->
    jade.render 'runs/show'

  bindings:
    jobId: [
      selector: '.showJob'
    ,
      selector: '.showJob'
      elAttribute: 'href'
      converter: (_, v) -> "/jobs/#{v}"
    ,
      selector: '.editJob'
      elAttribute: 'href'
      converter: (_, v) -> "/jobs/#{v}/edit"
    ]
    name: '.name'
    status:
      selector: '.status'
      elAttribute: 'html'
      converter: (_, v) -> app.helpers.statusIcon(v) + ' ' + v
    result:
      selector: '.result'
    ranAt:
      selector: '.ranAt'
      converter: app.converters.date_time.long
    completedAt:
      selector: '.completedAt'
      converter: app.converters.date_time.long

  render: =>
    super()
    @pos = 0
    @updateOutput()
    @

  refresh: =>
    if @model.get('status') == 'idle' # kick off
      Backbone.socket.emit 'sync::trigger::run', _id: @model.id

  updateOutput: =>
    # append output only
    if (out = @model.get('output')) and out.length > @pos
      @$el.find('.output').append out[@pos..-1]
      @pos = out.length
