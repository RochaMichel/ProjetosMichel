#Include 'totvs.ch'
#Include 'Restful.ch'
#Include "topconn.ch"
#Include "tbiconn.ch"



WsRestful CashUpCli Description "WebService de clientes"
    WSDATA CGC AS STRING OPTIONAL
	WsMethod GET Description "Disponibilizacao dos clientes" WSSYNTAX "/GET"

End WsRestful

WSMETHOD GET WSRECEIVE CGC WSSERVICE CashUpCli

	Local nPosCli := aScan(Self:AQueryString, {|x| AllTrim(Upper(x[1])) == "CGC"})
	Local cCliente
	Local oBody
	Local cJson
	If nPosCli > 0
		cCliente := Self:AQueryString[nPosCli][2]
	EndIf
	oBody       := u_GetCliCash(cCliente)
	cJson           := oBody:toJson()

	::SetContentType( 'application/json' )
	::SetResponse(cJson)

Return .T.
/**/
// Retorna todos os pedidos com legenda - LIBERAROS
//WsMethod GET Clientes WsService cashUP

  
    // Tratamento para paginação
   // BeginSql Alias cAlias
    
 User Function GetCliCash(cCliente)
	Local cQuery      := ""
//	Local cCampos     := ""
	Local lAtivAmb    := .F.
	Local a           := 0
	Local oBody       := JsonObject():new()
	Local oLine       := Nil//JsonObject():new()
	Private xConteudo := ""
	Private aCampos   := {}
	Private aNomes   := {}
	Default cCliente := ''
	
