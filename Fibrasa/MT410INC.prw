#Include "Protheus.ch"

/*/{Protheus.doc} MT410INC
Este ponto de entrada pertence à rotina de pedidos de venda, MATA410(). 
Está localizado na rotina de alteração do pedido, A410INCLUI(). É executado após a gravação das informações.
@type function
@version 12.1.33
@author Silvano Franca
@since 21/11/2022
/*/    
User Function MT410INC()
	Local oRest := JSonObject():new()
	Local oBody := JSonObject():new()
	Local oToken := JSonObject():new()
	local cResult := ''
	// Envia e-mail para o cliente informando que o pedido recebido por API foi integrado ao EPR.
	U_ALW0001()

	oRest     := FWRest():New('http://177.39.232.66:9000')
	oBody := JSonObject():New()
	oBody['cdOP'] := '20750201001'
	oBody['qtdRegistro'] := '99999999999999999999'

	oRest:setPath("/api/ColetaCep/ObterInspecoesOP")
	oRest:SetPostParams(oBody:toJson())
	oRest:POST()
	cResult := oRest:GetResult()
	cErro := oToken:FromJson(cResult)
	If oRest:GetHTTPCode() == '200'
        ZLA->(Reclock('ZLA',.T.))
        ZLA->ZLA_FILIAL := xFilial('ZLA')
        ZLA->ZLA_NLAUDO := "20742601001"
        ZLA->ZLA_MINIMO := oToken:LIE
        ZLA->ZLA_PADRAO := oToken:media
        ZLA->ZLA_MAX    := oToken:LSE
        ZLA->ZLA_MINRE  := oToken:valor
        ZLA->ZLA_MAXRES := oToken:valor
        ZLA->ZLA_MEDIA  := oToken:valor

        ZLA->(MsUnlock())

	EndIf
Return
