{SDMXStream} = require '../sdmxStream'
util = require 'util'
_ = require 'underscore'


class Checker extends SDMXStream
	constructor: (log) ->
		@errors = []
		super log

	write: (sdmxdata) ->
		@assert sdmxdata.type?, "data event must have property 'type'"
		@assert sdmxdata.data?, "data event must have property 'data'"
		@check sdmxdata.data, sdmxdata.type if sdmxdata.data? and sdmxdata.type?
		super sdmxdata

	# Checking methods

	getSchema: (schemaID, forJSON) ->

	getID: (schemaID, obj) ->
		switch schemaID
			when 'series'
				schemaID + ':' + (value for key, value of obj.seriesKey).join '.'
			when 'group'
				schemaID + ':' + (value for key, value of obj.groupKey).join '.'
			else
				schemaID

	assert: (value, msg, context) ->
		@errors.push "#{msg} in #{context}" unless value

	validateSimpleType: (obj, type, path) ->
		switch type
			when 'integer'
				@assert typeof obj is 'number', "value should be number but is #{typeof obj}", path
				@assert obj % 1 is 0, "value should be integer but is #{obj}", path unless obj isnt obj
			when 'array'
				@assert Array.isArray obj, "value should be array but is #{typeof obj}", path
			when 'date'
				@assert obj instanceof Date, "value should be date but is #{obj}", path
			when 'null'
				@assert obj is null, "value should be null but is #{obj}", path
			when 'any'
				@assert typeof obj isnt 'undefined', 'value must be defined', path
			else
				@assert typeof obj is type, "value should be #{type} but is #{typeof obj}", path

	validateType: (obj, schema, path) ->
		return unless schema.type?
		@validateSimpleType obj, schema.type

	validateEnum: (obj, schema, path) ->
		return unless schema.enum?
		result = (item for item in schema.enum when item is obj)
		@assert result.length is 1, "value #{obj} is not in [#{schema.enum.join(',')}]", path

	validatePattern: (obj, schema, path) ->
		return unless schema.pattern?
		@assert new RegExp(schema.pattern).test(obj), "value #{obj} does not match pattern #{schema.pattern}", path

	validateLength: (obj, schema, path) ->
		if schema.minLength?
			@assert schema.minLength <= obj.length , "value #{obj} must be longer than #{schema.minLength}", path
		if schema.maxLength?
			@assert obj.length <= schema.maxLength, "value #{obj} must be shorter than #{schema.maxLength}", path

	validateRequired: (obj, schema, path) ->
		@assert typeof obj isnt 'undefined', "#{path} is required", path if schema.required? and schema.required
		#if schema.properties?
		#	@validateRequired obj[property], value, context, property for property, value of schema.properties

	validateProperties: (obj, schema, path) ->
		return unless schema.properties? or schema.patternProperties?
		@assert typeof obj is 'object', "value should be object but is #{typeof obj}", path
		return unless typeof obj is 'object'
		if schema.properties?
			for property, value of schema.properties
				@validate obj[property], value, "#{path}/#{property}"
			if schema.patternProperties?
				for property, value of obj
					continue if schema.properties[property]
					for pattern, subschema of schema.patternProperties
						@validate value, subschema, "#{path}/#{property}" if property.match pattern
		else
			if schema.patternProperties?
				for property, value of obj
					for pattern, subschema of schema.patternProperties
						@validate value, subschema, "#{path}/#{property}" if property.match pattern

	validateAdditionalProperties: (obj, schema, path) ->
		return unless schema.additionalProperties? and not schema.additionalProperties
		@assert typeof obj is 'object', "value should be object but is #{typeof obj}", path
		return unless typeof obj is 'object'
		if schema.properties?
			if schema.patternProperties?
				for property of obj
					matched = false
					matched = schema.properties[property]
					if not matched
						for pattern of schema.patternProperties
							matched = true if property.match pattern
					@assert matched, "property #{property} is not allowed", path
			else
				@assert schema.properties[property]?, "property #{property} is not allowed", path for property of obj
		else
			if schema.patternProperties?
				for property of obj
					matched = false
					for pattern of schema.patternProperties
						matched = true if property.match pattern
					@assert matched, "property #{property} is not allowed", path

	validateItems: (obj, schema, path) ->
		return unless schema.items?
		@assert Array.isArray obj, "#{obj} is not an Array", path
		@validate item, schema.items, "#{path}/#{item}" for item in obj

	validateUniqueItems: (obj, schema, path) ->
		return unless schema.uniqueItems? and schema.uniqueItems
		@assert Array.isArray obj, "#{obj} is not an Array", path
		@assert obj.length is _.uniq(obj).length, "All items in array #{obj} must be unique", path

	addDefaultValues: (obj, schema) ->
		return unless schema.properties?
		return unless typeof obj is 'object'
		for key of schema.properties when schema.properties[key].default?
			obj[key] = schema.properties[key].default unless obj[key]?

	validate: (obj, schema, path) ->
		@validateRequired obj, schema, path
		return if typeof obj is 'undefined'
		@validateType obj, schema, path
		@validateEnum obj, schema, path
		@validatePattern obj, schema, path
		@validateLength obj, schema, path
		@validateAdditionalProperties obj, schema, path
		@validateProperties obj, schema, path
		@validateItems obj, schema, path
		@validateUniqueItems obj, schema, path
		@addDefaultValues obj, schema

	check: (data, schemaID, forJSON = false) ->
		schema = @getSchema schemaID, forJSON
		if schema?
			@validate data, schema, "#{@getID(schemaID,data)}"
		else
			@log.debug "No schema for #{schemaID}"


exports.Checker = Checker
