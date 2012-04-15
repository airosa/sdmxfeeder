{XMLReader} = require '../../lib/xml/reader'
{CompactHandler} = require '../../lib/util/compactHandler'
{GenericChecker} = require '../../lib/checks/genericChecker'
Log = require 'log'
fs = require 'fs'
path = require 'path'

describe 'XMLReader helpers', ->
	log = new Log Log['INFO'], process.stderr

	it 'parse URN to ref', ->
		reader = new XMLReader log
		ref = reader.parseURN 'urn:sdmx:org.sdmx.infomodel.conceptscheme.Concept=ECB:ECB_CONCEPTS(1.0).EXR_VAR'
		ref.should.have.property 'id', 'EXR_VAR'
		ref.should.have.property 'agencyID', 'ECB'
		ref.should.have.property 'maintainableParentID', 'ECB_CONCEPTS'
		ref.should.have.property 'maintainableParentVersion', '1.0'


describe 'XMLReader', ->

	reader = checker = handler = {}
	fixturePath = path.resolve __dirname, '../fixtures/xml'
	dsd = attributes: { AVAILABILITY:{}, DECIMALS:{}, BIS_UNIT:{}, UNIT_MULT:{}, COLLECTION:{}, TIME_FORMAT:{} }
	log = new Log Log['INFO'], process.stderr
	timeout = 100

	runTest = (filename, done) ->
		stream = fs.createReadStream "#{fixturePath}/#{filename}", { encoding: 'utf8' }
		reader = new XMLReader log
		stream.pipe reader
		handler = new CompactHandler log, dsd
		reader.pipe handler
		checker = new GenericChecker log
		handler.pipe checker
		checker.on 'end', done

	afterEach ->
		checker.counters.header.should.be.above 0
		checker.counters.missing.should.equal 0
		checker.counters.undefined.should.equal 0
		checker.counters.error.should.equal 0
		(checker.counters.structure + checker.counters.data).should.be.above 0
		checker.errors.length.should.equal 0
		console.log checker.errors if 0 < checker.errors.length

	it 'parses v2.0 generic data', (done) ->
		runTest 'v2_0/GenericSample.xml', done

	it 'parses v1.0 generic data', (done) ->
		runTest 'v1_0/GenericSample.xml', done

	it 'parses v2.0 structures', (done) ->
		runTest 'v2_0/StructureSample.xml', done

	it 'parses v1.0 structures', (done) ->
		runTest 'v1_0/StructureSample.xml', done

	it 'parses v2.0 compact data', (done) ->
		runTest 'v2_0/CompactSample.xml', done

	it 'parses v1.0 compact data', (done) ->
		runTest 'v1_0/CompactSample.xml', done

	it 'parses v2.1 GenericTimeSeriesData', (done) ->
		runTest 'v2_1/ecb_exr_rg_ts_generic.xml', done

	it 'parses v2.1 Structures', (done) ->
		runTest 'v2_1/ecb_exr_rg_full.xml', done
