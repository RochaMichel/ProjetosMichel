#Include "Totvs.ch"
#Include 'Protheus.ch'

User Function wfPro1()
	Local lOk           := .T.
	Local cFolderLyt    := 'workflow\html\'
	Local cLayoutHTML   := 'tabprz1.html'
	Local lAtivWFPro    := SUPERGETMV("MV_ZATIVWFP", .F., .T.)
	Local cUserAprov    := SUPERGETMV("MV_ZUSRAPRO", .T., '000000') //Usuário aprovador do processo, código e não nome de usuário
	Local cMailAprov    := 'fecona5393geekjun@outlook.com'
	Local cContaWF      := "fecona5393geekjun@outlook.com" //Conta de e-mail para recebimento da resposta do WF
	Local cUsrProcess   := '000000'
	Local cLink         := ''
	Local cWSLink       := 'http://192.168.0.14:8080/'
	Local cCodPro 	:= "0001"

	Private oHtml
	//Se o e-mail do aprovador for valido entra na condição
	IF ISEMAIL(cMailAprov) .and. lAtivWFPro
		oProcess := TWFProcess():New( "WFWPRO", "WorkFLow Produtos" )
		oProcess:NewTask( "WorkFLow Produtos", cFolderLyt+cLayoutHTML )
		oProcess:cTo          :=  cUsrProcess     //Codigo do usuario ou email
		oProcess:bReturn    := "U_wfPrd1()"
		oProcess:cSubject   := "WorkFLow Marketing  "
		oProcess:UserSiga   := cUserAprov     //"000000"
		oProcess:NewVersion(.T.)

		oHtml := oProcess:oHTML

		oHtml:ValByName( "B1_COD" 	  ,EncodeUtf8(cCodPro))
		oHtml:ValByName( "B1_DESC" 	  ,EncodeUtf8(posicione("SB1",1,xFilial('SB1')+cCodPro,"B1_DESC") ))
		oHtml:ValByName( "B1_XACABAM" ,EncodeUtf8(alltrim( SB1->B1_XACABAM  )))
		oHtml:ValByName( "B1_XAPLICA" ,EncodeUtf8(alltrim( SB1->B1_XAPLICA)))
		oHtml:ValByName( "B1_XTEXTUR" ,EncodeUtf8(alltrim( SB1->B1_XTEXTUR  )))
		oHtml:ValByName( "B1_XDFAMIL" ,EncodeUtf8(alltrim( SB1->B1_XDFAMIL   )))
		oHtml:ValByName( "B1_XDSUBGR" ,EncodeUtf8(alltrim( SB1->B1_XDSUBGR )))
		oHtml:ValByName( "B1_XDIMEN"  ,EncodeUtf8(alltrim( SB1->B1_XDIMEN )))
		oHtml:ValByName( "B1_FABRIC"  ,EncodeUtf8(alltrim( SB1->B1_FABRIC )))
		oHtml:ValByName( "B1_XMARCA"  ,EncodeUtf8(alltrim( SB1->B1_XMARCA )))
		oHtml:ValByName( "B1_XFILFAB" ,EncodeUtf8(alltrim( SB1->B1_XFILFAB )))
		oHtml:ValByName( "B1_XDGRUPO" ,EncodeUtf8(alltrim( SB1->B1_XDGRUPO )))
		oHtml:ValByName( "B5_XCORPRE" ,EncodeUtf8(alltrim( SB5->B5_XCORPRE)))
		oHtml:ValByName( "B5_XCOF"    ,EncodeUtf8(alltrim( SB5->B5_XCOF)))
		oHtml:ValByName( "B5_XGRAGUA" ,EncodeUtf8(alltrim( SB5->B5_XGRAGUA)))
		oHtml:ValByName( "B5_XCLSUSO" ,EncodeUtf8(alltrim( SB5->B5_XCLSUSO)))
		oHtml:ValByName( "B5_XVRTON"  ,EncodeUtf8(alltrim( SB5->B5_XVRTON)))
		oHtml:ValByName( "B5_XFACES"  ,EncodeUtf8(alltrim( SB5->B5_XFACES)))
		oHtml:ValByName( "B5_XSUPEFI" ,EncodeUtf8(alltrim( SB5->B5_XSUPEFI)))

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


