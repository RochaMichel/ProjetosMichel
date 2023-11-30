#Include "Totvs.ch"
#Include "RPTDef.ch"
#include "TBICONN.ch"

/*/{Protheus.doc} RAPRET
Fonte para exibir Relatório de Apuração Retidos
@type function
@author Felipe Henrique
@since 30/	01/2023
@return 
/*/

User Function RAPRET()
	Local aPergs	 := {}
	Local cQuery	 := ""
	Private oReport  := Nil
	Private oSecCab	 := Nil

	aAdd(aPergs,{1,"De Filial  ",Space(6),"","","SM0","",50,.F.})                   //MV_PAR01
	aAdd(aPergs,{1,"Data de Digitação de: ",Ctod(Space(8)),"","","","",50,.F.})		//MV_PAR02
	aAdd(aPergs,{1,"Data de Digitação ate: ",Ctod(Space(8)),"","","","",50,.F.})	//MV_PAR03
	aAdd(aPergs,{1,"Cod. Receita: ",Space(4),"","","","",50,.F.})					//MV_PAR04

	If !ParamBox(aPergs,"Informe os Parametros ")
		Return
	EndIf

	cQuery := "	SELECT D1_FILIAL, D1_DOC, A2_COD, A2_CGC, A2_NOME,D1_TOTAL, D1_EMISSAO, D1_DTDIGIT, D1_BASECSL,             "
	cQuery += "	D1_BASECOF,	D1_BASEPIS,	D1_BASEIRR,	D1_VALCSL,	D1_VALCOF,	D1_VALPIS,	D1_VALIRR , E2_CODRET               "
	cQuery += "	FROM " +RetSqlName("SD1") + " SD1 "
	cQuery += "	INNER JOIN " +RetSqlName("SA2") + " SA2  ON SD1.D1_FORNECE = SA2.A2_COD AND SD1.D1_LOJA = A2_LOJA           "
	cQuery += "	INNER JOIN " +RetSqlName("SE2") + " SE2  ON SD1.D1_DOC = SE2.E2_NUM AND SD1.D1_SERIE = SE2.E2_PREFIXO 		"
	cQuery += " AND SD1.D1_FORNECE = SE2.E2_FORNECE AND  SD1.D1_FILIAL = SE2.E2_FILIAL 										"
	cQuery += "	WHERE SD1.D1_DTDIGIT BETWEEN '"+dTos(MV_PAR02)+"' AND '"+dTos(MV_PAR03)+"'                                  "
	cQuery += "	AND SE2.E2_CODRET = '"+MV_PAR04+"'   AND SD1.D1_FILIAL = '"+MV_PAR01+"'                                                                       "
	cQuery += "	AND SD1.D_E_L_E_T_ <> '*'    "
	cQuery += "	AND SA2.D_E_L_E_T_ <> '*'    "
	cQuery += "	AND SE2.D_E_L_E_T_ <> '*'    "

	MpSysOpenQuery(cQuery,"cQry")

	oReport := reportDef()
	oReport:printDialog()

Return

