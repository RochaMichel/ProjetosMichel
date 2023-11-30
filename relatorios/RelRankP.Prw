#INCLUDE "LOJR780.CH"
#INCLUDE "PROTHEUS.CH"

*******************************************************************************
// Função : RelRankP - Ranking de Produtos por Preco ou por Quantidade  	  |
// Modulo : Faturamento                                                       |
// Fonte  : RelRankP.prw                                                      |
// ---------+--------------------------+--------------------------------------+
// Data     | Autor                    | Uso	                              |
// ---------+--------------------------+--------------------------------------+
// 24/03/23 | Rivaldo Júnior - Cod.ERP | Protheus - Relatorio			      |
*******************************************************************************
User Function RelRankP()
	Local oReport
	Local aArea := GetArea()      

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros						 ³
	//³ mv_par01				 // De Grupo						 ³
	//³ mv_par02				 // Ate o Grupo						 ³
	//³ mv_par03				 // De Data 						 ³
	//³ mv_par04				 // Ate a Data 						 ³
	//³ mv_par05				 // De Produto 						 ³
	//³ mv_par06				 // Ate o Produto 					 ³
	//³ mv_par07				 // Ranking p/ Preco ou Quant.		 ³
	//³ mv_par08				 // Classificacao s 10 Mais,...      ³
	//³         				 // ...os 20 mais,.                  ³
	//³ mv_par09				 // Considera as devolucoes para a   ³
	//³         				 // geracao do ranking               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("LJR780",.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := Ljr780RptDef()
	oReport:PrintDialog()

	RestArea( aArea )
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Ljr780RptDefºAutor  ³Vendas e CRM      º Data ³  25/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para informar as celulas que serao utilizadas no re- º±±
±±º          ³latorio                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA780                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Ljr780RptDef()
Local oReport										// Objeto do relatorio
Local oSection1										// Objeto da secao 1
Local cAlias1	:= GetNextAlias()					// Pega o proximo Alias Disponivel
Local aTamCod	:= TamSX3("B1_COD")
Local lTop      := .T.                        		// Verifica se esta usando o Top

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera a tela com os dados para a confirmação da geracao do relatorio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                                        
// Ranking de Produtos
//"Este programa irá emitir um Ranking de Produtos por" "Preço ou Quantidade em Moeda Corrente."
oReport := TReport():New("LOJR780",STR0005,"LJR780",{|oReport| Ljr780PrtRpt(oReport,cAlias1)}, STR0001 + STR0002 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define a secao1 do relatorio, informando que o arquivo principal utlizado eh o SL2 e o complementar o SB1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport,STR0013,{"SB1"} )		// Detalhes dos Produtos
oSection1:SetTotalText("")									// Inibe o texto da secao
oSection1:SetTotalInLine(.F.)								// Imprime total em linha ou coluna (default .T. - linha )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define as celulas que irao aparecer na secao1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRCell():New(oSection1,"COD"		,cAlias1,STR0012,"@!",If(aTamCod[1]>13, aTamCod[1], 13))					// "Código "
TRCell():New(oSection1,"B1_DESC"	,"SB1",,,170,,,,,,,,.T.)
TRCell():New(oSection1,"QUANT"		,cAlias1,STR0008,"@E 999,999.99"		,18	,NIL, If(cPaisLoc == "BRA" .And. lTop, Nil, {|| Lj780QtdCalc(1) }),"RIGHT",,"RIGHT",,,.T.  ) // "Quantidade")
TRCell():New(oSection1,"B1_UM"		,"SB1",,,15,,,"CENTER",,"CENTER",,,.T.)
TRCell():New(oSection1,"VALOR"		,cAlias1,STR0007,"@E 999,999,999.9999"	,18 ,NIL, If(cPaisLoc == "BRA" .And. lTop, Nil, {|| Lj780QtdCalc(2) }),"RIGHT",,"RIGHT",,,.T. ) // "Valor"
TRCell():New(oSection1,"VALOR MEDIO",cAlias1,,"@E 999,999,999.9999"			,18 ,NIL, ,"RIGHT",,"RIGHT",,,.T. ) // "Valor Medio"

