_ = require 'underscore'
header = require './header'
sdmx = require '../../pipe/sdmxPipe'

xmlns_msg = 'http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message'

seriesCur = {}
groupCur = {}

entryActions =
	'DataSet': (attrs) ->
		@emitSDMX sdmx.DATA_SET_HEADER, _.extend( {}, attrs )

	'DataSet/Series': (attrs) ->
		seriesCur = {}
		seriesCur.components = _.extend {}, attrs

	'DataSet/Series/Obs': (attrs) ->
		seriesCur.obs ?= {}
		seriesCur.obs.obsDimension ?= []
		seriesCur.obs.obsValue ?= []
		seriesCur.obs.attributes ?= {}
		for key, value of attrs
			switch key
				when 'TIME_PERIOD' then seriesCur.obs.obsDimension.push value
				when 'OBS_VALUE' then seriesCur.obs.obsValue.push Number(value)
				else
					seriesCur.obs.attributes[key] ?= []
					seriesCur.obs.attributes[key].push value

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
