#Include 'Totvs.ch'
User Function MTA103OK()
	Local lRet := .T.
	Local cCond := Posicione('SE4',1,xFilial('SE4')+ccondicao,'E4_COND')
	If ddEmissao+GetDToVal(cCond) < MSdate()+GetMV('MV_XDIAVENC',,7)
		DbSelectArea('ZF1')
		ZF1->(DbsetOrder(1))
		If ZF1->(Dbseek(cFilant+cNfiscal+cSerie+cA100For+cLoja+cEspecie))
			If !Empty(ZF1->ZF1_USERAP)
				lRet := .T.
			Else
				FWAlertError("Doc Vencido precisa de aprovacao")
				lRet := .F.
			EndIf
		Else
			Reclock('ZF1',.T.)
			ZF1->ZF1_FILIAL := cFilant
			ZF1->ZF1_DOC    := cNfiscal
			ZF1->ZF1_SERIE  := cSerie
			ZF1->ZF1_FORNEC := cA100For
			ZF1->ZF1_LOJA   := cLoja
			ZF1->ZF1_TIPO   := cEspecie
			ZF1->ZF1_USERAP := "" 
			ZF1->(MsUnlock())
			FWAlertError("Doc Vencido precisa de aprovacao")
			lRet := .F.
		EndIf
		ZF1->(DbCloseArea())
	EndIf
Return lRet
