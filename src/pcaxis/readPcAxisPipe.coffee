sdmx = require '../pipe/sdmxPipe'
{PcAxisParser} = require './pcAxisParser'
cdc = require '../sdmx/crossDomainConcepts'
pcxc = require './pcAxisConcepts'
cdcl = require '../sdmx/crossDomainCodeLists'

MANDATORY = 0
LANGUAGE = 1
CONCEPT = 2


PCAXIS_KEYWORDS =
	AGGREGALLOWED:			[	false,	false	]
	AUTOPEN:				[	false,	false	]
	'AXIS-VERSION':			[	false,	false	]
	BASEPERIOD:				[	false,	false	]
	CELLNOTE:				[	false,	true	]
	CELLNOTEX:				[	false,	true	]
	CFPRICES:				[	false,	true	]
	CHARSET:				[	false,	false	]
	CODEPAGE:				[	false,	false	]
	CODES:					[	false,	true	]
	CONFIDENTIAL:			[	false,	false	]
	CONTACT:				[	false,	true	]
	CONTENTS:				[	true,	true,  'CONTENTS' ]
	CONTVARIABLE:			[	false,	true	]
	COPYRIGHT:				[	false,	false	]
	'CREATION-DATE':		[	false,	false	]
	DATA:					[	true,	false	]
	DATABASE:				[	false,	true	]
	DATANOTECELL:			[	false,	true	]
	DATANOTESUM:			[	false,	true	]
	DATASYMBOL1:			[	false,	true	]
	DATASYMBOL2:			[	false,	true	]
	DATASYMBOL3:			[	false,	true	]
	DATASYMBOL4:			[	false,	true	]
	DATASYMBOL5:			[	false,	true	]
	DATASYMBOL6:			[	false,	true	]
	DATASYMBOLNIL:			[	false,	true	]
	DATASYMBOLSUM:			[	false,	true	]
	DAYADJ:					[	false,	true	]
	DECIMALS:				[	true,	false	]
	'DEFAULT-GRAPH':		[	false,	false	]
	DESCRIPTION:			[	false,	true	]
	DESCRIPTIONDEFAULT:		[	false,	false	]
	'DIRECTORY-PATH':		[	false,	false	]
	DOMAIN:					[	false,	true	]
	DOUBLECOLUMN:			[	false,	true	]
	ELIMINATION:			[	false,	true	]
	HEADING:				[	true,	true	]
	HIERARCHIES:			[	false,	true	]
	HIERARCHYLEVELS:		[	false,	true	]
	HIERARCHYLEVELSOPEN:	[	false,	true	]
	HIERARCHYNAMES:			[	false,	true	]
	INFO:					[	false,	true	]
	INFOFILE:				[	false,	true	]
	KEYS:					[	false,	true	]
	LANGUAGE:				[	false,	false	]
	LANGUAGES:				[	false,	false	]
	'LAST-UPDATED':			[	false,	true	]
	LINK:					[	false,	true	]
	MAP:					[	false,	true	]
	MATRIX:					[	true,	false	]
	'NEXT-UPDATE':			[	false,	false	]
	NOTE:					[	false,	true   ,'NOTE' ]
	NOTEX:					[	false,	true	]
	PARTITIONED:			[	false,	true	]
	PRECISION:				[	false,	true	]
	PRESTEXT:				[	false,	true	]
	'PX-SERVER':			[	false,	false	]
	REFPERIOD:				[	false,	true	]
	ROUNDING:				[	false,	false	]
	SEASADJ:				[	false,	true	]
	SHOWDECIMALS:			[	false,	false	]
	SOURCE:					[	false,	true	]
	STOCKFA:				[	false,	true	]
	STUB:					[	true,	true	]
	'SUBJECT-AREA':			[	true,	true	]
	'SUBJECT-CODE':			[	true,	false	]
	SURVEY:					[	false,	true	]
	SYNONYMS:				[	false,	false	]
	TABLEID:				[	false,	false	]
	TIMEVAL:				[	false,	true	]
	TITLE:					[	true,	true	]
	UNITS:					[	true,	true	, 'UNITS' ]
	'UPDATE-FREQUENCY':		[	false,	false	]
	VALUENOTE:				[	false,	true	]
	VALUENOTEX:				[	false,	true	]
	VALUES:					[	true,	true	]
	'VARIABLE-TYPE':		[	false,	true	]


