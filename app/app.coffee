@console ?= log: ->

@app =
  models: {}
  collections: {}
  views: {}

  start: ->
    console.log 'starting app'
    @socket = Backbone.socket = io.connect()

    @workspace = new app.router
    Backbone.history.start pushState: yes
