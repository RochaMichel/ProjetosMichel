#INCLUDE 'PROTHEUS.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "MSOLE.CH"
#INCLUDE "FILEIO.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ACSendM� Autor � Gustavo Henrique     � Data � 22/01/02   ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina para o envio de emails                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Conta para conexao com servidor SMTP                 ���
���          | ExpC2 : Password da conta para conexao com o servidor SMTP   ���
���          � ExpC3 : Servidor de SMTP                                     ���
���          � ExpC4 : Conta de origem do e-mail. O padrao eh a mesma conta ���
���          �         de conexao com o servidor SMTP.                      ���
���          � ExpC5 : Conta de destino do e-mail.                          ���
���          � ExpC6 : Assunto do e-mail.                                   ���
���          � ExpC7 : Corpo da mensagem a ser enviada.               	    |��
���          | ExpC8 : Patch com o arquivo que serah enviado                |��
���          | ExpC9 : .T. Exibir mensagem de erro, .f. n�o exibir msg      |��
���          | ExpC10 : Par�metro por refer�ncia, armazena o erro de envio  |��
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGAC                                                      ���
����������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������Ĵ��
���Analista Resp.�  Data  � Bops � Manutencao Efetuada                              ���
�����������������������������������������������������������������������������������Ĵ��
���Alessandro M. �25/05/18�      �Adicionado um segundo exemplo de Fraude.          ���
���              �  /  /  �      �                                                  ���
���              �  /  /  �      �                                                  ���
���              �  /  /  �      �                                                  ���
���              �  /  /  �      �                                                  ���
���              �  /  /  �      �                                                  ���
������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������*/

User Function ACSendM(cAccount,cPassword,cServer,cFrom,cEmail,cAssunto,cMensagem,cAttach,lMsg,cLog)

	Local cEmailTo := ""
	Local cEmailCc := ""
	Local lResult  := .F.
	Local cError   := ""
	Local cUser
	Local nAt
	Local cFromGe  := GetNewPar("MV_ACEMAIL", "")

	Default lMsg := .T.
	Default cLog := ""

	// Verifica se serao utilizados os valores padrao.
	cAccount	   := Iif( cAccount  == NIL, GetMV( "MV_RELACNT" ), cAccount  )
	cPassword	:= Iif( cPassword == NIL, GetMV( "MV_RELPSW"  ), cPassword )
	cServer		:= Iif( cServer   == NIL, GetMV( "MV_RELSERV" ), cServer   )
	cAttach 	   := Iif( cAttach   == NIL, "", cAttach )
	cFrom		   := Iif( cFrom     == NIL, Iif( Empty(GetMV( "MV_RELFROM" )), GetMV( "MV_RELACNT" ), GetMV( "MV_RELFROM" ) ), cFrom )

	If  !EMPTY(cFromGe)
		If Alltrim(cFrom) == Alltrim( GetMV( "MV_RELACNT" ) ) .or. Alltrim(cFrom) == Alltrim( GetMV( "MV_RELFROM" ) ) // verifica se est� utilizando o email do parametro global
			cFrom := cFromGe
		EndIf
	EndIf


	If Alltrim(Upper(GetEnvServer())) $ "HOMOLOGMORIAH"
		cEmailTo		:= ""
		cCopia		:= ""
		cEmailCc		:= ""
		VarInfo("DrillEmail",{cAccount,cPassword,cServer,cFrom,cEmail,cAssunto,cMensagem,cAttach,lMsg,cLog}) 
		MemoWrit('LogSendMailACSendM'+DTOS(Date())+Alltrim(cValToChar(Seconds()))+'.html',cMensagem)
		Return .T.
	Endif


	//�������������������������������������������������������������������������������Ŀ
	//�Envia o e-mail para a lista selecionada. Envia como CC                         �
	//���������������������������������������������������������������������������������
	cEmailTo := SubStr(cEmail,1,At(Chr(59),cEmail)-1)
	cEmailCc := SubStr(cEmail,At(Chr(59),cEmail)+1,Len(cEmail))

	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

	//���������������������������������������������������������Ŀ
	//�Verifica se o Servidor de EMAIL necessita de Autenticacao�
	//�����������������������������������������������������������
	if lResult .and. GetMv("MV_RELAUTH")
		//Primeiro tenta fazer a Autenticacao de E-mail utilizando o e-mail completo
		lResult := MailAuth(cAccount, cPassword)
		//Se nao conseguiu fazer a Autenticacao usando o E-mail completo, tenta fazer a autenticacao usando apenas o nome de usuario do E-mail
		if !lResult
			nAt 	:= At("@",cAccount)
			cUser 	:= If(nAt>0,Subs(cAccount,1,nAt-1),cAccount)
			lResult := MailAuth(cUser, cPassword)
		endif
	endif

	//���������������������������Ŀ
	//�Traduz a mensagem para HTML�
	//�����������������������������
	cMensagem := iif(GetNewPar("MV_ACEMLAC","1") $ "12",cMensagem,cMensagem)

	//������������������������������������������������������������������������������������������Ŀ
	//�Executa o ponto de entrada que permite ao usuario customizar a mensagem HTML a ser enviada�
	//��������������������������������������������������������������������������������������������
	If ExistBlock("AcaMail")
		cMensagem := ExecBlock("AcaMail",.F.,.F.,{FunName(),cFrom,cEmailTo,cAssunto,cMensagem,cAttach})
	EndIf

	If lResult
		SEND MAIL FROM cFrom ;
		TO      	cEmailTo;
		CC     		cEmailCc;
		SUBJECT 	if( GetNewPar("MV_ACEMLAC", "1")$"1", cAssunto , cAssunto );
		BODY    	cMensagem;
		ATTACHMENT  cAttach  ;
		RESULT lResult

		If !lResult
			//Erro no envio do email
			GET MAIL ERROR cError
			If lMsg
				//Help(" ",1,"ATENCAO",,"N�o foi poss�vel enviar o e-mail para:" + cEmailTo +" ."+ "Verifique se o e-mail est� cadastrado corretamente!",4,5)
			EndIf
			cLog := "N�o foi poss�vel enviar o e-mail para:" + cEmailTo
		EndIf

		DISCONNECT SMTP SERVER

	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		If lMsg
			//Help(" ",1,"ATENCAO",,"N�o foi poss�vel conectar com o servidor SMTP!" +" "+ "Aviso de Error:"+cError,4,5)
		EndIf
		cLog := "N�o foi poss�vel conectar com o servidor SMTP!" +" "+ "Aviso de Error:"+cError
	EndIf

