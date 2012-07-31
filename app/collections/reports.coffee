class app.collections.reports extends Backbone.Collection
  model: app.models.report
  namespace: 'report'

  comparator: (report) ->
    report.get('name')

  getOrFetch: (id, callback) ->
    obj = @get(id)
    if obj
      callback(null, obj)
    else
      obj = new @model(_id: id)
      obj.fetch
        success: -> callback(null, obj)
        error: (_, r) -> callback(r)
