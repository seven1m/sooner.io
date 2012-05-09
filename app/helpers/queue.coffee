app.helpers ?= {}

escape = (text) ->
  new String(text || '').replace(/</g, '&lt;').replace(/>/g, '&gt;')

escapeAndLink = (text) ->
  escape(text).replace(/https?:\/\/\S+/g, "<a href='$&'>$&</a>")

row = (k, v) ->
  key = app.helpers.sortCol(escape(k), '["data.' + escape(k) + '",1]')
  "<tr><td>#{key}</td><td>#{escapeAndLink v}</td></tr>"

app.helpers.queueData = (data) ->
  if data && typeof data == 'object'
    "<table>\n" +
    (row(k, v) for k, v of data).join("\n") +
    "\n</table>"
  else
    JSON.stringify data
