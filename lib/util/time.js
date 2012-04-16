// Generated by CoffeeScript 1.3.1
(function() {
  var DistinctTimePeriod, GregorianTimePeriod, ReportingTimePeriod, fromEdifactTimeValue, fromTimeValue;

  require('datejs');

  fromEdifactTimeValue = function(format, value, begin) {
    var century, day, hour, min, month, year;
    if (begin == null) {
      begin = true;
    }
    switch (format) {
      case '102':
        return new GregorianTimePeriod('GD', +value.slice(0, 4), +value.slice(4, 6), +value.slice(6, 8));
      case '602':
        return new GregorianTimePeriod('GY', +value, 1, 1);
      case '604':
        return new ReportingTimePeriod('S', +value.slice(0, 4), +value.slice(4, 5));
      case '608':
        return new ReportingTimePeriod('Q', +value.slice(0, 4), +value.slice(4, 5));
      case '610':
        return new GregorianTimePeriod('GTM', +value.slice(0, 4), +value.slice(4, 6), 1);
      case '616':
        return new ReportingTimePeriod('W', +value.slice(0, 4), +value.slice(4, 6));
      case '702':
        return fromEdifactTimeValue('602', (begin ? value.slice(0, 4) : value.slice(5, 9)));
      case '704':
        return fromEdifactTimeValue('604', (begin ? value.slice(0, 5) : value.slice(6, 11)));
      case '708':
        return fromEdifactTimeValue('608', (begin ? value.slice(0, 5) : value.slice(6, 11)));
      case '710':
        return fromEdifactTimeValue('610', (begin ? value.slice(0, 6) : value.slice(7, 13)));
      case '711':
        return fromEdifactTimeValue('102', (begin ? value.slice(0, 8) : value.slice(9, 17)));
      case '716':
        return fromEdifactTimeValue('616', (begin ? value.slice(0, 6) : value.slice(7, 13)));
      case '201':
        century = +value.slice(0, 2) < 49 ? '20' : '19';
        year = value.slice(0, 2);
        month = value.slice(2, 4);
        day = value.slice(4, 6);
        hour = value.slice(6, 8);
        min = value.slice(8, 10);
        return new DistinctTimePeriod("" + century + year + "-" + month + "-" + day + "T" + hour + ":" + min + ":00");
      case '203':
        year = value.slice(0, 4);
        month = value.slice(4, 6);
        day = value.slice(6, 8);
        hour = value.slice(8, 10);
        min = value.slice(10, 12);
        return new DistinctTimePeriod("" + year + "-" + month + "-" + day + "T" + hour + ":" + min + ":00");
    }
  };

  fromTimeValue = function(value) {
    switch (value.length) {
      case 4:
        return new GregorianTimePeriod('GY', +value, 1, 1);
      case 7:
        switch (value.slice(5, 6)) {
          case 'A':
          case 'S':
          case 'T':
          case 'Q':
            return new ReportingTimePeriod(value.slice(5, 6), +value.slice(0, 4), +value.slice(6));
          default:
            return new GregorianTimePeriod('GTM', +value.slice(0, 4), +value.slice(5, 7), 1);
        }
        break;
      case 8:
      case 9:
        return new ReportingTimePeriod(value.slice(5, 6), +value.slice(0, 4), +value.slice(6));
      case 10:
        return new GregorianTimePeriod('GD', +value.slice(0, 4), +value.slice(5, 7), +value.slice(8, 10));
      case 19:
        return new DistinctTimePeriod(value);
    }
  };

  GregorianTimePeriod = (function() {

    GregorianTimePeriod.name = 'GregorianTimePeriod';

    function GregorianTimePeriod(format, year, month, day) {
      this.format = format;
      this.date = new Date(Date.UTC(year, month - 1, day, 0, 0, 0));
    }

    GregorianTimePeriod.prototype.next = function() {
      switch (this.format) {
        case 'GY':
          this.date.addYears(1);
          break;
        case 'GTM':
          this.date.addMonths(1);
          break;
        case 'GD':
          this.date.addDays(1);
      }
      return this;
    };

    GregorianTimePeriod.prototype.toString = function() {
      switch (this.format) {
        case 'GY':
          return this.date.toString('yyyy');
        case 'GTM':
          return this.date.toString('yyyy-MM');
        case 'GD':
          return this.date.toString('yyyy-MM-dd');
      }
    };

    GregorianTimePeriod.prototype.toDate = function() {
      return this.date;
    };

    return GregorianTimePeriod;

  })();

  ReportingTimePeriod = (function() {

    ReportingTimePeriod.name = 'ReportingTimePeriod';

    function ReportingTimePeriod(frequency, year, period) {
      this.frequency = frequency;
      this.year = year;
      this.period = period;
    }

    ReportingTimePeriod.prototype.limitPerYear = function() {
      switch (this.frequency) {
        case 'A':
          return 1;
        case 'S':
          return 2;
        case 'T':
          return 3;
        case 'Q':
          return 4;
        case 'M':
          return 12;
        case 'W':
          return +(new Date(Date.UTC(this.year, 11, 28))).getISOWeek();
        case 'D':
          if (Date.isLeapYear(this.year)) {
            return 366;
          } else {
            return 365;
          }
      }
    };

    ReportingTimePeriod.prototype.next = function() {
      var limit;
      limit = this.limitPerYear();
      this.year += (this.period === limit ? 1 : 0);
      this.period = (this.period === limit ? 1 : this.period + 1);
      return this;
    };

    ReportingTimePeriod.prototype.paddedPeriod = function() {
      var pad, str;
      str = '' + this.period;
      pad = (function() {
        switch (this.frequency) {
          case 'A':
          case 'S':
          case 'T':
          case 'Q':
            return '0';
          case 'M':
          case 'W':
            return '00';
          case 'D':
            return '000';
        }
      }).call(this);
      return pad.substr(0, pad.length - str.length) + str;
    };

    ReportingTimePeriod.prototype.toString = function() {
      return "" + this.year + "-" + this.frequency + (this.paddedPeriod());
    };

    ReportingTimePeriod.prototype.toDate = function() {
      var date;
      date = new Date(Date.UTC(year, 0, 1, 0, 0, 0));
      switch (this.frequency) {
        case 'A':
          return date;
        case 'S':
          return date.addMonths(6 * (this.period - 1));
        case 'T':
          return date.addMonths(4 * (this.period - 1));
        case 'Q':
          return date.addMonths(3 * (this.period - 1));
        case 'M':
          return date.addMonths(this.period - 1);
        case 'W':
          return date.addWeeks(this.period - 1);
        case 'D':
          return date.addDays(this.period - 1);
      }
    };

    return ReportingTimePeriod;

  })();

  DistinctTimePeriod = (function() {

    DistinctTimePeriod.name = 'DistinctTimePeriod';

    function DistinctTimePeriod(value) {
      this.date = Date.parse(value, 'yyyy-MM-ddTHH:mm:ss');
    }

    DistinctTimePeriod.prototype.next = function() {
      return this;
    };

    DistinctTimePeriod.prototype.toString = function() {
      return this.date.toString('yyyy-MM-ddTHH:mm:ss');
    };

    DistinctTimePeriod.prototype.toDate = function() {
      return this.date;
    };

    return DistinctTimePeriod;

  })();

  exports.fromTimeValue = fromTimeValue;

  exports.fromEdifactTimeValue = fromEdifactTimeValue;

}).call(this);