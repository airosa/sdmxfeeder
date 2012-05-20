// Generated by CoffeeScript 1.3.1
(function() {
  var SubmitToRegistryPipe, sdmx,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  sdmx = require('../pipe/sdmxPipe');

  SubmitToRegistryPipe = (function(_super) {

    __extends(SubmitToRegistryPipe, _super);

    SubmitToRegistryPipe.name = 'SubmitToRegistryPipe';

    function SubmitToRegistryPipe(log, registry) {
      this.registry = registry;
      this.submitCallback = __bind(this.submitCallback, this);

      SubmitToRegistryPipe.__super__.constructor.apply(this, arguments);
    }

    SubmitToRegistryPipe.prototype.processData = function(sdmxdata) {
      switch (sdmxdata.type) {
        case sdmx.CODE_LIST:
        case sdmx.CONCEPT_SCHEME:
        case sdmx.DATA_STRUCTURE_DEFINITION:
          this.pause();
          this.registry.submit(sdmxdata.data, this.submitCallback);
      }
      return SubmitToRegistryPipe.__super__.processData.apply(this, arguments);
    };

    SubmitToRegistryPipe.prototype.submitCallback = function(err) {
      if (err != null) {
        throw new Error(err);
      }
      return this.resume();
    };

    return SubmitToRegistryPipe;

  })(sdmx.SdmxPipe);

  exports.SubmitToRegistryPipe = SubmitToRegistryPipe;

}).call(this);