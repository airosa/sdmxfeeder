sdmx = require '../pipe/sdmxPipe'
{JSV} = require 'JSV'
util = require 'util'

_ = require 'underscore'


class CheckPipe extends sdmx.SdmxPipe
	constructor: (log) ->
		@errors = []
		@jsvenv = JSV.createEnvironment 'json-schema-draft-03'
		@loadSchemas()
		@validationCount = 0
		super log

	processData: (sdmxdata) ->
		@assert sdmxdata.type?, "data event must have property 'type'"
		@assert sdmxdata.data?, "data event must have property 'data'"
		@validate sdmxdata.data, sdmxdata.type if sdmxdata.data? and sdmxdata.type?
		@checkEventOrder sdmxdata.type
		super sdmxdata

	# Checking methods

	checkEventOrder: (type) ->
		@errors.push "Header should be the first event"  if @counters.objects is 0 and type isnt sdmx.HEADER
		switch type
			when sdmx.CODE_LIST, sdmx.CONCEPT_SCHEME, sdmx.DATA_STRUCTURE_DEFINITION
				@errors.push 'Header should come before structures' if @counters.header is 0
				@errors.push 'Structures should come before data' if 0 < @counters.data
			when sdmx.DATA_SET_HEADER
				@errors.push 'Header should come before data set header' if @counters.header is 0
			when sdmx.DATA_SET_ATTRIBUTES, sdmx.ATTRIBUTE_GROUP, sdmx.SERIES
				@errors.push 'Data set header should come before data' if @counters.datasetheader is 0
				@errors.push 'Header should come before data' if @counters.header is 0

	validate: (data, type) ->
		schema = @findSchema type
		if schema?
			errors = schema.validate( data ).errors
			for error in errors
				@errors.push "#{@getReadableID type, data}: #{error.message + ' ' + error.schemaUri + ' ' + error.attribute + ' ' + error.details}"
			@validationCount += 1

	getReadableID: (type, obj) ->
		switch type
			when 'series'
				type + ' ' + (value for key, value of obj.seriesKey).join '.'
			when 'group'
				type + ' ' + (value for key, value of obj.groupKey).join '.'
			else
				type + ( if obj.id? then " #{obj.id}" else '' )

	findSchema: (type) ->

	loadSchemas: ->

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

	validateOld: (obj, schema, path) ->
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


exports.CheckPipe = CheckPipe