Return(lResult)


user function ELTEST(PRM1)

	RpcSetType(2)
	RpcSetEnv("01", "020101" )

	EnvTEST()
	Alert("FIM")
Return

user function ELMAIL(oProcess,cAux)

	RpcSetType(2)
	RpcSetEnv("01", "020101" )

	EnvMCer(oProcess,cAux)

	RpcClearEnv()

return

user function ELCMAIL(oProcess,_cUF,_cCaminho)

	EnvMACIM(oProcess,_cUF,_cCaminho)

return

static function EnvMACim(oProcess,_cUF,_cCaminho)
	Local cMailEl := " "
	Local _cHTML := " "
	Local cQuery := " "
	Local nC := 0
	Local _aDadoTmp :=  Separa(_cUF,";",.T.)
	Local _nRegua
	Local _nI := 1
	cQuery := " SELECT A1.A1_XVEND2,TRIM(A1.A1_EMAIL) as EMAIL "
	cQuery += " ,( select count(*) FROM "+RetSqlName("SA1")+" SA WHERE SA.A1_VEND<>' ' and SA.A1_XVEND2<>' ' AND trim(SA.A1_EMAIL) NOT IN ('@','@.','.') AND SA.A1_EMAIL LIKE '%@%' AND SA.D_E_L_E_T_=' ' " 
	cQuery += " AND SA.A1_EST IN ( "
	For _nI := 1 To Len(_aDadoTmp)
		cQuery += "'"+AllTrim(_aDadoTmp[_nI])+"'"+IIf(_nI < Len(_aDadoTmp), ',', ') ')
	Next _nI
	cQuery += " ) as QTD "
	cQuery += " FROM "+RetSqlName("SA1")+" A1 " 
	cQuery += " WHERE A1.A1_VEND<>' ' and A1.A1_XVEND2<>' ' AND trim(A1.A1_EMAIL) NOT IN ('@','@.','.') AND A1.A1_EMAIL LIKE '%@%' AND A1.D_E_L_E_T_=' ' "
	cQuery += " AND A1_EST IN ( "   
	For _nI := 1 To Len(_aDadoTmp)
		cQuery += "'"+AllTrim(_aDadoTmp[_nI])+"'"+IIf(_nI < Len(_aDadoTmp), ',', ') ')
	Next _nI
	cQuery += "  order by 2 "

	If Select("TMP") > 0
		DBSELECTAREA("TMP")
		TMP->(DBCLOSEAREA())
	EndIf

	TcQuery cQuery New Alias "TMP"
	DBSELECTAREA("TMP")
	TMP->(DBGOTOP())

	_cHTML  := " " //"ELIZABETH CIMENTOS LTDA - SERVI�OS AO CLIENTE"
	//cMailEl := "rodrigo.lyra@elizabethcimentos.com.br;venilton.silva@elizabethcimentos.com.br;andre.pessoa@grupoelizabeth.com.br"
	cMailEl := "andre.pessoa@grupoelizabeth.com.br"
	EnvRCIM(cMailEl,_cHTML,"COMUNICADO - "+Time(),"Comunicado "+cMailEl,_cCaminho)

	oProcess:SetRegua1(TMP->QTD)
	WHILE !TMP->(EOF())	
		oProcess:IncRegua1("Processando Clientes...")
		cMailEl := TMP->EMAIL
		EnvRCIM(cMailEl,_cHTML,"COMUNICADO - "+Time(),"Comunicado "+cMailEl,_cCaminho)  
		nC := nC + 1
		oProcess:IncRegua1("Enviando: " + TMP->EMAIL) 
		//conout(nC)
		TMP->(DBSKIP())
	ENDDO 
	cMailEl := "andre.pessoa@grupoelizabeth.com.br"

	EnvRCIM(cMailEl,_cHTML,"COMUNICADO - "+Time(),"Comunicado "+cMailEl,_cCaminho)

	//conout("Fim de envio de comunicado "+DtoC(date())+" - "+Time())
