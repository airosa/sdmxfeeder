parser = require('../../lib/edifact/parser')
EdifactParser = parser.EdifactParser

describe 'EdifactParser', ->

	it 'can parse edifact formats', ->
		parser.parseFormat('AN1').should.eql { textType: 'AlphaNumeric', minLength: 1, maxLength: 1 }
		parser.parseFormat('AN10').should.eql { textType: 'AlphaNumeric', minLength: 10, maxLength: 10 }
		parser.parseFormat('AN..3').should.eql { textType: 'AlphaNumeric', maxLength: 3 }
		parser.parseFormat('AN..70').should.eql { textType: 'AlphaNumeric', maxLength: 70 }
		parser.parseFormat('A1').should.eql { textType: 'Alpha', minLength: 1, maxLength: 1 }
		parser.parseFormat('N1').should.eql { textType: 'Numeric', minLength: 1, maxLength: 1 }

	it 'parses edifact segments', ->
		p = new EdifactParser [['ARR'],['4'],['','XX','ZZ','CC']]
		p.moreElements().should.be.ok
		p.moreComponents().should.be.ok
		p.expect('ARR').should.be.ok
		p.element()
		p.moreElements().should.be.ok
		p.moreComponents().should.be.ok
		p.next().should.equal '4'
		p.expect('4').should.be.ok
		p.moreElements().should.be.ok
		p.moreComponents().should.not.be.ok
		p.element()
		p.expect('').should.be.ok
		p.get().should.equal 'XX'
		p.expect('ZZ').should.be.ok
		p.expect('CC').should.be.ok
		p.moreElements().should.not.be.ok
		p.moreComponents().should.not.be.ok
		p.end()
