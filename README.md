# sdmxfeeder

Experimental converter for [SDMX](http://sdmx.org) files.
Written in [CoffeeScript](http://coffeescript.org), runs with [Node](http://nodejs.org).

## Features

- Supports a limited set of SDMX artefacts (basically what is supported in SDMX 1.0):
	- Data structure definition
	- Concept scheme
	- Code list
	- Time series data and metadata
- Reads following formats
	- SDMX-ML (XML) versions 1.0, 2.0, and 2.1
	- SDMX-EDI (EDIFACT)
- Writes following formats
	- SDMX-ML (XML) version 2.1
	- JSON
- JSON is not supported by the SDMX technical standards.
Examples directory contains some sample JSON files.
- Validates input data. Generic validation rules are defined in
[JSON Schema](http://tools.ietf.org/html/draft-zyp-json-schema-03) format.
Data structure specific validation is also supported.
- Streams data from input to output. Should convert and check large files.

## Installation

### Linux

Check that [Node.js](https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager)
and [NPM package manager](http://npmjs.org/) are installed:

	$ node -v
	v0.6.14
	$ npm -v
	1.1.1

Download and expand sdmxfeeder:

	$ curl --location https://github.com/airosa/sdmxfeeder/tarball/master | tar zx

Alternatively clone the repo:

	$ git clone git://github.com/airosa/sdmxfeeder.git

Finally in the sdmxfeeder directory run:

	$ make install

## Usage

Run from the install directory:

	bin/sdmxfeeder my_input_sdmx_file.xml my_output_sdmx_file.json

File formats depend on the file extensions: .xml -> XML, .json -> JSON, .edi -> EDIFACT.

Conversion of all SDMX-EDI and some SDMX-ML data files requires access to the
relevant data structure definitions. Create a directory named registry in the current
directory and copy the structure files (in any supported format) there. Application
will use them automatically.
