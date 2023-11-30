#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "Totvs.ch"
#include 'TBICONN.CH'

User Function ImpE1DtB()
	Local cCaminho := ""
	Local cDirIni  := "C:/"
	Local aRes     := {}
	Private cErro 	:= ""
	DEFINE MSDIALOG oDlg TITLE "Executar Baixa automatica de Titulos" From 0,0 To 15,50
	oSayArq := tSay():New(15,07,{|| "Este programa tem como objetivo fazer a Baixa dos titulos , onde os mesmos ser„o importados e diretamente Baixados "+;
		"de um arquivo no formato CSV"+;
		"(Valores Separados por 'Ponto e VÌrgula')."},oDlg,,,,,,.T.,,,200,80)
	oSayArq := tSay():New(45,07,{|| "Informe o local onde se encontra o arquivo para importaÁ„o:"},oDlg,,,,,,.T.,,,200,80)
	oGetArq := TGet():New(55,05,{|u| If(PCount()>0,cCaminho:=u,cCaminho)},oDlg,150,10,'@!',,,,,,,.T.,,,,,,,,,,'cCaminho')
	oBtnArq := tButton():New(55,160,"Abrir...",oDlg,{|| cCaminho := cGetFile( "Arquivos CSV|*.csv|Arquivos CSV|*.csv", "Selecione o arquivo:",  1, cDirIni, .F., GETF_LOCALHARD, .F., .T. )},30,12,,,,.T.)
	oBtnImp := tButton():New(80,050,"Importar",oDlg,{|| aRes := ImpE1DtB1(cCaminho) },40,12,,,,.T.)
	oBtnCan := tButton():New(80,110,"Cancelar",oDlg,{|| oDlg:End()},40,12,,,,.T.)
	ACTIVATE MSDIALOG oDlg CENTERED

Return aRes

Static Function ImpE1DtB1(cCaminho)
	Local oProcess  := nil
	Local aRes      := nil
	Default cIdPlan := "1"
	Default cArq    := ""
	Default cDelimiter := ";"

	If Empty(cCaminho)
		MsgInfo("Selecione um arquivo",)
		Return
	ElseIf !File(cCaminho)
		MsgInfo("Arquivo n„o localizado","AtenÁ„o")
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

	SetFunName("FINA070")
	oFile := FWFileReader():New(cCaminho)
	If oFile:Open() = .F.
		ApMsgStop("N„o foi possÌvel efetuar a leitura do arquivo." + cArq, cMsgHead)
		Return aRes
	EndIf
	aLines := oFile:GetAllLines()
	If lEnd = .T.   //VERIFICAR SE NÔøΩO CLICOU NO BOTAO CANCELAR
		ApMsgStop("Processo cancelado pelo usu·rio." + cArq, cMsgHead)
		Return aRes
	EndIf
	oProcess:IncRegua1("3/4 Ler Arquivo CSV")
	oProcess:SetRegua2(Len(aLines))

	For i:=2 to len(aLines)
		If lEnd = .T.    //VERIFICAR SE NÔøΩO CLICOU NO BOTAO CANCELAR
			ApMsgStop("Processo cancelado pelo usu·rio." + cArq, cMsgHead)
			Return {}
		EndIf
		oProcess:IncRegua2("Atualizando registro " + CvalToChar(i) + " de " + cValToCHar(Len(aLines)) )
		cLinha  := aLines[i]
		If Empty(cLinha) = .F.
			cLinha := StrTran(StrTran(cLinha, '"', ''), ",", ".")
			aLinha := Separa(cLinha, cDelimiter, lManterVazio)
			If Len(aLinha) > 0
				//Filial;Nota;Serie;Data
				Update(aLinha[1],aLinha[2], aLinha[3], aLinha[4], aLinha[5], aLinha[6], aLinha[7],aLinha[8],aLinha[9],aLinha[10],aLinha[11],aLinha[12],aLinha[13],aLinha[14])
			EndIf
		EndIf
	Next i
	oFile:Close()
	oProcess:IncRegua1("4/4 Remove temporarios")
	oProcess:SetRegua2(1)
	oProcess:IncRegua2("")
	If !Empty(cErro)
		zMsgLog(cErro,"Falha na importaÁ„o",1, .F.)
	Else
		MsgInfo("OperaÁ„o concluida com sucesso!")
	EndIf
Return aRes

