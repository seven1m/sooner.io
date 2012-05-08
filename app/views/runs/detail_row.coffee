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
    progressPercent:
      selector: '.progress .bar'
      elAttribute: 'css'
      cssAttribute: 'width'
      converter: (_, v) -> v + '%'
    status: [
      selector: '.status'
      elAttribute: 'html'
      converter: (_, v) -> app.helpers.statusIcon(v) + ' ' + v
    ,
      selector: '.progress'
      elAttribute: 'class'
      converter: (_, v) ->
        $(@boundEls).attr('class', '')
        app.helpers.progressClass(v)
    ]

  showOutput: (e) =>
    @$el.find('.show-output i').removeClass('icon-plus').addClass('icon-minus')
    @outputView ?= new app.views.runs.outputRow(model: @model).render()
    @$el.after @outputView.$el
    @model.fetch() # sync the 'output' attribute

  hideOutput: (e) =>
    @$el.find('.show-output i').addClass('icon-plus').removeClass('icon-minus')
    @outputView.remove()

  render: ->
    super()
    @$el.find('.show-output').toggle @showOutput, @hideOutput
    @
