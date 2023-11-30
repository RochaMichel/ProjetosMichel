#Include "Totvs.ch"
#Include 'Protheus.ch'

User Function wfPro4()
	Local lOk           := .T.
	Local cFolderLyt    := 'workflow\html\'
	Local cLayoutHTML   := 'tabprz4.html'
	Local lAtivWFPro    := SUPERGETMV("MV_ZATIVWFP", .F., .T.)
	Local cUserAprov    := SUPERGETMV("MV_ZUSRAPRO", .T., '000000') //Usuário aprovador do processo, código e não nome de usuário
	Local cMailAprov    := 'rivaldogfj@hotmail.com'
	Local cContaWF      := "fecona5393geekjun@outlook.com" //Conta de e-mail para recebimento da resposta do WF
	Local cUsrProcess   := '000000'
	Local cLink         := ''
	Local cWSLink       := 'http://192.168.0.14:8080/'
	Local cCodPro 	    := "0001"

	Private oHtml
	//Se o e-mail do aprovador for valido entra na condição
	IF ISEMAIL(cMailAprov) .and. lAtivWFPro
		oProcess := TWFProcess():New( "WFWPRO", "WorkFLow Fiscal" )
		oProcess:NewTask( "WorkFLow fiscal", cFolderLyt+cLayoutHTML )
		oProcess:cTo          :=  cUsrProcess     //Codigo do usuario ou email
		oProcess:bReturn    := "U_wfPrd4()"
		oProcess:cSubject   := "WorkFLow Fiscal  "
		oProcess:UserSiga   := cUserAprov     //"000000"
		oProcess:NewVersion(.T.)

		oHtml := oProcess:oHTML

		oHtml:ValByName( "B1_COD" 	  ,EncodeUtf8(cCodPro))
		oHtml:ValByName( "B1_DESC" 	  ,EncodeUtf8(posicione("SB1",1,xFilial('SB1')+cCodPro,"B1_DESC") ))
		oHtml:ValByName( "B1_IPI"     ,EncodeUtf8(alltrim( SB1->B1_IPI    )))
		oHtml:ValByName( "B1_CEST"    ,EncodeUtf8(alltrim( SB1->B1_CEST   )))
		oHtml:ValByName( "B1_GRTRIB"  ,EncodeUtf8(alltrim( SB1->B1_GRTRIB )))


		oProcess:nEncodeMime := 0
		//Iniciando e gravando aquivo do processo
		cProcess := oProcess:Start("\workflow\messenger\emp" +cEmpAnt  + "\" + cUsrProcess + "\")
		//Carregando nome do arquivo html gerado
		cHtmlFile  := cProcess + ".htm"
		cMailTo    := "mailto:" + cContaWF

		//Lendo arquivo e armazenando na variavel
		cHtml := wfloadfile("\workflow\messenger\emp" +cEmpAnt  + "\" + cUsrProcess + "\" + cHtmlFile )
		//Substituido o email no corpo do form pelo WFHTTPRET.APL
		cHtml := strtran( cHtml, cMailTo, "WFHTTPRET.APL" )

		//Gerando HTML para ser acessado via Link
		wfsavefile("\workflow\messenger\emp" +cEmpAnt  + "\" + cUsrProcess + "\" + cHtmlFile+"l", cHtml)
		//Apagando  o arquivo gerado
		fErase("\workflow\messenger\emp" +cEmpAnt  + "\" + cUsrProcess + "\" + cHtmlFile)

		//Link do processo, ainda faltando o endereço/dominio do WS
		cLink := cWSLink+'workflow/messenger/emp' +cEmpAnt  + '/' + cUsrProcess + '/' + alltrim(cProcess) + '.html


		//Notificando aprovador
		wfNotifica(cUserAprov,cMailAprov,oProcess:cSubject,cLink)


	Else
		MsgInfo('E-mail cadastrado para o usuario '+FwGetUserName(cUserAprov)+' é invalido, favor verificar')
	EndIF

Return lOk

Static Function wfNotifica(cUserAprov,cTo,cSubject,cLink)
	Local lOk         := .T.
	Local cHtml       := ''
	Local cFolderLyt  := 'workflow\html\'
	Local cLayoutHTML := 'tela.html'

	//Carregando arquivo
	cHtml := wfloadfile(cFolderLyt+cLayoutHTML)


	cHtml := strtran( cHtml, '%cLink%', cLink )                                 //Link para aprovaçao


	WFNotifyAdmin( cTo , cSubject, cHtml )

Return lOk

User Function wfPrd4(oProcess)
	Local cMessage  := ""
	Local nX        := 0
	Local lOk       := .T.
	Local cCodPro   := oProcess:oHTML:RetByName("B1_COD")
	local aProd 	:= {}

	//variável de controle interno da rotina automatica que informa se houve erro durante o processamento
	Private lMsErroAuto := .F.
	//força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário
	Private lAutoErrNoFile := .T.

	DBSelectArea('Sb1')
	Sb1->(DbSetOrder(1))
	Sb1->(DBSeek(xFilial('SB1')+cCodPro))

	Aadd(aProd, {"B1_COD   ", SB1->B1_COD   , NIL }) 
	Aadd(aProd, {"B1_DESC  ", SB1->B1_DESC  , NIL })
	Aadd(aProd, {"B1_TIPO  ", SB1->B1_TIPO  , NIL })
	Aadd(aProd, {"B1_UM    ", SB1->B1_UM    , NIL })
	Aadd(aProd, {"B1_LOCPAD", SB1->B1_LOCPAD, NIL })
	Aadd(aProd, {"B1_IPI"   , Val(oProcess:oHTML:RetByName("B1_IPI")), NIL })
	Aadd(aProd, {"B1_CEST"  , oProcess:oHTML:RetByName("B1_CEST"  )  , NIL })
	Aadd(aProd, {"B1_GRTRIB", oProcess:oHTML:RetByName("B1_GRTRIB")  , NIL })

	MSExecAuto({|x,y| Mata010(x,y)},aProd,4)

	IF lMsErroAuto
		aLog        := GetAutoGRLog()
		//Tratamento para o retorno do erro
		For nX := 1 to len(aLog)
			cErrorAuto += alltrim(EncodeUTF8(aLog[nX]))+'</br>'
		Next

		wfNoticaError("rivaldogfj@hotmail.com",cErrorAuto,cMessage)
	else
		U_wfPro5()
	EndIF



Return lOk

Static Function wfNoticaError(cTo , cErrorAuto, cMessage)
	Local aHtml     := {}
	Local cHtml     := ''
	Local nI        := 0

	aAdd(aHtml,"<html>")
	aAdd(aHtml,"<head>")
	aAdd(aHtml,"<meta charset='utf-8' />")
	aAdd(aHtml,"<title>Notificação</title>")
	aAdd(aHtml,"</head>")
	aAdd(aHtml,"<body>")
	aAdd(aHtml,"<table>")
	aAdd(aHtml,"<tr>")
	aAdd(aHtml,"<td>")
	aAdd(aHtml,cErrorAuto)
	aAdd(aHtml,"</td>")
	aAdd(aHtml,"</tr>")
	aAdd(aHtml,"<tr>")
	aAdd(aHtml,"<td>")
	aAdd(aHtml,cMessage)
	aAdd(aHtml,"</td>")
	aAdd(aHtml,"</tr>")
	aAdd(aHtml,"</body>")
	aAdd(aHtml,"</html>")

	For nI := 1 to len(aHtml)
		cHtml += aHtml[nI]
	Next
	WFNotifyAdmin( cTo, , cHtml )
Return

