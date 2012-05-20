sdmx = require '../pipe/sdmxPipe'


class CompactSeriesPipe extends sdmx.SdmxPipe
	constructor: (@log) ->
		super


	processData: (data) ->
		if data.type is sdmx.SERIES
			series = data.data
			first = last = -1
			for obs, i in series.obs.obsValue
				if obs / obs is 1
					first = last = i if first is -1
					last = i if last < i

			return if first is -1

			if 0 < first or last < series.obs.obsValue.length - 1
				series.obs.obsValue = series.obs.obsValue[first..last]
				series.obs.obsDimension = series.obs.obsDimension[first..last]
				for key, value of series.obs.attributes
					series.obs.attributes[key] = value[first..last]
			super
		else
			super


exports.CompactSeriesPipe = CompactSeriesPipe
