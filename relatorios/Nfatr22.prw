#Include "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*
*======================================================================================================*
| PROGRAMA | NFATR22           ||                                                  |   ALTERADO POR    |
|----------------------------------------------------------------------------------|-------------------|
| Mapa de Faturamento por Filial                                                   |Michel Rocha-Coderp|
|                                                                                  |-------------------|
|                                                                                  | EM:   13/10/2022  |
*======================================================================================================*
*/

User Function NFatR22()
	cString	:= "SD2"
	cDesc1	:= OemToAnsi("Emite o Mapa de faturamento.")
	cDesc2	:= ""
	cDesc3	:= ""
	tamanho	:="P"
	aReturn 	:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	nomeprog	:="RFATR22"
	aLinha  	:= { }
	nLastKey := 0
	lEnd 		:= .f.
	nmult		:=1
	titulo   := "Teste de impressao - Interpretador xBase"
	cabec1   := "TESTE DE IMPRESSAO"
	cabec2   := ""
	cCancel 	:= "***** CANCELADO PELO OPERADOR *****"
	lFim  := .F.

	private m_pag 	:= 0  //Variavel que acumula numero da pagina
	nLi      := 80
	nPag     := 0
	ntotal   := 0
	ctotal   := 0
	cTotcat  := 0
	cTotcag  := 0

	W_HrIni  := Time()
	W_FatAGR1 := 0
	W_FATATA1 := 0
	W_FATVET1 := 0
	W_FATSEM1 := 0
	W_FATBAY1 := 0
	W_FATjac1 := 0
	W_FATCOS1 := 0
	W_FATTRA1 := 0
	W_FATFER1 := 0
	W_FATpas1 := 0

	W_DEVAGR1 := 0
	W_DEVATA1 := 0
	W_DEVVET1 := 0
	W_DEVSEM1 := 0
	W_DEVBAY1 := 0
	W_DEVjac1 := 0
	W_DEVCOS1 := 0
	W_DEVTRA1 := 0
	W_DEVFER1 := 0
	W_DEVpas1 := 0

	W_CarAgr1 := 0
	W_CarAta1 := 0
	W_CarVET1 := 0
	W_CarSEM1 := 0
	W_CarBAY1 := 0
	W_CarCOS1 := 0
	w_carjac1 := 0
	W_CarTRA1 := 0
	W_CarFER1 := 0
	W_Carpas1 := 0

	W_FatAGR := 0
	W_FATATA := 0
	W_FATVET := 0
	W_FATSEM := 0
	W_FATBAY := 0
	W_FATjac := 0
	W_FATCOS := 0
	W_FATTRA := 0
	W_FATFER := 0
	W_FATpas := 0

	W_DEVAGR := 0
	W_DEVATA := 0
	W_DEVVET := 0
	W_DEVSEM := 0
	W_DEVBAY := 0
	W_DEVjac := 0
	W_DEVCOS := 0
	W_DEVTRA := 0
	W_DEVFER := 0
	W_DEVpas := 0

	W_CarAgr := 0
	W_CarAta := 0
	W_CarVET := 0
	W_CarSEM := 0
	W_CarBAY := 0
	W_CarCOS := 0
	w_carjac := 0
	W_CarTRA := 0
	W_CarFER := 0
	W_Carpas := 0

	ntotgrup := 0

	cEmpresa := "EMIS -"

/*
mv_par01   := 1        // Consolida: Sim / Nao
mv_par02   := 1        // Agricola/Atacado/Veterinaria/Bayer Pco/Pecas Jacto
MV_PAR04   := Space(6) // Vendedor
MV_PAR05   := Date()   // Da  Emissao
MV_PAR06   := Date()   // Ate Emissao
MV_PAR07               // Estado
MV_PAR08               // Municipio
*/

	nContab	:= 2
	wnrel		:= "NFATR22"

	Pergunte("RFAT22",.f.)

	wnrel:=SetPrint(cString,wnrel,"RFAT22",titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho)

	If nLastKey == 27
		Set Filter To
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Set Filter To
		Return
	Endif

	mv:=Trim(sm0->m0_filial)
	If mv_par01==1
		mv:="CONSOLIDADO"
	ENDIF

//cEmpresa:= "EMIS - "+alltrim(mv)
//Adilson Jorge em 21/11/2018


//MsAguarde( { || RunProc()   }, "Aguarde", "Processando...")

//MsAguarde( { || RptDetail() }, "Aguarde", "Imprimindo...")

	Processa(  {|| RunProc() }  ,"Selecionando Faturamento..." )

//RptStatus( {|| RptDetail() },"Imprimindo Mapa de Faturamento..." )

Return
/*
*======================================================================================================*
| PROGRAMA | RunProc           ||                                                  |   ALTERADO POR    |
|----------------------------------------------------------------------------------|-------------------|
| execução da consulta SQL e inserção de valores                                   |Michel Rocha-Coderp|
|                                                                                  |-------------------|
|                                                                                  | EM:   13/10/2022  |
*======================================================================================================*
*/

Static Function RunProc()
	Private nlin := 6
