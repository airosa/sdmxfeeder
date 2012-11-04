_ = require 'underscore'
header = require './header'
sdmx = require '../../pipe/sdmxPipe'

xmlns_msg = 'http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message'

seriesCur = {}
groupCur = {}
obsCounter = 0

entryActions =
	'DataSet': (attrs) ->
		@emitSDMX sdmx.DATA_SET_HEADER, _.extend( {}, attrs )

	'DataSet/Series': (attrs) ->
		obsCounter = 0
		seriesCur = 
			seriesKey: {}
			attributes: {}
			obs:
				obsDimension: []
				obsValue: []
				attributes: {}

		seriesCur.components = _.extend {}, attrs

	'DataSet/Series/Obs': (attrs) ->
		for key, value of attrs
			switch key
				when 'TIME_PERIOD' then seriesCur.obs.obsDimension[obsCounter] = value
				when 'OBS_VALUE' then seriesCur.obs.obsValue[obsCounter] = +value
				else
					seriesCur.obs.attributes[key] ?= []
					seriesCur.obs.attributes[key][obsCounter] = value
		obsCounter += 1

	'DataSet/Group': (attrs) ->
		groupCur = { type: 'SiblingGroup' }
		groupCur.components = _.extend {}, attrs
		@emitSDMX sdmx.ATTRIBUTE_GROUP, groupCur

entryActions['DataSet/SiblingGroup'] = entryActions['DataSet/Group']

exitActions =
	'DataSet/Series': () ->
		@emitSDMX sdmx.SERIES, seriesCur

guards = {}

exports.fst = _.extend {}, header.fst, entryActions, exitActions, guards
exports.entryActions = _.defaults entryActions, header.entryActions
exports.exitActions = _.defaults exitActions, header.exitActions
exports.guards = _.defaults guards, header.guards
