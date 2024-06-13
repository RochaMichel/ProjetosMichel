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

WSRESTFUL PEDVENDA Description "Serviço REST para geracao do pedido de Venda."
	WSMethod POST Description "Inclusão de pedido de venda" WSSYNTAX  "/POST/PEDVENDA/"
END WSRESTFUL

WSMethod POST WSSERVICE PEDVENDA

//user function tetstejson()
	Local cJson            := Self:GetContent()
	//Local lRet   :=  .T.
	Local aCabec           := {}
	Local aItens           := {}
	Local aLinha           := {}
	Local aLog             := {}
	Local cTexto           := ''
	Local cOper            := ''
	Local cNaturez         := ''
	Local cNum             := ''
	Local cTipo            := ''
	//Local cResposta             := '{"code": "200", "Status": "Pedidos cadastrados com sucesso!", "pedidos":['
	Local n                :=  0
	Local nX               :=  0
	Private oPedJSON       := JsonObject():New()
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
	DbSelectArea("SA1")
	For n := 1 to len(oPedJSON:PEDIDOS)
		aItens := {}
		aCabec := {}

		cNum	:= SOMA1(AllTrim(GetMv("MV_XSEQPED")))
		PutMv("MV_XSEQPED",cNum)
		SC5->(DbSetOrder(1))
		While SC5->( DbSeek( AllTrim(GetMv('MV_XFILPD',,'010101'))+cNum ) )
			cNum := SOMA1(AllTrim(GetMv("MV_XSEQPED")))
			PutMv("MV_XSEQPED",cNum)
		Enddo

		If SA1->(MsSeek(xFilial('SA1')+oPedJSON:PEDIDOS[n]:PEDIDO:CODIGO_CLIENTE+oPedJSON:PEDIDOS[n]:PEDIDO:LOJA_CLIENTE))
			cTipo := SA1->A1_TIPO
		EndIf

		If oPedJSON:PEDIDOS[n]:PEDIDO:TIPO_VENDA == '0'
			//If len(oPedJSON:PEDIDOS[n]:PEDIDO:CPF_CNPJ) > 11
			If cTipo == 'R' //REVENDEDOR
				cOper := '01'
				cNaturez := '1001002'
			ElseIf cTipo $ 'F|S' //FINAL OU SOLIDARIO
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
		aAdd(aCabec , {"C5_FILIAL",   GetMv('MV_XFILPD',,'010101') ,nil})
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
		aAdd(aCabec , {"C5_TPFRETE"  , oPedJSON:PEDIDOS[n]:PEDIDO:TIPO_FRETE                                     , NIL})
		aAdd(aCabec , {"C5_PBRUTO" , oPedJSON:PEDIDOS[n]:PEDIDO:PESO_BRUTO                                 , NIL})
		aAdd(aCabec , {"C5_XLOTPED" , oPedJSON:PEDIDOS[n]:PEDIDO:LOTE                                 , NIL})
		dbSelectArea('SB1')
		SB1->(DbSetOrder(1))
		For nX := 1 To Len(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS)
			aLinha := {}
			SB1->(DbSeek(xFilial('SB1')+oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:PRODUTO))
			aAdd(aLinha , {"C6_PRODUTO",oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:PRODUTO                            , NIL})
			If oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:UNIDADE_MEDIDA == 0
				if SB1->B1_TIPCONV == 'D'
					aAdd(aLinha , {"C6_QTDVEN" ,Val(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:QUANTIDADE_PRODUTO)*SB1->B1_CONV, NIL})
					aAdd(aLinha , {"C6_PRCVEN" ,Val(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:VALOR_PRODUTO)/SB1->B1_CONV      , NIL})
				Else
					aAdd(aLinha , {"C6_QTDVEN" ,Val(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:QUANTIDADE_PRODUTO), NIL})
					aAdd(aLinha , {"C6_PRCVEN" ,Val(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:VALOR_PRODUTO)      , NIL})
				EndIF
			Else
				if SB1->B1_TIPCONV == 'D'
					aAdd(aLinha , {"C6_QTDVEN" ,Val(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:QUANTIDADE_PRODUTO), NIL})
					aAdd(aLinha , {"C6_PRCVEN" ,Val(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:VALOR_PRODUTO)     , NIL})
				Else
					aAdd(aLinha , {"C6_QTDVEN" ,Val(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:QUANTIDADE_PRODUTO)/SB1->B1_CONV, NIL})
					aAdd(aLinha , {"C6_PRCVEN" ,Val(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:VALOR_PRODUTO)*SB1->B1_CONV      , NIL})
				EndIf
				//aAdd(aLinha , {"C6_UNSVEN" ,Val(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:QUANTIDADE_PRODUTO), NIL})

			EndIf
			//aAdd(aLinha , {"C6_PRUNIT" ,Val(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:VALOR_PRODUTO)         , NIL})
			aAdd(aLinha , {"C6_OPER"   ,cOper                                                        , NIL})
			//aAdd(aLinha , {"C6_DESCONT",Val(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:DESCONTO_PERC)             , NIL})
			//aAdd(aLinha , {"C6_VALDESC",Val(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:DESCONTO_VALOR)           , NIL})
			//aAdd(aLinha , {"C6_COMIS1" ,Val(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:PERC_COMISSAO_PRODUTO)            , NIL})
			aAdd(aItens, aClone(aLinha))
		Next nX
		lMsErroAuto    := .F.
		MsExecAuto({|x, y, z| mata410(x, y, z)},aCabec,aItens,3)
		If lMsErroAuto
			cTexto := ''
			aLog := GetAutoGRLog()
			For nX := 1 To Len(aLog)
				cTexto += aLog[nX] + CRLF
			Next nX
			U_EnvPedRaj(oPedJSON:PEDIDOS[n]:PEDIDO:CODIGO_VENDA,cTexto,.F.)
		else
			confirmSX8()
			U_EnvPedRaj(oPedJSON:PEDIDOS[n]:PEDIDO:CODIGO_VENDA,cNum,.T.)

		EndIF
	Next n

	FreeObj(oPedJSON)
	SA1->(DbCloseArea())
	SC5->(DbCloseArea())
	If lAtivAmb == .T.
		RpcClearEnv()
	EndIF

Return
