#Include "Totvs.ch"
#Include "RPTDef.ch"
#include "TBICONN.ch"

/*/{Protheus.doc} APURAISS
Fonte para exibir Relatório de Apuração ISS
@type function
@author Felipe Henrique
@since 30/01/2023
@return 
/*/

User Function APURAISS()
	Local aPergs	 := {}
	Local cQuery	 := ""
	Private oReport  := Nil
	Private oSecCab	 := Nil

	aAdd(aPergs,{1,"De Filial  ",Space(6),"","","SM0","",50,.F.})                   // MV_PAR01
	aAdd(aPergs,{1,"Data de Digitação de: ",Ctod(Space(8)),"","","","",50,.F.})		// MV_PAR02
	aAdd(aPergs,{1,"Data de Digitação ate: ",Ctod(Space(8)),"","","","",50,.F.})	// MV_PAR03

	If !ParamBox(aPergs,"Informe os Parametros ")
		Return
	EndIf

	cQuery := "	SELECT F1_FILIAL, F1_VALMERC, F1_EMISSAO, F1_DTDIGIT, F1_ISS, F1_DOC, SUM(E2_VALOR)AS VALOR, E2_TIPO, A2_CGC, A2_NOME, SUM(E2_ISS)AS ISS   "
	cQuery += "	FROM " +RetSqlName("SF1")+ " SF1 "
	cQuery += "	INNER JOIN " +RetSqlName("SA2")+ " SA2 ON SF1.F1_FORNECE = SA2.A2_COD AND SF1.F1_LOJA = SA2.A2_LOJA        "
	cQuery += "	INNER JOIN " +RetSqlName("SE2")+ " SE2 ON SF1.F1_DOC = SE2.E2_NUM AND SF1.F1_SERIE = SE2.E2_PREFIXO AND SF1.F1_FILIAL = SE2.E2_FILIAL       "
	cQuery += "	WHERE SF1.F1_DTDIGIT BETWEEN '"+dTos(MV_PAR02)+"' AND '"+dTos(MV_PAR03)+"' AND SF1.F1_FILIAL = '"+MV_PAR01+"'							   "
	cQuery += "	AND SE2.E2_ISS > 0               "
	cQuery += "	AND SF1.F1_ISS > 0               "
	cQuery += "	AND SF1.D_E_L_E_T_ <> '*'          "
	cQuery += "	AND SA2.D_E_L_E_T_ <> '*'          "
	cQuery += "	AND SE2.D_E_L_E_T_ <> '*'          "
	cQuery += "	GROUP BY F1_FILIAL,F1_VALMERC, F1_EMISSAO, F1_DTDIGIT, F1_ISS, F1_DOC, E2_TIPO, A2_CGC, A2_NOME          "
	cQuery += "	ORDER BY F1_FILIAL           "

	MpSysOpenQuery(cQuery,"cQry")

	oReport := reportDef()
	oReport:printDialog()

Return

Static Function reportDef()
	local oReport
	Local oSection1
//	Local oBreak
	local cTitulo := ' Relatorio de Apuração ISS ' //titulo do relatorio

	oReport := TReport():New('APURAISS', cTitulo, , {|oReport| PrintReport(oReport)},'Relatorio de Apuração ISS')
	oReport:SetPortrait()
	oReport:nFontBody := 06

	//Primeira sessao
	oSection1:= TRSection():New(oReport, "Relatorio de Apuração ISS", {"cQry"}, , .F., .T., , , ,.F., .F.)
	oSection1:SetHeaderSection(.T.)
	TRCell():new(oSection1, "F1_FILIAL" 	 , "cQry", 'FILIAL'	          ,PesqPict('SF1',"F1_FILIAL")   ,TamSX3("F1_FILIAL")   [1]+2  	   ,,,  "LEFT")
	TRCell():new(oSection1, "F1_DOC"     	 , "cQry", 'NUMERO'	      	  ,PesqPict('SF1',"F1_DOC")      ,TamSX3("F1_DOC")  	[1]+2      ,,,  "LEFT")
	TRCell():New(oSection1, "A2_CGC"		 , "cQry", 'CNPJ/CPF'	      ,PesqPict('SA2',"A2_CGC")      ,TamSX3("A2_CGC")      [1]+2      ,,,  "LEFT")
	TRCell():New(oSection1, "A2_NOME"	 	 , "cQry", 'RAZÃO SOCIAL'     ,PesqPict('SA2',"A2_NOME")     ,TamSX3("A2_NOME")     [1]+3      ,,,  "LEFT")
	TRCell():New(oSection1, "F1_VALMERC"	 , "cQry", 'VLR. MERCADORIA'  ,PesqPict('SF1',"F1_VALMERC")  ,TamSX3("F1_VALMERC")  [1]/*+2*/  ,,,  "LEFT")
	TRCell():New(oSection1, "F1_EMISSAO"	 , "cQry", 'DT. EMISSAO'	  ,PesqPict('SF1',"F1_EMISSAO")  ,TamSX3("F1_EMISSAO")	[1]/*+2*/  ,,,  "LEFT")
	TRCell():New(oSection1, "F1_DTDIGIT"	 , "cQry", 'DT. DIGITACAO'    ,PesqPict('SF1',"F1_DTDIGIT")  ,TamSX3("F1_DTDIGIT")  [1]-2      ,,,  "LEFT")
	TRCell():New(oSection1, "F1_ISS"	     , "cQry", 'VALOR ISS'	      ,PesqPict('SF1',"F1_ISS")      ,TamSX3("F1_ISS")  	[1]+2      ,,,  "LEFT")

