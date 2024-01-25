#include "PROTHEUS.CH"
#include "TBICONN.ch"

*******************************************************************************
// Funcao   : RELDP2 - Função para gerar o relatorio de batidas        	 	  |
// Modulo   : SIGAGPE - Gestão de pessoal                           	      |
// Fonte    : RELDP2.prw                        	                          |
// ---------+--------------------------+--------------------------------------+
// Data     | Autor                    | Descricao                            |
// ---------+---------------+----------+--------------------------------------+
// 24/01/24 | Rivaldo G.    |Cod.ERP   | Monta os parâmetros e executa o arqv.|
*******************************************************************************

static oCellHorAlign := FwXlsxCellAlignment():Horizontal()
static oCellVertAlign := FwXlsxCellAlignment():Vertical()

User Function RELDP2(aParam)
	Local cArquivo      := ''
	Local aPergs        := {}
	Private _DaData		:= ''
	Private _AteData	:= ''
	Private  DaData		:= ''
	Private  AteData	:= ''
	Private cStyle  	:= FwXlsxBorderStyle():Thin() //01 - Thin - linha contÃ­nua
	Private cFont 	    := FwPrinterFont():Arial()
	Private cHorAliCent := oCellHorAlign:Center()
	Private cHorAliLeft := oCellHorAlign:left()
	Private cHorAliRight:= oCellHorAlign:right()
	Private cVertAliCent:= oCellVertAlign:Center()
	Private cPath       := '\spool\'
	Private cPathLocal  := GetTempPath()

	If Isblind()
		Prepare Environment Empresa aParam[1] Filial aParam[2]

	Else

		aAdd(aPergs, {1, "Da Filial"      ,space(TamSX3("A1_filial")[1]),PesqPict("SA1","A1_filial"),,'SM0',,TamSX3("A1_filial")[1], .F.}) //MV_PAR01
		aAdd(aPergs, {1, "Ate a Filial"   ,space(TamSX3("A1_filial")[1]),PesqPict("SA1","A1_filial"),,'SM0',,TamSX3("A1_filial")[1], .T.}) //MV_PAR02
		aAdd(aPergs, {1, "De C. Custo "   ,space(TamSX3("CTT_CUSTO")[1]),"@!",'.T.','CTT','.T.',TamSX3("CTT_CUSTO")[1]+50	,.F.})//MV_PAR03
		aAdd(aPergs, {1, "Até C. Custo"   ,space(TamSX3("CTT_CUSTO")[1]),"@!",'.T.','CTT','.T.',TamSX3("CTT_CUSTO")[1]+50	,.T.})//MV_PAR04
		aAdd(aPergs, {1, "Da Matricula"   ,space(TamSX3("RG_MAT")[1]),"@!",'.T.','SRA','.T.',TamSX3("RG_MAT")[1]+50	,.F.})//MV_PAR05
		aAdd(aPergs, {1, "Até a Matricula",space(TamSX3("RG_MAT")[1]),"@!",'.T.','SRA','.T.',TamSX3("RG_MAT")[1]+50	,.T.})//MV_PAR06
		aAdd(aPergs, {1, "Da data"   	  ,Date()   , "", ".T.", "", ".T.", 80 , .F.}) //MV_PAR07
		aAdd(aPergs, {1, "Até a data"  	  ,Date()   , "", ".T.", "", ".T.", 80 , .T.}) //MV_PAR08
		aAdd(aPergs, {2, "Tipo de Relatorio :", "1" , {"1=Individual","2=Consolidado"}  , 60 ,".T.",.T.})//MV_PAR09

		If !parambox(aPergs,"Informe os parametros")
			Return
		EndIf

		//cPathLocal := cGetFile("Todos os arquivos|.", "Selecione o local:",  0, "\", .F., GETF_LOCALHARD, .F.)

		If MV_PAR09 == '1'
			Processa({|| cArquivo := PorMat() },"Aguarde um momento, Gerando relatorio...")
		Else
			Processa({|| cArquivo := PorCCusto() },"Aguarde um momento, Gerando relatorio...")
		EndIf

		oExib := MsExcel():New()             //Abre uma nova conexÃ£o com Excel
		oExib:WorkBooks:Open(cArquivo)     //Abre uma planilha
		oExib:SetVisible(.T.)                 //Visualiza a planilha
		oExib:Destroy()

	EndIf

	If Isblind()
		Reset Environment
	EndIf