User Function wfPrd1(oProcess)
	Local cMessage  := ""
	Local nX        := 0
	Local lOk       := .T.
	Local cCodPro   := oProcess:oHTML:RetByName("B1_COD")
	local aProd 	:= {}
	local aProd2 	:= {}

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
	Aadd(aProd, {"B1_XACABAM", oProcess:oHTML:RetByName("B1_XACABAM" ), NIL })
	Aadd(aProd, {"B1_XAPLICA", oProcess:oHTML:RetByName("B1_XAPLICA" ), NIL })
	Aadd(aProd, {"B1_XTEXTUR", oProcess:oHTML:RetByName("B1_XTEXTUR" ), NIL })
	Aadd(aProd, {"B1_XDFAMIL", oProcess:oHTML:RetByName("B1_XDFAMIL" ), NIL })
	Aadd(aProd, {"B1_XDSUBGR", oProcess:oHTML:RetByName("B1_XDSUBGR" ), NIL })
	Aadd(aProd, {"B1_XDIMEN" , LEFT(oProcess:oHTML:RetByName("B1_XDIMEN"  ),AT(",",oProcess:oHTML:RetByName("B1_XDIMEN"  ) - 1)), NIL })
	Aadd(aProd, {"B1_FABRIC" , oProcess:oHTML:RetByName("B1_FABRIC"  ), NIL })
	Aadd(aProd, {"B1_XMARCA" , oProcess:oHTML:RetByName("B1_XMARCA"  ), NIL })
	Aadd(aProd, {"B1_XFILFAB", oProcess:oHTML:RetByName("B1_XFILFAB" ), NIL })
	Aadd(aProd, {"B1_XDGRUPO", oProcess:oHTML:RetByName("B1_XDGRUPO" ), NIL })
	
	MSExecAuto({|x,y| Mata010(x,y)},aProd,4)

	IF lMsErroAuto
		aLog        := GetAutoGRLog()
		//Tratamento para o retorno do erro
		For nX := 1 to len(aLog)
			cErrorAuto += alltrim(EncodeUTF8(aLog[nX]))+'</br>'
		Next
		cSubject := 'Erro alçada produto '
		cMessage := "Não foi possivel posicionar no produto para atualização</br>"
		wfNoticaError("fecona5393geekjun@outlook.com",cSubject,cMessage)
	EndIF

	DbSelectArea('SB5')
	Sb5->(DbSetOrder(1))
	SB5->(dbseek(xFilial('SB5')+SB1->B1_COD))
	Aadd(aProd2,{'B5_XCORPRE' , oProcess:oHTML:RetByName("B5_XCORPRE" ), NIL})
	Aadd(aProd2,{'B5_XCOF'    , oProcess:oHTML:RetByName("B5_XCOF"    ), NIL})
	Aadd(aProd2,{'B5_XGRAGUA' , oProcess:oHTML:RetByName("B5_XGRAGUA" ), NIL})
	Aadd(aProd2,{'B5_XCLSUSO' , oProcess:oHTML:RetByName("B5_XCLSUSO" ), NIL})
	Aadd(aProd2,{'B5_XVRTON'  , oProcess:oHTML:RetByName("B5_XVRTON"  ), NIL})
	Aadd(aProd2,{'B5_XFACES'  , oProcess:oHTML:RetByName("B5_XFACES"  ), NIL})
	Aadd(aProd2,{'B5_XSUPEFI' , oProcess:oHTML:RetByName("B5_XSUPEFI" ), NIL})

	MSExecAuto({|x,y| Mata180(x,y)},aProd2,4)

	//Tratando erros caso ocorram
	IF lMsErroAuto
		aLog        := GetAutoGRLog()
		//Tratamento para o retorno do erro
		For nX := 1 to len(aLog)
			cErrorAuto += alltrim(EncodeUTF8(aLog[nX]))+'</br>'
		Next
		wfNoticaError("fecona5393geekjun@outlook.com",cErrorAuto,cMessage)
	else
	 U_wfPro2()	

	EndIF

	//Notificação caso haja algum problema ao posicionar o produto no retorno


Return lOk

