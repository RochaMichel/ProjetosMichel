#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

#Define cUrl   "https://api.chat24.io"
#Define cToken "f357c34cf5dce08a3434feeb2d25e8"

/*
*+-------------------------------------------------------------------------+
*|Funcao      | Chat2Desk()                                                |
*+------------+------------------------------------------------------------+
*|Autor       | Rivaldo Jr. ( Cod.ERP Tecnologia LTDA )                    |
*+------------+------------------------------------------------------------+
*|Data        | 17/10/2023                                                 |
*+------------+------------------------------------------------------------|
*|Descricao   | Consome API do Chat2Desk                                   |
*+------------+------------------------------------------------------------+
*|Solicitante | Setor financeiro                                           |
*+------------+------------------------------------------------------------+
*|Partida     | REST                                                       |
*+------------+------------------------------------------------------------+
*/
User Function Chat2Desk(cContato, cNome, cMensagem)
    Local cID     := ""
    Local cStatus := ""

    cID := ConsultaCli(cContato)

    If Empty(cID)
        cID := CadastraCli(cContato, cNome)
    EndIf

    cStatus := Mensagem(cID, cMensagem)

Return cStatus

/*
*+-------------------------------------------------------------------------+
*|Funcao      | ConsultaCli()                                              |
*+------------+------------------------------------------------------------+
*|Autor       | Rivaldo Jr. ( Cod.ERP Tecnologia LTDA )                    |
*+------------+------------------------------------------------------------+
*|Data        | 17/10/2023                                                 |
*+------------+------------------------------------------------------------|
*|Descricao   | Consome API do Chat2Desk buscando o ID do cliente          |
*+------------+------------------------------------------------------------+
*|Solicitante | Setor financeiro                                           |
*+------------+------------------------------------------------------------+
*|Partida     | REST                                                       |
*+------------+------------------------------------------------------------+
*/
Static Function ConsultaCli(cContato)
    Local cAuth          := "Authorization: " + cToken
    Local cPath          := "/v1/clients?phone=" + cContato
    Local aHeader        := {}
    Local oRest          := FWRest():New(cUrl)
    Local cId            := ""
    Local a              := 1
    Local oJson          := JSonObject():New()

    Aadd(aHeader, cAuth)

    oRest:setPath(cPath)
    oRest:GET(aHeader)

    cErro := oJSon:fromJson(oRest:GetResult())

    If !empty(cErro)
        FWAlertWarning(cErro,"JSON PARSE ERROR")
        Return ""
    Endif
    
    For a := 1 To Len(oJson:GetJSonObject('data'))
        cId := cValToChar(oJson:GetJSonObject('data')[a]:GetJSonObject('id'))
    Next    

Return cId


/*
*+-------------------------------------------------------------------------+
*|Funcao      | CadastraCli()                                              |
*+------------+------------------------------------------------------------+
*|Autor       | Rivaldo Jr. ( Cod.ERP Tecnologia LTDA )                    |
*+------------+------------------------------------------------------------+
*|Data        | 17/10/2023                                                 |
*+------------+------------------------------------------------------------|
*|Descricao   | Consome API do Chat2Desk para cadastrar o cliente          |
*+------------+------------------------------------------------------------+
*|Solicitante | Setor financeiro                                           |
*+------------+------------------------------------------------------------+
*|Partida     | REST                                                       |
*+------------+------------------------------------------------------------+
*/
Static Function CadastraCli(cContato, cNome)
    Local cAuth          := "Authorization: " + cToken
    Local cContent       := "Content-Type: application/json"
    Local cPath          := "/v1/clients"
    Local aHeader        := {}
    Local oRest          := FWRest():New(cUrl)
    Local cId            := ""
    Local cJson          := ""
    Local oJson          := JSonObject():New()

    Aadd(aHeader, cAuth)
    Aadd(aHeader, cContent)

    cJson += '{'
    cJson += '"channel_id": 58547,' // ID do canal que possui a integração com o WhatsApp
    cJson += '"transport": "external",'
    cJson += '"phone": "'+cContato+'",' // +55 (XX) 9XXXX-XXXX
    cJson += '"nickname": "'+cNome+'"' // Nome do cliente
    cJson += '}'

    oRest:setPath(cPath)
    oRest:SetPostParams(cJson)
    oRest:POST(aHeader)

    cErro := oJSon:fromJson(oRest:GetResult())

    If !empty(cErro)
        FWAlertWarning(cErro,"JSON PARSE ERROR")
        Return ""
    Endif
    
    cId := cValToChar(oJson:GetJSonObject('data'):GetJSonObject('id'))

