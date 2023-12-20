#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"

*******************************************************************************
// Função : RELFATM - rel. recorrência de vendas mês a mês           		  |
// Modulo : FATURAMENTO                                                       |
// Fonte  : RELFATM.prw                                                       |
// ---------+--------------------------+--------------------------------------+
// Data     | Autor             	   | Descricao                            |
// ---------+--------------------------+--------------------------------------+
// 09/02/23 | Lucas	Antônio - Cod.ERP  | Relatório			                  |
*******************************************************************************

#define CLR_LIGHTGRAY rgb(220,220,220)
#define CLR_LightSteelBlue rgb(176,196,222)

User Function RelDvP()
	PRIVATE cTitulo     := 'Relatorio registros de desvio padrão'
	PRIVATE cDescri     := ""
	PRIVATE cFunName    := FunName()
	PRIVATE oRelatorio
	PRIVATE aPergs      := {}
	Private _lBold      := .F. //Controle de IMpressÃ£o em NEgrito
	Private lAutoSize   := .T.
	Private lLandscape   := .T.

	aAdd(aPergs, {1, "Da Filial"       ,space(TamSX3("A2_filial")[1]),PesqPict("SA2","A2_filial"),,"SM0",,TamSX3("A2_filial")[1], .F.}) //MV_PAR01
	aAdd(aPergs, {1, "Ate a Filial"    ,space(TamSX3("A2_filial")[1]),PesqPict("SA2","A2_filial"),,"SM0",,TamSX3("A2_filial")[1], .T.}) //MV_PAR02
	aAdd(aPergs, {1, "Do Fornecedor"   ,space(TamSX3("A2_COD")[1]),PesqPict("SA2","A2_COD"),,"SA2",,TamSX3("A2_COD")[1], .F.}) //MV_PAR03
	aAdd(aPergs, {1, "Ate o Fornecedor",space(TamSX3("A2_COD")[1]),PesqPict("SA2","A2_COD"),,"SA2",,TamSX3("A2_COD")[1], .T.}) //MV_PAR04
	aAdd(aPergs, {1, "Do Cliente"      ,space(TamSX3("A1_COD")[1]),PesqPict("SA1","A1_COD"),,"SA1",,TamSX3("A1_COD")[1], .F.}) //MV_PAR03
	aAdd(aPergs, {1, "Ate o Cliente"   ,space(TamSX3("A1_COD")[1]),PesqPict("SA1","A1_COD"),,"SA1",,TamSX3("A1_COD")[1], .T.}) //MV_PAR04
	aAdd(aPergs, {1, "Data De"         ,Date()   , "", ".T.", "", ".T.", 80 , .F.}) //MV_PAR05
	aAdd(aPergs, {1, "Data Até "       ,Date()   , "", ".T.", "", ".T.", 80 , .T.}) //MV_PAR06
	//aAdd(aPergs, {2,"Tipo de Relatório: ", "2" , {"1=Não Efetivados","2=Efetivados", "3=Todos"} , 60 ,".T.",.T.})										   //MV_PAR09

	If !parambox(aPergs,"Informe os parametros")
		Return
	EndIf

	oRelatorio  := TReport():New(cFunName, cTitulo,, {|oRelatorio| PrintReport(oRelatorio)}, cDescri, lLandscape)
	oRelatorio:SetCustomText({||CriaCab(oRelatorio)})

	oSection1   := TRSection():New(oRelatorio, cTitulo , {'SF2','SD2','SA2','SA1','SC5'},,,,,,.F.,.F.,.F.,,,,,,,,,CLR_LightSteelBlue)
	TRCell():New(oSection1,'FILIAL'      ,'',,PesqPict("SD2","D2_FILIAL"),TamSX3("D2_FILIAL")[1]+3,/*lPixel*/, ,"LEFT", ,"LEFT", ,,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'N.F. ENTRADA','',,PesqPict("SD2","D2_DOC")	 ,TamSX3("D2_DOC")[1]+3,/*lPixel*/, ,"CENTER", ,"CENTER", ,,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'SERIE ENT'       ,'',,PesqPict("SD2","D2_SERIE") ,TamSX3("D2_SERIE")[1]+5,/*lPixel*/, ,"CENTER", ,"CENTER", ,,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'FORNECEDOR'  ,'',,PesqPict("SA2","A2_COD")   ,TamSX3("A1_COD")[1]+5	  ,/*lPixel*/, ,"LEFT", ,"LEFT", ,,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'LOJA FORN'          ,'',,PesqPict("SA2","A2_LOJA")  ,TamSX3("A1_LOJA")[1]+3  ,/*lPixel*/, ,"LEFT", ,"LEFT", ,,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'NOME FORN'	     ,'',,PesqPict("SA2","A2_NOME")  ,TamSX3("A1_NOME")[1]-15 ,/*lPixel*/, ,"LEFT", ,"LEFT", ,,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'N.F. SAIDA'  ,'',,PesqPict("SD2","D2_DOC")   ,TamSX3("D2_DOC")[1]+3 ,/*lPixel*/, ,"CENTER", ,"CENTER", ,,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'SERIE SAI'       ,'',,PesqPict("SD2","D2_SERIE") ,TamSX3("D2_SERIE")[1]+5,/*lPixel*/, ,"CENTER", ,"CENTER", ,,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'CLIENTE'     ,'',,PesqPict("SA1","A1_COD")   ,TamSX3("A1_COD")[1]+5	  ,/*lPixel*/, ,"LEFT", ,"LEFT", ,,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'LOJA CLI'          ,'',,PesqPict("SA1","A1_LOJA")  ,TamSX3("A1_LOJA")[1]+3  ,/*lPixel*/, ,"LEFT", ,"LEFT", ,,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'NOME CLI'	     ,'',,PesqPict("SA1","A1_NOME")  ,TamSX3("A1_NOME")[1]-15 ,/*lPixel*/, ,"LEFT", ,"LEFT", ,,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'PEDIDO'	     ,'',,PesqPict("SC5","C5_NUM")   ,TamSX3("C5_NUM")[1]+3 ,/*lPixel*/, ,"CENTER", ,"CENTER", ,,lAutoSize ,,  ,_lBold )

	oSection2   := TRSection():New(oRelatorio, cTitulo , {'SF2','SD2','SA2','SA1','SB1'},,,,,,.F.,.F.,.F.,,,,,,,,,)
	TRCell():New(oSection2,'ITEM'    	,'',,PesqPict("SD2","D2_ITEM")	,TamSX3("D2_ITEM")[1]+3	  ,/*lPixel*/, ,"LEFT", ,"LEFT", ,,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection2,'PRODUTO'    ,'',,PesqPict("SB1","B1_COD")	,TamSX3("B1_COD")[1]+3	  ,/*lPixel*/, ,"LEFT", ,"LEFT", ,,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection2,'DESCRIÇÃO'  ,'',,PesqPict("SB1","B1_DESC")	,TamSX3("B1_DESC")[1]-10	  ,/*lPixel*/, ,"LEFT", ,"LEFT", ,,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection2,'UND.'  		,'',,PesqPict("SB1","B1_UM")	,TamSX3("B1_UM")[1]+3	  ,/*lPixel*/, ,"CENTER", ,"CENTER", ,,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection2,'ARMAZÉM'	,'',,PesqPict("SB1","B1_LOCPAD"),TamSX3("B1_LOCPAD")[1]+3,/*lPixel*/, ,"CENTER", ,"CENTER", ,,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection2,'QUANTIDADE' ,'',,"@E 999999999.99" ,TamSX3("D2_QUANT")[1]+3  ,/*lPixel*/, ,"RIGHT", ,"RIGHT", ,,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection2,'VALOR UNIT.','',,"@E 99,999,999,999.99",TamSX3("D2_PRCVEN")[1]+5 ,/*lPixel*/, ,"RIGHT", ,"RIGHT", ,,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection2,'VALOR TOTAL','',,"@E 99,999,999,999.99" ,TamSX3("D2_LOJA")[1]+3   ,/*lPixel*/, ,"RIGHT", ,"RIGHT", ,,lAutoSize ,,  ,_lBold )

	oRelatorio:printDialog()

