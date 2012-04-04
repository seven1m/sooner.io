module.exports =

  pluralize: (count, word, plword) ->
    # a bit naiive I suppose
    plword ||= if word.match(/s$/) then word else "#{word}s"
    if count == 1
      "#{count} #{word}"
    else
      "#{count} #{plword}"

  sortCol: (label, sort, params) ->
    console.log params
    params = ("#{k}=#{v}" for k, v of params).join('&')
    console.log params
    "<a href='?sort=#{sort}&#{params}'>#{label}</a>"
