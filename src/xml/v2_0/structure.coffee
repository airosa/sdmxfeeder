_ = require 'underscore'
header = require './header'

codeListCur = {}
codeCur = {}
conceptsCur = {}
conceptCur = {}
keyFamilyCur = {}
dimensionPos = 1
attributeCur = {}
groupCur = {}
primaryMeasureCur = {}
conceptSchemeTmp = {}
dsdCur = {}
comp = {}

renameProperty = (obj, oldName, newName) ->
	if obj.hasOwnProperty(oldName) and not obj.hasOwnProperty(newName)
		obj[newName] = obj[oldName]
		delete obj[oldName]

addConceptIdentity = (component, attrs) ->
	component.conceptIdentity = {}
	component.id = if attrs.concept? then attrs.concept else attrs.conceptRef
	component.conceptIdentity.ref = {}
	component.conceptIdentity.ref.id = if attrs.concept? then attrs.concept else attrs.conceptRef
	component.conceptIdentity.ref.agencyID = if attrs.conceptAgency? then attrs.conceptAgency else dsdCur.agencyID
	component.conceptIdentity.ref.maintainableParentID = 'CONCEPTS'
	component.conceptIdentity.ref.maintainableParentVersion = attrs.conceptVersion if attrs.conceptVersion?

addEnumeration = (component, attrs) ->
	return unless attrs.codelist?
	component.localRepresentation ?= {}
	component.localRepresentation.enumeration = {}
	component.localRepresentation.enumeration.ref = {}
	component.localRepresentation.enumeration.ref.id = attrs.codelist
	component.localRepresentation.enumeration.ref.agencyID = if attrs.codelistAgency? then attrs.codelistAgency else dsdCur.agencyID
	component.localRepresentation.enumeration.ref.version = attrs.codelistVersion if attrs.codelistVersion?

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
	'Concepts': (attrs) ->
		conceptSchemeTmp = {}
	'Concepts/Concept': (attrs) ->
		conceptSchemeTmp.id = 'CONCEPTS' unless conceptSchemeTmp.id?
		conceptSchemeTmp.agencyID = attrs.agency if not conceptSchemeTmp.agencyID? and attrs.agency?
		conceptSchemeTmp.agencyID = attrs.agencyID if not conceptSchemeTmp.agencyID? and attrs.agencyID?
		conceptSchemeTmp.name = {} unless conceptSchemeTmp.name?
		conceptSchemeTmp.name.en = 'Statistical concepts' unless conceptSchemeTmp.name.en?
		conceptSchemeTmp.concepts = {} unless conceptSchemeTmp.concepts?
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
	'KeyFamilies/KeyFamily/Components/Attribute/TextFormat': (attrs) ->
		addTextFormat comp, attrs
	'KeyFamilies/KeyFamily/Components/Group': (attrs) ->
		comp = {}
		comp.id = attrs.id
	'KeyFamilies/KeyFamily/Components/PrimaryMeasure/TextFormat': (attrs) ->
		addTextFormat comp, attrs


exitActions =
	'CodeLists/CodeList': (attrs) ->
		@emitSDMX 'codelist', codeListCur
	'CodeLists/CodeList/Code': (attrs) ->
		codeListCur.codes ?= {}
		codeListCur.codes[codeCur.value] = {}
		codeListCur.codes[codeCur.value].id = codeCur.value
		codeListCur.codes[codeCur.value].name = codeCur.description
	'CodeLists/CodeList/Name': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		codeListCur.name ?= {}
		codeListCur.name[ attrs['xml:lang'] ] = @stringBuffer
	'CodeLists/CodeList/Code/Description': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		codeCur.description ?= {}
		codeCur.description[ attrs['xml:lang'] ] = @stringBuffer
	'Concepts/Concept': (attrs) ->
		conceptSchemeTmp.concepts[conceptCur.id] = conceptCur
	'Concepts': (attrs) ->
		@emitSDMX 'conceptScheme', conceptSchemeTmp
	'Concepts/Concept/Name': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		conceptCur.name ?= {}
		conceptCur.name[ attrs['xml:lang'] ] = @stringBuffer
	'KeyFamilies/KeyFamily': (attrs) ->
		@emitSDMX 'dataStructure', dsdCur
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
