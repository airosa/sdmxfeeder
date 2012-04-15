{Stream} = require 'stream'

class StringStream extends Stream
	constructor: (@string = '') ->
		@writable = true
		@readable = true

	write: (string) ->
		@string += string
		@emit 'data', string
		true

	end: (string) ->
		@atEnd = true
		@string += string if string?
		@writable = false
		@emit 'end'

	destroy: ->
		@writable = false


exports.StringStream = StringStream
