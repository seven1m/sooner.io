app.views.runs ?= {}

class app.views.runs.row extends Backbone.BoundView

  template: ->
    $(jade.render 'runs/row').html()

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
