{JSV} = require 'JSV'
schemas = require '../../lib/checks/genericSchemas'

describe 'Generic JSON Schemas', ->

	it 'passes JSON Schema Draft 03 schema validation', ->
		env = JSV.createEnvironment 'json-schema-draft-03'
		jsonSchema = env.findSchema( env.getOption 'latestJSONSchemaSchemaURI' )

		for schema in schemas
			env.createSchema schema
			should.exist env.findSchema my_schema.id
			report = jsonSchema.validate( env.findSchema schema.id )
			console.log report.errors if 0 < report.errors.length
			report.errors.length.should.equal 0

