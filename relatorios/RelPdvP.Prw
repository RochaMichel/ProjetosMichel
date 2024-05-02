#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#include "TopConn.ch"
#include "COLORS.ch"

#define CLR_SILVER rgb(192,192,192)
#define CLR_GAINSBORO rgb(220,220,220)
#define CLR_LightSteelBlue rgb(176,196,222)

*******************************************************************************
// Função : RelPDVp - rel. vendas por tipo de cliente  						  |
// Modulo : Financeiro                                                        |
// Fonte  : RelPDVp.prw                                                       |
// ---------+-------------------+---------------------------------------------+
// Data     | Autor             | Descricao                                   |
// ---------+-------------------+---------------------------------------------+
// 09/01/23 | Rivaldo Júnior    | Relatório			                          |
*******************************************************************************

User Function RelPDVp()
	PRIVATE cTitulo     := 'Relatório resumo das vendas - por PDV x Produtos'
	PRIVATE cDescri     := ""
	PRIVATE cFunName    := FunName()
	PRIVATE oRelatorio
	PRIVATE aPergs      := {}
	Private _lBold      := .T. //Controle de IMpressÃ£o em NEgrito
	Private lAutoSize   := .T.

	aAdd(aPergs, {1, "Do Cliente:   "         ,space(TamSX3("A1_COD")[1]) , "",  ".T."  , "SA1", ".T."   , 40, .F.}) //MV_Par01
	aAdd(aPergs, {1, "Até Cliente:  "         ,space(TamSX3("A1_COD")[1]) , "",  ".T."  , "SA1", ".T."   , 40, .T.}) //MV_Par02
	aAdd(aPergs, {1, "Periodo De    "         ,Date(), "", ".T.", "", ".T.", 80 , .F.})                              //MV_PAR03
	aAdd(aPergs, {1, "Periodo Até   "         ,Date(), "", ".T.", "", ".T.", 80 , .F.})                              //MV_PAR04
	aAdd(aPergs, {1, "Do Vendedor:  "         ,space(TamSX3("A3_COD")[1]) , "",  ".T."  , "SA3", ".T."   , 40, .F.}) //MV_Par05
	aAdd(aPergs, {1, "Até Vendedor: "         ,space(TamSX3("A3_COD")[1]) , "",  ".T."  , "SA3", ".T."   , 40, .T.}) //MV_Par06

	If !parambox(aPergs,"Informe os parametros")
		Return
	EndIf

	oRelatorio  := TReport():New(cFunName, cTitulo,, {|oRelatorio| PrintReport(oRelatorio)}, cDescri)
	oRelatorio:SetCustomText({||CriaCab(oRelatorio)})

	oSection1   := TRSection():New(oRelatorio, cTitulo , {'SC9','SB1'},,,,,,.F.,.F.,.F.,,,,,,,,,CLR_SILVER)
	TRCell():New(oSection1,'PRODUTO'           ,''    ,      ,PesqPict("SC9","C9_PRODUTO"),	 40	 ,/*lPixel*/,  , "LEFT"  ,  ,"LEFT" ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection1,'DESCRIÇÃO'         ,''    ,      ,PesqPict("SB1","B1_DESC")   ,	 40	 ,/*lPixel*/,  , "LEFT"  ,  ,"LEFT" ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection1,'UND.'              ,''    ,      ,PesqPict("SB1","B1_UM")     ,	 20	 ,/*lPixel*/,  , "LEFT"  ,  ,"LEFT" ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection1,'QUANTIDADE VENDIDA',''    ,      ,"@!"                     	  ,	 40	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGTH",  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection1,'VALOR VENDIDO'     ,''    ,      ,"@!"                        ,	 40	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGTH",  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection1,'PREÇO MÉDIO'       ,''    ,      ,"@!"                        ,	 40	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGTH",  ,  ,lAutoSize ,  ,  ,_lBold)

	oSection2   := TRSection():New(oRelatorio, cTitulo , {'SC9','SB1'},,,,,,.F.,.F.)
	TRCell():New(oSection2,'PRODUTO'           ,''    ,      ,PesqPict("SC9","C9_PRODUTO"),	 40	 ,/*lPixel*/,  , "LEFT"  ,  ,"LEFT" ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection2,'DESCRIÇÃO'         ,''    ,      ,PesqPict("SB1","B1_DESC")   ,	 40	 ,/*lPixel*/,  , "LEFT"  ,  ,"LEFT" ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection2,'UND.'              ,''    ,      ,PesqPict("SB1","B1_UM")     ,	 20	 ,/*lPixel*/,  , "LEFT"  ,  ,"LEFT" ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection2,'QUANTIDADE VENDIDA',''    ,      ,"@E 999,999,999" 	          ,	 40	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT",  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection2,'VALOR VENDIDO'     ,''    ,      ,"@E 9,999,999,999.99"  	  ,	 40	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT",  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection2,'PREÇO MÉDIO'       ,''    ,      ,"@E 9,999,999,999.99"       ,	 40	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT",  ,  ,lAutoSize ,  ,  ,_lBold)

	oSection3   := TRSection():New(oRelatorio, cTitulo , {'SC9','SB1'},,,,,,.F.,.F.,.F.,,,,,,,,,CLR_LightSteelBlue)
	TRCell():New(oSection3,'RESUMO DOS PRODUTOS'           ,''    ,      ,PesqPict("SB1","B1_DESC"),	 40	 ,/*lPixel*/,  , "CENTER"  ,  ,"CENTER"  ,  ,  ,lAutoSize ,  ,  ,_lBold)

	oSection4   := TRSection():New(oRelatorio, cTitulo , {'SC9','SB1'},,,,,,.F.,.F.)
	TRCell():New(oSection4,'PRODUTO'           ,''    ,      ,PesqPict("SC9","C9_PRODUTO"),	 40	 ,/*lPixel*/,  , "LEFT"  ,  ,"LEFT" ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection4,'DESCRIÇÃO'         ,''    ,      ,PesqPict("SB1","B1_DESC")   ,	 40	 ,/*lPixel*/,  , "LEFT"  ,  ,"LEFT" ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection4,'QUANTIDADE VENDIDA',''    ,      ,"@E 999,999,999" 	          ,	 40	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT",  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection4,'VALOR VENDIDO'     ,''    ,      ,"@E 9,999,999,999.99"  	  ,	 40	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT",  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection4,'PREÇO MÉDIO'       ,''    ,      ,"@E 9,999,999,999.99"       ,	 40	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT",  ,  ,lAutoSize ,  ,  ,_lBold)

	oSection5   := TRSection():New(oRelatorio, cTitulo , {'SC9','SB1'},,,,,,.F.,.F.,.F.,,,,,,,,,CLR_SILVER)
	TRCell():New(oSection5,'PRODUTO'           ,''    ,      ,PesqPict("SC9","C9_PRODUTO"),	 40	 ,/*lPixel*/,  , "LEFT"  ,  ,"LEFT" ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection5,'DESCRIÇÃO'         ,''    ,      ,PesqPict("SB1","B1_DESC")   ,	 40	 ,/*lPixel*/,  , "LEFT"  ,  ,"LEFT" ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection5,'QUANTIDADE VENDIDA',''    ,      ,"@E 999,999,999" 	          ,	 40	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT",  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection5,'VALOR VENDIDO'     ,''    ,      ,"@E 9,999,999,999.99"  	  ,	 40	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT",  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection5,'PREÇO MÉDIO'       ,''    ,      ,"@E 9,999,999,999.99"       ,	 40	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT",  ,  ,lAutoSize ,  ,  ,_lBold)

	oRelatorio:printDialog()

Return

Static Function PrintReport(oRelatorio)
	Local oSection1   := oRelatorio:section(1)
	Local oSection2   := oRelatorio:section(2)
	Local oSection3   := oRelatorio:section(3)
	Local cQuery      := ""
	Local cQuery2     := ""
	Local cPedido     := ""
	Local nQtd:=nPrc  := 0
	Local nQtd2:=nPrc2:= 0
	Local nPrcTotal   := 0
	Local nQtdTotal   := 0

	cQuery:= " SELECT C9_PEDIDO, C9_PRODUTO, B1_UM, C9_QTDLIB, C9_PRCVEN, B1_DESC, A1_NOME, A1_COD"
	cQuery+= " FROM "+RetSqlName("SC9")+" SC9  "
	cQuery+= " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_COD = SC9.C9_PRODUTO AND SB1.B1_FILIAL = SC9.C9_FILIAL  "
	cQuery+= " INNER JOIN "+RetSqlName("SC5")+" SC5 ON SC5.C5_NUM = SC9.C9_PEDIDO AND SC5.C5_FILIAL = SC9.C9_FILIAL  "
	cQuery+= " INNER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_COD = SC9.C9_CLIENTE AND SA1.A1_LOJA = SC9.C9_LOJA  AND SA1.A1_FILIAL = SUBSTRING(SC9.C9_FILIAL,1,4) "
	cQuery+= " WHERE SC9.D_E_L_E_T_ <> '*'  "
	cQuery+= " AND SB1.D_E_L_E_T_ <> '*'  "
	cQuery+= " AND SC5.D_E_L_E_T_ <> '*'  "
	cQuery+= " AND SA1.D_E_L_E_T_ <> '*'  "
	cQuery+= " AND C9_CLIENTE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  "
	cQuery+= " AND C5_EMISSAO BETWEEN '"+dToS(MV_PAR03)+"' AND '"+dToS(MV_PAR04)+"'  "
	cQuery+= " AND C5_VEND1 BETWEEN   '"+MV_PAR05+"' AND '"+MV_PAR06+"'  "
	cQuery+= " ORDER BY C9_PEDIDO, C9_PRODUTO "
	MpSysOpenQuery(cQuery,"RelPDVp")

	cQuery2:= " SELECT C9_PEDIDO, C9_PRODUTO, B1_UM, C9_QTDLIB, C9_PRCVEN, B1_DESC, A1_COD, A1_NOME"
	cQuery2+= " FROM "+RetSqlName("SC9")+" SC9  "
	cQuery2+= " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_COD = SC9.C9_PRODUTO AND SB1.B1_FILIAL = SC9.C9_FILIAL  "
	cQuery2+= " INNER JOIN "+RetSqlName("SC5")+" SC5 ON SC5.C5_NUM = SC9.C9_PEDIDO AND SC5.C5_FILIAL = SC9.C9_FILIAL  "
	cQuery2+= " INNER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_COD = SC9.C9_CLIENTE AND SA1.A1_LOJA = SC9.C9_LOJA  AND SA1.A1_FILIAL = SUBSTRING(SC9.C9_FILIAL,1,4) "
	cQuery2+= " WHERE SC9.D_E_L_E_T_ <> '*'  "
	cQuery2+= " AND SB1.D_E_L_E_T_ <> '*'  "
	cQuery2+= " AND SC5.D_E_L_E_T_ <> '*'  "
	cQuery2+= " AND SA1.D_E_L_E_T_ <> '*'  "
	cQuery2+= " AND C9_CLIENTE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  "
	cQuery2+= " AND C5_EMISSAO BETWEEN '"+dToS(MV_PAR03)+"' AND '"+dToS(MV_PAR04)+"'  "
	cQuery2+= " AND C5_VEND1 BETWEEN   '"+MV_PAR05+"' AND '"+MV_PAR06+"'  "
	cQuery2+= " ORDER BY C9_PRODUTO "
	MpSysOpenQuery(cQuery2,"RelPDVp2")

	If RelPDVp->(Eof())
		MsgInfo("Nenhum dado foi localizado com os parâmetros informados.","Atenção!")
		Return .F.
	EndIf

	oSection1:SetHeaderPage(.T.)
	oSection2:SetHeaderPage(.F.)
	oSection2:SetHeaderSection(.F.)

	While RelPDVp->(!Eof())

		oSection1:Cell('QUANTIDADE VENDIDA'):SetHeaderAlign("RIGHT")
		oSection1:Cell('VALOR VENDIDO'):SetHeaderAlign("RIGHT")
		oSection1:Cell('PREÇO MÉDIO'):SetHeaderAlign("RIGHT")
		If oRelatorio:Cancel()
			Exit
		EndIf
		cPedido := RelPDVp->C9_PEDIDO
		oRelatorio:IncMeter()
		oSection1:Init()
		oRelatorio:SkipLine(2) //-- Salta Linha
		oRelatorio:ThinLine() //-- Desenha uma linha simples
		oSection1:Cell('PRODUTO'):SetValue('PEDIDO : '+cPedido)
		oSection1:Cell('DESCRIÇÃO'):SetValue(RelPDVp->A1_COD+' - '+RelPDVp->A1_NOME)
		oSection1:Cell('UND.'):SetValue('')
		oSection1:Cell('QUANTIDADE VENDIDA'):SetValue('')
		oSection1:Cell('VALOR VENDIDO'):SetValue('')
		oSection1:Cell('PREÇO MÉDIO'):SetValue('')
		oSection1:PrintLine()
		oRelatorio:ThinLine() //-- Desenha uma linha simples
		oRelatorio:SkipLine() //-- Salta Linha

		While RelPDVp->(!Eof()) .And. RelPDVp->C9_PEDIDO == cPEDIDO
			oSection2:Init()
			oSection2:Cell('PRODUTO'):SetValue(RelPDVp->C9_PRODUTO)
			oSection2:Cell('DESCRIÇÃO'):SetValue(RelPDVp->B1_DESC)
			oSection2:Cell('UND.'):SetValue(RelPDVp->B1_UM)
			oSection2:Cell('QUANTIDADE VENDIDA'):SetValue(RelPDVp->C9_QTDLIB)
			oSection2:Cell('VALOR VENDIDO'):SetValue(RelPDVp->C9_QTDLIB*RelPDVp->C9_PRCVEN)
			oSection2:Cell('PREÇO MÉDIO'):SetValue((RelPDVp->C9_QTDLIB*RelPDVp->C9_PRCVEN)/RelPDVp->C9_QTDLIB)
			oSection2:Printline()
			nQtd += RelPDVp->C9_QTDLIB
			nPrc += (RelPDVp->C9_QTDLIB*RelPDVp->C9_PRCVEN)
			RelPDVp->(DbSkip())
		End
		oRelatorio:SkipLine() //-- Salta Linha
		oRelatorio:ThinLine() //-- Desenha uma linha simples
		oSection2:Cell('PRODUTO'):SetValue('')
		oSection2:Cell('DESCRIÇÃO'):SetValue('TOTAIS DESTE PEDIDO :')
		oSection2:Cell('UND.'):SetValue('')
		oSection2:Cell('QUANTIDADE VENDIDA'):SetValue(nQtd)
		oSection2:Cell('VALOR VENDIDO'):SetValue(nPrc)
		oSection2:Cell('PREÇO MÉDIO'):SetValue()
		oSection2:Printline()
		nQtdTotal += nQtd
		nPrcTotal += nPrc
		nQtd := 0
		nPrc := 0
	End
	oRelatorio:SkipLine(2)
	oSection1:Cell('QUANTIDADE VENDIDA'):SetPicture("@E 999,999,999")
	oSection1:Cell('VALOR VENDIDO'):SetPicture("@E 9,999,999,999.99")

	oSection1:Cell('PRODUTO'):SetValue('')
	oSection1:Cell('DESCRIÇÃO'):SetValue("TOTAIS GERAIS : ")
	oSection1:Cell('UND.'):SetValue('')
	oSection1:Cell('QUANTIDADE VENDIDA'):SetValue(nQtdTotal)
	oSection1:Cell('VALOR VENDIDO'):SetValue(nPrcTotal)
	oSection1:Cell('PREÇO MÉDIO'):SetValue()
	oSection1:Printline()

	oRelatorio:SkipLine(2) //-- Salta Linha
	oRelatorio:ThinLine() //-- Desenha uma linha simples
	oRelatorio:SkipLine(2) //-- Salta Linha

	oRelatorio:EndPage()    // Finaliza a pagina
	oSection1:SetHeaderPage(.F.)
	oSection1:SetHeaderSection(.F.)
	oSection3:SetHeaderPage(.F.)
	oSection3:SetHeaderSection(.F.)
	oSection4:SetHeaderPage(.F.)
	oSection4:SetHeaderSection(.T.)
	oSection5:SetHeaderPage(.F.)
	oSection5:SetHeaderSection(.F.)
	oRelatorio:StartPage()  // Inicia uma nova pagina

	oSection3:Init()
	IF MV_PAR01 == MV_PAR02
		oSection3:Cell('RESUMO DOS PRODUTOS'):SetValue('CLIENTE : '+RelPDVp2->A1_COD+' - '+RelPDVp2->A1_NOME+'RESUMO DOS PRODUTOS')
	Else
		oSection3:Cell('RESUMO DOS PRODUTOS'):SetValue('RESUMO DOS PRODUTOS')
	EndIf
	oSection3:PrintLine()

	oRelatorio:SkipLine() //-- Salta Linha
	oRelatorio:ThinLine() //-- Desenha uma linha simples

	While RelPDVp2->(!Eof())

		If oRelatorio:Cancel()
			Exit
		EndIf
		cProduto := RelPDVp2->C9_PRODUTO

		While RelPDVp2->(!Eof()) .And. RelPDVp2->C9_PRODUTO == cProduto
			nQtd2 += RelPDVp2->C9_QTDLIB
			nPrc2 += (RelPDVp2->C9_QTDLIB*RelPDVp2->C9_PRCVEN)
			cDesc := RelPDVp2->B1_DESC
			RelPDVp2->(DbSkip())
		End
		oSection4:Init()
		oSection4:Cell('PRODUTO'):SetValue(cProduto)
		oSection4:Cell('DESCRIÇÃO'):SetValue(cDesc)
		oSection4:Cell('QUANTIDADE VENDIDA'):SetValue(nQtd2)
		oSection4:Cell('VALOR VENDIDO'):SetValue(nPrc2)
		oSection4:Cell('PREÇO MÉDIO'):SetValue(nPrc2/nQtd2)
		oSection4:Printline()
		nQtd2 := 0
		nPrc2 := 0
	End
	oRelatorio:SkipLine()
	oRelatorio:ThinLine() //-- Desenha uma linha simples
	oSection5:Init()
	oSection5:Cell('PRODUTO'):SetValue('')
	oSection5:Cell('DESCRIÇÃO'):SetValue('TOTAIS : ')
	oSection5:Cell('QUANTIDADE VENDIDA'):SetValue(nQtdTotal)
	oSection5:Cell('VALOR VENDIDO'):SetValue(nPrcTotal)
	oSection5:Cell('PREÇO MÉDIO'):SetValue()
	oSection5:Printline()
	oRelatorio:ThinLine() //-- Desenha uma linha simples

	oSection1:Finish()
	oSection2:Finish()
	oSection3:Finish()
	oSection4:Finish()
	oSection5:Finish()
	RelPDVp->(DbCloseArea())

Return

	*******************************************************************************
// Função : CriaCab - Realiza a Montagem do Cabeçalho do Relatório		      |
// Modulo : Estoque e Custo                                                   |
// Fonte  : RelInvent.prw                                                     |
// ---------+-------------------+---------------------------------------------+
// Data     | Autor             | Descricao                                   |
// ---------+-------------------+---------------------------------------------+
// 25/11/22 | Rivaldo Júnior    | Cabeçalho			                          |
	*******************************************************************************

Static Function CriaCab( oRelatorio )
	Local aArea		:= GetArea()
	Local aCabec	:= {}
	Local cChar		:= chr(160)
	local _cEmp 	:= FWCodEmp()

	_DataDe := DToC(MV_PAR03)
	_DataAte:= DToC(MV_PAR04)

	aCabec := {	"__LOGOEMP__" + "         " + cChar + "         " + RptFolha+TRANSFORM(oRelatorio:Page(),'999999');
		, Padc(Upper("Relatório resumo das vendas - por PDV x Produtos - " + AllTrim(FWFilialName(_cEmp))),132);
		, Padc("",132);
		, Padc(UPPER('Período de '+_DataDe+' até '+_DataAte),132);
		, RptHora + " " + time() + cChar + "         " + RptEmiss + " " + Dtoc(dDataBase)}

	RestArea( aArea )

Return aCabec
