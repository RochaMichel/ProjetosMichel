#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} MA410MNU
Ponto de entrada disparado antes da abertura do Browse, caso Browse inicial da rotina esteja habilitado, ou antes da apresentação do Menu de opções,
caso Browse inicial esteja desabilitado.  
Para habilitar ou desabilitar o Browse, entre na rotina, clique em Configurações/Browse Inicial e selecione
a opção desejada:
Sim - Habilitar Browse Inicial
Não - Desabilitar Browse Inicial 
Este ponto de entrada pode ser utilizado para inserir novas opções no array aRotina.
@type function
@author diversos
@since 08/2023
@see https://tdn.engpro.totvs.com.br/display/public/PROT/MA410MNU
/*/
User Function MA410MNU
	aAdd(aRotina,{ "Informar PESO", "U_MT440PES()", 0 , 4, 0, NIL})
	aAdd(aRotina,{ "Visualizar Itens", "U_TelPdItem()", 0 , 4, 0, NIL})

Return

/*/{Protheus.doc} MT440PES
Alterar o peso do pedido de venda
@type function
@author Totvs NE, Izaias Arruda
@since 08/2023
/*/
User Function MT440PES

	Local aPergs 	:= {}
	Local cSolucao as char
	Local nTamNum 	:= TamSX3("Z3_TICKET")[1] As numeric
	Local aCombo	:= {}
	Local cAliasTMP	:= GetNextAlias()

	If !Empty(SC5->C5_NOTA) /*se já possui NF, devemos checar se foi totalmente faturado*/
		BEGINSQL Alias cAliasTMP
		SELECT 
			SC6.C6_QTDVEN, SC6.C6_QTDENT
		FROM
			%table:SC6% SC6
		WHERE
			SC6.C6_FILIAL = %exp:SC5->C5_FILIAL% AND
			SC6.C6_NUM = %exp:SC6->C6_NUM% AND
			SC6.D_E_L_E_T_=''
		ENDSQL
		nQtdVen := 0
		nQtdEnt := 0
		While !(cAliasTMP)->( EOF() )
			nQtdVen += (cAliasTMP)->C6_QTDVEN
			nQtdEnt += (cAliasTMP)->C6_QTDENT
			(cAliasTMP)->(dbSkip())
		EndDo
		(cAliasTMP)->(dbCloseArea())
		/*se a quantidade vendida for maior que a quantidade entregue e já tem nf, é pedido Mãe parcial
		devemos permitir a alteração
		se a quantidade vendida for igual à quantidade entregue, o pedido já foi totalmente faturado., não devemos permitir*/
		If nQtdVen <= nQtdEnt 
			cSolucao := "Não poderá ser alterado."
			Help( ,, "HELP","MA410MNU_1", "Pedido já faturado.", 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
			Return
		EndIf
	EndIf

	u_JobBalanca() /*izaias arruda, 28/12/2023, executar a importação dos dados.*/

	SE4->( dbSetOrder( 1 ) )
	SE4->( msSeek( xFilial( "SE4" ) + SC5->C5_CONDPAG ) )

	aAdd( aPergs ,  { 1,; 						//TIPO
						"Pesagem correta",;		    //Descricao
						Space(10),;			        //String contendo o inicializador do campo
						"",;						//String contendo a Picture do campo
						"",;						//String contendo a validacao
						"SZ3X01",;					//Consulta F3
						'.T.',; 					//WHEN
						50,; 						//TAMANHO DO GET
						.T.; 						//OBRIGATÓRIO?
						})

	aAdd( aPergs ,  { 1,; 		//TIPO
						"Ticket Pesagem",;		    //Descricao
						Space(nTamNum),;			//String contendo o inicializador do campo
						"",;						//String contendo a Picture do campo
						"",;						//String contendo a validacao
						"",;					    //Consulta F3
						'.F.',; 					//WHEN
						50,; 						//TAMANHO DO GET
						.T.; 						//OBRIGATÓRIO?
						})
	aCombo := {"Não","Sim"}
    aAdd(aPergs,    {2,;
                        "Pedido Mãe",; 				//pergunta
                        1,; 						//Numerico contendo a opcao inicial do combo
                        aCombo,; 					//Array contendo as opcoes do Combo
                        70,; 						//Tamanho do Combo
                        "",; 						//Validacao
                        .F.; 						//Parametro Obrigatorio ?
                        })

	If ParamBox(aPergs ,"Parametros ") //permitir o usuário salvar, izaias arruda, 12/05/2022
		/*o combo tem problema no parambox, então, temos que tratar o tipo da variável que retornou da pergunta*/
		If Valtype(mv_par03) == "C"
			If Upper(mv_par03) == "SIM"
				mv_par03 := 2
			Else
				mv_par03 := 1
			EndIf
		EndIf
		Processa( {|| MT440PED(mv_par01, mv_par02, mv_par03) }, "Ajustando peso e quantidade no Pedido de Venda..." )
	EndIf

Return

Static Function MT440PED(mv_par01, mv_par02, mv_par03)

	Local aAreaSC6		:= SC6->( GetArea() )
	Local aAreaSC5		:= SC5->( GetArea() )
	Local aAreaSZ3		:= SZ3->( GetArea() )
	Local aFieldsSC5	:= FWSX3Util():GetAllFields( "SC5", .F.)
	Local aFieldsSC6 	:= FWSX3Util():GetAllFields( "SC6", .F.)
	Local aLine     := {}
	Local aItems    := {}
	Local aCabec    := {}
	Local nX as numeric
	Local nLinha as numeric
	Local nCol as numeric
	Local lAlterQTD as Logical
	Local lLiber := .T. as Logical
	Local lTransf := .F. as Logical
	Local nCont := 0
	Local cLiberOk := SC5->C5_LIBEROK

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private aHeader		:= {} /*izaias arruda, precisa na função de análise de crédito*/
	Private aCols		:= {}
	Private INCLUI		:= .F.
	Private ALTERA		:= .T.

	dbSelectArea("SC5")

	ProcRegua(5)

	// /*montar aheader*/
	For nX := 1 to Len(aFieldsSC6)
		If   ((X3USO(GetSX3Cache(aFieldsSC6[nX],"X3_USADO")) .And. ;
				!( Trim(aFieldsSC6[nX]) == "C6_NUM" ) .And.;
				Trim(aFieldsSC6[nX]) != "C6_QTDEMP"  .And.;
				Trim(aFieldsSC6[nX]) != "C6_FILIAL"  .And.;
				Trim(aFieldsSC6[nX]) != "C6_QTDENT") .And.;
				cNivel >= GetSX3Cache(aFieldsSC6[nX],"X3_NIVEL") )
			Aadd(aHeader,{GetSx3Cache(aFieldsSC6[nX],"X3_TITULO"),;
							aFieldsSC6[nX],;
							GetSx3Cache(aFieldsSC6[nX],"X3_PICTURE"),;
							GetSx3Cache(aFieldsSC6[nX],"X3_TAMANHO"),;
							GetSx3Cache(aFieldsSC6[nX],"X3_DECIMAL"),;
							GetSx3Cache(aFieldsSC6[nX],"X3_VALID"),;
							GetSx3Cache(aFieldsSC6[nX],"X3_USADO"),;
							GetSx3Cache(aFieldsSC6[nX],"X3_TIPO"),;
							GetSx3Cache(aFieldsSC6[nX],"X3_F3"),;
							GetSx3Cache(aFieldsSC6[nX],"X3_CONTEXT") } )
		EndIf
	Next nX

	POSSZ3(mv_par02)
	If SZ3->(Recno()) == 0
		Return
	EndIf

    /*carregar cabeçalho do pedido de venda*/
	For nLinha := 1 to Len(aFieldsSC5)
		If X3USO(GetSX3Cache(aFieldsSC5[nLinha],"X3_USADO") ) .And. cNivel >= GetSX3Cache(aFieldsSC5[nLinha],"X3_NIVEL")
			If aFieldsSC5[nLinha] == "C5_PESOL" .OR. aFieldsSC5[nLinha] == "C5_PBRUTO"
				AAdd(aCabec, {aFieldsSC5[nLinha], Val(mv_par01), NIL})
			ElseIf aFieldsSC5[nLinha] == "C5_PLACA1"
				nCont++
				AAdd(aCabec, {aFieldsSC5[nLinha], SZ3->Z3_PLCAVAL, NIL})
			ElseIf aFieldsSC5[nLinha] == "C5_PLACA2"
				nCont++
				AAdd(aCabec, {aFieldsSC5[nLinha], SZ3->Z3_PLACA, NIL})
			Else
				AAdd(aCabec, {aFieldsSC5[nLinha], &("SC5->"+(Alltrim(aFieldsSC5[nLinha]))), NIL})
			EndIf
		EndIf
	Next nLinha

    /*carregar vetor de itens do pedido*/
	SC6->( dbSetOrder( 1 ) ) /*C6_FILIAL+C6_PRODUTO+C6_NUM+C6_ITEM*/
	If SC6->( msSeek( xFilial( "SC6" ) + SC5->C5_NUM ) )
		While !SC6->(EOF()) .and. xFilial( "SC6" ) + SC5->C5_NUM == SC6->(C6_FILIAL+C6_NUM)
			aLine := {}
			lAlterQTD := .F.
			aadd(aCols,Array(Len(aHeader)+1))
			nY := Len(aCols)
			aCols[nY,Len(aHeader)+1] := .F.
			nColAcols := 0
			For nCol := 1 To Len(aFieldsSC6)
				If   ((X3USO(GetSX3Cache(aFieldsSC6[nCol],"X3_USADO")) .And. ;
						!( Trim(aFieldsSC6[nCol]) == "C6_NUM" ) .And.;
						Trim(aFieldsSC6[nCol]) != "C6_QTDEMP"  .And.;
						Trim(aFieldsSC6[nCol]) != "C6_FILIAL"  .And.;
						Trim(aFieldsSC6[nCol]) != "C6_QTDENT") .And.;
						cNivel >= GetSX3Cache(aFieldsSC6[nCol],"X3_NIVEL") )
					//If !Empty(&("SC6->"+(Alltrim(aFieldsSC6[nCol])))) /*não considerar campos vazios*/
						If Alltrim(aFieldsSC6[nCol]) == "C6_QTDVEN"
							If mv_par03 == 1 /*se não for pedido mãe...nos pedidos mãe, não alteramos a quantidade principal*/
								nQtd    := Val(mv_par01) /*coloca a nova quantidade no pedido*/
								AAdd(aLine, {aFieldsSC6[nCol], nQtd, NIL})
								lAlterQTD := .T.
							Else /*se não vai alterar, gravar o conteúdo valor que havia antes*/
								AAdd(aLine, {aFieldsSC6[nCol], &("SC6->"+(Alltrim(aFieldsSC6[nCol]))), NIL})
							EndIf
						ElseIf Alltrim(aFieldsSC6[nCol]) == "C6_QTDLIB"
							nQtd    := Val(mv_par01) /*coloca a nova quantidade no pedido*/
							AAdd(aLine, {aFieldsSC6[nCol], nQtd, NIL})							
						ElseIf Alltrim(aFieldsSC6[nCol]) == "C6_VALOR" .and. lAlterQTD  /*se mexeu na quantidade, precisa corrigir no valor total*/
							nVlrTot := Round(nQtd * SC6->C6_PRCVEN,4)
							AAdd(aLine, {aFieldsSC6[nCol], nVlrTot, NIL})
						Else
							If !Empty(&("SC6->"+(Alltrim(aFieldsSC6[nCol])))) 
								AAdd(aLine, {aFieldsSC6[nCol], &("SC6->"+(Alltrim(aFieldsSC6[nCol]))), NIL})
							Endif
						EndIf
					//EndIf
					nColAcols++
					aCols[nY,nColAcols]	:= &("SC6->"+(Alltrim(aFieldsSC6[nCol])))
				Endif
			Next nCol

			nPos := aScan( aline, { |x| AllTrim(Upper(x[1])) == "C6_QTDVEN" } )
			If !Empty(Len(aLine))
				AAdd(aItems, aLine)
			EndIf
			SC6->( dbSkip() )
		EndDo
	EndIf

	If Len(aItems) > 0
		MSExecAuto({ |a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItems, 4, .F.)
	EndIf

	If lMsErroAuto
		Mostraerro()
	Else
		/*FORÇAR LIBERAÇÃO DO PEDIDO*/
		If cLiberOk == 'S' /*libera apenas se o pedido já estiver liberado anteiormente*/
			dbSelectArea("SC6")
			dbSetOrder(1)
			MsSeek(xFilial("SC6")+SC5->C5_NUM)
			While !Eof() .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM
				RecLock("SC6")
				nQtdLib := ( SC6->C6_QTDVEN - ( SC6->C6_QTDEMP + SC6->C6_QTDENT ) )
				If nQtdLib > 0
					Begin Transaction
						MaLibDoFat(SC6->(RecNo()),@nQtdLib,.F.,.F.,.T.,.T.,lLiber,lTransf)
					End Transaction
				EndIf
				SC6->( MsUnLock() )
				SC6->( dbSkip() )
			EndDo
			Begin Transaction
				SC6->(MaLiberOk({SC5->C5_NUM},.F.))
			End Transaction]
		EndIf

		MarcaUsado(mv_par02, SC5->C5_NUM)
	EndIf

	RestArea( aAreaSC6 )
	RestArea( aAreaSC5 )
	RestArea( aAreaSZ3 )

Return

/*/{Protheus.doc} MarcaUsado
função para marcar a pesagem como usada por um pedido de venda
@type function
@author MASTER TI, Izaias Arruda
@since 1/2024
@param cTicket, character, número do ticket de pesagem
@param cPedVend, character, Número do pedido de venda
@return variant, NULO
/*/
Static Function MarcaUsado(cTicket, cPedVend)
	Local aArea := GetArea()
	Local aAreaSZ3 := SZ3->(GetArea())
	Local cAlias := GetNextAlias()

	BEGINSQL ALIAS cAlias
        SELECT
            SZ3.R_E_C_N_O_ REG
        FROM %Table:SZ3% AS SZ3
        WHERE
            SZ3.%NotDel%
            AND SZ3.Z3_FILIAL = %xFilial:SZ3%
            AND SZ3.Z3_TICKET = %exp:cTicket%
	ENDSQL

	If !(cAlias)->(Eof())
		SZ3->(DbGoto((cAlias)->REG))
		RECLOCK( "SZ3", .F.)
		REPLACE Z3_JAUSADO WITH "X"
		REPLACE Z3_PV WITH cPedVend
		MSUNLOCK()
	EndIf
	(cAlias)->(DbCloseArea())

	/*izaias arruda, 08/01/2023, verificar se o usuário trocou de pesagem e deixou uma pesagem marcada como usada
	então, vamos procurar se há alguma pesagem diferente da escolhida nesse momento para o mesmo pedido.*/

	BEGINSQL ALIAS cAlias
    SELECT
        SZ3.R_E_C_N_O_ REG
    FROM 
		%table:SZ3% AS SZ3
    WHERE
        SZ3.Z3_FILIAL = %xFilial:SZ3% AND
        SZ3.Z3_PV = %exp:SC5->C5_NUM% AND //mesmo pedido
		SZ3.Z3_TICKET <> %exp:cTicket% AND //ticket diferente
		SZ3.%NotDel%
	ENDSQL

	If !(cAlias)->(Eof()) //se achou, limpa os campos
		SZ3->(DbGoto((cAlias)->REG))
		RECLOCK( "SZ3", .F.)
		Replace Z3_JAUSADO	with Space(Len(SZ3->Z3_JAUSADO))
		Replace Z3_PV 		with Space(Len(SZ3->Z3_PV))
		MSUNLOCK()
	EndIf
	(cAlias)->(DbCloseArea())

	SZ3->(RestArea(aAreaSZ3))
	RestArea(aArea)
Return

Static Function POSSZ3(cTicket)
	Local cAlias := GetNextAlias()

	BEGINSQL ALIAS cAlias
        SELECT
            SZ3.R_E_C_N_O_ REG
        FROM %Table:SZ3% AS SZ3
        WHERE
            SZ3.%NotDel%
            AND SZ3.Z3_FILIAL = %xFilial:SZ3%
            AND SZ3.Z3_TICKET = %exp:cTicket%
	ENDSQL

	If !(cAlias)->(Eof())
		SZ3->(DbGoto((cAlias)->REG))
	EndIf
	(cAlias)->(DbCloseArea())
Return
