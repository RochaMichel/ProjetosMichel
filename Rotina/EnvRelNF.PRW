#INCLUDE "Totvs.ch"
#include 'TBICONN.CH'
/*/{Protheus.doc} User Function EnvRelNF
    (long_description)
    @type  Function
    @author user
    @since 05/07/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)

Status NFe (campo STATUS):
 1 = NFe Recebida.
 2 = NFe Assinada.
 3 = NFe com falha no schema XML.
 4 = NFe transmitida.
 5 = NFe com problemas.
 6 = NFe autorizada.
 7 = Cancelamento.

Status Cancelamento/inutilização (campo STATUSCANC):
 1 = NFe Recebida.
 2 = NFe Cancelada.
 3 = NFe com falha de cancelamento/inutilização.

Status Mail (campo STATUSMAIL):
 1 = A transmitir.
 2 = Transmitido.
 3 = Bloqueio de transmissão – cancelamento/inutilização.
  /*/

User Function EnvRelNF

	Local cConexao    := SuperGetMV("MV_XXCON01", .F., "ORACLE/SPEDNFE")
	Local cServerAddr := SuperGetMV("MV_XXCON02", .F., "localhost")
	Local nPort       := Val(SuperGetMV("MV_XXCON03", .F., "7790"))
	Local cSPED050    := ""
	Local cTableName  := ""
	Local aFields     := {}
	Local oTempTable
	Local nTopProtheus := AdvConnection()
	Local nTopTSS


	//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "020202"


	cConexao    := SuperGetMV("MV_XXCON01", .F., "ORACLE/TSS_C")
	cServerAddr := SuperGetMV("MV_XXCON02", .F., "127.0.0.1")
	nPort       := Val(SuperGetMV("MV_XXCON03", .F., "7778"))
	cSPED050    := ""
	cTableName  := ""
	aFields     := {}
	nTopProtheus := AdvConnection()

	aAdd(aFields, {"ID_ENT",  "C",  TamSX3("F2_FILIAL")[1], 0})
	aAdd(aFields, {"NOTA",    "C",  TamSX3("F2_DOC")[1]   , 0})
	aAdd(aFields, {"SERIE",   "C",  TamSX3("F2_SERIE")[1] , 0})
	aAdd(aFields, {"STATUS",  "C",  1, 0})
	aAdd(aFields, {"EMISSAO", "D",  8, 0})


	MsgRun("Conectando ao TSS...","Conexão",;
		{|| nTopTSS := TcLink(cConexao,cServerAddr,nPort) })

	If nTopTSS < 0
		MsgAlert("Não foi possível se conectar com TSS. "+;
			"Essa falha pode ocorrer devido ao número de licenças excedidas. "+;
			"Tente mais tarde ou contate o administrador do sistema.")
		Return .F.
	Else
		cSPED050  := GetNextAlias()
		BeginSql Alias cSPED050
			SELECT TS50.*			
			FROM SPED050 TS50
			    WHERE TS50.MODELO    = '55'
				//AND   TS50.ID_NF     = %Exp:% 
				AND   TS50.DATE_NFE  >= %Exp:DTOS(DATE()-30)%
			  //  AND TS50.%notdel%
		EndSql

		oTempTable := FWTemporaryTable():New("TMP_TSS")
		oTempTable:SetFields(aFields)
		oTempTable:AddIndex("01", {"ID_ENT", "NOTA","SERIE","EMISSAO"} )
		oTempTable:Create()
		cTableName := oTempTable:GetRealName()

		While (cSPED050)->(!Eof())
/*
Status NFe (campo STATUS):
 1 = NFe Recebida.
 2 = NFe Assinada.
 3 = NFe com falha no schema XML.
 4 = NFe transmitida.
 5 = NFe com problemas.
 6 = NFe autorizada.
 7 = Cancelamento.

Status Cancelamento/inutilização (campo STATUSCANC):
 1 = NFe Recebida.
 2 = NFe Cancelada.
 3 = NFe com falha de cancelamento/inutilização.
*/
			cQuerySQL := ""
			cQuerySQL += "INSERT INTO " + cTableName + " (ID_ENT, NOTA, SERIE, EMISSAO, STATUS "
			cQuerySQL += "('" +  (cSPED050)->ID_ENT + "', '"+(cSPED050)->DOC_ID+"', '"+(cSPED050)->DOC_SERIE+"', '"+(cSPED050)->DOC_ID+"' "

			If TCSqlExec(cQuerySQL) < 0
				ConOut("EnvRelNF -- Erro: ", TCSqlError())
				Return nil
			Endif

			(cSPED050)->(DbSkip())
		End

		TcSetConn(nTopTSS)

		oTempTable:Delete()

		TCUNLink()
		fErrMail()

	EndIf
	DbSelectArea('SF3')
	DbSetOrder(1) 
	dbseek(SF3->(F3_CLIEFOR+F3_LOJA+F3_SERIE+F3_NFISCAL+F3_IDENTFT))
	IF SF3->F3_CODRSEF == "110"
		fErrMail()
	ENDIF	



//	RESET ENVIRONMENT
Return nil


Static Function fErrMail()
	

	//Local email, mensagem, _assunto
	//Local _aArea := GetArea()
	Local cAccount, cPassword, cServer
	Local lMailAut := .T.

	cAccount := GetMv("EL_RLCONTA")
	cPassword := GetMv("EL_RLSENHA")
	cServer  := GetMv("EL_RLSERV")
	lMailAut := GetMv("EL_RLAUTEN")

	//cMV1  := "MV_RELSSL"
	//cMV2  := "MV_RELTLS"

	_assunto:= aFields
	xTxt := cSPED050
	//xTxt:= " Prezados "+chr(13)+chr(10)
	//xTxt+= " Ocorreu o erro abaixo no momento do envio do boleto referente ao pedido de vendas "+chr(13)+chr(10)
	//xTxt+= ":: " + SC5->C5_NUM+chr(13)+chr(10)
	//xTxt+= chr(13)+chr(10)
	//xTxt+= cErr +chr(13)+chr(10)

	U_ACSENDM(cAccount,cPassword,cServer,GetMv("EL_RLMAIL"),cEmail,_assunto, xTxt ,"")

	If !IsBlind()
		MsgInfo("Email enviado !")
	Endif
Return ()

