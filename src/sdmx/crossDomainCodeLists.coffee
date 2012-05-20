
CL_OBS_STATUS =
	id: 'CL_OBS_STATUS'
	agencyID: 'SDMX'
	version: '1.0'
	isPartial: false
	name:
		en: 'Code list for Observation Status (OBS_STATUS)'
	description:
		en: 'This code list provides coded information about the "status" of an
		     observation (with respect events such  as the ones reflected in the codes
		     composing the code list).'
	codes:
		A:
			id: 'A'
			name:
				en: 'Normal'
		B:
			id: 'B'
			name:
				en: 'Break'
		E:
			id: 'E'
			name:
				en: 'Estimated value'
		F:
			id: 'F'
			name:
				en: 'Forecast value'
		I:
			id: 'I'
			name:
				en: 'Imputed value'
		M:
			id: 'M'
			name:
				en: 'Missing value'
		P:
			id: 'P'
			name:
				en: 'Provisional value'
		S:
			id: 'S'
			name:
				en: 'Strike'


CL_FREQ =
	id: 'CL_FREQ'
	agencyID: 'SDMX'
	version: '1.0'
	isPartial: false
	name:
		en: 'Code list for Frequency (FREQ)'
	description:
		en: 'It provides a list of values indicating the "frequency" of the data
			(e.g. monthly) and, thus, indirectly, also implying the type of
			"time reference" that could be used for identifying the data with respect time.'
	codes:
		A:
			id: 'A'
			name:
				en: 'Annual'
		S:
			id: 'S'
			name:
				en: 'Half-yearly'
		Q:
			id: 'Q'
			name:
				en: 'Quarterly'
		M:
			id: 'M'
			name:
				en: 'Monthly'
		W:
			id: 'W'
			name:
				en: 'Weekly'
		D:
			id: 'D'
			name:
				en: 'Daily'
		B:
			id: 'B'
			name:
				en: 'Daily - business week'
		N:
			id: 'N'
			name:
				en: 'Minutely'


exports.CL_OBS_STATUS = CL_OBS_STATUS
exports.CL_FREQ = CL_FREQ
