#include "PROTHEUS.CH"
#include "TBICONN.ch"

*******************************************************************************
// Funcao   : RELFAL01 - Função para gerar o relatorio de faltas           	  |
// Modulo   : SIGAGPE - Gestão de pessoal                           	      |
// Fonte    : RELFAL01.prw                                                    |
// ---------+--------------------------+--------------------------------------+
// Data     | Autor                    | Descricao                            |
// ---------+---------------+----------+--------------------------------------+
// 11/01/24 | Rivaldo G.    |Cod.ERP   | Monta os parâmetros e executa o arqv.|
*******************************************************************************

static oCellHorAlign := FwXlsxCellAlignment():Horizontal()
static oCellVertAlign := FwXlsxCellAlignment():Vertical()

User Function RELFAL01(aParam)
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

		If Empty(cArquivo)
			FwAlertWarning("Não foram encontrados dados com os parâmetros especificados", "Atenção!")
			Return
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
// FunÃ§Ã£o   : GeraExcelEntradas - Monta o Excel de Entradas no Periodo      |
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
	local cArquivo 	:= cPath+"RelFaltasIndiv.rel"
	local oFileW   	:= FwFileWriter():New(cArquivo)
	local oPrtXlsx 	:= FwPrinterXlsx():New()
	Local nRow 	   	:= 1
	Local cCor 		:= "95B3D7"//"66FFFF"
	Local cArquivoFinal:= ""
	Local nDias		:= 0
	Local nTotDias 	:= 0
	Local nTotHoras := 0


	cQuery +=" SELECT *
	cQuery +=" FROM
	cQuery +="  (SELECT FILIAL,
	cQuery +="          CODIGO,
	cQuery +="          DESCRICAO,
	cQuery +="          MATRICULA,
	cQuery +="          DATA_EVENTO,
	cQuery +="          NOME,
	cQuery +="          JUSTIFICATIVA,
	cQuery +="          COD_JUS,
	cQuery +="          DATA_INICIO,
	cQuery +="          DATA_FIM,
	cQuery +="          SUM(SOMA_DURACAO) AS SOMA
	cQuery +="   FROM
	cQuery +="     (SELECT PC_FILIAL AS FILIAL,
	cQuery +="             SRA.RA_CC AS CODIGO,
	cQuery +="             CTT.CTT_DESC01 AS DESCRICAO,
	cQuery +="             PC_MAT AS MATRICULA,
	cQuery +="             CONVERT(DATE, PC_DATA, 103) AS DATA_EVENTO,
	cQuery +="             '' AS DATA_INICIO,
	cQuery +="             '' AS DATA_FIM,
	cQuery +="             SRA.RA_NOME AS NOME,
	cQuery +="             SP6.P6_DESC AS JUSTIFICATIVA,
	cQuery +="             SP6.P6_CODIGO AS COD_JUS,
	cQuery +="             SUM(PC_QUANTC) AS SOMA_DURACAO
	cQuery +="      FROM "+RETSQLNAME('SPC')+" SPC
	cQuery +="      INNER JOIN "+RETSQLNAME('SRA')+" SRA ON SRA.RA_MAT = SPC.PC_MAT AND SRA.RA_FILIAL = SPC.PC_FILIAL AND SRA.D_E_L_E_T_ <> '*'
	cQuery +="      INNER JOIN "+RETSQLNAME('CTT')+" CTT ON SRA.RA_CC = CTT.CTT_CUSTO AND SUBSTRING(SRA.RA_FILIAL, 1, 2) = CTT.CTT_FILIAL AND CTT.D_E_L_E_T_ <> '*'
	cQuery +="      INNER JOIN "+RETSQLNAME('SP9')+" SP9 ON SPC.PC_PD = SP9.P9_CODIGO AND P9_CODIGO = '010' AND SP9.D_E_L_E_T_ <> '*'
	cQuery +="      LEFT  JOIN "+RETSQLNAME('SP6')+" SP6 ON SPC.PC_ABONO = SP6.P6_CODIGO
	cQuery +="      AND SP6.D_E_L_E_T_ <> '*'
	cQuery +="      WHERE SPC.D_E_L_E_T_ <> '*'
	cQuery +="        AND PC_FILIAL 	BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'
	cQuery +="        AND RA_CC 		BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
	cQuery +="        AND PC_MAT 		BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
	cQuery +="        AND PC_DATA 	BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"'
	cQuery +="      GROUP BY PC_FILIAL,
	cQuery +="               PC_MAT,
	cQuery +="               SRA.RA_NOME,
	cQuery +="               SRA.RA_CC,
	cQuery +="               CTT.CTT_DESC01,
	cQuery +="               PC_DATA,
	cQuery +="               P6_DESC,
	cQuery +="               SP6.P6_CODIGO
	cQuery +="      UNION ALL
	cQuery +="         SELECT PH_FILIAL AS FILIAL,
	cQuery +="            SRA.RA_CC AS CODIGO,
	cQuery +="                       CTT.CTT_DESC01 AS DESCRICAO,
	cQuery +="                       PH_MAT AS MATRICULA,
	cQuery +="                       CONVERT(DATE, PH_DATA, 103) AS DATA_EVENTO,
	cQuery +="                       '' AS DATA_INICIO,
	cQuery +="                       '' AS DATA_FIM,
	cQuery +="                       SRA.RA_NOME AS NOME,
	cQuery +="                       SP6.P6_DESC AS JUSTIFICATIVA,
	cQuery +="                       SP6.P6_CODIGO AS COD_JUS,
	cQuery +="                       SUM(PH_QUANTC) AS SOMA_DURACAO
	cQuery +="      FROM "+RETSQLNAME('SPH')+" SPH
	cQuery +="      INNER JOIN "+RETSQLNAME('SRA')+" SRA ON SRA.RA_MAT = SPH.PH_MAT AND SRA.RA_FILIAL = SPH.PH_FILIAL AND SRA.D_E_L_E_T_ <> '*'
	cQuery +="      INNER JOIN "+RETSQLNAME('CTT')+" CTT ON SRA.RA_CC = CTT.CTT_CUSTO AND SUBSTRING(SRA.RA_FILIAL, 1, 2) = CTT.CTT_FILIAL AND CTT.D_E_L_E_T_ <> '*'
	cQuery +="      INNER JOIN "+RETSQLNAME('SP9')+" SP9 ON SPH.PH_PD = SP9.P9_CODIGO AND P9_CODIGO = '010' AND SP9.D_E_L_E_T_ <> '*'
	cQuery +="      LEFT  JOIN "+RETSQLNAME('SP6')+" SP6 ON SPH.PH_ABONO = SP6.P6_CODIGO AND SP6.D_E_L_E_T_ <> '*'
	cQuery +="      WHERE SPH.D_E_L_E_T_ <> '*'
	cQuery +="        AND PH_FILIAL 	BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'
	cQuery +="        AND RA_CC 		BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
	cQuery +="        AND PH_MAT 		BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
	cQuery +="        AND PH_DATA 		BETWEEN 	'"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"'
	cQuery +="      GROUP BY PH_FILIAL,
	cQuery +="               PH_MAT,
	cQuery +="               SRA.RA_NOME,
	cQuery +="               SRA.RA_CC,
	cQuery +="               CTT.CTT_DESC01,
	cQuery +="               PH_DATA,
	cQuery +="               P6_DESC,
	cQuery +="               SP6.P6_CODIGO
	cQuery +="     UNION ALL
	cQuery +="	  SELECT SR8.R8_FILIAL AS FILIAL,
	cQuery +="        SRA.RA_CC AS CODIGO,
	cQuery +="        CTT.CTT_DESC01 AS DESCRICAO,
	cQuery +="        SR8.R8_MAT AS MATRICULA,
	cQuery +="        CONVERT(DATE, SR8.R8_DATA, 103) AS DATA_EVENTO,
	cQuery +="        SR8.R8_DATAINI AS DATA_INICIO,
	cQuery +="        SR8.R8_DATAFIM AS DATA_FIM,
	cQuery +="        SRA.RA_NOME AS NOME,
	cQuery +="        RCM.RCM_DESCRI AS JUSTIFICATIVA,
	cQuery +="        RCM.RCM_TIPO AS COD_JUS,
	cQuery +="        SUM(SR8.R8_DURACAO) AS SOMA_DURACAO
	cQuery +="      FROM "+RETSQLNAME('SR8')+" SR8
	cQuery +="      INNER JOIN "+RETSQLNAME('SRA')+" SRA ON SRA.RA_MAT = SR8.R8_MAT AND SRA.RA_FILIAL = SR8.R8_FILIAL AND SRA.D_E_L_E_T_ <> '*'
	cQuery +="      INNER JOIN "+RETSQLNAME('CTT')+" CTT ON SRA.RA_CC = CTT.CTT_CUSTO AND SUBSTRING(SRA.RA_FILIAL, 1, 2) = CTT.CTT_FILIAL AND CTT.D_E_L_E_T_ <> '*'
	cQuery +="      INNER JOIN "+RETSQLNAME('RCM')+" RCM ON RCM.RCM_FILIAL =SUBSTRING(SR8.R8_FILIAL, 1, 2) AND RCM.RCM_TIPO=SR8.R8_TIPOAFA AND RCM.D_E_L_E_T_ <> '*'
	cQuery +="      WHERE SR8.D_E_L_E_T_ <> '*'
	cQuery +="        AND SR8.R8_FILIAL 	BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'
	cQuery +="        AND RA_CC 			BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
	cQuery +="        AND SR8.R8_MAT 		BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
	cQuery +="        AND (SR8.R8_DATAINI	BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"' OR SR8.R8_DATAFIM	BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"')
	cQuery +="      GROUP BY SR8.R8_FILIAL,SR8.R8_MAT,RCM.RCM_TIPO,SRA.RA_NOME,SRA.RA_CC,CTT.CTT_DESC01,SR8.R8_DATAINI,SR8.R8_DATAFIM,RCM.RCM_DESCRI,SR8.R8_DATA
	cQuery +="   	UNION ALL
	cQuery +="  SELECT SP2.P2_FILIAL AS FILIAL, '' AS CODIGO, '' as DESCRICAO, SP2.P2_MAT AS MATRICULA, SP2.P2_DATA AS DATA_EVENTO, SP2.P2_DATA AS DATA_INICIO, SP2.P2_DATAATE AS DATA_FIM, SRA.RA_NOME AS NOME, SP2.P2_MOTIVO AS JUSTIFICATIVA,'' AS COD_JUS, '' AS SOMA_DURACAO
	cQuery +=" 	FROM SP2010 SP2
	cQuery +=" 	INNER JOIN SRA010 SRA ON SRA.RA_FILIAL = SP2.P2_FILIAL AND SRA.RA_MAT =SP2.P2_MAT AND SRA.D_E_L_E_T_ <> '*'
	cQuery +=" WHERE SP2.D_E_L_E_T_ <> '*'
	cQuery +="  AND SP2.P2_FILIAL 	BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'
	cQuery +="  AND SP2.P2_MAT      BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
	cQuery +="  AND (SP2.P2_DATA	BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"' OR SP2.P2_DATAATE	BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"')
	cQuery +=" GROUP BY SP2.P2_FILIAL,SP2.P2_MAT,SP2.P2_DATA,SP2.P2_DATAATE, SRA.RA_NOME,SP2.P2_MOTIVO,SP2.P2_DATA ) AS A
	cQuery +=" GROUP BY FILIAL,CODIGO,DESCRICAO,MATRICULA,DATA_EVENTO,NOME,JUSTIFICATIVA,COD_JUS,DATA_INICIO,DATA_FIM) AS A
	cQuery +=" ORDER BY FILIAL,CODIGO,NOME, DATA_EVENTO, DATA_INICIO

	MpSysOpenQuery(cQuery, "TE5")