Static Function reportDef()
	local oReport
	Local oSection1
	local cTitulo := ' Relatorio de Apuração Retidos ' //titulo do relatorio
	oReport := TReport():New('RAPRET', cTitulo, , {|oReport| PrintReport(oReport)},'Relatorio de Apuração Retidos')
	oReport:SetPortrait()
	oReport:nFontBody := 06

	//Primeira sessao
	oSection1:= TRSection():New(oReport, "Relatorio de Apuração Retidos", {"cQry"}, , .F., .T., , , ,.F., .F.)
	oSection1:SetHeaderSection(.T.)
	TRCell():new(oSection1, "D1_FILIAL" 	 , "cQry", 'FILIAL'	          ,PesqPict('SD1',"D1_FILIAL")   ,TamSX3("D1_FILIAL")   [1]+2  	   ,,,  "LEFT")
	TRCell():new(oSection1, "D1_DOC"     	 , "cQry", 'DOCUMENTO'	      ,PesqPict('SD1',"D1_DOC")      ,TamSX3("D1_DOC")  	[1]+2      ,,,  "LEFT")
	TRCell():New(oSection1, "A2_COD"	 	 , "cQry", 'COD. FORNECEDOR'  ,PesqPict('SA2',"A2_COD")      ,TamSX3("A2_COD")      [1]+5      ,,,  "LEFT")
	TRCell():New(oSection1, "A2_CGC"		 , "cQry", 'CNPJ'	          ,PesqPict('SA2',"A2_CGC")      ,TamSX3("A2_CGC")      [1]+2      ,,,  "LEFT")
	TRCell():New(oSection1, "A2_NOME"	 	 , "cQry", 'NOME FORNECEDOR'  ,PesqPict('SA2',"A2_NOME")     ,TamSX3("A2_NOME")     [1]+3      ,,,  "LEFT")
	TRCell():New(oSection1, "E2_CODRET"		 , "cQry", 'COD. RECEITA'	  ,PesqPict('SE2',"E2_CODRET")   ,TamSX3("E2_CODRET")   [1]/*+2*/  ,,,  "LEFT")
	TRCell():New(oSection1, "D1_TOTAL"		 , "cQry", 'VLR. TOTAL'	      ,PesqPict('SD1',"D1_TOTAL")    ,TamSX3("D1_TOTAL")    [1]-2      ,,,  "LEFT")
	TRCell():New(oSection1, "D1_EMISSAO"	 , "cQry", 'DT. EMISSAO'	  ,PesqPict('SD1',"D1_EMISSAO")  ,TamSX3("D1_EMISSAO")	[1]/*+2*/  ,,,  "LEFT")
	TRCell():New(oSection1, "D1_DTDIGIT"	 , "cQry", 'DT. DIGITACAO'    ,PesqPict('SD1',"D1_DTDIGIT")  ,TamSX3("D1_DTDIGIT")  [1]-2      ,,,  "LEFT")
	TRCell():New(oSection1, "D1_BASECSL"	 , "cQry", 'BASE CSLL'	      ,PesqPict('SD1',"D1_BASECSL")  ,TamSX3("D1_BASECSL")  [1]+2      ,,,  "LEFT")
	TRCell():New(oSection1, "D1_BASECOF"     , "cQry", 'BASE COFINS'	  ,PesqPict('SD1',"D1_BASECOF")  ,TamSX3("D1_BASECOF")	[1]/*+2*/  ,,,  "LEFT")
	TRCell():New(oSection1, "D1_BASEPIS"	 , "cQry", 'BASE PIS'	      ,PesqPict('SD1',"D1_BASEPIS")  ,TamSX3("D1_BASEPIS")	[1]+4      ,,,  "LEFT")
	TRCell():New(oSection1, "D1_BASEIRR"	 , "cQry", 'BASE DE IRRF'	  ,PesqPict('SD1',"D1_BASEIRR")  ,TamSX3("D1_BASEIRR")  [1]/*+2*/  ,,,  "LEFT")
	TRCell():New(oSection1, "D1_VALCSL"	 	 , "cQry", 'VLR. CSLL'        ,PesqPict('SD1',"D1_VALCSL")   ,TamSX3("D1_VALCSL")  	[1]-4      ,,,  "LEFT")
	TRCell():New(oSection1, "D1_VALCOF"	     , "cQry", 'VLR. COFINS'      ,PesqPict('SD1',"D1_VALCOF")   ,TamSX3("D1_VALCOF")  	[1]+3      ,,,  "LEFT")
	TRCell():New(oSection1, "D1_VALPIS"		 , "cQry", 'VLR. PIS'	      ,PesqPict('SD1',"D1_VALPIS")   ,TamSX3("D1_VALPIS")   [1]/*+2*/  ,,,  "LEFT")
	TRCell():New(oSection1, "D1_VALIRR"		 , "cQry", 'VALOR IRRF'		  ,PesqPict('SD1',"D1_VALIRR")   ,TamSX3("D1_VALIRR")   [1]/*+2*/  ,,,  "LEFT")

