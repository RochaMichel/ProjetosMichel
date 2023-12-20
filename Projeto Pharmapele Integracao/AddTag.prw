#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

#Define cUrl   "https://api.chat24.io"
#Define cToken "f357c34cf5dce08a3434feeb2d25e8"
/*+------------------------------------------------------------------------+
*|Funcao      | AddTag()                                                   |
*+------------+------------------------------------------------------------+
*|Autor       | Rivaldo Jr. ( Cod.ERP Tecnologia LTDA )                    |
*+------------+------------------------------------------------------------+
*|Data        | 17/10/2023                                                 |
*+------------+------------------------------------------------------------|
*|Descricao   | Consome API do Chat2Desk para envio da AddTag              |
*+------------+------------------------------------------------------------+
*|Solicitante | Setor financeiro                                           |
*+------------+------------------------------------------------------------+
*|Partida     | REST                                                       |
*+------------+-----------------------------------------------------------*/
User Function AddTag(cIDTag,cIdChat)
    Local cAuth          := "Authorization: " + cToken
    Local cContent       := "Content-Type: application/json"
    Local cPath          := "/v1/tags/assign_to"
    Local aHeader        := {}
    Local cStatus        := ""
    Local cJson          := ""
    Local oRest          := FWRest():New(cUrl)
    Local oJson          := JSonObject():New()

    Aadd(aHeader, cAuth)
    Aadd(aHeader, cContent)

    cJson += ' { '
    cJson += '   "tag_ids": ['+cIDTag+'], '
    cJson += '   "assignee_type": "request", '
    cJson += '   "assignee_id": "'+cIdChat+'" '
    cJson += ' } '

    oRest:setPath(cPath)
    oRest:SetPostParams(cJson)
    oRest:POST(aHeader)

    cErro := oJSon:fromJson(oRest:GetResult())

    If !empty(cErro)
        //FWAlertWarning(cErro,"JSON PARSE ERROR")
        Return ""
    Endif
    
    cStatus := oJson:GetJSonObject('status')

Return cStatus
