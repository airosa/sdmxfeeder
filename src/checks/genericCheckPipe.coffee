{CheckPipe} = require './checkPipe'
{schemas} = require './genericSchemas'

class GenericCheckPipe extends CheckPipe
	constructor: (log) ->
		super

	loadSchemas: ->
		for schema in schemas
			@jsvenv.createSchema schema

	findSchema: (type) ->
		@jsvenv.findSchema 'urn:sdmxfeeder.infomodel.' + type

exports.GenericCheckPipe = GenericCheckPipe
