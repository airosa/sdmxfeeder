{PcAxisParser} = require '../../lib/pcaxis/pcAxisParser'
Log = require 'log'
should = require 'should'

describe 'PcAxisParser', ->

	log = {}

	beforeEach ->
		log = new Log Log.INFO, process.stderr

	it 'parses metadata keywords', ->

		runTest = (text,result) ->
			parser = new PcAxisParser log
			keywordParsed = false
			parser.onKeyword = (keyword) ->
				should.exist keyword
				keyword.should.eql result
				keywordParsed = true
			parser.parse new Buffer text, 'utf8'
			keywordParsed.should.be.true

		runTest(
			'CHARSET="ANSI";',
			{name:'CHARSET',value:'ANSI'}
		)
		runTest(
			'SUBJECT-AREA[fi]="Rahoitus ja vakuutus";',
			{name:'SUBJECT-AREA',language:'fi',value:'Rahoitus ja vakuutus'}
		)
		runTest(
			'DOMAIN("geo")="Eurostat";',
			{name:'DOMAIN',variable:'geo',value:'Eurostat'}
		)
		runTest(
			'DOMAIN[fi]("geo")="Eurostat";',
			{name:'DOMAIN',language:'fi',variable:'geo',value:'Eurostat'}
		)
		runTest(
			'CODES("time")="2000","2001","2002","2003";',
			{name:'CODES',variable:'time',value:['2000','2001','2002','2003']}
		)
		runTest(
			'NOTE="First line. " "Second line.";',
			{name:'NOTE',value:'First line. Second line.'}
		)
		runTest(
			'KEYS("county")=CODES;',
			{name:'KEYS',variable:'county',value:'CODES'}
		)
		runTest(
			'TIMEVAL("time")=TLIST(A1),"1990","1991","1992";',
			{name:'TIMEVAL',variable:'time',value:[{name:'TLIST',args:['A1']},'1990','1991','1992']}
		)
		runTest(
			'TIMEVAL("time")=TLIST(A1, "1994" -"1996");',
			{name:'TIMEVAL',variable:'time',value:{name:'TLIST',args:['A1','1994','1996']}}
		)
		runTest(
			'CREATION-DATE="";',
			{name:'CREATION-DATE'}
		)
		runTest(
			'PRECISION("Tunnusluku","Rangaistuksen mediaani")=1;',
			{name:'PRECISION',variable:'Tunnusluku',valueName:'Rangaistuksen mediaani',value:'1'}
		)
		runTest(
			'PRECISION("Tiedot","Indeksi (2005=100)")=1;',
			{name:'PRECISION',variable:'Tiedot',valueName:'Indeksi (2005=100)',value:'1'}
		)



	it 'parses data', ->

		runTest = (text, length, result) ->
			parser = new PcAxisParser log
			values = []
			endOfFile = false
			parser.onData = ->
				parser.dataArrayMaxLength = length
			parser.onDataValue = (data) ->
				should.exist data
				values.push data
			parser.onEndOfData = ->
				values.should.eql result
				endOfFile = true
			parser.parse new Buffer text, 'utf8'
			endOfFile.should.be.true

		runTest 'DATA=2.90;', 1, [ [2.90] ]
		runTest 'DATA=2.90 3.10;', 1, [ [2.90], [3.10] ]
		runTest 'DATA=2.90, 3.10;', 1, [ [2.90], [3.10] ]
		runTest 'DATA=2.90	3.10;', 1, [ [2.90], [3.10] ]
		runTest 'DATA=2.90 "." 3.10;', 1, [ [2.90], ['.'], [3.10] ]
		runTest 'DATA="19","1980","1","30",809 104 140;', 1, [ ['19'], ['1980'], ['1'], ['30'], [809], [104], [140] ]

		runTest 'DATA=2.90 3.10;', 2, [ [2.90, 3.10] ]
		runTest 'DATA=2.90 3.10 ".";', 2, [ [2.90, 3.10], ['.'] ]
		runTest 'DATA=2.90\n3.10;', 2, [ [2.90, 3.10] ]
