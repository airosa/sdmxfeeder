{MegaPipe} = require './megaPipe'
{ReadXmlPipe} = require '../xml/readXmlPipe'
{WriteXmlPipe} = require '../xml/writeXmlPipe'
{ReadEdifactPipe} = require '../edifact/readEdifactPipe'
{WriteEdifactPipe} = require '../edifact/writeEdifactPipe'
{WriteJsonPipe} = require '../json/writeJsonPipe'
{SubmitToRegistryPipe} = require '../registry/submitToRegistryPipe'
{ConvertCompactPipe} = require '../transform/convertCompactPipe'
{GenericCheckPipe} = require '../checks/genericCheckPipe'
{DebugPipe} = require '../util/debugPipe'


class PipeFactory
	constructor: ->

	build: (pipes, options) ->
		subpipes = []
		for name, n in pipes
			subpipe = switch name
				when 'XML'
					if n is 0
						new ReadXmlPipe options.log
					else
						new WriteXmlPipe options.log
				when 'EDI'
					if n is 0
						new ReadEdifactPipe options.log
					else
						new WriteEdifactPipe options.log
				when 'JSON'
					new WriteJsonPipe options.log
				when 'submit'
					new SubmitToRegistryPipe options.log, options.registry
				when 'convert'
					new ConvertCompactPipe options.log, options.registry
				when 'check'
					new GenericCheckPipe options.log
				when 'debug'
					new DebugPipe options.log
				else
					throw new Error "Invalid subpipe name: #{name}"
			subpipes.push subpipe

		new MegaPipe options.log, subpipes


exports.PipeFactory = PipeFactory
