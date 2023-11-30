#include "apwebsrv.ch"
#INCLUDE 'RESTFUL.CH'
#include "TbiConn.ch"
#include "topconn.ch"
#include "Totvs.ch"
#include "Protheus.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE 'FWMVCDef.ch'

#DEFINE _OPC_cGETFILE (GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
#Define ENTER Chr(13) + Chr (10)

User function ESTF007()

	Local cCadastro := "Importação Produtos"
	Local lOk		:= .T.
	Local aCabec    := {}
	Local aDados    := {}
	Private lPerg   := .F.
	Private cFilFil := cFilAnt
	Private aPergs  := {}
	Private aButton := {}
	Private aRet    := {}
	Private aSay			:= {}

	aAdd( aSay, "Esta rotina tem como objetivo gerar as informações" )
	aAdd( aSay, "no cadastro de produtos (inclusão/alteração)" )

	//Abre a tela pra escolher a empresa e o arquivo a ser processado
	AADD(aPergs,{1,;					//1 - MsMGet
	"Filial:",;							//2 - Descrição
	cFilFil,;							//3 - Inicializador do cpo
	,;									//4 - Picture
	,;									//5 - Validação
	"XM0",;								//6 - Consulta F3
	,;									//7 - Validação 'When' <- deixar sempre editavel
	50,;								//8 - Tamanho do get
	.T.,;								//9 - Parametro obrigatorio
	})

	aAdd(  aButton, {  5, .T., { || lPerg := ParamBox(aPergs,"Filtro",aRet),  Processa( {|| LeCSV(@aCabec,@aDados) }, "Processando Arquivo..." ) } } ) //Escolhe arquivo
	aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
	aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

	FormBatch( cCadastro, aSay, aButton ,,220,380)

	IF !lPerg .or. Empty(aRet[1])
		Return
	Endif

	IF lOk
		//Processa( {|| Importa(aRet[1],aCabec,aDados) }, "Aguarde...", "Geração do cadastro de produto...",.T.)
		//Processa( {|| Importa(aCabec,aDados) }, "Aguarde...", "Geração do cadastro de produto...",.T.)
		Processa( {|| Importa(aCabec,aDados) }, "Aguarde...", "Geração do cadastro de produto...",.T.)
	EndIf
 
Return

Static Function Importa(aCabec,aDados)
	Local b      := 0
	Local aItens := {}
	Local aRet   := {}
	For b := 1 To Len(aDados)
		aItens := {}
		AADD(aItens,aDados[b])
		aRet := StartJob("U_WCadProd",GetEnvServer(),.T., aCabec,aItens,.T.) // PADRAO//CadProd(aCabIt[1],aCabIt[2])
		If ValType(aRet) == 'A'
			cErro := aRet[1,1]
			If !Empty(cErro)
				MsgInfo(cErro, "Erro ao cadastrar produto - " + aItens[1,4])
			Endif
			aRet := {}
		Endif
	Next
Return

Static Function LeCSV(aCabec,aDados)

	Local cLinha		:= ""
	//Local cStartPath	:= GetSrvProfString("Startpath","")
	Local cExtens		:= "Arquivo CSV ( *.CSV ) |*.CSV|"
	Local cDir			:= cGetFile(cExtens,OemToAnsi("Arquivo Folha"), , , .T., _OPC_cGETFILE)
	Local nX := 1

	//******************************************************
	//                 CARREGA .CSV
	//******************************************************
	If !File(cDir)
		MsgStop("O arquivo " +cDir + " não foi encontrado. A importação será abortada!","ATENCAO")
		Return
	EndIf

	FT_FUSE(cDir)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()

	nCount := 0

	While !FT_FEOF()
		nCount++

		IncProc("Lendo Arquivo...")

		cLinha := FT_FREADLN()

		IF nCount == 1
			aAux := Separa(cLinha,";",.T.)

			//Só começa a contar os campos do cabeçalho a partir da segunda coluna, pois a primeira é repetida com B1_COD (código do produto alterado)
			For nX := 1 to Len(aAux)
				//Verifica se o campo existe na SX3

				DbSelectArea("SB1")
				nPosCpo := FieldPos(aAux[nX])

				//Verifica se o campo do arquivo existe na estrutura de dados
				IF nPosCpo > 0
					aAdd(aCabec,{aAux[nX],,Nil})
				Else
					aAdd(aCabec,{"",,Nil})
				Endif
			Next
		Else
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIF

		FT_FSKIP()
	EndDo

	FT_FUSE()

	IF Len(aDados) <= 0
		MsgAlert("Problemas na leitura do arquivo!")
	Endif

