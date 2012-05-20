sdmx = require '../pipe/sdmxPipe'


class WriteCsvPipe extends sdmx.WriteSdmxPipe
	constructor: (log) ->
		super


	before: (type, data) -> ''

	beforeNext: (type) -> ''

	beforeFirst: (type, data) ->
		if type is sdmx.SERIES
			row = []
			for key, value of data.seriesKey
				row.push key
			for key, value of data.obs.attributes
				row.push key
			row.push 'OBS_DIMENSION'
			row.push 'OBS_VALUE'
			row.join(',') + '\n'
		else
			''


	stringify: (type, data) ->
		if type is sdmx.SERIES
			rows = []
			for obs, i in data.obs.obsValue
				row = []
				for key, value of data.seriesKey
					row.push value
				for key, value of data.obs.attributes
					row.push value[i]
				row.push data.obs.obsDimension[i]
				row.push obs
				rows.push row.join ','
			rows.join('\n') + '\n'
		else
			''


	afterLast: (type) -> ''


exports.WriteCsvPipe = WriteCsvPipe
