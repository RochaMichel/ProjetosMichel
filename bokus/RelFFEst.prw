#Include 'TOTVS.CH'

*******************************************************************************
// Função : RelFFEst - Realiza a Montagem do Relatório	Treport			      |
// Modulo : Estoque e Custo                                                   |
// Fonte  : RelFFEst.prw                                                      |
// ---------+-----------------------+-----------------------------------------+
// Data     | Autor            	    | Descricao                               |
// ---------+-----------------------+-----------------------------------------+
// 22/03/24 | Rivaldo Jr. (Cod.ERP) | Relatório			                      |
*******************************************************************************
#define CLR_SILVER rgb(192,192,192)
#define CLR_GAINSBORO rgb(220,220,220)
#define CLR_LightSteelBlue rgb(176,196,222)

User Function RelFFEst()
    PRIVATE _DataDe		:= ""
	PRIVATE _DataAte	:= ""
	PRIVATE cTitulo     := ""
	PRIVATE cDescri     := ""
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
	aAdd(aPergs, {1, "Do produto:"      	 ,space(TamSX3("B1_COD")[1]) 	, "",  ".T."  , "SB1", ".T."   , 40, .F.}) //MV_PAR05
	aAdd(aPergs, {1, "Até o produto:"   	 ,space(TamSX3("B1_COD")[1]) 	, "",  ".T."  , "SB1", ".T."   , 40, .T.}) //MV_PAR06

	aAdd(aPergs, {1, "Do grupo:"      	 	 ,space(TamSX3("B1_GRUPO")[1]) 	, "",  ".T."  , "SBM", ".T."   , 40, .F.}) //MV_PAR07
	aAdd(aPergs, {1, "Até o Grupo:"   	 	 ,space(TamSX3("B1_GRUPO")[1]) 	, "",  ".T."  , "SBM", ".T."   , 40, .T.}) //MV_PAR08

	aAdd(aPergs, {1, "Tipo do produto:"      ,space(TamSX3("B1_TIPO")[1]) 	, "",  ".T."  , "02", ".T."    , 40, .F.}) //MV_PAR09
	aAdd(aPergs, {2, "Apenas com movimento:" , "N" , {"S=Sim","N=Nao",""}  	, 60,  ".T."  ,.T.}) 					   //MV_PAR10
	aAdd(aPergs, {1, "Qual armazém:"      ,space(TamSX3("B1_LOCPAD")[1]) , "",  ".T."  , "NNR", ".T."   , 40, .T.}) //MV_PAR11

	If !parambox(aPergs,"Informe os parametros")
		Return
	EndIf

	oRelatorio  := TReport():New(cFunName, ,, {|oRelatorio| PrintReport(oRelatorio)}, cDescri,,,,,,,)
	oRelatorio:SetPortrait()
	oRelatorio:SetCustomText({||CriaCab(oRelatorio)})
	oRelatorio:SetLineHeight(42)
	oRelatorio:SetRightAlignPrinter(.T.)

	oSection1   := TRSection():New(oRelatorio,  , {'SB1','SB9','SB2','SD1','SD2'})
	TRCell():New(oSection1,'PRODUTO'              ,'', ,PesqPict("SB1", "B1_DESC") ,35 ,/*lPixel*/, ,"LEFT"  ,lLineBreak,"LEFT"  ,,   0 ,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'SALDO ANTERIOR (R$)'  ,'', ,"@E 9,999,999.99"		   ,23 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -2	,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'SALDO ANTERIOR (Qtd.)','', ,"@E 9,999,999.99"		   ,24 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -2	,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'ENTRADAS (R$)'        ,'', ,"@E 9,999,999.99"      	   ,18 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -3	,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'ENTRADAS (Qtd.)'      ,'', ,"@E 9,999,999.99"      	   ,20 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -3	,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'SAIDA (R$)'    		  ,'', ,"@E 9,999,999.99"      	   ,16 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -3	,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'SAIDA (Qtd.)'         ,'', ,"@E 9,999,999.99"      	   ,16 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -3	,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'SALDO ATUAL (R$)'     ,'', ,"@E 9,999,999.99"      	   ,20 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -3 ,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'SALDO ATUAL (Qtd.)'   ,'', ,"@E 9,999,999.99"      	   ,22 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -3 ,lAutoSize, , ,_lBold)
	oSection1:SetHeaderPage(.F.)
	oSection1:SetHeaderSection(.F.)

	oSection2   := TRSection():New(oRelatorio,  , {'SB1','SB9','SB2','SD1','SD2'},,,,,,.F.,.F.,.F.,,,,,,,,,CLR_GAINSBORO)
	TRCell():New(oSection2,'PRODUTO'              ,'', ,PesqPict("SB1", "B1_DESC") ,35 ,/*lPixel*/, ,"LEFT"  ,lLineBreak,"LEFT"  ,,   0 ,lAutoSize, , ,_lBold)
	TRCell():New(oSection2,'SALDO ANTERIOR (R$)'  ,'', ,"@E 9,999,999.99"		   ,23 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -2	,lAutoSize, , ,_lBold)
	TRCell():New(oSection2,'SALDO ANTERIOR (Qtd.)','', ,"@E 9,999,999.99"		   ,24 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -2	,lAutoSize, , ,_lBold)
	TRCell():New(oSection2,'ENTRADAS (R$)'        ,'', ,"@E 9,999,999.99"      	   ,18 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -3	,lAutoSize, , ,_lBold)
	TRCell():New(oSection2,'ENTRADAS (Qtd.)'      ,'', ,"@E 9,999,999.99"      	   ,20 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -3	,lAutoSize, , ,_lBold)
	TRCell():New(oSection2,'SAIDA (R$)'    		  ,'', ,"@E 9,999,999.99"      	   ,16 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -3	,lAutoSize, , ,_lBold)
	TRCell():New(oSection2,'SAIDA (Qtd.)'         ,'', ,"@E 9,999,999.99"      	   ,16 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -3	,lAutoSize, , ,_lBold)
	TRCell():New(oSection2,'SALDO ATUAL (R$)'     ,'', ,"@E 9,999,999.99"      	   ,20 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -3 ,lAutoSize, , ,_lBold)
	TRCell():New(oSection2,'SALDO ATUAL (Qtd.)'   ,'', ,"@E 9,999,999.99"      	   ,22 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -3 ,lAutoSize, , ,_lBold)

	oSection3   := TRSection():New(oRelatorio,  , {'SB1','SB9','SB2','SD1','SD2'},,,,,,.F.,.F.,.F.,,,,,,,,,CLR_LightSteelBlue)
	TRCell():New(oSection3,'PRODUTO'              ,'', ,PesqPict("SB1", "B1_DESC") ,35 ,/*lPixel*/, ,"LEFT"  ,lLineBreak,"LEFT"  ,,   0 ,lAutoSize, , ,_lBold)
	TRCell():New(oSection3,'SALDO ANTERIOR (R$)'  ,'', ,"@E 9,999,999.99"		   ,23 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -2	,lAutoSize, , ,_lBold)
	TRCell():New(oSection3,'SALDO ANTERIOR (Qtd.)','', ,"@E 9,999,999.99"		   ,24 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -2	,lAutoSize, , ,_lBold)
	TRCell():New(oSection3,'ENTRADAS (R$)'        ,'', ,"@E 9,999,999.99"      	   ,18 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -3	,lAutoSize, , ,_lBold)
	TRCell():New(oSection3,'ENTRADAS (Qtd.)'      ,'', ,"@E 9,999,999.99"      	   ,20 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -3	,lAutoSize, , ,_lBold)
	TRCell():New(oSection3,'SAIDA (R$)'    		  ,'', ,"@E 9,999,999.99"      	   ,16 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -3	,lAutoSize, , ,_lBold)
	TRCell():New(oSection3,'SAIDA (Qtd.)'         ,'', ,"@E 9,999,999.99"      	   ,16 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -3	,lAutoSize, , ,_lBold)
	TRCell():New(oSection3,'SALDO ATUAL (R$)'     ,'', ,"@E 9,999,999.99"      	   ,20 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -3 ,lAutoSize, , ,_lBold)
	TRCell():New(oSection3,'SALDO ATUAL (Qtd.)'   ,'', ,"@E 9,999,999.99"      	   ,22 ,/*lPixel*/, ,"RIGHT" ,lLineBreak,"RIGHT" ,,  -3 ,lAutoSize, , ,_lBold)
	oSection3:SetHeaderPage(.F.)
	oSection3:SetHeaderSection(.F.)
	oRelatorio:printDialog()

