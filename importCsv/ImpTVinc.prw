#INCLUDE "Protheus.Ch"
#INCLUDE 'TOTVS.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} ImportCsv
@description    Importa arquivo CSV para Executar a alteração no Cadastro de Natureza
                no campo de conta contábil(ED_CONTA).
@author         Rivaldo - Cod.ERP
@since          27/06/2022
@version        1.00
@type 			function
/*/
//-------------------------------------------------------------------
User Function ImpTVinc()

	Local cCaminho := ""
	Local cDirIni  := "C:/"
	Local aRes     := {}

	DEFINE MSDIALOG oDlg TITLE "Importação CSV" From 0,0 To 15,50

	oSayArq := tSay():New(15,07,{|| "Este programa tem como objetivo a alteração no Cadastro de Natureza, onde os mesmos serão importados e diretamente alterados "+;
		"de um arquivo no formato CSV"+;
		"(Valores Separados por 'Ponto e Vírgula')."},oDlg,,,,,,.T.,,,200,80)

	oSayArq := tSay():New(45,07,{|| "Informe o local onde se encontra o arquivo para importação:"},oDlg,,,,,,.T.,,,200,80)
	oGetArq := TGet():New(55,05,{|u| If(PCount()>0,cCaminho:=u,cCaminho)},oDlg,150,10,'@!',,,,,,,.T.,,,,,,,,,,'cCaminho')

	oBtnArq := tButton():New(55,160,"Abrir...",oDlg,{|| cCaminho := cGetFile( "Arquivos CSV|*.csv|Arquivos CSV|*.csv", "Selecione o arquivo:",  1, cDirIni, .F., GETF_LOCALHARD, .F., .T. )},30,12,,,,.T.)
	oBtnImp := tButton():New(80,050,"Importar",oDlg,{|| aRes := ICsvNat(cCaminho) },40,12,,,,.T.)
	oBtnCan := tButton():New(80,110,"Cancelar",oDlg,{|| oDlg:End()},40,12,,,,.T.)

	ACTIVATE MSDIALOG oDlg CENTERED

Return aRes

//-------------------------------------------------------------------
/*/{Protheus.doc} AbreCsv
@description    Localiza o arquivo CSV
@author         Rivaldo - Cod.Erp
@since          27/06/2022
@version        1.00
@type 			function
/*/
//-------------------------------------------------------------------

Static Function ICsvNat(cCaminho)

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

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcessCSV
@description    Lê e carrega o arquivo CSV
@author         Rivaldo - Cod.ERP
@since          27/06/2022
@version        1.00
@type 			function
/*/
//-------------------------------------------------------------------