//Montando String para compor a query com seleï¿½ï¿½o da divisï¿½o
	cTxt := ""

	If MV_PAR03 == 1
		W_DIV  := ".T."
		cabec1 := Cabec1 + " Agr.+Ata.+Vet.+Bay.+Pec."
	ElseIf MV_PAR02 == 1
		W_DIV  := "Sb1->B1_DIVISAO=='1'"
		cabec1 := Cabec1 + " Agricola"
		cTxt   := "   AND B1_DIVISAO = '1' "
	ElseIf MV_PAR02 == 2
		W_DIV  := "SB1->B1_DIVISAO=='2'"
		cabec1 := Cabec1 + " Atacado"
		cTxt   := "   AND B1_DIVISAO = '2' "
	ElseIf MV_PAR02 == 3
		W_DIV  := "SB1->B1_DIVISAO=='3'"
		cabec1 := Cabec1 + " Veterinaria"
		cTxt   := "   AND B1_DIVISAO = '3' "
	ElseIf MV_PAR02 == 4
		W_DIV  := "SB1->B1_DIVISAO=='4'"
		cabec1 := Cabec1 + " Bayer Pco"
		cTxt   := "   AND B1_DIVISAO = '4' "
	ElseIf MV_PAR02 == 5
		W_DIV  := "SB1->B1_DIVISAO=='5'"
		cabec1 := Cabec1 + " Pecas Jacto"
		cTxt   := "   AND B1_DIVISAO = '5' "
	EndIf

	W_ContD2 := "sd2->D2_Total*nMult"
	W_ContD1 := "(sd1->D1_Total-sd1->d1_valdesc)"
	W_ContD3 := "((sc6->C6_QtdVen-sc6->C6_QtdEnt)*sc6->C6_PrcVen)"

	cabec2   := " Com Contrato  " + DtoC(MV_PAR05) + " a "+DtoC(MV_PAR06)

	If Empty(MV_PAR04)
		W_VEN    := W_VenSF2 := ".T."
	Else
		W_VEN    := "SC5->C5_VEND1==MV_PAR04"
		W_VENSF2 := "SC5->C5_VEND1==MV_PAR04"
	EndIf

//Seleciona registros
//MsProcTxt("Selecionando faturamento...")

//Inï¿½cio da query

//FATURAMENTO
	cSQL := " SELECT CODDIV=B1_DIVISAO,CODFOR=B1_CODFOR,GRUPO=B1_GRUPO, "
	cSQL += " NOMDIV=(CASE WHEN B1_DIVISAO='1' AND B1_GRUPO NOT IN ('0009','0007') THEN 'AGRICOLA'     ELSE "
	cSQL += "        (CASE WHEN B1_DIVISAO='1' AND B1_GRUPO= '0009' THEN 'FERTILIZANTE' ELSE "
	cSQL += "        (CASE WHEN B1_DIVISAO='1' AND B1_GRUPO= '0007' THEN 'SEMENTES' ELSE "
	cSQL += "        (CASE WHEN B1_DIVISAO='2'    THEN 'ATACADO'     ELSE "
	cSQL += "        (CASE WHEN B1_DIVISAO='3'    THEN 'VETERINARIA' ELSE "
	cSQL += "        (CASE WHEN B1_CODFOR ='01'   THEN 'BAYER PCO'   ELSE "
	cSQL += "        (CASE WHEN B1_CODFOR IN ('A4','83','A7','A8','C3') THEN 'PASTAGEM' ELSE "
	cSQL += "        (CASE WHEN B1_CODFOR IN ('73','76')           THEN 'PECAS COSTAL' END)END)END)END)END)END)END)END), "
	cSQL += " QTDNF = COUNT(DISTINCT D2_DOC), "
	cSQL += " TIPO  = '0F', "
	cSQL += " VALOR = SUM(D2_TOTAL),FILIAL=D2_FILIAL "
	cSQL += " FROM "+RetSqlName("SD2")+" SD2 (NOLOCK), "+RetSqlName("SF4")+" SF4 (NOLOCK), "+RetSqlName("SB1")+" SB1 (NOLOCK), "+RetSqlName("SA1")+" SA1 (NOLOCK), "+RetSqlName("SF2")+" SF2 (NOLOCK) "
//cSQL += " FROM  SD2010 SD2, SF4010 SF4, SB1010 SB1
	cSQL += " WHERE D2_EMISSAO BETWEEN '" + Dtos(MV_PAR05)  + "' AND '" + Dtos(MV_PAR06)   + "' "
	If MV_PAR01 == 2    //Se a divisï¿½o nï¿½o for consolidada
		//cSQL += "   AND D2_FILIAL  = '"+xFilial("SD2")+"' "
	Endif
	cSQL += "   AND SUBSTRING(D2_CF,2,3) IN ('12 ','102','922','108') "