Static Function Update(cFilx,cSerie,cNota,cParc,cDescont,cJuros,cMulta,cValRec,cbaixa,cMotiBx,cBanco,cAgencia,cConta,cHist)
	Local cValRec1 ,cDescont1 , cJuros1 
	Local nLin , nLin1 , nLin2
	Private cE1Alias  		:= GetNextAlias()
	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile  := .T.
	Private aDados := {}
	If Len(cValRec) > 6 
		cValRec1 := StrTran(cValRec,".","")
		nLin := len(cValRec1)
		cValRec  := stuff(cValRec1, nlin - 1  , 0, ".")
		
	EndIf
	If Len(cDescont) > 6 
		cDescont1 := StrTran(cDescont,".","")
		nLin1 := len(cDescont1)
		cDescont  := stuff(cDescont1, nlin - 1  , 0, ".")
	EndIf
	If Len(cJuros) > 6 
		cJuros1 := StrTran(cJuros,".","")
		nLin2 := len(cJuros1)
		cJuros  := stuff(cJuros1, nlin - 1  , 0, ".")
	EndIf
	BeginSql Alias cE1Alias
		SELECT E1_FILIAL, E1_PREFIXO , E1_NUM , E1_PARCELA , E1_TIPO  
			FROM %Table:SE1% SE1
				WHERE SE1.%notdel%
				AND SE1.E1_FILIAL = %Exp:cFilx%
				AND SE1.E1_PARCELA = %Exp:Padr(cParc,tamSX3('E1_PARCELA')[1])%
				AND SE1.E1_NUM = %Exp:cNota%
				AND SE1.E1_PREFIXO = %Exp:cSerie%
	EndSql
	If (cE1Alias)->(Eof())
		cErro += Replicate("-",39) + CRLF
		cErro += CRLF
		cErro += "Titulo n„o encontrado ou n„o foi possivel Baixar o mesmo "+cNota+" "+cSerie+ CRLF
		cErro += Replicate("-",39) + CRLF
		Return
	EndIf

	DbSelectArea(cE1Alias)
	DbSelectArea('SE1')
	SE1->(dbSetOrder(1))
	If SE1->(dbseek((cE1Alias)->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
		If SE1->E1_SALDO == 0
			cErro += Replicate("-",39) + CRLF
			cErro += CRLF
			cErro += "Titulo j· Baixado" + CRLF
			cErro += Replicate("-",39) + CRLF
		
		else
			StartJob( "U_bxSE1",getenvserver(),.T.,{{"E1_FILIAL" , SE1->E1_FILIAL , Nil},;
			{"E1_PREFIXO"      , SE1->E1_PREFIXO, Nil},;
			{"E1_NUM"          , SE1->E1_NUM    , Nil},;
			{"E1_TIPO"         , SE1->E1_TIPO   , Nil},;
			{"E1_PARCELA"      , SE1->E1_PARCELA, Nil},;
			{"AUTMOTBX"        , cMotiBx        , Nil},;
			{"AUTBANCO"        , cBanco         , Nil},;
			{"AUTAGENCIA"      , cAgencia       , Nil},;
			{"AUTCONTA"        , cConta         , Nil},;
			{"AUTDTBAIXA"      , CtoD(cBaixa)   , Nil},;
			{"AUTDTCREDITO"    , CtoD(cBaixa)   , Nil},;
			{"AUTHIST"         , AllTrim(cHist) , Nil},;
			{"AUTJUROS"        , val(cJuros)    , Nil},;
			{"AUTDESCONT"      , val(cDescont)  , Nil},;
			{"AUTVALREC"       , val(cValrec)   , Nil}})

		EndIf
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
	Default cMsg    := "..."
	Default cTitulo := "zMsgLog"
	Default nTipo   := 1 // 1=Ok; 2= Confirmar e Cancelar
	Default lEdit   := .F.

	//Definindo os textos dos bot√µes
	If(nTipo == 1)
		cTxtConf:='&Ok'
	Else
		cTxtConf:='&Confirmar'
		cTxtCancel:='C&ancelar'
	EndIf

	//Criando a janela centralizada com os bot√µes
	DEFINE MSDIALOG oDlgMens TITLE cTitulo FROM 000, 000  TO 300, 400 COLORS 0, 16777215 PIXEL
	//Get com o Log
	@ 002, 004 GET oMsg VAR cMsg OF oDlgMens MULTILINE SIZE 191, 121 FONT oFntTxt COLORS 0, 16777215 HSCROLL PIXEL
	If !lEdit
		oMsg:lReadOnly := .T.
	EndIf

	//Se for Tipo 1, cria somente o bot√£o OK
	If (nTipo==1)
		@ 127, 144 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 019 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL

		//Sen√£o, cria os bot√µes OK e Cancelar
	ElseIf(nTipo==2)
		@ 127, 144 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 009 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
		@ 137, 144 BUTTON oBtnCnc PROMPT cTxtCancel SIZE 051, 009 ACTION (lRetMens:=.F., oDlgMens:End()) OF oDlgMens PIXEL
	EndIf

	//Bot√£o de Salvar em Txt
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
	//Se o nome n√£o estiver em branco
	If !Empty(cFileNom)
		//Teste de exist√™ncia do diret√≥rio
		If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
			Alert("Diret√≥rio n√£o existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
			Return
		End
		//Montando a mensagem
		cTexto := "Fun√ß√£o   - "+ FunName()       + CRLF
		cTexto += "Usu√°rio  - "+ cUserName       + CRLF
		cTexto += "Data     - "+ dToC(dDataBase) + CRLF
		cTexto += "Hora     - "+ Time()          + CRLF
		cTexto += "Mensagem - "+ cTitulo + cQuebra  + cMsg
		//Testando se o arquivo j√° existe
		If File(cFileNom)
			lOk := MsgYesNo("Arquivo j√° existe, deseja substituir?", "Aten√ß√£o")
		End
		If lOk
			MemoWrite(cFileNom, cTexto)
			MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cFileNom,"Aten√ß√£o")
		EndIf
	EndIf
Return

user Function BxSe1(aDados)

	PREPARE ENVIRONMENT EMPRESA '01' FILIAL aDados[1][2]

	Private lMsErroAuto := .F.

	MSExecAuto({|x,y| Fina070(x,y)},aDados,3)

	Reset Environment
return(lMsErroAuto)
