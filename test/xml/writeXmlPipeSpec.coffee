{WriteXmlPipe} = require '../../lib/xml/writeXmlPipe'
{ReadXmlPipe} = require '../../lib/xml/readXmlPipe'
{WriteToStringStream} = require '../../lib/util/writeToStringStream'
{GenericCheckPipe} = require '../../lib/checks/genericCheckPipe'
Log = require 'log'

testData = require '../fixtures/testData'

describe 'WriteXmlPipe', ->

	stream = writer = checker = reader = {}
	log = new Log(Log.INFO, process.stderr)


	beforeEach ->
		writer = new WriteXmlPipe log
		stream = new WriteToStringStream()
		writer.pipe stream
		reader = new ReadXmlPipe log
		stream.pipe reader
		checker = new GenericCheckPipe log
		reader.pipe checker


	afterEach ->
		checker.counters.in.header.should.equal 1
		console.log checker.errors if 0 < checker.errors.length
		checker.errors.length.should.equal 0


	it 'writes structures into XML', (done) ->
		checker.on 'end', done
		writer.write testData.header
		writer.write testData.codelist
		writer.write testData.codelist
		writer.write testData.conceptScheme
		writer.write testData.dataStructureDefinition
		writer.end()


	it 'writes datasets into XML', (done) ->
		checker.on 'end', done
		writer.write testData.header
		writer.write testData.dataSetHeader
		writer.write testData.testDataSetAttributes
		writer.write testData.testDataSetAttributes
		writer.write testData.testGroup
		writer.write testData.testGroup
		writer.write testData.series
		writer.write testData.series
		writer.write testData.testGroup
		writer.write testData.series
		writer.end()
