{SimpleRegistry} = require '../../lib/registry/simpleRegistry'
sdmx = require '../../lib/pipe/sdmxPipe'
testData = require '../fixtures/testData'
Log = require 'log'
should = require 'should'


describe 'SimpleRegistry', ->

	log = new Log(Log.INFO, process.stderr)

	it 'caches code lists and finds cached code lists', (done) ->
		registry = new SimpleRegistry log
		codelist = testData.codelist

		queryCallback = (err, result) ->
			should.exist result
			should.not.exist err
			result.should.be.a 'object'
			result.codeLists[ Object.keys(result.codeLists)[0] ].should.eql codelist.data
			done()

		submitCallback = (err) ->
			should.not.exist err
			registry.query codelist.type, codelist.data, false, queryCallback

		registry.submit codelist.data, submitCallback


	it 'finds data structure definitions based on a match to a set of components', (done) ->
		registry = new SimpleRegistry log
		dsd = testData.dataStructureDefinition.data
		components =
			FREQ: 'test'
			CURRENCY: 'test'

		matchCallback = (err, result) ->
			should.exist result
			should.not.exist err
			result.should.be.a 'object'
			result.should.eql dsd
			done()

		submitCallback = (err) ->
			should.not.exist err
			registry.match sdmx.SERIES, components, matchCallback

		registry.submit dsd, submitCallback


	it 'finds data structure definitions based on a match to series key', (done) ->
		registry = new SimpleRegistry log
		dsd = testData.dataStructureDefinition.data
		series = testData.series

		matchCallback = (err, result) ->
			should.exist result
			should.not.exist err
			result.should.be.a 'object'
			result.should.eql dsd
			done()

		submitCallback = (err) ->
			should.not.exist err
			registry.match series.type, series.data, matchCallback

		registry.submit dsd, submitCallback


	it 'resolves references between sdmx artefacts', (done) ->
		registry = new SimpleRegistry log
		cl = testData.codelist.data
		dsd = testData.dataStructureDefinition.data

		registry.submit cl, (err) ->
			should.not.exist err
			registry.submit dsd, (err) ->
				should.not.exist err
				registry.query sdmx.DATA_STRUCTURE_DEFINITION, dsd, true, (err, result) ->
					should.not.exist err
					should.exist result
					result.should.be.a 'object'
					result.should.have.property 'codeLists'
					result.codeLists.should.have.property "#{cl.agencyID}:#{cl.id}(#{cl.version})"
					result.should.have.property 'dataStructureDefinitions'
					result.dataStructureDefinitions.should.have.property "#{dsd.agencyID}:#{dsd.id}(#{dsd.version})"
					done()

