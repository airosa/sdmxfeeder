
testArray = [
	[['UNA:+.? ']]
	[['UNB'],['UNOC','3'],['4F0'],['ZZZ'],['001201','1410'],['IREF000215'],[],['GESMES/CB'],[],[],[],['1']]
	[['UNH'],['MREF000001'],['GESMES','2','1','E6']]
	[['BGM'],['73']]
	[['NAD'],['Z02'],['ECB']]
	[['NAD'],['MR'],['ZZZ']]
	[['NAD'],['MS'],['4F0']]
	[['IDE'],['10'],['Test metadata']]
	[['VLI'],['CL_ADJUSTMENT'],[],[],['Adjustment code list']]
	[['CDV'],['EPS']]
	[['FTX'],['ACM'],[],[],['Danmarks Nationalbank']]
	[['CDV'],['TEST1']]
	[['FTX'],['ACM'],[],[],['Test1']]
	[['CDV'],['TEST2']]
	[['FTX'],['ACM'],[],[],['Test2','More Test2']]
	[['STC'],['SOURCE_AGENCY']]
	[['FTX'],['ACM'],[],[],['Source agency']]
	[['STC'],['CONCEPT2']]
	[['FTX'],['ACM'],[],[],['Concept2']]
	[['ASI'],['TEST1']]
	[['FTX'],['ACM'],[],[],['DSD: data sructure definition']]
	[['SCD'],['13'],['FREQ'],[],[],[],['','1']]
	[['ATT'],['3'],['5'],['','','','AN1']]
	[['IDE'],['1'],['CL_FREQ']]
	[['SCD'],['4'],['REF_AREA'],[],[],[],['','2']]
	[['ATT'],['3'],['5'],['','','','AN2']]
	[['IDE'],['1'],['CL_AREA_EE']]
	[['SCD'],['1'],['TIME_PERIOD'],[],[],[],['','3']]
	[['ATT'],['3'],['5'],['','','','AN..35']]
	[['SCD'],['1'],['TIME_FORMAT'],[],[],[],['','4']]
	[['ATT'],['3'],['5'],['','','','AN3']]
	[['SCD'],['3'],['OBS_VALUE'],[],[],[],['','5']]
	[['ATT'],['3'],['5'],['','','','AN..15']]
	[['SCD'],['3'],['OBS_STATUS'],[],[],[],['','6']]
	[['ATT'],['3'],['5'],['','','','AN1']]
	[['ATT'],['3'],['35'],['2','USS']]
	[['ATT'],['3'],['32'],['5','ALV']]
	[['IDE'],['1'],['CL_OBS_STATUS']]
	[['SCD'],['Z09'],['TITLE']]
	[['ATT'],['3'],['5'],['','','','AN..70']]
	[['ATT'],['3'],['35'],['2','USS']]
	[['ATT'],['3'],['32'],['9','ALV']]
	[['SCD'],['Z09'],['UNIT_MULT']]
	[['ATT'],['3'],['5'],['','','','AN..2']]
	[['ATT'],['3'],['35'],['2','USS']]
	[['ATT'],['3'],['32'],['4','ALV']]
	[['IDE'],['1'],['CL_UNIT_MULT']]
	[['UNT'],['77'],['MREF000001']]
	[['UNH'],['MREF000002'],['GESMES','2','1','E6']]
	[['BGM'],['74']]
	[['NAD'],['Z02'],['ECB']]
	[['NAD'],['MR'],['BIS']]
	[['NAD'],['MS'],['4F0']]
	[['IDE'],['10'],['Test data']]
	[['CTA'],['CP'],['','Mr Mark Smith']]
	[['CTA'],['CF'],['IS/BoP','Mr John Smith']]
	[['COM'],['0049 69 13440','TE']]
	[['DSI'],['ECB_BOP1']]
	[['STS'],['3'],['7']]
	[['DTM'],['242','200008091923','203']]
	[['IDE'],['5'],['SIS_FOOB']]
	[['GIS'],['AR3']]
	[['GIS'],['1','','','-']]
	[['ARR'],[],['M','YY','ZZ','199902','610','-7.9','E','C']]
	[['ARR'],[],['M','YY','ZZ','199302199305','710','21.5','A'],['23.4','A'],['43.0','E'], ['-','M']]
	[['FNS'],['Test Attributes','10']]
	[['REL'],['Z01'],['1']]
	[['ARR'],['0']]
	[['IDE'],['Z10'],['UNIT']]
	[['CDV'],['USD']]
	[['REL'],['Z01'],['4']]
	[['ARR'],['4'],['','XX','ZZ','CC']]
	[['IDE'],['Z11'],['TITLE']]
	[['FTX'],['ACM'],[],[],['MONETARY AGGREGATE M1']]
	[['REL'],['Z01'],['5']]
	[['ARR'],['6'],['A','XX','ZZ','CC','2012','602']]
	[['IDE'],['Z11'],['OBS_COM']]
	[['FTX'],['ACM'],[],[],['Comments']]
	[['UNT'],['48'],['MREF000002']]
	[['UNZ'],['2'],['IREF000215']]
]


