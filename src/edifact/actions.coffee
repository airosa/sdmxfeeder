{parseFormat} = require './parser'
_ = require 'underscore'
time = require '../util/time'
sdmx = require '../pipe/sdmxPipe'

DEFINITIONS = '73'
DATA = '74'
DATASETLIST = 'DSL'

TIME = '1'
ARRAY_CELL = '3'
FREQUENCY = '13'
DIMENSION = '4'
ATTRIBUTE = 'Z09'

DATASET = '1'
TIMESERIES = '4'
OBSERVATION = '5'
SIBLING_GROUP = '9'

REPRESENTATION = '5'
USAGE_STATUS = '35'
ATTACHMENT_LEVEL = '32'


processDescription = (p, spec) ->
	p.expect('FTX').element().expect('ACM')
	if p.moreElements()
		p.emptyElement().emptyElement().element().read(spec,'description')
		while p.moreComponents()
			p.read(spec,'description')
	p.end()


guards = {}

entryActions =
	'UNA:+.? ': ->
	'UNB': (p, spec) ->
		p.expect('UNB')
			.element().expect('UNOC').expect('3')
			.element().read(spec,'sender')
			.element().read(spec,'receiver')
			.element().read(spec,'date').read(spec,'time')
			.element().read(spec,'iref')
			.emptyElement()
			.element().read(spec, 'type')

		spec.isTest = false
		if p.moreElements()
			p.emptyElement().emptyElement().emptyElement()
				.element().expect('1')
			spec.isTest = true

		p.end()

		@header = {}
		@header.id = spec.iref if spec.iref?
		@header.test = if spec.isTest? then spec.isTest else false
		@header.prepared = time.fromEdifactTimeValue('201',"#{spec.date}#{spec.time}").toDate() if spec.date? and spec.time?
		@helper.iref = spec.iref
	'UNB/UNH': (p, spec) ->
		p.expectTag('UNH')
			.element().read(spec,'mref')
			.element().expect('GESMES').expect('2').expect('1').expect('E6')
			.end()
		#@messageBegin.Header.ID += spec.mref if spec.mref? and @messageBegin.Header.ID?
	'UNB/UNH/BGM': (p, spec) ->
		p.expect('BGM').element().read(spec,'messageFunction').end()
		@helper.messageFunction = spec.messageFunction
		@messageCount += 1
	'UNB/UNH/BGM/NAD': (p, spec) ->
		p.expect('NAD').element()
		switch p.next()
			when 'Z02' then p.expect('Z02').element().read(spec,'maintenanceAgency').end()
			when 'MR' then p.expect('MR').element().read(spec,'receiver').end()
			else p.expect('MS').element().read(spec,'sender').end()
		@header.sender = {} if spec.sender?
		@header.sender[spec.sender] = {} if spec.sender?
		@header.sender[spec.sender].id = spec.sender if spec.sender?
		@header.receiver = {} if spec.receiver?
		@header.receiver[spec.receiver] = {} if spec.receiver?
		@header.receiver[spec.receiver].id = spec.receiver if spec.receiver?
		@helper.maintenanceAgency = spec.maintenanceAgency if spec.maintenanceAgency?
	'UNB/UNH/BGM/NAD/IDE': (p, spec) ->
		p.expect('IDE').element().expect('10').element().read(spec, 'identity').end()
		@header.name = {} if spec.identity?
		@header.name.en = spec.identity if spec.identity?
	'UNB/UNH/BGM/NAD/CTA': (p, spec) ->
		p.expect('CTA')
			.element().read(spec,'function')
			.element().read(spec,'id').read(spec,'name')
			.end()
		sender = Object.keys(@header.sender)[0] if @header.sender?
		@header.sender[sender].contact = [] unless @header.sender[sender].contact?
		contact = {}
		contact.name = { 'en': spec.name } if spec.name?
		contact.department = { 'en': spec.id } if spec.id? and 0 < spec.id.length
		@header.sender[sender].contact.push contact
	'UNB/UNH/BGM/NAD/CTA/COM': (p, spec) ->
		p.expect('COM')
			.element().read(spec,'number').read(spec,'type')
			.end()
		sender = Object.keys(@header.sender)[0] if @header.sender?
		contact = @header.sender[sender].contact[ @header.sender[sender].contact.length - 1 ]
		if spec.type?
			switch spec.type
				when 'EM' then contact.email = spec.number
				when 'TE' then contact.telephone = spec.number
				when 'FX' then contact.fax = spec.number
				when 'XF' then contact.x400 = spec.number
				else throw new Error "Invalid contact type #{spec.type}"
	'UNB/UNH/VLI': (p, spec) ->
		p.expect('VLI')
			.element().read(spec,'id')
			.emptyElement().emptyElement()
			.element().read(spec,'description')
			.end()
		@codelist = {}
		@codelist.id = spec.id if spec.id?
		@codelist.name = {} if spec.description?
		@codelist.name.en = spec.description if spec.description?
		@codelist.agencyID = @helper.maintenanceAgency if @helper.maintenanceAgency?
		@codelist.version = '1.0'
	'UNB/UNH/VLI/CDV': (p, spec) ->
		p.expect('CDV').element().read(spec,'code').end()
		@helper.code = spec.code if spec.code?
	'UNB/UNH/VLI/CDV/FTX': (p, spec) ->
		code = id: @helper.code, name: en: ''
		processDescription p, spec
		@codelist.codes = {} unless @codelist.codes?
		@codelist.codes[@helper.code] = code unless @codelist.codes[@helper.code]?
		@codelist.codes[@helper.code].name.en += spec.description
	'UNB/UNH/STC': (p, spec) ->
		p.expect('STC').element().read(spec,'id').end()
		if not @conceptScheme.agencyID?
			@conceptScheme = {}
			@conceptScheme.id = 'CONCEPTS'
			@conceptScheme.version = '1.0'
			@conceptScheme.name = {}
			@conceptScheme.name.en = 'Statistical concepts'
			@conceptScheme.agencyID = @helper.maintenanceAgency if @helper.maintenanceAgency?
			@conceptScheme.concepts = {}
		@helper.conceptID = spec.id if spec.id?
	'UNB/UNH/STC/FTX': (p, spec) ->
		concept = id: @helper.conceptID, name: en: ''
		processDescription p, spec
		@conceptScheme.concepts[@helper.conceptID] = concept unless @conceptScheme.concepts[@helper.conceptID]?
		@conceptScheme.concepts[@helper.conceptID].name.en += spec.description
	'UNB/UNH/ASI': (p, spec) ->
		if not _.isEmpty @conceptScheme.concepts
			@emitSDMX sdmx.CONCEPT_SCHEME, @conceptScheme
			@conceptScheme.concepts = {}
		p.expect('ASI').element().read(spec,'id').end()
		@dsd = {}
		delete @helper.primaryMeasure
		@dsd.id = spec.id if spec.id?
		@dsd.agencyID = @helper.maintenanceAgency if @helper.maintenanceAgency?
		@dsd.version = '1.0'
		@dsd.dimensionGroupDescriptor = {}
		@dsd.dimensionGroupDescriptor['TIMESERIES'] = { id: 'TIMESERIES', dimensions: [] }
		@dsd.dimensionGroupDescriptor['SIBLING_GROUP'] = { id: 'SIBLING_GROUP', dimensions: [] }
	'UNB/UNH/ASI/FTX': (p, spec) ->
		processDescription p, spec
		@dsd.name = {}
		@dsd.name.en = spec.description if spec.description?
	'UNB/UNH/ASI/SCD': (p, spec) ->
		p.expect('SCD').element().read(spec,'type').element().read(spec,'id')
		if p.moreElements()
			p.emptyElement().emptyElement().emptyElement()
				.element().read(spec,'empty').read(spec,'position').end()
		@component = {}
		@helper.componentType = spec.type
		switch spec.type
			when FREQUENCY
				@component.order = +spec.position
				@component.type = 'dimension'
				@dsd.dimensionGroupDescriptor['TIMESERIES'].dimensions.push spec.id
			when DIMENSION
				@component.order = +spec.position
				@component.type = 'dimension'
				@dsd.dimensionGroupDescriptor['TIMESERIES'].dimensions.push spec.id
				@dsd.dimensionGroupDescriptor['SIBLING_GROUP'].dimensions.push spec.id
			when TIME
				@component.order = +spec.position
				@component.type = 'timeDimension'
		@helper.primaryMeasure = spec.id if not @helper.primaryMeasure? and spec.type is ARRAY_CELL
		@component.id = spec.id
		@component.conceptIdentity = {}
		@component.conceptIdentity.ref = {}
		@component.conceptIdentity.ref.id = @component.id
		@component.conceptIdentity.ref.agencyID = @helper.maintenanceAgency
		@component.conceptIdentity.ref.maintainableParentID = 'CONCEPTS'
		@component.conceptIdentity.ref.maintainableParentVersion = '1.0'
	'UNB/UNH/ASI/SCD/ATT': (p, spec) ->
		p.expect('ATT').element().expect('3').element()
		switch p.next()
			when REPRESENTATION
				p.read(spec,'type').element().expect('').expect('').expect('').read(spec,'format')
				@component.localRepresentation = {}
				@component.localRepresentation.textFormat = parseFormat(spec.format)
			when USAGE_STATUS
				p.read(spec,'type').element().read(spec,'status').expect('USS')
				switch spec.status
					when '1' then @component.assignmentStatus = 'Conditional'
					when '2' then @component.assignmentStatus = 'Mandatory'
					else throw new Error "Invalid status #{spec.status}"
			when ATTACHMENT_LEVEL
				p.read(spec,'type').element().read(spec,'attachmentLevel').expect('ALV')
				@component.attributeRelationship = {}
				switch spec.attachmentLevel
					when DATASET then
					when TIMESERIES
						@component.attributeRelationship.group = 'TIMESERIES'
					when OBSERVATION
						@component.attributeRelationship.primaryMeasure = @helper.primaryMeasure
					when SIBLING_GROUP
						@component.attributeRelationship.group = 'SIBLING_GROUP'
					else throw new Error "Invalid attachment level #{spec.attachmentLevel}"
			else throw new Error "Invalid type #{p.next()}"
		p.end()
	'UNB/UNH/ASI/SCD/IDE': (p, spec) ->
		p.expect('IDE').element().expect('1').element().read(spec,'codelistID').end()
		@component.localRepresentation.enumeration = {}
		@component.localRepresentation.enumeration.ref = {}
		@component.localRepresentation.enumeration.ref.id = spec.codelistID
		@component.localRepresentation.enumeration.ref.agencyID = @helper.maintenanceAgency
		@component.localRepresentation.enumeration.ref.version = '1.0'
	'UNB/UNH/DSI': (p, spec) ->
		p.expect('DSI').element().read(spec,'dsi').end()
		@dataSetBegin.setID = spec.dsi
		@header.dataSetID = @dataSetBegin.setID
	'UNB/UNH/DSI/STS': (p, spec) ->
		p.expect('STS').element().expect('3').element().read(spec,'action').end()
		@dataSetBegin.action = switch spec.action
			when '7' then 'Append'
			when '6' then 'Delete'
			else throw new Error "Invalid message action #{spec.action}"
		@header.dataSetAction = @dataSetBegin.action
	'UNB/UNH/DSI/DTM': (p, spec) ->
		p.expect('DTM').element().read(spec,'type').read(spec,'datetime').read(spec,'format').end()
		switch spec.type
			when '242'
				@header.prepared = time.fromEdifactTimeValue(spec.format,spec.datetime).toDate()
			when 'Z02'
				@dataSetBegin.reportingBeginDate = time.fromEdifactTimeValue(spec.format,spec.datetime).toString()
				@dataSetBegin.reportingEndDate = time.fromEdifactTimeValue(spec.format,spec.datetime,false).toString()
				@header.reportingBegin = @dataSetBegin.reportingBeginDate
				@header.reportingEnd = @dataSetBegin.reportingEndDate
			else throw new Error "Invalid DTM date-time-type #{spec.type}"
	'UNB/UNH/DSI/IDE': (p, spec) ->
		p.expect('IDE').element().expect('5').element().read(spec,'dsd').end()
		@header.structure = {}
		@header.structure[spec.dsd] =
			structureID: spec.dsd
			dimensionAtObservation: 'TIME_PERIOD'
			structureRef:
				ref:
					id: spec.dsd
					agencyID: @helper.maintenanceAgency
					version: '1.0'
		@dataSetBegin.structureRef = spec.dsd
	'UNB/UNH/DSI/IDE/GIS': (p, spec) ->
		p.expect('GIS').element()
		switch p.next()
			when 'AR3' then p.expect('AR3')
			when '1' then p.expect('1').expect('').expect('').expect('-')
			else p.error ''
		p.end()
	'UNB/UNH/DSI/ARR': (p) ->
		@series = {}
		p.expect('ARR').emptyElement().element()
		@series.seriesKey = {}

		order = 1
		while p.moreComponents() and not /^[0-9]/.test p.next()
			@series.seriesKey[order] = p.get()
			order += 1

		if p.moreComponents()
			period = p.get()
		if p.moreComponents()
			timeFormat = p.get()
			timePeriod = time.fromEdifactTimeValue timeFormat, period

		index = 0
		if p.moreComponents()
			@series.obs = {}
			@series.obs.obsDimension = []
			@series.obs.obsDimension[index] = timePeriod.toString()
		if p.moreComponents()
			@series.obs.obsValue = []
			@series.obs.obsValue[index] = +p.get()
		if p.moreComponents()
			@series.obs.attributes = {}
			@series.obs.attributes['OBS_STATUS'] = []
			@series.obs.attributes['OBS_STATUS'][index] = p.get()
		if p.moreComponents()
			@series.obs.attributes['OBS_CONF'] = []
			@series.obs.attributes['OBS_CONF'][index] = p.get()
		if p.moreComponents()
			@series.obs.attributes['OBS_PRE_BREAK'] = []
			@series.obs.attributes['OBS_PRE_BREAK'][index] = p.get()

		while p.moreElements()
			index += 1
			p.element()
			@series.obs.obsDimension.push timePeriod.next().toString()
			if p.moreComponents()
				@series.obs.obsValue ?= []
				@series.obs.obsValue[index] =  +p.get()
			if p.moreComponents()
				@series.obs.attributes ?= {}
				@series.obs.attributes['OBS_STATUS'] ?= []
				@series.obs.attributes['OBS_STATUS'][index] =  p.get()
			if p.moreComponents()
				@series.obs.attributes['OBS_CONF'] ?= []
				@series.obs.attributes['OBS_CONF'][index] =  p.get()
			if p.moreComponents()
				@series.obs.attributes['OBS_PRE_BREAK'] ?= []
				@series.obs.attributes['OBS_PRE_BREAK'][index] =  p.get()

		p.end()
	'UNB/UNH/DSI/FNS': (p, spec) ->
		p.expect('FNS').element().read(spec,'identity').expect('10').end()
	'UNB/UNH/DSI/FNS/REL': (p, spec) ->
		p.expect('REL').element().expect('Z01').element().read(spec,'scope').end()
		@helper.attributeScope = spec.scope
	'UNB/UNH/DSI/FNS/REL/ARR': (p, spec) ->
		@attributes = {}
		switch @helper.attributeScope
			when OBSERVATION
				@attributes.obs = {}
				@attributes.obs.attributes = {}
			when TIMESERIES, SIBLING_GROUP, DATASET
				@attributes.attributes = {}

		p.expect('ARR').element().read(spec,'lastElement')

		if p.moreElements()
			p.element()
			@helper.attributeScope = SIBLING_GROUP if p.next() is ''
			key = {}
			order = 1
			while p.moreComponents()
				dim = p.get()
				key[order] = dim unless dim is ''
				order += 1
			if @helper.attributeScope is OBSERVATION
				@attributes.obs.obsDimension = []
				@attributes.obs.obsDimension.push time.fromEdifactTimeValue(key[order-1], key[order-2]).toString()
				delete key[order-1]
				delete key[order-2]
			if @helper.attributeScope is SIBLING_GROUP
				@attributes.groupKey = key
			else
				@attributes.seriesKey = key

		p.end()
	'UNB/UNH/DSI/FNS/REL/ARR/IDE': (p, spec) ->
		p.expect('IDE').element().read(spec,'objectType').element().read(spec,'id').end()
		@helper.attributeID = spec.id
		if @helper.attributeScope is OBSERVATION
			@attributes.obs.attributes[@helper.attributeID] = []
	'UNB/UNH/DSI/FNS/REL/ARR/IDE/CDV': (p, spec) ->
		p.expect('CDV').element().read(spec,'value').end()
		if @helper.attributeScope is OBSERVATION
			@attributes.obs.attributes[@helper.attributeID] = spec.value
		else
			@attributes.attributes[@helper.attributeID] = spec.value
	'UNB/UNH/DSI/FNS/REL/ARR/IDE/FTX': (p, spec) ->
		p.expect('FTX').element().expect('ACM').emptyElement().emptyElement().element()
		spec.text = p.get()
		spec.text += p.get() if p.moreComponents()
		spec.text += p.get() if p.moreComponents()
		spec.text += p.get() if p.moreComponents()
		spec.text += p.get() if p.moreComponents()
		p.end()
		if @helper.attributeScope is OBSERVATION
			@attributes.obs.attributes[@helper.attributeID].push spec.text
		else
			@attributes.attributes[@helper.attributeID] = spec.text
	'UNB/UNT': (p, spec) ->
		if not _.isEmpty @conceptScheme.concepts
			@emitSDMX sdmx.CONCEPT_SCHEME, @conceptScheme
			@conceptScheme.concepts = {}
		p.expect('UNT')
			.element().read(spec,'value')
			.element().read(spec,'value')
			.end()
	'UNZ': (p, spec) ->
		p.expect('UNZ')
			.element().expect(@messageCount.toString())
			.element().read(spec,'value')
			.end()

