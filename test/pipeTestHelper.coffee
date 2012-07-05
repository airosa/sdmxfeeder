Log = require 'log'
factory = require '../lib/pipe/pipeFactory'
{SimpleRegistry} = require '../lib/registry/simpleRegistry'
should = require 'should'
util = require 'util'


log = new Log Log.ERROR, process.stderr


runTestWithRegistry = ( pipes, before, after, registry, done ) ->
	options =
		log: log
		registry: registry
	testPipe = factory.build pipes, options
	results = []
	errors = []

	testPipe.on 'data', (data) -> results.push data
	testPipe.on 'error', (err) -> errors.push err
	testPipe.on 'end', ->
		for val, i in after when val?
			results[i].should.eql after[i]
		errors.length.should.equal 0
		done()

	testPipe.write data for data in before
	testPipe.end()


runTest = ( pipes, before, after, done ) ->
	registry = new SimpleRegistry log
	runTestWithRegistry pipes, before, after, registry, done 


exports.runTest = runTest
exports.runTestWithRegistry = runTestWithRegistry