parsePcAxisDate = (date) ->
	return unless date?
	yyyy = date[0..3]
	mmm = date[4..5] - 1
	dd = date[6..7]
	hh = date[9..10]
	mm = date[12..13]
	new Date yyyy, mmm, dd, hh, mm


parseContact = (contact) ->
	contact.replace(/#/g, ' ').match(/\S+@\S+/)[0]


class ReadPcAxisPipe extends sdmx.ReadSdmxPipe
	constructor: (log) ->
		@parser = new PcAxisParser log
		@parser.onKeyword = @onKeyword
		@parser.onData = @onData
		@parser.onDataValue = @onDataValue
		@keywords = {}
		@variables = {}
		@dimensions = []
		@obsDimension = {}
		@dataSetId = ''
		@agencyId = ''
		@lang = 'en'
		@dataCount = 0
		super

#-------------------------------------------------------------------------------

	processData: (data) ->
		@parser.parse data


	processEnd: ->
		@parser.end()

#-------------------------------------------------------------------------------

	onKeyword: (keyword) =>
		@log.debug "#{@constructor.name} onKeyword"
		throw new Error "Invalid keyword #{keyword.name}" unless PCAXIS_KEYWORDS[keyword.name]?
		@lang = keyword.value if keyword.name is 'LANGUAGE'
		keyword.language ?= @lang if PCAXIS_KEYWORDS[keyword.name][LANGUAGE]
		@keywords[keyword.name] ?= []
		@keywords[keyword.name].push keyword

		if keyword.variable?
			@variables[keyword.variable] ?= {}
			@variables[keyword.variable][keyword.name] ?= []
			@variables[keyword.variable][keyword.name].push keyword

		@dataSetId = keyword.value.toUpperCase() if keyword.name is 'MATRIX'
		@agencyId = keyword.value.toUpperCase() if keyword.name is 'SOURCE'


	onData: =>
		@log.debug "#{@constructor.name} onData"
		@checkKeywords()
		@establishDimensions()
		@emitHeader()
		@emitCodelists()
		@emitConceptScheme()
		@emitDataStructureDefinition()
		@emitDatasetHeader()
		@emitAttributes()
		@parser.dataArrayMaxLength = @dimensions[ @dimensions.length - 1 ].codelist.codes.length


	onDataValue: (data) =>
		obsDimensionCodes = @dimensions[ @dimensions.length - 1 ].codelist.codes 
		obsDimension = []
		obsValue = []
		obsStatus = []

		for value, i in data
			continue if value is '.'
			obsDimension.push obsDimensionCodes[i]
			obsValue.push if value is '..' or value is '...' then NaN else value
			obsStatus.push if value is '..' or value is '...' then 'M' else 'A'

		key = {}
		for dim, i in @dimensions when i < @dimensions.length - 1
			index = Math.floor(@dataCount / dim.step) % dim.codelist.codes.length
			key[dim.concept.id] = dim.codelist.codes[index]

		series =
			seriesKey: key
			attributes: {}
			obs:
				obsDimension: obsDimension
				obsValue: obsValue
				attributes:
					OBS_STATUS: obsStatus

		@dataCount += 1
		@emitSDMX sdmx.SERIES, series

#-------------------------------------------------------------------------------

	findKeywordValue: (keywords...) ->
		for key in keywords
			return @keywords[key][0].value if @keywords[key]?
		undefined


	checkKeywords: ->
		@log.debug "#{@constructor.name} checkKeywords"
		for key, value in PCAXIS_KEYWORDS
			if value[MANDATORY] and not @keywords[key]?
				throw new Error "Mandatory keyword #{key} missing."


	establishDimensions: ->
		toArray = (value) -> if Array.isArray value then value else [ value ]
		toId = (name) -> name.toUpperCase().replace(/\s/g, '_')

		vars = []

		stub = toArray @keywords['STUB'][0].value
		vars.push value for value in stub
		heading = toArray @keywords['HEADING'][0].value
		vars.push value for value in heading

		timeVarFound = false
		for varName, i in vars
			varKeywords = @variables[varName]
			dim =
				variable: varName
				concept:
					id: toId varName
					agencyID: @agencyId
					parentID: 'CONCEPT_SCHEME'
				codelist:
					id: 'CL_' + toId varName
					agencyID: @agencyId
					codes: toArray varKeywords['CODES'][0].value
					codeNames: []

			for names in varKeywords['VALUES']
				dim.codelist.codeNames.push names

			if varKeywords['TIMEVAL']?
				timeVarFound = true
				dim.concept.id = 'TIME_PERIOD'
				dim.concept.agencyID = 'SDMX'
				dim.concept.parentID = 'CROSS_DOMAIN_CONCEPTS'
				timeVal = varKeywords['TIMEVAL'][0].value
				if Array.isArray timeVal
					@frequency = timeVal[0].args[0].slice 0,1
				else
					@frequency = timeVal.args[0].slice 0,1
				@dimensions.unshift
					concept:
						id: 'FREQ'
						agencyID: 'SDMX'
						parentID: 'CROSS_DOMAIN_CONCEPTS'
					codelist:
						id: 'CL_FREQ'
						agencyID: 'SDMX'
						codes: [ @frequency ]
						codeNames: []

			@dimensions.push dim

		@searchForTimeVariable() unless timeVarFound

		i = @dimensions.length - 1
		@dimensions[ i ].step = 1
		@dimensions[ --i ].step = previousStep = 1
		previousCodesLength = @dimensions[ i ].codelist.codes.length
		while dim = @dimensions[--i]
			 dim.step =  previousCodesLength * previousStep
			 previousCodesLength = dim.codelist.codes.length
			 previousStep = dim.step


	searchForTimeVariable: ->
		for dim in @dimensions
			if dim.concept.id is 'TIME'
				dim.concept.id = 'TIME_PERIOD'
				dim.concept.agencyID = 'SDMX'
				dim.concept.parentID = 'CROSS_DOMAIN_CONCEPTS'
				switch dim.codelist.codes[0].length
					when 4 then @frequency = cdcl.CL_FREQ.codes.A.id
				@dimensions.unshift
					concept:
						id: 'FREQ'
						agencyID: 'SDMX'
						parentID: 'CROSS_DOMAIN_CONCEPTS'
					codelist:
						id: 'CL_FREQ'
						agencyID: 'SDMX'
						codes: [ @frequency ]
				break


	emitHeader: ->
		@log.debug "#{@constructor.name} emitHeader"

		contact = {}
		contact.name = {en: 'Contact'}
		contact.email = parseContact @keywords['CONTACT'][0].value

		sender = {}
		sender.id = @agencyId
		sender.name = {}
		for keyword in @keywords['SOURCE']
			sender.name[keyword.language] = keyword.value
		sender.contact = []
		sender.contact.push contact

		structure = {}
		structure.structureID = @dataSetId
		structure.structureRef = {}
		structure.structureRef.ref = {}
		structure.structureRef.ref.id = structure.structureID
		structure.structureRef.ref.agencyID = sender.id
		structure.structureRef.ref.version = '1.0'
		structure.dimensionAtObservation = @dimensions[ @dimensions.length - 1 ].concept.id

		header = {}
		header.id = @dataSetId
		header.test = false
		header.prepared = parsePcAxisDate @findKeywordValue('CREATION-DATE','LAST-UPDATED')
		header.sender = {}
		header.sender[sender.id] = sender
		header.extracted = parsePcAxisDate @keywords['LAST-UPDATED'][0].value
		header.source = {}
		for source in @keywords['SOURCE']
			header.source[source.language] = source.value
		header.structure = {}
		header.structure[structure.structureID] = structure
		header.name = {}
		for keyword in @keywords['TITLE']
			header.name[keyword.language] = keyword.value

		@emitSDMX sdmx.HEADER, header


	emitCodelists: ->
		for dim in @dimensions when dim.codelist.agencyID isnt 'SDMX'
			codelist =
				id: dim.codelist.id
				agencyID: dim.codelist.agencyID
				version: '1.0'
				codes: {}
				name: {}

			for codeValue, i in dim.codelist.codes
				code = { id: codeValue, name: {} }
				for names in dim.codelist.codeNames
					code.name[names.language] = names.value[i]
				codelist.codes[code.id] = code

			codelist.name[@lang] = dim.variable

			@emitSDMX sdmx.CODE_LIST, codelist

		@emitSDMX sdmx.CODE_LIST, cdcl.CL_FREQ
		@emitSDMX sdmx.CODE_LIST, cdcl.CL_OBS_STATUS


	emitConceptScheme: ->
		conceptScheme =
			id: 'CONCEPT_SCHEME'
			agencyID: @agencyId
			version: '1.0'
			concepts: {}
			name: {}

		for domain in @keywords['CONTENTS']
			conceptScheme.name[domain.language] = domain.value

		for dim in @dimensions when dim.concept.agencyID isnt 'SDMX'
			concept =
				id: dim.concept.id
				name: {}
			concept.name[@lang] = dim.variable
			conceptScheme.concepts[concept.id] = concept

		@emitSDMX sdmx.CONCEPT_SCHEME, conceptScheme
		@emitSDMX sdmx.CONCEPT_SCHEME, cdc.CROSS_DOMAIN_CONCEPTS
		@emitSDMX sdmx.CONCEPT_SCHEME, pcxc.PC_AXIS_CONCEPTS


	emitDataStructureDefinition:->
		dsd =
			id: @dataSetId
			agencyID: @agencyId
			version: '1.0'
			name: {}
			dimensionDescriptor: {}
			measureDescriptor: {}
			attributeDescriptor: {}

		for domain in @keywords['CONTENTS']
			dsd.name[domain.language] = domain.value

		i = 1
		for dim in @dimensions
			dimension =
				id: dim.concept.id
				order: i
				conceptIdentity:
						ref:
							id: dim.concept.id
							agencyID: dim.concept.agencyID
							maintainableParentID: dim.concept.parentID
							maintainableParentVersion: '1.0'

			if dim.concept.id is 'TIME_PERIOD'
				dimension.type = 'timeDimension'
				dimension.localRepresentation =
					textFormat:
						textType: 'ObservationalTimePeriod'
			else
				dimension.type = 'dimension'
				dimension.localRepresentation =
					enumeration:
						ref:
							id: dim.codelist.id
							agencyID: dim.codelist.agencyID
							version: '1.0'

			dsd.dimensionDescriptor[dimension.id] = dimension
			i += 1

		dsd.measureDescriptor.primaryMeasure =
			id: 'OBS_VALUE'
			conceptIdentity:
				ref:
					id: 'OBS_VALUE'
					agencyID: 'SDMX'
					maintainableParentID: 'CROSS_DOMAIN_CONCEPTS'
					maintainableParentVersion: '1.0'

		dsd.attributeDescriptor['OBS_STATUS'] =
			id: 'OBS_STATUS'
			assignmentStatus: 'Mandatory'
			conceptIdentity:
				ref:
					id: 'OBS_STATUS'
					agencyID: 'SDMX'
					maintainableParentID: 'CROSS_DOMAIN_CONCEPTS'
					maintainableParentVersion: '1.0'
			attributeRelationship:
				primaryMeasure: 'OBS_VALUE'
			localRepresentation:
				enumeration:
					ref:
						id: 'CL_OBS_STATUS'
						agencyID: 'SDMX'
						version: '1.0'

		for key, value of @keywords
			conceptId = PCAXIS_KEYWORDS[key][CONCEPT]
			continue unless conceptId?

			dsd.attributeDescriptor[key] =
				id: conceptId
				assignmentStatus: 'Conditional'
				conceptIdentity:
					ref:
						id: conceptId
						agencyID: pcxc.PC_AXIS_CONCEPTS.agencyID
						maintainableParentID: pcxc.PC_AXIS_CONCEPTS.id
						maintainableParentVersion: pcxc.PC_AXIS_CONCEPTS.version
				attributeRelationship: null

		@emitSDMX sdmx.DATA_STRUCTURE_DEFINITION, dsd


	emitDatasetHeader: ->
		header =
			structureRef: @dataSetId

		@emitSDMX sdmx.DATA_SET_HEADER, header


	emitAttributes: ->
		attribute =
			attributes: {}

		for key, keyword of @keywords
			continue unless PCAXIS_KEYWORDS[key][CONCEPT]?
			attribute.attributes[ PCAXIS_KEYWORDS[key][CONCEPT] ] = keyword[0].value

		@emitSDMX sdmx.DATA_SET_ATTRIBUTES, attribute


#-------------------------------------------------------------------------------

exports.ReadPcAxisPipe = ReadPcAxisPipe
