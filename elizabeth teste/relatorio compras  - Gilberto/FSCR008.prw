#Include "Totvs.ch"
#Include "RPTDef.ch"
#include "TBICONN.ch"

/*/{Protheus.doc} ESTF008
Fonte para exibir relatório de pedido de compras
@type function
@version  
@type function
@version  
@author Michel Rocha
@since 09/01/2023
@return 
/*/

User Function FSCR008()
	Local aPergs	 := {}
	Local cQuery	 := ""
	Private oReport  := Nil
	Private oSecCab	 := Nil


	//aAdd(aPergs,{1,"De Filial  ",Space(6),"","","SM0","",50,.F.})
	aAdd(aPergs,{1,"Filial Diferente de ",Space(6),"","","SM0","",50,.F.})					//MV_PAR01
	aAdd(aPergs,{1,"Data de Digitação maior que ",Ctod(Space(8)),"","","","",50,.F.})		//MV_PAR02
	aAdd(aPergs,{1,"Data de Digitação menor que ",Ctod(Space(8)),"","","","",50,.F.})		//MV_PAR03

	If !ParamBox(aPergs,"Informe os Parametros ")
		Return
	EndIf

	cQuery := " SELECT F1_SIMPNAC, D1_FILIAL, D1_COD,TRIM(B1_DESC)B1_DESC, D1_QUANT,F1_DOC, F1_FORNECE, D1_LOJA, 	"
	cQuery += " D1_TOTAL, D1_IPI, D1_VALIPI, D1_TES, D1_DTDIGIT, D1_ICMSRET, D1_ICMSCOM, F1_STATUS, 		"
	cQuery += " F1_CHVNFE,F1_EST, F1_VALICM, D1_PICM, D1_CF, D1_DOC, F1_VALIPI, D1_VUNIT, D1_BASEICM
	cQuery += " FROM " + RetSqlName("SD1") + " SD1 "
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1   ON D1_COD = B1_COD "
	cQuery += " INNER JOIN " + RetSqlName("SF1") + " SF1   ON D1_DOC = F1_DOC AND D1_FILIAL = F1_FILIAL 			"
	cQuery += " AND D1_SERIE =F1_SERIE  AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA 							"
	cQuery += " WHERE D1_DTDIGIT BETWEEN '"+dTos(MV_PAR02)+"' AND '"+dTos(MV_PAR03)+"' 				    			"
	cQuery += "  AND D1_FILIAL <> '"+MV_PAR01+"'                     												"
	cQuery += " AND SD1.D_E_L_E_T_ <> '*' "
	cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
	cQuery += " AND SF1.D_E_L_E_T_ <> '*' "

	MpSysOpenQuery(cQuery,"cQry")

	oReport := reportDef()
	oReport:printDialog()

Return

