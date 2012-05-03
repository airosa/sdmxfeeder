sdmx = require '../pipe/sdmxPipe'


class NativeWriteJsonPipe extends sdmx.WriteSdmxPipe
	constructor: (log) ->
		@message = []
		super log

	processData: (sdmxData) ->
		data = sdmxData.data
		switch sdmxData.type
			when sdmx.HEADER
				@message.push data
			when sdmx.DATA_STRUCTURE_DEFINITION[1]
				@message[1] ?= {}
				@message[1].dataStructures ?= {}
				@message.structures.dataStructures["#{data.agencyID}:#{data.id}(#{data.version})"] = data
			when sdmx.CODE_LIST
				@message[1] ?= {}
				@message[1].codelists ?= {}
				@message[1].codelists["#{data.agencyID}:#{data.id}(#{data.version})"] = data
			when sdmx.CONCEPT_SCHEME
				@message[1] ?= {}
				@message[1].concepts ?= {}
				@message[1].concepts["#{data.agencyID}:#{data.id}(#{data.version})"] = data
			when sdmx.DATA_SET_HEADER
				@message[1] ?= {}
				@message[2] = []
				@message[2][0] = data
			when sdmx.DATA_SET_ATTRIBUTES or sdmx.SERIES or sdmx.ATTRIBUTE_GROUP
				@message[2][1] ?= []
				@message[2][1].push data

	processEnd: ->
		@emitData JSON.stringify @message
		super


exports.NativeWriteJsonPipe = NativeWriteJsonPipe
