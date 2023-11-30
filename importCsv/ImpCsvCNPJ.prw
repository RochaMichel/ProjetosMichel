#INCLUDE 'TOTVS.CH'
/*
*======================================================================================================*
| PROGRAMA | ImpCsvCg           ||                                                 |     FEITO POR     |
|----------------------------------------------------------------------------------|-------------------|
| Executa as Perguntas para inicar a importa��o                                    |Michel Rocha-Coderp|
|                                                                                  |-------------------|
|                                                                                  | EM:   17/10/2022  |
*======================================================================================================*
*/

User Function ImpCsvC()

	Local cCaminho := ""
	Local cDirIni  := "C:/"
	Local aRes     := {}
	private cErro := ""

	DEFINE MSDIALOG oDlg TITLE " Importa��o de longitude e latitude do cliente." From 0,0 To 15,50

	oSayArq := tSay():New(15,07,{|| "Este programa tem como objetivo importar a longitude e latitude do cliente , onde os mesmos ser�o importados e diretamente alterados "+;
		"de um arquivo no formato CSV"+;
		"(Valores Separados por 'Ponto e v�rgula')."},oDlg,,,,,,.T.,,,200,80)

	oSayArq := tSay():New(45,07,{|| "Informe o local onde se encontra o arquivo para importa��o:"},oDlg,,,,,,.T.,,,200,80)
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
| fun��o para Sele��o do arquivo ao clicar importar                                |Michel Rocha-Coderp|
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
		MsgInfo("Arquivo n�o localizado","Aten��o")
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
| Fun��o para ler os arquivos CSV                                                  |Michel Rocha-Coderp|
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
		ApMsgStop("N�o foi poss�vel efetuar a leitura do arquivo." + cArq, cMsgHead)
		Return aRes
	EndIf
	aLines := oFile:GetAllLines()
	if lEnd = .T.   //VERIFICAR SE N�O CLICOU NO BOTAO CANCELAR
		ApMsgStop("Processo cancelado pelo usu�rio." + cArq, cMsgHead)
		Return aRes
	EndIf
	oProcess:IncRegua1("3/4 Ler Arquivo CSV")
	oProcess:SetRegua2(Len(aLines))

	For i:=2 to len(aLines)
		if lEnd = .T.    //VERIFICAR SE N�O CLICOU NO BOTAO CANCELAR
			ApMsgStop("Processo cancelado pelo usu�rio." + cArq, cMsgHead)
			Return {}
		EndIf
		oProcess:IncRegua2("Atualizando registro " + CvalToChar(i) + " de " + cValToCHar(Len(aLines)) )
		cLinha  := aLines[i]
		If Empty(cLinha) = .F.
			cLinha := StrTran(StrTran(cLinha, '"', ''), ",", ".")
			aLinha := Separa(cLinha, cDelimiter, lManterVazio)
			If Len(aLinha) > 0
				//Filial;Nota;Serie;Data
				Update(aLinha[8],aLinha[9],aLinha[10])
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
		MsgInfo("Operea��o conclu�da com sucesso!")
	EndIf

Return aRes

/*
*======================================================================================================*
| PROGRAMA | Update           ||                                                   |     FEITO POR     |
|----------------------------------------------------------------------------------|-------------------|
| Fun��o para executar a altera��o da observa��o da carga                          |Michel Rocha-Coderp|
|                                                                                  |-------------------|
|                                                                                  | EM:   14/10/2022  |
*======================================================================================================*
*/

Static Function Update(cLAT,cLONG,cCGC)
	local clati := "0"
	local clongi := "0"
	If substr(cLat,1,1) == "-"
		clati  := transform(cLat ,"@R 99.9999999999999999999999999999")
	EndIf
	If substr(cLONG,1,1) == "-"
	    clongi := transform(cLong,"@R 999.9999999999999999999999999999")
	EndIf
	If substr(cLat,1,1) <> "-"	.AND. substr(cLat,1,1) <> "0"
		clati  := transform(cLat ,"@R 9.9999999999999999999999999999")
	EndIf
	If substr(cLONG,1,1) <> "-"	.AND. substr(cLong,1,1) <> "0"
	    clongi := transform(cLong,"@R 99.9999999999999999999999999999")	
	EndIf
	DbSelectArea("SA1")
	SA1->(DbSetOrder(3))
	IF dbseek(FWxfilial("SA1")+PADR(cCGC,TAMSX3("A1_CGC")[1]))
		SA1->(RecLock("SA1", .F.))
		SA1->A1_XLAT := alltrim(clati)
		SA1->A1_XLONG := alltrim(clongi)
		SA1->(MsUnlock())
	else
		cErro += "Cliente com CPF/CNPJ "+cCGC+" N�o cadastrado" + CRLF
	ENDIF


Return

