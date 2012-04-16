_ = require 'underscore'
header = require './header'
util = require '../../util/util'

codeListCur = {}
codeCur = {}
conceptSchemeCur = {}
conceptCur = {}
dataStructureCur = {}
componentCur = {}
dimensionPos = 0


entryActions =
	'Structures/Codelists': (attrs) ->
	'Structures/Codelists/Codelist': (attrs) ->
		codeListCur = _.extend {}, attrs
		codeListCur.isPartial = (codeListCur.isPartial is 'true') if codeListCur.isPartial?
	'Structures/Codelists/Codelist/Code': (attrs) ->
		codeCur = _.extend {}, attrs

	'Structures/Concepts/ConceptScheme': (attrs) ->
		conceptSchemeCur = _.extend {}, attrs
		conceptSchemeCur.isPartial = (conceptSchemeCur.isPartial is 'true') if conceptSchemeCur.isPartial?
	'Structures/Concepts/ConceptScheme/Concept': (attrs) ->
		conceptCur = _.extend {}, attrs
	'Structures/Concepts/ConceptScheme/Concept/CoreRepresentation/TextFormat': (attrs) ->
		conceptCur.coreRepresentation ?= {}
		conceptCur.coreRepresentation.textFormat = attrs

	'Structures/DataStructures/DataStructure': (attrs) ->
		dataStructureCur = _.extend {}, attrs
		dimensionPos = 0
	'Structures/DataStructures/DataStructure/DataStructureComponents/DimensionList/Dimension': (attrs) ->
		componentCur = _.extend {}, attrs
		dimensionPos += 1
		componentCur.order = dimensionPos
		componentCur.type = 'dimension'
	'Structures/DataStructures/DataStructure/DataStructureComponents/DimensionList/TimeDimension': (attrs) ->
		componentCur = _.extend {}, attrs
		dimensionPos += 1
		componentCur.order = dimensionPos
		componentCur.type = 'timeDimension'
	'Structures/DataStructures/DataStructure/DataStructureComponents/Group': (attrs) ->
		componentCur = _.extend {}, attrs
	'Structures/DataStructures/DataStructure/DataStructureComponents/Group/GroupDimension/DimensionReference/Ref': (attrs) ->
		componentCur.dimension ?= []
		componentCur.dimension.push attrs.id
	'Structures/DataStructures/DataStructure/DataStructureComponents/AttributeList/Attribute': (attrs) ->
		componentCur = _.extend {}, attrs
	'Structures/DataStructures/DataStructure/DataStructureComponents/AttributeList/Attribute/AttributeRelationship/Dimension/Ref': (attrs) ->
		componentCur.attributeRelationship ?= {}
		componentCur.attributeRelationship.dimension ?= []
		componentCur.attributeRelationship.dimension.push attrs.id
	'Structures/DataStructures/DataStructure/DataStructureComponents/AttributeList/Attribute/AttributeRelationship/Group/Ref': (attrs) ->
		componentCur.attributeRelationship ?= {}
		componentCur.attributeRelationship.group = attrs.id
	'Structures/DataStructures/DataStructure/DataStructureComponents/AttributeList/Attribute/AttributeRelationship/PrimaryMeasure/Ref': (attrs) ->
		componentCur.attributeRelationship ?= {}
		componentCur.attributeRelationship.primaryMeasure = attrs.id
	'Structures/DataStructures/DataStructure/DataStructureComponents/MeasureList/PrimaryMeasure': (attrs) ->
		componentCur = _.extend {}, attrs

