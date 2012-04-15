{Checker} = require './checker'
util = require 'util'


class StructureSpecificChecker extends Checker
	constructor: (log) ->
		@schemas = {}
		super

	getItemID: (item) ->
		"#{item.agencyID}:#{item.id}(#{item.version})"

	getItemParentID: (item) ->
		"#{item.agencyID}:#{item.maintainableParentID}(#{item.maintainableParentVersion})"

	addEnum: (enumeration, target, codelists) ->
		return unless enumeration?
		codelist = codelists[ @getItemID enumeration.ref ]
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

	addFromRepresentation: (comp, target, structs) ->
		conceptScheme = structs.conceptSchemes[ @getItemParentID(comp.conceptIdentity?.ref) ]
		concept = conceptScheme?.concepts[ comp.conceptIdentity?.ref?.id ]
		@addEnum concept?.coreRepresentation?.enumeration, target, structs.codelists
		@addEnum comp.localRepresentation?.enumeration, target, structs.codelists
		@addTextFormat concept?.coreRepresentation?.textFormat, target
		@addTextFormat comp.localRepresentation?.textFormat, target

	addDimensions: (source, target, structs) ->
		for key, comp of source when comp.type isnt 'timeDimension'
			@log.debug "adding dimension #{key}"
			dim = {}
			dim.type = 'string'
			dim.required = true
			@addFromRepresentation comp, dim, structs
			target[ key ] = dim

	addAttributes: (source, target, structs) ->
		for key, comp of source when comp.attributeRelationship.dimensions?
			@log.debug "adding attribute #{key}"
			dim = {}
			dim.type = 'string'
			dim.required = true if comp.usageStatus is 'Mandatory'
			@addFromRepresentation comp, dim, structs
			target[ key ] = dim

	addObsAttributes: (source, target, structs) ->
		for key, comp of source when comp.attributeRelationship.primaryMeasure?
			@log.debug "adding obs attribute #{key}"
			dim = {}
			dim.type = 'array'
			dim.required = true if comp.usageStatus is 'Mandatory'
			dim.items = {}
			@addFromRepresentation comp, dim.items, structs
			target[ key ] = dim

	convertToJSONSchema: (structs) ->
		schema =
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

		@addDimensions structs.dataStructure.dimensionDescriptor, schema.properties.seriesKey.properties, structs
		@addAttributes structs.dataStructure.attributeDescriptor, schema.properties.attributes.properties, structs
		@addObsAttributes structs.dataStructure.attributeDescriptor, schema.properties.obs.properties.attributes.properties, structs

		@schemas.series = schema

	getSchema: (schemaID, forJSON = false) ->
		@schemas[schemaID]

	write: (sdmxdata) =>
		if sdmxdata.type is 'header' and sdmxdata.structures?
			@convertToJSONSchema sdmxdata.structures
		super


exports.StructureSpecificChecker = StructureSpecificChecker
