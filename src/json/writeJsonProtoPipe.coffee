sdmx = require '../pipe/sdmxPipe'
util = require 'util'

class WriteJsonProtoPipe extends sdmx.SdmxPipe
    constructor: (@log) ->
        @cache = []
        @dimensions = []
        @obsAttributes = []
        @obsAttributeDefaults = ['A', 'F']
        @codes = {}
        super


    processData: (data) ->
        @log.debug "#{@constructor.name} processData (default)"
        switch data.type
            when sdmx.SERIES
                if @counters.in.series is 1
                    for dim of data.data.seriesKey
                        @dimensions.push dim
                        @codes[dim] = {}
                    @codes['obsDimension'] = {}
                    for attr of data.data.obs.attributes
                        @obsAttributes.push attr

                for dim in @dimensions
                    @codes[dim][ data.data.seriesKey[dim] ] = null

                for obsDim, i in data.data.obs.obsDimension
                    @codes['obsDimension'][obsDim] = null

                @cache.push data.data


    processEnd: ->
        @log.debug "#{@constructor.name} processEnd"
        #@log.info "cache size #{@cache.length}"
        @buildMessage()

#-------------------------------------------------------------------------------

    buildMessage: ->
        msg = 
            codes: []
            data: []

        for dim, i in @dimensions.concat 'obsDimension'
            msg.codes[i] = Object.keys( @codes[dim] ).sort()
        obsDimCodes = msg.codes[ msg.codes.length - 1 ]

        multipliers = calculateIndexMultipliers @dimensions.concat('obsDimension'), @codes
        #@log.info util.inspect( @obsAttributes, true, null)

        for series in @cache
            index = 0
            for dim, i in @dimensions
                index += msg.codes[i].indexOf( series.seriesKey[dim] ) * multipliers[dim]
        
            for code, i in series.obs.obsDimension
                obsIndex = index + obsDimCodes.indexOf( code )
                value = []
                value.push series.obs.obsValue[i]

                for attr, j in @obsAttributes
                    if series.obs.attributes[attr]?
                        if series.obs.attributes[attr][i] isnt @obsAttributeDefaults[j]
                            value[j+1] = series.obs.attributes[attr][i]

                msg.data[obsIndex] = value

        @emitData JSON.stringify msg


    calculateIndexMultipliers = (dimensions, codes) ->
        multipliers = {}
        reversedDims = dimensions.slice().reverse()
        prev = 1
        for dim in reversedDims
            multipliers[dim] = prev
            prev = Object.keys( codes[dim] ).length * prev
        multipliers




exports.WriteJsonProtoPipe = WriteJsonProtoPipe
