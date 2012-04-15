{JSONWriter} = require '../../lib/json/writer'
{StringStream} = require '../../lib/util/StringStream'
{GenericChecker} = require '../../lib/checks/genericChecker'
testData = require '../fixtures/testData'
Log = require 'log'


describe 'JSONWriter', ->

	stream = writer = checker = {}
	log = new Log(Log['INFO'], process.stderr)

	beforeEach ->
		writer = new JSONWriter log
		stream = new StringStream()
		writer.pipe stream

	afterEach ->
		message = JSON.parse stream.string
		checker = new GenericChecker log
		checker.check message, 'message', true
		checker.errors.length.should.equal 0
		console.log checker.errors if 0 < checker.errors.length

	it 'writes structures', (done) ->
		stream.on 'end', done
		writer.write testData.testHeader
		writer.write testData.testCodelist
		writer.write testData.testCodelist
		writer.write testData.testConceptScheme
		writer.write testData.testDataStructure
		writer.end()

	it 'writes datasets', (done) ->
		stream.on 'end', done
		writer.write testData.testHeader
		writer.write testData.testTimeSeriesDataSetBegin
		writer.write testData.testDataSetAttributes
		writer.write testData.testDataSetAttributes
		writer.write testData.testGroup
		writer.write testData.testGroup
		writer.write testData.testSeries
		writer.write testData.testSeries
		writer.write testData.testGroup
		writer.write testData.testSeries
		writer.end()
