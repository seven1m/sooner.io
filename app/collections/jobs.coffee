class app.collections.jobs extends Backbone.Collection
  model: app.models.job
  namespace: 'job'

  comparator: (job) ->
    new String(job.get('name')).toLowerCase()

  getOrFetch: (id, callback) ->
    obj = @get(id)
    if obj
      callback(null, obj)
    else
      obj = new @model(_id: id)
      obj.fetch
        success: -> callback(null, obj)
        error: (_, r) -> callback(r)
