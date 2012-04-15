time = require '../../lib/util/time'

describe 'timePeriodFromTimeValue', ->

	testIncrement = (original, incremented) ->
		period = time.fromTimeValue original
		period.next()
		period.toString().should.equal incremented

	testIncrementFromEdifact = (format, original, incremented) ->
		period = time.fromEdifactTimeValue format, original
		period.next()
		period.toString().should.equal incremented

	testIncrementFromEdifactRange = (format, original, begin, incremented) ->
		period = time.fromEdifactTimeValue format, original, begin
		period.next()
		period.toString().should.equal incremented

	it 'increments periods', ->
		testIncrement '2011', '2012'
		testIncrement '2011-12', '2012-01'
		testIncrement '2011-12-31', '2012-01-01'
		testIncrement '2011-A1', '2012-A1'
		testIncrement '2011-S2', '2012-S1'
		testIncrement '2011-T3', '2012-T1'
		testIncrement '2011-Q4', '2012-Q1'
		testIncrement '2011-M12', '2012-M01'
		testIncrement '2011-W52', '2012-W01'
		testIncrement '2011-D365', '2012-D001'

	it 'converts and increments edifact periods', ->
		testIncrementFromEdifact '102', '20111231', '2012-01-01'
		testIncrementFromEdifact '201', '1112312359', '2011-12-31T23:59:00'
		testIncrementFromEdifact '203', '200008091923', '2000-08-09T19:23:00'
		testIncrementFromEdifact '602', '2011', '2012'
		testIncrementFromEdifact '604', '20112', '2012-S1'
		testIncrementFromEdifact '608', '20114', '2012-Q1'
		testIncrementFromEdifact '610', '201112', '2012-01'
		testIncrementFromEdifact '616', '201152', '2012-W01'

	it 'converts and increments edifact period ranges', ->
		testIncrementFromEdifactRange '702', '2011-2012', true, '2012'
		testIncrementFromEdifactRange '702', '2011-2012', false, '2013'
