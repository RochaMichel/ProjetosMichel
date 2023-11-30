#Include "Totvs.ch"
#Include "RPTDef.ch"
#include "TBICONN.ch"

/*/{Protheus.doc} RELPEDCOMP
Fonte para exibir relatório de pedido de compras
@type function
@version  
@type function
@version  
@author Felipe Henrique
@since 09/01/2023
@return 
/*/


User Function RELPEDCOMP()
	Local aPergs	 := {}
	Local cQuery	 := ""
	Local aOpc      := {"SIM","NAO"}
	Private oReport  := Nil
	Private oSecCab	 := Nil

	aAdd(aPergs,{1,"Do pedido de Compras: ",Space(6),"","","SC7","",50,.F.})    //MV_PAR01
	aAdd(aPergs,{1,"Ate pedido de Compras: ",Space(6),"","","SC7","",50,.F.})   //MV_PAR02
	aAdd(aPergs,{1,"Da Emissao ",Ctod(Space(8)),"","","","",50,.F.})            //MV_PAR03
	aAdd(aPergs,{1,"Ate Emissao ",Ctod(Space(8)),"","","","",50,.F.})           //MV_PAR04
	aAdd(aPergs,{1,"De Filial  ",Space(6),"","","SM0","",50,.F.}) 		        //MV_PAR05
	aAdd(aPergs,{1,"Ate Filial ",Space(6),"","","SM0","",50,.F.})		        //MV_PAR06
	aAdd(aPergs,{2,"Apenas pedidos liberados    ","NÃO",aOpc,35,"",.F.,,})		//MV_PAR07
	aAdd(aPergs,{2,"Considera parametros abaixo    ","NÃO",aOpc,35,"",.F.,,})	//MV_PAR08
	aAdd(aPergs,{1,"Data da Aprovacao ",Ctod(Space(8)),"","","","",50,.F.})		//MV_PAR09
	aAdd(aPergs,{1,"Codigo do comprador ",Space(6),"","","SC7","",50,.F.})		//MV_PAR10
	aAdd(aPergs,{1,"Codigo do Usuario ",Space(6),"","","SC7","",50,.F.})		//MV_PAR11

	If !ParamBox(aPergs,"Informe os Parametros ")
		Return
	EndIf

	cQuery := "	SELECT  C7_FILIAL, C7_NUM, C7_FORNECE, C7_LOJA, A2_NOME, C7_EMISSAO, C7_QUANT, C7_TOTAL,    "
	cQuery += " C7_CONAPRO, C7_XDHAPRO, C7_COMPRA, C7_USER, C7_QUJE, BM_DESC					  		    "
	cQuery += "	FROM " + RetSqlName("SC7") + " SC7 "
	cQuery += "	INNER JOIN " + RetSqlName("SA2") + " SA2 ON C7_FORNECE = A2_COD  							"
	cQuery += "	INNER JOIN " + RetSqlName("SB1") + " SB1 ON C7_PRODUTO = B1_COD 							"
	cQuery += "	INNER JOIN " + RetSqlName("SBM") + " SBM ON B1_GRUPO = BM_GRUPO 							"
	cQuery += " WHERE SC7.D_E_L_E_T_ <> '*' 															    "
	cQuery += " AND SC7.D_E_L_E_T_ <> '*' 																    "
	cQuery += " AND SC7.D_E_L_E_T_ <> '*' 																    "
	cQuery += " AND SA2.D_E_L_E_T_ <> '*' 																    "
	cQuery += " AND SB1.D_E_L_E_T_ <> '*' 																    "
	cQuery += " AND SBM.D_E_L_E_T_ <> '*' 																    "
	cQuery += "	AND C7_NUM  BETWEEN '" +MV_PAR01+ "' AND '" +MV_PAR02+ "'                                   "															"
	cQuery += " AND	C7_EMISSAO BETWEEN '" +dTos(MV_PAR03)+ "'  AND '" +dTos(MV_PAR04)+ "'				    "																		"
	cQuery += " AND C7_FILIAL BETWEEN '" +MV_PAR05+ "' AND '" +MV_PAR06+ "'                                 "

	If MV_PAR07 == 'SIM'
		cQuery += " AND C7_CONAPRO = 'L' "
	ELSE
		cQuery += " AND C7_CONAPRO = ' '	"
	EndIf

	//Caso considere os parametros
	If MV_PAR08 == 'SIM'
		cQuery += "AND SUBSTR(C7_XDHAPRO,10,10) LIKE '%"+dToc(MV_PAR09)+"' AND C7_COMPRA ='"+MV_PAR10+"' AND C7_USER = '"+MV_PAR11+"'"
	EndIf
	MpSysOpenQuery(cQuery,"cQry")

	oReport := reportDef()
	oReport:printDialog()

