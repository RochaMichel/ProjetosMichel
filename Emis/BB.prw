#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#Include 'TbIconn.CH'

//#Define cAppKey "eb44e9fd1827f28b90e6c2edcf306b1b"
//#Define cClientID "eyJpZCI6Ijc1Yjg2ODQtMDc0OS00MmEwLWI3MDAtYjQ3IiwiY29kaWdvUHVibGljYWRvciI6MCwiY29kaWdvU29mdHdhcmUiOjU3ODA2LCJzZXF1ZW5jaWFsSW5zdGFsYWNhbyI6MX0"
//#Define cClientSecret "eyJpZCI6ImVlYzVhYzctYmE3Ny0iLCJjb2RpZ29QdWJsaWNhZG9yIjowLCJjb2RpZ29Tb2Z0d2FyZSI6NTc4MDYsInNlcXVlbmNpYWxJbnN0YWxhY2FvIjoxLCJzZXF1ZW5jaWFsQ3JlZGVuY2lhbCI6MSwiYW1iaWVudGUiOiJob21vbG9nYWNhbyIsImlhdCI6MTY3OTQ4ODQwNjQzMX0"
//#Define cAppKey "0420861c0267291b149a6025d8d4db70"
//#Define cClientID "eyJpZCI6IjQwZjQ4OCIsImNvZGlnb1B1YmxpY2Fkb3IiOjAsImNvZGlnb1NvZnR3YXJlIjo0NDU3NCwic2VxdWVuY2lhbEluc3RhbGFjYW8iOjF9"
//#Define cClientSecret "eyJpZCI6IjQwZWIxZGEtNDI2Yy00IiwiY29kaWdvUHVibGljYWRvciI6MCwiY29kaWdvU29mdHdhcmUiOjQ0NTc0LCJzZXF1ZW5jaWFsSW5zdGFsYWNhbyI6MSwic2VxdWVuY2lhbENyZWRlbmNpYWwiOjEsImFtYmllbnRlIjoicHJvZHVjYW8iLCJpYXQiOjE2ODM2NTU2MTU3ODZ9"
#DEFINE ENTER Chr(10) + Chr (13)

/*/{Protheus.doc} BB
Função principal da integração BB
@type function
@author Cod.Erp
@since 7/11/2023
/*/
User Function BB(nAcao)
	Local cUUID  	:= GetMV("MV_XAPPKEY", .F., "")
	//Local cUUID 	:= cAppKey
	Local oModel 	:= Nil
	Local lExclui 	:= .F. //Variável de retorno exclusiva para o uso da exclusão de documento 12.09.2023 - Mateus Ramos
	Default nAcao  	:= 0
	Private cClientID := GetMV("MV_XCLIEID", .F., "")
	Private cClientSecret := GetMV("MV_XCLIESE", .F., "")
	Private cLog 	:= ""

	If Posicione('SA1',1,FWxFilial('SA1')+SE1->E1_CLIENTE+SE1->E1_LOJA,'A1_XBOLHIB') <> 'S'
		FWAlertWarning("Cliente não está apto ao uso do boleto híbrido.", "Boleto Híbrido - Aviso")
		Return cLog
	ElseIf Empty(cUUID) .OR. Empty(cClientID) .OR. Empty(cClientSecret)
		FWAlertWarning("Favor checar parâmetros da API e preenche-los corretamente.", "Boleto Híbrido - Aviso")
		Return cLog
	EndIf

	If nAcao == 1
		If !Empty(SE1->E1_XNUMBOL)
			FWAlertWarning("Título já possui numeração no banco.", "Registra Boleto - Aviso")
			Return cLog
		EndIf
		oModel := FwModelActive()
		Registra(cUUID)
		If FunName() == "FINA740"
			oModel:DeActivate()
			oModel:Activate()
		EndIf
	ElseIf nAcao == 2
		Prorroga(cUUID)
	ElseIf nAcao == 3
		oModel := FwModelActive()
		lExclui := Retira(cUUID)
		If FunName() == "FINA740"
			oModel:DeActivate()
			oModel:Activate()
		Else
			Return lExclui
		EndIf
	Endif

Return cLog

