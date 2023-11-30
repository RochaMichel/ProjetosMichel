#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"

*******************************************************************************
// Função : RELFATM - rel. recorrência de vendas mês a mês           		  |
// Modulo : FATURAMENTO                                                       |
// Fonte  : RELFATM.prw                                                       |
// ---------+--------------------------+--------------------------------------+
// Data     | Autor             	   | Descricao                            |
// ---------+--------------------------+--------------------------------------+
// 09/02/23 | Lucas	Antônio - Cod.ERP  | Relatório			                  |
*******************************************************************************

#define CLR_LIGHTGRAY rgb(220,220,220)
#define CLR_LightSteelBlue rgb(176,196,222)

User Function RELFATM()
	PRIVATE cTitulo     := 'Relatorio de recorrência de vendas mês a mês'
	PRIVATE cDescri     := ""
	PRIVATE cFunName    := FunName()
	PRIVATE oRelatorio
	PRIVATE aPergs      := {}
	Private _lBold      := .T. //Controle de IMpressÃ£o em NEgrito
	Private lAutoSize   := .T.

	aAdd(aPergs, {1, "Da Filial"    ,space(TamSX3("A1_filial")[1]),PesqPict("SA1","A1_filial"),,,,TamSX3("A1_filial")[1], .F.}) //MV_PAR01
	aAdd(aPergs, {1, "Ate a Filial" ,space(TamSX3("A1_filial")[1]),PesqPict("SA1","A1_filial"),,,,TamSX3("A1_filial")[1], .T.}) //MV_PAR02
	aAdd(aPergs, {1, "Do Cliente"   ,space(TamSX3("A1_COD")[1]),PesqPict("SA1","A1_COD"),,"SA1",,TamSX3("A1_COD")[1], .F.}) //MV_PAR03
	aAdd(aPergs, {1, "Ate o Cliente",space(TamSX3("A1_COD")[1]),PesqPict("SA1","A1_COD"),,"SA1",,TamSX3("A1_COD")[1], .T.}) //MV_PAR04
	aAdd(aPergs, {1, "Data De"      ,Date()   , "", ".T.", "", ".T.", 80 , .F.}) //MV_PAR05
	aAdd(aPergs, {1, "Data Até "    ,Date()   , "", ".T.", "", ".T.", 80 , .T.}) //MV_PAR06

	If !parambox(aPergs,"Informe os parametros")
		Return
	EndIf

	oRelatorio  := TReport():New(cFunName, cTitulo,, {|oRelatorio| PrintReport(oRelatorio)}, cDescri, .T.)
	oRelatorio:SetCustomText({||CriaCab(oRelatorio)})
	oRelatorio:cFontBody := 'ARIAL'
	oRelatorio:nFontBody := 10

	oSection1   := TRSection():New(oRelatorio, cTitulo , {'SE1','SA1'})
	TRCell():New(oSection1,'CLIENTE'  ,'',,PesqPict("SA1","A1_NOME") ,TamSX3("A1_NOME")[1]+5 ,/*lPixel*/, ,"LEFT" , ,"LEFT" , ,-2,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'JANEIRO'  ,'',,PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+3,/*lPixel*/, ,"RIGHT", ,"RIGHT", ,-2,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'FEVEREIRO','',,PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+3,/*lPixel*/, ,"RIGHT", ,"RIGHT", ,-2,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'MARÇO'    ,'',,PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+3,/*lPixel*/, ,"RIGHT", ,"RIGHT", ,-2,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'ABRIL'    ,'',,PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+3,/*lPixel*/, ,"RIGHT", ,"RIGHT", ,-2,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'MAIO'     ,'',,PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+3,/*lPixel*/, ,"RIGHT", ,"RIGHT", ,-2,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'JUNHO'    ,'',,PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+3,/*lPixel*/, ,"RIGHT", ,"RIGHT", ,-2,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'JULHO'    ,'',,PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+3,/*lPixel*/, ,"RIGHT", ,"RIGHT", ,-2,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'AGOSTO'   ,'',,PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+3,/*lPixel*/, ,"RIGHT", ,"RIGHT", ,-2,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'SETEMBRO' ,'',,PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+3,/*lPixel*/, ,"RIGHT", ,"RIGHT", ,-2,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'OUTUBRO'  ,'',,PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+3,/*lPixel*/, ,"RIGHT", ,"RIGHT", ,-2,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'NOVEMBRO' ,'',,PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+3,/*lPixel*/, ,"RIGHT", ,"RIGHT", ,-2,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'DEZEMBRO' ,'',,PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+3,/*lPixel*/, ,"RIGHT", ,"RIGHT", ,-2,lAutoSize ,,  ,_lBold )
	TRCell():New(oSection1,'TOTAL' 	  ,'',,PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+3,/*lPixel*/, ,"RIGHT", ,"RIGHT", ,,lAutoSize ,,  ,_lBold )
	oRelatorio:printDialog()

