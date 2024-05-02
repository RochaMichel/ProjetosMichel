#include "TOTVS.ch"
#include "RESTFUL.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} StatusPed
 WebService para disponibilização do cadastro de produto
@author  Cod.erp Tecnologia
@since   28/09/2023 
@version 1.0  
/*/
//-------------------------------------------------------------------

WsRestful StatusPed Description "WebService de StatusPed"
	WSDATA PEDIDO AS STRING OPTIONAL
	WsMethod GET Description "Disponibilização dos StatusPed" WSSYNTAX "/GET"

End WsRestful

WSMETHOD GET WSRECEIVE PEDIDO WSSERVICE StatusPed

	Local nPosPedido := aScan(Self:AQueryString, {|x| AllTrim(Upper(x[1])) == "PEDIDO"})
	Local cPedido
	Local oBody
	Local cJson
	If nPosPedido > 0
		cPedido := Self:AQueryString[nPosPedido][2]
	EndIf
	oBody       := u_GetStatus(cPedido)
	cJson           := oBody:toJson()

	::SetContentType( 'application/json' )
	::SetResponse(cJson)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetStatus
 WebService para disponibilização do cadastro de produto
@author  Cod.Erp Tecnologia
@since   28/09/2023
@version 1.0
/*/
//-------------------------------------------------------------------

User Function GetStatus(cPedido)
	Local cQuery      := ""
	Local cCampos     := ""
	Local lAtivAmb    := .F.
	Local a           := 0
	Local oBody       := JsonObject():new()
	Local oLine       := Nil//JsonObject():new()
	Private xConteudo := ""
	Private aCampos   := {}
	Private aNomes   := {}
	Default cPedido := ''

// Prepara o ambiente caso precise
	If Select("SX2") == 0
		RPCClearEnv()
		RpcSetType( 3 )
		RpcSetEnv( "01",'010101', , , "",,, , , ,  )
		lAtivAmb := .T. // Seta se precisou montar o ambiente
	Endif

	AADD(aCampos,"C9_PEDIDO")//codigo_cliente
	AADD(aCampos,"C9_ITEM")//codigo_cliente
	AADD(aCampos,"C9_SEQUEN")//nome
	AADD(aCampos,"C9_PRODUTO")//razao_social
	AADD(aCampos,"C9_BLEST")//razao_social  
	AADD(aCampos,"C9_BLCRED")//razao_social
	AADD(aCampos,"C9_CARGA")//razao_social
	AADD(aCampos,"C9_NFISCAL")//razao_social
	AADD(aCampos,"C9_SERIENF")//razao_social

	AADD(aNomes,"Pedido")
	AADD(aNomes,"Item")
	AADD(aNomes,"Sequencia")
	AADD(aNomes,"Produto")
	AADD(aNomes,"Bloqueio_Estoque")
	AADD(aNomes,"Bloqueio_Credito")
	AADD(aNomes,"Codigo_carga")
	AADD(aNomes,"numero_NF")
	AADD(aNomes,"Serie_NF")


	For a := 1 To Len(aCampos)
		cCampos := cCampos + aCampos[a] + ", "
	Next

	cCampos := SubStr(cCampos, 1, Len(cCampos) - 2) + Space(1)

	cQuery += "SELECT "
	cQuery +=  cCampos
	cQuery += "FROM " + RetSqlName("SC9") + " SC9 "
	cQuery += "WHERE SC9.D_E_L_E_T_ <> '*' "
	If !Empty(cPedido)
		cQuery += "AND C9_PEDIDO = '"+cPedido+"'
	EndIf

	cQuery := ChangeQuery(cQuery)

	MpSysOpenQuery(cQuery, "TMP")

	If TMP->(!EOF())
		TMP->(DBGOTOP())
		oBody["Status_Pedido"] := {}
		While TMP->(!EOF())
			oLine := JsonObject():new()
			For a := 1 To Len(aCampos)
				xConteudo := &("TMP->"+aCampos[a])
				&('oLine["'+aNomes[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar(xConteudo), '"' + EncodeUtf8(Alltrim(xConteudo)) + '"') )
			Next
			AADD(oBody["Status_Pedido"],oLine)
			TMP->(DbSkip())
		EndDo
	Else
		oBody['Code'] :=  404
		oBody['pedido'] := cPedido
		oBody['status'] := 'pedido não encontrado'
	EndIf
// Se montou o ambiente, desmonta
	If lAtivAmb
		RPCClearEnv()
	Endif

Return oBody

