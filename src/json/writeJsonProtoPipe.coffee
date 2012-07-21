sdmx = require '../pipe/sdmxPipe'
util = require 'util'


class WriteJsonProtoPipe extends sdmx.SdmxPipe
    constructor: (@log) ->
        @cache = []
        @dimensions = []
        @obsAttributes = []
        #@obsAttributeDefaults = ['A', 'F']
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
        @log.info "cache size #{@cache.length}"
        @buildMessage()

#-------------------------------------------------------------------------------

    buildMessage: ->
        msg = 
            codes: []
            data: []
        obsAttributeDefaults = []
        frameOfReference = null

        @log.info "starting to build the message"

        for dim, i in @dimensions.concat 'obsDimension'
            msg.codes[i] = Object.keys( @codes[dim] ).sort()
        obsDimCodes = msg.codes[ msg.codes.length - 1 ]

        multipliers = calculateIndexMultipliers @dimensions.concat('obsDimension'), @codes
        obsAttributeDefaults = calculateObsAttributeDefaults @cache, @obsAttributes
        @log.info util.inspect( obsAttributeDefaults, true, null)
        frameOfReference = calculateFrameOfReference @cache

        for series in @cache
            index = 0
            for dim, i in @dimensions
                index += msg.codes[i].indexOf( series.seriesKey[dim] ) * multipliers[dim]
        
            for code, i in series.obs.obsDimension
                obsIndex = index + obsDimCodes.indexOf( code )
                value = []
                value.push series.obs.obsValue[i]

                for attr, j in @obsAttributes when series.obs.attributes[attr]?
                    if series.obs.attributes[attr][i] isnt obsAttributeDefaults[j]
                        value[j+1] = series.obs.attributes[attr][i]

                msg.data[obsIndex] = value

        @log.info "starting to stringify json"

        @emitData JSON.stringify msg

        @log.info "finished building the message"


    calculateIndexMultipliers = (dimensions, codes) ->
        multipliers = {}
        reversedDims = dimensions.slice().reverse()
        prev = 1
        for dim in reversedDims
            multipliers[dim] = prev
            prev = Object.keys( codes[dim] ).length * prev
        multipliers


    calculateObsAttributeDefaults = (cache, obsAttributes) ->
        obsAttributeValueCounts = {}
        
        for attr in obsAttributes
            obsAttributeValueCounts[attr] = {}
        
        for series in cache
            for i in [0..series.obs.obsDimension.length-1]
                for attr, j in obsAttributes when series.obs.attributes[attr]?
                    continue unless series.obs.attributes[attr][i]?
                    value = series.obs.attributes[attr][i]
                    if obsAttributeValueCounts[attr][value]?
                        obsAttributeValueCounts[attr][value] += 1
                    else
                        obsAttributeValueCounts[attr][value] = 1
        
        obsAttributeDefaults = []
        for attr of obsAttributeValueCounts
            maxCount = 0
            maxValue = null

            for value, count of obsAttributeValueCounts[attr]
                if maxCount < count 
                    maxValue = value
                    maxCount = count

            obsAttributeDefaults[attr] = maxValue

        obsAttributeDefaults


    calculateFrameOfReference = (cache) ->
        min = null
        max = null

        for series in cache
            for i in [0..series.obs.obsDimension.length-1] when series.obs.obsValue[i]?
                if min?
                    min = series.obs.obsValue[i] if series.obs.obsValue[i] < min
                else 
                    min = series.obs.obsValue[i]

                if max?
                    max = series.obs.obsValue[i] if max < series.obs.obsValue[i]
                else 
                    max = series.obs.obsValue[i]

        console.log min
        console.log max

        min


exports.WriteJsonProtoPipe = WriteJsonProtoPipe
