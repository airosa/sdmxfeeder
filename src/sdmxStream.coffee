{Stream} = require 'stream'

sdmxArtefacts =
	header: 0
	dataStructure: 0
	codelist: 0
	conceptScheme: 0
	dataSet: 0
	dataSetAttributes: 0
	series: 0
	group: 0
	query: 0

sdmxStructures =
	dataStructure: 0
	codelist: 0
	conceptScheme: 0

sdmxData =
	dataSetAttributes: 0
	series: 0
	group: 0

class SDMXStream extends Stream
	constructor: (@log) ->
		@readable = true
		@writable = true
		@counters =
			missing: 0
			undefined: 0
			unknown: 0
			error: 0
			structure: 0
			data: 0
		@counters[key] = 0 for key of sdmxArtefacts

	count: (data) ->
		if data?
			if data.type?
				if sdmxArtefacts[data.type]?
					@log.debug "#{@constructor.name} #{data.type}"
					@counters[data.type] += 1
				else
					@log.debug "#{@constructor.name} unknown #{data.type}"
					@counters.unknown += 1
			else
				@log.debug "#{@constructor.name} undefined data.type"
				@counters.undefined += 1
		else
			@log.debug "#{@constructor.name} undefined data"
			@counters.missing += 1
		@counters.structure += 1 if sdmxStructures[data.type]?
		@counters.data += 1 if sdmxData[data.type]?

	write: (data) ->
		@count data
		@emit 'data', data
		true

	end: ->
		@readable = false
		@writable = false
		@emit 'end'

	destroy: ->
		@readable = false
		@writable = false
		@emit 'close'


class StringToSDMXStream extends SDMXStream
	constructor: (@log) ->
		@readable = true
		@writable = true
		@sequenceNumber = 0
		@charsRead = 0
		super

	bufferToStr: (data) ->
		if typeof data is 'string'
			data
		else
			data.toString 'utf8'

	write: (str) =>
		@charsRead += str.length
		true

	emitSDMX: (type, artefact) ->
		@log.debug "#{@constructor.name} emit #{type}"
		@sequenceNumber += 1
		@emit 'data', { 'type': type, 'sequenceNumber': @sequenceNumber, 'data': artefact }


class SDMXToStringStream extends SDMXStream
	constructor: (log) ->
		@readable = true
		@writable = true
		@charsWritten = 0
		@previous = ''
		super

	write: (sdmxdata) ->
		current = sdmxdata.type
		data = sdmxdata.data
		str = ''
		if @previous is current
			str += @beforeNext( current )
		else
			str += @afterLast( @previous )
			str += @beforeFirst( current )
		str += @before( current, data )
		str += @stringify( current, data )
		@previous = current
		@count sdmxdata
		@emitStr str

	end: ->
		str = ''
		str += @afterLast( @previous )
		str += @beforeFirst('end')
		@emitStr str
		super

	emitStr: (str) ->
		@charsWritten += str.length
		@emit 'data', str if 0 < str.length

	before: (event, data) -> ''

	beforeNext: (event) -> ''

	beforeFirst: (event) -> ''

	stringify: (event, data) -> ''

	afterLast: (event) -> ''


exports.SDMXStream = SDMXStream
exports.StringToSDMXStream = StringToSDMXStream
exports.SDMXToStringStream = SDMXToStringStream