return

static function EnvMailAnexo(caminho)
	Local cMailEl := " "
	Local _cHTML := " "
	Local cQuery := " "
	Local nC := 0

	cQuery := " SELECT A1_XVEND2,TRIM(A1_EMAIL) EMAIL FROM SA1010 WHERE A1_VEND<>' ' and A1_XVEND2<>' ' AND trim(A1_EMAIL) NOT IN ('@','@.') AND A1_EMAIL LIKE '%@%' AND D_E_L_E_T_=' ' and A1_EMAIL>'nfe@ferreiracosta.com.br' order by 2 "
	If Select("TMP") > 0
		DBSELECTAREA("TMP")
		TMP->(DBCLOSEAREA())
	EndIf

	TcQuery cQuery New Alias "TMP"
	DBSELECTAREA("TMP")
	TMP->(DBGOTOP())

	_cHTML  := " " //"ELIZABETH CIMENTOS LTDA - SERVI�OS AO CLIENTE"

	WHILE !TMP->(EOF())	
		cMailEl := TMP->EMAIL
		EnvResp(cMailEl,_cHTML,"COMUNICADO - "+Time(),"Comunicado "+cMailEl,caminho)
		TMP->(DBSKIP())
		nC := nC + 1
		//conout(nC)
	END
	//conout("Fim de envio de comunicado "+DtoC(date())+" - "+Time())
return



