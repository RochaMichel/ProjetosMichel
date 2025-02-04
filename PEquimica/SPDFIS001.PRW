#INCLUDE 'PROTHEUS.CH'

User Function SPDFIS001
	Local aTipo := ParamIXB[1]

	AADD(aTipo, {"00", "00"})
	AADD(aTipo, {"01", "01"})
	AADD(aTipo, {"02", "02"})
	AADD(aTipo, {"03", "03"})
	AADD(aTipo, {"04", "04"})
	AADD(aTipo, {"05", "05"})
	AADD(aTipo, {"06", "06"})
	AADD(aTipo, {"07", "07"})
	AADD(aTipo, {"08", "08"})
	AADD(aTipo, {"09", "09"})
	AADD(aTipo, {"10", "10"})
    AADD(aTipo, {"90", "99"})
	AADD(aTipo, {"99", "99"})

Return aTipo
