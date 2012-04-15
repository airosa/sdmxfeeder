{StringToSDMXStream} = require '../sdmxStream'
{EdifactParser} = require './parser'
{EdifactLexer} = require './lexer'
actions = require './actions'


class EDIFACTReader extends StringToSDMXStream
	constructor: (log, stream) ->
		@lexer = new EdifactLexer @onSegment
		@stream = {}
		@pathStack = []
		@path = ''
		@segmentCount = 0
		@messageCount = 0
		@tooManyErrors = false
		@helper = {}
		@messageBegin = {}
		@codelist = {}
		@conceptScheme = {}
		@dsd = {}
		@component = {}
		@dataSetBegin = {}
		@header = {}
		@series = {}
		@attributes = {}
		super

	write: (data) =>
		@lexer.tokenize data
		super

	onSegment: (seg) =>
		parser = new EdifactParser(seg)
		tagName = parser.tag()
		@segmentCount += 1

		@pathStack.push tagName
		path = @pathStack.join '/'

		#try
		if actions.fst[path]
			actions.guards[path].call this, parser if actions.guards[path]?
			actions.entryActions[path].call this, parser, {} if actions.entryActions[path]?
			return

		while 1 < @pathStack.length
			@pathStack.pop()
			path = @pathStack.join '/'
			actions.exitActions[path].call this, {} if actions.exitActions[path]?
			@pathStack.pop()
			@pathStack.push tagName
			path = @pathStack.join '/'

			if actions.fst[path]
				actions.guards[path].call this, parser if actions.guards[path]?
				actions.entryActions[path].call this, parser, {} if actions.entryActions[path]?
				return

		@log.error "Invalid tag #{tagName} in segment #{seg}"


exports.EDIFACTReader = EDIFACTReader
