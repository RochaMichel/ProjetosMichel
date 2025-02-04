#Include "TOTVS.CH"

User Function  MT120LOK()
	Local nPosCDR    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_XCMPDIR'})
	Local nPosCOD    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_PRODUTO'})
	Local lValido := .T.
	cTipo := posicione("sb1",1,xfilial("sb1")+aCols[n][nPosCOD],"B1_TIPO")
	If aCols[n][nPosCDR] == "1"
		If !(cTipo $ GetMV('MV_XCMPDIR',,"07"))
			lValido := .F.
			FWAlertError( "Esse Produto não pode ser compra direta","Mensagem de erro")
		EndIf
	EndIf
Return(lValido)

