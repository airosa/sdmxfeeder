{EDIFACTWriter} = require '../../lib/edifact/writer'
testdata = require('./testdata')


describe 'EDIFACTWriter', ->

	writer = {}

	beforeEach ->
		writer = new EDIFACTWriter()

	it 'can write edifact segments', ->
		"UNB+UNOC:3+4F0+ZZZ+001201:1410+IREF000215++GESMES/CB++++1'".should.equal writer.arrayToSegment(testdata.testArray[1])
		"FTX+ACM+++DSD?: data sructure definition'".should.equal writer.arrayToSegment(testdata.testArray[20])
