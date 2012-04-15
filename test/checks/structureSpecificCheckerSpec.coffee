{StructureSpecificChecker} = require '../../lib/checks/structureSpecificChecker'
testData = require '../fixtures/testData'
Log = require 'log'
_ = require 'underscore'
util = require 'util'

describe 'structure specific checker', ->

	log = new Log(Log['INFO'], process.stderr)
	checker = cache = series = {}
	header = testData.testHeader
	header.structures =
		dataStructure: testData.testDataStructure.data
		codelists:
			'ISO:CL_CURRENCY(1.0)': testData.testCodelist.data
		conceptSchemes:
			'SDMX:CROSS_DOMAIN_CONCEPTS(1.0)': testData.testConceptScheme.data

	beforeEach ->
		checker = new StructureSpecificChecker log
		checker.write header
		series = testData.testSeries()

	it 'converts dsds to schemas', ->
		series = checker.schemas.series
		series.should.be.a 'object'
		series.should.have.property 'additionalProperties', false
		series.should.have.property('properties').with.keys 'seriesKey', 'attributes', 'obs'
		series.properties.seriesKey.should.be.a 'object'
		series.properties.attributes.should.be.a 'object'

		seriesKey = series.properties.seriesKey
		seriesKey.should.have.property 'additionalProperties', false
		seriesKey.should.have.property 'required', true
		seriesKey.should.have.property('properties').with.property 'FREQ'
		seriesKey.properties.FREQ.should.have.property 'type', 'string'

		attributes = series.properties.attributes
		attributes.should.have.property 'additionalProperties', false
		attributes.should.have.property('properties').with.keys 'UNIT_MEASURE', 'COLL_METHOD', 'DECIMALS'
		attributes.properties.COLL_METHOD.should.have.property 'maxLength', 40

		obs = series.properties.obs
		obs.should.have.property('properties').with.property 'attributes'
		obs.properties.attributes.properties.should.have.property 'OBS_STATUS'
		obs.properties.attributes.properties.OBS_STATUS.should.have.property 'type', 'array'

	it 'checks data types from local representation', ->
		series.data.seriesKey.FREQ = 10
		checker.write series
		checker.errors[0].should.match /should be string/

	it 'checks coded values', ->
		series.data.seriesKey.CURRENCY = 'INVALID'
		checker.write series
		checker.errors[0].should.match /is not in/

	it 'checks string lengths', ->
		series.data.attributes.COLL_METHOD = 'This value is                             too long'
		checker.write series
		checker.errors[0].should.match /must be shorter/

	it 'checks string lenghts from core representation', ->
		series.data.attributes.UNIT_MEASURE = 'INVALID'
		checker.write series
		checker.errors[0].should.match /must be shorter/

	it 'checks string lengths of obs level attributes', ->
		series.data.obs.attributes.OBS_STATUS[0] = 'INVALID'
		checker.write series
		checker.errors[0].should.match /must be shorter/

	it 'checks that all dimensions are valid', ->
		series.data.seriesKey.INVALID = 'INVALID'
		checker.write series
		checker.errors[0].should.match /is not allowed/

	it 'checks that all dimension values are defined', ->
		delete series.data.seriesKey.FREQ
		checker.write series
		checker.errors[0].should.match /is required/

	it 'validates series', ->
		checker.write series
		checker.errors.length.should.equal 0

	xit 'validates groups', ->
		checker.write testData.testGroup
		checker.errors.length.should.equal 0

	xit 'validates data set attributes', ->
		checker.write testData.testDataSetAttributes
		checker.errors.length.should.equal 0