//Query usada att 17/04/2024
/* SELECT *
FROM
  (SELECT FILIAL,
          CODIGO,
          DESCRICAO,
          MATRICULA,
          DATA_EVENTO,
          NOME,
          JUSTIFICATIVA,
          COD_JUS,
          DATA_INICIO,
          DATA_FIM,
          SUM(SOMA_DURACAO) AS SOMA
   FROM
     (SELECT PC_FILIAL AS FILIAL,
             SRA.RA_CC AS CODIGO,
             CTT.CTT_DESC01 AS DESCRICAO,
             PC_MAT AS MATRICULA,
             CONVERT(DATE, PC_DATA, 103) AS DATA_EVENTO,
             '' AS DATA_INICIO,
             '' AS DATA_FIM,
             SRA.RA_NOME AS NOME,
             SP6.P6_DESC AS JUSTIFICATIVA,
             SP6.P6_CODIGO AS COD_JUS,
             SUM(PC_QUANTC) AS SOMA_DURACAO
      FROM SPC010 SPC
      INNER JOIN SRA010 SRA ON SRA.RA_MAT = SPC.PC_MAT
      AND SRA.RA_FILIAL = SPC.PC_FILIAL
      AND SRA.D_E_L_E_T_ <> '*'
      INNER JOIN CTT010 CTT ON SRA.RA_CC = CTT.CTT_CUSTO
      AND SUBSTRING(SRA.RA_FILIAL, 1, 2) = CTT.CTT_FILIAL
      AND CTT.D_E_L_E_T_ <> '*'
      INNER JOIN SP9010 SP9 ON SPC.PC_PD = SP9.P9_CODIGO
      AND P9_CODIGO = '010'
      AND SP9.D_E_L_E_T_ <> '*'
      LEFT  JOIN SP6010 SP6 ON SPC.PC_ABONO = SP6.P6_CODIGO
      AND SP6.D_E_L_E_T_ <> '*'
      WHERE SPC.D_E_L_E_T_ <> '*'
        AND PC_FILIAL BETWEEN '0203' AND '0203'
        AND RA_CC BETWEEN '         ' AND 'ZZZZZZZZZ'
        AND PC_MAT BETWEEN '      ' AND 'ZZZZZZ'
        AND PC_DATA BETWEEN '20240201' AND '20240229'
      GROUP BY PC_FILIAL,
               PC_MAT,
               SRA.RA_NOME,
               SRA.RA_CC,
               CTT.CTT_DESC01,
               PC_DATA,
               P6_DESC,
               SP6.P6_CODIGO
      UNION ALL SELECT PH_FILIAL AS FILIAL,
                       SRA.RA_CC AS CODIGO,
                       CTT.CTT_DESC01 AS DESCRICAO,
                       PH_MAT AS MATRICULA,
                       CONVERT(DATE, PH_DATA, 103) AS DATA_EVENTO,
                       '' AS DATA_INICIO,
                       '' AS DATA_FIM,
                       SRA.RA_NOME AS NOME,
                       SP6.P6_DESC AS JUSTIFICATIVA,
                       SP6.P6_CODIGO AS COD_JUS,
                       SUM(PH_QUANTC) AS SOMA_DURACAO
      FROM SPH010 SPH
      INNER JOIN SRA010 SRA ON SRA.RA_MAT = SPH.PH_MAT
      AND SRA.RA_FILIAL = SPH.PH_FILIAL
      AND SRA.D_E_L_E_T_ <> '*'
      INNER JOIN CTT010 CTT ON SRA.RA_CC = CTT.CTT_CUSTO
      AND SUBSTRING(SRA.RA_FILIAL, 1, 2) = CTT.CTT_FILIAL
      AND CTT.D_E_L_E_T_ <> '*'
      INNER JOIN SP9010 SP9 ON SPH.PH_PD = SP9.P9_CODIGO
      AND P9_CODIGO = '010'
      AND SP9.D_E_L_E_T_ <> '*'
      LEFT  JOIN SP6010 SP6 ON SPH.PH_ABONO = SP6.P6_CODIGO
      AND SP6.D_E_L_E_T_ <> '*'
      WHERE SPH.D_E_L_E_T_ <> '*'
        AND PH_FILIAL BETWEEN '0203' AND '0203'
        AND RA_CC BETWEEN '         ' AND 'ZZZZZZZZZ'
        AND PH_MAT BETWEEN '      ' AND 'ZZZZZZ'
        AND PH_DATA BETWEEN '20240201' AND '20240229'
      GROUP BY PH_FILIAL,
               PH_MAT,
               SRA.RA_NOME,
               SRA.RA_CC,
               CTT.CTT_DESC01,
               PH_DATA,
               P6_DESC,
               SP6.P6_CODIGO
      UNION ALL SELECT SR8.R8_FILIAL AS FILIAL,
                       SRA.RA_CC AS CODIGO,
                       CTT.CTT_DESC01 AS DESCRICAO,
                       SR8.R8_MAT AS MATRICULA,
                       CONVERT(DATE, SR8.R8_DATA, 103) AS DATA_EVENTO,
                       SR8.R8_DATAINI AS DATA_INICIO,
                       SR8.R8_DATAFIM AS DATA_FIM,
                       SRA.RA_NOME AS NOME,
					   RCM.RCM_DESCRI  AS JUSTIFICATIVA,
                       RCM.RCM_TIPO  AS COD_JUS,
                       SUM(SR8.R8_DURACAO) AS SOMA_DURACAO
      FROM SR8010 SR8
      INNER JOIN SRA010 SRA ON SRA.RA_MAT = SR8.R8_MAT
      AND SRA.RA_FILIAL = SR8.R8_FILIAL
      AND SRA.D_E_L_E_T_ <> '*'
      INNER JOIN CTT010 CTT ON SRA.RA_CC = CTT.CTT_CUSTO
      AND SUBSTRING(SRA.RA_FILIAL, 1, 2) = CTT.CTT_FILIAL
      AND CTT.D_E_L_E_T_ <> '*'
      INNER JOIN RCM010 RCM ON RCM.RCM_FILIAL =SUBSTRING(SR8.R8_FILIAL, 1, 2)
      AND RCM.RCM_TIPO=SR8.R8_TIPOAFA
      AND RCM.D_E_L_E_T_ <> '*'
      WHERE SR8.D_E_L_E_T_ <> '*'
        AND SR8.R8_FILIAL BETWEEN '0203' AND '0203'
        AND RA_CC BETWEEN '         ' AND 'ZZZZZZZZZ'
        AND SR8.R8_MAT BETWEEN '      ' AND 'ZZZZZZ'
        AND (SR8.R8_DATAINI BETWEEN '20240201' AND '20240229' OR SR8.R8_DATAFIM BETWEEN '20240201' AND '20240229')
      GROUP BY SR8.R8_FILIAL,
               SR8.R8_MAT,
               RCM.RCM_TIPO,
               SRA.RA_NOME,
               SRA.RA_CC,
               CTT.CTT_DESC01,
               SR8.R8_DATAINI,
               SR8.R8_DATAFIM,
               RCM.RCM_DESCRI,
               SR8.R8_DATA
	UNION ALL

	 SELECT SP2.P2_FILIAL AS FILIAL, '' AS CODIGO, '' as DESCRICAO, SP2.P2_MAT AS MATRICULA, '' AS DATA_EVENTO, SP2.P2_DATA AS DATA_INICIO, SP2.P2_DATAATE AS DATA_FIM, SRA.RA_NOME AS NOME, SP2.P2_MOTIVO AS JUSTIFICATIVA,'' AS COD_JUS, '' AS SOMA_DURACAO  
		FROM SP2010 SP2 
		INNER JOIN SRA010 SRA ON SRA.RA_FILIAL =SP2.P2_FILIAL AND SRA.RA_MAT =SP2.P2_MAT AND SRA.D_E_L_E_T_ <> '*'
	WHERE SP2.D_E_L_E_T_ <> '*'
	 AND SP2.P2_FILIAL 	BETWEEN '0203' AND '0203'
	 AND SP2.P2_MAT     BETWEEN '' AND 'ZZZZ'
	 AND (SP2.P2_DATA	BETWEEN '20240201' AND '20240229' OR SP2.P2_DATAATE	BETWEEN '20240201' AND '20240229')
	GROUP BY SP2.P2_FILIAL,SP2.P2_MAT,SP2.P2_DATA,SP2.P2_DATAATE, SRA.RA_NOME,SP2.P2_MOTIVO

) AS A
   GROUP BY FILIAL,
            CODIGO,
            DESCRICAO,
            MATRICULA,
            DATA_EVENTO,
            NOME,
            JUSTIFICATIVA,
            COD_JUS,
            DATA_INICIO,
            DATA_FIM) AS A
ORDER BY FILIAL,
         CODIGO,
         NOME */

	

	If TE5->(Eof())
		TE5->(DbCloseArea())
		Return Alert("Não foram encontrados registros, Por favor analise os parâmetros","Atenção")
	EndIf

	oPrtXlsx:Activate(cArquivo, oFileW)
	oPrtXlsx:AddSheet("INDIVIDUAL")
	
	//definiÃ§Ã£o da largura das colunas
	//oPrtXlsx:SetColumnsWidth(1, 1, 5.78 ) // Filial
	//oPrtXlsx:SetColumnsWidth(2, 2, 5.78 ) // centro de custo

	oPrtXlsx:SetColumnsWidth(1, 1, 9.33	) // Filial
	oPrtXlsx:SetColumnsWidth(2, 2, 14	) // centro de custo
	oPrtXlsx:SetColumnsWidth(3, 3, 36   ) // descricao
	oPrtXlsx:SetColumnsWidth(4, 4, 9    ) // matricula
	oPrtXlsx:SetColumnsWidth(5, 5, 36   ) // nome
	oPrtXlsx:SetColumnsWidth(6, 8, 14   ) // data, horas, dias
	//oPrtXlsx:SetColumnsWidth(7, 7, 7.6  )
	//oPrtXlsx:SetColumnsWidth(8, 8, 12   )
	oPrtXlsx:SetColumnsWidth(9, 9, 28.67) // Justificativa

	oPrtXlsx:SetFont(cFont, 16, .F., .T., .F.) // seta o texto em negrito
	oPrtXlsx:MergeCells(/*lin inicial*/1,/*col inicial*/1,/*lin final*/1,/*col final*/9)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	oPrtXlsx:MergeCells(/*lin inicial*/2,/*col inicial*/1,/*lin final*/2,/*col final*/9)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	oPrtXlsx:MergeCells(/*lin inicial*/3,/*col inicial*/1,/*lin final*/3,/*col final*/9)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	oPrtXlsx:MergeCells(/*lin inicial*/4,/*col inicial*/1,/*lin final*/4,/*col final*/9)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	oPrtXlsx:MergeCells(/*lin inicial*/5,/*col inicial*/1,/*lin final*/5,/*col final*/9)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	//oPrtXlsx:MergeCells(/*lin inicial*/6,/*col inicial*/1,/*lin final*/6,/*col final*/9)// merge das celulas iniciais para o cabeÃ§alho do arquivo

	oPrtXlsx:SetCellsFormat(cHorAliLeft, cVertAliCent, /*lWrapText*/.F., /*nRotation*/0, "000000", "FFFFFF", "" )
	oPrtXlsx:SetText(/*nRow*/1, /*nCol*/ 1, "RELATÓRIO DE FALTAS - INDIVIDUAL") // Texto em A1
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
	oPrtXlsx:SetText( nRow , /*nCol*/7 , "Soma de Horas"	) //-- 7
	oPrtXlsx:SetText( nRow , /*nCol*/8 , "Soma de Dias"     ) //-- 8
	oPrtXlsx:SetText( nRow , /*nCol*/9 , "Justificativa"	) //-- 9
	oPrtXlsx:ResetCellsFormat()

	While TE5->(!Eof())
		oPrtXlsx:SetFont(cFont, 10, .F., .F., .F.) // seta o texto sem negrito
		
	    If Empty(TE5->CODIGO)
			cCentro := Posicione("SRA",1, TE5->FILIAL + TE5->MATRICULA + TE5->NOME, "RA_CC")
			cDescCC := Posicione("CTT",1, xFilial('CTT') + cCentro, "CTT_DESC01")
		else
			cCentro  := TE5->CODIGO
			cDescCC  := TE5->DESCRICAO 
		EndIf
		nTotDias := 0
		nTotHoras:= 0
		cMat     := TE5->MATRICULA
		cNome    := AllTrim(TE5->NOME)
		While TE5->(!Eof()) .And. cMat == TE5->MATRICULA
			cCodJus := TE5->COD_JUS
			cDescJus:= AllTrim(TE5->JUSTIFICATIVA)
			nDias 	:= 0
			cFil    := TE5->FILIAL
			cData   := cValToChar(TE5->Data_Evento)
			
			//Verifica os registros com data de inicio e fim de ausencia
			If !Empty(TE5->DATA_INICIO)
				dDataIni := IIF(MV_PAR07 > StoD(TE5->DATA_INICIO), MV_PAR07, StoD(TE5->DATA_INICIO))
				dDataFim := StoD(TE5->DATA_FIM)
				cCodTurn := Posicione("SRA",1,FWxFilial("SRA") + cMat + cNome, "RA_TNOTRAB")
				nTurno   := Posicione("SR6",1,FWxFilial("SR6") + cCodTurn, "R6_HRNORMA")//Pegar o turno de trabalho
				While dDataIni <= dDataFim
					nRow++
					oPrtXlsx:SetCellsFormat(cHorAliCent, cVertAliCent, /*lWrapText*/.F.,/*nRotation*/0,"000000","FFFFFF","")
					oPrtXlsx:SetValue( nRow , /*nCol*/1 , cFil		     			          )//-- 1
					oPrtXlsx:SetValue( nRow , /*nCol*/2 , AllTrim(cCentro)	  		          )//-- 2
					oPrtXlsx:SetValue( nRow , /*nCol*/3 , AllTrim(cDescCC)  			      )//-- 3
					oPrtXlsx:SetValue( nRow , /*nCol*/4 , cMat			  			          )//-- 4
					oPrtXlsx:SetValue( nRow , /*nCol*/5 , cNome						          )//-- 5
					oPrtXlsx:SetValue( nRow , /*nCol*/6 , cValtoChar(dDataIni)			 	  )//-- 6
					oPrtXlsx:SetValue( nRow , /*nCol*/7 , StrTran(cValToChar(nTurno),'.',':'))//-- 7
					oPrtXlsx:SetValue( nRow , /*nCol*/8 , 1		 						  	  )//-- 8
					oPrtXlsx:SetValue( nRow , /*nCol*/9 , iIf(Empty(cDescJus),'Banco de horas',cDescJus))//-- 9
					nTotHoras+=Hrs2Min( cValToChar(nTurno) )
					nTotDias++		
					dDataIni := dDataIni + 1
				End
			Else
				nRow++
				oPrtXlsx:SetCellsFormat(cHorAliCent, cVertAliCent, /*lWrapText*/.F.,/*nRotation*/0,"000000","FFFFFF","")
				oPrtXlsx:SetValue( nRow , /*nCol*/1 , cFil		     			          )//-- 1
				oPrtXlsx:SetValue( nRow , /*nCol*/2 , AllTrim(cCentro)	  		          )//-- 2
				oPrtXlsx:SetValue( nRow , /*nCol*/3 , AllTrim(cDescCC)  			      )//-- 3
				oPrtXlsx:SetValue( nRow , /*nCol*/4 , cMat			  			          )//-- 4
				oPrtXlsx:SetValue( nRow , /*nCol*/5 , cNome						          )//-- 5
				oPrtXlsx:SetValue( nRow , /*nCol*/6 , cData 						  	  )//-- 6
				oPrtXlsx:SetValue( nRow , /*nCol*/7 , StrTran(cValToChar(TE5->SOMA),'.',':'))//-- 7
				oPrtXlsx:SetValue( nRow , /*nCol*/8 , 1		 						  	  )//-- 8
				oPrtXlsx:SetValue( nRow , /*nCol*/9 , iIf(Empty(cDescJus),'Banco de horas',cDescJus))//-- 9
				nTotHoras+=Hrs2Min( cValToChar(TE5->SOMA) )//TE5->SOMA_DURACAO
				nTotDias++
			Endif
			TE5->(DbSkip())
		End	
		oPrtXlsx:SetFont(cFont, 10, .F., .T., .F.) // seta o texto em negrito
		nRow++
		oPrtXlsx:SetCellsFormat(cHorAliCent, cVertAliCent, /*lWrapText*/.F.,/*nRotation*/0,"000000",cCor,"")
		oPrtXlsx:SetValue( nRow , /*nCol*/1 , ''		     			          )//-- 1
		oPrtXlsx:SetValue( nRow , /*nCol*/2 , ''						  		  )//-- 2
		oPrtXlsx:SetValue( nRow , /*nCol*/3 , 'TOTAL '+AllTrim(cDescCC)			  )//-- 3
		oPrtXlsx:SetValue( nRow , /*nCol*/4 , cMat			 			          )//-- 4
		oPrtXlsx:SetValue( nRow , /*nCol*/5 , cNome						          )//-- 5
		oPrtXlsx:SetValue( nRow , /*nCol*/6 , ''						  	 	  )//-- 6
		oPrtXlsx:SetValue( nRow , /*nCol*/7 , StrTran(cValToChar(Min2Hrs(nTotHoras)),'.',':'))//-- 7
		//oPrtXlsx:SetValue( nRow , /*nCol*/7 , StrTran(cValToChar(nTotHoras),'.',':'))//-- 7
		oPrtXlsx:SetValue( nRow , /*nCol*/8 , nTotDias						      )//-- 8
		oPrtXlsx:SetValue( nRow , /*nCol*/9 , ''								  )//-- 9
	End
	TE5->(DbCloseArea())	

	oPrtXlsx:toXlsx()
	cArquivoFinal := StrTran(cArquivo, ".rel", ".xlsx")
	If !IsBlind()
		If File(cPathLocal+"RelFaltasIndiv.rel")
			FErase(cPathLocal+"RelFaltasIndiv.rel")
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
	Local cQuery    	:= ''
	Local cMat      	:= ''
	Local cCentro   	:= ''
	local cArquivo 		:= cPath+"RelFaltasConso.rel"
	local oFileW   		:= FwFileWriter():New(cArquivo)
	local oPrtXlsx 		:= FwPrinterXlsx():New()
	Local nRow 	   		:= 1
	Local cCor 			:= "95B3D7"//"66FFFF"
	Local cArquivoFinal := ""
	Local nTotVazio	    := 0
	//Local nAbono        := nCasam := nExterno := nCurso := nBhoras := nHome := nVazio := nAtest := nComps := nDefeit := 0
	//Local nJurid        := nDecla := nEsque   := nInic  := nDias   := nDuInd:= 0
	Local nVazio := 0
	Local aCabec        := RetSP6()
	Local nPos          := 1


	cQuery := " 	SELECT FILIAL,CODIGO,DESCRICAO,MATRICULA,DATA_EVENTO,NOME,JUSTIFICATIVA,COD_JUS,SUM(SOMA_DURACAO) AS SOMA FROM (
	cQuery += "  SELECT
	cQuery += "      PC_FILIAL AS FILIAL,
	cQuery += "      SRA.RA_CC AS CODIGO,
	cQuery += "      CTT.CTT_DESC01 AS DESCRICAO,
	cQuery += "      PC_MAT AS MATRICULA,
	cQuery += "      CONVERT(DATE, PC_DATA, 103) AS DATA_EVENTO,
	cQuery += "      '' AS DATA_INICIO,
	cQuery += "      '' AS DATA_FIM,
	cQuery += "      SRA.RA_NOME AS NOME,
	cQuery += "      SP6.P6_DESC AS JUSTIFICATIVA,
	cQuery += "      SP6.P6_CODIGO AS COD_JUS,
	cQuery += "      SUM(PC_QUANTC) AS SOMA_DURACAO
	cQuery += "  FROM "+RETSQLNAME('SPC')+" SPC
	cQuery += "      INNER JOIN "+RETSQLNAME('SRA')+" SRA ON SRA.RA_MAT = SPC.PC_MAT AND SRA.RA_FILIAL = SPC.PC_FILIAL AND SRA.D_E_L_E_T_ <> '*'
	cQuery += "      INNER JOIN "+RETSQLNAME('CTT')+" CTT ON SRA.RA_CC = CTT.CTT_CUSTO AND SUBSTRING(SRA.RA_FILIAL,1,2) = CTT.CTT_FILIAL AND CTT.D_E_L_E_T_ <> '*'
	cQuery += "      INNER JOIN "+RETSQLNAME('SP9')+" SP9 ON SPC.PC_PD = SP9.P9_CODIGO  AND  P9_CODIGO = '010' AND SP9.D_E_L_E_T_ <> '*'
	cQuery += "      LEFT  JOIN "+RETSQLNAME('SP6')+" SP6 ON SPC.PC_ABONO = SP6.P6_CODIGO AND SP6.D_E_L_E_T_ <> '*'
	cQuery += "  WHERE SPC.D_E_L_E_T_ <> '*'
	cQuery += "      AND PC_FILIAL BETWEEN	 '"+MV_PAR01+"' AND '"+MV_PAR02+"'
	cQuery += "      AND RA_CC BETWEEN 		 '"+MV_PAR03+"' AND '"+MV_PAR04+"'
	cQuery += "      AND PC_MAT BETWEEN 	 '"+MV_PAR05+"' AND '"+MV_PAR06+"'
	cQuery += "      AND PC_DATA BETWEEN 	 '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"'
	cQuery += "  GROUP BY PC_FILIAL, PC_MAT, SRA.RA_NOME, SRA.RA_CC, CTT.CTT_DESC01, PC_DATA, P6_DESC, SP6.P6_CODIGO
	cQuery += " UNION ALL
	cQuery += " SELECT
	cQuery += "      PH_FILIAL AS FILIAL,
	cQuery += "      SRA.RA_CC AS CODIGO,
	cQuery += "      CTT.CTT_DESC01 AS DESCRICAO,
	cQuery += "      PH_MAT AS MATRICULA,
	cQuery += "      CONVERT(DATE, PH_DATA, 103) AS DATA_EVENTO,
	cQuery += "      '' AS DATA_INICIO,
	cQuery += "      '' AS DATA_FIM,
	cQuery += "      SRA.RA_NOME AS NOME,
	cQuery += "      SP6.P6_DESC AS JUSTIFICATIVA,
	cQuery += "      SP6.P6_CODIGO AS COD_JUS,
	cQuery += "      SUM(PH_QUANTC) AS SOMA_DURACAO
	cQuery += "  FROM "+RETSQLNAME('SPH')+" SPH
	cQuery += "      INNER JOIN "+RETSQLNAME('SRA')+" SRA ON SRA.RA_MAT = SPH.PH_MAT AND SRA.RA_FILIAL = SPH.PH_FILIAL AND SRA.D_E_L_E_T_ <> '*'
	cQuery += "      INNER JOIN "+RETSQLNAME('CTT')+" CTT ON SRA.RA_CC = CTT.CTT_CUSTO AND SUBSTRING(SRA.RA_FILIAL,1,2) = CTT.CTT_FILIAL AND CTT.D_E_L_E_T_ <> '*'
	cQuery += "      INNER JOIN "+RETSQLNAME('SP9')+" SP9 ON SPH.PH_PD = SP9.P9_CODIGO  AND  P9_CODIGO = '010' AND SP9.D_E_L_E_T_ <> '*'
	cQuery += "      LEFT  JOIN "+RETSQLNAME('SP6')+" SP6 ON SPH.PH_ABONO = SP6.P6_CODIGO AND SP6.D_E_L_E_T_ <> '*'
	cQuery += "  WHERE SPH.D_E_L_E_T_ <> '*'
	cQuery += "      AND PH_FILIAL BETWEEN  '"+MV_PAR01+"' AND '"+MV_PAR02+"'
	cQuery += "      AND RA_CC BETWEEN 		'"+MV_PAR03+"' AND '"+MV_PAR04+"'
	cQuery += "      AND PH_MAT BETWEEN 	'"+MV_PAR05+"' AND '"+MV_PAR06+"'
	cQuery += "      AND PH_DATA BETWEEN 	'"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"'
	cQuery += "  GROUP BY PH_FILIAL, PH_MAT, SRA.RA_NOME, SRA.RA_CC, CTT.CTT_DESC01, PH_DATA, P6_DESC, SP6.P6_CODIGO
	cQuery += " UNION ALL
	cQuery += " SELECT
	cQuery += "      SR8.R8_FILIAL AS FILIAL, 
	cQuery += "      SRA.RA_CC AS CODIGO,  
	cQuery += "      CTT.CTT_DESC01 AS DESCRICAO,  
	cQuery += "      SR8.R8_MAT AS MATRICULA,
	cQuery += "       CONVERT(DATE, SR8.R8_DATA, 103) AS DATA_EVENTO,
    cQuery += "       SR8.R8_DATAINI  AS DATA_INICIO,
    cQuery += "       SR8.R8_DATAFIM AS DATA_FIM,
    cQuery += "       SRA.RA_NOME  AS NOME,  
	cQuery += "      RCM.RCM_DESCRI AS COD_JUS,
 	cQuery += "      SR8.R8_TIPOAFA  AS JUSTIFICATIVA,
	cQuery += "      SUM(SR8.R8_DURACAO)  AS SOMA_DURACAO
	cQuery += "  FROM "+RETSQLNAME('SR8')+" SR8  
	cQuery += "      INNER JOIN "+RETSQLNAME('SRA')+" SRA ON SRA.RA_MAT = SR8.R8_MAT AND SRA.RA_FILIAL = SR8.R8_FILIAL AND SRA.D_E_L_E_T_ <> '*'
	cQuery += "      INNER JOIN "+RETSQLNAME('CTT')+" CTT ON SRA.RA_CC = CTT.CTT_CUSTO AND SUBSTRING(SRA.RA_FILIAL,1,2) = CTT.CTT_FILIAL AND CTT.D_E_L_E_T_ <> '*'  
    cQuery += "      INNER JOIN "+RETSQLNAME('RCM')+" RCM ON RCM.RCM_FILIAL =SUBSTRING(SR8.R8_FILIAL,1,2) AND RCM.RCM_TIPO=SR8.R8_TIPOAFA  AND RCM.D_E_L_E_T_ <> '*'  
	cQuery += "  WHERE SR8.D_E_L_E_T_ <> '*' 
	cQuery += "      AND SR8.R8_FILIAL BETWEEN	 '"+MV_PAR01+"' AND '"+MV_PAR02+"'
	cQuery += "      AND RA_CC BETWEEN 			 '"+MV_PAR03+"' AND '"+MV_PAR04+"'
	cQuery += "      AND SR8.R8_MAT BETWEEN 	 '"+MV_PAR05+"' AND '"+MV_PAR06+"'
	cQuery += "      AND ( SR8.R8_DATAINI BETWEEN  '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"' OR SR8.R8_DATAFIM BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"')
    cQuery += "     GROUP BY SR8.R8_FILIAL, SR8.R8_MAT,SR8.R8_TIPOAFA, SRA.RA_NOME, SRA.RA_CC, CTT.CTT_DESC01, SR8.R8_DATAINI,SR8.R8_DATAFIM,RCM.RCM_DESCRI,SR8.R8_DATA
	cQuery +="   	UNION ALL
	cQuery +="  SELECT SP2.P2_FILIAL AS FILIAL, '' AS CODIGO, '' as DESCRICAO, SP2.P2_MAT AS MATRICULA, SP2.P2_DATA AS DATA_EVENTO, SP2.P2_DATA AS DATA_INICIO, SP2.P2_DATAATE AS DATA_FIM, SRA.RA_NOME AS NOME, SP2.P2_MOTIVO AS JUSTIFICATIVA,'' AS COD_JUS, '' AS SOMA_DURACAO
	cQuery +=" 	FROM SP2010 SP2
	cQuery +=" 	INNER JOIN SRA010 SRA ON SRA.RA_FILIAL = SP2.P2_FILIAL AND SRA.RA_MAT =SP2.P2_MAT AND SRA.D_E_L_E_T_ <> '*'
	cQuery +=" WHERE SP2.D_E_L_E_T_ <> '*'
	cQuery +="  AND SP2.P2_FILIAL 	BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'
	cQuery +="  AND SP2.P2_MAT      BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
	cQuery +="  AND (SP2.P2_DATA	BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"' OR SP2.P2_DATAATE	BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"')
	cQuery +=" GROUP BY SP2.P2_FILIAL,SP2.P2_MAT,SP2.P2_DATA,SP2.P2_DATAATE, SRA.RA_NOME,SP2.P2_MOTIVO,SP2.P2_DATA
	cQuery += " ) AS A
	cQuery += "  GROUP BY FILIAL,CODIGO,DESCRICAO,MATRICULA,DATA_EVENTO,NOME,JUSTIFICATIVA,COD_JUS
	cQuery += "  ORDER BY FILIAL,CODIGO,NOME
	
	MpSysOpenQuery(cQuery, "TE5")

	If TE5->(Eof())
		TE5->(DbCloseArea())
		Return Alert("Não foram encontrados registros, Por favor analise os parâmetros","Atenção")
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
	oPrtXlsx:SetColumnsWidth(7 , 7 , 15.5 	) // ocorrencia
	oPrtXlsx:SetColumnsWidth(8 , 8 , 14.33 	) // NAO JUSTIFICADA
	oPrtXlsx:SetColumnsWidth(9 , 10, 8.10 	) // abono|atestado
	oPrtXlsx:SetColumnsWidth(11, 11, 12.56 	) // compensacao
	oPrtXlsx:SetColumnsWidth(12, 12, 14.10 	) // banco de horas
	oPrtXlsx:SetColumnsWidth(13, 13, 8.10 	) // juridico
	oPrtXlsx:SetColumnsWidth(14, 15, 10 	) // casamento|declaracao
	oPrtXlsx:SetColumnsWidth(16, 16, 13  	) // esquecimento
	oPrtXlsx:SetColumnsWidth(17, 17, 8	 	) // inicio
	oPrtXlsx:SetColumnsWidth(18, 18, 16		) // defeito
	oPrtXlsx:SetColumnsWidth(19, 19, 15		) // externo
	oPrtXlsx:SetColumnsWidth(20, 20, 13.44	) // horas
	oPrtXlsx:SetColumnsWidth(21, 21, 12		) // dias

	oPrtXlsx:SetFont(cFont, 16, .F., .T., .F.) // seta o texto em negrito
	//oPrtXlsx:MergeCells(/*lin inicial*/nRow,/*col inicial*/1,/*lin final*/nRow+4,/*col final*/9)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	oPrtXlsx:MergeCells(/*lin inicial*/1,/*col inicial*/1,/*lin final*/1,/*col final*/21)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	oPrtXlsx:MergeCells(/*lin inicial*/2,/*col inicial*/1,/*lin final*/2,/*col final*/21)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	oPrtXlsx:MergeCells(/*lin inicial*/3,/*col inicial*/1,/*lin final*/3,/*col final*/21)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	oPrtXlsx:MergeCells(/*lin inicial*/4,/*col inicial*/1,/*lin final*/4,/*col final*/21)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	oPrtXlsx:MergeCells(/*lin inicial*/5,/*col inicial*/1,/*lin final*/5,/*col final*/21)// merge das celulas iniciais para o cabeÃ§alho do arquivo
	//oPrtXlsx:MergeCells(/*lin inicial*/6,/*col inicial*/1,/*lin final*/6,/*col final*/21)// merge das celulas iniciais para o cabeÃ§alho do arquivo

	oPrtXlsx:SetCellsFormat(cHorAliLeft, cVertAliCent, /*lWrapText*/.F., /*nRotation*/0, "000000", "FFFFFF", "" )
	oPrtXlsx:SetText(/*nRow*/1, /*nCol*/ 1, "RELATÓRIO DE FALTAS - CONSOLIDADO") // Texto em A1
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
	oPrtXlsx:SetText( nRow , /*nCol*/6 , "Tipo evento"      ) //-- 6
	oPrtXlsx:SetText( nRow , /*nCol*/7 , "Total ocorrencias") //-- 7
	oPrtXlsx:SetText( nRow , /*nCol*/8 , "Faltas nao just."	) //-- 8
	//Comentado para ser dinamico
	//oPrtXlsx:SetText( nRow , /*nCol*/9 , "Atestado"         ) //-- 9
	//oPrtXlsx:SetText( nRow , /*nCol*/10, "Abonado"          ) //-- 10
	//oPrtXlsx:SetText( nRow , /*nCol*/11, "Compensacao"      ) //-- 11
	//oPrtXlsx:SetText( nRow , /*nCol*/12, "Banco de horas"   ) //-- 12
	//oPrtXlsx:SetText( nRow , /*nCol*/13, "Juridico"         ) //-- 13
	//oPrtXlsx:SetText( nRow , /*nCol*/14, "Casamento"        ) //-- 14
	//oPrtXlsx:SetText( nRow , /*nCol*/15, "Declaracao"       ) //-- 15
	//oPrtXlsx:SetText( nRow , /*nCol*/16, "Esquecimento"     ) //-- 16
	//oPrtXlsx:SetText( nRow , /*nCol*/17, "Inicio"           ) //-- 17
	//oPrtXlsx:SetText( nRow , /*nCol*/18, "Ponto com defeito") //-- 18
	//oPrtXlsx:SetText( nRow , /*nCol*/19, "Servico externo" ) //-- 19
	

	//Atualizado para gerar os dados dinamicos
	For nPos := 1 To Len(aCabec)
		&('oPrtXlsx:SetText( nRow , ' + Alltrim(cValToChar(nPos + 8)) + ' , "' + Alltrim(aCabec[nPos,2]) + '"	)')
	Next
	//Fim

	oPrtXlsx:SetText( nRow , /*nCol*/nPos + 8, "Soma de horas"    ) //-- 20
	oPrtXlsx:SetText( nRow , /*nCol*/nPos + 9, "Soma de dias"     ) //-- 21

	//Inicializa as variaves
	For nPos := 1 To Len(aCabec)
		&("n" + Alltrim(aCabec[nPos,1]) + " := 0")
	Next
	//Fim
	
	oPrtXlsx:ResetCellsFormat()

	While TE5->(!Eof())
		oPrtXlsx:SetFont(cFont, 10, .F., .F., .F.) // seta o texto sem negrito
		
		If Empty(TE5->CODIGO)
			cCentr := Posicione("SRA",1,TE5->FILIAL + TE5->MATRICULA + TE5->NOME, "RA_CC")
			cCentro  := TE5->CODIGO
		Else 
			cCentro  := TE5->CODIGO
		Endif
        
		//nAtivos  := TE5->TOTAL_ATIVO
		nDuracao := 0
		nTotOc   := 0
		nTotDia  := 0
		nTotVazio:= 0 

		While TE5->(!Eof()) .And. cCentro == TE5->CODIGO

			If Empty(TE5->DESCRICAO) 
				cDescCC := Posicione("CTT",1,FWxFilial("CTT") + cCentr, "CTT_DESC01")
			Else 
				cDescCC  := TE5->DESCRICAO
			Endif
			//cDescCC:= Posicione("CTT",1,FWxFilial("CTT") + cCentro, "CTT_DESC01")
        	cMat   := TE5->MATRICULA
       		cNome  := AllTrim(TE5->NOME)
			nDias  := 0
			nDuInd := 0
			cJustificativa := TE5->JUSTIFICATIVA
			//nAbono := nCasam := nExterno := nCurso := nBhoras := nHome := nVazio := nAtest := nComps := nDefeit := 0
			//nJurid := nDecla := nEsque := nInic := 0
			nVazio := 0
			//Inicializa as variaves
			For nPos := 1 To Len(aCabec)
				&("n" + Alltrim(aCabec[nPos,1]) + " := 0")
			Next
			//Fim

			While TE5->(!Eof()) .And. cCentro == TE5->CODIGO .And. cMat == TE5->MATRICULA
				//IncProc("Produto "+AllTrim(TE5->CCUSTO))
				
				//Comentado para ficar dinamico
				/*
				Do Case
					Case TE5->COD_JUS == '060' //'ABONADO'
						nAbono++
					Case TE5->COD_JUS == '006' //'JURIDICO'
						nJurid++
					Case TE5->COD_JUS == '008' //'ATESTADO'
						nAtest++
					Case TE5->COD_JUS == '016' //'COMPENSACAO'
						nComps++
					Case TE5->COD_JUS == '014' //'CASAMENTO'
						nCasam++
					Case TE5->COD_JUS $ '018|020|019' .Or. TE5->JUSTIFICATIVA $ 'DECL'//'DECLARACAO'
						nDecla++
					Case TE5->COD_JUS == '051' //'EXTERNO'
						nExterno++
					Case TE5->COD_JUS == '047' //'PONTO COM DEFEITO'
						nDefeit++
					Case TE5->COD_JUS == '017' //'CURSO'
						nCurso++
					Case TE5->COD_JUS == '061' //'B.HORAS'
						nBhoras++
					Case TE5->COD_JUS == '028' //'ESQUECIMENTO'
						nEsque++
					Case TE5->COD_JUS == '057' //'HOME OFFICE'
						nHome++
					Case TE5->COD_JUS == '037' //'INICIO'
						nInic++
					Case Empty(TE5->COD_JUS) //'SEM JUSTIFICATIVA'
						nVazio++
				EndCase
				*/

	nPosCod := aScan(aCabec, {|x| x[1] == TE5->COD_JUS })
	If nPosCod > 0
		&("n" + Alltrim(aCabec[nPosCod,1]) + "++")
	Else
		nVazio++
	Endif

	nDuInd+=TE5->SOMA
	nDias++

	TE5->(DbSkip())
