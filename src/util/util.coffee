_ = require 'underscore'

###
Converts a 2D array into object
###
exports.array2DToObject = ( array ) ->
	tmp = {}
	_.each array, (arr) -> tmp[arr[0]] = arr[1]
	return tmp

###
 * http://stackoverflow.com/questions/2731579/convert-an-xml-schema-date-string-to-a-javascript-date
 *
 * Return a Javascript Date for the given XML Schema date string.  Return
 * null if the date cannot be parsed.
 *
 * Does not know how to parse BC dates or AD dates < 100.
 *
 * Valid examples of input:
 * 2010-04-28T10:46:37.0123456789Z
 * 2010-04-28T10:46:37.37Z
 * 2010-04-28T10:46:37Z
 * 2010-04-28T10:46:37
 * 2010-04-28T10:46:37.012345+05:30
 * 2010-04-28T10:46:37.37-05:30
 * 1776-04-28T10:46:37+05:30
 * 0150-04-28T10:46:37-05:30
###
exports.xmlDateToJavascriptDate = (xmlDate) ->
	# It's times like these you wish Javascript supported multiline regex specs
	re = /^([0-9]{4,})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})(\.[0-9]+)?(Z|([+-])([0-9]{2}):([0-9]{2}))?$/;
	match = xmlDate.match re
	return null if not match

	all = match[0]
	year = match[1];  month = match[2];  day = match[3]
	hour = match[4];  minute = match[5]; second = match[6]
	milli = match[7]
	z_or_offset = match[8];  offset_sign = match[9]
	offset_hour = match[10]; offset_minute = match[11]

	utcDate = new Date( Date.UTC year, month-1, day, hour, minute, second, (milli or 0) )

	if offset_sign  # ended with +xx:xx or -xx:xx as opposed to Z or nothing
		direction = if offset_sign is '+' then 1 else -1
		utcDate.setUTCHours( utcDate.getUTCHours() + (offset_hour * direction) )
		utcDate.setUTCMinutes( utcDate.getUTCMinutes() + (offset_minute * direction) )

	return utcDate