/*/{Protheus.doc} RetAuth
Função de autenticação
@type function
@author Cod.Erp
@since 7/11/2023
/*/

Static Function RetAuth()
//Local cURL       	:= "https://oauth.hm.bb.com.br"
	Local cURL       	:= "https://oauth.bb.com.br"
	Local cBase64    	:= Encode64(cClientID+":"+cClientSecret)
	Local cAuth      	:= "Authorization: Basic "+cBase64
	Local cContent   	:= "Content-Type: application/x-www-form-urlencoded"
	Local aHeader   	:= {}
	Local oRest     	:= FWRest():New(cURL)
	Local cJson     	:= "grant_type=client_credentials&scope=cobrancas.boletos-info+cobrancas.boletos-requisicao"
	Local oJRet     	:= JSonObject():New()
	Private cTkType 	:= ""

	Aadd(aHeader, cAuth)
	Aadd(aHeader, cContent)

	oRest:setPath("/oauth/token")
	oRest:SetPostParams(cJson)
	oRest:Post(aHeader)
	If oRest:GetHTTPCode() $ "200/201"
		oJRet:fromJson(oRest:GetResult())
		cAcessTk  := oJRet:GetJSonObject('access_token')
		cTkType   := oJRet:GetJSonObject('token_type')
		cExpireIn := oJRet:GetJSonObject('expires_in')
	Else
		cErro := DecodeUTF8(oRest:GetResult(), "cp1252")
		If FunName() == "FINA740"
			FWAlertError(cErro,"RetAuth - Erro")
			Return ""
		Else
			cLog := Replicate("-",101) + ENTER + ENTER
			cLog += "Banco: BB  -  Título: "+SE1->E1_NUM+"  Parcela: "+SE1->E1_PARCELA+ ENTER + ENTER
			cLog += "Mensagem: " + cErro
			cLog += Replicate("-",101) + ENTER + ENTER
			Return ""
		EndIf
	Endif

// Valida o retorno
	If Type("cAcessTk")=="U" .or. Empty(cAcessTk)
		Return ""
	Endif

Return "Authorization: "+cTkType+" "+cAcessTk


/*/{Protheus.doc} Registra
Função que registra boleto no banco
@type function
@author Cod.Erp
@since 7/11/2023
/*/

Static Function Registra(cUUID, cValor)

	Local cAuth     := RetAuth()
	Local cIDCNAB 	:= ""
	Local cContent  := "Content-Type: application/json "
	Local aHeader   := {}
	Local oRest     := FWRest():New("https://api.bb.com.br")
	Local oJRet     := JSonObject():New()
	Local oJBody    := JSonObject():New()
	Local cNUMBOL   := ""
	Local cMsg 		:= ""
	Local cNUMCON 	:= ""
	Local cCodCart 	:= ""
	Local cVarCart  := ""
	Local cAgencia 	:= ""
	Local cConta 	:= ""
	Local nPerc 	:= 0
	Local aSEE      := {}

	//PesqSEE(@cNUMCON,@cConta,@cAgencia, @cCodCart, @cVarCart)
	aSEE := PesqSEEV2("001")//{cFilInfo, cCodigo, cAgencia, cConta, cSubCta, cNUMCON, cCodCart, cVarCart}

	cBanco   := aSEE[2]
	cSubCta  := aSEE[5]

	cAgencia := aSEE[3]
	cConta   := aSEE[4]
	cNUMCON  := aSEE[6]
	cCodCart := aSEE[7]
	cVarCart := aSEE[8]
//Local cEEBanco	:= PadR(SuperGetMV("MV_XEEBAN", .F., "001"),TamSX3("EE_CODIGO")[1])
//Local cEEAgenc	:= PadR(SuperGetMV("MV_XEEAGE", .F., "34339"),TamSX3("EE_AGENCIA")[1])
//Local cEEConta	:= PadR(SuperGetMV("MV_XEECON", .F., "27515-8"),TamSX3("EE_CONTA")[1])

