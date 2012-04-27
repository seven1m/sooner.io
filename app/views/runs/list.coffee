app.views.runs ?= {}

class app.views.runs.list extends Backbone.View

  initialize: ->
    @collection.on 'add', @add
    @collection.on 'reset', @reset

  add: (run) =>
    view = new app.views.runs.row(model: run).render()
    @$el.find('tbody').append view.$el

  reset: (runs) =>
    @$el.find('tbody').empty()
    @collection.each @add

  render: ->
    @$el.html jade.render('runs/list')
    @reset()
    @
