helpers = require '../app/helpers/forms'

obj =
  name: 'Foo'

describe 'form helpers', ->

  describe 'inputTag', ->

    it 'returns an input with value by default', ->
      html = helpers.inputTag obj, 'name'
      expect(html).toMatch /<input .*value='Foo'/

    it 'returns an input with value if specified', ->
      html = helpers.inputTag obj, 'name', tag: 'input'
      expect(html).toMatch /<input .*value='Foo'/

    it 'returns a textarea with content if specified', ->
      html = helpers.inputTag obj, 'name', tag: 'textarea'
      expect(html).toMatch /<textarea.*>Foo<\/textarea>/

    it 'sets the name and id', ->
      html = helpers.inputTag obj, 'name', tag: 'input'
      expect(html).toMatch /<input.* name='name' id='name'/

    it 'sets the css class to input-medium if not specified', ->
      html = helpers.inputTag obj, 'name'
      expect(html).toMatch /class='input-medium'/

    it 'sets the css class if specified', ->
      html = helpers.inputTag obj, 'name', inputClass: 'input-xlarge'
      expect(html).toMatch /class='input-xlarge'/

    it 'escapes the field value', ->
      html = helpers.inputTag {name: "'bar'"}, 'name'
      expect(html).toMatch /value='\\'bar\\''/
      html = helpers.inputTag {name: "<bar>"}, 'name'
      expect(html).toMatch /value='&lt;bar&gt;'/

    it 'escapes the field content', ->
      html = helpers.inputTag {name: "<i>'bar'</i>"}, 'name', tag: 'textarea'
      expect(html).toMatch />&lt;i&gt;'bar'&lt;\/i&gt;/