// Valida a autorização
	If Empty(cAuth)
		Return ""
	ElseIf Empty(cNUMCON)
		FWAlertWarning("Não foi encontrada conexão remota para este banco. Processo encerrado.", "Registra Boleto - Aviso")
		Return ""
	Endif

	cNN     := RetNN(cBanco, cAgencia, cConta, cSubConta)
	cNUMBOL := "000" + PadL(cNUMCON,7,"0") + strZero(Val(cNN),10)
	If Select('SA1') == 0
		DbSelectArea('SA1')
	EndIf
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(FWxFilial('SA1')+SE1->E1_CLIENTE+SE1->E1_LOJA))
		oJBody["numeroConvenio"] 						:= cNUMCON
		oJBody["numeroCarteira"] 						:= cCodCart
		oJBody["numeroVariacaoCarteira"] 				:= cVarCart
		oJBody["dataEmissao"] 							:= dateFormat(SE1->E1_EMISSAO, "dd.mm.yyyy")
		oJBody["dataVencimento"] 						:= dateFormat(SE1->E1_VENCREAL, "dd.mm.yyyy")
		oJBody["valorOriginal"] 						:= SE1->E1_VALOR
		oJBody["jurosMora"] 							:= JSonObject():New()

		//Controle de juros
		//Tipos: 0 - Sem juros; 1 - Valor fixo por dias de atraso; 2 - Taxa mensal; 3 - Isento.
		oJBody["jurosMora"]["tipo"] 					:= GetMv("MV_XTIPJUR", .F., 0)

		If oJBody["jurosMora"]["tipo"] == 1	//Caso seja valor fixo, verifica parâmetro de Valor de Juros.
			oJBody["jurosMora"]["valor"] 				:= GetMV("MV_XVALJUR", .F., 0)
		ElseIf oJBody["jurosMora"]["tipo"] == 2 //Caso seja percentual, verifica o parâmetro de percentual de juros.
			oJBody["jurosMora"]["porcentagem"] 			:= GetMV("MV_XPORJUR", .F., 0)
		EndIf

		oJBody["desconto"] 								:= JSonObject():New()
		//Controle de descontos
		//Tipos: 0 - Sem desconto; 1 - Valor fixo até a data informada; 2 - Percentual até a data informada.
		oJBody["desconto"]["tipo"] 						:= GetMV("MV_XTIPDES", .F., 0)

		If oJBody["desconto"]["tipo"] == 1	//Caso seja valor fixo, verifica o parâmetro de valor de desconto.
			oJBody["desconto"]["valor"] 		:= GetMV("MV_XVALDES", .F., 0)
			oJBody["desconto"]["dataExpiracao"] := dateFormat(SE1->E1_VENCREAL-1, "dd.mm.yyyy") //Data limite de desconto definida por vencimento.
		ElseIf oJBody["desconto"]["tipo"] == 2	//Caso seja percentual, verifica o parâmetro de percentual de desconto.
			oJBody["desconto"]["porcentagem"] 	:= GetMV("MV_XPORDES", .F., 0)
			oJBody["desconto"]["dataExpiracao"] := dateFormat(SE1->E1_VENCREAL-1, "dd.mm.yyyy") //Data limite de desconto definida por vencimento.
		ElseIf oJBody["desconto"]["tipo"] == 3	//Caso seja valor multiplicado por dia de antecedencia, verifica o parâmetro de percentual de desconto.
			nPerc := GetMV("MV_XPORDES", .F., 0)
			oJBody["desconto"]["valor"] 		:= (SE1->E1_VALOR * IIF(nPerc <= 9, Val("0.0"+CValToChar(nPerc)), IIF(nPerc >= 10 .AND. nPerc <= 99, Val("0."+CValToChar(nPerc)), nPerc / 100))) / 30
			//oJBody["desconto"]["dataExpiracao"] := dateFormat(SE1->E1_VENCREAL-1, "dd.mm.yyyy") //Data limite de desconto definida por vencimento.
		EndIf

		//oJBody["valorOriginal"] 						:= 0.50
		oJBody["codigoAceite"] 							:= "A"
		oJBody["indicadorPermissaoRecebimentoParcial"] 	:= "N"
		oJBody["numeroTituloCliente"] 					:= cNUMBOL
		oJBody["numeroTituloBeneficiario"] 				:= SE1->E1_NUM		//Adicionado o numero titulo beneficiario para exibir no extrato - 18/10/2023
		oJBody["pagador"] 								:= JSonObject():New()
		oJBody["pagador"]["tipoInscricao"] 				:= IIF(SA1->A1_PESSOA == "F",1,2)
		oJBody["pagador"]["numeroInscricao"] 			:= SA1->A1_CGC
		oJBody["pagador"]["nome"] 						:= SA1->A1_NOME
		oJBody["pagador"]["endereco"] 					:= SA1->A1_END
		oJBody["pagador"]["cep"] 						:= SA1->A1_CEP
		oJBody["pagador"]["cidade"] 					:= SA1->A1_MUN
		oJBody["pagador"]["bairro"] 					:= SA1->A1_BAIRRO
		oJBody["pagador"]["uf"] 						:= SA1->A1_EST
		oJBody["indicadorPix"]                          := "S"
		//EndIf
	/*
	oJBody["numeroConvenio"] := Val(SEE->EE_CODEMP) 
	oJBody["numeroCarteira"] := 17 
	oJBody["numeroVariacaoCarteira"] := 35 
	oJBody["dataEmissao"] := "28.03.2023" 
	oJBody["dataVencimento"] := "20.12.2023" 
	oJBody["valorOriginal"] := 123.45 
	oJBody["codigoAceite"] := "A" 
	oJBody["indicadorPermissaoRecebimentoParcial"] := "N" 
	oJBody["numeroTituloCliente"] := cNUMBOL
	oJBody["pagador"] := JSonObject():New()
	oJBody["pagador"]["tipoInscricao"] := 1 
	oJBody["pagador"]["numeroInscricao"] := 97965940132 
	oJBody["pagador"]["nome"] := "Odorico Paraguassu" 
	oJBody["pagador"]["endereco"] := "Avenida Dias Gomes 1970" 
	oJBody["pagador"]["cep"] := 77458000 
	oJBody["pagador"]["cidade"] := "Sucupira" 
	oJBody["pagador"]["bairro"] := "Centro" 
	oJBody["pagador"]["uf"] := "TO"
	oJBody["indicadorPix"] := "S"
	*/

		Aadd(aHeader, cAuth)
		Aadd(aHeader, cContent)
		oRest:setPath("/cobrancas/v2/boletos?gw-dev-app-key="+cUUID)
		oRest:SetPostParams(oJBody:toJson())
		oRest:POST(aHeader)
		oJRet:fromJson(oRest:GetResult())

		Begin Transaction
			//Pegando o IDCNAB conforme a SXE
			cIDCNAB	:= GetSxENum("SE1", "E1_IDCNAB","E1_IDCNAB" + cEmpAnt, 19)
			ConfirmSX8() //Atualiza a tabela SXE
			If oRest:GetHTTPCode() $ "201/200"
				Reclock("SE1", .F.)
				SE1->E1_PORTADO := "001"
				SE1->E1_AGEDEP 	:= cAgencia
				SE1->E1_CONTA 	:= cConta
				SE1->E1_IDCNAB  := cIDCNAB
				SE1->E1_XNUMBOL := cNUMBOL
				SE1->E1_XBOLHIB := 'S'
				SE1->(MsUnlock())
				RecLock("ZBH", .T.)
				ZBH->ZBH_FILIAL := FWxFilial('ZBH')
				ZBH->ZBH_IDCNAB := cIDCNAB
				ZBH->ZBH_PREFIX	:= SE1->E1_PREFIXO
				ZBH->ZBH_TITULO := SE1->E1_NUM
				ZBH->ZBH_PARCEL := SE1->E1_PARCELA
				ZBH->ZBH_NUMBOL := cNUMBOL
				ZBH->ZBH_NUMCON := cNUMCON
				ZBH->ZBH_EMV 	:= oJRet:GetJSonObject('qrCode')['emv']
				ZBH->ZBH_TXID 	:= oJRet:GetJSonObject('qrCode')['txId']
				ZBH->ZBH_CODBAR := oJRet['codigoBarraNumerico']
				ZBH->ZBH_LINDIG := oJRet['linhaDigitavel']
				ZBH->ZBH_DATA 	:= Date()
				ZBH->ZBH_HORA 	:= Time()
				ZBH->ZBH_ACAO	:= "Boleto registrado no banco"
				ZBH->(MsUnlock())
				If FunName() == "FINA740"
					FWAlertSuccess("Boleto registrado no banco.", "Registra Boleto - Sucesso")
				EndIf
				cLog := ""
			Else
				cMsg := oRest:GetResult()
				If FunName() == "FINA740"
					FWAlertError(cMsg, "Registra Boleto - Erro")
				Else
					cLog := Replicate("-",101) + ENTER + ENTER
					cLog += "Banco: BB  -  Título: "+SE1->E1_NUM+"  Parcela: "+SE1->E1_PARCELA+ ENTER + ENTER
					cLog += "Mensagem: " + cMsg
					cLog += Replicate("-",101) + ENTER + ENTER
				EndIf
			Endif
		End Transaction
	Else
		FWAlertWarning("Não foi encontrada conexão remota para este banco. Processo encerrado.", "Registra Boleto - Aviso")
	EndIf
