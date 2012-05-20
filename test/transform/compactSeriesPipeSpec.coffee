helpers = require '../pipeTestHelper'
sdmx = require '../../lib/pipe/sdmxPipe'


describe 'CompactSeriesPipe', ->

	it 'removes leading missing observations from series', (done) ->

		before =
			type: sdmx.SERIES
			data:
				seriesKey:
					A: 'A'
					B: 'B'
				obs:
					obsValue: [ NaN, 1 ]
					obsDimension: [ '2000', '2001' ]
					attributes:
						OBS_STATUS: [ 'M', 'A' ]

		after =
			type: sdmx.SERIES
			data:
				seriesKey:
					A: 'A'
					B: 'B'
				obs:
					obsValue: [ 1 ]
					obsDimension: [ '2001' ]
					attributes:
						OBS_STATUS: [ 'A' ]

		helpers.runTest [ 'COMPACT' ], [ before ], [ after ], done


	it 'removes trailing missing observations from series', (done) ->

		before =
			type: sdmx.SERIES
			data:
				seriesKey:
					A: 'A'
					B: 'B'
				obs:
					obsValue: [ 1, NaN ]
					obsDimension: [ '2000', '2001' ]
					attributes:
						OBS_STATUS: [ 'A', 'M' ]

		after =
			type: sdmx.SERIES
			data:
				seriesKey:
					A: 'A'
					B: 'B'
				obs:
					obsValue: [ 1 ]
					obsDimension: [ '2000' ]
					attributes:
						OBS_STATUS: [ 'A' ]

		helpers.runTest [ 'COMPACT' ], [ before ], [ after ], done


	it 'removes leading and trailing missing observations from series', (done) ->

		before =
			type: sdmx.SERIES
			data:
				seriesKey:
					A: 'A'
					B: 'B'
				obs:
					obsValue: [ NaN, 1, 2, NaN ]
					obsDimension: [ '1999', '2000', '2001', '2002' ]
					attributes:
						OBS_STATUS: [ 'M', 'A', 'A', 'M' ]

		after =
			type: sdmx.SERIES
			data:
				seriesKey:
					A: 'A'
					B: 'B'
				obs:
					obsValue: [ 1, 2 ]
					obsDimension: [ '2000', '2001' ]
					attributes:
						OBS_STATUS: [ 'A', 'A' ]

		helpers.runTest [ 'COMPACT' ], [ before ], [ after ], done



	it 'removes series with all missing observations', (done) ->

		before =
			type: sdmx.SERIES
			data:
				seriesKey:
					A: 'A'
					B: 'B'
				obs:
					obsValue: [ NaN, NaN ]
					obsDimension: [ '1999', '2000' ]
					attributes:
						OBS_STATUS: [ 'M', 'M' ]

		helpers.runTest [ 'COMPACT' ], [ before ], [], done
