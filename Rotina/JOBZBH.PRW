#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#Include 'TbIconn.CH'

#Define cAppKey "eb44e9fd1827f28b90e6c2edcf306b1b"
#Define cClientID "eyJpZCI6Ijc1Yjg2ODQtMDc0OS00MmEwLWI3MDAtYjQ3IiwiY29kaWdvUHVibGljYWRvciI6MCwiY29kaWdvU29mdHdhcmUiOjU3ODA2LCJzZXF1ZW5jaWFsSW5zdGFsYWNhbyI6MX0"
#Define cClientSecret "eyJpZCI6ImVlYzVhYzctYmE3Ny0iLCJjb2RpZ29QdWJsaWNhZG9yIjowLCJjb2RpZ29Tb2Z0d2FyZSI6NTc4MDYsInNlcXVlbmNpYWxJbnN0YWxhY2FvIjoxLCJzZXF1ZW5jaWFsQ3JlZGVuY2lhbCI6MSwiYW1iaWVudGUiOiJob21vbG9nYWNhbyIsImlhdCI6MTY3OTQ4ODQwNjQzMX0"


User Function JOZBH()
	Local cUUID  	:= cAppKey
	Default nAcao  	:= 0

	Local cAuth     := RetAuth()
	Local cNUMBOL 	:= ""
	Local cContent  := "Content-Type: application/json "
	Local aHeader   := {}
	Local oRest     := FWRest():New("https://api.hm.bb.com.br")
	Local oJRet     := JSonObject():New()
	Local cJson     := ""
	Local cZBHalias := GetNextAlias()
// Valida a autorização
	If Empty(cAuth)
		Return ""
	Endif

	Aadd(aHeader, cAuth)
	Aadd(aHeader, cContent)
	BEGINSQL Alias cZBHalias
        Select * from %table:ZBH% ZBH
        Where ZBH.ZBH_FLAGPG <> 'S'
        Group by ZBH_IDCNAB 
	ENDSQL

	If Select('SEE') == 0
		DbSelectArea('SEE')
	Endif

	//SEE->(DbSetOrder(1))
	//If SEE->(DbSeek(FWxFilial('SEE')+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA))
	DbSelectArea(cZBHalias)
	While (cZBHalias)->(!EOF())
		cNumBOl := (cZBHalias)->ZBH_NUMBOL
		cIdcnab := (cZBHalias)->ZBH_IDCNAB
		oRest:setPath("/cobrancas/v2/boletos/"+cNUMBOL+"?gw-dev-app-key="+cUUID+'&numeroConvenio=')
		oRest:POST(aHeader,cJson)
		oJRet:fromJson(oRest:GetResult())
		cMsg := oJRet["erros"][1]["mensagem"]
		If oRest:GetHTTPCode() $ "201/200"
			ZBH->(DbSetOrder(1))
			If ZBH->(DbSeek(xFilial('ZBH')+(cZBHalias)->ZBH_IDCNAB))
				If oJRet:GetJSonObject('valorPagoSacado') > 0
					While ZBH->ZBH_IDCNAB == cIdcnab
						RecLock('ZBH',.F.)
						ZBH_FLAGPG := 'S'
						ZBH->(MsUnlock())
						ZBH->(DbSkip())
					End
					StartJob( "U_bxZBH",getenvserver(),.T.,{{"E1_FILIAL" , SE1->E1_FILIAL , Nil},;
						{"E1_PREFIXO"      , SE1->E1_PREFIXO, Nil},;
						{"E1_NUM"          , SE1->E1_NUM    , Nil},;
						{"E1_TIPO"         , SE1->E1_TIPO   , Nil},;
						{"E1_PARCELA"      , SE1->E1_PARCELA, Nil},;
						{"AUTMOTBX"        , cMotiBx        , Nil},;
						{"AUTBANCO"        , cBanco         , Nil},;
						{"AUTAGENCIA"      , cAgencia       , Nil},;
						{"AUTCONTA"        , cConta         , Nil},;
						{"AUTDTBAIXA"      , CtoD(cBaixa)   , Nil},;
						{"AUTDTCREDITO"    , CtoD(cBaixa)   , Nil},;
						{"AUTHIST"         , AllTrim(cHist) , Nil},;
						{"AUTJUROS"        , val(cJuros)    , Nil},;
						{"AUTDESCONT"      , val(cDescont)  , Nil},;
						{"AUTVALREC"       , val(cValrec)   , Nil},;
						{FWAllCompany()}})
				EndIf
			EndIf
		Else
			FWAlertError(cMsg, "Registra Boleto - Erro")
		Endif
		(cZBHalias)->(DbSkip())
	End
	//Else
	//FWAlertWarning("Não foi encontrada conexão remota para este banco. Processo encerrado.", "Baixa Boleto - Aviso")
	//EndIf

Return

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | RetAuth  | Autor |    Walter Rodrigo                             |*
*+------------+------------------------------------------------------------------+*
*|Data        | 24.09.2021                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao de autenticação			                                 |*
**********************************************************************************/

Static Function RetAuth()
Local cURL       	:= "https://oauth.hm.bb.com.br"
Local cBase64    	:= Encode64(cClientID+":"+cClientSecret)
Local cAuth      	:= "Authorization: Basic "+cBase64
Local cContent   	:= "Content-Type: application/x-www-form-urlencoded"
Local aHeader   	:= {}
Local oRest     	:= FWRest():New(cURL)
Local cJson     	:= "grant_type=client_credentials&scope=cobrancas.boletos-info+cobrancas.boletos-requisicao"
Local oJRet     	:= JSonObject():New()
Private cTkType 	:= ""

Aadd(aHeader, cAuth)
Aadd(aHeader, cContent)

oRest:setPath("/oauth/token")
oRest:SetPostParams(cJson)
oRest:Post(aHeader)
cErro := oJRet:fromJson(oRest:GetResult())

If !empty(cErro)
  FWAlertError(cErro,"RetAuth - Erro")
  Return ""
Endif

cAcessTk  := oJRet:GetJSonObject('access_token')
cTkType   := oJRet:GetJSonObject('token_type')
cExpireIn := oJRet:GetJSonObject('expires_in')

// Valida o retorno
If Type("cAcessTk")=="U" .or. Empty(cAcessTk)
	Return ""
Endif

Return "Authorization: "+cTkType+" "+cAcessTk

user Function BxZBH(aDados)
local nx
local aCampos
    For nx := 1 TO 15
        Aadd(aCampos,adados[nx])
    Next
    For nx := 1 to len(adados[16])
	    PREPARE ENVIRONMENT EMPRESA adados[16][nx] FILIAL aDados[1][2]

	    Private lMsErroAuto := .F.

	    MSExecAuto({|x,y| Fina070(x,y)},aCampos,3)

	    Reset Environment
    Next
return