Return

Static Function GetCod(cGrupo, cSbGrupo, cFamilia)

	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cNxAlias 	:= GetNextAlias()
	Local cRet      := ""

	cQuery := " SELECT NVL(MAX(B1_COD),'"+cGrupo+cSbGrupo+cFamilia+"000') AS B1_COD FROM " + RetSqlName("SB1")
	cQuery += " WHERE D_E_L_E_T_ = ' ' " //AND rownum = 1 "
	cQuery += " AND B1_GRUPO = '"+cGrupo+"' AND B1_XSBGRP = '"+cSbGrupo+"' AND B1_XFAMILI = '"+cFamilia+"'"
	cQuery += " AND length(RTRIM(B1_COD)) > 7 "
	If cGrupo == '8009' .And. cSbGrupo == '0003' .And. cFamilia == '001' //Validação para numeração correta, pois inseriram código errado que não pode ser excluido.
		cQuery += " AND SUBSTR(B1_COD,1,7) NOT IN ('8043069') "   
	ElseIf cGrupo == '8009' .And. cSbGrupo == '0001' .And. cFamilia == '001' //Validação para numeração correta, pois inseriram código errado que não pode ser excluido.
		cQuery += " AND SUBSTR(B1_COD,1,7) NOT IN ('8009001') "  	
	ElseIf cGrupo == 'SV00' .And. cSbGrupo == '0092' .And. cFamilia == '001' //Validação para numeração correta, pois inseriram código errado que não pode ser excluido.
		cQuery += " AND SUBSTR(B1_COD,1,7) NOT IN ('SV00092') "  	     
	ElseIf cGrupo == '0201'
		cQuery += " AND SUBSTR(B1_COD,1,11) = '"+cGrupo+cSbGrupo+cFamilia+"' "
	Endif
	cQuery += " ORDER BY B1_COD DESC"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cNxAlias, .F., .T.)

	DbSelectArea(cNxAlias)

	IF !(cNxAlias)->(Eof())
		cRet := Soma1(Alltrim((cNxAlias)->B1_COD))
	Else
		cRet := cGrupo+cSbGrupo+cFamilia+"0001"
	Endif

	IF Select(cNxAlias) > 0
		(cNxAlias)->(DbCloseArea())
	Endif

	RestArea(aArea)

Return cRet

