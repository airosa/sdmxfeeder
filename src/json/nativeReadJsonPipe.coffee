sdmx = require '../pipe/sdmxPipe'


class NativeReadJsonPipe extends sdmx.ReadSdmxPipe
	constructor: (log) ->
		@string = ''
		super log

	processData: (data) ->
		@string += data

	processEnd: ->
		message = JSON.parse @string
		@emitSDMX sdmx.HEADER, message.header if message.header?
		if message.structures?
			for key, value of message.structures.codelists
				@emitSDMX sdmx.CODE_LIST, value
			for key, value of message.structures.concepts
				@emitSDMX sdmx.CONCEPT_SCHEME, value
			for key, value of message.structures.dataStructures
				@emitSDMX sdmx.DATA_STRUCTURE_DEFINITION, value
		if message.dataset?
			if message.dataset.data?
				for obj in message.dataset.data
					if obj.groupKey?
						@emitSDMX sdmx.ATTRIBUTE_GROUP, obj
					else if obj.seriesKey?
						@emitSDMX sdmx.SERIES, obj
					else
						@emitSDMX sdmx.DATA_SET_ATTRIBUTES, obj
		super


exports.NativeReadJsonPipe = NativeReadJsonPipe
