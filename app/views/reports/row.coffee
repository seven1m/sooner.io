app.views.reports ?= {}

class app.views.reports.row extends Backbone.BoundView

  template: ->
    $(jade.render 'reports/row').html()

  tagName: 'tr'

  bindings:
    _id: [
      selector: '.edit-button'
      elAttribute: 'href'
      converter: (_, v) -> "/reports/#{v}/edit"
    ,
      selector: 'a.name'
      elAttribute: 'href'
      converter: (_, v) -> "/reports/#{v}"
    ]
    name: '.name'
    lastRanAt:
      selector: '.lastRanAt'
      converter: app.converters.date_time.short