Return


*******************************************************************************
// Função : PrintReport - Realiza a Busca dos dados e Definição 		      |
// Modulo : Estoque e Custo                                                   |
// ---------+-------------------+---------------------------------------------+
// Data     | Autor             | Descricao                                   |
// ---------+-------------------+---------------------------------------------+
// 22/03/24 | Rivaldo Júnior    | Busca dos dados	                          |
*******************************************************************************

Static Function PrintReport(oRelatorio)
	Local oSection1    := oRelatorio:section(1)
	Local cQuebra	   := chr(13) + Chr(10)
	Local QERY	 	   := ""
	Local aSaldos      := {}
	Local nVlrSaldoAnt := 0
	Local nVlrEntrada  := 0
	Local nVlrSaida	   := 0
	Local nVlrSaldo	   := 0
	Local nSaldoAntQtd := 0
	Local nEntradasQtd := 0
	Local nSaidasQtd   := 0
	Local nSaldoQtd    := 0
	Local cGrupo	   := ""
	Local nVlrSaldTot  := 0
	Local nSldQtdTot   := 0
	Local nVlrEntTot   := 0
	Local nQtdEntTot   := 0
	Local nVlrSaiTot   := 0
	Local nQtdSaiTot   := 0
	Local nVlrTotAtu   := 0
	Local nSldTotAtu   := 0
	Local nSaldoGeral  := 0
	Local nQtdGeral    := 0
	Local nEntGeral    := 0
	Local nQtdEntGer   := 0
	Local nSaiGeral    := 0
	Local nQtdSaiGer   := 0
	Local nAtualGer    := 0
	Local nAtualQtd    := 0

	QERY += "  SELECT B1_FILIAL, B1_COD, B1_DESC, B1_UM, B1_LOCPAD , B1_TIPO,B2_FILIAL, B1_GRUPO, "+CQUEBRA		
	QERY += " 							
	QERY += " 	( SELECT SUM(D1_QUANT) CUSTOS FROM "+RETSQLNAME('SB1')+" B1	 "+CQUEBRA											
	QERY += " 			INNER JOIN "+RETSQLNAME('SD1')+" SD1 ON B1_COD = D1_COD AND D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND D1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'	AND SD1.D_E_L_E_T_='' "+CQUEBRA		
	If !Empty(MV_PAR11) .And. AllTrim(MV_PAR11) <> '*'
		QERY += " 			AND D1_LOCAL = '"+MV_PAR11+"' "
	EndIf
	QERY += " 			INNER JOIN "+RETSQLNAME('SF1')+" SF1 ON F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA  AND  F1_FILIAL = D1_FILIAL AND SF1.D_E_L_E_T_ = '' AND F1_TIPO <> 'D' "+CQUEBRA	 													
	QERY += " 			INNER JOIN "+RETSQLNAME('SF4')+" SF4 ON D1_TES = F4_CODIGO 	AND F4_ESTOQUE = 'S' AND F4_FILIAL  = SUBSTRING(D1_FILIAL,1,2) "+CQUEBRA											
	QERY += " 		WHERE B1.B1_COD = SB1.B1_COD "+CQUEBRA																		
	QERY += " 			AND B1.B1_FILIAL = SB1.B1_FILIAL ) ENTRADA_D1,	"+CQUEBRA		
	QERY += " 										
	QERY += " 	( SELECT SUM(D1_CUSTO) FROM "+RETSQLNAME('SB1')+" B1 "+CQUEBRA												 	
	QERY += " 			INNER JOIN "+RETSQLNAME('SD1')+" SD1 ON B1_COD = D1_COD  AND D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND D1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND SD1.D_E_L_E_T_=''"+CQUEBRA
	If !Empty(MV_PAR11) .And. AllTrim(MV_PAR11) <> '*'
		QERY += " 			AND D1_LOCAL = '"+MV_PAR11+"' "
	EndIf	 				
	QERY += " 			INNER JOIN "+RETSQLNAME('SF1')+" SF1 ON F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA  AND  F1_FILIAL = D1_FILIAL AND SF1.D_E_L_E_T_ = '' AND F1_TIPO <> 'D' "+CQUEBRA	 				
	QERY += " 			INNER JOIN "+RETSQLNAME('SF4')+" SF4 ON D1_TES = F4_CODIGO 	AND F4_ESTOQUE = 'S'  AND F4_ESTOQUE = 'S'	AND F4_FILIAL  = SUBSTRING(D1_FILIAL,1,2) "+CQUEBRA	 			
	QERY += " 		WHERE B1.B1_COD = SB1.B1_COD "+CQUEBRA																					       					
	QERY += " 			AND B1.B1_FILIAL = SB1.B1_FILIAL ) D1_CUSTO, "+CQUEBRA			
	QERY += " 										
	QERY += " 	( SELECT SUM(D3_QUANT) CUSTOS FROM "+RETSQLNAME('SB1')+" B1	"+CQUEBRA								 			
	QERY += " 			INNER JOIN "+RETSQLNAME('SD3')+" SD3 ON B1_COD = D3_COD AND D3_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'   AND D3_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  AND D3_ESTORNO = ''  AND SD3.D_E_L_E_T_='' "+CQUEBRA
	If !Empty(MV_PAR11) .And. AllTrim(MV_PAR11) <> '*'
		QERY += " 			AND D3_LOCAL = '"+MV_PAR11+"' "
	EndIf			 										
	QERY += " 		WHERE  (D3_CF LIKE '%DE%' OR D3_CF LIKE '%PR%') "+CQUEBRA													
	QERY += " 			AND B1.B1_COD = SB1.B1_COD "+CQUEBRA																		
	QERY += " 			AND B1.B1_FILIAL = SB1.B1_FILIAL ) ENTRADA_D3, "+CQUEBRA			
	QERY += " 										
	QERY += " 	( SELECT SUM(D3_CUSTO1) CUSTOS FROM "+RETSQLNAME('SB1')+" B1 "+CQUEBRA									 		
	QERY += " 			INNER JOIN "+RETSQLNAME('SD3')+" SD3 ON B1_COD = D3_COD AND D3_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'  AND D3_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND D3_ESTORNO = ''  AND SD3.D_E_L_E_T_='' "+CQUEBRA
	If !Empty(MV_PAR11) .And. AllTrim(MV_PAR11) <> '*'
		QERY += " 			AND D3_LOCAL = '"+MV_PAR11+"' "
	EndIf			  									
	QERY += " 		WHERE  (D3_CF LIKE '%DE%' OR D3_CF LIKE '%PR%')  "+CQUEBRA													
	QERY += " 			AND B1.B1_COD = SB1.B1_COD "+CQUEBRA																					       					
	QERY += " 			AND B1.B1_FILIAL = SB1.B1_FILIAL ) D3_CUSTO_ENT, "+CQUEBRA			
	QERY += " 							
	QERY += " 	(SELECT SUM(QUANT) SAIDA_D2 FROM  		
	QERY += " 		( SELECT SUM(D2_QUANT) QUANT FROM "+RETSQLNAME('SB1')+" B1	"+CQUEBRA											
	QERY += " 			INNER JOIN "+RETSQLNAME('SD2')+" SD2 ON B1_COD = D2_COD AND D2_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'  AND D2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND SD2.D_E_L_E_T_='' "+CQUEBRA
	If !Empty(MV_PAR11) .And. AllTrim(MV_PAR11) <> '*'
		QERY += " 			AND D2_LOCAL = '"+MV_PAR11+"' "
	EndIf
	QERY += " 			INNER JOIN "+RETSQLNAME('SF2')+" SF2 ON F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND  F2_CLIENTE = D2_CLIENTE AND  F2_LOJA = D2_LOJA AND  F2_FILIAL = D2_FILIAL	AND SF2.D_E_L_E_T_ = '' AND F2_TIPO <> 'D' "+CQUEBRA		    										
	QERY += " 			INNER JOIN "+RETSQLNAME('SF4')+" SF4 ON D2_TES = F4_CODIGO 	AND F4_ESTOQUE = 'S' AND F4_FILIAL  = SUBSTRING(D2_FILIAL,1,2) "+CQUEBRA											
	QERY += " 		  WHERE B1.B1_COD = SB1.B1_COD AND B1.B1_FILIAL = SB1.B1_FILIAL "+CQUEBRA																						
	QERY += " 		UNION
	QERY += " 		  SELECT SUM(D1_QUANT)*-1 QUANT FROM "+RETSQLNAME('SB1')+" B1	 "+CQUEBRA											
	QERY += " 			INNER JOIN "+RETSQLNAME('SD1')+" SD1 ON B1_COD = D1_COD AND D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND D1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'	AND SD1.D_E_L_E_T_='' "+CQUEBRA
	If !Empty(MV_PAR11) .And. AllTrim(MV_PAR11) <> '*'
		QERY += " 			AND D1_LOCAL = '"+MV_PAR11+"' "
	EndIf		
	QERY += " 			INNER JOIN "+RETSQLNAME('SF1')+" SF1 ON F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA  AND  F1_FILIAL = D1_FILIAL AND SF1.D_E_L_E_T_ = '' AND F1_TIPO = 'D' "+CQUEBRA	 													
	QERY += " 			INNER JOIN "+RETSQLNAME('SF4')+" SF4 ON D1_TES = F4_CODIGO 	AND F4_ESTOQUE = 'S' AND F4_FILIAL  = SUBSTRING(D1_FILIAL,1,2) "+CQUEBRA											
	QERY += " 		  WHERE B1.B1_COD = SB1.B1_COD AND B1.B1_FILIAL = SB1.B1_FILIAL "+CQUEBRA																		
	QERY += " 		) A) SAIDA_D2 , "+CQUEBRA	
	QERY += " 												
	QERY += " 	(SELECT SUM(CUSTO) D2_CUSTO FROM  		
	QERY += " 		( SELECT SUM(D2_CUSTO1) CUSTO FROM "+RETSQLNAME('SB1')+" B1	"+CQUEBRA											
	QERY += " 			INNER JOIN "+RETSQLNAME('SD2')+" SD2 ON B1_COD = D2_COD AND D2_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'  AND D2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND SD2.D_E_L_E_T_='' "+CQUEBRA
	If !Empty(MV_PAR11) .And. AllTrim(MV_PAR11) <> '*'
		QERY += " 			AND D2_LOCAL = '"+MV_PAR11+"' "
	EndIf
	QERY += " 			INNER JOIN "+RETSQLNAME('SF2')+" SF2 ON F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND  F2_CLIENTE = D2_CLIENTE AND  F2_LOJA = D2_LOJA AND  F2_FILIAL = D2_FILIAL	AND SF2.D_E_L_E_T_ = '' AND F2_TIPO <> 'D' "+CQUEBRA		    										
	QERY += " 			INNER JOIN "+RETSQLNAME('SF4')+" SF4 ON D2_TES = F4_CODIGO 	AND F4_ESTOQUE = 'S' AND F4_FILIAL  = SUBSTRING(D2_FILIAL,1,2) "+CQUEBRA											
	QERY += " 		  WHERE B1.B1_COD = SB1.B1_COD AND B1.B1_FILIAL = SB1.B1_FILIAL "+CQUEBRA																						
	QERY += " 		UNION
	QERY += " 		  SELECT SUM(D1_CUSTO)*-1 CUSTO FROM "+RETSQLNAME('SB1')+" B1	 "+CQUEBRA											
	QERY += " 			INNER JOIN "+RETSQLNAME('SD1')+" SD1 ON B1_COD = D1_COD AND D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND D1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'	AND SD1.D_E_L_E_T_='' "+CQUEBRA
	If !Empty(MV_PAR11) .And. AllTrim(MV_PAR11) <> '*'
		QERY += " 			AND D1_LOCAL = '"+MV_PAR11+"' "
	EndIf		
	QERY += " 			INNER JOIN "+RETSQLNAME('SF1')+" SF1 ON F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA  AND  F1_FILIAL = D1_FILIAL AND SF1.D_E_L_E_T_ = '' AND F1_TIPO = 'D' "+CQUEBRA	 													
	QERY += " 			INNER JOIN "+RETSQLNAME('SF4')+" SF4 ON D1_TES = F4_CODIGO 	AND F4_ESTOQUE = 'S' AND F4_FILIAL  = SUBSTRING(D1_FILIAL,1,2) "+CQUEBRA											
	QERY += " 		  WHERE B1.B1_COD = SB1.B1_COD AND B1.B1_FILIAL = SB1.B1_FILIAL "+CQUEBRA																		
	QERY += " 		) A) D2_CUSTO , "+CQUEBRA		
	QERY += " 												
	QERY += " 	( SELECT SUM(D3_QUANT) CUSTOS FROM "+RETSQLNAME('SB1')+" B1	"+CQUEBRA								 			
	QERY += " 			INNER JOIN "+RETSQLNAME('SD3')+" SD3 ON B1_COD = D3_COD AND D3_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'  AND D3_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND D3_ESTORNO = '' AND SD3.D_E_L_E_T_='' "+CQUEBRA
	If !Empty(MV_PAR11) .And. AllTrim(MV_PAR11) <> '*'
		QERY += " 			AND D3_LOCAL = '"+MV_PAR11+"' "
	EndIf				  										
	QERY += " 		WHERE  D3_CF LIKE '%RE%' "+CQUEBRA																			
	QERY += " 		AND B1.B1_COD = SB1.B1_COD 	 "+CQUEBRA																								
	QERY += " 		AND B1.B1_FILIAL = SB1.B1_FILIAL ) SAIDA_D3,	"+CQUEBRA	
	QERY += " 												
	QERY += " 	( SELECT SUM(D3_CUSTO1) CUSTOS FROM "+RETSQLNAME('SB1')+" B1	"+CQUEBRA								 	    
	QERY += " 			INNER JOIN "+RETSQLNAME('SD3')+" SD3 ON B1_COD = D3_COD AND D3_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND D3_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'	 AND D3_ESTORNO = '' AND SD3.D_E_L_E_T_='' "+CQUEBRA
	If !Empty(MV_PAR11) .And. AllTrim(MV_PAR11) <> '*'
		QERY += " 			AND D3_LOCAL = '"+MV_PAR11+"' "
	EndIf										
	QERY += " 		WHERE  D3_CF LIKE '%RE%' "+CQUEBRA																			
	QERY += " 		AND B1.B1_COD = SB1.B1_COD "+CQUEBRA																					
	QERY += " 		AND B1.B1_FILIAL = SB1.B1_FILIAL ) D3_CUSTO_SAI "+CQUEBRA			
	QERY += " 											
	QERY += " FROM "+RETSQLNAME('SB1')+" SB1 "+CQUEBRA																			 
	QERY += " INNER JOIN "+RETSQLNAME('SB2')+" B2 ON B2.B2_COD = SB1.B1_COD  "+CQUEBRA	 	 		  	 							
	If MV_PAR10 == 'S'
		QERY += " INNER JOIN "+RETSQLNAME('SD3')+" D3 ON D3_COD = SB1.B1_COD  AND D3_FILIAL = B2_FILIAL  "+CQUEBRA	
	EndIf 
	QERY += " WHERE SB1.D_E_L_E_T_='' "+CQUEBRA																			
	QERY += " 	AND B2.D_E_L_E_T_='' "+CQUEBRA																				
	QERY += " 	AND B1_COD BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "+CQUEBRA	
	QERY += " 	AND B1_FILIAL = '"+xFilial("SB1")+"' "+CQUEBRA
	QERY += " 	AND B2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CQUEBRA
	If MV_PAR10 == 'S'
		QERY += " 	AND D3_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "+CQUEBRA
		QERY += " 	AND D3.D_E_L_E_T_='' "+CQUEBRA
	EndIf 
	If !Empty(MV_PAR09) 
		QERY += " AND B1_TIPO = '"+MV_PAR09+"' "+CQUEBRA
	EndIf
	QERY += " 	AND B1_GRUPO BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "+CQUEBRA																									 																									 
	QERY += " 	GROUP BY B1_FILIAL,B2_FILIAL, B1_GRUPO, B1_COD, B1_DESC, B1_UM ,B1_TIPO, B1_LOCPAD "+CQUEBRA			      				
	QERY += " 	ORDER BY B1_FILIAL,B2_FILIAL, B1_GRUPO, B1_COD "+CQUEBRA																		
    MpSysOpenQuery(QERY, "QERY")

	If QERY->(Eof())
		MsgInfo("Nenhum dado foi localizado com os parâmetros informados.","Atenção!")
		Return .F.
	EndIf					

	DbSelectArea("SB2")
	SB2->(dbsetorder(1))
    DbSelectArea("SB1")
    SB1->(DbSetOrder(1))

	oRelatorio:SetMeter(QERY->(RecCount()))

	While !QERY->(Eof())
		If oRelatorio:Cancel()
			Exit
		EndIf

		oRelatorio:SetMsgPrint( "Calculando valores ... Produto "+QERY->B1_COD)   

		nVlrSaldTot:= 0
		nSldQtdTot := 0
		nVlrEntTot := 0
		nQtdEntTot := 0
		nVlrSaiTot := 0
		nQtdSaiTot := 0
		nVlrTotAtu := 0
		nSldTotAtu := 0

		cGrupo := QERY->B1_GRUPO
		oSection2:Init()
		oSection2:Cell('PRODUTO'):SetValue('GRUPO DE PRODUTO: '+cGrupo)
		oSection2:Cell('SALDO ANTERIOR (R$)'):SetValue()
		oSection2:Cell('SALDO ANTERIOR (Qtd.)'):SetValue()
		oSection2:Cell('ENTRADAS (R$)'):SetValue()
		oSection2:Cell('ENTRADAS (Qtd.)'):SetValue()
		oSection2:Cell('SAIDA (R$)'):SetValue()
		oSection2:Cell('SAIDA (Qtd.)'):SetValue()
		oSection2:Cell('SALDO ATUAL (R$)'):SetValue()
		oSection2:Cell('SALDO ATUAL (Qtd.)'):SetValue()
		oSection2:PrintLine()
		//oRelatorio:SkipLine() //-- Salta Linha
		oRelatorio:ThinLine() //-- Desenha uma linha simples
		oRelatorio:SkipLine() //-- Salta Linha
		While !QERY->(Eof()) .And. cGrupo == QERY->B1_GRUPO
			//Posiciona no cadastro
			//If SB2->(MsSeek(QERY->(B2_FILIAL+B1_COD+B1_LOCPAD)))

			If SB2->(MsSeek(QERY->(B2_FILIAL+B1_COD+B1_LOCPAD)))
				//aSaldos := CalcEst(SB2->B2_COD, SB2->B2_LOCAL, DaySub(MV_PAR03,1))//Busca os saldos
				aSaldos := CalcEst(SB2->B2_COD, SB2->B2_LOCAL, MV_PAR03+1)//Busca os saldos
				//1 = saldo / 2 = vlr. total saldo / 8 = custo medio
			EndIf

			//Quantidades
			If Len(aSaldos) > 0
				nSaldoAntQtd := aSaldos[1]
			EndI

			nEntradasQtd := (QERY->ENTRADA_D1+QERY->ENTRADA_D3)

			nSaidasQtd 	 := (QERY->SAIDA_D2+QERY->SAIDA_D3)

			nSaldoQtd    := ((nEntradasQtd+nSaldoAntQtd)-nSaidasQtd)

			//Valores
			If Len(aSaldos) > 0
				nVlrSaldoAnt := aSaldos[2]
			EndIf

			nVlrEntrada  := (QERY->D1_CUSTO+QERY->D3_CUSTO_ENT) //CUSTO ENTRADAS

			nVlrSaida	 := (QERY->D2_CUSTO+QERY->D3_CUSTO_SAI) //CUSTO SAIDAS

			nVlrSaldo	 := ((nVlrSaldoAnt+nVlrEntrada)-nVlrSaida)

			oSection1:Init()
			oSection1:Cell('PRODUTO'):SetValue(AllTrim(QERY->B1_COD)+' - '+AllTrim(QERY->B1_DESC))
			oSection1:Cell('SALDO ANTERIOR (R$)'):SetValue(nVlrSaldoAnt)
			oSection1:Cell('SALDO ANTERIOR (Qtd.)'):SetValue(nSaldoAntQtd)
			oSection1:Cell('ENTRADAS (R$)'):SetValue(nVlrEntrada)
			oSection1:Cell('ENTRADAS (Qtd.)'):SetValue(nEntradasQtd)
			oSection1:Cell('SAIDA (R$)'):SetValue(nVlrSaida)
			oSection1:Cell('SAIDA (Qtd.)'):SetValue(nSaidasQtd)
			oSection1:Cell('SALDO ATUAL (R$)'):SetValue(nVlrSaldo)
			oSection1:Cell('SALDO ATUAL (Qtd.)'):SetValue(nSaldoQtd)
			oSection1:PrintLine()

			nVlrSaldTot += nVlrSaldoAnt
			nSldQtdTot  += nSaldoAntQtd

			nVlrEntTot += nVlrEntrada
			nQtdEntTot += nEntradasQtd
 
			nVlrSaiTot += nVlrSaida
			nQtdSaiTot += nSaidasQtd

			nVlrTotAtu += nVlrSaldo
			nSldTotAtu  += nSaldoQtd

			QERY->(DbSkip())
		EndDo
		//oRelatorio:SkipLine() //-- Salta Linha
		oRelatorio:ThinLine() //-- Desenha uma linha simples
		//oRelatorio:SkipLine() //-- Salta Linha
		oSection2:Init()
		oSection2:Cell('PRODUTO'):SetValue('TOTAL DOS VALORES DO GRUPO: '+cGrupo)
		oSection2:Cell('SALDO ANTERIOR (R$)'):SetValue(nVlrSaldTot)
		oSection2:Cell('SALDO ANTERIOR (Qtd.)'):SetValue(nSldQtdTot)
		oSection2:Cell('ENTRADAS (R$)'):SetValue(nVlrEntTot)
		oSection2:Cell('ENTRADAS (Qtd.)'):SetValue(nQtdEntTot)
		oSection2:Cell('SAIDA (R$)'):SetValue(nVlrSaiTot)
		oSection2:Cell('SAIDA (Qtd.)'):SetValue(nQtdSaiTot)
		oSection2:Cell('SALDO ATUAL (R$)'):SetValue(nVlrTotAtu)
		oSection2:Cell('SALDO ATUAL (Qtd.)'):SetValue(nSldTotAtu)
		oSection2:PrintLine()

		nSaldoGeral += nVlrSaldTot
		nQtdGeral   += nSldQtdTot

		nEntGeral   += nVlrEntTot
		nQtdEntGer  += nQtdEntTot

		nSaiGeral   += nVlrSaiTot
		nQtdSaiGer  += nQtdSaiTot

		nAtualGer   += nVlrTotAtu
		nAtualQtd   += nSldTotAtu
 
		If !QERY->(Eof())
			//oRelatorio:SkipLine() //-- Salta Linha
			oRelatorio:ThinLine() //-- Desenha uma linha simples
			oRelatorio:SkipLine() //-- Salta Linha
			oRelatorio:SkipLine() //-- Salta Linha
		EndIf

	EndDo
	oRelatorio:SkipLine() //-- Salta Linha
	oRelatorio:SkipLine() //-- Salta Linha
	oRelatorio:SkipLine() //-- Salta Linha
	oRelatorio:ThinLine() //-- Desenha uma linha simples
	oRelatorio:SkipLine() //-- Salta Linha
	oSection3:Init()	
	oSection3:Cell('PRODUTO'):SetValue('TOTAL GERAL DO RELATÓRIO: ')
	oSection3:Cell('SALDO ANTERIOR (R$)'):SetValue(nSaldoGeral)
	oSection3:Cell('SALDO ANTERIOR (Qtd.)'):SetValue(nQtdGeral)
	oSection3:Cell('ENTRADAS (R$)'):SetValue(nEntGeral)
	oSection3:Cell('ENTRADAS (Qtd.)'):SetValue(nQtdEntGer)
	oSection3:Cell('SAIDA (R$)'):SetValue(nSaiGeral)
	oSection3:Cell('SAIDA (Qtd.)'):SetValue(nQtdSaiGer)
	oSection3:Cell('SALDO ATUAL (R$)'):SetValue(nAtualGer)
	oSection3:Cell('SALDO ATUAL (Qtd.)'):SetValue(nAtualQtd)
	oSection3:PrintLine()
	oRelatorio:SkipLine() //-- Salta Linha
	oRelatorio:ThinLine() //-- Desenha uma linha simples

	QERY->(DbCloseArea())
	oSection1:Finish()
	oSection2:Finish()
	oSection3:Finish()