static function EnvMailCeramica()
	Local cMailEl := " "
	Local _cHTML := " "
	Local cQuery := " "

	_cHTML := '<html>'
	_cHTML += '<head>'
	_cHTML += '    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />'
	_cHTML += '	<title>GRUPO ELIZABETH - Portal do Representante</title>'
	_cHTML += '    <meta name="description" content="GRUPO ELIZABETH">'
	_cHTML += '    <meta name="viewport" content="width=device-width, initial-scale=1.0">'
	_cHTML += '    <link rel="stylesheet" type="text/css" href="http://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700,800">'
	_cHTML += '    <link rel="stylesheet" type="text/css" href="http://fonts.googleapis.com/css?family=Roboto:400,500,700,300">'
	_cHTML += '    <link rel="stylesheet" type="text/css" href="http://elizabethweb.com.br/site/assets/skin/default_skin/css/theme.css">'
	_cHTML += '    <link rel="shortcut icon" href="http://elizabethweb.com.br/site/assets/img/favicon.ico">'
	_cHTML += '    <style> .indented {   padding-left: 50pt;   padding-right: 50pt; } </style> '
	_cHTML += '    <!--[if lt IE 9]>'
	_cHTML += '  <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>'
	_cHTML += '  <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>'
	_cHTML += '<![endif]-->'
	_cHTML += '</head>'
	_cHTML += '<body class="blank-page">'
	_cHTML += '	<div id="main">'
	_cHTML += '        <header class="navbar navbar-fixed-top bg-primary">'
	_cHTML += '            <div class="navbar-branding">'
	_cHTML += '                <a class="navbar-brand" href="ceramicaelizabeth.com.br"> <img src="http://elizabethweb.com.br/site/img/logoelizabethazulescuro.png" width="180" height="50" border="0"> </a>'
	_cHTML += '                <span id="toggle_sidemenu_l" class="glyphicons glyphicons-show_lines"></span>'
	_cHTML += '                <ul class="nav navbar-nav pull-right hidden">'
	_cHTML += '                    <li>'
	_cHTML += '                        <a href="#" class="sidebar-menu-toggle">'
	_cHTML += '                            <span class="octicon octicon-ruby fs20 mr10 pull-right "></span>'
	_cHTML += '                        </a>'
	_cHTML += '                    </li>'
	_cHTML += '                </ul>'
	_cHTML += '            </div>'
	_cHTML += '		</header>'
	_cHTML += '		<br><br><br><br>'
	_cHTML += '		<div class="panel panel-default">'
	_cHTML += '			<div class="panel-body">'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented">Prezados Senhores,</p>'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented">Alertamos que golpistas est�o veiculando e-mails fraudulentos solicitando a substitui��o de boletos banc�rios (exemplo abaixo).</p>'
	_cHTML += '				<p class="indented">Reiteramos que as empresas do Grupo Elizabeth n�o enviam e-mails solicitando pagamentos, informa��es pessoais, informa��es financeiras, n�meros de conta, senhas, trocas de boletos, etc., que n�o tenham sido solicitados pelo cliente. O Grupo Elizabeth n�o aceita qualquer responsabilidade por quaisquer custos ou encargos incorridos como resultado de uma atividade fraudulenta.</p>'
	_cHTML += '				<p class="indented">Quando solicitados pelos clientes, os e-mails que partem do Grupo Elizabeth s�o devidamente identificados atrav�s dos dom�nios: @grupoelizabeth.com.br, @ceramicaelizabeth.com.br ou @elizabethcimentos.com.br.</p>'
	_cHTML += '				<p class="indented">Se receber algum e-mail suspeito, <u>n�o clique em links ou anexos</u>.  Em vez disso, simplesmente apague o e-mail.  Havendo d�vidas sobre a proced�ncia do e-mail, entre em contado com a nossa �rea de Cr�dito e Cobran�a atrav�s dos telefones:</p>'
	_cHTML += '				<p class="indented" align="center"><b>Crici�ma - SC (048) 3461-2700		Nordeste: (083) 2107-2000</b></p>'
	_cHTML += '				<p class="indented">O que o Grupo Elizabeth est� fazendo a respeito?</p>'
	_cHTML += '				<p class="indented">Todas as fraudes com uma conex�o pretendida com as empresas do Grupo Elizabeth s�o encaminhadas �s autoridades pertinentes para rastreamento e investiga��o.  Tamb�m estamos trabalhando junto com os servidores de e-mail para identificar e paralisar esta atividade fraudulenta. </p>'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented"><img src="http://elizabethweb.com.br/site/img/fraudeboleto.png"/></p>'
	_cHTML += '				<p class="indented"><a href="http://elizabethweb.com.br/site/anexos/Comunicado_fraudes_nos_boletos_07-11-2016.pdf"><img src="http://elizabethweb.com.br/site/img/icon_down_pdf.png" width="40" height="40"></a></p>'
	_cHTML += '			</div>'
	_cHTML += '		</div>'
	_cHTML += '	</div>'
	_cHTML += '</body>'
	_cHTML += '</html>'

	cQuery := " SELECT A1_VEND,TRIM(A1_EMAIL) EMAIL FROM SA1010 WHERE A1_VEND<>' ' AND trim(A1_EMAIL) NOT IN  ('@','@.','@@','@!','@@@','@') AND A1_EMAIL LIKE '%@%' AND D_E_L_E_T_=' ' ORDER BY A1_EMAIL "
	If Select("TMP") > 0
		DBSELECTAREA("TMP")
		TMP->(DBCLOSEAREA())
	EndIf

	TcQuery cQuery New Alias "TMP"
	DBSELECTAREA("TMP")
	TMP->(DBGOTOP())

	cMailEl := "alessandro.bezerra@grupoelizabeth.com.br;rogerio@grupoelizabeth.com.br;roberto.farias@grupoelizabeth.com.br"
	EnvRCer(cMailEl,_cHTML,"ALERTA DE FRAUDE "+DtoC(date())+" - "+Time(),"Comunicado "+cMailEl,"")
	WHILE !TMP->(EOF())	
		cMailEl := TMP->EMAIL
		//conout("Enviado Comunicado para: "+cMailEl)
		EnvRCer(cMailEl,_cHTML,"ALERTA DE FRAUDE "+DtoC(date())+" - "+Time(),"Comunicado "+cMailEl,"")

		TMP->(DBSKIP())
	END
	cMailEl := "alessandro.bezerra@grupoelizabeth.com.br; andre@grupoelizabeth.com.br; rogerio@grupoelizabeth.com.br; alexandre@ceramicaelizabeth.com.br"
	EnvRCer(cMailEl,_cHTML,"ALERTA DE FRAUDE "+DtoC(date())+" - "+Time(),"Comunicado "+cMailEl,"")
return


