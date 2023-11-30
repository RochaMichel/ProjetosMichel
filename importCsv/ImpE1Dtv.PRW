#INCLUDE 'TOTVS.CH'

User Function ImpE1Dtv()
	Local cCaminho := ""
	Local cDirIni  := "C:/"
	Local aRes     := {}
	Private cErro 	:= ""
	DEFINE MSDIALOG oDlg TITLE "Atualização de Títulos x Data de embarque" From 0,0 To 15,50
	oSayArq := tSay():New(15,07,{|| "Este programa tem como objetivo a alteração dos vencimentos, onde os mesmos serão importados e diretamente alterados "+;
		"de um arquivo no formato CSV"+;
		"(Valores Separados por 'Ponto e Vírgula')."},oDlg,,,,,,.T.,,,200,80)
	oSayArq := tSay():New(45,07,{|| "Informe o local onde se encontra o arquivo para importação:"},oDlg,,,,,,.T.,,,200,80)
	oGetArq := TGet():New(55,05,{|u| If(PCount()>0,cCaminho:=u,cCaminho)},oDlg,150,10,'@!',,,,,,,.T.,,,,,,,,,,'cCaminho')
	oBtnArq := tButton():New(55,160,"Abrir...",oDlg,{|| cCaminho := cGetFile( "Arquivos CSV|*.csv|Arquivos CSV|*.csv", "Selecione o arquivo:",  1, cDirIni, .F., GETF_LOCALHARD, .F., .T. )},30,12,,,,.T.)
	oBtnImp := tButton():New(80,050,"Importar",oDlg,{|| aRes := ImpE1Dtv1(cCaminho) },40,12,,,,.T.)
	oBtnCan := tButton():New(80,110,"Cancelar",oDlg,{|| oDlg:End()},40,12,,,,.T.)
	ACTIVATE MSDIALOG oDlg CENTERED

Return aRes

Static Function ImpE1Dtv1(cCaminho)
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

	SetFunName("FINA040")
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
				Update(aLinha[1],aLinha[2], aLinha[3], aLinha[4], aLinha[5], aLinha[6])
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

Static Function Update(cFilx,cNota,cSerie,dDtVenc,cParc,cHist)
	//Local aLog   	:= {}
	//Local nY
	//Local aSE1      := {}
	Local dDtVencRe 		:= DataValida(CTOD(dDtVenc),.T.)
	Local cE1Alias  		:= GetNextAlias()
	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile  := .T. 
	
	BeginSql Alias cE1Alias
		SELECT E1_FILIAL, E1_PREFIXO , E1_NUM , E1_PARCELA , E1_TIPO, E1_XOBSTA   
			FROM %Table:SE1% SE1
			INNER JOIN %Table:SA1% SA1
				ON SE1.E1_CLIENTE = SA1.A1_COD
				AND SE1.E1_LOJA = SA1.A1_LOJA
				WHERE SE1.%notdel%
				AND SA1.A1_EST = 'EX'
				AND SE1.E1_FILIAL = %Exp:cFilx%
				AND SE1.E1_PARCELA = %Exp:Padr(cParc,tamSX3('E1_PARCELA')[1])%
				AND SE1.E1_SALDO > 0
				AND SE1.E1_NUM = %Exp:cNota%
				AND SE1.E1_TIPO = 'NF'
				AND SE1.E1_PREFIXO = %Exp:cSerie%
	EndSql
	If (cE1Alias)->(Eof())
		cErro += Replicate("-",39) + CRLF
			cErro += CRLF
			cErro += "Titulo não encontrado ou não foi possivel alterar o mesmo "+cNota+" "+cSerie+ CRLF
			cErro += Replicate("-",39) + CRLF
			Return 
	EndIf
	DbSelectArea(cE1Alias)
	DbSelectArea( 'SE1' )
	SE1->( dbSetOrder( 1 ) )
		If SE1->(dbseek((cE1Alias)->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
			SE1->(RecLock("SE1", .F.))
               SE1->E1_VENCTO  := CTOD(dDtVenc) 
               SE1->E1_VENCREA := dDtVencRe
			   SE1->E1_XOBSTA  := cHist
			   SE1->E1_XOCCOB  := "1"
            SE1->(MsUnlock())
			//aAdd( aSE1, { 'E1_FILIAL ', SE1->E1_FILIAL      , NIL } )
			//aAdd( aSE1, { 'E1_PREFIXO', SE1->E1_PREFIXO     , NIL } )
			//aAdd( aSE1, { 'E1_NUM    ', SE1->E1_NUM         , NIL } )
			//aAdd( aSE1, { 'E1_PARCELA', SE1->E1_PARCELA     , NIL } )
			//aAdd( aSE1, { 'E1_TIPO   ', SE1->E1_TIPO        , NIL } )
			//aAdd( aSE1, { 'E1_EMISSAO', SE1->E1_EMISSAO     , NIL } )
			//aAdd( aSE1, { 'E1_VENCTO ', CTOD(dDtVenc)       , NIL } )
			//aAdd( aSE1, { 'E1_VENCREA', dDtVencRe           , NIL } )
			//lMsErroAuto := .F.
			//MSExecAuto({| x, y | FINA040( x, y ) }, aSE1, 4 )
		EndIf		
		//If lMsErroAuto
		//	aLog        := GetAutoGRLog()
		//	cErro += Replicate("-",39) + CRLF
		//	cErro += CRLF
		//	For nY := 1 To Len(aLog)
		//		cErro += aLog[nY] + CRLF
		//	Next nY
		//	cErro += Replicate("-",39) + CRLF
		//EndIf	
Return 

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

