
SEGMENT_TERMINATOR = 39
SPACE = 32
DEL = 127
RELEASE_INDICATOR = 63
COMPONENT_SEPARATOR = 58
DATA_ELEMENT_SEPARATOR = 43


class EdifactLexer
	constructor: (@callback) ->
		@segmentCount = 0
		@segment = [[]]
		@string = []
		@elementPos = @componentPos = @pos = @segmentCount = 0


	tokenize: (data) ->
		len = data.length
		i = c = 0
		released = false

		while (c = data.charCodeAt(i++))
			@segmentCount += 1 if c is SEGMENT_TERMINATOR

			if 127 < c
				continue

			if c < SPACE or c is DEL
				continue

			if @segmentCount is 0
				@string[@pos++] = String.fromCharCode c
				continue

			if c is SPACE and @pos is 0
				continue

			if released
				@string[@pos++] = String.fromCharCode c
				released = false
				continue

			if c is RELEASE_INDICATOR
				released = true
				continue

			if c is SEGMENT_TERMINATOR or c is DATA_ELEMENT_SEPARATOR or c is COMPONENT_SEPARATOR
				@segment[@elementPos][@componentPos] = @string.join('') unless @string.length is 0
				@segment[@elementPos][@componentPos] = '' if @string.length is 0 and c is COMPONENT_SEPARATOR
				@string = []
				@pos = 0

			if c is SEGMENT_TERMINATOR
				@callback @segment
				@segment = [[]]
				@elementPos = @componentPos = 0
				continue

			if c is DATA_ELEMENT_SEPARATOR
				@elementPos++
				@segment[@elementPos] = []
				@componentPos = 0
				continue

			if c is COMPONENT_SEPARATOR
				@componentPos++
				continue

			@string[@pos++] = String.fromCharCode c

exports.EdifactLexer = EdifactLexer
