sdmx = require '../pipe/sdmxPipe'

SETUP = 0
WAITING_PASSTHROUGH = 1
WAITING_CONVERT = 2
CONVERT = 3
PASSTHROUGH = 4


class ConvertCompactPipe extends sdmx.SdmxPipe
	constructor: (log, @registry) ->
		@state = SETUP
		@dsd = {}
		@convertQueue = []
		super


	processData: (sdmxdata) ->
		@log.debug "#{@constructor.name} processData"
		switch @state
			when SETUP
				@pause() unless @paused
				@doSetup sdmxdata
				super
			when WAITING_CONVERT, WAITING_PASSTHROUGH
				@convertQueue.push sdmxdata
				super
			when CONVERT
				super (@convert sdmxdata)
			when PASSTHROUGH
				super


	doSetup: (sdmxdata) ->
		@log.debug "#{@constructor.name} doSetup"
		switch sdmxdata.type
			when sdmx.HEADER
				@header = sdmxdata
			when sdmx.DATA_SET_HEADER
				@dataSetHeader = sdmxdata
				@repairHeaderRefs @header.data, @dataSetHeader.data
			when sdmx.DATA_SET_ATTRIBUTES, sdmx.SERIES, sdmx.ATTRIBUTE_GROUP
				ref = @header.data.structure[ @dataSetHeader.data.structureRef ].structureRef

				if sdmxdata.data.components?
					@state = WAITING_CONVERT

					if ref?
						@registry.query sdmx.DATA_STRUCTURE_DEFINITION, ref, false, @doCallbackForFind
					else
						@registry.match sdmxdata.type, sdmxdata.data, @doCallbackForFind
					@convertQueue.push sdmxdata
				else
					@state = PASSTHROUGH

					if not ref?
						@state = WAITING_PASSTHROUGH
						@registry.match sdmxdata.type, sdmxdata.data, @doCallbackForFind
						@convertQueue.push sdmxdata
			else
				@state = PASSTHROUGH

		if @state is PASSTHROUGH
			@resume()


	doCallbackForFind: (err, result) =>
		@log.debug "#{@constructor.name} doCallbackForFind"
		throw new Error 'Missing Data Structure Definition' unless result?
		@state = CONVERT if @state is WAITING_CONVERT
		@state = PASSTHROUGH if @state is WAITING_PASSTHROUGH
		@dsd = result
		@repairHeaderStructureRef @header.data, @dsd
		if @state is CONVERT
			for sdmxdata in @convertQueue
				@convert sdmxdata
		@resume()


	convertSeries: (sdmxdata) ->
		@log.debug "#{@constructor.name} convertSeries"
		series = sdmxdata.data
		if series.components?
			for key, value of series.components
				if @dsd.dimensionDescriptor[key]?
					series.seriesKey ?= {}
					series.seriesKey[key] = value
				else if @dsd.attributeDescriptor[key]?
					series.attributes ?= {}
					series.attributes[key] = value
			delete series.components
		sdmxdata


	convertGroup: (sdmxdata) ->
		@log.debug "#{@constructor.name} convertGroup"
		group = sdmxdata.data
		if group.components?
			for key, value of group.components
				if @dsd.dimensionDescriptor[key]?
					group.groupKey ?= {}
					group.groupKey[key] = value
				else if @dsd.attributeDescriptor[key]?
					group.attributes ?= {}
					group.attributes[key] = value
			delete group.components
		sdmxdata


	emitHeaders: ->
		@log.debug "#{@constructor.name} emitHeaders"
		@emitData @header
		@emitData @dataSetHeader if @dataSetHeader?


	convert: (sdmxdata) ->
		@log.debug "#{@constructor.name} convert"
		switch sdmxdata.type
			when sdmx.ATTRIBUTE_GROUP then @convertGroup sdmxdata
			when sdmx.DATA_SET_ATTRIBUTES then @convertGroup sdmxdata
			when sdmx.SERIES then @convertSeries sdmxdata
			else sdmxdata


	repairHeaderRefs: (header, dataSetHeader) ->
		@log.debug "#{@constructor.name} repairHeaderRefs"
		header.structure ?= {}

		if dataSetHeader.structureRef?
			header.structure[ dataSetHeader.structureRef ] ?=
				structureID: dataSetHeader.structureRef
			return

		if 0 < Object.keys(header.structure).length
			dataSetHeader.structureRef =
				header.structure[ Object.keys(header.structure)[0] ].structureID
			return

		structure = { structureID: 'STR1' }
		header.structure[ structure.structureID ] = structure
		dataSetHeader.structureRef = structure.structureID


	repairHeaderStructureRef: (header, dsd) ->
		@log.debug "#{@constructor.name} repairHeaderStructureRef"
		structure = header.structure[ Object.keys(header.structure)[0] ]
		structure.structureRef ?= {}
		if not structure.structureRef.ref?
			structure.structureRef.ref = {}
			structure.structureRef.ref.agencyID = dsd.agencyID
			structure.structureRef.ref.id = dsd.id
			structure.structureRef.ref.version = dsd.version




exports.ConvertCompactPipe = ConvertCompactPipe