//cSQL += "   AND D2_TES         = F4_CODIGO AND F4_DUPLIC = 'S' "
	cSQL += "   AND D2_TES = F4_CODIGO AND F4_CODIGO <> '706'AND F4_DUPLIC = 'S' AND F4_FILIAL = '"+xFilial("SF4")+"' "
	cSQL += "   AND D2_COD         = B1_COD "
	If MV_PAR03 == 2    //Se a divisï¿½o nï¿½o for consolidada
		cSQL += cTxt
	Endif
	cSQL += "   AND D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_EMISSAO = F2_EMISSAO AND SF2.D_E_L_E_T_ = '' "
	If !Empty(MV_PAR04) //Se selecionar o vendedor
		cSQL += "   AND F2_VEND1 = '" + MV_PAR04 + "' "
	Endif
	cSQL += "   AND D2_CLIENTE     = A1_COD AND D2_LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = '' "
	If !Empty(MV_PAR07) //Se selecionar o estado
		cSQL += "   AND A1_EST   = '" + MV_PAR07 + "' "
	Endif
	If !Empty(MV_PAR08) //Se selecionar o municï¿½pio
		cSQL += "   AND A1_MUN   = '" + MV_PAR08 + "' "
	Endif
	cSQL += "   AND SD2.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' AND SB1.D_E_L_E_T_ = '' "
	cSQL += " GROUP BY B1_DIVISAO,B1_CODFOR,B1_GRUPO,D2_FILIAL "
	cSQL += " UNION "
//DEVOLUCOES
	cSQL += " SELECT CODDIV=B1_DIVISAO,CODFOR=B1_CODFOR,GRUPO=B1_GRUPO, "
	cSQL += " NOMDIV=(CASE WHEN B1_DIVISAO='1' AND B1_GRUPO NOT IN ('0009','0007') THEN 'AGRICOLA'     ELSE "
	cSQL += "        (CASE WHEN B1_DIVISAO='1' AND B1_GRUPO= '0009' THEN 'FERTILIZANTE' ELSE "
	cSQL += "        (CASE WHEN B1_DIVISAO='1' AND B1_GRUPO= '0007' THEN 'SEMENTES' ELSE "
	cSQL += "        (CASE WHEN B1_DIVISAO='2'    THEN 'ATACADO'     ELSE "
	cSQL += "        (CASE WHEN B1_DIVISAO='3'    THEN 'VETERINARIA' ELSE "
	cSQL += "        (CASE WHEN B1_CODFOR ='01'   THEN 'BAYER PCO'   ELSE "
	cSQL += "        (CASE WHEN B1_CODFOR IN ('A4','83','A7','A8','C3') THEN 'PASTAGEM' ELSE "
	cSQL += "        (CASE WHEN B1_CODFOR IN ('73','76')           THEN 'PECAS COSTAL' END)END)END)END)END)END)END)END), "
	cSQL += " QTDNF = COUNT(DISTINCT D1_DOC), "
	cSQL += " TIPO  = '1D', "
	cSQL += " VALOR = SUM(D1_TOTAL-D1_VALDESC),FILIAL=D1_FILIAL "
	cSQL += " FROM "+RetSqlName("SD1")+" SD1 (NOLOCK), "+RetSqlName("SF4")+" SF4 (NOLOCK), "+RetSqlName("SB1")+" SB1 (NOLOCK), "+RetSqlName("SA1")+" SA1 (NOLOCK), "+RetSqlName("SF2")+" SF2 (NOLOCK) "
//cSQL += " FROM SD1010 SD1, SF4010 SF4, SB1010 SB1
	cSQL += " WHERE D1_DTDIGIT BETWEEN '" + Dtos(MV_PAR05)  + "' AND '" + Dtos(MV_PAR06)   + "' "
	If MV_PAR01 == 2    //Se a divisï¿½o nï¿½o for consolidada
		//cSQL += "   AND D1_FILIAL  = '"+xFilial("SD1")+"' "
	Endif
//cSQL += "   AND D1_FILIAL  BETWEEN '" + Trim(W_De) + "' AND '" + Trim(W_Ate) + "' "
	cSQL += "   AND SUBSTRING(D1_CF,2,3) IN ('32 ','202') "
	cSQL += "   AND D1_TES         = F4_CODIGO  AND F4_DUPLIC = 'S' AND F4_FILIAL = '' "
	cSQL += "   AND D1_COD         = B1_COD "
	If MV_PAR03 == 2    //Se a divisï¿½o nï¿½o for consolidada
		cSQL += cTxt
	Endif
	cSQL += "   AND D1_FORNECE     = A1_COD AND D1_LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = '' "
	If !Empty(MV_PAR07) //Se selecionar o estado
		cSQL += "   AND A1_EST   = '" + MV_PAR07 + "' "
	Endif
	If !Empty(MV_PAR08) //Se selecionar o municï¿½pio
		cSQL += "   AND A1_MUN   = '" + MV_PAR08 + "' "
	Endif
	cSQL += "   AND D1_NFORI       = F2_DOC AND D1_SERIORI = F2_SERIE AND D1_FILIAL = F2_FILIAL AND SF2.D_E_L_E_T_ = '' "
	If !Empty(MV_PAR04) //Se selecionar o vendedor
		cSQL += "   AND F2_VEND1 = '" + MV_PAR04 + "' "
	Endif
	cSQL += "   AND SD1.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' AND SB1.D_E_L_E_T_ = '' "
	cSQL += " GROUP BY B1_DIVISAO,B1_CODFOR,B1_GRUPO,D1_FILIAL "
	cSQL += " UNION "
