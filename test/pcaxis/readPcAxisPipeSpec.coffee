sdmx = require '../../lib/pipe/sdmxPipe'
helpers = require '../pipeTestHelper'
Log = require 'log'

describe 'ReadPcAxisPipe', ->

	px = """
CHARSET="ANSI";
AXIS-VERSION="2000";
LANGUAGE="fi";
DECIMALS=6;
CREATION-DATE="20090511 09:00";
MATRIX="ashi1";
SUBJECT-CODE="ASU";
SUBJECT-AREA="Asuminen";
TITLE="Vanhojen asuntojen hintaindeksi 2005=100 muuttujina Vuosi, Alue, Neljännes, Talotyyppi, Huoneluku ja Tiedot";
CONTENTS="Vanhojen asuntojen hintaindeksi 2005=100";
UNITS="euroa/neliö";
STUB="d1","d2","d3","d4","d5";
HEADING="d6";
VALUES("d1")="2005","2006";
VALUES("d2")="VD21","VD22";
VALUES("d3")="VD31","VD32";
VALUES("d4")="VD41","VD42";
VALUES("d5")="VD51","VD52";
VALUES("d6")="VD61","VD62";
TIMEVAL("d1")=TLIST(A1,"2005"-"2006");
CODES("d1")="2005","2006";
CODES("d2")="CD21","CD22";
CODES("d3")="CD31","CD32";
CODES("d4")="CD41","CD42";
CODES("d5")="CD51","CD52";
CODES("d6")="CD61","CD62";
LAST-UPDATED="20120427 09:00";
CONTACT="Sähköposti: asuminen@tilastokeskus.fi";
SOURCE="Tilastokeskus";
DATA=
1	2	3	4	5	6	7	8	9	10
11	12	13	14	15	16	17	18	19	20
21	22	23	24	25	26	27	28	29	30
31	32	33	34	35	36	37	38	39	40
41	42	43	44	45	46	47	48	49	50
51	52	53	54	55	56	57	58	59	60
61	62	63	64;
"""

	before = new Buffer px, 'ascii'
	after = []

	beforeEach ->
		after = []


	it 'extracts headers from PC-Axis files', (done) ->

		after[0] =
			type: sdmx.HEADER
			sequenceNumber: 1
			data:
				id: 'ASHI1'
				test: false
				prepared: new Date 2009, 4, 11, 9
				sender:
					TILASTOKESKUS:
						id: 'TILASTOKESKUS'
						name:
							fi: 'Tilastokeskus'
						contact: [
							{
								name:
									en: 'Contact'
								email: 'asuminen@tilastokeskus.fi'
							}
						]
				extracted: new Date 2012, 3, 27, 9
				source:
					fi: 'Tilastokeskus'
				structure:
					ASHI1:
						structureID: 'ASHI1'
						structureRef:
							id: 'ASHI1'
							agencyID: 'TILASTOKESKUS'
							version: '1.0'
				name:
					fi: 'Vanhojen asuntojen hintaindeksi 2005=100 muuttujina Vuosi, Alue, Neljännes, Talotyyppi, Huoneluku ja Tiedot'

		helpers.runTest [ 'READ_PX' ], [ before ], after, done


	it 'extracts code lists from PC-Axis files', (done) ->

		after[1] =
			type: sdmx.CODE_LIST
			sequenceNumber: 2
			data:
				id: 'CL_D1'
				agencyID: 'TILASTOKESKUS'
				version: '1.0'
				name:
					fi: 'd1'
				codes:
					2005:
						id: '2005'
						name:
							fi: '2005'
					2006:
						id: '2006'
						name:
							fi: '2006'

		helpers.runTest [ 'READ_PX' ], [ before ], after, done


	it 'extracts concept schemes from PC-Axis files', (done) ->

		after[9] =
			type: sdmx.CONCEPT_SCHEME
			sequenceNumber: 10
			data:
				id: 'CONCEPT_SCHEME'
				agencyID: 'TILASTOKESKUS'
				version: '1.0'
				name:
					fi: 'Vanhojen asuntojen hintaindeksi 2005=100'
				concepts:
					D2:
						id: 'D2'
						name:
							fi: 'd2'
					D3:
						id: 'D3'
						name:
							fi: 'd3'
					D4:
						id: 'D4'
						name:
							fi: 'd4'
					D5:
						id: 'D5'
						name:
							fi: 'd5'
					D6:
						id: 'D6'
						name:
							fi: 'd6'

		helpers.runTest [ 'READ_PX' ], [ before ], after, done


	it 'extracts concept schemes from PC-Axis files', (done) ->

		after[11] =
			type: sdmx.DATA_STRUCTURE_DEFINITION
			sequenceNumber: 12
			data:
				id: 'ASHI1'
				agencyID: 'TILASTOKESKUS'
				version: '1.0'
				name:
					fi: 'Vanhojen asuntojen hintaindeksi 2005=100'
				dimensionDescriptor:
					'FREQ':
						id: 'FREQ'
						order: 1
						type: 'dimension'
						conceptIdentity:
							ref:
								id: 'FREQ'
								agencyID: 'SDMX'
								maintainableParentID: 'CROSS_DOMAIN_CONCEPTS'
								maintainableParentVersion: '1.0'
						localRepresentation:
							enumeration:
								ref:
									id: 'CL_FREQ'
									agencyID: 'SDMX'
									version: '1.0'
					'TIME_PERIOD':
						id: 'TIME_PERIOD'
						order: 2
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
					'D2':
						id: 'D2'
						order: 3
						type: 'dimension'
						conceptIdentity:
							ref:
								agencyID: 'TILASTOKESKUS'
								maintainableParentID: 'CONCEPT_SCHEME'
								maintainableParentVersion: '1.0'
								id: 'D2'
						localRepresentation:
							enumeration:
								ref:
									id: 'CL_D2'
									agencyID: 'TILASTOKESKUS'
									version: '1.0'
					'D3':
						id: 'D3'
						order: 4
						type: 'dimension'
						conceptIdentity:
							ref:
								agencyID: 'TILASTOKESKUS'
								maintainableParentID: 'CONCEPT_SCHEME'
								maintainableParentVersion: '1.0'
								id: 'D3'
						localRepresentation:
							enumeration:
								ref:
									id: 'CL_D3'
									agencyID: 'TILASTOKESKUS'
									version: '1.0'
					'D4':
						id: 'D4'
						order: 5
						type: 'dimension'
						conceptIdentity:
							ref:
								agencyID: 'TILASTOKESKUS'
								maintainableParentID: 'CONCEPT_SCHEME'
								maintainableParentVersion: '1.0'
								id: 'D4'
						localRepresentation:
							enumeration:
								ref:
									id: 'CL_D4'
									agencyID: 'TILASTOKESKUS'
									version: '1.0'
					'D5':
						id: 'D5'
						order: 6
						type: 'dimension'
						conceptIdentity:
							ref:
								agencyID: 'TILASTOKESKUS'
								maintainableParentID: 'CONCEPT_SCHEME'
								maintainableParentVersion: '1.0'
								id: 'D5'
						localRepresentation:
							enumeration:
								ref:
									id: 'CL_D5'
									agencyID: 'TILASTOKESKUS'
									version: '1.0'
					'D6':
						id: 'D6'
						order: 7
						type: 'dimension'
						conceptIdentity:
							ref:
								agencyID: 'TILASTOKESKUS'
								maintainableParentID: 'CONCEPT_SCHEME'
								maintainableParentVersion: '1.0'
								id: 'D6'
						localRepresentation:
							enumeration:
								ref:
									id: 'CL_D6'
									agencyID: 'TILASTOKESKUS'
									version: '1.0'
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
					'OBS_STATUS':
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
							enumeration:
								ref:
									id: 'CL_OBS_STATUS'
									agencyID: 'SDMX'
									version: '1.0'


		helpers.runTest [ 'READ_PX' ], [ before ], after, done
