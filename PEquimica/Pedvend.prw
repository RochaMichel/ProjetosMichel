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

WSRESTFUL PVENDA Description "Serviço REST para geracao do pedido de Venda."
	WSMethod POST Description "Inclusão de pedido de venda" WSSYNTAX  "/POST/PVENDA/"
END WSRESTFUL

WSMethod POST WSSERVICE PVENDA

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
//	Local cTipo            := ''
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

		cNum	:= GetSXENum('SC5','C5_NUM')

		aAdd(aCabec , {"C5_FILIAL",   GetMv('MV_XFILPD',,'010101')                             , Nil})
		aAdd(aCabec , {"C5_TIPO"   ,  GetMV("MV_XTPPDV",,'N')                                  , Nil})
		aAdd(aCabec , {"C5_NUM"    ,  cNum                                                     , Nil})
		aAdd(aCabec , {"C5_CLIENTE",  oPedJSON:PEDIDOS[n]:PEDIDO:CODIGO_CLIENTE                , Nil})
		aAdd(aCabec , {"C5_LOJACLI",  oPedJSON:PEDIDOS[n]:PEDIDO:LOJA_CLIENTE                  , Nil})
		aAdd(aCabec , {"C5_CONDPAG",  oPedJSON:PEDIDOS[n]:PEDIDO:SFA_CODIGO_CONDICAO_PAGAMENTO , Nil})
		aAdd(aCabec , {"C5_NOTA"   ,  oPedJSON:PEDIDOS[n]:PEDIDO:NUMERO_NF                     , Nil})
		aAdd(aCabec , {"C5_TIPOCLI",  oPedJSON:PEDIDOS[n]:PEDIDO:TIPO_CLIENTE                  , Nil})
		aAdd(aCabec , {"C5_NATUREZ",   cNaturez                                                , Nil})
		aAdd(aCabec , {"C5_EMISSAO",  CtoD(oPedJSON:PEDIDOS[n]:PEDIDO:DATA_VENDA)              , Nil})
		aAdd(aCabec , {"C5_VEND1"  , oPedJSON:PEDIDOS[n]:PEDIDO:CODIGO_USUARIO                 , Nil})
		aAdd(aCabec , {"C5_PESOL"  , oPedJSON:PEDIDOS[n]:PEDIDO:PESO_LIQUIDO                   , Nil})
		aAdd(aCabec , {"C5_TPFRETE"  , oPedJSON:PEDIDOS[n]:PEDIDO:TIPO_FRETE                   , Nil})
		aAdd(aCabec , {"C5_PBRUTO" , oPedJSON:PEDIDOS[n]:PEDIDO:PESO_BRUTO                     , Nil})
		aAdd(aCabec , {"C5_XLOTPED" , oPedJSON:PEDIDOS[n]:PEDIDO:LOTE                          , Nil})

		dbSelectArea('SB1')
		SB1->(DbSetOrder(1))
		For nX := 1 To Len(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS)
			aLinha := {}

			SB1->(DbSeek(xFilial('SB1')+oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:PRODUTO))
			aAdd(aLinha , {"C6_PRODUTO",oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:PRODUTO                            , NIL})
			aAdd(aLinha , {"C6_QTDVEN" ,Val(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:QUANTIDADE_PRODUTO), NIL})
			aAdd(aLinha , {"C6_PRCVEN" ,Val(oPedJSON:PEDIDOS[n]:PEDIDO:ITENS[nx]:VALOR_PRODUTO)     , NIL})
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
		else
			confirmSX8()

		EndIF
	Next n

	FreeObj(oPedJSON)
	SA1->(DbCloseArea())
	SC5->(DbCloseArea())
	If lAtivAmb == .T.
		RpcClearEnv()
	EndIF

Return