//CARTEIRA
	cSQL += " SELECT CODDIV=B1_DIVISAO,CODFOR=B1_CODFOR,GRUPO=B1_GRUPO, "
	cSQL += " NOMDIV=(CASE WHEN B1_DIVISAO='1' AND B1_GRUPO NOT IN ('0009','0007') THEN 'AGRICOLA'     ELSE "
	cSQL += "        (CASE WHEN B1_DIVISAO='1' AND B1_GRUPO= '0009' THEN 'FERTILIZANTE' ELSE "
	cSQL += "        (CASE WHEN B1_DIVISAO='1' AND B1_GRUPO= '0007' THEN 'SEMENTES' ELSE "
	cSQL += "        (CASE WHEN B1_DIVISAO='2'    THEN 'ATACADO'     ELSE "
	cSQL += "        (CASE WHEN B1_DIVISAO='3'    THEN 'VETERINARIA' ELSE "
	cSQL += "        (CASE WHEN B1_CODFOR ='01'   THEN 'BAYER PCO'   ELSE "
	cSQL += "        (CASE WHEN B1_CODFOR IN ('A4','83','A7','A8','C3') THEN 'PASTAGEM' ELSE "
	cSQL += "        (CASE WHEN B1_CODFOR IN ('73','76')           THEN 'PECAS COSTAL' END)END)END)END)END)END)END)END), "
	cSQL += " QTDNF = COUNT(DISTINCT C6_NUM), "
	cSQL += " TIPO  = '3C', "
	cSQL += " VALOR = SUM((C6_QTDVEN-C6_QTDENT)*C6_PRCVEN),FILIAL=C6_FILIAL "
	cSQL += " FROM "+RetSqlName("SC6")+" SC6 (NOLOCK), "+RetSqlName("SF4")+" SF4 (NOLOCK), "+RetSqlName("SB1")+" SB1 (NOLOCK), "+RetSqlName("SA1")+" SA1 (NOLOCK), "+RetSqlName("SC5")+" SC5 (NOLOCK) "
//cSQL += " FROM SC6010 SC6, SF4010 SF4, SB1010 SB1
	cSQL += " WHERE C6_ENTREG BETWEEN '" + Dtos(MV_PAR05-90) + "' AND '" + Dtos(MV_PAR06)   + "' "
	If MV_PAR01 == 2    //Se a divisï¿½o nï¿½o for consolidada
		//cSQL += "   AND C6_FILIAL  = '"+xFilial("SC6")+"' "
	Endif
//cSQL += "   AND C6_FILIAL BETWEEN '" + Trim(W_De) + "' AND '" + Trim(W_Ate) + "' "
	cSQL += "   AND C6_PRODUTO     = B1_COD "
	If MV_PAR03 == 2 //Se a divisï¿½o nï¿½o for consolidada0
		cSQL += cTxt
	Endif
	cSQL += "   AND C6_QTDVEN-C6_QTDENT > 0 "
	cSQL += "   AND C6_BLQ        <> 'R' "
	cSQL += "   AND SUBSTRING(C6_CF,2,3) IN ('12 ','102','922','108') "
//cSQL += "   AND C6_TES         = F4_CODIGO AND F4_DUPLIC = 'S' "
	cSQL += "   AND C6_TES = F4_CODIGO AND F4_CODIGO <> '706' AND F4_DUPLIC = 'S' AND F4_FILIAL = '"+xFilial("SF4")+"' "
	cSQL += "   AND C6_FILIAL      = C5_FILIAL AND C6_NUM = C5_NUM AND SC5.D_E_L_E_T_ = '' "
	If !Empty(MV_PAR04) //Se selecionar o vendedor
		cSQL += "   AND C5_VEND1 = '" + MV_PAR04 + "' "
	Endif
	cSQL += "   AND C6_CLI         = A1_COD AND C6_LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = '' "
	If !Empty(MV_PAR07) //Se selecionar o estado
		cSQL += "   AND A1_EST   = '" + MV_PAR07 + "' "
	Endif
	If !Empty(MV_PAR08) //Se selecionar o municï¿½pio
		cSQL += "   AND A1_MUN   = '" + MV_PAR08 + "' "
	Endif
	cSQL += "   AND SC6.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' AND SB1.D_E_L_E_T_ = '' "
	cSQL += " GROUP BY B1_DIVISAO,B1_CODFOR,B1_GRUPO,C6_FILIAL "
	cSQL += " ORDER BY FILIAL,1,6,3 "

//dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRY",.T.,.T.) 

	TCQuery cSQL NEW ALIAS "QRY"

//QRY->(DbGoTop())sr

	DBSelectARea("QRY")
	ProcRegua(RecCount())

	QRY->(DbGoTop())

