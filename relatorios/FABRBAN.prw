#include 'Protheus.ch'

User Function FABRBAN
	Local aPergs   := {}
	Private oCellH := FwXlsxCellAlignment():Horizontal()
	Private oCellV := FwXlsxCellAlignment():Vertical()

	aAdd(aPergs, {1, "Data De"          ,Date()   , "", ".T.", "", ".T.", 80 , .F.})
	aAdd(aPergs, {1, "Data Até "        ,Date()   , "", ".T.", "", ".T.", 80 , .T.})

	If !(aPergs, "Informe os parâmetros")
		Return
	EndIf

	FWMsgRun(, {|| Relatorio() }, "Aguarde...", "Exportando dados para o Excel")

Return

Static Function Relatorio

	Local cQuery 	:= ""
	Local cAliasTmp := GetNextAlias()
	Local cPath     := GetTempPath()
	Local aRec
	Local aDes
	Local cArquivo  := cPath+"FABRBRAN.rel"
	local oFileW   	:= FwFileWriter():New(cArquivo)
	Local oPrtXlsx  := FwPrinterXlsx():New()
	Local oExcel 	:= MsExcel():New()
	Local cFont 	:= FwPrinterFont():Arial()
	Local cStyle  	:= FwXlsxBorderStyle():Thin()
	Local nRow 		:= 1

	cQuery += " SELECT  "
	cQuery += "   'Receitas' as DESCRICAO, "
	cQuery += "   1 AS ORDEM, "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '01' THEN D2_TOTAL ELSE 0 END), 0) AS JAN,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '02' THEN D2_TOTAL ELSE 0 END), 0) AS FEV,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '03' THEN D2_TOTAL ELSE 0 END), 0) AS MAR,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '04' THEN D2_TOTAL ELSE 0 END), 0) AS ABR,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '05' THEN D2_TOTAL ELSE 0 END), 0) AS MAI,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '06' THEN D2_TOTAL ELSE 0 END), 0) AS JUN,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '07' THEN D2_TOTAL ELSE 0 END), 0) AS JUL,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '08' THEN D2_TOTAL ELSE 0 END), 0) AS AGO,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '09' THEN D2_TOTAL ELSE 0 END), 0) AS SET,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '10' THEN D2_TOTAL ELSE 0 END), 0) AS OUT,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '11' THEN D2_TOTAL ELSE 0 END), 0) AS NOV,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '12' THEN D2_TOTAL ELSE 0 END), 0) AS DEZ  "
	cQuery += " FROM  "
	cQuery += "   "+RetSqlName('SD2')+" D2  "
	cQuery += " WHERE  "
	cQuery += "   D2_FILIAL = '"+FWxFilial('SD2')+"'  "
	cQuery += "   AND D2_EMISSAO BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"'  "
	cQuery += "   AND D2.D_E_L_E_T_ <> '*'  "
	cQuery += " UNION "
	cQuery += " SELECT  "
	cQuery += "   'Ovo Malta' as DESCRICAO, "
	cQuery += "   2 AS ORDEM, "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '01' THEN D2_TOTAL ELSE 0 END), 0) AS JAN,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '02' THEN D2_TOTAL ELSE 0 END), 0) AS FEV,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '03' THEN D2_TOTAL ELSE 0 END), 0) AS MAR,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '04' THEN D2_TOTAL ELSE 0 END), 0) AS ABR,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '05' THEN D2_TOTAL ELSE 0 END), 0) AS MAI,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '06' THEN D2_TOTAL ELSE 0 END), 0) AS JUN,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '07' THEN D2_TOTAL ELSE 0 END), 0) AS JUL,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '08' THEN D2_TOTAL ELSE 0 END), 0) AS AGO,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '09' THEN D2_TOTAL ELSE 0 END), 0) AS SET,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '10' THEN D2_TOTAL ELSE 0 END), 0) AS OUT,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '11' THEN D2_TOTAL ELSE 0 END), 0) AS NOV,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '12' THEN D2_TOTAL ELSE 0 END), 0) AS DEZ  "
	cQuery += " FROM  "
	cQuery += "   "+RetSqlName('SD2')+" D2  "
	cQuery += " WHERE  "
	cQuery += "   D2_FILIAL = '"+FWxFilial('SD2')+"'  "
	cQuery += "   AND D2_SERIE = 'A  '  "
	cQuery += "   AND D2_EMISSAO BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"'  "
	cQuery += "   AND D2.D_E_L_E_T_ <> '*'  "
	cQuery += " UNION  "
	cQuery += " SELECT  "
	cQuery += "   'Externa' as DESCRICAO, "
	cQuery += "   3 AS ORDEM, "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '01' THEN D2_TOTAL ELSE 0 END), 0) AS JAN,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '02' THEN D2_TOTAL ELSE 0 END), 0) AS FEV,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '03' THEN D2_TOTAL ELSE 0 END), 0) AS MAR,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '04' THEN D2_TOTAL ELSE 0 END), 0) AS ABR,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '05' THEN D2_TOTAL ELSE 0 END), 0) AS MAI,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '06' THEN D2_TOTAL ELSE 0 END), 0) AS JUN,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '07' THEN D2_TOTAL ELSE 0 END), 0) AS JUL,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '08' THEN D2_TOTAL ELSE 0 END), 0) AS AGO,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '09' THEN D2_TOTAL ELSE 0 END), 0) AS SET,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '10' THEN D2_TOTAL ELSE 0 END), 0) AS OUT,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '11' THEN D2_TOTAL ELSE 0 END), 0) AS NOV,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '12' THEN D2_TOTAL ELSE 0 END), 0) AS DEZ  "
	cQuery += " FROM  "
	cQuery += "   "+RetSqlName('SD2')+" D2  "
	cQuery += " WHERE  "
	cQuery += "   D2_FILIAL = '"+FWxFilial('SD2')+"'  "
	cQuery += "   AND D2_SERIE <> 'A  '  "
	cQuery += "   AND D2_EMISSAO BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"'  "
	cQuery += "   AND D2.D_E_L_E_T_ <> '*'  "
	cQuery += " UNION  "
	cQuery += " SELECT  "
	cQuery += "   'Total (Qtd)' AS DESCRICAO, "
	cQuery += "    4 AS ORDEM, "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '01' THEN D2_QUANT ELSE 0 END), 0) AS JAN,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '02' THEN D2_QUANT ELSE 0 END), 0) AS FEV,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '03' THEN D2_QUANT ELSE 0 END), 0) AS MAR,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '04' THEN D2_QUANT ELSE 0 END), 0) AS ABR,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '05' THEN D2_QUANT ELSE 0 END), 0) AS MAI,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '06' THEN D2_QUANT ELSE 0 END), 0) AS JUN,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '07' THEN D2_QUANT ELSE 0 END), 0) AS JUL,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '08' THEN D2_QUANT ELSE 0 END), 0) AS AGO,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '09' THEN D2_QUANT ELSE 0 END), 0) AS SET,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '10' THEN D2_QUANT ELSE 0 END), 0) AS OUT,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '11' THEN D2_QUANT ELSE 0 END), 0) AS NOV,  "
	cQuery += "   COALESCE(SUM(CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '12' THEN D2_QUANT ELSE 0 END), 0) AS DEZ  "
	cQuery += " FROM  "
	cQuery += "   "+RetSqlName('SD2')+" D2  "
	cQuery += " WHERE  "
	cQuery += "   D2_FILIAL = '"+FWxFilial('SD2')+"'  "
	cQuery += "   AND D2_EMISSAO BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"'  "
	cQuery += "   AND D2.D_E_L_E_T_ <> '*'  "
	cQuery += " GROUP BY   "
	cQuery += "   DESCRICAO "
	cQuery += " UNION "
	cQuery += " SELECT  "
	cQuery += "   'Valor Unitario' AS DESCRICAO, "
	cQuery += "    5 AS ORDEM, "
	cQuery += "   COALESCE(B.JAN / NULLIF(A.JAN, 0), 0) AS JAN, "
	cQuery += "   COALESCE(B.FEV / NULLIF(A.FEV, 0), 0) AS FEV, "
	cQuery += "   COALESCE(B.MAR / NULLIF(A.MAR, 0), 0) AS MAR, "
	cQuery += "   COALESCE(B.ABR / NULLIF(A.ABR, 0), 0) AS ABR, "
	cQuery += "   COALESCE(B.MAI / NULLIF(A.MAI, 0), 0) AS MAI, "
	cQuery += "   COALESCE(B.JUN / NULLIF(A.JUN, 0), 0) AS JUN, "
	cQuery += "   COALESCE(B.JUL / NULLIF(A.JUL, 0), 0) AS JUL, "
	cQuery += "   COALESCE(B.AGO / NULLIF(A.AGO, 0), 0) AS AGO, "
	cQuery += "   COALESCE(B.SET / NULLIF(A.SET, 0), 0) AS SET, "
	cQuery += "   COALESCE(B.OUT / NULLIF(A.OUT, 0), 0) AS OUT, "
	cQuery += "   COALESCE(B.NOV / NULLIF(A.NOV, 0), 0) AS NOV, "
	cQuery += "   COALESCE(B.DEZ / NULLIF(A.DEZ, 0), 0) AS DEZ "
	cQuery += " FROM  "
	cQuery += "   (SELECT "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '01' THEN D2_QUANT ELSE 0 END "
	cQuery += "     ), 0) AS JAN,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '02' THEN D2_QUANT ELSE 0 END "
	cQuery += "     ), 0) AS FEV,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '03' THEN D2_QUANT ELSE 0 END "
	cQuery += "     ), 0) AS MAR,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '04' THEN D2_QUANT ELSE 0 END "
	cQuery += "     ), 0) AS ABR,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '05' THEN D2_QUANT ELSE 0 END "
	cQuery += "     ), 0) AS MAI,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '06' THEN D2_QUANT ELSE 0 END "
	cQuery += "     ), 0) AS JUN,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '07' THEN D2_QUANT ELSE 0 END "
	cQuery += "     ), 0) AS JUL,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '08' THEN D2_QUANT ELSE 0 END "
	cQuery += "     ), 0) AS AGO,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '09' THEN D2_QUANT ELSE 0 END "
	cQuery += "     ), 0) AS SET,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '10' THEN D2_QUANT ELSE 0 END "
	cQuery += "     ), 0) AS OUT,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '11' THEN D2_QUANT ELSE 0 END "
	cQuery += "     ), 0) AS NOV,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '12' THEN D2_QUANT ELSE 0 END "
	cQuery += "     ), 0) AS DEZ  "
	cQuery += "   FROM  "
	cQuery += "     "+RetSqlName('SD2')+" D2 "
	cQuery += "   WHERE  "
	cQuery += "     D2_FILIAL = '"+FWxFilial('SD2')+"'  "
	cQuery += "     AND D2_EMISSAO BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"'  "
	cQuery += "     AND D2.D_E_L_E_T_ <> '*') AS A "
	cQuery += " JOIN "
	cQuery += "   (SELECT  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '01' THEN D2_TOTAL ELSE 0 END "
	cQuery += "     ), 0) AS JAN,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '02' THEN D2_TOTAL ELSE 0 END "
	cQuery += "     ), 0) AS FEV,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '03' THEN D2_TOTAL ELSE 0 END "
	cQuery += "     ), 0) AS MAR,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '04' THEN D2_TOTAL ELSE 0 END "
	cQuery += "     ), 0) AS ABR,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '05' THEN D2_TOTAL ELSE 0 END "
	cQuery += "     ), 0) AS MAI,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '06' THEN D2_TOTAL ELSE 0 END "
	cQuery += "     ), 0) AS JUN,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '07' THEN D2_TOTAL ELSE 0 END "
	cQuery += "     ), 0) AS JUL,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '08' THEN D2_TOTAL ELSE 0 END "
	cQuery += "     ), 0) AS AGO,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '09' THEN D2_TOTAL ELSE 0 END "
	cQuery += "     ), 0) AS SET,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '10' THEN D2_TOTAL ELSE 0 END "
	cQuery += "     ), 0) AS OUT,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '11' THEN D2_TOTAL ELSE 0 END "
	cQuery += "     ), 0) AS NOV,  "
	cQuery += "     COALESCE(SUM( "
	cQuery += "       CASE WHEN SUBSTRING(D2_EMISSAO, 5, 2) = '12' THEN D2_TOTAL ELSE 0 END "
	cQuery += "     ), 0) AS DEZ  "
	cQuery += "   FROM  "
	cQuery += "     "+RetSqlName('SD2')+" D2  "
	cQuery += "   WHERE  "
	cQuery += "     D2_FILIAL = '"+FWxFilial('SD2')+"'  "
	cQuery += "     AND D2_EMISSAO BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"'  "
	cQuery += "     AND D2.D_E_L_E_T_ <> '*') AS B "
	cQuery += " ON 1=1 "
	cQuery += " ORDER BY ORDEM "

	MpSysOpenQuery(cQuery, cAliasTmp)

	oPrtXlsx:Activate(cArquivo, oFileW)
	oPrtXlsx:AddSheet('FABRBRAN')

	oPrtXlsx:SetColumnsWidth(1 , 1, 6.78) // DESCRICAO
	oPrtXlsx:SetColumnsWidth(2 , 2, 11.25)// JAN
	oPrtXlsx:SetColumnsWidth(3 , 3, 11.25)// FEV
	oPrtXlsx:SetColumnsWidth(4 , 4, 11.25)// MAR
	oPrtXlsx:SetColumnsWidth(5 , 5, 11.25)// ABR
	oPrtXlsx:SetColumnsWidth(6 , 6, 11.25)// MAI
	oPrtXlsx:SetColumnsWidth(7 , 7, 11.25)// JUN
	oPrtXlsx:SetColumnsWidth(8 , 8, 11.25)// JUL
	oPrtXlsx:SetColumnsWidth(9 , 9, 11.25)// AGO
	oPrtXlsx:SetColumnsWidth(10, 10, 11.25)// SET
	oPrtXlsx:SetColumnsWidth(11, 11, 11.25)// OUT
	oPrtXlsx:SetColumnsWidth(12, 12, 11.25)// NOV
	oPrtXlsx:SetColumnsWidth(13, 13, 11.25)// DEZ

	oPrtXlsx:SetFont(cFont, 12, .F., .T., .F.)
	oPrtXlsx:SetBorder(.T.,.T.,.T.,.T., cStyle, "000000")
	oPrtXlsx:MergeCells(nRow,1,nRow,13) // DRE - Fabrica de Bandejas
	oPrtXlsx:SetCellsFormat(oCellH:Center(),oCellV:Center(),.F.,0,"FFFFFF","000000","")
	oPrtXlsx:SetText(nRow,1,"DRE - Fábrica de Bandejas","")

	nRow++

	oPrtXlsx:SetCellsFormat(oCellH:Center(),oCellV:Center(),.F.,0,"000000","FDBD18","")
	oPrtXlsx:SetText( nRow , 01 , "Descrição")
	oPrtXlsx:SetText( nRow , 02 , "Jan"		)
	oPrtXlsx:SetText( nRow , 03 , "Fev"		)
	oPrtXlsx:SetText( nRow , 04 , "Mar"		)
	oPrtXlsx:SetText( nRow , 05 , "Abr"		)
	oPrtXlsx:SetText( nRow , 06 , "Mai"		)
	oPrtXlsx:SetText( nRow , 07 , "Jun"		)
	oPrtXlsx:SetText( nRow , 08 , "Jul"		)
	oPrtXlsx:SetText( nRow , 09 , "Ago"		)
	oPrtXlsx:SetText( nRow , 10 , "Set"		)
	oPrtXlsx:SetText( nRow , 11 , "Out"		)
	oPrtXlsx:SetText( nRow , 12 , "Nov"		)
	oPrtXlsx:SetText( nRow , 13 , "Dez"		)

	//Impressão de Receitas
	While (cAliasTmp)->(!EoF())
		nRow++
		If ALLTRIM((cAliasTmp)->DESCRICAO) == 'Receitas'
			oPrtXlsx:SetCellsFormat(oCellH:Center(),oCellV:Center(),.F.,0,"FFFFFF","000000","")
			oPrtXlsx:SetText(  nRow , 01 , ALLTRIM((cAliasTmp)->DESCRICAO))
			oPrtXlsx:SetCellsFormat(oCellH:Right(),oCellV:Center(),.F.,0,"FFFFFF","000000","")
			oPrtXlsx:SetValue( nRow , 02 , Transform((cAliasTmp)->JAN, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 03 , Transform((cAliasTmp)->FEV, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 04 , Transform((cAliasTmp)->MAR, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 05 , Transform((cAliasTmp)->ABR, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 06 , Transform((cAliasTmp)->MAI, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 07 , Transform((cAliasTmp)->JUN, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 08 , Transform((cAliasTmp)->JUL, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 09 , Transform((cAliasTmp)->AGO, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 10 , Transform((cAliasTmp)->SET, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 11 , Transform((cAliasTmp)->OUT, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 12 , Transform((cAliasTmp)->NOV, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 13 , Transform((cAliasTmp)->DEZ, "@E 999,999,999,999.99")		)
			aRec := { 	(cAliasTmp)->JAN,;
				(cAliasTmp)->FEV,;
				(cAliasTmp)->MAR,;
				(cAliasTmp)->ABR,;
				(cAliasTmp)->MAI,;
				(cAliasTmp)->JUN,;
				(cAliasTmp)->JUL,;
				(cAliasTmp)->AGO,;
				(cAliasTmp)->SET,;
				(cAliasTmp)->OUT,;
				(cAliasTmp)->NOV,;
				(cAliasTmp)->DEZ }
		Else
			oPrtXlsx:SetCellsFormat(oCellH:Left(),oCellV:Center(),.F.,0,"000000","FFFFFF","")
			oPrtXlsx:SetText(  nRow , 01 , ALLTRIM((cAliasTmp)->DESCRICAO))
			oPrtXlsx:SetCellsFormat(oCellH:Right(),oCellV:Center(),.F.,0,"000000","FFFFFF","")
			oPrtXlsx:SetValue( nRow , 02 , Transform((cAliasTmp)->JAN, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 03 , Transform((cAliasTmp)->FEV, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 04 , Transform((cAliasTmp)->MAR, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 05 , Transform((cAliasTmp)->ABR, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 06 , Transform((cAliasTmp)->MAI, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 07 , Transform((cAliasTmp)->JUN, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 08 , Transform((cAliasTmp)->JUL, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 09 , Transform((cAliasTmp)->AGO, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 10 , Transform((cAliasTmp)->SET, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 11 , Transform((cAliasTmp)->OUT, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 12 , Transform((cAliasTmp)->NOV, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 13 , Transform((cAliasTmp)->DEZ, "@E 999,999,999,999.99")		)
		EndIf
		(cAliasTmp)->(DbSkip())
	End

	(cAliasTmp)->(DbCloseArea())

	nRow++
	oPrtXlsx:SetCellsFormat(oCellH:Center(),oCellV:Center(),.F.,0,"FFFFFF","FFFFFF","")
	oPrtXlsx:SetBorder(.F.,.F.,.F.,.F., cStyle, "000000")
	oPrtXlsx:MergeCells(nRow,1,nRow,13)
	oPrtXlsx:SetText(nRow,1,Space(12),"")

	cQuery := " SELECT DESPESAS.DESCRICAO,  "
	cQuery += "    COALESCE(DESPESAS.JAN, 0) AS JAN, "
	cQuery += "    COALESCE(DESPESAS.FEV, 0) AS FEV, "
	cQuery += "    COALESCE(DESPESAS.MAR, 0) AS MAR, "
	cQuery += "    COALESCE(DESPESAS.ABR, 0) AS ABR,  "
	cQuery += "    COALESCE(DESPESAS.MAI, 0) AS MAI, "
	cQuery += "    COALESCE(DESPESAS.JUN, 0) AS JUN, "
	cQuery += "    COALESCE(DESPESAS.JUL, 0) AS JUL, "
	cQuery += "    COALESCE(DESPESAS.AGO, 0) AS AGO, "
	cQuery += "    COALESCE(DESPESAS.SET, 0) AS SET, "
	cQuery += "    COALESCE(DESPESAS.OUT, 0) AS OUT, "
	cQuery += "    COALESCE(DESPESAS.NOV, 0) AS NOV, "
	cQuery += "    COALESCE(DESPESAS.DEZ, 0) AS DEZ "
	cQuery += "    FROM "
	cQuery += " ( SELECT  "
	cQuery += "   'Despesas' as DESCRICAO, "
	cQuery += "   1 AS ORDEM, "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '01' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JAN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '02' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS FEV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '03' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '04' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS ABR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '05' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAI,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '06' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '07' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUL,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '08' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS AGO,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '09' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS  "
	cQuery += " SET  "
	cQuery += "   ,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '10' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS OUT,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '11' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS NOV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '12' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS DEZ  "
	cQuery += " FROM  "
	cQuery += "   "+RetSqlName('SE5')+" E5  "
	cQuery += " WHERE  "
	cQuery += "   E5_TIPODOC NOT IN ( "
	cQuery += "     'DC', 'D2', 'JR', 'J2', 'TL', 'MT', 'M2',  "
	cQuery += "     'CM', 'C2', 'ES', 'BA' "
	cQuery += "   )  "
	cQuery += "   AND E5_SITUACA NOT IN ('C', 'E', 'X')  "
	cQuery += "   AND E5_FILIAL = '"+FWxFilial('SE5')+"'  "
	cQuery += "   AND E5_RECPAG = 'P' "
	cQuery += "   AND E5_DATA BETWEEN '"+DtoS(MV_PAR01)+"'  "
	cQuery += "   AND '"+DtoS(MV_PAR02)+"' "
	cQuery += "   AND E5.D_E_L_E_T_ <> '*'  "
	cQuery += " UNION "
	cQuery += " SELECT  "
	cQuery += "   'Insumos' as DESCRICAO, "
	cQuery += "   2 AS ORDEM, "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '01' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JAN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '02' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS FEV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '03' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '04' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS ABR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '05' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAI,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '06' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '07' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUL,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '08' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS AGO,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '09' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS  "
	cQuery += " SET  "
	cQuery += "   ,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '10' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS OUT,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '11' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS NOV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '12' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS DEZ  "
	cQuery += " FROM  "
	cQuery += "   "+RetSqlName('SE5')+" E5  "
	cQuery += " WHERE  "
	cQuery += "   E5_TIPODOC NOT IN ( "
	cQuery += "     'DC', 'D2', 'JR', 'J2', 'TL', 'MT', 'M2',  "
	cQuery += "     'CM', 'C2', 'ES', 'BA' "
	cQuery += "   )  "
	cQuery += "   AND E5_SITUACA NOT IN ('C', 'E', 'X')  "
	cQuery += "   AND E5_FILIAL = '"+FWxFilial('SE5')+"'  "
	cQuery += "   AND E5_RECPAG = 'P' "
	cQuery += "   AND E5_NATUREZ IN ('03004002','03004001') "
	cQuery += "   AND E5_DATA BETWEEN '"+DtoS(MV_PAR01)+"'  "
	cQuery += "   AND '"+DtoS(MV_PAR02)+"' "
	cQuery += "   AND E5.D_E_L_E_T_ <> '*'  "
	cQuery += " UNION "
	cQuery += " SELECT  "
	cQuery += "   'Papelão' as DESCRICAO, "
	cQuery += "   3 AS ORDEM, "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '01' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JAN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '02' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS FEV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '03' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '04' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS ABR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '05' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAI,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '06' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '07' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUL,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '08' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS AGO,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '09' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS  "
	cQuery += " SET  "
	cQuery += "   ,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '10' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS OUT,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '11' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS NOV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '12' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS DEZ  "
	cQuery += " FROM  "
	cQuery += "   "+RetSqlName('SE5')+" E5  "
	cQuery += " WHERE  "
	cQuery += "   E5_TIPODOC NOT IN ( "
	cQuery += "     'DC', 'D2', 'JR', 'J2', 'TL', 'MT', 'M2',  "
	cQuery += "     'CM', 'C2', 'ES', 'BA' "
	cQuery += "   )  "
	cQuery += "   AND E5_SITUACA NOT IN ('C', 'E', 'X')  "
	cQuery += "   AND E5_FILIAL = '"+FWxFilial('SE5')+"'  "
	cQuery += "   AND E5_RECPAG = 'P' "
	cQuery += "   AND E5_CCUSTO = '3.5.1' "
	cQuery += "   AND E5_NATUREZ = '03002002' "
	cQuery += "   AND E5_DATA BETWEEN '"+DtoS(MV_PAR01)+"'  "
	cQuery += "   AND '"+DtoS(MV_PAR02)+"' "
	cQuery += "   AND E5.D_E_L_E_T_ <> '*' "
	cQuery += " UNION "
	cQuery += " SELECT  "
	cQuery += "   'Embalagem' as DESCRICAO, "
	cQuery += "   4 AS ORDEM, "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '01' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JAN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '02' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS FEV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '03' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '04' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS ABR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '05' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAI,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '06' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '07' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUL,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '08' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS AGO,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '09' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS  "
	cQuery += " SET  "
	cQuery += "   ,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '10' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS OUT,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '11' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS NOV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '12' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS DEZ  "
	cQuery += " FROM  "
	cQuery += "   "+RetSqlName('SE5')+" E5  "
	cQuery += " WHERE  "
	cQuery += "   E5_TIPODOC NOT IN ( "
	cQuery += "     'DC', 'D2', 'JR', 'J2', 'TL', 'MT', 'M2',  "
	cQuery += "     'CM', 'C2', 'ES', 'BA' "
	cQuery += "   )  "
	cQuery += "   AND E5_SITUACA NOT IN ('C', 'E', 'X')  "
	cQuery += "   AND E5_FILIAL = '"+FWxFilial('SE5')+"'  "
	cQuery += "   AND E5_RECPAG = 'P' "
	cQuery += "   AND E5_CCUSTO = '3.5.1' "
	cQuery += "   AND E5_NATUREZ = '03004002' "
	cQuery += "   AND E5_DATA BETWEEN '"+DtoS(MV_PAR01)+"'  "
	cQuery += "   AND '"+DtoS(MV_PAR02)+"' "
	cQuery += "   AND E5.D_E_L_E_T_ <> '*' "
	cQuery += " UNION "
	cQuery += " SELECT  "
	cQuery += "   'Pessoal' AS DESCRICAO, "
	cQuery += "   5 AS ORDEM, "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN COALESCE(SUBSTRING(E5_DATA, 5, 2),'X') = '01' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JAN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN COALESCE(SUBSTRING(E5_DATA, 5, 2),'X') = '02' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS FEV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN COALESCE(SUBSTRING(E5_DATA, 5, 2),'X') = '03' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN COALESCE(SUBSTRING(E5_DATA, 5, 2),'X') = '04' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS ABR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN COALESCE(SUBSTRING(E5_DATA, 5, 2),'X') = '05' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAI,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN COALESCE(SUBSTRING(E5_DATA, 5, 2),'X') = '06' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN COALESCE(SUBSTRING(E5_DATA, 5, 2),'X') = '07' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUL,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN COALESCE(SUBSTRING(E5_DATA, 5, 2),'X') = '08' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS AGO,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN COALESCE(SUBSTRING(E5_DATA, 5, 2),'X') = '09' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS  "
	cQuery += " SET  "
	cQuery += "   ,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN COALESCE(SUBSTRING(E5_DATA, 5, 2),'X') = '10' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS OUT,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN COALESCE(SUBSTRING(E5_DATA, 5, 2),'X') = '11' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS NOV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN COALESCE(SUBSTRING(E5_DATA, 5, 2),'X') = '12' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS DEZ  "
	cQuery += " FROM  "
	cQuery += "   "+RetSqlName('SE5')+" E5 "
	cQuery += " WHERE  "
	cQuery += "   E5_TIPODOC NOT IN ( "
	cQuery += "     'DC', 'D2', 'JR', 'J2', 'TL', 'MT', 'M2',  "
	cQuery += "     'CM', 'C2', 'ES', 'BA' "
	cQuery += "   )  "
	cQuery += "   AND E5_SITUACA NOT IN ('C', 'E', 'X')  "
	cQuery += "   AND E5_FILIAL = '"+FWxFilial('SE5')+"'  "
	cQuery += "   AND E5_RECPAG = 'P' "
	cQuery += "   AND E5_PREFIXO = 'FOL' "
	cQuery += "   AND E5_CCUSTO LIKE '3.5%' "
	cQuery += "   AND E5_DATA BETWEEN '"+DtoS(MV_PAR01)+"' "
	cQuery += "   AND '"+DtoS(MV_PAR02)+"'  "
	cQuery += "   AND E5.D_E_L_E_T_ <> '*'  "
	cQuery += " UNION "
	cQuery += " SELECT 'Nº Funcionários' AS DESCRICAO, "
	cQuery += " 	   6 AS ORDEM, "
	cQuery += "        JAN.JAN, "
	cQuery += "        FEV.FEV, "
	cQuery += "        MAR.MAR, "
	cQuery += "        ABR.ABR, "
	cQuery += "        MAI.MAI, "
	cQuery += "        JUN.JUN, "
	cQuery += "        JUL.JUL, "
	cQuery += "        AGO.AGO, "
	cQuery += "        SET.SET, "
	cQuery += "        OUT.OUT, "
	cQuery += "        NOV.NOV, "
	cQuery += "        DEZ.DEZ "
	cQuery += " FROM ( SELECT COUNT(*) AS JAN FROM "+RetSqlName('SRA')+" "
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND ( RA_DEMISSA = ' ' OR RA_DEMISSA > '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'0101')))+"' ) "
	cQuery += " AND RA_ADMISSA < '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'0101')))+"' "
	cQuery += " AND '01' < '"+Substr(DtoS(MV_PAR02),5,2)+"' "
	cQuery += " ) JAN, "
	cQuery += " ( SELECT COUNT(*) AS FEV FROM "+RetSqlName('SRA')+" "
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND ( RA_DEMISSA = ' ' OR RA_DEMISSA > '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'0201')))+"' ) "
	cQuery += " AND RA_ADMISSA < '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'0201')))+"' "
	cQuery += " AND '02' < '"+Substr(DtoS(MV_PAR02),5,2)+"' "
	cQuery += " ) FEV, "
	cQuery += " ( SELECT COUNT(*) AS MAR FROM "+RetSqlName('SRA')+" "
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND ( RA_DEMISSA = ' ' OR RA_DEMISSA > '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'0301')))+"' ) "
	cQuery += " AND RA_ADMISSA < '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'0301')))+"' "
	cQuery += " AND '03' < '"+Substr(DtoS(MV_PAR02),5,2)+"' "
	cQuery += " ) MAR, "
	cQuery += " ( SELECT COUNT(*) AS ABR FROM "+RetSqlName('SRA')+" "
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND ( RA_DEMISSA = ' ' OR RA_DEMISSA > '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'0401')))+"' ) "
	cQuery += " AND RA_ADMISSA < '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'0401')))+"' "
	cQuery += " AND '04' < '"+Substr(DtoS(MV_PAR02),5,2)+"' "
	cQuery += " ) ABR, "
	cQuery += " ( SELECT COUNT(*) AS MAI FROM "+RetSqlName('SRA')+" "
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND ( RA_DEMISSA = ' ' OR RA_DEMISSA > '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'0501')))+"' ) "
	cQuery += " AND RA_ADMISSA < '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'0501')))+"' "
	cQuery += " AND '05' < '"+Substr(DtoS(MV_PAR02),5,2)+"' "
	cQuery += " ) MAI, "
	cQuery += " ( SELECT COUNT(*) AS JUN FROM "+RetSqlName('SRA')+" "
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND ( RA_DEMISSA = ' ' OR RA_DEMISSA > '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'0601')))+"' ) "
	cQuery += " AND RA_ADMISSA < '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'0601')))+"' "
	cQuery += " AND '06' < '"+Substr(DtoS(MV_PAR02),5,2)+"' "
	cQuery += " ) JUN, "
	cQuery += " ( SELECT COUNT(*) AS JUL FROM "+RetSqlName('SRA')+" "
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND ( RA_DEMISSA = ' ' OR RA_DEMISSA > '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'0701')))+"' ) "
	cQuery += " AND RA_ADMISSA < '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'0701')))+"' "
	cQuery += " AND '07' < '"+Substr(DtoS(MV_PAR02),5,2)+"' "
	cQuery += " ) JUL, "
	cQuery += " ( SELECT COUNT(*) AS AGO FROM "+RetSqlName('SRA')+" "
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND ( RA_DEMISSA = ' ' OR RA_DEMISSA > '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'0801')))+"' ) "
	cQuery += " AND RA_ADMISSA < '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'0801')))+"' "
	cQuery += " AND '08' < '"+Substr(DtoS(MV_PAR02),5,2)+"' "
	cQuery += " ) AGO, "
	cQuery += " ( SELECT COUNT(*) AS SET FROM "+RetSqlName('SRA')+" "
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND ( RA_DEMISSA = ' ' OR RA_DEMISSA > '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'0901')))+"' ) "
	cQuery += " AND RA_ADMISSA < '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'0901')))+"' "
	cQuery += " AND '09' < '"+Substr(DtoS(MV_PAR02),5,2)+"' "
	cQuery += " ) SET, "
	cQuery += " ( SELECT COUNT(*) AS OUT FROM "+RetSqlName('SRA')+" "
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND ( RA_DEMISSA = ' ' OR RA_DEMISSA > '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'1001')))+"' ) "
	cQuery += " AND RA_ADMISSA < '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'1001')))+"' "
	cQuery += " AND '10' < '"+Substr(DtoS(MV_PAR02),5,2)+"' "
	cQuery += " ) OUT, "
	cQuery += " ( SELECT COUNT(*) AS NOV FROM "+RetSqlName('SRA')+" "
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND ( RA_DEMISSA = ' ' OR RA_DEMISSA > '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'1101')))+"' ) "
	cQuery += " AND RA_ADMISSA < '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'1101')))+"' "
	cQuery += " AND '11' < '"+Substr(DtoS(MV_PAR02),5,2)+"' "
	cQuery += " ) NOV, "
	cQuery += " ( SELECT COUNT(*) AS DEZ FROM "+RetSqlName('SRA')+" "
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND ( RA_DEMISSA = ' ' OR RA_DEMISSA > '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'1201')))+"' ) "
	cQuery += " AND RA_ADMISSA < '"+DtoS(LastDate(StoD(Year2Str(dDatabase)+'1201')))+"' "
	cQuery += " AND '12' < '"+Substr(DtoS(MV_PAR02),5,2)+"' "
	cQuery += " ) DEZ "
	cQuery += " UNION "
	cQuery += " SELECT  "
	cQuery += "   'Manutenção' as DESCRICAO, "
	cQuery += "   7 AS ORDEM, "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '01' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JAN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '02' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS FEV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '03' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '04' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS ABR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '05' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAI,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '06' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '07' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUL,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '08' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS AGO,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '09' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS  "
	cQuery += " SET  "
	cQuery += "   ,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '10' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS OUT,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '11' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS NOV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '12' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS DEZ  "
	cQuery += " FROM  "
	cQuery += "   "+RetSqlName('SE5')+" E5  "
	cQuery += " WHERE  "
	cQuery += "   E5_TIPODOC NOT IN ( "
	cQuery += "     'DC', 'D2', 'JR', 'J2', 'TL', 'MT', 'M2',  "
	cQuery += "     'CM', 'C2', 'ES', 'BA' "
	cQuery += "   )  "
	cQuery += "   AND E5_SITUACA NOT IN ('C', 'E', 'X')  "
	cQuery += "   AND E5_FILIAL = '"+FWxFilial('SE5')+"'  "
	cQuery += "   AND E5_RECPAG = 'P' "
	cQuery += "   AND E5_NATUREZ IN ('04008002','04002012','04008003') "
	cQuery += "   AND E5_DATA BETWEEN '"+DtoS(MV_PAR01)+"'  "
	cQuery += "   AND '"+DtoS(MV_PAR02)+"' "
	cQuery += "   AND E5.D_E_L_E_T_ <> '*' "
	cQuery += " UNION "
	cQuery += " SELECT  "
	cQuery += "   'Lubrificação' as DESCRICAO, "
	cQuery += "   8 AS ORDEM, "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '01' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JAN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '02' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS FEV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '03' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '04' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS ABR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '05' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAI,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '06' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '07' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUL,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '08' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS AGO,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '09' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS  "
	cQuery += " SET  "
	cQuery += "   ,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '10' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS OUT,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '11' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS NOV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '12' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS DEZ  "
	cQuery += " FROM  "
	cQuery += "   "+RetSqlName('SE5')+" E5  "
	cQuery += " WHERE  "
	cQuery += "   E5_TIPODOC NOT IN ( "
	cQuery += "     'DC', 'D2', 'JR', 'J2', 'TL', 'MT', 'M2',  "
	cQuery += "     'CM', 'C2', 'ES', 'BA' "
	cQuery += "   )  "
	cQuery += "   AND E5_SITUACA NOT IN ('C', 'E', 'X')  "
	cQuery += "   AND E5_FILIAL = '"+FWxFilial('SE5')+"'  "
	cQuery += "   AND E5_RECPAG = 'P' "
	cQuery += "   AND E5_NATUREZ = '04008002' "
	cQuery += "   AND E5_DATA BETWEEN '"+DtoS(MV_PAR01)+"'  "
	cQuery += "   AND '"+DtoS(MV_PAR02)+"' "
	cQuery += "   AND E5.D_E_L_E_T_ <> '*' "
	cQuery += " UNION "
	cQuery += " SELECT  "
	cQuery += "   'Mecânica' as DESCRICAO, "
	cQuery += "   9 AS ORDEM, "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '01' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JAN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '02' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS FEV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '03' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '04' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS ABR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '05' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAI,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '06' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '07' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUL,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '08' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS AGO,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '09' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS  "
	cQuery += " SET  "
	cQuery += "   ,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '10' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS OUT,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '11' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS NOV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '12' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS DEZ  "
	cQuery += " FROM  "
	cQuery += "   "+RetSqlName('SE5')+" E5  "
	cQuery += " WHERE  "
	cQuery += "   E5_TIPODOC NOT IN ( "
	cQuery += "     'DC', 'D2', 'JR', 'J2', 'TL', 'MT', 'M2',  "
	cQuery += "     'CM', 'C2', 'ES', 'BA' "
	cQuery += "   )  "
	cQuery += "   AND E5_SITUACA NOT IN ('C', 'E', 'X')  "
	cQuery += "   AND E5_FILIAL = '"+FWxFilial('SE5')+"'  "
	cQuery += "   AND E5_RECPAG = 'P' "
	cQuery += "   AND E5_NATUREZ IN ('04002012','04008003') "
	cQuery += "   AND E5_DATA BETWEEN '"+DtoS(MV_PAR01)+"'  "
	cQuery += "   AND '"+DtoS(MV_PAR02)+"' "
	cQuery += "   AND E5.D_E_L_E_T_ <> '*' "
	cQuery += " UNION "
	cQuery += " SELECT  "
	cQuery += "   'Utilidades' as DESCRICAO, "
	cQuery += "   10 AS ORDEM, "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '01' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JAN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '02' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS FEV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '03' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '04' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS ABR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '05' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAI,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '06' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '07' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUL,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '08' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS AGO,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '09' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS  "
	cQuery += " SET  "
	cQuery += "   ,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '10' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS OUT,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '11' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS NOV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '12' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS DEZ  "
	cQuery += " FROM  "
	cQuery += "   "+RetSqlName('SE5')+" E5  "
	cQuery += " WHERE  "
	cQuery += "   E5_TIPODOC NOT IN ( "
	cQuery += "     'DC', 'D2', 'JR', 'J2', 'TL', 'MT', 'M2',  "
	cQuery += "     'CM', 'C2', 'ES', 'BA' "
	cQuery += "   )  "
	cQuery += "   AND E5_SITUACA NOT IN ('C', 'E', 'X')  "
	cQuery += "   AND E5_FILIAL = '"+FWxFilial('SE5')+"'  "
	cQuery += "   AND E5_RECPAG = 'P' "
	cQuery += "   AND E5_CCUSTO = '3.5%' "
	cQuery += "   AND E5_DATA BETWEEN '"+DtoS(MV_PAR01)+"'  "
	cQuery += "   AND '"+DtoS(MV_PAR02)+"' "
	cQuery += "   AND E5.D_E_L_E_T_ <> '*' "
	cQuery += " UNION "
	cQuery += " SELECT "
	cQuery += "   'Lenha' AS DESCRICAO,  "
	cQuery += "   11 AS ORDEM, "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '01' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JAN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '02' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS FEV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '03' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '04' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS ABR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '05' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAI,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '06' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '07' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUL,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '08' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS AGO,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '09' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS  "
	cQuery += " SET  "
	cQuery += "   ,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '10' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS OUT,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '11' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS NOV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '12' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS DEZ  "
	cQuery += " FROM  "
	cQuery += "   "+RetSqlName('SE5')+" E5 "
	cQuery += " WHERE  "
	cQuery += "   E5_TIPODOC NOT IN ( "
	cQuery += "     'DC', 'D2', 'JR', 'J2', 'TL', 'MT', 'M2',  "
	cQuery += "     'CM', 'C2', 'ES', 'BA' "
	cQuery += "   )  "
	cQuery += "   AND E5_SITUACA NOT IN ('C', 'E', 'X')  "
	cQuery += "   AND E5_FILIAL = '"+FWxFilial('SE5')+"'  "
	cQuery += "   AND E5_CCUSTO LIKE '3.5%' "
	cQuery += "   AND E5_NATUREZ = '03002002' "
	cQuery += "   AND E5_DATA BETWEEN '"+DtoS(MV_PAR01)+"' "
	cQuery += "   AND '"+DtoS(MV_PAR02)+"'  "
	cQuery += "   AND E5.D_E_L_E_T_ <> '*'  "
	cQuery += " UNION "
	cQuery += " SELECT "
	cQuery += "   'Energia' AS DESCRICAO, "
	cQuery += "   12 AS ORDEM, "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '01' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JAN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '02' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS FEV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '03' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '04' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS ABR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '05' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAI,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '06' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '07' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUL,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '08' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS AGO,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '09' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS  "
	cQuery += " SET  "
	cQuery += "   ,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '10' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS OUT,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '11' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS NOV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '12' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS DEZ  "
	cQuery += " FROM  "
	cQuery += "   "+RetSqlName('SE5')+" E5 "
	cQuery += " WHERE  "
	cQuery += "   E5_TIPODOC NOT IN ( "
	cQuery += "     'DC', 'D2', 'JR', 'J2', 'TL', 'MT', 'M2',  "
	cQuery += "     'CM', 'C2', 'ES', 'BA' "
	cQuery += "   )  "
	cQuery += "   AND E5_SITUACA NOT IN ('C', 'E', 'X')  "
	cQuery += "   AND E5_FILIAL = '"+FWxFilial('SE5')+"'  "
	cQuery += "   AND E5_CCUSTO LIKE '3.5%' "
	cQuery += "   AND E5_NATUREZ = '03002001' "
	cQuery += "   AND E5_DATA BETWEEN '"+DtoS(MV_PAR01)+"' "
	cQuery += "   AND '"+DtoS(MV_PAR02)+"' "
	cQuery += "   AND E5.D_E_L_E_T_ <> '*'  "
	cQuery += " UNION "
	cQuery += " SELECT 'Custo Bandeja' AS DESCRICAO, "
	cQuery += "         13 AS ORDEM, "
	cQuery += "         (B.JAN / NULLIF(A.JAN, 0)) AS JAN, "
	cQuery += "         (B.FEV / NULLIF(A.FEV, 0)) AS FEV, "
	cQuery += "         (B.MAR / NULLIF(A.MAR, 0)) AS MAR, "
	cQuery += "         (B.ABR / NULLIF(A.ABR, 0)) AS ABR, "
	cQuery += "         (B.MAI / NULLIF(A.MAI, 0)) AS MAI, "
	cQuery += "         (B.JUN / NULLIF(A.JUN, 0)) AS JUN, "
	cQuery += "         (B.JUL / NULLIF(A.JUL, 0)) AS JUL, "
	cQuery += "         (B.AGO / NULLIF(A.AGO, 0)) AS AGO, "
	cQuery += "         (B.SET / NULLIF(A.SET, 0)) AS SET, "
	cQuery += "         (B.OUT / NULLIF(A.OUT, 0)) AS OUT, "
	cQuery += "         (B.NOV / NULLIF(A.NOV, 0)) AS NOV, "
	cQuery += "         (B.DEZ / NULLIF(A.DEZ, 0)) AS DEZ "
	cQuery += " FROM ( SELECT "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '01' THEN D3_QUANT ELSE 0 END "
	cQuery += "   ) AS JAN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '02' THEN D3_QUANT ELSE 0 END "
	cQuery += "   ) AS FEV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '03' THEN D3_QUANT ELSE 0 END "
	cQuery += "   ) AS MAR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '04' THEN D3_QUANT ELSE 0 END "
	cQuery += "   ) AS ABR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '05' THEN D3_QUANT ELSE 0 END "
	cQuery += "   ) AS MAI,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '06' THEN D3_QUANT ELSE 0 END "
	cQuery += "   ) AS JUN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '07' THEN D3_QUANT ELSE 0 END "
	cQuery += "   ) AS JUL,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '08' THEN D3_QUANT ELSE 0 END "
	cQuery += "   ) AS AGO,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '09' THEN D3_QUANT ELSE 0 END "
	cQuery += "   ) AS SET,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '10' THEN D3_QUANT ELSE 0 END "
	cQuery += "   ) AS OUT,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '11' THEN D3_QUANT ELSE 0 END "
	cQuery += "   ) AS NOV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '12' THEN D3_QUANT ELSE 0 END "
	cQuery += "   ) AS DEZ  "
	cQuery += " FROM  "
	cQuery += " "+RetSqlName('SD3')+" D3 "
	cQuery += " WHERE D3_FILIAL = '"+FWxFilial('SD3')+"'  "
	cQuery += "   AND D3_EMISSAO BETWEEN '"+DtoS(MV_PAR01)+"'  "
	cQuery += "   AND '"+DtoS(MV_PAR02)+"' "
	cQuery += "   AND D3_CF LIKE 'PR%' "
	cQuery += "   AND D3.D_E_L_E_T_ <> '*' ) as A "
	cQuery += "   JOIN "
	cQuery += "   ( SELECT  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '01' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JAN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '02' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS FEV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '03' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '04' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS ABR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '05' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS MAI,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '06' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '07' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS JUL,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '08' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS AGO,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '09' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS SET,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '10' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS OUT,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '11' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS NOV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(E5_DATA, 5, 2) = '12' THEN E5_VALOR ELSE 0 END "
	cQuery += "   ) AS DEZ  "
	cQuery += " FROM  "
	cQuery += "   "+RetSqlName('SE5')+" E5  "
	cQuery += " WHERE  "
	cQuery += "   E5_TIPODOC NOT IN ( "
	cQuery += "     'DC', 'D2', 'JR', 'J2', 'TL', 'MT', 'M2',  "
	cQuery += "     'CM', 'C2', 'ES', 'BA' "
	cQuery += "   )  "
	cQuery += "   AND E5_SITUACA NOT IN ('C', 'E', 'X')  "
	cQuery += "   AND E5_FILIAL = '"+FWxFilial('SE5')+"'  "
	cQuery += "   AND E5_RECPAG = 'P' "
	cQuery += "   AND E5_DATA BETWEEN '"+DtoS(MV_PAR01)+"'  "
	cQuery += "   AND '"+DtoS(MV_PAR02)+"' "
	cQuery += "   AND E5.D_E_L_E_T_ <> '*' ) AS B "
	cQuery += "   ON "
	cQuery += "   1=1  "
	cQuery += " ORDER BY ORDEM) AS DESPESAS "

	MpSysOpenQuery(cQuery, cAliasTmp)
	oPrtXlsx:SetBorder(.T.,.T.,.T.,.T., cStyle, "000000")
	//Impressão de Despesas
	While (cAliasTmp)->(!EoF())
		nRow++
		If ALLTRIM((cAliasTmp)->DESCRICAO) == 'Despesas'
			oPrtXlsx:SetCellsFormat(oCellH:Center(),oCellV:Center(),.F.,0,"FFFFFF","000000","")
			oPrtXlsx:SetText(  nRow , 01 , ALLTRIM((cAliasTmp)->DESCRICAO))
			oPrtXlsx:SetCellsFormat(oCellH:Right(),oCellV:Center(),.F.,0,"FFFFFF","000000","")
			oPrtXlsx:SetValue( nRow , 02 , Transform((cAliasTmp)->JAN, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 03 , Transform((cAliasTmp)->FEV, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 04 , Transform((cAliasTmp)->MAR, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 05 , Transform((cAliasTmp)->ABR, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 06 , Transform((cAliasTmp)->MAI, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 07 , Transform((cAliasTmp)->JUN, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 08 , Transform((cAliasTmp)->JUL, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 09 , Transform((cAliasTmp)->AGO, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 10 , Transform((cAliasTmp)->SET, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 11 , Transform((cAliasTmp)->OUT, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 12 , Transform((cAliasTmp)->NOV, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 13 , Transform((cAliasTmp)->DEZ, "@E 999,999,999,999.99")		)
			aDes := { 	(cAliasTmp)->JAN,;
				(cAliasTmp)->FEV,;
				(cAliasTmp)->MAR,;
				(cAliasTmp)->ABR,;
				(cAliasTmp)->MAI,;
				(cAliasTmp)->JUN,;
				(cAliasTmp)->JUL,;
				(cAliasTmp)->AGO,;
				(cAliasTmp)->SET,;
				(cAliasTmp)->OUT,;
				(cAliasTmp)->NOV,;
				(cAliasTmp)->DEZ }
		ElseIf ALLTRIM((cAliasTmp)->DESCRICAO) $ 'Insumos/Pessoal/Manutenção/Utilidades'
			oPrtXlsx:SetCellsFormat(oCellH:Left(),oCellV:Center(),.F.,0,"000000","C1C1C1","")
			oPrtXlsx:SetText(  nRow , 01 , ALLTRIM((cAliasTmp)->DESCRICAO))
			oPrtXlsx:SetCellsFormat(oCellH:Right(),oCellV:Center(),.F.,0,"000000","C1C1C1","")
			oPrtXlsx:SetValue( nRow , 02 , Transform((cAliasTmp)->JAN, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 03 , Transform((cAliasTmp)->FEV, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 04 , Transform((cAliasTmp)->MAR, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 05 , Transform((cAliasTmp)->ABR, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 06 , Transform((cAliasTmp)->MAI, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 07 , Transform((cAliasTmp)->JUN, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 08 , Transform((cAliasTmp)->JUL, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 09 , Transform((cAliasTmp)->AGO, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 10 , Transform((cAliasTmp)->SET, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 11 , Transform((cAliasTmp)->OUT, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 12 , Transform((cAliasTmp)->NOV, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 13 , Transform((cAliasTmp)->DEZ, "@E 999,999,999,999.99")		)
		ElseIf ALLTRIM((cAliasTmp)->DESCRICAO) == 'Custo Bandeja'
			nRow++
			oPrtXlsx:SetBorder(.F.,.F.,.F.,.F., cStyle, "000000")
			oPrtXlsx:MergeCells(nRow,1,nRow,13)
			oPrtXlsx:SetCellsFormat(oCellH:Center(),oCellV:Center(),.F.,0,"FFFFFF","FFFFFF","")
			oPrtXlsx:SetText(nRow,1,Space(12),"")
			nRow++
			oPrtXlsx:SetBorder(.T.,.T.,.T.,.T., cStyle, "000000")
			oPrtXlsx:SetCellsFormat(oCellH:Left(),oCellV:Center(),.F.,0,"000000","FFFFFF","")
			oPrtXlsx:SetText(  nRow , 01 , ALLTRIM((cAliasTmp)->DESCRICAO))
			oPrtXlsx:SetValue( nRow , 02 , Transform((cAliasTmp)->JAN, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 03 , Transform((cAliasTmp)->FEV, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 04 , Transform((cAliasTmp)->MAR, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 05 , Transform((cAliasTmp)->ABR, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 06 , Transform((cAliasTmp)->MAI, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 07 , Transform((cAliasTmp)->JUN, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 08 , Transform((cAliasTmp)->JUL, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 09 , Transform((cAliasTmp)->AGO, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 10 , Transform((cAliasTmp)->SET, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 11 , Transform((cAliasTmp)->OUT, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 12 , Transform((cAliasTmp)->NOV, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 13 , Transform((cAliasTmp)->DEZ, "@E 999,999,999,999.99")		)
		Else
			oPrtXlsx:SetCellsFormat(oCellH:Left(),oCellV:Center(),.F.,0,"000000","FFFFFF","")
			oPrtXlsx:SetText(  nRow , 01 , ALLTRIM((cAliasTmp)->DESCRICAO))
			oPrtXlsx:SetCellsFormat(oCellH:Right(),oCellV:Center(),.F.,0,"000000","FFFFFF","")
			oPrtXlsx:SetValue( nRow , 02 , Transform((cAliasTmp)->JAN, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 03 , Transform((cAliasTmp)->FEV, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 04 , Transform((cAliasTmp)->MAR, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 05 , Transform((cAliasTmp)->ABR, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 06 , Transform((cAliasTmp)->MAI, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 07 , Transform((cAliasTmp)->JUN, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 08 , Transform((cAliasTmp)->JUL, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 09 , Transform((cAliasTmp)->AGO, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 10 , Transform((cAliasTmp)->SET, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 11 , Transform((cAliasTmp)->OUT, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 12 , Transform((cAliasTmp)->NOV, "@E 999,999,999,999.99")		)
			oPrtXlsx:SetValue( nRow , 13 , Transform((cAliasTmp)->DEZ, "@E 999,999,999,999.99")		)
		EndIf
		(cAliasTmp)->(DbSkip())
	End

	nRow++
	oPrtXlsx:SetBorder(.F.,.F.,.F.,.F., cStyle, "000000")
	oPrtXlsx:MergeCells(nRow,1,nRow,13)
	oPrtXlsx:SetCellsFormat(oCellH:Center(),oCellV:Center(),.F.,0,"FFFFFF","FFFFFF","")
	oPrtXlsx:SetText(nRow,1,Space(12),"")
	nRow++
	oPrtXlsx:SetBorder(.T.,.T.,.T.,.T., cStyle, "000000")
	oPrtXlsx:SetCellsFormat(oCellH:Left(),oCellV:Center(),.F.,0,"000000","FFFFFF","")
	oPrtXlsx:SetText(  nRow , 01 , 	'Resultado')
	oPrtXlsx:SetCellsFormat(oCellH:Right(),oCellV:Center(),.F.,0,"000000","FFFFFF","")
	oPrtXlsx:SetValue( nRow , 02 , Transform(aRec[01]-aDes[01], "@E 999,999,999,999.99")		)
	oPrtXlsx:SetValue( nRow , 03 , Transform(aRec[02]-aDes[02], "@E 999,999,999,999.99")		)
	oPrtXlsx:SetValue( nRow , 04 , Transform(aRec[03]-aDes[03], "@E 999,999,999,999.99")		)
	oPrtXlsx:SetValue( nRow , 05 , Transform(aRec[04]-aDes[04], "@E 999,999,999,999.99")		)
	oPrtXlsx:SetValue( nRow , 06 , Transform(aRec[05]-aDes[05], "@E 999,999,999,999.99")		)
	oPrtXlsx:SetValue( nRow , 07 , Transform(aRec[06]-aDes[06], "@E 999,999,999,999.99")		)
	oPrtXlsx:SetValue( nRow , 08 , Transform(aRec[07]-aDes[07], "@E 999,999,999,999.99")		)
	oPrtXlsx:SetValue( nRow , 09 , Transform(aRec[08]-aDes[08], "@E 999,999,999,999.99")		)
	oPrtXlsx:SetValue( nRow , 10 , Transform(aRec[09]-aDes[09], "@E 999,999,999,999.99")		)
	oPrtXlsx:SetValue( nRow , 11 , Transform(aRec[10]-aDes[10], "@E 999,999,999,999.99")		)
	oPrtXlsx:SetValue( nRow , 12 , Transform(aRec[11]-aDes[11], "@E 999,999,999,999.99")		)
	oPrtXlsx:SetValue( nRow , 13 , Transform(aRec[12]-aDes[12], "@E 999,999,999,999.99")		)

	nRow++
	oPrtXlsx:SetBorder(.F.,.F.,.F.,.F., cStyle, "000000")
	oPrtXlsx:MergeCells(nRow,1,nRow,13)
	oPrtXlsx:SetCellsFormat(oCellH:Center(),oCellV:Center(),.F.,0,"FFFFFF","FFFFFF","")
	oPrtXlsx:SetText(nRow,1,Space(12),"")
	nRow++

	oPrtXlsx:MergeCells(nRow,1,nRow,13) // Estoque
	oPrtXlsx:SetCellsFormat(oCellH:Center(),oCellV:Center(),.F.,0,"FFFFFF","000000","")
	oPrtXlsx:SetText(nRow,1,"Estoque","")
	nRow++
	oPrtXlsx:SetBorder(.T.,.T.,.T.,.T., cStyle, "000000")
	oPrtXlsx:SetCellsFormat(oCellH:Center(),oCellV:Center(),.F.,0,"000000","FDBD18","")
	oPrtXlsx:SetText( nRow , 01 , "Descrição")
	oPrtXlsx:SetText( nRow , 02 , "Jan"		)
	oPrtXlsx:SetText( nRow , 03 , "Fev"		)
	oPrtXlsx:SetText( nRow , 04 , "Mar"		)
	oPrtXlsx:SetText( nRow , 05 , "Abr"		)
	oPrtXlsx:SetText( nRow , 06 , "Mai"		)
	oPrtXlsx:SetText( nRow , 07 , "Jun"		)
	oPrtXlsx:SetText( nRow , 08 , "Jul"		)
	oPrtXlsx:SetText( nRow , 09 , "Ago"		)
	oPrtXlsx:SetText( nRow , 10 , "Set"		)
	oPrtXlsx:SetText( nRow , 11 , "Out"		)
	oPrtXlsx:SetText( nRow , 12 , "Nov"		)
	oPrtXlsx:SetText( nRow , 13 , "Dez"		)

	(cAliasTmp)->(DbCloseArea())

	cQuery := " SELECT "
	cQuery += "   'Saldo Inicial' AS DESCRICAO,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(B9_DATA, 5, 2) = '01' THEN B9_QINI ELSE 0 END "
	cQuery += "   ) AS JAN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(B9_DATA, 5, 2) = '02' THEN B9_QINI ELSE 0 END "
	cQuery += "   ) AS FEV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(B9_DATA, 5, 2) = '03' THEN B9_QINI ELSE 0 END "
	cQuery += "   ) AS MAR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(B9_DATA, 5, 2) = '04' THEN B9_QINI ELSE 0 END "
	cQuery += "   ) AS ABR,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(B9_DATA, 5, 2) = '05' THEN B9_QINI ELSE 0 END "
	cQuery += "   ) AS MAI,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(B9_DATA, 5, 2) = '06' THEN B9_QINI ELSE 0 END "
	cQuery += "   ) AS JUN,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(B9_DATA, 5, 2) = '07' THEN B9_QINI ELSE 0 END "
	cQuery += "   ) AS JUL,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(B9_DATA, 5, 2) = '08' THEN B9_QINI ELSE 0 END "
	cQuery += "   ) AS AGO,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(B9_DATA, 5, 2) = '09' THEN B9_QINI ELSE 0 END "
	cQuery += "   ) AS  "
	cQuery += " SET  "
	cQuery += "   ,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(B9_DATA, 5, 2) = '10' THEN B9_QINI ELSE 0 END "
	cQuery += "   ) AS OUT,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(B9_DATA, 5, 2) = '11' THEN B9_QINI ELSE 0 END "
	cQuery += "   ) AS NOV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(B9_DATA, 5, 2) = '12' THEN B9_QINI ELSE 0 END "
	cQuery += "   ) AS DEZ  "
	cQuery += " FROM  "
	cQuery += "   "+RetSqlName('SB9')+" B9 "
	cQuery += " WHERE B9_FILIAL = '"+FWxFilial('SB9')+"'  "
	cQuery += " AND B9_DATA BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "
	cQuery += " AND B9.D_E_L_E_T_ <> '*'  "
	cQuery += " UNION "
	cQuery += " SELECT "
	cQuery += " 'Produção' AS DESCRICAO,  "
	cQuery += " SUM( "
	cQuery += "   CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '01' THEN D3_QUANT ELSE 0 END "
	cQuery += " ) AS JAN,  "
	cQuery += " SUM( "
	cQuery += "   CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '02' THEN D3_QUANT ELSE 0 END "
	cQuery += " ) AS FEV,  "
	cQuery += " SUM( "
	cQuery += "   CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '03' THEN D3_QUANT ELSE 0 END "
	cQuery += " ) AS MAR,  "
	cQuery += " SUM( "
	cQuery += "   CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '04' THEN D3_QUANT ELSE 0 END "
	cQuery += " ) AS ABR,  "
	cQuery += " SUM( "
	cQuery += "   CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '05' THEN D3_QUANT ELSE 0 END "
	cQuery += " ) AS MAI,  "
	cQuery += " SUM( "
	cQuery += "   CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '06' THEN D3_QUANT ELSE 0 END "
	cQuery += " ) AS JUN,  "
	cQuery += " SUM( "
	cQuery += "   CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '07' THEN D3_QUANT ELSE 0 END "
	cQuery += " ) AS JUL,  "
	cQuery += " SUM( "
	cQuery += "   CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '08' THEN D3_QUANT ELSE 0 END "
	cQuery += " ) AS AGO,  "
	cQuery += " SUM( "
	cQuery += "   CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '09' THEN D3_QUANT ELSE 0 END "
	cQuery += " ) AS  "
	cQuery += " SET  "
	cQuery += "   ,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '10' THEN D3_QUANT ELSE 0 END "
	cQuery += "   ) AS OUT,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '11' THEN D3_QUANT ELSE 0 END "
	cQuery += "   ) AS NOV,  "
	cQuery += "   SUM( "
	cQuery += "     CASE WHEN SUBSTRING(D3_EMISSAO, 5, 2) = '12' THEN D3_QUANT ELSE 0 END "
	cQuery += "   ) AS DEZ  "
	cQuery += " FROM  "
	cQuery += "   "+RetSqlName('SD3')+" D3 "
	cQuery += " WHERE D3_FILIAL = '"+FWxFilial('SD3')+"'  "
	cQuery += " AND D3_EMISSAO BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "
	cQuery += " AND D3_CF LIKE 'PR%' "
	cQuery += " AND D3.D_E_L_E_T_ <> '*' "

	MpSysOpenQuery(cQuery, cAliasTmp)

	While (cAliasTmp)->(!EoF())
		nRow++
		oPrtXlsx:SetCellsFormat(oCellH:Left(),oCellV:Center(),.F.,0,"000000","FFFFFF","")
		oPrtXlsx:SetText(  nRow , 01 , ALLTRIM((cAliasTmp)->DESCRICAO))
		oPrtXlsx:SetCellsFormat(oCellH:Right(),oCellV:Center(),.F.,0,"000000","FFFFFF","")
		oPrtXlsx:SetValue( nRow , 02 , Transform((cAliasTmp)->JAN, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 03 , Transform((cAliasTmp)->FEV, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 04 , Transform((cAliasTmp)->MAR, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 05 , Transform((cAliasTmp)->ABR, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 06 , Transform((cAliasTmp)->MAI, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 07 , Transform((cAliasTmp)->JUN, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 08 , Transform((cAliasTmp)->JUL, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 09 , Transform((cAliasTmp)->AGO, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 10 , Transform((cAliasTmp)->SET, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 11 , Transform((cAliasTmp)->OUT, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 12 , Transform((cAliasTmp)->NOV, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 13 , Transform((cAliasTmp)->DEZ, "@E 999,999,999,999.99")		)
		(cAliasTmp)->(DbSkip())
	End

	nRow++
	oPrtXlsx:SetBorder(.F.,.F.,.F.,.F., cStyle, "000000")
	oPrtXlsx:MergeCells(nRow,1,nRow,13)
	oPrtXlsx:SetCellsFormat(oCellH:Center(),oCellV:Center(),.F.,0,"FFFFFF","FFFFFF","")
	oPrtXlsx:SetText(nRow,1,Space(12),"")
	nRow++
	oPrtXlsx:SetBorder(.T.,.T.,.T.,.T., cStyle, "000000")
	oPrtXlsx:MergeCells(nRow,1,nRow,13)
	oPrtXlsx:SetCellsFormat(oCellH:Center(),oCellV:Center(),.F.,0,"FFFFFF","000000","")
	oPrtXlsx:SetText(nRow,1,"Preço Médio - Papelão","")
	nRow++

	oPrtXlsx:SetCellsFormat(oCellH:Center(),oCellV:Center(),.F.,0,"000000","FDBD18","")
	oPrtXlsx:SetText( nRow , 01 , "Descrição")
	oPrtXlsx:SetText( nRow , 02 , "Jan"		)
	oPrtXlsx:SetText( nRow , 03 , "Fev"		)
	oPrtXlsx:SetText( nRow , 04 , "Mar"		)
	oPrtXlsx:SetText( nRow , 05 , "Abr"		)
	oPrtXlsx:SetText( nRow , 06 , "Mai"		)
	oPrtXlsx:SetText( nRow , 07 , "Jun"		)
	oPrtXlsx:SetText( nRow , 08 , "Jul"		)
	oPrtXlsx:SetText( nRow , 09 , "Ago"		)
	oPrtXlsx:SetText( nRow , 10 , "Set"		)
	oPrtXlsx:SetText( nRow , 11 , "Out"		)
	oPrtXlsx:SetText( nRow , 12 , "Nov"		)
	oPrtXlsx:SetText( nRow , 13 , "Dez"		)

	(cAliasTmp)->(DbCloseArea())

	cQuery := " SELECT "
	cQuery += " 'Preço Médio' AS DESCRICAO, "
	cQuery += " COALESCE(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '01' THEN D1_TOTAL ELSE 0 END) / NULLIF(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '01' THEN D1_QUANT ELSE 0 END), 0), 0) AS JAN, "
	cQuery += " COALESCE(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '02' THEN D1_TOTAL ELSE 0 END) / NULLIF(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '02' THEN D1_QUANT ELSE 0 END), 0), 0) AS FEV, "
	cQuery += " COALESCE(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '03' THEN D1_TOTAL ELSE 0 END) / NULLIF(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '03' THEN D1_QUANT ELSE 0 END), 0), 0) AS MAR, "
	cQuery += " COALESCE(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '04' THEN D1_TOTAL ELSE 0 END) / NULLIF(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '04' THEN D1_QUANT ELSE 0 END), 0), 0) AS ABR, "
	cQuery += " COALESCE(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '05' THEN D1_TOTAL ELSE 0 END) / NULLIF(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '05' THEN D1_QUANT ELSE 0 END), 0), 0) AS MAI, "
	cQuery += " COALESCE(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '06' THEN D1_TOTAL ELSE 0 END) / NULLIF(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '06' THEN D1_QUANT ELSE 0 END), 0), 0) AS JUN, "
	cQuery += " COALESCE(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '07' THEN D1_TOTAL ELSE 0 END) / NULLIF(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '07' THEN D1_QUANT ELSE 0 END), 0), 0) AS JUL, "
	cQuery += " COALESCE(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '08' THEN D1_TOTAL ELSE 0 END) / NULLIF(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '08' THEN D1_QUANT ELSE 0 END), 0), 0) AS AGO, "
	cQuery += " COALESCE(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '09' THEN D1_TOTAL ELSE 0 END) / NULLIF(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '09' THEN D1_QUANT ELSE 0 END), 0), 0) AS SET, "
	cQuery += " COALESCE(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '10' THEN D1_TOTAL ELSE 0 END) / NULLIF(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '10' THEN D1_QUANT ELSE 0 END), 0), 0) AS OUT, "
	cQuery += " COALESCE(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '11' THEN D1_TOTAL ELSE 0 END) / NULLIF(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '11' THEN D1_QUANT ELSE 0 END), 0), 0) AS NOV, "
	cQuery += " COALESCE(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '12' THEN D1_TOTAL ELSE 0 END) / NULLIF(SUM(CASE WHEN SUBSTRING(D1_EMISSAO, 5, 2) = '12' THEN D1_QUANT ELSE 0 END), 0), 0) AS DEZ "
	cQuery += " FROM "
	cQuery += " "+RetSqlName('SD1')+" D1 "
	cQuery += " WHERE "
	cQuery += " D1_FILIAL = '"+FWxFilial('SD1')+"' "
	cQuery += " AND D1_EMISSAO BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "
	cQuery += " AND D1.D_E_L_E_T_ <> '*' "

	MpSysOpenQuery(cQuery, cAliasTmp)

	If (cAliasTmp)->(!EoF())
		nRow++
		oPrtXlsx:SetCellsFormat(oCellH:Left(),oCellV:Center(),.F.,0,"000000","FFFFFF","")
		oPrtXlsx:SetText(  nRow , 01 , ALLTRIM((cAliasTmp)->DESCRICAO))
		oPrtXlsx:SetCellsFormat(oCellH:Right(),oCellV:Center(),.F.,0,"000000","FFFFFF","")
		oPrtXlsx:SetValue( nRow , 02 , Transform((cAliasTmp)->JAN, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 03 , Transform((cAliasTmp)->FEV, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 04 , Transform((cAliasTmp)->MAR, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 05 , Transform((cAliasTmp)->ABR, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 06 , Transform((cAliasTmp)->MAI, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 07 , Transform((cAliasTmp)->JUN, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 08 , Transform((cAliasTmp)->JUL, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 09 , Transform((cAliasTmp)->AGO, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 10 , Transform((cAliasTmp)->SET, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 11 , Transform((cAliasTmp)->OUT, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 12 , Transform((cAliasTmp)->NOV, "@E 999,999,999,999.99")		)
		oPrtXlsx:SetValue( nRow , 13 , Transform((cAliasTmp)->DEZ, "@E 999,999,999,999.99")		)
	EndIf

	(cAliasTmp)->(DbCloseArea())

	oPrtXlsx:toXlsx()

	If File(cArquivo)
		oExcel:WorkBooks:Open(Strtran(cArquivo,'.rel','.xlsx'))
		oExcel:SetVisible(.T.)
		oExcel:Destroy()
		FErase(cArquivo)
	EndIf

Return
