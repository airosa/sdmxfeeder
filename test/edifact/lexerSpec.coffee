Lexer = require('../../lib/edifact/lexer').EdifactLexer
testdata = require('./testdata')

describe 'EdifactLexer', ->

	segments = []
	lexer = {}

	callback = (segment) =>
		segments.push segment

	beforeEach ->
		lexer = new Lexer callback
		lexer.tokenize "UNA:+.? '"
		segments = []

	it 'tokenizes segments', ->
		lexer.tokenize "ARR++M:YY:ZZ:199902:610:-7.9:E:C'"
		segments[0].should.eql [['ARR'],[],['M','YY','ZZ','199902','610','-7.9','E','C']]

	it 'tokenizes multiple segments', ->
		lexer.tokenize "ARR++M:YY:ZZ:199902:610:-7.9:E:C'IDE+Z10+UNIT'"
		segments[0].should.eql [['ARR'],[],['M','YY','ZZ','199902','610','-7.9','E','C']]
		segments[1].should.eql [['IDE'],['Z10'],['UNIT']]

	it 'tokenizes multiple segments in multiple parts', ->
		lexer.tokenize 'ARR++M:YY:ZZ:199902:'
		lexer.tokenize "610:-7.9:E:C'IDE+Z10+UNIT'"
		segments[0].should.eql [['ARR'],[],['M','YY','ZZ','199902','610','-7.9','E','C']]
		segments[1].should.eql [['IDE'],['Z10'],['UNIT']]

	it 'tokenizes edifact data', ->
		lexer = new Lexer callback
		lexer.tokenize testdata.testText
		segments[i].should.eql testdata.testArray[i] for i in [0...testdata.testArray.length]
