@console ?= log: ->

@app =
  models: {}
  collections: {}
  views: {}
  data: {}

  start: ->
    console.log 'starting app'
    @socket = Backbone.socket = io.connect()

    @bindLinks()

    @workspace = new app.router

    @data.jobs = new app.collections.jobs
    @data.jobs.fetch()

    Backbone.history.start pushState: yes

  bindLinks: ->
    $(document).on 'click', 'a:not([href^="http"])', (e) ->
      e.preventDefault()
      href = $(@).attr('href')
      if href.match(/^\?/)
        href = "#{location.pathname}#{href}"
      app.workspace.navigate href, trigger: yes