Return

/*/{Protheus.doc} Prorroga
Função que prorroga vencimento do boleto
@type function
@author Cod.Erp
@since 7/11/2023
/*/
Static Function Prorroga(cUUID)

	Local cAuth     	:= RetAuth()
	Local cContent  	:= "Content-Type: application/json "
	Local aHeader   	:= {}
	//Local cURL     		:= "https://api.hm.bb.com.br"
	Local cURL     		:= "https://api.bb.com.br"
	Local cPath 		:= ""
	Local oJBody    	:= JSonObject():New()
	Local cHeaderRet	:= ""
	Local cMsg      	:= {}
	Local cZIDC := ZBH->ZBH_IDCNAB
	Local cZPRE := ZBH->ZBH_PREFIX
	Local cZTIT := ZBH->ZBH_TITULO
	Local cZPAR := ZBH->ZBH_PARCEL
	Local cZNUM := ZBH->ZBH_NUMBOL
	Local cZCON := ZBH->ZBH_NUMCON
	Local cEMV  := ZBH->ZBH_EMV
	Local cZTXI := ZBH->ZBH_TXID
	Local cZCBR := ZBH->ZBH_CODBAR
	Local cZLND := ZBH->ZBH_LINDIG
	//Local cEEBanco	:= PadR(SuperGetMV("MV_XEEBAN", .F., "001"),TamSX3("EE_CODIGO")[1])
	//Local cEEAgenc	:= PadR(SuperGetMV("MV_XEEAGE", .F., "34339"),TamSX3("EE_AGENCIA")[1])
	//Local cEEConta	:= PadR(SuperGetMV("MV_XEECON", .F., "27515-8"),TamSX3("EE_CONTA")[1])