Return

Static Function PrintReport(oRelatorio)
	Local oSection1  := oRelatorio:section(1)
	Local cQuebra	 := chr(13) + Chr(10)
	Local cQuery     := cQuery_SD1 := ""
	Local cCod       := ""
	Local cLoja      := cFil:= ""
	Local cNomeMes   := ""
	Local cDevNomeMes:= ""
	Local cCliente   := ""
	Local nJaneiro	 := nJulho    := nTotJan := nTotJul := nDevTotJan := nDevTotJul := 0
	Local nFevereiro := nAgosto   := nTotFev := nTotAgo := nDevTotFev := nDevTotAgo := 0
	Local nMarco	 := nSetembro := nTotMar := nTotSet := nDevTotMar := nDevTotSet := 0
	Local nAbril	 := nOutubro  := nTotAbr := nTotOut := nDevTotAbr := nDevTotOut := 0
	Local nMaio		 := nNovembro := nToTMai := nTotNov := nDevToTMai := nDevTotNov := 0
	Local nJunho	 := nDezembro := nTotJun := nTotDez := nDevTotJun := nDevTotDez := 0
	Local nDataMes   := nTotGeral := nDevTotGeral:= 0
	Local nTotalCli	 := nDevTotalCli:= 0
	
	cQuery+=" SELECT A1_COD COD, A1_LOJA LOJA, A1_NOME CLIENTE, D2_TOTAL VALOR, D2_EMISSAO DATA, D2_FILIAL FILIAL"+cQuebra
	cQuery+=" FROM "+RetSqlName("SA1")+" SA1 														    		 "+cQuebra
	cQuery+=" INNER JOIN "+RetSqlName('SD2')+" SD2 ON SA1.A1_COD = SD2.D2_CLIENTE AND SA1.A1_LOJA = SD2.D2_LOJA	 "+cQuebra
	cQuery+=" INNER JOIN "+RetSqlName('SF4')+" SF4 ON SF4.F4_CODIGO = SD2.D2_TES  								 "+cQuebra
	cQuery+=" WHERE SA1.D_E_L_E_T_ <> '*'															  			 "+cQuebra
	cQuery+=" AND SD2.D_E_L_E_T_<> '*'																  			 "+cQuebra
	cQuery+=" AND SF4.D_E_L_E_T_<> '*'																  			 "+cQuebra
	cQuery+=" AND SUBSTRING(SD2.D2_CF,2,3) IN ('12 ','102','922','108') 										 "+cQuebra
	cQuery+=" AND SF4.F4_DUPLIC = 'S'					        												 "+cQuebra
	cQuery+=" AND A1_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'									  			 "+cQuebra
	cQuery+=" AND A1_FILIAL = '"+xFilial("SA1")+"' 													  			 "+cQuebra
	cQuery+=" AND D2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'								  			 "+cQuebra
	cQuery+=" AND D2_EMISSAO BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06)+"'					  			 "+cQuebra
	cQuery+=" GROUP BY A1_COD, A1_LOJA, D2_EMISSAO, D2_FILIAL, A1_NOME, D2_TOTAL			                	 "+cQuebra
	cQuery+=" ORDER BY A1_COD, A1_LOJA,D2_FILIAL, D2_EMISSAO													 "+cQuebra
	MpSysOpenQuery(cQuery,"RFATM")

	If RFATM->(Eof())
		DbSelectArea("RFATM")
		RFATM->(DbCloseArea())
		MsgInfo("Nenhum dado foi localizado com os parâmetros informados.","Atenção!")
		Return .F.
	EndIf

	RFATM->(dbGoTop())
	oRelatorio:SetMeter(RFATM->(RecCount()))
	
	//DbSelectArea("SD1")
	//SD1->(DbSetOrder(10))

	While RFATM->(!Eof())

		If oRelatorio:Cancel()
			Exit
		EndIf
 
		cCod := RFATM->COD
		cLoja:= RFATM->LOJA
		cFil := RFATM->FILIAL
		cCliente := AllTrim(RFATM->CLIENTE)

		nJaneiro	:= nJulho    :=	nDevJaneiro	    := nDevJulho    := 0
		nFevereiro	:= nAgosto   :=	nDevFevereiro	:= nDevAgosto   := 0 
		nMarco		:= nSetembro :=	nDevMarco		:= nDevSetembro := 0
		nAbril		:= nOutubro	 :=	nDevAbril		:= nDevOutubro	:= 0
		nMaio		:= nNovembro :=	nDevMaio		:= nDevNovembro := 0
		nJunho		:= nDezembro :=	nDevJunho		:= nDevDezembro := 0
		nTotalCli	:= 	nDevTotalCli:= 0

		While RFATM->(!Eof()) .And. RFATM->(COD+LOJA+FILIAL) == cCod+cLoja+cFil

			nDataMes := Month(STOD(RFATM->DATA))
			cNomeMes := MesExtenso(nDataMes)

			While RFATM->(!Eof()) .And. Month(STOD(RFATM->DATA)) == nDataMes

