{SDMXStream} = require '../sdmxStream'

class CompactHandler extends SDMXStream
	constructor: (log, @dsd) ->
		super log

	convertDataset: (dataset) ->
		if not dataset.structureRef?
			dataset.structureRef = 'STR1'

	convertSeries: (series) ->
		if series.components?
			for key, value of series.components
				if @dsd.attributes[key]?
					series.attributes ?= {}
					series.attributes[key] = value
				else
					series.seriesKey ?= {}
					series.seriesKey[key] = value
			delete series.components

	convertGroup: (group) ->
		if group.components?
			for key, value of group.components
				if @dsd.attributes[key]?
					group.attributes ?= {}
					group.attributes[key] = value
				else
					group.groupKey ?= {}
					group.groupKey[key] = value
			delete group.components

	write: (sdmxdata) ->
		switch sdmxdata.type
			when 'dataSet' then @convertDataset sdmxdata.data
			when 'series' then @convertSeries sdmxdata.data
			when 'group' then @convertGroup sdmxdata.data
		super sdmxdata

exports.CompactHandler = CompactHandler
