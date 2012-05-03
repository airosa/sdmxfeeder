sdmx = require '../pipe/sdmxPipe'


class SimpleRegistry
	constructor: (@log) ->
		@cache = {}


	query: (type, ref, callback) ->
		@log.debug "#{@constructor.name} query"
		result = @cache[type]?[ref.agencyID]?[ref.id]?[ref.version]
		process.nextTick ( -> callback null, result )


	match: (type, data, callback ) ->
		@log.debug "#{@constructor.name} match"
		for agencyId, ids of @cache[sdmx.DATA_STRUCTURE_DEFINITION]
			for id, versions of ids
				for version, dsd of versions
					if @matchComponentsToDSD type, data, dsd
				  		process.nextTick ( -> callback null, dsd )
				  		return
		process.nextTick callback


	submit: (data, callback) ->
		@log.debug "#{@constructor.name} submit"
		type = @findType data
		if type? and data.agencyID? and data.id?
			version = if data.version? then data.version else '1.0'
			@cache[type] ?= {}
			@cache[type][data.agencyID] ?= {}
			@cache[type][data.agencyID][data.id] ?= {}
			@cache[type][data.agencyID][data.id][version] = data
		process.nextTick callback


	findType: (data) ->
		return sdmx.CODE_LIST if data.codes?
		return sdmx.CONCEPT_SCHEME if data.concepts?
		return sdmx.DATA_STRUCTURE_DEFINITION if data.dimensionDescriptor?
		return null


	matchComponentsToDSD: (type, data, dsd) ->
		if data.components?
			for key, value of data.components
				isDimension = dsd.dimensionDescriptor[key]?
				isAttribute = dsd.attributeDescriptor[key]?
				isMeasure = dsd.measureDescriptor.primaryMeasure.id is key
				return false unless isDimension or isAttribute or isMeasure
			return true

		if type is sdmx.SERIES
			for key, value of data.seriesKey
				return false unless dsd.dimensionDescriptor[key]?
			for key, value of data.attributes
				return false unless dsd.attributeDescriptor[key]?

		if type is sdmx.ATTRIBUTE_GROUP
			for key, value of data.groupKey
				return false unless dsd.dimensionDescriptor[key]?
			for key, value of data.attributes
				return false unless dsd.attributeDescriptor[key]?

		if type is sdmx.DATA_SET_ATTRIBUTES
			for key, value of data
				return false unless dsd.attributeDescriptor[key]?

		return true



exports.SimpleRegistry = SimpleRegistry
