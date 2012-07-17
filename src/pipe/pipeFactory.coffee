{MegaPipe} = require './megaPipe'
{ReadXmlPipe} = require '../xml/readXmlPipe'
{WriteXmlPipe} = require '../xml/writeXmlPipe'
{ReadEdifactPipe} = require '../edifact/readEdifactPipe'
{WriteEdifactPipe} = require '../edifact/writeEdifactPipe'
{WriteJsonPipe} = require '../json/writeJsonPipe'
{WriteJsonProtoPipe} = require '../json/writeJsonProtoPipe'
{SubmitToRegistryPipe} = require '../registry/submitToRegistryPipe'
{ConvertCompactPipe} = require '../transform/convertCompactPipe'
{GenericCheckPipe} = require '../checks/genericCheckPipe'
{DebugPipe} = require '../util/debugPipe'
{ReadPcAxisPipe} = require '../pcaxis/readPcAxisPipe'
{WriteCsvPipe} = require '../csv/writeCsvPipe'
{CompactSeriesPipe} = require '../transform/compactSeriesPipe'
{WriteAtomPipe} = require '../odata/writeAtomPipe'
{DecodingPipe} = require '../transform/decodingPipe'


exports.READ_XML = 0
exports.WRITE_XML = 1
exports.READ_EDI = 2
exports.WRITE_JSON = 3
exports.SUBMIT = 4
exports.CONVERT = 5
exports.CHECK = 6
exports.DEBUG = 7
exports.READ_PX = 8
exports.WRITE_CSV = 9
exports.COMPACT = 10
exports.WRITE_ATOM = 11
exports.DECODE = 12


build = (pipes, options) ->
	subpipes = []
	for name in pipes
		subpipes.push createSubPipe name, options
	new MegaPipe subpipes, options.log


createSubPipe = (name, options) ->
	throw new Error "Invalid subpipe name: #{name}" unless exports[name]?

	switch exports[name]
		when exports.READ_XML
			new ReadXmlPipe options.log
		when exports.WRITE_XML
			new WriteXmlPipe options.log
		when exports.READ_EDI
			new ReadEdifactPipe options.log
		when exports.WRITE_JSON
			new WriteJsonProtoPipe options.log
		when exports.SUBMIT
			new SubmitToRegistryPipe options.log, options.registry
		when exports.CONVERT
			new ConvertCompactPipe options.log, options.registry
		when exports.CHECK
			new GenericCheckPipe options.log
		when exports.DEBUG
			new DebugPipe options.log
		when exports.READ_PX
			new ReadPcAxisPipe options.log
		when exports.WRITE_CSV
			new WriteCsvPipe options.log
		when exports.COMPACT
			new CompactSeriesPipe options.log
		when exports.WRITE_ATOM
			new WriteAtomPipe options.log, options.registry
		when exports.DECODE
			new DecodingPipe options.log, options.registry


exports.build = build
