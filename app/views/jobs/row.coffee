app.views.jobs ?= {}

class app.views.jobs.row extends Backbone.BoundView

  template: ->
    $(jade.render 'jobs/row').html()

  tagName: 'tr'

  bindings:
    _id: [
      selector: '.edit-button'
      elAttribute: 'href'
      converter: (_, v) -> "/jobs/#{v}/edit"
    ,
      selector: 'a.name'
      elAttribute: 'href'
      converter: (_, v) -> "/jobs/#{v}"
    ]
    name: '.name'
    schedule: '.schedule'
    hooks: '.hooks'
    lastRanAt:
      selector: '.lastRanAt'
      converter: app.converters.date_time.short
    lastStatus:
      selector: '.lastStatus'
      elAttribute: 'html'
      converter: (_, v) -> app.helpers.statusIcon(v) + ' ' + v
    enabled:
      selector: 'a.name'
      elAttribute: 'class'
      converter: (_, v) -> 'disabled' unless v
