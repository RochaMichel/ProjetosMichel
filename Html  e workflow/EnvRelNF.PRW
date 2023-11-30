#INCLUDE "Totvs.ch"
#include 'TBICONN.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
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
	//Local cConexao    := SuperGetMV("MV_XXCON01", .F., "ORACLE/SPEDNFE")
	//Local cServerAddr := SuperGetMV("MV_XXCON02", .F., "localhost")
	//Local nPort       := Val(SuperGetMV("MV_XXCON03", .F., "7790"))
	//Local cSPED050    := ""
	//Local cTableName  := ""
	//Local aFields     := {}
	//Local oTempTable
	//Local nTopProtheus := AdvConnection()
	Local nTopTSS
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "020202"
	cConexao    := SuperGetMV("MV_XXCON01", .F., "ORACLE/TSS_C")
	cServerAddr := SuperGetMV("MV_XXCON02", .F., "127.0.0.1")
	nPort       := Val(SuperGetMV("MV_XXCON03", .F., "7778"))
	cSPED050    := ""
	cAlias		:= ""
	Private aCampos := {}
	Private cNomeUsr := ""
	cTableName  := ""
	aFields     := {}
	nTopProtheus := AdvConnection()
	aAdd(aFields, {"ID_ENT"    ,"C",  TamSX3("F2_FILIAL")[1], 0})
	aAdd(aFields, {"NOTA"      ,"C",  TamSX3("F2_DOC")[1]   , 0})
	aAdd(aFields, {"SERIE"     ,"C",  TamSX3("F2_SERIE")[1] , 0})
	aAdd(aFields, {"STATUS"    ,"C",  1, 0})
	aAdd(aFields, {"STATUSCANC","C",  1, 0})
	aAdd(aFields, {"EMISSAO"   ,"D",  8, 0})
	aAdd(aFields, {"CNPJDEST"  ,"C", 14, 0})
	aAdd(aFields, {"DOC_ID"    ,"C",  9, 0})
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
			    //AND TS50.%notdel% 
				AND TS50.DATE_NFE  >= %Exp:DTOS(DATE()-30)%
		EndSql
		TcSetConn(nTopProtheus)
		oTempTable := FWTemporaryTable():New("TMP_TSS")
		oTempTable:SetFields( aFields )
		oTempTable:Create()
		cTableName := oTempTable:GetAlias()

		(cSPED050)->(dbgotop())
		While (cSPED050)->(!Eof())
			(cTableName)->(reclock(cTableName,.T.))
			ID_ENT 		:= (cSPED050)->ID_ENT
			NOTA		:= SubStr((cSPED050)->NFE_ID,4,TamSX3("F2_DOC")[1])
			SERIE 		:= AllTrim((cSPED050)->DOC_SERIE)
			STATUS		:= AllTrim(Str((cSPED050)->STATUS))
			STATUSCANC	:= AllTrim(Str((cSPED050)->STATUSCANC))
			EMISSAO		:= STod((cSPED050)->DATE_NFE)
			CNPJDEST	:= (cSPED050)->CNPJDEST
			DOC_ID		:= (cSPED050)->DOC_ID
			(cTableName)->(msunlock())
			(cSPED050)->(DbSkip())
		End
	EndIf
	TCUNLink(nTopTSS)
	(cTableName)->(DbGoTop())
	While (cTableName)->(!EOF())
		cAlias := GetNextAlias()
		DbSeectArea("SM0")
		SM0->(DBSetOrder(1), DBGoTop())
		While SM0->(!Eof())
			If SM0->M0_CGC == CNPJDEST
				cFil := SM0->M0_CODFIL
				Exit
			EndIf
			SM0->(DbSkip())
		End
		BEGINSql Alias cAlias
			Select F2_FILIAL, F2_DOC, F2_SERIE, D_E_L_E_T_ As Deletado, F2_USERLGI
			From %Table:SF2% SF2
			Where F2_DOC = %Exp:(cTableName)->(NOTA)%
			AND F2_SERIE = %Exp:(cTableName)->(SERIE)%
			AND F2_FILIAL = %Exp:(cFil)%
		EndSql
		cNomeUsr := FwGetUserName(AllTrim(Substr(Embaralha((cAlias)->F2_USERLGI,1),3,6)))
		cCodSeg  := Posicione("SF3",5,(cAlias)->(F2_FILIAL+F2_SERIE+F2_DOC),"F3_CODRSEF")
		Do Case
		Case  (cTableName)->(STATUS) == "3"
			Aadd(aCampos,{(cAlias)->(F2_FILIAL),DtoC((cTableName)->(EMISSAO)),(cTableName)->(DOC_ID),(cAlias)->(F2_SERIE),;
				cNomeUsr," ", "NF NÃO TRANSMITIDA"})
		Case Empty((cAlias)->(Deletado)) .AND. (cTableName)->(STATUSCANC) == "2"
			Aadd(aCampos,{(cAlias)->(F2_FILIAL),DtoC((cTableName)->(EMISSAO)),(cTableName)->(DOC_ID),(cAlias)->(F2_SERIE),;
				cNomeUsr,"CANCELADA", "AUTORIZADA"})
		Case Empty((cAlias)->(Deletado)) .AND. cCodSeg == "110"
			Aadd(aCampos,{(cAlias)->(F2_FILIAL),DtoC((cTableName)->(EMISSAO)),(cTableName)->(DOC_ID),(cAlias)->(F2_SERIE),;
				cNomeUsr,"DENEGADA", "AUTORIZADA"})
		Case !Empty((cAlias)->(Deletado)) .AND. (cTableName)->(STATUS) == "6"
			Aadd(aCampos,{(cAlias)->(F2_FILIAL),DtoC((cTableName)->(EMISSAO)),(cTableName)->(DOC_ID),(cAlias)->(F2_SERIE),;
				cNomeUsr,"AUTORIZADA", "CANCELADA"})
		EndCase
		(cTableName)->(DbSkip())
	End
	If !Empty(aCampos)
		FormaBody(aCampos)
	EndIf
	oTempTable:Delete()
	//RESET ENVIRONMENT
