{SDMXStream} = require '../sdmxStream'

class DebugHandler extends SDMXStream
	constructor: (log) ->
		super

	write: (sdmxdata) =>
		@log.debug "#{@constructor.name} #{sdmxdata.type} #{@counters[sdmxdata.type]} #{sdmxdata.sequenceNumber}"
		super


exports.DebugHandler = DebugHandler
