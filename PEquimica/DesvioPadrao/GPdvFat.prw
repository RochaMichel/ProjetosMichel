#INCLUDE 'TOTVS.CH'
#INCLUDE 'PRTOPDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

User Function gpdvfat(cProcesso)
	Local aArea		:= GetArea()
	Local lESTNEG   := (SuperGetMV("MV_ESTNEG") == "S",.T.,.F.)
	Local cZR23Alias:= GetNextAlias()
	Local cLoja 	:= ''
	Local cCliente 	:= ''
	Local cNpro 	:= ''
	Local aDados 	:= {}
	Local lEfet     := .F.

	//Consulta para buscar os dados da tela e assim gerar o pedido de venda e documento de saida
	BeginSql Alias cZR23Alias
		SELECT ZR2_FILIAL, ZR2_CLOJA, ZR2_CLI, ZR2_NPRO, ZR2_USER,
		ZR3_PROD, ZR3_QUANT, ZR3_PRCVEN, ZR3_VLRT, ZR3_LOCAL, ZR3_UM, ZR2_OPER //ZR2_CONDPS, 
		FROM %TABLE:ZR3% ZR3
		INNER JOIN %TABLE:ZR2% ZR2 ON ZR3.ZR3_NPRO = ZR2.ZR2_NPRO AND ZR3.ZR3_FILIAL = ZR2.ZR2_FILIAL
		WHERE ZR2.ZR2_FILIAL = %EXP:cFilAnt%
		AND ZR2.ZR2_NPRO = %EXP:cProcesso%
		AND ZR2.%NOTDEL%
		AND ZR3.%NOTDEL%
		ORDER BY ZR3_ITEM
	EndSql

	If (cZR23Alias)->(Eof())
		dbselectarea(cZR23Alias)
		(cZR23Alias)->(DbCloseArea())
		Return
	EndIf

	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))

	DbSelectArea("SC9")
	SC9->(DbSetOrder(1))

	While (cZR23Alias)->(!EOF())
		cChaveNpro := (cZR23Alias)->(ZR2_FILIAL+ZR2_NPRO)
		While (cZR23Alias)->(!EOF()) .AND. (cZR23Alias)->(ZR2_FILIAL+ZR2_NPRO) == cChaveNpro
			aAdd(aDados				,;
				{(cZR23Alias)->ZR3_PROD ,;//1 -- Produto
			(cZR23Alias)->ZR3_QUANT ,;//2 -- Quantidade
			(cZR23Alias)->ZR3_PRCVEN,;//3 -- Pre�o
			(cZR23Alias)->ZR3_VLRT  ,;//4 -- Valor total
			(cZR23Alias)->ZR2_NPRO	,;//5 -- Cod. Processo
			(cZR23Alias)->ZR2_CLI	,;//6 -- Cod. Cliente
			(cZR23Alias)->ZR2_CLOJA	,;//7 -- Cod. Loja do Cliente
			(cZR23Alias)->ZR3_LOCAL	,;//8 -- Armaz�m
			(cZR23Alias)->ZR2_USER  ,;//9-- Cod. Usu�rio
			(cZR23Alias)->ZR3_UM  	,;//10-- Uni. Medida
			(cZR23Alias)->ZR2_OPER})//11-- Operacao
			(cZR23Alias)->(DbSkip())
			//(cZR23Alias)->ZR2_CONDPS,;//12-- Cond. pag. saida
		End
		// Capturo os valores constantes
		cNpro		:= aLlTrim(aDados[1,5])
		cCliente 	:= aLlTrim(aDados[1,6])
		cLoja 		:= aLlTrim(aDados[1,7])
		If GeraPdVd(cCliente, cLoja, cNpro, aDados) //Fun��o para gerar o pedido de venda
			lCredito := .T.
			lEstoque := .T.
			lLiber   := .T.
			lTransf  := .F.
			cFilInfo := SC5->C5_FILIAL
			cNumPed  := SC5->C5_NUM
			// Percorro os itens do pedido gerado
			While SC6->(!EOF()) .AND. SC6->(C6_FILIAL+C6_NUM) == cFilInfo+cNumPed
				If !SC9->(dbSeek(cFilInfo+SC6->C6_NUM+SC6->C6_ITEM))
					//Libera os itens do pedido de venda, caso n�o esteja liberado
					MaLibDoFat(SC6->(Recno()),SC6->C6_QTDVEN,@lCredito,@lEstoque,.F.,(!lESTNEG),lLiber,lTransf)
				EndIf
				SC6->(DbSkip())
			End
			lEfet := FaturaPd(cFilInfo, cNumPed, cNpro) //Fun��o para Faturar pedido liberado
		EndIf
	End

	DbSelectArea(cZR23Alias)
	(cZR23Alias)->(DbCloseArea())
	RestArea(aArea)

