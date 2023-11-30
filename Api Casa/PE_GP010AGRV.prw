#Include 'Protheus.ch'
#DEFINE cURL "https://app.solides.com/pt-BR/api/v1/"
#DEFINE cAccept  "Accept: application/json"
#DEFINE cContent "Content-Type: application/json"

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | GP010AGRV  | Autor |    Cod.ERP Tecnologia                       |*
*+------------+------------------------------------------------------------------+*
*|Data        | 01.10.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Ponto de entrada na alteração do funcionario                     |*
**********************************************************************************/ 

User Function GP010AGRV()
	Local nOpc   :=Paramixb[1]
	Private cToken :=  "Authorization: Token token="+GetMv("MV_XSTOKEN",,"c0754fe94f42ebb42315b4510e886b830593b277f303030a7654")

	If nOpc == 4
		If SRA->RA_SITFOLH == "D"
			DemissionSolid()
			DemissionBeeHo()
		EndIf
		If SRA->RA_SITFOLH == "F" .OR. Empty(SRA->RA_SITFOLH)
			StatusAlt()
		EndIf
	EndIf
	If nOpc == 3
		CadBeeHo()
	EndIf
Return

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | DemissionSolid  | Autor |    Cod.ERP Tecnologia                  |*
*+------------+------------------------------------------------------------------+*
*|Data        | 01.10.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Demite o funcionario na Solides                                  |*
**********************************************************************************/

static Function DemissionSolid()
	Local oRest     := FWRest():New(cURL)
	Local oRestDemis    As object
	Local oJsToken         As object
	Local oBody         As object
	Local aHeader   := {}
	Local cResult 	:= ""
	Aadd(aHeader, cToken)
	Aadd(aHeader, cAccept)
	Aadd(aHeader, cContent)

	oJsToken   := JSonObject():New()
	oRest:setPath("colaboradores/existe/"+SRA->RA_CIC)
	oRest:Get(aHeader)
	cResult := oRest:GetResult()
	cErro := oJsToken:FromJson(cResult)
	If oRest:GetHTTPCode() == "200"
		oRestDemis := FWRest():New(cURL)
		oBody := JSonObject():New()
		oBody["dateDismissal"]     := Dtoc(SRA->RA_DEMISSA)
		oBody["dateDismissal"]     := JsonObject():New()
		oBody["dateDismissal"]["jorge"]     := "jorge"
		oBody["formDismissal"]     := GetMv("MV_XDEMTAPI",,"Suas atividades na "+SM0->EMP+" está sendo encerrado a partir de"+Dtoc(SRA->RA_DEMISSA)+".")
		oBody["decisionDismissal"] := "Sem Decisão"
		oRestDemis:setPath("colaboradores/"+oJsToken["Id"]+"/demitir")
		oRestDemis:SetPostParams(oBody:toJson())
		oRestDemis:POST(aHeader)
	EndIf
return

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | DemissionBeeHo  | Autor |    Cod.ERP Tecnologia                  |*
*+------------+------------------------------------------------------------------+*
*|Data        | 01.10.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Desativa o funcionario na BeeHome                                |*
**********************************************************************************/

Static Function DemissionBeeHo()
	local cUrlBeeHo := "https://rederena.mybeehome.com/"
	Local oRestTok     := FWRest():New(cUrlBeeHo)
	Local oJsToken         As object
	Local oJsDemis         As object
	Local oBodyTok         As object
	Local oRestCPF         As object
	Local oRestDemis       As object
	Local aHeader   := {}
	Local cResult 	:= ""

	Aadd(aHeader, cContent)

	oBodyTok := JSonObject():New()
	oBodyTok["username"]     := GetMV("MV_XUSERAPI",,"Deiler@casarena.com.Br")
	oBodyTok["password"]     := GetMV("MV_XSENHAPI",,"Adminlocal@0910")
	oRestTok:setPath("userdata/login")
	oRestTok:SetPostParams(oBodyTok:toJson())
	oRestTok:POST(aHeader)
	cResult := oRestTok:GetResult()
	oJsToken   := JSonObject():New()
	cErro := oJsToken:FromJson(cResult)

	If cErro == Nil
		oRestCPF := FWRest():New(cUrlBeeHo)
		aHeader   := {}
		cResult   := ""
		Aadd(aHeader, "Authorization: Bearer "+oJsToken["token"])
		oRestCPF:setPath("directory/getIdByCPF?cpf="+SRA->RA_CIC)
		oRestCPF:Get(aHeader)
		cResult := oRestCPF:GetResult()
		If cResult <> "0"
			oRestDemis := FWRest():New(cUrlBeeHo)
			oJsDemis   := JSonObject():New()
			aHeader   := {}
			Aadd(aHeader, "Authorization: Bearer "+oJsToken["token"])
			oRestDemis:setPath("directory/"+cResult)
			oRestDemis:Delete(aHeader)
		EndIf
	EndIf
return

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | StatusAlt  | Autor |    Cod.ERP Tecnologia                       |*
*+------------+------------------------------------------------------------------+*
*|Data        | 01.10.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Atualiza o status na BeeHome                                     |*
**********************************************************************************/

