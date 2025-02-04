#INCLUDE 'TOTVS.CH'

User Function ImpDtTit()

	Local cCaminho := ""
	Local cDirIni  := "C:/"
	Local aRes     := {}
    Local aItems:= {'Titulos a Pagar','Titulos a Receber'}
	Private cErro := " "
	DEFINE MSDIALOG oDlg TITLE EncodeUTF8("Atualizacao de Vencimento dos Titulos") From 0,0 To 15,60

	oSayArq := tSay():New(05,07,{|| EncodeUTF8("Este programa tem como objetivo a alteracao dos vencimentos, onde os mesmos serao importados e diretamente alterados ")+;
		EncodeUTF8("de um arquivo no formato CSV")+;
		EncodeUTF8("(Valores Separados por 'Ponto e Virgula').")},oDlg,,,,,,.T.,,,200,80)

	oSayArq := tSay():New(27,07,{|| EncodeUTF8("Informe o Tipo de importacao:")},oDlg,,,,,,.T.,,,200,80)
    cCombo1:= aItems[1]
    oCombo1 := TComboBox():New(35,05,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},;
    aItems,100,20,oDlg,,;
    ,,,,.T.,,,,,,,,,'cCombo1')
	oSayArq := tSay():New(52,07,{|| EncodeUTF8("Informe o local onde se encontra o arquivo para importacao:")},oDlg,,,,,,.T.,,,200,80)
	oGetArq := TGet():New(62,05,{|u| If(PCount()>0,cCaminho:=u,cCaminho)},oDlg,150,10,'@!',,,,,,,.T.,,,,,,,,,,'cCaminho')

	oBtnArq := tButton():New(62,160,"Abrir...",oDlg,{|| cCaminho := cGetFile( "Arquivos CSV|*.csv|Arquivos CSV|*.csv", "Selecione o arquivo:",  1, cDirIni, .F., GETF_LOCALHARD, .F., .T. )},30,12,,,,.T.)
	oBtnImp := tButton():New(85,050,"Importar",oDlg,{|| aRes := ImportCsv(cCaminho) },40,12,,,,.T.)
	oBtnCan := tButton():New(85,110,"Cancelar",oDlg,{|| oDlg:End()},40,12,,,,.T.)

	ACTIVATE MSDIALOG oDlg CENTERED

Return aRes

Static Function ImportCsv(cCaminho)

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
	if lEnd = .T.   //VERIFICAR SE N�O CLICOU NO BOTAO CANCELAR
		ApMsgStop("Processo cancelado pelo usuário." + cArq, cMsgHead)
		Return aRes
	EndIf
	oProcess:IncRegua1("3/4 Ler Arquivo CSV")
	oProcess:SetRegua2(Len(aLines))

	For i:=2 to len(aLines)
		if lEnd = .T.    //VERIFICAR SE N�O CLICOU NO BOTAO CANCELAR
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
				if cCombo1 == 'Titulos a Receber'
					UpdateR(aLinha[1], aLinha[2], aLinha[3], aLinha[4], aLinha[5], aLinha[6])
				Else
					UpdateP(aLinha[1], aLinha[2], aLinha[3], aLinha[4], aLinha[5], aLinha[6], aLinha[7], aLinha[8])
				EndIf
			EndIf
		EndIf
	Next
	oFile:Close()
	oProcess:IncRegua1("4/4 Remove temporarios")
	oProcess:SetRegua2(1)
	oProcess:IncRegua2("")
    If !Empty(cErro)
		zMsgLog(cErro,"Falha na importação",1, .F.)
	Else
		MsgInfo("Opereação concluída com sucesso!")
	EndIf

Return aRes

Static Function UpdateR(cFilx,cPrefixo,cNota,cParcela,cTipo,dDtVenc)
	Local lRet      := .F.
	Local dDtVencRe := DataValida(CTOD(dDtVenc),.T.)

	DbSelectArea('SE1')
	SE1->(dbSetOrder(1))
	if SE1->(dbseek(Padr(cFilx,tamSX3('E1_FILIAL')[1])+Padr(cPrefixo,tamSX3('E1_PREFIXO')[1])+Padr(cNota,tamSX3('E1_NUM')[1])+Padr(cParcela,tamSX3('E1_PARCELA')[1])+Padr(cTipo,tamSX3('E1_TIPO')[1])))
		SE1->(RecLock("SE1", .F.))
		SE1->E1_VENCTO  := CTOD(dDtVenc)
		SE1->E1_VENCREA := dDtVencRe
		SE1->(MsUnlock())
        lRet := .T.
	else
		cErro += Replicate("-",39) + CRLF
		cErro += CRLF
		cErro += "Titulo não encontrado ou não foi possivel alterar o mesmo "+cNota+" "+cParcela+ CRLF
		cErro += Replicate("-",39) + CRLF
	EndIf
    SE1->(DbCloseArea())
Return lRet

Static Function UpdateP(cFILIAL,cPREFIXO,cNUM,cPARCELA,cTIPO,cFORNECE,cLOJA,dVENCTO)

	Local lRet      := .F.
	Local dDtVencRe := DataValida(CTOD(dVENCTO),.T.)

    DbSelectArea('SE2')
	SE2->(dbSetOrder(1))
	if SE2->(dbseek(Padr(cFILIAL,tamSX3('E2_FILIAL')[1])+Padr(cPrefixo,tamSX3('E2_PREFIXO')[1])+Padr(cNUM,tamSX3('E2_NUM')[1])+Padr(cParcela,tamSX3('E2_PARCELA')[1])+Padr(cTipo,tamSX3('E2_TIPO')[1])+Padr(cFORNECE,tamSX3('E2_FORNECE')[1])+Padr(cLOJA,tamSX3('E2_LOJA')[1])))
		SE2->(RecLock("SE2", .F.))
		SE2->E2_VENCTO  := CTOD(dVENCTO)
		SE2->E2_VENCREA := dDtVencRe
		SE2->E2_DATALIB := CtoD("")
		SE2->E2_USUALIB := ""
		SE2->E2_XNEGAD  := ""
		SE2->E2_STATLIB := "01"
		SE2->E2_CODAPRO := ""
		SE2->(MsUnlock())
        lRet := .T.
	else
		cErro += Replicate("-",39) + CRLF
		cErro += CRLF
		cErro += "Titulo não encontrado ou não foi possivel alterar o mesmo "+cNUM+" "+cPARCELA+ CRLF
		cErro += Replicate("-",39) + CRLF
	EndIf

    SE2->(DbCloseArea())

Return lRet

Static Function zMsgLog(cMsg, cTitulo, nTipo, lEdit)
	Local lRetMens := .F.
	Local oDlgMens
	Local oBtnOk, cTxtConf := ""
	Local oBtnCnc, cTxtCancel := ""
	Local oBtnSlv
	Local oFntTxt := TFont():New("Lucida Console",,-015,,.F.,,,,,.F.,.F.)
	Local oMsg
	Local nIni:=1
	Local nFim:=50
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
		End
		//Montando a mensagem
		cTexto := "Função   - "+ FunName()       + CRLF
		cTexto += "Usuário  - "+ cUserName       + CRLF
		cTexto += "Data     - "+ dToC(dDataBase) + CRLF
		cTexto += "Hora     - "+ Time()          + CRLF
		cTexto += "Mensagem - "+ cTitulo + cQuebra  + cMsg
		//Testando se o arquivo já existe
		If File(cFileNom)
			lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
		End
		If lOk
			MemoWrite(cFileNom, cTexto)
			MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cFileNom,"Atenção")
		EndIf
	EndIf
Return
