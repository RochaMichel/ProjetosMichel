#include "apwebsrv.ch"
#INCLUDE 'RESTFUL.CH'
#include "TbiConn.ch"
#include "topconn.ch"
#include "Totvs.ch"
#include "Protheus.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE 'FWMVCDef.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RDWFPRZ    Autor ณ DrillTec Solu็๕es  บ Data ณ  26/05/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Workflow para retorno de aprova็ใo de ATRASO NA ENTREGA.   บฑฑ 
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Televendas                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DWFRCON0(oWf)
	Local cProduto      := PADR(oWF:oHtml:RetByName("B1_COD"),TamSx3("B1_COD")[1])
	Local cCest         := PADR(oWF:oHtml:RetByName("B1_CEST"),TamSx3("B1_CEST")[1])
	Local oModel        := Nil
	Local cErro         := ""
	Local lAtivAmb      := .F.
	Private lMsErroAuto := .F.

	FWLogMsg("DEBUG", /*cTransactionId*/, "DWFRCONT0", /*cCategory*/, /*cStep*/, /*cMsgId*/, PADR(oWF:oHtml:RetByName("B1_COD"),TamSx3("B1_COD")[1])  , /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	FWLogMsg("DEBUG", /*cTransactionId*/, "DWFRCONT0", /*cCategory*/, /*cStep*/, /*cMsgId*/, PADR(oWF:oHtml:RetByName("B1_CEST"),TamSx3("B1_CEST")[1]), /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

	If Select("SX2") <= 0
		RpcClearEnv()
		RpcSetType(3)
		RpcSetEnv("01","020202",,,"FAT",,{})
		lAtivAmb := .T.
	EndIf
	DbSelectArea("SB1")
	DbSetOrder(1)
	If DbSeek(xFilial("SB1")+cProduto)
		oModel  := FwLoadModel("MATA010")
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		INCLUI := .F.
		ALTERA := .T.
		oModel:Activate()
		//Atualiza Cest
		If !Empty(cCest)
			oModel:SetValue("SB1MASTER","B1_CEST" ,cCest )
		EndIf
		If oModel:VldData()
			oModel:CommitData()
			//EnvConfPrd(cProduto, cCest)  
			//Envia confirma็ใo para o solicitante por email
			//ConfirmPrd(cProduto)
			U_DWFCONT(cProduto)
		Else
			aErro := oModel:GetErrorMessage()
			cErro += aErro[1] + " - "
			cErro += aErro[2] + " - "
			cErro += aErro[3] + " - "
			cErro += aErro[4] + " - "
			cErro += aErro[5] + " - "
			cErro += aErro[6]
			//Envia o erro por email
			cDe        := GetMv("EL_RLMAIL")
			cPara      := "contato.michelrocha@gmail.com"//"nucleo.cadastral@grupoelizabeth.com.br"
			cCopia     := ""
			cConhCopia := ""
			cAssunto   := "Erro ao atualizar conta do produto: " + cProduto
			cTexto     := "Segue detalhes. <br> " + cErro
			lHtml      := .F.
			cFile      := ""
			cPara      := U_RetEmail(xFilial("ZW2") + "000001" + "000007")
			U_DrillEmail(cDe,cPara,cCopia,cConhCopia,cAssunto,cTexto,lHtml,cFile)
		EndIf
	Endif
	If lAtivAmb
		RpcClearEnv()
	Endif
Return lOk

User Function DWFRCONT(oWf)

	Local cProduto      := PADR(oWF:oHtml:RetByName("B1_COD"),TamSx3("B1_COD")[1])
	Local cConta        := PADR(oWF:oHtml:RetByName("CONTA"),TamSx3("B1_CONTA")[1])
	Local oModel        := Nil
	Local cErro         := ""
	Local lAtivAmb      := .F.
	Private lMsErroAuto := .F.

	FWLogMsg("DEBUG", /*cTransactionId*/, "DWFRCONT", /*cCategory*/, /*cStep*/, /*cMsgId*/, PADR(oWF:oHtml:RetByName("B1_COD"),TamSx3("B1_COD")[1])  , /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	FWLogMsg("DEBUG", /*cTransactionId*/, "DWFRCONT", /*cCategory*/, /*cStep*/, /*cMsgId*/, PADR(oWF:oHtml:RetByName("B1_COD"),TamSx3("B1_CONTA")[1]), /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

	If Select("SX2") <= 0
		RpcClearEnv()
		RpcSetType(3)
		RpcSetEnv("01","020202",,,"FAT",,{})
		lAtivAmb := .T.
	EndIf

//Verifica se conta existe na CT1
	DbSelectArea("CT1")
	DbSetOrder(1)
	If DbSeek(xFilial("CT1")+cConta)
		DbSelectArea("SB1")
		DbSetOrder(1)
		If DbSeek(xFilial("SB1")+cProduto)
			oModel  := FwLoadModel("MATA010")
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
			INCLUI := .F.
			ALTERA := .T.
			oModel:Activate()

			//Atualiza conta
			oModel:SetValue("SB1MASTER","B1_CONTA" ,cConta )
			oModel:SetValue("SB1MASTER","B1_MSBLQL" ,'2' )

			If oModel:VldData()
				oModel:CommitData()
				EnvConfPrd(cProduto, cConta)
				//Envia confirma็ใo para o solicitante por email
				ConfirmPrd(cProduto)
				DbSelectArea("ZW1")
				ZW1->(DbSetOrder(1))
				If ZW1->(DbSeek(xFilial("ZW1") + cProduto))
					U_UPDZW1(ZW1->(Recno()), "", "OK", "")
				Endif
			Else
				aErro := oModel:GetErrorMessage()
				cErro += aErro[1] + " - "
				cErro += aErro[2] + " - "
				cErro += aErro[3] + " - "
				cErro += aErro[4] + " - "
				cErro += aErro[5] + " - "
				cErro += aErro[6]
				//Envia o erro por email
				cDe        := GetMv("EL_RLMAIL")
				cPara      := "contato.michelrocha@gmail.com"//"nucleo.cadastral@grupoelizabeth.com.br"
				cCopia     := ""
				cConhCopia := ""
				cAssunto   := "Erro ao atualizar conta do produto: " + cProduto
				cTexto     := "Segue detalhes. <br> " + cErro
				lHtml      := .F.
				cFile      := ""
				cPara      := U_RetEmail(xFilial("ZW2") + "000001" + "000003")
				U_DrillEmail(cDe,cPara,cCopia,cConhCopia,cAssunto,cTexto,lHtml,cFile)
			EndIf
		Endif

	Else
		//Envia o erro por email
		cDe        := GetMv("EL_RLMAIL")
		cPara      := "contato.michelrocha@gmail.com"//"nucleo.cadastral@grupoelizabeth.com.br"
		cCopia     := ""
		cConhCopia := ""
		cAssunto   := "Erro ao atualizar conta do produto: " + cProduto
		cTexto     := "Segue detalhes. <br> " + "Conta contabil informada nใo existe no cadastro de conta!"
		lHtml      := .F.
		cFile      := ""
		cPara      := U_RetEmail(xFilial("ZW2") + "000001" + "000003")
		U_DrillEmail(cDe,cPara,cCopia,cConhCopia,cAssunto,cTexto,lHtml,cFile)
	Endif

	If lAtivAmb
		RpcClearEnv()
	Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DWFCONT1  บAutor  ณ Walter Rodrigo     บ Data ณ  09/03/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Workflow para preenchimento do campo conta contabil do     บฑฑ
ฑฑบ          ณ produto                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa็ใo de produtos                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DWFRCON1(oProcess)
	Local cMessage   := ""
	Local nX         := 0
	Local lOk        := .T.
	Local cProduto   := oProcess:oHTML:RetByName("B1_COD")
	local aProd 	 := {}
	local aProd2 	 := {}
	local cErrorAuto := ""

	//variแvel de controle interno da rotina automatica que informa se houve erro durante o processamento
	Private lMsErroAuto := .F.
	//for็a a grava็ใo das informa็๕es de erro em array para manipula็ใo da grava็ใo ao inv้s de gravar direto no arquivo temporแrio
	Private lAutoErrNoFile := .T.

	DBSelectArea('Sb1')
	Sb1->(DbSetOrder(1))
	Sb1->(DBSeek(xFilial('SB1')+cProduto))

	Aadd(aProd, {"B1_COD   ", SB1->B1_COD   , NIL })
	Aadd(aProd, {"B1_DESC  ", SB1->B1_DESC  , NIL })
	Aadd(aProd, {"B1_TIPO  ", SB1->B1_TIPO  , NIL })
	Aadd(aProd, {"B1_UM    ", SB1->B1_UM    , NIL })
	Aadd(aProd, {"B1_XAPLICA", AllTrim(UPPER(oProcess:oHTML:RetByName("B1_XAPLICA" ))), NIL })
	Aadd(aProd, {"B1_XAGRUP" , AllTrim(UPPER(oProcess:oHTML:RetByName("B1_XAGRUP" ))), NIL })
	Aadd(aProd, {"B1_XDFAMIL", AllTrim(UPPER(oProcess:oHTML:RetByName("B1_XDFAMIL" ))), NIL })
	Aadd(aProd, {"B1_XDSUBGR", Alltrim(UPPER(oProcess:oHTML:RetByName("B1_XDSUBGR" ))), NIL })
	Aadd(aProd, {"B1_XDIMEN" , AllTrim(SubStr(oProcess:oHTML:RetByName("B1_XDIMEN"),1,AT(",",oProcess:oHTML:RetByName("B1_XDIMEN"))- 1)), NIL })
	Aadd(aProd, {"B1_FABRIC" , oProcess:oHTML:RetByName("B1_FABRIC"  ), NIL })
	Aadd(aProd, {"B1_XMARCA" , oProcess:oHTML:RetByName("B1_XMARCA"  ), NIL })
	Aadd(aProd, {"B1_XFILFAB", SubStr(oProcess:oHTML:RetByName("B1_XFILFAB" ),1,6), NIL })
	Aadd(aProd, {"B1_XDGRUPO", AllTrim(UPPER(oProcess:oHTML:RetByName("B1_XDGRUPO" ))), NIL })
	Aadd(aProd, {"B1_XPALETE",30  , NIL })
	Aadd(aProd, {"B1_XFORLIN","E" , NIL })
	Aadd(aProd, {"B1_RASTRO ","S" , NIL })
	Aadd(aProd, {"B1_LOCALIZ","S" , NIL })
	Aadd(aProd, {"B1_TIPCONV","D" , NIL })
	Aadd(aProd, {"B1_QB     ",100 , NIL })
	Aadd(aProd, {"B1_APROPRI","D" , NIL })
	Aadd(aProd, {"B1_SEGUM  ","CX", NIL })
	Aadd(aProd, {"B1_CONV  ",1, NIL })

	If SB1->B1_GRUPO == "0101"
		Aadd(aProd, {"B1_TIPCAR  ","000001", NIL })
	EndIf
	If SB1->B1_GRUPO == "0104"
		Aadd(aProd, {"B1_TIPCAR  ","000002", NIL })
	EndIf

	Do Case
	Case oProcess:oHTML:RetByName("B1_XFILFAB") == "020103"
		Aadd(aProd, {"B1_LOCPAD","10",NIL})
	Case oProcess:oHTML:RetByName("B1_XFILFAB") $ "020201|020203|020202"
		Aadd(aProd, {"B1_LOCPAD","12",NIL})
	Otherwise
		Aadd(aProd, {"B1_LOCPAD", SB1->B1_LOCPAD, NIL })
	End Case

	MSExecAuto({|x,y| Mata010(x,y)},aProd,4)

	IF lMsErroAuto
		aLog        := GetAutoGRLog()
		//Tratamento para o retorno do erro
		For nX := 1 to len(aLog)
			cErrorAuto += alltrim(EncodeUTF8(aLog[nX]))+'</br>'
		Next

		cMessage := "Nใo foi possivel posicionar no produto para atualiza็ใo</br>"
		U_wfNoticaError("contato.michelrocha@gmail.com",cErrorAuto,cMessage)
	else
		//Libera o produto para atualizar/cadastrar o SB5
		If SB1->(DBSeek(xFilial('SB1')+cProduto))
			SB1->(RecLock("SB1", .F.))
			SB1->B1_MSBLQL := "2"
			SB1->(MsUnlock())
		Endif

		DbSelectArea('SB5')

		Aadd(aProd2,{'B5_COD'     , padr(cProduto,TamSx3('B5_COD')[1]), NIL})
		Aadd(aProd2,{'B5_CEME'    , posicione("SB1",1,xFilial('SB1')+cProduto,"B1_DESC") , NIL})
		Aadd(aProd2,{'B5_UMIND'   ,"1", NIL})
		Aadd(aProd2,{'B5_XCORPRE' , oProcess:oHTML:RetByName("B5_XCORPRE" ), NIL})
		Aadd(aProd2,{'B5_XACABAM' , oProcess:oHTML:RetByName("B5_XACABAM" ), NIL})
		Aadd(aProd2,{'B5_XCOF'    , oProcess:oHTML:RetByName("B5_XCOF"    ), NIL})
		Aadd(aProd2,{'B5_XCLSUSO' , oProcess:oHTML:RetByName("B5_XCLSUSO" ), NIL})
		Aadd(aProd2,{'B5_XVRTON'  , oProcess:oHTML:RetByName("B5_XVRTON"  ), NIL})
		Aadd(aProd2,{'B5_XFACES'  , oProcess:oHTML:RetByName("B5_XFACES"  ), NIL})
		Aadd(aProd2,{'B5_XSUPEFI' , oProcess:oHTML:RetByName("B5_XSUPEFI" ), NIL})
		Aadd(aProd2,{"B5_XACALAT" , oProcess:oHTML:RetByName("B5_XACALAT"), NIL})

		SB5->(DbSetOrder(1))
		if SB5->(dbseek(xFilial('SB5')+cProduto))
			MSExecAuto({|x,y| Mata180(x,y)},aProd2,4)
		else
			MSExecAuto({|x,y| Mata180(x,y)},aProd2,3)
		Endif

		//Bloqueia o produto ap๓s atualizar/cadastrar o SB5
		If SB1->(DBSeek(xFilial('SB1')+cProduto))
			SB1->(RecLock("SB1", .F.))
			SB1->B1_MSBLQL := "1"
			SB1->(MsUnlock())
		Endif

		//Tratando erros caso ocorram
		IF lMsErroAuto
			aLog        := GetAutoGRLog()
			//Tratamento para o retorno do erro
			For nX := 1 to len(aLog)
				cErrorAuto += alltrim(EncodeUTF8(aLog[nX]))+'</br>'
			Next
			U_wfNoticaError("contato.michelrocha@gmail.com",cErrorAuto,cMessage)
		else
			U_DWFCONT2(cProduto)
		EndIF

	EndIF



Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DWFRCON2 บAutor  ณ Walter Rodrigo     บ Data ณ  09/03/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Workflow para preenchimento do campo conta contabil do     บฑฑ
ฑฑบ          ณ produto                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa็ใo de produtos                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DWFRCON2(oProcess)
	Local cMessage  := ""
	Local nX        := 0
	Local lOk       := .T.
	Local cProduto   := oProcess:oHTML:RetByName("B1_COD")
	local aProd 	:= {}
	local cErrorAuto := ""

	//variแvel de controle interno da rotina automatica que informa se houve erro durante o processamento
	Private lMsErroAuto := .F.
	//for็a a grava็ใo das informa็๕es de erro em array para manipula็ใo da grava็ใo ao inv้s de gravar direto no arquivo temporแrio
	Private lAutoErrNoFile := .T.

	DBSelectArea('Sb1')
	Sb1->(DbSetOrder(1))
	Sb1->(DBSeek(xFilial('SB1')+cProduto))

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

		U_wfNoticaError("contato.michelrocha@gmail.com",cErrorAuto,cMessage)
	else
		U_DWFCONT3(cProduto)
	EndIF

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DWFRCON3 บAutor  ณ Walter Rodrigo     บ Data ณ  09/03/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Workflow para preenchimento do campo conta contabil do     บฑฑ
ฑฑบ          ณ produto                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa็ใo de produtos                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DWFRCON3(oProcess)
	Local cMessage   := ""
	Local nX         := 0
	Local lOk        := .T.
	Local cProduto   := oProcess:oHTML:RetByName("B1_COD")
	local aProd 	 := {}
	local aProd2 	 := {}
	Local cErrorAuto := ""

	//variแvel de controle interno da rotina automatica que informa se houve erro durante o processamento
	Private lMsErroAuto := .F.
	//for็a a grava็ใo das informa็๕es de erro em array para manipula็ใo da grava็ใo ao inv้s de gravar direto no arquivo temporแrio
	Private lAutoErrNoFile := .T.

	DBSelectArea('Sb1')
	Sb1->(DbSetOrder(1))
	Sb1->(DBSeek(xFilial('SB1')+cProduto))

	Aadd(aProd, {"B1_COD   ", SB1->B1_COD   , NIL })
	Aadd(aProd, {"B1_DESC  ", SB1->B1_DESC  , NIL })
	Aadd(aProd, {"B1_TIPO  ", SB1->B1_TIPO  , NIL })
	Aadd(aProd, {"B1_UM    ", SB1->B1_UM    , NIL })
	Aadd(aProd, {"B1_LOCPAD", SB1->B1_LOCPAD, NIL })
	Aadd(aProd, {"B1_XCOMPRI", Val(StrTran(oProcess:oHTML:RetByName("B1_XCOMPRI" ),",",".")) , NIL })
	Aadd(aProd, {"B1_XPESBRU", Val(StrTran(oProcess:oHTML:RetByName("B1_XPESBRU" ),",",".")) , NIL })
	Aadd(aProd, {"B1_XLARGUR", Val(StrTran(oProcess:oHTML:RetByName("B1_XLARGUR" ),",",".")) , NIL })
	Aadd(aProd, {"B1_XPESLIQ", Val(StrTran(oProcess:oHTML:RetByName("B1_XPESLIQ" ),",",".")) , NIL })
	Aadd(aProd, {"B1_XALTURA", Val(StrTran(oProcess:oHTML:RetByName("B1_XALTURA" ),",",".")) , NIL })
	Aadd(aProd, {"B1_CONV"   , Val(StrTran(oProcess:oHTML:RetByName("B1_CONV"),",","."))	 , NIL })
	Aadd(aProd, {"B1_XPALETE", Val(StrTran(oProcess:oHTML:RetByName("B1_XPALETE" ),",",".")), NIL })
	Aadd(aProd, {"B1_PESO"   , Val(StrTran(oProcess:oHTML:RetByName("B1_PESO"    ),",",".")), NIL })
	Aadd(aProd, {"B1_PESBRU" , Val(StrTran(oProcess:oHTML:RetByName("B1_PESBRU"  ),",",".")), NIL })

	MSExecAuto({|x,y| Mata010(x,y)},aProd,4)

	IF lMsErroAuto
		aLog        := GetAutoGRLog()
		//Tratamento para o retorno do erro
		For nX := 1 to len(aLog)
			cErrorAuto += alltrim(EncodeUTF8(aLog[nX]))+'</br>'
		Next
		cMessage := "Nใo foi possivel posicionar no produto para atualiza็ใo</br>"
		U_wfNoticaError("contato.michelrocha@gmail.com",cErrorAuto,cMessage)
	EndIF
	//Libera o produto para atualizar/cadastrar o SB5
	If SB1->(DBSeek(xFilial('SB1')+cProduto))
		SB1->(RecLock("SB1", .F.))
		SB1->B1_MSBLQL := "2"
		SB1->(MsUnlock())
	Endif

	DbSelectArea('SB5')
	Sb5->(DbSetOrder(1))
	If SB5->(dbseek(xFilial('SB5')+cProduto))

		Aadd(aProd2,{'B5_COD'     , padr(cProduto,TamSx3('B5_COD')[1]), NIL})
		Aadd(aProd2,{'B5_UMIND'   ,"1", NIL})
		Aadd(aProd2,{"B5_XACABAM", oProcess:oHTML:RetByName("B5_XACABAM"), NIL})
		Aadd(aProd2,{"B5_XTELAGE", oProcess:oHTML:RetByName("B5_XTELAGE"), NIL})
		Aadd(aProd2,{"B5_XVRTON" , oProcess:oHTML:RetByName("B5_XVRTON" ), NIL})
		Aadd(aProd2,{"B5_XESPESS", oProcess:oHTML:RetByName("B5_XESPESS"), NIL})
		Aadd(aProd2,{"B5_XGRPABS", oProcess:oHTML:RetByName("B5_XGRPABS"), NIL})
		Aadd(aProd2,{"B5_XPCCAIX", oProcess:oHTML:RetByName("B5_XPCCAIX"), NIL})
		Aadd(aProd2,{"B5_XGRAGUA", oProcess:oHTML:RetByName("B5_GRAGUA"), NIL})
		Aadd(aProd2,{"B5_XDIMFAB", oProcess:oHTML:RetByName("B5_XDIMFAB"), NIL})
		Aadd(aProd2,{"B5_XTIPOPR", oProcess:oHTML:RetByName("B5_XTIPOPR"), NIL})

		MSExecAuto({|x,y| Mata180(x,y)},aProd2,4)

		//Tratando erros caso ocorram
		IF lMsErroAuto
			aLog        := GetAutoGRLog()
			//Tratamento para o retorno do erro
			For nX := 1 to len(aLog)
				cErrorAuto += alltrim(EncodeUTF8(aLog[nX]))+'</br>'
			Next
			U_wfNoticaError("contato.michelrocha@gmail.com",cErrorAuto,cMessage)
		else
			U_DWFCONT4(cProduto)
		EndIF

		//Libera o produto para atualizar/cadastrar o SB5
		If SB1->(DBSeek(xFilial('SB1')+cProduto))
			SB1->(RecLock("SB1", .F.))
			SB1->B1_MSBLQL := "1"
			SB1->(MsUnlock())
		Endif

	Endif

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DWFRCON4 บAutor  ณ Walter Rodrigo     บ Data ณ  09/03/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Workflow para preenchimento do campo conta contabil do     บฑฑ
ฑฑบ          ณ produto                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa็ใo de produtos                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DWFRCON4(oProcess)
	Local cMessage   := ""
	Local nX         := 0
	Local lOk        := .T.
	Local cProduto   := oProcess:oHTML:RetByName("B1_COD")
	local aProd 	 := {}
	Local cErrorAuto := ""

	//variแvel de controle interno da rotina automatica que informa se houve erro durante o processamento
	Private lMsErroAuto := .F.
	//for็a a grava็ใo das informa็๕es de erro em array para manipula็ใo da grava็ใo ao inv้s de gravar direto no arquivo temporแrio
	Private lAutoErrNoFile := .T.

	DBSelectArea('Sb1')
	Sb1->(DbSetOrder(1))
	Sb1->(DBSeek(xFilial('SB1')+cProduto))

	Aadd(aProd, {"B1_COD   ", SB1->B1_COD   , NIL })
	Aadd(aProd, {"B1_DESC  ", SB1->B1_DESC  , NIL })
	Aadd(aProd, {"B1_TIPO  ", SB1->B1_TIPO  , NIL })
	Aadd(aProd, {"B1_UM    ", SB1->B1_UM    , NIL })
	Aadd(aProd, {"B1_LOCPAD", SB1->B1_LOCPAD, NIL })
	Aadd(aProd, {"B1_IPI"   , Val(StrTran(oProcess:oHTML:RetByName("B1_IPI"),",",".")), NIL })
	Aadd(aProd, {"B1_CEST"  , oProcess:oHTML:RetByName("B1_CEST"  )  , NIL })
	Aadd(aProd, {"B1_GRTRIB", oProcess:oHTML:RetByName("B1_GRTRIB")  , NIL })

	MSExecAuto({|x,y| Mata010(x,y)},aProd,4)

	IF lMsErroAuto
		aLog        := GetAutoGRLog()
		//Tratamento para o retorno do erro
		For nX := 1 to len(aLog)
			cErrorAuto += alltrim(EncodeUTF8(aLog[nX]))+'</br>'
		Next

		U_wfNoticaError("contato.michelrocha@gmail.com",cErrorAuto,cMessage)
	else
		U_DWFCONT5(cProduto)
	EndIF

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DWFRCON5 บAutor  ณ Walter Rodrigo     บ Data ณ  09/03/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Workflow para preenchimento do campo conta contabil do     บฑฑ
ฑฑบ          ณ produto                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa็ใo de produtos                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DWFRCON5(oProcess)
	Local cMessage  := ""
	Local nX        := 0
	Local lOk       := .T.
	Local cProduto  := oProcess:oHTML:RetByName("B1_COD")
	local aProd 	:= {}
	local aProd2 	:= {}
	local cErrorAuto := ""

	//variแvel de controle interno da rotina automatica que informa se houve erro durante o processamento
	Private lMsErroAuto := .F.
	//for็a a grava็ใo das informa็๕es de erro em array para manipula็ใo da grava็ใo ao inv้s de gravar direto no arquivo temporแrio
	Private lAutoErrNoFile := .T.

	DBSelectArea('Sb1')
	Sb1->(DbSetOrder(1))
	Sb1->(DBSeek(xFilial('SB1')+cProduto))

	Aadd(aProd, {"B1_COD   "   , SB1->B1_COD   , NIL })
	Aadd(aProd, {"B1_DESC  "   , SB1->B1_DESC  , NIL })
	Aadd(aProd, {"B1_TIPO  "   , SB1->B1_TIPO  , NIL })
	Aadd(aProd, {"B1_UM    "   , SB1->B1_UM    , NIL })
	Aadd(aProd, {"B1_LOCPAD"   , SB1->B1_LOCPAD, NIL })
	Aadd(aProd, {"B1_MSBLQL"   , "2", NIL })
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

		U_wfNoticaError("contato.michelrocha@gmail.com",cErrorAuto,cMessage)
	else
		//Chamada da fun็ใo se nใo ocorrer erro
		DbSelectArea('SB5')
		Sb5->(DbSetOrder(1))
		If SB5->(dbseek(xFilial('SB5')+cProduto))

			Aadd(aProd2,{'B5_COD'     , padr(cProduto,TamSx3('B5_COD')[1]), NIL})
			Aadd(aProd2,{'B5_UMIND'   ,"1", NIL})
			Aadd(aProd2,{'B5_CEME'    ,oProcess:oHTML:RetByName("B5_CEME"), NIL})
		

			MSExecAuto({|x,y| Mata180(x,y)},aProd2,4)

			//Tratando erros caso ocorram
			IF lMsErroAuto
				aLog        := GetAutoGRLog()
				//Tratamento para o retorno do erro
				For nX := 1 to len(aLog)
					cErrorAuto += alltrim(EncodeUTF8(aLog[nX]))+'</br>'
				Next
				U_wfNoticaError("contato.michelrocha@gmail.com",cErrorAuto,cMessage)
			else
				U_NotFiFim(SB1->B1_COD, SB1->B1_DESC)
			EndIF
		EndIf	
	EndIF


Return lOk

Static Function EnvConfPrd(cProduto, cConta)
	Local aArea      := GetArea()
	Local cDe        := GetMv("EL_RLMAIL")
	Local cPara      := "nucleo.cadastral@grupoelizabeth.com.br;cyntia.cavalcanti@grupoelizabeth.com.br;carine.carbonera@grupoelizabeth.com.br;rayanne.costa@grupoelizabeth.com.br"
	Local cCopia     := ""
	Local cConhCopia := ""
	Local cAssunto   := "Cadastro realizado com sucesso"
	Local cTexto     := ""
	Local lHtml      := .F.
	Local cFile      := ""
	//Local cSolic     := ""
	Local cDesc      := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_XDESCOM")

	cTexto := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> '
	cTexto += '  <html>
	cTexto += '  <head>
	cTexto += '  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	cTexto += '  <title>Aprovacao</title>
	cTexto += '  <style type="text/css">
	cTexto += '  <!--
	cTexto += '  .style1 {
	cTexto += '	font-family: "Courier New", Courier, monospace;
		cTexto += '	font-weight: bold;
		cTexto += '} '
	cTexto += '#apDiv1 {
	cTexto += '	position:absolute;
		cTexto += '	left:1149px;
		cTexto += '	top:25px;
		cTexto += '	width:160px;
		cTexto += '	height:85px;
		cTexto += '	z-index:1;
		cTexto += '}
	cTexto += '#apDiv2 {
	cTexto += '	position:absolute;
		cTexto += '	left:1126px;
		cTexto += '	top:20px;
		cTexto += '	width:174px;
		cTexto += '	height:92px;
		cTexto += '	z-index:1;
		cTexto += '}
	cTexto += '#apDiv3 {
	cTexto += '	position:absolute;
		cTexto += '	left:12px;
		cTexto += '	top:105px;
		cTexto += '	width:338px;
		cTexto += '	height:47px;
		cTexto += '	z-index:1;
		cTexto += '}
	cTexto += '#apDiv4 {
	cTexto += '	position:absolute;
		cTexto += '	left:156px;
		cTexto += '	top:91px;
		cTexto += '	width:226px;
		cTexto += '	height:19px;
		cTexto += '	z-index:1;
		cTexto += '}
	cTexto += '.aaaaa {	color: #FFF;
		cTexto += '}
	cTexto += '.bbbbbb {
	cTexto += '	color: #FFF;
		cTexto += '}
	cTexto += '.Numero {
	cTexto += '	text-align: right;
		cTexto += '}
	cTexto += '.RIGHT {
	cTexto += '	text-align: right;
		cTexto += '}
	cTexto += '.Branco {
	cTexto += '	color: #FFFFFF;
		cTexto += '}
	cTexto += '.table.table-striped.table-bordered.table-hover.table.table-sm tr td div {
	cTexto += '	text-align: justify;
		cTexto += '}
	cTexto += '-->
	cTexto += '  </style>

	cTexto += '<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css">
	cTexto += '		<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
	cTexto += '		<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"></script>
	cTexto += '		<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"></script>
	cTexto += '</head>

	cTexto += '<body>

	cTexto += '<fieldset>
	cTexto += '<legend class="style1"></legend>
	cTexto += '<form name="form1" method="post" action="mailto:%WFMailTo%">
	cTexto += '  <p class="font-weight-normal"><span class="Branco">O</span></p>
	cTexto += '  <table width="100%" border="1" bordercolor="#B2CBE7" class="table table-striped table-bordered table-hover table table-sm">
	cTexto += '    <tr bgcolor="#B2CBE7">
	cTexto += '      <td colspan="1" align="center" bgcolor="#1D5692"><strong class="bbbbbb"><span class="font-weight-normal">'+cAssunto+'</span></strong></td>
	cTexto += '    </tr>
	cTexto += '    <tr bgcolor="#B2CBE7">
	cTexto += '      <td width="100%"><div align="justify">
	cTexto += '        <p>&nbsp;</p>
	cTexto += '        <p>Prezado, </p>
	cTexto += '        <p><br>
	cTexto += '          Segue confirma็ใo da atualiza็ใo da conta no produto. <br>
	cTexto += '        </p>
	cTexto += '        <ol>
	cTexto += '          O produto '+cProduto+' - '+cDesc+' foi preenchido com a conta '+cConta+'. <br>
	cTexto += '        </ol> <br> <br> <br> <br>
	cTexto += '          </strong><br>
	cTexto += '        </p>
	cTexto += '            </div></td>

	cTexto += '      </tr>
	cTexto += '</table>
	cTexto += '  <p>&nbsp;</p>
	cTexto += '  <table width="294" border="1" align="justify" bordercolor="#B2CBE7" class="table table-striped table-bordered table-hover table table-sm">
	cTexto += '  </table>
	cTexto += '</form>
	cTexto += '</fieldset>
	cTexto += '</body>
	cTexto += '</html>
	cPara      := U_RetEmail(xFilial("ZW2") + "000001" + "000002")
	U_DrillEmail(cDe,cPara,cCopia,cConhCopia,cAssunto,cTexto,lHtml,cFile)

	RestArea(aArea)

Return


Static Function ConfirmPrd(cProduto, cConta)

	Local aArea      := GetArea()
	Local cDe        := GetMv("EL_RLMAIL")
	Local cPara      := Alltrim(Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_XMAILSO"))
	Local cCopia     := ""
	Local cConhCopia := ""
	Local cAssunto   := "Confirma็ใo do cadastro do produto"
	Local cTexto     := ""
	Local lHtml      := .F.
	Local cFile      := ""
	Local cDesc      := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_XDESCOM")

	cTexto := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> '
	cTexto += '  <html>
	cTexto += '  <head>
	cTexto += '  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	cTexto += '  <title>Aprovacao</title>
	cTexto += '  <style type="text/css">
	cTexto += '  <!--
	cTexto += '  .style1 {
	cTexto += '	font-family: "Courier New", Courier, monospace;
		cTexto += '	font-weight: bold;
		cTexto += '} '
	cTexto += '#apDiv1 {
	cTexto += '	position:absolute;
		cTexto += '	left:1149px;
		cTexto += '	top:25px;
		cTexto += '	width:160px;
		cTexto += '	height:85px;
		cTexto += '	z-index:1;
		cTexto += '}
	cTexto += '#apDiv2 {
	cTexto += '	position:absolute;
		cTexto += '	left:1126px;
		cTexto += '	top:20px;
		cTexto += '	width:174px;
		cTexto += '	height:92px;
		cTexto += '	z-index:1;
		cTexto += '}
	cTexto += '#apDiv3 {
	cTexto += '	position:absolute;
		cTexto += '	left:12px;
		cTexto += '	top:105px;
		cTexto += '	width:338px;
		cTexto += '	height:47px;
		cTexto += '	z-index:1;
		cTexto += '}
	cTexto += '#apDiv4 {
	cTexto += '	position:absolute;
		cTexto += '	left:156px;
		cTexto += '	top:91px;
		cTexto += '	width:226px;
		cTexto += '	height:19px;
		cTexto += '	z-index:1;
		cTexto += '}
	cTexto += '.aaaaa {	color: #FFF;
		cTexto += '}
	cTexto += '.bbbbbb {
	cTexto += '	color: #FFF;
		cTexto += '}
	cTexto += '.Numero {
	cTexto += '	text-align: right;
		cTexto += '}
	cTexto += '.RIGHT {
	cTexto += '	text-align: right;
		cTexto += '}
	cTexto += '.Branco {
	cTexto += '	color: #FFFFFF;
		cTexto += '}
	cTexto += '.table.table-striped.table-bordered.table-hover.table.table-sm tr td div {
	cTexto += '	text-align: justify;
		cTexto += '}
	cTexto += '-->
	cTexto += '  </style>

	cTexto += '<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css">
	cTexto += '		<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
	cTexto += '		<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"></script>
	cTexto += '		<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"></script>
	cTexto += '</head>

	cTexto += '<body>

	cTexto += '<fieldset>
	cTexto += '<legend class="style1"></legend>
	cTexto += '<form name="form1" method="post" action="mailto:%WFMailTo%">
	cTexto += '  <p class="font-weight-normal"><span class="Branco">O</span></p>
	cTexto += '  <table width="100%" border="1" bordercolor="#B2CBE7" class="table table-striped table-bordered table-hover table table-sm">
	cTexto += '    <tr bgcolor="#B2CBE7">
	cTexto += '      <td colspan="1" align="center" bgcolor="#1D5692"><strong class="bbbbbb"><span class="font-weight-normal">'+cAssunto+'</span></strong></td>
	cTexto += '    </tr>
	cTexto += '    <tr bgcolor="#B2CBE7">
	cTexto += '      <td width="100%"><div align="justify">
	cTexto += '        <p>&nbsp;</p>
	cTexto += '        <p>Prezado, </p>
	cTexto += '        <p><br>
	cTexto += '          Segue confirma็ใo do casdatro do produto. <br>
	cTexto += '        </p>
	cTexto += '        <ol>
	cTexto += '          O produto '+cProduto+' - '+cDesc+' foi cadastrado com sucesso. <br>
	cTexto += '        </ol> <br> <br> <br> <br>
	cTexto += '          </strong><br>
	cTexto += '        </p>
	cTexto += '            </div></td>
	cTexto += '      </tr>
	cTexto += '</table>
	cTexto += '  <p>&nbsp;</p>
	cTexto += '  <table width="294" border="1" align="justify" bordercolor="#B2CBE7" class="table table-striped table-bordered table-hover table table-sm">
	cTexto += '  </table>
	cTexto += '</form>
	cTexto += '</fieldset>
	cTexto += '</body>
	cTexto += '</html>
	U_DrillEmail(cDe,cPara,cCopia,cConhCopia,cAssunto,cTexto,lHtml,cFile)

	RestArea(aArea)

Return