Return

Static Function reportDef()
	local oReport
	Local oSection1
	local cTitulo := ' Relatorio de Pedido de Compras' //titulo do relatorio
	oReport := TReport():New('RELPEDCOMP', cTitulo, , {|oReport| PrintReport(oReport)},'Relatorio de Pedido de Compras')
	oReport:SetPortrait()
	oReport:nFontBody := 06

	//Primeira sessao
	oSection1:= TRSection():New(oReport, "Relatorio de lista de precos", {"cQry"}, , .F., .T., , , ,.F., .F.)
	oSection1:SetHeaderSection(.T.)
	TRCell():new(oSection1, "C7_FILIAL" 	 , "cQry", 'FILIAL'	         ,PesqPict('SC7',"C7_FILIAL")   ,TamSX3("C7_FILIAL")   [1]+2  	  ,,, "LEFT")
	TRCell():new(oSection1, "C7_NUM"    	 , "cQry", 'PEDIDO'	         ,PesqPict('SC7',"C7_NUM")      ,TamSX3("C7_NUM")      [1]+2      ,,, "LEFT")
	TRCell():New(oSection1, "C7_FORNECE"	 , "cQry", 'FORNECEDOR'      ,PesqPict('SC7',"C7_FORNECE")  ,TamSX3("C7_FORNECE")  [1]+5      ,,, "LEFT")
	TRCell():New(oSection1, "C7_LOJA"		 , "cQry", 'LOJA'	         ,PesqPict('SC7',"C7_LOJA")     ,TamSX3("C7_LOJA")     [1]+2      ,,, "LEFT")
	TRCell():New(oSection1, "A2_NOME"		 , "cQry", 'RAZAO SOCIAL'	 ,PesqPict('SA2',"A2_NOME")     ,TamSX3("A2_NOME")     [1]+3      ,,, "LEFT")
	TRCell():New(oSection1, "C7_EMISSAO"	 , "cQry", 'EMISSAO'	     ,PesqPict('SC7',"C7_EMISSAO")  ,TamSX3("C7_EMISSAO")  [1]/*+2*/  ,,, "LEFT")
	TRCell():New(oSection1, "C7_QUANT"		 , "cQry", 'QUANT.'	         ,PesqPict('SC7',"C7_QUANT")    ,TamSX3("C7_QUANT")    [1]-2      ,,, "LEFT")
	TRCell():New(oSection1, "C7_TOTAL"		 , "cQry", 'VL.TOTAL'	     ,PesqPict('SC7',"C7_TOTAL")    ,TamSX3("C7_TOTAL")	   [1]/*+2*/  ,,, "LEFT")
	TRCell():New(oSection1, "VALOR RECEBIDO" , "cQry", 'VALOR RECEBIDO'	 ,PesqPict('SC7',"C7_TOTAL")    ,TamSX3("C7_TOTAL")	   [1]/*+2*/  ,,, "LEFT")
	TRCell():New(oSection1, "QTD PENDENTE"	 , "cQry", 'QTD PENDENTE'	 ,PesqPict('SC7',"C7_QUANT")    ,TamSX3("C7_QUANT")	   [1]+4      ,,, "LEFT")
	TRCell():New(oSection1, "C7_CONAPRO"	 , "cQry", 'LIBERACAO'	     ,PesqPict('SC7',"C7_CONAPRO")  ,TamSX3("C7_CONAPRO")  [1]/*+2*/  ,,, "LEFT")
	TRCell():New(oSection1, "C7_XDHAPRO"	 , "cQry", 'DT. APROVACAO'   ,PesqPict('SC7',"C7_XDHAPRO")  ,TamSX3("C7_XDHAPRO")  [1]-4      ,,, "LEFT")
	TRCell():New(oSection1, "C7_COMPRA"		 , "cQry", 'COD COMPRADOR'   ,PesqPict('SC7',"C7_COMPRA")   ,TamSX3("C7_COMPRA")   [1]+3      ,,, "LEFT")
	TRCell():New(oSection1, "C7_USER"		 , "cQry", 'COD USUARIO'	 ,PesqPict('SC7',"C7_USER")     ,TamSX3("C7_USER")     [1]+2      ,,, "LEFT")
	TRCell():New(oSection1, "C7_XREF1"		 , "cQry", 'REFERENCIA1'	 ,PesqPict('SC7',"C7_XREF1")    ,TamSX3("C7_XREF1")    [1]/*+2*/  ,,, "LEFT")
	TRCell():New(oSection1, "BM_DESC"		 , "cQry", 'GRUPO'			 ,PesqPict('SC7',"BM_DESC")     ,TamSX3("BM_DESC")     [1]/*+2*/  ,,, "LEFT")
	TRCell():New(oSection1, "SUBGRUPO"		 , "cQry", 'SUBGRUPO'		 ,PesqPict('SC7',"BM_DESC")     ,TamSX3("BM_DESC")     [1]/*+2*/  ,,, "LEFT")

