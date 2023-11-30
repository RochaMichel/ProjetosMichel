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
// 11/03/23 | Rivaldo G.    |Cod.ERP   | Chama a função de Disparo do Email	  |
*******************************************************************************

static oCellHorAlign := FwXlsxCellAlignment():Horizontal()
static oCellVertAlign := FwXlsxCellAlignment():Vertical()

User Function RelFat()
	Private cFat := GetNextAlias()
	Private cPath:= ''
	PRIVATE aPergs      := {}
	Private nRecCount := 0

    aAdd(aPergs, {1, "Da Filial"    ,space(TamSX3("D2_FILIAL")[1]),PesqPict("SD2","D2_FILIAL"),,,,TamSX3("D2_FILIAL")[1], .F.}) //MV_PAR01  
	aAdd(aPergs, {1, "Ate a Filial" ,space(TamSX3("D2_FILIAL")[1]),PesqPict("SD2","D2_FILIAL"),,,,TamSX3("D2_FILIAL")[1], .T.}) //MV_PAR02
	aAdd(aPergs, {1, "Do Cliente"   ,space(TamSX3("A1_COD")[1]),PesqPict("SA1","A1_COD"),,"SA1",,TamSX3("A1_COD")[1], .F.}) //MV_PAR03
	aAdd(aPergs, {1, "Ate o Cliente",space(TamSX3("A1_COD")[1]),PesqPict("SA1","A1_COD"),,"SA1",,TamSX3("A1_COD")[1], .T.}) //MV_PAR04
	aAdd(aPergs, {1, "Da Emissão"   ,Date()   , "", ".T.", "", ".T.", 80 , .F.}) //MV_PAR05
	aAdd(aPergs, {1, "Até a Emissão",Date()   , "", ".T.", "", ".T.", 80 , .T.}) //MV_PAR06

	If !parambox(aPergs,"Informe os parametros")
		Return
	EndIf

	BeginSql Alias cFat
		SELECT DOC=D2_DOC, SERIE=D2_SERIE, EMISSAO=D2_EMISSAO, CLIENTE=A1_NOME, DESCRICAO=B1_DESC, TOTAL=D2_TOTAL,
			   QTD=D2_QUANT, PESOT=D2_PESO//, PESOL=CC0_PESOB
		FROM %Table:SD2% D2, %Table:SB1% B1, %Table:SA1% A1//, %Table:CC0% C0
		WHERE D2.%NOTDEL% AND B1.%NOTDEL% AND A1.%NOTDEL% //AND C0.%NOTDEL%
			AND B1_COD = D2_COD  
			AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA
			//AND D2_DOC = CC0_NUMMDF AND D2_SERIE = CC0_SERMDF AND D2_FILIAL = CC0_FILIAL
			AND D2_CLIENTE >= %Exp:MV_PAR03%
			AND D2_CLIENTE <= %Exp:MV_PAR04%
			AND D2_FILIAL  >= %Exp:MV_PAR01%
			AND D2_FILIAL  <= %Exp:MV_PAR02%
			AND D2_EMISSAO >= %Exp:DtoS(MV_PAR05)%
			AND D2_EMISSAO <= %Exp:DtoS(MV_PAR06)%
			//AND D2_DOC = '000008704'
		ORDER BY EMISSAO, DOC
	EndSql

	If (cFat)->(Eof())
		(cFat)->(DbCloseArea())
		MsgAlert('Não foram encontrados registros com os parâmetros fornecidos.', 'Atenção!')
		Return 
	EndIf

	Count to nRecCount

	cPath := cGetFile(  , 'Arquivos', 1, 'C:\', .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY),.T.,.T.)

	If !Empty(cPath)
		GeraXlsx()
		GeraPDF()
	EndIf
	
	(cFat)->(DbCloseArea())
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
    local cArquivo := cPath + "RelFat.rel"
    local oFileW := FwFileWriter():New(cArquivo)
    local oPrtXlsx := FwPrinterXlsx():New()
	Local nRow 		:= 1

	oPrtXlsx:Activate(cArquivo, oFileW)

    oPrtXlsx:AddSheet("VENDAS")
	cHorAlignment := oCellHorAlign:Center()
    cVertAlignment := oCellVertAlign:Center()

	oPrtXlsx:SetRowsHeight(/*nRowFrom*/1,/*nRowTo*/1, /*nHeight*/21)

	oPrtXlsx:SetColumnsWidth(1, 2, 10.00)
	oPrtXlsx:SetColumnsWidth(3, 3, 67.00)
	oPrtXlsx:SetColumnsWidth(4, 4, 61.00)
	oPrtXlsx:SetColumnsWidth(5, 6, 14.00)
	//oPrtXlsx:SetColumnsWidth(7, 8, 16.00)

	cStyle := FwXlsxBorderStyle():Thin() //01 - Thin - linha contínua
	oPrtXlsx:SetBorder(/*lLeft*/.T., /*lTop*/.T., /*lRight*/.T., /*lBottom*/.T., cStyle, "000000")
	oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, /*lWrapText*/.F., /*nRotation*/0, "000000", "FFFF00", "" )
	oPrtXlsx:SetText( nRow , /*nCol*/1 , "NF"			   )	//-- 1
	oPrtXlsx:SetText( nRow , /*nCol*/2 , "DATA"			   )	//-- 2
	oPrtXlsx:SetText( nRow , /*nCol*/3 , "Cliente"		   )	//-- 3
	oPrtXlsx:SetText( nRow , /*nCol*/4 , "Descrição"	   )	//-- 4
	//oPrtXlsx:SetText( nRow , /*nCol*/5 , "Peso Liq.(Kg)"   )	//-- 5
	oPrtXlsx:SetText( nRow , /*nCol*/5 , "Bags (und.)"	   )	//-- 6
