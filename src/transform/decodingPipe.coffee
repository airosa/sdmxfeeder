sdmx = require '../pipe/sdmxPipe'

#-------------------------------------------------------------------------------

decodeCodeValue = (key, value, decoder, lang) ->
	decoder.codelist?[key]?[value]?.name[lang] ? value


decodeConcept = (key, decoder, lang) ->
	decoder.concept?[key]?[lang] ? key


decodeSeries = (series, decoder, lang) ->
	for key, value of series.seriesKey
		series.seriesKey[ key ] = decodeCodeValue key, value, decoder, lang

	decodedObsDimension = []
	for value in series.obs.obsDimension
		decodedObsDimension.push decodeCodeValue decoder.obsDimension, value, decoder, lang
	series.obs.obsDimension = decodedObsDimension

	if series.attributes?
		for key, value of series.attributes
			series.attributes[ key ] = decodeCodeValue key, value, decoder, lang

	if series.obs.attributes?
		for key, values of series.obs.attributes
			decodedValues = []
			for value in values
				decodedValues.push decodeCodeValue key, value, decoder, lang
			series.obs.attributes[ key ] = decodedValues


buildDecoder = (dsds, conceptSchemes, codelists) ->
	decoder =
		concept: {}
		codelist: {}

	dsd = dsds[ Object.keys(dsds)[0] ]

	addComponent = (component) ->
		ref = component.conceptIdentity.ref
		cs = conceptSchemes["#{ref.agencyID}:#{ref.maintainableParentID}(#{ref.maintainableParentVersion})"]
		decoder.concept[key] = cs.concepts[key].name

		ref = component.localRepresentation?.enumeration?.ref

		if ref?
			cl = codelists["#{ref.agencyID}:#{ref.id}(#{ref.version})"]
			decoder.codelist[key] = cl.codes

	for key, value of dsd.dimensionDescriptor
		addComponent value

	for key, value of dsd.attributeDescriptor
		addComponent value

	decoder

#-------------------------------------------------------------------------------

class DecodingPipe extends sdmx.SdmxPipe
	constructor: (@log, @registry) ->
		@lang = 'en'
		@decoder = {}
		@header = {}
		@waiting = false
		super @log


	processData: (data) ->
		@log.debug "#{@constructor.name} processData"
		switch data.type
			when sdmx.HEADER
				@header = data.data
			when sdmx.DATA_SET_HEADER
				@pause() unless @paused
				structure = @header.structure[data.data.structureRef]
				@decoder.obsDimension = structure.dimensionAtObservation
				@registry.query sdmx.DATA_STRUCTURE_DEFINITION, structure.structureRef.ref, true, @callbackForQuery
				@waiting = true
			when sdmx.SERIES
				decodeSeries data.data, @decoder, @lang unless @waiting
		super data


	callbackForQuery: (err, result) =>
		@log.debug "#{@constructor.name} callbackForQuery"
		throw new Error 'Missing Data Structure Definition' unless result?
		@waiting = false
		@decoder = buildDecoder result.dataStructureDefinitions, result.conceptSchemes, result.codeLists

		for data in @queue.out when data.name is 'data' and data.arg.type is sdmx.SERIES
			decodeSeries data.arg.data, @decoder, @lang

		@resume()

#-------------------------------------------------------------------------------

exports.DecodingPipe = DecodingPipe