testText = "
	UNA:+.? '
	UNB+UNOC:3+4F0+ZZZ+001201:1410+IREF000215++GESMES/CB++++1'
	UNH+MREF000001+GESMES:2:1:E6'
	BGM+73'
	NAD+Z02+ECB'
	NAD+MR+ZZZ'
	NAD+MS+4F0'
	IDE+10+Test metadata'
	VLI+CL_ADJUSTMENT+++Adjustment code list'
	CDV+EPS'
	FTX+ACM+++Danmarks Nationalbank'
	CDV+TEST1'
	FTX+ACM+++Test1'
	CDV+TEST2'
	FTX+ACM+++Test2:More Test2'
	STC+SOURCE_AGENCY'
	FTX+ACM+++Source agency'
	STC+CONCEPT2'
	FTX+ACM+++Concept2'
	ASI+TEST1'
	FTX+ACM+++DSD?: data sructure definition'
	SCD+13+FREQ++++:1'
	ATT+3+5+:::AN1'
	IDE+1+CL_FREQ'
	SCD+4+REF_AREA++++:2'
	ATT+3+5+:::AN2'
	IDE+1+CL_AREA_EE'
	SCD+1+TIME_PERIOD++++:3'
	ATT+3+5+:::AN..35'
	SCD+1+TIME_FORMAT++++:4'
	ATT+3+5+:::AN3'
	SCD+3+OBS_VALUE++++:5'
	ATT+3+5+:::AN..15'
	SCD+3+OBS_STATUS++++:6'
	ATT+3+5+:::AN1'
	ATT+3+35+2:USS'
	ATT+3+32+5:ALV'
	IDE+1+CL_OBS_STATUS'
	SCD+Z09+TITLE'
	ATT+3+5+:::AN..70'
	ATT+3+35+2:USS'
	ATT+3+32+9:ALV'
	SCD+Z09+UNIT_MULT'
	ATT+3+5+:::AN..2'
	ATT+3+35+2:USS'
	ATT+3+32+4:ALV'
	IDE+1+CL_UNIT_MULT'
	UNT+77+MREF000001'
	UNH+MREF000002+GESMES:2:1:E6'
	BGM+74'
	NAD+Z02+ECB'
	NAD+MR+BIS'
	NAD+MS+4F0'
	IDE+10+Test data'
	CTA+CP+:Mr Mark Smith'
	CTA+CF+IS/BoP:Mr John Smith'
	COM+0049 69 13440:TE'
	DSI+ECB_BOP1'
	STS+3+7'
	DTM+242:200008091923:203'
	IDE+5+SIS_FOOB'
	GIS+AR3'
	GIS+1:::-'
	ARR++M:YY:ZZ:199902:610:-7.9:E:C'
	ARR++M:YY:ZZ:199302199305:710:21.5:A+23.4:A+43.0:E+-:M'
	FNS+Test Attributes:10'
	REL+Z01+1'
	ARR+0'
	IDE+Z10+UNIT'
	CDV+USD'
	REL+Z01+4'
	ARR+4+:XX:ZZ:CC'
	IDE+Z11+TITLE'
	FTX+ACM+++MONETARY AGGREGATE M1'
	REL+Z01+5'
	ARR+6+A:XX:ZZ:CC:2012:602'
	IDE+Z11+OBS_COM'
	FTX+ACM+++Comments'
	UNT+48+MREF000002'
	UNZ+2+IREF000215'
	"

exports.testArray = testArray
exports.testText = testText
