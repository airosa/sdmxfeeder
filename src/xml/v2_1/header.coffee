_ = require 'underscore'
util = require '../../util/util'

xmlns_msg = 'http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message'

headerCur = {}
partyCur = {}
contactCur = {}
structureCur = {}

entryActions =
	'Header': ->
		headerCur = {}
	'Header/Sender': ->
		partyCur = {}
	'Header/Sender/Contact': ->
		contactCur = {}
	'Header/Structure': (attrs) ->
		structureCur = _.extend {}, attrs
	'Header/Structure/Structure/Ref': (attrs) ->
		structureCur.structure = {}
		structureCur.structure.ref = _.extend {}, attrs

entryActions['Header/Receiver'] = entryActions['Header/Sender']
entryActions['Header/Receiver/Contact'] = entryActions['Header/Sender/Contact']

exitActions =
	'Header': ->
		@emitSDMX 'header', headerCur
	'Header/ID': ->
		headerCur.id = @stringBuffer
	'Header/Test': ->
		headerCur.test = @stringBuffer is 'true'
	'Header/Truncated': ->
		headerCur.truncated = @stringBuffer is 'true'
	'Header/Name': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		headerCur.name ?= {}
		headerCur.name[ attrs['xml:lang'] ] = @stringBuffer
	'Header/Prepared': ->
		headerCur.prepared = util.xmlDateToJavascriptDate @stringBuffer

	'Header/Sender': (attrs) ->
		headerCur.sender ?= {}
		partyCur.id = attrs.id
		headerCur.sender[ attrs.id ] = partyCur
	'Header/Sender/Name': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		partyCur.name ?= {}
		partyCur.name[ attrs['xml:lang'] ] = @stringBuffer
	'Header/Sender/Contact': ->
		partyCur.contact ?= []
		partyCur.contact.push contactCur
	'Header/Sender/Contact/Name': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		contactCur.name ?= {}
		contactCur.name[ attrs['xml:lang'] ] = @stringBuffer
	'Header/Sender/Contact/Department': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		contactCur.department ?= {}
		contactCur.department[ attrs['xml:lang'] ] = @stringBuffer
	'Header/Sender/Contact/Role': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		contactCur.role ?= {}
		contactCur.role[ attrs['xml:lang'] ] = @stringBuffer
	'Header/Sender/Contact/URI': ->
		contactCur.uri = @stringBuffer
	'Header/Sender/Contact/X400': ->
		contactCur.x400 = @stringBuffer
	'Header/Sender/Contact/Telephone': ->
		contactCur.telephone = @stringBuffer
	'Header/Sender/Contact/Email': ->
		contactCur.email = @stringBuffer
	'Header/Sender/Contact/Fax': ->
		contactCur.fax = @stringBuffer

	'Header/Receiver': (attrs) ->
		headerCur.receiver ?= {}
		headerCur.receiver[ attrs.id ] = partyCur

	'Header/Structure': (attrs) ->
		headerCur.structure = structureCur

	'Header/KeyFamilyRef': ->
		headerCur.keyFamilyRef = @stringBuffer
	'Header/KeyFamilyAgency': ->
		headerCur.keyFamilyAgency = @stringBuffer
	'Header/DataSetAgency': ->
		headerCur.dataSetAgency = @stringBuffer
	'Header/DataSetID': ->
		headerCur.dataSetID = @stringBuffer
	'Header/DataSetAction': ->
		headerCur.dataSetAction = @stringBuffer
	'Header/Extracted': ->
		headerCur.extracted = util.xmlDateToJavascriptDate @stringBuffer
	'Header/ReportingBegin': ->
		headerCur.reportingBegin = util.xmlDateToJavascriptDate @stringBuffer
	'Header/ReportingEnd': ->
		headerCur.reportingEnd = util.xmlDateToJavascriptDate @stringBuffer
	'Header/Source': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		headerCur.source ?= {}
		headerCur.source[ attrs['xml:lang'] ] = @stringBuffer

exitActions['Header/Receiver/Name'] = exitActions['Header/Sender/Name']
exitActions['Header/Receiver/Contact'] = exitActions['Header/Sender/Contact']
exitActions['Header/Receiver/Contact/Name'] = exitActions['Header/Sender/Contact/Name']
exitActions['Header/Receiver/Contact/Department'] = exitActions['Header/Sender/Contact/Department']
exitActions['Header/Receiver/Contact/Role'] = exitActions['Header/Sender/Contact/Role']
exitActions['Header/Receiver/Contact/URI'] = exitActions['Header/Sender/Contact/URI']
exitActions['Header/Receiver/Contact/X400'] = exitActions['Header/Sender/Contact/X400']
exitActions['Header/Receiver/Contact/Telephone'] = exitActions['Header/Sender/Contact/Telephone']
exitActions['Header/Receiver/Contact/Email'] = exitActions['Header/Sender/Contact/Email']
exitActions['Header/Receiver/Contact/Fax'] = exitActions['Header/Sender/Contact/Fax']

guards = {}

exports.fst = _.extend {}, entryActions, exitActions, guards
exports.entryActions = entryActions
exports.exitActions = exitActions
exports.guards = guards