//------------------------- ( FATURAMENTO ) --------------------------------\\
				Do Case
					Case AllTrim(Upper(cNomeMes)) == 'JANEIRO'
						nJaneiro += RFATM->VALOR
						nTotJan += RFATM->VALOR
					Case AllTrim(Upper(cNomeMes)) == 'FEVEREIRO'
						nFevereiro += RFATM->VALOR
						nTotFev += RFATM->VALOR
					Case AllTrim(Upper(cNomeMes)) == 'MARCO'
						nMarco += RFATM->VALOR
						nTotMar += RFATM->VALOR
					Case AllTrim(Upper(cNomeMes)) == 'ABRIL'
						nAbril += RFATM->VALOR
						nTotAbr += RFATM->VALOR
					Case AllTrim(Upper(cNomeMes)) == 'MAIO'
						nMaio += RFATM->VALOR
						nToTMai += RFATM->VALOR
					Case AllTrim(Upper(cNomeMes)) == 'JUNHO'
						nJunho += RFATM->VALOR
						nTotJun += RFATM->VALOR
					Case AllTrim(Upper(cNomeMes)) == 'JULHO'
						nJulho += RFATM->VALOR
						nTotJul += RFATM->VALOR
					Case AllTrim(Upper(cNomeMes)) == 'AGOSTO'
						nAgosto += RFATM->VALOR
						nTotAgo += RFATM->VALOR
					Case AllTrim(Upper(cNomeMes)) == 'SETEMBRO'
						nSetembro += RFATM->VALOR
						nTotSet += RFATM->VALOR
					Case AllTrim(Upper(cNomeMes)) == 'OUTUBRO'
						nOutubro += RFATM->VALOR
						nTotOut += RFATM->VALOR
					Case AllTrim(Upper(cNomeMes)) == 'NOVEMBRO'
						nNovembro += RFATM->VALOR
						nTotNov += RFATM->VALOR
					Case AllTrim(Upper(cNomeMes)) == 'DEZEMBRO'
						nDezembro += RFATM->VALOR
						nTotDez += RFATM->VALOR
				EndCase
				nTotalCli += RFATM->VALOR
				RFATM->(DbSkip())
			End

		End