Return

Static Function PrintReport(oRelatorio)
	Local oSection1  := oRelatorio:section(1)
	Local oSection2  := oRelatorio:section(2)
	Local cQuery     := GetNextAlias()
	
	BeginSql Alias cQuery
		SELECT ZR2_FILIAL FILIAL, ZR2_DOC DOC, ZR2_SERIE SERIE, ZR2_FORN FORN, ZR2_FLOJA FLOJA, ZR2_NPRO NPRO,
			   ZR2_DOCS DOCS, ZR2_SSERIE SERIES, ZR2_CLI CLI, ZR2_CLOJA CLOJA, ZR2_PDV PDV, 
			   ZR3_PROD PROD, ZR3_UM UM, ZR3_LOCAL LOC, ZR3_QUANT QUANT, ZR3_PRCVEN VLRU, ZR3_VLRT VLRT, ZR3_ITEM ITEM
		FROM %Table:ZR2% ZR2
		INNER JOIN %Table:ZR3% ZR3 ON ZR3_FILIAL = ZR2_FILIAL AND ZR3_NPRO = ZR2_NPRO
		WHERE ZR2_FILIAL BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02%
			AND ZR2_FORN BETWEEN %EXP:MV_PAR03% AND %EXP:MV_PAR04%
			AND ZR2_CLI BETWEEN %EXP:MV_PAR05% AND %EXP:MV_PAR06%
			AND ZR2_DATA BETWEEN %EXP:DTOS(MV_PAR07)% AND %EXP:DTOS(MV_PAR08)%
			//AND ZR2_STATUS = %EXP:MV_PAR09%
			AND ZR2.%NOTDEL%
			AND ZR3.%NOTDEL%
	EndSql

	If (cQuery)->(Eof())
		DbSelectArea(cQuery)
		(cQuery)->(DbCloseArea())
		FwAlertWarning("Nenhum dado foi localizado com os parâmetros informados.","Atenção!")
		Return .F.
	EndIf

	(cQuery)->(dbGoTop())
	oRelatorio:SetMeter((cQuery)->(RecCount()))

	//oSection1:SetHeaderSection(.T.)
	//oSection2:SetHeaderSection(.T.)
	While (cQuery)->(!Eof())

		If oRelatorio:Cancel()
			Exit
		EndIf
        cProcesso := (cQuery)->NPRO
		oSection1:Init()
		oRelatorio:IncMeter()
		//oRelatorio:SkipLine(2) //-- Salta Linha
        //oRelatorio:ThinLine() //-- Desenha uma linha simples

		oSection1:Cell('FILIAL'      ):SetValue((cQuery)->FILIAL)
		oSection1:Cell('N.F. ENTRADA'):SetValue((cQuery)->DOC)
		oSection1:Cell('SERIE ENT'   ):SetValue((cQuery)->SERIE)
		oSection1:Cell('FORNECEDOR'  ):SetValue((cQuery)->FORN)
		oSection1:Cell('LOJA FORN'   ):SetValue((cQuery)->FLOJA)
		oSection1:Cell('NOME FORN'	 ):SetValue(AllTrim(Posicione("SA2",1,xFilial("SA2")+(cQuery)->(FORN+FLOJA),"A2_NREDUZ")))
		oSection1:Cell('N.F. SAIDA'  ):SetValue((cQuery)->DOCS)
		oSection1:Cell('SERIE SAI'   ):SetValue((cQuery)->SERIES)
		oSection1:Cell('CLIENTE'     ):SetValue((cQuery)->CLI)
		oSection1:Cell('LOJA CLI'    ):SetValue((cQuery)->CLOJA)
		oSection1:Cell('NOME CLI'	 ):SetValue(AllTrim(Posicione("SA1",1,xFilial("SA1")+(cQuery)->(CLI+CLOJA),"A1_NREDUZ")))
		oSection1:Cell('PEDIDO'	     ):SetValue((cQuery)->PDV)
		oSection1:PrintLine()
		oSection1:Finish()
		//oRelatorio:ThinLine() //-- Desenha uma linha simples
		oRelatorio:SkipLine() //-- Salta Linha
		oRelatorio:PrtCenter("Itens da nota fiscal de entrada")
		oRelatorio:SkipLine() //-- Salta Linha
		oRelatorio:ThinLine() //-- Desenha uma linha simples
		oRelatorio:SkipLine() //-- Salta Linha

		oSection2:Init()	
		While (cQuery)->(!Eof()) .And. (cQuery)->NPRO == cProcesso
			oRelatorio:IncMeter()
			oSection2:Cell('ITEM'    ):SetValue((cQuery)->ITEM)
			oSection2:Cell('PRODUTO'    ):SetValue((cQuery)->PROD)
			oSection2:Cell('DESCRIÇÃO'  ):SetValue(AllTrim(Posicione("SB1",1,xFilial("SB1")+(cQuery)->PROD,"B1_DESC")))
			oSection2:Cell('UND.'		):SetValue((cQuery)->UM)
			oSection2:Cell('ARMAZEM'	):SetValue((cQuery)->LOC)
			oSection2:Cell('QUANTIDADE' ):SetValue((cQuery)->QUANT)
			oSection2:Cell('VALOR UNIT.'):SetValue((cQuery)->VLRU)
			oSection2:Cell('VALOR TOTAL'):SetValue((cQuery)->VLRT)
			oSection2:Printline()
			(cQuery)->(DbSkip())
		End
		oSection2:Finish()
		oRelatorio:SkipLine(3)
		oRelatorio:SkipLine(3)
		oRelatorio:ThinLine() //-- Desenha uma linha simples
	End
   
	oSection1:Finish()
	oSection2:Finish()
	(cQuery)->(DbCloseArea())

