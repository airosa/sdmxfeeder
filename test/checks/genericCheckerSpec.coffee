{GenericChecker} = require '../../lib/checks/genericChecker'
testData = require '../fixtures/testData'
Log = require 'log'

describe 'checker', ->

	checker = {}

	beforeEach ->
		checker = new GenericChecker( new Log(Log['INFO'], process.stderr) )

	it 'validates types', ->
		checker.validateType 100.00, { type: 'number' }, 'number ok'
		checker.validateType NaN, { type: 'number' }, 'number ok'
		checker.validateType 100.00, { type: 'integer' }, 'integer ok'
		checker.validateType NaN, { type: 'integer' }, 'integer ok'
		checker.validateType [], { type: 'array' }, 'array ok'
		checker.validateType new Date(), { type: 'date' }, 'date ok'
		checker.validateType null, { type: 'null' }, 'null ok'
		checker.validateType 'test', { type: 'any' }, 'any ok'
		checker.errors.length.should.equal 0

		checker.validateType undefined, { type: 'any' }, 'any nok'
		checker.validateType 1000, { type: 'string' }, 'string nok'
		checker.validateType 1000.1, { type: 'integer' }, 'integer nok'
		checker.errors.length.should.equal 3

	it 'validates enums', ->
		schema = { type: 'string', enum: [ 'foo' ] }
		checker.validateEnum 'foo', schema, 'enum ok'
		checker.errors.length.should.equal 0

		checker.validateEnum 'bar', schema, 'enum nok'
		checker.errors.length.should.equal 1

	it 'validates required', ->
		checker.validateRequired 100, { required: true }, 'required ok'
		checker.validateRequired null, { required: true }, 'required ok'
		checker.errors.length.should.equal 0

		checker.validateRequired undefined, { required: true }, 'required nok'
		checker.errors.length.should.equal 1

	it 'validates properties', ->
		checker.validateProperties { test: 'foo' }, properties: { test: { type: 'string' } }, 'properties ok'
		checker.errors.length.should.equal 0

		checker.validateProperties { test: 100 }, properties: { test: { type: 'string' } }, 'properties nok'
		checker.errors.length.should.equal 1

	it 'validates additionalProperties', ->
		obj = test: 'foo', test1: 100
		schema = properties: { test: { type: 'string' } }
		checker.validateAdditionalProperties obj, schema, 'additionalProperties ok'
		checker.errors.length.should.equal 0

		schema.additionalProperties = false
		checker.validateAdditionalProperties obj, schema, 'additionalProperties nok'
		checker.errors.length.should.equal 1

	it 'validates properties with patterns', ->
		obj = en: 'Description', fi: 'Kuvaus'
		schema = patternProperties: { '^[a-z][a-z]$': { type: 'string' } }
		checker.validateProperties obj, schema, 'validateProperties (patterns ok', 'obj'
		checker.errors.length.should.equal 0

		obj.sv = 100
		checker.validateProperties obj, schema, 'validateProperties (patterns nok', 'obj'
		checker.errors.length.should.equal 1

	it 'validates additionalProperties with patterns', ->
		obj = test: 'foo', en: 'Test'
		schema = properties: { test: { type: 'string' } }, patternProperties: { '^[a-z][a-z]$': { type: 'string' } }
		schema.additionalProperties = false
		checker.validateAdditionalProperties obj, schema, 'additionalProperties (patterns) ok'
		checker.errors.length.should.equal 0

		obj.notok = 'Invalid'
		checker.validateAdditionalProperties obj, schema, 'additionalProperties (patterns) nok'
		checker.errors.length.should.equal 1

	it 'validates items', ->
		obj = ['a','b']
		schema = items: { type: 'string' }
		checker.validateItems obj, schema, 'items ok'
		checker.errors.length.should.equal 0

		console.log checker.errors if 0 < checker.errors.length
		obj = ['a','b', 100]
		checker.validateItems obj, schema, 'items nok'
		checker.errors.length.should.equal 1

	it 'validates uniqueItems', ->
		obj = ['a','b']
		schema = items: { type: 'string' }, uniqueItems: true
		checker.validateUniqueItems obj, schema, 'items ok'
		checker.errors.length.should.equal 0

		console.log checker.errors if 0 < checker.errors.length
		obj = ['a','b','b']
		checker.validateUniqueItems obj, schema, 'items nok'
		checker.errors.length.should.equal 1

	it 'adds default values', ->
		obj = a: '1'
		schema = type: 'object', properties: { a: { type: 'string' }, b: { type: 'string', default: '2' } }
		checker.addDefaultValues obj, schema
		obj.b.should.equal '2'

	it 'validates headers', ->
		checker.write testData.testHeader
		checker.errors.length.should.equal 0

	it 'validates codelists', ->
		checker.write testData.testCodelist
		checker.errors.length.should.equal 0

	it 'validates concept schemes', ->
		checker.write testData.testConceptScheme
		checker.errors.length.should.equal 0

	it 'validates dataStructureDefinitions', ->
		checker.write testData.testDataStructure
		checker.errors.length.should.equal 0

	it 'validates series', ->
		checker.write testData.testSeries()
		checker.errors.length.should.equal 0

	it 'validates groups', ->
		checker.write testData.testGroup
		checker.errors.length.should.equal 0

	it 'validates data set attributes', ->
		checker.write testData.testDataSetAttributes
		checker.errors.length.should.equal 0

	it 'validates time series data set begins', ->
		checker.write testData.testTimeSeriesDataSetBegin
		checker.errors.length.should.equal 0
