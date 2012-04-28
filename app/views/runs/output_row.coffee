app.views.runs ?= {}

class app.views.runs.outputRow extends Backbone.View
  # this is NOT a BoundView, because output can get very very large
  # (re-inserting the large output every time it changes will be too slow)

  initialize: (options) ->
    @model.on 'change:output', @refresh

  tagName: 'tr'
  className: 'output'

  render: =>
    @$el.html $(jade.render('runs/output_row', run: @model)).html()
    @pos = 0
    @refresh()
    @

  refresh: =>
    # append content only
    if (out = @model.get('output')) and out.length > @pos
      @$el.find('td').append out[@pos..-1]
      @pos = out.length
