{Stream} = require 'stream'
util = require 'util'


exports.HEADER = 'header'
exports.CODE_LIST = 'codelist'
exports.CONCEPT_SCHEME = 'conceptscheme'
exports.DATA_STRUCTURE_DEFINITION = 'datastructure'
exports.DATA_SET_HEADER = 'datasetheader'
exports.ATTRIBUTE_GROUP = 'group'
exports.DATA_SET_ATTRIBUTES = 'datasetattributes'
exports.SERIES = 'series'


sdmxArtefacts =
	header: 0
	datastructure: 0
	codelist: 0
	conceptscheme: 0
	datasetheader: 0
	datasetattributes: 0
	series: 0
	group: 0
	query: 0

sdmxStructures =
	datastructure: 0
	codelist: 0
	conceptscheme: 0

sdmxData =
	datasetattributes: 0
	series: 0
	group: 0


#-------------------------------------------------------------------------------

class SdmxPipe extends Stream
	constructor: (@log) ->
		@queueLengthMax = 1000
		@readable = true
		@writable = true
		@paused = false
		@waiting = false
		@queue = {}
		@counters = {}
		@_init()
		super


	write: (data) ->
		@log.debug "#{@constructor.name} write #{if data.type? then data.type else data.length}"
		@counters.write += 1
		@_count 'in', data

		if not @writable
			throw new Error "#{@constructor.name} write after end"

		@processData data


	end: ->
		@log.debug "#{@constructor.name} end"
		@counters.end += 1
		@writable = false
		@processEnd()
		@_pushToQueue 'end'


	pause: ->
		@log.debug "#{@constructor.name} pause"
		@counters.pause += 1
		@paused = true


	resume: ->
		@log.debug "#{@constructor.name} resume"
		@counters.resume += 1
		@paused = false
		@_drain()


	xpipex: (destination) ->
		util.pump this, destination, (err) ->
			if not err then destination.end()
		return destination

#-------------------------------------------------------------------------------

	processData: (data) ->
		@log.debug "#{@constructor.name} processData (default)"
		@emitData data


	processEnd: ->
		@log.debug "#{@constructor.name} processEnd"


	emitData: (data) ->
		@log.debug "#{@constructor.name} emitData"
		@_count 'out', data if data?
		@_pushToQueue 'data', data

#-------------------------------------------------------------------------------

	_init: ->
		@queue =
			in: []
			out: []
		@counters =
			write: 0
			emit: 0
			end: 0
			pause: 0
			resume: 0
			wait: 0
			continue: 0
			error: 0
			in:
				missing: 0
				unknown: 0
				structure: 0
				data: 0
				objects: 0
				chars: 0
			out: {}
		@counters.in[key] = 0 for key of sdmxArtefacts
		@counters.out[key] = 0 for key of @counters.in


	_pushToQueue: (event, arg) ->
		@log.debug "#{@constructor.name} pushToQueue #{event}"
		@queue.out.push { name: event, arg: arg }
		@_drain()


	_drain: ->
		@log.debug "#{@constructor.name} drain"

		wasFull = @queueLengthMax < @queue.out.length

		while 0 < @queue.out.length and not @paused
			event = @queue.out.shift()
			@log.debug "#{@constructor.name} emit #{event.name}"
			@counters.emit += 1
			@emit event.name, event.arg

		isFull = @queueLengthMax < @queue.out.length

		if isFull
			false
		else
			if wasFull
				@log.debug "#{@constructor.name} emit drain"
				@emit 'drain'
			true


	_count: (direction, data) ->
		if data?
			@counters[direction][data.type] += 1 if @counters[direction][data.type]?
			@counters[direction].unknown += 1 unless @counters[direction][data.type]?
			@counters[direction].structure += 1 if sdmxStructures[data.type]?
			@counters[direction].data += 1 if sdmxData[data.type]?
			@counters[direction].objects += 1 if @counters[direction][data.type]?
			@counters[direction].chars += data.length if data.length?
		else
			@counters[direction].missing += 1

#-------------------------------------------------------------------------------


class ReadSdmxPipe extends SdmxPipe
	constructor: (log) ->
		@sequenceNumber = 0
		super


	bufferToStr: (data) ->
		if typeof data is 'string' then data else data.toString 'utf8'


	emitSDMX: (type, artefact) ->
		@sequenceNumber += 1
		@emitData
			type: type,
			sequenceNumber: @sequenceNumber
			data: artefact

#-------------------------------------------------------------------------------


class WriteSdmxPipe extends SdmxPipe
	constructor: (log) ->
		@previous = ''
		super


	processData: (sdmxdata) ->
		@log.debug "#{@constructor.name} processData"
		current = sdmxdata.type
		data = sdmxdata.data
		str = ''
		if @previous is current
			str += @beforeNext( current )
		else
			str += @afterLast( @previous )
			str += @beforeFirst( current, data )
		str += @before( current, data )
		str += @stringify( current, data )
		@previous = current
		@emitData str


	processEnd: ->
		@log.debug "#{@constructor.name} processEnd"
		current = 'end'
		str = ''
		if @previous is current
			str += @beforeNext( 'end' )
		else
			str += @afterLast( @previous )
			str += @beforeFirst( current )
		@previous = current
		@emitData str


	before: (event, data) -> ''


	beforeNext: (event) -> ''


	beforeFirst: (event, data) -> ''


	stringify: (event, data) -> ''


	afterLast: (event) -> ''

#-------------------------------------------------------------------------------

exports.SdmxPipe = SdmxPipe
exports.ReadSdmxPipe = ReadSdmxPipe
exports.WriteSdmxPipe = WriteSdmxPipe
