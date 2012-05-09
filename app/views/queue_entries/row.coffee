app.views.queueEntries ?= {}

class app.views.queueEntries.row extends Backbone.BoundView

  template: ->
    $(jade.render 'queue_entries/row').html()

  tagName: 'tr'

  bindings:
    _id:
      selector: '.id'
    data:
      selector: '.data'
      elAttribute: 'html'
      converter: (_, v) -> app.helpers.queueData(v)
    createdAt:
      selector: '.createdAt'
      converter: app.converters.date_time.long
    updatedAt:
      selector: '.updatedAt'
      converter: app.converters.date_time.long
