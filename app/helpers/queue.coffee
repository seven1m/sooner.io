sortCol = require('./app').sortCol

escape = (text) ->
  new String(text || '').replace(/</g, '&lt;').replace(/>/g, '&gt;')

escapeAndLink = (text) ->
  escape(text).replace(/https?:\/\/\S+/g, "<a href='$&'>$&</a>")

row = (k, v, query) ->
  key = sortCol(escape(k), '["data.' + escape(k) + '",1]', {query: query})
  "<tr><td>#{key}</td><td>#{escapeAndLink v}</td></tr>"

exports.queueData = (data, query) ->
  if data && typeof data == 'object'
    "<table>\n" +
    (row(k, v, query) for k, v of data).join("\n") +
    "\n</table>"
  else
    JSON.stringify data
