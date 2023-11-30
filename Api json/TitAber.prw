#include "PROTHEUS.ch"
#include "RESTFUL.ch"
#Include "topconn.ch" 
#Include "tbiconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TitAber
 WebService para disponibilizaÁ„o do cadastro de produto
@author  Cod.erp Tecnologia
@since   28/09/2023
@version 1.0  
/*/
//-------------------------------------------------------------------
WsRestful Titaberto Description "WebService de titaberto"
	WSDATA CGC AS STRING
	WsMethod GET  Description "Disponibilizacao dos titaberto" WsSyntax "/GET"

End WsRestful

WSMETHOD GET  WSRECEIVE CGC WSSERVICE Titaberto

Local nPosCod := aScan(Self:AQueryString, {|x| AllTrim(Upper(x[1])) == "CGC"})
Local cCGC
Local oBody
Local cJson
If nPosCod > 0
	cCGC := Self:AQueryString[nPosCod][2]

EndIf
oBody       := u_Gettitaberto(cCGC)
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
 WebService para disponibiliza√ß√£o do cadastro de titaberto
@author  RDS Tecnologia
@since   03/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------

User Function Gettitaberto(cCGC)
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
		RpcSetEnv( "01",'020101', , , "",,, , , ,  )
		lAtivAmb := .T. // Seta se precisou montar o ambiente
	Endif

	AADD(aCampos,"E1_CLIENTE")   //codigo_cliente
	AADD(aCampos,"E1_EMISSAO")  //data_emissao
//AADD(aCampos,"B1_UM")    //codigo_regional      
	AADD(aCampos,"E1_PEDIDO") //codigo_pedido
	AADD(aCampos,"E1_PARCELA")  //numero_parcela
	AADD(aCampos,"E1_SALDO") //saldo
	AADD(aCampos,"E1_TIPO")  //tipo_pagamento
	AADD(aCampos,"E1_VALOR")  //valor
	AADD(aCampos,"E1_VENCREA")//data_vencimento
	AADD(aCampos,"E1_SITUACA")//situacao


	AADD(aNomes,"codigo_cliente")
	AADD(aNomes,"data_emissao")
//AADD(aNomes,"codigo_regional  ")
	AADD(aNomes,"codigo_pedido")
	AADD(aNomes,"numero_parcela")
	AADD(aNomes,"saldo")
	AADD(aNomes,"tipo_pagamento")
	AADD(aNomes,"valor")
	AADD(aNomes,"data_vencimento")
	AADD(aNomes,"situacao")


	For a := 1 To Len(aCampos)
		cCampos := cCampos + aCampos[a] + ", "
	Next

	cCampos := SubStr(cCampos, 1, Len(cCampos) - 2) + Space(1)

	cQuery += "SELECT "
	cQuery += cCampos
	cQuery += "FROM " + RetSqlName("SE1") + " SE1 "
	cQuery += "Inner join "+ RetSqlName('SA1')+" SA1 "
	cQuery += "ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
	cQuery += "WHERE SE1.D_E_L_E_T_ <> '*' "
	cQuery += "AND E1_SALDO > 0 "
	cQuery += "AND A1_CGC = '"+cCGC+"'

	cQuery := ChangeQuery(cQuery)

	MpSysOpenQuery(cQuery, "TMP")

	If TMP->(!EOF())
		TMP->(DBGOTOP())
		oBody["titaberto"] := {}
		While TMP->(!EOF())
			oLine       := JsonObject():new()
			For a := 1 To Len(aCampos)
				xConteudo := &("TMP->"+aCampos[a])
				&('oLine["'+aNomes[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar(xConteudo), '"' + EncodeUtf8(Alltrim(xConteudo)) + '"') )
			Next
			AADD(oBody["titaberto"],oLine)
			TMP->(DbSkip())
		EndDo
	Else
		SetRestFault(404,' titulos do Cliente: '+cCGC+' ,Status : Nao encontrado',.T.)
	EndIf

// Se montou o ambiente, desmonta
	If lAtivAmb
		RPCClearEnv()
	Endi

Return oBody

