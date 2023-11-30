#INCLUDE "PROTHEUS.CH"
#Include "FWMVCDEF.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR260  ³ Autor ³ Marcos V. Ferreira    ³ Data ³ 16/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Posicao dos Estoques                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function ESTR003()
	Local oReport

	Private oTempTable	:= NIL
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= ReportDef()
	oReport:PrintDialog()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Marcos V. Ferreira     ³ Data ³16/06/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR260			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
	Local aOrdem    := {OemToAnsi(" Por Codigo         "),OemToAnsi(" Por Tipo           "),OemToAnsi(" Por Descricao     "),OemToAnsi(" Por Grupo        "),OemToAnsi(" Por Almoxarifado   ")}    //" Por Codigo         "###" Por Tipo           "###" Por Descricao     "###" Por Grupo        "###" Por Almoxarifado   "
	Local cAliasTRB := ""
	Local aSizeQT	:= TamSX3("B2_QATU")
	Local aSizeVL	:= TamSX3("B2_VATU1")
	Local nTamProd	:= TamSX3("B1_COD")[1] + 5
	Local cPictQT   := PesqPict("SB2","B2_QATU")
	Local cPictVL   := PesqPict("SB2","B2_VATU1")
	Local oReport
	Local oSection
	Local cPerg		:= "NI_MTR260"

	Gera_SX1(cPerg)

	cAliasTRB:=GetNextAlias()

	oReport:= TReport():New("NI_MATR260","Resumo Kardex",cPerg,,)

	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Variaveis utilizadas para parametros no grupo de pergunta MTR260R1
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// mv_par01 - Data de
	// mv_par02 - Data ate
	// mv_par03 - Produto de
	// mv_par04 - Produto ate
	// mv_par05 - almoxarifado de
	// mv_par06 - almoxarifado ate
	// mv_par07 - tipo de
	// mv_par08 - tipo ate
	// mv_par09 - grupo de
	// mv_par10 - grupo ate
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(oReport:uParam,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do componente de impressao                                      ³
	//³                                                                        ³
	//³TReport():New                                                           ³
	//³ExpC1 : Nome do relatorio                                               ³
	//³ExpC2 : Titulo                                                          ³
	//³ExpC3 : Pergunte                                                        ³
	//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
	//³ExpC5 : Descricao                                                       ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection := TRSection():New(oReport,"Resumo Kardex",{"SB2","SB1"},aOrdem)
	MontaTrab(oReport,oSection:GetOrder(),cAliasTRB,oSection,.T.)
	oReport := TReport():New("NI_MATR260","Resumo Kardex",cPerg, {|oReport| ReportPr(oreport,aOrdem,cAliasTRB)},"Relatório demonstra resumidamente a movimentação de entrada e saída dos produtos, conforme parâmetro") //
	oReport:SetUseGC(.F.) //-- Desabilita GE para não conflitar com perguntas do relatório
	oReport:SetLandscape()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criacao da Sessao 1                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection := TRSection():New(oReport,"Resumo Kardex",{"SB2","SB1",cAliasTRB},aOrdem) //"Saldos em Estoque"
	oSection:SetTotalInLine(.F.)

	TRCell():New(oSection,'B1_COD'	,'SB1',"Código"						   	,/*Picture*/,nTamProd,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,'B1_DESC'	,'SB1',"Descrição"					   	,/*Picture*/,If(oReport:GetOrientation() == 1,50,),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,'B1_UM'	,'SB1',"UM"							   	,/*Picture*/,If(oReport:GetOrientation() == 1,50,),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,'B1_TIPO'	,'SB1',"Tipo"						   	,/*Picture*/,4,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,'B1_GRUPO','SB1',"Grupo"						   	,/*Picture*/,7,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,'B1_CONTA','SB1',"Conta"						   	,/*Picture*/,TAMSX3("CT1_CONTA")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,'QTINICIO',cAliasTRB,"Inicial"+CRLF+"Quantidade" 	,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VUINICIO',cAliasTRB,"Inicial"+CRLF+"Unitário"   	,cPictQT	,aSizeVL[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VTINICIO',cAliasTRB,"Inicial"+CRLF+"Total"      	,cPictQT	,aSizeVL[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'QPRODUCA',cAliasTRB,"Produção"				   	,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VUPROD'	,cAliasTRB,"Unitário"				   	,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VTPROD'	,cAliasTRB,"Custo Prod"					,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'QMOVIOE'	,cAliasTRB,"Entrada"+CRLF+"Mov.Interno"	,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VUMOVIOE',cAliasTRB,"Entrada"+CRLF+"Unitário"	,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VTMOVIOE',cAliasTRB,"Entrada"+CRLF+"Custo Mov.I"	,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'QCOMPRA',cAliasTRB,"Compras"						,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VUCOMPR',cAliasTRB,"Unitário"					,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VTCOMPR',cAliasTRB,"Custo Compras"				,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'QDEVOLU',cAliasTRB,"Dev.Vendas"					,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VUDEVOL',cAliasTRB,"Unitário"					,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VTDEVOL',cAliasTRB,"Custo Dev.Vd."				,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'QOUTROS',cAliasTRB,"Outras Entradas NF"			,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VUOUTRO',cAliasTRB,"Unitário"					,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VTOUTRO',cAliasTRB,"C. Outras NF"				,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'QREQUISI',cAliasTRB,"Req. p/OP"					,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VUREQUIS',cAliasTRB,"Unitário" 					,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VTREQUIS',cAliasTRB,"Custo Req. p/OP"			,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'QMOVIOS',cAliasTRB,"Saída Mov.Int."				,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VUMOVIOS',cAliasTRB,"Unitário"					,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VTMOVIOS',cAliasTRB,"Custo Saída"				,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'QVENDAS',cAliasTRB,"Vendas	"					,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VUVENDA',cAliasTRB,"Unitário"					,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VTVENDA',cAliasTRB,"CPV"							,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'QDEVOLVC',cAliasTRB,"Dev.Compras"				,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VUDEVOLC',cAliasTRB,"Unitário"					,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VTDEVOLC',cAliasTRB,"Custo Dev.Cp"				,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'QOUTROSS',cAliasTRB,"Outras Saídas NF"			,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VUOUTROS',cAliasTRB,"Unitário"					,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VTOUTROS',cAliasTRB,"C. Outras Saídas NF"		,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'QTSALDO'	,cAliasTRB,"Final"+CRLF+"Quantidade"	,cPictQT	,aSizeQT[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VUSALDO'	,cAliasTRB,"Custo"+CRLF+"Unitário"  	,cPictVL	,aSizeVL[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")
	TRCell():New(oSection,'VTSALDO'	,cAliasTRB,"Custo"+CRLF+"Total"  		,cPictVL	,aSizeVL[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")

	oSection:SetHeaderPage()
	oSection:SetNoFilter(cAliasTRB)

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint ³ Autor ³Marcos V. Ferreira   ³ Data ³16/06/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportPrint devera ser criada para todos  ³±±
±±³          ³os relatorios que poderao ser agendados pelo usuario.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatorio                           ³±±
±±³          ³ExpA2: Array com as ordem do relatorio                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR260			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPr(oReport,aOrdem,cAliasTRB)

	Local oSection	:= oReport:Section(1)
	Local nOrdem	:= oSection:GetOrder()
	Local cCodAnt	:= ""
	Local cFilAnter	:= ""
	Local oBreak01

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao do titulo do relatorio                             |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:SetTitle(oReport:Title()+" - ("+AllTrim(aOrdem[oSection:GetOrder()])+")")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao da linha de SubTotal                               |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If StrZero(nOrdem,1) $ "245"
		If nOrdem == 2
			//-- SubtTotal por Tipo
			oBreak01 := TRBreak():New(oSection,oSection:Cell("B1_TIPO"),"Ordem por Tipo",.F.)
		ElseIf nOrdem == 4
			//-- SubtTotal por Grupo
			oBreak01 := TRBreak():New(oSection,oSection:Cell("B1_GRUPO"),"Ordem por Grupo",.F.)
		ElseIf nOrdem == 5
			//-- SubtTotal por Armazem
			oBreak01 := TRBreak():New(oSection,oSection:Cell("B2_LOCAL"),"Tot",.F.)
		EndIf
		//	TRFunction():New(oSection:Cell('VUINICIO'),NIL,"SUM",oBreak01,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
		TRFunction():New(oSection:Cell('QTINICIO'),NIL,"SUM",oBreak01,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
		TRFunction():New(oSection:Cell('VTINICIO'),NIL,"SUM",oBreak01,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao da linha de Total Geral                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRFunction():New(oSection:Cell('QTINICIO'),NIL,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,/*uFormula*/,.T.,.F.)
	TRFunction():New(oSection:Cell('VTINICIO'),NIL,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,/*uFormula*/,.T.,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta arquivo de trabalho                                    |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	MontaTrab(oReport,nOrdem,cAliasTRB,oSection,.F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Processando Impressao                                        |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( cAliasTRB )
	dbGoTop()
	oReport:SetMeter(LastRec())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Posiciona nas tabelas SB1 e SB2                              |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRPosition():New(oSection,"SB1",1,{|| xFilial("SB1")+(cAliasTRB)->CODIGO})
	TRPosition():New(oSection,"SB2",1,{|| xFilial("SB2")+(cAliasTRB)->CODIGO+(cAliasTRB)->LOCAL})

	oSection:Init()
	cCodAnt  := ""
	cFilAnter  := ""

	While !oReport:Cancel() .And. (cAliasTRB)->(!Eof())

		oReport:IncMeter()

		oSection:PrintLine()
		(cAliasTRB)->(dbSkip())

	EndDo

	oSection:Finish()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Apagando arquivo de trabalho temporario                      |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTempTable:Delete()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MontaTrab | Autor ³ Marcos V. Ferreira    ³ Data ³ 16/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preparacao do Arquivo de Trabalho p/ Relatorio             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR260                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontaTrab(oReport,nOrdem,cAliasTRB,oSection,lVisualiz)
	Local _aArea		:= GetArea()
	Local cWhere		:= ""
	Local cWhereB1  	:= ""
	Local cWhereLOCAL 	:= ""
	Local aSizeQT		:= TamSX3( "B2_QATU" )
	Local aSizeVL		:= TamSX3( "B2_VATU1")
	Local aSaldo		:= {}
	Local cAliasSB1		:= "SB1"
	Local lExcl			:= .F.
	Local cCampos		:= ""
	Local cAliasSB2 	:= "SB2"
	Local nX			:= 0
	Local dDataRef, dDataFim
	Local aStrucSB2		:= {}
	Local lVeic			:= Upper(SuperGetMV('MV_VEICULO',.F.,'N'))=="S"
	Local aEntrada 		:= {}
	Local aSaida 		:= {}

	Default lVisualiz:= .F.

	// cria a tabela temporaria para guardar as informacoes para impressão
	NewTable(cAliasTRB, oReport:GetOrientation(),nOrdem,aSizeVL,aSizeQT,lVeic)

	If !lVisualiz
		
		aStrucSB2 := SB2->(dbStruct())
		dDataRef := mv_par01
		dDataFim := mv_par02

		dbSelectArea("SB2")
		oReport:SetMeter(LastRec())

		cSelect := "%"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtro adicional no clausula Where                                     |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhere := "%"
		cWhere += "SB1.B1_COD    BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "

		cWhere += "%"

		cWhereB2 := "%"
		cWhereB2 += "B2_FILIAL = '" + xFilial("SB2") + "'"
		cWhereB2 += "%"

		cWhereB1 := "%"
		cWhereB1 += "B1_FILIAL = '" + xFilial("SB1") + "'"
		cWhereB1 += "%"

		cWhereLOCAL := "%"
		cWhereLOCAL += " SB2.B2_LOCAL BETWEEN '"+ mv_par05 + "' AND '" + mv_par06 + "' "
		cWhereLOCAL += "%"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Transforma parametros Range em expressao SQL                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MakeSqlExpr(oReport:uParam)

		cAliasSB2 := GetNextAlias()
		cAliasSB1 := cAliasSB2

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicio do Embedded SQL                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BeginSql Alias cAliasSB2
			SELECT B2_FILIAL, B2_LOCAL, B2_COD, B2_QATU, B2_QTSEGUM, B2_QFIM, B2_QFIM2, B2_VATU1, B2_VATU2,
			B2_VATU3, B2_VATU4, B2_VATU5, B2_VFIMFF1, B2_VFIMFF2, B2_VFIMFF3, B2_VFIMFF4, B2_VFIMFF5,
			B2_QEMP, B2_QEMP2, B2_QEMPPRE, B2_RESERVA, B2_RESERV2, B2_QEMPSA, B2_QEMPPRJ, B2_VFIM1,
			B2_QEMPPR2, B2_VFIM2, B2_VFIM3, B2_VFIM4, B2_VFIM5, B1_COD, B1_FILIAL, B1_TIPO, B1_GRUPO,
			B1_DESC, B1_GRUPO, B1_CUSTD, B1_UPRC, B1_MCUSTD, B1_SEGUM, B1_UM, B1_CODITE, B1_CONTA,
			B2_SALPPRE, B2_QEPRE2, %Exp:cCampos%

			FROM %table:SB2% SB2
			INNER JOIN %table:SB1% SB1 ON
			%Exp:cWhereB1%
			AND SB1.B1_COD = SB2.B2_COD
			AND SB1.%NotDel%
			WHERE  %Exp:cWhereB2%
			AND SB1.B1_GRUPO BETWEEN %Exp:mv_par09% AND %Exp:mv_par10%
			AND SB1.B1_TIPO  BETWEEN %Exp:mv_par07% AND %Exp:mv_par08%
			AND SB1.B1_CONTA BETWEEN %Exp:mv_par11% AND %Exp:mv_par12%
			AND %Exp:cWhereLOCAL%
			AND %Exp:cWhere%
			AND SB2.%NotDel%
			ORDER BY B2_FILIAL, B2_COD
		EndSql

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Abertura do arquivo de trabalho                              |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea( cAliasSB2 )

		For nX := 1 To Len(aStrucSB2)
			If aStrucSB2[nX][2] <> "C"
				TcSetField(cAliasSB2,aStrucSB2[nX][1],aStrucSB2[nX][2],aStrucSB2[nX][3],aStrucSB2[nX][4])
			EndIf
		Next nX

		If xFilial("SB2") != Space(FwSizeFilial())
			lExcl := .T.
		EndIf

		dbSelectArea( cAliasSB2 )

		While !oReport:Cancel() .And. (cAliasSB2)->(!Eof())

			oReport:IncMeter()
			_cCodPro := (cAliasSB2)->B2_COD

			If IsProdMOD(_cCodPro,.T.)
				dbSelectArea( cAliasSB2 )
				(cAliasSB2)->(dbSkip())
				Loop
			Endif

			_cTipo	 := (cAliasSB2)->B1_TIPO
			_cGrupo	 := (cAliasSB2)->B1_GRUPO
			_cConta	 := (cAliasSB2)->B1_CONTA
			_cDescr	 := (cAliasSB2)->B1_DESC
			_nQINI	 := 0
			_nVINI	 := 0
			_nUINI   := 0
			While !oReport:Cancel() .And. (cAliasSB2)->(!Eof()) .and. _cCodPro == (cAliasSB2)->B2_COD
				aSaldo := CalcEst( _cCodPro,(cAliasSB2)->B2_LOCAL,dDataRef )
				_nQINI += aSaldo[1]
				_nVINI += aSaldo[2]
				If _nQINI <> 0
					_nUINI := Round(_nVINI / _nQINI, 2)
				Else
					_nUINI := 0
				Endif
				dbSelectArea( cAliasSB2 )
				(cAliasSB2)->(dbSkip())
			End

			aEntrada := QryEntrada(_cCodPro, dDataRef, dDataFim)
			aSaida   := QrySaida(_cCodPro, dDataRef, dDataFim)

			nQSaldo := _nQINI + (aEntrada[11] - aSaida[11])
			nVSaldo := _nVINI + (aEntrada[12] - aSaida[12])

			If nQSaldo <> 0 .or. nVSaldo <> 0 .or. _nVINI <> 0

				dbSelectArea( cAliasTRB )
				RecLock(cAliasTRB,.T.)
				FIELD->CODIGO := _cCodPro
				FIELD->TIPO   := _cTipo
				FIELD->GRUPO  := _cGrupo
				FIELD->CONTA  := _cConta
				FIELD->DESCRI := _cDescr
				FIELD->QTINICIO := _nQINI
				FIELD->VUINICIO := _nUINI
				FIELD->VTINICIO := _nVINI

				FIELD->QPRODUCA := aEntrada[1]
				FIELD->VUPROD	:= IIF(aEntrada[1] <> 0, Round(aEntrada[2] / aEntrada[1] , 2), 0)
				FIELD->VTPROD	:= aEntrada[2]
				FIELD->QMOVIOE	:= aEntrada[3]
				FIELD->VUMOVIOE	:= IIF(aEntrada[3] <> 0, Round(aEntrada[4] / aEntrada[3] , 2), 0)
				FIELD->VTMOVIOE	:= aEntrada[4]
				FIELD->QCOMPRA	:= aEntrada[5]
				FIELD->VUCOMPR	:= IIF(aEntrada[5] <> 0, Round(aEntrada[6] / aEntrada[5] , 2), 0)
				FIELD->VTCOMPR	:= aEntrada[6]
				FIELD->QDEVOLU	:= aEntrada[7]
				FIELD->VUDEVOL	:= IIF(aEntrada[7] <> 0, Round(aEntrada[8] / aEntrada[7] , 2), 0)
				FIELD->VTDEVOL	:= aEntrada[8]
				FIELD->QOUTROS	:= aEntrada[9]
				FIELD->VUOUTRO	:= IIF(aEntrada[9] <> 0, Round(aEntrada[10] / aEntrada[9] , 2), 0)
				FIELD->VTOUTRO	:= aEntrada[10]

				FIELD->QREQUISI := aSaida[1]
				FIELD->VUREQUIS	:= IIF(aSaida[1] <> 0, Round(aSaida[2] / aSaida[1] , 2), 0)
				FIELD->VTREQUIS	:= aSaida[2]
				FIELD->QMOVIOS	:= aSaida[3]
				FIELD->VUMOVIOS	:= IIF(aSaida[3] <> 0, Round(aSaida[4] / aSaida[3] , 2), 0)
				FIELD->VTMOVIOS	:= aSaida[4]
				FIELD->QVENDAS	:= aSaida[5]
				FIELD->VUVENDA	:= IIF(aSaida[5] <> 0, Round(aSaida[6] / aSaida[5] , 2), 0)
				FIELD->VTVENDA	:= aSaida[6]
				FIELD->QDEVOLVC := aSaida[7]
				FIELD->VUDEVOLC	:= IIF(aSaida[7] <> 0, Round(aSaida[8] / aSaida[7] , 2), 0)
				FIELD->VTDEVOLC	:= aSaida[8]
				FIELD->QOUTROSS	:= aSaida[9]
				FIELD->VUOUTROS	:= IIF(aSaida[9] <> 0, Round(aSaida[10] / aSaida[9] , 2), 0)
				FIELD->VTOUTROS	:= aSaida[10]

				FIELD->QTSALDO	:= nQSaldo
				if nVSaldo <> 0 .or. nQSaldo <> 0
					FIELD->VUSALDO	:= 0//IIF(nVSaldo <> 0, Round(nVSaldo / nQSaldo, 2), 0)
				else
					FIELD->VUSALDO	:= Round(nVSaldo / nQSaldo, 2)
				endif
				FIELD->VTSALDO	:= nVSaldo
				MsUnlock()
			Endif
			dbSelectArea( cAliasSB2 )
		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apaga os arquivos de trabalho, cancela os filtros e restabelece as ordens originais.|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cAliasSB2)
		dbCloseArea()
	EndIf
	RestArea(_aArea)
Return .T.


Static Function QrySaida(_cCodPro, dDataRef, dDataFim)

	Local _aArea := GetArea()
	Local _cQuery
	Local cCFCPV	:= ""
	Local cCFCMP	:= ""
	Local cCFNF	    := ""
	Local cArqSD2 	:= "QRYSD2"
	Local cArqSD3 	:= "QRYSD3"
	Local nQSaida	:= 0
	Local nVSaida	:= 0
	Local nQMovIP	:= 0
	Local nVMovIP	:= 0
	Local nQMovIO	:= 0
	Local nVMovIO	:= 0
	Local nQSD2VD	:= 0
	Local nVSD2VD	:= 0
	Local nQSD2D	:= 0
	Local nVSD2D	:= 0
	Local nQSD2O	:= 0
	Local nVSD2O	:= 0

	Do Case
	Case cFilAnt == "020103"
		cCFCPV := "5101/5102/5109/5113/5116/5401/5501/5923/6107/7101/7127"
	Endcase
	Do Case
	Case cFilAnt == "020103"
		cCFCMP := "1101/1102"
	Endcase
	Do Case
	Case cFilAnt == "020103"
		cCFNF := "5910/5911/5912/5913/5914/5917/5924/5927/5949/7949"
	Endcase

	_cQuery := "SELECT D3_COD, D3_CF, D3_OP, SUM(D3_QUANT) D3_QUANT, SUM(D3_CUSTO1) D3_CUSTO1"
	_cQuery += " FROM " + RetSqlName("SD3") + " SD3 "
	_cQuery += " WHERE D3_FILIAL = '" + xFilial("SD3") + "'"
	_cQuery += " AND D3_EMISSAO >= '" + Dtos(dDataRef) + "'"
	_cQuery += " AND D3_EMISSAO <= '" + Dtos(dDataFim) + "'"
	_cQuery += " AND D3_LOCAL >= '" + mv_par05 + "'"
	_cQuery += " AND D3_LOCAL <= '" + mv_par06 + "'"
	_cQuery += " AND D3_COD = '" + _cCodPro + "'"
	_cQuery += " AND D3_ESTORNO = ' '"
	_cQuery += " AND D3_TM > '500'"
	_cQuery += " AND SD3.D_E_L_E_T_ = ' '"
	_cQuery += " GROUP BY D3_COD, D3_CF, D3_OP"
	_cQuery := ChangeQuery(_cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),cArqSD3,.t.,.t.)
	dbSelectArea(cArqSD3)
	While (cArqSD3)->(!Eof())
		nQsaida += (cArqSD3)->D3_QUANT
		nVsaida += (cArqSD3)->D3_CUSTO1
		If !Empty((cArqSD3)->D3_OP)
			nQMovIP += (cArqSD3)->D3_QUANT
			nVMovIP += (cArqSD3)->D3_CUSTO1
		Else
			nQMovIO += (cArqSD3)->D3_QUANT
			nVMovIO += (cArqSD3)->D3_CUSTO1
		Endif
		(cArqSD3)->(dbSkip())
	End
	(cArqSD3)->(dbCloseArea())
	_cQuery := "SELECT D2_COD, D2_TIPO, D2_CF, SUM(D2_QUANT) D2_QUANT, SUM(D2_CUSTO1) D2_CUSTO1"
	_cQuery += " FROM " + RetSqlName("SD2") + " SD2, " + RetSqlName("SF4") + " SF4"
	_cQuery += " WHERE D2_FILIAL = '" + xFilial("SD2") + "'"
	_cQuery += " AND D2_EMISSAO >= '" + Dtos(dDataRef) + "'"
	_cQuery += " AND D2_EMISSAO <= '" + Dtos(dDataFim) + "'"
	_cQuery += " AND D2_LOCAL >= '" + mv_par05 + "'"
	_cQuery += " AND D2_LOCAL <= '" + mv_par06 + "'"
	_cQuery += " AND F4_FILIAL = '" + xFilial("SF4") + "'"
	_cQuery += " AND D2_TES = F4_CODIGO"
	_cQuery += " AND F4_ESTOQUE = 'S'"
	_cQuery += " AND D2_COD = '" + _cCodPro + "'"
	_cQuery += " AND SD2.D_E_L_E_T_ = ' '"
	_cQuery += " AND SF4.D_E_L_E_T_ = ' '"
	_cQuery += " GROUP BY D2_COD, D2_TIPO, D2_CF"
	_cQuery += " ORDER BY D2_COD, D2_TIPO, D2_CF"
	_cQuery := ChangeQuery(_cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),cArqSD2,.t.,.t.)
	dbSelectArea(cArqSD2)
	While (cArqSD2)->(!Eof())
		nQsaida += (cArqSD2)->D2_QUANT
		nVsaida += (cArqSD2)->D2_CUSTO1
		If (cArqSD2)->D2_TIPO == "N"
			If AllTrim((cArqSD2)->D2_CF) $ cCFNF
				nQSD2O += (cArqSD2)->D2_QUANT
				nVSD2O += (cArqSD2)->D2_CUSTO1
			Else
				If AllTrim((cArqSD2)->D2_CF) $ cCFCPV
					nQSD2VD += (cArqSD2)->D2_QUANT
					nVSD2VD += (cArqSD2)->D2_CUSTO1
				EndIf
			Endif
		ElseIf (cArqSD2)->D2_TIPO == "D"
			If AllTrim((cArqSD2)->D2_CF) $ cCFCMP
				nQSD2D += (cArqSD2)->D2_QUANT
				nVSD2D += (cArqSD2)->D2_CUSTO1
			EndIf
		Else
			If AllTrim((cArqSD2)->D2_CF) $ cCFNF
				nQSD2O += (cArqSD2)->D2_QUANT
				nVSD2O += (cArqSD2)->D2_CUSTO1
			EndIf
		Endif
		(cArqSD2)->(dbSkip())
	End
	(cArqSD2)->(dbCloseArea())
	RestArea(_aArea)

//			1        2       3        4        5        6        7       8       9      10      11        12          
Return({nQMovIP, nVMovIP, nQMovIO, nVMovIO, nQSD2VD, nVSD2VD, nQSD2D, nVSD2D, nQSD2O, nVSD2O, nQsaida, nVsaida})

Static Function QryEntrada(_cCodPro, dDataRef, dDataFim)

	Local _aArea := GetArea()
	Local _cQuery
	Local cCFCPV	:= ""
	Local cCFCMP	:= ""
	Local cCFNF	    := ""
	Local cArqSD1 := "QRYSD1"
	Local cArqSD3 := "QRYSD3"
	Local nQEntrada:= 0
	Local nVEntrada:= 0
	Local nQMovIP := 0
	Local nVMovIP := 0
	Local nQMovIO := 0
	Local nVMovIO := 0
	Local nQSD1CP := 0
	Local nVSD1CP := 0
	Local nQSD1D  := 0
	Local nVSD1D  := 0
	Local nQSD1O  := 0
	Local nVSD1O  := 0

	Do Case
	Case cFilAnt == "020103"
		cCFCPV := "5101/5102/5109/5113/5116/5401/5501/5923/6107/7101/7127"
	Endcase
	Do Case
	Case cFilAnt == "020103"
		cCFCMP := "1101/1102"
	Endcase
	Do Case
	Case cFilAnt == "020103"
		cCFNF := "5910/5911/5912/5913/5914/5917/5924/5927/5949/7949"
	Endcase

	_cQuery := "SELECT D3_COD, D3_CF, SUM(D3_QUANT) D3_QUANT, SUM(D3_CUSTO1) D3_CUSTO1"
	_cQuery += " FROM " + RetSqlName("SD3") + " SD3 "
	_cQuery += " WHERE D3_FILIAL = '" + xFilial("SD3") + "'"
	_cQuery += " AND D3_EMISSAO >= '" + Dtos(dDataRef) + "'"
	_cQuery += " AND D3_EMISSAO <= '" + Dtos(dDataFim) + "'"
	_cQuery += " AND D3_LOCAL >= '" + mv_par05 + "'"
	_cQuery += " AND D3_LOCAL <= '" + mv_par06 + "'"
	_cQuery += " AND D3_COD = '" + _cCodPro + "'"
	_cQuery += " AND D3_ESTORNO = ' '"
	_cQuery += " AND D3_TM < '500'"
	_cQuery += " AND SD3.D_E_L_E_T_ = ' '"
	_cQuery += " GROUP BY D3_COD, D3_CF"
	_cQuery := ChangeQuery(_cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),cArqSD3,.t.,.t.)
	dbSelectArea(cArqSD3)
	While (cArqSD3)->(!Eof())
		nQEntrada += (cArqSD3)->D3_QUANT
		nVEntrada += (cArqSD3)->D3_CUSTO1
		If (cArqSD3)->D3_CF == "PR0"
			nQMovIP += (cArqSD3)->D3_QUANT
			nVMovIP += (cArqSD3)->D3_CUSTO1
		Else
			nQMovIO += (cArqSD3)->D3_QUANT
			nVMovIO += (cArqSD3)->D3_CUSTO1
		Endif
		(cArqSD3)->(dbSkip())
	End
	(cArqSD3)->(dbCloseArea())
	_cQuery := "SELECT D1_COD, D1_TIPO, D1_CF, F4_DUPLIC, SUM(D1_QUANT) D1_QUANT, SUM(D1_CUSTO) D1_CUSTO"
	_cQuery += " FROM " + RetSqlName("SD1") + " SD1, " + RetSqlName("SF4") + " SF4"
	_cQuery += " WHERE D1_FILIAL = '" + xFilial("SD1") + "'"
	_cQuery += " AND D1_DTDIGIT >= '" + Dtos(dDataRef) + "'"
	_cQuery += " AND D1_DTDIGIT <= '" + Dtos(dDataFim) + "'"
	_cQuery += " AND D1_LOCAL >= '" + mv_par05 + "'"
	_cQuery += " AND D1_LOCAL <= '" + mv_par06 + "'"
	_cQuery += " AND F4_FILIAL = '" + xFilial("SF4") + "'"
	_cQuery += " AND D1_TES = F4_CODIGO"
	_cQuery += " AND F4_ESTOQUE = 'S'"
	_cQuery += " AND D1_COD = '" + _cCodPro + "'"
	_cQuery += " AND SD1.D_E_L_E_T_ = ' '"
	_cQuery += " AND SF4.D_E_L_E_T_ = ' '"
	_cQuery += " GROUP BY D1_COD, D1_TIPO, F4_DUPLIC,D1_CF"
	_cQuery := ChangeQuery(_cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),cArqSD1,.t.,.t.)
	dbSelectArea(cArqSD1)
	While (cArqSD1)->(!Eof())
		nQEntrada += (cArqSD1)->D1_QUANT
		nVEntrada += (cArqSD1)->D1_CUSTO
		If (cArqSD1)->D1_TIPO == "N"
			If (cArqSD1)->F4_DUPLIC == "S"
				If AllTrim((cArqSD1)->D1_CF) $ cCFCMP
					nQSD1CP += (cArqSD1)->D1_QUANT
					nVSD1CP += (cArqSD1)->D1_CUSTO
				EndIf	
			Else
				IF AllTrim((cArqSD1)->D1_CF) $ cCFNF
					nQSD1O += (cArqSD1)->D1_QUANT
					nVSD1O += (cArqSD1)->D1_CUSTO
				EndIf
			Endif
		ElseIF (cArqSD1)->D1_TIPO == "D"
			If AllTrim((cArqSD1)->D1_CF) $ cCFCMP
				nQSD1D += (cArqSD1)->D1_QUANT
				nVSD1D += (cArqSD1)->D1_CUSTO
			EndIf	
		else
			IF AllTrim((cArqSD1)->D1_CF) $ cCFNF 
				nQSD1O += (cArqSD1)->D1_QUANT
				nVSD1O += (cArqSD1)->D1_CUSTO
			Endif
		Endif
		(cArqSD1)->(dbSkip())
	End
	(cArqSD1)->(dbCloseArea())
	RestArea(_aArea)

// entrada  entrada entrada  entrada entrada  entrada entrada  entrada entrada  entrada entrada  entrada entrada  entrada 
//			1        2       3        4        5        6        7       8       9      10        11        12          
Return({nQMovIP, nVMovIP, nQMovIO, nVMovIO, nQSD1CP, nVSD1CP, nQSD1D, nVSD1D, nQSD1O, nVSD1O, nQEntrada, nVEntrada})

/*/{Protheus.doc} NewTable
//TODO Cria a tabela temporaria para armazenar as informaçoes que serão impressas
@author reynaldo
@since 26/02/2018
@version 1.0
@return logico, sempre verdadeiro
@param cAliasTRB, caracter, nome do alias da tabela
@param lTamDesc, logical, define o tamanho do descricao, conforme orientacao de impressao do relatorio
@param nOrdem, numeric, define a ordem de impressão que impacta na ordenacao dos registros
@param aSizeVL, array, tamanho e decimais para campos de valor(custo)
@param aSizeQT, array, tamanho e decimais para campos de quantidade
@param lVeic, logical, descricao
@type function
/*/
Static Function NewTable(cAliasTRB, lTamDesc,nOrdem,aSizeVL,aSizeQT,lVeic)
	Local aCampos	:= {}
	Local aIndxKEY	:= {}

	DEFAULT aSizeQT	:= TamSX3( "B2_QATU" )
	DEFAULT aSizeVL	:= TamSX3( "B2_VATU1")

	aCampos:= {	{ "FILIAL"	,"C",FWSizeFilial(),00 },;
		{ "CODIGO"	,"C",TamSX3("B1_COD")[1],00 },;
		{ "LOCAL"	,"C",TamSX3("B2_LOCAL")[1],00 },;
		{ "TIPO"	,"C",02	,00 },;
		{ "GRUPO"	,"C",04	,00 },;
		{ "CONTA"	,"C",TamSX3("CT1_CONTA")[1]	,00 },;
		{ "DESCRI"	,"C",If(lTamDesc == 1,50,TamSX3("B1_DESC")[1]),00 },;
		{ "QTINICIO","N",aSizeQT[ 1 ]+1	, aSizeQT[ 2 ] },;
		{ "VUINICIO","N",aSizeVL[ 1 ]+1	, aSizeVL[ 2 ] },;
		{ "VTINICIO","N",aSizeVL[ 1 ]+1	, aSizeVL[ 2 ] },;
		{ "QPRODUCA","N",aSizeQT[ 1 ]+1	, aSizeQT[ 2 ] },;
		{ "VUPROD"  ,"N",aSizeVL[ 1 ]+1	, aSizeVL[ 2 ] },;
		{ "VTPROD"  ,"N",aSizeVL[ 1 ]+1	, aSizeVL[ 2 ] },;
		{ "QMOVIOE"	,"N",aSizeQT[ 1 ]+1	, aSizeQT[ 2 ] },;
		{ "VUMOVIOE" ,"N",aSizeVL[ 1 ]+1, aSizeVL[ 2 ] },;
		{ "VTMOVIOE" ,"N",aSizeVL[ 1 ]+1, aSizeVL[ 2 ] },;
		{ "QVENDAS"	,"N",aSizeQT[ 1 ]+1	, aSizeQT[ 2 ] },;
		{ "VUVENDA" ,"N",aSizeVL[ 1 ]+1	, aSizeVL[ 2 ] },;
		{ "VTVENDA" ,"N",aSizeVL[ 1 ]+1	, aSizeVL[ 2 ] },;
		{ "QDEVOLU"	,"N",aSizeQT[ 1 ]+1	, aSizeQT[ 2 ] },;
		{ "VUDEVOL" ,"N",aSizeVL[ 1 ]+1	, aSizeVL[ 2 ] },;
		{ "VTDEVOL" ,"N",aSizeVL[ 1 ]+1	, aSizeVL[ 2 ] },;
		{ "QOUTROS"	,"N",aSizeQT[ 1 ]+1	, aSizeQT[ 2 ] },;
		{ "VUOUTRO" ,"N",aSizeVL[ 1 ]+1	, aSizeVL[ 2 ] },;
		{ "VTOUTRO" ,"N",aSizeVL[ 1 ]+1	, aSizeVL[ 2 ] },;
		{ "QREQUISI","N",aSizeQT[ 1 ]+1	, aSizeQT[ 2 ] },;
		{ "VUREQUIS","N",aSizeVL[ 1 ]+1	, aSizeVL[ 2 ] },;
		{ "VTREQUIS","N",aSizeVL[ 1 ]+1	, aSizeVL[ 2 ] },;
		{ "QMOVIOS"	,"N",aSizeQT[ 1 ]+1	, aSizeQT[ 2 ] },;
		{ "VUMOVIOS" ,"N",aSizeVL[ 1 ]+1, aSizeVL[ 2 ] },;
		{ "VTMOVIOS" ,"N",aSizeVL[ 1 ]+1, aSizeVL[ 2 ] },;
		{ "QCOMPRA"	 ,"N",aSizeQT[ 1 ]+1, aSizeQT[ 2 ] },;
		{ "VUCOMPR"  ,"N",aSizeVL[ 1 ]+1, aSizeVL[ 2 ] },;
		{ "VTCOMPR"  ,"N",aSizeVL[ 1 ]+1, aSizeVL[ 2 ] },;
		{ "QDEVOLVC" ,"N",aSizeQT[ 1 ]+1, aSizeQT[ 2 ] },;
		{ "VUDEVOLC" ,"N",aSizeVL[ 1 ]+1, aSizeVL[ 2 ] },;
		{ "VTDEVOLC" ,"N",aSizeVL[ 1 ]+1, aSizeVL[ 2 ] },;
		{ "QOUTROSS" ,"N",aSizeQT[ 1 ]+1, aSizeQT[ 2 ] },;
		{ "VUOUTROS" ,"N",aSizeVL[ 1 ]+1, aSizeVL[ 2 ] },;
		{ "VTOUTROS" ,"N",aSizeVL[ 1 ]+1, aSizeVL[ 2 ] },;
		{ "QTSALDO","N"	,aSizeQT[ 1 ]+1	, aSizeQT[ 2 ] },;
		{ "VUSALDO","N"	,aSizeVL[ 1 ]+1	, aSizeVL[ 2 ] },;
		{ "VTSALDO","N"	,aSizeVL[ 1 ]+1	, aSizeVL[ 2 ] }}

	Aadd(aIndxKEY,"LOCAL")

	If Select(cAliasTRB) >0
		If oTempTable:lCreated
			oTempTable:delete()
		EndIf
	EndIf

	oTempTable := FWTemporaryTable():New( cAliasTRB )
	oTempTable:SetFields( aCampos )
	oTempTable:AddIndex("01", aIndxKEY )
	oTempTable:Create()

Return .T.

Static Function Gera_SX1(cPerg)

	Local i := 0
	Local j := 0
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	aRegs:={}

	aAdd(aRegs,{cPerg,"01","Data De        ?"  ,"","","mv_ch1","D",08						,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Data Ate       ?"  ,"","","mv_ch2","D",08						,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Produto De     ?"  ,"","","mv_ch3","C",TAMSX3("B1_COD")[1]		,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	AADD(aRegs,{cPerg,"04","Produto Ate    ?"  ,"","","mv_ch4","C",TAMSX3("B1_COD")[1]		,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	AADD(aRegs,{cPerg,"05","Almox. De      ?"  ,"","","mv_ch5","C",TAMSX3("B1_LOCPAD")[1]	,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","NNR"})
	AADD(aRegs,{cPerg,"06","Almox. Ate     ?"  ,"","","mv_ch6","C",TAMSX3("B1_LOCPAD")[1]	,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","NNR"})
	AADD(aRegs,{cPerg,"07","Tipo De        ?"  ,"","","mv_ch7","C",TAMSX3("B1_TIPO")[1]		,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","02"})
	AADD(aRegs,{cPerg,"08","Tipo Ate       ?"  ,"","","mv_ch8","C",TAMSX3("B1_TIPO")[1]		,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","02"})
	AADD(aRegs,{cPerg,"09","Grupo De       ?"  ,"","","mv_ch9","C",TAMSX3("B1_GRUPO")[1]	,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})
	AADD(aRegs,{cPerg,"10","Grupo Ate      ?"  ,"","","mv_cha","C",TAMSX3("B1_GRUPO")[1]	,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})
	AADD(aRegs,{cPerg,"11","Conta De       ?"  ,"","","mv_chb","C",TAMSX3("CT1_CONTA")[1]	,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","CT1"})
	AADD(aRegs,{cPerg,"12","Conta Ate      ?"  ,"","","mv_chc","C",TAMSX3("CT1_CONTA")[1]	,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","CT1"})

	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
Return
