app.views.status ?= {}

class app.views.status.show extends Backbone.View

  tagName: 'div'

  initialize: ->
    Backbone.socket.on 'cxn::i-am', @addRow
    Backbone.socket.on 'cxn::connected', @refresh
    Backbone.socket.on 'cxn::disconnected', @refresh

  template: ->
    jade.render 'status/show'

  addRow: (node) =>
    html = "<tr><td>#{node.name}</td><td>#{node.host}</td><td>#{node.port || ''}</td></tr>"
    @$el.find('tbody').append html

  refresh: =>
    @$el.find('tbody').html('')
    Backbone.socket.emit 'cxn::list-nodes'

  render: ->
    @$el.html jade.render('status/show')
    @refresh()
    @
