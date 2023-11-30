#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#include "TopConn.ch"
#include "COLORS.ch"

#define CLR_SILVER rgb(192,192,192)
#define CLR_LIGHTGRAY rgb(220,220,220)

*******************************************************************************
// Função : RELINVENT - Realiza a Montagem do Relatório	Treport			      |
// Modulo : Estoque e Custo                                                   |
// Fonte  : RelInvent.prw                                                     |
// ---------+-------------------+---------------------------------------------+
// Data     | Autor             | Descricao                                   |
// ---------+-------------------+---------------------------------------------+
// 25/11/22 | Rivaldo Júnior    | Relatório			                          |
*******************************************************************************

User Function RELINVENT()
	Private _DataDe		:= ""
	Private _DataAte	:= ""
	PRIVATE cTitulo     := ""
	PRIVATE cDescri     := ""
	PRIVATE cFunName    := FunName()
	PRIVATE oRelatorio
	PRIVATE aPergs      := {}
	Private _lBold    	:= .F. //Controle de IMpressÃ£o em NEgrito
	Private lAutoSize 	:= .T.
	Private lLineBreak 	:= .F.
	Private nTotal 		:=  0
	Private nTot		:=  0

	aAdd(aPergs, {1, "Codigo de"        ,space(TamSX3("B1_COD")[1]) , "",  ".T."  , "SB1", ".T."   , 40, .F.}) //MV_Par01
	aAdd(aPergs, {1, "Codigo  até  "    ,space(TamSX3("B1_COD")[1]) , "",  ".T."  , "SB1", ".T."   , 40, .T.}) //MV_Par02
	aAdd(aPergs, {2, "Selecione :"		, "" , {"0023=Macro","0024=Micro",""}  , 60 ,".T.",.T.}) //MV_PAR03
	aAdd(aPergs, {1, "Data De"          ,Date()   , "", ".T.", "", ".T.", 80 , .F.}) //MV_PAR04
	aAdd(aPergs, {1, "Data Até "        ,Date()   , "", ".T.", "", ".T.", 80 , .T.}) //MV_PAR05
	aAdd(aPergs, {2, "Com movimento "	, "N" , {"S=Sim","N=Nao",""}  , 60 ,".T.",.T.}) //MV_PAR06
	aAdd(aPergs, {2, "Diferente de 0"	    , "S" , {"S=Sim","N=Nao",""}  , 60 ,".T.",.T.}) //MV_PAR07

	If !parambox(aPergs,"Informe os parametros")
		Return
	EndIf

	oRelatorio  := TReport():New(cFunName, ,, {|oRelatorio| PrintReport(oRelatorio)}, cDescri)
	oRelatorio:SetCustomText({||CriaCab(oRelatorio)})
	//oRelatorio:SetLineHeight(40)
	oRelatorio:SetLandScape(.T.)
	oRelatorio:SetRightAlignPrinter(.F.)
	//oRelatorio:SetLeftMargin(-5)
	oRelatorio:cFontBody := 'Courier PS Cyrillic Bold'
	oRelatorio:nFontBody := 8
	//oRelatorio:SetColSpace(1)

	oSection1   := TRSection():New(oRelatorio,  , {'SB1','SB9','SB2','SD1','SD2'})
	TRCell():New(oSection1,'PRODUTO'            ,'', ,PesqPict("SB1", "B1_COD")  ,93 ,/*lPixel*/, ,"LEFT" ,lLineBreak,"LEFT" , ,-3,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'UND'                ,'', ,PesqPict("SB1", "B1_UM")   ,10 ,/*lPixel*/, ,"LEFT" ,lLineBreak,"LEFT" , ,-3,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'TIPO'               ,'', ,PesqPict("SB1","B1_TIPO")  ,15 ,/*lPixel*/, ,"RIGHT",lLineBreak,"RIGHT", ,-3,lAutoSize, , ,_lBold)
	//TRCell():New(oSection1,'Classificação'    ,'', ,PesqPict("SB1","B1_CLASSI"),30 ,/*lPixel*/, ,"RIGHT",lLineBreak,"RIGHT", ,-3,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'ESTOQUE INICIAL'    ,'', ,"@E 9,999,999.99"      ,35 ,/*lPixel*/, ,"RIGHT",lLineBreak,"RIGHT", ,-3,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'CUSTO MÉDIO'        ,'', ,"@E 9,999,999.99"      ,35 ,/*lPixel*/, ,"RIGHT",lLineBreak,"RIGHT", ,-3,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'ENTRADAS'           ,'', ,"@E 9,999,999.99"      ,35 ,/*lPixel*/, ,"RIGHT",lLineBreak,"RIGHT", ,-3,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'CONSUMO'            ,'', ,"@E 9,999,999.99"      ,35 ,/*lPixel*/, ,"RIGHT",lLineBreak,"RIGHT", ,-3,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'ESTOQUE FINAL'      ,'', ,"@E 9,999,999.99"      ,35 ,/*lPixel*/, ,"RIGHT",lLineBreak,"RIGHT", ,-3,lAutoSize, , ,_lBold)
	TRCell():New(oSection1,'PREVISÃO EST. DIAS'	,'', ,"@E 9,999,999.99"      ,75 ,/*lPixel*/, ,"RIGHT",lLineBreak,"RIGHT", ,-3,lAutoSize, , ,_lBold)

	oRelatorio:printDialog()

