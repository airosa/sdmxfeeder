_ = require 'underscore'
header = require './header'
sdmx = require '../../pipe/sdmxPipe'

xmlns_msg = 'http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message'
xmlns_gen = 'http://www.SDMX.org/resources/SDMXML/schemas/v2_0/generic'

dataSetCur = {}
seriesCur = {}
groupCur = {}

entryActions =
	'DataSet': (attrs) ->
		dataSetCur = _.extend {}, attrs
	'DataSet/Group': () ->
		groupCur = type: 'SiblingGroup', groupKey: {}, attributes: {}
	'DataSet/Group/GroupKey/Value': (attrs) ->
		groupCur.groupKey[ attrs.concept ] = attrs.value
	'DataSet/Group/Attributes/Value': (attrs) ->
		groupCur.attributes[ attrs.concept ] = attrs.value
	'DataSet/Group/Series': ->
		seriesCur = seriesKey: {}, attributes: {}, obs: { obsDimension: [], obsValue: [] }
	'DataSet/Group/Series/SeriesKey/Value': (attrs) ->
		seriesCur.seriesKey[ attrs.concept ] = attrs.value
	'DataSet/Group/Series/Attributes/Value': (attrs) ->
		seriesCur.attributes[ attrs.concept ] = attrs.value
	'DataSet/Group/Series/Obs/ObsValue': (attrs) ->
		seriesCur.obs.obsValue.push Number(attrs.value)
	'DataSet/Group/Series/Obs/Attributes/Value': (attrs) ->
		seriesCur.obs.attributes ?= {}
		seriesCur.obs.attributes[ attrs.concept ] ?= []
		seriesCur.obs.attributes[ attrs.concept ].push attrs.value

entryActions['DataSet/Series'] = entryActions['DataSet/Group/Series']
entryActions['DataSet/Series/SeriesKey/Value'] = entryActions['DataSet/Group/Series/SeriesKey/Value']
entryActions['DataSet/Series/Attributes/Value'] = entryActions['DataSet/Group/Series/Attributes/Value']
entryActions['DataSet/Series/Obs/ObsValue'] = entryActions['DataSet/Group/Series/Obs/ObsValue']
entryActions['DataSet/Series/Obs/Attributes/Value'] = entryActions['DataSet/Group/Series/Obs/Attributes/Value']

exitActions =
	'DataSet/KeyFamilyRef': () ->
		dataSetCur.structureRef = @stringBuffer
		@emitSDMX sdmx.DATA_SET_HEADER, dataSetCur
	'DataSet': () ->
		#@emitSDMX 'dataSetEnd', ''
	'DataSet/Group': ->
		@emitSDMX sdmx.ATTRIBUTE_GROUP, groupCur
	'DataSet/Group/Series': ->
		@emitSDMX sdmx.SERIES, seriesCur
	'DataSet/Group/Series/Obs/Time': ->
		seriesCur.obs.obsDimension.push @stringBuffer

exitActions['DataSet/Series'] = exitActions['DataSet/Group/Series']
exitActions['DataSet/Series/Obs/Time'] = exitActions['DataSet/Group/Series/Obs/Time']

guards = {}

exports.fst = _.extend {}, header.fst, entryActions, exitActions, guards
exports.entryActions = _.defaults entryActions, header.entryActions
exports.exitActions = _.defaults exitActions, header.exitActions
exports.guards = _.defaults guards, header.guards
