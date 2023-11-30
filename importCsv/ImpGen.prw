#INCLUDE "Protheus.Ch"
#INCLUDE 'TOTVS.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMVCDef.ch'


*******************************************************************************
// Função : U_ImpGen() - Rotina de Importação de Arquivo .CSV				  |
// Modulo : Estoque e Custo                                                   |
// Fonte  : ImpGen.prw                                                        |
// ---------+----------------------------+------------------------------------+
// Data     | Autor             		 | Descricao                          |
// ---------+----------------------------+------------------------------------+
// 13/01/23 | Rivaldo Júnior - Cod.ERP   | Alteração SB1 ou SBZ				  |
*******************************************************************************

User Function ImpGen()

	Local cCaminho := ""
	Local cDirIni  := "C:/"
	Local aRes     := {}

	DEFINE MSDIALOG oDlg TITLE "Importação CSV" From 0,0 To 15,50

	oSayArq := tSay():New(15,07,{|| "Este programa tem como objetivo executar alteração nos dados do produto, onde os mesmos serão importados e diretamente alterados "+;
		"de um arquivo no formato .CSV"+;
		"(Valores Separados por 'Ponto e Vírgula')."},oDlg,,,,,,.T.,,,200,80)

	oSayArq := tSay():New(45,07,{|| "Informe o local onde se encontra o arquivo para importação:"},oDlg,,,,,,.T.,,,200,80)
	oGetArq := TGet():New(55,05,{|u| If(PCount()>0,cCaminho:=u,cCaminho)},oDlg,150,10,'@!',,,,,,,.T.,,,,,,,,,,'cCaminho')

	oBtnArq := tButton():New(55,160,"Abrir...",oDlg,{|| cCaminho := cGetFile( "Arquivos CSV|*.csv|Arquivos CSV|*.csv", "Selecione o arquivo:",  1, cDirIni, .F., GETF_LOCALHARD, , .T. )},30,12,,,,.T.)
	oBtnImp := tButton():New(80,050,"Importar",oDlg,{|| aRes := ImpGen(cCaminho) },40,12,,,,.T.)
	oBtnCan := tButton():New(80,110,"Cancelar",oDlg,{|| oDlg:End()},40,12,,,,.T.)

	ACTIVATE MSDIALOG oDlg CENTERED

Return aRes



	*******************************************************************************
// Função : ImpGen() - Localiza o arquivo CSV   							  |
// Modulo : Estoque e Custo                                                   |
// Fonte  : ImpGen.prw                                                        |
// ---------+----------------------------+------------------------------------+
// Data     | Autor             		 | Descricao                          |
// ---------+----------------------------+------------------------------------+
// 13/01/23 | Rivaldo Júnior - Cod.ERP   | Localiza o arquivo CSV   		  |
	*******************************************************************************

Static Function ImpGen(cCaminho)

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


	*******************************************************************************
// Função : ProcessCSV() - Lê e carrega o arquivo CSV						  |
// Modulo : Estoque e Custo                                                   |
// Fonte  : ImpGen.prw                                                        |
// ---------+----------------------------+------------------------------------+
// Data     | Autor             		 | Descricao                          |
// ---------+----------------------------+------------------------------------+
// 13/01/23 | Rivaldo Júnior - Cod.ERP   | Lê e carrega o arquivo CSV		  |
	*******************************************************************************