End

oPrtXlsx:SetCellsFormat(cHorAliCent, cVertAliCent, /*lWrapText*/.F.,/*nRotation*/0,"000000","FFFFFF","")
nRow++
oPrtXlsx:SetValue( nRow , /*nCol*/1 , TE5->FILIAL     			          )//-- 1
oPrtXlsx:SetValue( nRow , /*nCol*/2 , AllTrim(cCentr)	  		      	  )//-- 2
oPrtXlsx:SetValue( nRow , /*nCol*/3 , AllTrim(cDescCC)  				  )//-- 3
oPrtXlsx:SetValue( nRow , /*nCol*/4 , cMat			  			          )//-- 4
oPrtXlsx:SetValue( nRow , /*nCol*/5 , AllTrim(cNome)			          )//-- 5
oPrtXlsx:SetValue( nRow , /*nCol*/6 , iif(Empty(cJustificativa),"Banco de horas",AllTrim(cJustificativa)))//-- 6
oPrtXlsx:SetValue( nRow , /*nCol*/7 , nDias                   			  )//-- 7
oPrtXlsx:SetValue( nRow , /*nCol*/8 , nVazio  		          		      )//-- 8
//Comentado para gerar dinamicamente
//oPrtXlsx:SetValue( nRow , /*nCol*/9 , nAtest   	                  	  )//-- 9
//oPrtXlsx:SetValue( nRow , /*nCol*/10, nAbono                  		  )//-- 10
//oPrtXlsx:SetValue( nRow , /*nCol*/11, nComps                        	  )//-- 11
//oPrtXlsx:SetValue( nRow , /*nCol*/12, nBhoras                 		  )//-- 12
//oPrtXlsx:SetValue( nRow , /*nCol*/13, nJurid                        	  )//-- 13
//oPrtXlsx:SetValue( nRow , /*nCol*/14, nCasam                  		  )//-- 14
//oPrtXlsx:SetValue( nRow , /*nCol*/15, nDecla                        	  )//-- 15
//oPrtXlsx:SetValue( nRow , /*nCol*/16, nEsque                        	  )//-- 16
//oPrtXlsx:SetValue( nRow , /*nCol*/17, nInic                        	  )//-- 17
//oPrtXlsx:SetValue( nRow , /*nCol*/18, nDefeit                        	  )//-- 18
//oPrtXlsx:SetValue( nRow , /*nCol*/19, nExterno                		  )//-- 19
//oPrtXlsx:SetValue( nRow , /*nCol*/20, nDuInd                			  )//-- 20
//oPrtXlsx:SetValue( nRow , /*nCol*/21, nDias                   		  )//-- 21
//oPrtXlsx:SetValue( nRow , /*nCol*/22, ''                                )//-- 22

