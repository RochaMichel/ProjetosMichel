#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

#Define cUrl "http://pharmapeleapps.dynns.com:50465/datasnap/rest/TSM"

/*
*+-------------------------------------------------------------------------+
*|Funcao      | RetTB()                                                    |
*+------------+------------------------------------------------------------+
*|Autor       | Rivaldo Jr. ( Cod.ERP Tecnologia LTDA )                    |
*+------------+------------------------------------------------------------+
*|Data        | 29/09/2023                                                 |
*+------------+------------------------------------------------------------|
*|Descricao   | Consome API para retorno do Terminal Balcão                |
*+------------+------------------------------------------------------------+
*|Solicitante | Setor financeiro                                           |
*+------------+------------------------------------------------------------+
*|Partida     | REST                                                       |
*+------------+------------------------------------------------------------+
*/
User Function RetTB(cFil, cOrc, cSerie)
    Local oRest      As Object
    Local oJson      As Object
    Local cPath      := "/FinalizaOrcamento"
    Local cJsonBody  := ""
    Local cErro      := ""
    Local cTermBalcao:= ""
    Local aHeader    := {"Content-Type: application/json"}

    oRest := FWRest():New(cUrl)
    oJson := JSonObject():New()

    cJsonBody:= ' { '
    cJsonBody+= ' 	"ID":"gradar", '
    cJsonBody+= ' 	"ORCAMENTOS" : '
    cJsonBody+= ' 	[ '
    cJsonBody+= ' 		{ '
    cJsonBody+= ' 			"FILORC":'+cFil+', '
    cJsonBody+= '  			"NRORC":'+cOrc+', '
    cJsonBody+= '  			"SERIEORC":'+cSerie+' '
    cJsonBody+= ' 		} '
    cJsonBody+= ' 	] '
    cJsonBody+= ' } '

    oRest:setPath(cPath)
    oRest:SetPostParams(cJsonBody)
    oRest:Post(aHeader)
    cErro := oJSon:fromJson(oRest:GetResult())

    If !empty(cErro)
        MsgStop(cErro,"JSON PARSE ERROR")
        Return ''
    Endif

    cTermBalcao  := oJson:GetJSonObject('TerminalBalcao')

Return cTermBalcao
