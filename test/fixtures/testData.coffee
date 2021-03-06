sdmx = require '../../lib/pipe/sdmxPipe'

exports.header =
	type: sdmx.HEADER
	data:
		id: 'Quarterly BoP reporting'
		test: false
		prepared: new Date 2010, 1, 13, 16, 0, 33
		sender:
			SDMX:
				id: 'SDMX'
				name:
					en: 'SDMX.org'
				contact: [
					{ name:
						en: 'Mr Mark Smith' }
					{ name:
						en: 'Mr John Smith'
					department:
						en: 'IS/BoP'
					telephone: '0049 69 13440' }
				]
		structure:
			ECB_EXR1:
				structureID: 'ECB_EXR1'
				structureRef:
					ref:
						id: 'ECB_EXR'
						agencyID: 'ECB'
						version: '1.0'



exports.codelist =
	type: sdmx.CODE_LIST
	data:
		id: 'CL_CURRENCY'
		agencyID: 'ISO'
		version: '1.0'
		name:
			en: 'Currency'
		codes:
			EUR:
				id: 'EUR'
				name:
					en: 'Euro'
			GBP:
				id: 'GBP'
				name:
					en: 'UK pound'
			SEK:
				id: 'SEK'
				name:
					en: 'Swedish krona'


exports.conceptScheme =
	type: sdmx.CONCEPT_SCHEME
	data:
		id: 'CROSS_DOMAIN_CONCEPTS'
		agencyID: 'SDMX'
		version: '1.0'
		name:
			en: 'Statistical concepts'
		concepts:
			UNIT_MEASURE:
				id: 'UNIT_MEASURE'
				name:
					en: 'Unit measure'
				coreRepresentation:
					textFormat:
						maxLength: 3


exports.dataStructureDefinition =
	type: sdmx.DATA_STRUCTURE_DEFINITION
	data:
		id: 'ECB_EXR'
		agencyID: 'ECB'
		version: '1.0'
		name:
			en: 'Sample Data Structure Definition for exchange rates'
		dimensionDescriptor:
			FREQ:
				id: 'FREQ'
				order: 1
				type: 'dimension'
				conceptIdentity:
					ref:
						id: 'FREQ'
						agencyID: 'SDMX'
						maintainableParentID: 'CROSS_DOMAIN_CONCEPTS'
						maintainableParentVersion: '1.0'
			CURRENCY:
				id: 'CURRENCY'
				order: 2
				type: 'dimension'
				conceptIdentity:
					ref:
						agencyID: 'SDMX'
						maintainableParentID: 'CROSS_DOMAIN_CONCEPTS'
						maintainableParentVersion: '1.0'
						id: 'CURRENCY'
				localRepresentation:
					enumeration:
						ref:
							agencyID: 'ISO'
							id: 'CL_CURRENCY'
							version: '1.0'
			CURRENCY_DENOM:
				id: 'CURRENCY_DENOM'
				order: 3
				type: 'dimension'
				conceptIdentity:
					ref:
						agencyID: 'ECB'
						maintainableParentID: 'ECB_CONCEPTS'
						maintainableParentVersion: '1.0'
						id: 'CURRENCY_DENOM'
			EXR_TYPE:
				id: 'EXR_TYPE'
				order: 4
				type: 'dimension'
				conceptIdentity:
					ref:
						agencyID: 'ECB'
						maintainableParentID: 'ECB_CONCEPTS'
						maintainableParentVersion: '1.0'
						id: 'EXR_TYPE'
			EXR_VAR:
				id: 'EXR_VAR'
				order: 5
				type: 'dimension'
				conceptIdentity:
					ref:
						agencyID: 'ECB'
						maintainableParentID: 'ECB_CONCEPTS'
						maintainableParentVersion: '1.0'
						id: 'EXR_VAR'
			TIME_PERIOD:
				id: 'TIME_PERIOD'
				order: 6
				type: 'timeDimension'
				conceptIdentity:
					ref:
						agencyID: 'SDMX'
						maintainableParentID: 'CROSS_DOMAIN_CONCEPTS'
						maintainableParentVersion: '1.0'
						id: 'TIME_PERIOD'
				localRepresentation:
					textFormat:
						textType: 'ObservationalTimePeriod'
		measureDescriptor:
			primaryMeasure:
				id: 'OBS_VALUE'
				conceptIdentity:
					ref:
						agencyID: 'SDMX'
						maintainableParentID: 'CROSS_DOMAIN_CONCEPTS'
						maintainableParentVersion: '1.0'
						id: 'OBS_VALUE'
		attributeDescriptor:
			UNIT_MEASURE:
				id: 'UNIT_MEASURE'
				assignmentStatus: 'Conditional'
				conceptIdentity:
					ref:
						agencyID: 'SDMX'
						maintainableParentID: 'CROSS_DOMAIN_CONCEPTS'
						maintainableParentVersion: '1.0'
						id: 'UNIT_MEASURE'
				attributeRelationship:
					dimensions: ['CURRENCY','CURRENCY_DENOM','EXR_TYPE']
			COLL_METHOD:
				id: 'COLL_METHOD'
				assignmentStatus: 'Conditional'
				conceptIdentity:
					ref:
						agencyID: 'SDMX'
						maintainableParentID: 'CROSS_DOMAIN_CONCEPTS'
						maintainableParentVersion: '1.0'
						id: 'COLL_METHOD'
				attributeRelationship:
					dimensions: ['CURRENCY','CURRENCY_DENOM','EXR_TYPE']
				localRepresentation:
					textFormat:
						maxLength: 40
			DECIMALS:
				id: 'DECIMALS'
				assignmentStatus: 'Mandatory'
				conceptIdentity:
					ref:
						agencyID: 'SDMX'
						maintainableParentID: 'CROSS_DOMAIN_CONCEPTS'
						maintainableParentVersion: '1.0'
						id: 'DECIMALS'
				attributeRelationship:
					dimensions: ['CURRENCY','CURRENCY_DENOM','EXR_TYPE']
			OBS_STATUS:
				id: 'OBS_STATUS'
				assignmentStatus: 'Mandatory'
				conceptIdentity:
					ref:
						agencyID: 'SDMX'
						maintainableParentID: 'CROSS_DOMAIN_CONCEPTS'
						maintainableParentVersion: '1.0'
						id: 'OBS_STATUS'
				attributeRelationship:
					primaryMeasure: 'OBS_VALUE'
				localRepresentation:
					textFormat:
						maxLength: 1
			CONF_STATUS_OBS:
				id: 'CONF_STATUS_OBS'
				assignmentStatus: 'Conditional'
				conceptIdentity:
					ref:
						agencyID: 'SDMX'
						maintainableParentID: 'CROSS_DOMAIN_CONCEPTS'
						maintainableParentVersion: '1.0'
						id: 'CONF_STATUS_OBS'
				attributeRelationship:
					primaryMeasure: 'OBS_VALUE'

