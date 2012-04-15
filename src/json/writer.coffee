{SDMXToStringStream} = require '../sdmxStream'

class JSONWriter extends SDMXToStringStream

	before: (type, data) ->
		switch type
			when 'codelist', 'conceptScheme', 'dataStructure'
				"\t\t\t\"#{data.agencyID}:#{data.id}(#{data.version})\": "
			else ''

	beforeNext: (type) ->
		switch type
			when 'codelist', 'conceptScheme', 'dataStructure' then ',\n'
			when 'group', 'series', 'dataSetAttributes' then ',\n\t\t\t'
			else ''

	beforeFirst: (type) ->
		str = ''
		switch type
			when 'end'
				str += '\n\t\t]' if 0 < @counters.dataSet
				str += '\n\t}' if 0 < (@counters.structure + @counters.dataSet)
				str += '\n}'
			when 'header'
				str += '{\n\t"header": '
			when 'codelist', 'conceptScheme', 'dataStructure'
				if @counters.structure is 0
					str += ',\n\t"structures": {\n'
				else
					str += ',\n'
				switch type
					when 'codelist'
						str += '\t\t"codelists": {\n'
					when 'conceptScheme'
						str += '\t\t"concepts": {\n'
					when 'dataStructure'
						str += '\t\t"dataStructures": {\n'
			when 'dataSet'
				str += ',\n\t"dataSet": {\n\t'
			when 'group', 'series', 'dataSetAttributes'
				str += ',\n\t\t\t' if 0 < (@counters.group + @counters.series + @counters.dataSetAttributes)
		str

	stringify: (type, data) ->
		switch type
			when 'header' then @toJSON data
			when 'codelist', 'conceptScheme', 'dataStructure' then @toJSON data, true, 3
			when 'dataSet' then @toJSON data, false
			when 'series', 'group', 'dataSetAttributes' then @toJSON data, true, 3
			else ''

	afterLast: (type) ->
		switch type
			when 'codelist', 'conceptScheme', 'dataStructure' then '\n\t\t}'
			when 'dataSet' then ',\n\t\t"data": [\n\t\t\t'
			else ''

	toJSON: (data, withBraces = true, level = 1) ->
		return if not data?
		str = JSON.stringify data, null, '\t'
		str = str.slice 2, -2 unless withBraces
		str = str.replace( /\n/g, '\n' + Array(level + 1).join('\t') )
		str


exports.JSONWriter = JSONWriter
