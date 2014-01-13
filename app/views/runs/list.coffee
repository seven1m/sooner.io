app.views.runs ?= {}

class app.views.runs.list extends Backbone.View

  initialize: ->
    @collection.on 'reset', @reset

  reset: (runs) =>
    open = ($(tr).data('run-id') for tr in @$el.find('tr.output'))
    @$el.find('tbody').empty()
    @collection.each (run) =>
      view = new app.views.runs.detailRow(model: run).render()
      @$el.find('tbody').append view.$el
      # HACK open back up the rows that were previously open
      # TODO would be better to only insert new rows rather than re-render the entire thing
      if run.id in open
        view.showOutput()
    @$el.find('.pagination').html @collection.paginator.pageLinks()

  render: ->
    @$el.html jade.render('runs/list')
    @reset()
    @