Return


	*******************************************************************************
// FunÃ§Ã£o   : GeraExcelEntradas - Monta o Excel de Entradas no Periodo        |
// Modulo   : SIGAEST - Estoque e Custo                           	          |
// Fonte    : RelESTR.prw                                                     |
// ---------+--------------------------+--------------------------------------+
// Data     | Autor                    | Descricao                            |
// ---------+---------------+----------+--------------------------------------+
// 11/03/23 | Rivaldo G.    |Cod.ERP   | Busca os dados e monta o Excel 	  |
	*******************************************************************************
Static Function PorMat()
	Local cQuery    := ''
	Local cMat      := ''
	Local cFil      := ''
	Local cNome     := ''
	local cArquivo 	:= cPath+"RelBatidas.rel"
	local oFileW   	:= FwFileWriter():New(cArquivo)
	local oPrtXlsx 	:= FwPrinterXlsx():New()
	Local nRow 	   	:= 1
	Local cCor 		:= "95B3D7"//"66FFFF"
	Local cArquivoFinal:= ""
	Local nDias		:= 0

	cQuery := " SELECT
	cQuery += " 	P8_FILIAL FILIAL, "
	cQuery += " 	P8_DATA DATA, "
	cQuery += " 	P8_MAT MATRICULA, "
	cQuery += " 	P8_CC CODIGO, "
	cQuery += " 	NUM_REGISTROS REGISTROS, "
	cQuery += " 	CTT_DESC01 DESCRICAO, "
	cQuery += " 	RA_NOME NOME,  "
	cQuery += " 	P6_DESC AS JUSTIFICATIVA "
	cQuery += " FROM ( "
	cQuery += " 	SELECT P8_DATA , P8_MAT, P8_CC, P8_FILIAL, COUNT(*) AS NUM_REGISTROS "
	cQuery += " 	FROM "+RetSqlName('SP8')+" SP8 "
	cQuery += " 	WHERE P8_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cQuery += " 		AND P8_DATA BETWEEN '"+DtoS(MV_PAR07)+"' AND '"+DtoS(MV_PAR08)+"' "
	cQuery += " 		AND P8_CC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	cQuery += " 		AND P8_MAT BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	cQuery += " 	GROUP BY P8_FILIAL, P8_MAT, P8_CC, P8_DATA "
	cQuery += " 	) AS CONTAGEM_REGISTROS "
	cQuery += " 	INNER JOIN "+RetSqlName('CTT')+" CTT ON P8_CC = CTT_CUSTO "
	cQuery += " 	INNER JOIN "+RetSqlName('SRA')+" SRA ON P8_MAT = RA_MAT "
	cQuery += "     INNER JOIN "+RetSqlName('SPC')+" SPC ON PC_MAT = RA_MAT AND PC_FILIAL = RA_FILIAL AND SPC.D_E_L_E_T_ <> '*' "
	cQuery += "     LEFT  JOIN "+RetSqlName('SP6')+" SP6 ON P6_CODIGO = PC_ABONO AND SP6.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE NUM_REGISTROS < 4 "
	cQuery += " GROUP BY P8_FILIAL, P8_MAT, RA_NOME, CTT_DESC01 , P8_CC, NUM_REGISTROS, P8_DATA, P6_DESC "
	cQuery += " ORDER BY P8_FILIAL, P8_MAT "
	MpSysOpenQuery(cQuery, "TE5")

	If TE5->(Eof())
		TE5->(DbCloseArea())
		Return ""
	EndIf

	oPrtXlsx:Activate(cArquivo, oFileW)
	oPrtXlsx:AddSheet("INDIVIDUAL")

	//definiÃ§Ã£o da largura das colunas
	oPrtXlsx:SetColumnsWidth(1, 1, 9.33	) // Filial
	oPrtXlsx:SetColumnsWidth(2, 2, 14	) // centro de custo
	oPrtXlsx:SetColumnsWidth(3, 3, 43   ) // descricao
	oPrtXlsx:SetColumnsWidth(4, 4, 9    ) // matricula
	oPrtXlsx:SetColumnsWidth(5, 5, 36   ) // nome
	oPrtXlsx:SetColumnsWidth(6, 6, 14   ) // dias
	oPrtXlsx:SetColumnsWidth(7, 7, 28   ) // dias

	oPrtXlsx:SetFont(cFont, 16, .F., .T., .F.) // seta o texto em negrito
	oPrtXlsx:MergeCells(/*lin inicial*/1,/*col inicial*/1,/*lin final*/1,/*col final*/7)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	oPrtXlsx:MergeCells(/*lin inicial*/2,/*col inicial*/1,/*lin final*/2,/*col final*/7)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	oPrtXlsx:MergeCells(/*lin inicial*/3,/*col inicial*/1,/*lin final*/3,/*col final*/7)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	oPrtXlsx:MergeCells(/*lin inicial*/4,/*col inicial*/1,/*lin final*/4,/*col final*/7)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	oPrtXlsx:MergeCells(/*lin inicial*/5,/*col inicial*/1,/*lin final*/5,/*col final*/7)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	//oPrtXlsx:MergeCells(/*lin inicial*/6,/*col inicial*/1,/*lin final*/6,/*col final*/7)// merge das celulas iniciais para o cabeÃ§alho do arquivo

	oPrtXlsx:SetCellsFormat(cHorAliLeft, cVertAliCent, /*lWrapText*/.F., /*nRotation*/0, "000000", "FFFFFF", "" )
	oPrtXlsx:SetText(/*nRow*/1, /*nCol*/ 1, "RELATÓRIO DE BATIDAS NÃO REGISTRADAS INDIVIDUAL") // Texto em A1
	oPrtXlsx:SetFont(cFont, 10, .F., .T., .F.) // seta o texto em negrito
	oPrtXlsx:SetText(/*nRow*/2, /*nCol*/ 1, "EMPRESA: "+iIf(Empty(MV_PAR01),"TODAS","DE "+MV_PAR01+" ATÉ "+Upper(MV_PAR02))) // Texto em A1
	oPrtXlsx:SetText(/*nRow*/3, /*nCol*/ 1, "DATA: DE "+DtoC(MV_PAR07)+" ATÉ "+DtoC(MV_PAR08)) // Texto em A1
	oPrtXlsx:SetText(/*nRow*/4, /*nCol*/ 1, "CENTRO DE CUSTO: "+iIf(Empty(MV_PAR03),"TODOS","DE "+MV_PAR03+" ATÉ "+Upper(MV_PAR04))) // Texto em A1
	oPrtXlsx:SetText(/*nRow*/5, /*nCol*/ 1, "MATRICULA: "+iIf(Empty(MV_PAR05),"TODAS","DE "+MV_PAR05+" ATÉ "+Upper(MV_PAR05))) // Texto em A1
	//oPrtXlsx:SetText(/*nRow*/6, /*nCol*/ 1, "INDIVIDUAL") // Texto em A1

	oPrtXlsx:SetBorder(/*lLeft*/.T., /*lTop*/.T., /*lRight*/.T., /*lBottom*/.T., cStyle, "000000")//borda
	nRow := nRow+5
	oPrtXlsx:SetCellsFormat(cHorAliCent, cVertAliCent, /*lWrapText*/.F., /*nRotation*/0,"000000",cCor, "" )
	oPrtXlsx:SetText( nRow , /*nCol*/1 , "Empresa"		    ) //-- 1
	oPrtXlsx:SetText( nRow , /*nCol*/2 , "Centro de custo"	) //-- 2
	oPrtXlsx:SetText( nRow , /*nCol*/3 , "Descricao"	    ) //-- 3
	oPrtXlsx:SetText( nRow , /*nCol*/4 , "Matricula"        ) //-- 4
	oPrtXlsx:SetText( nRow , /*nCol*/5 , "Nome"			    ) //-- 5
	oPrtXlsx:SetText( nRow , /*nCol*/6 , "Data"			    ) //-- 6
	oPrtXlsx:SetText( nRow , /*nCol*/7 , "Motivo"			) //-- 7
	oPrtXlsx:ResetCellsFormat()

	While TE5->(!Eof())
		oPrtXlsx:SetFont(cFont, 10, .F., .F., .F.) // seta o texto sem negrito
		cCentro  := AllTrim(TE5->CODIGO)
		cDescCC  := AllTrim(TE5->DESCRICAO)
		nDias 	 := 0
		cMat     := TE5->MATRICULA
		cNome    := AllTrim(TE5->NOME)
		While TE5->(!Eof()) .And. cMat == TE5->MATRICULA

			cDescJus:= AllTrim(TE5->JUSTIFICATIVA)
			nDias++
			cFil    := TE5->FILIAL
			cData   := cValToChar(StoD(TE5->DATA))

			nRow++
			oPrtXlsx:SetCellsFormat(cHorAliCent, cVertAliCent, /*lWrapText*/.F.,/*nRotation*/0,"000000","FFFFFF","")
			oPrtXlsx:SetValue( nRow , /*nCol*/1 , cFil		     			          )//-- 1
			oPrtXlsx:SetValue( nRow , /*nCol*/2 , cCentro			  		          )//-- 2
			oPrtXlsx:SetValue( nRow , /*nCol*/3 , cDescCC		  			      	  )//-- 3
			oPrtXlsx:SetValue( nRow , /*nCol*/4 , cMat			  			          )//-- 4
			oPrtXlsx:SetValue( nRow , /*nCol*/5 , cNome						          )//-- 5
			oPrtXlsx:SetValue( nRow , /*nCol*/6 , cData 						  	  )//-- 6
			oPrtXlsx:SetValue( nRow , /*nCol*/7 , cDescJus 						  	  )//-- 7

			TE5->(DbSkip())
		End
		oPrtXlsx:SetFont(cFont, 10, .F., .T., .F.) // seta o texto em negrito
		nRow++
		oPrtXlsx:SetCellsFormat(cHorAliCent, cVertAliCent, /*lWrapText*/.F.,/*nRotation*/0,"000000",cCor,"")
		oPrtXlsx:SetValue( nRow , /*nCol*/1 , ''		     			          )//-- 1
		oPrtXlsx:SetValue( nRow , /*nCol*/2 , ''						  		  )//-- 2
		oPrtXlsx:SetValue( nRow , /*nCol*/3 , 'TOTAL '+AllTrim(cNome)			  )//-- 3
		oPrtXlsx:SetValue( nRow , /*nCol*/4 , ''			 			          )//-- 4
		oPrtXlsx:SetValue( nRow , /*nCol*/5 , ''						          )//-- 5
		oPrtXlsx:SetValue( nRow , /*nCol*/6 , nDias						  	 	  )//-- 6
		oPrtXlsx:SetValue( nRow , /*nCol*/7 , ''								  )//-- 7

	End
	TE5->(DbCloseArea())

	oPrtXlsx:toXlsx()
	cArquivoFinal := StrTran(cArquivo, ".rel", ".xlsx")
	If !IsBlind()
		If File(cPathLocal+"RelBatidas.rel")
			FErase(cPathLocal+"RelBatidas.rel")
		EndIf
		CpyS2T(cArquivoFinal, cPathLocal)
		cArquivoFinal := StrTran(cArquivoFinal, cPath, cPathLocal)
	EndIf
	FErase(cArquivo)

