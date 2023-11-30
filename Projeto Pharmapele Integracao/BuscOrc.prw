#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'


#Define cUrl "http://pharmapeleapps.dynns.com:50465/datasnap/rest/TSM"
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
User Function BuscOrc(cOrca, cFil)
    Local oRest      As Object
    Local oJson      As Object
    Local nX         := 0
    Local cBody      := ''
    Local aItens     := {}
    Local aHeader    := {}
    Local cContent   := "Content-Type: application/json"
    Default cOrca    := "428248"
    Default cFil     := "137"

    cBody += ' { '
    cBody += '   "id":"gradar", '
    //cBody += '   "filial" : "'+cFil+'", '
    cBody += '   "filial" : "137", '
    cBody += '   "norc":"'+cOrca+'"'
    cBody += ' } '

    Aadd(aHeader, cContent)

    oRest := FWRest():New(cUrl)
    oJson := JSonObject():New()

    oRest:setPath("/BuscaOrcamento")
    oRest:SetPostParams(cBody)
    oRest:Post(aHeader)
    oJSon:fromJson(SubString(oRest:cResult,2,Len(oRest:cResult)-1))

    If oJson:GetJsonObject('StatusDescr') == "Erro"
        FWAlertWarning("Orçamento não localizado.","Atenção!")
        Return aItens
    Endif

    If oRest:oResponseh:cStatusCode == "200"
      For nX := 1 To Len(oJson["Itens"])
        aAdd(aItens,{ oJson["Itens",nX]:GetJsonObject('NRORC'),;
                      oJson["Itens",nX]:GetJsonObject('SERIEO'),;
                      oJson["Itens",nX]:GetJsonObject('CODPRO'),;
                      oJson["Itens",nX]:GetJsonObject('DESCRPROD'),;
                      oJson["Itens",nX]:GetJsonObject('UNIDA'),;
                      oJson["Itens",nX]:GetJsonObject('QUANT'),;
                      oJson["Itens",nX]:GetJsonObject('PRCOBR')}) 
      Next nX
    Endif

Return aItens
