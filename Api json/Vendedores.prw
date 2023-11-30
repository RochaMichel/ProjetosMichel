#include "PROTHEUS.ch"
#include "RESTFUL.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Vendedores
 WebService para disponibilização do cadastro de produto
@author  Cod.erp Tecnologia
@since   28/09/2023
@version 1.0  
/*/
//-------------------------------------------------------------------
WsRestful Vendedores Description "WebService de Vendedores"
	WSDATA CODIGO AS STRING OPTIONAL
	WsMethod GET  Description "Disponibilização dos Vendedores" WsSyntax "/GET"

End WsRestful

WSMETHOD GET  WSRECEIVE CODIGO WSSERVICE Vendedores

Local nPosCod := aScan(Self:AQueryString, {|x| AllTrim(Upper(x[1])) == "CODIGO"})
Local cCodigo
Local oBody
Local cJson
If nPosCod > 0
	cCodigo := Self:AQueryString[nPosCod][2]
EndIf
oBody       := u_GetVendedores(cCodigo)
cJson           := oBody:toJson()

::SetContentType( 'application/json' )
::SetResponse(cJson)

    /*
	SetRestFault(400,"Ops")
    Return .F.
    */
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetVendedores
 WebService para disponibilização do cadastro de produto
@author  RDS Tecnologia
@since   03/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------

User Function GetVendedores(cCodigo)
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

	AADD(aCampos,"A3_COD")//codigo_Vendedores
	AADD(aCampos,"A3_NOME")//nome
	AADD(aCampos,"A3_SUPER")//codigo_supervisor
	AADD(aCampos,"A3_GEREN")//codigo_supervisor
                
	AADD(aNomes,"codigo_vendedore")
	AADD(aNomes,"nome")
	AADD(aNomes,"codigo_supervisor")
	AADD(aNomes,"codigo_gerente")


	For a := 1 To Len(aCampos)
		cCampos := cCampos + aCampos[a] + ", "
	Next

	cCampos := SubStr(cCampos, 1, Len(cCampos) - 2) + Space(1)

	cQuery += "SELECT "
	cQuery += cCampos
	cQuery += "FROM " + RetSqlName("SA3") + " SA3 "
	cQuery += "WHERE SA3.D_E_L_E_T_ <> '*' "
	If !Empty(cCodigo)
		cQuery += "AND A3_COD = '"+cCodigo+"'
	EndIf
	cQuery := ChangeQuery(cQuery)

	MpSysOpenQuery(cQuery, "TMP")

	If TMP->(!EOF())
		TMP->(DBGOTOP())
		oBody["Vendedores"] := {}
		While TMP->(!EOF())
			oLine       := JsonObject():new()
			For a := 1 To Len(aCampos)
				xConteudo := &("TMP->"+aCampos[a])
				&('oLine["'+aNomes[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar(xConteudo), '"' + EncodeUtf8(Alltrim(xConteudo)) + '"') )
			Next
			AADD(oBody["Vendedores"],oLine)
			TMP->(DbSkip())
		EndDo
	Else
		SetRestFault(404,'Vendedores: '+cCodigo+',Status: Nao encontrado ',.T.)
	EndIf
// Se montou o ambiente, desmonta
	If lAtivAmb
		RPCClearEnv()
	Endif

Return oBody