Static Function StatusAlt()
	local cUrlBeeHo := "https://rederena.mybeehome.com/"
	Local oRestTok     := FWRest():New(cUrlBeeHo)
	Local oJsToken         As object
	Local oBodyTok         As object
	Local oRestAtt     	   As object
	Local ojsonAtt         As object
	Local aHeader   := {}
	Local cResult 	:= ""
	Aadd(aHeader, cContent)
	oBodyTok := JSonObject():New()
	oBodyTok["username"]     := GetMV("MV_XUSERAPI",,"Deiler@casarena.com.Br")
	oBodyTok["password"]     := GetMV("MV_XSENHAPI",,"Adminlocal@0910")
	oRestTok:setPath("userdata/login")
	oRestTok:SetPostParams(oBodyTok:toJson())
	oRestTok:POST(aHeader)
	cResult := oRestTok:GetResult()
	oJsToken   := JSonObject():New()
	cErro := oJsToken:FromJson(cResult)
	If cErro == Nil
		oRestAtt := FWRest():New(cUrlBeeHo)
		ojsonAtt := JSonObject():New()
		aHeader := {}
		Aadd(aHeader, "Authorization: Bearer "+oJsToken["token"])
		If SRA->RA_SITFOLH == "F"
		    oRestAtt:setPath("directory/docsapi/"+SRA->RA_CIC+"/updateStatus/inativo")
		Else
			oRestAtt:setPath("directory/docsapi/"+SRA->RA_CIC+"/updateStatus/ativo")
		EndIf
		oRestAtt:PUT(aHeader)
	EndIf
Return

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | CadBeeHo  | Autor |    Cod.ERP Tecnologia                        |*
*+------------+------------------------------------------------------------------+*
*|Data        | 01.10.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Cadastra o usuario no BeeHome                                    |*
**********************************************************************************/

Static Function CadBeeHo()
	local cUrlBeeHo := "https://rederena.mybeehome.com/"
	Local oRestTok     := FWRest():New(cUrlBeeHo)
	Local oJsToken         As object
	Local oBodyTok         As object
	Local oRestCad     	   As object
	Local oBodyCad         As object
	Local aHeader   := {}
	//Local aNome   := {}
	Local cResult 	:= ""

	Aadd(aHeader, cContent)

	oBodyTok := JSonObject():New()
	oBodyTok["username"]     := GetMV("MV_XUSERAPI",,"Deiler@casarena.com.Br")
	oBodyTok["password"]     := GetMV("MV_XSENHAPI",,"Adminlocal@0910")
	oRestTok:setPath("userdata/login")
	oRestTok:SetPostParams(oBodyTok:toJson())
	oRestTok:POST(aHeader)
	cResult := oRestTok:GetResult()
	oJsToken   := JSonObject():New()
	cErro := oJsToken:FromJson(cResult)

	If cErro == Nil
		oRestCad     := FWRest():New(cUrlBeeHo)
		oBodyCad := JSonObject():New()

		aHeader := {}
		aNome := Separa(AllTrim(SRA->RA_NOME)," ", .F.)

		oBodyCad["cpf"] :=  SRA->RA_CIC
		oBodyCad["email"] := SRA->RA_EMAIL
		oBodyCad["externalCode"] := ""
		oBodyCad["firstName"] := iif(len(aNome) < 3,aNome[1]+" "+aNome[2],aNome[1])
		oBodyCad["rg"] := SRA->RA_RG
		oBodyCad["lastName"] := aNome[len(aNome)]
		oBodyCad["password"] := GetMV("MV_XPSWPD",,"1234") //Senha padrão para a plataforma do BeeHome
		oBodyCad["middleName"] := iif(len(aNome) < 3,aNome[3],aNome[2])
		oBodyCad["socialName"] := SRA->RA_NOME
		oBodyCad["telephoneNumber"] := SRA->RA_TELEFON
		oBodyCad["telephone_extension"] := ""
		oBodyCad["mobileNumber"] := SRA->RA_TELEFON
		oBodyCad["birthday"] := Transform(DtoS(SRA->RA_NASC),"@R 9999-99-99")
		oBodyCad["admissionDate"] := Transform(DtoS(SRA->RA_ADMISSA),"@R 9999-99-99")
		oBodyCad["statusString"] := 'ativo'
		oBodyCad["companyId"] := 0
		oBodyCad["companyDepartmentId"] := 0
		oBodyCad["jobTitle"] := SRA->RA_CARGO
		oBodyCad["department"] := SRA->RA_DEPTO
		oBodyCad["state"] := SRA->RA_NATURAL
		oBodyCad["country"] := "BRASIL"
		oBodyCad["regional"] := ""
		oBodyCad["directorship"] := ""
		oBodyCad["management"] := ""
		oBodyCad["supervision"] := ""
		oBodyCad["coordinatorExternalCode"] := ""
		oBodyCad["supervisorExternalCode"] := ""
		oBodyCad["coordinatorExternalCode"] := ""
		oBodyCad["temporaryPassword"] := .T.

		Aadd(aHeader, "Authorization: Bearer "+oJsToken["token"])
		Aadd(aHeader, cContent)

		oRestCad:setPath("directory/docsapi/insertUser")
		oRestCad:SetPostParams(oBodyCad:toJson())
		oRestCad:POST(aHeader)
		oRestCad:GetHTTPCode()
	EndIf
Return
