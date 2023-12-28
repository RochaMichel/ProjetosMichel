//Bibliotecas
#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
#Define PAD_JUSTIFY 3
#Define COR_CINZA   RGB(180, 180, 180)

//Cor(es)
Static nCorCinza := RGB(11, 10, 68)
//Static nCorLinha := RGB(11, 10, 68)

/*/{Protheus.doc} User Function FolhaPon
Folha do Ponto
@author jose vinicius lourenço
@since 18/12/2023
@version 1.0
@type function
/*/

User Function MailPonto()
	Private lAtivAmb := .F.
	If Select("SX2") == 0
		RPCClearEnv()
		RpcSetType( 3 )
		RpcSetEnv( "01",'010101', , , "",,, , , ,  )
		lAtivAmb := .T. // Seta se precisou montar o ambiente
	Endif

	//fImprime(FirstDate(dDatabase),dDatabase)
	fImprime(cToD('01/01/2023'),dDatabase)

	GPEMAIL("FOLHA DE PONTO","teste","michel.tjs.futebol@gmail.com",{GetTempPath()+'FolhaPon'+RetCodUsr()+'_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.pdf'})
	If lAtivAmb
		RPCClearEnv()
	Endif

Return
/*/{Protheus.doc} fImprime
Faz a impressão do relatório FolhaPon
@author jose vinicius lourenço
@since 18/12/2023
@version 1.0
@type function
/*/

