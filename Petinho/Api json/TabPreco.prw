#include "PROTHEUS.ch"
#include "RESTFUL.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TabPreco
 WebService para disponibilização do cadastro de produto
@author  Cod.erp Tecnologia
@since   28/09/2023
@version 1.0  
/*/
//-------------------------------------------------------------------
WsRestful Tabpreco Description "WebService de tabpreco"
	WSDATA CODIGO AS STRING OPTIONAL
	WsMethod GET  Description "Disponibilização dos tabpreco" WsSyntax "/GET"

End WsRestful

WSMETHOD GET  WSRECEIVE CODIGO WSSERVICE Tabpreco

	Local nPosCod := aScan(Self:AQueryString, {|x| AllTrim(Upper(x[1])) == "CODIGO"})
	Local cCodigo
	Local oBody
	Local cJson
	If nPosCod > 0
		cCodigo := Self:AQueryString[nPosCod][2]

	EndIf
	oBody       := u_Gettabpreco(cCodigo)
	cJson           := oBody:toJson()

	::SetContentType( 'application/json' )
	::SetResponse(cJson)

    /*
	SetRestFault(400,"Ops")
    Return .F.
    */
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Getusuario
 WebService para disponibilização do cadastro de produto
@author  RDS Tecnologia
@since   03/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------

User Function Gettabpreco(cCodigo)
	Local cQuery      := ""
	Local cCampos      := ""
	Local cCamposP     := ""
	Local lAtivAmb    := .F.
	Local a           := 0
	Local oBody       := JsonObject():new()
	Private xConteudo := ""
	Private aCampos   := {}
	Private aCamposP   := {}
	Private aNomes   := {}
	Private aNomesP   := {}
	Default cCodigo := ''

// Prepara o ambiente caso precise
	If Select("SX2") == 0
		RPCClearEnv()
		RpcSetType( 3 )
		RpcSetEnv( "01",'010101', , , "",,, , , ,  )
		lAtivAmb := .T. // Seta se precisou montar o ambiente
	Endif

	AADD(aCampos,"DA0_CODTAB")// codigo_tabela_preco
//AADD(aCampos,"E1_EMISSAO")// situacao             
	AADD(aCampos,"DA0_DESCRI")// Descrição
//AADD(aCampos,"B1_UM")   // codigo_regional          
	AADD(aCampos,"DA0_DATDE") // data_inicio_vigencia
	AADD(aCampos,"DA0_DATATE")// data_termino_vigencia
//AADD(aCampos,"DA1_CODTAB")   //codigo_tabela_preco_produto         
	AADD(aCamposP,"DA1_CODPRO")  //codigo_produto
	AADD(aCamposP,"DA1_CODTAB")    //codigo_tabela_preco
	AADD(aCamposP,"DA1_PRCVEN") //valor_produto
	AADD(aCamposP,"DA1_ESTADO")  //codigo_regional
//AADD(aCampos,"B1_GRUPO") //permite_desconto                      
	AADD(aCamposP,"DA1_PERDES")  //percentual_desconto
//AADD(aCampos,"B1_PESO")  //situacao                              

	AADD(aNomes,"codigo_tabela_preco")
//AADD(aNomes,"situacao     ")
    AADD(aNomes,"descricao_tabela")
	AADD(aNomes,"data_inicio_vigencia")
	AADD(aNomes,"data_termino_vigencia")
//AADD(aNomes,"codigo_tabela_preco_produto")
	AADD(aNomesP,"codigo_produto")
	AADD(aNomesP,"codigo_tabela_preco")
	AADD(aNomesP,"valor_produto")
	AADD(aNomesP,"codigo_regional")
//AADD(aNomes,"permite_desconto")            
	AADD(aNomesP,"percentual_desconto")
//AADD(aNomes,"situacao")          

	For a := 1 To Len(aCampos)
		cCampos := cCampos + aCampos[a] + ", "
	Next

	cCampos := SubStr(cCampos, 1, Len(cCampos) - 2) + Space(1)

	For a := 1 To Len(aCamposP)
		cCamposP := cCamposP + aCamposP[a] + ", "
	Next

	cCamposP := SubStr(cCamposP, 1, Len(cCamposP) - 2) + Space(1)

	cQuery += "SELECT "
	cQuery += cCampos+","+cCamposP
	cQuery += "FROM " + RetSqlName("DA0") + " DA0 "
	cQuery += "INNER JOIN " + RetSqlName("DA1") + " DA1 "
	cQuery += "ON DA1_CODTAB = DA0_CODTAB "
	cQuery += "WHERE  "
	cQuery += " DA0_ATIVO = '1' "
	cQuery += " AND DA0.D_E_L_E_T_ <> '*'  "
	cQuery += " AND DA1.D_E_L_E_T_ <> '*' "
	If !Empty(cCodigo)
		cQuery += "AND DA0_CODTAB = '"+cCodigo+"'
	EndIf
	cQuery += " Order By DA0_CODTAB "
	cQuery := ChangeQuery(cQuery)

	MpSysOpenQuery(cQuery, "TMP")
	dbSelectArea('DA1')
	DA1->(dbSetOrder(1))
	If TMP->(!EOF())
		TMP->(DBGOTOP())
		oBody["tabpreco"] := {}
		While TMP->(!EOF())
			oLine := JsonObject():new()
			For a := 1 To Len(aCampos)
				xConteudo := &("TMP->"+aCampos[a])
				&('oLine["'+aNomes[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar(xConteudo), '"' + EncodeUtf8(Alltrim(xConteudo)) + '"'))
			Next
			cCodtab := TMP->DA0_CODTAB
			oLine['Produtos'] := {}
			While TMP->(!EOF()) .AND. TMP->DA0_CODTAB == cCodtab
				oLineP      := JsonObject():new()
				For a := 1 To Len(aCamposP) 
					xConteudo := &("TMP->"+aCamposP[a])
					if posicione('SB1',1,xFilial('SB1')+TMP->DA1_CODPRO,'B1_TIPCONV') == 'D'
						if aNomesP[a] == "valor_produto" 
							&('oLineP["'+aNomesP[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar((xConteudo*posicione('SB1',1,xFilial('SB1')+TMP->DA1_CODPRO,'B1_CONV'))), '"' + EncodeUtf8(Alltrim(xConteudo)) + '"'))
						Else
							&('oLineP["'+aNomesP[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar(xConteudo), '"' + EncodeUtf8(Alltrim(xConteudo)) + '"'))
						EndIF
					Else
						&('oLineP["'+aNomesP[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar(xConteudo), '"' + EncodeUtf8(Alltrim(xConteudo)) + '"'))
					EndIf
				Next
				AADD(oLine["Produtos"],oLineP)
				TMP->(DbSkip())
			EndDo
			AADD(oBody["tabpreco"],oLine)
		EndDo
	Else
		SetRestFault(404,'Codigo da tabela de preco: '+cCodigo+' ,Status: Nao encontrada' ,.T.)
	EndIf
// Se montou o ambiente, desmonta
	If lAtivAmb
		RPCClearEnv()
	Endif

Return oBody