//Atualizado para gerar os dados dinamicos
For nPos := 1 To Len(aCabec)
	&("oPrtXlsx:SetValue( nRow , " + Alltrim(cValToChar(nPos + 8)) + " , n" + Alltrim(aCabec[nPos,1]) + ")")
Next
//Fim
oPrtXlsx:SetValue( nRow , /*nCol*/nPos + 8 , nDuInd   	                  	  )//-- 9
oPrtXlsx:SetValue( nRow , /*nCol*/nPos + 9 , nDias   	                  	  )//-- 9

nTotOc   += nDias
nTotDia  += nDias
nDuracao += nDuInd
nTotVazio+= nVazio
End

oPrtXlsx:SetFont(cFont, 10, .F., .T., .F.) // seta o texto em negrito
nRow++
oPrtXlsx:SetCellsFormat(cHorAliCent, cVertAliCent, /*lWrapText*/.F.,/*nRotation*/0,"000000",cCor,"")
oPrtXlsx:SetValue( nRow , /*nCol*/1 , ""     			   			   	 )//-- 1
oPrtXlsx:SetValue( nRow , /*nCol*/2 , ""            	  			   	 )//-- 2
oPrtXlsx:SetValue( nRow , /*nCol*/3 , "TOTAL "+AllTrim(cDescCC) 	   	 )//-- 3
oPrtXlsx:SetValue( nRow , /*nCol*/4 , ""							   	 )//-- 4
oPrtXlsx:SetValue( nRow , /*nCol*/5 , ""					  		   	 )//-- 5
oPrtXlsx:SetValue( nRow , /*nCol*/6 , ""							   	 )//-- 6
oPrtXlsx:SetValue( nRow , /*nCol*/7 , nTotOc						   	 )//-- 7
oPrtXlsx:SetValue( nRow , /*nCol*/8 , nTotVazio						   	 )//-- 8
//oPrtXlsx:SetValue( nRow , /*nCol*/9 , ''                               )//-- 9
//oPrtXlsx:SetValue( nRow , /*nCol*/10, ''                               )//-- 10
//oPrtXlsx:SetValue( nRow , /*nCol*/11, ''                               )//-- 11
//oPrtXlsx:SetValue( nRow , /*nCol*/12, ''                               )//-- 12
//oPrtXlsx:SetValue( nRow , /*nCol*/13, ''                               )//-- 13
//oPrtXlsx:SetValue( nRow , /*nCol*/14, ''                               )//-- 14
//oPrtXlsx:SetValue( nRow , /*nCol*/15, ''                               )//-- 15
//oPrtXlsx:SetValue( nRow , /*nCol*/16, ''                               )//-- 16
//oPrtXlsx:SetValue( nRow , /*nCol*/17, ''                               )//-- 17
//oPrtXlsx:SetValue( nRow , /*nCol*/18, ''                               )//-- 18
//oPrtXlsx:SetValue( nRow , /*nCol*/19, ''                               )//-- 19
//oPrtXlsx:SetValue( nRow , /*nCol*/20, ''                               )//-- 20
//oPrtXlsx:SetValue( nRow , /*nCol*/21, ''                               )//-- 21
For nPos := 1 To Len(aCabec)
	&("oPrtXlsx:SetValue( nRow , " + Alltrim(cValToChar(nPos + 8)) + " , '' )")
