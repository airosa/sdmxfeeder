fs = require 'fs'
util = require 'util'
path = require 'path'
url = require 'url'
optimist = require 'optimist'
request = require 'request'
Log = require 'log'
{XMLReader} = require './xml/reader'
{EDIFACTReader} = require './edifact/reader'
{JSONWriter} = require './json/writer'
{XMLWriter} = require './xml/writer'
{GenericChecker} = require './checks/genericChecker'
{DebugHandler} = require './util/debugHandler'

len = 0
countTo1Meg = 0
start = (new Date).getTime()

argv = optimist
    .usage('Process a SDMX file.\nUsage: sdmxfeeder inputfile [outputfile]')
    .demand(1)
    .default({
    	level: 'INFO'
    })
    .describe({
    	log: 'Log file name'
    	level: 'Logging level'
    })
    .argv

log = new Log Log[argv.level], process.stderr
log.info "Logging level is #{argv.level}"

delegate =
	onClose: ->
		log.info "File closed"
	onEnd: =>
		log.debug "Reader is readable: #{reader.readable}"
		log.info "Finished reading #{reader.charsRead} bytes"
		if writer?
			log.info "Finished writing #{writer.charsWritten} bytes"
			for key, value of writer.counters when 0 < value
				log.info "#{key}: #{value}"
		for msg in checker.errors
			log.error msg
	onError: (exception) =>
		log.error exception
	onData: (data) =>
		len += data.length
		countTo1Meg += data.length
		if countTo1Meg > 1000000
			diff = ((new Date).getTime() - start) / 1000
			log.info "Processed #{len} bytes in #{diff} seconds"
			countTo1Meg = 0
			start = (new Date).getTime()


log.info "http://github.com/airosa/sdmxfeeder v0.1.0"
log.info "Starting to process"

urlObj = url.parse argv._[0]

if urlObj.protocol?
	log.info "Input url is #{urlObj.href}"
	source = request.get( { uri: urlObj.href, encoding: 'utf8' } )
	inext = '.xml'
else
	log.info "Input file is #{argv._[0]}"
	inext = path.extname argv._[0]
	source = fs.createReadStream argv._[0]
	source.setEncoding if inext is '.edi' then 'ascii' else 'utf8'

log.info "Input format is #{inext}"
source.on 'close', delegate.onClose
source.on 'end', delegate.onEnd
source.on 'error', delegate.onError
source.on 'data', delegate.onData

switch inext
	when '.xml' then reader = new XMLReader log
	when '.edi' then reader = new EDIFACTReader log
	else log.error "No reader for #{argv.in}"

source.pipe reader
source = reader

if argv.level is 'DEBUG'
	debuglogger = new DebugHandler log
	source.pipe debuglogger
	source = debuglogger

checker = new GenericChecker log
source.pipe checker
source = checker

if argv._[1]?
	log.info "Output file is #{argv._[1]}"
	outext = path.extname argv._[1]
	log.info "Output format is #{outext}"

	switch outext
		when '.xml' then writer = new XMLWriter log
		when '.json' then writer = new JSONWriter log
		else log.error "No writer for #{argv.out}"

	source.pipe writer
	source = writer

	outStream = fs.createWriteStream argv._[1]
	outStream.on 'error', delegate.onError

	source.pipe outStream
