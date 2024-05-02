#Include 'TOTVS.CH'

*******************************************************************************
// Função : RelNVinc - Realiza a Montagem do Relatório	Treport			      |
// Modulo : Estoque e Custo                                                   |
// Fonte  : RelNVinc.prw                                                      |
// ---------+-----------------------+-----------------------------------------+ 
// Data     | Autor            	    | Descricao                               |
// ---------+-----------------------+-----------------------------------------+
// 26/03/24 | Rivaldo Jr. (Cod.ERP) | Relatório			                      |
*******************************************************************************

User Function RelNVinc()
   // PRIVATE _DataDe		:= ""
	//PRIVATE _DataAte	:= ""
	PRIVATE cTitulo     := "titulo"
	PRIVATE cDescri     := "descricao"
	PRIVATE cFunName    := FunName()
	PRIVATE oRelatorio
	PRIVATE aPergs      := {}
	PRIVATE _lBold    	:= .F. //Controle de IMpressÃ£o em NEgrito
	PRIVATE lAutoSize 	:= .T.
	PRIVATE lLineBreak 	:= .F.

	aAdd(aPergs, {1, "Da Filial:"       	 ,space(TamSX3("D1_FILIAL")[1]) , "",  ".T."  , "SM0", ".T."   , 40, .F.}) //MV_PAR01
	aAdd(aPergs, {1, "Até a filial:"    	 ,space(TamSX3("D1_FILIAL")[1]) , "",  ".T."  , "SM0", ".T."   , 40, .T.}) //MV_PAR02
	aAdd(aPergs, {1, "Da data:"         	 ,Date()  , "", ".T.", "", ".T.", 80 , .F.}) 							   //MV_PAR03
	aAdd(aPergs, {1, "Até a data:"      	 ,Date()  , "", ".T.", "", ".T.", 80 , .T.}) 							   //MV_PAR04
	//aAdd(aPergs, {2, "Qual informação:"      , "1" , {"1=Todos","2=Doc. Entrada","3=Doc. Saida","4=Titulos a receber","5=Titulos a pagar"}  	, 60 ,".T.",.T.}) 						   //MV_PAR10

	If !parambox(aPergs,"Informe os parametros")
		Return
	EndIf

	//oRelatorio  := TReport():New(cFunName, ,, {|oRelatorio| PrintReport(oRelatorio)}, cDescri,/* <lLandscape> */ ,/* <uTotalText> */ , /* <lTotalInLine> */,/* <cPageTText> */ , /* <lPageTInLine> */, /* <lTPageBreak> */,)
	oRelatorio  := TReport():New(cFunName, ,, {|oRelatorio| PrintReport(oRelatorio)}, cDescri,,,,,,,)
	oRelatorio:SetPortrait()
	oRelatorio:SetCustomText({||CriaCab(oRelatorio)})
	oRelatorio:SetLineHeight(42)
	oRelatorio:SetRightAlignPrinter(.T.)

    // TITULOS A PAGAR E RECEBER
	oSection1   := TRSection():New(oRelatorio,  , {'SE1','SE2','SF1','SF2'})
	TRCell():New(oSection1,'FILIAL'             ,'', ,PesqPict("SE1", "E1_FILIAL")  , ,/*lPixel*/, ,"LEFT"  ,lLineBreak,"LEFT"  ,,   0 ,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'PREFIXO'        	,'', ,PesqPict("SE1", "E1_PREFIXO") , ,/*lPixel*/, ,"LEFT"  ,lLineBreak,"LEFT"  ,,   0 ,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'TITULO'             ,'', ,PesqPict("SE1", "E1_NUM")   	, ,/*lPixel*/, ,"LEFT"  ,lLineBreak,"LEFT"  ,,   0 ,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'EMISSAO'            ,'', ,PesqPict("SE1", "E1_EMISSAO") , ,/*lPixel*/, ,"CENTER",lLineBreak,"CENTER",,   0 ,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'TIPO'    			,'', ,PesqPict("SE1", "E1_TIPO") 	, ,/*lPixel*/, ,"LEFT"  ,lLineBreak,"LEFT"  ,,   0 ,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'PARCELA'    		,'', ,PesqPict("SE1", "E1_PARCELA") , ,/*lPixel*/, ,"LEFT"  ,lLineBreak,"LEFT"  ,,   0 ,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'FORN/CLI'    		,'', ,PesqPict("SE1", "E1_CLIENTE") , ,/*lPixel*/, ,"LEFT"  ,lLineBreak,"LEFT"  ,,   0 ,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'LOJA'               ,'', ,PesqPict("SE1", "E1_LOJA")    , ,/*lPixel*/, ,"LEFT"  ,lLineBreak,"LEFT"  ,,   0 ,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'VALOR TOTAL'        ,'', ,"@E 9,999,999.99"      	    , ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,   0 ,lAutoSize, , ,_lBold)
	oSection1:SetHeaderSection(.T.)

	// DOCUMENTO DE ENTRADA E SAIDA 
	oSection2   := TRSection():New(oRelatorio,  , {'SE1','SE2','SF1','SF2'})
	TRCell():New(oSection2,'FILIAL'             ,'', ,PesqPict("SF1", "F1_FILIAL")  , ,/*lPixel*/, ,"LEFT"  ,lLineBreak,"LEFT"  ,,   0 ,lAutoSize, , ,_lBold)
	TRCell():New(oSection2,'NOTA FISCAL'        ,'', ,PesqPict("SF1", "F1_DOC")     , ,/*lPixel*/, ,"LEFT"  ,lLineBreak,"LEFT"  ,,   0 ,lAutoSize, , ,_lBold)
	TRCell():New(oSection2,'SERIE'              ,'', ,PesqPict("SF1", "F1_SERIE")   , ,/*lPixel*/, ,"LEFT"  ,lLineBreak,"LEFT"  ,,   0 ,lAutoSize, , ,_lBold)
	TRCell():New(oSection2,'EMISSAO'            ,'', ,PesqPict("SF1", "F1_EMISSAO") , ,/*lPixel*/, ,"CENTER",lLineBreak,"CENTER",,   0 ,lAutoSize, , ,_lBold)
	TRCell():New(oSection2,'FORN/CLI'    		,'', ,PesqPict("SF1", "F1_FORNECE") , ,/*lPixel*/, ,"LEFT"  ,lLineBreak,"LEFT"  ,,   0 ,lAutoSize, , ,_lBold)
	TRCell():New(oSection2,'LOJA'               ,'', ,PesqPict("SF1", "F1_LOJA")    , ,/*lPixel*/, ,"LEFT"  ,lLineBreak,"LEFT"  ,,   0 ,lAutoSize, , ,_lBold)
	TRCell():New(oSection2,'VALOR TOTAL'        ,'', ,"@E 9,999,999.99"      	    , ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,   0 ,lAutoSize, , ,_lBold)
	oSection2:SetHeaderSection(.T.)

	oRelatorio:printDialog()

