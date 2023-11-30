#INCLUDE 'TOTVS.CH'

/*
*=======================================================================================================*
| PROGRAMA | ImpCsvE2           ||                                                 |     FEITO POR      |
|----------------------------------------------------------------------------------|--------------------|
| Executa as Perguntas para inicar a importação                                    |Lucas Antonio-Coderp|
|                                                                                  |--------------------|
|                                                                                  | EM:   31/03/2023   |
*====================================================================================================+==*
*/

User Function ImpCsvE2()

	Local cCaminho := ""
	Local cDirIni  := "C:/"
	Local aRes     := {}

	DEFINE MSDIALOG oDlg TITLE " Importação de dados para contas a pagar" From 0,0 To 15,50

	oSayArq := tSay():New(15,07,{|| "Este programa tem como objetivo a inserção de informações de contas a pagar , onde os mesmos serão importados e diretamente alterados "+;
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
*================================================================================================+======*
| PROGRAMA | ImCsvDt           ||                                                  |     FEITO POR      |
|----------------------------------------------------------------------------------|--------------------|
| função para Seleção do arquivo ao clicar importar                                |Lucas Antonio-Coderp|
|                                                                                  |--------------------|
|                                                                                  | EM:   31/03/2023   |
*================================================================================================+======*
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
*=======================================================================================================*
| PROGRAMA | ProcessCSV           ||                                               |     FEITO POR      |
|----------------------------------------------------------------------------------|--------------------|
| Função para ler os arquivos CSV                                                  |Lucas Antonio-Coderp|
|                                                                                  |--------------------|
|                                                                                  | EM:   31/03/2023   |
*=======================================================================================================*
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
	Private cErro := ""

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
				        //Filial;         ;N.Titulo            ;TP.Titulo       ;Cod.Fornecedor;      NFornecedor;         Vencimento;             Valor    
				Update(aLinha[1],aLinha[2],aLinha[3],aLinha[4],aLinha[5],aLinha[6],aLinha[7],aLinha[8],aLinha[9],aLinha[10],aLinha[11],aLinha[12],aLinha[13],aLinha[14])
				              // Prefixo;            P.Titulo;        Cod.Natureza;            Loja;              Emissao;            Venc.Real              Historico
			EndIf
		EndIf
	Next i
	oFile:Close()
	oProcess:IncRegua1("4/4 Remove temporarios")
	oProcess:SetRegua2(1)
	oProcess:IncRegua2("")
	If !Empty(cErro)
		zMsgLog(cErro,"Falha na importação",1, .F.)
	Else
		MsgInfo("Processo finalizado.")
	EndIf


Return aRes

/*
*=======================================================================================================*
| PROGRAMA | Update           ||                                                   |     FEITO POR      |
|----------------------------------------------------------------------------------|--------------------|
| Função para executar a alteração da observação da carga                          |Lucas Antonio-Coderp|
|                                                                                  |--------------------|
|                                                                                  | EM:   31/03/2023   |
*=======================================================================================================*
*/

Static Function Update(cFilx,cPrefixo,cNumero,cParcela,cTipo,cNatureza,cFornece,cLoja,cNomFor,cEmissao,cVencto,cVencreal,cValor,cHist)
	Local aSe2Val := {}
	Local nY

	aAdd(aSe2Val, {"E2_FILIAL",  cFilx,             Nil})
	aAdd(aSe2Val, {"E2_NUM",     cNumero,           Nil})
	aAdd(aSe2Val, {"E2_PREFIXO", cPrefixo,          Nil})
	aAdd(aSe2Val, {"E2_PARCELA", cParcela,          Nil})
	aAdd(aSe2Val, {"E2_TIPO",    cTipo,             Nil})
	aAdd(aSe2Val, {"E2_NATUREZ", cNatureza,         Nil})
	aAdd(aSe2Val, {"E2_FORNECE", cFornece,          Nil})
	aAdd(aSe2Val, {"E2_LOJA",    cLoja,             Nil})
	aAdd(aSe2Val, {"E2_NOMFOR",  cNomFor,           Nil})
	aAdd(aSe2Val, {"E2_EMISSAO", CtoD(cEmissao ),   Nil})
	aAdd(aSe2Val, {"E2_VENCTO",  CtoD(cVencto  ),   Nil})
	aAdd(aSe2Val, {"E2_VENCREA", CtoD(cVencReal),   Nil})
	aAdd(aSe2Val, {"E2_VALOR",   Val(cValor),       Nil})
	aAdd(aSe2Val, {"E2_HIST",    cHist,             Nil})
	aAdd(aSe2Val, {"E2_MOEDA",   1,                 Nil})

	DbSelectArea("SE2")
	Begin Transaction
		//Chama a rotina automática
		lMsErroAuto := .F.
		MSExecAuto({|x,y| FINA050(x,y)}, aSe2Val, 3)

		//Se houve erro, mostra o erro ao usuário e desarma a transação
		If lMsErroAuto
			aLog  := GetAutoGRLog()
			For nY := 1 To Len(aLog)
				cErro += aLog[nY] + CRLF
			Next nY
			cErro += Replicate("-",39) + CRLF
		EndIf
//Finaliza a transação
	End Transaction
return
Static Function zMsgLog(cMsg, cTitulo, nTipo, lEdit)
	Local lRetMens := .F.
	Local oDlgMens
	Local oBtnOk, cTxtConf := ""
	Local oBtnCnc, cTxtCancel := ""
	Local oBtnSlv
	Local oFntTxt := TFont():New("Lucida Console",,-015,,.F.,,,,,.F.,.F.)
	Local oMsg
	//Local nIni:=1
	//Local nFim:=50
	Default cMsg    := "..."
	Default cTitulo := "zMsgLog"
	Default nTipo   := 1 // 1=Ok; 2= Confirmar e Cancelar
	Default lEdit   := .F.

	//Definindo os textos dos botões
	If(nTipo == 1)
		cTxtConf:='&Ok'
	Else
		cTxtConf:='&Confirmar'
		cTxtCancel:='C&ancelar'
	EndIf

	//Criando a janela centralizada com os botões
	DEFINE MSDIALOG oDlgMens TITLE cTitulo FROM 000, 000  TO 300, 400 COLORS 0, 16777215 PIXEL
	//Get com o Log
	@ 002, 004 GET oMsg VAR cMsg OF oDlgMens MULTILINE SIZE 191, 121 FONT oFntTxt COLORS 0, 16777215 HSCROLL PIXEL
	If !lEdit
		oMsg:lReadOnly := .T.
	EndIf

	//Se for Tipo 1, cria somente o botão OK
	If (nTipo==1)
		@ 127, 144 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 019 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL

		//Senão, cria os botões OK e Cancelar
	ElseIf(nTipo==2)
		@ 127, 144 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 009 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
		@ 137, 144 BUTTON oBtnCnc PROMPT cTxtCancel SIZE 051, 009 ACTION (lRetMens:=.F., oDlgMens:End()) OF oDlgMens PIXEL
	EndIf

	//Botão de Salvar em Txt
	@ 127, 004 BUTTON oBtnSlv PROMPT "&Salvar em .txt" SIZE 051, 019 ACTION (fSalvArq(cMsg, cTitulo)) OF oDlgMens PIXEL
	ACTIVATE MSDIALOG oDlgMens CENTERED

Return lRetMens

/*-----------------------------------------------*
 | Função: fSalvArq                              |
 | Descr.: Função para gerar um arquivo texto    |
 *-----------------------------------------------*/
 
Static Function fSalvArq(cMsg, cTitulo)
    Local cFileNom :='\x_arq_'+dToS(Date())+StrTran(Time(),":")+".txt"
    Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
    Local lOk      := .T.
    Local cTexto   := ""
     
    //Pegando o caminho do arquivo
    cFileNom := cGetFile( "Arquivo TXT *.txt | *.txt", "Arquivo .txt...",,'',.T., GETF_LOCALHARD)
 
    //Se o nome não estiver em branco    
    If !Empty(cFileNom)
        //Teste de existência do diretório
        If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
            Alert("Diretório não existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
            Return
        EndIf
         
        //Montando a mensagem
        cTexto := "Função   - "+ FunName()       + CRLF
        cTexto += "Usuário  - "+ cUserName       + CRLF
        cTexto += "Data     - "+ dToC(dDataBase) + CRLF
        cTexto += "Hora     - "+ Time()          + CRLF
        cTexto += "Mensagem - "+ cTitulo + cQuebra  + cMsg + cQuebra
         
        //Testando se o arquivo já existe
        If File(cFileNom)
            lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
        EndIf
         
        If lOk
            MemoWrite(cFileNom, cTexto)
            MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cFileNom,"Atenção")
        EndIf
    EndIf
Return
