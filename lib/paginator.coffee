_ = require 'underscore'

class Paginator

  constructor: (config, callback) ->
    @limit = @perPage = config.perPage
    @page = parseInt(config.page) || 1
    @skip = (@page - 1) * @perPage
    @query = config.query
    _.clone(@query).count (err, count) =>
      if err
        throw err
      @total = count
      callback(@)

  pageLinks: ->
    pages = @total / @perPage
    unless @total % @perPage == 0
      pages++
    links = for page in [1..pages]
      if @page == page
        "<strong class='page-link'>#{page}</strong>"
      else
        "<a class='page-link' href='?page=#{page}'>#{page}</a>"
    links.join ' '

module.exports = Paginator