Return cId

/*
*+-------------------------------------------------------------------------+
*|Funcao      | Mensagem()                                              |
*+------------+------------------------------------------------------------+
*|Autor       | Rivaldo Jr. ( Cod.ERP Tecnologia LTDA )                    |
*+------------+------------------------------------------------------------+
*|Data        | 17/10/2023                                                 |
*+------------+------------------------------------------------------------|
*|Descricao   | Consome API do Chat2Desk para envio da mensagem            |
*+------------+------------------------------------------------------------+
*|Solicitante | Setor financeiro                                           |
*+------------+------------------------------------------------------------+
*|Partida     | REST                                                       |
*+------------+------------------------------------------------------------+
*/
Static Function Mensagem(cID, cMensagem)
    Local cAuth          := "Authorization: " + cToken
    Local cContent       := "Content-Type: application/json"
    Local cPath          := "/v1/messages"
    Local aHeader        := {}
    Local cStatus        := ""
    Local cJson          := ""
    Local oRest          := FWRest():New(cUrl)
    Local oJson          := JSonObject():New()

    Aadd(aHeader, cAuth)
    Aadd(aHeader, cContent)

    cJson += '{'
    cJson += '"client_id": ' + cID + ','
    cJson += '"text": "' + cMensagem + '",'
    cJson += '"type": "to_client",'
    cJson += '"transport": "external",'
    cJson += '"channel_id": 58547'
    cJson += '}'

    oRest:setPath(cPath)
    oRest:SetPostParams(cJson)
    oRest:POST(aHeader)

    cErro := oJSon:fromJson(oRest:GetResult())

    If !empty(cErro)
        FWAlertWarning(cErro,"JSON PARSE ERROR")
        Return ""
    Endif
    
    cStatus := oJson:GetJSonObject('status')

Return cStatus

Static Function Operador(id_operator,id_mensagem)
    Local cAuth          := "Authorization: " + cToken
    Local cPath          := "/v1/messages/"+id_mensagem+"/transfer?operator_id="+id_operator
    Local aHeader        := {}
    Local oRest          := FWRest():New(cUrl)
    Local oJson          := JSonObject():New()

    Aadd(aHeader, cAuth)

    oRest:setPath(cPath)
    oRest:GET(aHeader)
    cErro := oJSon:fromJson(oRest:GetResult())

    If !empty(cErro)
        FWAlertWarning(cErro,"JSON PARSE ERROR")
        Return ""
    Endif
return

User Function tags(Id_tag,id_cliente)
    Local cAuth          := "Authorization: " + cToken
    Local cContent       := "Content-Type: application/json"
    Local cPath          := "/v1/tags/assign_to"
    Local aHeader        := {}
    Local cJson          := ""
    Local oRest          := FWRest():New(cUrl)
    Local oJson          := JSonObject():New()

    Aadd(aHeader, cAuth)
    Aadd(aHeader, cContent)

    cJson += '{'
    cJson += '"tag_ids": ['+Id_tag+'],'
    cJson += '"assignee_type": "cliente",'
    cJson += '"assignee_id": "'+id_cliente+'",'
    cJson += '}'

    oRest:setPath(cPath)
    oRest:SetPostParams(cJson)
    oRest:POST(aHeader)

    cErro := oJSon:fromJson(oRest:GetResult())

    If !empty(cErro)
        FWAlertWarning(cErro,"JSON PARSE ERROR")
        Return ""
    Endif
return