Return


*******************************************************************************
// Função : CriaCab - Realiza a Montagem do Cabeçalho do Relatório		      |
// Modulo : Estoque e Custo                                                   |
// ---------+-------------------+---------------------------------------------+
// Data     | Autor             | Descricao                                   |
// ---------+-------------------+---------------------------------------------+
// 22/03/24 | Rivaldo Júnior    | Cabeçalho			                          |
*******************************************************************************

Static Function CriaCab( oRelatorio )
	Local aArea		:= GetArea()
	Local aCabec	:= {}
	Local cChar		:= chr(160)
	local _cEmp 	:= FWCodEmp()

	_DataDe := DToC(MV_PAR03)
	_DataAte:= DToC(MV_PAR04)

	aCabec := {	"__LOGOEMP__" + "         " + cChar + "         " + RptFolha+TRANSFORM(oRelatorio:Page(),'999999');
		, Padc(UPPER("Balanço fisico e financeiro do estoque - ") + FWFilialName(_cEmp),132);
		, Padc("",132);
		, Padc(UPPER('Período de '+_DataDe+' até '+_DataAte),132);
		, RptHora + " " + time() ;
		+ cChar + "         " + RptEmiss + " " + Dtoc(dDataBase)}

	RestArea( aArea )

Return aCabec
