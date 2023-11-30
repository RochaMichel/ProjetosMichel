#Include "Totvs.ch"
#Include "RPTDef.ch"
#include "TBICONN.ch"

/*/{Protheus.doc} RelDre
Fonte para exibir Relatório de Apuração Retidos
@type function
@author Michel Rocha 
@since 30/	01/2023
@return 
/*/

User Function RelDre()
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
	Local cQuery	 :=  GetNextAlias()
	Local aDados	 := {}
	Local oExib
    BeginSql Alias cQuery
    Select * from %table:ZED% ZED
    EndSql
	While cQry->(!Eof())
		aAdd(aDados,{  })
		cQry->(DbSkip())
	End
	cQry->(DbCloseArea())
	oExcel := FwMsExcelXlsx():New()

	// primeira aba do relatorio  //
	oExcel:AddWorkSheet("0588")
	oExcel:AddTable("0588","RELATORIO DE APURAÇÃO RETIDOS ")
	oExcel:AddColumn("0588","RELATORIO DE APURAÇÃO RETIDOS ","FILIAL",2,1)//1 ( 1-General,2-Number,3-Monetário,4-DateTime )
	oExcel:AddColumn("0588","RELATORIO DE APURAÇÃO RETIDOS ","DOCUMENTO",2,1)//2

	For nx := 1 to len(aDados)
		If ALLTRIM(aDados[nx,6]) == "0588"
			oExcel:AddRow("0588","RELATORIO DE APURAÇÃO RETIDOS ",;
				{aDados[nx,1],;
				aDados[nx,2]})
		EndIf
	Next nx
	oExcel:Activate()
	cArquivo := cGetFile(  , 'Arquivos', 1, 'C:\', .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )
	oExcel:GetXMLFile(cArquivo+"\RelDre.xls")
	oExcel:DeActivate()
	//Abrindo o excel e abrindo o arquivo xml
	oExib := MsExcel():New()             //Abre uma nova conexão com Excel
	oExib:WorkBooks:Open(cArquivo+"\RelDre.xls")     //Abre uma planilha
	oExib:SetVisible(.T.)                 //Visualiza a planilha
	oExib:Destroy()
Return
