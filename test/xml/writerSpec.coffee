{XMLWriter} = require '../../lib/xml/writer'
{XMLReader} = require '../../lib/xml/reader'
{StringStream} = require '../../lib/util/StringStream'
{Checker} = require '../../lib/checks/checker'
Log = require 'log'

testData = require '../fixtures/testData'

describe 'XMLWriter', ->

	stream = writer = checker = reader = {}
	log = new Log(Log['INFO'], process.stderr)

	beforeEach ->
		stream = new StringStream()
		writer = new XMLWriter log
		writer.pipe stream
		reader = new XMLReader log
		stream.pipe reader
		checker = new Checker log
		reader.pipe checker

	afterEach ->
		checker.counters.header.should.equal 1
		checker.errors.length.should.equal 0
		console.log checker.errors if 0 < checker.errors.length


	it 'writes structures into XML', (done) ->
		checker.on 'end', done
		writer.write testData.testHeader
		writer.write testData.testCodelist
		writer.write testData.testCodelist
		writer.write testData.testConceptScheme
		writer.write testData.testDataStructure
		writer.end()


	it 'writes datasets into XML', (done) ->
		checker.on 'end', done
		writer.write testData.testHeader
		writer.write testData.testTimeSeriesDataSetBegin
		writer.write testData.testDataSetAttributes
		writer.write testData.testDataSetAttributes
		writer.write testData.testGroup
		writer.write testData.testGroup
		writer.write testData.testSeries()
		writer.write testData.testSeries()
		writer.write testData.testGroup
		writer.write testData.testSeries()
		writer.end()
