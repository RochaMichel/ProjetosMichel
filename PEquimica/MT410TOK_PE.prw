#Include "TOTVS.CH"
User Function MT410TOK()
	Local nPosDT    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C6_ENTREG'})
	Local lRet 		:= .T.
	Local nX 		:= 1
	For nX := 1 to len(aCols)
		If aCols[nX][nPosDT] < dDataBase
			lRet := .F.
		EndIf
	Next
	If !lRet
		FWAlertInfo("O campo data de entrega precisa ser maior ou igual a data de hoje", "Erro no item ")
	EndIf
Return lRet

//*-----------------------------------------------------*
//User Function MT410TOK( nOpc, aRecnoSE1RA )
//*-----------------------------------------------------*
//
//Local lRet := .T. // Conteúdo de retorno
//
//lRet := MsgYesNo("Confirma a execução desta operação?")
//Help( , , "PE(MT410TOK)", , "Entrou no PE(MT410TOK)", 1, 0,,,,,,{"Após acionamento do botão Salvar"})
//
//Return (lRet)
