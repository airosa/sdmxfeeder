sdmx = require '../pipe/sdmxPipe'


class SubmitToRegistryPipe extends sdmx.SdmxPipe
	constructor: (log, @registry) ->
		super


	processData: (sdmxdata) ->
		switch sdmxdata.type
			when sdmx.CODE_LIST, sdmx.CONCEPT_SCHEME, sdmx.DATA_STRUCTURE_DEFINITION
				@pause()
				@registry.submit sdmxdata.data, @submitCallback
		super


	submitCallback: (err) =>
		throw new Error(err) if err?
		@resume()


exports.SubmitToRegistryPipe = SubmitToRegistryPipe