static function EnvMCer(oProcess,cAux)
	Local cMailEl := " "
	Local _cHTML := " "
	Local cQuery := " "
	Local nCnt := 0

	_cHTML := '<html>'
	_cHTML += '<head>'
	_cHTML += '    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />'
	_cHTML += '	<title>GRUPO ELIZABETH - Portal do Representante</title>'
	_cHTML += '    <meta name="description" content="GRUPO ELIZABETH">'
	_cHTML += '    <meta name="viewport" content="width=device-width, initial-scale=1.0">'
	_cHTML += '    <link rel="stylesheet" type="text/css" href="http://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700,800">'
	_cHTML += '    <link rel="stylesheet" type="text/css" href="http://fonts.googleapis.com/css?family=Roboto:400,500,700,300">'
	_cHTML += '    <link rel="stylesheet" type="text/css" href="http://elizabethweb.com.br/site/assets/skin/default_skin/css/theme.css">'
	_cHTML += '    <link rel="shortcut icon" href="http://elizabethweb.com.br/site/assets/img/favicon.ico">'
	_cHTML += '    <style> .indented {   padding-left: 50pt;   padding-right: 50pt; } </style> '
	_cHTML += '    <!--[if lt IE 9]>'
	_cHTML += '  <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>'
	_cHTML += '  <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>'
	_cHTML += '<![endif]-->'
	_cHTML += '</head>'
	_cHTML += '<body class="blank-page">'
	_cHTML += '	<div id="main">'
	_cHTML += '        <header class="navbar navbar-fixed-top bg-primary">'
	_cHTML += '            <div class="navbar-branding">'
	_cHTML += '                <a class="navbar-brand" href="ceramicaelizabeth.com.br"> <img src="http://elizabethweb.com.br/site/img/logoelizabethazulescuro.png" width="180" height="50" border="0"> </a>'
	_cHTML += '                <span id="toggle_sidemenu_l" class="glyphicons glyphicons-show_lines"></span>'
	_cHTML += '                <ul class="nav navbar-nav pull-right hidden">'
	_cHTML += '                    <li>'
	_cHTML += '                        <a href="#" class="sidebar-menu-toggle">'
	_cHTML += '                            <span class="octicon octicon-ruby fs20 mr10 pull-right "></span>'
	_cHTML += '                        </a>'
	_cHTML += '                    </li>'
	_cHTML += '                </ul>'
	_cHTML += '            </div>'
	_cHTML += '		</header>'
	_cHTML += '		<br><br><br><br>'
	_cHTML += '		<div class="panel panel-default">'
	_cHTML += '			<div class="panel-body">'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented">Prezados Senhores,</p>'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented">Alertamos que golpistas est�o veiculando e-mails fraudulentos solicitando a substitui��o de boletos banc�rios (exemplo abaixo).</p>'
	_cHTML += '				<p class="indented">Reiteramos que as empresas do Grupo Elizabeth n�o enviam e-mails solicitando pagamentos, informa��es pessoais, informa��es financeiras, n�meros de conta, senhas, trocas de boletos, etc., que n�o tenham sido solicitados pelo cliente. O Grupo Elizabeth n�o aceita qualquer responsabilidade por quaisquer custos ou encargos incorridos como resultado de uma atividade fraudulenta.</p>'
	_cHTML += '				<p class="indented">Quando solicitados pelos clientes, os e-mails que partem do Grupo Elizabeth s�o devidamente identificados atrav�s dos dom�nios: @grupoelizabeth.com.br, @ceramicaelizabeth.com.br ou @elizabethcimentos.com.br.</p>'
	_cHTML += '				<p class="indented">Se receber algum e-mail suspeito, <u>n�o clique em links ou anexos</u>.  Em vez disso, simplesmente apague o e-mail.  Havendo d�vidas sobre a proced�ncia do e-mail, entre em contado com a nossa �rea de Cr�dito e Cobran�a atrav�s dos telefones:</p>'
	_cHTML += '				<p class="indented" align="center"><b>Crici�ma - SC (048) 3461-2700		Nordeste: (083) 2107-2000</b></p>'
	_cHTML += '				<p class="indented">O que o Grupo Elizabeth est� fazendo a respeito?</p>'
	_cHTML += '				<p class="indented">Todas as fraudes com uma conex�o pretendida com as empresas do Grupo Elizabeth s�o encaminhadas �s autoridades pertinentes para rastreamento e investiga��o.  Tamb�m estamos trabalhando junto com os servidores de e-mail para identificar e paralisar esta atividade fraudulenta. </p>'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented">Alerta!!</p>'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented">Novo golpe na pra�a, Vejam exmplos de textos utilizados pelos bandidos para fraudar clientes. O Grupo Elizabeth n�o envia Boletos por e-mail sem que seja solicitado pelo cliente nos canais de atendimentos.</font></p>'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented">Exemplo 1</p>'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented"><font color="red">Prezado(a),</font></p>'
	_cHTML += '				<p class="indented"><font color="red">Aten��o, �ltimo aviso antes do protesto!</font></p>'
	_cHTML += '				<p class="indented"><font color="red">Informamos a empresa XXXXX que hoje XX/XX/2018 � o �ltimo dia para pagamento do t�tulo XXXXXX valor R$ 999,99 fora do cart�rio (protesto).</font></p>'
	_cHTML += '				<p class="indented"><font color="red">Estamos enviando o t�tulo atualizado para pagamento at� 03/05/2018!</font></p>'
	_cHTML += '				<p class="indented"><font color="red">Caso n�o seja poss�vel efetuar o pagamento at� 03/05/2018, ser� necess�rio aguardar o instrumento de protesto e efetuar o pagamento diretamente ao cart�rio VALOR + CUSTAS.</font></p>'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented"><font color="red">Atenciosamente,</font></p>'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented"><font color="red">Juliano Teixeira</font></p>'
	_cHTML += '				<p class="indented"><font color="red">Dpto Financeiro</font></p>'
	_cHTML += '				<p class="indented"><font color="red">ELIZABETH REVESTIMENTOS LTDA </font></p>'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented">Exemplo 2</p>'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented"><font color="red">Prezado(a),</font></p>'
	_cHTML += '				<p class="indented"><font color="red">Informamos a XXXXXXX XXXXXX XXXXX LTDA, que devido a problemas operacionais em nosso programa de faturamento de Notas Fiscais, foi constatado uma diverg�ncia no c�lculo da al�quota de ICMS/Cofins sendo que foi contabilizado a cobran�a � maior do valor de $99.99.</font></p>'
	_cHTML += '				<p class="indented"><font color="red">Como forma de neutralizar o erro de nosso programa, estaremos concedendo igualmente um cr�dito de $99.99 no t�tulo 1  000999999999 com data de vencimento para o dia XX/XX/2018.</font></p>'
	_cHTML += '				<p class="indented"><font color="red">Pedimos que despreze o boleto anterior (N�O PAGUE) de $9999.99  em DDA e utilize o NOVO BOLETO EM ANEXO com o valor corrigido de $999.99.</font></p>'
	_cHTML += '				<p class="indented"><font color="red">Por gentileza solicitamos que confirme o recebimento deste email.</font></p>'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented"><font color="red">OBS: Bonifica��o/Cr�dito referente a erro no c�lculo da al�quota de ICMS/PIS/Cofins cobrado � maior.</font></p>'
	_cHTML += '				<p class="indented"><font color="red">Em Anexo se encontra a Baixa do T�tulo Anterior e o Novo Boleto com o devido abatimento.</font></p>'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented"><font color="red">Atenciosamente,</font></p>'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented"><font color="red">Maria Souza</font></p>'
	_cHTML += '				<p class="indented"><font color="red">Dpto Financeiro</font></p>'
	_cHTML += '				<p class="indented"><font color="red">ELIZABETH REVESTIMENTOS LTDA </font></p>'
	_cHTML += '				<br>'
	_cHTML += '			</div>'
	_cHTML += '		</div>'
	_cHTML += '	</div>'
	_cHTML += '</body>'
	_cHTML += '</html>'

	//cQuery := " SELECT A1_VEND,TRIM(A1_EMAIL) EMAIL FROM SA1010 WHERE A1_MSBLQL<>'1' AND A1_VEND<>' ' AND A1_EMAIL NOT LIKE '@%' AND  trim(A1_EMAIL) NOT IN  ('@','@.','@@','@!','@@@','@') AND A1_EMAIL LIKE '%@%' AND D_E_L_E_T_=' ' ORDER BY A1_EMAIL "
	cQuery := " SELECT A1.A1_VEND,TRIM(A1.A1_EMAIL) EMAIL, " 
	cQuery += " ( Select count(*) "
	cQuery += " FROM " + RETSQLNAME("SA1") + " SA1 " 
	cQuery += " WHERE SA1.A1_MSBLQL<>'1' AND SA1.A1_VEND<>' ' AND SA1.A1_EMAIL NOT LIKE '@%' AND  trim(SA1.A1_EMAIL) NOT IN  ('@','@.','@@','@!','@@@','@') AND " 
	cQuery += " SA1.A1_EMAIL LIKE '%@%' AND SA1.D_E_L_E_T_=' ' "
	cQuery += " ) as QTD " 
	cQuery += " FROM " + RETSQLNAME("SA1") + " A1 " 
	cQuery += " WHERE A1.A1_MSBLQL<>'1' AND A1.A1_VEND<>' ' AND A1.A1_EMAIL NOT LIKE '@%' AND  trim(A1.A1_EMAIL) NOT IN  ('@','@.','@@','@!','@@@','@') AND " 
	cQuery += " A1.A1_EMAIL LIKE '%@%' AND A1.D_E_L_E_T_=' ' " 
	cQuery += " ORDER BY A1.A1_EMAIL "

	If Select("TMP") > 0
		DBSELECTAREA("TMP")
		TMP->(DBCLOSEAREA())
	EndIf

	TcQuery cQuery New Alias "TMP"
	DBSELECTAREA("TMP")
	TMP->(DBGOTOP())
	If empty(cAux)
		cMailEl := "andre.pessoa@grupoelizabeth.com.br"
	else
		cMailEl := "andre.pessoa@grupoelizabeth.com.br"+";"+cAux
	endif	
	EnvRCer(cMailEl,_cHTML,"ALERTA DE FRAUDE "+DtoC(date())+" - "+Time(),"Comunicado "+cMailEl,"")
	oProcess:SetRegua1(TMP->QTD)
	WHILE !TMP->(EOF())	
		cMailEl := TMP->EMAIL
		nCnt := nCnt+1
		oProcess:IncRegua1("Processando Clientes...")
		//conout("Enviado Comunicado para "+Str(nCnt)+" : "+cMailEl)
		oProcess:IncRegua1("Enviando: " + TMP->EMAIL)
		EnvRCer(cMailEl,_cHTML,"ALERTA DE FRAUDE "+DtoC(date())+" - "+Time(),"Comunicado "+cMailEl,"") //enviar para todos os clientes

		TMP->(DBSKIP())
	END
	If empty(cAux)
		cMailEl := "andre.pessoa@grupoelizabeth.com.br"
	else
		cMailEl := "andre.pessoa@grupoelizabeth.com.br"+";"+cAux
	endif
	EnvRCer(cMailEl,_cHTML,"ALERTA DE FRAUDE "+DtoC(date())+" - "+Time(),"Comunicado "+cMailEl,"")
