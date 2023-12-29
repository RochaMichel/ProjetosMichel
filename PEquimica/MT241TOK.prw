#Include 'Protheus.ch'

User Function MT241TOK()

	Local lRet := .T.
	If SD3->D3_TM == GETMV("MV_XTMBASE",,"002")
        SD3->D3_CUSTO1 := 0
	EndIF
Return lRet