User Function wfPro2()
	Local lOk           := .T.
	Local cFolderLyt    := 'workflow\html\'
	Local cLayoutHTML   := 'tabprz2.html'
	Local lAtivWFPro    := SUPERGETMV("MV_ZATIVWFP", .F., .T.)
	Local cUserAprov    := SUPERGETMV("MV_ZUSRAPRO", .T., '000000') //Usuário aprovador do processo, código e não nome de usuário
	Local cMailAprov    := 'fecona5393geekjun@outlook.com'
	Local cContaWF      := "fecona5393geekjun@outlook.com" //Conta de e-mail para recebimento da resposta do WF
	Local cUsrProcess   := '000000'
	Local cLink         := ''
	Local cWSLink       := 'http://192.168.0.14:8080/'
	Local cCodPro 	:= "0001"

	Private oHtml
	//Se o e-mail do aprovador for valido entra na condição
	IF ISEMAIL(cMailAprov) .and. lAtivWFPro
		oProcess := TWFProcess():New( "WFWPRO", "WorkFLow contabilidade" )
		oProcess:NewTask( "WorkFLow contabilidade", cFolderLyt+cLayoutHTML )
		oProcess:cTo          :=  cUsrProcess     //Codigo do usuario ou email
		oProcess:bReturn    := "U_wfPrd2()"
		oProcess:cSubject   := "WorkFLow contabilidade  "
		oProcess:UserSiga   := cUserAprov     //"000000"
		oProcess:NewVersion(.T.)

		oHtml := oProcess:oHTML

		oHtml:ValByName( "B1_COD" 	  ,EncodeUtf8(cCodPro))
		oHtml:ValByName( "B1_DESC" 	  ,EncodeUtf8(posicione("SB1",1,xFilial('SB1')+cCodPro,"B1_DESC") ))
		oHtml:ValByName( "B1_CONTA"   ,EncodeUtf8(alltrim( SB1->B1_CONTA  )))
	

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


User Function wfPrd2(oProcess)
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
	Aadd(aProd, {"B1_CONTA", Padr(oProcess:oHTML:RetByName("B1_CONTA" ),tamSX3('B1_CONTA')[1]), NIL })
	
	
	MSExecAuto({|x,y| Mata010(x,y)},aProd,4)

	IF lMsErroAuto
		aLog        := GetAutoGRLog()
		//Tratamento para o retorno do erro
		For nX := 1 to len(aLog)
			cErrorAuto += alltrim(EncodeUTF8(aLog[nX]))+'</br>'
		Next

		wfNoticaError("rivaldogfj@hotmail.com",cErrorAuto,cMessage)
	else
		U_wfPro3()	
	EndIF
	


Return lOk

