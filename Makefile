TESTS = $(shell find test -name "*Spec.coffee")

install:
		@test `which npm` || echo 'You need to have npm installed'
		@npm install

test: release
		@./node_modules/mocha/bin/mocha $(TESTS)

release:
		@rm -fr lib
		@./node_modules/coffee-script/bin/coffee -c -o lib src

samples:
		@rm examples/*
		@bin/sdmxfeeder --level ERROR test/fixtures/edifact/concepts.edi examples/concepts.edi.json
		@bin/sdmxfeeder --level ERROR test/fixtures/edifact/data_update_1.edi examples/data_update_1.edi.json
		@bin/sdmxfeeder --level ERROR test/fixtures/edifact/data_update_2.edi examples/data_update_2.edi.json
		@bin/sdmxfeeder --level ERROR test/fixtures/xml/v2_1/ecb_exr_rg_full.xml examples/ecb_exr_rg_full.xml.json
		@bin/sdmxfeeder --level ERROR test/fixtures/xml/v2_1/ecb_exr_rg_ts_generic.xml examples/ecb_exr_rg_ts_generic.xml.json

.PHONY: install test release samples
