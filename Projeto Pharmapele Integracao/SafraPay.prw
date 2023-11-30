#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

#Define cUrl "https://payment.safrapay.com.br"
#Define cUrlPortal "https://portal-api.safrapay.com.br"
#Define cUrlBase "https://portal.safrapay.com.br"
#Define cMercTk "mk_78Zx4h7YgkaBWtBIsvLyvg"
#Define cIdCli "e271c6ef-d81e-4682-815a-d048b2f2f2be"

/*
*+-------------------------------------------------------------------------+
*|Funcao      | SafraPay()                                                 |
*+------------+------------------------------------------------------------+
*|Autor       | Rivaldo Jr. ( Cod.ERP Tecnologia LTDA )                    |
*+------------+------------------------------------------------------------+
*|Data        | 29/09/2023                                                 |
*+------------+------------------------------------------------------------|
*|Descricao   | Consome API para geração do link de pagamento              |
*+------------+------------------------------------------------------------+
*|Solicitante | Setor financeiro                                           |
*+------------+------------------------------------------------------------+
*|Partida     | REST                                                       |
*+------------+------------------------------------------------------------+
*/
User Function SafraPay(nOpcao, nValor, cContato, cEmail, cIdLink)
    Local aDados     := {}
    Default nOpcao   := 1
    Default nValor   := 1
    Default cContato := "81999999999"
    Default cEmail   := "rivaldo.junior@coderp.inf.br"
    Default cIdLink  := ""

    If nOpcao == 1
        aDados := GeraLink(nValor, cContato, cEmail)
    Else
        aDados := DetLink(cIdLink)
    Endif

Return aDados

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | GeraToken  | Autor |    Rivaldo Jr.  ( Cod.ERP )                 |*
*+------------+------------------------------------------------------------------+*
*|Data        | 29.09.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao para geração do token de autorização                      |*
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

    If !empty(cErro)
        FWAlertWarning(cErro,"JSON PARSE ERROR")
        Return ""
    Endif

    cGeneratedToken := oJson:GetJSonObject('generatedToken')

Return "Bearer " + cGeneratedToken


/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | GeraLink  | Autor |    Rivaldo Jr.  ( Cod.ERP )                  |*
*+------------+------------------------------------------------------------------+*
*|Data        | 29.09.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao para geração do Link de pagamento                         |*
**********************************************************************************/
Static Function GeraLink(nValor, cContato, cEmail)
    Local cLinkPag   := ''
    Local cIdLink    := ''
    Local aHeader    := {}
    Local oRest      As Object
    Local oJson      As Object
    Local cAuth      := "Authorization: " + GeraToken()
    Local cPath      := "/v2/paymentlink"
    Local cContent   := "Content-Type: application/json"
    Local cJsonBody  := ""

    Aadd(aHeader, cAuth         )
    Aadd(aHeader, cContent      )

    oRest := FWRest():New(cUrl)
    oJson := JSonObject():New()

    cJsonBody:= '{ '
    cJsonBody+=     '"amount": "'+cValToChar(nValor)+'",'
    cJsonBody+=     '"description": "LinkPagamento Pharmapele",'
    cJsonBody+=     '"emailNotification": "'+cEmail+'",' // Email Padrão do cliente
    cJsonBody+=     '"phoneNotification": "'+cContato+'",'
    cJsonBody+= '} '

    oRest:setPath(cPath)
    oRest:SetPostParams(cJsonBody)
    oRest:Post(aHeader)
    cErro := oJSon:fromJson(oRest:GetResult())

    If !empty(cErro)
        MsgStop(cErro,"JSON PARSE ERROR")
        Return {}
    Endif

    cLinkPag  := cUrlBase+oJson:GetJSonObject('smartCheckoutUrl')
    cIdLink   := oJson:GetJSonObject('id')

Return { cIdLink, cLinkPag }


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
Static Function DetLink(cIdLink)
    Local cAuth          := "Authorization: " + Encode64(GeraToken())
    Local cMerchant      := "MerchantId: "+cIdCli // Id do cliente
    Local nStatus        := 0
    Local aHeader        := {}
    Local oRest      As Object
    Local oJson      As Object

    oRest := FWRest():New(cUrlPortal)
    oJson := JSonObject():New()

    Aadd(aHeader, cAuth)
    Aadd(aHeader, cMerchant)

    oRest:setPath("/v1/smartcheckout/"+cIdLink+"/detail")
    oRest:GET(aHeader)
    cErro := oJSon:fromJson(oRest:GetResult())

    If !empty(cErro)
      FWAlertWarning(cErro,"JSON PARSE ERROR")
      Return ""
    Endif

    nStatus := oJson:GetJSonObject('status')

Return {nStatus}



