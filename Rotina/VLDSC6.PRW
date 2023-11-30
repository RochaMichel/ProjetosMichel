#Include "TOTVS.ch"

user function VldSc6(nCod)
local nI
local nTotal   := 0
local nDescont := 0
	Do Case
	CASE nCod == 1  // valor total
		For nI:=1 to Len(aCols) 
			nTotal += GdFieldGet("C6_XPRCORI",nI)*GdFieldGet("C6_QTDVEN",nI)
        Next 
        M->C5_XVALOR := nTotal
        //return nTotal
        //GdFieldPut("C5_XVALOR",nTotal)   
	CASE nCod == 2  // valor desconto
        For nI:=1 to Len(aCols)
			nDescont += GdFieldGet("C6_XVALDES",nI)
        Next 
        M->C5_XVALDES := nDescont
       //return nDescont
       //GdFieldPut("C5_XVALDES",nDescont)   
	CASE nCod == 3  // valor final
        For nI:=1 to Len(aCols)
			nTotal   += GdFieldGet("C6_VALOR",nI)
        Next
        M->C5_XVlrFin := nTotal
        //Return nTotalF
        //GdFieldPut("C5_XVlrFin",nTotalF)   
	End Case
return 