Return lEfet


Static Function GeraPdVd(cCodCli, cLojCli, cNpro, aDados)
	Local aArea			:= GetArea()
	Local aCabPv  		:= {}
	Local aItePv  		:= {}
	Local aIteTp		:= {}
	Local alog		:= {}
	local cTexto := ''
	Local cNumPed 		:= ''
	Local nX			:=  0
	Local lOK           := .F.
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.
	Private lMSHelpAuto     := .T.

	DbSelectArea("SB8")
	SB8->(DbSetOrder(3))

	DbSelectArea("ZR2")
	ZR2->(DbSetOrder(1))

	cNumPed  := GetSxeNum("SC5","C5_NUM") // Pega a Pr�xima numera��o dispon�vel

	**/*TABELA SC5 CABE�ALHO DO PEDIDO DE VENDA*/**
	aAdd(aCabPv,{"C5_FILIAL"  	, cFilant													,Nil}) //01
	aAdd(aCabPv,{"C5_NUM"     	, cNumPed			   										,Nil}) //02
	aAdd(aCabPv,{"C5_TIPO"     	, SuperGetMV("MV_PEDTP",,"N")			   					,Nil}) //02
	aAdd(aCabPv,{"C5_CLIENTE"	, cCodCli													,Nil}) //06
	aAdd(aCabPv,{"C5_LOJACLI"	, cLojCli													,Nil}) //07
	aAdd(aCabPv,{"C5_TIPOCLI"	, SuperGetMV("MV_TIPOCLI",,"R")								,Nil}) //10
	aAdd(aCabPv,{"C5_CONDPAG"	, SuperGetMV("MV_CONDPG",,"000")							,Nil}) //11
	//aAdd(aCabPv,{"C5_VEND1" 	, cVend														,Nil}) //13
	aAdd(aCabPv,{"C5_EMISSAO" 	, dDataBase													,Nil}) //14
	aAdd(aCabPv,{"C5_MOEDA" 	, 1															,Nil}) //15
	aAdd(aCabPv,{"C5_NATUREZ" 	, SuperGetMV("MV_NATVEND",,"1001001")						,Nil}) //17
	aAdd(aCabPv,{"C5_XNPRO"   	, cNpro														,Nil}) //18
	aAdd(aCabPv,{"C5_MENNOTA"   , ZR2->ZR2_OBS												,Nil}) //18
	//aAdd(aCabPv,{"C5_TRANSP"   	, "90"														,Nil}) //19

	For nX:= 1 To Len(aDados)

		aItePv := {} // Limpo o array
		**/*TABELA SC6 ITENS DO PEDIDO DE VENDA*/**
		aAdd(aItePv,{"C6_FILIAL"  	,cFilant													,Nil}) //01
		aAdd(aItePv,{"C6_ITEM"   	,StrZero(nX,2)												,Nil}) //02
		aAdd(aItePv,{"C6_PRODUTO"	,AllTrim(aDados[nX,1])										,Nil}) //03
		aAdd(aItePv,{"C6_DESCRI"	,AllTrim(Posicione("SB1",1,xFilial("SB1")+aDados[nX,1],"B1_DESC")),Nil}) //04
		aAdd(aItePv,{"C6_UM"      	,aDados[nX,10]												,Nil}) //08
		aAdd(aItePv,{"C6_QTDVEN"  	,aDados[nX,2]												,Nil}) //05
		aAdd(aItePv,{"C6_PRCVEN"  	,aDados[nX,3]												,Nil}) //06
		aAdd(aItePv,{"C6_VALOR"   	,Round(aDados[nX,2]*aDados[nX,3],2)							,Nil}) //07
		aAdd(aItePv,{"C6_OPER"    	,aDados[nX,11]												,Nil}) //09
		//aAdd(aItePv,{"C6_TES"   	,AllTrim(aDados[nX,5])										,Nil}) //10
		aAdd(aItePv,{"C6_LOCAL"		,aDados[nX,8]												,Nil}) //11
		//If SB8->(DbSeek(xFilial("SB8")+aDados[nX,1]+cLocal)) // Posiciono na B8 para pegar o Lote e validade
		//	aAdd(aItePv,{"C6_LOTECTL"  	,SB8->B8_LOTECTL											,Nil}) //12
		//	aAdd(aItePv,{"C6_DTVALID"  	,SB8->B8_DTVALID											,Nil}) //12
		//EndIf
		aAdd(aIteTp,aClone(aItePv))
	Next
	MsExecAuto({|x,y,z| mata410(x,y,z)},aCabPv,aIteTp,3) // Chamo a rotina automatica para inclus�o do pedido
	If  lMsErroAuto
		RollBackSX8()
		cTexto := ''
		aLog := GetAutoGRLog()
		For nX := 1 To Len(aLog)
			cTexto += aLog[nX] + CRLF
		Next nX
	Else
		ConfirmSX8()
		lOK := .T.
		If ZR2->(DbSeek(xFilial("ZR2")+cNpro))
			ZR2->(RecLock("ZR2", .F.))
			ZR2->ZR2_NUMPED := alltrim(cNumPed)
			ZR2->ZR2_USER := RetCodUsr()
			ZR2->(MsUnlock())
		EndIf
	EndIf
	RestArea(aArea)
