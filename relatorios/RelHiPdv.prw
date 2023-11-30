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
// Função : RelHiPdv - Rel. Histórico de vendas por clientes			      |
// Modulo : Faturamento                                                   	  |
// Fonte  : RelHiPDV.prw                                                      |
// ---------+-------------------+---------------------------------------------+
// Data     | Autor             | Descricao                                   |
// ---------+-------------------+---------------------------------------------+
// 10/01/23 | Rivaldo Júnior    | Cabeçalho			                          |
*******************************************************************************

User Function RelHiPdv()
	PRIVATE cTitulo     := 'Relatório histórico de PDVs x Clientes'
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

	oSection1   := TRSection():New(oRelatorio, cTitulo , {'SC9','SB1'},,,,,,.F.,.F.,.F.,,,,,,,,,CLR_LightSteelBlue)
	TRCell():New(oSection1,'PRODUTO'           ,''    ,      ,PesqPict("SC9","C9_PRODUTO"),	 60	 ,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection1,'QUANTIDADE'        ,''    ,      ,"@!"                     	  ,	 40	 ,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection1,'VALOR_TOTAL'       ,''    ,      ,"@!"                        ,	 40	 ,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection1,'PREÇO_MEDIO'       ,''    ,      ,"@!"                        ,	 40	 ,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize ,  ,  ,_lBold)

	oSection2   := TRSection():New(oRelatorio, cTitulo , {'SC9','SB1'},,,,,,.F.,.F.,.F.,,,,,,,,,CLR_GAINSBORO)
	TRCell():New(oSection2,'PRODUTO'           ,''    ,      ,PesqPict("SC9","C9_PRODUTO"),	 60	 ,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection2,'QUANTIDADE'        ,''    ,      ,"@!"                     	  ,	 40	 ,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection2,'VALOR_TOTAL'       ,''    ,      ,"@!"                        ,	 40	 ,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection2,'PREÇO_MEDIO'       ,''    ,      ,"@!"                        ,	 40	 ,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize ,  ,  ,_lBold)

	oSection3   := TRSection():New(oRelatorio, cTitulo , {'SC9','SB1'},,,,,,.F.,.F.)
	TRCell():New(oSection3,'PRODUTO'           ,''    ,      ,PesqPict("SC9","C9_PRODUTO"),	 60	 ,/*lPixel*/,  , "LEFT"  ,  ,"CENTER"  ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection3,'QUANTIDADE'        ,''    ,      ,"@E 999,999,999" 	          ,	 40	 ,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection3,'VALOR_TOTAL'       ,''    ,      ,"@E 9,999,999,999.99"  	  ,	 40	 ,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection3,'PREÇO_MEDIO'       ,''    ,      ,"@E 9,999,999,999.99"       ,	 40	 ,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize ,  ,  ,_lBold)

	oSection4   := TRSection():New(oRelatorio, cTitulo , {'SC9','SB1'},,,,,,.F.,.F.,.F.,,,,,,,,,CLR_SILVER)
	TRCell():New(oSection4,'PRODUTO'           ,''    ,      ,PesqPict("SC9","C9_PRODUTO"),	 60	 ,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection4,'QUANTIDADE'        ,''    ,      ,"@!"                     	  ,	 40	 ,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection4,'VALOR_TOTAL'       ,''    ,      ,"@!"                        ,	 40	 ,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection4,'PREÇO_MEDIO'       ,''    ,      ,"@!"                        ,	 40	 ,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  ,lAutoSize ,  ,  ,_lBold)

	oRelatorio:printDialog()

Return

