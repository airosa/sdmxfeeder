EDIFACTReader = require('../../lib/edifact/reader').EDIFACTReader
#CompactHandler = require('../../lib/xml/compactHandler').CompactHandler
{GenericChecker} = require '../../lib/checks/genericChecker'
Log = require 'log'
testdata = require './testdata'
fs = require 'fs'
path = require 'path'

describe 'EDIFACTReader', ->

	reader = checker = handler = {}
	fixturePath = path.resolve __dirname, '../fixtures/edifact'
	#dsd = attributes: { AVAILABILITY:{}, DECIMALS:{}, BIS_UNIT:{}, UNIT_MULT:{}, COLLECTION:{}, TIME_FORMAT:{} }
	log = new Log Log['INFO'], process.stderr
	timeout = 100

	beforeEach ->
		reader = new EDIFACTReader log
		checker = new GenericChecker log
		reader.pipe checker

	runTest = (filename, done) ->
		checker.on 'end', done
		stream = fs.createReadStream "#{fixturePath}/#{filename}", { encoding: 'ascii' }
		stream.pipe reader

	afterEach ->
		checker.counters.header.should.be.above 0
		checker.counters.missing.should.equal 0
		checker.counters.undefined.should.equal 0
		checker.counters.error.should.equal 0
		(checker.counters.structure + checker.counters.data).should.be.above 0
		checker.errors.length.should.equal 0
		console.log checker.errors if 0 < checker.errors.length

	it 'handles onSegment event', ->
		reader.onSegment seg for seg in testdata.testArray

	it 'reads code lists from edifact files', (done) ->
		runTest 'code_list.edi', done

	it 'reads concepts from edifact files', (done) ->
		runTest 'concepts.edi', done

	it 'reads key families from edifact files', (done) ->
		runTest 'key_family.edi', done

	it 'reads data updates from edifact files (1)', (done) ->
		runTest 'data_update_1.edi', done

	it 'reads data updates from edifact files (2)', (done) ->
		runTest 'data_update_2.edi', done

	it 'reads data and attribute updates from edifact files', (done) ->
		runTest 'data_and_attribute_update.edi', done
