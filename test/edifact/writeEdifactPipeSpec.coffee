{WriteEdifactPipe} = require '../../lib/edifact/writeEdifactPipe'
testdata = require('./testdata')


describe 'WriteEdifactPipe', ->

	writer = {}

	beforeEach ->
		writer = new WriteEdifactPipe()

	it 'can write edifact segments', ->
		"UNB+UNOC:3+4F0+ZZZ+001201:1410+IREF000215++GESMES/CB++++1'".should.equal writer.arrayToSegment(testdata.testArray[1])
		"FTX+ACM+++DSD?: data sructure definition'".should.equal writer.arrayToSegment(testdata.testArray[20])
