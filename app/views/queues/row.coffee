app.views.queues ?= {}

class app.views.queues.row extends Backbone.BoundView

  className: 'queue'

  template: ->
    jade.render('queues/row')

  bindings:
    name: [
      selector: 'a.name'
      elAttribute: 'href'
      converter: (_, v) -> "/queues/#{v}"
    ,
      selector: 'a.name'
    ]
    counts:
      selector: 'table.statuses tbody'
      elAttribute: 'html'
      converter: (_, v) ->
        rows = for status, count of v
          jade.render('queues/status_row', status: status, count: count)
        rows.join('')

  render: =>
    super()
    g = new app.views.graphs.pie(data: @model.get('counts'))
    g.classForDatum = (d) -> "misc #{d.l}"
    @$el.find('.graphs').append g.render().$el
    @
