
SPACE = 32
DEL = 127
SEMICOLON = 59
EQUAL_SIGN = 61
OPENING_BRACKET = 91
CLOSING_BRACKET = 93
OPENING_PARENTHESIS = 40
CLOSING_PARENTHESIS = 41
DOUBLE_QUOTES = 34
COMMA = 44
HYPHEN = 45


NONE 				= 0
NAME 				= 1
LANGUAGE 			= 2
VARIABLE 			= 3
VARIABLE_STRING 	= 4
VALUE_NAME 			= 5
VALUE_NAME_STRING 	= 6
VALUE_NONE 			= 7
VALUE 				= 8
VALUE_STRING 		= 9
FUNCTION 			= 10
ARGUMENT 			= 11


class PcAxisParser
	constructor: (@log) ->
		@keyword = {}
		@function = {}
		@symbol = NONE
		@token = []
		@atEnd = false
		@parser = @parseMetadata
		@dataArrayMaxLength = 1
		@dataArray = []

#-------------------------------------------------------------------------------

	parse: (data) ->
		@log.debug "#{@constructor.name} parse"
		throw new Error 'PC-Axis file is at end.' if @atEnd
		@parser data


	end: ->
		@log.debug "#{@constructor.name} end"
		throw new Error 'PC-Axis file is not complete.' unless @atEnd

#-------------------------------------------------------------------------------

	onKeyword: ->

	onData: ->

	onDataValue: ->

	onEndOfData: ->

#-------------------------------------------------------------------------------

	saveToken: ->
		return if @token.length is 0
		token = @token.join ''

		switch @symbol
			when NAME
				@keyword.name = token
			when LANGUAGE
				@keyword.language = token
			when VARIABLE
				@keyword.variable = token
			when VALUE_NAME
				@keyword.valueName = token
			when VALUE, VALUE_STRING
				@keyword.value ?= []
				@keyword.value.push token
			when FUNCTION
				@function = {}
				@function.name = token
				@keyword.value ?= []
				@keyword.value.push @function
			when ARGUMENT
				@function.args ?= []
				@function.args.push token

		@token = []


	saveKeyword: ->
		@log.debug "#{@constructor.name} saveKeyword"
		@keyword.value = @keyword.value[0] if @keyword.value?.length is 1
		@onKeyword @keyword
		@keyword = {}
		@symbol = NONE
		@token = []


	saveDataValue: ->
		@log.debug "#{@constructor.name} saveDataValue"
		@dataArray.push if @symbol is VALUE then Number @token.join('') else @token.join ''
		if @dataArray.length is @dataArrayMaxLength
			@onDataValue @dataArray
			@dataArray = []
		@token = []
		@symbol = NONE


	switchToDataParsing: (data, i) ->
		@log.debug "#{@constructor.name} switchToDataParsing"
		@parser = @parseData
		@onData()
		@parseData data, i


	endOfData: ->
		if 0 < @dataArray.length
			@onDataValue @dataArray
		@atEnd = true
		@onEndOfData()

#-------------------------------------------------------------------------------

	parseData: (data, start) ->
		@log.debug "#{@constructor.name} parseData"
		len = data.length
		c = -1
		i = if start? then start else -1

		while (i += 1) < len
			c = data.readUInt8 i
			s = String.fromCharCode c

			switch @symbol
				when NONE
					continue if c <= SPACE or c is DEL or c is COMMA
					switch c
						when DOUBLE_QUOTES
							@symbol = VALUE_STRING
						when SEMICOLON
							@endOfData()
							return
						else
							@symbol = VALUE
							@token.push s
				when VALUE_STRING
					switch c
						when DOUBLE_QUOTES
							@saveDataValue()
							@symbol = NONE
						else
							@token.push s
				when VALUE
					if c <= SPACE or c is DEL or c is COMMA
						@saveDataValue()
						@symbol = NONE
						continue

					switch c
						when SEMICOLON
							@saveDataValue()
							@endOfData()
							return
						else
							@token.push s


	parseMetadata: (data) ->
		@log.debug "#{@constructor.name} parseMetadata"
		len = data.length
		i = c = -1

		while (i += 1) < len
			c = data.readUInt8 i
			s = String.fromCharCode c

			switch @symbol
				when NONE
					continue if c <= SPACE or c is DEL
					@symbol = NAME
					@token.push s
				when NAME
					switch c
						when OPENING_BRACKET
							@saveToken()
							@symbol = LANGUAGE
						when OPENING_PARENTHESIS
							@saveToken()
							@symbol = VARIABLE
						when EQUAL_SIGN
							@saveToken()
							@symbol = VALUE
							if @keyword.name is 'DATA'
								@symbol = NONE
								@switchToDataParsing data, i
								return
						else
							@token.push s
				when LANGUAGE
					switch c
						when CLOSING_BRACKET
							@saveToken()
							@symbol = NAME
						else
							@token.push s
				when VARIABLE
					switch c
						when CLOSING_PARENTHESIS
							@saveToken()
							@symbol = NAME
						when COMMA
							@saveToken()
							@symbol = VALUE_NAME
						when DOUBLE_QUOTES
							@symbol = VARIABLE_STRING
				when VARIABLE_STRING
					switch c
						when DOUBLE_QUOTES
							@symbol = VARIABLE
						else
							@token.push s
				when VALUE_NAME
					switch c
						when CLOSING_PARENTHESIS
							@saveToken()
							@symbol = NAME
						when DOUBLE_QUOTES
							@symbol = VALUE_NAME_STRING
				when VALUE_NAME_STRING
					switch c
						when DOUBLE_QUOTES
							@symbol = VALUE_NAME
						else
							@token.push s
				when VALUE
					continue if c <= SPACE or c is DEL
					switch c
						when COMMA
							@saveToken()
						when DOUBLE_QUOTES
							@symbol = VALUE_STRING
						when SEMICOLON
							@saveToken()
							@saveKeyword()
						when OPENING_PARENTHESIS
							@symbol = FUNCTION
							@saveToken()
							@symbol = ARGUMENT
						else
							@token.push s
				when VALUE_STRING
					switch c
						when DOUBLE_QUOTES
							@symbol = VALUE
						else
							@token.push s
				when ARGUMENT
					continue if c <= SPACE or c is DEL
					switch c
						when DOUBLE_QUOTES
							continue
						when COMMA, HYPHEN
							@saveToken()
						when CLOSING_PARENTHESIS
							@saveToken()
							@symbol = VALUE
						else
							@token.push s

#-------------------------------------------------------------------------------

exports.PcAxisParser = PcAxisParser
