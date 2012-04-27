class Backbone.PaginatedCollection extends Backbone.Collection

  initialize: (models, options) ->
    options ?= {}
    @paginator = new Paginator perPage: 10
    @setPage(options.page)

  setPage: (page) ->
    @paginator.setPage(page)

  fetch: (options) ->
    data =
      skip: @paginator.skip
      limit: @paginator.limit
    _.extend(data, options.data) if options && options.data
    super data: data
