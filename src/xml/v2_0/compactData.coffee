_ = require 'underscore'
header = require './header'

xmlns_msg = 'http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message'

seriesCur = {}
groupCur = {}

entryActions =
	'DataSet': (attrs) ->
		@emitSDMX 'dataSet', _.extend( {}, attrs )

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
		@emitSDMX 'group', groupCur

entryActions['DataSet/SiblingGroup'] = entryActions['DataSet/Group']

exitActions =
	'DataSet/Series': () ->
		@emitSDMX 'series', seriesCur

guards = {}

exports.fst = _.extend {}, header.fst, entryActions, exitActions, guards
exports.entryActions = _.defaults entryActions, header.entryActions
exports.exitActions = _.defaults exitActions, header.exitActions
exports.guards = _.defaults guards, header.guards