User Function wfPro3()
	Local lOk           := .T.
	Local cFolderLyt    := 'workflow\html\'
	Local cLayoutHTML   := 'tabprz3.html'
	Local lAtivWFPro    := SUPERGETMV("MV_ZATIVWFP", .F., .T.)
	Local cUserAprov    := SUPERGETMV("MV_ZUSRAPRO", .T., '000000') //Usuário aprovador do processo, código e não nome de usuário
	Local cMailAprov    := 'liviacamilla@virtuconsultoria.com.br'
	Local cContaWF      := "fecona5393geekjun@outlook.com" //Conta de e-mail para recebimento da resposta do WF
	Local cUsrProcess   := '000000'
	Local cLink         := ''
	Local cWSLink       := 'http://192.168.0.14:8080/'
	Local cCodPro 	:= "0001"

	Private oHtml
	//Se o e-mail do aprovador for valido entra na condição
	IF ISEMAIL(cMailAprov) .and. lAtivWFPro
		oProcess := TWFProcess():New( "WFWPRO", "WorkFLow SGQ" )
		oProcess:NewTask( "WorkFLow SGQ", cFolderLyt+cLayoutHTML )
		oProcess:cTo          :=  cUsrProcess     //Codigo do usuario ou email
		oProcess:bReturn    := "U_wfPrd3()"
		oProcess:cSubject   := "WorkFLow SGQ  "
		oProcess:UserSiga   := cUserAprov     //"000000"
		oProcess:NewVersion(.T.)

		oHtml := oProcess:oHTML

		oHtml:ValByName( "B1_COD" 	  ,EncodeUtf8(cCodPro))
		oHtml:ValByName( "B1_DESC" 	  ,EncodeUtf8(posicione("SB1",1,xFilial('SB1')+cCodPro,"B1_DESC") ))
		oHtml:ValByName( "B1_XCOMPRI" ,EncodeUtf8(alltrim( SB1->B1_XCOMPRI )))
		oHtml:ValByName( "B1_XPESBRU" ,EncodeUtf8(alltrim( SB1->B1_XPESBRU )))
		oHtml:ValByName( "B1_XLARGUR" ,EncodeUtf8(alltrim( SB1->B1_XLARGUR )))
		oHtml:ValByName( "B1_XPESLIQ" ,EncodeUtf8(alltrim( SB1->B1_XPESLIQ )))
		oHtml:ValByName( "B1_XALTURA" ,EncodeUtf8(alltrim( SB1->B1_XALTURA )))
		oHtml:ValByName( "B1_CONV"    ,EncodeUtf8(alltrim( SB1->B1_CONV    )))
		oHtml:ValByName( "B5_XPISO"   ,EncodeUtf8(alltrim( SB5->B5_XPISO   )))
		oHtml:ValByName( "B5_XEXTER"  ,EncodeUtf8(alltrim( SB5->B5_XEXTER  )))
		oHtml:ValByName( "B5_XRAMPA"  ,EncodeUtf8(alltrim( SB5->B5_XRAMPA  )))
		oHtml:ValByName( "B5_XCALCA"  ,EncodeUtf8(alltrim( SB5->B5_XCALCA  )))
		oHtml:ValByName( "B5_XTALTIS" ,EncodeUtf8(alltrim( SB5->B5_XTALTIS )))
		oHtml:ValByName( "B5_XTALTO"  ,EncodeUtf8(alltrim( SB5->B5_XTALTO  )))
		oHtml:ValByName( "B5_XTMEDI"  ,EncodeUtf8(alltrim( SB5->B5_XTMEDI  )))
		oHtml:ValByName( "B5_XTLEVE"  ,EncodeUtf8(alltrim( SB5->B5_XTLEVE  )))
		oHtml:ValByName( "B5_XBANHE"  ,EncodeUtf8(alltrim( SB5->B5_XBANHE  )))
		oHtml:ValByName( "B5_XBOXBAN" ,EncodeUtf8(alltrim( SB5->B5_XBOXBAN )))
		oHtml:ValByName( "B5_XCOZIN"  ,EncodeUtf8(alltrim( SB5->B5_XCOZIN  )))
		oHtml:ValByName( "B5_XAREASR" ,EncodeUtf8(alltrim( SB5->B5_XAREASR )))
		oHtml:ValByName( "B5_XQUARTO" ,EncodeUtf8(alltrim( SB5->B5_XQUARTO )))
		oHtml:ValByName( "B5_XSALA"   ,EncodeUtf8(alltrim( SB5->B5_XSALA   )))
		oHtml:ValByName( "B5_XHALL"   ,EncodeUtf8(alltrim( SB5->B5_XHALL   )))
		oHtml:ValByName( "B5_XTERRAC" ,EncodeUtf8(alltrim( SB5->B5_XTERRAC )))
		oHtml:ValByName( "B5_XGARAGE" ,EncodeUtf8(alltrim( SB5->B5_XGARAGE )))
		oHtml:ValByName( "B5_XPINTER" ,EncodeUtf8(alltrim( SB5->B5_XPINTER )))
		oHtml:ValByName( "B5_XPBANHE" ,EncodeUtf8(alltrim( SB5->B5_XPBANHE )))
		oHtml:ValByName( "B5_XPCOZIN" ,EncodeUtf8(alltrim( SB5->B5_XPCOZIN )))
		oHtml:ValByName( "B5_XPMURO"  ,EncodeUtf8(alltrim( SB5->B5_XPMURO  )))
		oHtml:ValByName( "B5_XPARESR" ,EncodeUtf8(alltrim( SB5->B5_XPARESR )))
		oHtml:ValByName( "B5_XFACHAD" ,EncodeUtf8(alltrim( SB5->B5_XFACHAD )))
		oHtml:ValByName( "B5_XPISCIN" ,EncodeUtf8(alltrim( SB5->B5_XPISCIN )))
		oHtml:ValByName( "B5_XACABAM" ,EncodeUtf8(alltrim( SB5->B5_XACABAMI)))
		oHtml:ValByName( "B5_XTELAGE" ,EncodeUtf8(alltrim( SB5->B5_XTELAGE )))
		oHtml:ValByName( "B5_VRTON"   ,EncodeUtf8(alltrim( SB5->B5_VRTON   )))
		oHtml:ValByName( "B5_XESPESS" ,EncodeUtf8(alltrim( SB5->B5_XESPESS )))
		oHtml:ValByName( "B5_XGRPABS" ,EncodeUtf8(alltrim( SB5->B5_XGRPABS )))
		oHtml:ValByName( "B5_XACALAT" ,EncodeUtf8(alltrim( SB5->B5_XACALAT )))
		
		oProcess:nEncodeMime :=  0
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