Return


*******************************************************************************
// Função : PrintReport - Realiza a Busca dos dados e Definição 		      |
// Modulo : Estoque e Custo                                                   |
// ---------+-------------------+---------------------------------------------+
// Data     | Autor             | Descricao                                   |
// ---------+-------------------+---------------------------------------------+
// 26/03/24 | Rivaldo Júnior    | Busca dos dados	                          |
*******************************************************************************

Static Function PrintReport(oRelatorio)
	Local oSection1    := oRelatorio:section(1)
	Local oSection2    := oRelatorio:section(2)
	Local cQuebra	   := chr(13) + Chr(10)
	Local cQRY	 	   := ""
	
	cQRY += " SELECT 'SF1' AS TABELA, F1_FILIAL FILIAL, F1_DOC NOTATIT, F1_SERIE SERIEPRE, F1_EMISSAO EMISSAO, F1_FORNECE FORCLI, F1_LOJA LOJA, F1_VALBRUT VALOR "+CQUEBRA 
	cQRY += " , ' '  TIPO,' ' PARCELA 																															 "+CQUEBRA                         
	cQRY += " FROM "+RETSQLNAME('SF1')+" SF1 																													 "+CQUEBRA
	cQRY += " WHERE SF1.D_E_L_E_T_=''																															 "+CQUEBRA
	cQRY += "  AND F1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  																						 "+CQUEBRA
	cQRY += "  AND F1_EMISSAO BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"'																				 "+CQUEBRA
	cQRY += "  AND F1_DTLANC = '' 												                            													 "+CQUEBRA
	cQRY += " UNION																																				 "+CQUEBRA
	cQRY += " SELECT 'SF2' AS TABELA, F2_FILIAL FILIAL, F2_DOC NOTATIT, F2_SERIE SERIEPRE, F2_EMISSAO EMISSAO, F2_CLIENTE FORCLI, F2_LOJA LOJA, F2_VALBRUT VALOR "+CQUEBRA
	cQRY += " , ' '  TIPO,' ' PARCELA 																															 "+CQUEBRA
	cQRY += " FROM "+RETSQLNAME('SF2')+" SF2  																		            								 "+CQUEBRA
	cQRY += " WHERE SF2.D_E_L_E_T_=''																				            								 "+CQUEBRA
	cQRY += "  AND F2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  											            								 "+CQUEBRA
	cQRY += "  AND F2_EMISSAO BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"'									        									 "+CQUEBRA
	cQRY += "  AND F2_DTLANC = '' 												                                            									 "+CQUEBRA
	cQRY += " UNION 																																			 "+CQUEBRA
	cQRY += " SELECT 'SE1' AS TABELA, E1_FILIAL FILIAL, E1_NUM NOTATIT, E1_PREFIXO SERIEPRE, E1_EMISSAO EMISSAO, E1_CLIENTE FORCLI, E1_LOJA LOJA, E1_VALOR VALOR "+CQUEBRA
	cQRY += " , E1_TIPO TIPO, E1_PARCELA PARCELA 																												 "+CQUEBRA
	cQRY += " FROM "+RETSQLNAME('SE1')+" SE1 																		            								 "+CQUEBRA
	cQRY += " WHERE SE1.D_E_L_E_T_=''																				            								 "+CQUEBRA
	cQRY += "  AND E1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  											            								 "+CQUEBRA
	cQRY += "  AND E1_EMISSAO BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"'									        									 "+CQUEBRA
	cQRY += "  AND E1_LA = '' 												                                            										 "+CQUEBRA
	cQRY += " UNION 																																			 "+CQUEBRA
	cQRY += " SELECT 'SE2' AS TABELA, E2_FILIAL FILIAL, E2_NUM NOTATIT, E2_PREFIXO SERIEPRE, E2_EMISSAO EMISSAO, E2_FORNECE FORCLI, E2_LOJA LOJA, E2_VALOR VALOR "+CQUEBRA
	cQRY += " , E2_TIPO TIPO, E2_PARCELA PARCELA																												 "+CQUEBRA 
	cQRY += " FROM "+RETSQLNAME('SE2')+" SE2  																		            								 "+CQUEBRA
	cQRY += " WHERE SE2.D_E_L_E_T_=''																				            								 "+CQUEBRA
	cQRY += "  AND E2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  											            								 "+CQUEBRA
	cQRY += "  AND E2_EMISSAO BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"'																				 "+CQUEBRA				        
	cQRY += "  AND E2_LA = '' 																																	 "+CQUEBRA
	cQRY += " ORDER BY TABELA, FILIAL,EMISSAO, NOTATIT, FORCLI, LOJA																							 "+CQUEBRA
    MpSysOpenQuery(cQRY, "cQRY")

	If cQRY->(Eof())
		MsgInfo("Nenhum dado foi localizado com os parâmetros informados.","Atenção!")
		Return .F.
	EndIf					

	DbSelectArea("SB2")
	SB2->(dbsetorder(1))
    DbSelectArea("SB1")
    SB1->(DbSetOrder(1))

	oRelatorio:SetMeter(cQRY->(RecCount()))

	While !cQRY->(Eof())

		oRelatorio:IncMeter() 

		If oRelatorio:Cancel()
			Exit
		EndIf	

		cTabela := cQRY->TABELA

		oRelatorio:OnPageBreak( {|| ImpTitSec( oRelatorio, cTabela) } )


		While !cQRY->(Eof()) .And. cTabela == cQRY->TABELA

			//incproc("Produto "+QERY->B1_COD)

			If cTabela $ 'SE1|SE2'

				oSection1:Init()	
				oSection1:Cell('FILIAL'):SetValue(AllTrim(cQRY->FILIAL))
				oSection1:Cell('PREFIXO'):SetValue(cQRY->SERIEPRE)
				oSection1:Cell('TITULO'):SetValue(cQRY->NOTATIT)
				oSection1:Cell('EMISSAO'):SetValue(DtoC(StoD(cQRY->EMISSAO)))
				oSection1:Cell('TIPO'):SetValue(cQRY->TIPO)
				oSection1:Cell('PARCELA'):SetValue(cQRY->PARCELA)
				oSection1:Cell('FORN/CLI'):SetValue(cQRY->FORCLI)
				oSection1:Cell('LOJA'):SetValue(cQRY->LOJA)
				oSection1:Cell('VALOR TOTAL'):SetValue(cQRY->VALOR)
				oSection1:PrintLine()

			Else

				oSection2:Init()
				oSection2:Cell('FILIAL'):SetValue(AllTrim(cQRY->FILIAL))
				oSection2:Cell('NOTA FISCAL'):SetValue(cQRY->NOTATIT)
				oSection2:Cell('SERIE'):SetValue(cQRY->SERIEPRE)
				oSection2:Cell('EMISSAO'):SetValue(DtoC(StoD(cQRY->EMISSAO)))
				oSection2:Cell('FORN/CLI'):SetValue(cQRY->FORCLI)
				oSection2:Cell('LOJA'):SetValue(cQRY->LOJA)
				oSection2:Cell('VALOR TOTAL'):SetValue(cQRY->VALOR)
				oSection2:PrintLine()

			EndIf

			cQRY->(DbSkip())

		EndDo
	EndDo

	cQRY->(DbCloseArea())
	oSection1:Finish()

