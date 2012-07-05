Log = require 'log'
helpers = require '../pipeTestHelper'
sdmx = require '../../lib/pipe/sdmxPipe'
{SimpleRegistry} = require '../../lib/registry/simpleRegistry'
testData = require '../fixtures/testData'
should = require 'should'


log = new Log Log.ERROR, process.stderr


describe 'SubmitToRegistryPipe', ->

    it 'submits code lists and other structures into registry', (done) ->
        registry = new SimpleRegistry log
        before = []
        after = []

        before.push testData.codelist

        checkRegistry = ->
        	registry.query sdmx.CODE_LIST, testData.codelist.data, false, (err, results) ->
        		should.not.exist err
        		should.exist results
        		results.should.have.property 'codeLists'
        		results.codeLists.should.have.property 'ISO:CL_CURRENCY(1.0)'
        		done()

        helpers.runTestWithRegistry [ 'SUBMIT' ], before, after, registry, checkRegistry

