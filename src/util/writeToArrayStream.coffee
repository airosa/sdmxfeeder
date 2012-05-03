{Stream} = require 'stream'

class WriteToArrayStream extends Stream
	constructor: (@items = []) ->
		@writable = true

	write: (data) ->
		@items.push data
		@emit 'data', data
		true

	end: (data) ->
		@items.push data if data?
		@writable = false
		@emit 'end', data

exports.WriteToArrayStream = WriteToArrayStream
