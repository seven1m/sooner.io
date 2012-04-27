app.views.jobs ?= {}

class app.views.jobs.show extends Backbone.BoundView

  initialize: ->
    super()
    @model.history = new app.collections.runs
    @model.history.fetch()
    @list = new app.views.runs.list(collection: @model.history)

  template: ->
    jade.render 'jobs/show'

  bindings:
    _id: [
      selector: '.edit-button'
      elAttribute: 'href'
      converter: (_, v) -> "/jobs/#{v}/edit"
    ,
      selector: '#run-form'
      elAttribute: 'action'
      converter: (_, v) -> "/jobs/#{v}/runs"
    ]
    name: '.name'
    schedule: '.schedule'
    hooks: '.hooks'
    workerName: '.workerName'
    lastStatus:
      selector: '.lastStatus'
      elAttribute: 'html'
      converter: (_, v) -> app.helpers.statusIcon(v) + ' ' + v
    lastRanAt:
      selector: '.lastRanAt'
      converter: app.converters.date_time.long
    createdAt:
      selector: '.createdAt'
      converter: app.converters.date_time.long
    updatedAt:
      selector: '.updatedAt'
      converter: app.converters.date_time.long

  render: ->
    super()
    @list.render().$el.appendTo @$el.find('#job-history')
    @$el.find('#run-button').mouseenter ->
      $('#run-data').fadeIn()
    .mouseleave ->
      $('#run-data').fadeOut()
    .find('.btn').click ->
      $('#run-form').submit()
    @