return (oReport)

Static Function PrintReport(oReport)
	Local oSection1 := oReport:Section(1)

	DbSelectArea('cQry')
	cQry->(dbGoTop())
	oReport:SetMeter(cQry->(RecCount()))
	oReport:IncMeter()
	oSection1:Init()
	oReport:SkipLine()

	While cQry->(!Eof())

		If oReport:Cancel()
			Exit
		EndIf

		oSection1:Cell("D1_FILIAL"):SetValue(cQry->D1_FILIAL)
		oSection1:Cell("D1_FILIAL"):SetAlign("LEFT")
		oSection1:Cell("D1_DOC"):SetValue(cQry->D1_DOC)
		oSection1:Cell("D1_DOC"):SetAlign("LEFT")
		oSection1:Cell("A2_COD"):SetValue(Alltrim(cQry->A2_COD))
		oSection1:Cell("A2_COD"):SetAlign("LEFT")
		oSection1:Cell("A2_CGC"):SetValue(cQry->A2_CGC)
		oSection1:Cell("A2_CGC"):SetAlign("LEFT")
		oSection1:Cell("A2_NOME"):SetValue(cQry->A2_NOME)
		oSection1:Cell("A2_NOME"):SetAlign("LEFT")
		oSection1:Cell("E2_CODRET"):SetValue(cQry->E2_CODRET)
		oSection1:Cell("E2_CODRET"):SetAlign("LEFT")
		oSection1:Cell("D1_TOTAL"):SetValue(cQry->D1_TOTAL)
		oSection1:Cell("D1_TOTAL"):SetAlign("LEFT")
		oSection1:Cell("D1_EMISSAO"):SetValue(sTod(cQry->D1_EMISSAO))
		oSection1:Cell("D1_EMISSAO"):SetAlign("LEFT")
		oSection1:Cell("D1_DTDIGIT"):SetValue(sTod(cQry->D1_DTDIGIT))
		oSection1:Cell("D1_DTDIGIT"):SetAlign("LEFT")
		oSection1:Cell("D1_BASECSL"):SetValue(cQry->D1_BASECSL)
		oSection1:Cell("D1_BASECSL"):SetAlign("LEFT")
		oSection1:Cell("D1_BASECOF"):SetValue(cQry->D1_BASECOF)
		oSection1:Cell("D1_BASECOF"):SetAlign("LEFT")
		oSection1:Cell("D1_BASEPIS"):SetValue(cQry->D1_BASEPIS)
		oSection1:Cell("D1_BASEPIS"):SetAlign("LEFT")
		oSection1:Cell("D1_BASEIRR"):SetValue(cQry->D1_BASEIRR)
		oSection1:Cell("D1_BASEIRR"):SetAlign("LEFT")
		oSection1:Cell("D1_VALCSL"):SetValue(cQry->D1_VALCSL)
		oSection1:Cell("D1_VALCSL"):SetAlign("LEFT")
		oSection1:Cell("D1_VALCOF"):SetValue(cQry->D1_VALCOF)
		oSection1:Cell("D1_VALCOF"):SetAlign("LEFT")
		oSection1:Cell("D1_VALPIS"):SetValue(cQry->D1_VALPIS)
		oSection1:Cell("D1_VALPIS"):SetAlign("LEFT")
		oSection1:Cell("D1_VALIRR"):SetValue(cQry->D1_VALIRR)
		oSection1:Cell("D1_VALIRR"):SetAlign("LEFT")
		oSection1:PrintLine()

		cQry->(DbSkip())

	Enddo
	oSection1:Finish()
	cQry->(DbCloseArea())

Return
