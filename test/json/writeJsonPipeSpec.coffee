{WriteJsonPipe} = require '../../lib/json/writeJsonPipe'
{NativeWriteJsonPipe} = require '../../lib/json/nativeWriteJsonPipe'
{WriteToStringStream} = require '../../lib/util/writeToStringStream'
{GenericCheckPipe} = require '../../lib/checks/genericCheckPipe'
testData = require '../fixtures/testData'
Log = require 'log'

stream = writer = checker = log = {}

checkMessage = ->
	message = JSON.parse stream.string
	checker = new GenericCheckPipe log
	checker.validate message, 'message'
	console.log checker.errors if 0 < checker.errors.length
	checker.errors.length.should.equal 0


writeTestStructures = (done)->
	stream.on 'end', done
	writer.write testData.header
	writer.write testData.codelist
	writer.write testData.codelist
	writer.write testData.conceptScheme
	writer.write testData.dataStructureDefinition
	writer.end()

writeTestData = (done) ->
	stream.on 'end', done
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


describe 'WriteJsonPipe', ->

	beforeEach ->
		log = new Log(Log.INFO, process.stderr)
		writer = new WriteJsonPipe log
		stream = new WriteToStringStream()
		writer.pipe stream

	afterEach ->
		checkMessage()

	it 'writes structures', (done) ->
		writeTestStructures done

	it 'writes datasets', (done) ->
		writeTestData done


describe 'NativeJSONWriter', ->

	beforeEach ->
		log = new Log(Log.INFO, process.stderr)
		writer = new NativeWriteJsonPipe log
		stream = new WriteToStringStream()
		writer.pipe stream

	afterEach ->
		checkMessage()

	it 'writes structures', (done) ->
		writeTestStructures done

	it 'writes datasets', (done) ->
		writeTestData done
