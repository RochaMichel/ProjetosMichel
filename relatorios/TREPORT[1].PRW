#INCLUDE 'TOTVS.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} RFATRANS
Rotina de relatório Treport de MOVIMENTAÇÕES NO PEDIDO DE VENDAS
@type function
@version 1.0
@author Cod.ERP
@since 31/05/2022
/*/
//-------------------------------------------------------------------
User Function RFATRANS()
	//Local	aPergs	 := {}
	Local cSC5Alias   := GetNextAlias()
	Private oReport  := Nil
	Private oSecCab	 := Nil
	
	/*aAdd( aPergs ,{1,"DO REGISTRO  "	, space(TamSX3("ZAL_NUM")[1]),"@!",'.T.','CBL','.T.',TamSX3("ZAL_NUM")[1]+50,.F.})//MV_PAR01
	aAdd( aPergs ,{1,"ATÉ O REGISTRO "	, space(TamSX3("ZAL_NUM")[1]),"@!",'.T.','CBL','.T.',TamSX3("ZAL_NUM")[1]+50,.F.})//MV_PAR02
	If !ParamBox(aPergs ,"Parametros ")
		Return
	EndIf*/

	
	BeginSql Alias cSC5Alias
			SELECT C5_FILIAL, C5_CONDPAG, C5_VEND1, C5_CLIENTE
			FROM %Table:SC5% SC5
			INNER JOIN %Table:SC6% SC6 ON SC6.C6_NUM = SC5.C5_NUM
			    WHERE C5_NUM = '000066'
				AND C6_FILIAL = %xFilial:SC6%
				AND C5_FILIAL = %xFilial:SC5%
			    AND SC6.%notdel%
			    AND SC5.%notdel%
	EndSql
	DbSelectArea(cSC5Alias)

	oReport := reportDef()
  	oReport:nDevice := IMP_PDF
  	oReport:printDialog()

  	//FreeObj(oReport)
  	//FreeObj(oSection)
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} reportDef
Função que monta o relatório
@type function
@version 1.0
@author Cod.ERP
@since 31/05/2022
@return oReport
/*/
//-------------------------------------------------------------------
static function reportDef()
	local oReport
	Local oSection1
	Local oSection2
	local cTitulo := 'AUDITLOG - Relatório de Movimentações nos Pedidos de Vendas'
	Local cFile := 'RFATRANS'


	oReport := TReport():New(cFile, cTitulo, , {|oReport| oSection1:Print()},"Impressão de Relatório de Movimentações nos Pedidos de Vendas")
	oReport:SetPortrait()
	//Primeira sessssão contendo os dados do vendedor
	oSection1:= TRSection():New(oReport, "PEDIDOS DE VENDAS", {"cSC5Alias"}, , .F., .T., , , ,.F., .F.)
	oSection1:SetHeaderBreak(.T.)
	oSection1:SetHeaderSection(.T.)

	TRCell():New(oSection1, "C5_FILIAL", "cSC5Alias", 'FILIAL'	,PesqPict('SC5',"C5_FILIAL"),TamSX3("C5_FILIAL")[1]+1,,,"LEFT")
	TRCell():New(oSection1, "C5_CONDPAG", "cSC5Alias", 'AÇÃO'	,PesqPict('SC5',"C5_CONDPAG"),TamSX3("C5_CONDPAG")[1]+1,,,"LEFT")
	TRCell():New(oSection1, "C5_VEND1"	, "cSC5Alias", 'USUÁRIO'	,PesqPict('SC5',"C5_VEND1"),TamSX3("C5_VEND1")[1]+1,,,"LEFT")
	TRCell():New(oSection1, "C5_CLIENTE"	, "cSC5Alias", 'N_PEDIDO'	,PesqPict('SC5',"C5_CLIENTE"),TamSX3("C5_CLIENTE")[1]+1,,,"LEFT")


	/*oSection2:= TRSection():New(oReport, " ", {"QRY"},NIL, .F., .T., , , ,.F., .F.)

	TRCell():New(oSection2, "ZAL_ITEM"	, "QRY", 'ITEM'	,PesqPict('ZAL',"ZAL_ITEM"),TamSX3("ZAL_ITEM")[1]+1,,,"LEFT")
	TRCell():New(oSection2, "ZAL_PROD"	, "QRY", 'PRODUTO'	,PesqPict('ZAL',"ZAL_PROD"),TamSX3("ZAL_PROD")[1]+1,,,"LEFT")
	TRCell():New(oSection2, "ZAL_DESCRI"	, "QRY", 'DESCRIÇÃO'	,PesqPict('ZAL',"ZAL_DESCRI"),TamSX3("ZAL_DESCRI")[1]+1,,,"LEFT")
	TRCell():New(oSection2, "ZAL_TPPROD"	, "QRY", 'TP_PROD'	,PesqPict('ZAL',"ZAL_TPPROD"),TamSX3("ZAL_TPPROD")[1]+1,,,"LEFT")
	TRCell():New(oSection2, "ZAL_QNTD"	, "QRY", 'QUANTIDADE'	,PesqPict('ZAL',"ZAL_QNTD"),TamSX3("ZAL_QNTD")[1]+1,,,"LEFT")
	TRCell():New(oSection2, "ZAL_PRCVEN"	, "QRY", 'PRC_UNIT'	,PesqPict('ZAL',"ZAL_PRCVEN"),TamSX3("ZAL_PRCVEN")[1]+1,,,"LEFT")
	TRCell():New(oSection2, "ZAL_VALOR"	, "QRY", 'VLR_TOTAL'	,PesqPict('ZAL',"ZAL_VALOR"),TamSX3("ZAL_VALOR")[1]+1,,,"LEFT")
	TRCell():New(oSection2, "ZAL_CONDPA"	, "QRY", 'C_PAG'	,PesqPict('ZAL',"ZAL_CONDPA"),TamSX3("ZAL_CONDPA")[1]+1,,,"LEFT")
	TRCell():New(oSection2, "ZAL_CPDESC"	, "QRY", 'COND_PAG'	,PesqPict('ZAL',"ZAL_CPDESC"),TamSX3("ZAL_CPDESC")[1]+1,,,"LEFT")
	TRCell():New(oSection2, "ZAL_DESC1"	, "QRY", 'DESCONTO'	,PesqPict('ZAL',"ZAL_DESC1"),TamSX3("ZAL_DESC1")[1]+1,,,"LEFT")
	TRCell():New(oSection2, "ZAL_PESOL"	, "QRY", 'P_LIQ'	,PesqPict('ZAL',"ZAL_PESOL"),TamSX3("ZAL_PESOL")[1]+1,,,"LEFT")
	TRCell():New(oSection2, "ZAL_PBRUTO"	, "QRY", 'P_BRUT'	,PesqPict('ZAL',"ZAL_PBRUTO"),TamSX3("ZAL_PBRUTO")[1]+1,,,"LEFT")
	TRCell():New(oSection2, "ZAL_STATUS"	, "QRY", 'STATUS'	,PesqPict('ZAL',"ZAL_STATUS"),TamSX3("ZAL_STATUS")[1]+1,,,"LEFT")
	TRCell():New(oSection2, "ZAL_NFC"	, "QRY", 'C_NFC'	,PesqPict('ZAL',"ZAL_NFC"),TamSX3("ZAL_NFC")[1]+1,,,"LEFT")*/

	//TRCell():new(oSection1, "F2_PLIQUI"	, "QRY", 'PESO'	,PesqPict('SF2',"F2_PLIQUI"),TamSX3("F2_PLIQUI")[1]+20,,,"LEFT")
