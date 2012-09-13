_ = require 'underscore'
header = require './header'
sdmx = require '../../pipe/sdmxPipe'


codeListCur = {}
codeCur = {}
conceptsCur = {}
conceptCur = {}
keyFamilyCur = {}
dimensionPos = 1
attributeCur = {}
groupCur = {}
primaryMeasureCur = {}
conceptSchemeCur = {}
conceptSchemeTmp = null
dsdCur = {}
comp = {}

renameProperty = (obj, oldName, newName) ->
	if obj.hasOwnProperty(oldName) and not obj.hasOwnProperty(newName)
		obj[newName] = obj[oldName]
		delete obj[oldName]

addConceptIdentity = (component, attrs) ->
	component.conceptIdentity = {}
	component.id = attrs.concept
	component.id ?= attrs.conceptRef
	component.conceptIdentity.ref = {}
	component.conceptIdentity.ref.id = attrs.concept
	component.conceptIdentity.ref.id ?= attrs.conceptRef
	component.conceptIdentity.ref.agencyID = attrs.conceptAgency
	component.conceptIdentity.ref.agencyID ?= attrs.conceptSchemeAgency
	component.conceptIdentity.ref.agencyID ?= dsdCur.agencyID
	component.conceptIdentity.ref.maintainableParentID ?= attrs.conceptSchemeRef
	component.conceptIdentity.ref.maintainableParentID ?= 'CONCEPTS'
	component.conceptIdentity.ref.maintainableParentVersion = attrs.conceptVersion
	component.conceptIdentity.ref.maintainableParentVersion ?= attrs.conceptSchemeVersion
	component.conceptIdentity.ref.maintainableParentVersion ?= '1.0'

addEnumeration = (component, attrs) ->
	return unless attrs.codelist?
	component.localRepresentation ?= {}
	component.localRepresentation.enumeration = {}
	component.localRepresentation.enumeration.ref = {}
	component.localRepresentation.enumeration.ref.id = attrs.codelist
	component.localRepresentation.enumeration.ref.agencyID = if attrs.codelistAgency? then attrs.codelistAgency else dsdCur.agencyID
	component.localRepresentation.enumeration.ref.version = attrs.codelistVersion if attrs.codelistVersion?
	component.localRepresentation.enumeration.ref.version ?= '1.0'

addTextFormat = (component, attrs) ->
	component.localRepresentation ?= {}
	component.localRepresentation.textFormat ?= {}
	component.localRepresentation.textFormat.textType = switch attrs.textType
		when 'Double' then 'Numeric'
		else 'AlphaNumeric'
	component.localRepresentation.textFormat.minLength = +attrs.minLength if attrs.minLength?
	component.localRepresentation.textFormat.maxLength = +attrs.maxLength if attrs.maxLength?

entryActions =
	'CodeLists': (attrs) ->
	'CodeLists/CodeList': (attrs) ->
		codeListCur = _.extend {}, attrs
		@convertBool codeListCur, 'isFinal'
		renameProperty codeListCur, 'agency', 'agencyID'
	'CodeLists/CodeList/Code': (attrs) ->
		codeCur = _.extend {}, attrs
		renameProperty codeCur, 'value', 'id'
	'Concepts': (attrs) ->
		conceptSchemeTmp = null
	'Concepts/ConceptScheme': (attrs) ->
		conceptSchemeCur = _.extend {}, attrs
		conceptSchemeCur.concepts = {}
	'Concepts/ConceptScheme/Concept': (attrs) ->
		conceptCur = _.extend {}, attrs
	'Concepts/Concept': (attrs) ->
		conceptSchemeTmp ?= {}
		conceptSchemeTmp.id ?= 'CONCEPTS'
		conceptSchemeTmp.agencyID ?= attrs.agency
		conceptSchemeTmp.agencyID ?= attrs.agencyID
		conceptSchemeTmp.name ?= {}
		conceptSchemeTmp.name.en ?= 'Statistical concepts'
		conceptSchemeTmp.concepts ?= {}
		conceptCur = {}
		conceptCur.id = attrs.id
		conceptCur.uri = attrs.uri
	'KeyFamilies/KeyFamily': (attrs) ->
		dsdCur = {}
		dsdCur.id = attrs.id if attrs.id?
		dsdCur.agencyID = if attrs.agency? then attrs.agency else attrs.agencyID
		dsdCur.version = attrs.version if attrs.version?
		dsdCur.measureDescriptor = {}
		dimensionPos = 1
		@dimensions = []
	'KeyFamilies/KeyFamily/Components/PrimaryMeasure': (attrs) ->
		comp = {}
		addConceptIdentity comp, attrs
		@primaryMeasureID = if attrs.concept? then attrs.concept else attrs.conceptRef
	'KeyFamilies/KeyFamily/Components/Dimension': (attrs) ->
		comp = {}
		addConceptIdentity comp, attrs
		comp.order = dimensionPos;
		comp.type = 'dimension'
		comp.type = 'measureDimension' if attrs.isMeasureDimension? and attrs.isMeasureDimension is 'true'
		addEnumeration comp, attrs
		dimensionPos += 1
		@dimensions.push if attrs.concept? then attrs.concept else attrs.conceptRef
	'KeyFamilies/KeyFamily/Components/TimeDimension': (attrs) ->
		comp = {}
		addConceptIdentity comp, attrs
		comp.order = dimensionPos;
		comp.type = 'timeDimension'
		dimensionPos += 1
	'KeyFamilies/KeyFamily/Components/Attribute': (attrs) ->
		comp = {}
		comp.assignmentStatus = attrs.assignmentStatus
		addConceptIdentity comp, attrs
		addEnumeration comp, attrs
		comp.attributeRelationship = {}
		if attrs.attachmentLevel is 'Observation'
			comp.attributeRelationship.primaryMeasure = @primaryMeasureID
		if attrs.attachmentLevel is 'Series'
			comp.attributeRelationship.dimensions = @dimensions
		if attrs.attachmentLevel is 'Group'
			comp.attributeRelationship.dimensions = @dimensions.slice 1
	'KeyFamilies/KeyFamily/Components/Attribute/TextFormat': (attrs) ->
		addTextFormat comp, attrs
	'KeyFamilies/KeyFamily/Components/Group': (attrs) ->
		comp = {}
		comp.id = attrs.id
	'KeyFamilies/KeyFamily/Components/PrimaryMeasure/TextFormat': (attrs) ->
		addTextFormat comp, attrs