//	oPrtXlsx:SetText( nRow , /*nCol*/7 , "Liner Peso Total")	//-- 7
	oPrtXlsx:SetText( nRow , /*nCol*/6 , "Valor NF."	   )	//-- 8
	oPrtXlsx:ResetCellsFormat()
(cFat)->(DbGoTop())

	While (cFat)->(!Eof())
		nRow++
		oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, /*lWrapText*/.F., /*nRotation*/0, "000000", "FFFFFF", "" )
		oPrtXlsx:SetValue( nRow , /*nCol*/1 , DOC			  	 )	//-- 1
		oPrtXlsx:SetValue( nRow , /*nCol*/2 , DtoC(StoD(EMISSAO)))	//-- 2
		oPrtXlsx:SetValue( nRow , /*nCol*/3 , AllTrim(CLIENTE)	 )	//-- 3
		oPrtXlsx:SetValue( nRow , /*nCol*/4 , aLLtRIM(DESCRICAO) )	//-- 4
	//d	oPrtXlsx:SetValue( nRow , /*nCol*/5 , ""				 )	//-- 5
		oPrtXlsx:SetValue( nRow , /*nCol*/5 , QTD	 			 )	//-- 6
	//	oPrtXlsx:SetValue( nRow , /*nCol*/7 , PESOT  			 )	//-- 7
		oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, /*lWrapText*/.F., /*nRotation*/0, "000000", "FFFFFF", "R$ #,##0.00")
		oPrtXlsx:SetValue( nRow , /*nCol*/6 , TOTAL				 )	//-- 8
		oPrtXlsx:ResetCellsFormat()

		(cFat)->(DbSkip())
	EndDo

	oPrtXlsx:toXlsx()
	cArquivo := StrTran(cArquivo, ".rel", ".xlsx")
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
	Local nCount		:= 0
	Local lAdjustToLegacy := .F.
	Local lDisableSetup   := .T. //Não abre tela de setup da impressão
    Private oFont0  := TFont():New( "Arial", , -7)
	Private oFont1  := TFont():New( "Arial", , -8)
	Private oFont3  := TFont():New( "Arial", , -10)
    Private oFont4  := TFont():New( "Arial", , -11)
	Private oFont1n := TFont():New( "Arial", , -8, ,.T.)
	Private oFont2  := TFont():New( "Arial", , -20, ,.T.)
	Private oFont3n := TFont():New( "Arial", , -11, ,.T.)
	Private oFont2n := TFont():New( "Arial", , -9, ,.T.)
    Private oFont3ns:= TFont():New( "Arial", , -11, ,.T.,,,,,.T.)
	Private nLin    := 005
	Private nSpace10   := 10
	Private nSpace15   := 15
	Private nSpace20   := 20
	Private nLinBox    := 0
	Private oHGRAY := TBrush():New( , CLR_YELLOW)

	oPrint:= FWMSPrinter():New("RelFat.pdf", IMP_PDF, lAdjustToLegacy, cPath, lDisableSetup)
	//Setando os atributos necessários do relatório
	oPrint:SetLandscape()
	oPrint:SetResolution(78)
	oPrint:SetPaperSize(DMPAPER_A4)

	oPrint:nDevice  := 6
	oPrint:cPathPDF := cPath
	oPrint:lServer  := .F.
	oPrint:lViewPDF := .T.

	oPrint:StartPage()

	fImpCbTit(oPrint)

	oPrint:Box(nLin+5, 0010, nLin+20, 900, "-4")
	oPrint:Line(nLin,0070 ,nLin+20, 0070)//fim NF
	oPrint:Line(nLin,0120 ,nLin+20, 0120)//fim DATA
	oPrint:Line(nLin,0370 ,nLin+20, 0370)//fim Cliente
	oPrint:Line(nLin,0600 ,nLin+20, 0600)//fim Descrição
	//oPrint:Line(nLin,0670 ,nLin+20, 0670)//fim Peso Liq.
	oPrint:Line(nLin,0670 ,nLin+20, 0670)//fim Bags Uni.
	//oPrint:Line(nLin,0817 ,nLin+20, 0817)//fim Peso Bruto

	nLin += nSpace15
    nLinBox := nLin

	(cFat)->(DbGoTop())

	While (cFat)->(!Eof())
	
		nCount++
		If nCount <> nRecCount .And. nRecCount <> 1
			oPrint:Box(nLinBox-10, 0010, nLinBox+5, 900, "-4")
			oPrint:Line(nLin-25,0070 ,nLinBox+5, 0070)//fim NF
			oPrint:Line(nLin-25,0120 ,nLinBox+5, 0120)//fim DATA
			oPrint:Line(nLin-25,0370 ,nLinBox+5, 0370)//fim Cliente
			oPrint:Line(nLin-25,0600 ,nLinBox+5, 0600)//fim Descrição
			//oPrint:Line(nLin-25,0670 ,nLinBox+5, 0670)//fim Peso Liq.
			oPrint:Line(nLin-25,0670 ,nLinBox+5, 0670)//fim Bags Uni.
			//oPrint:Line(nLin-25,0817 ,nLinBox+5, 0817)//fim Peso Bruto
		EndIf

		oPrint:Say(nLin,0025,AllTrim(DOC)	  	 ,oFont0)
		oPrint:Say(nLin,0078,DtoC(StoD(EMISSAO)) ,oFont0)
		oPrint:Say(nLin,0125,SubStr(AllTrim(CLIENTE),1,60),oFont0)
		oPrint:Say(nLin,0375,SubStr(AllTrim(DESCRICAO),1,55),oFont0)
		//oPrint:Say(nLin,0612,""				 	 ,oFont0)
		oPrint:Say(nLin,0612,Padc(cValToChar(QTD),35)	 ,oFont0)
		//oPrint:Say(nLin,0750,Padc(cValToChar(PESOT),35) 	 ,oFont0)
		oPrint:Say(nLin,0675,"R$"+Padl(Transform(TOTAL,PesqPict("SD2","D2_TOTAL")),20),oFont0)

		nLin += nSpace15
        nLinBox+= nSpace15

		IF nLin > 580

			oPrint:Say(600,0010,OemToAnsi("Página: "),oFont0)

            oPrint:EndPage()
            oPrint:StartPage()     
            //nLin := 022   
            nLin := 005   
			fImpCbTit(oPrint)

            nLin += nSpace15
            nLinBox := nLin
        EndIF

		(cFat)->(DbSkip())

		If (cFat)->(!Eof())
			oPrint:Box(nLinBox-10, 0010, nLinBox+5, 900, "-4")
			oPrint:Line(nLin-25,0070 ,nLinBox+5, 0070)//fim NF
			oPrint:Line(nLin-25,0120 ,nLinBox+5, 0120)//fim DATA
			oPrint:Line(nLin-25,0370 ,nLinBox+5, 0370)//fim Cliente
			oPrint:Line(nLin-25,0600 ,nLinBox+5, 0600)//fim Descrição
			//oPrint:Line(nLin-25,0670 ,nLinBox+5, 0670)//fim Peso Liq.
			oPrint:Line(nLin-25,0670 ,nLinBox+5, 0670)//fim Bags Uni.
			//oPrint:Line(nLin-25,0817 ,nLinBox+5, 0817)//fim Peso Bruto
		EndIf
	EndDo
 
	oPrint:Preview()//Mostrando o relatório