//CODDIV	CODFOR	GRUPO	NOMDIV	QTDNF	TIPO	VALOR

	While !QRY->(Eof())
		cChave := QRY->filial

		while !QRY->(Eof()) .and. QRY->filial == cChave

			IncProc()
			// Ajustei a qry para guardar a filial de d2, d1 e c6, com isso nï¿½o filtro a filial na montagem da qry e sim aqui,
			// na qry vem todas as filiais, Adilson Jorge em 19/01/2013
			//If MV_PAR01 == 2 .And. Trim(QRY->FILIAL) <> Trim(sm0->m0_codfil)   //Se a divisï¿½o nï¿½o for consolidada
			//	QRY->(dbskip())
			//	Loop
			//Endif

			//Totalizando o faturamento
			If QRY->TIPO == "0F"
				If QRY->CODFOR == "01"
					W_Fatbay += QRY->VALOR
					W_Fatbay1 += QRY->VALOR
				Elseif QRY->CODFOR $ "A4.83.A7.A8.C3"
					W_FatPAS += QRY->VALOR
					W_FatPas1 += QRY->VALOR
				elseIf QRY->CODFOR $ "73.76"
					W_Fatjac += QRY->VALOR
					W_Fatjac1 += QRY->VALOR
				elseIf QRY->GRUPO == "0009"
					W_FatFER += QRY->VALOR
					W_FatFER1 += QRY->VALOR
				elseIf QRY->GRUPO == "0007"
					W_FatSEM += QRY->VALOR
					W_FatSEM1 += QRY->VALOR
				ElseIf QRY->CODDIV == "1"
					W_FatAgr += QRY->VALOR
					W_FatAgr1 += QRY->VALOR
				ElseIf QRY->CODDIV == "2"
					W_FatAta += QRY->VALOR
					W_FatAta1 += QRY->VALOR
				ElseIf QRY->CODDIV == "3"
					W_FatVet += QRY->VALOR
					W_FatVet1 += QRY->VALOR
				EndIf
			ENDIF

			//Totalizando as devoluï¿½ï¿½es
			If QRY->TIPO == "1D"
				If QRY->CODFOR == "01"
					W_Devbay += QRY->VALOR
					W_Devbay1 += QRY->VALOR
				Elseif QRY->CODFOR $ "A4.83.A7.A8.C3"
					W_DevPAS += QRY->VALOR
					W_DevPAS1 += QRY->VALOR
				elseIf QRY->CODFOR $ "73.76"
					W_Devjac += QRY->VALOR
					W_Devjac1 += QRY->VALOR
				elseIf QRY->GRUPO == "0009"
					W_DevFER += QRY->VALOR
					W_DEVFER1 += QRY->VALOR
				elseIf QRY->GRUPO == "0007"
					W_DevSem += QRY->VALOR
					W_DevSem1 += QRY->VALOR
				ElseIf QRY->CODDIV == "1"
					W_DevAgr += QRY->VALOR
					W_DevAgr1 += QRY->VALOR
				ElseIf QRY->CODDIV == "2"
					W_DevAta += QRY->VALOR
					W_DevAta1 += QRY->VALOR
				ElseIf QRY->CODDIV == "3"
					W_DevVet += QRY->VALOR
					W_DevVet1 += QRY->VALOR
				EndIf
			ENDIF

			//Totalizando os pedidos em carteira
			If QRY->TIPO == "3C"
				If QRY->CODFOR == "01"
					W_Carbay += QRY->VALOR
					W_Carbay1 += QRY->VALOR
				Elseif QRY->CODFOR $ "A4.83.A7.A8.C3"
					W_CarPAS += QRY->VALOR
					W_CarPAS1 += QRY->VALOR
				elseIf QRY->CODFOR $ "73.76"
					W_Carjac += QRY->VALOR
					W_Carjac1 += QRY->VALOR
				elseIf QRY->GRUPO == "0009"
					W_CarFER += QRY->VALOR
					W_CarFER1 += QRY->VALOR
				elseIf QRY->GRUPO == "0007"
					W_CarSEM += QRY->VALOR
					W_CarSEM1 += QRY->VALOR
				ElseIf QRY->CODDIV == "1"
					W_CarAgr += QRY->VALOR
					W_CarAgr1 += QRY->VALOR
				ElseIf QRY->CODDIV == "2"
					W_CarAta += QRY->VALOR
					W_CarAta1 += QRY->VALOR
				ElseIf QRY->CODDIV == "3"
					W_CarVet += QRY->VALOR
					W_CarVet1 += QRY->VALOR
				EndIf
			ENDIf
			QRY->(dbskip())
		end
		RptDetail()
		W_FatAGR := 0
		W_FATATA := 0
		W_FATVET := 0
		W_FATSEM := 0
		W_FATBAY := 0
		W_FATjac := 0
		W_FATCOS := 0
		W_FATTRA := 0
		W_FATFER := 0
		W_FATpas := 0

		W_DEVAGR := 0
		W_DEVATA := 0
		W_DEVVET := 0
		W_DEVSEM := 0
		W_DEVBAY := 0
		W_DEVjac := 0
		W_DEVCOS := 0
		W_DEVTRA := 0
		W_DEVFER := 0
		W_DEVpas := 0

		W_CarAgr := 0
		W_CarAta := 0
		W_CarVET := 0
		W_CarSEM := 0
		W_CarBAY := 0
		W_CarCOS := 0
		w_carjac := 0
		W_CarTRA := 0
		W_CarFER := 0
		W_Carpas := 0


	End

	lFim := .T.
	if lFim == .T.
		RptDetail()
	ENDIF
	Set Filter To
	If aReturn[5] == 1
		Set Printer To
		Commit
		ourspool(wnrel) //Chamada do Spool de Impressao

	Endif
	ms_flush()
	QRY->(DBCloseArea())

