escape = (text) ->
  (text || '').replace(/</g, '&lt;').replace(/>/g, '&gt;')

escapeAttr = (text) ->
  escape(text).replace(/'/g, "\\'")

inputTag = exports.inputTag = (obj, field, options) ->
  options ||= {}
  if options.tag == 'input' || !options.tag
    "<input class='#{options.inputClass || 'input-medium'}' name='#{field}' id='#{field}' value='#{escapeAttr(obj[field])}'/>"
  else if options.tag == 'textarea'
    "<textarea class='#{options.inputClass || 'input-medium'}' name='#{field}' id='#{field}'>#{escape(obj[field])}</textarea>"
  else
    "unsupported"

exports.field = (obj, field, options) ->
  "<div class='control-group #{obj.errors && obj.errors[field] && 'error'}'>
    <label class='control-label' for='#{field}'>#{options.label || field[0].toUpperCase() + field.slice(1)}</label>
    <div class='controls'>
      #{options.input || inputTag(obj, field, options)}
      #{options.help && "<span class='help-inline'>" + options.help + "</span>" || ''}
    </div>
  </div>"

