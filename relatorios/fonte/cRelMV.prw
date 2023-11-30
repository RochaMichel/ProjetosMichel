#include "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TBICONN.CH"


*******************************************************************************
// Função   : RelESTR - Função de disparo de Email com anexos           	  |
// Modulo   : SIGAEST - Estoque e Custo                           	          |
// Fonte    : RelESTR.prw                                                     |
// ---------+--------------------------+--------------------------------------+
// Data     | Autor                    | Descricao                            |
// ---------+---------------+----------+--------------------------------------+
// 08/05/23 | Michel Rocha    |Cod.ERP   | Relatorio de movimento bancario    |
*******************************************************************************

User Function cRelMV()
	Private cRelMVF1 	 := GetNextAlias()
	Private cRelMVF2 	 := GetNextAlias()
	Private cPath	 := ''
	PRIVATE aPergs   := {}
	Private nRecCount:= 0


	aAdd(aPergs, {1, "Da Filial"    ,space(TamSX3("D1_FILIAL")[1]),PesqPict("SD1","D1_FILIAL"),,,,TamSX3("D1_FILIAL")[1], .F.}) //MV_PAR01
	aAdd(aPergs, {1, "Ate a Filial" ,space(TamSX3("D1_FILIAL")[1]),PesqPict("SD1","D1_FILIAL"),,,,TamSX3("D1_FILIAL")[1], .T.}) //MV_PAR02
	aAdd(aPergs, {1, "Da Emissão"   ,Date()   , "", ".T.", "", ".T.", 80 , .F.}) //MV_PAR03
	aAdd(aPergs, {1, "Até a Emissão",Date()   , "", ".T.", "", ".T.", 80 , .T.}) //MV_PAR04

	If !parambox(aPergs,"Informe os parametros")
		Return
	EndIf

	BeginSql Alias cRelMVF1
	SELECT F3_OBSERV,A1_NOME , F1_DOC,F4_TEXTO,F1_VALIPI, F1_VALICM,F3_ENTRADA ,F3_CHVNFE,F1_STATUS ,SUM(F1_VALBRUT) AS VALOR from SF3010 F3
	INNER JOIN %Table:SA1% A1 ON A1_FILIAL = SUBSTRING(F3_FILIAL,1,2) AND A1_COD = F3_CLIEFOR
	INNER JOIN %Table:SF1% F1 ON F1_FILIAL = F3_FILIAL AND F1_DOC = F3_NFISCAL AND F1_SERIE = F3_SERIE
	INNER JOIN %Table:SD1% D1 ON D1_FILIAL = F1_FILIAL AND D1_DOC = F1_DOC
	INNER JOIN %Table:SF4% F4 ON D1_FILIAL = F4_FILIAL AND  F4_CODIGO = D1_TES
	WHERE  F3_ENTRADA BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
	GROUP BY F3_OBSERV,A1_NOME ,F3_ENTRADA, F1_DOC,F4_TEXTO,F1_VALIPI, F1_VALICM,F3_CHVNFE , F1_STATUS
	EndSql

	BeginSql Alias cRelMVF2
	SELECT F3_OBSERV,A1_NOME , F2_DOC,F4_TEXTO,F2_VALIPI, F2_VALICM, F3_CHVNFE,F2_STATUS,F3_ENTRADA ,SUM(F2_VALBRUT) AS VALOR from SF3010 F3
	INNER JOIN %Table:SA1% A1 ON A1_FILIAL = SUBSTRING(F3_FILIAL,1,2) AND A1_COD = F3_CLIEFOR
	INNER JOIN %Table:SF2% F2 ON F2_FILIAL = F3_FILIAL AND F2_DOC = F3_NFISCAL AND F2_SERIE = F3_SERIE
	INNER JOIN %Table:SD2% D2 ON D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC
	INNER JOIN %Table:SF4% F4 ON D2_FILIAL = F4_FILIAL AND F4_CODIGO = D2_TES
	WHERE  F3_ENTRADA BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
	GROUP BY F3_OBSERV,A1_NOME ,F3_ENTRADA, F2_DOC,F4_TEXTO,F2_VALIPI, F2_VALICM,F3_CHVNFE,F2_STATUS
	EndSql
	
	If (cRelMVF1)->(Eof()) .AND. (cRelMVF2)->(Eof())
		(cRelMVF1)->(DbCloseArea())
		(cRelMVF2)->(DbCloseArea())
		MsgAlert('Não foram encontrados registros com os parâmetros fornecidos.', 'Atenção!')
		Return
	EndIf
	Count to nRecCount

	cPath := cGetFile(  , 'Arquivos', 1, 'C:\', .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY),.T.,.T.)
	cPath := 'C:\temp\'

	If !Empty(cPath)
		GeraXlsx()
		GeraPDF()
	EndIf

Return


	*******************************************************************************
// Função   : GeraExcelEntradas - Monta o Excel de Entradas no Periodo        |
// Modulo   : SIGAEST - Estoque e Custo                           	          |
// Fonte    : RelESTR.prw                                                     |
// ---------+--------------------------+--------------------------------------+
// Data     | Autor                    | Descricao                            |
// ---------+---------------+----------+--------------------------------------+
// 11/03/23 | Rivaldo G.    |Cod.ERP   | Busca os dados e monta o Excel 	  |
	*******************************************************************************

Static Function GeraXlsx()

	local oExcel 	:= FWMSEXCELEX():New()

	_DaData 	:= dtoc(MV_PAR03)
	_AteData 	:= dtoc(MV_PAR04)

	oExcel:SetFont("ARIAL")
	oExcel:SetFontSize(12)
	oExcel:SetBgGeneralColor("#FFFFFF")

	oExcel:SetFrColorHeader("#FFFFFF") // cor da fonte do cabeçalho
	oExcel:SetBgColorHeader("#FF0000") // background do cabeçalho

	********************** TERCEIRA ABA DO EXCEL VENDAS **************************
	oExcel:AddworkSheet("MOV.FISCAL")
	oExcel:AddTable("MOV.FISCAL" ,"RELATÓRIO MOVIMENTO FISCAL - DE "+_DaData+" ATÉ "+_ATEDATA)
	oExcel:AddColumn("MOV.FISCAL","RELATÓRIO MOVIMENTO FISCAL - DE "+_DaData+" ATÉ "+_ATEDATA,"Nota Fiscal",1,1)   //1
	oExcel:AddColumn("MOV.FISCAL","RELATÓRIO MOVIMENTO FISCAL - DE "+_DaData+" ATÉ "+_ATEDATA,"Emissão",2,1)		//2
	oExcel:AddColumn("MOV.FISCAL","RELATÓRIO MOVIMENTO FISCAL - DE "+_DaData+" ATÉ "+_ATEDATA,"Nome\Razão Social ",3,2) //3
	oExcel:AddColumn("MOV.FISCAL","RELATÓRIO MOVIMENTO FISCAL - DE "+_DaData+" ATÉ "+_ATEDATA,"Natureza operação",2,1) //4
	oExcel:AddColumn("MOV.FISCAL","RELATÓRIO MOVIMENTO FISCAL - DE "+_DaData+" ATÉ "+_ATEDATA,"ipi",1,1) //5
	oExcel:AddColumn("MOV.FISCAL","RELATÓRIO MOVIMENTO FISCAL - DE "+_DaData+" ATÉ "+_ATEDATA,"icms",1,1) //6
	oExcel:AddColumn("MOV.FISCAL","RELATÓRIO MOVIMENTO FISCAL - DE "+_DaData+" ATÉ "+_ATEDATA,"Valor",1,1) //7
	oExcel:AddColumn("MOV.FISCAL","RELATÓRIO MOVIMENTO FISCAL - DE "+_DaData+" ATÉ "+_ATEDATA,"Status",2,1) //8
	oExcel:AddColumn("MOV.FISCAL","RELATÓRIO MOVIMENTO FISCAL - DE "+_DaData+" ATÉ "+_ATEDATA,"Chave NFe",2,1) //9

	(cRelMVF1)->(DbGoTop())

	While (cRelMVF1)->(!Eof())
		oExcel:AddRow("MOV.FISCAL","RELATÓRIO MOVIMENTO FISCAL - DE "+_DaData+" ATÉ "+_ATEDATA ,;
			{ AllTrim((cRelMVF1)->(F1_DOC))      ,; 			    //1
		DtoC(StoD((cRelMVF1)->(F3_ENTRADA))) ,;		        //2
		AllTrim((cRelMVF1)->(A1_NOME))    ,;	            //3
		AllTrim((cRelMVF1)->(F4_TEXTO))       ,;				//4
		Transform((cRelMVF1)->(F1_VALIPI),"@R 9,999,999.99")  ,;	//5
		Transform((cRelMVF1)->(F1_VALICM),"@R 9,999,999.99")  ,;	//6
		Transform((cRelMVF1)->(VALOR),"@R 9,999,999.99")  ,;	//7
		Alltrim((cRelMVF1)->(F1_STATUS)) ,; //8
		Alltrim((cRelMVF1)->(F3_CHVNFE)) })	//9
		(cRelMVF1)->(DbSkip())
	EndDo
	(cRelMVF2)->(DbGoTop())

	While (cRelMVF2)->(!Eof())
		oExcel:AddRow("MOV.FISCAL","RELATÓRIO MOVIMENTO FISCAL - DE "+_DaData+" ATÉ "+_ATEDATA ,;
			{ AllTrim((cRelMVF2)->(F2_DOC))      ,; 			    //1
		DtoC(StoD((cRelMVF2)->(F3_ENTRADA))) ,;		        //2
		AllTrim((cRelMVF2)->(A1_NOME))    ,;	            //3
		AllTrim((cRelMVF2)->(F4_TEXTO))       ,;				//4
		Transform((cRelMVF2)->(F2_VALIPI),"@R 9,999,999.99")  ,;	//5
		Transform((cRelMVF2)->(F2_VALICM),"@R 9,999,999.99")  ,;	//6
		Transform((cRelMVF2)->(VALOR),"@R 9,999,999.99")  ,;	//7
		Alltrim((cRelMVF2)->(F2_STATUS)) ,; //8
		Alltrim((cRelMVF2)->(F3_CHVNFE)) })	//9
		(cRelMVF2)->(DbSkip())
	EndDo

	oExcel:Activate()
	oExcel:GetXMLFile(cPath+"RelMovFisc.xls")
	cArquivo := cPath+"RelMovFisc.xls"
	ShellExecute( "open", cArquivo, "", "", 1 )// executar o arquivo

Return

	********************************************************************************
// Função   : GeraExcelSaldos - Monta o Excel de Saldos dos produtos no Periodo|
// Modulo   : SIGAEST - Estoque e Custo                           	           |
// Fonte    : RelESTR.prw                                                      |
// ---------+--------------------------+---------------------------------------+
// Data     | Autor                    | Descricao                             |
// ---------+---------------+----------+---------------------------------------+
// 11/03/23 | Rivaldo G.    |Cod.ERP   | Busca os dados e monta o Excel        |
	********************************************************************************

Static Function GeraPDF()
	Local oPrint
	Local oTempTable
	Local cNaturez 			:= ""
	Local cFil 			    := ""
	Local cAlias 			:= ""
	Local nCount		:= 0
	Local nCounTot		:= 0
	Local nPag			:= 0
	Local nVlr  		:= 0
	Local nIpi  		:= 0
	Local nIcms  		:= 0
	Local n      		:= 0
	Local aInfos  		:= {}
	Local aFields  		:= {}
	Local lAdjustToLegacy := .F.
	Local lDisableSetup   := .T. //Não abre tela de setup da impressão
	Private oFont0  := TFont():New( "Times New Roman", , -7)
	Private oFont1  := TFont():New( "Times New Roman", , -8)
	Private oFont3  := TFont():New( "Times New Roman", , -10)
	Private oFont4  := TFont():New( "Times New Roman", , -11)
	Private oFont1n := TFont():New( "Times New Roman", , -8, ,.T.)
	Private oFont2  := TFont():New( "Times New Roman", , -20, ,.T.)
	Private oFont2n := TFont():New( "Times New Roman", , -10, ,.T.)
	Private oFont3ns:= TFont():New( "Times New Roman", , -13, ,.T.)
	Private oFont3n := TFont():New( "Times New Roman", , -17, ,.T.)
	Private nLin    := 005
	Private nSpace10   := 10
	Private nSpace15   := 15
	Private nSpace13   := 13
	Private nSpace20   := 20
	Private nLinBox    := 0
	Private oHGRAY := TBrush():New( , CLR_YELLOW)
 
	oPrint:= FWMSPrinter():New("RelCC.pdf", IMP_PDF, lAdjustToLegacy, cPath, lDisableSetup)
	//Setando os atributos necessários do relatório
	oPrint:SetLandscape()
	oPrint:SetResolution(78)
	oPrint:SetPaperSize(DMPAPER_A4)

	oPrint:nDevice  := 6
	oPrint:cPathPDF := cPath
	oPrint:lServer  := .F.
	oPrint:lViewPDF := .T.

	oPrint:StartPage()
	nPag++

	If MV_PAR01 == "      " .And. Upper(MV_PAR02) == "ZZZZZZ"
		cFil := "TODAS"
	Else
		cFil := MV_PAR01+" a "+Upper(MV_PAR02)
	EndIf

	oPrint:Say(nLin-20,0020,OemToAnsi("MOVIMENTAÇÃO FISCAL"),oFont2)
	oPrint:Say(nLin-20,0600,OemToAnsi("Empresa: "+AllTrim(SM0->M0_FULNAME)),oFont3)
	oPrint:Say(nLin-8,0670,OemToAnsi("Entrada: "+DtoC(MV_PAR03)+" a "+DtoC(MV_PAR04)+" | Filial: "+cFil),oFont3)
	oPrint:Say(nLin-8,0020,OemToAnsi("Emitido por: "+FwGetUserName(RetCodUsr())),oFont3)

	fImpCbTit(oPrint)
	(cRelMVF1)->(DbGoTop())
	While (cRelMVF1)->(!Eof())
		aadd(aInfos,{(cRelMVF1)->(F1_DOC),(cRelMVF1)->(F3_ENTRADA),(cRelMVF1)->(A1_NOME),(cRelMVF1)->(F4_TEXTO),(cRelMVF1)->(F1_VALIPI),(cRelMVF1)->(F1_VALICM),(cRelMVF1)->(VALOR),(cRelMVF1)->(F1_STATUS),(cRelMVF1)->(F3_CHVNFE)})
		(cRelMVF1)->(DBSKIP())
	EndDo
	(cRelMVF2)->(DbGoTop())
	While (cRelMVF2)->(!Eof())
		aadd(aInfos,{(cRelMVF2)->(F2_DOC),(cRelMVF2)->(F3_ENTRADA),(cRelMVF2)->(A1_NOME),(cRelMVF2)->(F4_TEXTO),(cRelMVF2)->(F2_VALIPI),(cRelMVF2)->(F2_VALICM),(cRelMVF2)->(VALOR),(cRelMVF2)->(F2_STATUS),(cRelMVF2)->(F3_CHVNFE)})
		(cRelMVF2)->(DBSKIP())
	EndDo
	(cRelMVF1)->(DbCloseArea())
	(cRelMVF2)->(DbCloseArea())

	oTempTable := FWTemporaryTable():New('ALIAS_TEMP')

//Adiciona no array das colunas as que serão incluidas (Nome do Campo, Tipo do Campo, Tamanho, Decimais)

	aFields := {}
	aAdd(aFields, {"DOC",     "C",  10, 0})
	aAdd(aFields, {"EMISSAO", "C",  8,  0})
	aAdd(aFields, {"NOME",    "C",  50, 2})
	aAdd(aFields, {"TEXTO",   "C",  50, 0})
	aAdd(aFields, {"VALIPI",  "N",  8,  0})
	aAdd(aFields, {"VALICM", "N",  8,  0})
	aAdd(aFields, {"VALOR",   "N",  8,  0})
	aAdd(aFields, {"STATUS",  "C",  8,  0})
	aAdd(aFields, {"CHVNFE",  "C",  50, 0})


//Define as colunas usadas
	oTempTable:SetFields( aFields )

//Cria índice com colunas setadas anteriormente
	oTempTable:AddIndex("1", {"TEXTO"} )

//Efetua a criação da tabela
	oTempTable:Create()

	cAlias := oTempTable:GetAlias()

	DbSelectArea(cAlias)

	for n := 1 to len(aInfos)
		(cAlias)->(DBAppend())
		(cAlias)->DOC     := aInfos[n][1]
		(cAlias)->EMISSAO := aInfos[n][2]
		(cAlias)->NOME    := aInfos[n][3]
		(cAlias)->TEXTO   := aInfos[n][4]
		(cAlias)->VALIPI  := aInfos[n][5]
		(cAlias)->VALICM  := aInfos[n][6]
		(cAlias)->VALOR   := aInfos[n][7]
		(cAlias)->STATUS  := aInfos[n][8]
		(cAlias)->CHVNFE  := aInfos[n][9]
		(cAlias)->(DBCommit())
	Next
	DbSelectArea(cAlias)
	DbsetOrder(1)
	nLin += nSpace20
	(cAlias)->(DbgoTop())
	While (cAlias)->(!Eof())
		nVlr  := 0
		nIpi  := 0
		nIcms  := 0
		nCount  := 0
		oPrint:Say(nLin,0020,OemToAnsi(AllTrim((cAlias)->(TEXTO))),oFont3ns)
		nLin += nSpace13
		cNaturez := (cAlias)->(TEXTO)
		While (cAlias)->(!Eof()) .AND. cNaturez == (cAlias)->(TEXTO)

			oPrint:Say(nLin,0020,AllTrim((cAlias)->(DOC))       ,oFont0) //1
			oPrint:Say(nLin,0080,DtoC(StoD((cAlias)->(EMISSAO))),oFont0) //2
			oPrint:Say(nLin,0140,AllTrim((cAlias)->(NOME))      ,oFont0) //3
			oPrint:Say(nLin,0350,AllTrim((cAlias)->(TEXTO))     ,oFont0) //4
			oPrint:Say(nLin,0545,Transform((cAlias)->(VALIPI),"@R 9,999,999.99") 	         ,oFont0) //5
			oPrint:Say(nLin,0595,Transform((cAlias)->(VALICM),"@R 9,999,999.99") 	         ,oFont0) //5
			oPrint:Say(nLin,0645,Transform((cAlias)->(VALOR) ,"@R 9,999,999.99") 	         ,oFont0) //5
			oPrint:Say(nLin,0700,AllTrim((cAlias)->(STATUS)) ,oFont0) //4
			oPrint:Say(nLin,0750,AllTrim((cAlias)->(CHVNFE)) ,oFont0) //4

			nVlr   += (cAlias)->(VALOR)
			nIpi   += (cAlias)->(VALIPI)
			nIcms  += (cAlias)->(VALICM)
			nLin += nSpace13

			IF nLin > 570

				nPag++
				oPrint:Say(600,0010,OemToAnsi("Página: "+cValToChar(nPag)),oFont0)

				oPrint:EndPage()
				oPrint:StartPage()
				//nLin := 022
				nLin := 005
				fImpCbTit(oPrint)

				nLin += nSpace13

			EndIF
			nCount++
			nCounTot++

			(cAlias)->(DbSkip())

			If (cAlias)->(Eof())
				nPag++
				oPrint:Say(600,0010,OemToAnsi("Página: "+cValToChar(nPag)),oFont0)
			EndIf

		EndDo
		oPrint:Line(nLin-8,0550 ,nLin-8, 0590)
		oPrint:Say(nLin,0545,Transform(nIpi,"@R 9,999,999.99"),oFont1n)
		oPrint:Line(nLin-8,0600 ,nLin-8, 0640)
		oPrint:Say(nLin,0595,Transform(nIcms,"@R 9,999,999.99"),oFont1n)
		oPrint:Line(nLin-8,0650 ,nLin-8, 0690)
		oPrint:Say(nLin,0645,Transform(nVlr,"@R 9,999,999.99"),oFont1n)
		oPrint:Say(nLin,0020,cValToChar(nCount)+" registro(s)",oFont0)
		nLin += nSpace13

	EndDo
	oPrint:Line(nLin-8,0020 ,nLin-8, 0080)
	oPrint:Say(nLin,0020,cValToChar(nCounTot)+" registro(s)",oFont0)

	(cAlias)->(DbCloseArea())
	oTempTable:Delete()
	oPrint:Preview()//Mostrando o relatório

Return


Static Function fImpCbTit(oPrint)

	nLin += nSpace20
	//oPrint:Say(nLin,0275,OemToAnsi('Nota Fiscal')	,oFont3ns)
	oPrint:Say(nLin,0020,OemToAnsi('Nota Fiscal')	,oFont3ns)
	oPrint:Say(nLin,0080,OemToAnsi('Emissão') 		,oFont3ns)
	oPrint:Say(nLin,0140,OemToAnsi('Nome\Razão Social')		,oFont3ns)
	oPrint:Say(nLin,0350,OemToAnsi('Natureza Operação')	 	,oFont3ns)
	oPrint:Say(nLin,0550,OemToAnsi('ipi')		    ,oFont3ns)
	oPrint:Say(nLin,0600,OemToAnsi('icms')		    ,oFont3ns)
	oPrint:Say(nLin,0650,OemToAnsi('Valor')		    ,oFont3ns)
	oPrint:Say(nLin,0700,OemToAnsi('Status')		    ,oFont3ns)
	oPrint:Say(nLin,0750,OemToAnsi('Chave Nfe')		    ,oFont3ns)


Return