Return


	*******************************************************************************
// Função : PrintReport - Realiza a Busca dos dados e Definição 		      |
// Modulo : Estoque e Custo                                                   |
// Fonte  : RelInvent.prw                                                     |
// ---------+-------------------+---------------------------------------------+
// Data     | Autor             | Descricao                                   |
// ---------+-------------------+---------------------------------------------+
// 25/11/22 | Rivaldo Júnior    | Busca dos dados	                          |
	*******************************************************************************

Static Function PrintReport(oRelatorio)
	Local oSection1 := oRelatorio:section(1)
	Local cClassi 	:= "" //Classificação do Produto
	Local QERY	 	:= ""
	Local nSemClassi:= 0
	Local cQuebra	:= chr(13) + Chr(10)
	Local cEntradas := ""
	Local cSaidas   := ""
	Local aSaldo	:= {}
	Local aCusto	:= {}

	QERY += " select b1_filial, B1_cod, b1_desc, b1_Um, b1_classi, b1_locpad , b1_tipo,								 "+cQuebra

	QERY += "	( SELECT Sum(d1_quant) custoS FROM "+RetSqlName('SB1')+" b1											 "+cQuebra
	QERY += "			LEFT JOIN "+RetSqlName('SD1')+" sd1 ON b1_cod = d1_cod AND b1_filial = d1_filial			 "+cQuebra
	QERY += "			LEFT JOIN "+RetSqlName('SF4')+" sf4 ON d1_tes = f4_codigo 									 "+cQuebra
	QERY += "		WHERE B1.b1_cod = sb1.b1_cod																	 "+cQuebra
	QERY += "		AND F4_Estoque = 'S'																			 "+cQuebra
	QERY += "		AND F4_filial = '"+xFilial("SF4")+"'															 "+cQuebra
	QERY += "		AND SD1.D_E_L_E_T_='' 																			 "+cQuebra
	QERY += "		and D1_DTDIGIT between '"+DtoS(MV_PAR04)+"' and '"+DtoS(MV_PAR05)+"'    						 "+cQuebra
	QERY += "		AND B1.b1_filial = sb1.b1_filial ) ENTRADA_D1,													 "+cQuebra

	QERY += "	( SELECT Sum(d3_quant) custoS FROM "+RetSqlName('SB1')+" b1								 			 "+cQuebra
	QERY += "			LEFT JOIN "+RetSqlName('SD3')+" sd3 ON b1_cod = d3_cod AND b1_filial = d3_filial			 "+cQuebra
	QERY += "		WHERE  d3_cf Like '%DE%'																		 "+cQuebra
	QERY += "		AND B1.b1_cod = sb1.b1_cod 																		 "+cQuebra
	QERY += "		AND SD3.D_E_L_E_T_='' 																			 "+cQuebra
	QERY += "		and D3_EMISSAO between '"+DtoS(MV_PAR04)+"' and '"+DtoS(MV_PAR05)+"'    						 "+cQuebra
	QERY += "		AND B1.b1_filial = sb1.b1_filial ) ENTRADA_D3,													 "+cQuebra

	QERY += "	( SELECT Sum(d2_quant) custoS FROM "+RetSqlName('SB1')+" b1											 "+cQuebra
	QERY += "			LEFT JOIN "+RetSqlName('SD2')+" sd2 ON b1_cod = d2_cod AND b1_filial = d2_filial			 "+cQuebra
	QERY += "			LEFT JOIN "+RetSqlName('SF4')+" sf4 ON d2_tes = f4_codigo 									 "+cQuebra
	QERY += "		WHERE B1.b1_cod = sb1.b1_cod																	 "+cQuebra
	QERY += "		AND F4_Estoque = 'S'																			 "+cQuebra
	QERY += "		AND F4_filial = '"+xFilial("SF4")+"'															 "+cQuebra
	QERY += "		AND SD2.D_E_L_E_T_='' 																			 "+cQuebra
	QERY += "		and D2_EMISSAO between '"+DtoS(MV_PAR04)+"' and '"+DtoS(MV_PAR05)+"'    						 "+cQuebra
	QERY += "		AND B1.b1_filial = sb1.b1_filial ) SAIDA_D2,													 "+cQuebra

	QERY += "	( SELECT Sum(d3_quant) custoS FROM "+RetSqlName('SB1')+" b1								 			 "+cQuebra
	QERY += "			LEFT JOIN "+RetSqlName('SD3')+" sd3 ON b1_cod = d3_cod AND b1_filial = d3_filial			 "+cQuebra
	QERY += "		WHERE  d3_cf Like '%RE%'																		 "+cQuebra
	QERY += "		AND B1.b1_cod = sb1.b1_cod 																		 "+cQuebra
	QERY += "		AND SD3.D_E_L_E_T_='' 																			 "+cQuebra
	QERY += "		and D3_EMISSAO between '"+DtoS(MV_PAR04)+"' and '"+DtoS(MV_PAR05)+"'    						 "+cQuebra
	QERY += "		AND B1.b1_filial = sb1.b1_filial ) SAIDA_D3,													 "+cQuebra

	QERY += " (select sum(b2_cm1) custoM from "+RetSqlName('SB2')+" sb2												 "+cQuebra
	QERY += "    where b2_cod = sb1.b1_cod 																			 "+cQuebra
	QERY += " 	 and b2_filial = sb1.b1_filial 																		 "+cQuebra
	QERY += " 	 AND SB2.D_E_L_E_T_='') PRC_MEDIO																	 "+cQuebra

	QERY += "From "+RetSqlName('SB1')+" sb1 																		 "+cQuebra

	QERY += "WHERE SB1.D_E_L_E_T_=''																				 "+cQuebra
	QERY += "AND B1_CLASSI <> ' '	       																			 "+cQuebra

	If !Empty(mv_par03)
		QERY += " 		  AND B1_CLASSI LIKE '"+cvaltochar(mv_par03)+"%'											 "+cQuebra
	EndIf
	QERY += "AND b1_cod between  '"+MV_Par01+"' and '"+MV_Par02+"' 													 "+cQuebra
	QERY += "Group by b1_classi, b1_filial, b1_cod, b1_desc, b1_Um ,b1_tipo, b1_locpad		      				     "+cQuebra
	QERY += "Order by b1_classi																						 "+cQuebra
	TCQuery QERY NEW ALIAS "QERY"

	If QERY->(Eof())
		MsgInfo("Nenhum dado foi localizado com os parâmetros informados.","Atenção!")
		Return .F.
	EndIf

	dbselectarea("sb2")
	sb2->(dbsetorder(1))

	oSection1:Init()
	oSection1:Cell('PRODUTO'):nClrBack := CLR_SILVER
	oSection1:Cell('UND'):nClrBack := CLR_SILVER
	oSection1:Cell('TIPO'):nClrBack := CLR_SILVER
	oSection1:Cell('ESTOQUE INICIAL'):nClrBack := CLR_SILVER
	oSection1:Cell('CUSTO MÉDIO'):nClrBack := CLR_SILVER
	oSection1:Cell('ENTRADAS'):nClrBack := CLR_SILVER
	oSection1:Cell('CONSUMO'):nClrBack := CLR_SILVER
	oSection1:Cell('ESTOQUE FINAL'):nClrBack := CLR_SILVER
	oSection1:Cell('PREVISÃO EST. DIAS'):nClrBack := CLR_SILVER
	oRelatorio:SkipLine()
	oSection1:PrintLine()

	//oSection2:SetHeaderSection(.F.)
	//oSection2:SetHeaderPage(.F.)
	While !QERY->(Eof()) //.and. QERY->b1_classi = '0023 - macro'
		If oRelatorio:Cancel()
			Exit
		EndIf
		nTot := 0
		cClassi := QERY->b1_classi
		//oRelatorio:IncMeter()
		//oRelatorio:SkipLine() //-- Salta Linha
		oSection1:Init()
		oSection1:Cell('PRODUTO'):nClrBack := CLR_SILVER
		oSection1:Cell('UND'):nClrBack := CLR_SILVER
		oSection1:Cell('TIPO'):nClrBack := CLR_SILVER
		oSection1:Cell('ESTOQUE INICIAL'):nClrBack := CLR_SILVER
		oSection1:Cell('CUSTO MÉDIO'):nClrBack := CLR_SILVER
		oSection1:Cell('ENTRADAS'):nClrBack := CLR_SILVER
		oSection1:Cell('CONSUMO'):nClrBack := CLR_SILVER
		oSection1:Cell('ESTOQUE FINAL'):nClrBack := CLR_SILVER
		oSection1:Cell('PREVISÃO EST. DIAS'):nClrBack := CLR_SILVER
		If !Empty(cClassi)
			oSection1:Cell('PRODUTO'):SetValue("CLASSIFICAÇÃO: "+QERY->b1_classi)
			oSection1:Cell('UND'):SetValue()
			oSection1:Cell('TIPO'):SetValue()
			//oSection1:Cell('Classificação'):SetValue()
			oSection1:Cell('ESTOQUE INICIAL'):SetAlign("RIGHT")
			oSection1:Cell('CUSTO MÉDIO'):SetAlign("RIGHT")
			oSection1:Cell('ENTRADAS'):SetAlign("RIGHT")
			oSection1:Cell('CONSUMO'):SetAlign("RIGHT")
			oSection1:Cell('ESTOQUE FINAL'):SetAlign("RIGHT")
			oSection1:Cell('PREVISÃO EST. DIAS'):SetAlign("RIGHT")
			oSection1:Cell('ESTOQUE INICIAL'):SetValue()
			oSection1:Cell('CUSTO MÉDIO'):SetValue()
			oSection1:Cell('ENTRADAS'):SetValue()
			oSection1:Cell('CONSUMO'):SetValue()
			oSection1:Cell('ESTOQUE FINAL'):SetValue()
			oSection1:Cell('PREVISÃO EST. DIAS'):SetValue()
			oSection1:PrintLine()
		EndIf
		//oRelatorio:SkipLine() //-- Salta Linha
		oRelatorio:OnPageBreak( {|| ImpCabec( oRelatorio, oSection1 ,cClassi) } )
		oRelatorio:SkipLine() //-- Salta Linha

		While QERY->b1_classi == cClassi .and. !QERY->(EoF())
			If !Empty(cClassi)
				SB2->(DBSEEK(XFILIAL("SB2")+QERY->(b1_cod+b1_locpad)))
				//aSaldo := xCalcEst(SB2->B2_COD,SB2->B2_LOCAL,MV_PAR04)
				cEntradas := (QERY->ENTRADA_D1+QERY->ENTRADA_D3)
				cSaidas  := (QERY->SAIDA_D2+QERY->SAIDA_D3)
				aCusto := CalcEst(PADR(SB2->B2_COD,TamSX3("B2_COD")[1]),SB2->B2_LOCAL,MV_PAR05+1)
				oRelatorio:IncMeter()
				If MV_PAR06 == 'S' .And. (cEntradas+cSaidas) > 0
					aSaldo := CalcEst(PADR(SB2->B2_COD,TamSX3("B2_COD")[1]),SB2->B2_LOCAL,MV_PAR04)
					nTot++
					oSection1:Init()

					oSection1:Cell('PRODUTO'):lBold := .F.
					oSection1:Cell('ESTOQUE INICIAL'):lBold := .T.
					oSection1:Cell('ESTOQUE FINAL'):lBold := .T.

					oRelatorio:SetMsgPrint( "Calculando ... ")

					oSection1:Cell('PRODUTO'):nClrBack := CLR_WHITE
					oSection1:Cell('UND'):nClrBack := CLR_WHITE
					oSection1:Cell('TIPO'):nClrBack := CLR_WHITE
					oSection1:Cell('ESTOQUE INICIAL'):nClrBack := CLR_WHITE
					oSection1:Cell('CUSTO MÉDIO'):nClrBack := CLR_WHITE
					oSection1:Cell('ENTRADAS'):nClrBack := CLR_WHITE
					oSection1:Cell('CONSUMO'):nClrBack := CLR_WHITE
					oSection1:Cell('ESTOQUE FINAL'):nClrBack := CLR_WHITE
					oSection1:Cell('PREVISÃO EST. DIAS'):nClrBack := CLR_WHITE

					oSection1:Cell('PRODUTO'):nClrFore := CLR_BLACK
					oSection1:Cell('UND'):nClrFore := CLR_BLACK
					oSection1:Cell('TIPO'):nClrFore := CLR_BLACK
					oSection1:Cell('ESTOQUE INICIAL'):nClrFore := CLR_BLACK
					oSection1:Cell('CUSTO MÉDIO'):nClrFore := CLR_BLACK
					oSection1:Cell('ENTRADAS'):nClrFore := CLR_BLACK
					oSection1:Cell('CONSUMO'):nClrFore := CLR_BLACK
					oSection1:Cell('ESTOQUE FINAL'):nClrFore := CLR_BLACK
					oSection1:Cell('PREVISÃO EST. DIAS'):nClrFore := CLR_BLACK

					oSection1:Cell('PRODUTO'):SetValue(AllTrim(QERY->B1_COD)+" - "+AllTrim(QERY->B1_DESC))
					oSection1:Cell('UND'):SetValue(QERY->B1_UM)
					oSection1:Cell('TIPO'):SetValue(QERY->B1_TIPO)
					//oSection1:Cell('Classificação'):SetValue(QERY->B1_CLASSI)
					oSection1:Cell('ESTOQUE INICIAL'):SetAlign("RIGHT")
					oSection1:Cell('CUSTO MÉDIO'):SetAlign("RIGHT")
					oSection1:Cell('ENTRADAS'):SetAlign("RIGHT")
					oSection1:Cell('CONSUMO'):SetAlign("RIGHT")
					oSection1:Cell('ESTOQUE FINAL'):SetAlign("RIGHT")
					oSection1:Cell('PREVISÃO EST. DIAS'):SetAlign("RIGHT")
					oSection1:Cell('ESTOQUE INICIAL'):SetValue(aSaldo[1])
					oSection1:Cell('CUSTO MÉDIO'):SetValue(round(aCusto[2]/aCusto[1],4))
					oSection1:Cell('ENTRADAS'):SetValue(cEntradas)
					oSection1:Cell('CONSUMO'):SetValue(cSaidas)
					oSection1:Cell('ESTOQUE FINAL'):SetValue((aSaldo[1]+cEntradas)-(cSaidas))
					oSection1:Cell('PREVISÃO EST. DIAS'):SetValue((((aSaldo[1]+(cEntradas))-(cSaidas))/(cSaidas))*(DateDiffDay(mv_par04,mv_par05)+1))
					oSection1:Printline()
				ElseIf MV_PAR06 == 'N'
					aSaldo := CalcEst(PADR(SB2->B2_COD,TamSX3("B2_COD")[1]),SB2->B2_LOCAL,MV_PAR04)
					If MV_PAR07 == 'S' .And. ((aSaldo[1]+cEntradas)-(cSaidas)) <> 0
						nTot++
						oSection1:Init()

						oSection1:Cell('PRODUTO'):lBold := .F.
						oSection1:Cell('ESTOQUE INICIAL'):lBold := .T.
						oSection1:Cell('ESTOQUE FINAL'):lBold := .T.

						oRelatorio:SetMsgPrint( "Calculando ... ")

						oSection1:Cell('PRODUTO'):nClrBack := CLR_WHITE
						oSection1:Cell('UND'):nClrBack := CLR_WHITE
						oSection1:Cell('TIPO'):nClrBack := CLR_WHITE
						oSection1:Cell('ESTOQUE INICIAL'):nClrBack := CLR_WHITE
						oSection1:Cell('CUSTO MÉDIO'):nClrBack := CLR_WHITE
						oSection1:Cell('ENTRADAS'):nClrBack := CLR_WHITE
						oSection1:Cell('CONSUMO'):nClrBack := CLR_WHITE
						oSection1:Cell('ESTOQUE FINAL'):nClrBack := CLR_WHITE
						oSection1:Cell('PREVISÃO EST. DIAS'):nClrBack := CLR_WHITE

						oSection1:Cell('PRODUTO'):nClrFore := CLR_BLACK
						oSection1:Cell('UND'):nClrFore := CLR_BLACK
						oSection1:Cell('TIPO'):nClrFore := CLR_BLACK
						oSection1:Cell('ESTOQUE INICIAL'):nClrFore := CLR_BLACK
						oSection1:Cell('CUSTO MÉDIO'):nClrFore := CLR_BLACK
						oSection1:Cell('ENTRADAS'):nClrFore := CLR_BLACK
						oSection1:Cell('CONSUMO'):nClrFore := CLR_BLACK
						oSection1:Cell('ESTOQUE FINAL'):nClrFore := CLR_BLACK
						oSection1:Cell('PREVISÃO EST. DIAS'):nClrFore := CLR_BLACK

						oSection1:Cell('PRODUTO'):SetValue(AllTrim(QERY->B1_COD)+" - "+AllTrim(QERY->B1_DESC))
						oSection1:Cell('UND'):SetValue(QERY->B1_UM)
						oSection1:Cell('TIPO'):SetValue(QERY->B1_TIPO)
						//oSection1:Cell('Classificação'):SetValue(QERY->B1_CLASSI)
						oSection1:Cell('ESTOQUE INICIAL'):SetAlign("RIGHT")
						oSection1:Cell('CUSTO MÉDIO'):SetAlign("RIGHT")
						oSection1:Cell('ENTRADAS'):SetAlign("RIGHT")
						oSection1:Cell('CONSUMO'):SetAlign("RIGHT")
						oSection1:Cell('ESTOQUE FINAL'):SetAlign("RIGHT")
						oSection1:Cell('PREVISÃO EST. DIAS'):SetAlign("RIGHT")
						oSection1:Cell('ESTOQUE INICIAL'):SetValue(aSaldo[1])
						oSection1:Cell('CUSTO MÉDIO'):SetValue(round(aCusto[2]/aCusto[1],4))
						oSection1:Cell('ENTRADAS'):SetValue(cEntradas)
						oSection1:Cell('CONSUMO'):SetValue(cSaidas)
						oSection1:Cell('ESTOQUE FINAL'):SetValue((aSaldo[1]+cEntradas)-(cSaidas))
						oSection1:Cell('PREVISÃO EST. DIAS'):SetValue((((aSaldo[1]+(cEntradas))-(cSaidas))/(cSaidas))*(DateDiffDay(mv_par04,mv_par05)+1))
						oSection1:Printline()
					ElseIf MV_PAR07 == 'N'
						nTot++
						oSection1:Init()

						oSection1:Cell('PRODUTO'):lBold := .F.
						oSection1:Cell('ESTOQUE INICIAL'):lBold := .T.
						oSection1:Cell('ESTOQUE FINAL'):lBold := .T.

						oRelatorio:SetMsgPrint( "Calculando ... ")

						oSection1:Cell('PRODUTO'):nClrBack := CLR_WHITE
						oSection1:Cell('UND'):nClrBack := CLR_WHITE
						oSection1:Cell('TIPO'):nClrBack := CLR_WHITE
						oSection1:Cell('ESTOQUE INICIAL'):nClrBack := CLR_WHITE
						oSection1:Cell('CUSTO MÉDIO'):nClrBack := CLR_WHITE
						oSection1:Cell('ENTRADAS'):nClrBack := CLR_WHITE
						oSection1:Cell('CONSUMO'):nClrBack := CLR_WHITE
						oSection1:Cell('ESTOQUE FINAL'):nClrBack := CLR_WHITE
						oSection1:Cell('PREVISÃO EST. DIAS'):nClrBack := CLR_WHITE

						oSection1:Cell('PRODUTO'):nClrFore := CLR_BLACK
						oSection1:Cell('UND'):nClrFore := CLR_BLACK
						oSection1:Cell('TIPO'):nClrFore := CLR_BLACK
						oSection1:Cell('ESTOQUE INICIAL'):nClrFore := CLR_BLACK
						oSection1:Cell('CUSTO MÉDIO'):nClrFore := CLR_BLACK
						oSection1:Cell('ENTRADAS'):nClrFore := CLR_BLACK
						oSection1:Cell('CONSUMO'):nClrFore := CLR_BLACK
						oSection1:Cell('ESTOQUE FINAL'):nClrFore := CLR_BLACK
						oSection1:Cell('PREVISÃO EST. DIAS'):nClrFore := CLR_BLACK

						oSection1:Cell('PRODUTO'):SetValue(AllTrim(QERY->B1_COD)+" - "+AllTrim(QERY->B1_DESC))
						oSection1:Cell('UND'):SetValue(QERY->B1_UM)
						oSection1:Cell('TIPO'):SetValue(QERY->B1_TIPO)
						//oSection1:Cell('Classificação'):SetValue(QERY->B1_CLASSI)
						oSection1:Cell('ESTOQUE INICIAL'):SetAlign("RIGHT")
						oSection1:Cell('CUSTO MÉDIO'):SetAlign("RIGHT")
						oSection1:Cell('ENTRADAS'):SetAlign("RIGHT")
						oSection1:Cell('CONSUMO'):SetAlign("RIGHT")
						oSection1:Cell('ESTOQUE FINAL'):SetAlign("RIGHT")
						oSection1:Cell('PREVISÃO EST. DIAS'):SetAlign("RIGHT")
						oSection1:Cell('ESTOQUE INICIAL'):SetValue(aSaldo[1])
						oSection1:Cell('CUSTO MÉDIO'):SetValue(round(aCusto[2]/aCusto[1],4))
						oSection1:Cell('ENTRADAS'):SetValue(cEntradas)
						oSection1:Cell('CONSUMO'):SetValue(cSaidas)
						oSection1:Cell('ESTOQUE FINAL'):SetValue((aSaldo[1]+cEntradas)-(cSaidas))
						oSection1:Cell('PREVISÃO EST. DIAS'):SetValue((((aSaldo[1]+(cEntradas))-(cSaidas))/(cSaidas))*(DateDiffDay(mv_par04,mv_par05)+1))
						oSection1:Printline()
					Endif
				EndIf
			else
				nSemClassi++
			EndIf
			QERY->(DbSkip())
		END
		If !Empty(cClassi) .And. nTot > 0
			oRelatorio:SkipLine() //-- Salta Linha
			oRelatorio:PrtCenter("QTD. DE PRODUTOS DESTA CLASSIFICAÇÃO :        "+cValToChar(nTot))
			nTotal+=nTot
			//oRelatorio:ThinLine() //-- Desenha uma linha simples
			oRelatorio:SkipLine() //-- Salta Linha
			oRelatorio:ThinLine() //-- Desenha uma linha simples
		EndIf
	END

	QERY->(DbCloseArea())
	oSection1:Finish()

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

	_DataDe := DToC(MV_PAR04)
	_DataAte:= DToC(MV_PAR05)

	aCabec := {	"__LOGOEMP__" + "         " + cChar + "         " + RptFolha+TRANSFORM(oRelatorio:Page(),'999999');
		, Padc(UPPER("Relatório de Registro de Inventário - ") + FWFilialName(_cEmp),132);
		, Padc("",132);
		, Padc(UPPER('Período de '+_DataDe+' até '+_DataAte),132);
		, RptHora + " " + time() ;
		+ cChar + "         " + RptEmiss + " " + Dtoc(dDataBase)}

	RestArea( aArea )

