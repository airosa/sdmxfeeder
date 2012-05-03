optimist = require 'optimist'
Log = require 'log'
async = require 'async'
fs = require 'fs'
path = require 'path'
{SimpleRegistry} = require './registry/simpleRegistry'
factory = require './pipe/pipeFactory'

#-------------------------------------------------------------------------------

start = (new Date).getTime()

argv = optimist
    .usage( 'Process a SDMX file.\nUsage: sdmxfeeder inputfile [outputfile]' )
    .demand( 1 )
    .default( level: 'INFO' )
    .describe( log: 'Log file name', level: 'Logging level' )
    .argv

log = new Log Log[argv.level], process.stderr
log.info "Logging level is #{argv.level}"

log.info "http://github.com/airosa/sdmxfeeder v0.1.1"
log.info "Starting to process"

registry = new SimpleRegistry log
sourcePath = argv._[0]
destinationPath = argv._[1]

options =
	log: log
	registry: registry

pipeFactory = new factory.PipeFactory()

#-------------------------------------------------------------------------------

loadStructuresFromFiles = (callback) ->
	path.exists './registry', (exists) ->
		if exists
			findFiles './registry', (err, dirPath, files) ->
				fileIterator = (file, callback1) ->
					fullpath = path.join(dirPath, file)
					format = getFileFormat fullpath
					source = createReadStream fullpath, format
					pipe = pipeFactory.build [ 'READ_' + format, 'CHECK', 'SUBMIT' ], options
					pipe.on 'end', callback1
					pipe.pump source

				async.forEachSeries	files, fileIterator, callback
		else
			callback()


processInputFile = (callback) ->
	formatIn = getFileFormat sourcePath
	pipes = [ 'READ_' + formatIn, 'CONVERT', 'CHECK' ]
	source = createReadStream sourcePath, formatIn

	if destinationPath?
		formatOut = getFileFormat destinationPath
		destination = createWriteStream destinationPath, formatOut
		pipes.push 'WRITE_' + formatOut

	pipe = pipeFactory.build pipes, options

	if destination?
		destination.on 'end', callback
	else
		pipe.on 'end', callback

	pipe.pump source, destination


findFiles = (path, callback) ->
	log.info "Looking for files in directory #{path}"
	fs.realpath path, (err, resolvedPath) ->
		throw err if err?
		fs.readdir resolvedPath, (err, files) ->
			throw err if err?
			callback err, resolvedPath, files


createReadStream = (fullpath, format) ->
	len = countTo1Mb = 0
	start = (new Date).getTime()
	log.info "Source: #{fullpath}"
	log.info "Source format: #{format}"
	source = fs.createReadStream fullpath
	source.setEncoding if format is 'EDI' then 'ascii' else 'utf8'
	source.on 'close', ->
		diff = ((new Date).getTime() - start) / 1000
		log.info "Source closed: #{fullpath}"
		log.info "Read #{len} bytes in #{diff} seconds"
	source.on 'data', ( data ) ->
		len += data.length
		countTo1Mb += data.length
		if countTo1Mb > 1000000
			diff = ((new Date).getTime() - start) / 1000
			log.info "#{fullpath} read #{len} bytes in #{diff} seconds"
			countTo1Mb = 0
			start = (new Date).getTime()
	source


createWriteStream = (fullpath, format) ->
	log.info "Destination: #{fullpath}"
	log.info "Destination format: #{format}"
	destination = fs.createWriteStream fullpath
	destination.on 'close', ( -> log.info "Destination closed: #{fullpath}" )
	destination


getFileFormat = (fullpath) ->
	format = path.extname(fullpath).toUpperCase().slice 1

#-------------------------------------------------------------------------------

process.on 'exit', ->
	diff = ((new Date).getTime() - start) / 1000
	log.info "Finished processing in #{diff}s"

process.on 'uncaughtException', (err) =>
	log.critical "#{err}"

#-------------------------------------------------------------------------------

async.series [ loadStructuresFromFiles, processInputFile ]

#-------------------------------------------------------------------------------

