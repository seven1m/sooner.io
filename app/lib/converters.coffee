app.converters = {}

for type, formats of app.formats
  for name, format of formats
    app.converters[type] ?= {}
    app.converters[type][name] = ((f) -> (_, v) -> new Date(v).toString(f))(format)
