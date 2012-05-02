Backbone.sync = (method, model, options) ->

  if namespace = (options && options.namespace) || (model && model.namespace)
    namespace = namespace() if 'function' == typeof namespace

    data = options.data || model.toJSON() || {}
    data.id ?= (model && model.get && model.get('id'))

    Backbone.socket.emit "sync::#{method}::#{namespace}", data, (err, data) ->
      if err
        options.error err
      else
        options.success data

  else
    console.log 'no namespace specified:', arguments