exitActions =
	'Structures/Codelists/Codelist': (attrs) ->
		@emitSDMX 'codelist', codeListCur
	'Structures/Codelists/Codelist/Code': (attrs) ->
		codeListCur.codes ?= {}
		codeListCur.codes[codeCur.id] = codeCur
	'Structures/Codelists/Codelist/Name': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		codeListCur.name ?= {}
		codeListCur.name[ attrs['xml:lang'] ] = @stringBuffer
	'Structures/Codelists/Codelist/Description': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		codeListCur.description ?= {}
		codeListCur.description[ attrs['xml:lang'] ] = @stringBuffer
	'Structures/Codelists/Codelist/Code/Name': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		codeCur.name ?= {}
		codeCur.name[ attrs['xml:lang'] ] = @stringBuffer
	'Structures/Codelists/Codelist/Code/Description': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		codeCur.description ?= {}
		codeCur.description[ attrs['xml:lang'] ] = @stringBuffer

	'Structures/Concepts/ConceptScheme': (attrs) ->
		@emitSDMX 'conceptScheme', conceptSchemeCur
	'Structures/Concepts/ConceptScheme/Name': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		conceptSchemeCur.name ?= {}
		conceptSchemeCur.name[ attrs['xml:lang'] ] = @stringBuffer
	'Structures/Concepts/ConceptScheme/Concept': ->
		conceptSchemeCur.concepts ?= {}
		conceptSchemeCur.concepts[conceptCur.id] = conceptCur
	'Structures/Concepts/ConceptScheme/Concept/Name': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		conceptCur.name ?= {}
		conceptCur.name[ attrs['xml:lang'] ] = @stringBuffer
	'Structures/Concepts/ConceptScheme/Concept/Description': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		conceptCur.description ?= {}
		conceptCur.description[ attrs['xml:lang'] ] = @stringBuffer
	'Structures/Concepts/ConceptScheme/Concept/CoreRepresentation/Enumeration/URN': ->
		conceptCur.coreRepresentation ?= {}
		conceptCur.coreRepresentation.enumeration ?= {}
		conceptCur.coreRepresentation.enumeration.ref = @parseURN @stringBuffer

	'Structures/DataStructures/DataStructure': (attrs) ->
		@emitSDMX 'dataStructure', dataStructureCur
	'Structures/DataStructures/DataStructure/Name': (attrs) ->
		attrs['xml:lang'] ?= 'en'
		dataStructureCur.name ?= {}
		dataStructureCur.name[ attrs['xml:lang'] ] = @stringBuffer
	'Structures/DataStructures/DataStructure/DataStructureComponents/DimensionList/Dimension': ->
		dataStructureCur.dimensionDescriptor ?= {}
		dataStructureCur.dimensionDescriptor[ componentCur.id ] = componentCur
	'Structures/DataStructures/DataStructure/DataStructureComponents/DimensionList/TimeDimension': ->
		dataStructureCur.dimensionDescriptor ?= {}
		dataStructureCur.dimensionDescriptor[ componentCur.id ] = componentCur
	'Structures/DataStructures/DataStructure/DataStructureComponents/DimensionList/Dimension/ConceptIdentity/URN': ->
		componentCur.conceptIdentity ?= {}
		componentCur.conceptIdentity.ref ?= @parseURN @stringBuffer
	'Structures/DataStructures/DataStructure/DataStructureComponents/DimensionList/TimeDimension/ConceptIdentity/URN': ->
		componentCur.conceptIdentity ?= {}
		componentCur.conceptIdentity.ref ?= @parseURN @stringBuffer
	'Structures/DataStructures/DataStructure/DataStructureComponents/Group': ->
		dataStructureCur.dimensionGroupDescriptor ?= {}
		dataStructureCur.dimensionGroupDescriptor[ componentCur.id ] = componentCur
	'Structures/DataStructures/DataStructure/DataStructureComponents/AttributeList/Attribute': ->
		dataStructureCur.attributeDescriptor ?= {}
		dataStructureCur.attributeDescriptor[ componentCur.id ] = componentCur
	'Structures/DataStructures/DataStructure/DataStructureComponents/AttributeList/Attribute/ConceptIdentity/URN': ->
		componentCur.conceptIdentity ?= {}
		componentCur.conceptIdentity.ref ?= @parseURN @stringBuffer
	'Structures/DataStructures/DataStructure/DataStructureComponents/MeasureList/PrimaryMeasure': ->
		dataStructureCur.measureDescriptor ?= {}
		dataStructureCur.measureDescriptor.primaryMeasure = componentCur
	'Structures/DataStructures/DataStructure/DataStructureComponents/MeasureList/PrimaryMeasure/ConceptIdentity/URN': ->
		componentCur.conceptIdentity ?= {}
		componentCur.conceptIdentity.ref ?= @parseURN @stringBuffer
		componentCur.id = componentCur.conceptIdentity.ref.id

guards = {}

exports.fst = _.extend {}, header.fst, entryActions, exitActions, guards
exports.entryActions = _.defaults entryActions, header.entryActions
exports.exitActions = _.defaults exitActions, header.exitActions
exports.guards = _.defaults guards, header.guards
