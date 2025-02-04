#include "TOTVS.ch"
#include "RESTFUL.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Produtos
 WebService para disponibilização do cadastro de produto
@author  Michel Rocha
@since   26/11/2024
@version 1.0  
/*/
//-------------------------------------------------------------------
WsRestful CashUpProd Description "WebService de Produtos"
	WSDATA codigo AS STRING OPTIONAL
	WsMethod GET Description "Disponibilização dos produtos" WSSYNTAX "/GET"

End WsRestful

WSMETHOD GET WSRECEIVE codigo WSSERVICE CashUpProd


	Local nPosCod := aScan(Self:AQueryString, {|x| AllTrim(Upper(x[1])) == "codigo"})
	Local cProd
	Local oBody
	Local cJson
	If nPosCod > 0
		cProd := Self:AQueryString[nPosCod][2]
	EndIf
	oBody       := u_GetProduto(cProd)
	cJson           := oBody:toJson()

	::SetContentType( 'application/json' )
	::SetResponse(cJson)

    /*
	SetRestFault(400,"Ops")
    Return .F.
    */
Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetProduto
 WebService para disponibilização do cadastro de produto
@author  Cod.Erp Tecnologia
@since   28/09/2023
@version 1.0
/*/
//-------------------------------------------------------------------

User Function GetProduto(cProd)
	Local cQuery      := ""
//	Local cCampos     := ""
	Local lAtivAmb    := .F.
	Local a           := 0
	Local oBody       := JsonObject():new()
	Local oLine       := Nil//JsonObject():new()
	Private xConteudo := ""
	Private aCampos   := {}
	Private aNomes   := {}
	Default cProd := ''

// Prepara o ambiente caso precise
	If Select("SX2") == 0
		RPCClearEnv()
		RpcSetType( 3 )
		RpcSetEnv( "01",'010101', , , "",,, , , ,  )
		lAtivAmb := .T. // Seta se precisou montar o ambiente
	Endif

	AADD(aCampos,"COD_PRODUTO")//codigo_cliente
	AADD(aCampos,"DESCR_PRODUTO")//codigo_cliente
	AADD(aCampos,"PESO_LIQ")//razao_social
	AADD(aCampos,"PESO_PC")//tipo_cliente
	AADD(aCampos,"ATIVO")//cpf_cnpj
	AADD(aCampos,"COD_NCM")//email
	AADD(aCampos,"DESCR_NCM")//limite_credito
	AADD(aCampos,"COD_GRUPO_TRIB")//limite_credito
	AADD(aCampos,"DT_CRIACAO")//limite_credito
	AADD(aCampos,"DT_ALTERACAO")//limite_credito


	AADD(aNomes,"COD_PRODUTO")
	AADD(aNomes,"DESCR_PRODUTO")
	AADD(aNomes,"PESO_LIQ")
	AADD(aNomes,"PESO_PC")
	AADD(aNomes,"ATIVO")
	AADD(aNomes,"COD_NCM")	
	AADD(aNomes,"DESCR_NCM")
	AADD(aNomes,"COD_GRUPO_TRIB")
	AADD(aNomes,"DT_CRIACAO")
	AADD(aNomes,"DT_ALTERACAO")


	//For a := 1 To Len(aCampos)
	//	cCampos := cCampos + aCampos[a] + ", "
	//Next
	//cCampos := SubStr(cCampos, 1, Len(cCampos) - 2) + Space(1)

	cQuery += " SELECT B1_COD COD_PRODUTO, TRIM(B1_DESC) DESCR_PRODUTO, B1_PESO PESO_LIQ, B1_PESBRU PESO_PC, IIF(TRIM(B1_MSBLQL) = '2', 'SIM', 'NAO') ATIVO, "
    cQuery += " B1_POSIPI COD_NCM, YD_DESC_P DESCR_NCM, B1_GRTRIB COD_GRUPO_TRIB,  "
    cQuery += " CASE WHEN SUBSTRING(B1_USERLGI, 03, 1) != ' ' AND B1_USERLGI != '' THEN "
    cQuery += "         CONVERT(VARCHAR,DATEADD(DAY,CONVERT(INT,CONCAT(ASCII(SUBSTRING(B1_USERLGI,12,1)) - 50, ASCII(SUBSTRING(B1_USERLGI,16,1)) - 50) + IIF(SUBSTRING(B1_USERLGI,08,1) = '<',10000,0)),'1996-01-01'), 103) "
    cQuery += "     ELSE '' "
    cQuery += "     END AS DT_CRIACAO, "
    cQuery += " CASE WHEN SUBSTRING(B1_USERLGA, 03, 1) != ' ' AND B1_USERLGA != '' THEN "
    cQuery += "         CONVERT(VARCHAR,DATEADD(DAY,CONVERT(INT,CONCAT(ASCII(SUBSTRING(B1_USERLGA,12,1)) - 50, ASCII(SUBSTRING(B1_USERLGA,16,1)) - 50) + IIF(SUBSTRING(B1_USERLGA,08,1) = '<',10000,0)),'1996-01-01'), 103) "
    cQuery += "     ELSE '' "
    cQuery += "     END AS DT_ALTERACAO, "
    cQuery += " B1_UM UN "
    cQuery += " FROM SB1010 SB1 "
    cQuery += " LEFT JOIN SYD010 SYD ON SYD.YD_TEC = SB1.B1_POSIPI AND SYD.YD_FILIAL = SB1.B1_FILIAL "
    cQuery += " WHERE SB1.D_E_L_E_T_ = '' AND SYD.D_E_L_E_T_ = '' "
    cQuery += " AND (LEFT(B1_COD,2) = '00' OR LEFT(B1_COD,2) = '04') "
	//cQuery += " SELECT "
	//cQuery +=  cCampos
	//cQuery += " FROM " + RetSqlName("SA1") + " SA1 "
	//cQuery += " WHERE "
    //cQuery += " SA1.D_E_L_E_T_ <> '*' "
	//cQuery += " AND A1_MSEXP = '' "
	If !Empty(cProd)
		cQuery += " AND B1_COD = '"+cProd+"'
	EndIf

	cQuery := ChangeQuery(cQuery)

	MpSysOpenQuery(cQuery, "TMP")

	SA1->(dbSetOrder(1))
	If TMP->(!EOF())
		TMP->(DBGOTOP())
		oBody["Produto"] := {}
		While TMP->(!EOF())
			oLine := JsonObject():new()
			For a := 1 To Len(aCampos)
				xConteudo := &("TMP->"+aCampos[a])
				&('oLine["'+aNomes[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar(xConteudo), '"' + Alltrim(xConteudo) + '"') )
			Next
			AADD(oBody["Produto"],oLine)
			TMP->(DbSkip())
		EndDo
	Else
		SetRestFault(404,'Produto: "'+cProd+'",Status: Nao encontrado ',.T.)
	EndIf
	TMP->(DbCloseArea())
// Se montou o ambiente, desmonta
	If lAtivAmb
		RPCClearEnv()
	Endif

Return oBody

