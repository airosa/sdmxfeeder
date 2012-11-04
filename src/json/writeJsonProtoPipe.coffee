sdmx = require '../pipe/sdmxPipe'
time = require '../util/time'
util = require 'util'

#-------------------------------------------------------------------------------

class WriteJsonProtoPipe extends sdmx.SdmxPipe
    constructor: (@log, @registry) ->
        @cache = series: [], groups: []

        @attributes = {}
        @obsAttributes = {}
        @obsAttrValues = {}
        @codes = {}
        @structures = {}
        @dsdKey

        @header = {}
        @waiting = false

        super


    processData: (data) ->
        @log.debug "#{@constructor.name} processData (default)"
        switch data.type
            when sdmx.HEADER
                @header = data.data
            when sdmx.DATA_SET_HEADER
                @pause() unless @paused
                structure = @header.structure[data.data.structureRef]
                ref = structure.structureRef.ref
                @dsdKey = "#{ref.agencyID}:#{ref.id}(#{ref.version})"
                @cache.obsDimension = structure.dimensionAtObservation
                @cache.obsDimension ?= 'TIME_PERIOD'
                @registry.query sdmx.DATA_STRUCTURE_DEFINITION, ref, true, @callbackForQuery
                @waiting = true
            when sdmx.SERIES
                for attr of data.data.attributes
                    @attributes[attr] = null

                for attr of data.data.obs.attributes
                    @obsAttributes[attr] = null

                for dim of data.data.seriesKey
                    @codes[dim] ?= {}
                    @codes[dim][ data.data.seriesKey[dim] ] = null

                for obsDim, i in data.data.obs.obsDimension
                    @codes[@cache.obsDimension] ?= {}
                    @codes[@cache.obsDimension][obsDim] = null
 
                @cache.series.push data.data
            when sdmx.ATTRIBUTE_GROUP
                for attr of data.data.attributes
                    @attributes ?= {}
                    @attributes[attr] = null

                @cache.groups.push data.data
            when sdmx.DATA_SET_ATTRIBUTES
                for attr of data.data.attributes
                    @attributes ?= {}
                    @attributes[attr] = null

                @cache.groups.push data.data


    processEnd: ->
        @log.debug "#{@constructor.name} processEnd"
        @log.info "cache size #{@cache.series.length}"
        @attributes = Object.keys( @attributes ).sort()
        @obsAttributes = Object.keys( @obsAttributes ).sort()
        @buildMessage() unless @waiting

#-------------------------------------------------------------------------------

    callbackForQuery: (err, result) =>
        @log.debug "#{@constructor.name} callbackForQuery"
        throw new Error 'Missing Data Structure Definition' unless result?
        @waiting = false
        @structures = result
        @obsAttrValues = @getCodedAttrs()
        @buildMessage() unless @writable
        @resume()

#-------------------------------------------------------------------------------

    getCodedAttrs: () ->
        result = {}
        dsd = @structures.dataStructureDefinitions[@dsdKey]
        for key, attr of dsd.attributeDescriptor
            continue unless attr?.localRepresentation?.enumeration?
            result[key] = {}
        result


    getDimIds: () ->
        ids = []
        dsd = @structures.dataStructureDefinitions[@dsdKey]
        for dim of dsd.dimensionDescriptor
            ids.push dim
        ids


    getDimName: ( dimID ) ->
        dsd = @structures.dataStructureDefinitions[@dsdKey]
        ref = dsd.dimensionDescriptor[dimID].conceptIdentity.ref
        conceptSchemeKey = "#{ref.agencyID}:#{ref.maintainableParentID}(#{ref.maintainableParentVersion})"
        conceptScheme = @structures.conceptSchemes[conceptSchemeKey]
        concept = conceptScheme.concepts[ref.id]
        concept.name.en


    getAttrName: ( attrId ) ->
        dsd = @structures.dataStructureDefinitions[@dsdKey]
        ref = dsd.attributeDescriptor[ attrId ].conceptIdentity.ref
        conceptSchemeKey = "#{ref.agencyID}:#{ref.maintainableParentID}(#{ref.maintainableParentVersion})"
        conceptScheme = @structures.conceptSchemes[conceptSchemeKey]
        concept = conceptScheme.concepts[ref.id]
        concept.name.en


    getAttrDims: ( attrId ) ->
        dims = []
        dsd = @structures.dataStructureDefinitions[@dsdKey]
        rel = dsd.attributeDescriptor[ attrId ].attributeRelationship
        return rel.dimensions if rel?.dimensions?
        dims


    getDimType: (dimID) ->
        dsd = @structures.dataStructureDefinitions[@dsdKey]
        switch dsd.dimensionDescriptor[dimID].type
            when 'timeDimension' then 'time'
            when 'measureDimension' then 'measure'
            else null


    getAttrRole: (attrId) ->
        return null


    getAttrMandatory: (attrId) ->
        dsd = @structures.dataStructureDefinitions[@dsdKey]
        dsd.attributeDescriptor[attrId].assignmentStatus is 'Mandatory'


    getDimCodeName: ( code, dimID, dimRole ) ->
        dsd = @structures.dataStructureDefinitions[@dsdKey]
        switch dimRole
            when 'time' then code
            else 
                ref = dsd.dimensionDescriptor[dimID].localRepresentation.enumeration.ref
                key = "#{ref.agencyID}:#{ref.id}(#{ref.version})"
                cl = @structures.codeLists[key]
                cl.codes[code].name.en


    getAttrCodeName: ( code, attrId ) ->
        dsd = @structures.dataStructureDefinitions[@dsdKey]
        ref = dsd.attributeDescriptor[attrId].localRepresentation.enumeration.ref
        key = "#{ref.agencyID}:#{ref.id}(#{ref.version})"
        cl = @structures.codeLists[key]
        cl.codes[code].name.en


    attrIsCoded: ( attrId ) ->
        dsd = @structures.dataStructureDefinitions[@dsdKey]
        dsd.attributeDescriptor[attrId]?.localRepresentation?.enumeration?.ref?


    getMeasureName: ( measureId ) ->
        dsd = @structures.dataStructureDefinitions[@dsdKey]
        ref = dsd.measureDescriptor.primaryMeasure.conceptIdentity.ref     
        conceptSchemeKey = "#{ref.agencyID}:#{ref.maintainableParentID}(#{ref.maintainableParentVersion})"
        conceptScheme = @structures.conceptSchemes[conceptSchemeKey]
        concept = conceptScheme.concepts[ref.id]
        concept.name.en


    getAttrDefault: (attrId, data) ->
        values = {}

        for obj in data
            if obj.attributes[attrId]?
                values[ obj.attributes[attrId] ] ?= 0 
                values[ obj.attributes[attrId] ] += 1

        maxCount = 0
        maxValue = null

        for value, count of values
            if maxCount < count 
                maxValue = value
                maxCount = count

        return null if maxCount <= 10
        maxValue

