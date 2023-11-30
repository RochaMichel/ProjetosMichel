#INCLUDE 'TOTVS.CH'

User Function ImpD3Mv()
	Local cCaminho := ""
	Local cDirIni  := "C:/"
	Local aRes     := {}
	Private cErro 	:= ""
	DEFINE MSDIALOG oDlg TITLE "Atualização do Saldo na rotina movimento interno" From 0,0 To 15,50
	oSayArq := tSay():New(15,07,{|| "Este programa tem como objetivo Atualizar o Saldo na rotina movimento interno "+;
		"de um arquivo no formato CSV"+;
		"(Valores Separados por 'Ponto e Vírgula')."},oDlg,,,,,,.T.,,,200,80)
	oSayArq := tSay():New(45,07,{|| "Informe o local onde se encontra o arquivo para importação:"},oDlg,,,,,,.T.,,,200,80)
	oGetArq := TGet():New(55,05,{|u| If(PCount()>0,cCaminho:=u,cCaminho)},oDlg,150,10,'@!',,,,,,,.T.,,,,,,,,,,'cCaminho')
	oBtnArq := tButton():New(55,160,"Abrir...",oDlg,{|| cCaminho := cGetFile( "Arquivos CSV|*.csv|Arquivos CSV|*.csv", "Selecione o arquivo:",  1, cDirIni, .F., GETF_LOCALHARD, .F., .T. )},30,12,,,,.T.)
	oBtnImp := tButton():New(80,050,"Importar",oDlg,{|| aRes := ImpD3Mv1(cCaminho) },40,12,,,,.T.)
	oBtnCan := tButton():New(80,110,"Cancelar",oDlg,{|| oDlg:End()},40,12,,,,.T.)
	ACTIVATE MSDIALOG oDlg CENTERED

Return aRes

Static Function ImpD3Mv1(cCaminho)
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

	SetFunName("MATA241")
	oFile := FWFileReader():New(cCaminho)
	If oFile:Open() = .F.
		ApMsgStop("Não foi possível efetuar a leitura do arquivo." + cArq, cMsgHead)
		Return aRes
	EndIf
	aLines := oFile:GetAllLines()
	If lEnd = .T.   //VERIFICAR SE NO CLICOU NO BOTAO CANCELAR
		ApMsgStop("Processo cancelado pelo usuário." + cArq, cMsgHead)
		Return aRes
	EndIf
	oProcess:IncRegua1("3/4 Ler Arquivo CSV")
	oProcess:SetRegua2(Len(aLines))

	For i:=2 to len(aLines)
		If lEnd = .T.    //VERIFICAR SE NO CLICOU NO BOTAO CANCELAR
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
				Update(aLinha[1],aLinha[2], aLinha[3], aLinha[4], aLinha[5])
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
		MsgInfo("Opereação concluída com sucesso!")
	EndIf
Return aRes

Static Function Update(cDocumento, cCOD , cData, cLocal, cQtde)
	Local aLog   	:= {}
	Local nY
	Local nQuant    := 0
	Local aSD3      := {}
	Local aCab1      := {}
	Local cB2Alias      := GetNextAlias()
	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile  := .T.

	BeginSql Alias cB2Alias
		SELECT B2_QATU From  %Table:SB2% SB2 
        WHERE B2_COD = %Exp:cCod%
        AND B2_LOCAL = %Exp:cLocal%
        AND B2_FILIAL = %Exp:cFilAnt%
	EndSql

	If (cB2Alias)->(Eof())
		cErro += Replicate("-",39) + CRLF
		cErro += CRLF
		cErro += "Saldo não encontrado "+cCOD+ CRLF
		cErro += Replicate("-",39) + CRLF
		Return
	EndIf 

	If (cB2Alias)->B2_QATU > 0
		If (cB2Alias)->B2_QATU > Val(cQtde)
			aCab1 := {{"D3_DOC"       ,cDocumento       ,Nil},;
				     {"D3_TM"        ,'502'            ,Nil},;
                     {"D3_EMISSAO"   ,cTod(cData)      ,Nil},;
			         {"D3_CC"        , ''              ,Nil}}
			nQuant := (cB2Alias)->B2_QATU - Val(cQtde)
		Else
			aCab1 := {{"D3_DOC"       ,cDocumento       ,Nil},;
				     {"D3_TM"        ,'002'            ,Nil},;
                     {"D3_EMISSAO"   ,cTod(cData)      ,Nil},;
			         {"D3_CC"        , ''              ,Nil}}
			nQuant := Val(cQtde) - (cB2Alias)->B2_QATU
		EndIf
		Aadd(aSD3,{{"D3_COD"		,cCOD        ,Nil},;
			{"D3_LOCAL"		,cLocal	     ,Nil},;
			{"D3_QUANT"		,nQuant      ,Nil}})
	ElseIf (cB2Alias)->B2_QATU < 0
		aCab1 := {{"D3_DOC"       ,cDocumento       ,Nil},;
				{"D3_TM"        ,'002'            ,Nil},;
				{"D3_EMISSAO"   ,cTod(cData)      ,Nil},;
				{"D3_CC"        , ''              ,Nil}}
		nQuant := Val(cQtde) - (cB2Alias)->B2_QATU
		Aadd(aSD3 ,{{"D3_COD"		,cCOD        ,Nil},;
			{"D3_LOCAL"		,cLocal	     ,Nil},;
			{"D3_QUANT"		,nQuant      ,Nil}})
	ElseIf Val(cQtde) == 0
		  aCab1 := {{"D3_DOC"       ,cDocumento       ,Nil},;
				{"D3_TM"        ,'502'            ,Nil},;
				{"D3_EMISSAO"   ,cTod(cData)      ,Nil},;
				{"D3_CC"        , ''              ,Nil}}
		Aadd(aSD3 ,{{"D3_COD"		,cCOD        ,Nil},;
			{"D3_LOCAL"		,cLocal	     ,Nil},;
			{"D3_QUANT"		,(cB2Alias)->B2_QATU       ,Nil}})
	ElseIf (cB2Alias)->B2_QATU == 0
	    aCab1 := {{"D3_DOC"       ,cDocumento       ,Nil},;
				{"D3_TM"        ,'002'            ,Nil},;
				{"D3_EMISSAO"   ,cTod(cData)      ,Nil},;
				{"D3_CC"        , ''              ,Nil}}
		Aadd(aSD3 ,{{"D3_COD"		,cCOD        ,Nil},;
			{"D3_LOCAL"		,cLocal	     ,Nil},;
			{"D3_QUANT"		,Val(cQtde)       ,Nil}})
	EndIf
	lMsErroAuto := .F.
	MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab1,aSD3,3)

	If lMsErroAuto
		aLog        := GetAutoGRLog()
		cErro += Replicate("-",39) + CRLF
		cErro += CRLF
		For nY := 1 To Len(aLog)
			cErro += aLog[nY] + CRLF
		Next nY
		cErro += Replicate("-",39) + CRLF
	EndIf
Return

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

