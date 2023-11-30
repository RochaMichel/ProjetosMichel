//Bibliotecas
#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#include "TopConn.ch"
#include "Color.ch"
#include "COLORS.ch"

#DEFINE SM0_FILIAL	02
#DEFINE SM0_NREDUZ 07

#define CLR_SILVER rgb(192,192,192)
#define CLR_LIGHTGRAY rgb(220,220,220)
////////////////////
/// Ita - 26/08/2022
///       fDemReceitas - Demonstrativos Anual de Receitas e Despesas
///       https://tdn.totvs.com/display/public/framework/FWMsPrinterz
/////////////////////////////////////////////////////////////////////

User Function fDemReceitas
	Local oReport
	Private _Enter    := chr(13) + Chr(10)
	Private aOrdem    := {}
	Private cAliasTop := GetNextAlias()
	Private oRelARD
	Private _lBold := .F. //Controle de IMpressão em NEgrito
	Private _nSize := TamSX3("E5_VALOR")[1]
	Private _lPixel := .F.
	Private lAutoSize := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= fRunRecDes()
	oReport:PrintDialog()
Return

Static Function fRunRecDes

	cPerg     := "XRELARD"
	Gera_SX1(cPerg)
	_cTitulo  := "Demonstrativo Anual das Receitas/Despesas"
	oReport:= TReport():New("fRunRecDes",_cTitulo,cPerg, {|oReport| ReportPrint(oReport,aOrdem,cAliasTop)},_cTitulo)
	oReport:SetLandscape()

	//Parametriza o TReport para alinhamento a direita
	oReport:SetRightAlignPrinter(.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criacao da Sessao 1                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oRelARD:= TRSection():New(oReport,_cTitulo,{"SED","SE5"} ,aOrdem)

	oRelARD:SetTotalInLine(.F.)
	//Ajusta o tamanho das células para que caiba em uma página.
	//oRelARD:lAutoSize := .F.

	//New(oParent,cName           ,cAlias,cTitle,cPicture                       ,nSize                    ,lPixel    ,bBlock                           ,cAlign ,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize      ,nClrBack  ,nClrFore ,lBold)
	TRCell():New(oRelARD,'CONTA'         ,''    ,      ,PesqPict("SED", "ED_CODIGO")   ,TamSX3("ED_CODIGO")[1]   ,/*lPixel*/,/*{|| code-block de impressao }*/, "LEFT",          ,"LEFT"      ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelARD,'DESCRIÇÃO'     ,''    ,      ,PesqPict("SED", "ED_DESCRIC")  ,22	                     ,/*lPixel*/,/*{|| code-block de impressao }*/, "LEFT",          ,"LEFT"      ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelARD,'ORG'           ,''    ,      ,"@!"                           ,3   	                 ,/*lPixel*/,/*{|| code-block de impressao }*/, "LEFT",          ,"LEFT"      ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelARD,'JANEIRO'       ,''    ,      ,PesqPict("SE5", "E5_VALOR")    ,14	                     ,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelARD,'FEVEREIRO'     ,''    ,      ,PesqPict("SE5", "E5_VALOR")    ,14	                     ,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelARD,'MARÇO'         ,''    ,      ,PesqPict("SE5", "E5_VALOR")    ,14	                     ,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelARD,'ABRIL'         ,''    ,      ,PesqPict("SE5", "E5_VALOR")    ,14	                     ,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelARD,'MAIO'          ,''    ,      ,PesqPict("SE5", "E5_VALOR")    ,14	                     ,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelARD,'JUNHO'         ,''    ,      ,PesqPict("SE5", "E5_VALOR")    ,14	                     ,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelARD,'JULHO'         ,''    ,      ,PesqPict("SE5", "E5_VALOR")    ,14	                     ,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelARD,'AGOSTO'        ,''    ,      ,PesqPict("SE5", "E5_VALOR")    ,14	                     ,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelARD,'SETEMBRO'      ,''    ,      ,PesqPict("SE5", "E5_VALOR")    ,14	                     ,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelARD,'OUTUBRO'       ,''    ,      ,PesqPict("SE5", "E5_VALOR")    ,14	                     ,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelARD,'NOVEMBRO'      ,''    ,      ,PesqPict("SE5", "E5_VALOR")    ,14	                     ,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)
	TRCell():New(oRelARD,'DEZEMBRO'      ,''    ,      ,PesqPict("SE5", "E5_VALOR")    ,14	                     ,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",         ,"RIGHT"     ,           ,        ,lAutoSize      ,CLR_SILVER,CLR_BLACK,_lBold)

Return(oReport)

Static Function ReportPrint(oReport,aOrdem,cAliasTop)

	Local nPrc, nMs, nX, nFil
	Local cOrderBy  := ''
	Local oRelARD	:= oReport:Section(1)
	Local cIndexkey	:= ''
	Local nOrdem   	:= oRelARD:GetOrder()
	Local cFilUser  := oReport:Section(1):GetAdvplExp()


	Private cFilSEDUser := oRelARD:GetSqlExp("SED")
	Private cFilSE5User := oRelARD:GetSqlExp("SE5")

	Private aMesesVl := {}
	Private cCpoOrg := ""

	Pergunte(oReport:uParam,.F.)
	//MakeSqlExpr(oReport:uParam)
	MakeSqlExpr(oReport:GetParam())

	_DaData  := MV_PAR01
	_AteData := MV_PAR02
	_cDaNat  := MV_PAR03
	_cAteNat := MV_PAR04
	_cDaFil  := MV_PAR05
	_cAteFil := MV_PAR06
	_nRecDes := MV_PAR07

	oReport:cTitle := "Demonstrativo Anual das "+If(_nRecDes == 1,"Receitas","Despesas")+" Ano Base: "+cValToChar(Year(_DaData))+" Origem: REALIZADO"

	//              1  2  3  4  5  6  7  8  9 10 11 12
	aNatTotais := { 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00 }
	//For nFil := 1 To Len(aFiliais)

	For nPrc := 1 To 2

		If nPrc == 1
			cQrySED := " SELECT COUNT(*) XQTDREG " + _Enter
		Else
			cQrySED := " SELECT SED.* " + _Enter
		EndIf

		cQrySED += "   FROM "+RetSQLName("SED")+" SED " + _Enter

		cQrySED += "  WHERE SED.ED_FILIAL BETWEEN '"+_cDaFil+"' AND '"+_cAteFil+"' " + _Enter
		cQrySED += "    AND SED.ED_CODIGO BETWEEN '"+_cDaNat+"' AND '"+_cAteNat+"' " + _Enter
		If _nRecDes == 1
			cCpoOrg := "CRE"
			cQrySED += "    AND SED.ED_COND = 'R' " + _Enter
		Else
			cCpoOrg := "DEV"
			cQrySED += "    AND SED.ED_COND = 'D' " + _Enter
		EndIf
		cQrySED += "    AND SED.D_E_L_E_T_ <> '*' " + _Enter

		If !Empty(cFilSEDUser)
			cQry += " AND ( "+cFilSEDUser + " ) " + _Enter
		Endif

		If nPrc > 1
			cQrySED += " ORDER BY SED.ED_FILIAL, SED.ED_CODIGO ASC " + _Enter
		EndIf

		MemoWrite("C:\TEMP\fRunRecDes.SQL",cQrySED)
		MemoWrite("fRunRecDes.SQL",cQrySED)

		TCQuery cQrySED NEW ALIAS "NATSED"

		If nPrc == 1

			TCSetField("NATSED","XQTDREG","N",10,00)
			DbSelectArea("NATSED")
			nRegPrc := NATSED->XQTDREG
			DbCloseArea()

		EndIf

	Next nPrc

	oReport:SetMeter(nRegPrc) //-> Indica quantos registros serao processados para a regua ³
	nCt := 1
	Do While !oReport:Cancel() .And. !NATSED->(Eof())

		oReport:IncMeter()
		oRelARD:Init()
		oReport:SetMsgPrint( "Calculando Naturezas ... "+cValToChar(nCt)+" / "+cValToChar(nRegPrc) )

		_aMeses := {{"01","JANEIRO"},{"02","FEVEREIRO"},{"03","MARÇO"},{"04","ABRIL"},{"05","MAIO"},{"06","JUNHO"},{"07","JULHO"},{"08","AGOSTO"},{"09","SETEMBRO"},{"10","OUTUBRO"},{"11","NOVEMBRO"},{"12","DEZEMBRO"}}
		aMesesVl:= {{"01",0.00},{"02",0.00},{"03",0.00},{"04",0.00},{"05",0.00},{"06",0.00},{"07",0.00},{"08",0.00},{"09",0.00},{"10",0.00},{"11",0.00},{"12",0.00}}
		//fGetVlrNat(NATSED->ED_CODIGO,aFiliais[nFil,1]) //Obtém o valor total da natureza dentro do período selecionado
		fGetVlrNat(NATSED->ED_CODIGO,NATSED->ED_FILIAL) //Obtém o valor total da natureza dentro do período selecionado


		If NATSED->ED_TIPO == "1" //Se For uma Conta Sintética, imprime a linha com fonte em negrito

			oRelARD:Cell('CONTA'):nClrBack := CLR_LIGHTGRAY
			oRelARD:Cell('DESCRIÇÃO'):nClrBack := CLR_LIGHTGRAY
			oRelARD:Cell('ORG'):nClrBack := CLR_LIGHTGRAY

			oRelARD:Cell('CONTA'):LBOLD := .T. //Negrito
			oRelARD:Cell('DESCRIÇÃO'):LBOLD := .T. //Negrito
			oRelARD:Cell('ORG'):LBOLD := .T. //Negrito

			oRelARD:Cell('CONTA'):SetValue(NATSED->ED_CODIGO)
			oRelARD:Cell('DESCRIÇÃO'):SetValue(NATSED->ED_DESCRIC)
			oRelARD:Cell('ORG'):SetValue(cCpoOrg)

			For nMs := 1 To 12
				nPosMes := aScan(_aMeses, {|x| x[1] == StrZero(nMs,2)})
				oRelARD:Cell(_aMeses[nPosMes,2]):nClrBack := CLR_LIGHTGRAY
				oRelARD:Cell(_aMeses[nPosMes,2]):nClrFore := CLR_BLACK
				oRelARD:Cell(_aMeses[nPosMes,2]):LBOLD := .T. //Negrito
				//oRelARD:Cell(_aMeses[nPosMes,2]):SetSize(_nSize,_lPixel)
				oRelARD:Cell(_aMeses[nPosMes,2]):SetPicture(PesqPict("SE5", "E5_VALOR"))
				oRelARD:Cell(_aMeses[nPosMes,2]):SetValue(aMesesVl[nMs,2])
				If Len(Alltrim(NATSED->ED_CODIGO)) == 2
					//aNatTotais[nMs] := aNatTotais[nMs] + aMesesVl[nMs,2]
					aNatTotais[nMs] += aMesesVl[nMs,2]
				EndIf
			Next nMs

		Else

			oRelARD:Cell('CONTA'):nClrBack := CLR_WHITE
			oRelARD:Cell('DESCRIÇÃO'):nClrBack := CLR_WHITE
			oRelARD:Cell('ORG'):nClrBack := CLR_WHITE

			oRelARD:Cell('CONTA'):LBOLD := .F.
			oRelARD:Cell('DESCRIÇÃO'):LBOLD := .F.
			oRelARD:Cell('ORG'):LBOLD := .F.

			oRelARD:Cell('CONTA'):SetValue(NATSED->ED_CODIGO)
			oRelARD:Cell('DESCRIÇÃO'):SetValue(NATSED->ED_DESCRIC)
			oRelARD:Cell('ORG'):SetValue(cCpoOrg)

			For nMs := 1 To 12
				nPosMes := aScan(_aMeses, {|x| x[1] == StrZero(nMs,2)})
				oRelARD:Cell(_aMeses[nPosMes,2]):LBOLD := .F. //Retira Negrito
				oRelARD:Cell(_aMeses[nPosMes,2]):nClrBack := CLR_WHITE
				//oRelARD:Cell(_aMeses[nPosMes,2]):nClrFore := CLR_BLACK
				oRelARD:Cell(_aMeses[nPosMes,2]):SetPicture(PesqPict("SE5", "E5_VALOR"))
				oRelARD:Cell(_aMeses[nPosMes,2]):SetValue(aMesesVl[nMs,2])
				//oPrint:Say(nRow+25, nMesCol, Transform(aMesesVl[nMs,2],cPicValor),	 oFont10n)                           //Imprime os Meses do Ano
				If Len(Alltrim(NATSED->ED_CODIGO)) == 2
					//aNatTotais[nMs] := aNatTotais[nMs] + aMesesVl[nMs,2]
					aNatTotais[nMs] += aMesesVl[nMs,2]
				EndIf
			Next nMs

		EndIf

		oRelARD:Printline()
		oReport:SkipLine() //-- Salta Linha

		oRelARD:Cell('CONTA'):nClrBack := CLR_WHITE
		oRelARD:Cell('DESCRIÇÃO'):nClrBack := CLR_WHITE
		oRelARD:Cell('ORG'):nClrBack := CLR_WHITE

		oRelARD:Cell('CONTA'):LBOLD := .F.
		oRelARD:Cell('DESCRIÇÃO'):LBOLD := .F.
		oRelARD:Cell('ORG'):LBOLD := .F.


		For nMs := 1 To 12
			nPosMes := aScan(_aMeses, {|x| x[1] == StrZero(nMs,2)})
			oRelARD:Cell(_aMeses[nPosMes,2]):LBOLD := .F. //Retira Negrito
			//oRelARD:Cell(_aMeses[nPosMes,2]):nClrBack := CLR_WHITE
			//oRelARD:Cell(_aMeses[nPosMes,2]):nClrFore := CLR_BLACK
		Next nMs


		DbSelectArea("NATSED")
		DbSkip()
		nCt ++

	EndDo
	DbSelectArea("NATSED")
	DbCloseArea()

	oRelARD:Cell('CONTA'):nClrBack := CLR_SILVER
	oRelARD:Cell('DESCRIÇÃO'):nClrBack := CLR_SILVER
	oRelARD:Cell('ORG'):nClrBack := CLR_SILVER

	oRelARD:Cell('CONTA'):LBOLD := .T. //Negrito
	oRelARD:Cell('DESCRIÇÃO'):LBOLD := .T. //Negrito
	oRelARD:Cell('ORG'):LBOLD := .T. //


	oRelARD:Cell('CONTA'):SetValue(SPACE(TamSX3("ED_CODIGO")[1]))
	oRelARD:Cell('DESCRIÇÃO'):SetValue('Totais Naturezas...')
	oRelARD:Cell('ORG'):SetValue(SPACE(3))
	For nMs := 1 To 12
		//nPosMes := aScan(_aMeses, {|x| x[1] == StrZero(nMs,2)})
		oRelARD:Cell(_aMeses[nMs,2]):nClrBack := CLR_SILVER
		oRelARD:Cell(_aMeses[nMs,2]):nClrFore := CLR_BLACK
		oRelARD:Cell(_aMeses[nMs,2]):LBOLD := .T. //Define Negrito
		oRelARD:Cell(_aMeses[nMs,2]):SetPicture(PesqPict("SE5", "E5_VALOR"))
		oRelARD:Cell(_aMeses[nMs,2]):SetValue(aNatTotais[nMs])
		//oRelARD:Cell(_aMeses[nPosMes,2]):LBOLD := .F. //Retira Negrito
		//oRelARD:Cell(_aMeses[nPosMes,2]):SetValue(aNatTotais[nMs])
	Next

	oRelARD:Printline()

	//Next nFil
	oRelARD:Finish()

Return


/******************************************************************************************************************************************************************
******************************************************************************************************************************************************************
******************************************************************************************************************************************************************/

/////////////////////
/// Ita - 26/08/2022
///     - Função fGetVlrNat - Obtém o Valor Total da
///                            natureza no período informado.
/////////////////////////////////////////////////////////////////////// 
Static Function fGetVlrNat(cNatSint,pFilial)
    
    nTamSED := Len(Alltrim(cNatSint))

	cQrySint := " select SUBSTRING(SE5.E5_DATA,1,6) ANOMES, SUM(CASE WHEN SE5.E5_TIPODOC = 'PA' AND SE5.E5_TIPO = '  ' THEN 0 ELSE SE5.E5_VALOR END) VLRSINT"+ _Enter

	//cQrySint += " - COALESCE(( SELECT SUM(E5.E5_VALOR) " + _Enter 
	//cQrySint += " FROM "+RetSQLName("SE5")+" E5 " +_Enter
	//cQrySint += " WHERE E5.E5_FILORIG = '"+pFilial+"' " +_Enter 
	//cQrySint += " AND SUBSTRING(E5.E5_NATUREZ,1,"+cValToChar(nTamSED)+") = 'SUBSTRING(SE5.E5_NATUREZ,1,"+cValToChar(nTamSED)+")'" + _Enter
	//cQrySint += " AND E5.E5_DATA BETWEEN '"+DTOS(_DaData)+"' AND '"+DTOS(_AteData)+"' "+ _Enter
	////cQrySint += " AND E5.E5_TIPO <> '' AND E5.E5_TIPODOC = 'ES' AND E5.E5_BANCO <> '' AND E5.D_E_L_E_T_ <> '*' ),0) VLRSINT"+ _Enter
	//cQrySint += " AND E5.E5_TIPODOC = 'ES' AND E5.E5_BANCO <> '' AND E5.D_E_L_E_T_ <> '*' ),0) VLRSINT"+ _Enter

	cQrySint += " FROM SE5010 SE5 "+ _Enter
	//Adicionado para desconisderar os estornos
	cQrySint += "LEFT JOIN SE5010 SE5A ON SE5.E5_FILIAL = SE5A.E5_FILIAL "
	cQrySint += "AND SE5.E5_PREFIXO = SE5A.E5_PREFIXO "
	cQrySint += "AND SE5.E5_NUMERO	   = SE5A.E5_NUMERO "
	cQrySint += "AND SE5.E5_PARCELA = SE5A.E5_PARCELA "
	cQrySint += "AND SE5.E5_TIPO    = SE5A.E5_TIPO "
	cQrySint += "AND SE5.E5_CLIENTE = SE5A.E5_CLIENTE "
	cQrySint += "AND SE5.E5_LOJA    = SE5A.E5_LOJA "
    cQrySint += "AND SE5.E5_SEQ = SE5A.E5_SEQ "
    cQrySint += "AND SE5.E5_DOCUMEN = SE5A.E5_DOCUMEN "
    cQrySint += "AND SE5.E5_NUMCHEQ = SE5A.E5_NUMCHEQ "
    cQrySint += "AND SE5A.E5_TIPODOC = 'ES' "
	cQrySint += "AND SE5A.D_E_L_E_T_ <> '*' "
	//Fim
	cQrySint += " WHERE  SUBSTRING(SE5.E5_NATUREZ,1,"+cValToChar(nTamSED)+") = '"+Alltrim(cNatSint)+"'"+ _Enter
	cQrySint += " AND SE5.D_E_L_E_T_ <> '*' "+ _Enter
	cQrySint += " AND SE5.E5_DATA BETWEEN '"+DTOS(_DaData)+"' AND '"+DTOS(_AteData)+"' "+ _Enter
	cQrySint += " AND SE5.E5_FILORIG = '"+pFilial+"' "+ _Enter
	cQrySint += " AND SE5.E5_BANCO <> '' "+ _Enter
	cQrySint += " AND SE5.E5_MOVCX <> 'S' "+ _Enter
	cQrySint += " AND SE5.E5_NATUREZ NOT IN ('01001006','01001010','03005004','04007006') "+ _Enter
	cQrySint += " AND SE5.E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','ES','BA')" + _Enter
	cQrySint += " AND ( ( SE5.E5_TIPODOC = 'EP' AND NOT EXISTS  ( SELECT seh.eh_numero " + _Enter
	cQrySint += "                                                 	FROM SEH010 seh " + _Enter
	cQrySint += "                                                 	WHERE seh.eh_filial = se5.e5_filial AND seh.eh_numero = SUBSTRING(se5.e5_documen,1,6) " + _Enter
	cQrySint += "                                                 		AND seh.d_e_l_e_t_ = ' ' ) ) OR SE5.E5_TIPODOC <> 'EP' )  " + _Enter
	cQrySint += " AND ( ( SE5.E5_TIPODOC = 'PE' AND NOT EXISTS  ( SELECT sei.ei_numero " + _Enter
	cQrySint += "                                                 	FROM SEI010 sei " + _Enter
	cQrySint += "                                                 	WHERE sei.ei_filial = se5.e5_filial AND sei.ei_numero = SUBSTRING(se5.e5_documen,1,3) " + _Enter
	cQrySint += "                                                 		AND sei.d_e_l_e_t_ = ' ' ) ) OR SE5.E5_TIPODOC <> 'PE' )     " + _Enter
	cQrySint += " AND ( ( SE5.E5_TIPODOC = 'CH' AND (SELECT COUNT(*) " + _Enter
	cQrySint += "                                    	FROM SEF010 EF " + _Enter
	cQrySint += "                                    	WHERE EF.EF_FILIAL = SE5.E5_FILIAL AND EF.EF_BANCO = SE5.E5_BANCO " + _Enter
	cQrySint += "                                    		AND EF.EF_CONTA = SE5.E5_CONTA AND EF.EF_AGENCIA = SE5.E5_AGENCIA " + _Enter
	cQrySint += "                                    		AND EF.EF_NUM = SE5.E5_NUMCHEQ AND EF.D_E_L_E_T_ <> '*') > 0 ) OR SE5.E5_TIPODOC <> 'CH' ) " + _Enter
	
	If _nRecDes == 1
		cQrySint += "    AND SE5.E5_RECPAG = 'R' " + _Enter
	Else
		cQrySint += "    AND SE5.E5_RECPAG = 'P' " + _Enter
	EndIf
	
	cQrySint += " AND SE5.E5_SITUACA NOT IN ('C','E','X') "+ _Enter

	cQrySint += " AND SE5A.E5_FILIAL IS NULL "+ _Enter
	
	cQrySint += " GROUP BY SUBSTRING(SE5.E5_DATA,1,6) "+ _Enter
	cQrySint += " ORDER BY SUBSTRING(SE5.E5_DATA,1,6) ASC "+ _Enter

	MemoWrite("C:\TEMP\fdemreceitas.SQL",cQrySint)

    TCQuery cQrySint NEW ALIAS "XSE5"
    TCSetField("XSE5","VLRSINT","N",TamSX3("E5_VALOR")[1],TamSX3("E5_VALOR")[2])
    DbSelectArea("XSE5")
    While XSE5->(!Eof())
        nPMes := aScan(aMesesVl, {|x| x[1] == Substr(XSE5->ANOMES,5,2)})
        If nPMes > 0
            aMesesVl[nPMes,2] := XSE5->VLRSINT
        Endif
        XSE5->(DbSkip())
    EndDo
    XSE5->(DbCloseArea())

Return
 

Static Function Gera_SX1(_cPerg)

	Local _aArea := GetArea()
	Local aRegs := {}
	Local i,j

	dbSelectArea("SX1")
	dbSetOrder(1)
	_cPerg := PADR(_cPerg,10)

	//-- Cria as perguntas.

	aAdd(aRegs,{_cPerg,"01","De ?"                  ,"","","mv_ch1","D",TamSX3("E5_DATA")[1]   ,0   ,0 ,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""      })
	aAdd(aRegs,{_cPerg,"02","Até ?"                 ,"","","mv_ch2","D",TamSX3("E5_DATA")[1]   ,0   ,0 ,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""      })
    aAdd(aRegs,{_cPerg,"03","Da Natureza ?"         ,"","","mv_ch3","C",TamSX3("ED_CODIGO")[1] ,0   ,0 ,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SED"   })
    aAdd(aRegs,{_cPerg,"04","Até Natureza ?"        ,"","","mv_ch4","C",TamSX3("ED_CODIGO")[1] ,0   ,0 ,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SED"   })
    aAdd(aRegs,{_cPerg,"05","Da Filial ?"           ,"","","mv_ch5","C",Len(xFilial())         ,0   ,0 ,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SM0"   })
    aAdd(aRegs,{_cPerg,"06","Até Filial?"           ,"","","mv_ch6","C",Len(xFilial())         ,0   ,0 ,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SM0"   })
    aAdd(aRegs,{_cPerg,"07","Tipo Relatorio ?"      ,"","","mv_ch7","N",1                      ,0   ,0 ,"C","","mv_par07","Receitas","","","","","Despesas","","","","","","","","","","","","","","","","","","",""})


	For i:=1 to Len(aRegs)
		If !dbSeek(_cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
	RestArea(_aArea)
Return
