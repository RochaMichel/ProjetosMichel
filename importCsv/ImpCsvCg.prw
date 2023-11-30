#INCLUDE 'TOTVS.CH'

/*
*======================================================================================================*
| PROGRAMA | ImpCsvCg           ||                                                 |     FEITO POR     |
|----------------------------------------------------------------------------------|-------------------|
| Executa as Perguntas para inicar a importação                                    |Michel Rocha-Coderp|
|                                                                                  |-------------------|
|                                                                                  | EM:   17/10/2022  |
*======================================================================================================*
*/

User Function ImpCsvCg()

	Local cCaminho := ""
	Local cDirIni  := "C:/"
	Local aRes     := {}

	DEFINE MSDIALOG oDlg TITLE " Ajustar informações da carga que não foram encerradas" From 0,0 To 15,50

	oSayArq := tSay():New(15,07,{|| "Este programa tem como objetivo a inserção de informações da carga , onde os mesmos serão importados e diretamente alterados "+;
		"de um arquivo no formato CSV"+;
		"(Valores Separados por 'Ponto e vírgula')."},oDlg,,,,,,.T.,,,200,80)

	oSayArq := tSay():New(45,07,{|| "Informe o local onde se encontra o arquivo para importação:"},oDlg,,,,,,.T.,,,200,80)
	oGetArq := TGet():New(55,05,{|u| If(PCount()>0,cCaminho:=u,cCaminho)},oDlg,150,10,'@!',,,,,,,.T.,,,,,,,,,,'cCaminho')

	oBtnArq := tButton():New(55,160,"Abrir...",oDlg,{|| cCaminho := cGetFile( "Arquivos CSV|*.csv|Arquivos CSV|*.csv", "Selecione o arquivo:",  1, cDirIni, .F., GETF_LOCALHARD, .F., .T. )},30,12,,,,.T.)
	oBtnImp := tButton():New(80,050,"Importar",oDlg,{|| aRes := ImCsvCg(cCaminho) },40,12,,,,.T.)
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

Static Function ImCsvCg(cCaminho)

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

	For i:=2 to len(aLines)
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
				Update(aLinha[1],aLinha[2], aLinha[3])
			EndIf
		EndIf
	Next i
	oFile:Close()
	oProcess:IncRegua1("4/4 Remove temporarios")
	oProcess:SetRegua2(1)
	oProcess:IncRegua2("")

	MsgInfo("Processo finalizado.")

Return aRes

/*
*======================================================================================================*
| PROGRAMA | Update           ||                                                   |     FEITO POR     |
|----------------------------------------------------------------------------------|-------------------|
| Função para executar a alteração da observação da carga                          |Michel Rocha-Coderp|
|                                                                                  |-------------------|
|                                                                                  | EM:   14/10/2022  |
*======================================================================================================*
*/

Static Function Update(cFilx,cCod,cObs)
	Local cDAKAlias := GetNextAlias()

	BeginSql Alias cDAKAlias
		SELECT  DAK_SEQCAR
			FROM %Table:DAK% DAK
				WHERE DAK.%NotDel%
				AND DAK.DAK_FILIAL = %Exp:cFilx%
				AND DAK.DAK_COD =  %Exp:cCod%
	EndSql
	DbSelectArea(cDAKAlias)	

	If (cDAKAlias)->(Eof())
		RETURN
	EndiF

	DbSelectArea("DAK")	
	DAK->(DbSetOrder(1))
	IF DAK->(DbSeek(cFilx+cCod+(cDAKAlias)->(DAK_SEQCAR)))
		if DAK->DAK_FEZNF <>'1'
			DAK->(RecLock("DAK", .F.))
				DAK->DAK_XOBSCA := cObs
			DAK->(MsUnlock())
		ENDIF
	ENDIF	

Return

