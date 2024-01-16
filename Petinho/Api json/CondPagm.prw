#include "PROTHEUS.ch"
#include "RESTFUL.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} CondPagm
 WebService para disponibilização do cadastro de produto
@author  Cod.erp Tecnologia
@since   28/09/2023
@version 1.0  
/*/
//-------------------------------------------------------------------
WsRestful Condpagm Description "WebService de condpagm"
	WSDATA CODIGO AS STRING OPTIONAL
	WsMethod GET  Description "Disponibilização dos condpagm" WSSYNTAX "/GET"
End WsRestful

WSMETHOD GET WSRECEIVE CODIGO WSSERVICE Condpagm

Local nPosCod := aScan(Self:AQueryString, {|x| AllTrim(Upper(x[1])) == "CODIGO"})
Local cCodigo
Local oBody
Local cJson
If nPosCod > 0
	cCodigo := Self:AQueryString[nPosCod][2]

EndIf
oBody       := u_Getcondpagm(cCodigo)
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
@author  Cod.Erp Tecnologia
@since   28/09/2023
@version 1.0
/*/
//-------------------------------------------------------------------

User Function Getcondpagm(cCodigo)
	Local cQuery      := ""
	Local cCampos     := ""
	Local lAtivAmb    := .F.
	Local a           := 0
	Local oBody       := JsonObject():new()
	Local oLine       := Nil//JsonObject():new()
	Private xConteudo := ""
	Private aCampos   := {}
	Private aNomes   := {}
	Default cCodigo := ''

// Prepara o ambiente caso precise
	If Select("SX2") == 0
		RPCClearEnv()
		RpcSetType( 3 )
		RpcSetEnv( "01",'020101', , , "",,, , , ,  )
		lAtivAmb := .T. // Seta se precisou montar o ambiente
	Endif

	AADD(aCampos,"E4_CODIGO")    //codigo_condicao_pagamento
	AADD(aCampos,"E4_DESCRI")    //descricao_condicao_pagamento
	AADD(aCampos,"E4_DDD")   //qtd_dias
	AADD(aCampos,"E4_COND")    //qtd_parcelas
	AADD(aCampos,"E4_DESCFIN")   //valor_desconto
	AADD(aCampos,"E4_ACRSFIN")   //porcentagem_pagamento
//	AADD(aCampos,"E4_TIPO")      //tipo_pagamento
//AADD(aCampos,"A1_PFISICA")  //codigo_regional                             
	AADD(aCampos,"E4_MSBLQL")    //situacao


	AADD(aNomes ,"codigo_condicao_pagamento")
	AADD(aNomes ,"descricao_condicao_pagamento")
	AADD(aNomes ,"qtd_dias")
	AADD(aNomes ,"qtd_parcelas")
	AADD(aNomes ,"valor_desconto")
	AADD(aNomes,"porcentagem_pagamento")
//	AADD(aNomes,"tipo_pagamento")
//AADD(aNomes,"codigo_regional             ")            
	AADD(aNomes,"situacao")

	For a := 1 To Len(aCampos)
		cCampos := cCampos + aCampos[a] + ", "
	Next

	cCampos := SubStr(cCampos, 1, Len(cCampos) - 2) + Space(1)

	cQuery += "SELECT "
	cQuery += cCampos
	cQuery += "FROM " + RetSqlName("SE4") + " SE4 "
	cQuery += "WHERE SE4.D_E_L_E_T_ <> '*' "
	If !Empty(cCodigo)
		cQuery += "AND E4_CODIGO = '"+cCodigo+"'
	EndIf
	cQuery := ChangeQuery(cQuery)

	MpSysOpenQuery(cQuery, "TMP")

	If TMP->(!EOF())
		TMP->(DBGOTOP())
		oBody["condpagm"] := {}
		While TMP->(!EOF())
			oLine       := JsonObject():new()
			For a := 1 To Len(aCampos)
				xConteudo := &("TMP->"+aCampos[a])
				&('oLine["'+aNomes[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar(xConteudo), '"' + EncodeUtf8(Alltrim(xConteudo)) + '"') )
			Next
			AADD(oBody["condpagm"],oLine)
			TMP->(DbSkip())
		EndDo
	Else
        SetRestFault(404,'Condicao de Pagamento: '+cCodigo+',Status: Nao encontrada ',.T.)
		//::SetResponse('{"Condição de Pagamento": "'+cCodigo+'","Status": "Não encontrada" }')
	EndIf
// Se montou o ambiente, desmonta
	If lAtivAmb
		RPCClearEnv()
	Endif

Return oBody