Return

/*
*======================================================================================================*
| PROGRAMA | RptDetail           ||                                                |   ALTERADO POR    |
|----------------------------------------------------------------------------------|-------------------|
| Imprime as Páginas do Relatorio                                                  |Michel Rocha-Coderp|
|                                                                                  |-------------------|
|                                                                                  | EM:   13/10/2022  |
*======================================================================================================*
*/

Static Function RptDetail()

	W_TotDev := 0      &&&  Davidson
	nNr_Fil  := 0
	aNomeFil := {}
	M_pag++

	DBSelectArea("SX5")
	DBSetorder(1)
	DBSeek("01X7")

	While !Eof() .And. X5_TABELA=="X7"
		AADD(aNomeFil,AllTrim(X5_DESCRI))
		nNr_Fil++
		Skip
	End

//Forï¿½ando o parï¿½metro para nï¿½o consolidar as empresas, se nï¿½o for Matriz, Adilson Jorge 28/12/2011
	If Trim(sm0->m0_codfil) <> "01" .And. lfim == .T.
		MV_PAR01 := 2
	Endif

	If lFim
		mv:="CONSOLIDADO"
	ELSE
		SM0->(dBSeek(cEmpAnt+cChave))
		Mv:= AllTrim(SM0->M0_FILIAL) +" - "+cChave
	ENDIF

	If SM0->M0_CODIGO == "01"
		cEmpresa:= "EMIS - "+alltrim(mv)
	ELSEIF SM0->M0_CODIGO == "02" .AND. SM0->M0_CODFIL == "01" .AND. MV_PAR01 <> 1
		cEmpresa:= "CATIVA - MATRIZ"
	ELSEIF (SM0->M0_CODIGO == "02" .AND. SM0->M0_CODFIL <> "01") .OR. (SM0->M0_CODIGO == "02" .AND. SM0->M0_CODFIL == "01" .AND. MV_PAR01 == 1)
		cEmpresa:= "CATIVA - "+alltrim(mv)
	ELSEIF SM0->M0_CODIGO == "03" .AND. SM0->M0_CODFIL == "01" .AND. MV_PAR01 <> 1
		cEmpresa:= "NUTIVA - MATRIZ"
	ELSEIF (SM0->M0_CODIGO == "03" .AND. SM0->M0_CODFIL <> "01") .OR. (SM0->M0_CODIGO == "03" .AND. SM0->M0_CODFIL == "01" .AND. MV_PAR01 == 1)
		cEmpresa:= "NUTIVA - "+alltrim(mv)
	Endif

//W_De  := W_Ate := Trim(sm0->m0_codfil)
	W_De  := W_Ate := Trim(sm0->m0_codfil)
	If MV_PAR01 == 1
		W_De  := "01"
		W_Ate := Strzero(nNr_Fil,2)
	EndIf

	cabec1  := "MAPA DE FATURAMENTO"+MV

	MV_PAR07 := UPPER(MV_PAR07)
	MV_PAR08 := UPPER(MV_PAR08)

	If !Empty(MV_PAR07)
		cabec1 := cabec1 + " - Estado de " + MV_PAR07
	ELSEIF!Empty(MV_PAR08)
		cabec1 := cabec1 + " - Cidade de " + MV_PAR08
	EndIf
//DBSelectArea("TMP")
//SetRegua(RecCount())
//GoTo Top
	@ 00,00 PSay CHR(18)+Repli("*",80)
//@ 01,00 PSay "EMIS - Nfatr22"
	@ 01,00 PSay cEmpresa+" - Nfatr22"
	@ 01,61 PSay "Folha..: " +StrZero(M_pag,1)
//@ 02,00 PSay "RFatr22"
	@ 02,00 PSay PADC(Cabec1,80)
	@ 03,00 PSay "Hora...: " + W_HrIni
	@ 03,61 PSay "Emissao: " + dtoc(Date())
	@ 04,00 PSay Repli("*",80)
	@ 05,00 PSay Cabec2
	nLin:=6
	If !EmpTy(MV_PAR04)
		DBSelectArea("SA3")
		DBSeek("  "+MV_PAR04)
		@ nLin,01 PSay "Vendedor : ("+MV_PAR04+") "+ Trim(SA3->A3_Nome) + "  Contato: " + Trim(SA3->A3_NREDUZ)
		nLin++
	EndIf
	@ nLin,00 PSay Repli("*",80)

	nlin:=nlin+2
	@ nLin,04 PSay "DIVISAO AGRICOLA   :" +Space(45)+"CARTEIRA";nLin++
	@ nLin,23 PSay "Faturamento : "+Transform(iif(lFim == .T.,W_fatagr1 ,w_fatagr)         ,'@E 9,999,999,999.99');nliN++
	@ nLin,23 PSay "Devolucao   : "+Transform(iif(lFim == .T.,w_devagr1,w_devagr)         ,'@E 9,999,999,999.99');nliN++
	@ nLin,23 PSay "Saldo       : "+Transform(iif(lFim == .T.,w_fatagr1-w_devagr1,w_fatagr-w_devagr),'@E 9,999,999,999.99')
	@ nLin,64 PSay iif(lFim == .T.,W_CarAgr1,W_CarAgr) Picture '@E 99,999,999.99'

	nlin:=nlin+2
	@ nLin,04 PSay "DIVISAO FERTILIZANTE:" +Space(44);nLin++
	@ nLin,23 PSay "Faturamento : "+Transform(iif(lFim == .T.,w_FatFER1,w_fatFER)         ,'@E 9,999,999,999.99');nliN++
	@ nLin,23 PSay "Devolucao   : "+Transform(iif(lFim == .T.,W_DevFer1,w_devFER)       ,'@E 9,999,999,999.99');nliN++
	@ nLin,23 PSay "Saldo       : "+Transform(iif(lFim == .T.,w_fatFER1-w_devFER1,w_fatFER-w_devFER),'@E 9,999,999,999.99')
	@ nLin,64 PSay iif(lFim == .T.,W_CarFER1,W_CarFER) Picture '@E 99,999,999.99'

