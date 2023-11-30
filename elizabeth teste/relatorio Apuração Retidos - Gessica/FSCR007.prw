#Include "Totvs.ch"
#Include "RPTDef.ch"
#include "TBICONN.ch"

/*/{Protheus.doc} FSCR007
Fonte para exibir Relatório de Apuração Retidos
@type function
@author Michel Rocha 
@since 30/	01/2023
@return 
/*/

User Function FSCR007()
	Local aPergs	 := {}
	Private oExcel  := Nil
	Private oSecCab	 := Nil

	aAdd(aPergs,{1,"De Filial  ",Space(6),"","","SM0","",50,.F.})                   //MV_PAR01
	aAdd(aPergs,{1,"Data de Digitação de: ",Ctod(Space(8)),"","","","",50,.F.})		//MV_PAR02
	aAdd(aPergs,{1,"Data de Digitação ate: ",Ctod(Space(8)),"","","","",50,.F.})	//MV_PAR03
	aAdd(aPergs,{1,"Data de Vencimento de: ",Ctod(Space(8)),"","","","",50,.F.})	//MV_PAR04
	aAdd(aPergs,{1,"Data de Vencimento ate: ",Ctod(Space(8)),"","","","",50,.F.})	//MV_PAR05
	If !ParamBox(aPergs,"Informe os Parametros ")
		Return
	EndIf
	MsAguarde({|| oExcel := geraExecel()}, "Aguarde...", "Processando Registros...")
	FWAlertSuccess("Excel gerado.","Processo concluido")
