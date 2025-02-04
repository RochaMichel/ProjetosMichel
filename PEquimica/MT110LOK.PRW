#Include "TOTVS.CH"

User Function MT110LOK()
	Local nPosTipo := aScan(aHeader, {|x| AllTrim(x[2]) == 'C1_XTIPO'})
	Local nPosObsT := aScan(aHeader, {|x| AllTrim(x[2]) == 'C1_XOBSTP'}) 
	Local cTipo := Alltrim(aCols[n,nPosTipo])
	Local cObsTp := Alltrim(aCols[n,nPosObsT])
	Local lValido := .T.
	Local nPosCDR    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XCMPDIR'})
	Local nPosCOD    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_PRODUTO'})

	cTipo := posicione("sb1",1,xfilial("sb1")+aCols[n][nPosCOD],"B1_TIPO")
	If aCols[n][nPosCDR] == "1"
		If !(cTipo $ GetMV('MV_XCMPDIR',,"07"))
			lValido := .F.
			FWAlertError("Esse Produto não pode ser compra direta","Mensagem de erro")
		EndIf
	EndIf

	If cTipo $ '2/3'
		If Empty(cObsTp)
			FwAlertError("Em pedidos urgentes/emergenciais deve ser informado o motivo da urgencia!")
			lValido := .F.
		EndIf
	EndIf

Return(lValido)