// Valida a autorização
	If Empty(cAuth)
		Return ""
	Endif

	//If Select('SEE') == 0
	//	DbSelectArea('SEE')
	//Endif

	//SEE->(DbSetOrder(1))
	//If SEE->(DbSeek(FWxFilial('SEE')+cEEBanco+cEEAgenc+cEEConta))
	oJBody["numeroConvenio"] := Val(cZCON)
	oJBody["indicadorCancelarAbatimento"] := "N"
	oJBody["indicadorNovaDataVencimento"] := "S"
	oJBody["alteracaoData"] := JSonObject():New()
	oJBody["alteracaoData"]["novaDataVencimento"] := dateFormat(SE1->E1_VENCREAL, "dd.mm.yyyy")
	oJBody["indicadorAlterarDesconto"] := "N"
	oJBody["indicadorAlterarDataDesconto"] := "N"
	oJBody["indicadorProtestar"] := "N"
	oJBody["indicadorSustacaoProtesto"] := "N"
	oJBody["indicadorCancelarProtesto"] := "N"
	oJBody["indicadorIncluirAbatimento"] := "N"
	oJBody["indicadorAlterarAbatimento"] := "N"
	oJBody["indicadorCobrarJuros"] := "N"
	oJBody["indicadorDispensarJuros"] := "N"
	oJBody["indicadorNegativar"] := "N"
	oJBody["indicadorAlterarSeuNumero"] := "N"
	oJBody["indicadorAlterarEnderecoPagador"] := "N"
	oJBody["indicadorAlterarPrazoBoletoVencido"] := "N"

	If Select('ZBH') == 0
		DbSelectArea('ZBH')
	EndIf

	cPath := cURL+"/cobrancas/v2/boletos/"+cZNUM+"?gw-dev-app-key="+cUUID

	Aadd(aHeader, cAuth)
	Aadd(aHeader, cContent)

	cMsg := HTTPQuote(cPath, "PATCH", , oJBody:toJson() , 120, aHeader, @cHeaderRet)

	RecLock("ZBH", .T.)
	ZBH->ZBH_FILIAL := FWxFilial('ZBH')
	ZBH->ZBH_IDCNAB := cZIDC
	ZBH->ZBH_PREFIX	:= cZPRE
	ZBH->ZBH_TITULO := cZTIT
	ZBH->ZBH_PARCEL := cZPAR
	ZBH->ZBH_NUMBOL := cZNUM
	ZBH->ZBH_EMV 	:= cEMV
	ZBH->ZBH_NUMCON := cZCON
	ZBH->ZBH_TXID 	:= cZTXI
	ZBH->ZBH_CODBAR := cZCBR
	ZBH->ZBH_LINDIG := cZLND
	ZBH->ZBH_DATA 	:= Date()
	ZBH->ZBH_HORA 	:= Time()
	ZBH->ZBH_ACAO	:= "Vencimento do boleto prorrogado"
	ZBH->(MsUnlock())
	FWAlertSuccess("Vencimento prorrogado.", "Prorroga Vencimento - Sucesso")
	//Else
	//	FWAlertWarning("Não foi encontrada conexão remota para este banco. Processo encerrado.", "Prorroga Vencimento - Aviso")
	//EndIf

