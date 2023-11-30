#INCLUDE 'TOTVS.CH'

User Function ImpCsvB2()
	Local cCaminho := ""
	Local cDirIni  := "C:/"
	Local aRes     := {}
	Private cErro 	:= ""
	DEFINE MSDIALOG oDlg TITLE "Atualização do Saldo" From 0,0 To 15,50
	oSayArq := tSay():New(15,07,{|| "Este programa tem como objetivo Atualizar o Saldo "+;
		"de um arquivo no formato CSV"+;
		"(Valores Separados por 'Ponto e Virgula')."},oDlg,,,,,,.T.,,,200,80)
	oSayArq := tSay():New(45,07,{|| "Informe o local onde se encontra o arquivo para importação:"},oDlg,,,,,,.T.,,,200,80)
	oGetArq := TGet():New(55,05,{|u| If(PCount()>0,cCaminho:=u,cCaminho)},oDlg,150,10,'@!',,,,,,,.T.,,,,,,,,,,'cCaminho')
	oBtnArq := tButton():New(55,160,"Abrir...",oDlg,{|| cCaminho := cGetFile( "Arquivos CSV|*.csv|Arquivos CSV|*.csv", "Selecione o arquivo:",  1, cDirIni, .F., GETF_LOCALHARD, .F., .T. )},30,12,,,,.T.)
	oBtnImp := tButton():New(80,050,"Importar",oDlg,{|| aRes := ImpCsvB21(cCaminho) },40,12,,,,.T.)
	oBtnCan := tButton():New(80,110,"Cancelar",oDlg,{|| oDlg:End()},40,12,,,,.T.)
	ACTIVATE MSDIALOG oDlg CENTERED

Return aRes

Static Function ImpCsvB21(cCaminho)
	Local oProcess  := nil
	Local aRes      := nil
	Default cIdPlan := "1"
	Default cArq    := ""
	Default cDelimiter := ";"

	If Empty(cCaminho)
		MsgInfo("Selecione um arquivo",)
		Return
	ElseIf !File(cCaminho)
		MsgInfo("Arquivo nÃ£o localizado","AtenÃ§Ã£o")
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
		ApMsgStop("Não foi possivel efetuar a leitura do arquivo." + cArq, cMsgHead)
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
				Update(aLinha[1],aLinha[2], aLinha[3], aLinha[4], aLinha[5],aLinha[6],aLinha[7],aLinha[8],aLinha[9],aLinha[10])
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
		MsgInfo("Operação concluida com sucesso!")
	EndIf
Return aRes

Static Function Update(cCodigo,cTipoMt,cArmazem,cDoc,nQuant,dDataInv,cLote,cDtValid,cContag,cCusto)

	Local cB2Alias      := GetNextAlias()
	Local nCusto := val(cCusto)
	Local nCustoUni := 0
	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile  := .T.

	BeginSql Alias cB2Alias
		SELECT B2_FILIAL , B2_COD ,B2_LOCAL ,B2_CM1,B2_QATU From  %Table:SB2% SB2 
        WHERE B2_COD = %Exp:cCodigo%
        AND B2_LOCAL = %Exp:cArmazem%
        AND B2_FILIAL = %Exp:cFilAnt%
	EndSql

	DbSelectArea('SB2')
	DbsetOrder(1)
	If DbSeek((cB2Alias)->(B2_FILIAL+B2_COD+B2_LOCAL))
		nCustoUni := nCusto/(cB2Alias)->B2_QATU
		Reclock( 'SB2', .F.)
		SB2->B2_CM1 := nCustoUni
		SB2->(MsUnlock())
	Else
		cErro += "Saldo não encontrado do produto Cod = "+cCodigo+" Local = "+cArmazem+" " +CRLF
	EndIf

Return
