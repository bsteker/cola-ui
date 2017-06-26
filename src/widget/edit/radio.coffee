class cola.RadioGroup extends cola.AbstractEditor
	@tagName: "c-radio-group"
	@CLASS_NAME: "ui radio-group"
	@attributes:
		items:
			expressionType: "repeat"
			setter: (items) ->
				if not @_valueProperty and not @_textProperty
					result = cola.util.decideValueProperty(items)
					if result
						@_valueProperty = result.valueProperty
						@_textProperty = result.textProperty

				@_items = items
				unless @_itemsTimestamp == items?.timestamp
					if items then @_itemsTimestamp = items.timestamp
					delete @_itemsIndex
				return

		valueProperty: null
		textProperty: null

	_initDom: (dom)->
		super(dom)
		selector = @
		$(dom).delegate(">item", "click", ()->
			if selector._readOnly then return
			value=selector._getDomValue(this)
			selector._setValue(value);
			selector._select(value)
		)

	_doRefreshDom: ()->
		super()
		itemsDom = @_getItemsDom()
		if itemsDom
			$fly(@_dom).empty().append(itemsDom)
		value = @_value
		@_select(value)

	_select: (value)->
		if typeof value == "undefined"
			return
		dom = $(@_dom).find("[value='" + value + "']")
		if dom.length > 0
			dom[0].checked = true

	_getDomValue:(itemDom)->
		text=$(itemDom).find("label").text()
		item=null
		textProperty= @_textProperty

		attrBinding = @_elementAttrBindings?["items"]
		if attrBinding
			raw = attrBinding.expression.raw
			entityList=attrBinding.scope.get(raw)
			entityList && entityList.each((entity)->
				if entity.get(textProperty) is text
					item=entity
					return false
			)
		if item
			return item.get(@_valueProperty)

	_getItemsDom: ()->
		attrBinding = @_elementAttrBindings?["items"]
		@_name ?= ("name_" + cola.sequenceNo());
		if attrBinding
			textProperty = "item"
			valueProperty = "item"
			if @_textProperty
				textProperty += "." + @_textProperty
			if @_valueProperty
				valueProperty += "." + @_valueProperty
			raw = attrBinding.expression.raw

			itemsDom = cola.xRender({
				tagName: "item",
				"c-repeat": "item in " + raw,
				"c-caption": textProperty,
				content: [
					{
						tagName: "input",
						name: @_name,
						type:"radio",
						"c-value": valueProperty
					},
					{
						tagName: "label",
						"c-bind": textProperty
					}
				]
			}, attrBinding.scope)


		return itemsDom

cola.registerWidget(cola.RadioGroup)