Return

/*/{Protheus.doc} Retira
Função que retira boleto do banco
@type function
@author Cod.Erp
@since 7/11/2023
/*/
Static Function Retira(cUUID)

	Local cAuth := RetAuth()
	Local cZIDC := ""
	Local cZPRE := ""
	Local cZTIT := ""
	Local cZPAR := ""
	Local cZNUM := ""
	Local cEMV  := ""
	Local cZTXI := ""
	Local cZCBR := ""
	Local cZLND := ""
	Local cZCON := ""
	Local cContent  := "Content-Type: application/json "
	Local aHeader   := {}
	Local lRet 		:= .F.
	//Local oRest     := FWRest():New("https://api.hm.bb.com.br")
	Local oRest     := FWRest():New("https://api.bb.com.br")
	Local oJRet     := JSonObject():New()
	Local oJBody    := JSonObject():New()
	//Local cEEBanco	:= PadR(SuperGetMV("MV_XEEBAN", .F., "001"),TamSX3("EE_CODIGO")[1])
	//Local cEEAgenc	:= PadR(SuperGetMV("MV_XEEAGE", .F., "34339"),TamSX3("EE_AGENCIA")[1])
	//Local cEEConta	:= PadR(SuperGetMV("MV_XEECON", .F., "27515-8"),TamSX3("EE_CONTA")[1])

