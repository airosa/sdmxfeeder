sdmx = require '../pipe/sdmxPipe'
xmlbuilder = require 'xmlbuilder'


stringifiers =
	toString: (doc) -> doc.toString pretty: true

	series: (doc, series) ->
		obs = []
		obs.push stringifiers.obs(doc, series, i) for t, i in series.obs.obsValue
		obs.join ''

	obs: (doc, series, i) ->
		addProperty = (parent, key, value) ->
			parent.ele("d:#{key}").text value

		entry = doc.begin 'entry'
		entry.ele('id').text 'id'
		entry.ele('title')
		entry.ele('updated').text '1900'
		content = entry.ele('content').att 'type', 'application/xml'
		properties = content.ele 'm:properties'
		for key, value of series.seriesKey
			addProperty properties, key, value
		for key, value of series.attributes
			addProperty properties, key, value
		for key, value of series.obs.attributes
			addProperty properties, key, value[i]
		addProperty properties, 'obsDimension', series.obs.obsDimension[i]
		if isNaN series.obs.obsValue[i]
			properties.ele("d:obsValue").att('m:null','true')
		else
			properties.ele("d:obsValue").att('m:type','Edm.Double').text series.obs.obsValue[i]

		stringifiers.toString doc

#-------------------------------------------------------------------------------

class WriteAtomPipe extends sdmx.WriteSdmxPipe
	constructor: (@log) ->
		@doc = xmlbuilder.create()
		super @log

#-------------------------------------------------------------------------------

	beforeFirst: (type, data) ->
		str = []
		switch type
			when sdmx.HEADER
				str.push '<feed xmlns="http://www.w3.org/2005/Atom"'
				str.push ' xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices"'
				str.push ' xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata">\n'
				str.push @doc.begin( 'id' ).text( data.id ).toString pretty: true
				str.push @doc.begin( 'title' ).text( data.id ).toString pretty: true
				str.push @doc.begin( 'updated' ).text( data.prepared.toISOString() ).toString pretty: true
				@structures = data.structure
			when 'end'
				str.push '</feed>'
		str.join ''


	stringify: (type, data) ->
		if type is sdmx.SERIES
			stringifiers.series @doc, data
		else
			''

#-------------------------------------------------------------------------------

exports.WriteAtomPipe = WriteAtomPipe
