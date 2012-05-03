{ConvertCompactPipe} = require '../../lib/transform/convertCompactPipe'
{SimpleRegistry} = require '../../lib/registry/simpleRegistry'
{WriteToArrayStream} = require '../../lib/util/writeToArrayStream'
Log = require 'log'


describe 'ConvertCompactPipe', ->


	beforeEach (callback) ->
		log = new Log Log.INFO, process.stderr
		testData = require '../fixtures/testData'

		registry = new SimpleRegistry log
		registry.submit testData.dataStructureDefinition, ->
			converter = new ConvertCompactPipe log, registry
			stack = new WriteToArrayStream()
			converter.pipe stack
			callback()


	xit 'adds missing structure to header', ->
		converter.write testData.header
		converter.write testData.dataSetHeader
		converter.write testData.series
		converter.write testData.series

		stack.items.length.should.equal 4
		stack.items[0].type.should.equal testData.header.type
		stack.items[1].type.should.equal testData.dataSetHeader.type
		stack.items[2].type.should.equal testData.series.type
		stack.items[3].type.should.equal testData.series.type


	xit 'converts series components to keys', ->

