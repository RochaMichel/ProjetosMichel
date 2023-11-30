#INCLUDE "Protheus.Ch"
#INCLUDE 'TOTVS.CH'

User Function ImportCsv ()

	Local cCaminho := ""
	Local cDirIni  := "C:\Users\Robert Callfman\Downloads\"
	Local aRes     := {}

	DEFINE MSDIALOG oDlg TITLE "Importa��o CSV" From 0,0 To 15,50

	oSayArq := tSay():New(15,07,{|| "Este programa tem como objetivo a altera��o no pedido de vendas, onde os mesmos ser�o importados e diretamente alterados "+;
		"de um arquivo no formato CSV"+;
		"(Valores Separados por 'Ponto e V�rgula')."},oDlg,,,,,,.T.,,,200,80)

	oSayArq := tSay():New(45,07,{|| "Informe o local onde se encontra o arquivo para importa��o:"},oDlg,,,,,,.T.,,,200,80)
	oGetArq := TGet():New(55,05,{|u| If (PCount()>0,cCaminho:=u,cCaminho)},oDlg,150,10,'@!',,,,,,,.T.,,,,,,,,,,'cCaminho')

	oBtnArq := tButton():New(55,160,"Abrir...",oDlg,{|| cCaminho := cGetFile( "Arquivos CSV|*.CSV|", "Selecione o arquivo:",  1, cDirIni, .F., GETF_LOCALHARD, .F., .T. )},30,12,,,,.T.)
	oBtnImp := tButton():New(80,050,"Importar",oDlg,{|| aRes := ImportCsv(cCaminho) },40,12,,,,.T.)
	oBtnCan := tButton():New(80,110,"Cancelar",oDlg,{|| oDlg:End()},40,12,,,,.T.)

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
		MsgInfo("Arquivo n�o localizado","Aten��o")
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
		cLinha  := aLines[i]
		If Empty(cLinha) = .F.
			cLinha := StrTran(StrTran(cLinha, '"', ''), ",", ".")
			aLinha := Separa(cLinha, cDelimiter, lManterVazio)
			If Len(aLinha) > 0
				Update(aLinha[1],aLinha[2], aLinha[3],aLinha[4],aLinha[5],i)
			EndIf
		EndIf
	Next i
	oFile:Close()
	oProcess:IncRegua1("4/4 Remove temporarios")
	oProcess:SetRegua2(1)
	oProcess:IncRegua2("")

	MsgInfo("Processo finalizado.")

Return 
Static Function Update(Cod, desc, tipo , uni , arma,i)
oModel := FWLoadModel("MATA010")
aFields := {}
 
aAdd(aFields, {"B1_COD", Cod, Nil})
aAdd(aFields, {"B1_DESC", desc, Nil})
aAdd(aFields, {"B1_TIPO", tipo, Nil})
aAdd(aFields, {"B1_UM", uni, Nil})
aAdd(aFields, {"B1_LOCPAD", arma, Nil})
//Se conseguir executar a operação automática
If FWMVCRotAuto(oModel, "SB1", 3, {{"SB1MASTER", aFields}} ,,.T.)
    lOk := .T.
     
Else
    lOk := .F.
EndIf
If ! lOk
    //Busca o Erro do Modelo de Dados
    aErro := oModel:GetErrorMessage()
       
    //Monta o Texto que será mostrado na tela
    cMessage := "Id do formulário de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
    cMessage += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
    cMessage += "Id do formulário de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
    cMessage += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
    cMessage += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
    cMessage += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], '
    cMessage += "Mensagem da solução: "        + ' [' + cValToChar(aErro[07]) + '], '
    cMessage += "Valor atribuído: "            + ' [' + cValToChar(aErro[08]) + '], '
    cMessage += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'
     
    //Mostra mensagem de erro
    lRet := .F.
    ConOut("Erro: " + cMessage)
     
Else
    lRet := .T.
    ConOut("Produto excluido")
EndIf
   
//Desativa o modelo de dados
oModel:DeActivate()
   
Return






