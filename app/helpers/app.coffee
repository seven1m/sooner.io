module.exports =

  pluralize: (count, word, plword) ->
    # a bit naiive I suppose
    plword ||= if word.match(/s$/) then word else "#{word}s"
    if count == 1
      "#{count} #{word}"
    else
      "#{count} #{plword}"