// Prepara o ambiente caso precise
	If Select("SX2") == 0
		RPCClearEnv()
		RpcSetType( 3 )
		RpcSetEnv( "01",'010101', , , "",,, , , ,  )
		lAtivAmb := .T. // Seta se precisou montar o ambiente
	Endif

	AADD(aCampos,"COD_CLI") //COD_CLI
	AADD(aCampos,"NOME_CLI") // NOME_CLI
	AADD(aCampos,"RAZAO_CLI") // RAZAO_CLI
	AADD(aCampos,"IE") //IE
	AADD(aCampos,"ENDERECO") //ENDERECO
	AADD(aCampos,"BAIRRO") //BAIRRO
	AADD(aCampos,"CIDADE") //CIDADE
	AADD(aCampos,"UF") //UF
	AADD(aCampos,"COMPLEMENTO") //COMPLEMENTO
    AADD(aCampos,"CEP") //CEP
    AADD(aCampos,"TEL_GERAL") //TEL_GERAL
    AADD(aCampos,"EMAIL_CLI") //EMAIL_CLI
    AADD(aCampos,"SITE") //SITE
    AADD(aCampos,"DT_CRIACAO") //DT_CRIACAO
    AADD(aCampos,"DT_ALTERACAO") //DT_ALTERACAO
    AADD(aCampos,"ATIVO") //ATIVO
    AADD(aCampos,"TPJUR") //DT_ALTERACAO

    AADD(aNomes,"COD_CLI") //COD_CLI
	AADD(aNomes,"NOME_CLI") // NOME_CLI
	AADD(aNomes,"RAZAO_CLI") // RAZAO_CLI
	AADD(aNomes,"IE") //IE
	AADD(aNomes,"ENDERECO") //ENDERECO
	AADD(aNomes,"BAIRRO") //BAIRRO
	AADD(aNomes,"CIDADE") //CIDADE
	AADD(aNomes,"UF") //UF
	AADD(aNomes,"COMPLEMENTO") //COMPLEMENTO
    AADD(aNomes,"CEP") //CEP
    AADD(aNomes,"TEL_GERAL") //TEL_GERAL
    AADD(aNomes,"EMAIL_CLI") //EMAIL_CLI
    AADD(aNomes,"SITE") //SITE
    AADD(aNomes,"DT_CRIACAO") //DT_CRIACAO
    AADD(aNomes,"DT_ALTERACAO") //DT_ALTERACAO
    AADD(aNomes,"ATIVO") //ATIVO
    AADD(aNomes,"TPJUR") //DT_ALTERACAO

    /*
	cQuery += " SELECT CONCAT(A1_COD, ' / ',A1_LOJA) COD_CLI, TRIM(A1_NREDUZ) NOME_CLI, TRIM(A1_NOME) RAZAO_CLI, A1_CGC CNPJ_CLI, A1_INSCR IE, TRIM(A1_END) ENDERECO, TRIM(A1_BAIRRO) BAIRRO, TRIM(A1_MUN) CIDADE, A1_EST UF, TRIM(A1_COMPLEM) COMPLEMENTO, " 
	cQuery += " A1_CEP CEP, CONCAT(A1_DDD,' ',A1_TEL) TEL_GERAL, TRIM(A1_EMAIL) EMAIL_CLI, TRIM(A1_IPWEB) SITE, IIF(TRIM(A1_MSBLQL) = '2', 'SIM', 'NAO') AS ATIVO, " 
	cQuery += " CASE TRIM(A1_TPJ) " 
	cQuery += "  WHEN '1' THEN 'ME' " 
	cQuery += "  WHEN '2' THEN 'EPP' " 
	cQuery += "  WHEN '3' THEN 'MEI' " 
	cQuery += "  ELSE 'NAO OPTANTE' " 
	cQuery += " END TPJUR " 
	cQuery += "     FROM SA1010 SA1 " 
	cQuery += "     WHERE SA1.D_E_L_E_T_ = '' " 
    */

	cQuery += " SELECT CONCAT(A1_COD, ' / ',A1_LOJA) COD_CLI, TRIM(A1_NREDUZ) NOME_CLI, TRIM(A1_NOME) RAZAO_CLI, A1_CGC CNPJ_CLI, A1_INSCR IE, TRIM(A1_END) ENDERECO, TRIM(A1_BAIRRO) BAIRRO, TRIM(A1_MUN) CIDADE, A1_EST UF, TRIM(A1_COMPLEM) COMPLEMENTO, " 
	cQuery += " A1_CEP CEP, CONCAT(A1_DDD,' ',A1_TEL) TEL_GERAL, TRIM(A1_EMAIL) EMAIL_CLI, TRIM(A1_IPWEB) SITE,  " 
	cQuery += " CASE WHEN SUBSTRING(A1_USERLGI, 03, 1) != ' ' AND A1_USERLGI != '' THEN " 
    cQuery += " CONVERT(VARCHAR,DATEADD(DAY,CONVERT(INT,CONCAT(ASCII(SUBSTRING(A1_USERLGI,12,1)) - 50, ASCII(SUBSTRING(A1_USERLGI,16,1)) - 50) + IIF(SUBSTRING(A1_USERLGI,08,1) = '<',10000,0)),'1996-01-01'), 103) " 
    cQuery += " ELSE '' " 
    cQuery += " END AS DT_CRIACAO, " 
	cQuery += " CASE WHEN SUBSTRING(A1_USERLGA, 03, 1) != ' ' AND A1_USERLGA != '' THEN " 
    cQuery += " CONVERT(VARCHAR,DATEADD(DAY,CONVERT(INT,CONCAT(ASCII(SUBSTRING(A1_USERLGA,12,1)) - 50, ASCII(SUBSTRING(A1_USERLGA,16,1)) - 50) + IIF(SUBSTRING(A1_USERLGA,08,1) = '<',10000,0)),'1996-01-01'), 103) " 
    cQuery += " ELSE '' " 
    cQuery += " END AS DT_ALTERACAO, " 
	cQuery += " IIF(TRIM(A1_MSBLQL) = '2', 'SIM', 'NAO') AS ATIVO, " 
	cQuery += " CASE TRIM(A1_TPJ) " 
    cQuery += " WHEN '1' THEN 'ME' " 
    cQuery += " WHEN '2' THEN 'EPP' " 
    cQuery += " WHEN '3' THEN 'MEI' " 
    cQuery += " ELSE 'NAO OPTANTE' "  
	cQuery += " END TPJUR " 
	cQuery += " FROM SA1010 SA1 " 
	cQuery += " WHERE SA1.D_E_L_E_T_ = '' " 



    If !Empty(cCliente)
		cQuery += " AND A1_CGC = '"+cCliente+"'
	EndIf

	cQuery := ChangeQuery(cQuery)

	MpSysOpenQuery(cQuery, "TMP")

	If TMP->(!EOF())
		TMP->(DBGOTOP())
		oBody["Cliente"] := {}
		While TMP->(!EOF())
			oLine := JsonObject():new()
			For a := 1 To Len(aCampos)
				xConteudo := &("TMP->"+aCampos[a])
				&('oLine["'+aNomes[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar(xConteudo), '"' + Alltrim(xConteudo) + '"') )
			Next
			AADD(oBody["Cliente"],oLine)
			TMP->(DbSkip())
		EndDo
	Else
		SetRestFault(404,'Cliente: "'+cCliente+'",Status: Nao encontrado ',.T.)
	EndIf
	TMP->(DbCloseArea())
// Se montou o ambiente, desmonta
	If lAtivAmb
		RPCClearEnv()
	Endif

Return oBody




