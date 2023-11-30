#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

#Define cUrl "https://payment.safrapay.com.br"
#Define cUrlPortal "https://portal-api.safrapay.com.br"
#Define cUrlBase "https://portal.safrapay.com.br"
#Define cMercTk "mk_78Zx4h7YgkaBWtBIsvLyvg"
#Define cIdCli "e271c6ef-d81e-4682-815a-d048b2f2f2be"
#Define cUrlCielo "https://cieloecommerce.cielo.com.br"
#Define cClientID "f72ff94d-da2b-48a5-bdb8-5ef92f4ed354"
#Define cClientSC "iOSbQOKiHzExAvtwfKrWhofBQ+YpyDkBWLHO5UTa6EE="

User function jobStatus()
	Local cAlias         := GetNextAlias()
    Private lAtivAmb := .T.
	// Prepara o ambiente caso precise
	If Select("SX2") == 0
		RPCClearEnv()
		RpcSetType(3)
		RpcSetEnv( "01",'0101', , , "",,, , , ,  )
		lAtivAmb := .T. // Seta se precisou montar o ambiente
	Endif
    cQuery := " SELECT * FROM "+RetSqlName("ZLP")+" WHERE R_E_C_N_O_ <> R_E_C_D_E_L_  AND ZLP_STATUS = 1 AND ZLP_CODLP = '000112'"
    MpSysOpenQuery(cQuery, cAlias)
    
	while (cAlias)->(!EOF())
		If (cAlias)->ZLP_BANCO == "2"
			DetLink((cAlias)->ZLP_FILIAL+(cAlias)->ZLP_CODLP,AllTrim((cAlias)->ZLP_IDLINK))
		ElseIf (cAlias)->ZLP_BANCO == "1"
			DLinkCielo((cAlias)->ZLP_FILIAL+(cAlias)->ZLP_CODLP,AllTrim((cAlias)->ZLP_IDLINK))
		EndIf
		(cAlias)->(DbSkip())
	End

    If lAtivAmb == .T.
		RpcClearEnv()
	EndIF
Return


/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | DetLink    | Autor |    Rivaldo Jr.  ( Cod.ERP )                 |*
*+------------+------------------------------------------------------------------+*
*|Data        | 29.09.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao para buscar os detalhes de um link de pagamento           |*
*+------------+------------------------------------------------------------------+*
*|Parâmetro   | Necessita do ID do link de pagamento                             |*
**********************************************************************************/
Static Function DetLink(cfiltro,cidlink)
    Local cAuth          := "Authorization: " + GeraToken()
    Local cMerchant      := "MerchantId: "+cIdCli // Id do cliente
    Local aHeader        := {}
    Local oRest      As Object
    Local oJson      As Object
    DbSelectArea('ZLP')
    oRest := FWRest():New(cUrlPortal)
    oJson := JSonObject():New()
    Aadd(aHeader, cAuth)
    Aadd(aHeader, cMerchant)
    oRest:setPath("/v1/smartcheckout/"+cidlink+"/detail")
    oRest:GET(aHeader)
    cErro := oJSon:fromJson(oRest:GetResult())
    if Empty(cErro)
        if oJson['smartCheckout']['charges'][1]['transactions'][1]['transactionStatus'] == 8
            ZLP->(dbSeek(cfiltro))
            Reclock('ZLP',.F.)
            ZLP->STATUS := 2
            ZLP->(MsUnLock())
        ElseIf oJson['smartCheckout']['charges'][1]['transactions'][1]['transactionStatus'] == 10
            ZLP->(dbSeek(cfiltro))
            Reclock('ZLP',.F.)
            ZLP->STATUS := 3
            ZLP->(MsUnLock())
        EndIf
    EndIf
    ZLP->(DbcloseArea())
Return

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | DetLink    | Autor |    Rivaldo Jr.  ( Cod.ERP )                 |*
*+------------+------------------------------------------------------------------+*
*|Data        | 29.09.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao para buscar os detalhes de um link de pagamento           |*
*+------------+------------------------------------------------------------------+*
*|Parâmetro   | Necessita do ID do link de pagamento                             |*
**********************************************************************************/
Static Function DLinkCielo(cfiltro,cIdLink)
    Local cAuth          := "Authorization: " + GTokenCielo()
    Local cPath          := "/api/public/v1/products/" + cIdLink +"/payments"
    Local nStatus        := 0
    Local cErro          := ''
    Local aHeader        := {}
    Local oRest          := FWRest():New(cUrlCielo)
    Local oJson          := JSonObject():New()

    Aadd(aHeader, cAuth)

    oRest:setPath(cPath)
    oRest:Get(aHeader)
    cErro := oJSon:fromJson(oRest:GetResult())
    if Empty(cErro)
        if oJson['orders'][1]['payment']['status'] == 'Paid'
            ZLP->(dbSeek(cfiltro))
            Reclock('ZLP',.F.)
            ZLP->STATUS := 2
            ZLP->(MsUnLock())
        ElseIf oJson['orders'][1]['payment']['status'] == 'Expired'
            ZLP->(dbSeek(cfiltro))
            Reclock('ZLP',.F.)
            ZLP->STATUS := 3
            ZLP->(MsUnLock())
        EndIf
    EndIf

Return nStatus

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | DetLink    | Autor |    Rivaldo Jr.  ( Cod.ERP )                 |*
*+------------+------------------------------------------------------------------+*
*|Data        | 29.09.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao para buscar os detalhes de um link de pagamento           |*
*+------------+------------------------------------------------------------------+*
*|Parâmetro   | Necessita do ID do link de pagamento                             |*
**********************************************************************************/

Static Function GeraToken()

    Local cGeneratedToken  := ''
    Local cErro            := ''
    Local oRest            As Object
    Local oJson            As Object
    Local cPath          := "/v1/Login/GenerateToken"
    Local aHeader        := {"MerchantToken: "+cMercTk}

    oRest := FWRest():New(cUrlPortal)
    oJson := JSonObject():New()

    oRest:setPath(cPath)
    oRest:Post(aHeader)
    cErro := oJSon:fromJson(oRest:GetResult())

    cGeneratedToken := oJson:GetJSonObject('generatedToken')

Return "Bearer " + cGeneratedToken

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | DetLink    | Autor |    Rivaldo Jr.  ( Cod.ERP )                 |*
*+------------+------------------------------------------------------------------+*
*|Data        | 29.09.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao para buscar os detalhes de um link de pagamento           |*
*+------------+------------------------------------------------------------------+*
*|Parâmetro   | Necessita do ID do link de pagamento                             |*
**********************************************************************************/

Static Function GTokenCielo()
    Local cToken           := ''
    Local cTkType          := ''
    Local cErro            := ''
    Local oRest            As Object
    Local oJson            As Object
    Local cPath          := "/api/public/v2/token"
    Local aHeader        := {"Authorization: Basic " + Encode64(cClientID + ":" + cClientSC)}
   
    oRest := FWRest():New(cUrlCielo)
    oJson := JSonObject():New()
    oRest:setPath(cPath)
    oRest:Post(aHeader)
    cErro := oJSon:fromJson(oRest:GetResult())

    cToken  := oJson:GetJSonObject('access_token')
    cTkType := oJson:GetJSonObject('token_type')

Return   "Bearer " + cToken
