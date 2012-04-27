app.helpers ?= {}

escape = (text) ->
  new String(text || '').replace(/</g, '&lt;').replace(/>/g, '&gt;')

escapeAttr = (text) ->
  escape(text).replace(/'/g, "\\'")

escapeAndLink = (text) ->
  escape(text).replace(/https?:\/\/\S+/g, "<a href='$&'>$&</a>")

inputTag = app.helpers.inputTag = (obj, field, options) ->
  options ||= {}
  if options.tag == 'input' || !options.tag
    if options.tagType == 'checkbox'
      "<input type='hidden' class='#{options.inputClass || 'input-medium'}' name='#{field}' id='#{field}' value='0'/>"
      "<input type='checkbox' class='#{options.inputClass || 'input-medium'}' name='#{field}' id='#{field}' value='1' #{obj[field] && 'checked="checked"'}/>"
    else
      "<input class='#{options.inputClass || 'input-medium'}' name='#{field}' id='#{field}' value='#{escapeAttr(obj[field])}'/>"
  else if options.tag == 'textarea'
    "<textarea class='#{options.inputClass || 'input-medium'}' name='#{field}' id='#{field}'>#{escape(obj[field])}</textarea>"
  else
    "unsupported"

app.helpers.field = (obj, field, options) ->
  "<div class='control-group #{obj.errors && obj.errors[field] && 'error' || ''}'>
    <label class='control-label' for='#{field}'>#{options.label || field[0].toUpperCase() + field.slice(1)}</label>
    <div class='controls'>
      #{options.input || inputTag(obj, field, options)}
      #{options.help && "<span class='help-inline'>" + options.help + "</span>" || ''}
    </div>
  </div>"

app.helpers.escapeAndLink = escapeAndLink
