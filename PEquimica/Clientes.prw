#include "TOTVS.ch"
#include "RESTFUL.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Clientes
 WebService para disponibilização do cadastro de produto
@author  Cod.erp Tecnologia
@since   28/09/2023
@version 1.0  
/*/
//-------------------------------------------------------------------
WsRestful Clientes Description "WebService de cliente"
	WSDATA CGC AS STRING OPTIONAL
	WsMethod GET Description "Disponibilização dos cliente" WSSYNTAX "/GET"

End WsRestful

WSMETHOD GET WSRECEIVE CGC WSSERVICE Clientes


	Local nPosCGC := aScan(Self:AQueryString, {|x| AllTrim(Upper(x[1])) == "CGC"})
	Local cCGC
	Local oBody
	Local cJson
	If nPosCGC > 0
		cCGC := Self:AQueryString[nPosCGC][2]
	EndIf
	oBody       := u_Getcliente(cCGC)
	cJson           := oBody:toJson()

	::SetContentType( 'application/json' )
	::SetResponse(cJson)

    /*
	SetRestFault(400,"Ops")
    Return .F.
    */
Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} Getcliente
 WebService para disponibilização do cadastro de produto
@author  Cod.Erp Tecnologia
@since   28/09/2023
@version 1.0
/*/
//-------------------------------------------------------------------

User Function Getcliente(cCGC)
	Local cQuery      := ""
	Local cCampos     := ""
	Local lAtivAmb    := .F.
	Local a           := 0
	Local oBody       := JsonObject():new()
	Local oLine       := Nil//JsonObject():new()
	Private xConteudo := ""
	Private aCampos   := {}
	Private aNomes   := {}
	Default cCGC := ''

// Prepara o ambiente caso precise
	If Select("SX2") == 0
		RPCClearEnv()
		RpcSetType( 3 )
		RpcSetEnv( "03",'010101', , , "",,, , , ,  )
		lAtivAmb := .T. // Seta se precisou montar o ambiente
	Endif

	AADD(aCampos,"A1_COD")//codigo_cliente
	AADD(aCampos,"A1_LOJA")//codigo_cliente
	AADD(aCampos,"A1_NOME")//razao_social
	AADD(aCampos,"A1_TIPO")//tipo_cliente
	AADD(aCampos,"A1_CGC")//cpf_cnpj
	AADD(aCampos,"A1_EMAIL")//email
	AADD(aCampos,"A1_LC")//limite_credito


	AADD(aNomes,"codigo_cliente")
	AADD(aNomes,"loja_cliente")
	AADD(aNomes,"nome")
	AADD(aNomes,"tipo_cliente")
	AADD(aNomes,"cpf_cnpj")
	AADD(aNomes,"email")	
	AADD(aNomes,"limite_credito")

 
	For a := 1 To Len(aCampos)
		cCampos := cCampos + aCampos[a] + ", "
	Next

	cCampos := SubStr(cCampos, 1, Len(cCampos) - 2) + Space(1)

	cQuery += " SELECT "
	cQuery +=  cCampos
	cQuery += " FROM " + RetSqlName("SA1") + " SA1 "
	cQuery += " WHERE "
    cQuery += " SA1.D_E_L_E_T_ <> '*' "
	cQuery += " AND A1_MSEXP = '' "
	If !Empty(cCGC)
		cQuery += "AND A1_CGC = '"+cCGC+"'
	EndIf

	cQuery := ChangeQuery(cQuery)

	MpSysOpenQuery(cQuery, "TMP")
	dbSelectArea('SA1')
	SA1->(dbSetOrder(1))
	If TMP->(!EOF())
		TMP->(DBGOTOP())
		oBody["cliente"] := {}
		While TMP->(!EOF())
			oLine := JsonObject():new()
			For a := 1 To Len(aCampos)
				xConteudo := &("TMP->"+aCampos[a])
				&('oLine["'+aNomes[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar(xConteudo), '"' + EncodeUtf8(Alltrim(xConteudo)) + '"') )
			Next
			if SA1->(DbSeek(xFilial('SA1')+TMP->A1_COD+TMP->A1_LOJA))
				Reclock('SA1',.F.)
				SA1->A1_MSEXP := DtoS(dDatabase)
				SA1->(MsUnlock())
			EndIf
			AADD(oBody["cliente"],oLine)
			TMP->(DbSkip())
		EndDo
	Else
		SetRestFault(404,'Cliente: "'+cCGC+'",Status: Nao encontrado ',.T.)
	EndIf
// Se montou o ambiente, desmonta
	If lAtivAmb
		RPCClearEnv()
	Endif

Return oBody

