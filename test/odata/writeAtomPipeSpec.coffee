helpers = require '../pipeTestHelper'
sdmx = require '../../lib/pipe/sdmxPipe'
testData = require '../fixtures/testData'


describe 'WriteAtomPipe', ->


	it 'writes atom feed documents', (done) ->

		before = []
		before.push testData.header

		after = []
		after[0] = """
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata">
<id>Quarterly BoP reporting</id>
<title>Quarterly BoP reporting</title>
<updated>2010-02-13T14:00:33.000Z</updated>

"""
		after[1] = """
</feed>
"""

		helpers.runTest [ 'WRITE_ATOM' ], before, after, done


	it 'writes series into atom (oData) files', (done) ->

		before = []
		before.push testData.header
		before.push testData.codelist
		before.push testData.dataStructureDefinition
		before.push testData.series

		after = []
		after[3] = """
<entry>
  <id>id</id>
  <title/>
  <updated>1900</updated>
  <content type="application/xml">
    <m:properties>
      <d:FREQ>M</d:FREQ>
      <d:CURRENCY>GBP</d:CURRENCY>
      <d:CURRENCY_DENOM>EUR</d:CURRENCY_DENOM>
      <d:EXR_TYPE>SP00</d:EXR_TYPE>
      <d:EXR_VAR>E</d:EXR_VAR>
      <d:DECIMALS>5</d:DECIMALS>
      <d:UNIT_MEASURE>GBP</d:UNIT_MEASURE>
      <d:COLL_METHOD>Average of observations through period</d:COLL_METHOD>
      <d:OBS_STATUS>A</d:OBS_STATUS>
      <d:CONF_STATUS_OBS>F</d:CONF_STATUS_OBS>
      <d:obsDimension>2010-08</d:obsDimension>
      <d:obsValue m:type="Edm.Double">0.82363</d:obsValue>
    </m:properties>
  </content>
</entry>
<entry>
  <id>id</id>
  <title/>
  <updated>1900</updated>
  <content type="application/xml">
    <m:properties>
      <d:FREQ>M</d:FREQ>
      <d:CURRENCY>GBP</d:CURRENCY>
      <d:CURRENCY_DENOM>EUR</d:CURRENCY_DENOM>
      <d:EXR_TYPE>SP00</d:EXR_TYPE>
      <d:EXR_VAR>E</d:EXR_VAR>
      <d:DECIMALS>5</d:DECIMALS>
      <d:UNIT_MEASURE>GBP</d:UNIT_MEASURE>
      <d:COLL_METHOD>Average of observations through period</d:COLL_METHOD>
      <d:OBS_STATUS>A</d:OBS_STATUS>
      <d:CONF_STATUS_OBS>F</d:CONF_STATUS_OBS>
      <d:obsDimension>2010-09</d:obsDimension>
      <d:obsValue m:type="Edm.Double">0.82987</d:obsValue>
    </m:properties>
  </content>
</entry>
<entry>
  <id>id</id>
  <title/>
  <updated>1900</updated>
  <content type="application/xml">
    <m:properties>
      <d:FREQ>M</d:FREQ>
      <d:CURRENCY>GBP</d:CURRENCY>
      <d:CURRENCY_DENOM>EUR</d:CURRENCY_DENOM>
      <d:EXR_TYPE>SP00</d:EXR_TYPE>
      <d:EXR_VAR>E</d:EXR_VAR>
      <d:DECIMALS>5</d:DECIMALS>
      <d:UNIT_MEASURE>GBP</d:UNIT_MEASURE>
      <d:COLL_METHOD>Average of observations through period</d:COLL_METHOD>
      <d:OBS_STATUS>A</d:OBS_STATUS>
      <d:CONF_STATUS_OBS>F</d:CONF_STATUS_OBS>
      <d:obsDimension>2010-10</d:obsDimension>
      <d:obsValue m:type="Edm.Double">0.87637</d:obsValue>
    </m:properties>
  </content>
</entry>

"""

		helpers.runTest [ 'WRITE_ATOM' ], before, after, done


