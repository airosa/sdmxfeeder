schemas =

	maintainableRef:
		id: 'maintainableRef'
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
					version:
						type: 'string'
						default: '1.0'
					local:
						type: 'boolean'
					class:
						type: 'string'
					package:
						type: 'string'

	itemRef:
		id: 'itemRef'
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

	dataProviderRef:
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


	party:
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
						extends: 'internationalString'
					contact:
						type: 'array'
						items:
							type: 'object'
							properties:
								name:
									extends: 'internationalString'
								department:
									extends: 'internationalString'
								role:
									extends: 'internationalString'
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


	header:
		id: 'header'
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
				extends: 'party'
				required: true
			receiver:
				extends: 'party'
			name:
				extends: 'internationalString'
			structure:
				type: 'object'
				additionalProperties: false
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
					provisionAgreement:
						extends: 'maintainableRef'
					structureUsage:
						extends: 'maintainableRef'
					structure:
						extends: 'maintainableRef'
			dataProvider:
				extends: 'dataProviderRef'
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
				extends: 'internationalString'

	footer:
		id: 'footer'
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
					extends: 'internationalString'

	internationalString:
		id: 'internationalString'
		type: 'object'
		additionalProperties: false
		patternProperties:
			'^[a-z][a-z]$':
				type: 'string'

	identifiableArtefact:
		id: 'identifiableArtefact'
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

	representation:
		id: 'representation'
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

	nameableArtefact:
		id: 'nameableArtefact'
		extends: 'identifiableArtefact'
		properties:
			name:
				required: true
				extends: 'internationalString'
			description:
				extends: 'internationalString'

	maintainableArtefact:
		id: 'maintainableArtefact'
		extends: 'nameableArtefact'
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

	itemScheme:
		id: 'itemScheme'
		extends: 'maintainableArtefact'
		properties:
			isPartial:
				type: 'boolean'

	item:
		id: 'item'
		extends: 'nameableArtefact'
		additionalProperties: false
		properties:
			parent:
				type: 'string'

	codelist:
		id: 'codelist'
		extends: 'itemScheme'
		additionalProperties: false
		properties:
			codes:
				type: 'object'
				required: true
				additionalProperties: false
				patternProperties:
					'[A-Z0-9_@$\-]+':
						extends: 'item'

	concept:
		id: 'object'
		extends: 'item'
		properties:
			coreRepresentation:
				extends: 'representation'

	conceptScheme:
		id: 'conceptScheme'
		extends: 'itemScheme'
		additionalProperties: false
		properties:
			concepts:
				type: 'object'
				required: true
				additionalProperties: false
				patternProperties:
					'[A-Z0-9_@$\-]+':
						extends: 'concept'

	component:
		id: 'component'
		extends: 'identifiableArtefact'
		properties:
			conceptIdentity:
				extends: 'itemRef'
				required: true
			localRepresentation:
				extends: 'representation'

	structure:
		id: 'structure'
		extends: 'maintainableArtefact'

	componentList:
		id: 'componentList'
		type: 'object'

	dataStructure:
		id: 'dataStructure'
		extends: 'structure'
		additionalProperties: false
		properties:
			dimensionDescriptor:
				extends: 'componentList'
				required: true
				additionalProperties: false
				patternProperties:
					'[A-Z0-9_@$\-]+':
						extends: 'component'
						properties:
							order:
								type: 'integer'
								required: true
							type:
								type: 'string'
								required: true
								enum: [ 'dimension', 'measureDimension', 'timeDimension' ]
			dimensionGroupDescriptor:
				extends: 'componentList'
				additionalProperties: false
				properties:
					isAttachmentConstraint:
						type: 'boolean'
				patternProperties:
					'[A-Z0-9_@$\-]+':
						type: 'object'
						properties:
							id:
								type: 'string'
							dimensions:
								type: 'array'
								additionalItems: false
								uniqueItems: true
								items:
									type: 'string'
			attributeDescriptor:
				extends: 'componentList'
				additionalProperties: false
				patternProperties:
					'[A-Z0-9_@$\-]+':
						extends: 'component'
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
				extends: 'componentList'
				additionalProperties: false
				required: true
				properties:
					primaryMeasure:
						extends: 'component'
						required: true
						additionalProperties: false

	observation:
		id: 'observation'
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

	group:
		id: 'group'
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

	series:
		id: 'series'
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

	dataSetAttributes:
		id: 'dataSetAttributes'
		type: 'object'
		patternProperties:
			'[A-Z0-9_@$\-]+':
				type: 'string'

	dataSet:
		id: 'timeSeriesDataSetBegin'
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
				extends: 'dataProviderRef'

	query:
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

	message:
		id: 'message'
		type: 'object'
		additionalProperties: false
		properties:
			header:
				extends: 'header'
			structures:
				type: 'object'
				additionalProperties: false
				properties:
					codelists:
						type: 'object'
					concepts:
						type: 'object'
					dataStructures:
						type: 'object'
			dataSet:
				extends: 'dataSet'
				properties:
					data:
						type: 'array'
			query:
				extends: 'query'



extendSchema = (schema, root) ->
	extended = {}
	tmp = {}

	if schema.extends? and root[schema.extends]?
		extended = extendSchema root[schema.extends], root

	for property, value of schema when property isnt 'extends'
		if value instanceof Array or typeof value isnt 'object'
			extended[property] = value
			continue

		value = extendSchema value, root
		if extended[property]?
			if typeof extended[property] is 'object'
				for property2, value2 of value
					extended[property][property2] = value2
			else
				extended[property] = value
		else
			extended[property] = value

	return extended


convertForJSON = (schema) ->
	for key, value of schema
		convertForJSON2 value
	return schema

convertForJSON2 = (schema) ->
	if schema.type? and schema.type is 'date'
		schema.type = 'string'
		schema.pattern = '^\\d{4}-[01]\\d-[0-3]\\dT[0-2]\\d:[0-5]\\d:[0-5]\\d\\.\\d+[+-][0-2]\\d:[0-5]\\d|Z$'
	if schema.properties?
		for key, value of schema.properties
			convertForJSON2 value


exports.schemas = extendSchema schemas, schemas
exports.schemasForJSON = convertForJSON extendSchema(schemas, schemas)