exitActions =
	'CodeLists/CodeList': (attrs) ->
		@emitSDMX sdmx.CODE_LIST, codeListCur
	'CodeLists/CodeList/Code': (attrs) ->
		codeListCur.codes ?= {}
		codeListCur.codes[codeCur.id] = codeCur
	'CodeLists/CodeList/Name': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		codeListCur.name ?= {}
		codeListCur.name[ attrs['xml:lang'] ] = @stringBuffer
	'CodeLists/CodeList/Code/Description': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		codeCur.name ?= {}
		codeCur.name[ attrs['xml:lang'] ] = @stringBuffer
	'Concepts/ConceptScheme/Concept': () ->
		conceptSchemeCur.concepts[conceptCur.id] = conceptCur
	'Concepts/Concept': (attrs) ->
		conceptSchemeTmp.concepts[conceptCur.id] = conceptCur
	'Concepts': (attrs) ->
		@emitSDMX sdmx.CONCEPT_SCHEME, conceptSchemeTmp if conceptSchemeTmp?
	'Concepts/ConceptScheme': (attrs) ->
		@emitSDMX sdmx.CONCEPT_SCHEME, conceptSchemeCur
	'Concepts/ConceptScheme/Name': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		conceptSchemeCur.name ?= {}
		conceptSchemeCur.name[ attrs['xml:lang'] ] = @stringBuffer
	'Concepts/ConceptScheme/Concept/Name': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		conceptCur.name ?= {}
		conceptCur.name[ attrs['xml:lang'] ] = @stringBuffer
	'Concepts/Concept/Name': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		conceptCur.name ?= {}
		conceptCur.name[ attrs['xml:lang'] ] = @stringBuffer
	'KeyFamilies/KeyFamily': (attrs) ->
		@emitSDMX sdmx.DATA_STRUCTURE_DEFINITION, dsdCur
	'KeyFamilies/KeyFamily/Name': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		dsdCur.name ?= {}
		dsdCur.name[ attrs['xml:lang'] ] = @stringBuffer
	'KeyFamilies/KeyFamily/Components/Dimension': (attrs) ->
		dsdCur.dimensionDescriptor ?= {}
		dsdCur.dimensionDescriptor[ comp.id ] = comp
	'KeyFamilies/KeyFamily/Components/TimeDimension': (attrs) ->
		dsdCur.dimensionDescriptor ?= {}
		dsdCur.dimensionDescriptor[ comp.id ] = comp
	'KeyFamilies/KeyFamily/Components/Attribute': (attrs) ->
		dsdCur.attributeDescriptor ?= {}
		dsdCur.attributeDescriptor[ comp.id ] = comp
	'KeyFamilies/KeyFamily/Components/PrimaryMeasure': (attrs) ->
		dsdCur.measureDescriptor = {}
		dsdCur.measureDescriptor.primaryMeasure = comp
	'KeyFamilies/KeyFamily/Components/Attribute/AttachmentMeasure': (attrs) ->
		attributeCur.AttachmentMeasure ?= []
		attributeCur.AttachmentMeasure.push @stringBuffer
	'KeyFamilies/KeyFamily/Components/Attribute/AttachmentGroup': (attrs) ->
		comp.attributeRelationship ?= {}
		comp.attributeRelationship.group = @stringBuffer
	'KeyFamilies/KeyFamily/Components/Group': (attrs) ->
		dsdCur.dimensionGroupDescriptor ?= {}
		dsdCur.dimensionGroupDescriptor[ comp.id ] = comp
	'KeyFamilies/KeyFamily/Components/Group/DimensionRef': (attrs) ->
		comp.dimensions ?= []
		comp.dimensions.push @stringBuffer



guards = {}

exports.fst = _.extend {}, header.fst, entryActions, exitActions, guards
exports.entryActions = _.defaults entryActions, header.entryActions
exports.exitActions = _.defaults exitActions, header.exitActions
exports.guards = _.defaults guards, header.guards
