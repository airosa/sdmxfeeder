Log = require 'log'
factory = require '../lib/pipe/pipeFactory'
{SimpleRegistry} = require '../lib/registry/simpleRegistry'
should = require 'should'
util = require 'util'


runTest = ( pipes, before, after, done ) ->
	log = new Log Log.ERROR, process.stderr
	options =
		log: log
		registry: new SimpleRegistry log
	testPipe = factory.build pipes, options
	results = []
	errors = []

	testPipe.on 'data', (data) -> results.push data
	testPipe.on 'error', (err) -> errors.push err
	testPipe.on 'end', ->
		data.should.eql results[i] for data, i in after when data?
		errors.length.should.equal 0
		done()

	testPipe.write data for data in before
	testPipe.end()


exports.runTest = runTest
