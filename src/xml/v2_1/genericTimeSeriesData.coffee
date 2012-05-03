_ = require 'underscore'
header = require './header'
sdmx = require '../../pipe/sdmxPipe'
util = require '../../util/util'

xmlns_msg = 'http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message'
xmlns_gen = 'http://www.SDMX.org/resources/SDMXML/schemas/v2_0/generic'

dataSetCur = {}
seriesCur = {}
groupCur = {}


convertKeysToDates = (obj, keys) ->
	for key in keys
		obj[key] = util.xmlDateToJavascriptDate obj[key] if obj[key]?


convertKeysToNumbers = (obj, keys) ->
	for key in keys
		obj[key] = Number(obj[key]) if obj[key]?


deleteKeys = (obj, keys) ->
	for key in keys
		delete obj[key]


entryActions =
	'DataSet': (attrs) ->
		dataSetCur = _.extend {}, attrs
		convertKeysToDates dataSetCur, ['reportingBeginDate','reportingEndDate','validFromDate','validToDate']
		convertKeysToNumbers dataSetCur, ['publicationYear']
		deleteKeys dataSetCur, ['xmlns']
		@emitSDMX sdmx.DATA_SET_HEADER, dataSetCur
	'DataSet/Group': (attrs) ->
		groupCur = _.extend {}, attrs
	'DataSet/Group/GroupKey/Value': (attrs) ->
		groupCur.groupKey ?= {}
		groupCur.groupKey[ attrs.id ] = attrs.value
	'DataSet/Group/Attributes/Value': (attrs) ->
		groupCur.attributes ?= {}
		groupCur.attributes[ attrs.id ] = attrs.value
	'DataSet/Group/Series': ->
		seriesCur = seriesKey: {}, obs: { obsDimension: [], obsValue: [], attributes: {} }
	'DataSet/Group/Series/SeriesKey/Value': (attrs) ->
		seriesCur.seriesKey[ attrs.id ] = attrs.value
	'DataSet/Group/Series/Attributes/Value': (attrs) ->
		seriesCur.attributes ?= {}
		seriesCur.attributes[ attrs.id ] = attrs.value
	'DataSet/Group/Series/Obs/ObsValue': (attrs) ->
		seriesCur.obs.obsValue.push Number(attrs.value)
	'DataSet/Group/Series/Obs/Attributes/Value': (attrs) ->
		seriesCur.obs.attributes[ attrs.id ] ?= []
		seriesCur.obs.attributes[ attrs.id ].push attrs.value
	'DataSet/Group/Series/Obs/ObsDimension': (attrs) ->
		seriesCur.obs.obsDimension.push attrs.value

entryActions['DataSet/Series'] = entryActions['DataSet/Group/Series']
entryActions['DataSet/Series/SeriesKey/Value'] = entryActions['DataSet/Group/Series/SeriesKey/Value']
entryActions['DataSet/Series/Attributes/Value'] = entryActions['DataSet/Group/Series/Attributes/Value']
entryActions['DataSet/Series/Obs/ObsValue'] = entryActions['DataSet/Group/Series/Obs/ObsValue']
entryActions['DataSet/Series/Obs/Attributes/Value'] = entryActions['DataSet/Group/Series/Obs/Attributes/Value']
entryActions['DataSet/Series/Obs/ObsDimension'] = entryActions['DataSet/Group/Series/Obs/ObsDimension']

exitActions =
	'DataSet': () ->
		@emitSDMX 'end', ''
	'DataSet/Group': ->
		@emitSDMX sdmx.ATTRIBUTE_GROUP, groupCur
	'DataSet/Group/Series': ->
		@emitSDMX sdmx.SERIES, seriesCur

exitActions['DataSet/Series'] = exitActions['DataSet/Group/Series']

guards = {}

exports.fst = _.extend {}, header.fst, entryActions, exitActions, guards
exports.entryActions = _.defaults entryActions, header.entryActions
exports.exitActions = _.defaults exitActions, header.exitActions
exports.guards = _.defaults guards, header.guards
