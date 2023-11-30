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
		RpcSetEnv( "01",'020101', , , "",,, , , ,  )
		lAtivAmb := .T. // Seta se precisou montar o ambiente
	Endif

	AADD(aCampos,"A1_COD")//codigo_cliente
	AADD(aCampos,"A1_LOJA")//codigo_cliente
	AADD(aCampos,"A1_NREDUZ")//nome
	AADD(aCampos,"A1_NOME")//razao_social
	AADD(aCampos,"A1_TIPO")//tipo_cliente
	AADD(aCampos,"A1_CGC")//cpf_cnpj
	AADD(aCampos,"A1_INSCR")//inscricao_estadual
	AADD(aCampos,"A1_INSCRM")//inscricao_municipal
	AADD(aCampos,"A1_PFISICA")//rg
	AADD(aCampos,"A1_EMAIL")//email
	AADD(aCampos,"A1_TEL")//telefone
	AADD(aCampos,"A1_TEL") //celular
	AADD(aCampos,"A1_CEP")//cep
	AADD(aCampos,"A1_END")//endereco
	AADD(aCampos,"A1_COMPENT")//complemento
	AADD(aCampos,"A1_BAIRRO")//bairro
	AADD(aCampos,"A1_MUN")//cidade
	AADD(aCampos,"A1_ESTADO")//estado
	AADD(aCampos,"A1_CEPE")//cep_entrega
	AADD(aCampos,"A1_ENDENT")//endereco_entrega
	AADD(aCampos,"A1_COMPENT")//complemento_entrega 
	AADD(aCampos,"A1_BAIRROE")//bairro_entrega
	AADD(aCampos,"A1_MUNE")//cidade_entrega
	AADD(aCampos,"A1_EST")//estado_entrega
	AADD(aCampos,"A1_TABELA")//codigo_tabela_preco
	AADD(aCampos,"A1_VEND")//codigo_vendedor
	AADD(aCampos,"A1_SUPER")//codigo_supervisor
	AADD(aCampos,"A1_COND")//codigo_condicao_pagamento
	AADD(aCampos,"A1_TRANSP")//rota de entrega
	AADD(aCampos,"A1_COD_MUN")//codigo_regional
	AADD(aCampos,"A1_SALDUP")//codigo_regional
	AADD(aCampos,"A1_LC")//limite_credito
	AADD(aCampos,"A1_XCODVIS")//codigo_visita
	AADD(aCampos,"A1_XORDEMV")//codigo_segmento
	AADD(aCampos,"A1_XDATAVI")//data_visita
	AADD(aCampos,"A1_CODSEG")//codigo_segmento
    AADD(aCampos,"A1_REGIAO")//codigo_roteirizacao
	AADD(aCampos,"A1_SITUA")//situacaoD
	AADD(aCampos,"A1_OBSERV")//observação
	AADD(aCampos,"A1_XLAT")//observação
	AADD(aCampos,"A1_XLONG")//observação

	AADD(aNomes,"codigo_cliente")
	AADD(aNomes,"loja_cliente")
	AADD(aNomes,"nome")
	AADD(aNomes,"razao_social")
	AADD(aNomes,"tipo_cliente")
	AADD(aNomes,"cpf_cnpj")
	AADD(aNomes,"inscricao_estadual")
	AADD(aNomes,"inscricao_municipal")
	AADD(aNomes,"rg")
	AADD(aNomes,"email")
	AADD(aNomes,"telefone")
	AADD(aNomes,"celular")
	AADD(aNomes,"cep")
	AADD(aNomes,"endereco")
	AADD(aNomes,"complemento")
	AADD(aNomes,"bairro")
	AADD(aNomes,"cidade")
	AADD(aNomes,"estado")
	AADD(aNomes,"cep_entrega")
	AADD(aNomes,"endereco_entrega")
	AADD(aNomes,"complemento_entrega")
	AADD(aNomes,"bairro_entrega")
	AADD(aNomes,"cidade_entrega")
	AADD(aNomes,"estado_entrega")
	AADD(aNomes,"codigo_tabela_preco")
	AADD(aNomes,"codigo_vendedor")
	AADD(aNomes,"codigo_supervisor")
	AADD(aNomes,"codigo_condicao_pagamento")
	AADD(aNomes,"codigo_rota_entrega")
	AADD(aNomes,"codigo_regional")
	AADD(aNomes,"saldo")
	AADD(aNomes,"limite_credito")
//AADD(aNomes,"codigo_cluster")
	AADD(aNomes,"codigo_visita")
	AADD(aNomes,"ordem_movimento")
	AADD(aNomes,"data_visita")
	AADD(aNomes,"codigo_segmento")
    AADD(aNomes,"codigo_roteirizacao")
	AADD(aNomes,"situacao")
	AADD(aNomes,"observacao")
	AADD(aNomes,"latitude")
	AADD(aNomes,"longitude")

	For a := 1 To Len(aCampos)
		cCampos := cCampos + aCampos[a] + ", "
	Next

	cCampos := SubStr(cCampos, 1, Len(cCampos) - 2) + Space(1)

	cQuery += "SELECT "
	cQuery += cCampos+',A1_LOJA'
	cQuery += "FROM " + RetSqlName("SA1") + " SA1 "
	cQuery += "WHERE A1_MSBLQL = 2 "
	cQuery += "AND SA1.D_E_L_E_T_ <> '*' "
	If !Empty(cCGC)
		cQuery += "AND A1_CGC = '"+cCGC+"'
	EndIf

	cQuery := ChangeQuery(cQuery)

	MpSysOpenQuery(cQuery, "TMP")

	If TMP->(!EOF())
		TMP->(DBGOTOP())
		oBody["cliente"] := {}
		While TMP->(!EOF())
			oLine := JsonObject():new()
			For a := 1 To Len(aCampos)
				If aCampos[a] == 'A1_COD'
					xConteudo := &("TMP->"+aCampos[a])
					&('oLine["'+aNomes[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar(xConteudo), '"' + EncodeUtf8(Alltrim(xConteudo+TMP->A1_LOJA)))+'"')
				ElseIf aCampos[a] == 'A1_XCODVIS'
					xConteudo := &("TMP->"+aCampos[a])
					&('oLine["'+aNomes[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar(xConteudo), '"' + EncodeUtf8(Alltrim(X3Combo("A1_XCODVIS",xConteudo))))+'"')
				Else
					xConteudo := &("TMP->"+aCampos[a])
					&('oLine["'+aNomes[a]+'"] := '+IIF(ValType(xConteudo) == 'N', cValToChar(xConteudo), '"' + EncodeUtf8(Alltrim(xConteudo)) + '"') )
				EndIf
			Next
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