Return lOK




Static Function FaturaPd(cFilInfo, cPedido, cNpro, oProcess)
	Local aArea		:= GetArea()
	Local aPvlDocS  := {}
	Local nPrcVen   := 0
	Local cSerie    := ""
	Local cEmbExp   := ""
	Local cDoc      := ""
	Local lOK       := .F.

	SC5->(DbSetOrder(1))
	SC5->(DbSeek(cFilInfo+cPedido))

	SC9->(DbSetOrder(1))//2
	SC9->(MsSeek(cFilInfo+SC5->C5_NUM))

	DbSelectArea("ZR2")
	ZR2->(DbSetOrder(1))

	//É necessário carregar o grupo de perguntas MT460A, se não será executado com os valores default.
	Pergunte("MT460A",.F.)

	cSerie := SuperGetMV("MV_SERIEDP",,"LOC")

	// Obter os dados de cada item do pedido de vendas liberado para gerar o Documento de Saída
	While SC9->(!Eof()) .And. SC9->C9_FILIAL == cFilInfo .And. SC9->C9_PEDIDO == SC5->C5_NUM

		SC6->(dbSetOrder(1))
		SC6->(DbSeek(SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_PRODUTO)))

		SE4->(DbSetOrder(1))
		SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG))  //FILIAL+CONDICAO PAGTO

		SB1->(DbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))    //FILIAL+PRODUTO

		SB2->(DbSetOrder(1))
		SB2->(MsSeek(cFilInfo+SC6->(C6_PRODUTO+C6_LOCAL))) //FILIAL+PRODUTO+LOCAL

		SF4->(DbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES))   //FILIAL+TES

		If ( SC5->C5_MOEDA <> 1 )
			nPrcVen := xMoeda(SC9->C9_PRCVEN,SC5->C5_MOEDA,1,dDataBase)
		EndIf

		If Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED)
			AAdd(aPvlDocS,{ SC9->C9_PEDIDO,;
				SC9->C9_ITEM,;
				SC9->C9_SEQUEN,;
				SC9->C9_QTDLIB,;
				nPrcVen,;
				SC9->C9_PRODUTO,;
				.F.,;
				SC9->(RecNo()),;
				SC5->(RecNo()),;
				SC6->(RecNo()),;
				SE4->(RecNo()),;
				SB1->(RecNo()),;
				SB2->(RecNo()),;
				SF4->(RecNo())})
		EndIf
		SC9->(DbSkip())
	EndDo

	SetFunName("MATA461")
	If Len(aPvlDocS) > 0
		cDoc := MaPvlNfs(  /*aPvlNfs*/         aPvlDocS,;  // 01 - Array com os itens 1 serem gerados
		/*cSerieNFS*/       cSerie,;    // 02 - Serie da Nota Fiscal
		/*lMostraCtb*/      .F.,;       // 03 - Mostra Lançamento Contábil
		/*lAglutCtb*/       .F.,;       // 04 - Aglutina Lançamento Contábil
		/*lCtbOnLine*/      .F.,;       // 05 - Contabiliza On-Line
		/*lCtbCusto*/       .F.,;       // 06 - Contabiliza Custo On-Line
		/*lReajuste*/       .F.,;       // 07 - Reajuste de preço na Nota Fiscal
		/*nCalAcrs*/        0,;         // 08 - Tipo de Acréscimo Financeiro
		/*nArredPrcLis*/    0,;         // 09 - Tipo de Arredondamento
		/*lAtuSA7*/         .T.,;       // 10 - Atualiza Amarração Cliente x Produto
		/*lECF*/            .F.,;       // 11 - Cupom Fiscal
		/*cEmbExp*/         cEmbExp,;   // 12 - Número do Embarque de Exportação
		/*bAtuFin*/         {||},;      // 13 - Bloco de Código para complemento de atualização dos títulos financeiros
		/*bAtuPGerNF*/      {||},;      // 14 - Bloco de Código para complemento de atualização dos dados após a geração da Nota Fiscal
		/*bAtuPvl*/         {||},;      // 15 - Bloco de Código de atualização do Pedido de Venda antes da geração da Nota Fiscal
		/*bFatSE1*/         {|| .T. },; // 16 - Bloco de Código para indicar se o valor do Titulo a Receber será gravado no campo F2_VALFAT quando o parâmetro MV_TMSMFAT estiver com o valor igual a "2".
		/*dDataMoe*/        dDatabase,; // 17 - Data da cotação para conversão dos valores da Moeda do Pedido de Venda para a Moeda Forte
		/*lJunta*/          .F.)        // 18 - Aglutina Pedido Iguais
		If !Empty(cDoc)
			lOK := .T.
			If ZR2->(DbSeek(xFilial("ZR2")+cNpro))
				ZR2->(RecLock("ZR2", .F.))
				ZR2->ZR2_DOCS := alltrim(cDoc)
				ZR2->ZR2_SERIES := cSerie
				ZR2->(MsUnlock())
			EndIf
		EndIf
	Else
		If ZR2->(DbSeek(xFilial("ZR2")+cNpro))
			ZR2->(RecLock("ZR2", .F.))

			If !Empty(SC9->C9_BLCRED)
				ZR2->ZR2_STATUS := '4' //Marco o status com bloqueio de credito
			else
				ZR2->ZR2_STATUS := '3' //Marco o status com bloqueio de estoque
			EndIf

			ZR2->(MsUnlock())
		EndIf
	EndIf
	RestArea(aArea)

Return lOK

