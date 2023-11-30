#Include 'TOTVS.CH'

#DEFINE cURL "https://app.solides.com/pt-BR/api/v1/"
#DEFINE cAccept  "Accept: application/json"
#DEFINE cContent "Content-Type: application/json"

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | CadSolid   | Autor |    Cod.ERP Tecnologia                       |*
*+------------+------------------------------------------------------------------+*
*|Data        | 01.10.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Função para cadastrar funcionario pegando da Solides             |*
**********************************************************************************/ 

User Function CadSolid()
	Local cResult   := ""
	Local aHeader   := {}
	Local aDados    := {}
	Local nX
	Local oRestTds  := FWRest():New(cURL)
	Local oRest     As object
	Local oJsonFun  AS object
	Local oJson     AS object
	Local lAtivAmb := .F.
	
	If Select("SX2") == 0
		RPCClearEnv()
		RpcSetType( 3 )
		RpcSetEnv( "99",'01', , , "",,, , , ,  ) //Precisa mudar para a filial
		lAtivAmb := .T. // Seta se precisou montar o ambiente
	Endif

	Private cToken := "Authorization: Token token=" + GetMv("MV_XSTOKEN",,"c0754fe94f42ebb42315b4510e886b830593b277f303030a7654")
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.

	Aadd(aHeader, cToken)
	Aadd(aHeader, cAccept)
	Aadd(aHeader, cContent)

	oRestTds:setPath("colaboradores?status=todos")
	oRestTds:Get(aHeader)
	oJsonFun     := JSonObject():New()
	cResult += "{"
	cResult += '	"funcionarios":'
	cResult += oRestTds:GetResult()
	cResult += "}"
	cErro := oJsonFun:FromJson(cResult)

	If oRestTds:GetHTTPCode() == "200"

		For nX := 1 To Len(oJsonFun["funcionarios"])
			oRest  := FWRest():New(cURL)
			oRest:setPath("colaboradores/"+cValtoChar(oJsonFun["funcionarios"][nx]["id"]))
			oRest:Get(aHeader)
			oJson   := JSonObject():New()
			cResult := oRest:GetResult()
			cErro := oJson:FromJson(cResult)

			DbSelectArea('SRA')
			SRA->(DbSetOrder(5))
			If SRA->(DbSeek(xFilial('SRA')+ojson["documents"]["idNumber"]))
				loop
			Else
				aadd(aDados,{"RA_MAT" 	   , GetSxeNum("SRA","RA_MAT")      									,Nil})
				aadd(aDados,{'RA_NOME'	   , ojson["name"]      												,Nil})
				aadd(aDados,{'RA_SEXO'	   , SubStr(ojson["gender"],1,1)      									,Nil})
				aadd(aDados,{'RA_ESTCIVI'  , Iif(ojson["maritalStatus"] == nil,"C",ojson["maritalStatus"])  	,Nil})
				aadd(aDados,{'RA_NATURAL'  , ojson["address"]["city"]["state"]["initials"]      				,Nil})
				aadd(aDados,{'RA_NACIONA'  , '10'      															,Nil})
				aadd(aDados,{'RA_NASC'	   , cTod(ojson["birthDate"])      										,Nil})
				aadd(aDados,{'RA_CC'	   ,  "010104"     														,Nil})
				aadd(aDados,{'RA_ADMISSA'  , cTod(ojson["dateAdmission"])      									,Nil})
				aadd(aDados,{'RA_OPCAO'	   , cTod(ojson["dateAdmission"])										,Nil})
				aadd(aDados,{'RA_HRSMES'   , GetMV("MV_XHRSMES",,220)											,Nil})
				aadd(aDados,{'RA_HRSEMAN'  , GetMV("MV_XHRSEMA",,44)											,Nil})
				aadd(aDados,{'RA_PROCES'   , GetMV("MV_XPROCES",,"00001")										,Nil})
				aadd(aDados,{'RA_CODFUNC'  , Querybusc("SRJ","RJ_FUNCAO",ojson["position"]["name"],"RJ_DESC")   ,Nil})
				aadd(aDados,{'RA_TNOTRAB'  , GetMV("MV_XNOTRAB",,"001")											,Nil})         
				aadd(aDados,{'RA_CATFUNC'  , GetMV("MV_XCATFUN",,"M")											,Nil})
				aadd(aDados,{'RA_TIPOPGT'  , GetMV("MV_XTPPGTO",,"M")											,Nil})
				aadd(aDados,{'RA_TIPOADM'  , GetMV("MV_XTPADM" ,,"9B")											,Nil})
				aadd(aDados,{'RA_VIEMRAI'  , GetMV("MV_XVIERAI",,"10")											,Nil})
				aadd(aDados,{'RA_GRINRAI'  , GetMV("MV_XGRIRAI",,"45")											,Nil})
				aadd(aDados,{'RA_HOPARC'   , '1'																,Nil})
				aadd(aDados,{'RA_COMPSAB'  , '1'																,Nil})
				aadd(aDados,{'RA_CIC'      ,  ojson["documents"]["idNumber"]   									,Nil})


				MSExecAuto({|x,y,k,w| GPEA010(x,y,k,w)},NIL,NIL,aDados,3)  //-- Opcao 3 - Inclusao registro

				If lMsErroAuto
					aLog   := GetAutoGRLog()
					Conout(cTexto)
					lRet := .F.
				EndIf
			EndIF
		Next nX
	Endif
	If lAtivAmb
		RPCClearEnv()
	Endif

Return

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | Querybusc  | Autor |    Cod.ERP Tecnologia                       |*
*+------------+------------------------------------------------------------------+*
*|Data        | 01.10.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Função para buscar informações nas tabelas acessorias            |*
**********************************************************************************/ 

Static Function Querybusc(cTable,cCampo,cInfo,cDesc)
	local cQry := ''
	local xReturn := ''

	cQry += " Select "+cCampo+" from "+RetSqlName(cTable)
	cQry += " Where "+cDesc+" Like '%"+cInfo+"%' AND D_E_L_E_T_ <> '*' "

	MpSysOpenQuery(cQry, "TMP")
	
	If TMP->(!EOF())
		xReturn := &("TMP->"+cCampo)
	EndIF

Return xReturn
