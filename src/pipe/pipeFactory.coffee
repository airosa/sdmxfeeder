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


exports.READ_XML = 0
exports.WRITE_XML = 1
exports.READ_EDI = 2
exports.WRITE_JSON = 3
exports.SUBMIT = 4
exports.CONVERT = 5
exports.CHECK = 6
exports.DEBUG = 7


class PipeFactory
	constructor: ->

	build: (pipes, options) ->
		subpipes = []
		for name in pipes
			subpipes.push @createSubPipe name, options
		new MegaPipe options.log, subpipes


	createSubPipe: (name, options) ->
		throw new Error "Invalid subpipe name: #{name}" unless exports[name]?

		switch exports[name]
			when exports.READ_XML
				new ReadXmlPipe options.log
			when exports.WRITE_XML
				new WriteXmlPipe options.log
			when exports.READ_EDI
				new ReadEdifactPipe options.log
			when exports.WRITE_JSON
				new WriteJsonPipe options.log
			when exports.SUBMIT
				new SubmitToRegistryPipe options.log, options.registry
			when exports.CONVERT
				new ConvertCompactPipe options.log, options.registry
			when exports.CHECK
				new GenericCheckPipe options.log
			when exports.DEBUG
				new DebugPipe options.log


exports.PipeFactory = PipeFactory
