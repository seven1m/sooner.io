app.views.jobs ?= {}

class app.views.jobs.index extends Backbone.View

  initialize: ->
    @collection.on 'add', @add
    @collection.on 'reset', @reset

  add: (job) =>
    view = new app.views.jobs.row(model: job).render()
    @$el.find('tbody').append view.$el

  reset: (jobs) =>
    @$el.find('tbody').empty()
    @collection.each @add

  render: ->
    @$el.html jade.render('jobs/index')
    @reset()
    @
