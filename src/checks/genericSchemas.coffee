
schemas = [
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.maintainableref'
		type: 'object'
		additionalProperties: false
		properties:
			ref:
				type: 'object'
				required: true
				additionalProperties: false
				properties:
					id:
						type: 'string'
						required: true
					agencyID:
						type: 'string'
						required: true
					version:
						type: 'string'
						default: '1.0'
					local:
						type: 'boolean'
					class:
						type: 'string'
					package:
						type: 'string'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.itemref'
		type: 'object'
		additionalProperties: false
		properties:
			ref:
				type: 'object'
				additionalProperties: false
				properties:
					id:
						type: 'string'
						required: true
					maintainableParentID:
						type: 'string'
						required: true
					maintainableParentVersion:
						type: 'string'
						default: '1.0'
					agencyID:
						type: 'string'
						required: true
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.dataproviderref'
		type: 'object'
		additionalProperties: false
		properties:
			ref:
				type: 'object'
				additionalProperties: false
				properties:
					id:
						type: 'string'
						required: true
					agencyID:
						type: 'string'
						required: true
					maintainableParentID:
						type: 'string'
					maintainableParentVersion:
						type: 'string'
						default: '1.0'
					class:
						type: 'string'
						enum: ['"Agency','DataConsumer','DataProvider','OrganisationUnit']
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.party'
		type: 'object'
		additionalProperties: false
		patternProperties:
			'^[A-Z0-9_@$\-]+':
				type: 'object'
				required: true
				additionalProperties: false
				properties:
					id:
						type: 'string'
						required: true
					name:
						$ref: 'urn:sdmxfeeder.infomodel.internationalstring'
					contact:
						type: 'array'
						items:
							type: 'object'
							properties:
								name:
									$ref: 'urn:sdmxfeeder.infomodel.internationalstring'
								department:
									$ref: 'urn:sdmxfeeder.infomodel.internationalstring'
								role:
									$ref: 'urn:sdmxfeeder.infomodel.internationalstring'
								telephone:
									type: 'string'
								fax:
									type: 'string'
								x400:
									type: 'string'
								uri:
									type: 'string'
								email:
									type: 'string'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.header'
		type: 'object'
		additionalProperties: false
		properties:
			id:
				type: 'string'
				required: true
			test:
				type: 'boolean'
				default: false
			prepared:
				type: 'date'
				required: true
			sender:
				id: 'urn:sdmxfeeder.infomodel.sender'
				extends:
					$ref: 'urn:sdmxfeeder.infomodel.party'
				required: true
			receiver:
				$ref: 'urn:sdmxfeeder.infomodel.party'
			name:
				$ref: 'urn:sdmxfeeder.infomodel.internationalstring'
			structure:
				type: 'object'
				additionalProperties:
					id: 'urn:sdmxfeeder.infomodel.header.structure'
					type: 'object'
					properties:
						structureID:
							type: 'string'
							required: true
						schemaURL:
							type: 'string'
						namespace:
							type: 'string'
						dimensionAtObservation:
							type: 'string'
						explicitMeasures:
							type: 'boolean'
						serviceURL:
							type: 'string'
						structureURL:
							type: 'string'
						provisionAgreementRef:
							$ref: 'urn:sdmxfeeder.infomodel.maintainableref'
						structureUsageRef:
							$ref: 'urn:sdmxfeeder.infomodel.maintainableref'
						structureRef:
							id: 'urn:sdmxfeeder.infomodel.header.structure.structureref'
							required: true
							extends:
								$ref: 'urn:sdmxfeeder.infomodel.maintainableref'
			dataProvider:
				$ref: 'urn:sdmxfeeder.infomodel.dataproviderref'
			dataSetAction:
				type: 'string'
				enum: ['Append','Replace','Delete','Information']
			dataSetID:
				type: 'string'
			extracted:
				type: 'date'
			reportingBegin:
				type: 'string'
			reportingEnd:
				type: 'string'
			embargoDate:
				type: 'date'
			source:
				$ref: 'urn:sdmxfeeder.infomodel.internationalstring'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.footer'
		type: 'array'
		items:
			type: 'object'
			additionalProperties: false
			properties:
				severity:
					type: 'string'
					enum: ['Error','Warning','Information']
				code:
					type: 'string'
				text:
					$ref: 'urn:sdmxfeeder.infomodel.internationalstring'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.internationalstring'
		type: 'object'
		additionalProperties: false
		patternProperties:
			'^[a-z][a-z]$':
				type: 'string'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.identifiableartefact'
		type: 'object'
		properties:
			id:
				type: 'string'
				required: true
				#pattern: '^[A-Z0-9][A-Z0-9_]{0,17}$'
			urn:
				type: 'string'
				format: 'uri'
			uri:
				type: 'string'
				format: 'uri'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.representation'
		type: 'object'
		additionalProperties: false
		properties:
			enumeration:
				type: 'object'
				additionalProperties: false
				properties:
					ref:
						type: 'object'
						additionalProperties: false
						properties:
							agencyID:
								type: 'string'
								required: true
							id:
								type: 'string'
								required: true
							version:
								type: 'string'
								default: '1.0'
			textFormat:
				type: 'object'
				additionalProperties: false
				properties:
					textType:
						type: 'string'
						enum: ['String','AlphaNumeric','Numeric','Alpha','ObservationalTimePeriod']
					minLength:
						type: 'integer'
						minimum: 1
					maxLength:
						type: 'integer'
						minimum: 1
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.nameableartefact'
		extends:
			$ref: 'urn:sdmxfeeder.infomodel.identifiableartefact'
		properties:
			name:
				required: true
				$ref: 'urn:sdmxfeeder.infomodel.internationalstring'
			description:
				$ref: 'urn:sdmxfeeder.infomodel.internationalstring'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.maintainableartefact'
		extends:
			$ref: 'urn:sdmxfeeder.infomodel.nameableartefact'
		properties:
			agencyID:
				type: 'string'
				required: true
			isFinal:
				type: 'boolean'
			isExternalReference:
				type: 'boolean'
			serviceURL:
				type: 'string'
			structureURL:
				type: 'string'
			version:
				type: 'string'
				default: '1.0'
				pattern: '[0-9]+(\.[0-9]+)*'
			validFrom:
				type: 'date'
			validTo:
				type: 'date'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.itemscheme'
		extends:
			$ref: 'urn:sdmxfeeder.infomodel.maintainableartefact'
		properties:
			isPartial:
				type: 'boolean'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.item'
		extends:
			$ref: 'urn:sdmxfeeder.infomodel.nameableartefact'
		properties:
			parent:
				type: 'string'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.codelist'
		extends:
			$ref: 'urn:sdmxfeeder.infomodel.itemscheme'
		additionalProperties: false
		properties:
			codes:
				type: 'object'
				required: true
				additionalProperties: false
				patternProperties:
					'[A-Z0-9_@$\-]+':
						$ref: 'urn:sdmxfeeder.infomodel.item'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.concept'
		extends:
			$ref: 'urn:sdmxfeeder.infomodel.item'
		additionalProperties: false
		properties:
			coreRepresentation:
				$ref: 'urn:sdmxfeeder.infomodel.representation'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.conceptscheme'
		extends:
			$ref: 'urn:sdmxfeeder.infomodel.itemscheme'
		additionalProperties: false
		properties:
			concepts:
				type: 'object'
				required: true
				additionalProperties:
					$ref: 'urn:sdmxfeeder.infomodel.concept'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.component'
		extends:
			$ref: 'urn:sdmxfeeder.infomodel.identifiableartefact'
		properties:
			conceptIdentity:
				extends:
					$ref: 'urn:sdmxfeeder.infomodel.itemref'
				required: true
			localRepresentation:
				$ref: 'urn:sdmxfeeder.infomodel.representation'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.structure'
		extends:
			$ref: 'urn:sdmxfeeder.infomodel.maintainableartefact'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.componentlist'
		type: 'object'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.datastructure'
		extends:
			$ref: 'urn:sdmxfeeder.infomodel.structure'
		additionalProperties: false
		properties:
			dimensionDescriptor:
				id: 'urn:sdmxfeeder.infomodel.dimensiondescriptor'
				type: 'object'
				required: true
				additionalProperties:
					id: 'urn:sdmxfeeder.infomodel.dimension'
					extends:
						$ref: 'urn:sdmxfeeder.infomodel.component'
					properties:
						order:
							type: 'integer'
							required: true
						type:
							type: 'string'
							required: true
							enum: [ 'dimension', 'measureDimension', 'timeDimension' ]
					additionalProperties: false
			dimensionGroupDescriptor:
				id: 'urn:sdmxfeeder.infomodel.dimensiongroupdescriptor'
				type: 'object'
				properties:
					isAttachmentConstraint:
						type: 'boolean'
				additionalProperties:
					id: 'urn:sdmxfeeder.infomodel.dimensiongroup'
					type: 'object'
					properties:
						id:
							type: 'string'
						dimensions:
							type: 'array'
							additionalItems: false
							uniqueIlems: true
							items:
								type: 'string'
			attributeDescriptor:
				id: 'urn:sdmxfeeder.infomodel.attributedescriptor'
				type: 'object'
				additionalProperties:
					id: 'urn:sdmxfeeder.infomodel.attribute'
					extends:
						$ref: 'urn:sdmxfeeder.infomodel.component'
					additionalProperties: false
					properties:
						assignmentStatus:
							type: 'string'
							required: true
							enum: [ 'Mandatory', 'Conditional' ]
						attributeRelationship:
							type: 'object'
							properties:
								group:
									type: 'string'
								dimensions:
									type: 'array'
									additionalItems: false
									uniqueItems: true
									items:
										type: 'string'
								primaryMeasure:
									type: 'string'
			measureDescriptor:
				extends:
					$ref: 'urn:sdmxfeeder.infomodel.componentlist'
				additionalProperties: false
				required: true
				properties:
					primaryMeasure:
						extends:
							$ref: 'urn:sdmxfeeder.infomodel.component'
						required: true
						additionalProperties: false
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.observation'
		type: 'object'
		properties:
			TIME_PERIOD:
				type: 'string'
			OBS_VALUE:
				type: 'number'
			attributes:
				type: 'object'
				patternProperties:
					'[A-Z0-9_@$\-]+':
						type: 'string'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.group'
		type: 'object'
		additionalProperties: false
		properties:
			type:
				type: 'string'
				required: true
			groupKey:
				type: 'object'
				required: true
				patternProperties:
					'[A-Z0-9_@$\-]+':
						type: 'string'
			attributes:
				type: 'object'
				patternProperties:
					'[A-Z0-9_@$\-]+':
						type: 'string'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.series'
		type: 'object'
		additionalProperties: false
		properties:
			seriesKey:
				type: 'object'
				required: true
				patternProperties:
					'[A-Z0-9_@$\-]+':
						type: 'string'
			attributes:
				type: 'object'
				patternProperties:
					'[A-Z0-9_@$\-]+':
						type: 'string'
			obs:
				type: 'object'
				additionalProperties: false
				properties:
					obsDimension:
						type: 'array'
						required: true
						items:
							type: 'string'
					obsValue:
						type: 'array'
						items:
							type: 'number'
					attributes:
						type: 'object'
						required: true
						patternProperties:
							'[A-Z0-9_@$\-]+':
								type: 'array'
								items:
									type: 'string'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.dataSetattributes'
		type: 'object'
		patternProperties:
			'[A-Z0-9_@$\-]+':
				type: 'string'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.datasetheader'
		type: 'object'
		additionalProperties: false
		properties:
			structureRef:
				type: 'string'
				required: true
			setID:
				type: 'string'
			action:
				type: 'string'
				enum: ['Append','Replace','Delete','Information']
			reportingBeginDate:
				type: 'date'
			reportingEndDate:
				type: 'date'
			validFromDate:
				type: 'date'
			validToDate:
				type: 'date'
			publicationYear:
				type: 'integer'
			publicationPeriod:
				type: 'string'
			dataProvider:
				$ref: 'urn:sdmxfeeder.infomodel.dataproviderref'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.query'
		type: 'object'
		additionalProperties: false
		properties:
			codelistWhere:
				type: 'object'
				additionalProperties: false
				properties:
					id:
						type: 'string'
					agencyID:
						type: 'string'
					version:
						type: 'string'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.structures'
		type: 'object'
		additionalProperties: false
		properties:
			codelists:
				type: 'object'
			concepts:
				type: 'object'
			dataStructures:
				type: 'object'
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.dataset'
		type: 'array'
		items: [
			{ $ref: 'urn:sdmxfeeder.infomodel.datasetheader' },
		]
	},
	{
		$schema : 'http://json-schema.org/draft-03/schema#'
		id: 'urn:sdmxfeeder.infomodel.message'
		type: 'array'
		items: [
			{ $ref: 'urn:sdmxfeeder.infomodel.header' },
			{ type: [
					{ type: 'object', default: {} },
					{ $ref: 'urn:sdmxfeeder.infomodel.structures' }
				]
			},
			{ $ref: 'urn:sdmxfeeder.infomodel.dataset' }
			{ $ref: 'urn:sdmxfeeder.infomodel.footer' }
		]
		additionalItems: false
	}
]

exports.schemas = schemas
