// Generated by CoffeeScript 1.3.1
(function() {
  var DebugHandler, EDIFACTReader, GenericChecker, JSONWriter, Log, XMLReader, XMLWriter, argv, checker, countTo1Meg, debuglogger, delegate, fs, inext, len, log, optimist, outStream, outext, path, reader, request, source, start, url, urlObj, util, writer,
    _this = this;

  fs = require('fs');

  util = require('util');

  path = require('path');

  url = require('url');

  optimist = require('optimist');

  request = require('request');

  Log = require('log');

  XMLReader = require('./xml/reader').XMLReader;

  EDIFACTReader = require('./edifact/reader').EDIFACTReader;

  JSONWriter = require('./json/writer').JSONWriter;

  XMLWriter = require('./xml/writer').XMLWriter;

  GenericChecker = require('./checks/genericChecker').GenericChecker;

  DebugHandler = require('./util/debugHandler').DebugHandler;

  len = 0;

  countTo1Meg = 0;

  start = (new Date).getTime();

  argv = optimist.usage('Process a SDMX file.\nUsage: sdmxfeeder inputfile [outputfile]').demand(1)["default"]({
    level: 'INFO'
  }).describe({
    log: 'Log file name',
    level: 'Logging level'
  }).argv;

  log = new Log(Log[argv.level], process.stderr);

  log.info("Logging level is " + argv.level);

  delegate = {
    onClose: function() {
      return log.info("File closed");
    },
    onEnd: function() {
      var key, msg, value, _i, _len, _ref, _ref1, _results;
      log.debug("Reader is readable: " + reader.readable);
      log.info("Finished reading " + reader.charsRead + " bytes");
      if (typeof writer !== "undefined" && writer !== null) {
        log.info("Finished writing " + writer.charsWritten + " bytes");
        _ref = writer.counters;
        for (key in _ref) {
          value = _ref[key];
          if (0 < value) {
            log.info("" + key + ": " + value);
          }
        }
      }
      _ref1 = checker.errors;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        msg = _ref1[_i];
        _results.push(log.error(msg));
      }
      return _results;
    },
    onError: function(exception) {
      return log.error(exception);
    },
    onData: function(data) {
      var diff;
      len += data.length;
      countTo1Meg += data.length;
      if (countTo1Meg > 1000000) {
        diff = ((new Date).getTime() - start) / 1000;
        log.info("Processed " + len + " bytes in " + diff + " seconds");
        countTo1Meg = 0;
        return start = (new Date).getTime();
      }
    }
  };

  log.info("http://github.com/airosa/sdmxfeeder v0.1.0");

  log.info("Starting to process");

  urlObj = url.parse(argv._[0]);

  if (urlObj.protocol != null) {
    log.info("Input url is " + urlObj.href);
    source = request.get({
      uri: urlObj.href,
      encoding: 'utf8'
    });
    inext = '.xml';
  } else {
    log.info("Input file is " + argv._[0]);
    inext = path.extname(argv._[0]);
    source = fs.createReadStream(argv._[0]);
    source.setEncoding(inext === '.edi' ? 'ascii' : 'utf8');
  }

  log.info("Input format is " + inext);

  source.on('close', delegate.onClose);

  source.on('end', delegate.onEnd);

  source.on('error', delegate.onError);

  source.on('data', delegate.onData);

  switch (inext) {
    case '.xml':
      reader = new XMLReader(log);
      break;
    case '.edi':
      reader = new EDIFACTReader(log);
      break;
    default:
      log.error("No reader for " + argv["in"]);
  }

  source.pipe(reader);

  source = reader;

  if (argv.level === 'DEBUG') {
    debuglogger = new DebugHandler(log);
    source.pipe(debuglogger);
    source = debuglogger;
  }

  checker = new GenericChecker(log);

  source.pipe(checker);

  source = checker;

  if (argv._[1] != null) {
    log.info("Output file is " + argv._[1]);
    outext = path.extname(argv._[1]);
    log.info("Output format is " + outext);
    switch (outext) {
      case '.xml':
        writer = new XMLWriter(log);
        break;
      case '.json':
        writer = new JSONWriter(log);
        break;
      default:
        log.error("No writer for " + argv.out);
    }
    source.pipe(writer);
    source = writer;
    outStream = fs.createWriteStream(argv._[1]);
    outStream.on('error', delegate.onError);
    source.pipe(outStream);
  }

}).call(this);