sdmx = require '../pipe/sdmxPipe'
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


    getDimRole: (dimID) ->
        dsd = @structures.dataStructureDefinitions[@dsdKey]
        switch dsd.dimensionDescriptor[dimID].type
            when 'timeDimension' then 'time'
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
        attrObj = msg.attribute[attrId]

        attrObj.name = @getAttrName attrId
        attrObj.role = @getAttrRole attrId
        attrObj.mandatory = @getAttrMandatory attrId
        attrObj.code = null
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
            attrObj.code = id: [], index: {}, name: {}
            for code, i in Object.keys( values ).sort()
                attrObj.code.id.push code
                attrObj.code.index[code] = i
                attrObj.code.name[code] = @getAttrCodeName code, attrId

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

        if valCount isnt 0 and valCount < ( attrObj.size / 10 )
            @log.info "Storing #{attrId} in object"
            attrObj.value = {} 
        else
            @log.info "Storing #{attrId} in array"
            attrObj.value = []


    buildAttribute: (attrId, attrObj, data, msg) ->
        attrObj.name = @getAttrName attrId
        attrObj.mandatory = @getAttrMandatory attrId
        attrObj.role = null
        attrObj.code = null
        attrObj.default = null
        attrObj.default = @getAttrDefault attrId, data if attrObj.mandatory

        if attrObj.dimension.length is 0
            for obj in data when obj.attributes[attrId]?
                attrObj.value = obj.attributes[attrId]
                return

        attrObj.size = 1
        for dim in attrObj.dimension
            attrObj.size *= msg.dimension[dim].code.size

        valCount = 0
        for obj in data when obj.attributes[attrId]?
            continue if obj.attributes[attrId] is attrObj.default
            valCount += 1 

        if valCount isnt 0 and valCount < ( attrObj.size / 10 )
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
            prev = msg.dimension[dim].code.size * prev

        for obj in data when obj.attributes[attrId]?
            continue if obj.attributes[attrId] is attrObj.default
            key = obj.seriesKey
            key ?= obj.groupKey
            index = 0
            for dim, i in attrObj.dimension
                index += msg.dimension[dim].code.index[ key[dim] ] * multipliers[dim]
            attrObj.value[index] = obj.attributes[attrId]

        if @attrIsCoded attrId
            attrObj.code = id: [], index: {}, name: {}

            codes = {}
            codes[ attrObj.default ] = null if attrObj.default?
            for i in [0..attrObj.size - 1]
                codes[ attrObj.value[i] ] = null if attrObj.value[i]?

            for code, i in Object.keys( codes ).sort()
                attrObj.code.id.push code
                attrObj.code.index[code] = i
                attrObj.code.name[code] = @getAttrCodeName code, attrId

            attrObj.code.size = attrObj.code.id.length
  

    buildDimension: (dimId, dimObj, cache) ->
        dimObj.name = @getDimName dimId
        dimObj.role = @getDimRole dimId
        dimObj.code = id: [], index: {}, name: {}

        if dimId is cache.obsDimension
            for series in cache.series
                for code in series.obs.obsDimension
                    continue unless code?
                    continue if dimObj.code.name[code]?
                    dimObj.code.name[code] = @getDimCodeName code, dimId, dimObj.role
        else
            for series in cache.series
                code = series.seriesKey[dimId]
                continue unless code?
                continue if dimObj.code.name[code]?
                dimObj.code.name[code] = @getDimCodeName code, dimId, dimObj.role

            for group in cache.groups when group.groupKey?
                code = group.groupKey[dimId]
                continue unless code?
                continue if dimObj.code.name[code]?
                dimObj.code.name[code] = @getDimCodeName code, dimId, dimObj.role

        for code, i in Object.keys( dimObj.code.name ).sort()
            dimObj.code.id[i] = code
            dimObj.code.index[code] = i

        dimObj.code.size = dimObj.code.id.length


    buildMeasure: (measureId, msg, cache) ->
        measureObj = msg.measure[measureId]
        measureObj.value = []
            #name: @getMeasureName measureId

        for series in cache.series
            index = 0
            prev = msg.dimension[@cache.obsDimension].code.size
            for dim, i in msg.dimension.id.slice().reverse()
                continue unless series.seriesKey[dim]?
                codeIndex = msg.dimension[dim].code.index[ series.seriesKey[dim] ]
                codeCount = msg.dimension[dim].code.size
                index += codeIndex * prev
                prev = prev * codeCount
        
            for code, i in series.obs.obsDimension
                obsIndex = index + msg.dimension[@cache.obsDimension].code.index[ code ]

                if typeof series.obs.obsValue[i] isnt 'undefined'
                    if isNaN series.obs.obsValue[i]
                        measureObj.value[obsIndex] = '-'
                    else    
                        measureObj.value[obsIndex] = series.obs.obsValue[i]

                for key, value of series.obs.attributes
                    continue unless value[i]?
                    if value[i] isnt msg.attribute[key].default
                        msg.attribute[key].value[obsIndex] = value[i]

#-------------------------------------------------------------------------------

    buildMessage: () ->
        msg =
            name: @header.name.en
            id: @header.id
            test: @header.test
            prepared: @header.prepared
            measure: null
            dimension:
                id: @getDimIds()
            attribute: null

        @log.info "starting to build data message"

        obsCount = 1
        @log.info "starting to process dimensions"
        for dim, i in msg.dimension.id
            msg.dimension[dim] = {}
            @buildDimension dim, msg.dimension[dim], @cache
            obsCount *= msg.dimension[dim].code.size

        @log.info "starting to process attributes"
        for attr in @attributes
            msg.attribute ?= id: []
            msg.attribute.id.push attr
            msg.attribute[attr] = {}
            attrObj = msg.attribute[attr]
            attrObj.dimension = @getAttrDims attr

            if attrObj.dimension.length is msg.dimension.id.length - 1
                @buildAttribute attr, attrObj, @cache.series, msg
            else
                @buildAttribute attr, attrObj, @cache.groups, msg

        @log.info "starting to process observation level attributes"
        for attr in @obsAttributes
            msg.attribute ?= id: []
            msg.attribute.id.push attr
            msg.attribute[attr] = {}
            msg.attribute[attr].dimension = msg.dimension.id.slice()
            msg.attribute[attr].size = obsCount
            @buildObsAttribute attr, msg, @cache
 
        @log.info "starting to process measures"
        for measureId in ['OBS_VALUE']
            msg.measure ?= id: [], size: obsCount
            msg.measure.id.push measureId
            msg.measure[measureId] = {}
            @buildMeasure measureId, msg, @cache

        @log.info 'starting to produce JSON'
        @emitData JSON.stringify msg, no, 2

        @log.info "finished building the data message"

#-------------------------------------------------------------------------------

exports.WriteJsonProtoPipe = WriteJsonProtoPipe
