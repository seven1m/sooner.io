escape = (text) ->
  new String(text || '').replace(/</g, '&lt;').replace(/>/g, '&gt;')

escapeAndLink = (text) ->
  escape(text).replace(/https?:\/\/\S+/g, "<a href='$&'>$&</a>")

row = (k, v) ->
  "<tr><td>#{escape k}</td><td>#{escapeAndLink v}</td></tr>"

exports.queueData = (data) ->
  if data && typeof data == 'object'
    "<table>\n" +
    (row(k, v) for k, v of data).join("\n") +
    "\n</table>"
  else
    JSON.stringify data
