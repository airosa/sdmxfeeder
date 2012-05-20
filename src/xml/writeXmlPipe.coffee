sdmx = require '../pipe/sdmxPipe'
builder = require 'xmlbuilder'
#datejs = require 'datejs'
util = require 'util'

stringifiers =
	toString: (doc) -> doc.toString({ pretty: true })

	intString:
		v2_1: (doc, obj, type) ->
			return unless obj?
			for key, value of obj
				doc.ele(type).att('xml:lang',key).txt(value)

	maintainable:
		v2_1: (doc, obj) ->
			id = doc.att('id',obj.id).att('agencyID',obj.agencyID)
			id.att('version',obj.version) if obj.version?
			id.att('isFinal',obj.isFinal) if obj.isFinal?
			stringifiers.intString.v2_1 doc, obj.name, 'Name'

	item:
		v2_1: (doc, obj) ->
			doc.att('id',obj.id)
			stringifiers.intString.v2_1 doc, obj.name, 'Name'

	itemScheme:
		v2_1: (doc, obj) ->
			stringifiers.maintainable.v2_1 doc, obj
			doc.att('isPartial', obj.isPartial) if obj.isPartial?

	urn:
		v2_1: (doc, obj) ->
			return unless obj.urn?
			doc.ele('URN').txt(obj.urn)

	itemRef:
		v2_1: (doc, obj) ->
			return unless obj.ref?
			ref = doc.ele('Ref')
			ref.att('id',obj.ref.id)
				.att('agencyID',obj.ref.agencyID)
				.att('maintainableParentID',obj.ref.maintainableParentID)
				.att('maintainableParentVersion',obj.ref.maintainableParentVersion)
			ref.att('class',obj.ref.class) if obj.ref.class?
			ref.att('package',obj.ref.package) if obj.ref.package?

	ref:
		v2_1: (doc, obj) ->
			return unless obj.ref?
			ref = doc.ele('Ref')
			ref.att('id',obj.ref.id)
				.att('agencyID',obj.ref.agencyID)
				.att('version',obj.ref.version)
			ref.att('class',obj.ref.class) if obj.ref.class?
			ref.att('package',obj.ref.package) if obj.ref.package?

	conceptIdentity:
		v2_1: (doc, obj) ->
			return unless obj.conceptIdentity?
			ident = doc.ele('ConceptIdentity')
			stringifiers.urn.v2_1 ident, obj.conceptIdentity
			stringifiers.itemRef.v2_1 ident, obj.conceptIdentity

	localRepresentation:
		v2_1: (doc, obj) ->
			return unless obj.localRepresentation?
			rep = doc.ele('LocalRepresentation')
			if obj.localRepresentation.enumeration?
				enume = rep.ele('Enumeration')
				stringifiers.urn.v2_1 enume, obj.localRepresentation.enumeration
				stringifiers.ref.v2_1 enume, obj.localRepresentation.enumeration
			if obj.localRepresentation.textFormat?
				frmt = rep.ele('TextFormat')
				frmt.att('textType', obj.localRepresentation.textFormat.textType) if obj.localRepresentation.textFormat.textType?
				frmt.att('minLength', obj.localRepresentation.textFormat.minLength) if obj.localRepresentation.textFormat.minLength?
				frmt.att('maxLength', obj.localRepresentation.textFormat.maxLength) if obj.localRepresentation.textFormat.maxLength?

	codelist:
		v2_1: (doc, obj) ->
			codelist = doc.begin('Codelist')
			stringifiers.itemScheme.v2_1 codelist, obj
			for key, value of obj.codes
				code = codelist.ele('Code')
				stringifiers.item.v2_1 code, value
			stringifiers.toString doc

	conceptScheme:
		v2_1: (doc, obj) ->
			concepts = doc.begin('ConceptScheme')
			stringifiers.itemScheme.v2_1 concepts, obj
			for key, value of obj.concepts
				concept = concepts.ele('Concept')
				stringifiers.item.v2_1 concept, value
			stringifiers.toString doc

	dataStructureDefinition:
		v2_1: (doc, obj) ->
			dsd = doc.begin('DataStructure')
			stringifiers.maintainable.v2_1 dsd, obj
			components = dsd.ele('DataStructureComponents')

			list = components.ele('DimensionList')
			for key, value of obj.dimensionDescriptor
				type = switch value.type
					when 'dimension' then 'Dimension'
					when 'measureDimension' then 'MeasureDimension'
					when 'timeDimension' then 'TimeDimension'
				comp = list.ele(type)
				comp.att('id', value.id)
				stringifiers.conceptIdentity.v2_1 comp, value
				stringifiers.localRepresentation.v2_1 comp, value

			list = components.ele('AttributeList')
			for key, value of obj.attributeDescriptor
				comp = list.ele('Attribute')
					.att('id', value.id)
					.att('assignmentStatus', value.assignmentStatus)
				stringifiers.conceptIdentity.v2_1 comp, value
				stringifiers.localRepresentation.v2_1 comp, value

			if obj.measureDescriptor?
				m = components.ele('MeasureList')
					.ele('PrimaryMeasure')
					.att('id',obj.measureDescriptor.primaryMeasure.id)
				stringifiers.conceptIdentity.v2_1 m, value
				stringifiers.localRepresentation.v2_1 m, value

			stringifiers.toString doc

	group:
		genericTimeSeriesData:
			v2_1: (doc, obj) ->
				group = doc.begin('Group').att('type',obj.type)
				groupKey = group.e 'GroupKey'
				for key, value of obj.groupKey
					groupKey.ele('Value').att('value',value).att('id',key)
				attributes = group.e 'Attributes'
				for key, value of obj.attributes
					attributes.ele('Value').att('value',value).att('id',key)
				stringifiers.toString doc
		structureSpecificTimeSeriesData:
			v2_1: (b, obj) ->
				group = doc.begin('Group').att( 'xsi:type', "str:#{obj.type}" )
				group.a key, value for key, value of obj.groupKey
				group.a key, value for key, value of obj.attributes
				stringifiers.toString doc


	series:
		genericTimeSeriesData:
			v2_1: (doc, obj) ->
				series = doc.begin 'Series'
				seriesKey = series.e 'SeriesKey'
				for key, value of obj.seriesKey
					seriesKey.ele('Value').att('value',value).att('id',key)
				if obj.attributes?
					attributes = series.e 'Attributes'
					for key, value of obj.attributes
						attributes.ele('Value').att('value',value).att('id',key)
				for t, i in obj.obs.obsDimension
					obs = series.e 'Obs'
					obs.ele('ObsDimension').att('value',obj.obs.obsDimension[i])
					obs.ele('ObsValue').att('value',obj.obs.obsValue[i])
					attributes = obs.e 'Attributes'
					for key, value of obj.obs.attributes
						attributes.ele( 'Value' ).att( 'value', value[i] ).att( 'id' , key )
				stringifiers.toString doc
		structureSpecificTimeSeriesData:
			v2_1: (doc, obj) ->
				series = doc.begin 'Series'
				series.a key, value for key, value of obj.seriesKey
				series.a key, value for key, value of obj.attributes
				for t, i in obj.obs.TIME_PERIOD
					obs = series.e 'Obs'
					obs.a 'TIME_PERIOD', obj.obs.TIME_PERIOD[i]
					obs.a 'OBS_VALUE', obj.obs.OBS_VALUE[i]
					obs.a key , value[i] for key, value of obj.obs.attributes
				stringifiers.toString doc

	dataset:
		genericTimeSeriesData:
			v2_1: (doc, obj) ->
				dataset = doc.begin 'message:DataSet'
				dataset.att('xmlns', 'http://www.sdmx.org/resources/sdmxml/schemas/v2_1/generic')
					.att('structureRef', obj.structureRef)
				dataset.att('setID',obj.setID) if obj.setID?
				dataset.att('action',obj.action) if obj.action?
				dataset.att('reportingBeginDate',obj.reportingBeginDate.toISOString()) if obj.reportingBeginDate?
				dataset.att('reportingEndDate',obj.reportingEndDate.toISOString()) if obj.reportingEndDate?
				dataset.att('validFromDate',obj.validFromDate.toISOString()) if obj.validFromDate?
				dataset.att('validToDate',obj.validToDate.toISOString()) if obj.validToDate?
				dataset.att('publicationYear',obj.publicationYear) if obj.publicationYear?
				dataset.att('publicationPeriod',obj.publicationPeriod) if obj.publicationPeriod?
				str = stringifiers.toString doc
				str = str.replace /\/>/,'>'
		structureSpecificTimeSeriesData:
			v2_1: (doc, obj) ->
				dataset = doc.begin('message:DataSet')
					.att('xsi:type','str:DataSetType')
					.att('data:structureRef', obj.structureRef)
				dataset.att('data:setID',obj.setID) if obj.setID?
				dataset.att('data:action',obj.action) if obj.action?
				dataset.att('data:reportingBeginDate',obj.reportingBeginDate.toISOString()) if obj.reportingBeginDate?
				dataset.att('data:reportingEndDate',obj.reportingEndDate.toISOString()) if obj.reportingEndDate?
				dataset.att('data:validFromDate',obj.validFromDate.toISOString()) if obj.validFromDate?
				dataset.att('data:validToDate',obj.validToDate.toISOString()) if obj.validToDate?
				dataset.att('data:publicationYear',obj.publicationYear) if obj.publicationYear?
				dataset.att('data:publicationPeriod',obj.publicationPeriod) if obj.publicationPeriod?
				dataset.att('data:dataScope',obj.dataScope) if obj.dataScope?
				dataset.att('REPORTING_YEAR_START_DAY',obj.REPORTING_YEAR_START_DAY) if obj.REPORTING_YEAR_START_DAY?
				str = stringifiers.toString doc
				str = str.replace /\/>/,'>'

	parties:
		v2_1: (doc, obj, type) ->
			return unless obj?
			for key, value of obj
				party = doc.ele(type).att('id', value.id)
				stringifiers.intString.v2_1 party, value.name, 'Name'
				if value.contact?
					for value2 in value.contact
						contact = party.ele('Contact')
						stringifiers.intString.v2_1 contact, value2.name, 'Name' if value2.name?
						stringifiers.intString.v2_1 contact, value2.department, 'Department' if value2.department?
						stringifiers.intString.v2_1 contact, value2.role, 'Role' if value2.role?
						contact.ele('Telephone').txt(value2.telephone) if value2.telephone?
						contact.ele('Fax').txt(value2.fax) if value2.fax?
						contact.ele('X400').txt(value2.x400) if value2.x400?
						contact.ele('URI').txt(value2.uri) if value2.uri?
						contact.ele('Email').txt(value2.email) if value2.email?

	header:
		v2_1: (doc, obj) ->
			header = doc.ele('Header')
				.ele('ID').txt(obj.id).up()
				.ele('Test').txt(obj.test).up()
				.ele('Prepared').txt(obj.prepared.toISOString()).up()
			stringifiers.parties.v2_1 header, obj.sender, 'Sender'
			stringifiers.parties.v2_1 header, obj.receiver, 'Receiver'
			stringifiers.intString.v2_1 header, obj.name, 'Name'
			header.ele('DataSetAction').txt(obj.dataSetAction) if obj.dataSetAction?
			header.ele('DataSetID').txt(obj.dataSetID) if obj.dataSetID?
			header.ele('Extracted').txt(obj.extracted.toISOString()) if obj.extracted?
			header.ele('ReportingBegin').txt(obj.reportingBegin) if obj.reportingBegin?
			header.ele('ReportingEnd').txt(obj.reportingEnd) if obj.reportingEnd?
			header.ele('EmbargoDate').txt(obj.embargoDate.toISOString()) if obj.embargoDate?
			stringifiers.intString.v2_1 header, obj.source, 'Source'
			stringifiers.toString doc

	document:
		v2_1: (doc, rootElemName, header) ->
			str =  '<?xml version="1.0" encoding="UTF-8"?>\n'
			str += "<#{rootElemName} "
			str += 'xmlns="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/message" '
			str += 'xmlns:message="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/message" '
			str += 'xmlns:common="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/common" '
			str += 'xmlns:generic="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/data/generic" '
			str += 'xmlns:data="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/data/structurespecific" '
			str += 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">\n'
			str += stringifiers.header.v2_1 doc, header
			str