User Function wfPrd3(oProcess)
	Local cMessage  := ""
	Local nX        := 0
	Local lOk       := .T.
	Local cCodPro   := oProcess:oHTML:RetByName("B1_COD")
	local aProd 	:= {}
	local aProd2 	:= {}

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
	Aadd(aProd, {"B1_XCOMPRI", oProcess:oHTML:RetByName("B1_XCOMPRI" ) , NIL })
	Aadd(aProd, {"B1_XPESBRU", oProcess:oHTML:RetByName("B1_XPESBRU" ) , NIL })
	Aadd(aProd, {"B1_XLARGUR", oProcess:oHTML:RetByName("B1_XLARGUR" ) , NIL })
	Aadd(aProd, {"B1_XPESLIQ", oProcess:oHTML:RetByName("B1_XPESLIQ" ) , NIL })
	Aadd(aProd, {"B1_XALTURA", oProcess:oHTML:RetByName("B1_XALTURA" ) , NIL })
	Aadd(aProd, {"B1_CONV"   , Val(oProcess:oHTML:RetByName("B1_CONV")), NIL })
	
	MSExecAuto({|x,y| Mata010(x,y)},aProd,4)

	IF lMsErroAuto
		aLog        := GetAutoGRLog()
		//Tratamento para o retorno do erro
		For nX := 1 to len(aLog)
			cErrorAuto += alltrim(EncodeUTF8(aLog[nX]))+'</br>'
		Next
		cSubject := 'Erro alçada produto '
		cMessage := "Não foi possivel posicionar no produto para atualização</br>"
		wfNoticaError("fecona5393geekjun@outlook.com",cSubject,cMessage)
	EndIF

	DbSelectArea('SB5')
	Sb5->(DbSetOrder(1))
	SB5->(dbseek(xFilial('SB5')+SB1->B1_COD))
	Aadd(aProd2,{"B5_XPISO"  , oProcess:oHTML:RetByName("B5_XPISO"  ), NIL})
	Aadd(aProd2,{"B5_XEXTER" , oProcess:oHTML:RetByName("B5_XEXTER" ), NIL})
	Aadd(aProd2,{"B5_XRAMPA" , oProcess:oHTML:RetByName("B5_XRAMPA" ), NIL})
	Aadd(aProd2,{"B5_XCALCA" , LEFT(oProcess:oHTML:RetByName("B5_XCALCA" ),1), NIL})
	Aadd(aProd2,{"B5_XTALTIS", oProcess:oHTML:RetByName("B5_XTALTIS"), NIL})
	Aadd(aProd2,{"B5_XTALTO" , oProcess:oHTML:RetByName("B5_XTALTO" ), NIL})
	Aadd(aProd2,{"B5_XTMEDI" , oProcess:oHTML:RetByName("B5_XTMEDI" ), NIL})
	Aadd(aProd2,{"B5_XTLEVE" , oProcess:oHTML:RetByName("B5_XTLEVE" ), NIL})
	Aadd(aProd2,{"B5_XBANHE" , oProcess:oHTML:RetByName("B5_XBANHE" ), NIL})
	Aadd(aProd2,{"B5_XBOXBAN", oProcess:oHTML:RetByName("B5_XBOXBAN"), NIL})
	Aadd(aProd2,{"B5_XCOZIN" , LEFT(oProcess:oHTML:RetByName("B5_XCOZIN" ),1), NIL})
	Aadd(aProd2,{"B5_XAREASR", oProcess:oHTML:RetByName("B5_XAREASR"), NIL})
	Aadd(aProd2,{"B5_XQUARTO", oProcess:oHTML:RetByName("B5_XQUARTO"), NIL})
	Aadd(aProd2,{"B5_XSALA"  , oProcess:oHTML:RetByName("B5_XSALA"  ), NIL})
	Aadd(aProd2,{"B5_XHALL"  , oProcess:oHTML:RetByName("B5_XHALL"  ), NIL})
	Aadd(aProd2,{"B5_XTERRAC", oProcess:oHTML:RetByName("B5_XTERRAC"), NIL})
	Aadd(aProd2,{"B5_XGARAGE", oProcess:oHTML:RetByName("B5_XGARAGE"), NIL})
	Aadd(aProd2,{"B5_XPINTER", oProcess:oHTML:RetByName("B5_XPINTER"), NIL})
	Aadd(aProd2,{"B5_XPBANHE", oProcess:oHTML:RetByName("B5_XPBANHE"), NIL})
	Aadd(aProd2,{"B5_XPCOZIN", oProcess:oHTML:RetByName("B5_XPCOZIN"), NIL})
	Aadd(aProd2,{"B5_XPMURO" , oProcess:oHTML:RetByName("B5_XPMURO" ), NIL})
	Aadd(aProd2,{"B5_XPARESR", oProcess:oHTML:RetByName("B5_XPARESR"), NIL})
	Aadd(aProd2,{"B5_XFACHAD", oProcess:oHTML:RetByName("B5_XFACHAD"), NIL})
	Aadd(aProd2,{"B5_XPISCIN", oProcess:oHTML:RetByName("B5_XPISCIN"), NIL})
	Aadd(aProd2,{"B5_XACABAM", oProcess:oHTML:RetByName("B5_XACABAM"), NIL})
	Aadd(aProd2,{"B5_XTELAGE", oProcess:oHTML:RetByName("B5_XTELAGE"), NIL})
	Aadd(aProd2,{"B5_VRTON"  , oProcess:oHTML:RetByName("B5_VRTON"  ), NIL})
	Aadd(aProd2,{"B5_XESPESS", oProcess:oHTML:RetByName("B5_XESPESS"), NIL})
	Aadd(aProd2,{"B5_XGRPABS", oProcess:oHTML:RetByName("B5_XGRPABS"), NIL})
	Aadd(aProd2,{"B5_XACALAT", oProcess:oHTML:RetByName("B5_XACALAT"), NIL})

	MSExecAuto({|x,y| Mata180(x,y)},aProd2,4)

	//Tratando erros caso ocorram
	IF lMsErroAuto
		aLog        := GetAutoGRLog()
		//Tratamento para o retorno do erro
		For nX := 1 to len(aLog)
			cErrorAuto += alltrim(EncodeUTF8(aLog[nX]))+'</br>'
		Next
		wfNoticaError("fecona5393geekjun@outlook.com",cErrorAuto,cMessage)
	else
	 U_wfPro4()	
	EndIF

	//Notificação caso haja algum problema ao posicionar o produto no retorno


