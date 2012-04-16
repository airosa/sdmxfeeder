// Generated by CoffeeScript 1.3.1
(function() {
  var EDIFACTWriter;

  EDIFACTWriter = (function() {

    EDIFACTWriter.name = 'EDIFACTWriter';

    function EDIFACTWriter() {}

    EDIFACTWriter.prototype.arrayToSegment = function(arr) {
      var i, j, seg, t, tmp, _i, _j, _k, _len, _ref, _ref1;
      if (arr[0][0].substring(0, 3) === 'UNA') {
        return arr[0][0] + "'";
      }
      tmp = [];
      for (i = _i = 0, _ref = arr.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        tmp.push([]);
        for (j = _j = 0, _ref1 = arr[i].length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; j = 0 <= _ref1 ? ++_j : --_j) {
          tmp[i].push(arr[i][j].replace(/\:|\+/g, '?$&'));
        }
      }
      seg = [];
      for (_k = 0, _len = tmp.length; _k < _len; _k++) {
        t = tmp[_k];
        seg.push(t.join(':'));
      }
      return seg.join('+') + "'";
    };

    return EDIFACTWriter;

  })();

  exports.EDIFACTWriter = EDIFACTWriter;

}).call(this);