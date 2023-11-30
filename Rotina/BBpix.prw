#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#Include 'TbIconn.CH'

#Define cAppKey "287e9884cf79b2be61a9d3531ebb6bef"
#Define cChavePIX "pixbb@nordesteatacado.com.br"
#Define cClientID "eyJpZCI6IjU4MTA3OWUtNzI0IiwiY29kaWdvUHVibGljYWRvciI6MCwiY29kaWdvU29mdHdhcmUiOjUyNzkxLCJzZXF1ZW5jaWFsSW5zdGFsYWNhbyI6MX0"
#Define cClientSecret "eyJpZCI6IjRmZDEzNWItNWQ4ZS00NmUwLWIyMDEtMjJlOWEzMGY3Y2RmMWJlZDE0ZWUtNzI4Zi0iLCJjb2RpZ29QdWJsaWNhZG9yIjowLCJjb2RpZ29Tb2Z0d2FyZSI6NTI3OTEsInNlcXVlbmNpYWxJbnN0YWxhY2FvIjoxLCJzZXF1ZW5jaWFsQ3JlZGVuY2lhbCI6MSwiYW1iaWVudGUiOiJwcm9kdWNhbyIsImlhdCI6MTY5MjczNTc0NzA1Mn0"

User Function BBpix(nAcao, cUUID, cValor, cTxID)
	Local aRet     := {}
	DEFAULT nAcao  := 1
	DEFAULT cUUID  := cAppKey
	DEFAULT cValor := "1.00"
	//DEFAULT cNome  := "Francisco da Silva"
	//DEFAULT cCpf   := "12345678909"
	DEFAULT cChave := cChavePIX
	DEFAULT cSolic := "Cobranca dos servicos prestados."
	DEFAULT cTxID  := ""

	If nAcao == 1
		aRet := GeraPIX(1, cUUID, cValor, cChave, cSolic, cTxID)
			/*
			RecLock( "SC5", .F. )
				SC5->C5_XCEMV:= aRet[1]
				SC5->C5_XTXID:= aRet[2]
				SC5->C5_XSTATPX := aRet[3]
			SC5->(MSUNLOCK())
			*/
	ElseIf nAcao == 2
		aRet := GetPIX(cUUID, cTxID)
	Endif

Return aRet
/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | RetAuth  | Autor |    Walter Rodrigo                             |*
*+------------+------------------------------------------------------------------+*
*|Data        | 24.09.2021                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao de autenticação para o Bradesco                           |*
**********************************************************************************/

Static Function RetAuth()
Local cURL       := "https://oauth.bb.com.br"
Local cBase64    := Encode64(cClientID+":"+cClientSecret)
Local cAuth      := "Authorization: Basic "+cBase64
Local cContent   := "Content-Type: application/x-www-form-urlencoded"
Local aHeader   := {}
Local oRest     := FWRest():New(cURL)
Local cJson     := "grant_type=client_credentials"
Local oJson     := JSonObject():New()
Private cTkType := ""

Aadd(aHeader, cAuth)
Aadd(aHeader, cContent)

oRest:setPath("/oauth/token")
oRest:SetPostParams(cJson)
oRest:Post(aHeader)
cErro := oJSon:fromJson(oRest:GetResult())

If !empty(cErro)
	MsgStop(cErro,"JSON PARSE ERROR")
	Return ""
Endif

cAcessTk  := oJson:GetJSonObject('access_token')
cTkType   := oJson:GetJSonObject('token_type')
cExpireIn := oJson:GetJSonObject('expires_in')

// Valida o retorno
If Type("cAcessTk")=="U" .or. Empty(cAcessTk)
	Return ""
Endif

Return "Authorization: "+cTkType+" "+cAcessTk

Static Function GeraPIX(nVal, cUUID, cValor, cChave, cSolic, cTxID)

Local cAuth     := RetAuth()
Local cContent  := "Content-Type: application/json "
Local aHeader   := {}
Local oRest     := FWRest():New("https://api-pix.bb.com.br")
Local oJson     := JSonObject():New()
Local cJson     := ""
Local aRet      := {}
Local cStatuspg   := ""
local nTimeout:= 120
local cUrl := "https://api-pix.bb.com.br/pix/v2/cob?gw-dev-app-key=287e9884cf79b2be61a9d3531ebb6bef"
local cCertificado  := "\cert\clientcert.pem"
local cPrivKey		:= "\cert\clientkey.pem"
local cRetorno := ""
local cSenha := "emis1771"
local cErro
//local cError

// Valida a autorização
If Empty(cAuth)
	Return ""
Endif

cJson +=  '{ '
cJson +=  '"chave": "'+cChave+'",'
cJson +=  '"solicitacaoPagador" : "'+cSolic+'", '
cJson +=  '"valor":'
cJson +=  '{ '
cJson +=  '"original":"'+cValor+'"'
cJson +=  '},'
cJson +=  ' "calendario": {'
cJson +=  '"expiracao": 36000'
cJson +=  ' }'
cJson +=  '}'
/*
cJson +='"devedor": {'
If Len(cCpf) > 11
	cJson +='"cnpj": "'+cCpf+'",'
Else
	cJson +='"cpf": "'+cCpf+'",'
EndIf
cJson +='"nome": "'+cNome+'"'
cJson +='}'*/

Aadd(aHeader, cAuth)
Aadd(aHeader, cContent)


//aHeader2 := aHeader[1]
/* cRet := HTTPSPost( cURL, cCertificado, cPrivKey, cSenha,"" , cJson, nTimeOut, aHeader, @cRetorno)

if Empty(cRet)
	nError := HttpGetStatus(@cErro)
endif */

