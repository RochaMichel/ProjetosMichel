#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

/*+------------------------------------------------------------------------+
*|Funcao      | Mensagem()                                                 |
*+------------+------------------------------------------------------------+
*|Autor       | Rivaldo Jr. ( Cod.ERP Tecnologia LTDA )                    |
*+------------+------------------------------------------------------------+
*|Data        | 17/10/2023                                                 |
*+------------+------------------------------------------------------------|
*|Descricao   | Consome API da Set Telecom para envio da mensagem          |
*+------------+------------------------------------------------------------+
*|Partida     | REST                                                       |
*+------------+-----------------------------------------------------------*/

#Define cUrl   "https://sac-patagonia.settelecom.com.br/rest/v2"

User Function Mensagem(cNome, cContato, cLink)
    Local cAuth          := "Authorization: Bearer " + U_GeraToken()
    Local cContent       := "Content-Type: application/json"
    Local cPath          := "/sendHsm"
    Local cJson          := ""
    Local cErro          := ""
    Local aHeader        := {}
    Local lRet           := .T.
    Local oRest          := FWRest():New(cUrl)
    Local oJson          := JSonObject():New()

    Aadd(aHeader, cAuth)
    Aadd(aHeader, cContent)

    cJson := '{                                     '
    cJson += '    "cod_conta": 1,                   '
    cJson += '    "hsm": 4,                         '
    cJson += '    "cod_flow": 3,                    '
    cJson += '    "tipo_envio": 1,                  '
    cJson += '    "variaveis": {                    '
    cJson += '        "1":"'+cLink+'"               '
    cJson += '    },                                '
    cJson += '    "contato": {                      '
    cJson += '        "telefone": "'+cContato+'",   '
    cJson += '        "nome": "'+cNome+'"           '
    cJson += '    },                                '
    cJson += '    "start_flow": 1                   '
    cJson += '}                                     '

    oRest:setPath(cPath)
    oRest:SetPostParams(cJson)
    oRest:POST(aHeader)

    cErro := oJSon:fromJson(oRest:GetResult())

    If !Empty(cErro)
        FWAlertWarning(cErro,"JSON PARSE ERROR")
        Return {}
    Endif
    
    If !oJson:GetJSonObject('sucess')
        lRet := .F.
    EndIf

Return lRet

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | GeraToken  | Autor |    Rivaldo Jr.  ( Cod.ERP )                 |*
*+------------+------------------------------------------------------------------+*
*|Data        | 29.09.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao para geração do token de autorização                      |*
**********************************************************************************/
User Function GeraToken()
    Local cToken           := ''
    Local cJson            := ''
    Local cErro            := ''
    Local oRest            As Object
    Local oJson            As Object
    Local cPath            := "/authuser"
    Local aHeader          := {"Content-Type: application/json"}

    oRest := FWRest():New(cUrl)
    oJson := JSonObject():New()

    cJson += '{ '
    cJson += '    "login": "coderp", '
    cJson += '    "chave": "wJt7*0KOihInC1r*$" '
    cJson += '} '

    oRest:setPath(cPath)
    oRest:SetPostParams(cJson)
    oRest:Post(aHeader)
    cErro := oJSon:fromJson(oRest:GetResult())

    If !empty(cErro)
        FWAlertWarning(cErro,"JSON PARSE ERROR")
        Return ""
    Endif

    cToken  := oJson['result']['token']

Return cToken
