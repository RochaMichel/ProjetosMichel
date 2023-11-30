#INCLUDE 'TOTVS.CH'


User Function ImportCsv ()

	Local cCaminho := ""
	Local cDirIni  := "C:/"
	Local aRes     := {}

	DEFINE MSDIALOG oDlg TITLE "Atualização Títulos x Data de embarque" From 0,0 To 15,50

	oSayArq := tSay():New(15,07,{|| "Este programa tem como objetivo a alteração dos vencimentos, onde os mesmos serão importados e diretamente alterados "+;
		"de um arquivo no formato CSV"+;
		"(Valores Separados por 'Ponto e Vírgula')."},oDlg,,,,,,.T.,,,200,80)

	oSayArq := tSay():New(45,07,{|| "Informe o local onde se encontra o arquivo para importação:"},oDlg,,,,,,.T.,,,200,80)
	oGetArq := TGet():New(55,05,{|u| If(PCount()>0,cCaminho:=u,cCaminho)},oDlg,150,10,'@!',,,,,,,.T.,,,,,,,,,,'cCaminho')

	oBtnArq := tButton():New(55,160,"Abrir...",oDlg,{|| cCaminho := cGetFile( "Arquivos CSV|*.csv|Arquivos CSV|*.csv", "Selecione o arquivo:",  1, cDirIni, .F., GETF_LOCALHARD, .F., .T. )},30,12,,,,.T.)
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
	if lEnd = .T.   //VERIFICAR SE NO CLICOU NO BOTAO CANCELAR
		ApMsgStop("Processo cancelado pelo usuário." + cArq, cMsgHead)
		Return aRes
	EndIf
	oProcess:IncRegua1("3/4 Ler Arquivo CSV")
	oProcess:SetRegua2(Len(aLines))

	For i:=2 to len(aLines)
		if lEnd = .T.    //VERIFICAR SE NO CLICOU NO BOTAO CANCELAR
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
				Update(aLinha[1],aLinha[2], aLinha[3], aLinha[4])
			EndIf
		EndIf
	Next
	oFile:Close()
	oProcess:IncRegua1("4/4 Remove temporarios")
	oProcess:SetRegua2(1)
	oProcess:IncRegua2("")

	MsgInfo("Processo finalizado.")

Return aRes



Static Function Update(cFilx,cNota,cSerie,dDtVenc)
	Local lRet      := .F.
	Local aSE1      := {}
	Local dDtVencRe := DataValida(dDtVenc,.T.)

	Local  cE1Alias  := GetNextAlias()

	Private lMsErroAuto := .F.

	BeginSql Alias cE1Alias
		SELECT SE1.R_E_C_N_O_ REC 
			FROM %Table:SE1% SE1
			INNER JOIN 
				WHERE SE1.%notdel%
				AND SE1.E1_FILIAL = %Exp:cFilx%
				AND SE1.E1_NUM =  %Exp:cNota%
				AND SE1.E1_PREFIXO =  %Exp:cSerie%
				AND SE1.E1_TIPO =  %Exp:cCodB2%
				AND SE1.E1_VALOR = E1_SALDO
	EndSql

	SE1->( dbGoTo( nRecnoSE1 ) )

	Begin Transaction



		DbSelectArea( 'SE1' )
		SE1->( dbSetOrder( 1 ) )
		cSE1Key := SE1->(xFilial+cSerie+cNota)


		aAdd( aSE1, { 'E1_FILIAL ', SE1->E1_FILIAL      , NIL } )
		aAdd( aSE1, { 'E1_PREFIXO', SE1->E1_PREFIXO     , NIL } )
		aAdd( aSE1, { 'E1_NUM    ', SE1->E1_NUM         , NIL } )
		aAdd( aSE1, { 'E1_PARCELA', SE1->E1_PARCELA     , NIL } )
		aAdd( aSE1, { 'E1_TIPO   ', SE1->E1_TIPO        , NIL } )
		aAdd( aSE1, { 'E1_EMISSAO', SE1->E1_EMISSAO     , NIL } )
		aAdd( aSE1, { 'E1_VENCTO ', dDtVenc             , NIL } )
		aAdd( aSE1, { 'E1_VENCREA', dDtVencRe           , NIL } )



		lMsErroAuto := .F.

		MSExecAuto( { | _x, _y | FINA040( _x, _y ) }, aSE1, 4 )

		If lMsErroAuto
			lRet := .F.
			DisarmTransaction()
		Else
			lRet := .T.
		EndIf


	End Transaction



Return lRet