User Function LerArqvo()
	Local ciDirOri := "\\10.0.0.65\sscm\entrada\"
	Local aFiles   := Directory(ciDirOri+"\*.csv", "D")
	Local aCabIt   := {}
	Local aRet     := {}
	Local a        := 0
	Local lAtivAmb := .F.
	Local cProd    := ""
	//Local aProdWF  := {}

	If Select("SX2") <= 0
		RpcClearEnv()
		RpcSetType(3)
		RpcSetEnv("01","020202",,,"FAT",,{})
		lAtivAmb := .T.
	EndIf

	For a := 1 To Len(aFiles)
		aCabIt := LeituraCSV(ciDirOri+'\'+aFiles[a,1])
		aRet := StartJob("U_WCadProd",GetEnvServer(),.T., aCabIt[1],aCabIt[2]) // PADRAO//CadProd(aCabIt[1],aCabIt[2])
		//aRet := u_W2CadProd(aCabIt[1],aCabIt[2])
		cErro := aRet[1,1]
		If Empty(cErro)
			__CopyFile(ciDirOri+'\'+aFiles[a,1], ciDirOri+'\integrado\'+aFiles[a,1]) //copia o arquivo para a pasta integrado
			FERASE(ciDirOri+'\'+aFiles[a,1])
			cProd := aRet[1,2]
			If !Empty(cProd)
				U_UPDZW1(ZW1->(Recno()), cProd, "", "")
			Endif
		else
			__CopyFile(ciDirOri+'\'+aFiles[a,1], ciDirOri+'\naointegrado\'+aFiles[a,1]) //copia o arquivo para a pasta não integrado
			FERASE(ciDirOri+'\'+aFiles[a,1])
			cDe   := GetMv("EL_RLMAIL")
			cPara := "nucleo.cadastral@grupoelizabeth.com.br"
			cCopia     := ""
			cConhCopia := ""
			cAssunto   := "Erro ao cadastrar produto do arquivo: " + ciDirOri + '\' + aFiles[a,1]
			cTexto     := "Segue detalhes. <br> " + cErro
			lHtml      := .F.
			cFile      := ""
			cPara      := U_RetEmail(xFilial("ZW2") + "000001" + "000003")
			U_DrillEmail(cDe,cPara,cCopia,cConhCopia,cAssunto,cTexto,lHtml,cFile)
			//MEMOWRITE( "C:\temp\importa-produto-data-"+dtos(ddatabase)+".log", cErro )
		Endif
	Next

		If aRet[1,3] == "01"
			U_DWFCONT1(cProd)
		Else
			U_DWFCONT0(cProd)
		Endif
	

	If lAtivAmb
		RpcClearEnv()
	Endif

Return

Static Function LeituraCSV(cDir)
	Local cLinha		:= ""
	Local aCabec        := {}
	Local aDados        := {}
	Local nX,nY         := 1
	Local cSeparador    := ';'

	//******************************************************
	//                 CARREGA .CSV
	//******************************************************
	If !File(cDir)
		MsgStop("O arquivo " +cDir + " não foi encontrado. A importação será abortada!","ATENCAO")
		Return
	EndIf

	FT_FUSE(cDir)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()

	nCount := 0

	While !FT_FEOF()
		nCount++

		IncProc("Lendo Arquivo...")

		cLinha := FT_FREADLN()

		IF nCount == 1
			aAux := Separa(cLinha,cSeparador,.T.)

			//Só começa a contar os campos do cabeçalho a partir da segunda coluna, pois a primeira é repetida com B1_COD (código do produto alterado)
			For nX := 1 to Len(aAux)
				//Verifica se o campo existe na SX3
				DbSelectArea("SB1")
				nPosCpo := FieldPos(aAux[nX])

				//Verifica se o campo do arquivo existe na estrutura de dados
				IF nPosCpo > 0
					aAdd(aCabec,{aAux[nX],,Nil})
				Else
					aAdd(aCabec,{"",,Nil})
				Endif
			Next
		Else
			AADD(aDados,Separa(cLinha,cSeparador,.T.))
		EndIF

		FT_FSKIP()
	EndDo

	For nX := 1 To Len(aDados)
		For nY := 1 To Len(aDados[nX])
			aDados[nX,nY] := STRTRAN(aDados[nX,nY],'"','')
		Next
		u_CADZW1(aDados[nX,1], aDados[nX,2], aDados[nX,3], aDados[nX,4], aDados[nX,5], aDados[nX,6], aDados[nX,7], aDados[nX,8], aDados[nX,9], aDados[nX,10], aDados[nX,11], aDados[nX,12], aDados[nX,13], aDados[nX,14], aDados[nX,15], aDados[nX,16], aDados[nX,17])
	Next

	FT_FUSE()

	IF Len(aDados) <= 0
		MsgAlert("Problemas na leitura do arquivo!")
	Endif

Return {aCabec,aDados}


User Function WCadProd(aCabec,aDados,lLote)
	Local oModel        := Nil
	//Local lAtivAmb      := .F.
	//Local oGrupo        := Nil'
	//Local lUpdate       := .F.
	Local nPosGrp   	:= Ascan(aCabec, {|x| AllTrim(x[1]) == "B1_GRUPO"})
	Local nPosCod       := Ascan(aCabec, {|x| AllTrim(x[1]) == "B1_COD"})
	Local nPosSGrp  	:= Ascan(aCabec, {|x| AllTrim(x[1]) == "B1_XSBGRP"})		// 0000
	Local nPosFam   	:= Ascan(aCabec, {|x| AllTrim(x[1]) == "B1_XFAMILI"})		// 000
	Local nPosLcPa  	:= Ascan(aCabec, {|x| AllTrim(x[1]) == "B1_LOCPAD"}) 		// 00
	Local aRet          := {}
	Local cErro         := ""
	Local nX,a          := 0
	Local cProduto      := ""
	Local cTipo         := ""
	Private lMsErroAuto := .F.
	PUBLIC INCLUI       := .T.
	PUBLIC ALTERA       := .F.
	Default lLote       := .F.

	//Abre Ambiente (não deve ser utilizado caso utilize interface ou seja chamado de uma outra rotina que já inicializou o ambiente)
	// Prepara o ambiente caso precise
	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv("01","020202",,,"FAT",,{})

	For a := 1 To Len(aDados)
		aDados[a][nPosSGrp] := Strzero(val(aDados[a][nPosSGrp]),4)
		aDados[a][nPosFam]  := Strzero(val(aDados[a][nPosFam]),3)
		aDados[a][nPosLcPa] := Strzero(val(aDados[a][nPosLcPa]),2)

		oModel  := FwLoadModel("MATA010")

		If !Empty(Posicione("SB1",1,xFilial("SB1")+PADR(aDados[a,nPosCod],TamSx3(aCabec[nPosCod][1])[1]),"B1_DESC"))
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
			INCLUI := .F.
			ALTERA := .T.
		else
			oModel:SetOperation(MODEL_OPERATION_INSERT)
		Endif

		oModel:Activate()

		//informa o b1_cod para não dar erro no b1_tipo
		If Empty(aDados[a][nPosCod])
			cProdInfo := getCod(aDados[a][nPosGrp],aDados[a][nPosSGrp],aDados[a][nPosFam])
			oModel:SetValue("SB1MASTER","B1_COD    "        ,cProdInfo)
		else
			oModel:SetValue("SB1MASTER","B1_COD    "        ,aDados[a][nPosCod])
		Endif

		//omodel:amodelstruct[1][3]:adatamodel[1]
		For nX := 1 to Len(aCabec)
			IF !Empty(aCabec[nX][1]) .And. Alltrim(aCabec[nX][1]) <> "B1_COD"
				If Alltrim(aCabec[nX][1]) == "B1_EMAIL"
					oModel:SetValue("SB1MASTER","B1_XMAILSO",PADR(aDados[a][nX],TamSx3("B1_XMAILSO")[1]))
				elseIf Alltrim(aCabec[nX][1]) == "B1_TIPO"
					oModel:SetValue("SB1MASTER","B1_TIPO",aDados[a][nX])
				else
					oModel:SetValue("SB1MASTER",aCabec[nX][1],PADR(aDados[a][nX],TamSx3(aCabec[nX][1])[1]))
				Endif
			Endif
		Next nY

		//informa o b1_cod pois o gatilho do tipo pode zerar o campo
		If Empty(aDados[a][nPosCod])
			cProdInfo := getCod(aDados[a][nPosGrp],aDados[a][nPosSGrp],aDados[a][nPosFam])
			oModel:SetValue("SB1MASTER","B1_COD    "        ,cProdInfo)
		else
			oModel:SetValue("SB1MASTER","B1_COD    "        ,aDados[a][nPosCod])
		Endif

		//Campos obriagtórios que não são enviados no arquivo
		oModel:SetValue("SB1MASTER","B1_XESTOQ"        ,"N")
		oModel:SetValue("SB1MASTER","B1_RASTRO"        ,"N")
		oModel:SetValue("SB1MASTER","B1_LOCALIZ"       ,"N")
		oModel:SetValue("SB1MASTER","B1_GARANT"        ,"2")

		//Adicionado para atender o chamado 323513
		If aDados[a][nPosGrp] $ GetMv("MV_XGRESTS",,'1101,1201,1301,1401,8009')
			oModel:SetValue("SB1MASTER","B1_XESTOQ"        ,"S")
		Endif

		If !lLote
			oModel:SetValue("SB1MASTER","B1_MSBLQL"        ,"1")
		Endif
	Next

	If oModel:VldData()
		oModel:CommitData()
		cProduto := SB1->B1_COD
		cTipo := SB1->B1_TIPO
	Else
		aErro := oModel:GetErrorMessage()
	EndIf

	oModel:DeActivate()
	oModel:Destroy()

	oModel := NIL

	//Desmonta o ambiente
	RPCClearEnv()

	AADD(aRet,{cErro, cProduto,cTipo})

Return aRet



User Function W2CadProd(aCabec,aDados,lLote)
	Local oModel        := Nil
	Local nPosGrp   	:= Ascan(aCabec, {|x| AllTrim(x[1]) == "B1_GRUPO"})
	Local nPosCod       := Ascan(aCabec, {|x| AllTrim(x[1]) == "B1_COD"})
	Local nPosSGrp  	:= Ascan(aCabec, {|x| AllTrim(x[1]) == "B1_XSBGRP"})		// 0000
	Local nPosFam   	:= Ascan(aCabec, {|x| AllTrim(x[1]) == "B1_XFAMILI"})		// 000
	Local nPosLcPa  	:= Ascan(aCabec, {|x| AllTrim(x[1]) == "B1_LOCPAD"}) 		// 00
	Local aRet          := {}
	Local cErro         := ""
	Local nX,a          := 1
	Local cProduto      := ""
	Private lMsErroAuto := .F.
	PUBLIC INCLUI       := .T.
	PUBLIC ALTERA       := .F.
	Default lLote       := .F.

	//Abre Ambiente (não deve ser utilizado caso utilize interface ou seja chamado de uma outra rotina que já inicializou o ambiente)
	// Prepara o ambiente caso precise
//	RpcClearEnv()
//	RpcSetType(3)
//	RpcSetEnv("01","020202",,,"FAT",,{})

	oModel := FWLoadModel("MATA010")
	aFields := {}

	aDados[1][nPosSGrp] := Strzero(val(aDados[1][nPosSGrp]),4)
	aDados[1][nPosFam]  := Strzero(val(aDados[1][nPosFam]),3)
	aDados[1][nPosLcPa] := Strzero(val(aDados[1][nPosLcPa]),2)

	//informa o b1_cod para não dar erro no b1_tipo
	If Empty(aDados[a][nPosCod])
		cProdInfo := getCod(aDados[a][nPosGrp],aDados[a][nPosSGrp],aDados[a][nPosFam])
		aAdd(aFields, {"B1_COD", cProdInfo, Nil})
	else
		aAdd(aFields, {"B1_COD", aDados[a][nPosCod], Nil})
	Endif

	For nX := 1 to Len(aCabec)
		IF !Empty(aCabec[nX][1]) .And. Alltrim(aCabec[nX][1]) <> "B1_COD"
			If Alltrim(aCabec[nX][1]) == "B1_EMAIL"
				aAdd(aFields, {"B1_XMAILSO", PADR(aDados[a][nX],TamSx3("B1_XMAILSO")[1]), Nil})
			elseIf Alltrim(aCabec[nX][1]) == "B1_TIPO"
				aAdd(aFields, {"B1_TIPO", PADR(aDados[a][nX],TamSx3("B1_TIPO")[1]), Nil})
			else
				aAdd(aFields, {aCabec[nX][1], PADR(aDados[a][nX],TamSx3(aCabec[nX][1])[1]), Nil})
			Endif
		Endif
	Next nY

	//Campos obriagtórios que não são enviados no arquivo
	aAdd(aFields, {"B1_XESTOQ"		  ,"N", Nil})
	aAdd(aFields, {"B1_RASTRO"        ,"N", Nil})
	aAdd(aFields, {"B1_LOCALIZ"       ,"N", Nil})
	aAdd(aFields, {"B1_GARANT"        ,"2", Nil})

	//Se conseguir executar a operação automática
	If FWMVCRotAuto(oModel, "SB1", 3, {{"SB1MASTER", aFields}} ,,.T.)
		lOk := .T.

	Else
		lOk := .F.
	EndIf

	//Se não deu certo a inclusão, mostra a mensagem de erro
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

	//Desmonta o ambiente
//	RPCClearEnv()

	AADD(aRet,{cErro, cProduto})

Return aRet


User Function ConfIntg()
	Local cQuery := ""

	If Select("SX2") <= 0
		RpcClearEnv()
		RpcSetType(3)
		RpcSetEnv("01","020202",,,"FAT",,{})
		lAtivAmb := .T.
	EndIf

	cQuery += "SELECT ZW1_IDPDM, ZW1_PRODUT, R_E_C_N_O_ AS ZW1_RECNO FROM " + RetSqlName("ZW1") + " ZW1 WHERE ZW1_CONINT = ' ' AND ZW1_PRODUT <> ' ' AND D_E_L_E_T_ <> '*' "

	MpSysOpenQuery(cQuery, "TZW")

	While TZW->(!Eof())
		EnviaJson(TZW->ZW1_IDPDM, '{"codigo_erp" : "'+TZW->ZW1_PRODUT+'"}', TZW->ZW1_RECNO)
		TZW->(DbSkip())
	EndDo

	If lAtivAmb
		RpcClearEnv()
	Endif

Return

Static Function EnviaJson(cCodigo, cJson, nZW1Recno)
	Local cAuth     := "Authorization: daf00126-aec0-4feb-b309-8d0e540f51ad"
	Local cContent  := "Content-Type: application/json"
	Local aHeader   := {}
	Local oRest     := FWRest():New("https://sistema.cotacoesecompras.com.br")
	Local oJson     := JSonObject():New()
	Local aArea     := GetArea()

	Aadd(aHeader, cAuth)
	Aadd(aHeader, cContent)

	Conout("https://sistema.cotacoesecompras.com.br/ws/rest/pdm/produtos-saneados/"+cCodigo+"/confirmar-integracao")
	Conout(cJson)

	oRest:setPath("/ws/rest/pdm/produtos-saneados/"+cCodigo+"/confirmar-integracao")
	oRest:SetPostParams(cJson)
	oRest:Post(aHeader)
	cErro := oJSon:fromJson(EncodeUTF8(oRest:GetResult()))

	Conout(oRest:GetResult())

	If !empty(cErro)
		MsgStop(cErro,"JSON PARSE ERROR")
	else
		If Alltrim(oJSon['erro']) <> 'true'
			U_UPDZW1(nZW1Recno, "", "", "OK")
		Endif
	Endif

	RestArea(aArea)

Return

// #########################################################################################
// Projeto: Cadastro de XMl utilizado na importação de DACTE e DANFE	
// Modulo : DACTE e DANFE
// Fonte  : CADXML
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 09/04/13 |Handerson L. Duarte| Cadastro de Caixas de Argamassa
// ---------+-------------------+-----------------------------------------------------------
// 07/03/17 |Lucas-Systop       | Alteracao para tratar arquivos com mais de 65 kbytes
// ---------+-------------------+-----------------------------------------------------------

User Function ZW1INT()

	Private oBrowser	:= FwMBrowse():New()
	oBrowser:SetAlias("ZW1")
	oBrowser:SetDescripton("Integração Dantel")
	//oBrowser:DisableDetails()

	oBrowser:AddLegend( " ZW1_INTEGR=='OK' .AND. ZW1_CONINT=='OK'   "  , "GREEN"   , "Totalmente integrado" )
	oBrowser:AddLegend( " !Empty(ZW1_PRODUT) .OR. ZW1_INTEGR=='OK'  "  , "YELLOW"  , "Produto cadastrado" )
	oBrowser:AddLegend( " Empty(ZW1_INTEGR) .AND. Empty(ZW1_CONINT) "  , "RED"	   , "Registro cadastrado" )

	oBrowser:Activate()

Return()
//=======================Fim do Programa principal=====================================
//=======================Menus e funcionalidades=======================================
Static Function MenuDef ()
	Local aiMenu	:={}

	ADD Option aiMenu Title "Pesquisar" 	Action "PesqBrw" 		Operation 1 Access 0
	ADD Option aiMenu Title "Visualizar"	Action "VIEWDEF.ZW1INT" Operation 2 Access 0

Return(aiMenu)
//=======================Fim dos Menus e funcionalidades===============================    
//=======================Modelo de Dados ==============================================
Static Function ModelDef ()
	Local oStruct := FWFormStruct (1,"ZW1")
	Local oModel
	oModel := MPFormModel ():New("PZW1INT",/*Pre Validacao*/,,/*Commit*/,/*Cancel*/)
	oModel:AddFields ("ID_ZW1_MASTER",/*cOwner*/,oStruct,/*dPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
	oModel:SetPrimaryKey({"ZW1_FILIAL","ZW1_PRODUT"})
	oModel:SetDescription("Integração dos produtos Dantel")
	oModel:GetModel("ID_ZW1_MASTER"):SetDescription("Integração dos produtos Dantel")
Return(oModel)
//=======================Fim do Modelo de Dados ======================================
//=======================Modelo de visão de Dados ====================================
Static Function ViewDef()
	Local oStru 	:= 	FWFormStruct(2,"ZW1")
	Local oModel	:=	FwLoadModel ("ZW1INT")
	Local oView		:=	FwFormView():New()
	oView:SetModel(oModel)
	oView:AddField("ID_VIEW_ZW1INT",oStru,"ID_ZW1_MASTER")
	oView:CreateHorizontalBox("ID_TELA_TOTAL",100)
	oView:SetOwnerView( "ID_VIEW_ZW1INT", "ID_TELA_TOTAL" )
Return (oView)

User Function CADZW1(cProduto, cDesc, cDesc01, cDescom, cTipo, cGrupo, cSbGrupo, cFamilia, cUM, cLocPad, cConta, cPosIPI, cFabric, cRef1, cOrigem, cMailSO, cIdPdm)
	DbSelectArea("ZW1")
	RecLock("ZW1",.T.)
	ZW1->ZW1_FILIAL := xFilial("ZW1")
	ZW1->ZW1_PRODUT := cProduto
	ZW1->ZW1_DESC   := cDesc
	ZW1->ZW1_DESC01 := cDesc01
	ZW1->ZW1_DESCOM := cDescom
	ZW1->ZW1_TIPO   := cTipo
	ZW1->ZW1_GRUPO  := cGrupo
	ZW1->ZW1_SBGRP  := cSbGrupo
	ZW1->ZW1_FAMILI := cFamilia
	ZW1->ZW1_UM     := cUM
	ZW1->ZW1_LOCPAD := cLocPad
	ZW1->ZW1_CONTA  := cConta
	ZW1->ZW1_POSIPI := cPosIPI
	ZW1->ZW1_FABRIC := cFabric
	ZW1->ZW1_REF1   := cRef1
	ZW1->ZW1_ORIGEM := cOrigem
	ZW1->ZW1_MAILSO := cMailSO
	ZW1->ZW1_IDPDM  := cIdPdm
	ZW1->ZW1_DATA   := Date()
	ZW1->(MsUnlock())
Return

User Function UPDZW1(nRecZw1, cProduto, cIntegr, cConInt)
	Local aArea := GetArea()
	Default cProduto := ""
	Default cIntegr  := ""
	Default cConInt  := ""

	DbSelectArea("ZW1")
	DbGoTo(nRecZw1)
	RecLock("ZW1",.F.)
	If !Empty(cProduto)
		ZW1->ZW1_PRODUT := cProduto
	Endif
	If !Empty(cIntegr)
		ZW1->ZW1_INTEGR := cIntegr
	Endif
	If !Empty(cConInt)
		ZW1->ZW1_CONINT := cConInt
	Endif
	ZW1->(MsUnlock())

	RestArea(aArea)

Return
