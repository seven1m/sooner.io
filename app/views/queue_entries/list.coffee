app.views.queueEntries ?= {}

class app.views.queueEntries.list extends Backbone.View

  initialize: ->
    @collection.on 'reset', @reset

  reset: (entries) =>
    @$el.find('#entry-list>tbody').empty()
    @collection.each (entry) =>
      view = new app.views.queueEntries.row(model: entry).render()
      @$el.find('#entry-list>tbody').append view.$el
    @$el.find('.page-links').html @collection.paginator.pageLinks()

  render: ->
    @$el.html jade.render('queue_entries/list')
    @reset()
    @