Return

Static Function ImpTitSec( oRelatorio, cTabela )
		oRelatorio:SkipLine(2) //-- Salta Linha
		oRelatorio:ThinLine() //-- Desenha uma linha simples
	Do Case
		Case cTabela == 'SE1'
			oRelatorio:PrtCenter("TITULOS A RECEBER")
		Case cTabela == 'SE2'
			oRelatorio:PrtCenter("TITULOS A PAGAR")
		Case cTabela == 'SF1'
			oRelatorio:PrtCenter("NOTAS FISCAIS DE ENTRADA")
		Case cTabela == 'SF2'
			oRelatorio:PrtCenter("NOTAS FISCAIS DE SAIDA")
	End Case
		oRelatorio:SkipLine(2) //-- Salta Linha
		oRelatorio:ThinLine() //-- Desenha uma linha simples

Return 


*******************************************************************************
// Função : CriaCab - Realiza a Montagem do Cabeçalho do Relatório		      |
// Modulo : Estoque e Custo                                                   |
// ---------+-------------------+---------------------------------------------+
// Data     | Autor             | Descricao                                   |
// ---------+-------------------+---------------------------------------------+
// 26/03/24 | Rivaldo Júnior    | Cabeçalho			                          |
*******************************************************************************

Static Function CriaCab( oRelatorio )
	Local aArea		:= GetArea()
	Local aCabec	:= {}
	Local cChar		:= chr(160)
	local _cEmp 	:= FWCodEmp()

	_DataDe := DToC(MV_PAR03)
	_DataAte:= DToC(MV_PAR04)

	aCabec := {	"__LOGOEMP__" + "         " + cChar + "         " + RptFolha+TRANSFORM(oRelatorio:Page(),'999999');
		, Padc(UPPER("Não integrados a contabilidade - ") + FWFilialName(_cEmp),132);
		, Padc("",132);
		, Padc(UPPER('Período de '+DtoC(MV_PAR03)+' até '+DtoC(MV_PAR04)),132);
		, RptHora + " " + time() ;
		+ cChar + "         " + RptEmiss + " " + Dtoc(dDataBase)}

	RestArea( aArea )

Return aCabec

										