#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#include "TopConn.ch"
#include "COLORS.ch"
#INCLUDE "MATC030.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)

#define CLR_SILVER rgb(192,192,192)
#define CLR_LIGHTGRAY rgb(220,220,220)
#define CLR_DARKGRAY rgb(169,169,169)

User Function ESPPROD()

	PRIVATE cTitulo     := 'Relatório de Espelho de Produção'
	PRIVATE cDescri     := ""
	PRIVATE cFunName    := FunName()
	PRIVATE oRelatorio
	PRIVATE aPergs      := {}
	Private _lBold    := .T. //Controle de IMpressÃ£o em NEgrito
	Private lAutoSize := .T.

	aAdd(aPergs, {1, "Codigo de     "         ,space(TamSX3("B1_COD")[1]) , "",  ".T."  , "SB1", ".T."   , 40, .F.}) //mv_par05
	aAdd(aPergs, {1, "Codigo  até   "         ,space(TamSX3("B1_COD")[1]) , "",  ".T."  , "SB1", ".T."   , 40, .T.}) //2
	aAdd(aPergs, {1, "Grupo  de     "         ,space(TamSX3("B1_CC")[1]) , "",  ".T."  , "", ".T."   , 40, .F.}) //cLocal
	aAdd(aPergs, {1, "Grupo  até    "         ,space(TamSX3("B1_CC")[1]) , "",  ".T."  , "", ".T."   , 40, .T.}) //1
	aAdd(aPergs, {1, "Data De       "         ,Date()   , "", ".T.", "", ".T.", 80 , .F.}) //MV_PAR05
	aAdd(aPergs, {1, "Data Até      "         ,Date()   , "", ".T.", "", ".T.", 80 , .T.}) //MV_PAR06
	//aAdd(aPergs, {1, "Armazém     "           ,space(TamSX3("B2_LOCAL")[1]) , "",  ".T."  , "NNR", ".T."   , 40, .F.}) //1

	If !parambox(aPergs,"Informe os parametros")
		Return
	EndIf

	oRelatorio  := TReport():New(cFunName, cTitulo,, {|oRelatorio| PrintReport(oRelatorio)}, cDescri)
	oRelatorio:SetCustomText({||CriaCab(oRelatorio)})
	//oRelatorio:SetLogo("logo.bmp")

	oHeader   := TRSection():New(oRelatorio, cTitulo , {'SB1','SB2','SC2'},,,,,,.F.,.F.,.F.,,,,,,,,,CLR_LIGHTGRAY)
	TRCell():New(oHeader,  ''  ,''    , ""     ,PesqPict("SC2", "C2_DATRF")  ,TamSX3("C2_DATRF")[1]         ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)


	oHeader1   := TRSection():New(oRelatorio, cTitulo , {'SB1','SB2','SC2'},,,,,,.F.,.F.,.F.,,,,,,,,,CLR_LIGHTGRAY)
	TRCell():New(oHeader1,  'Codigo'             ,''    ,      ,PesqPict("SB1", "B1_COD")  ,TamSX3("B1_COD")[1]         ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oHeader1,  'Descrição'          ,''    ,      ,PesqPict("SB1", "B1_DESC") ,40                          ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oHeader1,  'UND'                ,''    ,      ,PesqPict("SB1", "B1_UM")   ,TamSX3("B1_UM")[1]          ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oHeader1,  'Qtd. Prevista'      ,''    ,      ,"@E 999,999,999,999.999"  ,TamSX3("C2_QUANT")[1]        ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oHeader1,  'Qtd. Realizada'     ,''    ,      ,"@E 999,999,999,999.999",TamSX3("C2_QUANT")[1]      ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oHeader1,  'Custo'              ,''    ,      ,"@E 999,999,999,999.9999"      ,TamSX3("B9_VINI1")[1]       ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oHeader1,  'Custo Total'        ,''    ,      ,"@E 999,999,999,999.99"      ,TamSX3("B2_CM1")[1]         ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)

	oRows1 := TRSection():New(oRelatorio, cTitulo , {'SB1','SB2','SC2'})
	TRCell():New(oRows1,'Codigo'             ,''    ,      ,PesqPict("SB1", "B1_COD")  ,TamSX3("B1_COD")[1]         ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oRows1,'Descrição'          ,''    ,      ,PesqPict("SB1", "B1_DESC") ,40                          ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oRows1,'UND'                ,''    ,      ,PesqPict("SB1", "B1_UM")   ,TamSX3("B1_UM")[1]          ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oRows1,'Qtd. Prevista'      ,''    ,      ,"@E 999,999,999,999.999"  ,TamSX3("C2_QUANT")[1]        ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oRows1,'Qtd. Realizada'     ,''    ,      ,"@E 999,999,999,999.999",TamSX3("C2_QUANT")[1]      ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oRows1,'Custo'              ,''    ,      ,"@E 999,999,999,999.9999"      ,TamSX3("B9_VINI1")[1]       ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oRows1,'Custo Total'        ,''    ,      ,"@E 999,999,999,999.99"      ,TamSX3("B2_CM1")[1]         ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)

	oSubTot := TRSection():New(oRelatorio, cTitulo , {'SB1','SB2','SC2'})
	TRCell():New(oSubTot,'Codigo'             ,''    ,      ,PesqPict("SB1", "B1_COD")  ,TamSX3("B1_COD")[1]         ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oSubTot,'Descrição'          ,''    ,      ,PesqPict("SB1", "B1_DESC") ,40                          ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oSubTot,'UND'                ,''    ,      ,PesqPict("SB1", "B1_UM")   ,TamSX3("B1_UM")[1]          ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oSubTot,'Qtd. Prevista'      ,''    ,      ,"@E 999,999,999,999.999"  ,TamSX3("C2_QUANT")[1]        ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oSubTot,'Qtd. Realizada'     ,''    ,      ,"@E 999,999,999,999.999",TamSX3("C2_QUANT")[1]      ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oSubTot,'Custo'              ,''    ,      ,"@E 999,999,999,999.9999"      ,TamSX3("B9_VINI1")[1]       ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oSubTot,'Custo Total'        ,''    ,      ,"@E 999,999,999,999.99"      ,TamSX3("B2_CM1")[1]         ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)

	oTotais1 := TRSection():New(oRelatorio, cTitulo , {'SB1','SB2','SC2'},,,,,,.F.,.F.,.F.,,,,,,,,,CLR_DARKGRAY)
	TRCell():New(oTotais1,'Codigo'             ,''    ,      ,PesqPict("SB1", "B1_COD")  ,TamSX3("B1_COD")[1]         ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oTotais1,'Descrição'          ,''    ,      ,PesqPict("SB1", "B1_DESC") ,40                          ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oTotais1,'UND'                ,''    ,      ,PesqPict("SB1", "B1_UM")   ,TamSX3("B1_UM")[1]          ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oTotais1,'Qtd. Prevista'      ,''    ,      ,"@E 999,999,999,999.999"  ,TamSX3("C2_QUANT")[1]        ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oTotais1,'Qtd. Realizada'     ,''    ,      ,"@E 999,999,999,999.999",TamSX3("C2_QUANT")[1]      ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oTotais1,'Custo'              ,''    ,      ,"@E 999,999,999,999.9999"      ,TamSX3("B9_VINI1")[1]       ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oTotais1,'Custo Total'        ,''    ,      ,"@E 999,999,999,999.99"      ,TamSX3("B2_CM1")[1]         ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)



	oRows2 := TRSection():New(oRelatorio, cTitulo , {'SB1','SB2','SC2'})
	TRCell():New(oRows2,'Produtos Usados'    ,''    ,      ,PesqPict("SB1", "B1_COD")  ,TamSX3("B1_COD")[1]         ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oRows2,'Descrição'          ,''    ,      ,PesqPict("SB1", "B1_DESC") ,40                          ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oRows2,'UND'                ,''    ,      ,PesqPict("SB1", "B1_UM")   ,TamSX3("B1_UM")[1]          ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oRows2,'QTD'                ,''    ,      ,"@E 999,999,999,999.999"   ,TamSX3("C2_QUANT")[1]          ,/*lPixel*/,, "RIGHT" ,          ,"RIGHT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oRows2,'Custo Produto'      ,''    ,      ,"@E 999,999,999,999.9999"      ,TamSX3("B2_CM1")[1]       ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oRows2,'Custo Total'        ,''    ,      ,"@E 999,999,999,999,999,999.99"      ,TamSX3("B2_CM1")[1]         ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)

	oTotais2 := TRSection():New(oRelatorio, cTitulo , {'SB1','SB2','SC2'},,,,,,.F.,.F.,.F.,,,,,,,,,CLR_DARKGRAY)
	TRCell():New(oTotais2,'Produtos Usados'    ,''    ,      ,PesqPict("SB1", "B1_COD")  ,TamSX3("B1_COD")[1]         ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oTotais2,'Descrição'          ,''    ,      ,PesqPict("SB1", "B1_DESC") ,40                          ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oTotais2,'UND'                ,''    ,      ,PesqPict("SB1", "B1_UM")   ,TamSX3("B1_UM")[1]          ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oTotais2,'QTD'                ,''    ,      ,"@E 999,999,999,999.999"   ,TamSX3("C2_QUANT")[1]          ,/*lPixel*/,, "RIGHT" ,          ,"RIGHT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oTotais2,'Custo Produto'      ,''    ,      ,"@E 999,999,999,999.9999"      ,TamSX3("B2_CM1")[1]       ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oTotais2,'Custo Total'        ,''    ,      ,"@E 999,999,999,999,999,999.99"      ,TamSX3("B2_CM1")[1]         ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)


	oHeader2 := TRSection():New(oRelatorio, cTitulo , {'SB1','SB2','SC2'},,,,,,.F.,.F.,.F.,,,,,,,,,CLR_LIGHTGRAY)
	TRCell():New(oHeader2,'Produtos Usados'    ,''    ,      ,PesqPict("SB1", "B1_COD")  ,TamSX3("B1_COD")[1]         ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oHeader2,'Descrição'          ,''    ,      ,PesqPict("SB1", "B1_DESC") ,40                          ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oHeader2,'UND'                ,''    ,      ,PesqPict("SB1", "B1_UM")   ,TamSX3("B1_UM")[1]          ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oHeader2,'QTD'                ,''    ,      ,"@E 999,999,999,999.999"   ,TamSX3("C2_QUANT")[1]          ,/*lPixel*/,, "RIGHT" ,          ,"RIGHT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oHeader2,'Custo Produto'      ,''    ,      ,"@E 999,999,999,999.9999"      ,TamSX3("B2_CM1")[1]       ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oHeader2,'Custo Total'        ,''    ,      ,"@E 999,999,999,999,999,999.99"      ,TamSX3("B2_CM1")[1]         ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)

	oRelatorio:printDialog()

Return

Static Function PrintReport(oRelatorio)
	Local oHeader   	:= oRelatorio:section(1)
	Local oHeader1   	:= oRelatorio:section(2)
	Local oRows1 		:= oRelatorio:section(3)
	Local oSubTot 		:= oRelatorio:section(4)
	Local oTotais1  	:= oRelatorio:section(5)
	Local oRows2 		:= oRelatorio:section(6)
	Local oTotais2  	:= oRelatorio:section(7)
	Local oHeader2  	:= oRelatorio:section(8)
	Local nItens 		:= 0
	Local nTItens		:= 0
	Local nQtdpre		:= 0
	Local nQtdrea		:= 0
	Local nCusto		:= 0
	Local nCustot		:= 0
	Local nTQTDPR		:= 0
	Local nTQTDRE		:= 0
	Local nTCUSTO		:= 0
	Local nTCUSTOT		:= 0
	Local nQTDPROD		:= 0
	Local nCUSPROD 		:= 0
	Local nCUSTPR		:= 0
	Local cGrupo    	:= ""
	PRIVATE aSalTel := {}

	cPAGE1 := " SELECT  B1_COD,  "
	cPAGE1 += "         B1_DESC,  "
	cPAGE1 += "         'TON' UN,  "
	cPAGE1 += "         B1_CC,  "
	cPAGE1 += " SUM(C2_QUANT) / NULLIF(1000, 0) AS QTDPRE, "
	cPAGE1 += " SUM(C2_QUJE) / NULLIF(1000, 0) AS QTDRE, "
	cPAGE1 += " CASE WHEN SUM(C2_QUJE) = 0 THEN 0 ELSE SUM(B2_CM1 * C2_QUJE) / (SUM(C2_QUJE) / NULLIF(1000, 0)) END AS CUSTO, "
	cPAGE1 += " CASE WHEN SUM(B2_CM1 * C2_QUJE) = 0 THEN 0 ELSE SUM(B2_CM1 * C2_QUJE) END AS CUSTOT "
	cPAGE1 += " FROM "+RetSqlName('SB1')+" B1 "
	cPAGE1 += " INNER JOIN "+RetSqlName('SC2')+" C2 "
	cPAGE1 += " ON B1.B1_FILIAL = C2.C2_FILIAL AND B1.B1_COD = C2.C2_PRODUTO "
	cPAGE1 += " INNER JOIN "+RetSqlName('SB2')+" B2 "
	cPAGE1 += " ON B1.B1_FILIAL = B2.B2_FILIAL AND B1.B1_COD = B2.B2_COD "
	cPAGE1 += " WHERE B1.D_E_L_E_T_ <> '*' "
	cPAGE1 += " AND C2.D_E_L_E_T_ <> '*' "
	cPAGE1 += " AND B2.D_E_L_E_T_ <> '*' "
	cPAGE1 += " AND B1.B1_MSBLQL = '2' "
	cPAGE1 += " AND C2.C2_EMISSAO BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06)+"' "
	cPAGE1 += " AND B1.B1_TIPO IN ('PA', 'PI') "
	cPAGE1 += " GROUP BY B1_COD, B1_DESC, B1_UM, B1_CC "
	cPAGE1 += " ORDER BY B1_CC "

	MEMOWRITE( "C:\temp\espprod_page1.txt", CPAGE1 )

	MpSysOpenQuery(cPAGE1, 'PAGE1')

	cPAGE2 := " SELECT B1_COD,  "
	cPAGE2 += "        B1_DESC, "
	cPAGE2 += "        B1_UM,   "
	cPAGE2 += "        B2_COD,   "
	cPAGE2 += "        B2_LOCAL,   "
	cPAGE2 += "        B1_LOCPAD,   "
	cPAGE2 += " ( SELECT SUM(D3_QUANT) AS QTDE FROM "+RetSqlName('SD3')+" D3 WHERE D3.D3_FILIAL = '"+xFilial("SD3")+"' AND D3.D3_COD = B1.B1_COD AND D3.D_E_L_E_T_ <> '*' AND D3.D3_EMISSAO BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06)+"' AND d3_cf Like '%RE%' AND D3_LOCAL = B1_LOCPAD ) AS D3_SAIDA, "
	cPAGE2 += " ( SELECT SUM(D2_QUANT) AS QTDE FROM "+RetSqlName('Sd2')+" D2 WHERE D2.D2_FILIAL = '"+xFilial("SD2")+"' AND D2.D2_COD = B1.B1_COD AND D2.D_E_L_E_T_ <> '*' AND D2.D2_EMISSAO BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06) +"') AS D2_SAIDA, "
	cPAGE2 += "        SUM(B2_CM1) CUSTO, "
	cPAGE2 += "        SUM(B2_CM1 * (SELECT SUM(D3_QUANT) AS QTDE FROM "+RetSqlName('SD3')+" D3 WHERE D3.D3_FILIAL = '"+xFilial("SD3")+"'AND D3_LOCAL = B1_LOCPAD AND D3.D3_COD = B1.B1_COD AND D3.D_E_L_E_T_ <> '*' AND D3.D3_EMISSAO BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06)+"') ) AS CUSTOT "
	cPAGE2 += " FROM "+RetSqlName('SB1')+" B1 "
	cPAGE2 += " INNER JOIN "+RetSqlName('SB2')+" B2 ON B2_FILIAL = B1_FILIAL AND B2.B2_COD = B1.B1_COD "
	cPAGE2 += " WHERE B1.D_E_L_E_T_ <> '*' AND B2.D_E_L_E_T_ <> '*' "
	cPAGE2 += " AND B1_COD IN (SELECT D3_COD FROM "+RetSqlName('SD3')+" D3 WHERE D3.D3_FILIAL = B1.B1_FILIAL AND D3.D3_COD = B1.B1_COD AND D3.D_E_L_E_T_ <> '*' AND D3.D3_EMISSAO BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06)+"') "
	cPAGE2 += " AND B2_LOCAL = B1_LOCPAD "
	cPAGE2 += " GROUP BY B1_COD, B1_DESC, B1_UM ,B2_COD, B2_LOCAL, B1_LOCPAD"

	MEMOWRITE( "C:\temp\ESPPROD_PAGE2.txt",  cPAGE2)

	MpSysOpenQuery(cPAGE2, 'PAGE2')

	While !PAGE1->(Eof())
		If oRelatorio:Cancel()
			Exit
		EndIf
		cGrupo := PAGE1->B1_CC
		oRelatorio:IncMeter()
		oRows2:SetPageBreak(.T.)
		oHeader:Init()
		oHeader1:Init()
		oHeader1:Cell('Codigo'):SetValue("GRUPO: "+PAGE1->B1_CC+Space(800))
		oHeader:Printline()
		oHeader1:Printline()
		While PAGE1->B1_CC == cGrupo
			oRows1:Init(.F.)
			oRelatorio:SetMsgPrint( "Calculando ... ")
			oRows1:Cell('Codigo'):SetValue(PAGE1->B1_COD)
			oRows1:Cell('Descrição'):SetValue(PAGE1->B1_DESC)
			oRows1:Cell('UND'):SetValue(PAGE1->UN)
			oRows1:Cell('Qtd. Prevista'):SetValue(PAGE1->QTDPRE)
			oRows1:Cell('Qtd. Realizada'):SetValue(PAGE1->QTDRE)
			oRows1:Cell('Custo'):SetValue(PAGE1->CUSTO) //
			oRows1:Cell('Custo Total'):SetValue(PAGE1->CUSTOT)
			oRows1:Printline()
			nItens++
			nTItens++
			nQtdpre  += PAGE1->QTDPRE
			nQtdrea  += PAGE1->QTDRE
			nCusto   += PAGE1->CUSTO
			nCustot  += PAGE1->CUSTOT
			nTQTDPR  += PAGE1->QTDPRE
			nTQTDRE  += PAGE1->QTDRE
			nTCUSTO  += PAGE1->CUSTO
			nTCUSTOT += PAGE1->CUSTOT
			PAGE1->(DbSkip())
		END
		oRows1:Finish()
		oHeader:Finish()
		oHeader1:Finish()
		oRelatorio:Thinline()
		oSubTot:Init(.F.)
		oSubTot:Cell('Codigo'):Hide()
		oSubTot:Cell('Descrição'):SetValue("TOTAIS DO GRUPO:")
		oSubTot:Cell('UND'):SetValue(CValToChar(nItens))
		oSubTot:Cell('Qtd. Prevista'):SetValue(nQtdpre)
		oSubTot:Cell('Qtd. Realizada'):SetValue(nQtdrea)
		//oSubTot:Cell('Custo'):SetValue(nCusto)
		oSubTot:Cell('Custo'):SetValue(nCustot/nQtdrea)
		oSubTot:Cell('Custo Total'):SetValue(nCustot)
		oSubTot:Printline()
		oSubTot:Finish()
		nQtdpre := 0
		nQtdrea := 0
		nCusto  := 0
		nCustot := 0
		nItens	:= 0
	END
	oTotais1:Init(.F.)
	oTotais1:Cell('Codigo'):Hide()
	oTotais1:Cell('Descrição'):SetValue("TOTAL GERAL FABRICADO:")
	oTotais1:Cell('UND'):SetValue(CValToChar(nTItens))
	oTotais1:Cell('Qtd. Prevista'):SetValue(nTQTDPR)
	oTotais1:Cell('Qtd. Prevista'):SetPicture("@E 999,999,999,999.999")
	oTotais1:Cell('Qtd. Realizada'):SetValue(nTQTDRE)
	oTotais1:Cell('Qtd. Realizada'):SetPicture("@E 999,999,999,999.999")
	//oTotais1:Cell('Custo'):SetValue(nTCUSTO)
	oTotais1:Cell('Custo'):SetValue(nTCUSTOT/nTQTDRE)
	oTotais1:Cell('Custo Total'):SetValue(nTCUSTOT)
	oTotais1:Printline()
	oTotais1:Finish()
	While PAGE2->(!EoF())
		If oRelatorio:Cancel()
			Exit
		EndIf
		oRows2:Init(.F.)
		oRows2:Cell('Produtos Usados'):SetValue(PAGE2->B1_COD)
		oRows2:Cell('Descrição'):SetValue(PAGE2->B1_DESC)
		oRows2:Cell('UND'):SetValue(PAGE2->B1_UM)
		oRows2:Cell('QTD'):SetValue(PAGE2->D3_SAIDA)
		DbSelectArea('SB2')
		DbSelectArea('SB1')
		SB2->(DbSetOrder(1))
		SB1->(DbSetOrder(1))
		SB2->(DbSeek(cFilAnt+PAGE2->B2_COD+PAGE2->B2_LOCAL))
		SB1->(DbSeek(xFilial('SB1')+PAGE2->B2_COD))
		aSalTel := CalcEst(SB2->B2_COD,SB2->B2_LOCAL,MV_PAR06+1)
		
		//PRIVATE aGraph  := {}
		//PRIVATE aTrbP   := {}
		//PRIVATE aTrbTmp := {}
		//PRIVATE aTela   := {}
		//PRIVATE aSalAtu := { 0,0,0,0,0,0,0 }
		//PRIVATE cPictTotQT:=PesqPictQt("B2_QATU")
		//PRIVATE nTotSda := nTotEnt :=  nTotvSda := nTotvEnt  := 0
		//PRIVATE cTRBSD1 := CriaTrab(,.F.)
		//PRIVATE cTRBSD2 := Subs(cTRBSD1,1,7)+"A"
		//PRIVATE cTRBSD3 := Subs(cTRBSD1,1,7)+"B"
		//PRIVATE cPictQT := PesqPict("SB2","B2_QATU",18)
		//PRIVATE aSalTel := {}
		//PRIVATE aGraph  := {}
		//PRIVATE aTrbP   := {}
		//PRIVATE aTrbTmp := {}
		//PRIVATE aTela   := {}
		//PRIVATE aSalAtu := { 0,0,0,0,0,0,0 }
		//PRIVATE cPictTotQT:=PesqPictQt("B2_QATU")
		//PRIVATE nTotSda := nTotEnt :=  nTotvSda := nTotvEnt  := 0
		//PRIVATE cTRBSD1 := CriaTrab(,.F.)
		//PRIVATE cTRBSD2 := Subs(cTRBSD1,1,7)+"A"
		//PRIVATE cTRBSD3 := Subs(cTRBSD1,1,7)+"B"
		//PRIVATE cPictQT := PesqPict("SB2","B2_QATU",18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava as movimentacoes no arquivo de trabalho                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		

		//oRows2:Cell('Custo Produto'):SetValue(PAGE2->CUSTO)
		oRows2:Cell('Custo Produto'):SetValue(aSalTel[2]/aSaltel[1])
		oRows2:Cell('Custo Total'):SetValue(PAGE2->D3_SAIDA*(round(aSalTel[2]/aSaltel[1],4)))
		oRows2:Printline()
		nItens++
		nQTDPROD += PAGE2->D3_SAIDA
		nCUSPROD += round(aSalTel[2]/aSaltel[1],4)
		nCUSTPR  += PAGE2->D3_SAIDA*(round(aSalTel[2]/aSaltel[1],4))
		PAGE2->(DbSkip())
	Enddo
	oHeader2:Finish()
	oRows2:Finish()
	oTotais2:Init(.F.)
	oTotais2:Cell('Produtos Usados'):Hide()
	oTotais2:Cell('Descrição'):SetValue("TOTAL GERAL UTILIZADO:")
	oTotais2:Cell('UND'):SetValue(CValToChar(nItens))
	oTotais2:Cell('QTD'):SetValue(nQTDPROD)
	oTotais2:Cell('Custo Produto'):SetValue(nCUSPROD)
	//oTotais2:Cell('Custo Produto'):SetValue(nCUSTPR)
	oTotais2:Cell('Custo Total'):SetValue(nCUSTPR)
	oTotais2:Printline()
	oTotais2:Finish()
Return

Static Function CriaCab( oRelatorio )
	Local aArea		:= GetArea()
	Local aCabec	:= {}
	Local cChar		:= chr(160)
	local _cEmp 	:= FWCodEmp()

	_DataDe := DToC(MV_PAR05)
	_DataAte:= DToC(MV_PAR06)

	aCabec := {	"__LOGOEMP__" + "         " + cChar + "         " + RptFolha+TRANSFORM(oRelatorio:Page(),'999999');
		, Padc(Upper("Espelho de Produção - " + FWFilialName(_cEmp)),132);
		, Padc("",132);
		, Padc(UPPER('Período de '+_DataDe+' até '+_DataAte),132);
		, RptHora + " " + time() ;
		+ cChar + "         " + RptEmiss + " " + Dtoc(dDataBase)}

	RestArea( aArea )

Return aCabec
