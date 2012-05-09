class @Paginator

  constructor: (config) ->
    @limit = @perPage = config.perPage
    @window = config.window || 10
    @setCount(config.count)
    @setPage(config.page)

  setPage: (page) ->
    @page = parseInt(page) || 1
    @page = @pageCount if @page > @pageCount
    @skip = (@page - 1) * @perPage

  setCount: (count) ->
    @count = count
    @pageCount = Math.floor(@count / @perPage)
    @pageCount++ unless @count % @perPage == 0

  pageLinks: ->
    if @pageCount > 0
      start = Math.max(1, Math.round(@page - @window/2))
      stop = Math.min(@pageCount, start + @window)
      links = (@pageLink(page) for page in [start..stop])

      # elipsis at front
      if start > 1
        # only a single page in the gap, so just put the page
        if start == 3
          links.unshift @pageLink(2)
        # multiple pages, use elipsis
        else if start > 3
          links.unshift @pageLink(Math.round(start/2), '...')
        # first page
        links.unshift @pageLink(1)

      # elipsis at end
      if stop < @pageCount
        # only a single page in the gap, so just put the page
        if stop == @pageCount - 2
          links.push @pageLink(@pageCount - 1)
        # multiple pages, use elipsis
        else if stop < @pageCount - 2
          p = Math.round stop + ((@pageCount - stop) / 2)
          links.push @pageLink(p, '...')
        # last page
        links.push @pageLink(@pageCount)
      "<ul>#{links.join ' '}</ul>"

  pageLink: (page, label) ->
    label ?= page
    params = app.helpers.params()
    params.page = page
    pairs = ("#{k}=#{v}" for k, v of params)
    "<li class='#{'active' if @page == page}'><a href='?#{pairs.join '&'}'>#{label}</a></li>"