Return

*******************************************************************************
// Função : CriaCab - Realiza a Montagem do Cabeçalho do Relatório		      |
// Modulo : FATURAMENTO                                                       |
// Fonte  : RelInvent.prw                                                     |
// ---------+--------------------------+--------------------------------------+
// Data     | Autor                    | Descricao                            |
// ---------+--------------------------+--------------------------------------+
// 09/02/23 | Lucas	Antônio - Cod.ERP  | Cabeçalho			                  |
*******************************************************************************

Static Function CriaCab( oRelatorio )
	Local aArea		:= GetArea()
	Local aCabec	:= {}
	Local cChar		:= chr(175) 
	local _cEmp 	:= FWCodEmp()

	_DataDe := DToC(MV_PAR07)
	_DataAte:= DToC(MV_PAR08)

	aCabec := {	"__LOGOEMP__" + "         " + cChar + "         " + RptFolha+TRANSFORM(oRelatorio:Page(),'999999');
			  , Padc(UPPER("Relatório registros de desvio padrão - ") + FWFilialName(_cEmp),145);
	          , Padc("",145);          
	          , Padc(UPPER('Período de '+_DataDe+' até '+_DataAte),145);
	          , RptHora + " " + time() ;
			  + cChar + "         " + RptEmiss + " " + Dtoc(dDataBase)}
			  
	RestArea( aArea )

Return aCabec