Return lOk

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

User Function wfPro5()
	Local lOk           := .T.
	Local cFolderLyt    := 'workflow\html\'
	Local cLayoutHTML   := 'tabprz5.html'
	Local lAtivWFPro    := SUPERGETMV("MV_ZATIVWFP", .F., .T.)
	Local cUserAprov    := SUPERGETMV("MV_ZUSRAPRO", .T., '000000') //Usuário aprovador do processo, código e não nome de usuário
	Local cMailAprov    := 'fecona5393geekjun@outlook.com'
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
		oProcess:cTo          :=  cUsrProcess //Codigo do usuario ou email
		oProcess:bReturn    := "U_wfPrd5()"
		oProcess:cSubject   := "WorkFLow Fiscal  "
		oProcess:UserSiga   := cUserAprov //"000000"    
		oProcess:NewVersion(.T.)

		oHtml := oProcess:oHTML

		oHtml:ValByName( "B1_COD" 	  ,EncodeUtf8(cCodPro))
		oHtml:ValByName( "B1_DESC" 	  ,EncodeUtf8(posicione("SB1",1,xFilial('SB1')+cCodPro,"B1_DESC") ))
		oHtml:ValByName( "B1_CODBAR"  ,EncodeUtf8(alltrim( SB1->B1_CODBAR  )))
		oHtml:ValByName( "B1_XCODBAR" ,EncodeUtf8(alltrim( SB1->B1_XCODBAR )))
		oHtml:ValByName( "B1_XDESC"   ,EncodeUtf8(alltrim( SB1->B1_XDESC   )))


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

