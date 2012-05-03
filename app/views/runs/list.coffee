app.views.runs ?= {}

class app.views.runs.list extends Backbone.View

  initialize: ->
    @collection.on 'reset', @reset

  reset: (runs) =>
    @$el.find('tbody').empty()
    @collection.each (run) =>
      view = new app.views.runs.detailRow(model: run).render()
      @$el.find('tbody').append view.$el
    @$el.find('.page-links').html @collection.paginator.pageLinks()

  render: ->
    @$el.html jade.render('runs/list')
    @reset()
    @