Static Function ProcessCSV(cCaminho,oProcess)
	Local cMsgHead  	:= "ICsvNat()"
	Local aRes     		:= {}
	Local aLines  		:= {}
	Local aLinha    	:= {}
	Local aCampos    	:= {}
	Local lManterVazio 	:= .T.
	Local lEnd         	:= .F.
	Local nCount		:= 0
	Private nLinha		:= 2
	Private cError 		:= ""
	Private oFile     	As Object
	Private oTable		As Object

	oFile := FWFileReader():New(cCaminho)
	If oFile:Open() = .F.
		ApMsgStop("Não foi possivel efetuar a leitura do arquivo." + cArq, cMsgHead)
		Return aRes
	EndIf
	aLines := oFile:GetAllLines()

	if lEnd   //VERIFICAR SE NO CLICOU NO BOTAO CANCELAR
		ApMsgStop("Processo cancelado pelo usuário." + cArq, cMsgHead)
		Return aRes
	EndIf

	oProcess:IncRegua1("3/4 Ler Arquivo CSV")
	oProcess:SetRegua2(Len(aLines))

	For nCount:=2 to len(aLines)
		nLinha++

		If lEnd    //VERIFICAR SE NO CLICOU NO BOTAO CANCELAR
			ApMsgStop("Processo cancelado pelo usuário." + cArq, cMsgHead)
			Return {}
		EndIf
		oProcess:IncRegua2("Atualizando registro " + CvalToChar(nCount) + " de " + cValToCHar(Len(aLines)) )
		cLinha  := aLines[nCount]
		If !Empty(cLinha)
			cLinha := StrTran(StrTran(cLinha, '"', ''), ",", ".")
			aLinha := Separa(cLinha, cDelimiter, lManterVazio)

			If nCount == 2 .And. Len(aLinha) > 0
				aAdd(aCampos, aClone(aLinha))//-- Guardo os Campos
			Else
				If len(aCampos[1]) == len(aLinha)
					Do Case
					Case SubStr(aCampos[1,nCount],1,2) == "B1" //-- Caso os Campos sejam da SB1
						UpdateSB1(aCampos, aLinha)
					Case SubStr(aCampos[1,nCount],1,2) == "BZ" //-- Caso os Campos sejam da SBZ
						UpdateSBZ(aCampos, aLinha)
					EndCase
				Else
					ApMsgStop("Quantidade dos valores incorreto." + cArq, cMsgHead)
					Return {}
				Endif
			EndIf
		Else
			cError += "Não há dados a serem alterados!"	
		EndIf
	Next

	oFile:Close()
	oProcess:IncRegua1("4/4 Remove temporarios")
	oProcess:SetRegua2(1)
	oProcess:IncRegua2("")

	If empty(cError)
		FWAlertSuccess("Processo finalizado","Importação CSV concluida")
	Else
		FWAlertError("Processo finalizado","Falha na importação")
		zMsgLog(cError,"Falha na importação",1, .F.)
	EndIf

Return aRes


	*******************************************************************************
// Função : UpdateSB1 - Executa a Alteração na tabela SB1					  |
// Modulo : Estoque e Custo                                                   |
// Fonte  : ImpGen.prw                                                        |
// ---------+----------------------------+------------------------------------+
// Data     | Autor             		 | Descricao                          |
// ---------+----------------------------+------------------------------------+
// 13/01/23 | Rivaldo Júnior - Cod.ERP   | FWMVCRotAuto Alteração		      |
	*******************************************************************************
Static Function UpdateSB1(aCampos, aValores)
	Local nX			:= 0 //-- Posição na linha
	Local aFields 		:= {}
	Local cProd			:= ''
	//Local cErro			:= ''
	Local nValor 		:= 0
	Local lOk			:= .F.
	Local oModel		:= FWLoadModel("MATA010")

	DbSelectArea("SB1")

	For nX := 1 To Len(aValores) //-- Percorro os valores dos campos

		If nX == 2
			cProd := aValores[2] //-- Capturo o Código do Produto
			aAdd(aFields, {"B1_COD", cProd, Nil})
		Else
			If SB1->(DbSetOrder(1), DbSeek(xFilial("SB1")+cProd))
				Do Case
				Case aCampos[1,nX] == "B1_DESC" .And. Empty(aValores[nX])
					aAdd(aFields, {"B1_DESC", SB1->B1_DESC, Nil})
				Case aCampos[1,nX] == "B1_TIPO" .And. Empty(aValores[nX])
					aAdd(aFields, {"B1_TIPO", SB1->B1_TIPO, Nil})
				Case aCampos[1,nX] == "B1_UM" .And. Empty(aValores[nX])
					aAdd(aFields, {"B1_UM", SB1->B1_UM, Nil})
				Case aCampos[1,nX] == "B1_LOCPAD" .And. Empty(aValores[nX])
					aAdd(aFields, {"B1_LOCPAD", SB1->B1_LOCPAD, Nil})
				Case !Empty(aValores[nX]) .And. GetSx3Cache(aCampos[1,nX],"X3_TIPO") == 'N'
					aAdd(aFields,{ aCampos[1,nX], Val(aValores[nX]), NIL}) //-- Caso o campo seja tipo ( Numerico )
					nValor++
				Case !Empty(aValores[nX]) .And. GetSx3Cache(aCampos[1,nX],"X3_TIPO") == 'D'
					aAdd(aFields,{ aCampos[1,nX], CtoD(aValores[nX]), NIL}) //-- Caso o campo seja tipo ( Data )
					nValor++
				Case !Empty(aValores[nX])
					aAdd(aFields,{ aCampos[1,nX], aValores[nX], NIL}) //-- Caso o campo seja tipo ( String , Etc... )
					nValor++
				EndCase
			Else
				cError += "Produto não localizado: "+cProd+", linha: "+cValToChar(nLinha)+Chr(13)+Chr(10)
			EndIf
		EndIf

	Next

	If nValor > 0
		If FWMVCRotAuto(oModel, "SB1", 4, {{"SB1MASTER", aFields}} ,,.T.)//-- operação automática de Alteração
			lOk := .T.
		EndIf
	EndIf

	If oModel <> Nil
		oModel:DeActivate()//-- Desativa o modelo de dados
	EndIf