TRFunction():New(oSection1:Cell("QUANT"),,"SUM",,,,,,.F.)		// Ultimo parametro informa que nao deve imprimir o total no final da secao, somente no final do relatorio
TRFunction():New(oSection1:Cell("VALOR"),,"SUM",,,,,,.F.)
TRFunction():New(oSection1:Cell("VALOR MEDIO"),,"SUM",,,,,,.F.)

Return oReport

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Ljr780PrtRptºAutor  ³Vendas e CRM        º Data ³  25/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para impressao do relatorio personalizavel             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJR780                                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Ljr780PrtRpt( oReport, cAlias1 )
	Local oSection1 := oReport:Section(1)				// Define a secao 1 do relatorio
	Local cPart		:= ""								// Condicoes do IF, para ser incluido na query
	Local cOrderBy	:= ""								// Indice que sera usado no order by
	Local nCont		:= 0								// Contador de acordo com o parametro mv_par08
	Local nQtdeRegs := 0								// Contador para delimitar o tamanho da regua de progressao
	Local cUn2 		:= ""
	Local cConv 	:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros do tipo Range em expressao SQL para ser utilizada na query ³
	//³Exemplo Word, nao intervalos pre definidos (mais utilizado pelo RH - Ferias)     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr("LJR190")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se considera devolucao ou nao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MV_PAR09 == 2
		cPart := "%L2_STATUS  <> 'D' AND %"
	Else
		cPart := "%%"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³De acordo com o parametro, monta a ordem do relatorio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MV_PAR07 == 1
		cOrderBy := "%B1_DESC ,VALOR DESC %"
	Else
		cOrderBy := "%B1_DESC ,QUANT DESC %"
	EndIf	


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa a secao 1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//BEGIN REPORT QUERY oSection1

	If MV_PAR09 == 2				// Parametro que define se considera devolucao
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Query utilizada para filtrar todos os dados necessarios ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

		BeginSql alias cAlias1
			SELECT	B1_COD COD,	B1_DESC, B1_UM,	SUM(L2_QUANT) QUANT, SUM(L2_VLRITEM+L2_VALIPI) VALOR
		
			FROM %table:SB1% SB1,%table:SF4% SF4,%table:SL1% SL1,%table:SL2% SL2 			

			LEFT JOIN %table:SC6% SC6 ON (C6_FILIAL=L2_FILIAL AND C6_NUM=L2_PEDRES AND SC6.%notDel%)									 
			WHERE	B1_FILIAL	=	%xfilial:SB1%			AND	
					L2_FILIAL	=	%xfilial:SL2%			AND
					F4_FILIAL	=	%xfilial:SF4%			AND
					L1_FILIAL	= 	%xfilial:SL1%			AND
					SL1.%notDel%							AND
					L2_NUM = L1_NUM                         AND
					L2_DOC = L1_DOC                         AND
					L2_PDV = L1_PDV                         AND
					L1_STORC <> 'C'							AND
					B1_GRUPO	>=	%exp:mv_par01%			AND                                               
					B1_GRUPO	<=	%exp:mv_par02%			AND
					L2_EMISSAO	>=	%exp:DTOS(mv_par03)%	AND
					L2_EMISSAO	<=	%exp:DTOS(mv_par04)%	AND
					L2_PRODUTO	>=	%exp:mv_par05%			AND
					L2_PRODUTO	<=	%exp:mv_par06%			AND                                   
					L2_TES		=	F4_CODIGO				AND
					L2_PRODUTO	=	B1_COD					AND
				    (L2_VENDIDO = 	'S'  OR (L2_ENTREGA = '3' AND L2_PEDRES <> ' ' AND C6_QTDVEN = C6_QTDENT)) AND
					F4_DUPLIC	=	'S'						AND
					SL2.%notDel%							AND
					%exp:cPart%
					SF4.%notDel%							AND
					SB1.%notDel%							
	
			GROUP BY B1_COD, B1_DESC, B1_UM, L2_PRODUTO
			ORDER BY %exp:cOrderBy%	

		EndSql
	Else
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Query utilizada para filtrar todos os dados necessarios ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BeginSql alias cAlias1
		
			SELECT COD,		B1_DESC,	B1_UM,	SUM(QUANT) QUANT,	SUM(VALOR) VALOR
			FROM (
			
				SELECT	B1_COD COD,		B1_DESC,	B1_UM,	SUM(L2_QUANT) QUANT,	SUM(L2_VLRITEM+L2_VALIPI) VALOR
				FROM %table:SB1% SB1, %table:SF4% SF4, %table:SL1% SL1, %table:SL2% SL2
				LEFT JOIN %table:SC6% SC6 ON (C6_FILIAL=L2_FILIAL AND C6_NUM=L2_PEDRES AND SC6.%notDel%) 
				WHERE	B1_FILIAL		=	%xfilial:SB1%			AND
						L2_FILIAL		=	%xfilial:SL2%			AND
						F4_FILIAL		=	%xfilial:SF4%			AND
						L1_FILIAL		= 	%xfilial:SL1%			AND
						L2_NUM 			= 	L1_NUM              	AND
						L2_DOC 			= 	L1_DOC              	AND
						L2_PDV 			= 	L1_PDV              	AND
						L1_STORC 		<> 	'C'						AND
						B1_GRUPO		>=	%exp:mv_par01%			AND
						B1_GRUPO		<=	%exp:mv_par02%			AND
						L2_EMISSAO		>=	%exp:DTOS(mv_par03)%	AND
						L2_EMISSAO		<=	%exp:DTOS(mv_par04)%	AND
						L2_PRODUTO		>=	%exp:mv_par05%			AND
						L2_PRODUTO		<=	%exp:mv_par06%			AND
						L2_TES			=	F4_CODIGO				AND
						L2_PRODUTO		=	B1_COD					AND
						(L2_VENDIDO 	= 	'S'  OR (L2_ENTREGA = '3' AND L2_PEDRES <> ' ' AND C6_QTDVEN = C6_QTDENT)) AND
						F4_DUPLIC		=	'S'						AND
						%exp:cPart%
						SL1.%notDel%								AND
						SL2.%notDel%								AND
						SF4.%notDel%								AND
						SB1.%notDel%
						
						
				GROUP BY B1_COD, B1_DESC, B1_UM
				
				UNION
				
				SELECT	D1_COD COD, 	B1_DESC,	B1_UM,	(-SUM(D1_QUANT)) QUANT, (-SUM(D1_TOTAL+D1_VALIPI)) VALOR
				FROM %table:SD1% SD1, %table:SB1% SB1
				WHERE 	D1_FILIAL		=  %xfilial:SD1% 			AND
						B1_FILIAL		=  %xfilial:SB1% 			AND
						D1_COD			=  B1_COD 					AND
						B1_GRUPO		>= %exp:mv_par01% 			AND
						B1_GRUPO		<= %exp:mv_par02% 			AND
						D1_EMISSAO  	>= %exp:DTOS(mv_par03)% 	AND
						D1_EMISSAO  	<= %exp:DTOS(mv_par04)% 	AND
						D1_COD      	>= %exp:mv_par05% 			AND
						D1_COD      	<= %exp:mv_par06% 			AND
						D1_TIPO			=  'D' 						AND
						D1_ORIGLAN 		=  'LO' 					AND
						SD1.%notDel% 								AND
						SB1.%notDel%
				GROUP BY D1_COD, B1_DESC, B1_UM
			
			) TABTMP
			
			GROUP BY  COD,	B1_DESC,B1_UM
			
			ORDER BY %exp:cOrderBy%
			
		EndSql
		
	EndIf

	//END REPORT QUERY oSection1

	
	//Conta aproximadamente a quantidade de registros para definir o tamanho da regua de processamento.
	//Foi feito desta forma para melhorar o desempenho do processamento, fazendo a contagem dos registros de forma mais rapida.
	While (cAlias1)->( !EoF() )
		nQtdeRegs++
		(cAlias1)->(DbSkip(100))
	End
	nQtdeRegs := nQtdeRegs * 100
	(cAlias1)->(DbGoTop())
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o parametro estiver 0, imprime todo o ranking.         ³
	//³Se estiver com uma quantidade limitada deve ser controlado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea(cAlias1)
	oReport:SetMeter(nQtdeRegs)
	oSection1:Init()
	While (cAlias1)->( !EOF() )
		
		oReport:IncMeter() 

		If oReport:Cancel()
			Exit
		EndIf

		oSection1:Cell("COD"):SetValue((cAlias1)->COD)
		oSection1:Cell("B1_DESC"):SetValue(AllTrim((cAlias1)->B1_DESC))

		cUn2 := Posicione("SB1",1,xFilial("SB1")+(cAlias1)->COD,"B1_SEGUM")
		cConv := Posicione("SB1",1,xFilial("SB1")+(cAlias1)->COD,"B1_CONV")

		If !Empty(cUn2) .And. cConv > 0
			oSection1:Cell("QUANT"):SetValue((cAlias1)->QUANT*cConv)
			oSection1:Cell("B1_UM"):SetValue(cUn2)
			oSection1:Cell("VALOR"):SetValue((cAlias1)->VALOR)
			oSection1:Cell("VALOR MEDIO"):SetValue(((cAlias1)->VALOR/((cAlias1)->QUANT*cConv)))
		Else
			oSection1:Cell("QUANT"):SetValue((cAlias1)->QUANT)
			oSection1:Cell("B1_UM"):SetValue((cAlias1)->B1_UM)
			oSection1:Cell("VALOR"):SetValue((cAlias1)->VALOR)
			oSection1:Cell("VALOR MEDIO"):SetValue(((cAlias1)->VALOR/(cAlias1)->QUANT))
		EndIf
				
		oSection1:PrintLine()
		(cAlias1)->( DbSkip() )
		If MV_PAR08 > 0
			nCont	:= nCont + 1
			If nCont >= MV_PAR08
				Exit
			Endif
		Endif
	End

	oSection1:Finish()


Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³Lj780QtdCalc³ Autor ³ Vendas e CRM		³ Data ³ 04.07.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula a quantidade e  o valor do produto que esta   	  ³±±
±±³			 ³ posicionado na linha de impressao do relatorio			  ³±±	
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJR780                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Lj780QtdCalc( nTipo )
Local nQuant	:= QUANT		// Recebe a quantidade do produto que esta sendo impresso 
Local cCodPro	:= COD			// Recebe o Codigo do produto
Local nQtdDev	:= 0			// Quantidade do produto que foi devolvida
Local nValDev   := 0			// Valor que foi devolvido
Local aArea 	:= GetArea()
Local nMoeda  	:= 1			// Moeda
Local nDecs 	:= 2			// Decimais
Local nResult	:= 0

