module.exports =

  pluralize: (count, word) ->
    # a bit naiive I suppose
    plural = if word.match(/s$/) then word else "#{word}s"
    if count == 1
      "#{count} #{word}"
    else
      "#{count} #{plural}"