Static Function PrintReport(oRelatorio)
	Local oSection1     	 := oRelatorio:section(1)
	Local oSection2     	 := oRelatorio:section(2)
	Local oSection3     	 := oRelatorio:section(3)
	Local oSection4     	 := oRelatorio:section(4)
	Local cQuery        	 := ""
	Local cQuery2       	 := ""
	Local cPedido       	 := ""
	Local cVend				 := ""
    Local nQtd:=nPrc    	 := 0
    Local nQtd2:=nPrc2  	 := 0
    Local nPrcTCli:=nPrcTotal:= 0
    Local nQtdTCli:=nQtdTotal:= 0 

	cQuery:= " SELECT C9_PEDIDO, C9_CLIENTE, C9_PRODUTO, B1_UM, C9_QTDLIB, C9_PRCVEN, B1_DESC, A1_NOME, C5_VEND1, C5_FILIAL, C5_EMISSAO"
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
	cQuery+= " GROUP BY C9_CLIENTE, C9_PEDIDO, C9_PRODUTO, B1_UM, C9_QTDLIB, C9_PRCVEN, B1_DESC, A1_NOME, C5_VEND1, C5_FILIAL, C5_EMISSAO  "
	cQuery+= " ORDER BY C9_PEDIDO, C9_PRODUTO "
	MpSysOpenQuery(cQuery,"RelHiPdv")

	cQuery2:= " SELECT C9_PEDIDO, C9_PRODUTO, B1_UM, C9_QTDLIB, C9_PRCVEN, B1_DESC, A1_NREDUZ"
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
	MpSysOpenQuery(cQuery2,"RelHiPdv2")

    If RelHiPdv->(Eof())
		MsgInfo("Nenhum dado foi localizado com os parâmetros informados.","Atenção!")
		Return .F.
	EndIf

	oSection1:SetHeaderPage(.F.)
	oSection1:SetHeaderSection(.F.)
	oSection2:SetHeaderPage(.F.)
	oSection2:SetHeaderSection(.F.)
	oSection3:SetHeaderPage(.F.)
	oSection3:SetHeaderSection(.F.)
	oSection4:SetHeaderPage(.T.)

	DbSelectArea("SA3")
	SA3->(DbSetOrder(1))

	While RelHiPdv->(!Eof())

		If oRelatorio:Cancel()
			Exit
		EndIf
        cCliente := RelHiPdv->C9_CLIENTE
		oRelatorio:IncMeter()
		oSection1:Init()
		oRelatorio:SkipLine(3) //-- Salta Linha
        oRelatorio:ThinLine() //-- Desenha uma linha simples
        oSection1:Cell('PRODUTO'):SetValue('CLIENTE : '+cCliente+' - '+RelHiPdv->A1_NOME)
		oSection1:Cell('QUANTIDADE'):SetValue()
		oSection1:Cell('VALOR_TOTAL'):SetValue()
		oSection1:Cell('PREÇO_MEDIO'):SetValue()
		oSection1:PrintLine()
		oRelatorio:ThinLine() //-- Desenha uma linha simples
		oRelatorio:SkipLine() //-- Salta Linha
		While RelHiPdv->(!Eof()) .And. RelHiPdv->C9_CLIENTE == cCliente

			cPedido := RelHiPdv->C9_PEDIDO
			oSection2:Init()
			oRelatorio:SkipLine(1) //-- Salta Linha
        	oRelatorio:ThinLine() //-- Desenha uma linha simples
			If SA3->(DbSeek(Substr(RelHiPdv->(C5_FILIAL),1,4)+'  '+RelHiPdv->(C5_VEND1)))
				cVend := AllTrim(SA3->A3_NOME)
				oSection2:Cell('PRODUTO'):SetValue('PEDIDO : '+cPedido+" - "+cValToChar(sTod(RelHiPdv->C5_EMISSAO))+' | VENDEDOR: '+RelHiPdv->C5_VEND1+' - '+cVend)
			Else
				oSection2:Cell('PRODUTO'):SetValue('PEDIDO : '+cPedido+" - "+cValToChar(sTod(RelHiPdv->C5_EMISSAO)))
			EndIf
			oSection2:Cell('QUANTIDADE'):SetValue()
			oSection2:Cell('VALOR_TOTAL'):SetValue()
			oSection2:Cell('PREÇO_MEDIO'):SetValue()
			oSection2:PrintLine()
			oRelatorio:ThinLine() //-- Desenha uma linha simples
			oRelatorio:SkipLine() //-- Salta Linha

			While RelHiPdv->(!Eof()) .And. RelHiPdv->C9_PEDIDO == cPEDIDO
				oSection3:Init()
				oSection3:Cell('PRODUTO'):SetValue(AllTrim(RelHiPdv->C9_PRODUTO)+' - '+RelHiPdv->B1_DESC)
				oSection3:Cell('QUANTIDADE'):SetValue(RelHiPdv->C9_QTDLIB)
				oSection3:Cell('VALOR_TOTAL'):SetValue(RelHiPdv->C9_QTDLIB*RelHiPdv->C9_PRCVEN)
				oSection3:Cell('PREÇO_MEDIO'):SetValue((RelHiPdv->C9_QTDLIB*RelHiPdv->C9_PRCVEN)/RelHiPdv->C9_QTDLIB)
				oSection3:Printline()
        	    nQtd += RelHiPdv->C9_QTDLIB
        	    nPrc += (RelHiPdv->C9_QTDLIB*RelHiPdv->C9_PRCVEN)
				RelHiPdv->(DbSkip())
			End
			oRelatorio:SkipLine() //-- Salta Linha
			oRelatorio:ThinLine() //-- Desenha uma linha simples
			oSection3:Cell('PRODUTO'):SetAlign("CENTER")
        	oSection3:Cell('PRODUTO'):SetValue(Padl('TOTAIS DESTE PDV :',60))
        	oSection3:Cell('QUANTIDADE'):SetValue(nQtd)
        	oSection3:Cell('VALOR_TOTAL'):SetValue(nPrc)
        	oSection3:Cell('PREÇO_MEDIO'):SetValue()
        	oSection3:Printline()
			oSection3:Cell('PRODUTO'):SetAlign("LEFT")

			oRelatorio:ThinLine() //-- Desenha uma linha simples
			oRelatorio:SkipLine(2)
        	nQtdTCli += nQtd
        	nPrcTCli += nPrc
        	nQtd := 0
        	nPrc := 0
		End
		oSection4:Init()
    	oSection4:Cell('QUANTIDADE'):SetPicture("@E 999,999,999")
    	oSection4:Cell('VALOR_TOTAL'):SetPicture("@E 9,999,999,999.99")

    	oSection4:Cell('PRODUTO'):SetValue('TOTAIS DESTE CLIENTE :')
    	oSection4:Cell('QUANTIDADE'):SetValue(nQtdTCli)
    	oSection4:Cell('VALOR_TOTAL'):SetValue(nPrcTCli)
    	oSection4:Cell('PREÇO_MEDIO'):SetValue()
    	oSection4:Printline()
		oRelatorio:SkipLine()
		nQtdTotal += nQtdTCli
		nPrcTotal += nPrcTCli
		nQtdTCli := 0
		nPrcTCli := 0
		oRelatorio:FatLine()
		oRelatorio:FatLine()
	End
	oRelatorio:SkipLine(2)
	oSection2:Cell('QUANTIDADE'):SetPicture("@E 999,999,999")
	oSection2:Cell('VALOR_TOTAL'):SetPicture("@E 9,999,999,999.99")
	oSection2:Cell('PRODUTO'):SetValue('TOTAIS DESTE RELATÓRIO :')
	oSection2:Cell('QUANTIDADE'):SetValue(nQtdTotal)
	oSection2:Cell('VALOR_TOTAL'):SetValue(nPrcTotal)
	oSection2:Cell('PREÇO_MEDIO'):SetValue()
	oSection2:Printline()
	oRelatorio:SkipLine()
	oRelatorio:ThinLine() //-- Desenha uma linha simples
	oRelatorio:SkipLine()

    oRelatorio:SkipLine(2) //-- Salta Linha
    oRelatorio:ThinLine() //-- Desenha uma linha simples
    oSection1:Cell('PRODUTO'):SetValue('RESUMO DOS PRODUTOS')
    oSection1:Cell('QUANTIDADE'):SetValue()
    oSection1:Cell('VALOR_TOTAL'):SetValue()
    oSection1:Cell('PREÇO_MEDIO'):SetValue()
    oSection1:PrintLine()
    oRelatorio:ThinLine() //-- Desenha uma linha simples
    oRelatorio:SkipLine(2) //-- Salta Linha

    While RelHiPdv2->(!Eof())
        If oRelatorio:Cancel()
            Exit
        EndIf
        cProduto := RelHiPdv2->C9_PRODUTO

        While RelHiPdv2->(!Eof()) .And. RelHiPdv2->C9_PRODUTO == cProduto
            nQtd2 += RelHiPdv2->C9_QTDLIB
            nPrc2 += (RelHiPdv2->C9_QTDLIB*RelHiPdv2->C9_PRCVEN)
            cDesc := RelHiPdv2->B1_DESC
            RelHiPdv2->(DbSkip())
        End
        oSection3:Cell('PRODUTO'):SetValue(Padc(cProduto+' - '+cDesc,60))
        oSection3:Cell('QUANTIDADE'):SetValue(nQtd2)
        oSection3:Cell('VALOR_TOTAL'):SetValue(nPrc2)
        oSection3:Cell('PREÇO_MEDIO'):SetValue(nPrc2/nQtd2)
        oSection3:Printline()
        nQtd2 := 0
        nPrc2 := 0
    End
	oRelatorio:FatLine()
	oRelatorio:FatLine()
    oRelatorio:SkipLine()
    oSection1:Cell('QUANTIDADE'):SetPicture("@E 999,999,999")
    oSection1:Cell('VALOR_TOTAL'):SetPicture("@E 9,999,999,999.99")
    oSection1:Cell('PRODUTO'):SetValue(Padc('TOTAIS DOS PRODUTOS : ',60))
    oSection1:Cell('QUANTIDADE'):SetValue(nQtdTotal)
    oSection1:Cell('VALOR_TOTAL'):SetValue(nPrcTotal)
    oSection1:Cell('PREÇO_MEDIO'):SetValue()
    oSection1:Printline()
    oRelatorio:SkipLine()
	oRelatorio:FatLine()
	oRelatorio:FatLine()

	oSection1:Finish()
	oSection2:Finish()
	oSection3:Finish()
	oSection4:Finish()
	RelHiPdv->(DbCloseArea())
	RelHiPdv2->(DbCloseArea())