User Function wfPrd5(oProcess)
	Local cMessage  := ""
	Local nX        := 0
	Local lOk       := .T.
	Local cCodPro   := oProcess:oHTML:RetByName("B1_COD")
	Local cDescPro  := oProcess:oHTML:RetByName("B1_DESC")
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
	Aadd(aProd, {"B1_CODBAR"   , oProcess:oHTML:RetByName("B1_CODBAR")    , NIL })
	Aadd(aProd, {"B1_XCODBAR"  , oProcess:oHTML:RetByName("B1_XCODBAR"  ), NIL })
	Aadd(aProd, {"B1_XDESC"    , oProcess:oHTML:RetByName("B1_XDESC")  , NIL })

	MSExecAuto({|x,y| Mata010(x,y)},aProd,4)

	IF lMsErroAuto
		aLog        := GetAutoGRLog()
		//Tratamento para o retorno do erro
		For nX := 1 to len(aLog)
			cErrorAuto += alltrim(EncodeUTF8(aLog[nX]))+'</br>'
		Next

		wfNoticaError("fecona5393geekjun@outlook.com",cErrorAuto,cMessage)
	else
		//Chamada da função se não ocorrer erro
		NotFiFim(cCodPro, cDescPro)
	EndIF

Return lOk




Static Function wfNoticaError(cTo , cErrorAuto, cMessage)
	Local aHtml     := {}
	Local cHtml     := ''
	Local nI        := 0

	aAdd(aHtml,"<html>")
	aAdd(aHtml,"<head>")
	aAdd(aHtml,"<meta charset='utf-8' />")
	aAdd(aHtml,"<title>Notificação WorkFlow alçada de produtos - ERPLabs</title>")
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

static function NotFiFim(cCodPro, cDescPro)

LOCAL cHtml
local cSubject := 'Confirmação do Cadastro '
local cto := SuperGetMV("MV_",.T.,"fecona5393geekjun@outlook.com")

