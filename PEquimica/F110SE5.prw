User Function F110SE5()
	Local aRecno := ParamIxb[1]
	Local nCntFor :=0
	dbSelectArea("SE5")
	DbSetOrder(1)
	For nCntFor := 1 to Len(aRecno)
		SE5->(dbGoto(aRecno[nCntFor]))
    //MSGAlert("Titulo posicionado na SE5 Filial:" + SE5->e5_filial + Chr(13)Chr(10) + ", Data," DtOC(SE5->e5_data) + Chr(13)+Chr(10) + ", Tipo," + SE5->e5_tipo + Chr(13)+Chr(10) + ", Moeda" + SE5->e5_moeda + Chr(13)+Chr(10) + ", Valor," + str(SE5->e5_valor ) + Chr(13)+Chr(10) + ", Natureza," + SE5->e5_natureza + Chr(13)+Chr(10) + ", Numero do cheque," + SE5->e5_numcheq + Chr(13)+Chr(10) + ", Documento," + SE5->e5_documen )
	Next nCntFor
Return Nil
