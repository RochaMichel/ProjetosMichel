#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DWFAVARIAºAutor  ³ DrillTec Soluções  º Data ³  22/05/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Workflow para aprovação de carga avariada.                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Televendas                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DWFAVARIA(ADE_NMENT,ADE_NMCONT,ADE_DESCCH,ADE_DDDRET,ADE_TELRET,ADE_CODIGO,ADE_DATA,ADE_HORA,ADE_SEVCOD,ADE_NMPROD,ADE_NF,ADE_MOTIVO,QTDNF,ADE_QUANT,PRECOVEN,DESCONTO,cNivel,cOcorr,cAcao,ADE_NMOPER,ADE_INCIDE,ASSUNTO,ADE_MOTIVO,cCONFQTD,ADE_CHAVE)

	Local oWf
	Local cPasta	:= "WORKFLOW"
	Local cPula
	Local cArq		:= If(cNivel=="1","avaria.htm","avaria2.htm")
	Local cArqLink	:= "avarialink.htm"
	Local cMailAut := ""
	Local aArea		:= GetArea()
	Local cProcesso	:= "000001"
	Local nTotal	:= 0
	Private cSetor := ""

	Do Case
		Case cNivel == "1"
		cSetor := "LOGISTICA"
		Case cNivel == "2"
		cSetor := "GERENCIA"
		Case cNivel == "3"
		cSetor := "SUP COMERCIAL"
		Case cNivel == "4"
		cSetor := "DIRETORIA"
		Case cNivel == "5"
		
		cSetor := "FINANCEIRO"
		cMailAut := U_ZS1BuscaEmail("000001",cNivel,cOcorr,cAcao,"E")
		//DESCONTO,CODIGO DO ATENDIMENTO,ADE_CHAVE
		U_XNCC(DESCONTO,ADE_CODIGO,ADE_CHAVE,cMailAut,ADE_NF,QTDNF,ADE_QUANT,PRECOVEN,DESCONTO) 

		U_TInteracao(ADE_CODIGO,"NCC GERADA "+ADE_CODIGO+"A","999998","2","5","NCC","","000001")
		
		//Alimenta hora final NCC
		DBSELECTAREA("ADF")
		ADF->(dbSetOrder(1))
		ADF->(DBGOTOP())
		ADF->(dbSeek(xFilial("ADF") + ADE_CODIGO))

		While ADF->(!Eof()) .and. ADF->(ADF_FILIAL + ADF_CODIGO) = xFilial("ADF") + ADE_CODIGO
			If Substr(MSMM(ADF->ADF_CODOBS,TamSx3("ADE_INCIDE")[1]),1,3) == "NCC" .AND. ADF->ADF_CODSKW == "000001"
				RECLOCK("ADF",.F.)
				ADF->ADF_HORAF := Time()
				ADF->(MSUNLOCK())
			EndIf
			ADF->(DBSKIP())
		EndDo
		//INICIO DA NDF
		cMailAut := U_ZS1BuscaEmail("000001","6",cOcorr,cAcao,"E")
		//DESCONTO,CODIGO DO ATENDIMENTO,ADE_CHAVE
		U_XNDF(DESCONTO,ADE_CODIGO,ADE_CHAVE,cMailAut,ADE_NF,QTDNF,ADE_QUANT,PRECOVEN,DESCONTO) 
		U_TInteracao(ADE_CODIGO,"NDF GERADA "+ADE_CODIGO+"A","999998","2","5","NDF","","000001")

		//Alimenta hora final NDF
		DBSELECTAREA("ADF")
		ADF->(dbSetOrder(1))
		ADF->(DBGOTOP())
		ADF->(dbSeek(xFilial("ADF") + ADE_CODIGO))

		While ADF->(!Eof()) .and. ADF->(ADF_FILIAL + ADF_CODIGO) = xFilial("ADF") + ADE_CODIGO
			If Substr(MSMM(ADF->ADF_CODOBS,TamSx3("ADE_INCIDE")[1]),1,3) == "NDF" .AND. ADF->ADF_CODSKW == "000001"
				RECLOCK("ADF",.F.)
				ADF->ADF_HORAF := Time()
				ADF->(MSUNLOCK())
			EndIf
			ADF->(DBSKIP())
		EndDo

		//MUDA STATUS DO ANTENDIMENTO (FIM)
		DBSELECTAREA("ADE")
		ADE->(DBSETORDER(1))
		ADE->(DBGOTOP())
		ADE->(DBSEEK(XFILIAL("ADE")+ADE_CODIGO))

		RECLOCK("ADE",.F.)
		ADE->ADE_WFASTA := "5"
		ADE->ADE_STATUS := "1"
		ADE->(MSUNLOCK())

		restArea(aArea)
		Return .t.
	EndCase

	cMailAut := U_ZS1BuscaEmail("000001",cNivel,cOcorr,cAcao,"E")

	oWf := TWFProcess():New(cProcesso,"AVARIA DE CARGA")

	/* TAREFA 1: Html de aprovação. */
	oWf:NewTask("Criacao HTML","\workflow\" + cArq)

	oWF:oHtml:ValByName("ADE_CHAVE",ADE_CHAVE)	// Cliente+Loja
	oWF:oHtml:ValByName("SETOR",cSetor)			// Nível
	oWF:oHtml:ValByName("NIVEL",cNivel)			// Nível
	oWF:oHtml:ValByName("ADE_NMENT",ADE_NMENT)// Entidade
	oWF:oHtml:ValByName("ADE_NMCONT",ADE_NMCONT)// Contato
	oWF:oHtml:ValByName("ADE_DESCCH",ADE_DESCCH)// Entidade
	oWF:oHtml:ValByName("ADE_DDDRET",ADE_DDDRET)// DDD
	oWF:oHtml:ValByName("ADE_TELRET",FormataCpo ("ADE","ADE_TELRET",ADE_TELRET))// Telefone

	oWF:oHtml:ValByName("ADE_CODIGO",ADE_CODIGO)// Código do chamado
	oWF:oHtml:ValByName("ADE_NMOPER",ADE_NMOPER)// Operador
	oWF:oHtml:ValByName("ADE_DATA",ADE_DATA)    // Data
	oWF:oHtml:ValByName("ADE_HORA",ADE_HORA)    // Hora
	oWF:oHtml:ValByName("ADE_SEVCOD",ADE_SEVCOD)// Criticidade

	oWF:oHtml:ValByName("ADE_NMPROD",ADE_NMPROD)// Produto
	oWF:oHtml:ValByName("ADE_NF",ADE_NF)        // NF
	oWF:oHtml:ValByName("ADE_MOTIVO",ADE_MOTIVO)// Motivo
	oWF:oHtml:ValByName("QTDNF",QTDNF)          // Quantidade NF
	oWF:oHtml:ValByName("ADE_QUANT",ADE_QUANT)  // Quantidade Avariada
	oWF:oHtml:ValByName("PRECOVEN",PRECOVEN)    // Preço Venda
	oWF:oHtml:ValByName("DESCONTO",DESCONTO)    // Desconto
	oWF:oHtml:ValByName("CONFQTD",cConfQtd)    // Conferencia quantidade

	oWF:oHtml:ValByName("ASSUNTO",ASSUNTO)      // Assunto
	oWF:oHtml:ValByName("ADE_INCIDE",ADE_INCIDE) // Incidência

	oWF:oHtml:ValByName("COCORR",cOcorr)      // Ocorrencia
	oWF:oHtml:ValByName("CACAO",cAcao) // Ação

	/* Alimenta os itens do chamado */
	DBSELECTAREA("ADF")
	ADF->(dbSetOrder(1))
	ADF->(DBGOTOP())
	ADF->(dbSeek(xFilial("ADF") + ADE_CODIGO))
	While ADF->(!Eof()) .and. ADF->(ADF_FILIAL + ADF_CODIGO) = xFilial("ADF") + ADE->ADE_CODIGO
		If ADF->ADF_CODSKW == "000001" .or. POSICIONE('SU9',2,xFilial('SU9')+ADF->ADF_CODSU9,'U9_XINTERA') == "2"
			aAdd(oWF:oHtml:ValByName("IT.adf_item")	    , ADF->ADF_ITEM )   //Item
			aAdd(oWF:oHtml:ValByName("IT.ADF_NMSU9")	, ADF->ADF_CODSU9 +"-"+ FormataCpo ("SU9", "U9_DESC", POSICIONE('SU9',2,xFilial('SU9')+ADF->ADF_CODSU9,'U9_DESC'))) //Ocorrência
			aAdd(oWF:oHtml:ValByName("IT.ADF_NMSUQ")	, ADF->ADF_CODSUQ +"-"+ FormataCpo ("SUQ", "UQ_DESC", POSICIONE('SUQ', 1, xFilial('SUQ')+ADF->ADF_CODSUQ,'UQ_DESC'))) //Ação
			aAdd(oWF:oHtml:ValByName("IT.ADF_NMSU7")	, FormataCpo ("SU7", "U7_NOME",POSICIONE('SU7',1,XFILIAL('SU7') + ADF->ADF_CODSU7, 'U7_NOME'))) //Analista
			aAdd(oWF:oHtml:ValByName("IT.ADF_NMGRUP")   , DtoC(ADF->ADF_DATA) + '-' + ADF->ADF_HORAF)//Data - Hota
			aAdd(oWF:oHtml:ValByName("IT.OBSERV")       , MSMM(ADF->ADF_CODOBS,TamSx3("ADE_INCIDE")[1]))//Observacao
		EndIf
		ADF->(dbSkip())
	EndDo

	oWF:cTo			:= cPasta
	oWF:cSubject	:= "Liberacao de AVARIA - Número " + ADE_CODIGO + " - Nível " + cNivel
	oWF:bReturn	    := "U_DRWFAVARIA"
	oWF:bTimeOut	:= {{"U_DTWFAVARIA(1)",10,0,0}}
	cPula 			:= oWF:Start()

	oWf:NewTask("Envio E-mail","\workflow\" + cArqLink)
	oWF:cTo 	 := cMailAut
	oWF:cSubject := "Liberacao de AVARIA - Número " + ADE_CODIGO + " - Nível " + cNivel

	oWF:ohtml:ValByName("USUARIO",cSetor)
	oWF:ohtml:ValByName("REFERENTE","aprovação de avaria de carga Nível " + cNivel)

	oWF:ohtml:ValByName("proc_link","http://"+Alltrim(GetMV("EL_PAR013"))+"/wf/messenger/emp"+Alltrim(cEmpAnt)+"/WORKFLOW/"+cPula+".htm")

	oWF:Start()

	If cNivel == "1"
		//PARAMETRO: CODIGO DO CHAMADO, OBSERVACAO, Acão, Status ADE, STATUS WF ADE PADRAO,SETOR
		U_TInteracao(ADE_CODIGO,"(WF "+cSetor+")","999998","2","5","LOGISTICA","","000001")
	EndIf

	MsgInfo("(AVARIA DE CARGA) Enviado para análise do autorizador: " + cMailAut,"ELIZABETH")

	oWf:Free()
	oWf := nil
	restArea(aArea)

Return (.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao para retornar o conteudo do campo formatado. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function FormataCpo (cTabela, cCampo, cConteudo)

	Local cRet
	Local cTipo	:= Posicione ("SX3", 2, cCampo, "X3_TIPO")
	Local cBox	:= Posicione ("SX3", 2, cCampo, "X3_CBOX")

	Do Case
		Case cTipo $ "M"
		cRet := cConteudo
		Case cTipo $ "C"
		If Empty(cBox)
			cRet := Transform(cConteudo, PesqPict(cTabela, cCampo))
		Else
			aRetBox	:= RetSx3Box( cBox,,, Len(cConteudo) )
			nPosBox := Ascan( aRetBox, { |x| x[ 2 ] == cConteudo} )
			If nPosBox > 0
				cRet := AllTrim( aRetBox[ nPosBox, 3 ])
			Else
				cRet := cConteudo
			EndIf
		EndIf
		Case cTipo == "D"
		cRet := DtoC(cConteudo)
		Case cTipo == "N"
		cRet := Transform(cConteudo, PesqPict(cTabela, cCampo))
	EndCase

Return cRet

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao para retornar o conteudo do campo formatado. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function ZS1BuscaEmail(cProcesso,cNivel,Ocorr,Acao,cTipo)

	Local cEmail
	Local nFim

	DBSELECTAREA("ZS1")
	ZS1->(DBSETORDER(1))
	ZS1->(DBGOTOP())

	ZS1->(DBSEEK(XFILIAL("ZS1")+cProcesso+cNivel+Ocorr+Acao))

	cEmail := Alltrim(ZS1->ZS1_EMAIL)
	nFim   := ZS1->ZS1_LIMFIM

Return If(cTipo=="E",cEmail,nFim)

User Function DrillEmail(cDe,cPara,cCopia,cConhCopia,cAssunto,cTexto,lHtml,cFile)
	//*******************************************************************************

	lHtml    := Iif(ValType(lHtml)="U",.f.,lHtml)
	lOk		 := .F.

	cAccount    := GetMv("EL_RLCONTA")
	cPassword    := GetMv("EL_RLSENHA")
	cServer        := GetMv("EL_RLSERV")
	lMailAut    := GetMv("EL_RLAUTEN")

	Connect Smtp Server cServer Account cAccount Password cPassword TIMEOUT 12000 Result lOk

	If	lOk
		// SO COLOCAR ESTE TRECHO QUANDO O SERVIDOR TIVER AUTENTICACAO
		If ! MailAuth(cAccount,cPassword)
			Get Mail Error cErrorMsg
			Help("",1,"AVG0001056",,"Error: "+cErrorMsg,2,0)
			Disconnect Smtp Server Result lOk
			if !lOk
				Get Mail Error cErrorMsg
				Help("",1,"AVG0001056",,"Error: "+cErrorMsg,2,0)
			endif
			Return ( .f. )
		EndIf

		If !Empty(cCopia)
			if lHtml
				If !Empty(cFile)
					Send Mail From cDe To cPara CC cCopia Subject cAssunto Body cTexto Attachment cFile Result lOk
				Else
					Send Mail From cDe To cPara CC cCopia Subject cAssunto Body cTexto Result lOk
				EndIf
			else
				If !Empty(cFile)
					Send Mail From cDe To cPara CC cCopia Subject cAssunto Body cTexto Format Text Attachment cFile Result lOk
				Else
					Send Mail From cDe To cPara CC cCopia Subject cAssunto Body cTexto Format Text Result lOk
				EndIf
			endif
		Else
			if lHtml
				If !Empty(cFile)
					Send Mail From cDe To cPara BCC cConhCopia Subject cAssunto Body cTexto Attachment cFile Result lOk
				Else
					Send Mail From cDe To cPara BCC cConhCopia Subject cAssunto Body cTexto Result lOk
				EndIf
			else
				If !Empty(cFile)
					Send Mail From cDe To cPara BCC cConhCopia Subject cAssunto Body cTexto Format Text Attachment cFile Result lOk
				Else
					Send Mail From cDe To cPara BCC cConhCopia Subject cAssunto Body cTexto Format Text Result lOk
				EndIf
			endif
		EndIf
		If ! lOk
			Get Mail Error cErrorMsg
			Help("",1,"AVG0001056",,"Error: "+cErrorMsg,2,0)
		EndIf
	Else
		Get Mail Error cErrorMsg
		Help("",1,"AVG0001057",,"Error: "+cErrorMsg,2,0)
	EndIf
	Disconnect Smtp Server

Return