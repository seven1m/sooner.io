app.views.reports ?= {}

class app.views.reports.index extends Backbone.View

  initialize: ->
    @collection.on 'add', @add
    @collection.on 'reset', @reset

  add: (report) =>
    view = new app.views.reports.row(model: report).render()
    @$el.find('tbody').append view.$el

  reset: (jobs) =>
    @$el.find('tbody').empty()
    @collection.each @add

  render: ->
    @$el.html jade.render('reports/index')
    @reset()
    @
