// Generated by CoffeeScript 1.3.3
(function() {
  var ARRAY_CELL, ATTACHMENT_LEVEL, ATTRIBUTE, DATA, DATASET, DATASETLIST, DEFINITIONS, DIMENSION, FREQUENCY, OBSERVATION, REPRESENTATION, SIBLING_GROUP, TIME, TIMESERIES, USAGE_STATUS, entryActions, exitActions, guards, parseFormat, processDescription, sdmx, time, _;

  parseFormat = require('./parser').parseFormat;

  _ = require('underscore');

  time = require('../util/time');

  sdmx = require('../pipe/sdmxPipe');

  DEFINITIONS = '73';

  DATA = '74';

  DATASETLIST = 'DSL';

  TIME = '1';

  ARRAY_CELL = '3';

  FREQUENCY = '13';

  DIMENSION = '4';

  ATTRIBUTE = 'Z09';

  DATASET = '1';

  TIMESERIES = '4';

  OBSERVATION = '5';

  SIBLING_GROUP = '9';

  REPRESENTATION = '5';

  USAGE_STATUS = '35';

  ATTACHMENT_LEVEL = '32';

  processDescription = function(p, spec) {
    p.expect('FTX').element().expect('ACM');
    if (p.moreElements()) {
      p.emptyElement().emptyElement().element().read(spec, 'description');
      while (p.moreComponents()) {
        p.read(spec, 'description');
      }
    }
    return p.end();
  };

  guards = {};

  entryActions = {
    'UNA:+.? ': function() {},
    'UNB': function(p, spec) {
      p.expect('UNB').element().expect('UNOC').expect('3').element().read(spec, 'sender').element().read(spec, 'receiver').element().read(spec, 'date').read(spec, 'time').element().read(spec, 'iref').emptyElement().element().read(spec, 'type');
      spec.isTest = false;
      if (p.moreElements()) {
        p.emptyElement().emptyElement().emptyElement().element().expect('1');
        spec.isTest = true;
      }
      p.end();
      this.header = {};
      if (spec.iref != null) {
        this.header.id = spec.iref;
      }
      this.header.test = spec.isTest != null ? spec.isTest : false;
      if ((spec.date != null) && (spec.time != null)) {
        this.header.prepared = time.fromEdifactTimeValue('201', "" + spec.date + spec.time).toDate();
      }
      return this.helper.iref = spec.iref;
    },
    'UNB/UNH': function(p, spec) {
      return p.expectTag('UNH').element().read(spec, 'mref').element().expect('GESMES').expect('2').expect('1').expect('E6').end();
    },
    'UNB/UNH/BGM': function(p, spec) {
      p.expect('BGM').element().read(spec, 'messageFunction').end();
      this.helper.messageFunction = spec.messageFunction;
      return this.messageCount += 1;
    },
    'UNB/UNH/BGM/NAD': function(p, spec) {
      p.expect('NAD').element();
      switch (p.next()) {
        case 'Z02':
          p.expect('Z02').element().read(spec, 'maintenanceAgency').end();
          break;
        case 'MR':
          p.expect('MR').element().read(spec, 'receiver').end();
          break;
        default:
          p.expect('MS').element().read(spec, 'sender').end();
      }
      if (spec.sender != null) {
        this.header.sender = {};
      }
      if (spec.sender != null) {
        this.header.sender[spec.sender] = {};
      }
      if (spec.sender != null) {
        this.header.sender[spec.sender].id = spec.sender;
      }
      if (spec.receiver != null) {
        this.header.receiver = {};
      }
      if (spec.receiver != null) {
        this.header.receiver[spec.receiver] = {};
      }
      if (spec.receiver != null) {
        this.header.receiver[spec.receiver].id = spec.receiver;
      }
      if (spec.maintenanceAgency != null) {
        return this.helper.maintenanceAgency = spec.maintenanceAgency;
      }
    },
    'UNB/UNH/BGM/NAD/IDE': function(p, spec) {
      p.expect('IDE').element().expect('10').element().read(spec, 'identity').end();
      if (spec.identity != null) {
        this.header.name = {};
      }
      if (spec.identity != null) {
        return this.header.name.en = spec.identity;
      }
    },
    'UNB/UNH/BGM/NAD/CTA': function(p, spec) {
      var contact, sender;
      p.expect('CTA').element().read(spec, 'function').element().read(spec, 'id').read(spec, 'name').end();
      if (this.header.sender != null) {
        sender = Object.keys(this.header.sender)[0];
      }
      if (this.header.sender[sender].contact == null) {
        this.header.sender[sender].contact = [];
      }
      contact = {};
      if (spec.name != null) {
        contact.name = {
          'en': spec.name
        };
      }
      if ((spec.id != null) && 0 < spec.id.length) {
        contact.department = {
          'en': spec.id
        };
      }
      return this.header.sender[sender].contact.push(contact);
    },
    'UNB/UNH/BGM/NAD/CTA/COM': function(p, spec) {
      var contact, sender;
      p.expect('COM').element().read(spec, 'number').read(spec, 'type').end();
      if (this.header.sender != null) {
        sender = Object.keys(this.header.sender)[0];
      }
      contact = this.header.sender[sender].contact[this.header.sender[sender].contact.length - 1];
      if (spec.type != null) {
        switch (spec.type) {
          case 'EM':
            return contact.email = spec.number;
          case 'TE':
            return contact.telephone = spec.number;
          case 'FX':
            return contact.fax = spec.number;
          case 'XF':
            return contact.x400 = spec.number;
          default:
            throw new Error("Invalid contact type " + spec.type);
        }
      }
    },
    'UNB/UNH/VLI': function(p, spec) {
      p.expect('VLI').element().read(spec, 'id').emptyElement().emptyElement().element().read(spec, 'description').end();
      this.codelist = {};
      if (spec.id != null) {
        this.codelist.id = spec.id;
      }
      if (spec.description != null) {
        this.codelist.name = {};
      }
      if (spec.description != null) {
        this.codelist.name.en = spec.description;
      }
      if (this.helper.maintenanceAgency != null) {
        this.codelist.agencyID = this.helper.maintenanceAgency;
      }
      return this.codelist.version = '1.0';
    },
    'UNB/UNH/VLI/CDV': function(p, spec) {
      p.expect('CDV').element().read(spec, 'code').end();
      if (spec.code != null) {
        return this.helper.code = spec.code;
      }
    },
    'UNB/UNH/VLI/CDV/FTX': function(p, spec) {
      var code;
      code = {
        id: this.helper.code,
        name: {
          en: ''
        }
      };
      processDescription(p, spec);
      if (this.codelist.codes == null) {
        this.codelist.codes = {};
      }
      if (this.codelist.codes[this.helper.code] == null) {
        this.codelist.codes[this.helper.code] = code;
      }
      return this.codelist.codes[this.helper.code].name.en += spec.description;
    },
    'UNB/UNH/STC': function(p, spec) {
      p.expect('STC').element().read(spec, 'id').end();
      if (!(this.conceptScheme.agencyID != null)) {
        this.conceptScheme = {};
        this.conceptScheme.id = 'CONCEPTS';
        this.conceptScheme.version = '1.0';
        this.conceptScheme.name = {};
        this.conceptScheme.name.en = 'Statistical concepts';
        if (this.helper.maintenanceAgency != null) {
          this.conceptScheme.agencyID = this.helper.maintenanceAgency;
        }
        this.conceptScheme.concepts = {};
      }
      if (spec.id != null) {
        return this.helper.conceptID = spec.id;
      }
    },
    'UNB/UNH/STC/FTX': function(p, spec) {
      var concept;
      concept = {
        id: this.helper.conceptID,
        name: {
          en: ''
        }
      };
      processDescription(p, spec);
      if (this.conceptScheme.concepts[this.helper.conceptID] == null) {
        this.conceptScheme.concepts[this.helper.conceptID] = concept;
      }
      return this.conceptScheme.concepts[this.helper.conceptID].name.en += spec.description;
    },
    'UNB/UNH/ASI': function(p, spec) {
      if (!_.isEmpty(this.conceptScheme.concepts)) {
        this.emitSDMX(sdmx.CONCEPT_SCHEME, this.conceptScheme);
        this.conceptScheme.concepts = {};
      }
      p.expect('ASI').element().read(spec, 'id').end();
      this.dsd = {};
      delete this.helper.primaryMeasure;
      if (spec.id != null) {
        this.dsd.id = spec.id;
      }
      if (this.helper.maintenanceAgency != null) {
        this.dsd.agencyID = this.helper.maintenanceAgency;
      }
      this.dsd.version = '1.0';
      this.dsd.dimensionGroupDescriptor = {};
      this.dsd.dimensionGroupDescriptor['TIMESERIES'] = {
        id: 'TIMESERIES',
        dimensions: []
      };
      return this.dsd.dimensionGroupDescriptor['SIBLING_GROUP'] = {
        id: 'SIBLING_GROUP',
        dimensions: []
      };
    },
    'UNB/UNH/ASI/FTX': function(p, spec) {
      processDescription(p, spec);
      this.dsd.name = {};
      if (spec.description != null) {
        return this.dsd.name.en = spec.description;
      }
    },
    'UNB/UNH/ASI/SCD': function(p, spec) {
      p.expect('SCD').element().read(spec, 'type').element().read(spec, 'id');
      if (p.moreElements()) {
        p.emptyElement().emptyElement().emptyElement().element().read(spec, 'empty').read(spec, 'position').end();
      }
      this.component = {};
      this.helper.componentType = spec.type;
      switch (spec.type) {
        case FREQUENCY:
          this.component.order = +spec.position;
          this.component.type = 'dimension';
          this.dsd.dimensionGroupDescriptor['TIMESERIES'].dimensions.push(spec.id);
          break;
        case DIMENSION:
          this.component.order = +spec.position;
          this.component.type = 'dimension';
          this.dsd.dimensionGroupDescriptor['TIMESERIES'].dimensions.push(spec.id);
          this.dsd.dimensionGroupDescriptor['SIBLING_GROUP'].dimensions.push(spec.id);
          break;
        case TIME:
          this.component.order = +spec.position;
          this.component.type = 'timeDimension';
      }
      if (!(this.helper.primaryMeasure != null) && spec.type === ARRAY_CELL) {
        this.helper.primaryMeasure = spec.id;
      }
      this.component.id = spec.id;
      this.component.conceptIdentity = {};
      this.component.conceptIdentity.ref = {};
      this.component.conceptIdentity.ref.id = this.component.id;
      this.component.conceptIdentity.ref.agencyID = this.helper.maintenanceAgency;
      this.component.conceptIdentity.ref.maintainableParentID = 'CONCEPTS';
      return this.component.conceptIdentity.ref.maintainableParentVersion = '1.0';
    },
    'UNB/UNH/ASI/SCD/ATT': function(p, spec) {
      p.expect('ATT').element().expect('3').element();
      switch (p.next()) {
        case REPRESENTATION:
          p.read(spec, 'type').element().expect('').expect('').expect('').read(spec, 'format');
          this.component.localRepresentation = {};
          this.component.localRepresentation.textFormat = parseFormat(spec.format);
          break;
        case USAGE_STATUS:
          p.read(spec, 'type').element().read(spec, 'status').expect('USS');
          switch (spec.status) {
            case '1':
              this.component.assignmentStatus = 'Conditional';
              break;
            case '2':
              this.component.assignmentStatus = 'Mandatory';
              break;
            default:
              throw new Error("Invalid status " + spec.status);
          }
          break;
        case ATTACHMENT_LEVEL:
          p.read(spec, 'type').element().read(spec, 'attachmentLevel').expect('ALV');
          this.component.attributeRelationship = {};
          switch (spec.attachmentLevel) {
            case DATASET:
              break;
            case TIMESERIES:
              this.component.attributeRelationship.group = 'TIMESERIES';
              break;
            case OBSERVATION:
              this.component.attributeRelationship.primaryMeasure = this.helper.primaryMeasure;
              break;
            case SIBLING_GROUP:
              this.component.attributeRelationship.group = 'SIBLING_GROUP';
              break;
            default:
              throw new Error("Invalid attachment level " + spec.attachmentLevel);
          }
          break;
        default:
          throw new Error("Invalid type " + (p.next()));
      }
      return p.end();
    },
    'UNB/UNH/ASI/SCD/IDE': function(p, spec) {
      p.expect('IDE').element().expect('1').element().read(spec, 'codelistID').end();
      this.component.localRepresentation.enumeration = {};
      this.component.localRepresentation.enumeration.ref = {};
      this.component.localRepresentation.enumeration.ref.id = spec.codelistID;
      this.component.localRepresentation.enumeration.ref.agencyID = this.helper.maintenanceAgency;
      return this.component.localRepresentation.enumeration.ref.version = '1.0';
    },
    'UNB/UNH/DSI': function(p, spec) {
      p.expect('DSI').element().read(spec, 'dsi').end();
      this.dataSetBegin.setID = spec.dsi;
      return this.header.dataSetID = this.dataSetBegin.setID;
    },
    'UNB/UNH/DSI/STS': function(p, spec) {
      p.expect('STS').element().expect('3').element().read(spec, 'action').end();
      this.dataSetBegin.action = (function() {
        switch (spec.action) {
          case '7':
            return 'Append';
          case '6':
            return 'Delete';
          default:
            throw new Error("Invalid message action " + spec.action);
        }
      })();
      return this.header.dataSetAction = this.dataSetBegin.action;
    },
    'UNB/UNH/DSI/DTM': function(p, spec) {
      p.expect('DTM').element().read(spec, 'type').read(spec, 'datetime').read(spec, 'format').end();
      switch (spec.type) {
        case '242':
          return this.header.prepared = time.fromEdifactTimeValue(spec.format, spec.datetime).toDate();
        case 'Z02':
          this.dataSetBegin.reportingBeginDate = time.fromEdifactTimeValue(spec.format, spec.datetime).toString();
          this.dataSetBegin.reportingEndDate = time.fromEdifactTimeValue(spec.format, spec.datetime, false).toString();
          this.header.reportingBegin = this.dataSetBegin.reportingBeginDate;
          return this.header.reportingEnd = this.dataSetBegin.reportingEndDate;
        default:
          throw new Error("Invalid DTM date-time-type " + spec.type);
      }
    },
    'UNB/UNH/DSI/IDE': function(p, spec) {
      p.expect('IDE').element().expect('5').element().read(spec, 'dsd').end();
      this.header.structure = {};
      this.header.structure[spec.dsd] = {
        structureID: spec.dsd,
        dimensionAtObservation: 'TIME_PERIOD',
        structureRef: {
          ref: {
            id: spec.dsd,
            agencyID: this.helper.maintenanceAgency,
            version: '1.0'
          }
        }
      };
      return this.dataSetBegin.structureRef = spec.dsd;
    },
    'UNB/UNH/DSI/IDE/GIS': function(p, spec) {
      p.expect('GIS').element();
      switch (p.next()) {
        case 'AR3':
          p.expect('AR3');
          break;
        case '1':
          p.expect('1').expect('').expect('').expect('-');
          break;
        default:
          p.error('');
      }
      return p.end();
    },
    'UNB/UNH/DSI/ARR': function(p) {
      var index, order, period, timeFormat, timePeriod, _base, _base1, _base2, _base3, _base4, _ref, _ref1, _ref2, _ref3, _ref4;
      this.series = {};
      p.expect('ARR').emptyElement().element();
      this.series.seriesKey = {};
      order = 1;
      while (p.moreComponents() && !/^[0-9]/.test(p.next())) {
        this.series.seriesKey[order] = p.get();
        order += 1;
      }
      if (p.moreComponents()) {
        period = p.get();
      }
      if (p.moreComponents()) {
        timeFormat = p.get();
        timePeriod = time.fromEdifactTimeValue(timeFormat, period);
      }
      index = 0;
      if (p.moreComponents()) {
        this.series.obs = {};
        this.series.obs.obsDimension = [];
        this.series.obs.obsDimension[index] = timePeriod.toString();
      }
      if (p.moreComponents()) {
        this.series.obs.obsValue = [];
        this.series.obs.obsValue[index] = +p.get();
      }
      if (p.moreComponents()) {
        this.series.obs.attributes = {};
        this.series.obs.attributes['OBS_STATUS'] = [];
        this.series.obs.attributes['OBS_STATUS'][index] = p.get();
      }
      if (p.moreComponents()) {
        this.series.obs.attributes['OBS_CONF'] = [];
        this.series.obs.attributes['OBS_CONF'][index] = p.get();
      }
      if (p.moreComponents()) {
        this.series.obs.attributes['OBS_PRE_BREAK'] = [];
        this.series.obs.attributes['OBS_PRE_BREAK'][index] = p.get();
      }
      while (p.moreElements()) {
        index += 1;
        p.element();
        this.series.obs.obsDimension.push(timePeriod.next().toString());
        if (p.moreComponents()) {
          if ((_ref = (_base = this.series.obs).obsValue) == null) {
            _base.obsValue = [];
          }
          this.series.obs.obsValue[index] = +p.get();
        }
        if (p.moreComponents()) {
          if ((_ref1 = (_base1 = this.series.obs).attributes) == null) {
            _base1.attributes = {};
          }
          if ((_ref2 = (_base2 = this.series.obs.attributes)['OBS_STATUS']) == null) {
            _base2['OBS_STATUS'] = [];
          }
          this.series.obs.attributes['OBS_STATUS'][index] = p.get();
        }
        if (p.moreComponents()) {
          if ((_ref3 = (_base3 = this.series.obs.attributes)['OBS_CONF']) == null) {
            _base3['OBS_CONF'] = [];
          }
          this.series.obs.attributes['OBS_CONF'][index] = p.get();
        }
        if (p.moreComponents()) {
          if ((_ref4 = (_base4 = this.series.obs.attributes)['OBS_PRE_BREAK']) == null) {
            _base4['OBS_PRE_BREAK'] = [];
          }
          this.series.obs.attributes['OBS_PRE_BREAK'][index] = p.get();
        }
      }
      return p.end();
    },
    'UNB/UNH/DSI/FNS': function(p, spec) {
      return p.expect('FNS').element().read(spec, 'identity').expect('10').end();
    },
    'UNB/UNH/DSI/FNS/REL': function(p, spec) {
      p.expect('REL').element().expect('Z01').element().read(spec, 'scope').end();
      return this.helper.attributeScope = spec.scope;
    },
    'UNB/UNH/DSI/FNS/REL/ARR': function(p, spec) {
      var dim, key, order;
      this.attributes = {};
      switch (this.helper.attributeScope) {
        case OBSERVATION:
          this.attributes.obs = {};
          this.attributes.obs.attributes = {};
          break;
        case TIMESERIES:
        case SIBLING_GROUP:
        case DATASET:
          this.attributes.attributes = {};
      }
      p.expect('ARR').element().read(spec, 'lastElement');
      if (p.moreElements()) {
        p.element();
        if (p.next() === '') {
          this.helper.attributeScope = SIBLING_GROUP;
        }
        key = {};
        order = 1;
        while (p.moreComponents()) {
          dim = p.get();
          if (dim !== '') {
            key[order] = dim;
          }
          order += 1;
        }
        if (this.helper.attributeScope === OBSERVATION) {
          this.attributes.obs.obsDimension = [];
          this.attributes.obs.obsDimension.push(time.fromEdifactTimeValue(key[order - 1], key[order - 2]).toString());
          delete key[order - 1];
          delete key[order - 2];
        }
        if (this.helper.attributeScope === SIBLING_GROUP) {
          this.attributes.groupKey = key;
        } else {
          this.attributes.seriesKey = key;
        }
      }
      return p.end();
    },
    'UNB/UNH/DSI/FNS/REL/ARR/IDE': function(p, spec) {
      p.expect('IDE').element().read(spec, 'objectType').element().read(spec, 'id').end();
      this.helper.attributeID = spec.id;
      if (this.helper.attributeScope === OBSERVATION) {
        return this.attributes.obs.attributes[this.helper.attributeID] = [];
      }
    },
    'UNB/UNH/DSI/FNS/REL/ARR/IDE/CDV': function(p, spec) {
      p.expect('CDV').element().read(spec, 'value').end();
      if (this.helper.attributeScope === OBSERVATION) {
        return this.attributes.obs.attributes[this.helper.attributeID] = spec.value;
      } else {
        return this.attributes.attributes[this.helper.attributeID] = spec.value;
      }
    },
    'UNB/UNH/DSI/FNS/REL/ARR/IDE/FTX': function(p, spec) {
      p.expect('FTX').element().expect('ACM').emptyElement().emptyElement().element();
      spec.text = p.get();
      if (p.moreComponents()) {
        spec.text += p.get();
      }
      if (p.moreComponents()) {
        spec.text += p.get();
      }
      if (p.moreComponents()) {
        spec.text += p.get();
      }
      if (p.moreComponents()) {
        spec.text += p.get();
      }
      p.end();
      if (this.helper.attributeScope === OBSERVATION) {
        return this.attributes.obs.attributes[this.helper.attributeID].push(spec.text);
      } else {
        return this.attributes.attributes[this.helper.attributeID] = spec.text;
      }
    },
    'UNB/UNT': function(p, spec) {
      if (!_.isEmpty(this.conceptScheme.concepts)) {
        this.emitSDMX(sdmx.CONCEPT_SCHEME, this.conceptScheme);
        this.conceptScheme.concepts = {};
      }
      return p.expect('UNT').element().read(spec, 'value').element().read(spec, 'value').end();
    },
    'UNZ': function(p, spec) {
      return p.expect('UNZ').element().expect(this.messageCount.toString()).element().read(spec, 'value').end();
    }
  };

  exitActions = {
    'UNB/UNH/BGM': function() {
      if (this.helper.messageFunction === DEFINITIONS) {
        return this.emitSDMX(sdmx.HEADER, this.header);
      }
    },
    'UNB/UNH/DSI/IDE': function() {
      if (this.helper.messageFunction === DATA) {
        this.emitSDMX(sdmx.HEADER, this.header);
        return this.emitSDMX(sdmx.DATA_SET_HEADER, this.dataSetBegin);
      }
    },
    'UNB/UNH/VLI': function() {
      return this.emitSDMX(sdmx.CODE_LIST, this.codelist);
    },
    'UNB/UNH/ASI': function() {
      return this.emitSDMX(sdmx.DATA_STRUCTURE_DEFINITION, this.dsd);
    },
    'UNB/UNH/ASI/SCD': function() {
      switch (this.helper.componentType) {
        case TIME:
          if (this.dsd.dimensionDescriptor == null) {
            this.dsd.dimensionDescriptor = {};
          }
          return this.dsd.dimensionDescriptor[this.component.id] = this.component;
        case ARRAY_CELL:
          if (this.component.id === this.helper.primaryMeasure) {
            this.dsd.measureDescriptor = {};
            return this.dsd.measureDescriptor.primaryMeasure = this.component;
          } else {
            if (this.dsd.attributeDescriptor == null) {
              this.dsd.attributeDescriptor = {};
            }
            return this.dsd.attributeDescriptor[this.component.id] = this.component;
          }
          break;
        case FREQUENCY:
          if (this.dsd.dimensionDescriptor == null) {
            this.dsd.dimensionDescriptor = {};
          }
          return this.dsd.dimensionDescriptor[this.component.id] = this.component;
        case DIMENSION:
          if (this.dsd.dimensionDescriptor == null) {
            this.dsd.dimensionDescriptor = {};
          }
          return this.dsd.dimensionDescriptor[this.component.id] = this.component;
        case ATTRIBUTE:
          if (this.dsd.attributeDescriptor == null) {
            this.dsd.attributeDescriptor = {};
          }
          return this.dsd.attributeDescriptor[this.component.id] = this.component;
      }
    },
    'UNB/UNH/DSI/ARR': function() {
      return this.emitSDMX(sdmx.SERIES, this.series);
    },
    'UNB/UNH/DSI/FNS/REL/ARR': function() {
      switch (this.helper.attributeScope) {
        case OBSERVATION:
        case TIMESERIES:
          return this.emitSDMX(sdmx.SERIES, this.attributes);
        case SIBLING_GROUP:
          this.attributes.type = 'SiblingGroup';
          return this.emitSDMX(sdmx.ATTRIBUTE_GROUP, this.attributes);
        case DATASET:
          return this.emitSDMX(sdmx.DATA_SET_ATTRIBUTES, this.attributes);
      }
    }
  };

  exports.fst = _.extend({}, guards, entryActions, exitActions);

  exports.guards = guards;

  exports.entryActions = entryActions;

  exports.exitActions = exitActions;

}).call(this);