/*
nLin:=nlin+2
@ nLin,04 PSay "TOTAL DIV.AGRICOLA :" +Space(45);nLin++
@ nLin,23 PSay "Faturamento : "+Transform(w_fatagr+W_FATFER,'@E 9,999,999,999.99');nliN++
@ nLin,23 PSay "Devolucao   : "+Transform(w_devagr+W_DEVFER,'@E 9,999,999,999.99');nliN++
nSaldo3 :=(w_fatAGR+w_fatFER)-(w_DEVAGR+w_DEVFER)
@ nLin,23 PSay "Saldo       : "+Transform(nSaldo3,'@E 9,999,999,999.99')
@ nLin,64 PSay W_CarAgr+W_CARFER Picture '@E 99,999,999.99'
*/

	nlin:=nlin+2
	@ nLin,04 PSay "DIVISAO SEMENTES   :" +Space(44);nLin++
	@ nLin,23 PSay "Faturamento : "+Transform(iif(lFim == .T.,W_fatSem1,w_fatSEM)         ,'@E 9,999,999,999.99');nliN++
	@ nLin,23 PSay "Devolucao   : "+Transform(iif(lFim == .T.,W_DevSem1,w_devSEM)         ,'@E 9,999,999,999.99');nliN++
	@ nLin,23 PSay "Saldo       : "+Transform(iif(lFim == .T.,w_fatSEM1-w_devSEM1,w_fatSEM-w_devSEM),'@E 9,999,999,999.99')
	@ nLin,64 PSay iif(lFim == .T.,W_CarSem1,W_CarSEM )Picture '@E 99,999,999.99'

	nLin:=nlin+2
	@ nLin,04 PSay "DIVISAO ATACADO    :" +Space(43);nLin++
	@ nLin,23 PSay "Faturamento : "+Transform(iif(lFim == .T.,W_FatAta1,w_fataTA )        ,'@E 9,999,999,999.99');nliN++
	@ nLin,23 PSay "Devolucao   : "+Transform(iif(lFim == .T.,W_DevAta1,w_devaTA)         ,'@E 9,999,999,999.99');nliN++
	@ nLin,23 PSay "Saldo       : "+Transform(iif(lFim == .T.,w_fataTA1-w_devaTA1,w_fataTA-w_devaTA),'@E 9,999,999,999.99')
	@ nLin,64 PSay iif(lFim == .T.,W_CarAta1, W_CarATA )Picture '@E 99,999,999.99'
	nLin:=nlin+2

	@ nLin,04 PSay "DIVISAO PASTAGEM   :" +Space(43);nLin++
	@ nLin,23 PSay "Faturamento : "+Transform(iif(lFim == .T.,W_FatPas1,w_fatPAS)         ,'@E 9,999,999,999.99');nliN++
	@ nLin,23 PSay "Devolucao   : "+Transform(iif(lFim == .T.,W_DevPAS1,w_devPAS)         ,'@E 9,999,999,999.99');nliN++
	@ nLin,23 PSay "Saldo       : "+Transform(iif(lFim == .T.,w_fatPAS1-w_devPAS1,w_fatPAS-w_devPAS),'@E 9,999,999,999.99')
	@ nLin,64 PSay iif(lFim == .T.,W_CarPAS1,W_CarPAS) Picture '@E 99,999,999.99'
	nLin:=nlin+2

	@ nLin,04 PSay "DIVISAO VETERINA.  :" +Space(45);nLin++
	@ nLin,23 PSay "Faturamento : "+Transform(iif(lFim == .T.,W_FatVet1,w_fatVET)         ,'@E 9,999,999,999.99');nliN++
	@ nLin,23 PSay "Devolucao   : "+Transform(iif(lFim == .T.,W_DevVet1,w_devVET)         ,'@E 9,999,999,999.99');nliN++
	@ nLin,23 PSay "Saldo       : "+Transform(iif(lFim == .T.,w_fatVET1-w_devVET1,w_fatVET-w_devVET),'@E 9,999,999,999.99')
	@ nLin,64 PSay iif(lFim == .T.,W_CarVET1,W_CarVET) Picture '@E 99,999,999.99'
	nLin:=nlin+2

	@ nLin,04 PSay "DIVISAO BAYER PCO  :" +Space(43);nLin++
	@ nLin,23 PSay "Faturamento : "+Transform(iif(lFim == .T.,W_Fatbay1,w_fatBAY)         ,'@E 9,999,999,999.99');nliN++
	@ nLin,23 PSay "Devolucao   : "+Transform(iif(lFim == .T.,W_Devbay1,w_devBAY)         ,'@E 9,999,999,999.99');nliN++
	@ nLin,23 PSay "Saldo       : "+Transform(iif(lFim == .T.,W_Fatbay1-w_devBAY1,w_fatBAY-w_devBAY),'@E 9,999,999,999.99')
	@ nLin,64 PSay iif(lFim == .T.,W_CarBAY1,W_CarBAY) Picture '@E 99,999,999.99'
	nLin:=nlin+2

	@ nLin,04 PSay "DIVISAO PECAS COSTAL:" +Space(43);nLin++
	@ nLin,23 PSay "Faturamento : "+Transform(iif(lFim == .T.,W_Fatjac1,w_fatjac)         ,'@E 9,999,999,999.99');nliN++
	@ nLin,23 PSay "Devolucao   : "+Transform(iif(lFim == .T.,W_Devjac1,w_devjac)         ,'@E 9,999,999,999.99');nliN++
	@ nLin,23 PSay "Saldo       : "+Transform(iif(lFim == .T.,W_Fatjac1-w_devjac1,w_fatjac-w_devjac),'@E 9,999,999,999.99')
	@ nLin,64 PSay iif(lFim == .T.,W_Carjac1,W_Carjac) Picture '@E 99,999,999.99'

