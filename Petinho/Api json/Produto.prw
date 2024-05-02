#include "PROTHEUS.ch"
#include "RESTFUL.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Produto
 WebService para disponibilização do cadastro de produto
@author  Cod.erp Tecnologia
@since   28/09/2023
@version 1.0  
/*/
//-------------------------------------------------------------------
WsRestful Produto Description "WebService de Produto"
	WSDATA CODIGO AS STRING OPTIONAL
	WsMethod GET Description "Disponibilização dos Produto" WSSYNTAX "/GET"

End WsRestful

WSMETHOD GET WSRECEIVE CODIGO WSSERVICE Produto

Local nPosCod := aScan(Self:AQueryString, {|x| AllTrim(Upper(x[1])) == "CODIGO"})
Local cCodigo
Local oBody
Local cJson
If nPosCod > 0
	cCodigo := Self:AQueryString[nPosCod][2]

EndIf
oBody       := u_GetProduto(cCodigo)
cJson           := oBody:toJson()

::SetContentType( 'application/json' )
::SetResponse(cJson)

    /*
	SetRestFault(400,"Ops")
    Return .F.
    */
Return .T.

User Function GetProduto(cCodigo)
	Local cQuery      := ""
	Local cCampos     := ""
	Local cCampos1     := ""
	Local lAtivAmb    := .F.
	Local a           := 0
	Local oBody       := JsonObject():new()
	Local oLine       := Nil//JsonObject():new()
	Private xConteudo := ""
	Private aCampos   := {}
	Private aCampos1   := {}
	Private aNomes   := {}
	Private aNomes1   := {}
	Default cCodigo := ''

// Prepara o ambiente caso precise
	If Select("SX2") == 0
		RPCClearEnv()
		RpcSetType( 3 )
		RpcSetEnv( "01",'010101', , , "",,, , , ,  )
		lAtivAmb := .T. // Seta se precisou montar o ambiente
	Endif

	AADD(aCampos,"B1_COD")   // codigo_produto
	AADD(aCampos,"B1_DESC")  //  nome_produto
	AADD(aCampos,"B1_UM")    //     unidade_medida
	AADD(aCampos,"B1_SEGUM")   //  embalagem
	AADD(aCampos,"B1_DESC")// descricao_produto
	AADD(aCampos,"B1_GRUPO")//   grupo_produto
	AADD(aCampos,"B1_TIPO")   //   tipo_produto
	AADD(aCampos,"B1_PESO") //  peso_liquido
	AADD(aCampos,"B1_PESBRU") //       peso_bruto
	AADD(aCampos,"B1_CONV") //       peso_bruto
	AADD(aCampos1,"B5_COMPR") //       peso_bruto
	AADD(aCampos1,"B5_LARG") //       peso_bruto
	AADD(aCampos1,"B5_ALTURA") //       peso_bruto


	AADD(aNomes,"codigo_produto")
	AADD(aNomes,"nome_produto")
	AADD(aNomes,"unidade_medida")
	AADD(aNomes,"embalagem")
	AADD(aNomes,"descricao_produto")
	AADD(aNomes,"grupo_produto")
	AADD(aNomes,"tipo_produto")
	AADD(aNomes,"peso_liquido")
	AADD(aNomes,"peso_bruto")
	AADD(aNomes,"fator_conversao")
	AADD(aNomes1,"comprimento")
	AADD(aNomes1,"largura")
	AADD(aNomes1,"altura")
//AADD(aNomes,"comissao ")     
//AADD(aNomes,"situacao ")     

	For a := 1 To Len(aCampos)
		cCampos := cCampos + aCampos[a] + ", "
	Next
	For a := 1 To Len(aCampos1)
		cCampos1 := cCampos1 + aCampos1[a] + ", "
	Next
	cCampos := SubStr(cCampos, 1, Len(cCampos) - 2) + Space(1)
	cCampos1 := SubStr(cCampos1, 1, Len(cCampos1) - 2) + Space(1)

	cQuery += "SELECT "
	cQuery += cCampos+","+cCampos1 
	cQuery += ", CASE "
    cQuery +=" WHEN SB1.D_E_L_E_T_ <> '*' THEN 0 "
    cQuery +=" ELSE 1 "
    cQuery +="    END AS DELETADO  " 
	cQuery += "FROM " + RetSqlName("SB1") + " SB1 "
	cQuery += "INNER JOIN "+ RetSqlName("SB5")+" SB5 "
	cQuery += "ON B1_COD = B5_COD "
	cQuery += "WHERE  "
	cQuery += " B1_TIPO = 'PA' "
	cQuery += "AND B1_MSEXP = '' "
	If !Empty(cCodigo)
		cQuery += "AND B1_COD = '"+cCodigo+"'
	EndIf
	cQuery := ChangeQuery(cQuery)

	MpSysOpenQuery(cQuery, "TMP")
		dbSelectArea('SB1')
	SB1->(dbSetOrder(1))
	If TMP->(!EOF())
		TMP->(DBGOTOP())
		oBody["produto"] := {}
		While TMP->(!EOF())
			oLine       := JsonObject():new()
			For a := 1 To Len(aCampos)
				xConteudo := &("TMP->"+aCampos[a])
				If VALTYPE(xConteudo) == 'C'
					xConteudo := NoSpeChar(xConteudo)
				EndIf
				&('oLine["'+aNomes[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar(xConteudo), '"' + EncodeUtf8(Alltrim(xConteudo)) + '"') )
			Next
			For a := 1 To Len(aCampos1)
				xConteudo := &("TMP->"+aCampos1[a])
				If VALTYPE(xConteudo) == 'C'
					xConteudo := NoSpeChar(xConteudo)
				EndIf
				&('oLine["'+aNomes1[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar(xConteudo), '"' + EncodeUtf8(Alltrim(xConteudo)) + '"') )
			Next
			oLine["deletado"] := TMP->DELETADO
			if SB1->(DbSeek(xFilial('SB1')+TMP->B1_COD))
				Reclock('SB1',.F.)
				SB1->B1_MSEXP := DtoS(dDatabase)
				SB1->(MsUnlock())
			EndIf
			AADD(oBody["produto"],oLine)
			TMP->(DbSkip())
		EndDo
	Else
		SetRestFault(404,'Produto: '+cCodigo+',Status: Nao encontrado ',.T.)
	EndIf

// Se montou o ambiente, desmonta
	If lAtivAmb
		RPCClearEnv()
	Endif

Return oBody

Static Function NoSpeChar(cString)
	local cRet := cString
	cRet = NoAcento(cRet)
	cRet = strtran (cRet, "°", ".")
	cRet = strtran (cRet, "º", ".")
	cRet = strtran (cRet, "ª", ".")
	cRet = strtran (cRet, "'", "")
	cRet = strtran (cRet, '"', "")
	cRet = strtran (cRet, ";", ",")
	cRet = strtran (cRet, "|", "")
	cRet = strtran (cRet, chr(9), "") // TAB
	cRet = strtran (cRet, Chr(13)+Chr(10), "") // ENTER
return cRet

