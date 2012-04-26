@console ?= log: ->

@app =
  models: {}
  collections: {}
  controllers: {}
  views: {}

  start: ->
    console.log 'starting app'
    @socket = Backbone.socket = io.connect()

    @bindLinks()

    @workspace = new app.router

    for name, controller of @controllers
      for action, func of controller
        @workspace.on "route:#{name}.#{action}", func

    Backbone.history.start pushState: yes

  bindLinks: ->
    $(document).on 'click', 'a:not([href^="http"])', (e) ->
      e.preventDefault()
      app.workspace.navigate $(@).attr('href'), trigger: yes
