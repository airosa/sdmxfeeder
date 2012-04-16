// Generated by CoffeeScript 1.3.1
(function() {
  var CompactHandler, SDMXStream,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  SDMXStream = require('../sdmxStream').SDMXStream;

  CompactHandler = (function(_super) {

    __extends(CompactHandler, _super);

    CompactHandler.name = 'CompactHandler';

    function CompactHandler(log, dsd) {
      this.dsd = dsd;
      CompactHandler.__super__.constructor.call(this, log);
    }

    CompactHandler.prototype.convertDataset = function(dataset) {
      if (!(dataset.structureRef != null)) {
        return dataset.structureRef = 'STR1';
      }
    };

    CompactHandler.prototype.convertSeries = function(series) {
      var key, value, _ref;
      if (series.components != null) {
        _ref = series.components;
        for (key in _ref) {
          value = _ref[key];
          if (this.dsd.attributes[key] != null) {
            if (series.attributes == null) {
              series.attributes = {};
            }
            series.attributes[key] = value;
          } else {
            if (series.seriesKey == null) {
              series.seriesKey = {};
            }
            series.seriesKey[key] = value;
          }
        }
        return delete series.components;
      }
    };

    CompactHandler.prototype.convertGroup = function(group) {
      var key, value, _ref;
      if (group.components != null) {
        _ref = group.components;
        for (key in _ref) {
          value = _ref[key];
          if (this.dsd.attributes[key] != null) {
            if (group.attributes == null) {
              group.attributes = {};
            }
            group.attributes[key] = value;
          } else {
            if (group.groupKey == null) {
              group.groupKey = {};
            }
            group.groupKey[key] = value;
          }
        }
        return delete group.components;
      }
    };

    CompactHandler.prototype.write = function(sdmxdata) {
      switch (sdmxdata.type) {
        case 'dataSet':
          this.convertDataset(sdmxdata.data);
          break;
        case 'series':
          this.convertSeries(sdmxdata.data);
          break;
        case 'group':
          this.convertGroup(sdmxdata.data);
      }
      return CompactHandler.__super__.write.call(this, sdmxdata);
    };

    return CompactHandler;

  })(SDMXStream);

  exports.CompactHandler = CompactHandler;

}).call(this);