Static Function reportDef()
	local oReport
	Local oSection1

	local cTitulo := ' Relatorio de Conferencia ' //titulo do relatorio
	oReport := TReport():New('ESTF008', cTitulo, , {|oReport| PrintReport(oReport)},'Relatorio de Conferencia')
	oReport:SetPortrait()
	oReport:nFontBody := 06

	//Primeira sessao
	oSection1:= TRSection():New(oReport, "Relatorio de lista de precos", {"cQry"}, , .F., .T., , , ,.F., .F.)
	oSection1:SetHeaderSection(.T.)
	TRCell():new(oSection1, "D1_FILIAL" 	 , "cQry", 'FILIAL'	              ,PesqPict('SD1',"D1_FILIAL")   ,TamSX3("D1_FILIAL")   [1]+2  	   ,,,  "LEFT")
	TRCell():new(oSection1, "D1_COD"     	 , "cQry", 'PRODUTO'	          ,PesqPict('SC7',"D1_COD")      ,TamSX3("D1_COD")  	  [1]+2    ,,,  "LEFT")
	TRCell():New(oSection1, "B1_DESC"	 	 , "cQry", 'DESCRIÇÃO'            ,PesqPict('SC7',"B1_DESC")     ,TamSX3("B1_DESC")     [1]+5      ,,,  "LEFT")
	TRCell():New(oSection1, "D1_DOC"		 , "cQry", 'DOCUMENTO'	          ,PesqPict('SD1',"D1_DOC")      ,TamSX3("D1_DOC")      [1]+2      ,,,  "LEFT")
	TRCell():New(oSection1, "F1_FORNECE"	 , "cQry", 'FORNECEDOR'	          ,PesqPict('SC7',"F1_FORNECE")  ,TamSX3("F1_FORNECE")  [1]+3      ,,,  "LEFT")
	TRCell():New(oSection1, "D1_LOJA"		 , "cQry", 'LOJA'	              ,PesqPict('SC7',"D1_LOJA")     ,TamSX3("D1_LOJA")     [1]/*+2*/  ,,,  "LEFT")
	TRCell():New(oSection1, "D1_TOTAL"		 , "cQry", 'VLR. DA MERCADORIA'	  ,PesqPict('SD1',"D1_TOTAL")    ,TamSX3("D1_TOTAL")    [1]-2      ,,,  "LEFT")
	TRCell():New(oSection1, "D1_VALIPI"		 , "cQry", 'VALOR DO IPI ITEM'	  ,PesqPict('SD1',"D1_VALIPI")   ,TamSX3("D1_VALIPI")	[1]/*+2*/  ,,,  "LEFT")
	TRCell():New(oSection1, "VLR. TOTAL"	 , "cQry", 'VLR. TOTAL. PROD'     ,PesqPict('SD1',"D1_TOTAL")    ,TamSX3("D1_TOTAL")    [1]-2      ,,,  "LEFT")
	TRCell():New(oSection1, "D1_BASEICM"	 , "cQry", 'BASE CALC. ICMS'      ,PesqPict('SD1',"D1_BASEICM")  ,TamSX3("D1_BASEICM")  [1]-2      ,,,  "LEFT")
	TRCell():New(oSection1, "D1_ICMSCOM"	 , "cQry", 'ICMS COMPLE.'	      ,PesqPict('SD1',"D1_ICMSCOM")  ,TamSX3("D1_ICMSCOM")  [1]+2      ,,,  "LEFT")
	TRCell():New(oSection1, "CALC. DIFAL"    , "cQry", 'CALC. DIFAL'	      ,PesqPict('SD1',"D1_TOTAL")    ,TamSX3("D1_TOTAL")	[1]/*+2*/  ,,,  "LEFT")
	TRCell():New(oSection1, "D1_TES"	     , "cQry", 'TIPO ENTRADA'	      ,PesqPict('SD1',"D1_TES")      ,TamSX3("D1_TES")	    [1]+4      ,,,  "LEFT")
	TRCell():New(oSection1, "D1_CF"	         , "cQry", 'COD. FISCAL'	      ,PesqPict('SD1',"D1_CF")       ,TamSX3("D1_CF")       [1]/*+2*/  ,,,  "LEFT")
	TRCell():New(oSection1, "D1_DTDIGIT"	 , "cQry", 'DT. DIGITAÇÃO.'       ,PesqPict('SD1',"D1_DTDIGIT")  ,TamSX3("D1_DTDIGIT")  [1]-4      ,,,  "LEFT")
	TRCell():New(oSection1, "D1_ICMSRET"	 , "cQry", 'ICMS SOLID.'          ,PesqPict('SD1',"D1_ICMSRET")  ,TamSX3("D1_ICMSRET")  [1]+3      ,,,  "LEFT")
	TRCell():New(oSection1, "F1_STATUS"		 , "cQry", 'STATUS'	              ,PesqPict('SF1',"F1_STATUS")   ,TamSX3("F1_STATUS")   [1]/*+2*/  ,,,  "LEFT")
	TRCell():New(oSection1, "F1_CHVNFE"		 , "cQry", 'CHAVE NFe'		      ,PesqPict('SF1',"F1_CHVNFE")   ,TamSX3("F1_CHVNFE")   [1]/*+2*/  ,,,  "LEFT")
	TRCell():New(oSection1, "F1_EST"		 , "cQry", 'ESTADO'		          ,PesqPict('SF1',"F1_EST")      ,TamSX3("F1_EST")      [1]/*+2*/  ,,,  "LEFT")
	TRCell():New(oSection1, "F1_VALICM"		 , "cQry", 'VLR. ICMS'		      ,PesqPict('SF1',"F1_VALICM")   ,TamSX3("F1_VALICM")   [1]/*+2*/  ,,,  "LEFT")
	TRCell():New(oSection1, "D1_PICM"		 , "cQry", 'ALIQ. ICMS'		      ,PesqPict('SD1',"D1_PICM")     ,TamSX3("D1_PICM")     [1]/*+2*/  ,,,  "LEFT")

return (oReport)

