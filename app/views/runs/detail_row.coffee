app.views.runs ?= {}

class app.views.runs.detailRow extends Backbone.BoundView

  template: ->
    $(jade.render 'runs/detail_row').html()

  tagName: 'tr'

  bindings:
    _id: [
      selector: '.show-run'
      elAttribute: 'href'
      converter: (_, v) -> "/runs/#{v}"
    ,
      selector: '.show-run'
    ]
    ranAt:
      selector: '.ranAt'
      converter: app.converters.date_time.long
    completedAt:
      selector: '.completedAt'
      converter: app.converters.date_time.long
    status:
      selector: '.status'
      elAttribute: 'html'
      converter: (_, v) -> app.helpers.statusIcon(v) + ' ' + v

  showOutput: (e) =>
    @outputView ?= new app.views.runs.outputRow(model: @model).render()
    @$el.after @outputView.$el
    @model.fetch() # sync the 'output' attribute

  hideOutput: (e) =>
    @outputView.remove()

  render: ->
    super()
    @$el.find('.show-output').toggle @showOutput, @hideOutput
    @