#-------------------------------------------------------------------------------

    buildObsAttribute: (attrId, msg, cache) ->
        attrObj = msg.attributes[attrId]

        attrObj.id = attrId
        attrObj.name = @getAttrName attrId
        attrObj.role = @getAttrRole attrId
        attrObj.mandatory = @getAttrMandatory attrId
        attrObj.codes = null
        attrObj.default = null

        values = {}
        for series in cache.series
            continue unless series.obs.attributes[attrId]?
            for val, i in series.obs.obsDimension
                value = series.obs.attributes[attrId][i]
                continue unless value?
                values[ value ] ?= 0
                values[ value ] += 1

        if @attrIsCoded attrId
            attrObj.codes = id: []
            for code, i in Object.keys( values ).sort()
                attrObj.codes.id[i] = code
                attrObj.codes[code] =
                    id: code
                    index: i
                    name: @getAttrCodeName code, attrId

        if attrObj.mandatory
            maxCount = 0
            maxValue = null

            for value, count of values
                if maxCount < count 
                    maxValue = value
                    maxCount = count

            attrObj.default = maxValue if 10 <= maxCount

        valCount = 0
        valCount += count for value, count of values
        valCount -= values[ attrObj.default ] if attrObj.default?

        size = 1
        for dim in attrObj.dimension
            size *= msg.dimensions[dim].codes.id.length

        if valCount isnt 0 and valCount < ( size / 10 )
            @log.info "Storing #{attrId} in object"
            attrObj.value = {} 
        else
            @log.info "Storing #{attrId} in array"
            attrObj.value = []


    buildAttribute: (attrId, attrObj, data, msg) ->
        attrObj.id = attrId
        attrObj.name = @getAttrName attrId
        attrObj.mandatory = @getAttrMandatory attrId
        attrObj.role = null
        attrObj.codes = null
        attrObj.default = null
        attrObj.default = @getAttrDefault attrId, data if attrObj.mandatory

        if attrObj.dimension.length is 0
            for obj in data when obj.attributes[attrId]?
                attrObj.value = obj.attributes[attrId]
                return

        size = 1
        for dim in attrObj.dimension
            size *= msg.dimensions[dim].codes.id.length

        valCount = 0
        for obj in data when obj.attributes[attrId]?
            continue if obj.attributes[attrId] is attrObj.default
            valCount += 1 

        if valCount isnt 0 and valCount < ( size / 10 )
            @log.info "Storing #{attrId} in object"
            attrObj.value = {} 
        else
            @log.info "Storing #{attrId} in array"
            attrObj.value = []

        multipliers = {}
        reversedDims = attrObj.dimension.slice().reverse()
        prev = 1
        for dim in reversedDims
            multipliers[dim] = prev
            prev *= msg.dimensions[dim].codes.id.length

        for obj in data when obj.attributes[attrId]?
            continue if obj.attributes[attrId] is attrObj.default
            key = obj.seriesKey
            key ?= obj.groupKey
            index = 0
            for dim, i in attrObj.dimension
                index += msg.dimensions[dim].codes[ key[dim] ].index * multipliers[dim]
            attrObj.value[index] = obj.attributes[attrId]

        if @attrIsCoded attrId
            attrObj.codes = id: []

            codes = {}
            codes[ attrObj.default ] = null if attrObj.default?
            for i in [0..attrObj.size - 1]
                codes[ attrObj.value[i] ] = null if attrObj.value[i]?

            for code, i in Object.keys( codes ).sort()
                attrObj.codes.id.push code
                attrObj.codes[code] =
                    id: code
                    index: i
                    name: @getAttrCodeName code, attrId
  

    buildDimension: (dimId, dimObj, cache) ->
        dimObj.id = dimId
        dimObj.name = @getDimName dimId
        dimObj.type = @getDimType dimId
        dimObj.role = null
        dimObj.codes = id: []

        codes = {}
        if dimId is cache.obsDimension
            for series in cache.series
                for code in series.obs.obsDimension
                    continue unless code?
                    codes[code] = null
        else
            for series in cache.series
                code = series.seriesKey[dimId]
                continue unless code?
                codes[code] = null

            for group in cache.groups when group.groupKey?
                code = group.groupKey[dimId]
                continue unless code?
                codes[code] = null

        for code, i in Object.keys( codes ).sort()
            dimObj.codes.id[i] = code
            dimObj.codes[code] =
                id: code
                name: @getDimCodeName code, dimId, dimObj.type
                index: i

        if dimObj.type is 'time'
            for code in dimObj.codes.id
                dimObj.codes[code].start = time.parseDate dimObj.codes[code].id, false
                date = time.parseDate code, false
                dimObj.codes[code].end = time.parseDate code, true


    buildMeasure: (measureId, msg, cache) ->
        for series in cache.series
            index = 0
            prev = msg.dimensions[@cache.obsDimension].codes.id.length
            for dim, i in msg.dimensions.id.slice().reverse()
                continue unless series.seriesKey[dim]?
                codeIndex = msg.dimensions[dim].codes[ series.seriesKey[dim] ].index
                codeCount = msg.dimensions[dim].codes.id.length
                index += codeIndex * prev
                prev *= codeCount
        
            # loop over each value in the obsDimension (normally TIME_PERIOD) array
            for code, i in series.obs.obsDimension
                obsIndex = index + msg.dimensions[@cache.obsDimension].codes[ code ].index

                if typeof series.obs.obsValue[i] isnt 'undefined'
                    if isNaN series.obs.obsValue[i]
                        msg.measure[obsIndex] = '-'
                    else    
                        msg.measure[obsIndex] = series.obs.obsValue[i]

                for key, value of series.obs.attributes
                    continue unless value[i]?
                    if value[i] isnt msg.attributes[key].default
                        msg.attributes[key].value[obsIndex] = value[i]