Return lOk


	*******************************************************************************
// Função : UpdateSBZ - Executa a Alteração na tabela SBZ					  |
// Modulo : Estoque e Custo                                                   |
// Fonte  : ImpGen.prw                                                        |
// ---------+----------------------------+------------------------------------+
// Data     | Autor             		 | Descricao                          |
// ---------+----------------------------+------------------------------------+
// 13/01/23 | Rivaldo Júnior - Cod.ERP   | ExecAuto Alteração			      |
	*******************************************************************************
Static Function UpdateSBZ(aCampos, aValores)
	Local cProd			:= ''
	Local cFil			:= ''
	Local aCab          := {}
	Local nY
	//Local aLog          := {}
	Local nX				:= 0 //-- Posição na linha
	Local nValor 			:= 0
	Local lOk				:= .F.
	Private lMsErroAuto   	:= .F.
	Private lMsHelpAuto   	:= .T.
	Private lAutoErrNoFile	:= .T.

	DbSelectArea("SBZ")
		For nX := 1 To Len(aValores) //-- Percorro os valores dos campos

			If aCampos[1,nX] == "BZ_FILIAL" .And. !Empty(aValores[nX])
				cFil  := aValores[1]
				If cFil <> cFilant
					cError += "Você está na Filial "+cFilant+" e está tentando fazer alteração na Filial "+cFil+"  Linha" +cValToChar(nLinha)+Chr(13)+Chr(10)
					Return lOk				
				else
					aAdd(aCab, {"BZ_FILIAL", cFil, Nil})
				EndIf
			ElseIf aCampos[1,nX] == "BZ_COD" .And. !Empty(aValores[nX])
				cProd := aValores[4] //-- Capturo o Código do Produto
				IIf(Empty(cFil),cFil := cFilAnt,cFil)
				If SBZ->(DbSetOrder(1), DbSeek(cFil+cProd))

				aAdd(aCab, {"BZ_COD", cProd, Nil})
				Else
					cError += "Produto não localizado: "+cProd+", linha: "+cValToChar(nLinha)+Chr(13)+Chr(10)
				EndIf
			Elseif aCampos[1,nX] == "BZ_LOCPAD" .And. Empty(aValores[nX])
						aAdd(aCab, {"BZ_LOCPAD", SBZ->BZ_LOCPAD, Nil})
			Else	
					Do Case
					Case !Empty(aValores[nX]) .And. GetSx3Cache(aCampos[1,nX],"X3_TIPO") == 'N'
						aAdd(aCab,{ aCampos[1,nX], Val(aValores[nX]), NIL}) //-- Caso o campo seja tipo ( Numerico )
						nValor++
					Case !Empty(aValores[nX]) .And. GetSx3Cache(aCampos[1,nX],"X3_TIPO") == 'D'
						aAdd(aCab,{ aCampos[1,nX], CtoD(aValores[nX]), NIL}) //-- Caso o campo seja tipo ( Data )
						nValor++
					Case !Empty(aValores[nX])
						aAdd(aCab,{ aCampos[1,nX], aValores[nX], NIL}) //-- Caso o campo seja tipo ( String , Etc... )
						nValor++
					EndCase
			EndIf
		Next

		If nValor > 0
			MSExecAuto({|v,x| MATA018(v,x)},aCab,4) //-- Rotina automatica de alteração da ( SBZ )

			If !lMsErroAuto
				lOk := .T.
			Else
				//aLog   := GetAutoGRLog()
				//cError := aLog[1]
				aLog        := GetAutoGRLog()
				cError += Replicate("-",39) + CRLF
				cError += CRLF
				For nY := 1 To Len(aLog)
					cError += aLog[nY] + CRLF
				Next nY
				cError += Replicate("-",39) + CRLF
				//MostraErro()
			Endif
		EndIf

		Return lOk


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
	cFileNom := cGetFile( "Arquivo TXT *.txt | *.txt", "Arquivo .txt...",,'',.T., GETF_LOCALHARD,)
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