Static Function fImprime(dDataIni,dDataFim)
	Local aArea        := FWGetArea()
	Local nTotAux      := 0
	Local nAtuAux      := 0
	Local cArquivo     := 'FolhaPon'+RetCodUsr()+'_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.pdf'
	Private oPrintPvt
	Private oBrushLin  := TBrush():New(,COR_CINZA)
	Private cHoraEx    := Time()
	Private nPagAtu    := 1
	Private cLogoEmp   := fLogoEmp()
	//Linhas e colunas
	Private nLinAtu    := 0
	Private nLinFin    := 580
	Private nColIni    := 010
	Private nColFin    := 815
	Private nColMeio   := (nColFin-nColIni)/2
	//Colunas dos relatorio


	Private nColDad1    := nColIni + 25
	Private nColDad2    := nColIni + 90
	Private nColDad3    := nColIni + 130
	Private nColDad4    := nColIni + 160
	Private nColDad5    := nColIni + 190
	Private nColDad6    := nColIni + 220
	Private nColDad7    := nColIni + 250
	Private nColDad8    := nColIni + 280
	Private nColDad9    := nColIni + 310
	Private nColDad10   := nColIni + 340
	Private nColDad11   := nColIni + 550
	Private nColDad12   := nColIni + 520






	//Declarando as fontes
	Private cNomeFont  := 'Arial'
	Private oFontDet   := TFont():New(cNomeFont, /*uPar2*/, -11, /*uPar4*/, .F., /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F.)
	Private oFontDetN  := TFont():New(cNomeFont, /*uPar2*/, -13, /*uPar4*/, .T., /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F.)
	Private oFontRod   := TFont():New(cNomeFont, /*uPar2*/, -8,  /*uPar4*/, .F., /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F.)
	Private oFontMin   := TFont():New(cNomeFont, /*uPar2*/, -7,  /*uPar4*/, .F., /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F.)
	Private oFontTit   := TFont():New(cNomeFont, /*uPar2*/, -15, /*uPar4*/, .T., /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F.)

	BeginSql Alias "QRY_AUX"
		SELECT P8_DATA , P8_MAT, P8_FILIAL, P8_HORA, P8_TPMARCA , RA_NOME, P8_CC, 
		CTT_DESC01, RA_CODFUNC, RA_CHAPA, RA_DEPTO, QB_DESCRIC, 
		RA_TNOTRAB, R6_DESC
		FROM %Table:SP8% P8
		INNER JOIN %Table:SRA% RA On P8_MAT = RA_MAT
		INNER JOIN %Table:CTT% CC On P8_CC = CTT_CUSTO
		INNER JOIN %Table:SQB% QB On QB_DEPTO = RA_DEPTO
		INNER JOIN %Table:SR6% R6 On R6_TURNO = RA_TNOTRAB
		WHERE P8.%NotDel% AND RA.%NotDel% AND CC.%NotDel% 
		AND P8_MAT = '000043'
		AND P8_DATA BETWEEN %Exp:DtoS(dDataIni)% AND %Exp:DtoS(dDataFim)% 
		GROUP BY P8_MAT , P8_DATA, P8_FILIAL, P8_HORA, P8_TPMARCA , RA_NOME, P8_CC, 
		CTT_DESC01, RA_CODFUNC, RA_CHAPA, RA_DEPTO, QB_DESCRIC, 
		RA_TNOTRAB, R6_DESC  
	EndSql

		
	//Define o tamanho da régua
	DbSelectArea('QRY_AUX')
	QRY_AUX->(DbGoTop())
	Count to nTotAux
	QRY_AUX->(DbGoTop())

	//Somente se tiver dados
	If ! QRY_AUX->(EoF())
		//Criando o objeto de impressao
		oPrintPvt := FWMSPrinter():New(;
			cArquivo,;    // cFilePrinter
		IMP_PDF,;     // nDevice
		.F.,;         // lAdjustToLegacy
		,;            // cPathInServer
		.T.,;         // lDisabeSetup
		,;            // lTReport
		@oPrintPvt,;  // oPrintSetup
		,;            // cPrinter
		,;            // lServer
		,;            // lParam10
		,;            // lRaw
		.T.;          // lViewPDF
		)
		oPrintPvt:cPathPDF := GetTempPath()
		oPrintPvt:SetResolution(72)
		oPrintPvt:SetLandscape()
		oPrintPvt:SetPaperSize(DMPAPER_A4)
		oPrintPvt:SetMargin(0, 0, 0, 0)

		//Imprime os dados
		fImpCab()

		dData := dDataIni

		While ! QRY_AUX->(EoF())
			nAtuAux++

			//Se atingiu o limite, quebra de pagina
			fQuebra()







		/* 	//Faz o zebrado ao fundo
			If nAtuAux % 2 == 0
				oPrintPvt:FillRect({nLinAtu - 2, nColIni+4, nLinAtu + 12, nColFin }, oBrushLin)
			EndIf */



			cData := QRY_AUX->P8_DATA
			//Imprime a linha atual
			
			oPrintPvt:SayAlign(nLinAtu+50 , nColDad1, DtoC(dData), oFontDet, 100, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
			oPrintPvt:SayAlign(nLinAtu+50,nColDad2,  DiaSemana(dData), oFontDet, 30, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
			If DtoS(dData) == QRY_AUX->P8_DATA
				WHILE cData == QRY_AUX->P8_DATA 
					Do Case
						Case AllTrim(P8_TPMARCA) == '1E'
						oPrintPvt:SayAlign(nLinAtu+50, nColDad3, cValToChar(QRY_AUX->P8_HORA), oFontDet, 20, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
						Case AllTrim(P8_TPMARCA) == '1S'
						oPrintPvt:SayAlign(nLinAtu+50, nColDad4, cValToChar(QRY_AUX->P8_HORA), oFontDet, 20, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
						Case AllTrim(P8_TPMARCA) == '2E'
						oPrintPvt:SayAlign(nLinAtu+50, nColDad5, cValToChar(QRY_AUX->P8_HORA), oFontDet, 20, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
						Case AllTrim(P8_TPMARCA) == '2S'
						oPrintPvt:SayAlign(nLinAtu+50, nColDad6, cValToChar(QRY_AUX->P8_HORA), oFontDet, 20, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
						Case AllTrim(P8_TPMARCA) == '3E'
						oPrintPvt:SayAlign(nLinAtu+50, nColDad7, cValToChar(QRY_AUX->P8_HORA), oFontDet, 20, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
						Case AllTrim(P8_TPMARCA) == '3S'
						oPrintPvt:SayAlign(nLinAtu+50, nColDad8, cValToChar(QRY_AUX->P8_HORA), oFontDet, 20, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
						Case AllTrim(P8_TPMARCA) == '4E'
						oPrintPvt:SayAlign(nLinAtu+50, nColDad9, cValToChar(QRY_AUX->P8_HORA), oFontDet, 10, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
						Case AllTrim(P8_TPMARCA) == '4S'
						oPrintPvt:SayAlign(nLinAtu+50, nColDad10, cValToChar(QRY_AUX->P8_HORA), oFontDet, 10, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
					End
					QRY_AUX->(DbSkip())
				End
			EndIf		
			dData += 1
            //linhas entre os dados
           oPrintPvt:Line(nLinAtu+50, nColIni, nLinAtu+50, nColFin-211, nCorCinza)
 
			nLinAtu += 15
			//oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, nCorCinza)
 
        

			//Se atingiu o limite, quebra de pagina
			fQuebra()

			//QRY_AUX->(DbSkip())
		EndDo
		fImpRod()





		oPrintPvt:Preview()
	EndIf
	QRY_AUX->(DbCloseArea())

	FWRestArea(aArea)
Return

/*/{Protheus.doc} fLogoEmp
Função que retorna o logo da empresa conforme configuração da DANFE
@author jose vinicius lourenço
@since 18/12/2023
@version 1.0
@type function
/*/

Static Function fLogoEmp()
	Local cGrpCompany := AllTrim(FWGrpCompany())
	Local cCodEmpGrp  := AllTrim(FWCodEmp())
	Local cUnitGrp    := AllTrim(FWUnitBusiness())
	Local cFilGrp     := AllTrim(FWFilial())
	Local cLogo       := ''
	Local cCamFim     := GetTempPath()
	Local cStart      := GetSrvProfString('Startpath', '')

	//Se tiver filiais por grupo de empresas
	If !Empty(cUnitGrp)
		cDescLogo	:= cGrpCompany + cCodEmpGrp + cUnitGrp + cFilGrp

		//Senão, será apenas, empresa + filial
	Else
		cDescLogo	:= cEmpAnt + cFilAnt
	EndIf

	//Pega a imagem
	cLogo := cStart + 'DANFE' + cDescLogo + '.BMP'

	//Se o arquivo não existir, pega apenas o da empresa, desconsiderando a filial
	If !File(cLogo)
		cLogo	:= cStart + 'DANFE' + cEmpAnt + '.BMP'
	EndIf

	//Copia para a temporária do s.o.
	CpyS2T(cLogo, cCamFim)
	cLogo := cCamFim + StrTran(cLogo, cStart, '')

	//Se o arquivo não existir na temporária, espera meio segundo para terminar a cópia
	If !File(cLogo)
		Sleep(500)
	EndIf
Return cLogo

/*/{Protheus.doc} fImpCab
Função que imprime o cabeçalho do relatório
@author jose vinicius lourenço
@since 18/12/2023
@version 1.0
@type function
/*/

Static Function fImpCab()
	Local cTexto   := ''
	Local nLinCab  := 015

	//Iniciando Pagina
	oPrintPvt:StartPage()

     //retangulo certo
    oPrintPvt:Box(nLinAtu+100, nColIni, nLinAtu + 450, nColDad11+70, "-2")



	//Imprime o logo
	If File(cLogoEmp)
		oPrintPvt:SayBitmap(013, nColIni, cLogoEmp, 040, 040)
	EndIf

	//Cabecalho
	cTexto := 'Folha de Ponto'
	oPrintPvt:SayAlign(nLinCab, nColMeio-200, cTexto, oFontTit, 400, 20, /*nClrText*/, PAD_CENTER, /*nAlignVert*/)

	//Linha Separatoria
	nLinCab += 025
	oPrintPvt:Line(nLinCab+17,   nColIni-5, nLinCab+17,   nColFin-10)

	//Atualizando a linha inicial do relatorio
	nLinAtu := nLinCab + 5

	If nPagAtu == 1
		//Imprimindo os parâmetros e cabeçalho
		cTexto := MV_PAR01
		oPrintPvt:SayAlign(nLinAtu +23, nColIni, 'matricula :', oFontMin, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
		oPrintPvt:SayAlign(nLinAtu +23, nColIni+200, 'Nome :' + QRY_AUX->RA_NOME, oFontMin, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
		oPrintPvt:SayAlign(nLinAtu +23, nColIni+400, 'chapa :', oFontMin, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
		oPrintPvt:SayAlign(nLinAtu +30, nColIni, 'categoria :', oFontMin, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
		oPrintPvt:SayAlign(nLinAtu +30, nColIni+200, 'C.C : ', oFontMin, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
		oPrintPvt:SayAlign(nLinAtu +30, nColIni+400, 'Função :', oFontMin, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

		oPrintPvt:SayAlign(nLinAtu+100, nColIni+150, cTexto, oFontMin, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
		
		nLinAtu += 15

		oPrintPvt:Line(nLinAtu+25, nColIni, nLinAtu+25, nColFin, nCorCinza)
		nLinAtu += 5
	EndIf

	oPrintPvt:SayAlign(nLinAtu+50, nColDad1, 'Data', oFontMin, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
	oPrintPvt:SayAlign(nLinAtu+50, nColDad2, 'DIA', oFontMin, 20, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
	oPrintPvt:SayAlign(nLinAtu+50, nColDad3, '1a E.', oFontMin, 20, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
	oPrintPvt:SayAlign(nLinAtu+50, nColDad4, '1a S.', oFontMin, 20, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
	oPrintPvt:SayAlign(nLinAtu+50, nColDad5, '2a E', oFontMin, 20, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
	oPrintPvt:SayAlign(nLinAtu+50, nColDad6, '2a S.', oFontMin, 20, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
	oPrintPvt:SayAlign(nLinAtu+50, nColDad7, '3a  E.', oFontMin, 20, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
	oPrintPvt:SayAlign(nLinAtu+50, nColDad8, '3a S.', oFontMin, 20, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
	oPrintPvt:SayAlign(nLinAtu+50, nColDad9, '4a E.', oFontMin, 20, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
	oPrintPvt:SayAlign(nLinAtu+50, nColDad10, '4a S.', oFontMin, 20, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
	oPrintPvt:SayAlign(nLinAtu+80, nColDad11, 'ABONO', oFontMin, 30, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
	nLinAtu += 15
Return

 

/*/{Protheus.doc} fImpRod
Função que imprime o rodapé e encerra a página
@author jose vinicius lourenço
@since 18/12/2023
@version 1.0
@type function
/*/

Static Function fImpRod()
	Local nLinRod:= nLinFin
	Local cTexto := ''

	//Linha Separatoria
	oPrintPvt:Line(nLinRod,   nColIni, nLinRod,   nColFin)
	nLinRod += 3

	//Dados da Esquerda
	cTexto := dToC(dDataBase) + '     ' + cHoraEx + '     ' + FunName() + ' (FolhaPon)     ' + UsrRetName(RetCodUsr())
	oPrintPvt:SayAlign(nLinRod, nColIni, cTexto, oFontRod, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

	//Direita
	cTexto := 'Pagina '+cValToChar(nPagAtu)
	oPrintPvt:SayAlign(nLinRod, nColFin-40, cTexto, oFontRod, 040, 10, /*nClrText*/, PAD_RIGHT, /*nAlignVert*/)

	//Finalizando a pagina e somando mais um
	oPrintPvt:EndPage()
	nPagAtu++
Return

/*/{Protheus.doc} fQuebra
Função que valida se a linha esta próxima do final, se sim quebra a página
@author jose vinicius lourenço
@since 18/12/2023
@version 1.0
@type function
/*/

Static Function fQuebra()
	If nLinAtu >= nLinFin-10
		fImpRod()
		fImpCab()
	EndIf
Return