Static nVlrAtu	                // Recebe o valor do produto que esta sendo impresso

If nTipo == 1
	nVlrAtu    := VALOR
	If (MV_PAR09 == 1)    		// Parametro que define se considera devolucao
		DbSelectArea("SD1")
		DbSetOrder(2)
		If DbSeek( xFilial("SD1") + cCodPro )
			While !Eof() .AND. ( SD1->D1_FILIAL + SD1->D1_COD == xFilial("SD1") + cCodPro )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se o e' devolucao, e se esta dentro do periodo. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	     		If 	SD1->D1_TIPO <> "D" .OR. SD1->D1_ORIGLAN <> "LO".OR. ;
	     		(SD1->D1_EMISSAO < MV_PAR03 .OR. SD1->D1_EMISSAO > MV_PAR04)
					SD1->(dbSkip())
					Loop
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza a quantidade do produto que foi devolvido ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nQtdDev += SD1->D1_QUANT
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o Valor do produto que foi devolvido ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cPaisLoc == "BRA"
					nValDev += SD1->D1_TOTAL + SD1->D1_VALIPI
				Else
					dbSelectArea("SF1")
					dbSetOrder(1)
					If dbSeek(xFilial("SF1") + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_TIPO)
						nMoeda := 	Max(SF1->F1_MOEDA,1)
						nDecs  := 	MsDecimais(1)
						nVlrAtu += 	Round(xMoeda(SD1->D1_TOTAL,nMoeda,1,SD1->D1_EMISSAO,nDecs+1),nDecs) + ;
									RetImposto( SD1->D1_TES )[1] // Imposto Discriminado
					EndIf
				EndIf
			
				SD1->(dbSkip())
			End 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso tenha algum produto devolvido atualiza a quantidade³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( nQtdDev > 0 .OR. nValDev > 0 ) 
		  		nQuant 	-= nQtdDev
		  		nVlrAtu	-= nValDev
			EndIf          		
		EndIf
	EndIf
EndIf
		
RestArea( aArea )

If nTipo == 1
	nResult := nQuant
Else
	nResult := Abs(nVlrAtu)
EndIf

Return nResult  