Next

nPos := nPos + 8

oPrtXlsx:SetValue( nRow , /*nCol*/nPos, nDuracao                         )//-- 22
oPrtXlsx:SetValue( nRow , /*nCol*/nPos + 1, nTotDia                      )//-- 23
//oPrtXlsx:SetValue( nRow , /*nCol*/22, ''                               )//-- 22
End

TE5->(DbCloseArea())

oPrtXlsx:toXlsx()
cArquivoFinal := StrTran(cArquivo, ".rel", ".xlsx")
If !IsBlind()
	If File(cPathLocal+"RelFaltasConso.rel")
		FErase(cPathLocal+"RelFaltasConso.rel")
	EndIf
	CpyS2T(cArquivoFinal, cPathLocal)
	cArquivoFinal := StrTran(cArquivoFinal, cPath, cPathLocal)
EndIf
FErase(cArquivo)

Return cArquivoFinal

//*****************************************************************************
// Função   : RetSP6  - Retorna os dados da tabela SP6 para geração do excel  |
// Modulo   : SIGAGPE - Gestão de pessoal                         	          |
// Fonte    : RelFal01.prw                                                    |
// ---------+--------------------------+--------------------------------------+
// Data     | Autor                    | Descricao                            |
// ---------+---------------+----------+--------------------------------------+
// 11/03/23 | Rivaldo G.    |Cod.ERP   | Busca os dados e monta o Excel 	  |
//*****************************************************************************
Static Function RetSP6()
	Local cQuery := ""
	Local aCabec := {}

	cQuery += " SELECT * FROM (
	cQuery += " SELECT  DISTINCT P6_CODIGO AS CODIGO, P6_DESC AS DESCRICAO
	cQuery += " FROM " + RetSqlName("SP6")+" SP6
	cQuery += " INNER JOIN " + RetSqlName("SPC")+" SPC ON SPC.PC_ABONO = SP6.P6_CODIGO AND SPC.D_E_L_E_T_ <> '*'
	cQuery += " WHERE SP6.D_E_L_E_T_ <> '*'
	cQuery += " UNION ALL
	cQuery += " SELECT  DISTINCT P6_CODIGO AS CODIGO, P6_DESC AS DESCRICAO
	cQuery += " FROM " + RetSqlName("SP6")+" SP6
	cQuery += " INNER JOIN " + RetSqlName("SPH")+" SPH ON SPH.PH_ABONO = SP6.P6_CODIGO AND SPH.D_E_L_E_T_ <> '*'
	cQuery += " WHERE SP6.D_E_L_E_T_ <> '*'
	cQuery += " UNION ALL
	cQuery += " SELECT  SR8.R8_TIPOAFA  AS CODIGO, RCM.RCM_DESCRI AS DESCRICAO
	cQuery += " FROM " + RetSqlName("SR8")+" SR8
	cQuery += " INNER JOIN " + RetSqlName("RCM")+" RCM ON RCM.RCM_FILIAL = SUBSTRING(SR8.R8_FILIAL,1,2) AND RCM.RCM_TIPO = SR8.R8_TIPOAFA  AND RCM.D_E_L_E_T_ <> '*'
	cQuery += " WHERE SR8.D_E_L_E_T_ <> '*'
	cQuery += " ) AS B
	cQuery += " GROUP BY CODIGO, DESCRICAO
	MpSysOpenQuery(cQuery, "TP6")

	While TP6->(!EOF())
		AADD(aCabec,{TP6->CODIGO, TP6->DESCRICAO})
		TP6->(DbSkip())
	End
