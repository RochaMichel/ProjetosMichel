#INCLUDE 'PROTHEUS.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "MSOLE.CH"
#INCLUDE "FILEIO.CH"

User Function ENVCOM
	Local cFile     := FWInputBox("Informe o link da imagem a ser enviada", "")
	Local cAssunto  := FWInputBox("Informe o assunto do e-mail", "")
	Local cBody     := ""
	Local cQuery    := ""
	Local cAnexo    := ""
	Local cAccount, cPassword, cServer
	Local lMailAut  := .T.
	Private cAliasTmp := GetNextAlias()

	cBody := "<p><img src='"+cFile+"'/></p>"

	cAccount	:= GetMv("EL_RLCONTA")
	cPassword	:= GetMv("EL_RLSENHA")
	cServer		:= GetMv("EL_RLSERV")
	lMailAut	:= GetMv("EL_RLAUTEN")

	cMV1		:= "MV_RELSSL"
	cMV2		:= "MV_RELTLS"

	cQuery := " SELECT TRIM(A2.A2_EMAIL) EMAIL, "
	cQuery += " ( Select count(*) "
	cQuery += " FROM " + RETSQLNAME("SA2") + " SA2 "
	cQuery += " WHERE SA2.A2_MSBLQL<>'1' AND SA2.A2_EMAIL NOT LIKE '@%' AND  trim(SA2.A2_EMAIL) NOT IN  ('@','@.','@@','@!','@@@','@') AND "
	cQuery += " SA2.A2_EMAIL LIKE '%@%' AND SA2.D_E_L_E_T_=' ' "
	cQuery += " ) as QTD "
	cQuery += " FROM " + RETSQLNAME("SA2") + " A2 "
	cQuery += " WHERE A2.A2_MSBLQL<>'1' AND A2.A2_EMAIL NOT LIKE '@%' AND  trim(A2.A2_EMAIL) NOT IN  ('@','@.','@@','@!','@@@','@') AND "
	cQuery += " A2.A2_EMAIL LIKE '%@%' AND A2.D_E_L_E_T_=' ' AND rownum < 11000  "
	cQuery += " ORDER BY A2.A2_EMAIL DESC"

	MpSysOpenQuery(cQuery, cAliasTmp)

	Private oProcess as object
	oProcess := MsNewProcess():New({ || envia(cAccount, cPassword, cServer, cAssunto, cBody, cAnexo) }, 'Carregando...', 'Aguarde...', .T.)
	oProcess:Activate()

	(cAliasTmp)->(DbCloseArea())

Return

Static Function envia(cAccount, cPassword, cServer, cAssunto, cBody, cAnexo)

	Local nQtd	 := (cAliasTmp)->QTD
	Local nCount := 1
	Local cMail := '' 
	

	oProcess:SetReguA2(nQtd)
	For nCount := 1 to 5
	cMail += Alltrim((cAliasTmp)->EMAIL)+";"
	(cAliasTmp)->(DbSkip())
	Next nCount
	U_ACSendM(cAccount,cPassword,cServer,"erp2@grupoelizabeth.com.br","contato.michelrocha@gmail.com",cAssunto,cBody,cAnexo)
	//While (cAliasTmp)->(!EoF())
	//	oProcess:SetReguA2(1)
	//	
	//	oProcess:IncReguA2(" E-mail enviado para "+Alltrim((cAliasTmp)->EMAIL))
    //    
    //    oProcess:IncReguA2("Enviando email "+cValToChar(nCount)+" de "+cValToChar(nQtd))
	//	nCount++
	//End
    
	U_ACSendM(cAccount,cPassword,cServer,"erp2@grupoelizabeth.com.br","mateus.ramos@coderp.inf.br",cAssunto,cBody,cAnexo)
	U_ACSendM(cAccount,cPassword,cServer,"erp2@grupoelizabeth.com.br","aline.andrade@grupoelizabeth.com.br",cAssunto,cBody,cAnexo)

Return
