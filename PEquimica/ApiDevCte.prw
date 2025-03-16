#include "TOTVS.ch"
#include "RESTFUL.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} ApiDevCTe
 WebService para disponibilização devolução de titulos
@author  Michel Rocha
@since   04/02/2025
@version 1.0  
/*/
//-------------------------------------------------------------------
WsRestful ApiDevCTe Description "WebService de devolucao de titulos"
	WSDATA DATAMOV AS STRING OPTIONAL
	WsMethod GET Description "Disponibilização das devolucoes de titulos" WSSYNTAX "/GET"

End WsRestful

WSMETHOD GET WSRECEIVE DATAMOV WSSERVICE ApiDevCTe


	Local nPosDTA := aScan(Self:AQueryString, {|x| AllTrim(Upper(x[1])) == "DATAMOV"})
	Local cDATA
	Local oBody
	Local cJson
	If nPosDTA > 0
		cDATA := Self:AQueryString[nPosDTA][2]
	EndIf
	oBody       := u_GetApiDevCTe(cDATA)
	cJson           := oBody:toJson()

	::SetContentType( 'application/json' )
	::SetResponse(cJson)

    /*
	SetRestFault(400,"Ops")
    Return .F.
    */
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetApiDevCTe
 WebService para disponibilização devolução de titulos
@author  Michel Rocha
@since   04/02/2025
@version 1.0
/*/
//-------------------------------------------------------------------

User Function GetApiDevCTe(cDATA)
	Local cQuery      := ""
	Local cCampos     := ""
	Local lAtivAmb    := .F.
	Local a           := 0
	Local oBody       := JsonObject():new()
	Local oLine       := Nil//JsonObject():new()
	Private xConteudo := ""
	Private aCampos   := {}
	Private aNomes   := {}
	Default cDATA := ''

// Prepara o ambiente caso precise
	If Select("SX2") == 0
		RPCClearEnv()
		RpcSetType( 3 )
		RpcSetEnv( "01",'030101', , , "",,, , , ,  )
		lAtivAmb := .T. // Seta se precisou montar o ambiente
	Endif

	AADD(aCampos,"F2_CHVNFE")//codigo_cliente
	AADD(aCampos,"E1_NUM")//codigo_cliente
	AADD(aCampos,"D2_CLASFIS")//codigo_cliente
	AADD(aCampos,"E1_SERIE")//razao_social
	AADD(aCampos,"E1_PARCELA")//razao_social
	AADD(aCampos,"E1_VALOR")//tipo_cliente
	AADD(aCampos,"E1_JUROS")//cpf_cnpj
	AADD(aCampos,"D2_VALICM")//codigo_cliente
	AADD(aCampos,"E1_MULTA")//email
	AADD(aCampos,"E1_DESCONT")//limite_credito
	AADD(aCampos,"E1_SALDO")//limite_credito
	AADD(aCampos,"E5_VALOR")//limite_credito
	
	//Chave de acesso do CTe
	//Numero do Titulo
	//Numero da Parcela do Titulo
	//Valor Recebido
	//Juros Recebido
	//Multa Recebida
	//Desconto Concedido
	//Banco, Agencia e Conta Corrente recebida (Pode ser Fixo)
	//Tipo de Baixa (is_parcial) - Integral, Parcial
	//Valor da Nova Parcela se for origem Baixa Parcial
	//Vencimento Nova Parcela se for origem Baixa Parcial

	AADD(aNomes,"chave_cte")
	AADD(aNomes,"num_tit")
	AADD(aNomes,"Situacao_tributaria")
	AADD(aNomes,"serie")
	AADD(aNomes,"parcela")
	AADD(aNomes,"valor")
	AADD(aNomes,"juros")
	AADD(aNomes,"icms")
	AADD(aNomes,"multa")
	AADD(aNomes,"desconto")
	AADD(aNomes,"saldo")
	AADD(aNomes,"valor_cancelamento")


	For a := 1 To Len(aCampos)
		cCampos := cCampos + aCampos[a] + ", "
	Next

	cCampos := SubStr(cCampos, 1, Len(cCampos) - 2) + Space(1)

	cQuery += " SELECT "
	cQuery +=  cCampos
	cQuery += ", CASE "
	cQuery +=" WHEN SE1.D_E_L_E_T_ <> '*' THEN 'NAO' "
	cQuery +=" ELSE 'SIM' "
	cQuery +="    END AS CANCELADA  "
	cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
	cQuery += " INNER JOIN " + RetSqlName("SF2") + " SF2 ON F2_XCTENUM = E1_XCTENUM AND E1_FILIAL = F2_FILIAL "
	cQuery += " INNER JOIN " + RetSqlName("SD2") + " SD2 ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE "
	cQuery += " AND F2_LOJA = D2_LOJA AND F2_CHVNFE <> '' "
    cQuery += " INNER JOIN " + RetSqlName("SE5") + " SE5 ON E1_PREFIXO = E5_PREFIXO AND E1_NUM = E5_NUMERO AND E1_PARCELA = E5_PARCELA " 
    cQuery += " AND E5_TIPO = E1_TIPO AND E1_CLIENTE = E5_CLIENTE AND  E1_LOJA = E5_LOJA AND (E5_DTCANBX <> '' OR E5_TIPODOC = 'ES')"
	cQuery += " WHERE E1_FILIAL LIKE '03%' "
	cQuery += " AND E1_TIPO = 'CTE' "
	cQuery += " AND SE1.D_E_L_E_T_ = '' "
	cQuery += " AND SE5.D_E_L_E_T_ = '' "
	cQuery += " AND SF2.D_E_L_E_T_ = '' "
	cQuery += " AND SD2.D_E_L_E_T_ = '' "
	If !Empty(cDATA)
		cQuery += " AND E5_DATA BETWEEN '"+cDATA+"' AND 'ZZZZZZZZ'"
	EndIf
	cQuery := ChangeQuery(cQuery)

	MpSysOpenQuery(cQuery, "TMP")
	dbSelectArea('SA1')
	SA1->(dbSetOrder(1))
	If TMP->(!EOF())
		TMP->(DBGOTOP())
		oBody["NF_Cte"] := {}
		While TMP->(!EOF())
			oLine := JsonObject():new()
			For a := 1 To Len(aCampos)
				xConteudo := &("TMP->"+aCampos[a])
				&('oLine["'+aNomes[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar(xConteudo), '"' + EncodeUtf8(Alltrim(xConteudo)) + '"') )
			Next
			oLine["cancelada"] := TMP->CANCELADA
			//if SA1->(DbSeek(xFilial('SA1')+TMP->A1_COD+TMP->A1_LOJA))
			//	Reclock('SA1',.F.)
			//	SA1->A1_MSEXP := DtoS(dDatabase)
			//	SA1->(MsUnlock())
			//EndIf
			AADD(oBody["NF_Cte"],oLine)
			TMP->(DbSkip())
		EndDo
	Else
		SetRestFault(404,'CTE : "'+cDATA+'",Status: Data Nao encontrada ',.T.)
	EndIf
// Se montou o ambiente, desmonta
	If lAtivAmb
		RPCClearEnv()
	Endif

Return oBody