Static Function PrintReport(oReport)
	Local oSection1 := oReport:Section(1)
	Local nVtotal   := 0
	//Local nAliqfil  := 0
	Local nICMSori  := 0
	Local nValorOP  := 0
	DbSelectArea('cQry')
	cQry->(dbGoTop())
	oReport:SetMeter(cQry->(RecCount()))
	oReport:IncMeter()
	oSection1:Init()
	oReport:SkipLine() // ult

	While cQry->(!Eof())

		If oReport:Cancel()
			Exit
		EndIf

		oSection1:Cell("D1_FILIAL"):SetValue(cQry->D1_FILIAL)
		oSection1:Cell("D1_FILIAL"):SetAlign("LEFT")
		oSection1:Cell("D1_COD"):SetValue(cQry->D1_COD)
		oSection1:Cell("D1_COD"):SetAlign("LEFT")
		oSection1:Cell("B1_DESC"):SetValue(Alltrim(cQry->B1_DESC))
		oSection1:Cell("B1_DESC"):SetAlign("LEFT")
		oSection1:Cell("D1_DOC"):SetValue(cQry->D1_DOC)
		oSection1:Cell("D1_DOC"):SetAlign("LEFT")
		oSection1:Cell("F1_FORNECE"):SetValue(cQry->F1_FORNECE)
		oSection1:Cell("F1_FORNECE"):SetAlign("LEFT")
		oSection1:Cell("D1_LOJA"):SetValue(sTod(cQry->D1_LOJA))
		oSection1:Cell("D1_LOJA"):SetAlign("LEFT")
		oSection1:Cell("VLR. DA MERCADORIA"):SetValue(cQry->D1_TOTAL)
		oSection1:Cell("VLR. DA MERCADORIA"):SetAlign("LEFT")
		oSection1:Cell("D1_VALIPI"):SetValue(cQry->D1_VALIPI)
		oSection1:Cell("D1_VALIPI"):SetAlign("LEFT")
		oSection1:Cell("VLR. TOTAL"):SetValue(cQry->D1_TOTAL + cQry->D1_VALIPI)
		oSection1:Cell("VLR. TOTAL"):SetAlign("LEFT")
		oSection1:Cell("D1_BASEICM"):SetValue(cQry->D1_BASEICM)
		oSection1:Cell("D1_BASEICM"):SetAlign("LEFT")
		oSection1:Cell("D1_ICMSCOM"):SetValue(cQry->D1_ICMSCOM)
		oSection1:Cell("D1_ICMSCOM"):SetAlign("LEFT")
		nVtotal   := cQry->D1_TOTAL + cQry->D1_VALIPI
		If Alltrim(cQry->F1_SIMPNAC) == "1"
			//nAliqfil := Val(SubStr(GetMV("MV_ESTICM"),At(cQry->F1_EST,GetMV("MV_ESTICM"))+2,2))
			nICMSori := nVtotal * 0
			nValorOP := nVtotal - nICMSori
			DO CASE
			CASE cQry->D1_FILIAL = "020202"
				oSection1:Cell("CALC. DIFAL"):SetValue((nValorOP/0.83) * ((17-cQry->D1_PICM)/100))
			OTHERWISE
				oSection1:Cell("CALC. DIFAL"):SetValue((nValorOP/0.82) * ((18-cQry->D1_PICM)/100))
			ENDCASE
		Else
			//nAliqfil := Val(SubStr(GetMV("MV_ESTICM"),At(cQry->F1_EST,GetMV("MV_ESTICM"))+2,2))
			nICMSori := nVtotal * (cQry->D1_PICM/100)
			nValorOP := nVtotal - nICMSori
			DO CASE
			CASE cQry->D1_FILIAL = "020202"
				oSection1:Cell("CALC. DIFAL"):SetValue((nValorOP /0.83) * ((17-cQry->D1_PICM)/100))
			OTHERWISE
				oSection1:Cell("CALC. DIFAL"):SetValue((nValorOP/0.82) * ((18-cQry->D1_PICM)/100))
			ENDCASE
		EndIf

		oSection1:Cell("CALC. DIFAL"):SetAlign("LEFT")
		oSection1:Cell("D1_TES"):SetValue(cQry->D1_TES)
		oSection1:Cell("D1_TES"):SetAlign("LEFT")
		oSection1:Cell("D1_CF"):SetValue(cQry->D1_CF)
		oSection1:Cell("D1_CF"):SetAlign("LEFT")
		oSection1:Cell("D1_DTDIGIT"):SetValue(sTod(cQry->D1_DTDIGIT))
		oSection1:Cell("D1_DTDIGIT"):SetAlign("LEFT")
		oSection1:Cell("D1_ICMSRET"):SetValue(cQry->D1_ICMSRET)
		oSection1:Cell("D1_ICMSRET"):SetAlign("LEFT")
		oSection1:Cell("F1_STATUS"):SetValue(cQry->F1_STATUS)
		oSection1:Cell("F1_STATUS"):SetAlign("LEFT")
		oSection1:Cell("F1_CHVNFE"):SetValue(cQry->F1_CHVNFE)
		oSection1:Cell("F1_CHVNFE"):SetAlign("LEFT")
		oSection1:Cell("F1_EST"):SetValue(cQry->F1_EST)
		oSection1:Cell("F1_EST"):SetAlign("LEFT")
		oSection1:Cell("F1_VALICM"):SetValue(cQry->F1_VALICM)
		oSection1:Cell("F1_VALICM"):SetAlign("LEFT")
		oSection1:Cell("D1_PICM"):SetValue(cQry->D1_PICM)
		oSection1:Cell("D1_PICM"):SetAlign("LEFT")
		oSection1:Printline()
		cQry->(DbSkip())
		//	oSection1:PrintLine()
	Enddo

	oSection1:Finish()
	cQry->(DbCloseArea())

Return