//------------------------- ( DEVOLUÇÕES ) --------------------------------\\
		cQuery_SD1:=" SELECT A1_COD COD, A1_LOJA LOJA, A1_NOME CLIENTE, D1_TOTAL VALOR, D1_EMISSAO DATA, D1_FILIAL FILIAL"+cQuebra
		cQuery_SD1+=" FROM "+RetSqlName("SA1")+" SA1 														    		 "+cQuebra
		cQuery_SD1+=" INNER JOIN "+RetSqlName('SD1')+" SD1 ON SA1.A1_COD = SD1.D1_FORNECE AND SA1.A1_LOJA = SD1.D1_LOJA	 "+cQuebra
		cQuery_SD1+=" INNER JOIN "+RetSqlName('SF4')+" SF4 ON SF4.F4_CODIGO = SD1.D1_TES 							     "+cQuebra
		cQuery_SD1+=" WHERE SA1.D_E_L_E_T_ <> '*'															  			 "+cQuebra
		cQuery_SD1+=" AND SD1.D_E_L_E_T_<> '*'																  			 "+cQuebra
		cQuery_SD1+=" AND SF4.D_E_L_E_T_<> '*'																  			 "+cQuebra
		cQuery_SD1+=" AND A1_COD = '"+cCod+"' 																  			 "+cQuebra
		cQuery_SD1+=" AND A1_LOJA = '"+cLoja+"' 																  		 "+cQuebra
		cQuery_SD1+=" AND D1_TIPO = 'D' 																		  		 "+cQuebra
		cQuery_SD1+=" AND SUBSTRING(SD1.D1_CF,2,3) IN ('32 ','202') 										 "+cQuebra
		cQuery_SD1+=" AND SF4.F4_DUPLIC = 'S'					        												 "+cQuebra
		cQuery_SD1+=" AND A1_FILIAL = '"+xFilial("SA1")+"' 													  			 "+cQuebra
		cQuery_SD1+=" AND D1_FILIAL = '"+cFil+"'															  			 "+cQuebra
		cQuery_SD1+=" AND D1_EMISSAO BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06)+"'					  			 "+cQuebra
		cQuery_SD1+=" GROUP BY A1_COD, A1_LOJA, D1_EMISSAO, D1_FILIAL, A1_NOME, D1_TOTAL			                	 "+cQuebra
		cQuery_SD1+=" ORDER BY A1_COD, A1_LOJA, D1_FILIAL, D1_EMISSAO													 "+cQuebra
		MpSysOpenQuery(cQuery_SD1,"RFATM_SD1")

		While RFATM_SD1->(!EOF()) .AND. RFATM_SD1->(COD+LOJA+FILIAL) == cCod+cLoja+cFil

			nDataMes_SD1 := Month(STOD(RFATM_SD1->DATA))
			cNomeMes_SD1 := MesExtenso(nDataMes_SD1)

			While RFATM_SD1->(!Eof()) .And. Month(STOD(RFATM_SD1->DATA)) == nDataMes_SD1

				cDevNomeMes := MesExtenso(Month(STOD(RFATM_SD1->DATA)))
				Do Case
					Case AllTrim(Upper(cDevNomeMes)) == 'JANEIRO'
						nDevJaneiro += RFATM_SD1->VALOR
						nDevTotJan += RFATM_SD1->VALOR
					Case AllTrim(Upper(cDevNomeMes)) == 'FEVEREIRO'
						nDevFevereiro += RFATM_SD1->VALOR
						nDevTotFev += RFATM_SD1->VALOR
					Case AllTrim(Upper(cDevNomeMes)) == 'MARCO'
						nDevMarco += RFATM_SD1->VALOR
						nDevTotMar += RFATM_SD1->VALOR
					Case AllTrim(Upper(cDevNomeMes)) == 'ABRIL'
						nDevAbril += RFATM_SD1->VALOR
						nDevTotAbr += RFATM_SD1->VALOR
					Case AllTrim(Upper(cDevNomeMes)) == 'MAIO'
						nDevMaio += RFATM_SD1->VALOR
						nDevToTMai += RFATM_SD1->VALOR
					Case AllTrim(Upper(cDevNomeMes)) == 'JUNHO'
						nDevJunho += RFATM_SD1->VALOR
						nDevTotJun += RFATM_SD1->VALOR
					Case AllTrim(Upper(cDevNomeMes)) == 'JULHO'
						nDevJulho += RFATM_SD1->VALOR
						nDevTotJul += RFATM_SD1->VALOR
					Case AllTrim(Upper(cDevNomeMes)) == 'AGOSTO'
						nDevAgosto += RFATM_SD1->VALOR
						nDevTotAgo += RFATM_SD1->VALOR
					Case AllTrim(Upper(cDevNomeMes)) == 'SETEMBRO'
						nDevSetembro += RFATM_SD1->VALOR
						nDevTotSet += RFATM_SD1->VALOR
					Case AllTrim(Upper(cDevNomeMes)) == 'OUTUBRO'
						nDevOutubro += RFATM_SD1->VALOR
						nDevTotOut += RFATM_SD1->VALOR
					Case AllTrim(Upper(cDevNomeMes)) == 'NOVEMBRO'
						nDevNovembro += RFATM_SD1->VALOR
						nDevTotNov += RFATM_SD1->VALOR
					Case AllTrim(Upper(cDevNomeMes)) == 'DEZEMBRO'
						nDevDezembro += RFATM_SD1->VALOR
						nDevTotDez += RFATM_SD1->VALOR
				EndCase
				nDevTotalCli += RFATM_SD1->VALOR
				RFATM_SD1->(DbSkip())
			End
		End
		//RFATM_SD1->(DbCloseArea())

		oSection1:Init()
		oSection1:Cell('CLIENTE'):SetValue(cFil+"-"+cCod+"-"+cLoja+" - "+cCliente)
		oSection1:Cell('JANEIRO'):SetValue((nJaneiro-nDevJaneiro))
		oSection1:Cell('FEVEREIRO'):SetValue((nFevereiro-nDevFevereiro))
		oSection1:Cell('MARÇO'):SetValue((nMarco-nDevMarco))
		oSection1:Cell('ABRIL'):SetValue((nAbril-nDevAbril))
		oSection1:Cell('MAIO'):SetValue((nMaio-nDevMaio))
		oSection1:Cell('JUNHO'):SetValue((nJunho-nDevJunho))
		oSection1:Cell('JULHO'):SetValue((nJulho-nDevJulho))
		oSection1:Cell('AGOSTO'):SetValue((nAgosto-nDevAgosto))
		oSection1:Cell('SETEMBRO'):SetValue((nSetembro-nDevSetembro))
		oSection1:Cell('OUTUBRO'):SetValue((nOutubro-nDevOutubro))
		oSection1:Cell('NOVEMBRO'):SetValue((nNovembro-nDevNovembro))
		oSection1:Cell('DEZEMBRO'):SetValue((nDezembro-nDevDezembro))
		oSection1:Cell('TOTAL'):SetValue((nTotalCli-nDevTotalCli))
		oSection1:Printline()
		//nTotGeral   += nTotalCli
	End
	oRelatorio:SkipLine() //-- Salta Linha
	oRelatorio:ThinLine() //-- Desenha uma linha simples
	oRelatorio:SkipLine() //-- Salta Linha
	oSection1:Cell('CLIENTE'):SetValue("TOTAIS : ")
	oSection1:Cell('JANEIRO'):SetValue((nTotJan-nDevTotJan))
	oSection1:Cell('FEVEREIRO'):SetValue((nTotFev-nDevTotFev))
	oSection1:Cell('MARÇO'):SetValue((nTotMar-nDevTotMar))
	oSection1:Cell('ABRIL'):SetValue((nTotAbr-nDevTotAbr))
	oSection1:Cell('MAIO'):SetValue((nToTMai-nDevToTMai))
	oSection1:Cell('JUNHO'):SetValue((nTotJun-nDevTotJun))
	oSection1:Cell('JULHO'):SetValue((nTotJul-nDevTotJul))
	oSection1:Cell('AGOSTO'):SetValue((nTotAgo-nDevTotAgo))
	oSection1:Cell('SETEMBRO'):SetValue((nTotSet-nDevTotSet))
	oSection1:Cell('OUTUBRO'):SetValue((nTotOut-nDevTotOut))
	oSection1:Cell('NOVEMBRO'):SetValue((nTotNov-nDevTotNov))
	oSection1:Cell('DEZEMBRO'):SetValue((nTotDez-nDevTotDez))
	oSection1:Cell('TOTAL'):SetValue()
	oSection1:Printline()
	oRelatorio:SkipLine() //-- Salta Linha
	oRelatorio:ThinLine() //-- Desenha uma linha simples
	oRelatorio:SkipLine() //-- Salta Linha
	nTotGeral := (nTotJan+nTotFev+nTotMar+nTotAbr+nToTMai+nTotJun+nTotJul+nTotAgo+nTotSet+nTotOut+nTotNov+nTotDez)
	nDevTotGeral := (nDevTotJan+nDevTotFev+nDevTotMar+nDevTotAbr+nDevToTMai+nDevTotJun+nDevTotJul+nDevTotAgo+nDevTotSet+nDevTotOut+nDevTotNov+nDevTotDez)
	oRelatorio:PrtCenter("TOTAL ANUAL :        R$ "+Transform(nTotGeral-nDevTotGeral,"@E 99,999,999,999.99"))

	oSection1:Finish()
	RFATM->(DbCloseArea())
	RFATM_SD1->(DbCloseArea())