return




static function EnvTEST()
	Local cMailEl := " "
	Local _cHTML := " "
	Local cQuery := " "
	Local nCnt := 0

	_cHTML := '<html>'
	_cHTML += '<head>'
	_cHTML += '    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />'
	_cHTML += '	<title>GRUPO ELIZABETH - Portal do Representante</title>'
	_cHTML += '    <meta name="description" content="GRUPO ELIZABETH">'
	_cHTML += '    <meta name="viewport" content="width=device-width, initial-scale=1.0">'
	_cHTML += '    <link rel="stylesheet" type="text/css" href="http://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700,800">'
	_cHTML += '    <link rel="stylesheet" type="text/css" href="http://fonts.googleapis.com/css?family=Roboto:400,500,700,300">'
	_cHTML += '    <link rel="stylesheet" type="text/css" href="http://elizabethweb.com.br/site/assets/skin/default_skin/css/theme.css">'
	_cHTML += '    <link rel="shortcut icon" href="http://elizabethweb.com.br/site/assets/img/favicon.ico">'
	_cHTML += '    <style> .indented {   padding-left: 50pt;   padding-right: 50pt; } </style> '
	_cHTML += '    <!--[if lt IE 9]>'
	_cHTML += '  <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>'
	_cHTML += '  <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>'
	_cHTML += '<![endif]-->'
	_cHTML += '</head>'
	_cHTML += '<body class="blank-page">'
	_cHTML += '	<div id="main">'
	_cHTML += '        <header class="navbar navbar-fixed-top bg-primary">'
	_cHTML += '            <div class="navbar-branding">'
	_cHTML += '                <a class="navbar-brand" href="ceramicaelizabeth.com.br"> <img src="http://elizabethweb.com.br/site/img/logoelizabethazulescuro.png" width="180" height="50" border="0"> </a>'
	_cHTML += '                <span id="toggle_sidemenu_l" class="glyphicons glyphicons-show_lines"></span>'
	_cHTML += '                <ul class="nav navbar-nav pull-right hidden">'
	_cHTML += '                    <li>'
	_cHTML += '                        <a href="#" class="sidebar-menu-toggle">'
	_cHTML += '                            <span class="octicon octicon-ruby fs20 mr10 pull-right "></span>'
	_cHTML += '                        </a>'
	_cHTML += '                    </li>'
	_cHTML += '                </ul>'
	_cHTML += '            </div>'
	_cHTML += '		</header>'
	_cHTML += '		<br><br><br><br>'
	_cHTML += '		<div class="panel panel-default">'
	_cHTML += '			<div class="panel-body">'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented">Prezados Senhores,</p>'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented">Alertamos que golpistas est�o veiculando e-mails fraudulentos solicitando a substitui��o de boletos banc�rios (exemplo abaixo).</p>'
	_cHTML += '				<p class="indented">Reiteramos que as empresas do Grupo Elizabeth n�o enviam e-mails solicitando pagamentos, informa��es pessoais, informa��es financeiras, n�meros de conta, senhas, trocas de boletos, etc., que n�o tenham sido solicitados pelo cliente. O Grupo Elizabeth n�o aceita qualquer responsabilidade por quaisquer custos ou encargos incorridos como resultado de uma atividade fraudulenta.</p>'
	_cHTML += '				<p class="indented">Quando solicitados pelos clientes, os e-mails que partem do Grupo Elizabeth s�o devidamente identificados atrav�s dos dom�nios: @grupoelizabeth.com.br, @ceramicaelizabeth.com.br ou @elizabethcimentos.com.br.</p>'
	_cHTML += '				<p class="indented">Se receber algum e-mail suspeito, <u>n�o clique em links ou anexos</u>.  Em vez disso, simplesmente apague o e-mail.  Havendo d�vidas sobre a proced�ncia do e-mail, entre em contado com a nossa �rea de Cr�dito e Cobran�a atrav�s dos telefones:</p>'
	_cHTML += '				<p class="indented" align="center"><b>Crici�ma - SC (048) 3461-2700		Nordeste: (083) 2107-2000</b></p>'
	_cHTML += '				<p class="indented">O que o Grupo Elizabeth est� fazendo a respeito?</p>'
	_cHTML += '				<p class="indented">Todas as fraudes com uma conex�o pretendida com as empresas do Grupo Elizabeth s�o encaminhadas �s autoridades pertinentes para rastreamento e investiga��o.  Tamb�m estamos trabalhando junto com os servidores de e-mail para identificar e paralisar esta atividade fraudulenta. </p>'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented">Alerta!!</p>'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented">Novo golpe na pra�a, Vejam texto utilizado pelos bandidos para fraudar clientes. O Grupo Elizabeth n�o envia Boletos por e-mail sem que seja solicitado pelo cliente nos canais de atendimentos.</font></p>'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented"><font color="red">Prezado(a),</font></p>'
	_cHTML += '				<p class="indented"><font color="red">Aten��o, �ltimo aviso antes do protesto!</font></p>'
	_cHTML += '				<p class="indented"><font color="red">Informamos a empresa XXXXX que hoje XX/XX/2018 � o �ltimo dia para pagamento do t�tulo XXXXXX valor R$ 999,99 fora do cart�rio (protesto).</font></p>'
	_cHTML += '				<p class="indented"><font color="red">Estamos enviando o t�tulo atualizado para pagamento at� 03/05/2018!</font></p>'
	_cHTML += '				<p class="indented"><font color="red">Caso n�o seja poss�vel efetuar o pagamento at� 03/05/2018, ser� necess�rio aguardar o instrumento de protesto e efetuar o pagamento diretamente ao cart�rio VALOR + CUSTAS.</font></p>'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented"><font color="red">Atenciosamente,</font></p>'
	_cHTML += '				<br>'
	_cHTML += '				<p class="indented"><font color="red">Juliano Teixeira</font></p>'
	_cHTML += '				<p class="indented"><font color="red">Dpto Financeiro</font></p>'
	_cHTML += '				<p class="indented"><font color="red">ELIZABETH REVESTIMENTOS LTDA </font></p>'
	_cHTML += '				<br>'
	_cHTML += '			</div>'
	_cHTML += '		</div>'
	_cHTML += '	</div>'
	_cHTML += '</body>'
	_cHTML += '</html>'

	cMailEl := "alessandro.bezerra@grupoelizabeth.com.br;andre@grupoelizabeth.com.br;roberto.farias@grupoelizabeth.com.br;financeiro.controller@grupoelizabeth.com.br"
	EnvRCer(cMailEl,_cHTML,"TESTE - ALERTA DE FRAUDE "+DtoC(date())+" - "+Time(),"Comunicado "+cMailEl,"")
