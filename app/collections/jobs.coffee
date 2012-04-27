class app.collections.jobs extends Backbone.Collection
  model: app.models.job
  namespace: 'job'

  getOrFetch: (id, callback) ->
    obj = @get(id)
    if obj
      callback(null, obj)
    else
      obj = new @model(_id: id)
      obj.fetch
        success: -> callback(null, obj)
        error: -> callback('error')
