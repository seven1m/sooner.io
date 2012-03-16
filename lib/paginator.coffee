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

  window: 10

  pageLinks: ->
    pages = Math.floor(@total / @perPage)
    unless @total % @perPage == 0
      pages++
    if pages > 0
      start = Math.max(1, @page - @window/2)
      stop = Math.min(pages, start + @window)
      links = (@pageLink(page) for page in [start..stop])
      if start > 1
        links.unshift '...' if start > 2
        links.unshift @pageLink(1)
      if stop < pages
        links.push '...' if stop < pages - 1
        links.push @pageLink(pages)
      "<span class='paginator-intro'>page:</span> #{links.join(' ')}"

  pageLink: (page) ->
    if @page == page
      "<strong class='page-link'>#{page}</strong>"
    else
      "<a class='page-link' href='?page=#{page}'>#{page}</a>"


module.exports = Paginator
