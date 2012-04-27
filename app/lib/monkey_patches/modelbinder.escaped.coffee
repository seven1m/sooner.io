# set ModelBinder to set text() by default
#
Backbone.ModelBinder.prototype._origSetElValue = Backbone.ModelBinder.prototype._setElValue

Backbone.ModelBinder.prototype._setElValue = (el, convertedValue) ->
  if el.attr('type') || el.is('input') || el.is('select') || el.is('textarea')
    @_origSetElValue(el, convertedValue)
  else
    el.text(convertedValue)