Return aCabec


//Query com data inicial e data fim
/* SELECT * FROM (
	SELECT 
	     PC_FILIAL AS FILIAL, 
	     SRA.RA_CC AS CODIGO,  
	     CTT.CTT_DESC01 AS DESCRICAO, 
	     PC_MAT AS MATRICULA,
	     CONVERT(DATE, PC_DATA, 103) AS DATA_EVENTO,
         '' AS DATA_INICIO,
         '' AS DATA_FIM, 
	     SRA.RA_NOME AS NOME,  
	     SP6.P6_DESC AS JUSTIFICATIVA, 
	     SP6.P6_CODIGO AS COD_JUS, 
	     SUM(PC_QUANTC) AS SOMA_DURACAO
	 FROM SPC010 SPC 
	     INNER JOIN SRA010 SRA ON SRA.RA_MAT = SPC.PC_MAT AND SRA.RA_FILIAL = SPC.PC_FILIAL AND SRA.D_E_L_E_T_ <> '*'
	     INNER JOIN CTT010 CTT ON SRA.RA_CC = CTT.CTT_CUSTO AND SUBSTRING(SRA.RA_FILIAL,1,2) = CTT.CTT_FILIAL AND CTT.D_E_L_E_T_ <> '*'  
	     INNER JOIN SP9010 SP9 ON SPC.PC_PD = SP9.P9_CODIGO  AND  P9_CODIGO = '010' AND SP9.D_E_L_E_T_ <> '*'
	     LEFT  JOIN SP6010 SP6 ON SPC.PC_ABONO = SP6.P6_CODIGO AND SP6.D_E_L_E_T_ <> '*' 
	 WHERE SPC.D_E_L_E_T_ <> '*' 
	     AND PC_FILIAL BETWEEN '' AND 'ZZZZ' 
	     AND RA_CC BETWEEN '' AND 'ZZZZZ' 
	     AND PC_MAT BETWEEN '' AND 'zzzz' 
	     AND PC_DATA BETWEEN '20240201' AND '20240327'                                                                                
	 GROUP BY PC_FILIAL, PC_MAT, SRA.RA_NOME, SRA.RA_CC, CTT.CTT_DESC01, PC_DATA, P6_DESC, SP6.P6_CODIGO
	
	UNION ALL
	
	SELECT
	     PH_FILIAL AS FILIAL, 
	     SRA.RA_CC AS CODIGO,  
	     CTT.CTT_DESC01 AS DESCRICAO, 
	     PH_MAT AS MATRICULA,
	     CONVERT(DATE, PH_DATA, 103) AS DATA_EVENTO, 
         '' AS DATA_INICIO,  
         '' AS DATA_FIM, 
	     SRA.RA_NOME AS NOME,  
	     SP6.P6_DESC AS JUSTIFICATIVA, 
	     SP6.P6_CODIGO AS COD_JUS, 
	     SUM(PH_QUANTC) AS SOMA_DURACAO
	 FROM SPH010 SPH 
	     INNER JOIN SRA010 SRA ON SRA.RA_MAT = SPH.PH_MAT AND SRA.RA_FILIAL = SPH.PH_FILIAL AND SRA.D_E_L_E_T_ <> '*'
	     INNER JOIN CTT010 CTT ON SRA.RA_CC = CTT.CTT_CUSTO AND SUBSTRING(SRA.RA_FILIAL,1,2) = CTT.CTT_FILIAL AND CTT.D_E_L_E_T_ <> '*'  
	     INNER JOIN SP9010 SP9 ON SPH.PH_PD = SP9.P9_CODIGO  AND  P9_CODIGO = '010' AND SP9.D_E_L_E_T_ <> '*'
	     LEFT  JOIN SP6010 SP6 ON SPH.PH_ABONO = SP6.P6_CODIGO AND SP6.D_E_L_E_T_ <> '*' 
	 WHERE SPH.D_E_L_E_T_ <> '*' 
	     AND PH_FILIAL BETWEEN '' AND 'ZZZZ' 
	     AND RA_CC BETWEEN '' AND 'ZZZZZ' 
	     AND PH_MAT BETWEEN '' AND 'zzzz' 
	     AND PH_DATA BETWEEN '20240201' AND '20240327'                                                                               
	 GROUP BY PH_FILIAL, PH_MAT, SRA.RA_NOME, SRA.RA_CC, CTT.CTT_DESC01, PH_DATA, P6_DESC, SP6.P6_CODIGO

	UNION ALL

	SELECT
	     SR8.R8_FILIAL AS FILIAL, 
	     SRA.RA_CC AS CODIGO,  
	     CTT.CTT_DESC01 AS DESCRICAO,  
	     SR8.R8_MAT AS MATRICULA,
	      CONVERT(DATE, SR8.R8_DATA, 103) AS DATA_EVENTO,
              SR8.R8_DATAINI  AS DATA_INICIO,
              SR8.R8_DATAFIM AS DATA_FIM,
             SRA.RA_NOME  AS NOME,  
	     RCM.RCM_DESCRI AS COD_JUS,
 	     SR8.R8_TIPOAFA  AS JUSTIFICATIVA,
	     SUM(SR8.R8_DURACAO)  AS SOMA_DURACAO
	 FROM SR8010 SR8  
	     INNER JOIN SRA010 SRA ON SRA.RA_MAT = SR8.R8_MAT AND SRA.RA_FILIAL = SR8.R8_FILIAL AND SRA.D_E_L_E_T_ <> '*'
	     INNER JOIN CTT010 CTT ON SRA.RA_CC = CTT.CTT_CUSTO AND SUBSTRING(SRA.RA_FILIAL,1,2) = CTT.CTT_FILIAL AND CTT.D_E_L_E_T_ <> '*'  
         INNER JOIN RCM010 RCM ON RCM.RCM_FILIAL =SUBSTRING(SR8.R8_FILIAL,1,2) AND RCM.RCM_TIPO=SR8.R8_TIPOAFA  AND RCM.D_E_L_E_T_ <> '*'  
	 WHERE SR8.D_E_L_E_T_ <> '*' 
	     AND SR8.R8_FILIAL BETWEEN '' AND 'ZZZZ' 
	     AND RA_CC BETWEEN '' AND 'ZZZZZ' 
	     AND SR8.R8_MAT BETWEEN '' AND 'zzzz' 
	     AND SR8.R8_DATAINI BETWEEN '20240201' AND '20240327' 

        GROUP BY SR8.R8_FILIAL, SR8.R8_MAT,SR8.R8_TIPOAFA, SRA.RA_NOME, SRA.RA_CC, CTT.CTT_DESC01, SR8.R8_DATAINI,SR8.R8_DATAFIM,RCM.RCM_DESCRI,SR8.R8_DATA
) AS A
 ORDER BY FILIAL, CODIGO,MATRICULA
 */