Return 


Static Function fImpCbTit(oPrint)

	oPrint:SayAlign( nLin-25, 0370,OemToAnsi("Relatório de Faturamento"), oFont2, 235, 200,CLR_HRED,2,2)

	oPrint:Say(nLin-30,0670,OemToAnsi("Empresa: BBA NORDESTE INDUSTRIA DE CONTAINERS FLEXIVEIS LTDA"),oFont0)
	oPrint:Say(nLin-20,0805,OemToAnsi("Entrada: "+DtoC(MV_PAR05)+" a "+DtoC(MV_PAR06)),oFont0)

	oPrint:Say(nLin-30,0010,OemToAnsi("Emissão: "+DtoC(Date())),oFont0)
	oPrint:Say(nLin-20,0010,OemToAnsi("Emitido por: "+FwGetUserName(RetCodUsr())),oFont0)

    nLin+=nSpace15
	oPrint:Box(nLin, 0010, nLin+025, 900, "-4")
    oPrint:FillRect({nLin+1, 0011, nLin+024, 899}, oHGRAY) 
	oPrint:Line(nLin,0070 ,nLin+25, 0070)//fim NF
    oPrint:Line(nLin,0120 ,nLin+25, 0120)//fim DATA
    oPrint:Line(nLin,0370 ,nLin+25, 0370)//fim Cliente
    oPrint:Line(nLin,0600 ,nLin+25, 0600)//fim Descrição
   // oPrint:Line(nLin,0670 ,nLin+25, 0670)//fim Peso Liq.
    oPrint:Line(nLin,0670 ,nLin+25, 0670)//fim Bags Uni.
  //  oPrint:Line(nLin,0817 ,nLin+25, 0817)//fim Peso Bruto

	nLin += nSpace15
    oPrint:Say(nLin,0035,OemToAnsi('NF') 			  ,oFont4)
    oPrint:Say(nLin,0083,OemToAnsi('DATA') 			  ,oFont4)
    oPrint:Say(nLin,0235,OemToAnsi('Cliente')		  ,oFont4)
    oPrint:Say(nLin,0460,OemToAnsi('Descrição') 	  ,oFont4)
   // oPrint:Say(nLin,0608,OemToAnsi('Peso Liq.(Kg)')   ,oFont4)
    oPrint:Say(nLin,0608,OemToAnsi('Bags (und.)')     ,oFont4)
  //  oPrint:Say(nLin,0747,OemToAnsi('Liner Peso Total'),oFont4)
    oPrint:Say(nLin,0686,OemToAnsi('Valor NF.')  	  ,oFont4)  
    
Return


 