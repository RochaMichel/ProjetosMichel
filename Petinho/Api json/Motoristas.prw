#include "PROTHEUS.ch"
#include "RESTFUL.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Motoristas
 WebService para disponibilização do cadastro de produto
@author  Cod.erp Tecnologia
@since   28/09/2023
@version 1.0  
/*/
//-------------------------------------------------------------------
WsRestful Motoristas Description "WebService de Motoristas"
	WSDATA CODIGO AS STRING OPTIONAL
	WsMethod GET Description "Disponibilização dos Motoristas" WsSyntax "/GET"

End WsRestful

WSMETHOD GET WSRECEIVE CODIGO WSSERVICE Motoristas

Local nPosCod := aScan(Self:AQueryString, {|x| AllTrim(Upper(x[1])) == "CODIGO"})
Local cCodigo
Local oBody
Local cJson
If nPosCod > 0
	cCodigo := Self:AQueryString[nPosCod][2]
EndIf
oBody       := u_GetMotoristas(cCodigo)
cJson           := oBody:toJson()

::SetContentType( 'application/json' )
::SetResponse(cJson)

    /*
	SetRestFault(400,"Ops")
    Return .F.
    */
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMotoristas
 WebService para disponibilização do cadastro de produto
@author  Cod.erp Tecnologia
@since   28/09/2023
@version 1.0
/*/
//-------------------------------------------------------------------

User Function GetMotoristas(cCodigo)
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
		RpcSetEnv( "01",'010101', , , "",,, , , ,  )
		lAtivAmb := .T. // Seta se precisou montar o ambiente
	Endif

	AADD(aCampos,"DA4_COD")//codigo_Motoristas
	AADD(aCampos,"DA4_NOME")//nome
	AADD(aCampos,"DA4_NREDUZ")//codigo_supervisor
	AADD(aCampos,"DA4_CGC")//codigo_supervisor
                
	AADD(aNomes,"codigo_motorista")
	AADD(aNomes,"nome")
	AADD(aNomes,"nome_reduzido")
	AADD(aNomes,"CPF/CNPJ")


	For a := 1 To Len(aCampos)
		cCampos := cCampos + aCampos[a] + ", "
	Next

	cCampos := SubStr(cCampos, 1, Len(cCampos) - 2) + Space(1)

	cQuery += "SELECT "
	cQuery += cCampos
	cQuery += ", CASE "
    cQuery +=" WHEN DA4.D_E_L_E_T_ <> '*' THEN 0 "
    cQuery +=" ELSE 1 "
    cQuery +="    END AS DELETADO  " 
	cQuery += "FROM " + RetSqlName("DA4") + " DA4 "
	cQuery += "WHERE "
	cQuery += " DA4_MSEXP = '' "
	If !Empty(cCodigo)
		cQuery += "AND DA4_COD = '"+cCodigo+"'
	EndIf
	cQuery := ChangeQuery(cQuery)

	MpSysOpenQuery(cQuery, "TMP")
	dbSelectArea('DA4')
	DA4->(dbSetOrder(1))
	If TMP->(!EOF())
		TMP->(DBGOTOP())
		oBody["Motoristas"] := {}
		While TMP->(!EOF())
			oLine       := JsonObject():new()
			For a := 1 To Len(aCampos)
				xConteudo := &("TMP->"+aCampos[a])
				&('oLine["'+aNomes[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar(xConteudo), '"' + EncodeUtf8(Alltrim(xConteudo)) + '"') )
			Next
			oLine["deletado"] := TMP->DELETADO
			if DA4->(DbSeek(xFilial('DA4')+TMP->DA4_COD))
				Reclock('DA4',.F.)
				DA4->DA4_MSEXP := DtoS(dDatabase)
				DA4->(MsUnlock())
			EndIf
			AADD(oBody["Motoristas"],oLine)
			TMP->(DbSkip())
		EndDo
	Else
		SetRestFault(404,'Motorista: '+cCodigo+',Status: Nao encontrado ',.T.)
	EndIf
// Se montou o ambiente, desmonta
	If lAtivAmb
		RPCClearEnv()
	Endif

Return oBody

