require 'datejs'


fromEdifactTimeValue = (format, value, begin = true) ->
	switch format
		when '102' then new GregorianTimePeriod 'GD', +value[0..3], +value[4..5], +value[6..7]
		when '602' then new GregorianTimePeriod 'GY', +value, 1, 1
		when '604' then new ReportingTimePeriod 'S', +value[0..3], +value[4..4]
		when '608' then new ReportingTimePeriod 'Q', +value[0..3], +value[4..4]
		when '610' then new GregorianTimePeriod 'GTM', +value[0..3], +value[4..5], 1
		when '616' then new ReportingTimePeriod 'W', +value[0..3], +value[4..5]
		when '702' then fromEdifactTimeValue '602', (if begin then value[0..3] else value[5..8] ) 
		when '704' then fromEdifactTimeValue '604', (if begin then value[0..4] else value[6..10] )
		when '708' then fromEdifactTimeValue '608', (if begin then value[0..4] else value[6..10] )
		when '710' then fromEdifactTimeValue '610', (if begin then value[0..5] else value[7..12] )
		when '711' then fromEdifactTimeValue '102', (if begin then value[0..7] else value[9..16] )
		when '716' then fromEdifactTimeValue '616', (if begin then value[0..5] else value[7..12] )
		when '201'
			century = if +value[0..1] < 49 then '20' else '19'
			year = value[0..1]
			month = value[2..3]
			day = value[4..5]
			hour = value[6..7]
			min = value[8..9]
			new DistinctTimePeriod "#{century}#{year}-#{month}-#{day}T#{hour}:#{min}:00"
		when '203'
			year = value[0..3]
			month = value[4..5]
			day = value[6..7]
			hour = value[8..9]
			min = value[10..11]
			new DistinctTimePeriod "#{year}-#{month}-#{day}T#{hour}:#{min}:00"
			

fromTimeValue = (value) ->
	switch value.length
		when 4
			new GregorianTimePeriod 'GY', +value, 1, 1
		when 7
			switch value[5..5]
				when 'A', 'S', 'T', 'Q'
					new ReportingTimePeriod value[5..5], +value[0..3], +value[6..]
				else	
					new GregorianTimePeriod 'GTM', +value[0..3], +value[5..6], 1
		when 8, 9
			new ReportingTimePeriod value[5..5], +value[0..3], +value[6..]
		when 10
			new GregorianTimePeriod 'GD', +value[0..3], +value[5..6], +value[8..9]
		when 19
			new DistinctTimePeriod value


class GregorianTimePeriod
	constructor: (@format, year, month, day) ->
		@date = new Date Date.UTC(year,month-1,day,0,0,0)
	
	next: ->
		switch @format
			when 'GY' then @date.addYears 1
			when 'GTM' then @date.addMonths 1
			when 'GD' then @date.addDays 1
		this
	
	toString: ->
		switch @format
			when 'GY' then @date.toString 'yyyy'
			when 'GTM' then @date.toString 'yyyy-MM'
			when 'GD' then @date.toString 'yyyy-MM-dd'
			
	toDate: -> @date

			
class ReportingTimePeriod
	constructor: (@frequency, @year, @period) ->
	
	limitPerYear: ->
		switch @frequency
			when 'A' then 1
			when 'S' then 2
			when 'T' then 3
			when 'Q' then 4
			when 'M' then 12
			when 'W' then +(new Date Date.UTC(@year,11,28)).getISOWeek()
			when 'D' then ( if Date.isLeapYear @year then 366 else 365 )
	
	next: ->
		limit = @limitPerYear()
		@year += ( if @period is limit then 1 else 0 )
		@period = ( if @period is limit then 1 else @period + 1 )
		this
	
	paddedPeriod: ->
		str = '' + @period
		pad = switch @frequency
			when 'A','S','T','Q' then '0'
			when 'M', 'W' then '00'
			when 'D' then '000'
		pad.substr(0, pad.length - str.length) + str
	
	toString: -> "#{@year}-#{@frequency}#{@paddedPeriod()}"
	
	toDate: -> 
		date = new Date Date.UTC(year,0,1,0,0,0)
		switch @frequency
			when 'A' then date
			when 'S' then date.addMonths 6 * (@period-1)
			when 'T' then date.addMonths 4 * (@period-1)
			when 'Q' then date.addMonths 3 * (@period-1)
			when 'M' then date.addMonths @period - 1
			when 'W' then date.addWeeks @period - 1
			when 'D' then date.addDays @period - 1


class DistinctTimePeriod
	constructor: (value) ->
		@date = Date.parse value, 'yyyy-MM-ddTHH:mm:ss'

	next: -> this
		
	toString: -> @date.toString 'yyyy-MM-ddTHH:mm:ss'

	toDate: -> @date

exports.fromTimeValue = fromTimeValue
exports.fromEdifactTimeValue = fromEdifactTimeValue