Return cArquivoFinal


	*******************************************************************************
// FunÃ§Ã£o   : GeraExcelEntradas - Monta o Excel de Entradas no Periodo      |
// Modulo   : SIGAEST - Estoque e Custo                           	          |
// Fonte    : RelESTR.prw                                                     |
// ---------+--------------------------+--------------------------------------+
// Data     | Autor                    | Descricao                            |
// ---------+---------------+----------+--------------------------------------+
// 11/03/23 | Rivaldo G.    |Cod.ERP   | Busca os dados e monta o Excel 	  |
	*******************************************************************************
Static Function PorCCusto()
	Local cQuery    := ''
	Local cMat      := ''
	Local cCentro   := ''
	local cArquivo 	:= cPath+"RelBatidas.rel"
	local oFileW   	:= FwFileWriter():New(cArquivo)
	local oPrtXlsx 	:= FwPrinterXlsx():New()
	Local nRow 	   	:= 1
	Local cCor 		:= "95B3D7"//"66FFFF"
	Local cArquivoFinal:= ""
	Local nTotDia	:= 0
	Local nDias 	:= 0

	cQuery := " SELECT
	cQuery += " 	P8_FILIAL FILIAL, "
	cQuery += " 	P8_DATA DATA, "
	cQuery += " 	P8_MAT MATRICULA, "
	cQuery += " 	P8_CC CODIGO, "
	cQuery += " 	NUM_REGISTROS REGISTROS, "
	cQuery += " 	CTT_DESC01 DESCRICAO, "
	cQuery += " 	RA_NOME NOME,  "
	cQuery += " 	P6_DESC AS JUSTIFICATIVA "
	cQuery += " FROM ( "
	cQuery += " 	SELECT P8_DATA , P8_MAT, P8_CC, P8_FILIAL, COUNT(*) AS NUM_REGISTROS "
	cQuery += " 	FROM "+RetSqlName('SP8')+" SP8 "
	cQuery += " 	WHERE P8_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cQuery += " 		AND P8_DATA BETWEEN '"+DtoS(MV_PAR07)+"' AND '"+DtoS(MV_PAR08)+"' "
	cQuery += " 		AND P8_CC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	cQuery += " 		AND P8_MAT BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	cQuery += " 	GROUP BY P8_FILIAL, P8_MAT, P8_CC, P8_DATA "
	cQuery += " 	) AS CONTAGEM_REGISTROS "
	cQuery += " 	INNER JOIN "+RetSqlName('CTT')+" CTT ON P8_CC = CTT_CUSTO "
	cQuery += " 	INNER JOIN "+RetSqlName('SRA')+" SRA ON P8_MAT = RA_MAT "
	cQuery += "     INNER JOIN "+RetSqlName('SPC')+" SPC ON PC_MAT = RA_MAT AND PC_FILIAL = RA_FILIAL AND SPC.D_E_L_E_T_ <> '*' "
	cQuery += "     LEFT  JOIN "+RetSqlName('SP6')+" SP6 ON P6_CODIGO = PC_ABONO AND SP6.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE NUM_REGISTROS < 4 "
	cQuery += " GROUP BY P8_FILIAL, P8_CC, CTT_DESC01 , P8_MAT, RA_NOME, NUM_REGISTROS, P8_DATA, P6_DESC "
	cQuery += " ORDER BY P8_FILIAL, P8_CC, P8_MAT  "
	MpSysOpenQuery(cQuery, "TE5")
	If TE5->(Eof())
		TE5->(DbCloseArea())
		Return ""
	EndIf

	oPrtXlsx:Activate(cArquivo, oFileW)
	oPrtXlsx:AddSheet("CONSOLIDADO")

	//definiÃ§Ã£o da largura das colunas
	oPrtXlsx:SetColumnsWidth(1 , 1 , 9.33	) // Filial
	oPrtXlsx:SetColumnsWidth(2 , 2 , 14		) // centro de custo
	oPrtXlsx:SetColumnsWidth(3 , 3 , 36  	) // descricao
	oPrtXlsx:SetColumnsWidth(4 , 4 , 9   	) // matricula
	oPrtXlsx:SetColumnsWidth(5 , 5 , 36  	) // nome
	oPrtXlsx:SetColumnsWidth(6 , 6 , 18 	) // evento

	oPrtXlsx:SetFont(cFont, 16, .F., .T., .F.) // seta o texto em negrito
	//oPrtXlsx:MergeCells(/*lin inicial*/nRow,/*col inicial*/1,/*lin final*/nRow+4,/*col final*/9)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	oPrtXlsx:MergeCells(/*lin inicial*/1,/*col inicial*/1,/*lin final*/1,/*col final*/21)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	oPrtXlsx:MergeCells(/*lin inicial*/2,/*col inicial*/1,/*lin final*/2,/*col final*/21)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	oPrtXlsx:MergeCells(/*lin inicial*/3,/*col inicial*/1,/*lin final*/3,/*col final*/21)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	oPrtXlsx:MergeCells(/*lin inicial*/4,/*col inicial*/1,/*lin final*/4,/*col final*/21)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	oPrtXlsx:MergeCells(/*lin inicial*/5,/*col inicial*/1,/*lin final*/5,/*col final*/21)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	//oPrtXlsx:MergeCells(/*lin inicial*/6,/*col inicial*/1,/*lin final*/6,/*col final*/21)// merge das celulas iniciais para o cabeÃ§alho do arquivo

	oPrtXlsx:SetCellsFormat(cHorAliLeft, cVertAliCent, /*lWrapText*/.F., /*nRotation*/0, "000000", "FFFFFF", "" )
	oPrtXlsx:SetText(/*nRow*/1, /*nCol*/ 1, "RELATÓRIO DE BATIDAS NÃO REGISTRADAS POR SETOR - CONSOLIDADO") // Texto em A1
	oPrtXlsx:SetFont(cFont, 10, .F., .T., .F.) // seta o texto em negrito
	oPrtXlsx:SetText(/*nRow*/2, /*nCol*/ 1, "EMPRESA: "+iIf(Empty(MV_PAR01),"TODAS","DE "+MV_PAR01+" ATÉ "+Upper(MV_PAR02))) // Texto em A1
	oPrtXlsx:SetText(/*nRow*/3, /*nCol*/ 1, "DATA: DE "+DtoC(MV_PAR07)+" ATÉ "+DtoC(MV_PAR08)) // Texto em A1
	oPrtXlsx:SetText(/*nRow*/4, /*nCol*/ 1, "CENTRO DE CUSTO: "+iIf(Empty(MV_PAR03),"TODOS","DE "+MV_PAR03+" ATÉ "+Upper(MV_PAR04))) // Texto em A1
	oPrtXlsx:SetText(/*nRow*/5, /*nCol*/ 1, "MATRICULA: "+iIf(Empty(MV_PAR05),"TODAS","DE "+MV_PAR05+" ATÉ "+Upper(MV_PAR05))) // Texto em A1
	//oPrtXlsx:SetText(/*nRow*/6, /*nCol*/ 1, "CONSOLIDADO") // Texto em A1

	oPrtXlsx:SetBorder(/*lLeft*/.T., /*lTop*/.T., /*lRight*/.T., /*lBottom*/.T., cStyle, "000000")//borda
	nRow := nRow+5
	oPrtXlsx:SetCellsFormat(cHorAliCent, cVertAliCent, /*lWrapText*/.F., /*nRotation*/0, "000000", cCor, "" )
	oPrtXlsx:SetText( nRow , /*nCol*/1 , "Empresa"		    ) //-- 1
	oPrtXlsx:SetText( nRow , /*nCol*/2 , "Centro de custo"	) //-- 2
	oPrtXlsx:SetText( nRow , /*nCol*/3 , "Descricao"	    ) //-- 3
	oPrtXlsx:SetText( nRow , /*nCol*/4 , "Matricula"        ) //-- 4
	oPrtXlsx:SetText( nRow , /*nCol*/5 , "Nome"			    ) //-- 5
	oPrtXlsx:SetText( nRow , /*nCol*/6 , "Qtd. Dias"        ) //-- 6

	oPrtXlsx:ResetCellsFormat()

	While TE5->(!Eof())
		oPrtXlsx:SetFont(cFont, 10, .F., .F., .F.) // seta o texto sem negrito

		cCentro  := AllTrim(TE5->CODIGO)
		cDescCC	 := AllTrim(TE5->Descricao)
		nTotDia  := 0

		While TE5->(!Eof()) .And. cCentro == AllTrim(TE5->CODIGO)
			cMat   := TE5->MATRICULA
			cNome  := AllTrim(TE5->NOME)
			nDias  := 0
			cFil   := TE5->FILIAL

			While TE5->(!Eof()) .And. cCentro == AllTrim(TE5->CODIGO) .And. cMat == TE5->MATRICULA
				nDias++
				TE5->(DbSkip())
			End
			oPrtXlsx:SetCellsFormat(cHorAliCent, cVertAliCent, /*lWrapText*/.F.,/*nRotation*/0,"000000","FFFFFF","")
			nRow++
			oPrtXlsx:SetValue( nRow , /*nCol*/1 , cFil 		     			          )//-- 1
			oPrtXlsx:SetValue( nRow , /*nCol*/2 , cCentro			  		      	  )//-- 2
			oPrtXlsx:SetValue( nRow , /*nCol*/3 , cDescCC		  				  	  )//-- 3
			oPrtXlsx:SetValue( nRow , /*nCol*/4 , cMat			  			          )//-- 4
			oPrtXlsx:SetValue( nRow , /*nCol*/5 , cNome						          )//-- 5
			oPrtXlsx:SetValue( nRow , /*nCol*/6 , nDias 					  		  )//-- 6

			nTotDia += nDias
		End
		oPrtXlsx:SetFont(cFont, 10, .F., .T., .F.) // seta o texto em negrito
		nRow++
		oPrtXlsx:SetCellsFormat(cHorAliCent, cVertAliCent, /*lWrapText*/.F.,/*nRotation*/0,"000000",cCor,"")
		oPrtXlsx:SetValue( nRow , /*nCol*/1 , ""     			   			   )//-- 1
		oPrtXlsx:SetValue( nRow , /*nCol*/2 , ""            	  			   )//-- 2
		oPrtXlsx:SetValue( nRow , /*nCol*/3 , "TOTAL "+AllTrim(cDescCC) 	   )//-- 3
		oPrtXlsx:SetValue( nRow , /*nCol*/4 , ""							   )//-- 4
		oPrtXlsx:SetValue( nRow , /*nCol*/5 , ""					  		   )//-- 5
		oPrtXlsx:SetValue( nRow , /*nCol*/6 , nTotDia						   )//-- 6

	End
	TE5->(DbCloseArea())

	oPrtXlsx:toXlsx()
	cArquivoFinal := StrTran(cArquivo, ".rel", ".xlsx")
	If !IsBlind()
		If File(cPathLocal+"RelBatidas.rel")
			FErase(cPathLocal+"RelBatidas.rel")
		EndIf
		CpyS2T(cArquivoFinal, cPathLocal)
		cArquivoFinal := StrTran(cArquivoFinal, cPath, cPathLocal)
	EndIf
	FErase(cArquivo)

Return cArquivoFinal