Return

*******************************************************************************
// Função : CriaCab - Realiza a Montagem do Cabeçalho do Relatório		      |
// Modulo : FATURAMENTO                                                       |
// Fonte  : RelInvent.prw                                                     |
// ---------+--------------------------+--------------------------------------+
// Data     | Autor                    | Descricao                            |
// ---------+--------------------------+--------------------------------------+
// 09/02/23 | Lucas	Antônio - Cod.ERP  | Cabeçalho			                  |
*******************************************************************************

Static Function CriaCab( oRelatorio )
	Local aArea		:= GetArea()
	Local aCabec	:= {}
	Local cChar		:= chr(160) 
	local _cEmp 	:= FWCodEmp()

	_DataDe := DToC(MV_PAR05)
	_DataAte:= DToC(MV_PAR06)

	aCabec := {	"__LOGOEMP__" + "         " + cChar + "         " + RptFolha+TRANSFORM(oRelatorio:Page(),'999999');
			  , Padc("Relatório de recorrência de vendas mês a mês - " + FWFilialName(_cEmp),132);
	          , Padc("",132);          
	          , Padc(UPPER('Período de '+_DataDe+' até '+_DataAte),132);
	          , RptHora + " " + time() ;
			  + cChar + "         " + RptEmiss + " " + Dtoc(dDataBase)}
			  
	RestArea( aArea )

Return aCabec     