class WriteXmlPipe extends sdmx.WriteSdmxPipe
	constructor: (log) ->
		@header = {}
		@rootElemName = ''
		@doc = builder.create()
		super


	before: (type, data) ->
		str = ''
		switch type
			when 'header' then @header = data
		str


	beforeFirst: (type) ->
		str = ''
		switch type
			when sdmx.CODE_LIST, sdmx.CONCEPT_SCHEME, sdmx.DATA_STRUCTURE_DEFINITION
				if @counters.in.structure is 1
					@rootElemName = 'Structure'
					str += stringifiers.document.v2_1 @doc, @rootElemName, @header
					str += '<message:Structures xmlns="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/structure">\n'
				switch type
					when sdmx.CODE_LIST
						str += '<Codelists>\n'
					when sdmx.CONCEPT_SCHEME
						str += '<Concepts>\n'
					when sdmx.DATA_STRUCTURE_DEFINITION
						str += '<DataStructures>\n'
			when sdmx.DATA_SET_HEADER
				@rootElemName = 'GenericTimeSeriesData'
				str += stringifiers.document.v2_1 @doc, @rootElemName, @header
			when 'end'
				str += '</message:DataSet>\n' if 0 < @counters.in.datasetheader
				str += '</message:Structures>\n' if 0 < @counters.in.structure
				str += "</#{@rootElemName}>"
		str


	stringify: (type, data) ->
		switch type
			when sdmx.CODE_LIST
				stringifiers.codelist.v2_1 @doc, data
			when sdmx.CONCEPT_SCHEME
				stringifiers.conceptScheme.v2_1 @doc, data
			when sdmx.DATA_STRUCTURE_DEFINITION
				stringifiers.dataStructureDefinition.v2_1 @doc, data
			when sdmx.DATA_SET_HEADER
				stringifiers.dataset.genericTimeSeriesData.v2_1 @doc, data
			when sdmx.SERIES
				stringifiers.series.genericTimeSeriesData.v2_1 @doc, data
			when sdmx.ATTRIBUTE_GROUP
				stringifiers.group.genericTimeSeriesData.v2_1 @doc, data
			when sdmx.DATA_SET_ATTRIBUTES
				''
			else
				''


	afterLast: (type) ->
		switch type
			when sdmx.CODE_LIST then '</Codelists>\n'
			when sdmx.CONCEPT_SCHEME then '</Concepts>\n'
			when sdmx.DATA_STRUCTURE_DEFINITION then '</DataStructures>\n'
			else ''


exports.WriteXmlPipe = WriteXmlPipe
