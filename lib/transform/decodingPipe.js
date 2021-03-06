// Generated by CoffeeScript 1.3.3
(function() {
  var DecodingPipe, buildDecoder, decodeCodeValue, decodeConcept, decodeSeries, sdmx,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  sdmx = require('../pipe/sdmxPipe');

  decodeCodeValue = function(key, value, decoder, lang) {
    var _ref, _ref1, _ref2, _ref3;
    return (_ref = (_ref1 = decoder.codelist) != null ? (_ref2 = _ref1[key]) != null ? (_ref3 = _ref2[value]) != null ? _ref3.name[lang] : void 0 : void 0 : void 0) != null ? _ref : value;
  };

  decodeConcept = function(key, decoder, lang) {
    var _ref, _ref1, _ref2;
    return (_ref = (_ref1 = decoder.concept) != null ? (_ref2 = _ref1[key]) != null ? _ref2[lang] : void 0 : void 0) != null ? _ref : key;
  };

  decodeSeries = function(series, decoder, lang) {
    var decodedObsDimension, decodedValues, key, value, values, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3, _results;
    _ref = series.seriesKey;
    for (key in _ref) {
      value = _ref[key];
      series.seriesKey[key] = decodeCodeValue(key, value, decoder, lang);
    }
    decodedObsDimension = [];
    _ref1 = series.obs.obsDimension;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      value = _ref1[_i];
      decodedObsDimension.push(decodeCodeValue(decoder.obsDimension, value, decoder, lang));
    }
    series.obs.obsDimension = decodedObsDimension;
    if (series.attributes != null) {
      _ref2 = series.attributes;
      for (key in _ref2) {
        value = _ref2[key];
        series.attributes[key] = decodeCodeValue(key, value, decoder, lang);
      }
    }
    if (series.obs.attributes != null) {
      _ref3 = series.obs.attributes;
      _results = [];
      for (key in _ref3) {
        values = _ref3[key];
        decodedValues = [];
        for (_j = 0, _len1 = values.length; _j < _len1; _j++) {
          value = values[_j];
          decodedValues.push(decodeCodeValue(key, value, decoder, lang));
        }
        _results.push(series.obs.attributes[key] = decodedValues);
      }
      return _results;
    }
  };

  buildDecoder = function(dsds, conceptSchemes, codelists) {
    var addComponent, decoder, dsd, key, value, _ref, _ref1;
    decoder = {
      concept: {},
      codelist: {}
    };
    dsd = dsds[Object.keys(dsds)[0]];
    addComponent = function(component) {
      var cl, cs, ref, _ref, _ref1;
      ref = component.conceptIdentity.ref;
      cs = conceptSchemes["" + ref.agencyID + ":" + ref.maintainableParentID + "(" + ref.maintainableParentVersion + ")"];
      decoder.concept[key] = cs.concepts[key].name;
      ref = (_ref = component.localRepresentation) != null ? (_ref1 = _ref.enumeration) != null ? _ref1.ref : void 0 : void 0;
      if (ref != null) {
        cl = codelists["" + ref.agencyID + ":" + ref.id + "(" + ref.version + ")"];
        return decoder.codelist[key] = cl.codes;
      }
    };
    _ref = dsd.dimensionDescriptor;
    for (key in _ref) {
      value = _ref[key];
      addComponent(value);
    }
    _ref1 = dsd.attributeDescriptor;
    for (key in _ref1) {
      value = _ref1[key];
      addComponent(value);
    }
    return decoder;
  };

  DecodingPipe = (function(_super) {

    __extends(DecodingPipe, _super);

    function DecodingPipe(log, registry) {
      this.log = log;
      this.registry = registry;
      this.callbackForQuery = __bind(this.callbackForQuery, this);

      this.lang = 'en';
      this.decoder = {};
      this.header = {};
      this.waiting = false;
      DecodingPipe.__super__.constructor.call(this, this.log);
    }

    DecodingPipe.prototype.processData = function(data) {
      var structure;
      this.log.debug("" + this.constructor.name + " processData");
      switch (data.type) {
        case sdmx.HEADER:
          this.header = data.data;
          break;
        case sdmx.DATA_SET_HEADER:
          if (!this.paused) {
            this.pause();
          }
          structure = this.header.structure[data.data.structureRef];
          this.decoder.obsDimension = structure.dimensionAtObservation;
          this.registry.query(sdmx.DATA_STRUCTURE_DEFINITION, structure.structureRef.ref, true, this.callbackForQuery);
          this.waiting = true;
          break;
        case sdmx.SERIES:
          if (!this.waiting) {
            decodeSeries(data.data, this.decoder, this.lang);
          }
      }
      return DecodingPipe.__super__.processData.call(this, data);
    };

    DecodingPipe.prototype.callbackForQuery = function(err, result) {
      var data, _i, _len, _ref;
      this.log.debug("" + this.constructor.name + " callbackForQuery");
      if (result == null) {
        throw new Error('Missing Data Structure Definition');
      }
      this.waiting = false;
      this.decoder = buildDecoder(result.dataStructureDefinitions, result.conceptSchemes, result.codeLists);
      _ref = this.queue.out;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        data = _ref[_i];
        if (data.name === 'data' && data.arg.type === sdmx.SERIES) {
          decodeSeries(data.arg.data, this.decoder, this.lang);
        }
      }
      return this.resume();
    };

    return DecodingPipe;

  })(sdmx.SdmxPipe);

  exports.DecodingPipe = DecodingPipe;

}).call(this);