Return

Static Function FormaBody(aSection)
	Local nX	As Numeric
	Local _assunto 	:= "Relatorio de notas Sefaz/Elizabeth"
	Local cAccount, cPassword, cServer
	Local lMailAut 	:= .T.
	Local cEmail 	:= "contato.michelrocha@gmail.com"
	cAccount := GetMv("EL_RLCONTA")
	cPassword := GetMv("EL_RLSENHA")
	cServer  := GetMv("EL_RLSERV")
	lMailAut := GetMv("EL_RLAUTEN")

	cBody :=  "   <div style='font-family: arial; font-size: 14px;'> "
	cBody +=  "       <div fr-original-style='' style='box-sizing: border-box;'>&nbsp;</div> "
	cBody +=  "       <table border='0' cellpadding='0' cellspacing='0' fr-original-style='border-collapse: collapse;width:600pt;' "
	cBody +=  "           id='isPasted' "
	cBody +=  "           style='border-collapse: collapse; width: 600pt; box-sizing: border-box; border: none; empty-cells: show; max-width: 100%;' "
	cBody +=  "           width='600'> "
	cBody +=  "           <tbody fr-original-style='' style='box-sizing: border-box;'> "
	cBody +=  "        		 <tr fr-original-style='' style='box-sizing: border-box; user-select: none;'>

	*********************************************************************** TITULO DA PLANILHA  ************************************************************************************************************

	cBody +=  "       			  <td fr-original-class='xl64' ; colspan='8'
	cBody +=  "       		    	  fr-original-style='color:white; font-size:18px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;background:##FF0000;height:15.0pt;0.5pt solid windowtext;'
	cBody +=  "       		    	  height='20'
	cBody +=  "       		    	  style='color: White; font-size: 18px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext;border-left:  0.5pt solid windowtext; height: 18pt; box-sizing: border-box; user-select: text;'>
	cBody +=  "       		    	  RELATÓRIO DE INCONSISTENCIAS DE NOTAS FISCAIS  </td>
	cBody +=  "    			  </tr> "

	*********************************************************************** CABEÇALHO DAS COLUNAS ************************************************************************************************************

	cBody +=  "               <tr fr-original-style='' style='box-sizing: border-box; user-select: none;'> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;height:15.0pt;0.5pt solid windowtext;' "
	cBody +=  "                       height='20' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-left: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); height: 15pt; border-top: 0.5pt solid windowtext; box-sizing: border-box; width: 5%; user-select: text;'> "
	cBody +=  "                       FILIAL </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 10%; user-select: text;'> "
	cBody +=  "                       DATA EMISSÃO </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 10%; user-select: text;'> "
	cBody +=  "                       NF-E </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 20%; user-select: text;'> "
	cBody +=  "                       SÉRIE </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 10%; user-select: text;'> "
	cBody +=  "                       EMISSOR </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 10%; user-select: text;'> "
	cBody +=  "                       STATUS SEFAZ </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 10%; user-select: text;'> "
	cBody +=  "                       STATUS ELIZABETH </td> "
	cBody +=  "               </tr> "

	*********************************************************************** LINHAS CONTENDO OS DADOS ************************************************************************************************************

	For nX:=1 To Len(aSection)

		cBody +=  "               <tr fr-original-style='' style='box-sizing: border-box; user-select: none;'> "
		cBody +=  "                   <td fr-original-class='xl65' "
		cBody +=  "                       fr-original-style='color:Black;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:Center;vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;height:15.0pt;0.5pt solid windowtext;' "
		cBody +=  "                       height='20' "
		cBody +=  "                       style='color: Black; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: Center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-left: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); height: 15pt; border-top: 0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "+AllTrim(aSection[nX,1])+"</td> "
		cBody +=  "                   <td fr-original-class='xl65' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:Center;vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: Center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "+AllTrim(aSection[nX,2])+"</td> "
		cBody +=  "                   <td fr-original-class='xl66' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:Center; vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align:Center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "/*  &nbsp; &nbsp; &nbsp; &nbsp; "*/
		cBody +=  "                       "+AllTrim(aSection[nX,3])+"</td> "
		cBody +=  "                   <td fr-original-class='xl66' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:Center; vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align:Center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "/*  &nbsp; &nbsp; &nbsp; &nbsp; "*/
		cBody +=  "                       <b>"+AllTrim(aSection[nX,4])+"</b></td> "
		cBody +=  "                   <td fr-original-class='xl66' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:Center; vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align:Center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "/*  &nbsp; &nbsp; &nbsp; &nbsp; "*/
		cBody +=  "                       "+AllTrim(aSection[nX,5])+"</td> "
		cBody +=  "                   <td fr-original-class='xl66' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:Center; vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align:Center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "/*  &nbsp; &nbsp; &nbsp; &nbsp; "*/
		cBody +=  "                       <b>"+AllTrim(aSection[nX,6])+"</b></td> "
		cBody +=  "                   <td fr-original-class='xl66' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:Center; vertical-align:bottom;border:.5pt solid windowtext; background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align:Center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "/*  &nbsp; &nbsp; &nbsp; &nbsp; "*/
		cBody +=  "                       "+AllTrim(aSection[nX,7])+"</td> "
		cBody +=  "                   </td> "
		cBody +=  "               </tr> "
	Next nX
	cBody +=  "           </tbody> "
	cBody +=  "       </table> "
	cBody +=  "   </div> "

	U_ACSENDM(cAccount,cPassword,cServer,GetMv("EL_RLMAIL"),cEmail,_assunto, cBody ,"")

Return cBody

