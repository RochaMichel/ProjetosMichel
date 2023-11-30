#INCLUDE 'TOTVS.CH'
/*/{Protheus.doc} ImpE2Dtv
Ajuste em massa de vencimento de titulos
@type function
@author Michel Rocha
/*/

User Function ImpF2()
	Local cCaminho := ""
	Local cDirIni  := "C:/"
	Local aRes     := {}
	Private cErro 	:= ""
	DEFINE MSDIALOG oDlg TITLE "Atualização da tabela SF2 " From 0,0 To 15,50
	oSayArq := tSay():New(15,07,{|| "Este programa tem como objetivo a alterar as tabela SF2, onde os mesmos serão importados e diretamente alterados "+;
		"de um arquivo no formato CSV"+;
		"(Valores Separados por 'Ponto e virgula')."},oDlg,,,,,,.T.,,,200,80)
	oSayArq := tSay():New(45,07,{|| "Informe o local onde se encontra o arquivo para importação:"},oDlg,,,,,,.T.,,,200,80)
	oGetArq := TGet():New(55,05,{|u| If(PCount()>0,cCaminho:=u,cCaminho)},oDlg,150,10,'@!',,,,,,,.T.,,,,,,,,,,'cCaminho')
	oBtnArq := tButton():New(55,160,"Abrir...",oDlg,{|| cCaminho := cGetFile( "Arquivos CSV|*.csv|Arquivos CSV|*.csv", "Selecione o arquivo:",  1, cDirIni, .F., GETF_LOCALHARD, .F., .T. )},30,12,,,,.T.)
	oBtnImp := tButton():New(80,050,"Importar",oDlg,{|| aRes := ImpF21(cCaminho) },40,12,,,,.T.)
	oBtnCan := tButton():New(80,110,"Cancelar",oDlg,{|| oDlg:End()},40,12,,,,.T.)
	ACTIVATE MSDIALOG oDlg CENTERED

Return aRes

Static Function ImpF21(cCaminho)
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
		ApMsgStop("não foi possivel efetuar a leitura do arquivo." + cArq, cMsgHead)
		Return aRes
	EndIf
	aLines := oFile:GetAllLines()
	If lEnd = .T.   //VERIFICAR SE Nï¿½O CLICOU NO BOTAO CANCELAR
		ApMsgStop("Processo cancelado pelo usuario." + cArq, cMsgHead)
		Return aRes
	EndIf
	oProcess:IncRegua1("3/4 Ler Arquivo CSV")
	oProcess:SetRegua2(Len(aLines))

	For i:=2 to len(aLines)
		If lEnd = .T.    //VERIFICAR SE Nï¿½O CLICOU NO BOTAO CANCELAR
			ApMsgStop("Processo cancelado pelo usuario." + cArq, cMsgHead)
			Return {}
		EndIf
		oProcess:IncRegua2("Atualizando registro " + CvalToChar(i) + " de " + cValToCHar(Len(aLines)) )
		cLinha  := aLines[i]
		If Empty(cLinha) = .F.
			cLinha := StrTran(StrTran(cLinha, '"', ''), ",", ".")
			aLinha := Separa(cLinha, cDelimiter, lManterVazio)
			If Len(aLinha) > 0
				//Filial;Nota;Serie;Data
				Update(aLinha[1],aLinha[2], aLinha[3], aLinha[4], aLinha[5], aLinha[6], aLinha[7], aLinha[8], aLinha[9])
			EndIf
		EndIf
	Next i
	oFile:Close()
	oProcess:IncRegua1("4/4 Remove temporarios")
	oProcess:SetRegua2(1)
	oProcess:IncRegua2("")
	If !Empty(cErro)
		Msginfo(cErro,"Falha na importação")
	Else
		MsgInfo("Operação concluida com sucesso!")
	EndIf
Return aRes

Static Function Update(cFil,cDoc,cSerie,cCliente,cLoja,cBaseF5,cBaseF6,cValF5,cValF6)
	
	DbSelectArea( 'SF2' )
	SF2->( dbSetOrder( 1 ) )
    If SF2->(dbseek(AllTrim(cFil+cDoc+cSerie+cCliente+cLoja)))
        SF2->(RecLock("SF2", .F.))
			SF2->F2_BASIMP6 :=	Val(cBaseF5)
			SF2->F2_BASIMP5 :=  Val(cBaseF6)
			SF2->F2_VALIMP5	 := Val(cValF5)
			SF2->F2_VALIMP6  := Val(cValF6)
        SF2->(MsUnlock())
	Else 
		cErro := 'Não encontrado nota '+cDoc 
    EndIf		
	SF2->(DbCloseArea())
Return 
