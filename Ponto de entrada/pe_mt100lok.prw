#include 'protheus.ch'
#include 'parmtype.ch'

User Function MT100LOK()
	Local lExecuta := ParamIxb[1]
	Local nOper  := aScan(aHeader,{|x|Alltrim(x[2])=="D1_OPER"})
	Local nNfori := aScan(aHeader,{|x|Alltrim(x[2])=="D1_NFORI"})
	Local _cUsuAlm := GETMV("OR_USUALM")
	//Local ExpL1 := PARAMIXB[1] //Validações do UsuárioReturn ExpL1
	local _cPedinf := BUSCACOLS("D1_PEDIDO")
	Local _cUsrNF := RetCodUsr()
	Local i := 0
	Local cOper := 'A8'
	Local lRefresh := .F.

	// Validações do usuário para inclusão ou alteração do item na NF de Despesas de Importação
	// Verific o conteudo do parametro MV_PCNFE
	// UsrRetGrp()
	If lExecuta // Deverá conter .T. para continuar
		if M->F1_TIPO <> "D"
			IF _cUsrNF $(_cUsuAlm)
				IF Empty(_cPedinf)
					MsgInfo( UsrFullName(RetCodUsr())+" Informe os dados do pedido de compras para prosseguir - MT100Lok ", 'ATENCAO !!!' )
					lExecuta := .F.
				Endif
			Endif
		Endif
		// Cod.erp 18/04/2023 para prencher o campo de D1_OPER quando a NFORI estiver preenchida
		If cfilAnt == '0101'
			For i := 1 to len(aCols)
				If !Empty(aCols[i][nNfori]) .And. Empty(aCols[i][nOper])
					aCols[i][nOper] := cOper
					lRefresh := .T.
				EndIf
			Next
			If Type('oGetDados') <> 'U' .AND. lRefresh == .T.
				oGetDados:ForceRefresh()
			EndIf
		EndIf
	EndIf
Return (lExecuta)
