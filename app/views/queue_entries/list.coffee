app.views.queueEntries ?= {}

class app.views.queueEntries.list extends Backbone.View

  initialize: ->
    @collection.on 'reset', @reset

  reset: (entries) =>
    @$el.find('#entry-list>tbody').empty()
    @collection.each (entry) =>
      view = new app.views.queueEntries.row(model: entry).render()
      @$el.find('#entry-list>tbody').append view.$el
    $('.pagination').html @collection.paginator.pageLinks()
    @$el.find('#entry-list>thead').html jade.render('queue_entries/list_heading')

  render: ->
    @$el.html jade.render('queue_entries/list')
    @reset()
    @
