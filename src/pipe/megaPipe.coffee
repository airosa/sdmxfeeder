{Stream} = require 'stream'


class MegaPipe extends Stream
	constructor: (@subpipes, @log) ->
		@readable = true
		@writable = true
		@connectSubpipes()
		@wireEvents()

#-------------------------------------------------------------------------------

	write: (data) ->
		@log.debug "#{@constructor.name} write"
		@subpipes[0].write data

	end: ->
		@log.debug "#{@constructor.name} end"
		@subpipes[0].end()

	pause: ->
		@log.debug "#{@constructor.name} pause"
		@subpipes[@subpipes.length-1].pause()

	resume: ->
		@log.debug "#{@constructor.name} resume"
		@subpipes[@subpipes.length-1].resume()

	pump: (source, destination) ->
		throw new Error 'Pump must have source' unless source?
		source.pipe this
		@pipe destination if destination?

#-------------------------------------------------------------------------------

	onData: (data) =>
		@log.debug "#{@constructor.name} onData"
		@emit 'data', data

	onEnd: =>
		@log.debug "#{@constructor.name} onEnd"
		@cleanup()
		@emit 'end'

	onError: (err) =>
		@log.debug "#{@constructor.name} onError"
		@cleanup()
		if @listeners('error').length is 0
			throw err
		else
			@emit 'error', err

	onDrain: =>
		@log.debug "#{@constructor.name} onDrain"
		@emit 'drain'

#-------------------------------------------------------------------------------

	connectSubpipes: ->
		@log.debug "#{@constructor.name} connectSubpipes"
		for subpipe, n in @subpipes when n < (@subpipes.length - 1)
			subpipe.pipe @subpipes[n+1]


	wireEvents: ->
		@log.debug "#{@constructor.name} wireEvents"
		for subpipe in @subpipes
			subpipe.on 'error', @onError
		@subpipes[0].on 'drain', @onDrain
		@subpipes[@subpipes.length-1].on 'data', @onData
		@subpipes[@subpipes.length-1].on 'end', @onEnd


	cleanup: ->
		@log.debug "#{@constructor.name} cleanup"
		for subpipe in @subpipes
			subpipe.removeListener 'error', @onError
		@subpipes[0].removeListener 'drain', @onDrain
		@subpipes[@subpipes.length-1].removeListener 'data', @onData
		@subpipes[@subpipes.length-1].removeListener 'end', @onEnd


exports.MegaPipe = MegaPipe