// Valida a autorização
	If Empty(cAuth)
		Return .F.
	Endif

	//SEE->(DbSetOrder(1))
	//If SEE->(DbSeek(FWxFilial('SEE')+cEEBanco+cEEAgenc+cEEConta))

	Aadd(aHeader, cAuth)
	Aadd(aHeader, cContent)

	If Select('ZBH') == 0
		DbSelectArea('ZBH')
	EndIf
	ZBH->(DbSetOrder(1))
	If ZBH->(DbSeek(FWxFilial('ZBH')+SE1->E1_IDCNAB))
		If ZBH->ZBH_FLAGPG == 'P'
			FWAlertWarning("Boleto já foi pago.", "Retira Boleto - Aviso")
			Return .F.
		EndIf
		cZIDC := ZBH->ZBH_IDCNAB
		cZPRE := ZBH->ZBH_PREFIX
		cZTIT := ZBH->ZBH_TITULO
		cZPAR := ZBH->ZBH_PARCEL
		cZNUM := ZBH->ZBH_NUMBOL
		cEMV  := ZBH->ZBH_EMV
		cZTXI := ZBH->ZBH_TXID
		cZCBR := ZBH->ZBH_CODBAR
		cZLND := ZBH->ZBH_LINDIG
		cZCON := ZBH->ZBH_NUMCON


		oJBody["numeroConvenio"] := Val(cZCON)
	Else
		FWAlertWarning("Não foi encontrado boleto referente a este título", "Prorroga Boleto - Aviso")
		Return .T.
	Endif

	oRest:setPath("/cobrancas/v2/boletos/"+cZNUM+"/baixar?gw-dev-app-key="+cUUID)
	oRest:SetPostParams(oJBody:toJson())
	oRest:POST(aHeader)
	oJRet:fromJson(oRest:GetResult())
	If oRest:GetHTTPCode() $ "201/200"
		RecLock("ZBH", .T.)
		ZBH->ZBH_FILIAL := FWxFilial('ZBH')
		ZBH->ZBH_IDCNAB := cZIDC
		ZBH->ZBH_PREFIX	:= cZPRE
		ZBH->ZBH_TITULO := cZTIT
		ZBH->ZBH_PARCEL := cZPAR
		ZBH->ZBH_NUMBOL := cZNUM
		ZBH->ZBH_EMV 	:= cEMV
		ZBH->ZBH_NUMCON := cZCON
		ZBH->ZBH_TXID 	:= cZTXI
		ZBH->ZBH_CODBAR := cZCBR
		ZBH->ZBH_LINDIG := cZLND
		ZBH->ZBH_DATA 	:= Date()
		ZBH->ZBH_HORA 	:= Time()
		ZBH->ZBH_ACAO	:= "Boleto retirado do banco"
		ZBH->(MsUnlock())
		If ZBH->(DbSeek(xFilial('ZBH')+cZIDC))
			While ZBH->ZBH_IDCNAB == cZIDC
				RecLock('ZBH',.F.)
				ZBH->ZBH_FLAGPG := 'R'
				ZBH->(MsUnlock())
				ZBH->(DbSkip())
			End
		EndIf
		RecLock("SE1", .F.)
		// SE1->E1_PORTADO := ""
		// SE1->E1_AGEDEP  := ""
		// SE1->E1_CONTA   := ""
		SE1->E1_XNUMBOL := ""
		SE1->E1_IDCNAB	:= ""
		SE1->(MsUnlock())
		lRet := .T.
		FWAlertSuccess("Retirada realizada.", "Retira Boleto - Sucesso")
	ElseIf oRest:GetHTTPCode() $ "404"
		Atualiza(cZIDC,cZPRE,cZTIT,cZPAR,cEMV,cZTXI,cZCON,cZCBR,cZLND)
		FWAlertError("Retirada do boleto já foi efetuada anteriormente.", "Retira Boleto - Erro")
		lRet := .T.
	Else
		cMsg := FwNoAccent(oRest:cResult)
		FWAlertError(cMsg, "Retira Boleto - Erro")
	Endif
	//Else
	//	FWAlertWarning("Não foi encontrada conexão remota para este banco. Processo encerrado.", "Retira Boleto - Aviso")
	//EndIf

Return lRet

/*/{Protheus.doc} Atualiza
Função auxiliar para atualizar linhas do mesmo boleto já pago ou retirado
@type function
@author Cod.Erp
@since 7/11/2023
/*/
Static Function Atualiza(cIDCNAB,cPrefixo,cTitulo,cParcela,cUrl,cTxid,cNUMCON,cCodBar,cLinDig)

	Local cQuery 		:= ""
	Local cAliasAux 	:= GetNextAlias()
	Default cIDCNAB 	:= ""
	Default cPrefixo 	:= ""
	Default cTitulo 	:= ""
	Default cParcela 	:= ""
	Default cEmv 		:= ""
	Default cTxid 		:= ""
	Default cNUMCON 	:= ""

	cQuery += " SELECT * FROM "+RetSqlName('ZBH')+" "
	cQuery += " WHERE ZBH_IDCNAB = '"+cIDCNAB+"' "
	cQuery += "	AND ZBH_ACAO LIKE '%retirado%' AND D_E_L_E_T_ = ' ' "

	MpSysOpenQuery(cQuery, (cAliasAux))

	If (cAliasAux)->(EoF())
		RecLock("ZBH", .T.)
		ZBH->ZBH_FILIAL := FWxFilial('ZBH')
		ZBH->ZBH_IDCNAB := cIDCNAB
		ZBH->ZBH_PREFIX	:= cPrefixo
		ZBH->ZBH_TITULO := cTitulo
		ZBH->ZBH_PARCEL := cParcela
		ZBH->ZBH_EMV 	:= cEmv
		ZBH->ZBH_NUMCON := cNUMCON
		ZBH->ZBH_TXID 	:= cTxid
		ZBH->ZBH_CODBAR := cCodBar
		ZBH->ZBH_LINDIG := cLinDig
		ZBH->ZBH_DATA 	:= Date()
		ZBH->ZBH_HORA 	:= Time()
		ZBH->ZBH_ACAO	:= "Boleto retirado no banco"
		ZBH->(MsUnlock())
	EndIf

	(cAliasAux)->(DbCloseArea())

