{SimpleRegistry} = require '../../lib/registry/simpleRegistry'
sdmx = require '../../lib/pipe/sdmxPipe'
testData = require '../fixtures/testData'
Log = require 'log'
should = require 'should'


describe 'SimpleRegistry', ->


	it 'caches code lists and finds cached code lists', ->
		registry = new SimpleRegistry( new Log(Log.INFO, process.stderr) )
		codelist = testData.codelist

		queryCallback = (err, result) ->
			should.exist result
			should.not.exist err
			result.should.be.a 'object'
			result.should.eql codelist.data

		submitCallback = (err) ->
			should.not.exist err
			registry.query codelist.type, codelist.data, queryCallback

		registry.submit codelist.data, submitCallback


	it 'finds data structure definitions based on a match to a set of components', ->
		registry = new SimpleRegistry( new Log(Log.INFO, process.stderr) )
		dsd = testData.dataStructureDefinition.data
		components =
			FREQ: 'test'
			CURRENCY: 'test'

		matchCallback = (err, result) ->
			should.exist result
			should.not.exist err
			result.should.be.a 'object'
			result.should.eql dsd

		submitCallback = (err) ->
			should.not.exist err
			registry.match sdmx.SERIES, components, matchCallback

		registry.submit dsd, submitCallback


	it 'finds data structure definitions based on a match to series key', ->
		registry = new SimpleRegistry( new Log(Log.INFO, process.stderr) )
		dsd = testData.dataStructureDefinition.data
		series = testData.series

		matchCallback = (err, result) ->
			should.exist result
			should.not.exist err
			result.should.be.a 'object'
			result.should.eql dsd

		submitCallback = (err) ->
			should.not.exist err
			registry.match series.type, series.data, matchCallback

		registry.submit dsd, submitCallback