exitActions =
	'UNB/UNH/BGM': ->
		@emitSDMX sdmx.HEADER, @header if @helper.messageFunction is DEFINITIONS
	'UNB/UNH/DSI/IDE': ->
		if @helper.messageFunction is DATA
			@emitSDMX sdmx.HEADER, @header
			@emitSDMX sdmx.DATA_SET_HEADER, @dataSetBegin
	'UNB/UNH/VLI': ->
		@emitSDMX sdmx.CODE_LIST, @codelist
	'UNB/UNH/ASI': ->
		@emitSDMX sdmx.DATA_STRUCTURE_DEFINITION, @dsd
	'UNB/UNH/ASI/SCD': ->
		switch @helper.componentType
			when TIME
				@dsd.dimensionDescriptor = {} unless @dsd.dimensionDescriptor?
				@dsd.dimensionDescriptor[@component.id] = @component
			when ARRAY_CELL
				if @component.id is @helper.primaryMeasure
					@dsd.measureDescriptor = {}
					@dsd.measureDescriptor.primaryMeasure = @component
				else
					@dsd.attributeDescriptor = {} unless @dsd.attributeDescriptor?
					@dsd.attributeDescriptor[@component.id] = @component
			when FREQUENCY
				@dsd.dimensionDescriptor = {} unless @dsd.dimensionDescriptor?
				@dsd.dimensionDescriptor[@component.id] = @component
			when DIMENSION
				@dsd.dimensionDescriptor = {} unless @dsd.dimensionDescriptor?
				@dsd.dimensionDescriptor[@component.id] = @component
			when ATTRIBUTE
				@dsd.attributeDescriptor = {} unless @dsd.attributeDescriptor?
				@dsd.attributeDescriptor[@component.id] = @component
	'UNB/UNH/DSI/ARR': ->
		@emitSDMX sdmx.SERIES, @series
	'UNB/UNH/DSI/FNS/REL/ARR': ->
		switch @helper.attributeScope
			when OBSERVATION, TIMESERIES then @emitSDMX sdmx.SERIES, @attributes
			when SIBLING_GROUP
				@attributes.type = 'SiblingGroup'
				@emitSDMX sdmx.ATTRIBUTE_GROUP, @attributes
			when DATASET then @emitSDMX sdmx.DATA_SET_ATTRIBUTES, @attributes

exports.fst = _.extend {}, guards, entryActions, exitActions
exports.guards = guards
exports.entryActions = entryActions
exports.exitActions = exitActions
