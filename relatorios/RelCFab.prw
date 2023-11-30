#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#include "TopConn.ch"
#include "COLORS.ch"

#define CLR_SILVER rgb(192,192,192)

*******************************************************************************
// Função : RelVCli - rel. vendas por tipo de cliente  						  |
// Modulo : Financeiro                                                        |
// Fonte  : RelVCli.prw                                                       |
// ---------+-------------------+---------------------------------------------+
// Data     | Autor             | Descricao                                   |
// ---------+-------------------+---------------------------------------------+
// 09/01/23 | Rivaldo Júnior    | Relatório			                          |
*******************************************************************************

User Function RelCFab()
	PRIVATE cTitulo     := 'Relatório Controle de Fabricação'
	PRIVATE cDescri     := ""
	PRIVATE cFunName    := FunName()
	PRIVATE oRelatorio
	PRIVATE aPergs      := {}
	Private _lBold      := .T. //Controle de IMpressÃ£o em NEgrito
	Private lAutoSize   := .T.

	aAdd(aPergs, {1, "Do Produto:   " ,space(TamSX3("G1_COD")[1])   ,"@!",".T.","SB1",".T.",TamSX3("B1_COD")[1]+25, .F.}) //MV_Par01
	aAdd(aPergs, {1, "Até Produto:  " ,space(TamSX3("G1_COD")[1])   ,"@!",".T.","SB1",".T.",TamSX3("B1_COD")[1]+25, .T.}) //MV_Par02
	aAdd(aPergs, {1, "Data De       " ,Date()   , "", ".T.", "", ".T.", 80 , .F.}) 							 //MV_PAR03
	aAdd(aPergs, {1, "Data Até      " ,Date()   , "", ".T.", "", ".T.", 80 , .T.}) 							 //MV_PAR04
	aAdd(aPergs, {2, "Tipo Produto: " ,"3", {"CONCENTRADOS","NÃO CONCENTRADOS","AMBOS"},80,".T.",.T.}) //MV_PAR05
	aAdd(aPergs, {1, "De Filial     " ,space(TamSX3("C2_FILIAL")[1]),"@!",'.T.','','.T.',TamSX3("C2_FILIAL")[1],.F.}) //MV_PAR06
	aAdd(aPergs, {1, "Até Filial    " ,space(TamSX3("C2_FILIAL")[1]),"@!",'.T.','','.T.',TamSX3("C2_FILIAL")[1],.T.}) //MV_PAR07

	If !parambox(aPergs,"Informe os parametros")
		Return
	EndIf

	oRelatorio  := TReport():New(cFunName, cTitulo,, {|oRelatorio| PrintReport(oRelatorio)}, cDescri)
	oRelatorio:SetCustomText({||CriaCab(oRelatorio)})
	oRelatorio:SetLandscape()
	oRelatorio:SetLineHeight(40)
	oRelatorio:nFontBody := 9
	//oRelatorio:SetColSpace(-2)

	oSection1   := TRSection():New(oRelatorio, cTitulo , {'SB1','SB2','SC2','SG1'},,,,,,.F.,.F.,.F.,,,,,,,,,CLR_SILVER)
	TRCell():New(oSection1,' '       ,''    ,      ,"@!",		 ,/*lPixel*/,  , "LEFT" ,  ,"CENTER"  ,  ,  ,lAutoSize ,  ,  ,_lBold)
	TRCell():New(oSection1,'2'       ,''    ,      ,"@!",		 ,/*lPixel*/,  , "LEFT" ,  ,"CENTER"  ,  ,  ,lAutoSize ,  ,  ,_lBold)

	oSection2   := TRSection():New(oRelatorio, cTitulo , {'SB1','SB2','SC2','SG1'},,,,,,.F.,.F.,.F.)
	TRCell():New(oSection2,'PRODUTOS CONCENTRADOS','' , ,PesqPict("SB1","B1_DESC"),	 85	 ,/*lPixel*/,  , "LEFT"  ,  ,"LEFT"    ,  ,  -4,lAutoSize,  ,  ,_lBold)
	TRCell():New(oSection2,'UND.'                ,'' , ,PesqPict("SB1","B1_UM")   ,	 7	 ,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,  -6,lAutoSize,  ,  ,_lBold)
	TRCell():New(oSection2,'QTD.'                ,'' , ,"@E 9,999,999,999.99999"  ,	 50	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT"   ,  ,  -2,lAutoSize,  ,  ,_lBold)
	TRCell():New(oSection2,'QTD_BATIDA'          ,'' , ,"@E 9,999,999,999.99999" ,	 50	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT"   ,  ,  -2,lAutoSize,  ,  ,_lBold)
	TRCell():New(oSection2,' '              	 ,'' , ,"@!" 				     ,	 50	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT"   ,  ,  -2,lAutoSize,  ,  ,_lBold)
	TRCell():New(oSection2,' '              	 ,'' , ,"@!" 				     ,	 50	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT"   ,  ,  -2,lAutoSize,  ,  ,_lBold)
	TRCell():New(oSection2,' '              	 ,'' , ,"@!" 				     ,	 50	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT"   ,  ,  -2,lAutoSize,  ,  ,_lBold)
	TRCell():New(oSection2,' '              	 ,'' , ,"@!" 				     ,	 50	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT"   ,  ,  -2,lAutoSize,  ,  ,_lBold)
	TRCell():New(oSection2,' '              	 ,'' , ,"@!" 				     ,	 50	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT"   ,  ,  -2,lAutoSize,  ,  ,_lBold)
	TRCell():New(oSection2,' '              	 ,'' , ,"@!" 				     ,	 50	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT"   ,  ,  -2,lAutoSize,  ,  ,_lBold)
	TRCell():New(oSection2,' '              	 ,'' , ,"@!" 				     ,	 55	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT"   ,  ,  -6,lAutoSize,  ,  ,_lBold)

	oSection3   := TRSection():New(oRelatorio, cTitulo , {'SB1','SB2','SC2','SG1'},,,,,,.F.,.F.,.F.)
	TRCell():New(oSection3,'PRODUTOS NÃO CONCENTRADOS','' , ,PesqPict("SB1","B1_DESC"),	 85	 ,/*lPixel*/,  , "LEFT"  ,  ,"LEFT"    ,  ,-4,lAutoSize,  ,,_lBold)
	TRCell():New(oSection3,'UND.'                    ,'' , ,PesqPict("SB1","B1_UM")  ,	 7	 ,/*lPixel*/,  , "CENTER",  ,"CENTER"  ,  ,-6,lAutoSize,  ,,_lBold)
	TRCell():New(oSection3,'QTD.'                    ,'' , ,"@E 9,999,999,999.99999" ,	 50	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT"   ,  ,-2,lAutoSize,  ,,_lBold)
	TRCell():New(oSection3,'5'                       ,'' , ,"@!" 				     ,	 50	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT"   ,  ,-2,lAutoSize,  ,,_lBold)
	TRCell():New(oSection3,'10'              		 ,'' , ,"@!" 				     ,	 50	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT"   ,  ,-2,lAutoSize,  ,,_lBold)
	TRCell():New(oSection3,'15'              		 ,'' , ,"@!" 				     ,	 50	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT"   ,  ,-2,lAutoSize,  ,,_lBold)
	TRCell():New(oSection3,'20'              		 ,'' , ,"@!" 				     ,	 50	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT"   ,  ,-2,lAutoSize,  ,,_lBold)
	TRCell():New(oSection3,'25'              		 ,'' , ,"@!" 				     ,	 50	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT"   ,  ,-2,lAutoSize,  ,,_lBold)
	TRCell():New(oSection3,'30'              		 ,'' , ,"@!" 				     ,	 50	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT"   ,  ,-2,lAutoSize,  ,,_lBold)
	TRCell():New(oSection3,'35'              		 ,'' , ,"@!" 				     ,	 50	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT"   ,  ,-2,lAutoSize,  ,,_lBold)
	TRCell():New(oSection3,'40'              		 ,'' , ,"@!" 				     ,	 55	 ,/*lPixel*/,  , "RIGHT" ,  ,"RIGHT"   ,  ,-6,lAutoSize,  ,,_lBold)
	oRelatorio:printDialog() 

Return

Static Function PrintReport(oRelatorio)
	Local oSection1 := oRelatorio:section(1)
	Local oSection2 := oRelatorio:section(2)
	Local oSection3 := oRelatorio:section(3)
	Local cQuebra	:= chr(13) + Chr(10)
	Local cQuery    := ""
	Local cProd 	:= ""
	Local cOrdem	:= ""
	Local cDesc 	:= ""
	Local nQuant	:= nQuantTotal:=nQuant2:=nQtdcFab:= 0
/*
	cQuery:= " SELECT G1_COD,G1_COMP,B1_DESC,B1_UM,G1_QUANT,C2_NUM,C2_QUANT,C2_UM,C2_PRODUTO,C2_DATPRF,G1_CLASSI,G1_FILIAL,G1_TRT"+cQuebra
	cQuery+= " FROM "+RetSqlName("SB1")+" B1													 		   			   			  "+cQuebra
	cQuery+= " INNER JOIN "+RetSqlName("SG1")+" G1 ON G1_COMP = B1_COD AND G1_FILIAL = B1_FILIAL  		   			   			  "+cQuebra
	cQuery+= " LEFT JOIN "+RetSqlName("SC2")+" C2 ON C2_PRODUTO = G1_COD AND C2_FILIAL = G1_FILIAL 		 		   		   		  "+cQuebra
	cQuery+= " WHERE B1.D_E_L_E_T_ <> '*' 															 		   			   		  "+cQuebra
	cQuery+= " AND G1.D_E_L_E_T_ <> '*' 															 		   			   		  "+cQuebra
	cQuery+= " AND C2.D_E_L_E_T_ <> '*' 															 		   			   		  "+cQuebra
	cQuery+= " AND G1_CLASSI <> ''	 															 		   			   		      "+cQuebra
	cQuery+= " AND G1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'   								 		   			   		  "+cQuebra
	cQuery+= " AND C2_DATPRF BETWEEN '"+dToS(MV_PAR03)+"' AND '"+dToS(MV_PAR04)+"'   								 	   		  "+cQuebra
	cQuery+= " AND C2_FILIAL BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"'				   								 	   		  "+cQuebra
	If MV_PAR05 <> 'AMBOS'			   
		If MV_PAR05 == 'CONCENTRADOS'			   
			cQuery+= " AND G1_CLASSI = '0023'    									 			 	   			  		    	  "+cQuebra
		Else			   
			cQuery+= " AND G1_CLASSI = '0024'     									 			 	   			   		   		  "+cQuebra
		EndIf
	EndIf
	cQuery+= " GROUP BY C2_NUM,G1_COMP,C2_QUANT,C2_UM,C2_PRODUTO,C2_DATPRF,G1_CLASSI,G1_COD,B1_DESC,B1_UM,G1_QUANT,G1_FILIAL,G1_TRT"+cQuebra
	cQuery+= " ORDER BY C2_NUM, G1_CLASSI ,G1_TRT				  													 		       "+cQuebra*/
/*
	cQuery+= " SELECT G1_COD,G1_COMP,B1_DESC,B1_UM,G1_QUANT,C2_NUM,C2_QUANT,C2_UM,C2_PRODUTO,C2_DATPRF,G1_CLASSI,G1_FILIAL	"+CRLF
	cQuery+= " FROM "+RetSqlName("SB1")+" B1											 		   			   			  	"+CRLF
	cQuery+= " INNER JOIN "+RetSqlName("SG1")+" G1 ON G1_COMP = B1_COD AND G1_FILIAL = B1_FILIAL AND G1.D_E_L_E_T_ <> '*' 	"+CRLF
	cQuery+= " AND G1_CLASSI <> '' AND G1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  			   			  	"+CRLF
	cQuery+= " LEFT JOIN "+RetSqlName("SC2")+" C2 ON C2_PRODUTO = G1_COD AND C2_FILIAL = G1_FILIAL AND C2.D_E_L_E_T_ <> '*' 	"+CRLF
	cQuery+= " AND C2_DATPRF BETWEEN '"+dToS(MV_PAR03)+"' AND '"+dToS(MV_PAR04)+"' AND C2_FILIAL BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"'"	+CRLF	   		   		  
	cQuery+= " WHERE B1.D_E_L_E_T_ <> '*'			   								 	   		  	"+CRLF
	If MV_PAR05 <> 'AMBOS'			   
		If MV_PAR05 == 'CONCENTRADOS'			   
			cQuery+= " AND G1_CLASSI = '0023'    									 			 	   			  		    	  "+cQuebra
		Else			   
			cQuery+= " AND G1_CLASSI = '0024'     									 			 	   			   		   		  "+cQuebra
		EndIf
	EndIf
	cQuery+= " GROUP BY C2_NUM,G1_COMP,C2_QUANT,C2_UM,C2_PRODUTO,C2_DATPRF,G1_CLASSI,G1_COD,B1_DESC,B1_UM,G1_QUANT,G1_FILIAL,G1_TRT	"+CRLF
	cQuery+= " ORDER BY C2_NUM, G1_CLASSI	"+CRLF
	MpSysOpenQuery(cQuery,"RelCFab")*/
 	cQuery+= " SELECT G1_COD,G1_COMP,B1_DESC,B1_UM,G1_QUANT,C2_NUM,C2_QUANT,C2_UM,G1_CLASSI,G1_FILIAL	"+CRLF
	cQuery+= " FROM "+RetSqlName("SB1")+" B1											 		   			   			  	"+CRLF
	cQuery+= " INNER JOIN "+RetSqlName("SG1")+" G1 ON G1_COMP = B1_COD AND G1_FILIAL = B1_FILIAL AND G1.D_E_L_E_T_ <> '*' 	"+CRLF
	cQuery+= " AND G1_CLASSI <> '' AND G1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  			   			  	"+CRLF
	cQuery+= " LEFT JOIN "+RetSqlName("SC2")+" C2 ON C2_PRODUTO = G1_COD AND C2_FILIAL = G1_FILIAL AND C2.D_E_L_E_T_ <> '*' 	"+CRLF
	cQuery+= " AND C2_DATPRF BETWEEN '"+dToS(MV_PAR03)+"' AND '"+dToS(MV_PAR04)+"' AND C2_FILIAL BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"'"	+CRLF	   		   		  
	cQuery+= " WHERE B1.D_E_L_E_T_ <> '*'			   								 	   		  	"+CRLF
	cQuery+= " AND C2_QUANT > 0			   								 	   		  	"+CRLF
	If MV_PAR05 <> 'AMBOS'			   
		If MV_PAR05 == 'CONCENTRADOS'			   
			cQuery+= " AND G1_CLASSI = '0023'    									 			 	   			  		    	  "+cQuebra
		Else			   
			cQuery+= " AND G1_CLASSI = '0024'     									 			 	   			   		   		  "+cQuebra
		EndIf
	EndIf
	cQuery+= " GROUP BY G1_COD,C2_NUM,G1_COMP,C2_QUANT,C2_UM,B1_DESC,B1_UM,G1_QUANT,G1_CLASSI, G1_FILIAL	"+CRLF
	cQuery+= " ORDER BY C2_NUM,G1_COD, G1_CLASSI	"+CRLF
	MpSysOpenQuery(cQuery,"RelCFab")
 
	If RelCFab->(Eof())
		MsgInfo("Nenhum dado foi localizado com os parâmetros informados.","Atenção!")
		Return .F.
	Else 
		While RelCFab->(!Eof())
			nQtdcFab++
			RelCFab->(DbSkip())
		End
	EndIf
	
	oSection1:SetHeaderSection(.F.)
	oSection1:SetHeaderPage(.F.)
	oSection2:SetHeaderSection(.T.)
	oSection2:SetHeaderPage(.F.)
	oSection3:SetHeaderSection(.T.)
	oSection3:SetHeaderPage(.F.)

	oRelatorio:SetMeter(nQtdcFab)
	RelCFab->(DBGoTop())

	While RelCFab->(!Eof())

		If oRelatorio:Cancel()
			Exit
		EndIf
		cProd 	 := AllTrim(RelCFab->G1_COD)
		cOrdem	 := AllTrim(RelCFab->C2_NUM)
		cDesc 	 := AllTrim(Posicione("SB1", 1,RelCFab->G1_FILIAL+cProd, "B1_DESC"))
		nQtdPrev := RelCFab->C2_QUANT
		If nQtdPrev > 1000
			nQtdPrev := nQtdPrev / 1000
		Endif
		oRelatorio:IncMeter()
		oSection1:Init()
		oSection1:Cell(''):SetValue('FORMULA : '+cProd+' - '+cDesc+" - "+RelCFab->C2_UM)
		oSection1:Cell('2'):SetValue('QTD. PREVISTA : '+Transform(nQtdPrev, "@E 999,999.99"))
		oSection1:PrintLine()
		oRelatorio:ThinLine() //-- Desenha uma linha simples
		oRelatorio:SkipLine() //-- Salta Linha

		nQuant:=nQuantTotal:=nQuant2:= 0
		nCount:= 0
		While RelCFab->(!Eof()) .And. AllTrim(RelCFab->(G1_COD))+AllTrim(RelCFab->(C2_NUM)) == (cProd+cOrdem)
			cClassi := RelCFab->G1_CLASSI

			While RelCFab->(!Eof()) .And. RelCFab->G1_CLASSI == cClassi .And. cClassi == '0023';
			.And. AllTrim(RelCFab->(G1_COD))+AllTrim(RelCFab->(C2_NUM)) == (cProd+cOrdem)
				oSection2:Init()
				oRelatorio:IncMeter()
				oSection2:Cell('PRODUTOS CONCENTRADOS'):SetValue(AllTrim(RelCFab->G1_COMP)+' - '+AllTrim(RelCFab->B1_DESC))
				oSection2:Cell('UND.'):SetValue(RelCFab->B1_UM)
				oSection2:Cell('QTD.'):SetValue(RelCFab->G1_QUANT)
				oSection2:Cell('QTD_BATIDA'):SetValue((RelCFab->G1_QUANT*nQtdPrev))
				oSection2:Cell(' '):SetValue()
				oSection2:Cell(' '):SetValue()
				oSection2:Cell(' '):SetValue()
				oSection2:Cell(' '):SetValue()
				oSection2:Cell(' '):SetValue()
				oSection2:Cell(' '):SetValue()
				oSection2:Cell(' '):SetValue()
				oSection2:Printline()
				nQuant+=RelCFab->G1_QUANT
				nQuantTotal+=(RelCFab->G1_QUANT*nQtdPrev)
				nCount++
				RelCFab->(DbSkip())
			End
			If cClassi == '0023'
				oRelatorio:ThinLine() //-- Desenha uma linha simples
				oSection2:Cell('PRODUTOS CONCENTRADOS'):SetAlign("RIGHT")
				oSection2:Cell('PRODUTOS CONCENTRADOS'):SetValue('TOTAL CONCENTRADO : ')
				oSection2:Cell('UND.'):SetValue()
				oSection2:Cell('QTD.'):SetValue(nQuant)
				oSection2:Cell('QTD_BATIDA'):SetValue(nQuantTotal)
				oSection2:Cell(' '):SetValue()
				oSection2:Cell(' '):SetValue()
				oSection2:Cell(' '):SetValue()
				oSection2:Cell(' '):SetValue()
				oSection2:Cell(' '):SetValue()
				oSection2:Cell(' '):SetValue()
				oSection2:Cell(' '):SetValue()
				oSection2:Printline()
				oSection2:Cell('PRODUTOS CONCENTRADOS'):SetAlign("LEFT")
				oRelatorio:ThinLine() //-- Desenha uma linha simples
				oRelatorio:SkipLine(2) //-- Salta Linha
			EndIf

			cClassi2:= RelCFab->G1_CLASSI

			While RelCFab->(!Eof()) .And. RelCFab->G1_CLASSI == cClassi2 .And. cClassi2 == '0024';
			.And. AllTrim(RelCFab->(G1_COD))+AllTrim(RelCFab->(C2_NUM)) == (cProd+cOrdem)
				oSection3:Init()
				oRelatorio:IncMeter()
				oSection3:Cell('PRODUTOS NÃO CONCENTRADOS'):SetValue(AllTrim(RelCFab->G1_COMP)+' - '+AllTrim(RelCFab->B1_DESC))
				oSection3:Cell('UND.'):SetValue(RelCFab->B1_UM)
				oSection3:Cell('QTD.'):SetValue(RelCFab->G1_QUANT)
				oSection3:Cell('5'):SetValue("[ ][ ][ ][ ][ ]")
				oSection3:Cell('10'):SetValue("[ ][ ][ ][ ][ ]")
				oSection3:Cell('15'):SetValue("[ ][ ][ ][ ][ ]")
				oSection3:Cell('20'):SetValue("[ ][ ][ ][ ][ ]")
				oSection3:Cell('25'):SetValue("[ ][ ][ ][ ][ ]")
				oSection3:Cell('30'):SetValue("[ ][ ][ ][ ][ ]")
				oSection3:Cell('35'):SetValue("[ ][ ][ ][ ][ ]")
				oSection3:Cell('40'):SetValue("[ ][ ][ ][ ][ ]")
				oSection3:Printline()
				nQuant2+=RelCFab->G1_QUANT
				nCount++
				RelCFab->(DbSkip())
			End
			If cClassi == '0024'
				oSection3:Cell('PRODUTOS NÃO CONCENTRADOS'):SetValue('RESUMO PRODUTOS CONCENTRADOS')
				oSection3:Cell('UND.'):SetValue()
				oSection3:Cell('QTD.'):SetValue(nQuant)
				oSection3:Cell('5'):SetValue("[ ][ ][ ][ ][ ]")
				oSection3:Cell('10'):SetValue("[ ][ ][ ][ ][ ]")
				oSection3:Cell('15'):SetValue("[ ][ ][ ][ ][ ]")
				oSection3:Cell('20'):SetValue("[ ][ ][ ][ ][ ]")
				oSection3:Cell('25'):SetValue("[ ][ ][ ][ ][ ]")
				oSection3:Cell('30'):SetValue("[ ][ ][ ][ ][ ]")
				oSection3:Cell('35'):SetValue("[ ][ ][ ][ ][ ]")
				oSection3:Cell('40'):SetValue("[ ][ ][ ][ ][ ]")
				oSection3:Printline()
				oRelatorio:ThinLine() //-- Desenha uma linha simples
				//oRelatorio:SkipLine() //-- Salta Linha
			EndIf
		End
		If nQuant2 == 0
			oSection3:SetHeaderSection(.F.)
		EndIf
		oSection3:Init()
		oSection3:Cell('PRODUTOS NÃO CONCENTRADOS'):SetAlign("RIGHT")
		oSection3:Cell('PRODUTOS NÃO CONCENTRADOS'):SetValue('TOTAL GERAL FORMULA : ')
		oSection3:Cell('UND.'):SetValue()
		oSection3:Cell('QTD.'):SetValue(nQuant2+nQuant)
		oSection3:Cell('5'):SetValue()
		oSection3:Cell('10'):SetValue()
		oSection3:Cell('15'):SetValue()
		oSection3:Cell('20'):SetValue()
		oSection3:Cell('25'):SetValue()
		oSection3:Cell('30'):SetValue()
		oSection3:Cell('35'):SetValue()
		oSection3:Cell('40'):SetValue()
		oSection3:Printline()
		oRelatorio:ThinLine() //-- Desenha uma linha simples

		oSection3:Cell('QTD.'):SetPicture("@E 9,999,999,999")	
		oSection3:Cell('PRODUTOS NÃO CONCENTRADOS'):SetValue('TOTAL ITENS FORMULA : ')
		oSection3:Cell('UND.'):SetValue()
		oSection3:Cell('QTD.'):SetValue(nCount)
		oSection3:Cell('5'):SetValue()
		oSection3:Cell('10'):SetValue()
		oSection3:Cell('15'):SetValue()
		oSection3:Cell('20'):SetValue()
		oSection3:Cell('25'):SetValue()
		oSection3:Cell('30'):SetValue()
		oSection3:Cell('35'):SetValue()
		oSection3:Cell('40'):SetValue()
		oSection3:Printline()
		oSection1:Finish()
		oSection2:Finish()
		oSection3:Finish()
		oRelatorio:EndPage()    // Finaliza a pagina
		If RelCFab->(!Eof())
			oRelatorio:StartPage()  // Inicia uma nova pagina
		EndIf
		oRelatorio:IncMeter()
		oSection3:Cell('QTD.'):SetPicture("@E 9,999,999,999.99999")	
		oSection3:Cell('PRODUTOS NÃO CONCENTRADOS'):SetAlign("LEFT")
	End

	oSection1:Finish()
	oSection2:Finish()
	oSection3:Finish()
	RelCFab->(DbCloseArea())

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
			  , Padc(Upper("CONTROLE DE FABRICAÇÃO - " + FWFilialName(_cEmp)),132);
	          , Padc("",132);          
	          , Padc(UPPER('Período de '+_DataDe+' até '+_DataAte),132);
	          , RptHora + " " + time() ;
			  + cChar + "         " + RptEmiss + " " + Dtoc(dDataBase)}
			  
	RestArea( aArea )

Return aCabec     
