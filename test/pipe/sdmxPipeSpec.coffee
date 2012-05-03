sdmx = require '../../lib/pipe/sdmxPipe'
Log = require 'log'
util = require 'util'


describe 'SdmxPipe', ->

	log = s1 = s2 = s3 = {}
	bucket = []
	drain = false


	beforeEach ->
		log = new Log Log.INFO, process.stderr
		bucket = []
		s1 = new sdmx.SdmxPipe log
		s2 = new sdmx.SdmxPipe log
		s3 = new sdmx.SdmxPipe log
		drain = false


	it 'emits all writes and ends', ->
		s1.on 'data', (data) -> bucket.push data
		s1.on 'end', ->
			bucket.should.eql ['t1','t2']
			s1.counters.write.should.equal 2
			s1.counters.end.should.equal 1
			s1.counters.in.chars.should.equal 4
			s1.counters.out.chars.should.equal 4
			s1.counters.emit.should.equal 3

		s1.write('t1').should.be.true
		s1.write('t2').should.be.true
		s1.end()


	it 'handles pause, resume and drain', ->
		s1.on 'data', (data) -> bucket.push data
		s1.on 'drain', -> drain = true
		s1.on 'end', ->
			bucket.should.eql ['t1','t2', 't3']
			s1.counters.write.should.equal 3
			s1.counters.end.should.equal 1
			s1.counters.pause.should.equal 1
			s1.counters.resume.should.equal 1
			s1.counters.emit.should.equal 4
			drain.should.be.false

		s1.write('t1').should.be.true
		s1.pause()
		s1.write('t2').should.be.true
		s1.resume()
		s1.write('t3').should.be.true
		s1.end()


	xit 'handles wait, continue and drain', ->
		s1.on 'data', (data) -> bucket.push data
		s1.on 'drain', -> drain = true
		s1.on 'end', ->
			bucket.should.eql ['t1','t2','t3']
			s1.counters.wait.should.equal 1
			s1.counters.continue.should.equal 1
			drain.should.be.true

		s1.write('t1').should.be.true
		s1.wait()
		s1.write('t2').should.be.false
		s1.continue()
		s1.write('t3').should.be.true
		s1.end()


	it 'queues writes during pause', ->
		s1.on 'data', (data) -> bucket.push data
		s1.on 'end', ->
			bucket.should.eql ['t1','t2','t3']

		s1.write('t1').should.be.true
		s1.pause()
		s1.write('t2').should.be.true
		s1.write('t3').should.be.true
		s1.resume()
		s1.end()


	xit 'queues writes during wait', ->
		s1.on 'data', (data) -> bucket.push data
		s1.on 'end', ->
			bucket.should.eql ['t1','t2','t3']

		s1.write('t1').should.be.true
		s1.wait()
		s1.write('t2').should.be.false
		s1.write('t3').should.be.false
		s1.continue()
		s1.end()


	xit 'handles pause, wait, resume, continue', ->
		s1.on 'data', (data) -> bucket.push data
		s1.on 'end', ->
			bucket.should.eql ['t1','t2','t3','t4']

		s1.write('t1').should.be.true
		s1.pause()
		s1.write('t2').should.be.false
		s1.wait()
		s1.resume()
		s1.write('t3').should.be.false
		s1.continue()
		s1.write('t4').should.be.true
		s1.end()


	xit 'handles wait, pause, continue, resume', ->
		s1.on 'data', (data) -> bucket.push data
		s1.on 'end', ->
			bucket.should.eql ['t1','t2','t3','t4']

		s1.write('t1').should.be.true
		s1.wait()
		s1.write('t2').should.be.false
		s1.pause()
		s1.continue()
		s1.write('t3').should.be.false
		s1.resume()
		s1.write('t4').should.be.true
		s1.end()


	it 'handles piping', ->
		s3.on 'data', (data) -> bucket.push data
		s3.on 'end', ->
			bucket.should.eql ['t1','t2','t3']

		s1.pipe s2
		s2.pipe s3

		s1.write('t1').should.be.true
		s1.write('t2').should.be.true
		s1.write('t3').should.be.true
		s1.end()


	it 'handles pause/resume when piping', ->
		s3.on 'data', (data) -> bucket.push data
		s3.on 'end', ->
			bucket.should.eql ['t1','t2','t3']
			s1.counters.pause.should.equal 0
			s2.counters.pause.should.equal 1
			s3.counters.pause.should.equal 0

		s1.pipe s2
		s2.pipe s3

		s1.write('t1').should.be.true
		s2.pause()
		s1.write('t2').should.be.true
		s2.resume()
		s1.write('t3').should.be.true
		s1.end()




