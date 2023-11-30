#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#include "TopConn.ch"
#include "COLORS.ch"

#define CLR_SILVER rgb(192,192,192)
#define CLR_LightSteelBlue rgb(176,196,222)

*******************************************************************************
// Função : RelTtRec - rel. titulos recebidos por atividade de negocios		  |
// Modulo : Financeiro                                                        |
// Fonte  : RelTtRec.prw                                                      |
// ---------+----------------------------+------------------------------------+
// Data     | Autor             		 | Descricao                          |
// ---------+----------------------------+------------------------------------+
// 09/01/23 | Rivaldo Júnior - Cod.ERP   | Relatório			              |
*******************************************************************************

User Function RelTtRec()
	PRIVATE cTitulo     := 'Relatorio de titulos recebidos por atividade de negocios'
	PRIVATE cDescri     := ""
	PRIVATE cFunName    := FunName()
	PRIVATE oRelatorio
	PRIVATE aPergs      := {}
	PRIVATE _lBold      := .T. //Controle de IMpressÃ£o em NEgrito
	PRIVATE lAutoSize   := .T.

	aAdd( aPergs ,{1,"De Filial "	      , space(TamSX3("E1_FILIAL")[1])       ,"@!",'.T.','   ','.T.',TamSX3("E5_FILIAL")[1]+50	,.F.}) //MV_PAR01
	aAdd( aPergs ,{1,"Até Filial "        , space(TamSX3("E1_FILIAL")[1])       ,"@!",'.T.','   ','.T.',TamSX3("E5_FILIAL")[1]+50	,.T.}) //MV_PAR02
	aAdd( aPergs ,{1,"Do Titulo: "        , space(TamSX3("E5_NUMERO")[1]) 		, "" ,'.T.',"SE1",'.T.', 40						 	,.F.}) //MV_Par03
	aAdd( aPergs ,{1,"Até Titulo: "       , space(TamSX3("E5_NUMERO")[1]) 		, "" ,'.T.',"SE1",'.T.', 40						    ,.T.}) //MV_Par04
	aAdd( aPergs ,{1,"De Emissao "		  , ctod(space(TamSX3("E1_EMISSAO")[1])),"@!",'.T.','   ','.T.',TamSX3("E1_EMISSAO")[1]+50	,.F.}) //MV_PAR05
	aAdd( aPergs ,{1,"Até Emissao "	   	  , ctod(space(TamSX3("E1_EMISSAO")[1])),"@!",'.T.','   ','.T.',TamSX3("E1_EMISSAO")[1]+50	,.T.}) //MV_PAR06
	aAdd( aPergs ,{1,"De Vencimento "  	  , ctod(space(TamSX3("E1_VENCREA")[1])),"@!",'.T.','   ','.T.',TamSX3("E1_VENCREA")[1]+50	,.F.}) //MV_PAR07
	aAdd( aPergs ,{1,"Até Vencimento " 	  , ctod(space(TamSX3("E1_VENCREA")[1])),"@!",'.T.','   ','.T.',TamSX3("E1_VENCREA")[1]+50	,.T.}) //MV_PAR08
	aAdd( aPergs ,{2,"Tipo de Relatório: ", "1" , {"1=Sintético","2=Analítico"} , 60 ,".T.",.T.})										   //MV_PAR09

	If !parambox(aPergs,"Informe os parametros")
		Return
	EndIf

	oRelatorio  := TReport():New(cFunName, cTitulo,, {|oRelatorio| PrintReport(oRelatorio)}, cDescri)
	oRelatorio:SetTotalInLine(.T.)
	oRelatorio:SetCustomText({||CriaCab(oRelatorio)})

	oSection1   := TRSection():New(oRelatorio, cTitulo , {'SE5','SE1','SA1'},,,,,,.F.,.F.,.F.,,,,,,,,,CLR_LightSteelBlue)
	TRCell():New(oSection1,'SEGMENTO'        ,''    ,   ,'@!' ,,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)

	oSection2   := TRSection():New(oRelatorio, cTitulo , {'SE5','SE1','SA1'},,,,,,.F.,.F.,.F.,,,,,,,,,CLR_WHITE)
	TRCell():New(oSection2,'FILIAL'        	 ,''    ,   ,PesqPict("SE5","E5_FILIAL") ,TamSX3("E5_FILIAL")[1] ,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)
	TRCell():New(oSection2,'TITULO'        	 ,''    ,   ,PesqPict("SE5","E5_NUMERO") ,TamSX3("E5_NUMERO")[1] ,/*lPixel*/,  , "RIGHT",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)
	TRCell():New(oSection2,'PREFIXO'       	 ,''    ,   ,PesqPict("SE5","E5_PREFIXO"),TamSX3("E5_PREFIXO")[1],/*lPixel*/,  , "RIGHT",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)
	TRCell():New(oSection2,'PARCELA'       	 ,''    ,   ,PesqPict("SE5","E5_PARCELA"),TamSX3("E5_PARCELA")[1],/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)
	TRCell():New(oSection2,'TIPO'          	 ,''    ,   ,PesqPict("SE1","E1_TIPO")   ,TamSX3("E1_TIPO")[1]   ,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)
	TRCell():New(oSection2,'COD. CLIENTE'  	 ,''    ,   ,PesqPict("SE1","E1_CLIENTE"),TamSX3("E1_CLIENTE")[1],/*lPixel*/,  , "LEFT",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)
	TRCell():New(oSection2,'NOME'          	 ,''    ,   ,PesqPict("SE1","E1_NOMCLI") ,TamSX3("E1_NOMCLI")[1] ,/*lPixel*/,  , "LEFT",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)
	TRCell():New(oSection2,'EMISSAO'       	 ,''    ,   ,PesqPict("SE1","E1_EMISSAO"),TamSX3("E1_EMISSAO")[1]+5,/*lPixel*/,, "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)
	TRCell():New(oSection2,'VENC. REAL'    	 ,''    ,   ,PesqPict("SE1","E1_VENCREA"),TamSX3("E1_VENCREA")[1],/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)
	TRCell():New(oSection2,'VLR. ORIGINAL' 	 ,''    ,   ,PesqPict("SE1","E1_VALOR")  ,TamSX3("E1_VALOR")[1]  ,/*lPixel*/,  , "RIGHT",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)
	TRCell():New(oSection2,'VLR. CORRIGIDO'	 ,''    ,   ,PesqPict("SE1","E1_CORREC") ,TamSX3("E1_CORREC")[1] ,/*lPixel*/,  , "RIGHT",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)
	TRCell():New(oSection2,'ATRASO (DIAS)' 	 ,''    ,   ,"@!"						 ,10 					 ,/*lPixel*/,  , "RIGHT",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)

	oSection3   := TRSection():New(oRelatorio, cTitulo , {'SE5','SE1','SA1'},,,,,,.F.,.F.,.F.,,,,,,,,,CLR_SILVER)
	TRCell():New(oSection3,'TOTAL'           ,''    ,   ,'@!' 				  ,	 ,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)

	oSection4   := TRSection():New(oRelatorio, cTitulo , {'SE5','SE1','SA1'},,,,,,.F.,.F.,.F.,,,,,,,,,)
	TRCell():New(oSection4,'SEGMENTO'        ,''    ,   ,"@!" 				  ,40,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)
	TRCell():New(oSection4,'QTD. TITULOS'    ,''    ,   ,"@E 999,999,999"     ,40,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)
	TRCell():New(oSection4,'VLR. T.ORIGINAL' ,''    ,   ,"@E 999,999,999.99"  ,40,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)
	TRCell():New(oSection4,'VLR. T.CORRIGIDO',''    ,   ,"@E 999,999,999.99"  ,40,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)

	oSection5   := TRSection():New(oRelatorio, cTitulo , {'SE5','SE1','SA1'},,,,,,,,,,,,,,,,,CLR_SILVER)
	TRCell():New(oSection5,'SEGMENTO'        ,''    ,   , "@!" 				  ,40,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)
	TRCell():New(oSection5,'QTD. TITULOS'    ,''    ,   , "@E 999,999,999"    ,40,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)
	TRCell():New(oSection5,'VLR. T.ORIGINAL' ,''    ,   , "@E 999,999,999.99" ,40,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)
	TRCell():New(oSection5,'VLR. T.CORRIGIDO',''    ,   , "@E 999,999,999.99" ,40,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize , , ,_lBold)

	oRelatorio:printDialog()

Return

Static Function PrintReport(oRelatorio)
	Local oSection1  := oRelatorio:section(1)
	Local oSection2  := oRelatorio:section(2)
	Local oSection3  := oRelatorio:section(3)
	Local oSection4  := oRelatorio:section(4)
	Local oSection5  := oRelatorio:section(5)
	Local cQuery     := ""
	Local cSeg       := ""
	Local cSegmento	 := ""
	Local nValor	 := 0
	Local nValorTotal:= 0
	Local nTOTSeg	 := 0
	Local nQt		 := 0
	Local nQtotal	 := 0
	Local nTotCor	 := 0
	Local nValCorT	 := 0

	cQuery+=" SELECT E5_FILIAL AS FILIAL, E5_NUMERO AS TITULO, E5_PREFIXO AS PREFIXO, E5_PARCELA AS PARCELA, E1_TIPO AS TIPO, E1_CORREC AS CORRECAO, E1_CLIENTE AS CLIENTE, 
	cQuery+=" E1_NOMCLI AS NOME, E1_EMISSAO AS EMISSAO, E1_VENCREA AS VENCIMENTO, E1_VALOR AS VALOR, E1_BAIXA AS BAIXA, A1_XSEGM AS SEGMENTO, E5_VLJUROS, E5_VLMULTA, E5_VLDESCO "
	cQuery+=" FROM "+RetSqlName("SE5")+" SE5"
	cQuery+=" INNER JOIN "+RetSqlName("SE1")+" SE1 ON SE1.E1_PREFIXO = SE5.E5_PREFIXO AND SE1.E1_NUM = SE5.E5_NUMERO AND SE1.E1_PARCELA = SE5.E5_PARCELA"
	cQuery+=" AND SE1.E1_TIPO = SE5.E5_TIPO AND SE1.E1_CLIENTE = SE5.E5_CLIENTE AND SE1.E1_LOJA = SE5.E5_LOJA"
	cQuery+=" INNER JOIN "+RetSqlName('SA1')+" SA1 ON SA1.A1_FILIAL = SUBSTRING(SE5.E5_FILIAL,1,4) AND SA1.A1_COD = SE5.E5_CLIENTE AND SA1.A1_LOJA = SE5.E5_LOJA"
	cQuery+=" WHERE SE5.D_E_L_E_T_ <> '*'"
	cQuery+=" AND SE1.D_E_L_E_T_<> '*'"
	cQuery+=" AND SA1.D_E_L_E_T_<> '*'"
	cQuery+=" AND A1_XSEGM <> ' ' "
	cQuery+=" AND E5_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
	cQuery+=" AND E5_NUMERO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
	cQuery+=" AND E1_EMISSAO BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06)+"'"
	cQuery+=" AND E1_VENCREA BETWEEN '"+DtoS(MV_PAR07)+"' AND '"+DtoS(MV_PAR08)+"'"
	cQuery+=" GROUP BY E5_NUMERO,E5_FILIAL , E5_PREFIXO, E5_PARCELA, E1_TIPO, E1_CLIENTE, E1_NOMCLI, E1_EMISSAO, E1_VENCREA, E1_VALOR, E1_BAIXA, A1_XSEGM, E1_CORREC, E5_VLJUROS, E5_VLMULTA,E5_VLDESCO"
	cQuery+=" ORDER BY A1_XSEGM, E5_NUMERO"
	MpSysOpenQuery(cQuery,"RelTtRec")

	If RelTtRec->(Eof())
		MsgInfo("Nenhum dado foi localizado com os parâmetros informados.","Atenção!")
		Return .F.
	EndIf

	RelTtRec->(dbGoTop())
	oRelatorio:SetMeter(RelTtRec->(RecCount()))

	oSection1:SetHeaderPage(.F.)
	oSection2:SetHeaderSection(.T.)
	oSection3:SetHeaderPage(.F.)
	oSection3:SetHeaderSection(.F.)
	oSection4:SetHeaderSection(.F.)
	If MV_PAR09 <> "2"
		oSection5:SetHeaderPage(.T.)
		oSection5:SetHeaderSection(.T.)
	Else 
		oSection5:SetHeaderPage(.F.)
	EndIf

	While RelTtRec->(!Eof())

		If oRelatorio:Cancel()
			Exit
		EndIf

		cSegmento := X3Combo( "A1_XSEGM" , RelTtRec->SEGMENTO )
		
		nTOTSeg := 0
		nTotCor := 0
		nQt := 0
		cSeg := RelTtRec->SEGMENTO

		If MV_PAR09 <> "2"
			oRelatorio:IncMeter()
			oSection4:Init()
			oRelatorio:SkipLine() //-- Salta Linha
			While RelTtRec->(!Eof()) .And. RelTtRec->SEGMENTO == cSeg
				nTOTSeg += RelTtRec->VALOR
				nTotCor += ((RelTtRec->VALOR+RelTtRec->E5_VLJUROS+RelTtRec->E5_VLMULTA)-RelTtRec->E5_VLDESCO)
				nQt++
				RelTtRec->(DbSkip())
			End
			//oRelatorio:SkipLine(2) //-- Salta Linha
			oSection4:Cell('SEGMENTO'):SetValue(cSegmento)
			oSection4:Cell('QTD. TITULOS'):SetValue(nQt)
			oSection4:Cell('VLR. T.ORIGINAL'):SetValue(nTOTSeg)
			oSection4:Cell('VLR. T.CORRIGIDO'):SetValue(nTotCor)
			oSection4:Printline()
			oRelatorio:ThinLine() //-- Desenha uma linha simples
		Else

			oSection1:Init()
			oSection1:Cell('SEGMENTO'):SetValue(cSegmento)
			oSection1:Printline()
			oRelatorio:ThinLine() //-- Desenha uma linha simples
			oRelatorio:SkipLine() //-- Salta Linha

			While RelTtRec->(!Eof()) .And. RelTtRec->SEGMENTO == cSeg
				oSection2:Init()
				oSection2:Cell('FILIAL'):SetValue(RelTtRec->FILIAL)
				oSection2:Cell('TITULO'):SetValue(RelTtRec->TITULO)
				oSection2:Cell('PREFIXO'):SetValue(RelTtRec->PREFIXO)
				oSection2:Cell('PARCELA'):SetValue(RelTtRec->PARCELA)
				oSection2:Cell('TIPO'):SetValue(RelTtRec->TIPO)
				oSection2:Cell('COD. CLIENTE'):SetValue(RelTtRec->CLIENTE)
				oSection2:Cell('NOME'):SetValue(RelTtRec->NOME)
				oSection2:Cell('EMISSAO'):SetValue(StoD(RelTtRec->EMISSAO))
				oSection2:Cell('VENC. REAL'):SetValue(StoD(RelTtRec->VENCIMENTO))
				oSection2:Cell('VLR. ORIGINAL'):SetValue(RelTtRec->VALOR)
				oSection2:Cell('VLR. CORRIGIDO'):SetValue(((RelTtRec->VALOR+RelTtRec->E5_VLJUROS+RelTtRec->E5_VLMULTA)-RelTtRec->E5_VLDESCO))
				oSection2:Cell('ATRASO (DIAS)'):SetValue(DateDiffDay(StoD(RelTtRec->VENCIMENTO),StoD(RelTtRec->BAIXA)))
				oSection2:Printline()
				nValor += RelTtRec->VALOR
				nQt++
				nTotCor += ((RelTtRec->VALOR+RelTtRec->E5_VLJUROS+RelTtRec->E5_VLMULTA)-RelTtRec->E5_VLDESCO)
				RelTtRec->(DbSkip())
			End
			oRelatorio:SkipLine() //-- Salta Linha
			oRelatorio:ThinLine() //-- Desenha uma linha simples
			oRelatorio:SkipLine() //-- Salta Linha
			oSection3:Init()
			oSection3:Cell('TOTAL'):SetValue("VALOR TOTAL DO SEGMENTO:        R$ "+TRANSFORM(nValor,"@E 999,999,999.99"))
			oSection3:Printline()
			oRelatorio:ThinLine() //-- Desenha uma linha simples
			nValorTotal += nValor
			nValor := 0
			oRelatorio:SkipLine(2) //-- Salta Linha
			oRelatorio:ThinLine() //-- Desenha uma linha simples
		EndIf
		nQtotal += nQt
		nValorTotal += nTOTSeg
		nValCorT += nTotCor
	End

	//If MV_PAR09 == "2"
	//	oRelatorio:SkipLine(2) //-- Salta Linha
	//	oSection1:Init()
	//	oSection1:Cell('SEGMENTO'):SetValue("VALOR TOTAL DO RELATÓRIO:        R$ "+TRANSFORM(nValorTotal,"@E 999,999,999.99"))
	//	oSection1:Printline()
	//	oRelatorio:SkipLine(2) //-- Salta Linha
	//	oRelatorio:ThinLine() //-- Desenha uma linha simples
	//Else
		oRelatorio:SkipLine(1) //-- Salta Linha
		oSection5:Init()
		oSection5:Cell('SEGMENTO'):SetValue('TOTAIS : ')
		oSection5:Cell('QTD. TITULOS'):SetValue(nQtotal)
		oSection5:Cell('VLR. T.ORIGINAL'):SetValue(nValorTotal)
		oSection5:Cell('VLR. T.CORRIGIDO'):SetValue(nValCorT)
		oSection5:Printline()
		oRelatorio:ThinLine() //-- Desenha uma linha simples
	//EndIf

	oSection1:Finish()
	oSection2:Finish()
	oSection3:Finish()
	oSection4:Finish()
	oSection5:Finish()

	RelTtRec->(DbCloseArea())

Return

*******************************************************************************
// Função : CriaCab - Realiza a Montagem do Cabeçalho do Relatório		      |
// Modulo : Financeiro	                                                      |
// Fonte  : RelTtRec.prw                                                      |
// ---------+-------------------+---------------------------------------------+
// Data     | Autor             | Descricao                                   |
// ---------+-------------------+---------------------------------------------+
// 09/01/23 | Rivaldo Júnior    | Cabeçalho			                          |
*******************************************************************************

Static Function CriaCab( oRelatorio )
	Local aArea		:= GetArea()
	Local aCabec	:= {}
	Local cChar		:= chr(160) 
	local _cEmp 	:= FWCodEmp()

	_DataDe := DToC(MV_PAR05)
	_DataAte:= DToC(MV_PAR06)
	_VencDe := DToC(MV_PAR07)
	_VencAte:= DToC(MV_PAR08)

	aCabec := {	"__LOGOEMP__" , Padc(Upper("relatório de títulos recebidos por atividade de negócios - ") + FWFilialName(_cEmp),132);
	          , Padc("",132);          
	          , Padc(UPPER('EMISSÃO de '+_DataDe+' até '+_DataAte+'   |   VENCIMENTO '+_VencDe+' até '+_VencAte),132);
	          , RptHora + " " + time() ;
			  + cChar + "         " + RptEmiss + " " + Dtoc(dDataBase)}
			  
	RestArea( aArea )

Return aCabec     