Return

*******************************************************************************
// Função : CriaCab - Realiza a Montagem do Cabeçalho do Relatório		      |
// Modulo : Faturamento                                                   	  |
// Fonte  : RelHiPDV.prw                                                      |
// ---------+-------------------+---------------------------------------------+
// Data     | Autor             | Descricao                                   |
// ---------+-------------------+---------------------------------------------+
// 10/01/23 | Rivaldo Júnior    | Cabeçalho			                          |
*******************************************************************************

Static Function CriaCab( oRelatorio )
	Local aArea		:= GetArea()
	Local aCabec	:= {}
	Local cChar		:= chr(160) 
	local _cEmp 	:= FWCodEmp()

	_DataDe := DToC(MV_PAR03)
	_DataAte:= DToC(MV_PAR04)

	aCabec := {	"__LOGOEMP__" , Padc(Upper("HISTÓRICO DOS PDVs - MODELO 1 - " + AllTrim(FWFilialName(_cEmp))),132);
	          , Padc("",132);          
	          , Padc(UPPER('Período de '+_DataDe+' até '+_DataAte),132);
	          , RptHora + " " + time() ;
			  + cChar + "         " + RptEmiss + " " + Dtoc(dDataBase)}
			  
	RestArea( aArea )

Return aCabec     
