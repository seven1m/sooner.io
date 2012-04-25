this.app ?= {}

class this.app.router extends Backbone.Router

  routes:
    '': 'default'
    'jobs': 'jobsIndex'

  default: ->
    @navigate 'jobs'

  jobsIndex: ->
    jobs = new app.collections.jobs
    jobs.fetch()
