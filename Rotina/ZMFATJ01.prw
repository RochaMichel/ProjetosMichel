#include 'protheus.ch'
#include 'Totvs.ch'
#include 'TBICONN.CH'

/*/{Protheus.doc} ZMFATJ01
Rotina agendada para importar os pedidos da trinity
@author Normando RedPack
@since 19/09/2016
@version P12
@type function
/*/
User Function ZMFATJ01(aParam)
	Local cAlSC5
	Local cAlSC6
	Local aAreaSC5
	Local aAreaSC6
	Local cQuery:= "", cQrySC5:= "", cQrySC6:= ""
	Local nPeds:= 0, nImp:= 0, nNImp:= 0
	Local cArq:= "", cResum:= ""
	Local aCabPV, aItens
	Local oEmail
	Private lMsErroAuto:= .F.
	Private lMsHelpAuto:= .T.
	Private cPath:= GetSrvProfString("Startpath","")+"log_trinity\"

	//Preparando ambiente
	VarInfo("Array aParam", aParam)
	//RpcSetType(3) //Nao consome licenca
	//RpcSetEnv(aParam[1],aParam[2],,,,,) //Empresa, Filial
	PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2]
	MsgInfo("Ambiente pronto! Empresa: "+cEmpAnt+" Filial: "+RIGHT(cFilAnt,2))

	If LockByName(ProcName(), .F., .T.) //Semaforo para aplicação

		cAlSC5:= GetNextAlias()
		cAlSC6:= GetNextAlias()

		If Select(cAlSC5) > 0
			(cAlSC5)->(DBCloseArea())
		EndIf

		cQrySC5:= "SELECT * FROM TRINITY_SC5010 "
		cQrySC5+= "WHERE C5_STATUS = '1' AND C5_FILIAL = '"+RIGHT(cFilAnt,2)+"' AND D_E_L_E_T_ = ' ' "
		cQrySC5+= "AND C5_EMISSAO BETWEEN '"+DTOS(dDatabase-GETNEWPAR("NS_TRIEMIS", 30))+"' AND '"+DTOS(dDatabase)+"'  "
		cQrySC5:= ChangeQuery(cQrySC5)
		MPSysOpenQuery(cQrySC5, cAlSC5)

		While (cAlSC5)->(!EOF()) // Recuperar os itens
			//aAreaSC5:= SC5->(GetArea())
			//aAreaSC6:= SC6->(GetArea())
			aCabPV:= {}
			aItens:= {}
			DbSelectArea("SC5")
			DbSelectArea("SC6")
			//Verificar se o pedido já consta no sistema
			SC5->(DBOrderNickName("TRINPED")) //Indice criado
			SC5->(MsSeek(xFilial("SC5")+AllTrim((cAlSC5)->C5_NUM)))
			If SC5->(Found())
				MsgAlert("Pedido "+(cAlSC5)->C5_NUM+" ja esta no sistema")
				cResum+= "Pedido "+AllTrim((cAlSC5)->C5_NUM)+" ja esta no sistema<br>"
				// ALTERA STATUS DO CABEÇALHO PARA 2 (PEDIDO IMPORTADO)
				cQuery:= " UPDATE TRINITY_SC5010 SET C5_STATUS = '2'"
				cQuery+= " WHERE D_E_L_E_T_ = ' ' AND C5_FILIAL = '"+RIGHT(cFilAnt,2)+"' "
				cQuery+= " AND C5_NUM = '"+(cAlSC5)->C5_NUM+"'"
				TCSqlExec(cQuery)

				(cAlSC5)->(DBSkip())
				Loop
			EndIf

			// TABELA DOS ITENS
			If Select(cAlSC6) > 0
				(cAlSC6)->(DBCloseArea())
			EndIf

			cQrySC6:= " SELECT * FROM TRINITY_SC6010 WHERE C6_NUM = '"+(cAlSC5)->C5_NUM+"' AND C6_FILIAL = '"+RIGHT(cFilAnt,2)+"'"
			cQrySC6+= " ORDER BY C6_ITEM "
			cQrySC6:= ChangeQuery(cQrySC6)
			MPSysOpenQuery(cQrySC6, cAlSC6)

			aAdd(aCabPV,{"C5_FILIAL" , xFilial("SC5"), Nil }) 		// Filial
			aAdd(aCabPV,{"C5_TIPO" 	 , "N", Nil }) 					// Tipo do Pedido
			aAdd(aCabPV,{"C5_CLIENTE" , (cAlSC5)->C5_CLIENTE, Nil }) 	// Codigo do cliente
			aAdd(aCabPV,{"C5_LOJACLI" , (cAlSC5)->C5_LOJACLI, Nil }) 	// Loja para entrada
			aAdd(aCabPV,{"C5_CONDPAG" , (cAlSC5)->C5_CONDPAG, Nil }) 	// Condição de Pagamento
			aAdd(aCabPV,{"C5_TABELA" , (cAlSC5)->C5_TABELA, Nil }) 	// Tabela
			aAdd(aCabPV,{"C5_VEND1"  , (cAlSC5)->C5_VEND1 , Nil }) 	// Código do vendedor
			aAdd(aCabPV,{"C5_XFORMA"  , (cAlSC5)->C5_ESPECI1 , Nil }) 	// Código do vendedor
			aAdd(aCabPV,{"C5_EMISSAO" , StoD((cAlSC5)->C5_EMISSAO) , Nil }) 	// Data de Emissão
			aAdd(aCabPV,{"C5_TPFRETE" , IIF((cAlSC5)->C5_TPFRETE=="1","C","F"), Nil })   // Tipo de Frete
			aAdd(aCabPV,{"C5_XPEDTRI" , (cAlSC5)->C5_NUM, Nil })       // Numero Pedido Trinity
			aAdd(aCabPV,{"C5_XOBS1"  , (cAlSC5)->C5_MSGOPTR, Nil })   // Observacao 1

			While (cAlSC6)->(!EOF())
				SB1->(MsSeek(xFilial("SB1")+(cAlSC6)->C6_PRODUTO))
				If Empty((cAlSC6)->C6_DESCONT) //Sem desconto
					aAdd(aItens, {{"C6_ITEM", StrZero(Val((cAlSC6)->C6_ITEM),2),Nil},;// Numero do Item no Pedido
					{"C6_PRODUTO", (cAlSC6)->C6_PRODUTO,Nil},; // Codigo do Produto
					{"C6_QTDVEN", (cAlSC6)->C6_QTDVEN,Nil},; // Quantidade Vendida
					{"C6_PRCVEN", (cAlSC6)->C6_PRCVEN,Nil},;
					{"C6_OPER", (cAlSC6)->C6_OPER,Nil}}) // Tipo de Entrada/Saida do Item}) // Preco Venda(por ultimo para não pegar o preço de tabela)
				Else
					aAdd(aItens, {{"C6_ITEM", StrZero(Val((cAlSC6)->C6_ITEM),2),Nil},;// Numero do Item no Pedido
					{"C6_PRODUTO", (cAlSC6)->C6_PRODUTO,Nil},; // Codigo do Produto
					{"C6_QTDVEN", (cAlSC6)->C6_QTDVEN,Nil},; // Quantidade Vendida
					{"C6_PRCVEN", (cAlSC6)->C6_PRCVEN,Nil},; // Preco Venda(por ultimo para não pegar o preço de tabela)
					{"C6_OPER", (cAlSC6)->C6_OPER,Nil},; // Tipo de Entrada/Saida do Item
					{"C6_DESCONT", (cAlSC6)->C6_DESCONT,Nil},; // Perccentual de Desconto do Item
					{"C6_XVALDES", ((cAlSC6)->C6_DESCONT/100)*(cAlSC6)->C6_VALOR,Nil}}) // Valor Desconto (Campo customizado)
					//{"C6_VALDESC", ((cAlSC6)->C6_DESCONT/100)*(cAlSC6)->C6_VALOR,Nil}}) // Valor Desconto
				EndIf
				(cAlSC6)->(DBSkip())
			EndDo

			SC5->(RestArea(aAreaSC5))
			SC6->(RestArea(aAreaSC6))


			MsExecAuto( {|x, y, z| Mata410(x, y, z)}, aCabPV, aItens, 3 )  // Inclusão do pedido de venda
			If lMsErroAuto
				MostraErro(cPath, AllTrim((cAlSC5)->C5_NUM)+".log")
				DisarmTransaction()
				lMsErroAuto:= .F.
				cArq+= cPath+AllTrim((cAlSC5)->C5_NUM)+".log;"
				nNImp++
			Else
				// ALTERA STATUS DO CABEÇALHO PARA 2 (PEDIDO IMPORTADO)
				cQuery:= " UPDATE TRINITY_SC5010 SET C5_STATUS = '2', C5_SMRSNUM = '"+SC5->C5_NUM+"'"
				cQuery+= " WHERE D_E_L_E_T_ = ' ' AND C5_FILIAL = '"+RIGHT(cFilAnt,2)+"' "
				cQuery+= " AND C5_NUM = '"+(cAlSC5)->C5_NUM+"'"
				TCSqlExec(cQuery)
				MsgInfo("Empresa: "+cEmpAnt+" Filial: "+RIGHT(cFilAnt,2)+"|Pedido Trinity: "+(cAlSC5)->C5_NUM+" |Protheus: "+SC5->C5_NUM+" incluido com sucesso!")
				cResum+= "Pedido Trinity: "+(cAlSC5)->C5_NUM+" |Protheus: "+SC5->C5_NUM+" incluido com sucesso!<br>"
				nImp++
			EndIf

			nPeds++
			(cAlSC5)->(DBSkip())
		EndDo
		If nPeds > 0 //Se houver pedidos
			oEmail:= TlEmail():new(.T.)
			oEmail:enviaEmail(GETNEWPAR("NS_TRIMAIL", "normando.junior@newsiga.com.br"), , "Importação de pedidos", "Mensagem Automática "+Dtoc(DDATABASE)+" "+Time()+"<br>";
				+'Filial: '+RIGHT(cFilAnt,2)+'<br>';
				+'Pedido para serem importados: '+cValToChar(nPeds)+'<br>';
				+'<font color = "#006400">Pedido importados: '+cValToChar(nImp)+'</font><br>';
				+'<font color = "#FF0000">Pedido não importados: '+cValToChar(nNImp)+'</font><br><br>'+cResum, cArq, .F.)
		EndIf
		MsgInfo("Processo encerrado!")
		UnLockByName(ProcName(),.F.,.T.)
	Else
		MsgAlert("Semaforo ativo para aplicacao, aguardar processo...")
	EndIf

	Reset Environment
	//RpcClearEnv()

Return Nil
