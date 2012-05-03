{ReadXmlPipe} = require '../../lib/xml/readXmlPipe'
{ConvertCompactPipe} = require '../../lib/transform/convertCompactPipe'
{SubmitToRegistryPipe} = require '../../lib/registry/submitToRegistryPipe'
{SimpleRegistry} = require '../../lib/registry/simpleRegistry'
{GenericCheckPipe} = require '../../lib/checks/genericCheckPipe'
Log = require 'log'
fs = require 'fs'
path = require 'path'


describe 'ReadXmlPipe helpers', ->
	log = new Log Log.INFO, process.stderr

	testURN = (urn, agencyID, parentID, parentVersion, id) ->
		reader = new ReadXmlPipe log
		ref = reader.parseURN urn
		ref.should.have.property 'id', id if id?
		ref.should.have.property 'agencyID', agencyID
		if id?
			ref.should.have.property 'maintainableParentID', parentID
			ref.should.have.property 'maintainableParentVersion', parentVersion if parentVersion?
		else
			ref.should.have.property 'id', parentID
			ref.should.have.property 'version', parentVersion if parentVersion?

	it 'parse URN to ref', ->
		testURN 'urn:sdmx:org.sdmx.infomodel.conceptscheme.Concept=ECB:ECB_CONCEPTS(1.0).EXR_VAR', 'ECB', 'ECB_CONCEPTS', '1.0', 'EXR_VAR'
		testURN 'urn:sdmx:org.sdmx.infomodel.codelist.Codelist=SDMX:CL_CONF_STATUS(1.0)', 'SDMX', 'CL_CONF_STATUS', '1.0'
		#testURN 'urn:sdmx:org.sdmx.infomodel.codelist.Codelist=SDMX:CL_CONF_STATUS', 'SDMX', 'CL_CONF_STATUS'


describe 'ReadXmlPipe', ->

	log = registry = reader = checker = converter = {}
	fixturePath = path.resolve __dirname, '../fixtures/xml'


	loadRegistry = ( structureFile, done ) ->
		stream = fs.createReadStream "#{fixturePath}/#{structureFile}", { encoding: 'utf8' }
		reader = new ReadXmlPipe log
		stream.pipe reader
		submit = new SubmitToRegistryPipe log, registry
		reader.pipe submit
		submit.on 'end', done


	runTest = (testFile, done) ->
		stream = fs.createReadStream "#{fixturePath}/#{testFile}", { encoding: 'utf8' }
		reader = new ReadXmlPipe log
		stream.pipe reader
		converter = new ConvertCompactPipe log, registry
		reader.pipe converter
		checker = new GenericCheckPipe log
		converter.pipe checker
		checker.on 'end', done


	beforeEach ->
		log = new Log Log.INFO, process.stderr
		registry = new SimpleRegistry log


	checkResultsForGenericData = (done) ->
		checker.counters.out.header.should.equal 1
		checker.counters.out.missing.should.equal 0
		checker.counters.error.should.equal 0
		checker.counters.out.should.eql reader.counters.out
		console.log checker.errors if 0 < checker.errors.length
		checker.errors.length.should.equal 0
		done()


	checkResultsForCompactData = (done) ->
		checker.counters.out.header.should.equal 1
		checker.counters.out.missing.should.equal 0
		checker.counters.error.should.equal 0
		checker.counters.out.should.eql converter.counters.out
		console.log checker.errors if 0 < checker.errors.length
		checker.errors.length.should.equal 0
		done()


	it 'parses v2.0 structures', (done) ->
		runTest 'v2_0/StructureSample.xml', ->
			checkResultsForGenericData done


	it 'parses v2.0 generic data', (done) ->
		loadRegistry 'v2_0/StructureSample.xml', ->
			runTest 'v2_0/GenericSample.xml', ->
				checkResultsForGenericData done


	it 'parses v2.0 compact data', (done) ->
		loadRegistry 'v2_0/StructureSample.xml', ->
			runTest 'v2_0/CompactSample.xml', ->
				checkResultsForCompactData done


	it 'parses v1.0 structures', (done) ->
		runTest 'v1_0/StructureSample.xml', ->
				checkResultsForGenericData done


	it 'parses v1.0 generic data', (done) ->
		loadRegistry 'v2_0/StructureSample.xml', ->
			runTest 'v1_0/GenericSample.xml', ->
				checkResultsForGenericData done


	it 'parses v1.0 compact data', (done) ->
		loadRegistry 'v1_0/StructureSample.xml', ->
			runTest 'v1_0/CompactSample.xml', ->
				checkResultsForCompactData done


	it 'parses v2.1 Structures', (done) ->
		runTest 'v2_1/ecb_exr_rg_full.xml', ->
				checkResultsForGenericData done


	it 'parses v2.1 GenericTimeSeriesData', (done) ->
		loadRegistry 'v2_1/ecb_exr_rg_full.xml', ->
			runTest 'v2_1/ecb_exr_rg_ts_generic.xml', ->
				checkResultsForGenericData done


