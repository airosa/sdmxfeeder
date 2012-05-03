TESTS = $(shell find test -wholename "*Spec.coffee")

install:
		@test `which npm` || echo 'You need to have npm installed'
		@npm install

test: release
		@./node_modules/mocha/bin/mocha $(TESTS)

release:
		@rm -fr lib
		@./node_modules/coffee-script/bin/coffee -c -o lib src

samples: release
		@rm -f examples/*
		@bin/sdmxfeeder --level ERROR test/fixtures/edifact/concepts.edi examples/concepts_edi.json
		@bin/sdmxfeeder --level ERROR test/fixtures/edifact/code_list.edi examples/code_list_edi.json
		@bin/sdmxfeeder --level ERROR test/fixtures/edifact/key_family.edi examples/key_family_edi.json
		@bin/sdmxfeeder --level ERROR test/fixtures/edifact/data_update_1.edi examples/data_update_1_edi.json
		@bin/sdmxfeeder --level ERROR test/fixtures/edifact/data_update_2.edi examples/data_update_2_edi.json
		@bin/sdmxfeeder --level ERROR test/fixtures/xml/v1_0/StructureSample.xml examples/StructureSample_v1_0_xml.json
		@bin/sdmxfeeder --level ERROR test/fixtures/xml/v2_0/StructureSample.xml examples/StructureSample_v2_0_xml.json
		@bin/sdmxfeeder --level ERROR test/fixtures/xml/v1_0/GenericSample.xml examples/GenericSample_v1_0_xml.json
		@bin/sdmxfeeder --level ERROR test/fixtures/xml/v2_0/GenericSample.xml examples/GenericSample_v2_0_xml.json
		@bin/sdmxfeeder --level ERROR test/fixtures/xml/v1_0/CompactSample.xml examples/CompactSample_v1_0_xml.json
		@bin/sdmxfeeder --level ERROR test/fixtures/xml/v2_0/CompactSample.xml examples/CompactSample_v2_0_xml.json
		@bin/sdmxfeeder --level ERROR test/fixtures/xml/v2_1/ecb_exr_rg_full.xml examples/ecb_exr_rg_full_xml.json
		@bin/sdmxfeeder --level ERROR test/fixtures/xml/v2_1/ecb_exr_rg_ts_generic.xml examples/ecb_exr_rg_ts_generic_xml.json

.PHONY: install test release samples
