{CheckPipe} = require './checkPipe'
util = require 'util'
sdmx = require '../pipe/sdmxPipe'

emptySchemaForSeries = ->
	$schema : 'http://json-schema.org/draft-03/schema#'
	id: 'urn:sdmxfeeder.infomodel.dsdspecific.series'
	type: 'object'
	additionalProperties: false
	properties:
		seriesKey:
			type: 'object'
			required: true
			additionalProperties: false
			properties: {}
		attributes:
			type: 'object'
			additionalProperties: false
			properties: {}
		obs:
			type: 'object'
			additionalProperties: false
			properties:
				obsDimension:
					type: 'array'
					required: true
					items:
						type: 'string'
				obsValue:
					type: 'array'
					items:
						type: 'number'
				attributes:
					type: 'object'
					required: true
					additionalProperties: false
					properties: {}


class StructureSpecificCheckPipe extends CheckPipe
	constructor: (log) ->
		@schemas = {}
		@structures = {}
		super

	findSchema: (type) ->
		@jsvenv.findSchema 'urn:sdmxfeeder.infomodel.dsdspecific.' + type

	write: (sdmxdata) ->
		switch sdmxdata.type
			when sdmx.CODE_LIST
				@structures.codelists ?= {}
				@structures.codelists[ @getItemID sdmxdata.data ] = sdmxdata.data
			when sdmx.CONCEPT_SCHEME
				@structures.conceptSchemes ?= {}
				@structures.conceptSchemes[ @getItemID sdmxdata.data ] = sdmxdata.data
			when sdmx.DATA_STRUCTURE_DEFINITION
				@jsvenv.createSchema( @convertToSeriesSchema sdmxdata.data )
		super


	getItemID: (item) ->
		"#{item.agencyID}:#{item.id}(#{item.version})"

	getItemParentID: (item) ->
		"#{item.agencyID}:#{item.maintainableParentID}(#{item.maintainableParentVersion})"

	addEnumeration: (enumeration, target) ->
		return unless enumeration?
		codelist = @structures.codelists[ @getItemID enumeration.ref ]
		return unless codelist?
		codes = []
		codes.push code for code of codelist.codes
		target.enum = codes

	addTextFormat: (format, target) ->
		return unless format?
		target.type = switch format.textType
			when 'Numeric' then 'number'
			else 'string'
		target.minLength = format.minLength if format.minLength?
		target.maxLength = format.maxLength if format.maxLength?

	findConcept: (ref) ->
		conceptScheme = @structures.conceptSchemes[ @getItemParentID(ref) ]
		conceptScheme?.concepts[ ref?.id ]

	convertRepresentation: (comp, target) ->
		concept = @findConcept comp.conceptIdentity?.ref
		@addEnumeration concept?.coreRepresentation?.enumeration, target
		@addEnumeration comp.localRepresentation?.enumeration, target
		@addTextFormat concept?.coreRepresentation?.textFormat, target
		@addTextFormat comp.localRepresentation?.textFormat, target

	addDimensions: (schema, dataStructure) ->
		for key, comp of dataStructure.dimensionDescriptor when comp.type isnt 'timeDimension'
			dim = {}
			dim.type = 'string'
			dim.required = true
			@convertRepresentation comp, dim
			schema.properties.seriesKey.properties[ key ] = dim

	addAttributes: (schema, dataStructure) ->
		for key, comp of dataStructure.attributeDescriptor when comp.attributeRelationship.dimensions?
			dim = {}
			dim.type = 'string'
			dim.required = true if comp.usageStatus is 'Mandatory'
			@convertRepresentation comp, dim
			schema.properties.attributes.properties[ key ] = dim

	addObsAttributes: (schema, dataStructure) ->
		for key, comp of dataStructure.attributeDescriptor when comp.attributeRelationship.primaryMeasure?
			dim = {}
			dim.type = 'array'
			dim.required = true if comp.usageStatus is 'Mandatory'
			dim.items = {}
			@convertRepresentation comp, dim.items
			schema.properties.obs.properties.attributes.properties[ key ] = dim

	convertToSeriesSchema: (dataStructure, structures) ->
		schema = emptySchemaForSeries()

		@addDimensions schema, dataStructure
		@addAttributes schema, dataStructure
		@addObsAttributes schema, dataStructure

		schema

exports.StructureSpecificCheckPipe = StructureSpecificCheckPipe
