{SubmitToRegistryPipe} = require '../../lib/registry/submitToRegistryPipe'
{SimpleRegistry} = require '../../lib/registry/simpleRegistry'
sdmx = require '../../lib/pipe/sdmxPipe'
testData = require '../fixtures/testData'
Log = require 'log'
should = require 'should'


describe 'SubmitToRegistryPipe', ->

	it 'submits code lists and other structures into registry', (done) ->
		log = new Log Log.INFO, process.stderr
		registry = new SimpleRegistry log
		pipe = new SubmitToRegistryPipe log, registry

		checkResult = (err, found) ->
			should.exist found
			should.not.exist err
			found.should.be.a 'object'
			found.should.eql codelist.data
			done()

		pipe.on 'data', ->
			registry.query codelist.type, codelist.data, checkResult

		codelist = testData.codelist
		pipe.write testData.codelist