#-------------------------------------------------------------------------------

    buildMessage: () ->
        msg =
            'sdmx-proto-json': '2012-09-13'
            name: @header.name.en
            id: @header.id
            test: @header.test
            prepared: @header.prepared
            measure: []
            dimensions:
                id: @getDimIds()
                size: []
                dimensionAtObservation: 'AllDimensions'
            attributes: null

        @log.info "starting to build data message"

        obsCount = 1
        @log.info "starting to process dimensions"
        for dim, i in msg.dimensions.id
            msg.dimensions[dim] = {}
            @buildDimension dim, msg.dimensions[dim], @cache
            obsCount *= msg.dimensions[dim].codes.id.length
            msg.dimensions.size[i] = msg.dimensions[dim].codes.id.length

        @log.info "starting to process attributes"
        for attr in @attributes
            msg.attributes ?= id: []
            msg.attributes.id.push attr
            msg.attributes[attr] = {}
            attrObj = msg.attributes[attr]
            attrObj.dimension = @getAttrDims attr

            if attrObj.dimension.length is msg.dimensions.id.length - 1
                @buildAttribute attr, attrObj, @cache.series, msg
            else
                @buildAttribute attr, attrObj, @cache.groups, msg

        @log.info "starting to process observation level attributes"
        for attr in @obsAttributes
            msg.attributes ?= id: []
            msg.attributes.id.push attr
            msg.attributes[attr] = {}
            msg.attributes[attr].dimension = msg.dimensions.id.slice()
            @buildObsAttribute attr, msg, @cache
 
        @log.info "starting to process measures"
        @buildMeasure 'OBS_VALUE', msg, @cache

        @log.info 'starting to produce JSON'
        @emitData JSON.stringify msg, no, 2

        @log.info "finished building the data message"

#-------------------------------------------------------------------------------

exports.WriteJsonProtoPipe = WriteJsonProtoPipe