return (oReport)

Static Function PrintReport(oReport)
	Local oSection1 := oReport:Section(1)
	//Local oSection2 := oReport:Section(2)
	DbSelectArea('cSC5Alias')
	dbGoTop()
	oReport:SetMeter(cSC5Alias->(RecCount()))

	While cSC5Alias->(!Eof())
		If oReport:Cancel()
			Exit
		EndIf
		oReport:IncMeter()
		cVerify := cSC5Alias->C5_NUM
		//IncProc("Imprimindo Relatório "+cSC5Alias->C5_NUM)
		oSection1:Init()

			//imprimo a primeira sessão
			oSection1:Cell("C5_FILIAL"):SetValue(cSC5Alias->C5_FILIAL)
			oSection1:Cell("C5_FILIAL"):SetAlign("LEFT")
			oSection1:Cell("C5_CONDPAG"):SetValue(cSC5Alias->C5_CONDPAG)
			oSection1:Cell("C5_CONDPAG"):SetAlign("LEFT")
			oSection1:Cell("C5_VEND1"):SetValue(cSC5Alias->C5_VEND1)
			oSection1:Cell("C5_VEND1"):SetAlign("LEFT")
			oSection1:Cell("C5_CLIENTE"):SetValue(cSC5Alias->C5_CLIENTE)
			oSection1:Cell("C5_CLIENTE"):SetAlign("RIGHT")
			oSection1:Printline()
			oSection1:Finish()
			


		/*While TEMP1->ZAL_NUM == cVerify
		oSection2:SetHeaderSection(.T.)
	oSection2:SetHeaderBreak(.F.)

		oSection2:Init()
		oSection2:Cell("ZAL_ITEM"):SetValue(TEMP1->ZAL_ITEM)
		oSection2:Cell("ZAL_ITEM"):SetAlign("LEFT")
		oSection2:Cell("ZAL_PROD"):SetValue(TEMP1->ZAL_PROD)
		oSection2:Cell("ZAL_PROD"):SetAlign("LEFT")
		oSection2:Cell("ZAL_DESCRI"):SetValue(TEMP1->ZAL_DESCRI)
		oSection2:Cell("ZAL_DESCRI"):SetAlign("LEFT")
		oSection2:Cell("ZAL_TPPROD"):SetValue(TEMP1->ZAL_TPPROD)
		oSection2:Cell("ZAL_TPPROD"):SetAlign("LEFT")
		oSection2:Cell("ZAL_QNTD"):SetValue(TEMP1->ZAL_QNTD)
		oSection2:Cell("ZAL_QNTD"):SetAlign("LEFT")
		oSection2:Cell("ZAL_PRCVEN"):SetValue(TEMP1->ZAL_PRCVEN)
		oSection2:Cell("ZAL_PRCVEN"):SetAlign("LEFT")
		oSection2:Cell("ZAL_VALOR"):SetValue(TEMP1->ZAL_VALOR)
		oSection2:Cell("ZAL_VALOR"):SetAlign("LEFT")
		oSection2:Cell("ZAL_CONDPA"):SetValue(TEMP1->ZAL_CONDPA)
		oSection2:Cell("ZAL_CONDPA"):SetAlign("LEFT")
		oSection2:Cell("ZAL_CPDESC"):SetValue(TEMP1->ZAL_CPDESC)
		oSection2:Cell("ZAL_CPDESC"):SetAlign("LEFT")
		oSection2:Cell("ZAL_DESC1"):SetValue(TEMP1->ZAL_DESC1)
		oSection2:Cell("ZAL_DESC1"):SetAlign("LEFT")
		oSection2:Cell("ZAL_PESOL"):SetValue(TEMP1->ZAL_PESOL)
		oSection2:Cell("ZAL_PESOL"):SetAlign("LEFT")
		oSection2:Cell("ZAL_PBRUTO"):SetValue(TEMP1->ZAL_PBRUTO)
		oSection2:Cell("ZAL_PBRUTO"):SetAlign("LEFT")
		oSection2:Cell("ZAL_STATUS"):SetValue(TEMP1->ZAL_STATUS)
		oSection2:Cell("ZAL_STATUS"):SetAlign("LEFT")
		oSection2:Cell("ZAL_NFC"):SetValue(TEMP1->ZAL_NFC)
		oSection2:Cell("ZAL_NFC"):SetAlign("LEFT")
		oSection2:Printline()
		oSection2:Finish()

		
		oReport:SkipLine(3)
		Enddo*/
		cSC5Alias->(DbSkip())
	Enddo

	cSC5Alias->(DbCloseArea())
Return
