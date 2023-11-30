#include "PROTHEUS.ch"
#include "RESTFUL.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} Veiculos
 WebService para disponibiliza��o do cadastro de produto
@author  Cod.erp Tecnologia
@since   28/09/2023
@version 1.0  
/*/
//-------------------------------------------------------------------
WsRestful Veiculos Description "WebService de Veiculos"
	WSDATA CODIGO AS STRING OPTIONAL
	WsMethod GET  Description "Disponibilização dos Veiculos" WsSyntax "/GET"

End WsRestful

WSMETHOD GET  WSRECEIVE CODIGO WSSERVICE Veiculos

Local nPosCod := aScan(Self:AQueryString, {|x| AllTrim(Upper(x[1])) == "CODIGO"})
Local cCodigo
Local oBody
Local cJson
If nPosCod > 0
	cCodigo := Self:AQueryString[nPosCod][2]

EndIf
oBody       := u_GetVeiculos(cCodigo)
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
 WebService para disponibilização do cadastro de Veiculos
@author  RDS Tecnologia
@since   03/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------

User Function GetVeiculos(cCodigo)
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

	AADD(aCampos,"DA3_COD"   ) //codigo_veiculo
	AADD(aCampos,"DA3_DESC"  ) //descricao_veiculo
	AADD(aCampos,"DA3_ESTPLA") //codigo_regional
//AADD(aCampos,"B1_SEGUM") //cubagem              
	AADD(aCampos,"DA3_ANOFAB") //ano
	AADD(aCampos,"DA3_ANOMOD") //ano_modelo
	AADD(aCampos,"DA3_PLACA"   ) //placa_1
//AADD(aCampos,"B1_PESO"   ) //placa_2                  
//AADD(aCampos,"B1_PESBRU" ) //placa_3                 
//AADD(aCampos,"B1_PESBRU" ) //placa_4                 
	AADD(aCampos,"DA3_DESC" ) //modelo
//AADD(aCampos,"B1_PESBRU" ) //Rntrc                 
	AADD(aCampos,"DA3_CORVEI" ) //cor
	AADD(aCampos,"DA3_CHASSI" ) //chassi
	AADD(aCampos,"DA3_RENAVA" ) //renavam
//AADD(aCampos,"B1_PESBRU" ) //peso_bruto_tot                 
	AADD(aCampos,"DA3_TARA" ) //tara
//AADD(aCampos,"" ) //cap_carga_peso                 
//AADD(aCampos,"B1_PESBRU" ) //tap_mts_cubicos                 
	AADD(aCampos,"DA3_TIPVEI" ) //tipo_veiculo

	AADD(aNomes,"codigo_veiculo")
	AADD(aNomes,"descricao_veiculo")
	AADD(aNomes,"codigo_regional")
//AADD(aNomes,"cubagem")
	AADD(aNomes,"ano")
	AADD(aNomes,"ano_modelo")
	AADD(aNomes,"placa_1")
//AADD(aNomes,"placa_2")            
//AADD(aNomes,"placa_3")      
//AADD(aNomes,"placa_4")      
	AADD(aNomes,"modelo")
//AADD(aNomes,"Rntrc")      
	AADD(aNomes,"cor")
	AADD(aNomes,"chassi")
	AADD(aNomes,"renavam")
//AADD(aNomes,"peso_bruto_tot")      
	AADD(aNomes,"tara")
//AADD(aNomes,"cap_carga_peso")      
//AADD(aNomes,"tap_mts_cubicos")      
	AADD(aNomes,"tipo_veiculo")


	For a := 1 To Len(aCampos)
		cCampos := cCampos + aCampos[a] + ", "
	Next

	cCampos := SubStr(cCampos, 1, Len(cCampos) - 2) + Space(1)

	cQuery += "SELECT "
	cQuery += cCampos
	cQuery += "FROM " + RetSqlName("DA3") + " DA3 "
	cQuery += "WHERE DA3.D_E_L_E_T_ <> '*' "
	If !Empty(cCodigo)
		cQuery += "AND DA3_COD = '"+cCodigo+"'
	EndIf
	cQuery := ChangeQuery(cQuery)

	MpSysOpenQuery(cQuery, "TMP")

	If TMP->(!EOF())
		TMP->(DBGOTOP())
		oBody["Veiculos"] := {}
		While TMP->(!EOF())
			oLine       := JsonObject():new()
			For a := 1 To Len(aCampos)
				xConteudo := &("TMP->"+aCampos[a])
				&('oLine["'+aNomes[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar(xConteudo), '"' + EncodeUtf8(Alltrim(xConteudo)) + '"') )
			Next
			AADD(oBody["Veiculos"],oLine)
			TMP->(DbSkip())
		EndDo
	Else
		SetRestFault(404,'Veiculo: '+cCodigo+',Status: Nao encontrado ',.T.)
	EndIf
// Se montou o ambiente, desmonta
	If lAtivAmb
		RPCClearEnv()
	Endif

Return oBody

