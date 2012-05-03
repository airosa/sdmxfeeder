{GenericCheckPipe} = require '../../lib/checks/genericCheckPipe'
testData = require '../fixtures/testData'
Log = require 'log'

describe 'GenericCheckPipe', ->

	checker = {}

	beforeEach ->
		checker = new GenericCheckPipe( new Log(Log.INFO, process.stderr) )

	it 'validas invalid series', ->
		series =
			seriesKey:
				FREQ: 'M'
				CURRENCY: 'GBP'
				CURRENCY_DENOM: 'EUR'
				EXR_TYPE: 'SP00'
				EXR_VAR: 'E'
			extraProperty:
				'invalid'
			attributes_is_missing:
				DECIMALS: '5'
				UNIT_MEASURE: 'GBP'
				COLL_METHOD: 'Average of observations through period'
			obs:
				obsDimension: ['2010-08','2010-09','2010-10']
				obsValue: [0.82363,0.82987,0.87637]
				attributes:
					OBS_STATUS: ['A','A','A']
					CONF_STATUS_OBS: ['F','F','F']
					invalid_property_type: 100

		checker.validate series, 'series'
		checker.errors.length.should.equal 3

	testChecksForObject = (obj) ->
		checker.validate obj.data, obj.type
		console.log checker.errors if 0 < checker.errors.length
		checker.errors.length.should.equal 0

	it 'validates valid headers', ->
		testChecksForObject testData.header

	it 'validates valid code lists', ->
		testChecksForObject testData.codelist

	it 'validates valid concept schemes', ->
		testChecksForObject testData.conceptScheme

	it 'validates valid data structure definitions', ->
		testChecksForObject testData.dataStructureDefinition

	it 'validates valid series', ->
		testChecksForObject testData.series

	it 'validates valid groups', ->
		testChecksForObject testData.testGroup

	it 'validates valid data set attributes', ->
		testChecksForObject testData.testDataSetAttributes

	it 'validates valid data set headers', ->
		#testChecksForObject testData.testTimeSeriesDataSetBegin