oRest:setPath("/pix/v2/cob"+cTxID+"?gw-dev-app-key="+cUUID)
oRest:SetPostParams(cJson)
if oRest:POST(aHeader)
	cErro := oRest:GetResult()
else 
	cErro := oRest:GetLastError()
endif
nError := HttpGetStatus(@cErro)

If oRest:GetHTTPCode() == "201"
	cImgQrCode := oJson:GetJSonObject('pixCopiaECola')
	cRetTxID   := oJson:GetJSonObject('txid')
	cStatuspg := oJson:GetJSonObject('status')
	aRet := {cImgQrCode, cRetTxID,cStatuspg}
Endif

Return aRet

Static Function GetPIX(cUUID, cTxID)

Local cAuth     := RetAuth()
Local cContent  := "Content-Type: application/json "
Local aHeader   := {}
Local oRest     := FWRest():New("https://api-pix.bb.com.br")
Local oJson     := JSonObject():New()
Local cJson     := ""
Local cStatus   := ""
Local aRet      := {""}

// Valida a autorização
If Empty(cAuth)
	Return ""
Endif

Aadd(aHeader, cAuth)
Aadd(aHeader, cContent)

oRest:setPath("/pix/v2/cob"+cTxID+"?gw-dev-app-key="+cUUID)
oRest:SetPostParams(cJson)
oRest:GET(aHeader)
oJSon:fromJson(oRest:GetResult())

If oRest:GetHTTPCode() $ "200/201"
	cStatus := oJson:GetJSonObject('status')
	aRet    := {cStatus}
Endif

Return aRet

/**********************************************************************************
+-------------------------------------------------------------------------------+
|Funcao      | GerRAPIX | Autor |    Walter Rodrigo                             |
+------------+------------------------------------------------------------------+
|Data        | 01.01.2021                                                       |
+------------+------------------------------------------------------------------+
|Descricao   | Geração do RA com retorno do PIX                                 |
********************************************************************************/

User Function GerRAPIX(cEmp, cFil, cCliente, cLoja, nValor, cVend, cHist)

	local cQUERY := GetNextAlias()
	Local cBanco   := ""
	Local cConta   := ""
	Local cAgencia := ""
	Local aTitRA := {}
	Local cNum   := ""
	Local nX 	 := 0
	Local aiErro := {}
	Local ciErro := ""
	//Local cCCusto := SUPERGETMV('MV_XCUST', .F., 'D06002')
	//Local cICTA   := SUPERGETMV('MV_XITCCLJ', .F., '')
	Local cNatureza := ""
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.
	
	PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil MODULO "FIN"
	cNatureza := SUPERGETMV('MV_XNATPIX', .F., 'PIX')

	BeginSql alias cQUERY
	SELECT A6_XPIXRA,A6_AGENCIA,A6_NUMCON,A6_COD
	FROM %Table:SA6% SA6
	WHERE 	SA6.%NotDel% AND
			SA6.A6_XPIXRA = "S" AND
			A6_FILIAL = %xFilial:SA6%
	EndSql

	cBanco := (cQUERY)->A6_COD
	cAgencia := (cQUERY)->A6_AGENCIA
	cConta := ALLTRIM((cQUERY)->A6_NUMCON)

	if Empty(cBanco) .or. Empty(cAgencia) .or. Empty(cConta)
		return {.f.}
	endif

	cNum := GetSXENum('SE1','E1_NUM')
	ConfirmSX8()
	lMsErroAuto := .F.
	aTitRA := { ;
		{ "E1_PREFIXO"  , "PIX"     						    , NIL },;
		{ "E1_NUM"      , cNum              		    			, NIL },;
		{ "E1_TIPO"     , "RA "             		    			, NIL },;
		{ "E1_NATUREZ"  , cNatureza            		    			  , NIL },;
		{ "E1_CLIENTE"  , cCliente  		              , NIL },;
		{ "E1_LOJA"     , cLoja                			, NIL },;
		{ "E1_EMISSAO"  , dDatabase								        , NIL },;
		{ "E1_VENCTO"   , dDatabase								        , NIL },;
		{ "E1_VENCREA"  , dDatabase									        , NIL },;
		{ "E1_VALOR"    , nValor    		  					        , NIL },;
		{ "E1_VEND1"    , cVend                      , NIL },;
		{ "E1_HIST"  	, cHist                         , NIL },;
		{ "CBCOAUTO"    , PADR(cBanco,3) 							    , NIL },;
		{ "CAGEAUTO"    , PADR(cAgencia,5) 							  , NIL },;
		{ "CCTAAUTO"    , PADR(cConta,10) 							  , NIL } }

		/*
		Antes esses dois campos também eram incluidos no aTitRA
		{ "E1_CCUSTO"   , cCCusto                        , NIL },;
		{ "E1_ITEMCTA"  , cICTA                         , NIL },;*/

	Begin Transaction
	MsExecAuto( { |x,y| FINA040(x,y)} , aTitRA, 3)  // 3 - Inclusao, 4 - Alterao, 5 - Excluso

	If lMsErroAuto
		aiErro := GetAutoGRLog()
		For nX := 1 To Len(aiErro)
			ciErro += aiErro[nX] + Chr(13)+Chr(10)
		Next nX
		aiRet		:=	{.F.,"Erro na rotina automatica",ciErro,0 }
	Else
		aiRet		:=	{.T.,"" + cNum,"",se1->(RECNO())}
	Endif
	End Transaction

	RESET ENVIRONMENT

Return aiRet
