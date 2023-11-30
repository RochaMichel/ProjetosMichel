#Include "TOTVS.CH"
#Include "RESTFUL.CH"
#Include "tbiconn.ch"
#Include "topconn.ch"

/*/{Protheus.doc} VlrB2
    (Api REST para criação de pedido de venda)
    @type  Function
    @author Michel Rocha Cod.Erp
    @version P12 
    @return return_var, return_type, return_description
/*/ 

//WSRESTFUL PEDVENDA Description "Serviço REST para geracao do pedido de Venda."
//	WSMethod POST Description "Inclusão de pedido de venda" WSSYNTAX  "/POST/PEDVENDA/"
//END WSRESTFUL
//
//WSMethod POST WSSERVICE PEDVENDA
user function testerest()
	Local cJson            := ''//Self:GetContent()
	Local lRet   :=  .T.
	Local aCabec           := {}
	Local aItens           := {}
	Local aLinha           := {}
	Local aLog             := {}
	Local cTexto           := ''
	Local cOper           := ''
	Local cNaturez           := ''
	Local cNum             := ''
	Local cResposta             := '{"code": "200", "Status": "Pedidos cadastrados com sucesso!", "pedidos":['
	Local n               :=  0
	Local nX               :=  0
	Private oPedJSON       := JsonObject():New()

	cJson += '{          '
	cJson += '   "Pedidos":[          '
	cJson += '      {          '
	cJson += '         "Pedido":{          '
	cJson += '            "codigo_venda":"1",          '
	cJson += '            "lote":"2",          '
	cJson += '            "loja_cliente":"0001",          '
	cJson += '            "tipo_cliente":"R",          '
	cJson += '            "codigo_usuario":"0013",          '
	cJson += '            "data_venda":"14-11-2023",          '
	cJson += '            "valor":"732.00",          '
	cJson += '            "desconto":"0.00",          '
	cJson += '            "codigo_cliente":"32124692",          '
	cJson += '            "codigo_regional":1,          '
	cJson += '            "peso_liquido":9.8,          '
	cJson += '            "peso_bruto":23.4,          '
	cJson += '            "codigo_tabela_preco":"1",          '
	cJson += '            "status_venda":"0",          '
	cJson += '            "percentual_comissao_venda":"0",          '
	cJson += '            "sfa_codigo_condicao_pagamento":"092",          '
	cJson += '            "tipo_venda":"0",          '
	cJson += '            "numero_nf":"0",          '
	cJson += '            "Itens":[          '
	cJson += '               {          '
	cJson += '                  "produto":"0104000006",          '
	cJson += '                  "valor_produto":"48.00000000",          '
	cJson += '                  "quantidade_produto":"5.0",          '
	cJson += '                  "valor_total_produto":"240.00000000",          '
	cJson += '                  "valor_total_produto_bruto":"240.00000000",          '
	cJson += '                  "desconto_perc":"0",          '
	cJson += '                  "desconto_Valor":"0.00",          '
	cJson += '                  "perc_comissao_produto":"0.00",          '
	cJson += '                  "codigo_regional":1          '
	cJson += '               },          '
	cJson += '               {          '
	cJson += '                  "produto":"0109000004",          '
	cJson += '                  "valor_produto":"246.00000000",          '
	cJson += '                  "quantidade_produto":"2.0",          '
	cJson += '                  "valor_total_produto":"492.00000000",          '
	cJson += '                  "valor_total_produto_bruto":"492.00000000",          '
	cJson += '                  "desconto_perc":"0",          '
	cJson += '                  "desconto_Valor":"0.00",          '
	cJson += '                  "perc_comissao_produto":"0.00",          '
	cJson += '                  "codigo_regional":1          '
	cJson += '               }          '
	cJson += '            ]          '
	cJson += '         }          '
	cJson += '      },          '
	cJson += '      {          '
	cJson += '         "Pedido":{          '
	cJson += '            "codigo_venda":"3",          '
	cJson += '            "lote":"2",          '
	cJson += '            "loja_cliente":"0001",          '
	cJson += '            "tipo_cliente":"R",          '
	cJson += '            "codigo_usuario":"0013",          '
	cJson += '            "data_venda":"14-11-2023",          '
	cJson += '            "valor":"155000.00",          '
	cJson += '            "desconto":"0.00",          '
	cJson += '            "codigo_cliente":"",          '
	cJson += '            "codigo_regional":1,          '
	cJson += '            "peso_liquido":10000,          '
	cJson += '            "peso_bruto":10450,          '
	cJson += '            "codigo_tabela_preco":"1",          '
	cJson += '            "status_venda":"1",          '
	cJson += '            "percentual_comissao_venda":null,          '
	cJson += '            "sfa_codigo_condicao_pagamento":"092",          '
	cJson += '            "tipo_venda":"0",          '
	cJson += '            "numero_nf":"0",          '
	cJson += '            "Itens":[          '
	cJson += '               {          '
	cJson += '                  "produto":"0205000005",          '
	cJson += '                  "valor_produto":"155.00000000",          '
	cJson += '                  "quantidade_produto":"1000.00",          '
	cJson += '                  "valor_total_produto":"155000.00000000",          '
	cJson += '                "valor_total_produto_bruto":"155000.00000000",          '
	cJson += '                  "desconto_perc":null,          '
	cJson += '                  "desconto_Valor":"0.00",          '
	cJson += '                  "perc_comissao_produto":"0.00",          '
	cJson += '                  "codigo_regional":1          '
	cJson += '               }          '
	cJson += '            ]          '
	cJson += '         }          '
	cJson += '      }          '
	cJson += '    ]          '
	cJson += ' }          '


	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.
	Private lAtivAmb := .F.
	Private lMSHelpAuto     := .T.

	// Prepara o ambiente caso precise
	If Select("SX2") == 0
		RPCClearEnv()
		RpcSetType(3)
		RpcSetEnv( "01",'010101', , , "",,, , , ,  )
		lAtivAmb := .T. // Seta se precisou montar o ambiente
	Endif
 
	FwJsonDeserialize(cJson,@oPedJSON)
	setFunName('mata410')
	DbSelectArea("SC5")
	DbSelectArea('SA1')
	For n := 1 to len(oPedJSON:PEDIDOS)
		aItens := {}
		aCabec := {}
		cNum := GetSXENum('SC5', 'C5_NUM')
		SA1->(DbSetOrder(1))
		SA1->(Dbseek(xFilial('SA1')+oPedJSON:PEDIDOS[n]:PEDIDO:CODIGO_CLIENTE+oPedJSON:PEDIDOS[n]:PEDIDO:LOJA_CLIENTE))
		If oPedJSON:PEDIDOS[n]:PEDIDO:TIPO_VENDA == '0'
			If len(SA1->A1_CGC) > 11
				cOper := '01'
				cNaturez := '1001002'
			Else
				cOper := '03'
				cNaturez := '1001002'
			EndIf
		ElseIf oPedJSON:PEDIDOS[n]:PEDIDO:TIPO_VENDA == '1'
			cOper := '04'
			cNaturez := '1003002'
		ElseIf oPedJSON:PEDIDOS[n]:PEDIDO:TIPO_VENDA == '2'
			cOper := '6'
			cNaturez := '1003005'
		EndIf
		aAdd(aCabec , {"C5_FILIAL", GetMv('MV_XFILPD',,'010101'),nil})
		aAdd(aCabec , {"C5_TIPO"   ,  GetMV("MV_XTPPDV",,'N')                   , NIL})
		aAdd(aCabec , {"C5_NUM"    ,  cNum                                               , NIL})
		aAdd(aCabec , {"C5_CLIENTE",  oPedJSON:PEDIDOS[n]:PEDIDO:CODIGO_CLIENTE             , NIL})
		aAdd(aCabec , {"C5_LOJACLI",  oPedJSON:PEDIDOS[n]:PEDIDO:LOJA_CLIENTE                                                              , NIL})
		aAdd(aCabec , {"C5_CONDPAG",  oPedJSON:PEDIDOS[n]:PEDIDO:SFA_CODIGO_CONDICAO_PAGAMENTO             , NIL})
		aAdd(aCabec , {"C5_NOTA"   ,  oPedJSON:PEDIDOS[n]:PEDIDO:NUMERO_NF                                , NIL})
		aAdd(aCabec , {"C5_TIPOCLI",  oPedJSON:PEDIDOS[n]:PEDIDO:TIPO_CLIENTE                                                           , NIL})
		aAdd(aCabec , {"C5_NATUREZ",   cNaturez                                                              , NIL})
		aAdd(aCabec , {"C5_EMISSAO",  CtoD(oPedJSON:PEDIDOS[n]:PEDIDO:DATA_VENDA)                                , NIL})
		aAdd(aCabec , {"C5_VEND1"  , oPedJSON:PEDIDOS[n]:PEDIDO:CODIGO_USUARIO                                                        , NIL})
		aAdd(aCabec , {"C5_PESOL"  , oPedJSON:PEDIDOS[n]:PEDIDO:PESO_LIQUIDO                                     , NIL})
		aAdd(aCabec , {"C5_PBRUTO" , oPedJSON:PEDIDOS[n]:PEDIDO:PESO_BRUTO                                 , NIL})
		aAdd(aCabec , {"C5_XLOTPED" , oPedJSON:PEDIDOS[n]:PEDIDO:LOTE                                 , NIL})

		For nX := 1 To Len(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS)
			aLinha := {}
			aAdd(aLinha , {"C6_PRODUTO",oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:PRODUTO                            , NIL})
			aAdd(aLinha , {"C6_QTDVEN" ,Val(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:QUANTIDADE_PRODUTO)                 , NIL})
			aAdd(aLinha , {"C6_PRUNIT" ,Val(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:VALOR_PRODUTO)         , NIL})
			//aAdd(aLinha , {"C6_PRCVEN" ,Val(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:VALOR_TOTAL_PRODUTO)             , NIL})
			aAdd(aLinha , {"C6_OPER"   ,cOper                                                        , NIL})
			aAdd(aLinha , {"C6_DESCONT",Val(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:DESCONTO_PERC)             , NIL})
			aAdd(aLinha , {"C6_VALDESC",Val(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:DESCONTO_VALOR)           , NIL})
			aAdd(aLinha , {"C6_COMIS1" ,Val(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:PERC_COMISSAO_PRODUTO)            , NIL})
			aAdd(aItens,aClone(aLinha))
		Next nX
		lMsErroAuto    := .F.
		MsExecAuto({|x, y, z| mata410(x, y, z)},aCabec,aItens,3)
		If lMsErroAuto
			aLog := GetAutoGRLog()
			For nX := 1 To Len(aLog)
				cTexto += aLog[nX] + CRLF
			Next nX
		else
			If len(oPedJSON:PEDIDOS) == n
				cResposta += '{"codigo_raj": '+oPedJSON:PEDIDOS[n]:PEDIDO:CODIGO_VENDA+',"codigo_protheus":"'+cNum+'"}'
			else
				cResposta += '{"codigo_raj": '+oPedJSON:PEDIDOS[n]:PEDIDO:CODIGO_VENDA+',"codigo_protheus":"'+cNum+'"},'
			EndIf
		EndIF
	Next n
	cResposta += ' ]}'
	If !Empty(cTexto)
		SetRestFault(400,cTexto,.T.)
		lRet := .F.                                     
	Else
		::SetResponse(cResposta)
	EndIF
	FreeObj(oPedJSON)
	SA1->(DbCloseArea())
	SC5->(DbCloseArea())
	If lAtivAmb == .T.
		RpcClearEnv()
	EndIF

Return(lRet)
