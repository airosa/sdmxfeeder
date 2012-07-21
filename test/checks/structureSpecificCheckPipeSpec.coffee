{StructureSpecificCheckPipe} = require '../../lib/checks/structureSpecificCheckPipe'
testData = require '../fixtures/testData'
Log = require 'log'
_ = require 'underscore'
util = require 'util'

describe 'StructureSpecificCheckPipe', ->

	log = new Log(Log.INFO, process.stderr)
	checker = series = {}

	beforeEach ->
		checker = new StructureSpecificCheckPipe( new Log Log.INFO, process.stderr )
		checker.write testData.header
		checker.write testData.codelist
		checker.write testData.conceptScheme
		checker.write testData.dataStructureDefinition
		series =
			type: 'series'
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


	it 'converts dsds to schemas', ->
		seriesSchema = checker.convertToSeriesSchema testData.dataStructureDefinition.data
		seriesSchema.should.be.a 'object'
		seriesSchema.should.have.property 'additionalProperties', false
		seriesSchema.should.have.property('properties').with.keys 'seriesKey', 'attributes', 'obs'
		seriesSchema.properties.seriesKey.should.be.a 'object'
		seriesSchema.properties.attributes.should.be.a 'object'

		seriesKeySchema = seriesSchema.properties.seriesKey
		seriesKeySchema.should.have.property 'additionalProperties', false
		seriesKeySchema.should.have.property 'required', true
		seriesKeySchema.should.have.property('properties').with.property 'FREQ'
		seriesKeySchema.properties.FREQ.should.have.property 'type', 'string'

		attributesSchema = seriesSchema.properties.attributes
		attributesSchema.should.have.property 'additionalProperties', false
		attributesSchema.should.have.property('properties').with.keys 'UNIT_MEASURE', 'COLL_METHOD', 'DECIMALS'
		attributesSchema.properties.COLL_METHOD.should.have.property 'maxLength', 40

		obsSchema = seriesSchema.properties.obs
		obsSchema.should.have.property('properties').with.property 'attributes'
		obsSchema.properties.attributes.should.have.property('properties').with.keys 'OBS_STATUS', 'CONF_STATUS_OBS'
		obsSchema.properties.attributes.properties.should.have.property 'OBS_STATUS'
		obsSchema.properties.attributes.properties.OBS_STATUS.should.have.property 'type', 'array'

		checker.validate series.data, series.type
		checker.errors.length.should.equal 0

	it 'checks data types from local representation', ->
		series.data.seriesKey.FREQ = 10
		checker.write series
		checker.errors[0].should.match /is not a required type/

	it 'checks coded values', ->
		series.data.seriesKey.CURRENCY = 'INVALID'
		checker.write series
		checker.errors[0].should.match /is not one of the possible values/

	it 'checks string lengths', ->
		series.data.attributes.COLL_METHOD = 'This value is                             too long'
		checker.write series
		checker.errors[0].should.match /greater than the required maximum length/

	it 'checks string lenghts from core representation', ->
		series.data.attributes.UNIT_MEASURE = 'INVALID'
		checker.write series
		checker.errors[0].should.match /greater than the required maximum length/

	it 'checks string lengths of obs level attributes', ->
		series.data.obs.attributes.OBS_STATUS[0] = 'INVALID'
		checker.write series
		checker.errors[0].should.match /greater than the required maximum length/

	it 'checks that all dimensions are valid', ->
		series.data.seriesKey.INVALID = 'INVALID'
		checker.write series
		checker.errors[0].should.match /Additional properties are not allowed/

	it 'checks that all dimension values are defined', ->
		delete series.data.seriesKey.FREQ
		checker.write series
		checker.errors[0].should.match /is required/

	it 'validates series', ->
		checker.validate testData.series.data, testData.series.type
		checker.errors.length.should.equal 0

	it 'validates groups', ->
		checker.validate testData.testGroup.data, testData.testGroup.type
		checker.errors.length.should.equal 0

	it 'validates data set attributes', ->
		checker.validate testData.testDataSetAttributes.data, testData.testDataSetAttributes.type
		checker.errors.length.should.equal 0
