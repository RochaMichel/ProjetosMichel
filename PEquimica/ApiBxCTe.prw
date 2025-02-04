#include "TOTVS.ch"
#include "RESTFUL.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} ApiBxCTe
 WebService para disponibilização do cadastro de produto
@author  Cod.erp Tecnologia
@since   28/09/2023
@version 1.0  
/*/
//-------------------------------------------------------------------
WsRestful ApiBxCTe Description "WebService de cliente"
	WSDATA DATAMOV AS STRING OPTIONAL
	WsMethod GET Description "Disponibilização dos cliente" WSSYNTAX "/GET"

End WsRestful

WSMETHOD GET WSRECEIVE DATAMOV WSSERVICE ApiBxCTe


	Local nPosDTA := aScan(Self:AQueryString, {|x| AllTrim(Upper(x[1])) == "DATAMOV"})
	Local cDATA
	Local oBody
	Local cJson
	If nPosDTA > 0
		cDATA := Self:AQueryString[nPosDTA][2]
	EndIf
	oBody       := u_GetApiBxCTe(cDATA)
	cJson           := oBody:toJson()

	::SetContentType( 'application/json' )
	::SetResponse(cJson)

    /*
	SetRestFault(400,"Ops")
    Return .F.
    */
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetApiBxCTe
 WebService para disponibilização do cadastro de produto
@author  Cod.Erp Tecnologia
@since   28/09/2023
@version 1.0
/*/
//-------------------------------------------------------------------

User Function GetApiBxCTe(cDATA)
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
	cQuery += " INNER JOIN SF2010 SF2 ON F2_XCTENUM = E1_XCTENUM AND E1_FILIAL = F2_FILIAL "
	cQuery += " INNER JOIN SD2010 SD2 ON F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA "
	cQuery += " WHERE E1_FILIAL LIKE '03%' "
	cQuery += " AND E1_TIPO = 'CTE' "
	cQuery += " AND E1_SALDO <> E1_VALOR "
	//cQuery += "AND A1_MSEXP = '' "
	If !Empty(cDATA)
		cQuery += " AND E1_MOVIMEN BETWEEN '"+cDATA+"' AND 'ZZZZZZZZ'"
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
			oLine["valor_pago"] := ((TMP->E1_VALOR+TMP->E1_JUROS+TMP->E1_MULTA)-TMP->E1_SALDO)-TMP->E1_DESCONT
			//if SA1->(DbSeek(xFilial('SA1')+TMP->A1_COD+TMP->A1_LOJA))
			//	Reclock('SA1',.F.)
			//	SA1->A1_MSEXP := DtoS(dDatabase)
			//	SA1->(MsUnlock())
			//EndIf
			AADD(oBody["NF_Cte"],oLine)
			TMP->(DbSkip())
		EndDo
	Else
		SetRestFault(404,'CTE : "'+cDATA+'",Status: Chave Nao encontrada ',.T.)
	EndIf
// Se montou o ambiente, desmonta
	If lAtivAmb
		RPCClearEnv()
	Endif

Return oBody