exports.testGroup =
	type: sdmx.ATTRIBUTE_GROUP
	data:
		type: 'SiblingGroup'
		groupKey:
			CURRENCY: 'GBP'
			CURRENCY_DENOM: 'EUR'
			EXR_TYPE: 'SP00'
			EXR_VAR: 'E'
		attributes:
			TITLE: 'ECB reference exchange rate, U.K. Pound sterling /Euro'

exports.series =
	type: sdmx.SERIES
	data:
		seriesKey:
			FREQ: 'M'
			CURRENCY: 'GBP'
			CURRENCY_DENOM: 'EUR'
			EXR_TYPE: 'SP00'
			EXR_VAR: 'E'
		attributes:
			DECIMALS: '5'
			UNIT_MEASURE: 'GBP'
			COLL_METHOD: 'Average of observations through period'
		obs:
			obsDimension: ['2010-08','2010-09','2010-10']
			obsValue: [0.82363,0.82987,0.87637]
			attributes:
				OBS_STATUS: ['A','A','A']
				CONF_STATUS_OBS: ['F','F','F']

exports.testDataSetAttributes =
	type: sdmx.DATA_SET_ATTRIBUTES
	data:
		attributes:
			UNIT_MULT: '0'
			COLL_METHOD: 'Average of observations through period'

exports.dataSetHeader =
	type: sdmx.DATA_SET_HEADER
	data:
		structureRef: 'ECB_EXR1'
		setID: 'TEST'
		action: 'Replace'
		reportingBeginDate: new Date Date.parse('2010-11-13T16:00:33.000Z')
		reportingEndDate: new Date Date.parse('2010-11-13T16:00:33.000Z')
		validFromDate: new Date Date.parse('2010-11-13T16:00:33.000Z')
		validToDate: new Date Date.parse('2010-11-13T16:00:33.000Z')
		publicationYear: 2010
		publicationPeriod: '1'
		dataProvider:
			ref:
		 		id: 'TEST'
		 		agencyID: 'SDMX'
		 		maintainableParentID: 'TEST'
		 		class: 'DataProvider'