Return
Static Function geraExecel()
	Local oExcel 	As Object
	Local nX		As Numeric
	Local cArquivo    := ""
	Local cQuery	 := ""
	Local cQery	 := ""
	Local cQrye	 := ""
	Local cFor := ""
	Local aDados	 := {}
	Local aDados1	 := {}
	Local aDados2	 := {}
	Local oExib

	cQuery := "	SELECT D1_FILIAL, D1_DOC, A2_COD, D1_COD, E2_NATUREZ,A2_CGC, A2_NOME,D1_TOTAL, D1_EMISSAO, D1_DTDIGIT, D1_BASECSL, D1_VALINS,            "
	cQuery += " D1_BASEINS,	D1_BASECOF,	D1_BASEPIS,	D1_BASEIRR,	D1_VALCSL,	D1_VALCOF,	D1_VALPIS,	D1_VALIRR , E2_CODRET ,E2_VENCREA ,E2_PREFIXO, E2_TIPO               "
	cQuery += "	FROM " +RetSqlName("SD1") + " SD1 "
	cQuery += "	INNER JOIN " +RetSqlName("SA2") + " SA2  ON SD1.D1_FORNECE = SA2.A2_COD AND SD1.D1_LOJA = A2_LOJA           "
	cQuery += "	INNER JOIN " +RetSqlName("SE2") + " SE2  ON SD1.D1_FILIAL = SE2.E2_FILIAL AND SD1.D1_DOC = SE2.E2_NUM  AND SD1.D1_SERIE = SE2.E2_PREFIXO AND SD1.D1_FORNECE  = SE2.E2_FORNECE AND SD1.D1_LOJA  = SE2.E2_LOJA	"
	cQuery += " AND SD1.D1_FORNECE = SE2.E2_FORNECE AND  SD1.D1_FILIAL = SE2.E2_FILIAL 										"
	cQuery += "	WHERE SD1.D1_DTDIGIT BETWEEN '"+dTos(MV_PAR02)+"' AND '"+dTos(MV_PAR03)+"'                                  "
	cQuery += " AND SD1.D1_FILIAL = '"+MV_PAR01+"'                                                                      "
	cQuery += "	AND SD1.D_E_L_E_T_ <> '*'    "
	cQuery += "	AND SA2.D_E_L_E_T_ <> '*'    "
	cQuery += "	AND SE2.D_E_L_E_T_ <> '*'    "

	MpSysOpenQuery(cQuery,"cQry")
	While cQry->(!Eof())
		aAdd(aDados			,;
			{cQry->D1_FILIAL,;
			cQry->D1_DOC    ,;
			cQry->A2_COD    ,;
			cQry->A2_CGC    ,;
			cQry->A2_NOME   ,;
			cQry->E2_CODRET ,;
			cQry->D1_TOTAL  ,;
			cQry->D1_EMISSAO,;
			cQry->D1_DTDIGIT,;
			cQry->D1_BASECSL,;
			cQry->D1_BASECOF,;
			cQry->D1_BASEPIS,;
			cQry->D1_BASEIRR,;
			cQry->D1_VALCSL ,;
			cQry->D1_VALCOF ,;
			cQry->D1_VALPIS ,;
			cQry->D1_VALIRR ,;
			cQry->D1_BASEINS,;
			cQry->D1_VALINS ,;
			cQry->E2_PREFIXO,;
			cQry->E2_NATUREZ,;
			cQry->E2_VENCREA,;
			cQry->E2_TIPO  })
		cQry->(DbSkip())
	End
	cQry->(DbCloseArea())
	oExcel := FwMsExcelXlsx():New()

	// primeira aba do relatorio  //
	oExcel:AddWorkSheet("0588")
	oExcel:AddTable("0588","RELATORIO DE APURAÇÃO RETIDOS ")
	oExcel:AddColumn("0588","RELATORIO DE APURAÇÃO RETIDOS ","FILIAL",2,1)//1 ( 1-General,2-Number,3-Monetário,4-DateTime )
	oExcel:AddColumn("0588","RELATORIO DE APURAÇÃO RETIDOS ","DOCUMENTO",2,1)//2
	oExcel:AddColumn("0588","RELATORIO DE APURAÇÃO RETIDOS ","COD. FORNECEDOR",2,1)//2
	oExcel:AddColumn("0588","RELATORIO DE APURAÇÃO RETIDOS ","CNPJ",2,1)//2
	oExcel:AddColumn("0588","RELATORIO DE APURAÇÃO RETIDOS ","NOME FORNECEDOR",2,1)//2
	oExcel:AddColumn("0588","RELATORIO DE APURAÇÃO RETIDOS ","COD. RECEITA",2,1)//2
	oExcel:AddColumn("0588","RELATORIO DE APURAÇÃO RETIDOS ","VLR. TOTAL",2,2)//2
	oExcel:AddColumn("0588","RELATORIO DE APURAÇÃO RETIDOS ","DT. EMISSÃO",2,1)//2
	oExcel:AddColumn("0588","RELATORIO DE APURAÇÃO RETIDOS ","DT. DIGITAÇÃO",2,1)//2
	oExcel:AddColumn("0588","RELATORIO DE APURAÇÃO RETIDOS ","BASE DE IRRF",2,2)//2
	oExcel:AddColumn("0588","RELATORIO DE APURAÇÃO RETIDOS ","VALOR IRRF",2,2)//2

	For nx := 1 to len(aDados)
		If ALLTRIM(aDados[nx,6]) == "0588"
			oExcel:AddRow("0588","RELATORIO DE APURAÇÃO RETIDOS ",;
				{aDados[nx,1],;
				aDados[nx,2],;
				aDados[nx,3],;
				aDados[nx,4],;
				aDados[nx,5],;
				aDados[nx,6],;
				aDados[nx,7],;
				STOD(aDados[nx,8]),;
				STOD(aDados[nx,9]),;
				aDados[nx,13],;
				aDados[nx,17]})
		EndIf
	Next nx

	// segunda aba do relatorio  //
	oExcel:AddWorkSheet("1708")
	oExcel:AddTable("1708","RELATORIO DE APURAÇÃO RETIDOS ")
	oExcel:AddColumn("1708","RELATORIO DE APURAÇÃO RETIDOS ","FILIAL",2,1)//1 ( 1-General,2-Number,3-Monetário,4-DateTime )
	oExcel:AddColumn("1708","RELATORIO DE APURAÇÃO RETIDOS ","DOCUMENTO",2,1)//2
	oExcel:AddColumn("1708","RELATORIO DE APURAÇÃO RETIDOS ","COD. FORNECEDOR",2,1)//2
	oExcel:AddColumn("1708","RELATORIO DE APURAÇÃO RETIDOS ","CNPJ",2,1)//2
	oExcel:AddColumn("1708","RELATORIO DE APURAÇÃO RETIDOS ","NOME FORNECEDOR",2,1)//2
	oExcel:AddColumn("1708","RELATORIO DE APURAÇÃO RETIDOS ","COD. RECEITA",2,1)//2
	oExcel:AddColumn("1708","RELATORIO DE APURAÇÃO RETIDOS ","VLR. TOTAL",2,2)//2
	oExcel:AddColumn("1708","RELATORIO DE APURAÇÃO RETIDOS ","DT. EMISSÃO",2,1)//2
	oExcel:AddColumn("1708","RELATORIO DE APURAÇÃO RETIDOS ","DT. DIGITAÇÃO",2,1)//2
	oExcel:AddColumn("1708","RELATORIO DE APURAÇÃO RETIDOS ","BASE DE IRRF",2,2)//2
	oExcel:AddColumn("1708","RELATORIO DE APURAÇÃO RETIDOS ","VALOR IRRF",2,2)//2
	For nx := 1 to len(aDados)
		If aDados[nx,6] == "1708"
			oExcel:AddRow("1708","RELATORIO DE APURAÇÃO RETIDOS ",;
				{aDados[nx,1],;
				aDados[nx,2],;
				aDados[nx,3],;
				aDados[nx,4],;
				aDados[nx,5],;
				aDados[nx,6],;
				aDados[nx,7],;
				STOD(aDados[nx,8]),;
				STOD(aDados[nx,9]),;
				aDados[nx,13],;
				aDados[nx,17]})

		EndIf
	Next nx
	cQrye += "SELECT D1_FILIAL, D1_DOC, A2_COD, D1_COD,A2_CGC, A2_NOME,D1_TOTAL, D1_EMISSAO, D1_DTDIGIT,	D1_BASEIRR,	D1_VALIRR "
	cQrye += "FROM " +RetSqlName("SD1") + " SD1	"
	cQrye += "INNER JOIN " +RetSqlName("SA2") + " SA2  ON SD1.D1_FORNECE = SA2.A2_COD AND SD1.D1_LOJA = A2_LOJA  "
	cQrye += "WHERE SD1.D1_DTDIGIT BETWEEN '"+dTos(MV_PAR02)+"' AND '"+dTos(MV_PAR03)+"' "
	cQrye += "AND SD1.D1_FILIAL = '"+MV_PAR01+"'  "
	cQrye += "AND SD1.D_E_L_E_T_ <> '*'    "
	cQrye += "AND SA2.D_E_L_E_T_ <> '*'   "
	cQrye += "AND  D1_COD = 'SV000022001001' "

	MpSysOpenQuery(cQrye,"cQre")
	While cQre->(!Eof())
		aAdd(aDados2		,;
			{cQre->D1_FILIAL,;
			cQre->D1_DOC    ,;
			cQre->A2_COD    ,;
			cQre->A2_CGC    ,;
			cQre->A2_NOME   ,;
			cQre->D1_TOTAL  ,;
			cQre->D1_EMISSAO,;
			cQre->D1_DTDIGIT,;
			cQre->D1_BASEIRR,;
			cQre->D1_VALIRR })
		cQre->(DbSkip())
	End
	cQre->(DbCloseArea())

	// terceira aba do relatorio //
	oExcel:AddWorkSheet("8045")
	oExcel:AddTable("8045","RELATORIO DE APURAÇÃO RETIDOS ")
	oExcel:AddColumn("8045","RELATORIO DE APURAÇÃO RETIDOS ","FILIAL",2,1)//1 ( 1-General,2-Number,3-Monetário,4-DateTime )
	oExcel:AddColumn("8045","RELATORIO DE APURAÇÃO RETIDOS ","DOCUMENTO",2,1)//2
	oExcel:AddColumn("8045","RELATORIO DE APURAÇÃO RETIDOS ","COD. FORNECEDOR",2,1)//2
	oExcel:AddColumn("8045","RELATORIO DE APURAÇÃO RETIDOS ","CNPJ",2,1)//2
	oExcel:AddColumn("8045","RELATORIO DE APURAÇÃO RETIDOS ","NOME FORNECEDOR",2,1)//2
	//oExcel:AddColumn("8045","RELATORIO DE APURAÇÃO RETIDOS ","COD. RECEITA",2,1)//2
	oExcel:AddColumn("8045","RELATORIO DE APURAÇÃO RETIDOS ","VLR. TOTAL",2,2)//2
	oExcel:AddColumn("8045","RELATORIO DE APURAÇÃO RETIDOS ","DT. EMISSÃO",2,1)//2
	oExcel:AddColumn("8045","RELATORIO DE APURAÇÃO RETIDOS ","DT. DIGITAÇÃO",2,1)//2
	oExcel:AddColumn("8045","RELATORIO DE APURAÇÃO RETIDOS ","BASE DE IRRF",2,2)//2
	oExcel:AddColumn("8045","RELATORIO DE APURAÇÃO RETIDOS ","VALOR IRRF",2,2)//2
	For nx := 1 to len(aDados2)
		If aDados2[nx,9] > 0 .OR. aDados2[nx,10] > 0
			oExcel:AddRow("8045","RELATORIO DE APURAÇÃO RETIDOS ",;
				{aDados2[nx,1],;
				aDados2[nx,2],;
				aDados2[nx,3],;
				aDados2[nx,4],;
				aDados2[nx,5],;
				aDados2[nx,6],;
				STOD(aDados2[nx,7]),;
				STOD(aDados2[nx,8]),;
				aDados2[nx,9],;
				aDados2[nx,10]})
		EndIf
	Next nx

	// quarta aba do relatorio//
	oExcel:AddWorkSheet("9385")
	oExcel:AddTable("9385","RELATORIO DE APURAÇÃO RETIDOS ")
	oExcel:AddColumn("9385","RELATORIO DE APURAÇÃO RETIDOS ","FILIAL",2,1)//1 ( 1-General,2-Number,3-Monetário,4-DateTime )
	oExcel:AddColumn("9385","RELATORIO DE APURAÇÃO RETIDOS ","DOCUMENTO",2,1)//2
	oExcel:AddColumn("9385","RELATORIO DE APURAÇÃO RETIDOS ","COD. FORNECEDOR",2,1)//2
	oExcel:AddColumn("9385","RELATORIO DE APURAÇÃO RETIDOS ","CNPJ",2,1)//2
	oExcel:AddColumn("9385","RELATORIO DE APURAÇÃO RETIDOS ","NOME FORNECEDOR",2,1)//2
	oExcel:AddColumn("9385","RELATORIO DE APURAÇÃO RETIDOS ","COD. RECEITA",2,1)//2
	oExcel:AddColumn("9385","RELATORIO DE APURAÇÃO RETIDOS ","VLR. TOTAL",2,2)//2
	oExcel:AddColumn("9385","RELATORIO DE APURAÇÃO RETIDOS ","DT. EMISSÃO",2,1)//2
	oExcel:AddColumn("9385","RELATORIO DE APURAÇÃO RETIDOS ","DT. DIGITAÇÃO",2,1)//2
	oExcel:AddColumn("9385","RELATORIO DE APURAÇÃO RETIDOS ","BASE DE IRRF",2,2)//2
	oExcel:AddColumn("9385","RELATORIO DE APURAÇÃO RETIDOS ","VALOR IRRF",2,2)//2
	For nx := 1 to len(aDados)
		If aDados[nx,6] == "9385"
			oExcel:AddRow("9385","RELATORIO DE APURAÇÃO RETIDOS ",;
				{aDados[nx,1],;
				aDados[nx,2],;
				aDados[nx,3],;
				aDados[nx,4],;
				aDados[nx,5],;
				aDados[nx,6],;
				aDados[nx,7],;
				STOD(aDados[nx,8]),;
				STOD(aDados[nx,9]),;
				aDados[nx,13],;
				aDados[nx,17]})
		EndIf
	Next nx

	cQery := "	SELECT DISTINCT D1_FILIAL, D1_DOC, D1_COD,D1_TOTAL, D1_EMISSAO, D1_DTDIGIT, D1_BASECSL,             "
	cQery += "  D1_BASECOF, D1_BASEPIS,	D1_VALCSL,	D1_VALCOF ,	D1_VALPIS , E2_CODRET ,E2_VENCREA , E2_TIPO , E2_TITPAI              "
	cQery += "	FROM " +RetSqlName("SE2") + " SE2 "
	cQery += "	INNER JOIN " +RetSqlName("SD1") + " SD1  ON SD1.D1_FILIAL = SE2.E2_FILIAL AND SD1.D1_DOC = SE2.E2_NUM  AND SD1.D1_SERIE = SE2.E2_PREFIXO          "
	cQery += "	WHERE SE2.E2_VENCREA BETWEEN '"+dTos(MV_PAR04)+"' AND '"+dTos(MV_PAR05)+"'                                  "                               "
	cQery += "  AND SE2.E2_FILIAL = '"+MV_PAR01+"'                                                                       "
	cQery += "  AND SE2.E2_TIPO = 'TX'                                                                                "
	cQery += "  AND SE2.E2_CODRET = '5952'                                                                                 "
	cQery += "  AND D1_VALPIS <> 0  AND D1_VALCOF <> 0 AND D1_VALCSL <> 0                                                                    "
	cQery += "	AND SE2.D_E_L_E_T_ <> '*'    "
	cQery += "	AND SD1.D_E_L_E_T_ <> '*'    "

	MpSysOpenQuery(cQery,"cQr")
	While cQr->(!Eof())
		aAdd(aDados1	,;
			{cQr->D1_FILIAL,;
			cQr->D1_DOC    ,;
			cQr->E2_CODRET ,;
			cQr->D1_TOTAL  ,;
			cQr->D1_EMISSAO,;
			cQr->D1_DTDIGIT,;
			cQr->D1_BASECSL,;
			cQr->D1_BASECOF,;
			cQr->D1_BASEPIS,;
			cQr->D1_VALCSL ,;
			cQr->D1_VALCOF ,;
			cQr->D1_VALPIS ,;
			cQr->E2_VENCREA ,;
			cQr->E2_TITPAI})
		cQr->(DbSkip())
	End
	cQr->(DbCloseArea())
	// Quinta aba do relatorio //
	oExcel:AddWorkSheet("5952")
	oExcel:AddTable("5952","RELATORIO DE APURAÇÃO RETIDOS ")
	oExcel:AddColumn("5952","RELATORIO DE APURAÇÃO RETIDOS ","FILIAL",2,1)//1 ( 1-General,2-Number,3-Monetário,4-DateTime )
	oExcel:AddColumn("5952","RELATORIO DE APURAÇÃO RETIDOS ","DOCUMENTO",2,1)//2
	oExcel:AddColumn("5952","RELATORIO DE APURAÇÃO RETIDOS ","COD. FORNECEDOR",2,1)//2
	oExcel:AddColumn("5952","RELATORIO DE APURAÇÃO RETIDOS ","CNPJ",2,1)//2
	oExcel:AddColumn("5952","RELATORIO DE APURAÇÃO RETIDOS ","NOME FORNECEDOR",2,1)//2
	oExcel:AddColumn("5952","RELATORIO DE APURAÇÃO RETIDOS ","COD. RECEITA",2,1)//2
	oExcel:AddColumn("5952","RELATORIO DE APURAÇÃO RETIDOS ","VLR. TOTAL",2,2)//2
	oExcel:AddColumn("5952","RELATORIO DE APURAÇÃO RETIDOS ","DT. EMISSÃO",2,1)//2
	oExcel:AddColumn("5952","RELATORIO DE APURAÇÃO RETIDOS ","DT. DIGITAÇÃO",2,1)//2
	oExcel:AddColumn("5952","RELATORIO DE APURAÇÃO RETIDOS ","DT. VENCIMENTO",2,1)//2
	oExcel:AddColumn("5952","RELATORIO DE APURAÇÃO RETIDOS ","BASE CSLL",2,2)//2
	oExcel:AddColumn("5952","RELATORIO DE APURAÇÃO RETIDOS ","BASE CONFINS",2,2)//2
	oExcel:AddColumn("5952","RELATORIO DE APURAÇÃO RETIDOS ","BASE PIS",2,2)//2
	oExcel:AddColumn("5952","RELATORIO DE APURAÇÃO RETIDOS ","VLR. CSLL",2,2)//2
	oExcel:AddColumn("5952","RELATORIO DE APURAÇÃO RETIDOS ","VLR. CONFINS",2,2)//2
	oExcel:AddColumn("5952","RELATORIO DE APURAÇÃO RETIDOS ","VLR. PIS",2,2)//2
	For nx := 1 to len(aDados1)
			cFor := SubStr(aDados1[nx,14],19,10)
			oExcel:AddRow("5952","RELATORIO DE APURAÇÃO RETIDOS ",;
				{aDados1[nx,1],;
				aDados1[nx,2],;
				posicione('SA2',1,xFilial('SA2')+AllTrim(cFor),"A2_COD"),;
				posicione('SA2',1,xFilial('SA2')+AllTrim(cFor),"A2_CGC"),;
				posicione('SA2',1,xFilial('SA2')+AllTrim(cFor),"A2_NOME"),;
				aDados1[nx,3],;
				aDados1[nx,4],;
				STOD(aDados1[nx,5]),;
				STOD(aDados1[nx,6]),;
				STOD(aDados1[nx,13]),;
				aDados1[nx,7],;
				aDados1[nx,8],;
				aDados1[nx,9],;
				aDados1[nx,10],;
				aDados1[nx,11],;
				aDados1[nx,12]})
		cCodFor := ""
	Next nx
	oExcel:AddWorkSheet("INSS")
	oExcel:AddTable("INSS","RELATORIO DE APURAÇÃO RETIDOS ")
	oExcel:AddColumn("INSS","RELATORIO DE APURAÇÃO RETIDOS ","FILIAL",2,1)//1 ( 1-General,2-Number,3-Monetário,4-DateTime )
	oExcel:AddColumn("INSS","RELATORIO DE APURAÇÃO RETIDOS ","DOCUMENTO",2,1)//2
	oExcel:AddColumn("INSS","RELATORIO DE APURAÇÃO RETIDOS ","COD. FORNECEDOR",2,1)//2
	oExcel:AddColumn("INSS","RELATORIO DE APURAÇÃO RETIDOS ","CNPJ",2,1)//2
	oExcel:AddColumn("INSS","RELATORIO DE APURAÇÃO RETIDOS ","NOME FORNECEDOR",2,1)//2
	oExcel:AddColumn("INSS","RELATORIO DE APURAÇÃO RETIDOS ","COD. RECEITA",2,1)//2
	oExcel:AddColumn("INSS","RELATORIO DE APURAÇÃO RETIDOS ","VLR. TOTAL",2,2)//2
	oExcel:AddColumn("INSS","RELATORIO DE APURAÇÃO RETIDOS ","DT. EMISSÃO",2,1)//2
	oExcel:AddColumn("INSS","RELATORIO DE APURAÇÃO RETIDOS ","DT. DIGITAÇÃO",2,1)//2
	oExcel:AddColumn("INSS","RELATORIO DE APURAÇÃO RETIDOS ","BASE DE INSS",2,2)//2
	oExcel:AddColumn("INSS","RELATORIO DE APURAÇÃO RETIDOS ","VLR. INSS",2,2)//2
	For nx := 1 to len(aDados)
		If aDados[nx,18] > 0 .OR. aDados[nx,19] > 0
			oExcel:AddRow("INSS","RELATORIO DE APURAÇÃO RETIDOS ",;
				{aDados[nx,1],;
				aDados[nx,2],;
				aDados[nx,3],;
				aDados[nx,4],;
				aDados[nx,5],;
				aDados[nx,6],;
				aDados[nx,7],;
				STOD(aDados[nx,8]),;
				STOD(aDados[nx,9]),;
				aDados[nx,18],;
				aDados[nx,19]})
		EndIf
	Next nx
	oExcel:Activate()
	cArquivo := cGetFile(  , 'Arquivos', 1, 'C:\', .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )
	oExcel:GetXMLFile(cArquivo+"\FSCR007.xls")
	oExcel:DeActivate()
	//Abrindo o excel e abrindo o arquivo xml
	oExib := MsExcel():New()             //Abre uma nova conexão com Excel
	oExib:WorkBooks:Open(cArquivo+"\FSCR007.xls")     //Abre uma planilha
	oExib:SetVisible(.T.)                 //Visualiza a planilha
	oExib:Destroy()
Return 
