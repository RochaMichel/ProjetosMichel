#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

#Define cUrl "https://cieloecommerce.cielo.com.br"
#Define cClientID "f72ff94d-da2b-48a5-bdb8-5ef92f4ed354"
#Define cClientSC "iOSbQOKiHzExAvtwfKrWhofBQ+YpyDkBWLHO5UTa6EE="

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
User Function Cielo(nValor, nParc)
    Local aDados     := {}
    Default nValor   := 1
    //Default nParc    := 1

    aDados := GeraLink(nValor, nParc)

Return aDados


/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | GeraLink  | Autor |    Rivaldo Jr.  ( Cod.ERP )                  |*
*+------------+------------------------------------------------------------------+*
*|Data        | 29.09.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao para gera��o do Link de pagamento                         |*
**********************************************************************************/
Static Function GeraLink(nValor, nParc)
    Local cLinkPag   := ''
    Local cIdLink    := ''
    Local cErro      := ''
    Local oRest      As Object
    Local oJson      As Object
    Local cAuth      := "Authorization: " + GeraToken()
    Local cPath      := "/api/public/v1/products/"
    Local cContent   := "Content-Type: application/json"
    Local cJsonBody  := ""
    Local aHeader    := {}
    Local sExpira    := DTOS(Date() + 2)
    Local cExpira    := SubStr(sExpira,1,4) + "-" + SubStr(sExpira,5,2) + "-" + SubStr(sExpira,7,2)

    Aadd(aHeader, cAuth         )
    Aadd(aHeader, cContent      )

    oRest := FWRest():New(cUrl)
    oJson := JSonObject():New()

    cJsonBody:= '{ '
    cJsonBody+= '"type": "Digital", '
    cJsonBody+= '"name": "LP Pharma", '
    cJsonBody+= '"description": "LinkPagamento Pharmapele", '
    cJsonBody+= '"price": '+cValToChar(nValor*100)+', '
    cJsonBody+= '"weight": 100, '
    cJsonBody+= '"expirationDate": "'+cExpira+'", '
    cJsonBody+= '"maxNumberOfInstallments": "'+cValToChar(nParc)+'", '
    cJsonBody+= '"quantity": 5, '
    cJsonBody+= '"sku": "LinkPagamento", '
    cJsonBody+= '"shipping": { '
    cJsonBody+= '"type": "WithoutShipping", '
    cJsonBody+= '"name": "SFrete", '
    cJsonBody+= '"price": "10" '
    cJsonBody+= '}, '
    cJsonBody+= '"softDescriptor": "Pharmapele" '
    cJsonBody+= '} '

    oRest:setPath(cPath)
    oRest:SetPostParams(cJsonBody)
    oRest:Post(aHeader)
    cErro := oJSon:fromJson(oRest:GetResult())

    If !empty(cErro)
        MsgStop(cErro,"JSON PARSE ERROR")
        Return ""
    Endif

    cLinkPag  := oJson:GetJSonObject('shortUrl')
    cIdLink   := oJson:GetJSonObject('id')

Return { cIdLink, cLinkPag }


/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | GeraToken  | Autor |    Rivaldo Jr.  ( Cod.ERP )                 |*
*+------------+------------------------------------------------------------------+*
*|Data        | 29.09.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao para gera��o do token de autoriza��o                      |*
**********************************************************************************/
Static Function GeraToken()
    Local cToken           := ''
    Local cTkType          := ''
    Local cErro            := ''
    Local oRest            As Object
    Local oJson            As Object
    Local cPath          := "/api/public/v2/token"
    Local aHeader        := {"Authorization: Basic " + Encode64(cClientID + ":" + cClientSC)}

    oRest := FWRest():New(cUrl)
    oJson := JSonObject():New()

    oRest:setPath(cPath)
    oRest:Post(aHeader)
    cErro := oJSon:fromJson(oRest:GetResult())

    If !empty(cErro)
        FWAlertWarning(cErro,"JSON PARSE ERROR")
        Return ""
    Endif

    cToken  := oJson:GetJSonObject('access_token')
    cTkType := oJson:GetJSonObject('token_type')

Return cTkType + " " + cToken