//Notificação de e-mail caso o processo seja feito com sucesso
    cHtml := "<!DOCTYPE html>"
	cHtml += "<html>"
	cHtml += " "
	cHtml += "<head>"
	cHtml += "    <meta charset='utf-8' />"
	cHtml += "    <title>Cadastro</title>"
	cHtml += " "
	cHtml += "    <style>"
	cHtml += "        .invoice-box {"
	cHtml += "            max-width: 500px;"
	cHtml += "            margin: auto;"
	cHtml += "            padding: 30px;"
	cHtml += "            border: 1px solid #eee;"
	cHtml += "            box-shadow: 0 0 10px rgba(0, 0, 0, 0.15);"
	cHtml += "            font-size: 16px;"
	cHtml += "            line-height: 24px;"
	cHtml += "            font-family: 'Helvetica Neue', 'Helvetica', Helvetica, Arial, sans-serif;"
	cHtml += "            color: #555;"
	cHtml += "        }"
	cHtml += "      .invoice-box data td {position: static;}   "
	cHtml += "        .invoice-box table {"
	cHtml += "            width: 100%;"
	cHtml += "            line-height: inherit;"
	cHtml += "            text-align: left;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box table td {"
	cHtml += "            padding: 5px;"
	cHtml += "            vertical-align: top;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box table tr td:nth-child(2) {"
	cHtml += "            text-align: right;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box table tr.top table td {"
	cHtml += "            padding-bottom: 20px;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box table tr.top table td.title {"
	cHtml += "            font-size: 16px;"
	cHtml += "            line-height: 45px;"
	cHtml += "            color: #333;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box table tr.information table td {"
	cHtml += "            padding-bottom: 40px;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box table tr.heading td {"
	cHtml += "            background: #eee;"
	cHtml += "            border-bottom: 1px solid #ddd;"
	cHtml += "            font-weight: bold;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box table tr.details td {"
	cHtml += "            padding-bottom: 20px;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box table tr.item td {"
	cHtml += "            border-bottom: 1px solid #eee;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box table tr.item.last td {"
	cHtml += "            border-bottom: none;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box table tr.total td:nth-child(2) {"
	cHtml += "            border-top: 2px solid #eee;"
	cHtml += "            font-weight: bold;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box a {"
	cHtml += "            background-color: #ffffff;"
	cHtml += "            border: solid 1px #eb0684;"
	cHtml += "            border-radius: 5px;"
	cHtml += "            box-sizing: border-box;"
	cHtml += "            color: #eb0684;"
	cHtml += "            cursor: pointer;"
	cHtml += "            display: inline-block;"
	cHtml += "            font-size: 14px;"
	cHtml += "            font-weight: bold;"
	cHtml += "            margin: 0;"
	cHtml += "            padding: 12px 25px;"
	cHtml += "            text-decoration: none;"
	cHtml += "            text-transform: capitalize;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        @media only screen and (max-width: 600px) {"
	cHtml += "            .invoice-box table tr.top table td {"
	cHtml += "                width: 100%;"
	cHtml += "                display: block;"
	cHtml += "                text-align: center;"
	cHtml += "            }"
	cHtml += "            .invoice-box table tr.information table td {"
	cHtml += "                width: 100%;"
	cHtml += "                display: block;"
	cHtml += "                text-align: center;"
	cHtml += "            }"
	cHtml += "        }"
	cHtml += "        /** RTL **/"
	cHtml += "         "
	cHtml += "        .rtl {"
	cHtml += "            direction: rtl;"
	cHtml += "            font-family: Tahoma, 'Helvetica Neue', 'Helvetica', Helvetica, Arial, sans-serif;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .rtl table {"
	cHtml += "            text-align: right;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .rtl table tr td:nth-child(2) {"
	cHtml += "            text-align: left;"
	cHtml += "        }"
	cHtml += "    </style>"
	cHtml += "</head>"
	cHtml += " "
	cHtml += "<body>"
	cHtml += "    <div class='invoice-box'>"
	cHtml += "        <table cellpadding='0' cellspacing='0'>"
	cHtml += "            <tr class='top'>"
	cHtml += "                <td colspan='4'>"
	cHtml += "                    <table>"
	cHtml += "                    <a href='https://imgbox.com/E2aa77BG' target='_blank'><img src='https://images2.imgbox.com/7c/83/E2aa77BG_o.jpg' width='220' height='70' border='0' alt='image Elizabeth'/></a>"
	cHtml += "                        <tr>"
	cHtml += "                            <td class='title'></td>"
	cHtml += "                               <h4 style=' position: relative; bottom: 100px; left: 300px; '> Confirmação de Cadastro <br/>data:"+DTOC(date())+"</h4>"
	cHtml += "                        </tr>"
	cHtml += "                    <h4 style=' position: relative; bottom: 70px'>Processo de inclusão do produto concluida com "
    cHtml += "                        sucesso</h4></br> </br>"
    cHtml += "                    <h4 style=' position: relative; bottom: 130px'>Codigo: 0001</h4>"
    cHtml += "                    </br>"
    cHtml += "                    <h4 style=' position: relative; bottom: 190px'>Descrição: MONITOR MOD</h4> "               
	cHtml += "                    </table>"
	cHtml += "                </td>"
	cHtml += "            </tr>"
	cHtml += "       " 
	cHtml += "        </table>"
	cHtml += "    </div>"
	cHtml += "</body>"
	cHtml += " "
	cHtml += "</html>"

	WFNotifyAdmin(cTo, cSubject, cHtml)

RETURN