//TRPosition():New(oSection1, 'cQry', 1, {|| cQry->F1_DOC})
//
//oBreak1 := TRBreak():New(oSection1, oSection1:Cell("F1_DOC"))
//oBreak2 := TRBreak():New(oReport, {| | .T.}, , .F.)
//
//TRFunction():New(oSection1:Cell("F1_VALMERC"),'TOTALIZADOR0' ,"SUM",oBreak2,"","@E 999,999,999.99",/*uFormula*/,.F.,.F.,.F.,)
//TRFunction():New(oSection1:Cell("F1_ISS" )   ,'TOTALIZADOR1' ,"SUM",oBreak2,"","@E 999,999,999.99",/*uFormula*/,.F.,.F.,.F.,)
//
//oReport:PrintDialog()

return (oReport)

Static Function PrintReport(oReport)
	Local oSection1 := oReport:Section(1)
	Local nVlrMerc := 0
	Local nVlrIss  := 0

	DbSelectArea('cQry')
	cQry->(dbGoTop())
	oReport:SetMeter(cQry->(RecCount()))
	oReport:IncMeter()
	oSection1:Init()
	oReport:SkipLine()

	While cQry->(!Eof())
		//If cQry->F1_ISS > 0
			If oReport:Cancel()
				Exit
			EndIf

			oSection1:Cell("F1_FILIAL"):SetValue(cQry->F1_FILIAL)
			oSection1:Cell("F1_FILIAL"):SetAlign("LEFT")
			oSection1:Cell("F1_DOC"):SetValue(cQry->F1_DOC)
			oSection1:Cell("F1_DOC"):SetAlign("LEFT")
			oSection1:Cell("A2_CGC"):SetValue(cQry->A2_CGC)
			oSection1:Cell("A2_CGC"):SetAlign("LEFT")
			oSection1:Cell("A2_NOME"):SetValue(cQry->A2_NOME)
			oSection1:Cell("A2_NOME"):SetAlign("LEFT")
			oSection1:Cell("F1_VALMERC"):SetValue(cQry->F1_VALMERC)
			oSection1:Cell("F1_VALMERC"):SetAlign("LEFT")
			oSection1:Cell("F1_EMISSAO"):SetValue(sTod(cQry->F1_EMISSAO))
			oSection1:Cell("F1_EMISSAO"):SetAlign("LEFT")
			oSection1:Cell("F1_DTDIGIT"):SetValue(sTod(cQry->F1_DTDIGIT))
			oSection1:Cell("F1_DTDIGIT"):SetAlign("LEFT")
			oSection1:Cell("F1_ISS"):SetValue(cQry->F1_ISS)
			oSection1:Cell("F1_ISS"):SetAlign("LEFT")
			oSection1:Printline()
			nVlrMerc += cQry->F1_VALMERC
			nVlrIss  += cQry->F1_ISS
			cQry->(DbSkip())
		//ENDIF
		//cQry->(DbSkip())

	Enddo

	oSection1:Cell("F1_FILIAL"):SetValue("")
	oSection1:Cell("F1_FILIAL"):SetAlign("LEFT")
	oSection1:Cell("F1_DOC"):SetValue("")
	oSection1:Cell("F1_DOC"):SetAlign("LEFT")
	oSection1:Cell("A2_CGC"):SetValue("")
	oSection1:Cell("A2_CGC"):SetAlign("LEFT")
	oSection1:Cell("A2_NOME"):SetValue("VALOR TOTAL")
	oSection1:Cell("A2_NOME"):SetAlign("LEFT")
	oSection1:Cell("F1_VALMERC"):SetValue(nVlrMerc)
	oSection1:Cell("F1_VALMERC"):SetAlign("LEFT")
	oSection1:Cell("F1_EMISSAO"):SetValue("")
	oSection1:Cell("F1_EMISSAO"):SetAlign("LEFT")
	oSection1:Cell("F1_DTDIGIT"):SetValue("")
	oSection1:Cell("F1_DTDIGIT"):SetAlign("LEFT")
	oSection1:Cell("F1_ISS"):SetValue(nVlrIss)
	oSection1:Cell("F1_ISS"):SetAlign("LEFT")
	oSection1:Printline()

	oSection1:Finish()
	cQry->(DbCloseArea())

Return
