helpers = require '../pipeTestHelper'
sdmx = require '../../lib/pipe/sdmxPipe'


describe 'DecodingPipe', ->

	it 'does not decode if structural metadata is not available', (done) ->

		before =
			type: sdmx.SERIES
			data:
				seriesKey:
					FREQ: 'A'
					CURRENCY: 'EUR'
				obs:
					obsValue: [ 0, 1 ]
					obsDimension: [ '2000', '2001' ]
					attributes:
						OBS_STATUS: [ 'A', 'A' ]

		after =
			type: sdmx.SERIES
			data:
				seriesKey:
					FREQ: 'A'
					CURRENCY: 'EUR'
				obs:
					obsValue: [ 0, 1 ]
					obsDimension: [ '2000', '2001' ]
					attributes:
						OBS_STATUS: [ 'A', 'A' ]

		helpers.runTest [ 'DECODE' ], [ before ], [ after ], done


	it 'decodes coded attributes, keys and concepts', (done) ->

		before = []
		after = []

		before[0] =
			type: sdmx.HEADER
			data:
				structure:
					DSD:
						structureID: 'DSD'
						structureRef:
							ref:
								id: 'DSD'
								agencyID: 'TEST'
								version: '1.0'
						dimensionAtObservation: 'TIME_PERIOD'


		before[1] =
			type: sdmx.CODE_LIST
			data:
				id: 'CL_FREQ'
				agencyID: 'TEST'
				version: '1.0'
				codes:
					A:
						id: 'A'
						name:
							en: 'Annual'

		before[2] =
			type: sdmx.CODE_LIST
			data:
				id: 'CL_CURRENCY'
				agencyID: 'TEST'
				version: '1.0'
				codes:
					EUR:
						id: 'EUR'
						name:
							en: 'Euro'

		before[3] =
			type: sdmx.CODE_LIST
			data:
				id: 'CL_OBS_STATUS'
				agencyID: 'TEST'
				version: '1.0'
				codes:
					A:
						id: 'A'
						name:
							en: 'Normal value'

		before[4] =
			type: sdmx.CONCEPT_SCHEME
			data:
				id: 'CONCEPTS'
				agencyID: 'TEST'
				version: '1.0'
				concepts:
					FREQ:
						id: 'FREQ'
						name:
							en: 'Frequency'
					OBS_STATUS:
						id: 'OBS_STATUS'
						name:
							en: 'Observation status'
					TIME_PERIOD:
						id: 'TIME_PERIOD'
						name:
							en: 'Time period'
					CURRENCY:
						id: 'CURRENCY'
						name:
							en: 'Currency'

		before[5] =
			type: sdmx.DATA_STRUCTURE_DEFINITION
			data:
				id: 'DSD'
				agencyID: 'TEST'
				version: '1.0'
				dimensionDescriptor:
					FREQ:
						type: 'dimension'
						conceptIdentity:
							ref:
								id: 'FREQ'
								agencyID: 'TEST'
								maintainableParentID: 'CONCEPTS'
								maintainableParentVersion: '1.0'
						localRepresentation:
							enumeration:
								ref:
									agencyID: 'TEST'
									id: 'CL_FREQ'
									version: '1.0'
					CURRENCY:
						type: 'dimension'
						conceptIdentity:
							ref:
								id: 'CURRENCY'
								agencyID: 'TEST'
								maintainableParentID: 'CONCEPTS'
								maintainableParentVersion: '1.0'
						localRepresentation:
							enumeration:
								ref:
									agencyID: 'TEST'
									id: 'CL_FREQ'
									version: '1.0'
					TIME_PERIOD:
						type: 'timeDimension'
						conceptIdentity:
							ref:
								id: 'TIME_PERIOD'
								agencyID: 'TEST'
								maintainableParentID: 'CONCEPTS'
								maintainableParentVersion: '1.0'
				measureDescriptor:
					primaryMeasure:
						conceptIdentity:
							ref:
								agencyID: 'TEST'
								maintainableParentID: 'CONCEPTS'
								maintainableParentVersion: '1.0'
								id: 'OBS_VALUE'
				attributeDescriptor:
					OBS_STATUS:
						conceptIdentity:
							ref:
								agencyID: 'TEST'
								maintainableParentID: 'CONCEPTS'
								maintainableParentVersion: '1.0'
								id: 'OBS_STATUS'
						localRepresentation:
							enumeration:
								ref:
									agencyID: 'TEST'
									id: 'CL_OBS_STATUS'
									version: '1.0'

		before[6] =
			type: sdmx.DATA_SET_HEADER
			data:
				structureRef: 'DSD'

		before[7] =
			type: sdmx.SERIES
			data:
				seriesKey:
					FREQ: 'A'
					CURRENCY: 'EUR'
				obs:
					obsValue: [ 0, 1 ]
					obsDimension: [ '2000', '2001' ]
					attributes:
						OBS_STATUS: [ 'A', 'A' ]

		after[7] =
			type: sdmx.SERIES
			data:
				seriesKey:
					FREQ: 'Annual'
					CURRENCY: 'EUR'
				obs:
					obsValue: [ 0, 1 ]
					obsDimension: [ '2000', '2001' ]
					attributes:
						OBS_STATUS: [ 'Normal value', 'Normal value' ]

		helpers.runTest [ 'SUBMIT', 'DECODE' ], before, after, done
