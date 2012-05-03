{ReadSdmxPipe} = require '../pipe/sdmxPipe'
sax = require 'sax'
compactData_v2_0 = require './v2_0/compactData'
genericData_v2_0 = require './v2_0/genericData'
structure_v2_0 = require './v2_0/structure'
genericTimeSeriesData_v2_1 = require './v2_1/genericTimeSeriesData'
structure_v2_1 = require './v2_1/structure'

handlers =
	'http://www.sdmx.org/resources/sdmxml/schemas/v2_1/message':
		GenericTimeSeriesData: genericTimeSeriesData_v2_1
		Structure: structure_v2_1
	'http://www.SDMX.org/resources/SDMXML/schemas/v2_0/message':
		CompactData: compactData_v2_0
		GenericData: genericData_v2_0
		Structure: structure_v2_0
	'http://www.SDMX.org/resources/SDMXML/schemas/v1_0/message':
		GenericData: genericData_v2_0
		CompactData: compactData_v2_0
		Structure: structure_v2_0


class ReadXmlPipe extends ReadSdmxPipe
	constructor: (log, @startDepth = 0) ->
		@spec = {}
		@stringBuffer = ''
		@fst = {}
		@entryActions = {}
		@exitActions = {}
		@guards = {}
		@elementCount = 0
		@pathStack = []
		@attrsStack = []
		@path = ''
		@fullPath = ''
		@rootTag = ''
		@parser = sax.parser true, { trim: true, normalize: true }
		@parser.onopentag = @onopentag
		@parser.onclosetag =  @onclosetag
		@parser.ontext = @ontext
		@parser.onerror = @onerror
		super

	processData: (data) =>
		@parser.write @bufferToStr data


	# Helpers

	parseURN: (urn) ->
		ref = {}
		result = urn.match /^urn:\S*\=(\w+):(\w+)\((\S*)\)\.*(\w*)/
		if result?
			ref.agencyID = result[1]
			if 0 < result[4].length
				ref.maintainableParentID = result[2]
				ref.maintainableParentVersion = result[3]
				ref.id = result[4]
			else
				ref.id = result[2]
				ref.version = result[3]
		ref

	parseTag: (name) ->
		if name.indexOf(':') isnt -1
			return { prefix: name.split(':')[0], localPart: name.split(':')[1] }
		return { localPart: name }

	convertBool: (attrs, attr) ->
		attrs[attr] = attrs[attr] is 'true' if attrs[attr]?

	currentNamespace: (key, level) ->
		level ?= @attrsStack.length - 1
		throw "Undefined namespace #{key}" if level < 0
		return @attrsStack[level][key] if @attrsStack[level][key]?
		@currentNamespace key, level - 1

	nameSpaceForElement: (qualifiedName) ->
		key = 'xmlns' + ( if qualifiedName.prefix? then ':' + qualifiedName.prefix else '' )
		@currentNamespace key

	onRootElement: (qualifiedName, tag) ->
		@rootTag = qualifiedName.localPart
		namespace = @nameSpaceForElement qualifiedName
		throw "No namespace for root element" unless namespace?
		throw "Unexpected namespace #{namespace}" unless handlers[namespace]?
		throw "Unexpected root element #{@rootTag}" unless handlers[namespace][@rootTag]?
		@fst = handlers[namespace][@rootTag].fst
		@entryActions = handlers[namespace][@rootTag].entryActions
		@exitActions = handlers[namespace][@rootTag].exitActions
		@guards = handlers[namespace][@rootTag].guards

	# XML parser callbacks

	onopentag: (tag) =>
		qualifiedName = @parseTag tag.name
		tagName = qualifiedName.localPart
		@pathStack.push tagName
		@attrsStack.push tag.attributes

		if @pathStack.length < @startDepth
			return

		@elementCount += 1
		@path = @pathStack.slice(@startDepth + 1).join('/')
		@fullPath = @pathStack.join('/')

		try
			if @elementCount is 1
				@onRootElement qualifiedName, tag
				return

			if @guards[@path]?
				@guards[@path].call this, tag.attributes

			if @entryActions[@path]?
				@entryActions[@path].call this, tag.attributes
		catch error
			@log.error "XMLReader #{error} on line #{@parser.line + 1}"

	onclosetag: (tag) =>
		qualifiedName = @parseTag tag
		tagName = qualifiedName.localPart
		attrs = @attrsStack.pop()

		if @exitActions[@path]
			@exitActions[@path].call this, attrs

		@pathStack.pop()
		@path = @pathStack.slice(1).join('/')
		@fullPath = @pathStack.join '/'
		@stringBuffer = ''

	ontext: (chars) =>
		@stringBuffer += chars.replace /^\s+|\s+$/g, ''

	onerror: (msg) =>
		@emit 'error', msg
		@log.error "SAXError #{msg}"



exports.ReadXmlPipe = ReadXmlPipe
