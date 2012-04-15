
parseFormat = (formatString) ->
	pattern = ///
		^([AN]+)
		([\.]*)
		(\d+)$
	///
	[all, textType, dots, length ] = formatString.match pattern
	format = {}
	format.textType = switch textType
		when 'A' then 'Alpha'
		when 'N' then 'Numeric'
		when 'AN' then 'AlphaNumeric'
	if dots is '..'
		format.maxLength = +length
	else
		format.minLength = format.maxLength = +length
	return format


class EdifactParser
	constructor: (@seg) ->
		@ec = @seg.length
		@cc = 1
		@ep = @cp = 0

	segment: ->
		return @seg

	checkHasMoreElements: ->
		@error "No more elements (#{@ep+1}:#{@ec})" if @ec <= @ep

	checkHasMoreComponents: ->
		@error "No more components (#{@cp+1}:#{@cc})" if @cc <= @cp

	checkNoMoreElements: ->
		@error "Still more elements (#{@ep+1}:#{@ec})" if (@ep+1) < @ec

	checkNoMoreComponents: ->
		@error "Still more components (#{@cp+1}:#{@cc})" if (@cp+1) < @cc

	emptyElement: ->
		@element()
		@error "Element #{@seg[@ep]} is not empty" unless @cc is 0
		return this

	expect: (value) ->
		@error "Expected #{value} but was #{@seg[@ep][@cp]}" unless @verify value
		@cp++
		return this

	read: (spec, key) ->
		@checkHasMoreElements()
		@checkHasMoreComponents()
		spec[key] = @seg[@ep][@cp] if spec? and key?
		@cp++
		return this

	get: ->
		@checkHasMoreElements()
		@checkHasMoreComponents()
		@cp++
		@seg[@ep][@cp-1]

	readMax: (spec, key, count) ->
		@checkHasMoreElements()
		@checkHasMoreComponents()
		last = Math.min @cc, @cp + count
		spec[key] = @seg[@ep].slice( @cp, last ).join('')
		@cp = last
		return this

	element: ->
		@checkHasMoreElements()
		@checkNoMoreComponents()
		@ep++
		@cp = 0
		@cc = @seg[@ep].length
		return this

	moreElements: ->
		return (@ep + 1) < @ec

	moreComponents: ->
		return @cp < @cc

	end: ->
		@checkNoMoreElements()
		@checkNoMoreComponents()
		return this

	expectTag: (tag) ->
		@error "Expected #{tag} but was #{@seg[@ep][@cp]}" unless @seg[@ep][@cp] is tag
		@cp++
		return this

	tag: ->
		return @seg[0][0]

	verify: (value) ->
		@checkHasMoreElements()
		@checkHasMoreComponents()
		return @seg[@ep][@cp] is value;

	next: ->
		return @seg[@ep][@cp]

	error: (msg) ->
		throw new Error "#{msg} in element #{@ep}:#{@ec} component #{@cp}:#{@cc} #{JSON.stringify(@seg)}"

exports.parseFormat = parseFormat
exports.EdifactParser = EdifactParser
