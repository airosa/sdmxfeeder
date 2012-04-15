{Checker} = require './checker'
{schemas} = require './genericSchemas'
{schemasForJSON} = require './genericSchemas'

class GenericChecker extends Checker
	constructor: (log) ->
		super

	getSchema: (schemaID, forJSON = false) ->
		 if forJSON then schemasForJSON[schemaID] else schemas[schemaID]

exports.GenericChecker = GenericChecker
