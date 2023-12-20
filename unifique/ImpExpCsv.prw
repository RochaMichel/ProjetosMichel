#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


user Function ExpCsvCND()
	Local aPergs	 := {}
	Private oExcel  := Nil
	Private oSecCab	 := Nil

	aAdd(aPergs,{1,"Codigo do numero da medicao de ",Space(TAMSX3('CND_NUMMED')[1]),"","","CND","",50,.F.})                   //MV_PAR01
	aAdd(aPergs,{1,"Codigo do numero da medicao ate ",Space(TAMSX3('CND_NUMMED')[1]),"","","CND","",50,.F.})                   //MV_PAR02
	If !ParamBox(aPergs,"Informe os Parametros ")
		Return
	EndIf
	MsAguarde({|| oExcel := geraExecel()}, "Aguarde...", "Processando Registros...")
	FWAlertSuccess("Excel gerado.","Processo concluido")
Return
Static Function geraExecel()
	Local oExcel 	As Object
	Local cArquivo    := ""
	Local cQuery	 := GetNextAlias()
	Local oExib

    BeginSql Alias cQuery
        Select CND_NUMMED, CNE_CC,CNE_CLVL
        ,CNE_DTENT,CNE_CONTA,CNE_ITEMCT,CNE_PEDTIT
        ,CNE_PRODUT,CNE_QUANT,CNE_VLUNIT,CNE_TE,CNZ_ITEM
        ,CNZ_CC,CNZ_CONTA,CNZ_CLVL,CNZ_PERC,CNZ_ITEMCT 
        from %Table:CND%
        Inner join %Table:CNE% ON CND_NUMMED = CNE_NUMMED
        Inner Join %Table:CNZ% ON CNE_CONTRA = CNZ_CONTRA 
        AND CNE_REVISA = CNZ_REVISA
        AND CNE_NUMERO = CNZ_CODPLA
        AND CNE_NUMMED = CNZ_NUMMED
        AND CNE_ITEM   = CNZ_ITCONT    
        WHERE CND_NUMMED BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
    EndSql


	oExcel := FwMsExcelXlsx():New()

	// primeira aba do relatorio  //
	oExcel:AddWorkSheet("RELATORIO")
	oExcel:AddTable("RELATORIO","EXPORTAÇÃO CNE E CNZ ")
	oExcel:AddColumn("RELATORIO","EXPORTAÇÃO CNE E CNZ ","CND_NUMMED",2,1)//1 ( 1-General,2-Number,3-Monetário,4-DateTime )
	oExcel:AddColumn("RELATORIO","EXPORTAÇÃO CNE E CNZ ","CNE_CC"    ,2,1)//2
	oExcel:AddColumn("RELATORIO","EXPORTAÇÃO CNE E CNZ ","CNE_CLVL"  ,2,1)//2
	oExcel:AddColumn("RELATORIO","EXPORTAÇÃO CNE E CNZ ","CNE_DTENT" ,2,1)//2
	oExcel:AddColumn("RELATORIO","EXPORTAÇÃO CNE E CNZ ","CNE_CONTA" ,2,1)//2
	oExcel:AddColumn("RELATORIO","EXPORTAÇÃO CNE E CNZ ","CNE_ITEMCT",2,1)//2
	oExcel:AddColumn("RELATORIO","EXPORTAÇÃO CNE E CNZ ","CNE_PEDTIT",2,1)//2
	oExcel:AddColumn("RELATORIO","EXPORTAÇÃO CNE E CNZ ","CNE_PRODUT",2,1)//2
	oExcel:AddColumn("RELATORIO","EXPORTAÇÃO CNE E CNZ ","CNE_QUANT" ,2,2)//2
	oExcel:AddColumn("RELATORIO","EXPORTAÇÃO CNE E CNZ ","CNE_VLUNIT",2,2)//2
	oExcel:AddColumn("RELATORIO","EXPORTAÇÃO CNE E CNZ ","CNE_TE"    ,2,1)//2
	oExcel:AddColumn("RELATORIO","EXPORTAÇÃO CNE E CNZ ","CNZ_ITEM"  ,2,1)//2
	oExcel:AddColumn("RELATORIO","EXPORTAÇÃO CNE E CNZ ","CNZ_CC"    ,2,1)//2
	oExcel:AddColumn("RELATORIO","EXPORTAÇÃO CNE E CNZ ","CNZ_CONTA" ,2,1)//2
	oExcel:AddColumn("RELATORIO","EXPORTAÇÃO CNE E CNZ ","CNZ_CLVL"  ,2,1)//2
	oExcel:AddColumn("RELATORIO","EXPORTAÇÃO CNE E CNZ ","CNZ_PERC"  ,2,2)//2
	oExcel:AddColumn("RELATORIO","EXPORTAÇÃO CNE E CNZ ","CNZ_ITEMCT",2,1)//2
    
    While (cQuery)->(!EOF())
			oExcel:AddRow("RELATORIO","EXPORTAÇÃO CNE E CNZ ",;
				{ (cQuery)->CND_NUMMED,;
                  (cQuery)->CNE_CC,;     
                  (cQuery)->CNE_CLVL,;  
                  (cQuery)->CNE_DTENT,; 
                  (cQuery)->CNE_CONTA,; 
                  (cQuery)->CNE_ITEMCT,;
                  (cQuery)->CNE_PEDTIT,;
                  (cQuery)->CNE_PRODUT,;
                  (cQuery)->CNE_QUANT,; 
                  (cQuery)->CNE_VLUNIT,;
                  (cQuery)->CNE_TE,;    
                  (cQuery)->CNZ_ITEM,;  
                  (cQuery)->CNZ_CC,;    
                  (cQuery)->CNZ_CONTA,; 
                  (cQuery)->CNZ_CLVL,;  
                  (cQuery)->CNZ_PERC,;  
                  (cQuery)->CNZ_ITEMCT})
        (cQuery)->(DbSkip())          
    End
	oExcel:Activate()
	cArquivo := cGetFile(  , 'Arquivos', 1, 'C:\', .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )
	oExcel:GetXMLFile(cArquivo+"\IMP_RELCNE.csv")
	oExcel:DeActivate()
	//Abrindo o excel e abrindo o arquivo xml
	oExib := MsExcel():New()             //Abre uma nova conexão com Excel
	oExib:WorkBooks:Open(cArquivo+"\IMP_RELCNE.csv")     //Abre uma planilha
	oExib:SetVisible(.T.)                 //Visualiza a planilha
	oExib:Destroy()
Return 

User Function CNT121_004()

	Local cCaminho := ""
	Local cDirIni  := "C:/"
	Local aRes     := {}
	private cErro := ""

	DEFINE MSDIALOG oDlg TITLE " Importação de longitude e latitude do cliente." From 0,0 To 15,50

	oSayArq := tSay():New(15,07,{|| "Este programa tem como objetivo importar   , onde os mesmos serão importados e diretamente alterados "+;
		"de um arquivo no formato CSV"+;
		"(Valores Separados por 'Ponto e vírgula')."},oDlg,,,,,,.T.,,,200,80)

	oSayArq := tSay():New(45,07,{|| "Informe o local onde se encontra o arquivo para importação:"},oDlg,,,,,,.T.,,,200,80)
	oGetArq := TGet():New(55,05,{|u| If(PCount()>0,cCaminho:=u,cCaminho)},oDlg,150,10,'@!',,,,,,,.T.,,,,,,,,,,'cCaminho')

	oBtnArq := tButton():New(55,160,"Abrir...",oDlg,{|| cCaminho := cGetFile( "Arquivos CSV|*.csv|Arquivos CSV|*.csv", "Selecione o arquivo:",  1, cDirIni, .F., GETF_LOCALHARD, .F., .T. )},30,12,,,,.T.)
	oBtnImp := tButton():New(80,050,"Importar",oDlg,{|| aRes := ImCsv(cCaminho) },40,12,,,,.T.)
	oBtnCan := tButton():New(80,110,"Cancelar",oDlg,{|| oDlg:End()},40,12,,,,.T.)

	ACTIVATE MSDIALOG oDlg CENTERED

Return aRes

/*
*======================================================================================================*
| PROGRAMA | ImCsvDt           ||                                                  |     FEITO POR     |
|----------------------------------------------------------------------------------|-------------------|
| função para Seleção do arquivo ao clicar importar                                |Michel Rocha-Coderp|
|                                                                                  |-------------------|
|                                                                                  | EM:   17/10/2022  |
*======================================================================================================*
*/

Static Function ImCsv(cCaminho)

	Local oProcess  := nil
	Local aRes      := nil
	Default cIdPlan := "1"
	Default cArq    := ""
	Default cDelimiter := ";"
	If Empty(cCaminho)
		MsgInfo("Selecione um arquivo",)
		Return
	ElseIf !File(cCaminho)
		MsgInfo("Arquivo não localizado","Atenção")
		Return
	Else
		oDlg:End()
		oProcess := MsNewProcess():New({|lEnd| aRes:= ProcessCSV(cCaminho,@oProcess)  },"Extraindo dados da planilha CSV","Efetuando a leitura do arquivo CSV...", .T.)
		oProcess:Activate()
	EndIf

Return aRes

/*
*======================================================================================================*
| PROGRAMA | ProcessCSV           ||                                               |     FEITO POR     |
|----------------------------------------------------------------------------------|-------------------|
| Função para ler os arquivos CSV                                                  |Michel Rocha-Coderp|
|                                                                                  |-------------------|
|                                                                                  | EM:   17/10/2022  |
*======================================================================================================*
*/

Static Function ProcessCSV(cCaminho,oProcess)

	Local i
	Local aRes      := {}
	Local aLines    := {}
	Local cMsgHead  := "ImportCsv()"
	Local oFile     := NIL
	Local aLinha    := {}
	Local lManterVazio := .T.
	Local lEnd         := .F.

	oFile := FWFileReader():New(cCaminho)
	If oFile:Open() = .F.
		ApMsgStop("Não foi possível efetuar a leitura do arquivo." + cArq, cMsgHead)
		Return aRes
	EndIf
	aLines := oFile:GetAllLines()
	if lEnd = .T.   //VERIFICAR SE Nï¿½O CLICOU NO BOTAO CANCELAR
		ApMsgStop("Processo cancelado pelo usuário." + cArq, cMsgHead)
		Return aRes
	EndIf
	oProcess:IncRegua1("3/4 Ler Arquivo CSV")
	oProcess:SetRegua2(Len(aLines))

	For i:=3 to len(aLines)
		if lEnd = .T.    //VERIFICAR SE Nï¿½O CLICOU NO BOTAO CANCELAR
			ApMsgStop("Processo cancelado pelo usuário." + cArq, cMsgHead)
			Return {}
		EndIf
		oProcess:IncRegua2("Atualizando registro " + CvalToChar(i) + " de " + cValToCHar(Len(aLines)) )
		cLinha  := aLines[i]
		If Empty(cLinha) = .F.
			cLinha := StrTran(StrTran(cLinha, '"', ''), ",", ".")
			aLinha := Separa(cLinha, cDelimiter, lManterVazio)
			If Len(aLinha) > 0
				//Filial;Nota;Serie;Data
				Update(aLinha[1],aLinha[2],aLinha[3],aLinha[4],aLinha[5],aLinha[6],aLinha[7],aLinha[8],aLinha[9],;
                aLinha[10],aLinha[11],aLinha[12],aLinha[13],aLinha[14],aLinha[15],aLinha[16],aLinha[17])
			EndIf
		EndIf
	Next i
	oFile:Close()
	oProcess:IncRegua1("4/4 Remove temporarios")
	oProcess:SetRegua2(1)
	oProcess:IncRegua2("")
	If !Empty(cErro)
		MsgInfo(cErro)
	Else
		MsgInfo("Opereação concluída com sucesso!")
	EndIf

Return aRes

Static Function Update(cNumMed,cCC,cCLVL,cDTENT,cCONTA,cITEMCT,cPEDTIT,cPRODUT,cQuant,cVlunit,cTe,cItem,cCCz,cContaz,cClvlz,cPerc,cItemCtz) 
    Local oModel    := Nil
    Local aMsgDeErro:= {}
    Local lRet      := .F.
    DbSelectArea('CN9')
    CN9->(DbSetOrder(4))
         
    If CN9->(DbSeek(xFilial("CN9") + cNumMed))//Posicionar na CN9 para realizar a inclusão
        oModel := FWLoadModel("CNTA121")
         
        oModel:SetOperation(4)
        If(oModel:CanActivate())           
            oModel:Activate()
            oModel:SetValue("CNDMASTER","CND_CONTRA"    ,CN9->CN9_NUMERO)
                          
            oModel:SetValue( 'CNEDETAIL' , 'CNE_CC'    , cCC)
            oModel:SetValue( 'CNEDETAIL' , 'CNE_CLVL'  , cCLVL)
            oModel:SetValue( 'CNEDETAIL' , 'CNE_DTENT' , cDTENT)
            oModel:SetValue( 'CNEDETAIL' , 'CNE_CONTA' , cCONTA)
            oModel:SetValue( 'CNEDETAIL' , 'CNE_ITEMCT', cITEMCT)
            oModel:SetValue( 'CNEDETAIL' , 'CNE_PEDTIT', cPEDTIT)
            oModel:SetValue( 'CNEDETAIL' , 'CNE_PRODUT', cPRODUT)
            oModel:SetValue( 'CNEDETAIL' , 'CNE_QUANT' , Val(cQuant))
            oModel:SetValue( 'CNEDETAIL' , 'CNE_VLUNIT', Val(cVlunit))
            oModel:SetValue( 'CNEDETAIL' , 'CNE_TE'    , cTe)
 
            /*Os rateios abaixo serao incluidos pra corrente do modelo da CNE*/
            oModel:SetValue("CNZDETAIL","CNZ_ITEM"     , cItem)
            oModel:SetValue("CNZDETAIL","CNZ_CC"       , cCCz)
            oModel:SetValue("CNZDETAIL","CNZ_CONTA"    , cContaz)
            oModel:SetValue("CNZDETAIL","CNZ_CLVL"     , cClvlz)
            oModel:SetValue("CNZDETAIL","CNZ_ITEMCT"   , cItemCtz)
            oModel:SetValue("CNZDETAIL","CNZ_PERC"     , cPerc)
        
             
            If (oModel:VldData()) /*Valida o modelo como um todo*/
                oModel:CommitData()
            EndIf
        EndIf
         
        If(oModel:HasErrorMessage())
            aMsgDeErro := oModel:GetErrorMessage()
        Else
            cNumMed := CND->CND_NUMMED          
            oModel:DeActivate()        
            lRet := CN121Encerr(.T.) //Realiza o encerramento da medição                   
        EndIf
    EndIf  
Return lRet
