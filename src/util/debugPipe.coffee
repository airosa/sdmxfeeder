{SdmxPipe} = require '../pipe/sdmxPipe'
util = require 'util'


class DebugPipe extends SdmxPipe
	constructor: (log) ->
		super

	processData: (sdmxdata) ->
		console.log  util.inspect( sdmxdata, true, null, false )
		super


exports.DebugPipe = DebugPipe
