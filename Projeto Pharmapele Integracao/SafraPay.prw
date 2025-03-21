#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

#Define cUrl "https://payment.safrapay.com.br"
#Define cUrlPortal "https://portal-api.safrapay.com.br"
#Define cUrlBase "https://portal.safrapay.com.br"
#Define cMercTk "mk_78Zx4h7YgkaBWtBIsvLyvg"
#Define cIdCli "e271c6ef-d81e-4682-815a-d048b2f2f2be"

/*+------------------------------------------------------------------------+
*|Funcao      | SafraPay()                                                 |
*+------------+------------------------------------------------------------+
*|Autor       | Rivaldo Jr. ( Cod.ERP Tecnologia LTDA )                    |
*+------------+------------------------------------------------------------+
*|Data        | 29/09/2023                                                 |
*+------------+------------------------------------------------------------|
*|Descricao   | Consome API para gera��o do link de pagamento              |
*+------------+------------------------------------------------------------+
*|Solicitante | Setor financeiro                                           |
*+------------+------------------------------------------------------------+
*|Partida     | REST                                                       |
*+------------+-----------------------------------------------------------*/
User Function SafraPay(nValor, cContato, cEmail)
    Local aDados     := {}
    Default nValor   := 1
    Default cContato := "81999999999"
    Default cEmail   := "pharmapele@gmail.com"

    aDados := GeraLink(nValor, cContato, cEmail)

Return aDados

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | GeraToken  | Autor |    Rivaldo Jr.  ( Cod.ERP )                 |*
*+------------+------------------------------------------------------------------+*
*|Data        | 29.09.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao para gera��o do token de autoriza��o                      |*
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

    If !oJson["success"]
        //FWAlertWarning(cErro,"JSON PARSE ERROR")
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
*|Descricao   | Funcao para gera��o do Link de pagamento                         |*
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
    Local cValor     := Val(StrTran(StrTran(AllTrim(Transform(nValor, "@E 999,999,999.99")),',',''),'.',''))

    Aadd(aHeader, cAuth         )
    Aadd(aHeader, cContent      )

    oRest := FWRest():New(cUrl)
    oJson := JSonObject():New()

    cJsonBody:= '{ '
    cJsonBody+=     '"amount": '+cValor+','
    cJsonBody+=     '"description": "LinkPagamento Pharmapele",'
    cJsonBody+=     '"emailNotification": "'+cEmail+'",' // Email Padr�o do cliente
    cJsonBody+=     '"phoneNotification": "'+cContato+'" '
    cJsonBody+= '} '

    oRest:setPath(cPath)
    oRest:SetPostParams(cJsonBody)
    oRest:Post(aHeader)
    cErro := oJSon:fromJson(oRest:GetResult())

    If !oJson["success"]
        //MsgStop(cErro,"JSON PARSE ERROR")
        Return {}
    Endif

    cLinkPag  := cUrlBase+oJson:GetJSonObject('smartCheckoutUrl')
    cIdLink   := oJson:GetJSonObject('id')

Return { cIdLink, cLinkPag }