Return aCabec

Static Function ImpCabec( oReport, oSection1, cClassi)
	oSection1:Init()
	oSection1:Cell('PRODUTO'):nClrBack := CLR_SILVER
	oSection1:Cell('UND'):nClrBack := CLR_SILVER
	oSection1:Cell('TIPO'):nClrBack := CLR_SILVER
	oSection1:Cell('ESTOQUE INICIAL'):nClrBack := CLR_SILVER
	oSection1:Cell('CUSTO MÉDIO'):nClrBack := CLR_SILVER
	oSection1:Cell('ENTRADAS'):nClrBack := CLR_SILVER
	oSection1:Cell('CONSUMO'):nClrBack := CLR_SILVER
	oSection1:Cell('ESTOQUE FINAL'):nClrBack := CLR_SILVER
	oSection1:Cell('PREVISÃO EST. DIAS'):nClrBack := CLR_SILVER
	oSection1:Cell('PRODUTO'):SetValue("CLASSIFICAÇÃO: "+cClassi)
	oSection1:Cell('UND'):SetValue()
	oSection1:Cell('TIPO'):SetValue()
	//oSection1:Cell('Classificação'):SetValue()
	oSection1:Cell('ESTOQUE INICIAL'):SetAlign("RIGHT")
	oSection1:Cell('CUSTO MÉDIO'):SetAlign("RIGHT")
	oSection1:Cell('ENTRADAS'):SetAlign("RIGHT")
	oSection1:Cell('CONSUMO'):SetAlign("RIGHT")
	oSection1:Cell('ESTOQUE FINAL'):SetAlign("RIGHT")
	oSection1:Cell('PREVISÃO EST. DIAS'):SetAlign("RIGHT")
	oSection1:Cell('ESTOQUE INICIAL'):SetValue()
	oSection1:Cell('CUSTO MÉDIO'):SetValue()
	oSection1:Cell('ENTRADAS'):SetValue()
	oSection1:Cell('CONSUMO'):SetValue()
	oSection1:Cell('ESTOQUE FINAL'):SetValue()
	oSection1:Cell('PREVISÃO EST. DIAS'):SetValue()
	oSection1:PrintLine()

Return
