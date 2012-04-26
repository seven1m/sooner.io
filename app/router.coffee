class app.router extends Backbone.Router

  routes:
    '':         'default'
    'jobs':     'jobs.index'
    'jobs/:id': 'jobs.show'

  default: ->
    @navigate 'jobs', trigger: yes