/*
nLin:=nlin+2
@ nLin,04 PSay "TOTAL DIV.ATACADO  :" +Space(45);nLin++
@ nLin,23 PSay "Faturamento : "+Transform(w_fatATA+W_FATBAY+W_FATJAC+W_FATVET+W_FATPAS,'@E 9,999,999,999.99');nliN++
@ nLin,23 PSay "Devolucao   : "+Transform(w_devATA+W_DEVBAY+W_DEVJAC+W_DEVVET+W_DEVPAS,'@E 9,999,999,999.99');nliN++
nSaldo1 :=(w_fatATA+w_fatBAY+w_fatjac+w_fatVET+W_FATPAS)-(w_DEVATA+w_DEVBAY+w_devjac+w_DEVVET+W_DEVPAS)
@ nLin,23 PSay "Saldo       : "+Transform(nSaldo1,'@E 9,999,999,999.99')
@ nLin,64 PSay W_CarATA+W_CARBAY+W_CARJAC+W_CARVET+W_CARPAS Picture '@E 99,999,999.99'
*/

	nLin:=nlin+2
	@ nLin,04 PSay "TOTAL GERAL        :" +Space(45);nLin++
	@ nLin,23 PSay "Faturamento : "+Transform(iif(lFim == .T.,w_fatAGR1+w_fatATA1+w_fatBAY1+w_fatjac1+w_fatVET1+W_FATFER1+W_FATPAS1+W_FATSEM1,w_fatAGR+w_fatATA+w_fatBAY+w_fatjac+w_fatVET+W_FATFER+W_FATPAS+W_FATSEM),'@E 9,999,999,999.99');nliN++
	@ nLin,23 PSay "Devolucao   : "+Transform(iif(lFim == .T.,w_DEVAGR1+w_DEVATA1+w_DEVBAY1+w_devjac1+w_DEVVET1+W_DEVFER1+W_DEVPAS1+W_DEVSEM1,w_DEVAGR+w_DEVATA+w_DEVBAY+w_devjac+w_DEVVET+W_DEVFER+W_DEVPAS+W_DEVSEM),'@E 9,999,999,999.99');nliN++
	nSaldo := (w_fatAGR+w_fatATA+w_fatBAY+w_fatjac+w_fatVET+W_FATFER+W_FATPAS+W_FATSEM)-(w_DEVAGR+w_DEVATA+w_DEVBAY+w_devjac+w_DEVVET+W_DEVFER+W_DEVPAS+W_DEVSEM)
	nSaldo1 := (w_fatAGR1+w_fatATA1+w_fatBAY1+w_fatjac1+w_fatVET1+W_FATFER1+W_FATPAS1+W_FATSEM1)-(w_DEVAGR1+w_DEVATA1+w_DEVBAY1+w_devjac1+w_DEVVET1+W_DEVFER1+W_DEVPAS1+W_DEVSEM1)
	@ nLin,23 PSay "Saldo       : "+Transform(iif(lFim == .T.,nSaldo1,nSaldo),'@E 9,999,999,999.99')
	@ nLin,64 PSay iif(lFim == .T.,W_Caragr1+W_Carata1+W_Carbay1+w_carjac1+W_CarVET1+W_CARFER1+W_CARPAS1+W_CARSEM1,W_Caragr+W_Carata+W_Carbay+w_carjac+W_CarVET+W_CARFER+W_CARPAS+W_CARSEM) Picture '@E 99,999,999.99'

	Roda(0,"","P")


Return