return (oReport)

Static Function PrintReport(oReport)
	Local oSection1 := oReport:Section(1)

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

		oSection1:Cell("C7_FILIAL"):SetValue(cQry->C7_FILIAL)
		oSection1:Cell("C7_FILIAL"):SetAlign("LEFT")
		oSection1:Cell("C7_NUM"):SetValue(cQry->C7_NUM)
		oSection1:Cell("C7_NUM"):SetAlign("LEFT")
		oSection1:Cell("C7_FORNECE"):SetValue(cQry->C7_FORNECE)
		oSection1:Cell("C7_FORNECE"):SetAlign("LEFT")
		oSection1:Cell("C7_LOJA"):SetValue(cQry->C7_LOJA)
		oSection1:Cell("C7_LOJA"):SetAlign("LEFT")
		oSection1:Cell("A2_NOME"):SetValue(cQry->A2_NOME)
		oSection1:Cell("A2_NOME"):SetAlign("LEFT")
		oSection1:Cell("C7_EMISSAO"):SetValue(sTod(cQry->C7_EMISSAO))
		oSection1:Cell("C7_EMISSAO"):SetAlign("LEFT")
		oSection1:Cell("C7_QUANT"):SetValue(cQry->C7_QUANT)
		oSection1:Cell("C7_QUANT"):SetAlign("LEFT")
		oSection1:Cell("C7_TOTAL"):SetValue(cQry->C7_TOTAL)
		oSection1:Cell("C7_TOTAL"):SetAlign("LEFT")
		oSection1:Cell("VALOR RECEBIDO"):SetValue(cQry->C7_TOTAL*cQry->C7_QUANT)
		oSection1:Cell("VALOR RECEBIDO"):SetAlign("LEFT")
		oSection1:Cell("QTD PENDENTE"):SetValue(cQry->C7_QUANT-cQry-> C7_QUJE)
		oSection1:Cell("QTD PENDENTE"):SetAlign("LEFT")
		oSection1:Cell("C7_CONAPRO"):SetValue(cQry->C7_CONAPRO)
		oSection1:Cell("C7_CONAPRO"):SetAlign("LEFT")
		oSection1:Cell("C7_XDHAPRO"):SetValue(SubStr(cQry->C7_XDHAPRO,10,10))
		oSection1:Cell("C7_XDHAPRO"):SetAlign("LEFT")
		oSection1:Cell("C7_COMPRA"):SetValue(cQry->C7_COMPRA)
		oSection1:Cell("C7_COMPRA"):SetAlign("LEFT")
		oSection1:Cell("C7_USER"):SetValue(cQry->C7_USER)
		oSection1:Cell("C7_USER"):SetAlign("LEFT")
		oSection1:Cell("C7_XREF1"):SetValue( IniAuxCod(SC7->C7_PRODUTO,"C7_XREF1"))
		oSection1:Cell("C7_XREF1"):SetAlign("LEFT")
		oSection1:Cell("BM_DESC"):SetValue(cQry->BM_DESC)
		oSection1:Cell("BM_DESC"):SetAlign("LEFT")
		oSection1:Cell("SUBGRUPO"):SetValue(POSICIONE("SBM",1,XFILIAL("SBM")+SZ0->(Z0_TIPO+Z0_XGRUPO),"BM_DESC")            )
		oSection1:Cell("SUBGRUPO"):SetAlign("LEFT")


		cQry->(DbSkip())
	Enddo

	oReport:Section(1):Print()
	cQry->(DbCloseArea())

Return
