#include "PROTHEUS.ch"
#include "RESTFUL.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"

User Function Gettabpreco(cCodigo)
	Local cQuery      := ""
	Local cCampos      := ""
	Local cCamposP     := ""
	Local lAtivAmb    := .F.
    Local N           := 0
	Local a           := 0
	Local oBody       := JsonObject():new()
	Local oLine       := Nil//JsonObject():new()
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
		RpcSetEnv( "01",'020101', , , "",,, , , ,  )
		lAtivAmb := .T. // Seta se precisou montar o ambiente
	Endif

	AADD(aCampos,"DA0_CODTAB")// codigo_tabela_preco
//AADD(aCampos,"E1_EMISSAO")// situacao             
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

	AADD(aNomes,"codigo_tabela_preco    ")
//AADD(aNomes,"situacao     ")
//AADD(aNomes,"codigo_regional    ")
	AADD(aNomes,"data_inicio_vigencia     ")
	AADD(aNomes,"data_termino_vigencia     ")
//AADD(aNomes,"codigo_tabela_preco_produto")
	AADD(aNomesP,"codigo_produto")
	AADD(aNomesP,"codigo_tabela_preco ")
	AADD(aNomesP,"valor_produto ")
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
	cQuery += "ON DA1_CODTAB = DA0_CODTAB"
	cQuery += "WHERE DA0.D_E_L_E_T_ <> '*' "
	cQuery += "AND DA1.D_E_L_E_T_ <> '*' "
	If !Empty(cCodigo)
		cQuery += "AND DA0_CODTAB = '"+cCodigo+"'
	EndIf
    cQuery += " Order By DA0_CODTAB"
	cQuery := ChangeQuery(cQuery)

	MpSysOpenQuery(cQuery, "TMP")

	TMP->(DBGOTOP())
	oBody["tabpreco"] := {}
	While TMP->(!EOF())
		oLine       := JsonObject():new()
		cCodtab := TMP->DA0_CODTAB
		For a := 1 To Len(aCampos)
			xConteudo := &("TMP->"+aCampos[a])
			&('oLine["'+aNomes[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar(xConteudo), '"' + EncodeUtf8(Alltrim(xConteudo)) + '"') )
		Next
		While TMP->(!EOF()) .AND. TMP->DA0_CODTAB = cCodtab
            oBody["tabpreco"] := Array(Len(aCamposP))
            n := 1
			For a := 1 To Len(aCamposP)
                oBody["tabpreco"][n] := JsonObject():New()
				xConteudo := &("TMP->"+aCamposP[a])
				&('oBody["tabpreco"][n]["'+aNomesP[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar(xConteudo), '"' + EncodeUtf8(Alltrim(xConteudo)) + '"') )
			Next
            n++
			TMP->(DbSkip())
		EndDo
		AADD(oBody["tabpreco"],oLine)
	EndDo

// Se montou o ambiente, desmonta
	If lAtivAmb
		RPCClearEnv()
	Endif

Return oBody


