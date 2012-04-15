
class EDIFACTWriter
	constructor: () ->
	
	arrayToSegment: (arr) ->
		return arr[0][0] + "'" if arr[0][0].substring(0,3) is 'UNA'
		tmp = []
		for i in [0...arr.length]
			tmp.push []
			for j in [0...arr[i].length]
				tmp[i].push arr[i][j].replace /\:|\+/g, '?$&'
		seg = []
		seg.push t.join ':' for t in tmp
		seg.join('+') + "'"
		
exports.EDIFACTWriter = EDIFACTWriter