Return

/*/{Protheus.doc} PesqSEE
Função auxiliar para encontrar numero convenio a ser utilizado
@type function
@author Cod.Erp
@since 7/11/2023
/*/
Static Function PesqSEE(cNUMCON, cConta, cAgencia, cCodCart, cVarCart)

	Local cQuery 		:= ""
	Local cAliasAux 	:= GetNextAlias()

	cQuery += " SELECT * FROM "+RetSqlName('SEE')+" "
	cQuery += " WHERE EE_XBOLHIB = 'S' "
	cQuery += "	AND EE_CODIGO = '001' "
	cQuery += "	AND D_E_L_E_T_ <> '*' "

	MpSysOpenQuery(cQuery, (cAliasAux))

	If (cAliasAux)->(!EoF())
		cNUMCON 	:= (cAliasAux)->EE_CODEMP
		cAgencia 	:= (cAliasAux)->EE_AGENCIA
		cConta 		:= (cAliasAux)->EE_CONTA
		cCodCart	:= (cAliasAux)->EE_CODCART
		cVarCart 	:= (cAliasAux)->EE_VARCART
	EndIf

	(cAliasAux)->(DbCloseArea())

Return

/*/{Protheus.doc} PesqSEEV2
Função auxiliar para encontrar numero convenio a ser utilizado
@type function
@author Cod.Erp
@since 7/11/2023
/*/
Static Function PesqSEEV2(cBanco)

	Local cQuery 		:= ""
	Local cAliasAux 	:= GetNextAlias()
	Local cFilInfo      := ""
	Local cCodigo       := "" 

	cQuery += " SELECT * FROM "+RetSqlName('SEE')+" "
	cQuery += " WHERE EE_XBOLHIB = 'S' "
	cQuery += "	AND EE_CODIGO = '"+cBanco+"' "
	cQuery += "	AND D_E_L_E_T_ <> '*' "

	MpSysOpenQuery(cQuery, (cAliasAux))

	If (cAliasAux)->(!EoF())
		cFilInfo    := (cAliasAux)->EE_FILIAL
		cCodigo     := (cAliasAux)->EE_CODIGO
		cAgencia 	:= (cAliasAux)->EE_AGENCIA
		cConta 		:= (cAliasAux)->EE_CONTA
		cSubCta     := (cAliasAux)->EE_SUBCTA
		cNUMCON 	:= (cAliasAux)->EE_CODEMP
		cCodCart	:= (cAliasAux)->EE_CODCART
		cVarCart 	:= (cAliasAux)->EE_VARCART
	EndIf

	(cAliasAux)->(DbCloseArea())

Return {cFilInfo, cCodigo, cAgencia, cConta, cSubCta, cNUMCON, cCodCart, cVarCart}

/*/{Protheus.doc} PesqSEEV2
Função auxiliar para encontrar numero convenio a ser utilizado
@type function
@author Cod.Erp
@since 7/11/2023
/*/
Static Function RetNN(cBanco, cAgencia, cConta, cSubConta)
	Local cNossoNum := ""
	Local aAreaAtu  := GetArea()

	DbSelectArea("SEE")
	SEE->(DbSetOrder(1))
	If SEE->(DbSeek(xFilial("SEE") + cBanco + cAgencia + cConta + cSubConta))
		cNossoNum := NossoNum()
	Endif

	RestArea(aAreaAtu)

Return cNossoNum