Static Function ProcessCSV(cCaminho,oProcess)

	Local nX
	Local cMsgHead  	:= "ICsvNat()"
	Local aRes     		As Array
	Local aLines  		As Array
	Local aLinha    	As Array
	Local aCampos       := {}
	Local oFile     	As Object
	Local lManterVazio 	:= .T.
	Local lEnd         	:= .F.
	PRIVATE lMsErroAuto := .F.
	Private oTable		As Object

	oFile := FWFileReader():New(cCaminho)
	If oFile:Open() = .F.
		ApMsgStop("Não foi possvel efetuar a leitura do arquivo." + cArq, cMsgHead)
		Return aRes
	EndIf
	aLines := oFile:GetAllLines()
	if lEnd == .T.   //VERIFICAR SE NO CLICOU NO BOTAO CANCELAR
		ApMsgStop("Processo cancelado pelo usuário." + cArq, cMsgHead)
		Return aRes
	EndIf
	oProcess:IncRegua1("3/4 Ler Arquivo CSV")
	oProcess:SetRegua2(Len(aLines))

	oTable  := FWTemporaryTable():New("TMP")
	AAdd(aCampos,{"TMP_CODORI"  ,"C",10,0})
	AAdd(aCampos,{"TMP_CODDES"  ,"C",15,0})
	AAdd(aCampos,{"TMP_CONVER"  ,"C",06,0})
	AAdd(aCampos,{"TMP_TPCONV"  ,"C",01,0})

	//aAdd(aCampos,{TMP_CODORI , TamSx3('ZR0_COD')[1]    })
	//aAdd(aCampos,{TMP_CODDES , TamSx3('ZR1_COD')[1]    })
	//aAdd(aCampos,{TMP_CONVER , TamSx3('ZR1_CONV')[1]   })
	//aAdd(aCampos,{TMP_TIPCONV, TamSx3('ZR1_TIPCONV')[1]})

	oTable:SetFields(aCampos)// Adiciono os campos na tabela
	oTable:AddIndex('01', {'TMP_CODORI'})//Crio o Index da Tabela
	oTable:Create()// Crio a tabela no banco de dados

	DbSelectArea("TMP")

	For nX:=3 to len(aLines)
		if lEnd = .T.    //VERIFICAR SE NO CLICOU NO BOTAO CANCELAR
			ApMsgStop("Processo cancelado pelo usuário." + cArq, cMsgHead)
			Return {}
		EndIf
		oProcess:IncRegua2("Atualizando registro " + CvalToChar(nX) + " de " + cValToCHar(Len(aLines)) )
		cLinha  := aLines[nX]
		If Empty(cLinha) = .F.
			cLinha := StrTran(StrTran(cLinha, '"', ''), ",", ".")
			aLinha := Separa(cLinha, cDelimiter, lManterVazio)
			If Len(aLinha) > 0
				TMP->(RecLock('TMP', .T.))
				TMP->TMP_CODORI  :=	aLinha[1]
				TMP->TMP_CODDES  :=	aLinha[2]
				TMP->TMP_CONVER  :=	aLinha[3]
				TMP->TMP_TPCONV :=	aLinha[4]
				TMP->(MsUnLock())
				TMP->(DbSkip())
			EndIf
		EndIf
	Next
	if Len(aLinha) > 0
	 	update()
	else
		oFile:Close()
	ENDIF
	oProcess:IncRegua1("4/4 Remove temporarios")
	oProcess:SetRegua2(1)
	oProcess:IncRegua2("")

	MsgInfo("Processo finalizado.")

Return aRes

//-------------------------------------------------------------------
/*/{Protheus.doc} Update
@description    Executa a Alteração Via FwMvcRotAuto
@author         Rivaldo - Cod.ERP
@since          27/06/2022
@version        1.00
@type 			function
/*/
//-------------------------------------------------------------------

Static Function Update()//Update(cProO, cProD, cConv, cTipCon, nX)
	Local lOk       := .F.
	Local oModel    := FWLoadModel("TelVinc")//pegando o modelo de dados
	Local oZR0Mod 	:= oModel:GetModel("ZR0MASTER")
	Local oZR1Mod 	:= oModel:GetModel("ZR1DETAIL")

	oModel:SetOperation(3)//setando a operação de inclusão
	oModel:Activate()//ativando o modelo de dados

	DbSelectArea("TMP")
	TMP->(DBGOTOP())

	While TMP->(!Eof())
		cChave := AllTrim(TMP->TMP_CODORI)
		oZR0Mod:SetValue("ZR0_COD", cChave )// Seta o Campo do Cabeçalho
		While TMP->(!Eof()) .And. AllTrim(TMP->TMP_CODORI) == cChave
			OZR1Mod:addLine()
			//Setando os campos dos Itens
			oZR1Mod:SetValue("ZR1_COD"   , allTrim(TMP->TMP_CODDES)     )
			oZR1Mod:SetValue("ZR1_CONV"  , Val(allTrim(TMP->TMP_CONVER))     )
			oZR1Mod:SetValue("ZR1_TIPCON", allTrim(TMP->TMP_TPCONV)    )
	
			//oZR1Mod:SkipLine()
			TMP->(DbSkip())
		End

		//Se conseguir validar as informações
		If oModel:VldData()
			If oModel:CommitData()//Tenta realizar o Commit
				lOk := .T.
			EndIf
		EndIf

		//Se não deu certo a inclusão, mostra a mensagem de erro
		If lOk == .F.
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
			ConOut("Erro: " + cMessage) 
		Else
			ConOut("Produto incluido!")
		EndIf
	End

	If ValType(oModel) == 'O'
		oModel:DeActivate()//Desativa o modelo de dados
	EndIf

	oTable:Delete()
	FreeObj(oTable)
	TMP->(DbCloseArea())


Return