return

Static Function EnvResp(_email, _mensagem, _assunto, _setor,anexo)
	Local _email, _mensagem, _assunto
	Local _aArea := GetArea()
	Local cAccount, cPassword, cServer
	Local lMailAut := .T.

	cAccount	:= GetMv("EL_RLCONTA")
	cPassword	:= GetMv("EL_RLSENHA")
	cServer		:= GetMv("EL_RLSERV")
	lMailAut	:= GetMv("EL_RLAUTEN")

	cMV1		:= "MV_RELSSL"
	cMV2		:= "MV_RELTLS"

	U_ACSendM(cAccount,cPassword,cServer,"comunicado@elizabethcimentos.com.br",_email,_assunto,_mensagem,anexo)
	//conout("Notificacao de Retorno: " + _setor)  

Return



Static Function EnvRCIM(_email, _mensagem, _assunto, _setor,anexo)
	Local _email, _mensagem, _assunto
	Local _aArea := GetArea()
	Local cAccount, cPassword, cServer
	Local lMailAut := .T.

	cAccount	:= "comunicado@elizabethcimentos.com.br"//GetMv("EL_RLCONTA")
	cPassword	:= GetMv("EL_RLSENHA")
	cServer		:= GetMv("EL_RLSERV")
	lMailAut	:= GetMv("EL_RLAUTEN")

	cMV1		:= "MV_RELSSL"
	cMV2		:= "MV_RELTLS"

	U_ACSendM(cAccount,cPassword,cServer,"comunicado@elizabethcimentos.com.br",_email,_assunto,_mensagem,anexo)

	//conout("Notificacao de Retorno: " + _setor)  

Return

Static Function EnvRCer(_email, _mensagem, _assunto, _setor,anexo)
	Local _email, _mensagem, _assunto
	Local _aArea := GetArea()
	Local cAccount, cPassword, cServer
	Local lMailAut := .T.

	cAccount	:= GetMv("EL_RLCONTA")
	cPassword	:= GetMv("EL_RLSENHA")
	cServer		:= GetMv("EL_RLSERV")
	lMailAut	:= GetMv("EL_RLAUTEN")

	cMV1		:= "MV_RELSSL"
	cMV2		:= "MV_RELTLS"

	U_ACSendM(cAccount,cPassword,cServer,"erp@grupoelizabeth.com.br",_email,_assunto,_mensagem,anexo)
	//conout("Notificacao de Retorno: " + _setor)  

Return