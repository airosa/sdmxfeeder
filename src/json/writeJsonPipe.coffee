sdmx = require '../pipe/sdmxPipe'


class WriteJsonPipe extends sdmx.WriteSdmxPipe

	before: (type, data) ->
		switch type
			when sdmx.CODE_LIST, sdmx.CONCEPT_SCHEME, sdmx.DATA_STRUCTURE_DEFINITION
				"\t\t\t\"#{data.agencyID}:#{data.id}(#{data.version})\": "
			else ''

	beforeNext: (type) ->
		switch type
			when sdmx.CODE_LIST, sdmx.CONCEPT_SCHEME, sdmx.DATA_STRUCTURE_DEFINITION then ',\n'
			when sdmx.ATTRIBUTE_GROUP, sdmx.SERIES, sdmx.DATA_SET_ATTRIBUTES then ',\n\t\t\t'
			else ''

	beforeFirst: (type) ->
		str = ''
		switch type
			when 'end'
				str += '\n\t\t]' if 0 < @counters.in.datasetheader
				str += '\n\t}' if 0 < @counters.in.structure
				str += '\n\t]' if 0 < @counters.in.datasetheader
				str += '\n]'
			when sdmx.HEADER
				str += '[\n\t'
			when sdmx.CODE_LIST, sdmx.CONCEPT_SCHEME, sdmx.DATA_STRUCTURE_DEFINITION
				if @counters.in.structure is 1
					str += ',\n\t{\n'
				else
					str += ',\n'
				switch type
					when sdmx.CODE_LIST
						str += '\t\t"codelists": {\n'
					when sdmx.CONCEPT_SCHEME
						str += '\t\t"concepts": {\n'
					when sdmx.DATA_STRUCTURE_DEFINITION
						str += '\t\t"dataStructures": {\n'
			when sdmx.DATA_SET_HEADER
				str += ',\n\t{}' if @counters.in.structure is 0
				str += ',\n\t[\n\t\t'
			when sdmx.ATTRIBUTE_GROUP, sdmx.SERIES, sdmx.DATA_SET_ATTRIBUTES
				str += ',\n\t\t\t' if 1 < @counters.in.data
		str

	stringify: (type, data) ->
		switch type
			when sdmx.HEADER then @toJSON data
			when sdmx.CODE_LIST, sdmx.CONCEPT_SCHEME, sdmx.DATA_STRUCTURE_DEFINITION then @toJSON data, true, 3
			when sdmx.DATA_SET_HEADER then @toJSON data, true, 2
			when sdmx.SERIES, sdmx.ATTRIBUTE_GROUP, sdmx.DATA_SET_ATTRIBUTES then @toJSON data, true, 3
			else ''

	afterLast: (type) ->
		switch type
			when sdmx.CODE_LIST, sdmx.CONCEPT_SCHEME, sdmx.DATA_STRUCTURE_DEFINITION then '\n\t\t}'
			when sdmx.DATA_SET_HEADER then ',\n\t\t[\n\t\t\t'
			else ''

	toJSON: (data, withBraces = true, level = 1) ->
		return if not data?
		str = JSON.stringify data, null, '\t'
		str = str.slice 2, -2 unless withBraces
		str = str.replace( /\n/g, '\n' + Array(level + 1).join('\t') )
		str


exports.WriteJsonPipe = WriteJsonPipe
