/**

	Atilio, 11/11/2021
	Fonte foi congelado, atrav�s do PONR010 para ter o filtro de Supervisor e Regi�o
	conforme l�gica no SPGPER07

	Foi necess�rio o congelamento do arquivo, pois ele n�o possu�a pontos de entrada
	nem alguma outra forma de dar DbSetFilter na SRA

	Foi revisado dia 26/01/2023, adicionando a portaria 671

**/

//Bibliotecas
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PONR010.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
//#INCLUDE "PONCALEN.CH"

//Constantes
#Define STR0098 "Hr.Val"
#Define STR0099 "Horas Valorizadas"
#Define STR0100 "Nome Social"
#Define STR0101 "Log de ocorr�ncias na integra��o com TAE"
#Define STR0102 "N�o foi poss�vel efetuar autentica��o no TAE"
#Define STR0103 "Verifique os par�metros MV_SIGNURL, MV_RHTAEUS e MV_RHTAEPW"
#Define STR0104 "LIB desatualizada"
#Define STR0105 "Para execu��o da integra��o com o Totvs Assinatura Eletr�nica � necess�rio que a LIB esteja atualizada com vers�o igual ou superior a 02/12/2021"
#Define STR0106 "Espelhos de Ponto enviados: "
#Define STR0107 "Espelhos de Ponto n�o enviados:"
#Define STR0108 "E-mail n�o cadastrado. N�o foi enviado solicita��o de assinatura para o colaborador."
#Define STR0109 "Solicita��o enviada para "
#Define STR0110 'Acesse a op��o "Config. Assina. Eletr." na rotina Controle de Espelho de Ponto para configurar o usu�rio e senha de integra��o com o Totvs Assinatura Eletr�nica'
#Define STR0111 "Hor�rios"
#Define STR0112 "Admiss�o: "
#Define STR0113 "Jornada"
#Define STR0114 "N�o foi poss�vel realizar o upload do arquivo para o TAE. Verifique se o usu�rio utilizado para a integra��o possui permiss�o para enviar arquivos."
#Define STR0115 "Marca��es Desconsideradas"
#Define STR0116 "Hora da marca��o"
#Define STR0117 "Motivo"
#Define STR0118 "Legenda das marca��es: O: Original, I: inclu�da, P:Pr�-assinalada"

/*Fonte padr�o correspondente ao Rdmake IMPESP.PRX; Altera��es realizadas neste fonte devem ser compatibilizadas tamb�m no Rdmake.*/

/*
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������Ŀ��
���Fun��o    � Vers�o 1 � Autor � Equipe Advanded RH              � Data � 07.04.96 ���
���          � Vers�o 2 � Autor � Leandro Drumond                 � Data � 17.03.15 ���
�����������������������������������������������������������������������������������Ĵ��
���Descri��o � Espelho do Ponto                                                     ���
�����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � PONR010(void)                                                        ���
�����������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                      ���
�����������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                             ���
�����������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                       ���
�����������������������������������������������������������������������������������Ĵ��
���Programador �    Data   �     FNC     �  Motivo da Alteracao                     ���
�����������������������������������������������������������������������������������Ĵ��
���Leandro Dr. �17/03/2015 �      		 �Convers�o para FWMSPRINTER.               ���
���Luis Artuso �16/06/2015 �       TSADU0�Ajuste na chamada da rotina DescAbono em  ���
���            �           �      		 �fTotaliza para enviar a filial do funcio- ���
���            �           �      		 �nario quando o modo de compartilhamento da���
���            �           �      		 �tabela SP6 estiver exclusivo.             ���
���Leandro Dr. �22/07/2015 �      TSWKZ1 �Inclus�o de totalizador de banco de horas.���
���Luis Artuso �06/10/2015 �      TTIRVP �Ajuste para corrigir o totalizador de ho- ���
���            �           �      		 �ras extras, para informar corretamente o  ���
���            �           �      		 �valor das horas informadas.               ���
���Luis Artuso �26/10/2015 �       TTRDY0�Ajuste para corrigir a exibicao de horas  ���
���            �           �      		 �no formato Centesimal/Sexagenal.          ���
���Renan Borges�29/11/2015 �       TTXSEM�Ajuste para imprimir saldo anterior e sal-���
���            �           �             �do atual do Banco de Horas no Espelho de  ���
���            �           �             �Ponto gr�fico corretamente.               ���
���            �           �             �Ajuste para gerar horas do banco de horas ���
���            �           �             �respeitando o parametro "Horas em?" que   ���
���            �           �             �diz se � Centesimal ou Sexagenal.         ���
���            �           �             �Ajuste para quando nome da empresa possuir���
���            �           �             �50 caracteres n�o seja impresso o CNPJ em ���
���            �           �             �cima do nome da empresa.                  ���
���            �           �             �Ajuste para imprimir o espelho de ponto   ���
���            �           �             �corretamente, ajustando os valores impres-���
���            �           �             �sos nas colunas de Absenteismo e Horas Ex-���
���            �           �             �tras, por serem horas n�o utilizam a para-���
���            �           �             �metriza��o de Sexagenal/Centesimal, apenas���
���            �           �             �valores (Totais/Banco de Horas) utilizam  ���
���            �           �             �essa parametriza��o. ajustando a impress�o���
���            �           �             �dos turnos quando h� troca de turnos, para���
���            �           �             �n�o encavalar e sendo impresso as informa-���
���            �           �             ���es de observa��o na coluna correta de   ���
���            �           �             �Observa��o, como era realizado no espelho ���
���            �           �             �de ponto antigo.                          ���
���Renan Borges�17/02/2016 �       TUEMC7�Ajuste para gerar horas do banco de horas ���
���            �           �             �respeitando o parametro "Horas em?" que   ���
���            �           �             �diz se � Centesimal ou Sexagenal.         ���
���Renan Borges�21/03/2016 �       TURWDO�Ajuste para que descri��o de departamento ���
���            �           �      		 �n�o sejam impressa sobreposta com o turno.���
���Renan Borges�13/05/2016 �       TUXRXC�Ajuste para imprimir horas de absente�smo ���
���            �           �      		 �corretamente.                             ���
���Matheus M.  �10/08/2016 �       TVMTGF�Ajuste para exibir o item Descri��o da    ���
���            �           �      		 �categoria.                                ���
���M. Silveira �09/02/2017 �     MRH-6012�Incluida a funcao Pnr010Afas para fazer a ���
���            �           �             �impressao da situacao no cabecalho.       ���
���Eduardo K.  �16/02/2017 �MPRIMESP-9116�Ajuste na impress�o de informa��es geradas���
���            �           �      		 �sobrepostas.		                        ���
���M. Silveira �31/03/2017 �     MRH-9208�Ajuste na avaliacao dos afastamentos na   ���
���            �           �             �Pnr010Afas p/ considerar somente aqueles  ���
���            �           �             �que estao dentro do periodo do ponto.     ���
���Renan Borges�03/04/2017 �     MRH-9141�Ajuste para mostrar Centro de Custo corre-���
���            �           �             �tamente do per�odo de impress�o do espelho���
���            �           �             �do ponto.                                 ���
���Renan Borges�09/05/2017 � DRHPONTP-287�Melhoria para que a rotina de listagem de ���
���            �           �             �marca��es na portal apresente as marca��es���
���            �           �             �quando informado no par�metro MV_COLMARC  ���
���            �           �             �mais que 6 conjutos de marca��es.         ���
���Renan Borges�05/07/2017 � DRHPONTP-903�Ajuste para trazer a observa��o de afasta-���
���            �           �             �mento sem ultrapassar a borda do relat�rio���
���Isabel N.   �18/07/2017 �DRHPONTP-1120�Ajuste no cabecalho p/ exibir CPF, CNPJ ou���
���            �           �             �CEI da empresa conforme definido pelo CFG;���
���            �           �             �Ajuste p/quebra de p�g. ao imprimir totais���
���            �           �             �de banco de horas quando necess�rio.      ���
������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������*/
User Function xPonr010( lTerminal, cFilTerminal, cMatTerminal, cPerAponta, lPortal, aRetPortal, lMeuRH, cFileName, cPathCustom, aProcFun, aResult)

Local aArea		 := GetArea()
Local cHtml		 := ""
Local cAviso
Local aFilesOpen := {"SP5", "SPN", "SP8", "SPG","SPB","SPL","SPC", "SPH", "SPF"}
Local bCloseFiles:= {|cFiles| If( Select(cFiles) > 0, (cFiles)->( DbCloseArea() ), NIL) }
Local lNoWeb	 := .T.
Private lTAE	 := .F. // Vari�vel que define se envia para o TAE
Private oSign	 := Nil
Private aLogTAE     := Array(2)
Private aLogTitle   := Array(2)

// Define Variaveis Private(Basicas)
Private nomeprog := 'PONR010'
Private nLastKey := 0
Private cPerg    := 'PNR010'
Private oPrinter

// Define variaveis Private utilizadas no programa RDMAKE ImpEsp
Private aImp      := {}
Private aTotais   := {}
Private aAbonados := {}
Private aAfast    := {}
Private nImpHrs   := 0

// Variaveis Utilizadas na funcao IMPR
Private Titulo   := OemToAnsi(STR0001 ) // 'Espelho do Ponto'

// Define Variaveis Private(Programa)
Private dPerIni  := Ctod("//")
Private dPerFim  := Ctod("//")
Private cMenPad1 := Space(30)
Private cMenPad2 := Space(19)
Private cLocal	 := ""
Private cFilSPA	 := xFilial("SPA", SRA->RA_FILIAL)
Private nOrdem   := 1
Private aInfo    := {}
Private aTurnos  := {}
Private aPrtTurn := {}
Private nColunas := 0
Private aNaES	 := {}
Private nCol	 := 0
Private nColTot	 := 0
Private nLinTot	 := 0
Private aMargRel := {}
Private nLin	 := 0
Private nPxData	 :=	0
Private nPxSemana:= 0
Private nPxAbonos:= 0
Private nPxHe	 := 0
Private nPxHrVal := 0
Private nPxJor	 := 0
Private nPxFalta := 0
Private nPxAdnNot:= 0
Private nPxObser := 0
Private lImpMarc := .T.
Private lImpHrVal:= .F.
Private lCodeBar := .F.
Private lBigLine := .T.
Private nTamRAMAT := TamSx3("RA_MAT")[1]
Private lPort671 := SuperGetMV("MV_PORT671",, .F.)
//Objeto de Impress�o
Private oPrintPvt



/*
	 Vari�vel usada para controlar os totalizadores status normais [1] e ausentes [2]
*/

Private aResultado := {0, 0}
Default cPathCustom := ""

DEFAULT lTerminal := .F.
DEFAULT lMeuRH    := .F.
DEFAULT aProcFun  := {}

#DEFINE Imp_Spool      	2
#DEFINE ALIGN_H_LEFT   	0
#DEFINE ALIGN_H_RIGHT  	1
#DEFINE ALIGN_H_CENTER 	2
#DEFINE ALIGN_V_CENTER 	0
#DEFINE ALIGN_V_TOP	   	1
#DEFINE ALIGN_V_BOTTON 	2
#DEFINE oFontT 			TFont():New( "Verdana", 09, 09, , .T., , , , .T., .F. )//Titulo
#DEFINE oFontP 			TFont():New( "Verdana", 09, 09, , .T., , , , .T., .F. )//Linhas
#DEFINE oFontM 			TFont():New( "Verdana", 07, 07, , .F., , , , .T., .F. )//Marcacoes
#DEFINE oFontO 			TFont():New( "Verdana", 04, 04, , .F., , , , .T., .F. )//Marcacoes
#DEFINE oFont06 		TFont():New( "Verdana", 06, 06, , .T., , , , .T., .F. )//CodeBar

aFill(aLogTitle, "")
aLogTAE[1] := {}
aLogTAE[2] := {}

lPortal   := IF( lPortal == NIL , .F. , lPortal )
lNoWeb    := !lTerminal .And. !lMeuRH

// Par�metro MV_COLMARC
IF lPortal .OR. fValMVCOL() == .T.
	nColunas := 4 /*SuperGetmv("MV_COLMARC")*/ //- Customizado para ignorar o MV_COLMARC
Else
	Help("", 1,OemToAnsi( STR0086 ),,OemToAnsi( STR0080 ),1,0)//"Para esse relat�rio o parametro MV_COLMARC deve ser menor ou igual � 5."
Return( .F. )
ENDIF

If ( nColunas == NIL )
	Help("", 1, "MVCOLNCAD")
Return( .F. )
EndIf

// O numero de colunas eh sempre aos pares
nColunas *= 2

// Chamada da fun��o para criar o objeto FWMSPrinter
SetUpPrint(@oPrinter, lTerminal, lMeuRH, cFileName, cPathCustom)

// Cancelar a impress�o
If !lTerminal .And. oPrinter == NIL
Return
EndIf

// Verifica as perguntas selecionadas
Pergunte( cPerg, .F. )

// Carregando variaveis MV_PAR?? para Variaveis do Sistema.
FilialDe	:= IF( lNoWeb , MV_PAR01, cFilTerminal )			//Filial  De
FilialAte	:= IF( lNoWeb , MV_PAR02, cFilTerminal )			//Filial  Ate
CcDe		:= IF( lNoWeb , MV_PAR03, SRA->RA_CC   )			//Centro de Custo De
CcAte		:= IF( lNoWeb , MV_PAR04, SRA->RA_CC   )			//Centro de Custo Ate
TurDe		:= IF( lNoWeb , MV_PAR05, SRA->RA_TNOTRAB)			//Turno De
TurAte		:= IF( lNoWeb , MV_PAR06, SRA->RA_TNOTRAB)			//Turno Ate
MatDe		:= IF( lNoWeb , MV_PAR07, cMatTerminal)				//Matricula De
MatAte		:= IF( lNoWeb , MV_PAR08, cMatTerminal)				//Matricula Ate
NomDe		:= IF( lNoWeb , MV_PAR09, SRA->RA_NOME)				//Nome De
NomAte		:= IF( lNoWeb , MV_PAR10, SRA->RA_NOME)				//Nome Ate
cSit		:= IF( lNoWeb , MV_PAR11, fSituacao( NIL , .F. ))	//Situacao
cCat		:= IF( lNoWeb , MV_PAR12, fCategoria( NIL , .F. ))	//Categoria
nImpHrs		:= IF( lNoWeb , MV_PAR13, 3 )						//Imprimir horas Calculadas/Inform/Ambas/NA
nImpAut		:= IF( lNoWeb , MV_PAR14, 1 )						//Demonstrar horas Autoriz/Nao Autorizadas
nCopias		:= IF( lNoWeb , If(MV_PAR15>0,MV_PAR15,1),1)		//N�mero de C�pias
lSemMarc	:= IF( lNoWeb , (MV_PAR16==1), IIF(lPortal .Or. lMeuRH,.T.,.F.) )//Imprime para Funcion�rios sem Marca�oes
cMenPad1	:= IF( lNoWeb , MV_PAR17, "" )						//Mensagem padr�o anterior a Assinatura
cMenPad2	:= IF( lNoWeb , MV_PAR18, "" )						//Mens. padr�o anterior a Assinatura(Cont.)
dPerIni     := IF( lNoWeb , MV_PAR19, Stod(Subst(cPerAponta, 1, 8)) )	//Data Contendo o Inicio do Periodo de Apontamento
dPerFim     := IF( lNoWeb , MV_PAR20, sToD(SubStr(cPerAponta, At('/', cPerAponta) + 1)) )	//Data Contendo o Fim  do Periodo de Apontamento
lSexagenal	:= IF( lNoWeb , (MV_PAR21==1), .T.  )				//Horas em  (Sexagenal/Centesimal)
lImpRes		:= IF( lNoWeb , (MV_PAR22==1), .F.	)				//Imprime eventos a partir do resultado ?
lImpTroca   := IF( lNoWeb , (MV_PAR23==1), .F.	)				//Imprime Descricao Troca de Turnos ou o Atual
lImpExcecao := IF( lNoWeb , (MV_PAR24==1), .F.	)				//Imprime Descricao da Excecao no Lugar da do Afastamento
DeptoDe		:= IF( lNoWeb , MV_PAR25, SRA->RA_DEPTO   )			//Departamento De
DeptoAte	:= IF( lNoWeb , MV_PAR26, SRA->RA_DEPTO   )			//Departamento Ate
lImpMarc 	:= IF( lNoWeb , MV_PAR27==1, .T.   )		 		//Imprime marca��es? .T.
lCodeBar 	:= IF( lNoWeb , MV_PAR28==1, .F.   ) 				//Imprime c�digo de barras? .F.
lBigLine 	:= IF( lNoWeb , MV_PAR29==1, .T.   ) 				//Destaca linhas? .T.
lImpBh 		:= IF( lNoWeb , MV_PAR30==1, If( lMeuRH,.T.,.F. ) )	//Imprime banco de horas
RegDe		:= IF( lNoWeb , MV_PAR31, SRA->RA_REGRA)			//Regra De
RegAte		:= IF( lNoWeb , MV_PAR32, SRA->RA_REGRA)			//Regra Ate


If Type("MV_PAR33") == "N"
	lImpHrVal 	:= IF( lNoWeb , MV_PAR33 == 1, .T.)		 		//Imprime Horas Valorizadas?
EndIf


If Type("MV_PAR34") == "N"
	lTAE := If( lNoWeb, MV_PAR34 == 1, .F.)		 				//Integra��o totvs assinatura eletr�nica
EndIf

If lTAE .And. !SetUpSign(@oSign)
Return .F.
EndIf

// Redefine o Tamanho das Mensagens Padroes
cMenpad1 := IF(Empty( cMenPad1 ) , Space( 30 ) , cMenPad1 )
cMenpad2 := IF(Empty( cMenPad2 ) , Space( 19 ) , cMenPad2 )

//Atilio, 30/12/2021, conforme alinhado, foi alterado a database para ser a data at�
//   para que o relat�rio n�o saia vazio (pdf em branco)
dDataBase := dPerFim

Begin Sequence

	If ( lTerminal .Or. lMeuRH)
		//-- Verifica se foi possivel abrir os arquivos sem exclusividade
		If Pn090Open(@cHtml, @cAviso)
			cHtml := ""
			cHtml := Pnr010Imp( NIL , lTerminal, lPortal, aRetPortal, oPrinter, lMeuRH, cFileName, cPathCustom, aProcFun )
			/*
			��������������������������������������������������������������Ŀ
			� Apos a obtencao da consulta solicitada fecha os arquivos     �
			� utilizados no fechamento mensal para abertura exclusiva      �
			����������������������������������������������������������������*/
			Aeval(aFilesOpen, bCloseFiles)
		Else
		cHtml := HtmlDefault( cAviso , cHtml )
		Endif
	ElseIf !( nLastKey == 27 )

		If Pn090Open(@cHtml, @cAviso)

			If Empty( dPerIni ) .or. Empty( dPerFim )
				Help(" ",1,"PONFORAPER" , , OemToAnsi( STR0039 ) , 5 , 0  )	//'Periodo de Apontamento Invalido.'
				Break
			EndIf

			If !( nLastKey == 27 )

				RptStatus( { |lEnd| Pnr010Imp(@lEnd, lTerminal, ,,oPrinter ) } , Titulo )

			EndIf
		Else
			MsgStop( cHtml, cAviso )
			cHtml := ""
		EndIf

	EndIf

End Sequence

If !lTAE .And. !lTerminal .And. !lMeuRH
	oPrinter:Preview()
EndIf

If lTAE
	MsAguarde( { || fMakeLog( aLogTAE, aLogTitle, cPerg, , "PONR010", STR0101 )}, STR0101 ) //"Log de ocorr�ncias na integra��o com TAE"
EndIf

aResult := aClone(aResultado)

RestArea(aArea)
Return( cHtml )

/*/{Protheus.doc} SetUpPrint
Instacia a classe FWMSPrinter e realiza as configura��es para impress�o do relat�rio
@type  Static Function
@author C�cero Alves
@since 24/01/2022
@param oPrinter, Objeto, Inst�ncia da classe FWMSPrinter - deve ser passado por refer�ncia
@param lTerminal, L�gico, Define se a rotina est� sendo executada sem interface - Portal
@param lMeuRH, L�gico, Indica se a chamada da rotina foi realizada pelo Meu RH
@param cFileName, Caracter, Nome do arquivo que ser� gerado
/*/
Static Function SetUpPrint(oPrinter, lTerminal, lMeuRH, cFileName, cPathCustom)

	Local cSession	 := GetPrinterSession()
	Local cDestino	 := fwGetProfString(cSession, "DEFAULT", "c:\", .T.)
	Local cDevice    := fwGetProfString(cSession, "PRINTTYPE", "PDF", .T.)
	Local aMargProf	 := {}
	Local nFlags   	 := PD_ISTOTVSPRINTER +  PD_DISABLEORIENTATION
	Local oSetup
	Local aOrdem     := {STR0004 , STR0005 , STR0006 , STR0007, STR0038, STR0060, STR0061  } // 'Matricula'###'Centro de Custo'###'Nome'###'Turno'###'C.Custo + Nome'###'Departamento'###'Departamento + Nome'
	Local cFile		 := ""
	Local lContinua  := .F.
	Static cPathTmp	 := GetTempPath(.F.)



	

			lContinua := .T.
			
			If lContinua
			//alert("continuando relatorio")

			 

				// Envia controle para a funcao SETPRINT
				If !lTAE .and. !lTerminal .And. !lMeuRH
					aDevice := {}

					// Define os Tipos de Impressao validos
					AADD(aDevice,"DISCO")
					AADD(aDevice,"SPOOL")
					AADD(aDevice,"EMAIL")
					AADD(aDevice,"EXCEL")
					AADD(aDevice,"HTML" )
					AADD(aDevice,"PDF"  )

					// Realiza as configuracoes necessarias para a impressao
					nPrintType := aScan(aDevice,{|x| x == cDevice })
					nLocal     := If( fWGetProfString( cSession, "LOCAL", "SERVER", .T. ) == "SERVER", 1, 2 )

					aMargProf := {fwGetProfString(cSession,"MARG1","10",.T.),fwGetProfString(cSession,"MARG2","10",.T.),fwGetProfString(cSession,"MARG3","10",.T.),fwGetProfString(cSession,"MARG4","10",.T.) }

					oSetup := FWPrintSetup():New(nFlags, Titulo)
					oSetup:SetUserParms( {|| Pergunte(cPerg, .T.) } )
					oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
					oSetup:SetPropert(PD_ORIENTATION , 2)
					oSetup:SetPropert(PD_DESTINATION , nLocal)
					oSetup:SetPropert(PD_MARGIN      , {Val(aMargProf[1]),Val(aMargProf[2]),Val(aMargProf[3]),Val(aMargProf[4])})
					oSetup:SetPropert(PD_PAPERSIZE   , 2)
					oSetup:SetPropert(PD_PREVIEW,.T.)
					oSetup:SetOrderParms(aOrdem,@nOrdem)

					If cDevice == "PDF"
						oSetup:aOptions[PD_VALUETYPE] := cDestino
					EndIf

					oPrinter := FWMSPrinter():New( 'PONR010', IMP_PDF , .F., , .T., , oSetup )

					If !(oSetup:Activate() == PD_OK)
						oPrinter:Deactivate()
						oPrinter := NIL
						Return
					EndIf

					oPrinter:lServer := oSetup:GetProperty( PD_DESTINATION ) == AMB_SERVER
					oPrinter:SetResolution( 75 )

					If oSetup:GetProperty( PD_ORIENTATION ) == 2
						oPrinter:SetLandscape()
					Else
						oPrinter:SetPortrait()
					EndIf

					oPrinter:SetPaperSize( oSetup:GetProperty( PD_PAPERSIZE ) )
					oPrinter:SetMargin(oSetup:GetProperty( PD_MARGIN )[1],oSetup:GetProperty( PD_MARGIN )[2],oSetup:GetProperty( PD_MARGIN )[3],oSetup:GetProperty( PD_MARGIN )[4])
					aMargRel := {oSetup:GetProperty( PD_MARGIN )[1],oSetup:GetProperty( PD_MARGIN )[2],oSetup:GetProperty( PD_MARGIN )[3],oSetup:GetProperty( PD_MARGIN )[4]}

					fwWriteProfString(cSession,"LOCAL", If(oSetup:GetProperty(PD_DESTINATION)==1,"SERVER","LOCAL"), .T.)
					fwWriteProfString(cSession,"PRINTTYPE", aDevice[oSetup:GetProperty( PD_PRINTTYPE )], .T.)
					fwWriteProfString(cSession,"MARG1", alltrim(str(aMargRel[1])), .T.)
					fwWriteProfString(cSession,"MARG2", alltrim(str(aMargRel[2])), .T.)
					fwWriteProfString(cSession,"MARG3", alltrim(str(aMargRel[3])), .T.)
					fwWriteProfString(cSession,"MARG4", alltrim(str(aMargRel[4])), .T.)

					If oSetup:GetProperty( PD_PRINTTYPE ) == Imp_Spool

						oPrinter:nDevice := Imp_Spool
						fwWriteProfString(cSession,"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
						oPrinter:cPrinter := oSetup:aOptions[PD_VALUETYPE]

					ElseIf oSetup:GetProperty( PD_PRINTTYPE ) == IMP_PDF

						oPrinter:nDevice := IMP_PDF
						fwWriteProfString(cSession,"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
						oPrinter:cPathPDF := oSetup:aOptions[PD_VALUETYPE]

					EndIf
				
				
				
				
					//ja entra sem precisar do box das valida�oes

				ElseIf lMeuRH .Or. lTAE
					aMargRel := {10,10,10,10}
					cFile    := cFileName
					cLocal	 := SuperGetMV("MV_RELT", .F., "\spool\") + "espelho_ponto\" // 21/04/2022, mudando a pasta default para gerar o relat�rio
					If lTAE
						oPrinter := FWMSPrinter():New( cFileName, IMP_PDF, .F., cPathTmp, .T., , , , , , , .F. )
						oPrinter:nDevice := IMP_PDF
						fwWriteProfString(cSession, "DEFAULT", cPathTmp, .T.)
						oPrinter:cPathPDF := cPathTmp

						//Se veio da rotina que gera holerite e ponto, muda a pasta
					ElseIf FWIsInCallStack("U_SPJURM01")
						oPrinter	:= FWMSPrinter():New( cFileName, 6,.F.,iif(!Empty(cPathCustom),cPathCustom,cPathTmp),.T.,,,,.T.,.F.)
					Else
						oPrinter := FWMSPrinter():New( cFile+".rel", IMP_PDF, .F., cLocal, .T., , , , .T., , .F., )
					EndIf

					oPrinter:SetResolution( 75 )
					oPrinter:SetLandscape()
					oPrinter:SetMargin(10,10,10,10)
					oPrinter:SetPaperSize( 1 )
					
					 //Iniciando P�gina
                    oPrinter:StartPage()
     
/*     //Cabe�alho
   cTexto := "Rela��o de Grupos de Produtos"
    oPrinter:SayAlign(725,70,725,500) */
   
   
                //Mostrando o relat�rio
					//oPrinter:Preview()

					
				EndIf

			EndIf
			Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � POR010Imp� Autor � EQUIPE DE RH          � Data � 07.04.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Espelho do Ponto                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Pnr010Imp(lEnd)					                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd        - A��o do Codelock                             ���
���          � cString     - Mensagem                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Pnr010Imp( lEnd , lTerminal, lPortal, aRetPortal, oPrinter, lMeuRH, cFileName, cPathCustom, aProcFun )

Local aAbonosPer	:= {}
Local cOrdem		:= ""
Local cWhere		:= ""
Local cSituacao		:= ""
Local cCategoria	:= ""
Local cLastFil		:= "__cLastFil__"
Local cAcessaSRA	:= &("{ || " + ChkRH("PONR010","SRA","2") + "}")
Local cSeq			:= ""
Local cTurno		:= ""
Local cHtml			:= ""
Local cAliasSRA		:= "SRAPONR010"
Local cAliasQTD		:= "QTDPONR010"
Local lSPJExclu		:= !Empty( xFilial("SPJ") )
Local lSP9Exclu		:= !Empty( xFilial("SP9") )
Local nCount		:= 0.00
Local nX			:= 0.00
Local nY			:= 0
Local lMvAbosEve	:= .F.
Local lMvSubAbAp	:= .F.
Local cFile			:= ""
Local cPathFile		:= ""
//Local lOk			:= .F.
Local lPrinter		:= .F.
//- Utilizadas apenas para valida��o do looping
Local nAtual 		:= 0
Local nTotal 		:= 0



			Private aFuncFunc  := {SPACE(1), SPACE(1), SPACE(1), SPACE(1), SPACE(1), SPACE(1)}
			Private aMarcacoes := {}
			Private aMarcDes   := {}
			Private aTabPadrao := {}
			Private aTabCalend := {}
			Private aPeriodos  := {}
			Private aId		   := {}
			Private aResult	   := {}
			Private aBoxSPC	   := LoadX3Box("PC_TPMARCA")
			Private aBoxSPH	   := LoadX3Box("PH_TPMARCA")
			Private cCodeBar   := ""
			Private dIniCale   := Ctod("//")	//-- Data Inicial a considerar para o Calendario
			Private dFimCale   := Ctod("//")	//-- Data Final a considerar para o calendario
			Private dMarcIni   := Ctod("//")	//-- Data Inicial a Considerar para Recuperar as Marcacoes
			Private dMarcFim   := Ctod("//")	//-- Data Final a Considerar para Recuperar as Marcacoes
			Private dIniPonMes := Ctod("//")	//-- Data Inicial do Periodo em Aberto
			Private dFimPonMes := Ctod("//")	//-- Data Final do Periodo em Aberto
			Private lImpAcum   := .F.
			Private aCodAut	:= {}

/*
��������������������������������������������������������������Ŀ
�Como a Cada Periodo Lido reinicializamos as Datas Inicial e Fi�
�nal preservamos-as nas variaveis: dCaleIni e dCaleFim.		   �
����������������������������������������������������������������*/
dIniCale   := dPerIni   //-- Data Inicial a considerar para o Calendario
dFimCale   := dPerFim   //-- Data Final a considerar para o calendario

For nX:=1 to Len(cSit)
	If Subs(cSit,nX,1) <> "*"
		cSituacao += "'"+Subs(cSit,nX,1)+"'"
		If ( nX+1 ) <= Len(cSit)
			cSituacao += ","
		EndIf
	EndIf
Next nX

If !Empty(cSituacao) .and. Subs(cSituacao,Len(cSituacao),1) == ","
	cSituacao := Subs(cSituacao,1,Len(cSituacao)-1)
EndIf

For nX:=1 to Len(cCat)
	If Subs(cCat,nX,1) <> "*"
		cCategoria += "'"+Subs(cCat,nX,1)+"'"
		If ( nX+1 ) <= Len(cCat)
			cCategoria += ","
		EndIf
	EndIf
Next nX

If !Empty(cCategoria) .and. Subs(cCategoria,Len(cCategoria),1) == ","
	cCategoria := Subs(cCategoria,1,Len(cCategoria)-1)
EndIf

/*
��������������������������������������������������������������Ŀ
�Inicializa Variaveis Static								   �
����������������������������������������������������������������*/
( CarExtAut() , RstGetTabExtra() )

//--Seleciona funcion�rios de acordo com filtros
cWhere += "%"
If !lMeuRH .Or. (lMeuRH .And. Empty(aProcFun))
	cWhere += "SRA.RA_FILIAL >= '" + FilialDe + "' AND "
	cWhere += "SRA.RA_FILIAL <= '" + FilialAte + "' AND "
	cWhere += "SRA.RA_CC >= '" + CCDe + "' AND "
	cWhere += "SRA.RA_CC <= '" + CCAte + "' AND "
	cWhere += "SRA.RA_TNOTRAB >= '" + TurDe + "' AND "
	cWhere += "SRA.RA_TNOTRAB <= '" + TurAte + "' AND "
	cWhere += "SRA.RA_MAT >= '" + MatDe + "' AND "
	cWhere += "SRA.RA_MAT <= '" + MatAte + "' AND "
	cWhere += "SRA.RA_NOME >= '" + NomDe + "' AND "
	cWhere += "SRA.RA_NOME <= '" + NomAte + "' AND "
	If !Empty(RegAte)
		cWhere += "SRA.RA_REGRA >= '" + RegDe + "' AND "
		cWhere += "SRA.RA_REGRA <= '" + RegAte + "' AND "
	EndIf
	cWhere += "SRA.RA_DEPTO >= '" + DeptoDe + "' AND "
	cWhere += "SRA.RA_DEPTO <= '" + DeptoAte + "'"
Else
	For nY := 1 To Len(aProcFun)
		cWhere += If( nY > 1, " OR ", "" )
		cWhere += "(SRA.RA_FILIAL ='" + aProcFun[nY, 1] + "' AND SRA.RA_MAT = '" + aProcFun[nY, 2] + "')"
	Next nY
EndIf
If !Empty( cSituacao )
	cWhere += " AND SRA.RA_SITFOLH IN ( " + cSituacao + ") "
EndIf
If !Empty(cCategoria)
	cWhere += " AND SRA.RA_CATFUNC IN ( " + cCategoria + ") "
EndIf
cWhere += " AND SRA.D_E_L_E_T_ = ' ' "
cWhere += "%"

//'Matricula'###'Centro de Custo'###'Nome'###'Turno'###'C.Custo + Nome'###'Departamento'###'Departamento + Nome'
If ( ( nOrdem == 1 ) .or. ( lTerminal .Or. lMeuRH ) )
	cOrdem := "%SRA.RA_FILIAL, SRA.RA_MAT%"
ElseIf ( nOrdem == 2 )
	cOrdem := "%SRA.RA_FILIAL, SRA.RA_CC%"
ElseIf ( nOrdem == 3 )
	cOrdem := "%SRA.RA_FILIAL, SRA.RA_NOME, SRA.RA_MAT%"
ElseIf ( nOrdem == 4 )
	cOrdem := "%SRA.RA_FILIAL, SRA.RA_TNOTRAB%"
ElseIf ( nOrdem == 5 )
	cOrdem := "%SRA.RA_FILIAL, SRA.RA_CC, SRA.RA_NOME%"
ElseIf ( nOrdem == 6 )
	cOrdem := "%SRA.RA_FILIAL, SRA.RA_DEPTO, SRA.RA_MAT%"
ElseIf ( nOrdem == 7 )
	cOrdem := "%SRA.RA_FILIAL, SRA.RA_DEPTO, SRA.RA_NOME%"
EndIf

//Monta o Where customizado com o filtro de supervisor e regi�o
cWhereCust := "%1 = 1%"
/*cWhereCust := "% SRA.RA_CAMPO = 'aaaa'%"*/

BeginSql Alias cAliasSRA

 	SELECT SRA.RA_FILIAL, SRA.RA_MAT
	FROM
		%Table:SRA% SRA
	WHERE %Exp:cWhere%
	AND %Exp:cWhereCust%
	ORDER BY %Exp:cOrdem%

EndSql

/*
��������������������������������������������������������������Ŀ
�Inicializa R�gua de Impress�o								   �
����������������������������������������������������������������*/
	BeginSql Alias cAliasQTD

	 	SELECT Count(*) AS QTDREG
		FROM
			%Table:SRA% SRA
		WHERE %Exp:cWhere%
		AND %Exp:cWhereCust%
	EndSql

	If !lTerminal .And. !lMeuRH
		SetRegua( (cAliasQTD)->QTDREG )
	EndIf
	nTotal := (cAliasQTD)->QTDREG
	(cAliasQTD)->(DbCloseArea())

If lCodeBar .Or. lTAE
	DbSelectArea("RS4")
	RS4->(DbSetOrder(1))
EndIf

dbSelectArea('SRA')
SRA->( dbSetOrder( 1 ) )

/*
��������������������������������������������������������������Ŀ
�Processa o Cadastro de Funcionarios						   �
����������������������������������������������������������������*/
While (cAliasSRA)->( !Eof() )
	nAtual++ //- Contagem apenas para debug de loop

	//Posiciona no funcion�rio atual
	//SRA->(DbSeek((cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT)) //-- 2023-07-18, Linha comentada pois ao inv�s de posicionar estava desposicionando

	lPrinter := .F.

	/*
	��������������������������������������������������������������Ŀ
	�So Faz Validacoes Quando nao for Terminal					   �
	����������������������������������������������������������������*/
	If !lTerminal .And. !lMeuRH

		/*
		��������������������������������������������������������������Ŀ
		�Incrementa a R�gua de Impress�o							   �
		����������������������������������������������������������������*/
		IncRegua()

		/*
		��������������������������������������������������������������Ŀ
		�Cancela a Impress�o 										   �
		����������������������������������������������������������������*/
		If ( lEnd )
			Exit
		EndIf

		/*
		��������������������������������������������������������������Ŀ
		� Consiste controle de acessos e filiais validas               �
		����������������������������������������������������������������*/
		If SRA->( !( RA_FILIAL $ fValidFil() ) .or. !Eval( cAcessaSRA ) )
			(cAliasSRA)->( dbSkip() )
			Loop
		EndIf

		/*
		��������������������������������������������������������������Ŀ
		�Consiste a data de Demiss�o								   �
		�Se o Funcionario Foi Demitido Anteriormente ao Inicio do Perio�
		�do Solicitado Desconsidera-o								   �
		����������������������������������������������������������������*/
		If !Empty(SRA->RA_DEMISSA) .and. ( SRA->RA_DEMISSA < dIniCale )
			(cAliasSRA)->( dbSkip() )
			Loop
		EndIf

	EndIf

    /*
	�������������������������������������������������������������Ŀ
	� Verifica a Troca de Filial           						  �
	���������������������������������������������������������������*/
	If !( SRA->RA_FILIAL == cLastFil )

		/*
		��������������������������������������������������������������Ŀ
		� Alimenta as variaveis com o conteudo dos MV_'S correspondetes�
		����������������������������������������������������������������*/
		lMvAbosEve	:= ( Upper(AllTrim(fGetParam("MV_ABOSEVE",NIL,"N",cLastFil))) == "S" )	//--Verifica se Deduz as horas abonadas das horas do evento Sem a necessidade de informa o Codigo do Evento no motivo de abono que abona horas
		lMvSubAbAp	:= ( Upper(AllTrim(fGetParam("MV_SUBABAP",NIL,"N",cLastFil))) == "S" )	//--Verifica se Quando Abono nao Abonar Horas e Possuir codigo de Evento, se devera Gera-lo em outro evento e abater suas horas das Horas Calculadas

	    /*
		�������������������������������������������������������������Ŀ
		� Atualiza a Filial Corrente           						  �
		���������������������������������������������������������������*/
		cLastFil := SRA->RA_FILIAL

	    /*
		�������������������������������������������������������������Ŀ
		� Carrega periodo de Apontamento Aberto						  �
		���������������������������������������������������������������*/
		/*
		If !CheckPonMes( @dPerIni , @dPerFim , .F. , .T. , .F. , cLastFil )
			Exit
		EndIf
		*/

    	/*
		�������������������������������������������������������������Ŀ
		� Obtem datas do Periodo em Aberto							  �
		���������������������������������������������������������������*/
		GetPonMesDat( @dIniPonMes , @dFimPonMes , cLastFil )

    	/*
		�������������������������������������������������������������Ŀ
		�Atualiza o Array de Informa��es sobre a Empresa.			  �
		���������������������������������������������������������������*/
		aInfo := {}
		fInfo( @aInfo , cLastFil )

	    /*
		�������������������������������������������������������������Ŀ
		� Carrega as Tabelas de Horario Padrao						  �
		���������������������������������������������������������������*/
		If ( lSPJExclu .or. Empty( aTabPadrao ) )
			aTabPadrao := {}
			fTabTurno( @aTabPadrao , If( lSPJExclu , cLastFil , NIL ),,, SRA->RA_TNOTRAB)
		EndIf

    	/*
		�������������������������������������������������������������Ŀ
		� Carrega TODOS os Eventos da Filial						  �
		���������������������������������������������������������������*/
		If ( Empty( aId ) .or. ( lSP9Exclu ) )
			aId := {}
			CarId( fFilFunc("SP9") , @aId , "*" )
		EndIf

		aCodAut := {}
		fTabSP4(@aCodAut,xFilial("SP4",cLastFil))

	EndIf

   	/*
	�������������������������������������������������������������Ŀ
	�Retorna Periodos de Apontamentos Selecionados				  �
	���������������������������������������������������������������*/
	If ( lTerminal .Or. lMeuRH )
		dPerIni	:= dIniCale
		dPerFim := dFimCale
	EndIf

	aPeriodos := Monta_per( dIniCale , dFimCale , cLastFil , SRA->RA_MAT , dPerIni , dPerFim )

   	/*
	�������������������������������������������������������������Ŀ
	�Corre Todos os Periodos 									  �
	���������������������������������������������������������������*/
	naPeriodos := Len( aPeriodos )
	For nX := 1 To naPeriodos

   		/*
		�������������������������������������������������������������Ŀ
		�Reinicializa as Datas Inicial e Final a cada Periodo Lido.	  �
		�Os Valores de dPerIni e dPerFim foram preservados nas   varia�
		�veis: dCaleIni e dCaleFim.									  �
		���������������������������������������������������������������*/
        dPerIni		:= aPeriodos[ nX , 1 ]
        dPerFim		:= aPeriodos[ nX , 2 ]

   		/*
		�������������������������������������������������������������Ŀ
		�Obtem as Datas para Recuperacao das Marcacoes				  �
		���������������������������������������������������������������*/
        dMarcIni	:= aPeriodos[ nX , 3 ]
        dMarcFim	:= aPeriodos[ nX , 4 ]

   		/*
		�������������������������������������������������������������Ŀ
		�Verifica se Impressao eh de Acumulado						  �
		���������������������������������������������������������������*/
		lImpAcum := ( dPerFim < dIniPonMes )

	    /*
		�������������������������������������������������������������Ŀ
		� Retorna Turno/Sequencia das Marca��es Acumuladas			  �
		���������������������������������������������������������������*/
		If ( lImpAcum )
			If SPF->( dbSeek( SRA->( RA_FILIAL + RA_MAT ) + Dtos( dPerIni) ) ) .and. !Empty(SPF->PF_SEQUEPA)
				cTurno	:= SPF->PF_TURNOPA
				cSeq	:= SPF->PF_SEQUEPA
			Else
	    		/*
				�������������������������������������������������������������Ŀ
				� Tenta Achar a Sequencia Inicial utilizando RetSeq()�
				���������������������������������������������������������������*/
				If !RetSeq(cSeq,@cTurno,dPerIni,dPerFim,dDataBase,aTabPadrao,@cSeq) .or. Empty( cSeq )
	    			/*
					�������������������������������������������������������������Ŀ
					�Tenta Achar a Sequencia Inicial utilizando fQualSeq()		  �
					���������������������������������������������������������������*/
					cSeq := fQualSeq( NIL , aTabPadrao , dPerIni , @cTurno )
				EndIf
			EndIf

			If ( Empty(cTurno) )
				SPF->( dbSeek( SRA->( RA_FILIAL + RA_MAT ) ) )
				Do While	SPF->(!EOF()) .AND.;
						 	( SRA->RA_FILIAL + SRA->RA_MAT == SPF->PF_FILIAL + SPF->PF_MAT )
					If ( SPF->PF_DATA >= dPerIni .AND. SPF->PF_DATA <= dPerFim )
						cTurno	:= SPF->PF_TURNOPA
						cSeq	:= SPF->PF_SEQUEPA
						Exit
					Else
						SPF->( dbSkip() )
					EndIf
				EndDo
			EndIf

		Else
   			/*
			�������������������������������������������������������������Ŀ
			�Considera a Sequencia e Turno do Cadastro            		  �
			���������������������������������������������������������������*/
			cTurno	:= SRA->RA_TNOTRAB
			cSeq	:= SRA->RA_SEQTURN
		EndIf

		/*
		�������������������������������������������������������������Ŀ
		�Obtem Codigo e Descricao da Funcao do Trabalhador na Epoca   �
		���������������������������������������������������������������*/
		//Limpa array a cada funcionario processado
		aFuncFunc  := {SPACE(1), SPACE(1), SPACE(1), SPACE(1), SPACE(1), SPACE(1)}
		fBuscaCC(dMarcFim, @aFuncFunc[1], @aFuncFunc[2], Nil, .F. , .T.  )
		aFuncFunc[2]:= Substr(aFuncFunc[2], 1, 25)
		fBuscaFunc(dMarcFim, @aFuncFunc[3], @aFuncFunc[4],@aFuncFunc[6],.T. )

		If Empty(aFuncFunc[6])
			aFuncFunc[6] := DescCateg(SRA->RA_CATFUNC , 25)
		EndIf

	    /*
		�������������������������������������������������������������Ŀ
		� Carrega Arrays com as Marca��es do Periodo (aMarcacoes), com�
		�o Calendario de Marca��es do Periodo (aTabCalend) e com    as�
		�Trocas de Turno do Funcionario (aTurnos)					  �
		���������������������������������������������������������������*/
		( aMarcacoes := {} , aTabCalend := {} , aTurnos := {} )

		If lImpMarc
		    /*
			�������������������������������������������������������������Ŀ
			� Importante: 												  �
			� O periodo fornecido abaixo para recuperar as marcacoes   cor�
			� respondente ao periodo de apontamentoo Calendario de 	 Marca�
			� ��es do Periodo ( aTabCalend ) e com  as Trocas de Turno  do�
			� Funcionario ( aTurnos ) integral afim de criar o  calendario�
			� com as ordens correspondentes as gravadas nas marcacoes	  �
			���������������������������������������������������������������*/
			If !GetMarcacoes(	@aMarcacoes					,;	//Marcacoes dos Funcionarios
								@aTabCalend					,;	//Calendario de Marcacoes
								@aTabPadrao					,;	//Tabela Padrao
								@aTurnos					,;	//Turnos de Trabalho
								dPerIni 					,;	//Periodo Inicial
								dPerFim						,;	//Periodo Final
								SRA->RA_FILIAL				,;	//Filial
								SRA->RA_MAT					,;	//Matricula
								cTurno						,;	//Turno
								cSeq						,;	//Sequencia de Turno
								SRA->RA_CC					,;	//Centro de Custo
								If(lImpAcum,"SPG","SP8")	,;	//Alias para Carga das Marcacoes
								NIL							,;	//Se carrega Recno em aMarcacoes
								.T.							,;	//Se considera Apenas Ordenadas
							    .T.    						,;	//Se Verifica as Folgas Automaticas
							  	.F.    			 			,;	//Se Grava Evento de Folga Automatica Periodo Anterior
								NIL							,;	//17 -> Se Carrega as Marcacoes Automaticas
								NIL							,;	//18 -> Registros de Marcacoes Automaticas que deverao ser Desprezadas
								NIL							,;	//19 -> Bloco para avaliar as Marcacoes Automaticas que deverao ser Desprezadas
								NIL							,;	//20 -> Se Considera o Periodo de Apontamento das Marcacoes
								NIL							,;	//21 -> Se Efetua o Sincronismo dos Horarios na Criacao do Calendario
								.T.							,;  //22 -> Se carrega as marcacoes desconsideradas (Uso com lPort1510)
								NIL							 ;  //23 -> Se carrega as marcacoes das duas tabelas SP8 e SPG
						 )

				Loop
			EndIf

			//Carrega as marca��es desconsideradas no aMarcDes e as exclu� do aMarcacoes
			GetMarcDes(@aMarcacoes, @aMarcDes)

		EndIf

	    aPrtTurn:={}
	    Aeval(aTurnos, {|x| If( x[2] >= dPerIni .AND. x[2]<= dPerFim, Aadd(aPrtTurn, x),Nil )} )

		//Reinicializa os Arrays
		( aTotais := {} , aAbonados := {} )
		aAfast := {}

	    //Carrega os Abonos Conforme Periodo.
		If 	lImpMarc
			fAbonosPer( @aAbonosPer , dPerIni , dPerFim , cLastFil , SRA->RA_MAT )
		EndIf

	    //Carrega os Totais de Horas e Abonos.
		If 	lImpMarc
			CarAboTot( @aTotais , @aAbonados , aAbonosPer, lMvAbosEve, lMvSubAbAp )
		EndIf

	    /*Carrega o Array a ser utilizado na Impressao.
		aPeriodos[nX,3] --> Inicio do Periodo para considerar as marcacoes e tabela
		aPeriodos[nX,4] --> Fim do Periodo para considerar as marcacoes e tabela */
		If ( !fMontaAimp( aTabCalend, aMarcacoes, @aImp,dMarcIni,dMarcFim, lTerminal, lImpAcum, lMeuRH) .and. !( lSemMarc ) )
			Loop
		EndIf

	    //Carrega a situacao e os afastamentos.
		Pnr010Afas( dMarcIni, dMarcFim, @aAfast )

		// Quando integra��o com o TAE verifica se o funcion�rio tem email no cadastro
		If lTAE .And. Empty(SRA->RA_EMAIL)
			// "E-mail n�o cadastrado. N�o foi enviado solicita��o de assinatura para o colaborador."
			aAdd(aLogTAE[2], SRA->RA_FILIAL + " - " + SRA->RA_MAT + ": " + STR0108 )

			If Empty(aLogTitle[1])
				aLogTitle[2] := STR0107 // "Espelhos de Ponto n�o enviados: "
			EndIf
			LOOP
		EndIf

		If lTAE .And. !lPrinter
			cFile := "PON_" + SRA->RA_FILIAL + SRA->RA_MAT + "_" + AnoMes(dMarcIni)
			SetUpPrint(@oPrinter, lTerminal, lMeuRH, cFile)
			lPrinter := .T.
		EndIf

	    //Imprime o Espelho para um Funcionario.
		For nCount := 1 To nCopias
			If !lTerminal .Or. lMeuRH
				oPrinter:StartPage()
				If lCodeBar
					cCodeBar := cEmpAnt + SRA->RA_FILIAL + PADL(alltrim(SRA->RA_MAT),nTamRAMAT,"0") + DtoS(dPerIni) + DtoS(dPerFim) + DtoS(dDataBase) + StrTran(Time(),":","")
				EndIf
				fImpFun( aImp , nColunas, ,oPrinter )
				If lCodeBar .And. !lTAE //Grava o c�digo de barras gerado na tabela RS4
					GravaSR4()
				EndIf
				oPrinter:EndPage()

			Else
				If lPortal
					aRetPortal  := aClone(aImp)
				Else
					cHtml := fImpFun( aImp , nColunas , lTerminal )
				EndIf
		    EndIf
		Next nCount

	    //Reinicializa Variaveis
		aImp      := {}
		aTotais   := {}
		aAbonados := {}

	Next nX

	// Integra��o TAE
	If lTAE .And. lPrinter
		cPathFile := oPrinter:cPathPDF + cFile + ".pdf"

		oPrinter:Preview()
		FreeObj(oPrinter)
		oPrinter := Nil

		// Faz upload do documento para o TAE
		SendEsp(cPathFile, cFile + ".pdf")

		// Exclui o arquivo
		If File(cPathFile)
			fErase(cPathFile)
		EndIf

	EndIf

    (cAliasSRA)->( dbSkip() )

EndDo

If lMeuRH .or. FWIsInCallStack("U_SPJURM01")
	cFilePrint := iif(!Empty(cPathCustom),cPathCustom,cLocal) + cFileName + ".pdf"
	oPrinter:cPathPDF:= iif(!Empty(cPathCustom),cPathCustom,cLocal)
	oPrinter:lViewPDF := .F.
	oPrinter:Print()
EndIf

(cAliasSRA)->(DbCloseArea())

Return( cHtml )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FImpFun   � Autor � J.Ricardo             � Data � 09/04/96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime o espelho do ponto do funcionario                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � POR010IMP                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fImpFun( aImp , nColunas , lTerminal, oPrinter , lMeuRH )

Local cHtml			:= ""
Local cOcorr		:= ""
Local cAbHora		:= ""
Local lZebrado		:= .F.
Local nX        	:= 0.00
Local nY        	:= 0.00
Local nColMarc  	:= 0.00
Local nTamLin   	:= 0.00
Local nMin			:= 0.00
Local nLenImp		:= 0.00
Local nLenImpnX		:= 0.00
Local nTamAuxlin	:= 0.00
Local nSaldoAnt		:= 0.00
Local nSaldoAtu		:= 0.00
Local nCredito		:= 0.00
Local nDebito		:= 0.00
Local nTotHrVal		:= 0.00
Local nAbHora		:= 0
Local nPosES		:= 0
Local nValAux		:= 0
Local nValHrV		:= 0
Local nValHrV2		:= 0
Local nContEve		:= 0
Local oBrushC	    := TBrush():New( ,  RGB(228, 228, 228)  )
Local oBrushI	    := TBrush():New( ,  RGB(242, 242, 242)  )
local lBrush		:= .F.
Local nPxTurno		:= 0

//-- Define o tamanho da linha com base no MV_ColMarc.
aEval(aImp, { |x| nColMarc := If(Len(x)-3>nColMarc, Len(x)-3, nColMarc) } )
nColMarc += If(nColMarc%2 == 0, 0, 1)

//-- Calcula a Maior das Qtdes de Colunas existentes
nColunas := Max(nColunas, nColMarc)
nColunas := iif(nColunas>8,8,nColunas) //- Customizado para ignorar o MV_COLMARC

//-- Define configura��es da impress�o
nTamAuxLin	:= 19+(nColunas*6)+50
nTamLin    	:= If(nTamAuxLin <= 80,80,If(nTamAuxLin<=132,132,220))

If lTerminal .And. !lMeuRH
	/*
	��������������������������������������������������������������Ŀ
	� Inicio da Estrutura do Codigo HTML						   �
	����������������������������������������������������������������*/
	cHtml += HtmlProcId() + CRLF
	cHtml += '<html>'  + CRLF
	cHtml += 	'<head>'  + CRLF
	cHtml += 		'<title>RH Online</title>'  + CRLF
	cHtml +=		'<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'  + CRLF
	cHtml +=		'<link rel="stylesheet" href="css/rhonline.css" type="text/css">'  + CRLF
	cHtml +=	'</head>'  + CRLF
	cHtml +=	'<body bgcolor="#FFFFFF" text="#000000">' + CRLF
	cHtml +=		'<table width="515" border="0" cellspacing="0" cellpadding="0">'  + CRLF
  	cHtml +=			'<tr>'  + CRLF
    cHtml +=				'<td class="titulo">'  + CRLF
    cHtml +=					'<p>' + CRLF
    cHtml +=						'<img src="'+TcfRetDirImg()+'/icone_titulo.gif" width="7" height="9">' + CRLF
    cHtml +=							'<span class="titulo_opcao">' + CRLF
    cHtml +=								STR0040 + CRLF	//'Consultar Marca&ccedil;&otilde;es'
    cHtml +=							'</span>' + CRLF
    cHtml +=							'<br><br>' + CRLF
	cHtml +=					'</p>' + CRLF
	cHtml +=				'</td>' + CRLF
  	cHtml +=			'</tr>' + CRLF
  	cHtml +=			'<tr>' + CRLF
    cHtml +=				'<td>' + CRLF
    cHtml +=					'<table width="515" border="0" cellspacing="0" cellpadding="0">' + CRLF
    cHtml +=						'<tr>' + CRLF
    cHtml +=							'<td background="'+TcfRetDirImg()+'/tabela_conteudo_1.gif" width="10">&nbsp;</td>' + CRLF
    cHtml +=							'<td class="titulo" width="498">' + CRLF
    cHtml +=								'<table width="498" border="0" cellspacing="2" cellpadding="1">' + CRLF
	cHtml += Imp_Cabec( nTamLin , nColunas , lTerminal )
Else
	//-- Imprime Cabecalho Especifico.
	Imp_Cabec( nTamLin , nColunas ,  lTerminal, 1, oPrinter )
EndIf

//-- Imprime Marca��es
nLenImp := Len(aImp)
For nX := 1 To nLenImp
	If !lTerminal .And. !lMeuRH
		nLin += 12

		If nLin > nLinTot - 40
			fImpSign(oPrinter)
			oPrinter:EndPage()
			oPrinter:StartPage()
			Imp_Cabec( nTamLin , nColunas ,  lTerminal, 1, oPrinter )
		EndIf

		oPrinter:Box( nLin, nCol	, nLin+13, nColTot, "-6" )			// Caixa da linha total

		If lBigLine .and. nX%2 == 0 //Pinta somente as linhas pares
			oPrinter:Fillrect( {nLin+1, nCol+1, nLin+12, nColTot-1 }, oBrushI, "-2") // Quadro na Cor Cinza
		EndIf

		oPrinter:Line( nLin, nPxData	, nLin+13, nPxData	, 0 , "-6") 	// Linha Pos Data

		oPrinter:SayAlign(nLin,nCol+2,DtoC(aImp[nX,1]),oFontM,500,100,,ALIGN_H_LEFT)
		oPrinter:SayAlign(nLin,nPxData+2,DiaSemana(aImp[nX,1],8),oFontM,nPxSemana-nPxData,100,,ALIGN_H_LEFT)

		nMin := Len(aImp[nX])

		If Len(aImp[nX]) >= 4 .or. !lImpMarc
			aResultado[1]++

			For nPosES := 1 to Len(aNaES)
				oPrinter:Line( nLin, aNaES[nPosES]-6, nLin+13, aNaES[nPosES]-6, 0 , "-6")
				nY := nPosES + 3
				If lImpMarc .and. nY <= nMin
					oPrinter:SayAlign(nLin,aNaES[nPosES]+2,aImp[nX,nY],oFontM,500,100,,ALIGN_H_LEFT)
				EndIf
			Next nPosES
		Else
			oPrinter:Line( nLin, aNaES[1]-6, nLin+13, aNaES[1]-6, 0 , "-6")
			oPrinter:SayAlign(nLin,aNaES[1],aImp[nX,2],oFontM,Len(aNaES)*40,100,,ALIGN_H_CENTER)

			If aImp[nX,2] == STR0020
				aResultado[2]++
			EndIf
		EndIf

		oPrinter:Line( nLin, nPxAbonos-6, nLin+13	, nPxAbonos-6, 0 , "-6")
		If lImpHrVal
			oPrinter:Line( nLin, nPxHrVal-6	, nLin+13	, nPxHrVal-6, 0 , "-6")
		EndIf
		oPrinter:Line( nLin, nPxHE-6	, nLin+13	, nPxHE-6, 0 , "-6")
		oPrinter:Line( nLin, nPxFalta-6	, nLin+13	, nPxFalta-6, 0 , "-6")

		If lPort671
			oPrinter:Line( nLin, nPxJor-6, nLin+13, nPxJor-6, 0, "-6")
		EndIf

		oPrinter:Line( nLin, nPxAdnNot-6, nLin+13	, nPxAdnNot-6, 0 , "-6")
		oPrinter:Line( nLin, nPxObser	, nLin+13	, nPxObser, 0 , "-6")

		If lImpMarc //Imprime abonos,He,Faltas,adicionais apenas se for para imprimir marca��es.
			If ValType(aImp[nX,3]) == "A"
				oPrinter:SayAlign(nLin,nPxAbonos+2,aImp[nX,3,2],oFontM,500,100,,ALIGN_H_LEFT)
				If Len(aImp[nX,3,1]) > 50
					oPrinter:SayAlign(nLin,nPxObser+2,aImp[nX,3,1],oFontO,500,100,,ALIGN_H_LEFT)
				Else
					oPrinter:SayAlign(nLin,nPxObser+2,aImp[nX,3,1],oFontM,500,100,,ALIGN_H_LEFT)
				EndIf
			Else
				If Len(aImp[nX,3]) > 50
					oPrinter:SayAlign(nLin,nPxObser+2,aImp[nX,3],oFontO,500,100,,ALIGN_H_LEFT)
				Else
					oPrinter:SayAlign(nLin,nPxObser+2,aImp[nX,3],oFontM,500,100,,ALIGN_H_LEFT)
				EndIf
			EndIf

			If Len(aResult) > 0
				nValAux := 0
				Aeval(aResult, {|x| If( x[1] == DtoS(aImp[nX,1]) .and. x[2] == "1", nValAux := __TimeSum(nValAux,x[3]),Nil )} )
				If nValAux > 0
					If !( lSexagenal ) // Centesimal
						nValAux := fConvHr(nValAux,'D',,5)
					Endif
					oPrinter:SayAlign(nLin,nPxHE+2,StrTran(StrZero(nValAux,5,2),'.',':'),oFontM,500,100,,ALIGN_H_LEFT)
					nValAux := 0
				EndIf
				//Apenas gero as horas de Absenteismo na ultima linha do Dia.
				If nX == Len(aImp) .Or. aScan(aImp,{|x| x[1] == aImp[nX,1]},nX + 1) == 0
					Aeval(aResult, {|x| If( x[1] == DtoS(aImp[nX,1]) .and. x[2] =="2", nValAux := __TimeSum(nValAux,x[3]),Nil )} )
					If nValAux > 0
						If !( lSexagenal ) // Centesimal
							nValAux := fConvHr(nValAux,'D',,5)
						Endif
						oPrinter:SayAlign(nLin,nPxFalta+2,StrTran(StrZero(nValAux,5,2),'.',':'),oFontM,500,100,,ALIGN_H_LEFT)
						nValAux := 0
					EndIf
					If lImpHrVal
						nValHrV  := 0
						nValHrV2 := 0
						Aeval(aResult, {|x| If( x[1] == DtoS(aImp[nX,1]) .and. x[2] == "1", nValHrV  := __TimeSum(nValHrV,x[4]),Nil )} )
						Aeval(aResult, {|x| If( x[1] == DtoS(aImp[nX,1]) .and. x[2] == "2", nValHrV2 := __TimeSum(nValHrV2,x[4]),Nil )} )
						nValHrV  := Abs(__TimeSub(nValHrV,nValHrV2))
					EndIf
					If nValHrV > 0
						If !( lSexagenal ) // Centesimal
							nValHrV := fConvHr(nValHrV,'D',,5)
						Endif
						oPrinter:SayAlign(nLin,nPxHrVal+2,StrTran(StrZero(nValHrV,5,2),'.',':'),oFontM,500,100,,ALIGN_H_LEFT)
						nValHrV := 0
					EndIf
				EndIf

				If lPort671
					Aeval(aResult, {|x| If( x[1] == DtoS(aImp[nX,1]) .and. x[2] == "4", nValAux := __TimeSum(nValAux, x[3]), Nil)})
					If nValAux > 0
						If !( lSexagenal ) // Centesimal
							nValAux := fConvHr(nValAux,'D',,5)
						Endif
						oPrinter:SayAlign(nLin, nPxJor+2, StrTran(StrZero(nValAux, 5, 2),'.',':'), oFontM, 500, 100,, ALIGN_H_LEFT)
						nValAux := 0
					EndIf
				EndIf

				Aeval(aResult, {|x| If( x[1] == DtoS(aImp[nX,1]) .and. x[2] == "3", nValAux := __TimeSum(nValAux,x[3]),Nil )} )
				If nValAux > 0
					If !( lSexagenal ) // Centesimal
						nValAux := fConvHr(nValAux,'D',,5)
					Endif
					oPrinter:SayAlign(nLin,nPxAdnNot+2,StrTran(StrZero(nValAux,5,2),'.',':'),oFontM,500,100,,ALIGN_H_LEFT)
					nValAux := 0
					If lImpHrVal
						Aeval(aResult, {|x| If( x[1] == DtoS(aImp[nX,1]) .and. x[2] == "3", nValHrV := __TimeSum(nValHrV,x[4]),Nil )} )
						If nValHrV > 0
							If !( lSexagenal ) // Centesimal
								nValHrV := fConvHr(nValHrV,'D',,5)
							Endif
							oPrinter:SayAlign(nLin,nPxHrVal+2,StrTran(StrZero(nValHrV,5,2),'.',':'),oFontM,500,100,,ALIGN_H_LEFT)
							nValHrV := 0
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		/*
		��������������������������������������������������������������Ŀ
		� Detalhes do Codigo HTML          							   �
		����������������������������������������������������������������*/
		IF ( lZebrado := ( nX%2 == 0.00 ) )
			cHtml += '<tr bgcolor="#FAFBFC">' + CRLF
			cHtml += 	'<td class="dados_2" bgcolor="#FAFBFC" nowrap><div align="center">' + CRLF
			cHtml += 		Dtoc(aImp[nX,1]) + CRLF
			cHtml += 	'</td>' + CRLF
			cHtml += 	'<td class="dados_2" bgcolor="#FAFBFC" nowrap><div align="left">' + CRLF
			cHtml +=		DiaSemana(aImp[nX,1]) + CRLF
			cHtml += 	'</td>' + CRLF
		Else
			cHtml += '<tr>' + CRLF
			cHtml += 	'<td class="dados_2" nowrap><div align="center">' + CRLF
			cHtml += 		Dtoc(aImp[nX,1]) + CRLF
			cHtml += 	'</td>' + CRLF
			cHtml += 	'<td class="dados_2" nowrap><div align="left">' + CRLF
			cHtml +=		DiaSemana(aImp[nX,1]) + CRLF
			cHtml += 	'</td>' + CRLF
		EndIF
		If ( nLenImpnX := Len(aImp[nX]) ) < ( ( nColunas + nLenImpnX ) - 1 )
			For nY := Len(aImp[nX]) To ( ( nColunas + 3 ) - 1 )
				aAdd(aImp[nX] , Space(05) )
			Next nY
		EndIf
		nLenImpnX := Len(aImp[nX])
		For nY := 4 To nLenImpnX
			IF ( lZebrado )
				cHtml += 	'<td class="dados_2" bgcolor="#FAFBFC" nowrap><div align="center">' + CRLF
				cHtml += 		aImp[nX,nY] + CRLF
				cHtml += 	'</td>' + CRLF
			Else
				cHtml += 	'<td class="dados_2" nowrap><div align="center">' + CRLF
				cHtml += 		aImp[nX,nY] + CRLF
				cHtml += 	'</td>' + CRLF
			EndIF
		Next nY

		//-- Trata Abonos e Excecoes
		If ValType(aImp[nX,3]) == "A"
			nAbHora:=  At( ":" , aImp[nX,3,2] )
		Else
			nAbHora:=  At( ":" , aImp[nX,3] )
		EndIf

		If nAbHora > 0
			cOcorr :=	Capital( If (ValType(aImp[nX,3]) == "A",aImp[nX,3,1],SubStr( aImp[nX,3] , 1 , nAbHora - 3 )) )
			cAbHora:= 	Capital( If (ValType(aImp[nX,3]) == "A",aImp[nX,3,2],SubStr( aImp[nX,3] , nAbHora - 2 ) ) )
		Else
			cOcorr :=	Capital( If (ValType(aImp[nX,3]) == "A",aImp[nX,3,1],AllTrim( aImp[nX,3] ) ))
			cAbHora:= 	'&nbsp;'
		EndIf

		If ( lZebrado )
			cHtml += 		'<td class="dados_2" bgcolor="#FAFBFC" nowrap><div align="center">' + CRLF
			cHtml +=			Capital( AllTrim( aImp[nX,2] ) )
			cHtml += 		'</td>' + CRLF
			cHtml += 		'<td class="dados_2" bgcolor="#FAFBFC" nowrap><div align="left">' + CRLF
			cHtml +=	 		cOcorr
			cHtml += 		'</td>' + CRLF
			cHtml += 		'<td class="dados_2" bgcolor="#FAFBFC" nowrap><div align="left">' + CRLF
			cHtml +=	 		cAbHora
			cHtml += 		'</td>' + CRLF
		Else
			cHtml += 		'<td class="dados_2" nowrap><div align="center">' + CRLF
			cHtml +=			Capital( AllTrim( aImp[nX,2] ) )
			cHtml += 		'</td>' + CRLF
			cHtml += 		'<td class="dados_2" nowrap><div align="left">' + CRLF
			cHtml +=	 		cOcorr
			cHtml += 		'</td>' + CRLF
			cHtml += 		'<td class="dados_2" nowrap><div align="left">' + CRLF
			cHtml +=			cAbHora
			cHtml += 		'</td>' + CRLF
		EndIf
	EndIf
Next nX

If !( lTerminal )

	nLin += 35

	// Marca��es desconsideradas
	If lPort671 .And. lImpMarc .And. !Empty(aMarcDes)

		If(nLin > nLinTot - 40, fQuebra(oPrinter, nTamLin, nColunas,  lTerminal), NIL)

		oPrinter:SayAlign( nLin, nCol+5, STR0115, oFontT, 500, 150, , ALIGN_H_LEFT ) // "Marca��es Desconsideradas"
		nLin += 13

		oPrinter:Box( nLin, nCol, nLin+17, nColTot, "-6" ) // Caixa da linha total

		If lBigLine
			oPrinter:Fillrect( {nLin+1, nCol+1, nLin+17, nColTot-1 }, oBrushC, "-2") // Quadro na Cor Cinza
		EndIf

		oPrinter:SayAlign( nLin+3, nCol+5, STR0042, oFontP, nPxData, 150, , ALIGN_H_LEFT ) //Data

		oPrinter:Line( nLin, nCol+94, nLin+17, nCol+94, 0, "-6")
		oPrinter:SayAlign( nLin+3, nCol+100, STR0116, oFontP, 500, 150, , ALIGN_H_LEFT ) //Hora da marca��o

		oPrinter:Line( nLin, nCol+294, nLin+17, nCol+294, 0, "-6")
		oPrinter:SayAlign( nLin+3, nCol+300, STR0117, oFontP, 500, 150, , ALIGN_H_LEFT ) //Motivo

		For nX := 1 To Len(aMarcDes)

			If(nLin > nLinTot - 40, fQuebra(oPrinter, nTamLin, nColunas,  lTerminal), NIL)

			nLin += 13

			oPrinter:Box( nLin, nCol, nLin+13, nColTot, "-6" )			// Caixa da linha total

			If lBigLine .and. nX%2 == 0 //Pinta somente as linhas pares
				oPrinter:Fillrect( {nLin+1, nCol+1, nLin+12, nColTot-1 }, oBrushI, "-2") // Quadro na Cor Cinza
			EndIf

			oPrinter:SayAlign( nLin, nCol+5, dToC(aMarcDes[nX][1]), oFontP, nPxData, 150, , ALIGN_H_LEFT ) //Data

			oPrinter:Line( nLin, nCol+94, nLin+13, nCol+94, 0, "-6")
			oPrinter:SayAlign( nLin+3, nCol+100, aMarcDes[nX][2], oFontP, 500, 150, , ALIGN_H_LEFT ) //Hora da marca��o

			oPrinter:Line( nLin, nCol+294, nLin+13, nCol+294, 0, "-6")
			oPrinter:SayAlign( nLin+3, nCol+300, aMarcDes[nX][3], oFontP, 500, 150, , ALIGN_H_LEFT ) //Motivo

		Next nX

		nLin += 35
	EndIf


	If lImpBH
		If Pnr010ImpBh(@nSaldoAnt, @nSaldoAtu, @nCredito, @nDebito, @nTotHrVal)

			If nLin > nLinTot - 40
				fImpSign(oPrinter)
				oPrinter:EndPage()
				oPrinter:StartPage()
				Imp_Cabec( nTamLin, nColunas,  lTerminal, 0, oPrinter )
				nLin += 13
			EndIf

			oPrinter:Box( nLin, nCol, nLin + 17, nColTot, "-6" )		// Caixa da linha total
			If lImpHrVal
				nTamCol	 := (nColTot - nCol) / 7
				nColCod1 := nCol + nTamCol * 2
				nColCod2 := nColCod1 + nTamCol
				nColCod3 := nColCod2 + nTamCol
				nColCod4 := nColCod3 + nTamCol
				nColCod5 := nColCod4 + nTamCol
			Else
				nTamCol	 := (nColTot - nCol) / 6
				nColCod1 := nCol + nTamCol * 2
				nColCod2 := nColCod1 + nTamCol
				nColCod3 := nColCod2 + nTamCol
				nColCod4 := nColCod3 + nTamCol
			EndIf

			If lBigLine
				oPrinter:Fillrect( {nLin+1, nCol+1, nLin+13, nColTot-1 }, oBrushC, "-2") // Quadro na Cor Cinza
			EndIf

			oPrinter:Line( nLin, nColCod1, nLin+13, nColCod1, 0 , "-6")
			oPrinter:Line( nLin, nColCod2, nLin+13, nColCod2, 0 , "-6")
			oPrinter:Line( nLin, nColCod3, nLin+13, nColCod3, 0 , "-6")
			oPrinter:Line( nLin, nColCod4, nLin+13, nColCod4, 0 , "-6")

			If lImpHrVal
				oPrinter:Line( nLin, nColCod5, nLin+13, nColCod5, 0 , "-6")
			EndIf

			oPrinter:SayAlign(nLin, nCol + 2, STR0081, oFontP, 500, 100,, ALIGN_H_LEFT)		//Banco de Horas
			oPrinter:SayAlign(nLin, nColCod1 + 2, STR0082, oFontP, 500, 100,, ALIGN_H_LEFT)	//Saldo Anterior
			oPrinter:SayAlign(nLin, nColCod2 + 2, STR0083, oFontP, 500, 100,, ALIGN_H_LEFT)	//D�bito
			oPrinter:SayAlign(nLin, nColCod3 + 2, STR0084, oFontP, 500, 100,, ALIGN_H_LEFT)	//Cr�dito

			If lImpHrVal
				oPrinter:SayAlign(nLin, nColCod4 + 2, STR0099, oFontP, 500, 100,, ALIGN_H_LEFT)	//Horas Valorizadas
				oPrinter:SayAlign(nLin, nColCod5 + 2, STR0085, oFontP, 500, 100,, ALIGN_H_LEFT)	//Saldo Atual
			Else
				oPrinter:SayAlign(nLin, nColCod4 + 2, STR0085, oFontP, 500, 100,, ALIGN_H_LEFT)	//Saldo Atual
			EndIf

			nLin += 12

			oPrinter:Box( nLin, nCol, nLin+13, nColTot, "-6" )

			oPrinter:Line( nLin, nColCod1, nLin + 13, nColCod1, 0, "-6")
			oPrinter:Line( nLin, nColCod2, nLin + 13, nColCod2, 0, "-6")
			oPrinter:Line( nLin, nColCod3, nLin + 13, nColCod3, 0, "-6")
			oPrinter:Line( nLin, nColCod4, nLin + 13, nColCod4, 0, "-6")

			If lImpHrVal
				oPrinter:Line( nLin, nColCod5, nLin + 13, nColCod5, 0, "-6")
			EndIf

			oPrinter:SayAlign(nLin, nColCod1 + 2, Transform(nSaldoAnt, '@E 99,999.99'), oFontM, 500, 100,, ALIGN_H_LEFT)		//Saldo Anterior
			oPrinter:SayAlign(nLin, nColCod2 + 2, Transform(nDebito, '@E 99,999.99'), oFontM, 500, 100,, ALIGN_H_LEFT)			//D�bito
			oPrinter:SayAlign(nLin, nColCod3 + 2, Transform(nCredito, '@E 99,999.99'), oFontM, 500, 100,, ALIGN_H_LEFT)			//Cr�dito

			If lImpHrVal
				oPrinter:SayAlign(nLin, nColCod4 + 2, Transform(nTotHrVal, '@E 99,999.99'), oFontM, 500, 100,, ALIGN_H_LEFT)		//Horas Valorizadas
				oPrinter:SayAlign(nLin, nColCod5 + 2, Transform(nSaldoAtu, '@E 99,999.99'), oFontM, 500, 100,, ALIGN_H_LEFT)		//Saldo Atual
			Else
				oPrinter:SayAlign(nLin, nColCod4 + 2, Transform(nSaldoAtu, '@E 99,999.99'), oFontM, 500, 100,, ALIGN_H_LEFT)		//Horas Valorizadas
			EndIf

			nLin += 25
		EndIf
	EndIf

	If lPort671 .And. lImpMarc

		aHorarios := GetHorarios()

		If nLin > nLinTot - 40
			fImpSign(oPrinter)
			oPrinter:EndPage()
			oPrinter:StartPage()
			Imp_Cabec( nTamLin, nColunas,  lTerminal, 0, oPrinter )
		EndIf

		oPrinter:SayAlign( nLin, nCol+5, STR0111, oFontT, 500, 150, , ALIGN_H_LEFT ) //Hor�rios
		nLin += 13

		oPrinter:Box( nLin, nCol, nLin+17, nColTot, "-6" ) // Caixa da linha total

		If lBigLine
			oPrinter:Fillrect( {nLin+1, nCol+1, nLin+17, nColTot-1 }, oBrushC, "-2") // Quadro na Cor Cinza
		EndIf

		oPrinter:SayAlign( nLin+3, nCol+5, STR0042, oFontP, nPxData, 150, , ALIGN_H_LEFT ) //Data

		nESAux := 1
		For nX := 1 to Len(aNaES)
			oPrinter:Line( nLin, aNaES[nX]-6, nLin+17, aNaES[nX]-6, 0, "-6")
			If nX%2 == 0
				oPrinter:SayAlign( nLin+3, aNaES[nX], AllTrim(Str(nESAux)) + STR0036, oFontP, aNaES[nX]+40, 150 , , ALIGN_H_LEFT ) //Saida
				nESAux++
			Else
				oPrinter:SayAlign( nLin+3, aNaES[nX], AllTrim(Str(nESAux)) + STR0035, oFontP, aNaES[nX]+40, 150 , , ALIGN_H_LEFT ) //Entrada
			EndIf
		Next nX

		nPxTurno := aNaES[Len(aNaES)] + 40
		oPrinter:Line( nLin, nPxTurno-6, nLin+17, nPxTurno-6, 0 , "-6")
		oPrinter:SayAlign( nLin+3, nPxTurno, STR0007, oFontP, 500, 150 , , ALIGN_H_LEFT ) // Turno

		//Imprime as informa��es
		For nX := 1 To Len(aHorarios)

			If nLin > nLinTot - 40
				fImpSign(oPrinter)
				oPrinter:EndPage()
				oPrinter:StartPage()
				Imp_Cabec( nTamLin, nColunas,  lTerminal, 0, oPrinter )
			EndIf

			nLin += 13

			oPrinter:Box( nLin, nCol, nLin+13, nColTot, "-6" )			// Caixa da linha total

			If lBigLine .and. nX%2 == 0 //Pinta somente as linhas pares
				oPrinter:Fillrect( {nLin+1, nCol+1, nLin+12, nColTot-1 }, oBrushI, "-2") // Quadro na Cor Cinza
			EndIf

			oPrinter:SayAlign( nLin, nCol+5, dToC(aHorarios[nX][1]), oFontP, nPxData, 150, , ALIGN_H_LEFT ) //Data

			aEval(aNaES, {|X| oPrinter:Line( nLin, X-6, nLin+13, X-6, 0, "-6") })

			oPrinter:Line( nLin, nPxTurno-6, nLin+13, nPxTurno-6, 0 , "-6")
			oPrinter:SayAlign( nLin+3, nPxTurno, aHorarios[nX][2], oFontP, 500, 150 , , ALIGN_H_LEFT ) // Turno

			For nPosES := 1 To Len(aHorarios[nX][3])
				If nPosES <= Len(aNaES)
					oPrinter:SayAlign(nLin+3, aNaES[nPosES]+2, StrTran( StrZero(aHorarios[nX][3][nPosES], 5,2),".", ":"), oFontM, 500, 100,, ALIGN_H_LEFT)
				Else
					EXIT
				EndIf
			Next nPosES
		Next nX

		nLin += 25

	EndIf

	//-- Se existirem totais, e se for selecionada sua impress�o, ser�o impressos.
	If lImpMarc .and. Len(aTotais) > 0 .and. nImpHrs # 4
		If nLin > nLinTot - 40
			fImpSign(oPrinter)
			oPrinter:EndPage()
			oPrinter:StartPage()
			Imp_Cabec( nTamLin , nColunas ,  lTerminal, 0, oPrinter )
			nLin+=20
		EndIf

		oPrinter:Box( nLin, nCol , nLin+13, nColTot, "-6" )			// Caixa da linha total

		nTamCol	 := (nColTot - nCol) / 21
		nColCod1 := nCol + nTamCol
		nColDesc1:= nColCod1 + (nTamCol*4)
		nColCalc1:= nColDesc1 + nTamCol
		nColInf1 := nColCalc1 + nTamCol
		nColCod2 := nColInf1 + nTamCol
		nColDesc2:= nColCod2 + (nTamCol*4)
		nColCalc2:= nColDesc2 + nTamCol
		nColInf2 := nColCalc2 + nTamCol
		nColCod3 := nColInf2 + nTamCol
		nColDesc3:= nColCod3 + (nTamCol*4)
		nColCalc3:= nColDesc3 + nTamCol

		If lBigLine
			oPrinter:Fillrect( {nLin+1, nCol+1, nLin+13, nColTot-1 }, oBrushC, "-2") // Quadro na Cor Cinza
		EndIf

		oPrinter:Line( nLin, nColCod1	, nLin+13, nColCod1		, 0 , "-6")
		If nImpHrs == 1 .or. nImpHrs == 3
			oPrinter:Line( nLin, nColDesc1	, nLin+13, nColDesc1	, 0 , "-6")
		EndIf
		oPrinter:Line( nLin, nColCalc1	, nLin+13, nColCalc1	, 0 , "-6")
		oPrinter:Line( nLin, nColInf1	, nLin+13, nColInf1		, 0 , "-6")
		oPrinter:Line( nLin, nColCod2	, nLin+13, nColCod2		, 0 , "-6")
		If nImpHrs == 1 .or. nImpHrs == 3
			oPrinter:Line( nLin, nColDesc2	, nLin+13, nColDesc2	, 0 , "-6")
		EndIf
		oPrinter:Line( nLin, nColCalc2	, nLin+13, nColCalc2	, 0 , "-6")
		oPrinter:Line( nLin, nColInf2	, nLin+13, nColInf2		, 0 , "-6")
		oPrinter:Line( nLin, nColCod3	, nLin+13, nColCod3		, 0 , "-6")
		If nImpHrs == 1 .or. nImpHrs == 3
			oPrinter:Line( nLin, nColDesc3	, nLin+13, nColDesc3	, 0 , "-6")
		EndIf
		oPrinter:Line( nLin, nColCalc3	, nLin+13, nColCalc3	, 0 , "-6")

		oPrinter:SayAlign(nLin,nCol+2,STR0064,oFontP,500,100,,ALIGN_H_LEFT)				//Codigo
		oPrinter:SayAlign(nLin,nColCod1+2,STR0065,oFontP,500,100,,ALIGN_H_LEFT)			//Descri��o

		If nImpHrs == 1 .or. nImpHrs == 3
			oPrinter:SayAlign(nLin,nColDesc1+2,STR0066,oFontP,500,100,,ALIGN_H_LEFT)	//Calculado
		EndIf

		oPrinter:SayAlign(nLin,nColCalc1+2,STR0067,oFontP,500,100,,ALIGN_H_LEFT)		//Informado

		oPrinter:SayAlign(nLin,nColInf1+2,STR0064,oFontP,500,100,,ALIGN_H_LEFT)			//Codigo
		oPrinter:SayAlign(nLin,nColCod2+2,STR0065,oFontP,500,100,,ALIGN_H_LEFT)			//Descri��o

		If nImpHrs == 1 .or. nImpHrs == 3
			oPrinter:SayAlign(nLin,nColDesc2+2,STR0066,oFontP,500,100,,ALIGN_H_LEFT)	//Calculado
		EndIf
		oPrinter:SayAlign(nLin,nColCalc2+2,STR0067,oFontP,500,100,,ALIGN_H_LEFT)		//Informado

		oPrinter:SayAlign(nLin,nColInf2+2,STR0064,oFontP,500,100,,ALIGN_H_LEFT)			//Codigo
		oPrinter:SayAlign(nLin,nColCod3+2,STR0065,oFontP,500,100,,ALIGN_H_LEFT)			//Descri��o

		If nImpHrs == 1 .or. nImpHrs == 3
			oPrinter:SayAlign(nLin,nColDesc3+2,STR0066,oFontP,500,100,,ALIGN_H_LEFT)	//Calculado
		EndIf
		oPrinter:SayAlign(nLin,nColCalc3+2,STR0067,oFontP,500,100,,ALIGN_H_LEFT)

		nMetade := nLin
		nContEve:= 1
		For nX := 1 To Len(aTotais)
			If nContEve == 1
				nMetade+=12
				If nMetade > nLinTot - 40
					fImpSign(oPrinter)
					oPrinter:EndPage()
					oPrinter:StartPage()
					Imp_Cabec( nTamLin , nColunas ,  lTerminal, 2, oPrinter )
					nLin+=12
					nMetade := nLin
				EndIf
				oPrinter:Box(  nMetade, nCol	, nMetade+13, nColTot	, "-6" )
				If lBigLine .and. lBrush
					oPrinter:Fillrect( {nMetade+1, nCol+1, nMetade+12, nColTot-1 }, oBrushI, "-2") // Quadro na Cor Cinza
					lBrush := .F.
				Else
					lBrush := .T.
				EndIf
				oPrinter:Line( nMetade, nColCod1	, nMetade+13, nColCod1	, 0 , "-6")
				oPrinter:Line( nMetade, nColDesc1	, nMetade+13, nColDesc1	, 0 , "-6")
				oPrinter:Line( nMetade, nColCalc1	, nMetade+13, nColCalc1	, 0 , "-6")
				oPrinter:Line( nMetade, nColInf1	, nMetade+13, nColInf1	, 0 , "-6")
				oPrinter:Line( nMetade, nColCod2	, nMetade+13, nColCod2	, 0 , "-6")
				oPrinter:Line( nMetade, nColDesc2	, nMetade+13, nColDesc2	, 0 , "-6")
				oPrinter:Line( nMetade, nColCalc2	, nMetade+13, nColCalc2	, 0 , "-6")
				oPrinter:Line( nMetade, nColInf2	, nMetade+13, nColInf2	, 0 , "-6")
				oPrinter:Line( nMetade, nColCod3	, nMetade+13, nColCod3	, 0 , "-6")
				oPrinter:Line( nMetade, nColDesc3	, nMetade+13, nColDesc3	, 0 , "-6")
				oPrinter:Line( nMetade, nColCalc3	, nMetade+13, nColCalc3	, 0 , "-6")

				oPrinter:SayAlign(nMetade,nCol+2,aTotais[nX,1],oFontM,500,100,,ALIGN_H_LEFT)
				oPrinter:SayAlign(nMetade,nColCod1+2,aTotais[nX,2],oFontM,500,100,,ALIGN_H_LEFT)
				oPrinter:SayAlign(nMetade,nColDesc1,aTotais[nX,3],oFontM,500,100,,ALIGN_H_LEFT)
				oPrinter:SayAlign(nMetade,nColCalc1,aTotais[nX,4],oFontM,500,100,,ALIGN_H_LEFT)
				nContEve++
			ElseIf nContEve == 2
				oPrinter:SayAlign(nMetade,nColInf1+2,aTotais[nX,1],oFontM,500,100,,ALIGN_H_LEFT)
				oPrinter:SayAlign(nMetade,nColCod2+2,aTotais[nX,2],oFontM,500,100,,ALIGN_H_LEFT)
				oPrinter:SayAlign(nMetade,nColDesc2,aTotais[nX,3],oFontM,500,100,,ALIGN_H_LEFT)
				oPrinter:SayAlign(nMetade,nColCalc2,aTotais[nX,4],oFontM,500,100,,ALIGN_H_LEFT)
				nContEve++
			ElseIf nContEve == 3
				oPrinter:SayAlign(nMetade,nColInf2+2,aTotais[nX,1],oFontM,500,100,,ALIGN_H_LEFT)
				oPrinter:SayAlign(nMetade,nColCod3+2,aTotais[nX,2],oFontM,500,100,,ALIGN_H_LEFT)
				oPrinter:SayAlign(nMetade,nColDesc3,aTotais[nX,3],oFontM,500,100,,ALIGN_H_LEFT)
				oPrinter:SayAlign(nMetade,nColCalc3,aTotais[nX,4],oFontM,500,100,,ALIGN_H_LEFT)
				nContEve++
			EndIf
			If nContEve > 3
				nContEve := 1
			EndIf
			nLin := nMetade
		Next nX
	EndIf

	fImpSign(oPrinter)
Else
	/*
	��������������������������������������������������������������Ŀ
	� Final da Estrutura do Codigo HTML							   �
	����������������������������������������������������������������*/
    cHtml +=									'<tr>' + CRLF
    cHtml +=										'<td colspan="' + AllTrim( Str( nColunas + 5 ) ) + '" class="etiquetas_1" bgcolor="#FAFBFC"><hr size="1"></td>' + CRLF
    cHtml +=									'</tr>' + CRLF
	cHtml +=								'</table>' + CRLF
	cHtml +=							'</td>' + CRLF
    cHtml +=							'<td background="'+TcfRetDirImg()+'/tabela_conteudo_2.gif" width="7">&nbsp;</td>' + CRLF
    cHtml +=						'</tr>' + CRLF
    cHtml +=					'</table>' + CRLF
    cHtml +=				'</td>' + CRLF
  	cHtml +=			'</tr>' + CRLF
	cHtml +=		'</table>' + CRLF
	cHtml +=		'<p align="right"><a href="javascript:self.print()"><img src="'+TcfRetDirImg()+'/imprimir.gif" width="90" height="28" hspace="20" border="0"></a></p>' + CRLF
	cHtml +=	'</body>' + CRLF
	cHtml += '</html>' + CRLF
EndIf

Return( cHtml )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FMontaaIMP� aUTOR � EQUIPE DE RH          � dATA � 09/04/96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta o Vetor aImp , utilizado na impressao do espelho     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � POR010IMP                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function FMontaAimp(aTabCalend, aMarcacoes, aImp,dInicio,dFim, lTerminal, lImpAcum, lMeuRH)

Local aDescAbono := {}
//Local aCodigos	 := {}
Local cTipAfas   := ""
Local cDescAfas  := ""
Local cOcorr     := ""
Local cOrdem     := ""
Local cTipDia    := ""
Local dData      := Ctod("//")
Local dDtBase    := dFim
Local lRet       := .T.
Local lFeriado   := .T.
Local lTrabaFer  := .F.
Local lAfasta    := .T.
Local nX         := 0
Local nDia       := 0
Local nMarc      := 0
Local nLenMarc	 := Len( aMarcacoes )
Local nLenDescAb := Len( aDescAbono )
Local nTab       := 0
Local nContMarc  := 0
Local nDias		 := 0
Local cOriMarc	 := ""

//-- Variaveis ja inicializadas.
aImp := {}

nDias := ( dDtBase - dInicio )
For nDia := 0 To nDias

	//-- Reinicializa Variaveis.
	dData      := dInicio + nDia
	aDescAbono := {}
	cOcorr     := ""
	cTipAfas   := ""
	cDescAfas  := ""
	cOcorr	   := ""

	If !lImpMarc
		//-- Adiciona Nova Data a ser impressa.
		aAdd(aImp,{})
		aAdd(aImp[Len(aImp)], dData)
		aAdd(aImp[Len(aImp)], Space(1))
		nContMarc++
		Loop
	EndIf

	//-- o Array aTabcalend � setado para a 1a Entrada do dia em quest�o.
	If ( nTab := aScan(aTabCalend, {|x| x[48] == dData .and. x[4] == '1E' }) ) == 0.00
		Loop
	EndIf

	//-- o Array aMarcacoes � setado para a 1a Marca��o do dia em quest�o.
	nMarc := aScan(aMarcacoes, { |x| x[3] == aTabCalend[nTab, 2] })

	//-- Consiste Afastamentos, Demissoes ou Transferencias.
	If ( ( lAfasta := aTabCalend[ nTab , 24 ] ) .or. SRA->( RA_SITFOLH $ 'D�T' .and. dData > RA_DEMISSA ) )
		lAfasta		:= .T.
		cTipAfas	:= IF(!Empty(aTabCalend[ nTab , 25 ]),aTabCalend[ nTab , 25 ],fDemissao(SRA->RA_SITFOLH, SRA->RA_RESCRAI) )
		cDescAfas	:= Alltrim(fDescAfast( cTipAfas, TamSx3("RCM_DESCRI")[1], Nil, SRA->( RA_SITFOLH == 'D' .and. dData > RA_DEMISSA ), aTabCalend[ nTab , 47 ], SRA->RA_FILIAL ))
	EndIf

	//Verifica Regra de Apontamento ( Trabalha Feriado ? )
	lTrabaFer := ( PosSPA( aTabCalend[ nTab , 23 ] , cFilSPA , "PA_FERIADO" , 01 ) == "S" )

	//-- Consiste Feriados.
	If ( lFeriado := aTabCalend[ nTab , 19 ] )  .AND. !lTrabaFer
		cOcorr := aTabCalend[ nTab , 22 ]
	EndIf

	//-- Carrega Array aDescAbono com os Abonos ocorridos no Dia
	nLenDescAb := Len(aAbonados)
	For nX := 1 To nLenDescAb
		If aAbonados[nX,1] == dData
			aAdd(aDescAbono, { aAbonados[nX,2] , aAbonados[nX,3] , aAbonados[nX,4] })
		EndIf
	Next nX

	//-- Ordem e Tipo do dia em quest�o.
	cOrdem  := aTabCalend[nTab,2]
	cTipDia := aTabCalend[nTab,6]

    //-- Se a Data da marcacao for Posterior a Admissao
	If dData >= SRA->RA_ADMISSA
		//-- Se Afastado
		If ( lAfasta  .AND. aTabCalend[nTab,10] <> 'E' ) .OR. ( lAfasta  .AND. aTabCalend[nTab,10] == 'E' .AND. ( !lImpExcecao .OR. !aTabCalend[nTab,32] ) )
			cOcorr := cDescAfas
		//-- Se nao for Afastado
		Else

		    //-- Se tiver EXCECAO para o Dia  ------------------------------------------------
			If aTabCalend[nTab,10] == 'E'
		       //-- Se excecao trabalhada
		       If cTipDia == 'S'
		          //-- Se nao fez Marcacao
		          If Empty(nMarc)
					 cOcorr := STR0020  // '** Ausente **'
				  //-- Se fez marcacao
		          Else
		          	 //-- Motivo da Marcacao
	          		 If !Empty(aTabCalend[nTab,11])
					 	cOcorr := AllTrim(aTabCalend[nTab,11])
					 Else
					 	cOcorr := STR0018  // '** Excecao nao Trabalhada **'
					 EndIf
		          EndIf
		       //-- Se excecao outros dias (DSR/Compensado/Nao Trabalhado)
		       Else
 					//-- Motivo da Marcacao
		       		If !Empty(aTabCalend[nTab,11])
						cOcorr := AllTrim(aTabCalend[nTab,11])
					Else
						cOcorr := STR0018  // '** Excecao nao Trabalhada **'
					EndIf
			   EndIf

		    //-- Se nao Tiver Excecao  no Dia ---------------------------------------------------
		    Else
		        //-- Se feriado
		       	If lFeriado
		       	    //-- Se nao trabalha no Feriado
		       	    If !lTrabaFer
						cOcorr := If(!Empty(cOcorr),cOcorr,STR0019 ) // '** Feriado **'
					//-- Se trabalha no Feriado
					Else
					    //-- Se Dia Trabalhado e Nao fez Marcacao
				    	If cTipDia == 'S' .and. Empty(nMarc)
							cOcorr := STR0020  // '** Ausente **'
				    	ElseIf cTipDia == 'D'
							cOcorr := STR0021  // '** D.S.R. **'
						ElseIf cTipDia == 'C'
							cOcorr := STR0022  // '** Compensado **'
						ElseIf cTipDia == 'N'
							cOcorr := STR0023  // '** Nao Trabalhado **'
						EndIf
					EndIf
		    	Else
		    	    //-- Se Dia Trabalhado e Nao fez Marcacao
			    	If cTipDia == 'S' .and. Empty(nMarc)
						cOcorr := STR0020  // '** Ausente **'
			    	ElseIf cTipDia == 'D'
						cOcorr := STR0021  // '** D.S.R. **'
					ElseIf cTipDia == 'C'
						cOcorr := STR0022  // '** Compensado **'
					ElseIf cTipDia == 'N'
						cOcorr := STR0023  // '** Nao Trabalhado **'
					EndIf

				EndIf
		    EndIf
		EndIf
	EndIf

	nLenDescAb := Len(aDescAbono)

	//-- Adiciona Nova Data a ser impressa.
	aAdd(aImp,{})
	aAdd(aImp[Len(aImp)], aTabCalend[nTab,48])

	//-- Ocorrencia na Data.
	If (lTerminal .And. !lMeuRH)
		aAdd( aImp[Len(aImp)], cOcorr)
	EndIf

	//-- Abono na Data.
	If ( nLenDescAb  > 0 )
	    If !lTerminal .Or. lMeuRH
	    	If cOcorr == STR0020  // '** Ausente **'
			  	aAdd( aImp[Len(aImp)], cOcorr ) // '** Ausente **'
			Else
				If !empty(cOcorr)
					aAdd( aImp[Len(aImp)],	Space(01))
				  	aAdd( aImp[Len(aImp)], cOcorr )
					aAdd( aImp,{})
					aAdd( aImp[Len(aImp)], aTabCalend[nTab,1])
					aAdd( aImp[Len(aImp)],	Space(01) )
				Else
					aAdd( aImp[Len(aImp)],	Space(01))
				EndIf
			EndIf
	    EndIf
		For nX := 1 To nLenDescAb
			If nX == 1
				aAdd( aImp[Len(aImp)], aDescAbono[nX])
			Else
				aAdd(aImp, {})
				aAdd(aImp[Len(aImp)], aTabCalend[nTab,1]		)
				aAdd(aImp[Len(aImp)], Space(01)			 	)
				aAdd(aImp[Len(aImp)], aDescAbono[nX]			)
			EndIf
		Next nX
	Else
		If ( lTerminal .And. !lMeuRH )
			aAdd( aImp[Len(aImp)], '' )
		Else
			If cOcorr == STR0020  // '** Ausente **'
				aAdd( aImp[Len(aImp)], cOcorr)
				aAdd( aImp[Len(aImp)], Space(01))
			Else
				aAdd( aImp[Len(aImp)], Space(01))
			  	aAdd( aImp[Len(aImp)], cOcorr )
			EndIf
		EndIf
	EndIf

	//-- Marcacoes ocorridas na data.
	If nMarc > 0
		While nMarc <= nLenMarc .and. cOrdem == aMarcacoes[nMarc,3]
			nContMarc ++
			cOriMarc := ""
			If lPort671
				cOriMarc := " " + aMarcacoes[nMarc, 28]
			ElseIf aMarcacoes[nMarc, 28] != "O"
				cOriMarc := " *"
			EndIf

			aAdd( aImp[Len(aImp)], StrTran(StrZero(aMarcacoes[nMarc,2],5,2),'.',':') + cOriMarc ) //Se nao for original, inclui asterisco na frente da marcacao
			nMarc ++
		EndDo
	EndIf

Next nDia

If lImpMarc .And. (!lTerminal .Or. lMeuRH) //Carrega o array aResult para exibicao das HE, faltas e adc. noturno.
	aResult := {}
	fGetApo(@aResult, dInicio, dFim, lImpAcum, aTabCalend, aMarcacoes)
EndIf

lRet := If(nContMarc>=1,.T.,.F.)

Return( lRet )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Imp_Cabec � Autor � EQUIPE DE RH          � Data � 09/04/96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime o cabecalho do espelho do ponto                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � POR010IMP                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function Imp_Cabec(nTamLin ,nColunas, lTerminal, nTipoCab, oPrinter )

Local cDet			:= ""
Local cHtml			:= ""
Local lImpTurnos	:=.F.
Local nVezes		:= ( nColunas / 2 )
Local nQtdeTurno	:= 0.00
Local nX			:= 0.00
Local nTamTno		:= ( Min(TamSx3("R6_DESC")[1], nTamLin) ) - 1
Local nSizePage		:= 0
Local nColCab12		:= 0
Local nColCab13		:= 0
Local nVarAux		:= 0
Local nESAux		:= 0
Local oBrush		:= TBrush():New( ,  RGB(228, 228, 228)  )

Local nLinSit       := 0

DEFAULT lTerminal := .F.
DEFAULT nTipoCab  := 3 // 1 - Cab para as Marcacoes / 2 - Totais / 3 - Sem Cab Auxiliar

lImpTurnos := nTipoCab <> 2

If !( lTerminal )

	nSizePage	:= oPrinter:nPageWidth / oPrinter:nFactorHor //Largura da p�gina em cm dividido pelo fator horizontal, retorna tamanho da p�gina em pixels
	nLin		:= aMargRel[2] + 10
	nCol		:= aMargRel[1] + 10
	nPxData	 	:= nCol+50
	nPxSemana	:= nPxData+50
	nVarAux		:= nPxSemana
	nColTot		:= nSizePage-(aMargRel[1]+aMargRel[3])
	nLinTot		:= ((oPrinter:nPageHeight / oPrinter:nFactorVert) -20 ) - (aMargRel[2]+aMargRel[4])
	nColCab12	:= nColTot / 3
	nColCab13	:= ( nColTot / 3 ) * 2
	aNaES		:= Array(nColunas)

	For nX := 1 to Len(aNaES)
		aNaES[nX] := nVarAux
		nVarAux += 40
	Next nX

	If lImpHrVal
		nPxAbonos 	:= nVarAux
		nPxHe	 	:= nPxAbonos + 40
		nPxHrVal	:= nPxHe + 40
		nPxFalta 	:= nPxHrVal + 40
		If lPort671
			nPxJor 		:= nPxFalta + 40
			nPxAdnNot	:= nPxJor + 40
		Else
			nPxAdnNot	:= nPxFalta + 40
		EndIf
		nPxObser  	:= nPxAdnNot + 40
	Else
		nPxAbonos 	:= nVarAux
		nPxHe	 	:= nPxAbonos + 40
		nPxFalta 	:= nPxHe + 40
		If lPort671
			nPxJor 		:= nPxFalta + 40
			nPxAdnNot	:= nPxJor + 40
		Else
			nPxAdnNot	:= nPxFalta + 40
		EndIf
		nPxObser  	:= nPxAdnNot + 40
	EndIf
	If lCodeBar
		If lBigLine
			oPrinter:Fillrect( {nLin, nCol, nLin+17, nColTot-210 }, oBrush, "-2") 	// Quadro na Cor Cinza
		EndIf
		If lPort671
			oPrinter:SayAlign(nLin+2, nCol, STR0001 + " " + dToC(dPerIni) + " - " + dToC(dPerFim), oFontT, nColTot-210, 100,, ALIGN_H_CENTER)  	// 'Espelho do Ponto'
		Else
			oPrinter:SayAlign(nLin+2,nCol,STR0001,oFontT,nColTot-210,100,,ALIGN_H_CENTER)  	// 'Espelho do Ponto'
		EndIf

		oPrinter:Box( nLin+3, nColTot-200	, nLin+38, nColTot-5, "-6" )				// Caixa da linha total
		oPrinter:Code128c(nLin+30, nColTot-176, cCodeBar, 20)
		oPrinter:SayAlign(nLin+30,nColTot-200,cCodeBar,oFont06,(nColTot-(nColTot-200)),100,,ALIGN_H_CENTER)
	Else
		If lBigLine
			oPrinter:Fillrect( {nLin, nCol, nLin+17, nColTot }, oBrush, "-2") 	// Quadro na Cor Cinza
		EndIf
		If lPort671
			oPrinter:SayAlign(nLin+2,nCol, STR0001 + " " + dToC(dPerIni) + " - " + dToC(dPerFim), oFontT,nColTot,100,,ALIGN_H_CENTER)  	// 'Espelho do Ponto'
		Else
			oPrinter:SayAlign(nLin+2,nCol,STR0001,oFontT,nColTot,100,,ALIGN_H_CENTER)  	// 'Espelho do Ponto'
		EndIf
	EndIf

	/*
		Atilio, 30/12/2021, mudan�as no layout, sendo:
		1. A Fun��o ficar� no lugar da Chapa
		2. Na onde estava a Fun��o ficar� a Regi�o
		3. Na segunda coluna e linha do Situa��o, ficar� o Gerente
		4. Na terceira coluna e linha da Situa��o, ficar� o Supervisor
	*/

			nLin += 18

			cDet := STR0071  + PADR( If(Len(aInfo)>0,aInfo[03],SM0->M0_NomeCom) , 50)  // 'Empresa: '
			oPrinter:SayAlign(nLin,nCol,cDet,oFontP,500,100,,ALIGN_H_LEFT)

			If ( Len(aInfo) > 0 ) .And. ( aInfo[28] == 1 )
				cDet := STR0095  + PADR(Transform( If(!Empty(aInfo[27]), aInfo[27], SM0->M0_CEI),'@R ##.###.#####/##'),50)   // 'CEI: '
			ElseIf ( Len(aInfo) > 0 ) .And. ( aInfo[28] == 3 )
				cDet := STR0096  + PADR(Transform( If((aInfo[08]#""), aInfo[08], SM0->M0_CGC),'@R ###.###.###-##'),50)   // 'CPF: '
			Else
				cDet := STR0075  + PADR(Transform( If(Len(aInfo)>0,aInfo[08],SM0->M0_CGC),'@R ##.###.###/####-##'),50)   // 'CGC: '
			EndIf
			oPrinter:SayAlign(nLin,nColCab12,cDet,oFontP,500,100,,ALIGN_H_CENTER)

			nLin += 13
			cDet := PADR( If(Len(aInfo)>0,aInfo[04],SM0->M0_EndCob) , 50)
			oPrinter:SayAlign(nLin,nCol,cDet,oFontP,500,100,,ALIGN_H_LEFT)

			If lPort671
				cDet := "Emiss�o: " + dToC(Date())
				oPrinter:SayAlign(nLin, nColCab12, cDet, oFontP, 500, 100,, ALIGN_H_LEFT)
			EndIf

			nLin += 13

			oPrinter:Line(nLin,nCol,nLin,nColTot)

			nLin += 5
			cDet := STR0072  + AllTrim(SRA->RA_FILIAL) + ' - ' + SRA->RA_MAT  // ' Matr..: '
			oPrinter:SayAlign(nLin,nCol,cDet,oFontP,500,100,,ALIGN_H_LEFT)

			cDet := STR0074  + SRA->RA_Nome  // ' Nome..: '
			oPrinter:SayAlign(nLin,If(lPort671, 250, nColCab12),cDet,oFontP,500,100,,ALIGN_H_LEFT)

			//cDet := STR0073  + SRA->RA_Chapa // '  Chapa : '
			//oPrinter:SayAlign(nLin,If(lPort671, 500, nColCab13),cDet,oFontP,500,100,,ALIGN_H_LEFT)

			cDet := STR0076  + AllTrim(aFuncFunc[3]) + ' - ' + aFuncFunc[4]  // 'Funcao: '
			oPrinter:SayAlign(nLin,nColCab13,cDet,oFontP,500,100,,ALIGN_H_LEFT)

			If lPort671
				cDet := STR0112 + dToC(SRA->RA_ADMISSA) // 'Admiss�o: '
				oPrinter:SayAlign(nLin, 700, cDet, oFontP, 300, 100, , ALIGN_H_LEFT)
			EndIf

			If !Empty(SRA->RA_NSOCIAL)
				nLin += 13
				cDet := STR0100 + SRA->RA_NSOCIAL  // ' Nome Social: '
				oPrinter:SayAlign(nLin, nCol, cDet, oFontP, 500, 100, , ALIGN_H_LEFT)
			EndIf

			nLin += 13
			cDet := STR0078  + aFuncFunc[6] // ' Categ.: '
			oPrinter:SayAlign(nLin,If(lPort671, 700, nCol),cDet,oFontP,500,100,,ALIGN_H_LEFT)

			cDet := STR0077  + PADR(AllTrim(aFuncFunc[1]) + ' - ' + aFuncFunc[2] , 50) // 'C.C...: '
			oPrinter:SayAlign(nLin, If(lPort671, 250, nColCab12),cDet,oFontP,500,100,,ALIGN_H_LEFT)

			cDet := "Regi�o: XXXX"
			oPrinter:SayAlign(nLin, If(lPort671, nCol, nColCab13),cDet,oFontP,500,100,,ALIGN_H_LEFT)

			If lPort671
				cDet := STR0096 + Transform( SRA->RA_CIC, '@R ###.###.###-##') // "CPF: "
				oPrinter:SayAlign(nLin, 500, cDet, oFontP, 500, 100,,ALIGN_H_LEFT)

				//-- Imprime a Situa��o: XXXXXXXXXXXXXXXX - Per�odo: 99/99/9999 a 99/99/9999
				If Len( aAfast ) > 0
					For nX := 1 To Len( aAfast )
						nLin += 13
						cDet := aAfast[nX][1]
						oPrinter:SayAlign(nLin, nCol, cDet, oFontP, 500, 100, , ALIGN_H_LEFT)
					Next nX
				EndIf

				cDet := STR0060 + ": " + AllTrim(SRA->RA_DEPTO) + " - " + fDesc("SQB", SRA->RA_DEPTO, "QB_DESCRIC", Nil, SRA->RA_FILIAL)
				oPrinter:SayAlign(nLin, 250, cDet, oFontP, 500, 100,, ALIGN_H_LEFT)

				cDet := STR0118 // "Legenda das marca��es: O: Original, I: inclu�da, P:Pr�-assinalada"
				oPrinter:SayAlign(nLin, 500, cDet, oFontP, 500, 100,, ALIGN_H_LEFT)

			EndIf

			nLin += 13
			oPrinter:Line(nLin,nCol,nLin,nColTot)

			If !lPort671
				nLin += 5

				//-- Imprime Trocas de turnos
				nQtdeTurno:=Len(aPrtTurn)

				If !lImpTroca .OR. nQtdeTurno<2   //-- Imprime Somente a descricao do turno atual
					If !lImpTroca .OR. nQtdeTurno == 0 //-- Periodo Atual ou Superior
						cDet := STR0079  + AllTrim(SRA->RA_TnoTrab) + ' ' + fDescTno(SRA->RA_FILIAL,SRA->RA_TnoTrab, nTamTno)
					Else	 //Periodo Anterior
						cDet := STR0079  + AllTrim(Alltrim(aPrtTurn[1,1])) + ' ' + fDescTno(SRA->RA_FILIAL,aPrtTurn[1,1], nTamTno)
					EndIf
					oPrinter:SayAlign(nLin,nColCab12,cDet,oFontP,500,100,,ALIGN_H_CENTER)
					cDet := STR0060 + ": " + AllTrim(SRA->RA_DEPTO) + " - " + fDesc("SQB", SRA->RA_DEPTO, "QB_DESCRIC", Nil, SRA->RA_FILIAL)
					oPrinter:SayAlign(nLin,nCol,cDet,oFontP,500,100,,ALIGN_H_LEFT)
				Else
					If lImpTurnos // Se for o mesmo funcionario nao imprime trocas de turnos a partir da 2 pagina
						//-- Imprime Trocas de Turnos no Periodo
						For nX := 1 To nQtdeTurno
							cDet:= If(nX==1,STR0049,SPACE(Len(STR0049)))
							cDet:= cDet+DTOC(aPrtTurn[nX,2])+" "+STR0048+Alltrim(aPrtTurn[nX,1])+": "+fDescTno( SRA->RA_FILIAL, aPrtTurn[nX,1], nTamTno)
							oPrinter:SayAlign(nLin,nColCab12+12,cDet,oFontP,500,100,,ALIGN_H_LEFT)
							If nX == 1
								cDet := ' ' + STR0060 + ": " + AllTrim(SRA->RA_DEPTO)  + " - " + fDesc("SQB", SRA->RA_DEPTO, "QB_DESCRIC", Nil, SRA->RA_FILIAL) // 'Departamento: '
								oPrinter:SayAlign(nLin,nCol,cDet,oFontP,500,100,,ALIGN_H_LEFT)
							EndIf
							If nX <> nQtdeTurno
								nLin += 13
							EndIf
						Next nX
					EndIf
				EndIf

				nLinSit := nLin + 13

				//-- Imprime a Situa��o: XXXXXXXXXXXXXXXX - Per�odo: 99/99/9999 a 99/99/9999
				If Len( aAfast ) > 0
					For nX := 1 To Len( aAfast )
						nLin += 13
						cDet := aAfast[nX][1]
						oPrinter:SayAlign(nLin, nCol, cDet, oFontP, 500, 100, , ALIGN_H_LEFT)
					Next nX
				Else
					nLin += 13
				EndIf
			EndIf

			If nTipoCab==1 //Monta e Imprime Cabecalho das Marcacoes

				// Desenho do cabecalho //
				oPrinter:Box( nLin+=18, nCol	, nLin+20, nColTot, "-6" )				// Caixa da linha total

				If lBigLine
					oPrinter:Fillrect( {nLin+1, nCol+1, nLin+17, nColTot-1 }, oBrush, "-2") // Quadro na Cor Cinza
				EndIf

				oPrinter:Line( nLin, nPxData	, nLin+20, nPxData	, 0 , "-6") 		// Linha Pos Data

				For nX := 1 to Len(aNaES)
					oPrinter:Line( nLin, aNaES[nX]-6	, nLin+20	, aNaES[nX]-6, 0 , "-6")			// Linha Pos Na. Entrada/Sa�da
				Next nX

				oPrinter:Line( nLin, nPxAbonos-6	, nLin+20	, nPxAbonos-6, 0 , "-6")

				If lImpHrVal
					oPrinter:Line( nLin, nPxHrVal-6		, nLin+20	, nPxHrVal-6, 0 , "-6")
				EndIf

				oPrinter:Line( nLin, nPxHe-6		, nLin+20	, nPxHe-6, 0 , "-6")
				oPrinter:Line( nLin, nPxFalta-6		, nLin+20	, nPxFalta-6, 0 , "-6")

				If lPort671
					oPrinter:Line( nLin, nPxJor-6, nLin+20, nPxJor-6, 0 , "-6")
				EndIf

				oPrinter:Line( nLin, nPxAdnNot-6	, nLin+20	, nPxAdnNot-6, 0 , "-6")

				oPrinter:Line( nLin, nPxObser	, nLin+20	, nPxObser, 0 , "-6")

				oPrinter:SayAlign( nLin+=3 , nCol+5		, STR0042	, oFontP, nPxData, 150 , , ALIGN_H_LEFT ) //Data
				oPrinter:SayAlign( nLin, nPxData+6	, STR0043		, oFontP, nPxSemana, 150 , , ALIGN_H_LEFT ) //Semana

				nESAux := 1
				For nX := 1 to Len(aNaES)
					If nX%2 == 0
						oPrinter:SayAlign( nLin, aNaES[nX], AllTrim(Str(nESAux)) + STR0036, oFontP, aNaES[nX]+40, 150 , , ALIGN_H_LEFT ) //Saida
						nESAux++
					Else
						oPrinter:SayAlign( nLin, aNaES[nX], AllTrim(Str(nESAux)) + STR0035, oFontP, aNaES[nX]+40, 150 , , ALIGN_H_LEFT ) //Entrada
					EndIf
				Next nX

				oPrinter:SayAlign( nLin, nPxAbonos	, STR0062		, oFontP, 500, 150 , , ALIGN_H_LEFT ) //Abonos

				If lImpHrVal
					oPrinter:SayAlign( nLin, nPxHrVal	, STR0098		, oFontP, 500, 150 , , ALIGN_H_LEFT ) //Hr.Val
				EndIf

				oPrinter:SayAlign( nLin, nPxHe		, STR0068		, oFontP, 500, 150 , , ALIGN_H_LEFT ) //H.E.
				oPrinter:SayAlign( nLin, nPxFalta	, STR0069		, oFontP, 500, 150 , , ALIGN_H_LEFT ) //Falt/Atra

				If lPort671
					oPrinter:SayAlign( nLin, nPxJor, STR0113, oFontP, 500, 150, , ALIGN_H_LEFT ) // Jornada
				EndIf

				oPrinter:SayAlign( nLin, nPxAdnNot	, STR0070		, oFontP, 500, 150 , , ALIGN_H_LEFT ) //Ad. Not.
				oPrinter:SayAlign( nLin, nPxObser+6	, STR0063		, oFontP, 500, 150 , , ALIGN_H_LEFT ) //Observa��o
			ElseIf nTipoCab == 2
				nLin += 18
				oPrinter:Box( nLin, nCol , nLin+13, nColTot, "-6" )			// Caixa da linha total

				nTamCol	 := (nColTot - nCol) / 21
				nColCod1 := nCol + nTamCol
				nColDesc1:= nColCod1 + (nTamCol*4)
				nColCalc1:= nColDesc1 + nTamCol
				nColInf1 := nColCalc1 + nTamCol
				nColCod2 := nColInf1 + nTamCol
				nColDesc2:= nColCod2 + (nTamCol*4)
				nColCalc2:= nColDesc2 + nTamCol
				nColInf2 := nColCalc2 + nTamCol
				nColCod3 := nColInf2 + nTamCol
				nColDesc3:= nColCod3 + (nTamCol*4)
				nColCalc3:= nColDesc3 + nTamCol

				If lBigLine
					oPrinter:Fillrect( {nLin+1, nCol+1, nLin+13, nColTot-1 }, oBrush, "-2") // Quadro na Cor Cinza
				EndIf

				oPrinter:Line( nLin, nColCod1	, nLin+13, nColCod1		, 0 , "-6")
				If nImpHrs == 1 .or. nImpHrs == 3
					oPrinter:Line( nLin, nColDesc1	, nLin+13, nColDesc1	, 0 , "-6")
				EndIf
				oPrinter:Line( nLin, nColCalc1	, nLin+13, nColCalc1	, 0 , "-6")
				oPrinter:Line( nLin, nColInf1	, nLin+13, nColInf1		, 0 , "-6")
				oPrinter:Line( nLin, nColCod2	, nLin+13, nColCod2		, 0 , "-6")
				If nImpHrs == 1 .or. nImpHrs == 3
					oPrinter:Line( nLin, nColDesc2	, nLin+13, nColDesc2	, 0 , "-6")
				EndIf
				oPrinter:Line( nLin, nColCalc2	, nLin+13, nColCalc2	, 0 , "-6")
				oPrinter:Line( nLin, nColInf2	, nLin+13, nColInf2		, 0 , "-6")
				oPrinter:Line( nLin, nColCod3	, nLin+13, nColCod3		, 0 , "-6")
				If nImpHrs == 1 .or. nImpHrs == 3
					oPrinter:Line( nLin, nColDesc3	, nLin+13, nColDesc3	, 0 , "-6")
				EndIf
				oPrinter:Line( nLin, nColCalc3	, nLin+13, nColCalc3	, 0 , "-6")

				oPrinter:SayAlign(nLin,nCol+2,STR0064,oFontP,500,100,,ALIGN_H_LEFT) //Codigo
				oPrinter:SayAlign(nLin,nColCod1+2,STR0065,oFontP,500,100,,ALIGN_H_LEFT) //Descricao

				If nImpHrs == 1 .or. nImpHrs == 3 //Calculado
					oPrinter:SayAlign(nLin,nColDesc1+2,STR0066,oFontP,500,100,,ALIGN_H_LEFT)
				EndIf

				oPrinter:SayAlign(nLin,nColCalc1+2,STR0067,oFontP,500,100,,ALIGN_H_LEFT) //Informado

				oPrinter:SayAlign(nLin,nColInf1+2,STR0064,oFontP,500,100,,ALIGN_H_LEFT) //Codigo
				oPrinter:SayAlign(nLin,nColCod2+2,STR0065,oFontP,500,100,,ALIGN_H_LEFT) //Descricao

				If nImpHrs == 1 .or. nImpHrs == 3 //Calculado
					oPrinter:SayAlign(nLin,nColDesc2+2,STR0066,oFontP,500,100,,ALIGN_H_LEFT)
				EndIf
				oPrinter:SayAlign(nLin,nColCalc2+2,STR0067,oFontP,500,100,,ALIGN_H_LEFT) //Informado
				oPrinter:SayAlign(nLin,nColInf2+2,STR0064,oFontP,500,100,,ALIGN_H_LEFT) //Codigo
				oPrinter:SayAlign(nLin,nColCod3+2,STR0065,oFontP,500,100,,ALIGN_H_LEFT) //Descricao
				If nImpHrs == 1 .or. nImpHrs == 3 //Calculado
					oPrinter:SayAlign(nLin,nColDesc3+2,STR0066,oFontP,500,100,,ALIGN_H_LEFT)
				EndIf
				oPrinter:SayAlign(nLin,nColCalc3+2,STR0067,oFontP,500,100,,ALIGN_H_LEFT)//Informado
			EndIf
		Else
	/*
	��������������������������������������������������������������Ŀ
	� Monta o Cabecalho das Marcacoes							   �
	����������������������������������������������������������������*/
    cHtml +=									'<tr>' + CRLF
    cHtml +=										'<td colspan="' + AllTrim( Str( nColunas + 5 ) ) + '" class="etiquetas_1" bgcolor="#FAFBFC"><hr size="1"></td>' + CRLF
    cHtml +=									'</tr>' + CRLF
	cHtml +=									'<tr>' + CRLF
	cHtml +=											'<td class="etiquetas_1" bgcolor="#FAFBFC" nowrap>' + CRLF
    cHtml +=												'<div align="left">' + CRLF
	cHtml +=													STR0042 + CRLF	//'Data'
    cHtml +=												'</div>' + CRLF
	cHtml +=											'</td>' + CRLF
	cHtml +=											'<td class="etiquetas_1" bgcolor="#FAFBFC" nowrap>' + CRLF
    cHtml +=												'<div align="left">' + CRLF
	cHtml +=													STR0043 + CRLF	//'Dia'
    cHtml +=												'</div>' + CRLF
	cHtml +=											'</td>' + CRLF
	For nX := 1 To nVezes
		cHtml +=										'<td class="etiquetas_1" bgcolor="#FAFBFC" nowrap>' + CRLF
   		cHtml +=											'<div align="center">' + CRLF
    	cHtml +=												StrZero(nX,If(nX<10,1,2)) + STR0044 + CRLF	// '&#170;E.'
   		cHtml +=											'</div>' + CRLF
    	cHtml +=										'</td>' + CRLF
		cHtml +=										'<td class="etiquetas_1" bgcolor="#FAFBFC" nowrap>' + CRLF
   		cHtml +=											'<div align="center">' + CRLF
    	cHtml +=												StrZero(nX,If(nX<10,1,2)) + STR0045 + CRLF	//'&#170;S.'
   		cHtml +=											'</div>' + CRLF
    	cHtml +=										'</td>' + CRLF
	Next nX
	cHtml +=											'<td class="etiquetas_1" bgcolor="#FAFBFC" nowrap>' + CRLF
    cHtml +=												'<div align="left">' + CRLF
	cHtml +=													STR0046 + CRLF //'Observa&ccedil;&otilde;s
    cHtml +=												'</div>' + CRLF
	cHtml +=											'</td>' + CRLF
	cHtml +=											'<td class="etiquetas_1" bgcolor="#FAFBFC" nowrap>' + CRLF
    cHtml +=												'<div align="left">' + CRLF
	cHtml +=													STR0041 + CRLF	//'Motivo de Abono           Horas  Tipo da Marca&ccedil;&atilde;o'
    cHtml +=												'</div>' + CRLF
	cHtml +=											'</td>' + CRLF
	cHtml +=											'<td class="etiquetas_1" bgcolor="#FAFBFC" nowrap>' + CRLF
    cHtml +=												'<div align="left">' + CRLF
	cHtml +=													STR0047 + CRLF	//'Horas  Tipo da Marca&ccedil;&atilde;o'
    cHtml +=												'</div>' + CRLF
	cHtml +=											'</td>' + CRLF
    cHtml +=									'</tr>' + CRLF
    cHtml +=									'<tr>' + CRLF
    cHtml +=										'<td colspan="' + AllTrim( Str( nColunas + 5 ) ) + '" class="etiquetas_1" bgcolor="#FAFBFC"><hr size="1"></td>' + CRLF
    cHtml +=									'</tr>' + CRLF
EndIF

Return( cHtml )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CarAboTot � Autor � EQUIPE DE RH          � Data � 08/08/96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega os totais do SPC e os abonos                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � POR010IMP                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function CarAboTot( aTotais , aAbonados , aAbonosPer, lMvAbosEve, lMvSubAbAp )

Local aTotSpc		:= {} //-- 1-SPC->PC_PD/2-SPC->PC_QUANTC/3-SPC->PC_QUANTI/4-SPC->PC_QTABONO
Local aCodAbono		:= {}
Local cFilSP9   	:= xFilial( "SP9" , SRA->RA_FILIAL )
Local cFilSRV		:= xFilial( "SRV" , SRA->RA_FILIAL )
Local cImpHoras 	:= If(nImpHrs==1,"C",If(nImpHrs==2,"I","*")) //-- Calc/Info/Ambas
Local cAutoriza 	:= If(nImpAut==1,"A",If(nImpAut==2,"N","*")) //-- Aut./N.Aut./Ambas
Local cAliasRes		:= IF( lImpAcum , "SPL" , "SPB" )
Local cAliasApo		:= IF( lImpAcum , "SPH" , "SPC" )
Local bAcessaSPC 	:= &("{ || " + ChkRH("PONR010","SPC","2") + "}")
Local bAcessaSPH 	:= &("{ || " + ChkRH("PONR010","SPH","2") + "}")
Local bAcessaSPB 	:= &("{ || " + ChkRH("PONR010","SPB","2") + "}")
Local bAcessaSPL 	:= &("{ || " + ChkRH("PONR010","SPL","2") + "}")
Local bAcessRes		:= IF( lImpAcum , bAcessaSPH , bAcessaSPC )
Local bAcessApo		:= IF( lImpAcum , bAcessaSPL , bAcessaSPB )
Local nColSpc   	:= 0.00
Local nCtSpc    	:= 0.00
Local nPass     	:= 0.00
Local nHorasCal 	:= 0.00
Local nHorasInf 	:= 0.00
Local nX        	:= 0.00

If ( lImpRes )
	//Totaliza Codigos a partir do Resultado
	fTotalSPB(;
				@aTotSpc		,;
				SRA->RA_FILIAL	,;
				SRA->RA_Mat		,;
				dMarcIni		,;
				dMarcFim		,;
				bAcessRes		,;
				cAliasRes		;
			  )
	//-- Converte as horas para sexagenal quando impressao for a partir do resultado
	If ( lSexagenal )	// Sexagenal
		For nCtSpc := 1 To Len(aTotSpc)
			For nColSpc := 2 To 4
				aTotSpc[nCtSpc,nColSpc]:=fConvHr(aTotSpc[nCtSpc,nColSpc],'H')
			Next nColSpc
		Next nCtSpc
	EndIf
EndIf

//Totaliza Codigos a partir do Movimento
fTotaliza(;
			@aTotSpc,;
			SRA->RA_FILIAL,;
			SRA->RA_MAT,;
			bAcessApo,;
			cAliasApo,;
			cAutoriza,;
			@aCodAbono,;
			aAbonosPer,;
			lMvAbosEve,;
			lMvSubAbAp;
	 	)
//-- Converte as horas para Centesimal quando impressao for a partir do apontamento
If !( lImpRes ) .and. !( lSexagenal ) // Centesimal
	For nCtSpc :=1 To Len(aTotSpc)
		For nColSpc :=2 To 4
			aTotSpc[nCtSpc,nColSpc]:=fConvHr(aTotSpc[nCtSpc,nColSpc],'D',,5)
		Next nColSpc
	Next nCtSpc
EndIf

//-- Monta Array com Totais de Horas
If nImpHrs # 4  //-- Se solicitado para Listar Totais de Horas
	For nPass := 1 To Len(aTotSpc)
		If ( lImpRes ) //Impressao dos Resultados
			//-- Se encontrar o Codigo da Verba ou For um codigo de hora extra valido de acordo com o solicitado
			If PosSrv( aTotSpc[nPass,1] , cFilSRV , NIL , 01 )
		   	   nHorasCal 	:= aTotSpc[nPass,2] //-- Calculado - Abonado
			   nHorasInf 	:= aTotSpc[nPass,3] //-- Informado
			   If nHorasCal > 0 .and. cImpHoras $ 'C�*' .or. nHorasInf > 0 .and. cImpHoras $ 'I�*'
			  	  cHorCal := If(cImpHoras$'C�*',Transform(nHorasCal, '@E 999.99'),Space(9)) + Space(1)
				  cHorInf := If(cImpHoras$'I�*',Transform(nHorasInf, '@E 999.99'),Space(9))
				  aAdd(aTotais, { aTotSpc[nPass,1], SRV->RV_DESC , cHorCal, cHorInf } )
		  	   EndIf
	        EndIf
		ElseIf PosSP9( aTotSpc[nPass,1] , cFilSP9 , NIL , 01 )
			//-- Impressao a Partir do Movimento
			nHorasCal 	:= aTotSpc[nPass,2] //-- Calculado - Abonado
			nHorasInf 	:= aTotSpc[nPass,3] //-- Informado
			If nHorasCal > 0 .and. cImpHoras $ 'C�*' .or. nHorasInf > 0 .and. cImpHoras $ 'I�*'
				cHorCal := If(cImpHoras$'C�*',Transform(nHorasCal, '@E 999.99'),Space(9)) + Space(1)
				cHorInf := If(cImpHoras$'I�*',Transform(nHorasInf, '@E 999.99'),Space(9))
				aAdd(aTotais, { aTotSpc[nPass,1] , DescPDPon(aTotSpc[nPass,1], cFilSP9 ) , cHorCal, cHorInf } )
			EndIf
		EndIf
	Next nPass

	//-- Acrescenta as informacoes referentes aos eventos associados aos motivos de abono
	//-- Condicoes: Se nao For Impressao de Resultados
	//-- 			e Se For para Imprimir Horas Calculadas ou Ambas
	If !( lImpRes ) .and. (nImpHrs == 1 .or. nImpHrs == 3)
		For nX := 1 To Len(aCodAbono)
			// Converte as horas para Centesimal
			If !( lSexagenal ) // Centesimal
				aCodAbono[nX,2]:=fConvHr(aCodAbono[nX,2],'D',,5)
			EndIf
			aAdd(aTotais, { aCodAbono[nX,1] , DescPDPon(aCodAbono[nX,1], cFilSP9) , '  0,00'  , Transform(aCodAbono[nX,2],'@E 999.99') } )
		Next nX
	EndIf
EndIf

Return( NIL )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fTotaliza � Autor � Mauricio MR           � Data � 27/05/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Totalizar as Verbas do SPC (Apontamentos) /SPH (Acumulado) ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function fTotaliza(	aTotais		,;
							cFil		,;
							cMat		,;
							bAcessa 	,;
							cAlias		,;
							cAutoriza	,;
							aCodAbono	,;
							aAbonosPer	,;
							lMvAbosEve	,;
							lMvSubAbAp 	 ;
						 )

Local aJustifica	:= {}
Local cCodigo		:= ""
Local cPrefix		:= SubStr(cAlias,-2)
Local cTno			:= ""
Local cCodExtras	:= ""
Local cEvento		:= ""
Local cPD			:= ""
Local cPDI			:= ""
Local cCC			:= ""
Local cTPMARCA		:= ""
Local lExtra		:= .T.
Local lAbHoras		:= .T.
Local nQuaSpc		:= 0.00
Local nX			:= 0.00
Local nEfetAbono	:= 0.00
Local nQUANTC		:= 0.00
Local nQuanti		:= 0.00
Local nQTABONO		:= 0.00
//Local cAliasSP6		:= "SP6"
Local lRemonta		:= .F.
Local lContinua		:= .F.

If ( cAlias )->(dbSeek( cFil + cMat ) )
	While (cAlias)->( !Eof() .and. cFil+cMat == &(cPrefix+"_FILIAL")+&(cPrefix+"_MAT") )

        dData	:= (cAlias)->(&(cPrefix+"_DATA"))  	//-- Data do Apontamento
        cPD		:= (cAlias)->(&(cPrefix+"_PD"))    	//-- Codigo do Evento
        cPDI	:= (cAlias)->(&(cPrefix+"_PDI"))     	//-- Codigo do Evento Informado
        nQUANTC	:= (cAlias)->(&(cPrefix+"_QUANTC"))  	//-- Quantidade Calculada pelo Apontamento
        nQuanti	:= (cAlias)->(&(cPrefix+"_QUANTI"))  	//-- Quantidade Informada
        nQTABONO:= (cAlias)->(&(cPrefix+"_QTABONO")) 	//-- Quantidade Abonada
		cTPMARCA:= (cAlias)->(&(cPrefix+"_TPMARCA")) 	//-- Tipo da Marcacao
		cCC		:= (cAlias)->(&(cPrefix+"_CC")) 		//-- Centro de Custos

		If (cAlias)->( !Eval(bAcessa) )
			(cAlias)->( dbSkip() )
			Loop
		EndIf

		If dData < dMarcIni .or. dDATA > dMarcFim
			(cAlias)->( dbSkip() )
			Loop
		EndIf

		 /*
		��������������������������������������������������������������Ŀ
		� Obtem TODOS os ABONOS do Evento							   �
		����������������������������������������������������������������*/
        //-- Trata a Qtde de Abonos
        aJustifica 	:= {} //-- Reinicializa aJustifica
        nEfetAbono	:=	0.00
		If nQuanti == 0 .and. fAbonos( dData , cPD , NIL , @aJustifica , cTPMARCA , cCC , aAbonosPer ) > 0

            //-- Corre Todos os Abonos
			For nX := 1 To Len(aJustifica)

			   /*
				��������������������������������������������������������������Ŀ
				� Cria Array Analitico de Abonos com horas Convertidas.		   �
				����������������������������������������������������������������*/
				//-- Obtem a Quantidade de Horas Abonadas
				nQuaSpc := aJustifica[nX,2] //_QtAbono

				//-- Converte as horas Abonadas para Centesimal
				If !( lSexagenal ) // Centesimal
					nQuaSpc:= fConvHr(nQuaSpc,'D',,5)
				EndIf

                //-- Cria Novo Elemento no array ANALITICO de Abonos
				aAdd( aAbonados, {} )
				aAdd( aAbonados[Len(aAbonados)], dData )
				aAdd( aAbonados[Len(aAbonados)], DescAbono(aJustifica[nX,1],'C' , NIL , SRA->RA_FILIAL) )

				aAdd( aAbonados[Len(aAbonados)], StrTran(StrZero(nQuaSpc,5,2),'.',':') )
				aAdd( aAbonados[Len(aAbonados)], DescTpMarca(aBoxSPC,cTPMARCA))

				If !( lImpres )
					/*
					�������������������������������������������������������������������Ŀ
					� Trata das Informacoes sobre o Evento Associado ao Motivo corrente �
					���������������������������������������������������������������������*/
					//-- Obtem Evento Associado
					cEvento := PosSP6( aJustifica[nX,1] , SRA->RA_FILIAL , "P6_EVENTO" , 01 )
					If ( lAbHoras := ( PosSP6( aJustifica[nX,1] , SRA->RA_FILIAL , "P6_ABHORAS" , 01 ) $ " S" ) )
					    //-- Se o motivo abona Horas
						If ( lAbHoras )
							If !Empty( cEvento )
								If ( nPos := aScan( aCodAbono, { |x| x[1] == cEvento } ) ) > 0
									aCodAbono[nPos,2] := __TimeSum(aCodAbono[nPos,2], aJustifica[nX,2] ) //_QtAbono
								Else
									aAdd(aCodAbono, {cEvento,  aJustifica[nX,2] }) // Codigo do Evento e Qtde Abonada
								EndIf
							Else
								/*
								�����������������������������������������������������������������������Ŀ
								� A T E N C A O: Neste Ponto deveriamos tratar o paramentro MV_ABOSEVE  �
								�                no entanto, como ja havia a deducao abaixo e caso al-  �
								�                guem migra-se da versao 609 com o cadastro de motivo   �
								�                de abonos abonando horas mas sem o codigo, deixariamos �
								�                de tratar como antes e o cliente argumentaria alteracao�
								�                de conceito.											�
								�������������������������������������������������������������������������*/
							    //-- Se o motivo  nao possui abono associado
							    //-- Calcula o total de horas a abonar efetivamente
							    nEfetAbono:= __TimeSum(nEfetAbono, aJustifica[nX,2] ) //_QtAbono
							EndIf
						EndIf
					Else
						/*
						��������������������������������������������������������������Ŀ
						�Se Motivo de Abono Nao Abona Horas e o Codigo do Evento Relaci�
						�onado ao Abono nao Estiver Vazio, Eh como se fosse uma  altera�
						�racao do Codigo de Evento. Ou seja, Vai para os Totais      as�
						�Horas do Abono que serao subtraidas das Horas Calculadas (  Po�
						�deriamos Chamar esta operacao de "Informados via Abono" ).	   �
						�Para que esse processo seja feito o Parametro MV_SUBABAP  deve�
						�ra ter o Conteudo igual a "S"								   �
						����������������������������������������������������������������*/
						If ( ( lMvSubAbAp ) .and. !Empty( cEvento ) )
						   //-- Se o motivo  nao possui abono associado
						   //-- Calcula o total de horas a abonar efetivamente
						   If ( nPos := aScan( aCodAbono, { |x| x[1] == cEvento } ) ) > 0
								aCodAbono[nPos,2] := __TimeSum(aCodAbono[nPos,2], aJustifica[nX,2] ) //_QtAbono
						   Else
								aAdd(aCodAbono, {cEvento,  aJustifica[nX,2] }) // Codigo do Evento e Qtde Abonada
						   EndIf
						   //-- O total de horas acumulado em nEfetAbono sera deduzido do
						   //-- total de horas apontadas.
						   nEfetAbono:= __TimeSum(nEfetAbono, aJustifica[nX,2] ) //_QtAbono
						EndIf
					EndIf
				EndIf
			Next nX
		EndIf

        If !( lImpres )
	        //-- Obtem o Codigo do Evento  (Informado ou Calculado)
	        cCodigo:= If(!Empty(cPDI), cPDI, cPD )

	        //-- Obtem a posicao no Calendario para a Data

	        If ( nPos 	:= aScan(aTabCalend, {|x| x[1] ==dDATA .and. x[4] == '1E' }) ) > 0
			    //-- Obtem o Turno vigente na Data
			    cTno	:=	aTabCalend[nPos,14]
			    //-- Carrega ou recupera os codigos correspondentes a horas extras na Data
			    cCodExtras	:= ''
			    lRemonta	:= .F.
				If ( cAutoriza $ "A|N" .AND. !Empty(ALLTRIM(cPdi) ) )
					lRemonta	:= .T.
				EndIf
			    CarExtAut( @cCodExtras , cTno , cAutoriza , lRemonta )
			    lExtra:=.F.
			    If cCodigo$cCodExtras
			       lExtra:=.T.
			    EndIf
			EndIf

	        //-- Se o Evento for Alguma HE Solicitada (Autorizada ou Nao Autorizada)
	        //-- Ou  Valido Qquer Evento (Autorizado e Nao Autorizado)
	        //-- OU  Evento possui um identificador correspondente a Evento Autorizado ou Nao Autorizado.
			//-- Ou  Evento e' referente a banco de horas
			lContinua	:= .F.

			If ( lExtra .or. cAutoriza == '*' .or. (aScan(aId,{|aEvento| ( aEvento[1] == cCodigo .and. Right(aEvento[2],1) == cAutoriza ) .Or. ( aEvento[1] == cCodigo .And. cAutoriza == 'A' .And. Empty(aEvento[2]) .And. aEvento[4] == "S" ) }  ) > 0.00))
				lContinua	:= .T.
			EndIf

			If ( lContinua )

		        //-- Procura em aTotais pelo acumulado do Evento Lido
				If ( nPos := aScan(aTotais,{|x| x[1] = cCodigo  }) ) > 0
				   //-- Subtrai do evento a qtde de horas que efetivamente abona horas conforme motivo de abono
			       aTotais[nPos,2] := __TimeSum(aTotais[nPos,2],If(nQuanti>0, 0, __TimeSub(nQUANTC,nEfetAbono)))
				   aTotais[nPos,3] := __TimeSum(aTotais[nPos,3],nQuanti)
				   aTotais[nPos,4] := __TimeSum(aTotais[nPos,4],nQTABONO)

				Else
				   //-- Adiciona Evento em Acumulados
				   //-- Subtrai do evento a qtde de horas que efetivamente abona horas conforme motivo de abono
	           	   aAdd(aTotais,{cCodigo,If(nQuanti > 0, 0, __TimeSub(nQUANTC,nEfetAbono)), nQuanti,nQTABONO,lExtra })
	            EndIf
	        EndIf
         EndIf
		(cAlias)->( dbSkip() )
	End While
EndIf

Return( NIL )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fTotalSPB � Autor � EQUIPE DE RH		    � Data � 05/06/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Totaliza eventos a partir do SPB.                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function fTotalSPB(aTotais,cFil,cMat,dDataIni,dDataFim,bAcessa,cAlias)

Local cPrefix := ""

cPrefix		:= SubStr(cAlias,-2)

If ( cAlias )->( dbSeek( cFil + cMat ) )
	While (cAlias)->( !Eof() .and. cFil+cMat == &(cPrefix+"_FILIAL")+&(cPrefix+"_MAT") )

		If (cAlias)->( &(cPrefix+"_DATA") < dDataIni .or. &(cPrefix+"_DATA") > dDataFim )
			(cAlias)->( dbSkip() )
			Loop
		EndIf

		If (cAlias)->( !Eval(bAcessa) )
			(cAlias)->( dbSkip() )
			Loop
		EndIf

		If ( nPos := aScan(aTotais,{|x| x[1] == (cAlias)->( &(cPrefix+"_PD") ) }) ) > 0
			aTotais[nPos,2] := aTotais[nPos,2] + (cAlias)->( &(cPrefix+"_HORAS") )
		Else
			aAdd(aTotais,{(cAlias)->( &(cPrefix+"_PD") ),(cAlias)->( &(cPrefix+"_HORAS") ),0,0 })
		EndIf
		(cAlias)->( dbSkip() )
	End While
EndIf

Return( NIL )

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �LoadX3Box � Autor � Mauricio MR           � Data � 10.12.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna array da ComboBox                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cCampo - Nome do Campo                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function LoadX3Box(cCampo)

Local aRet:={},nCont,nIgual
Local cCbox,cString
Local aSvArea := SX3->(GetArea())

SX3->(DbSetOrder(2))
SX3->(DbSeek(cCampo))

cCbox := SX3->(X3Cbox())
//-- Opcao 1   |Opcao 2 |Opcao 3|Opcao 4
//-- 01=Amarelo;02=Preto;03=Azul;04=Vermelho
//   | �->nIgual        �->nCont
//   �->cString: 01=Amarelo
//aRet:={{01,Amarelo},{02.Preto},...}

While !Empty(cCbox)
   nCont:=AT(";",cCbox)
   nIgual:=AT("=",cCbox)
   cString:=AllTrim(SubStr(cCbox,1,nCont-1)) //Opcao
   IF nCont == 0
       aAdd(aRet,{SubStr(cString,1,nigual-1),SubStr(cString,nigual+1)})
      Exit
   Else
       aAdd(aRet,{SubStr(cString,1,nigual-1),SubStr(cString,nigual+1)})
   Endif
   cCbox:=SubStr(cCbox,nCont+1)
Enddo

RestArea(aSvArea)

Return( aRet )

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �DescTPMarc� Autor � Mauricio MR           � Data � 10.12.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna Descricao do Tipo da Marcacao                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aBox     - Array Contendo as Opcoes do Combox Ja Carregadas���
���          � cTpMarca - Tipo da Marcacao                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Ponr010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function DescTpMarca(aBox,cTpMarca)

//Local aTpMarca:={}
Local cRet:='',nTpMarca:=0
//-- SE Existirem Opcoes Realiza a Busca da Marcacao
If Len(aBox)>0
   nTpmarca:=aScan(aBox,{|xtp| xTp[1] == cTpMarca})
   cRet:=If(nTpMarca>0,aBox[nTpmarca,2],"")
EndIf

Return( cRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Monta_Per� Autor �Equipe Advanced RH     � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Gen�rico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function Monta_Per( dDataIni, dDataFim, cFil, cMat, dIniAtu, dFimAtu )

Local aPeriodos := {}
Local cFilSPO	:= xFilial( "SPO" , cFil )
Local dAdmissa	:= SRA->RA_ADMISSA
Local dPerIni   := Ctod("//")
Local dPerFim   := Ctod("//")

SPO->( dbSetOrder( 1 ) )
SPO->( dbSeek( cFilSPO , .F. ) )
While SPO->( !Eof() .and. PO_FILIAL == cFilSPO )

    dPerIni := SPO->PO_DATAINI
    dPerFim := SPO->PO_DATAFIM

    //-- Filtra Periodos de Apontamento a Serem considerados em funcao do Periodo Solicitado
    If dPerFim < dDataIni .OR. dPerIni > dDataFim
		SPO->( dbSkip() )
		Loop
    EndIf

    //-- Somente Considera Periodos de Apontamentos com Data Final Superior a Data de Admissao
    If ( dPerFim >= dAdmissa )
       aAdd( aPeriodos , { dPerIni , dPerFim , Max( dPerIni , dDataIni ) , Min( dPerFim , dDataFim ) } )
	Else
		Exit
	EndIf

	SPO->( dbSkip() )

End While

If ( ( aScan( aPeriodos, { |x| (x[1] == dIniAtu .and. x[2] == dFimAtu) }) == 0.00 ) .And. ( dDataFim >= dIniAtu ) )
	dPerIni := dIniAtu
	dPerFim	:= dFimAtu
	If !(dPerFim < dDataIni .OR. dPerIni > dDataFim)
		If ( dPerFim >= dAdmissa )
			aAdd(aPeriodos, { dPerIni, dPerFim, Max(dPerIni,dDataIni), Min(dPerFim,dDataFim) } )
		EndIf
    EndIf
EndIf

Return( aPeriodos )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CarExtAut� Autor � Mauricio MR           � Data � 24/05/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna Relacao de Horas Extras por Filial/Turno           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cCodExtras --> String que Contem ou Contera os Codigos     ���
���          � cTnoCad    --> Turno conforme o Dia                        ���
���          � cAutoriza  --> "*" Horas Autorizadas/Nao Autorizadas       ���
���          �                "A" Horas Autorizadas                       ���
���          �                "N" Horas Nao Autorizadas                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PONM010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function CarExtAut( cCodExtras , cTnoCad , cAutoriza , lRemonta )

Local aTabExtra		:= {}
Local cFilSP4		:= fFilFunc("SP4")
Local cTno			:= ""
Local lFound		:= .F.
Local lRet			:= .T.
Local nX			:= 0
Local naTabExtra	:= 0
Local ncTurno	    := 0.00

Static aExtrasTno

If ( PCount() == 0.00 )

	aExtrasTno	:= NIL

Else

	DEFAULT aExtrasTno	:= {}

	//-- Procura Tabela (Filial + Turno corrente)
	If ( lFound	:= ( SP4->( dbSeek( cFilSP4 + cTnoCad , .F. ) ) ) )
	   cTno		:=	cTnoCad
	   lFound	:=	.T.
	Else
	    //-- Procura Tabela (Filial)
	    cTno	:= Space(Len(SP4->P4_TURNO))
		lFound	:= SP4->( dbSeek(  cFilSP4 + cTno , .F.) )
	EndIf

	//-- Se Existe Tabela de HE
	If ( lFound )
	   //-- Verifica se a Tabela de HE para o Turno ainda nao foi carregada
   	   If (lRemonta) .OR. (ncTurno:=aScan(aExtrasTno,{|aTurno| aTurno[1]  == cFilSP4 .and. aTurno[2] == cTno} )) == 0.00
	      //-- Se nao Encontrou Carrega Tabela para Filial e Turno especificos
	      GetTabExtra( @aTabExtra , cFilSP4 , cTno , .F. , .F. )
	      //-- Posiciona no inicio da Tabela de HE da Filial Solicitada
		  If !Empty(aTabExtra)
			  naTabExtra:=	Len(aTabExtra)
			  //-- Corre C�digos de Hora Extra da Filial
			  For nX:=1 To naTabExtra
					//-- Se Ambos os Tipos de Eventos ou Autorizados
					If cAutoriza == '*' .or. (cAutoriza == 'A' .and. !Empty(aTabExtra[nX,4]))
						cCodExtras += aTabExtra[nX,4]+'A' //-- Cod Autorizado
					EndIf
					//-- Se Ambos os Tipos de Eventos ou Nao Autorizados
					If cAutoriza == '*' .or. (cAutoriza == 'N' .and. !Empty(aTabExtra[nX,5]))
						cCodExtras += aTabExtra[nX,5]+'N' //-- Cod Nao Autorizado
					EndIf
			  Next nX
		  EndIf
		  //-- Cria Nova Relacao de Codigos Extras para o Turno Lido
		  aAdd(aExtrasTno,{cFilSP4,cTno,cCodExtras})
	    Else
	        //-- Recupera Tabela Anteriormente Lida
	        cCodExtras:=aExtrasTno[ncTurno,3]
	    EndIf

	EndIf

EndIf

Return( lRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CarId    � Autor � Mauricio MR           � Data � 24/05/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna Relacao de Eventos da Filial						  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cFil       --> Codigo da Filial desejada					  ���
���          � aId    	  --> Array com a Relacao	                      ���
���          � cAutoriza  --> "*" Horas Autorizadas/Nao Autorizadas       ���
���          �                "A" Horas Autorizadas                       ���
���          �                "N" Horas Nao Autorizadas                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PONM010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function CarId( cFil , aId , cAutoriza )

Local nPos	:= 0.00

//-- Preenche o Array aCodAut com os Eventos (Menos DSR Mes Ant.)
SP9->( dbSeek( cFil , .T. ) )
While SP9->( !Eof() .and. cFil == P9_FILIAL )
	If ( ( Right(SP9->P9_IDPON,1) == cAutoriza ) .or. ( cAutoriza == "*" ) )
		aAdd( aId , Array( 04 ) )
		nPos := Len( aId )
		aId[ nPos , 01 ] := SP9->P9_CODIGO	//-- Codigo do Evento
		aId[ nPos , 02 ] := SP9->P9_IDPON 	//-- Identificador do Ponto
		aId[ nPos , 03 ] := SP9->P9_CODFOL	//-- Codigo do da Verba Folha
		aId[ nPos , 04 ] := SP9->P9_BHORAS	//-- Evento para B.Horas
	EndIf
	SP9->( dbSkip() )
EndDo

Return( NIL )

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fGetApo   � Autor � Leandro Dr.           � Data � 23.03.15 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna Apontamentos do funcionario.                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Ponr010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function fGetApo(aResult,dInicio,dFim,lImpAcum, aTabCalend, aMarcacoes)
Local aArea		:= GetArea()
Local cAliasQry	:= GetNextAlias()
Local cWhere	:= ""
//Local cAliasAux := If(lImpAcum,"SPH","SPC")
Local cPrefixo	:= If(lImpAcum,"PH_","PC_")
Local cJoinFil	:= ""
Local cJoinSPI	:= ""
Local cJoinSP6	:= ""
Local cAutoriza	:= If(nImpAut==1,"A",If(nImpAut==2,"N","*"))
Local aEvtDesc	:= {}
Local aEvtHe	:= {}
Local lSomaValo	:= .T.
Local nCont		:= 0
Local dLastApo	:= Ctod("//")

//Carrega tabela de Eventos do Tipo de Hora Extra

cWhere += "%"
cWhere += cPrefixo + "FILIAL = '" + SRA->RA_FILIAL + "' AND "
cWhere += cPrefixo + "MAT = '" + SRA->RA_MAT + "' AND "
cWhere += cPrefixo + "DATA >= '" + DtoS(dInicio) + "' AND "
cWhere += cPrefixo + "DATA <= '" + DtoS(dFim) + "' "
cWhere += "%"

If lImpAcum
	cJoinFil:= "%" + FWJoinFilial("SPH", "SP9") + "%"
	cJoinSPI:= "%" + FWJoinFilial("SPH", "SPI") + "%"
	cJoinSP6:= "%" + FWJoinFilial("SPH", "SP6") + "%"

	BeginSql Alias cAliasQry
	
	 	SELECT             
			SPH.PH_DATA, SPH.PH_PD, SPH.PH_PDI , SPH.PH_QUANTC, SPH.PH_QUANTI,SPH.PH_TPMARCA ,SP9.P9_CLASEV, SP9.P9_IDPON, SP6.P6_CODIGO, SP6.P6_EVENTO, SPI.PI_QUANTV
		FROM 
			%Table:SPH% SPH
		INNER JOIN %Table:SP9% SP9
		ON %exp:cJoinFil% AND SP9.%NotDel% AND SPH.PH_PD = SP9.P9_CODIGO
		LEFT JOIN  %Table:SP6% SP6
		ON %exp:cJoinSP6% AND SP6.%NotDel% AND SPH.PH_ABONO = SP6.P6_CODIGO
		LEFT JOIN  %Table:SPI% SPI
		ON %exp:cJoinSPI% AND SPI.%NotDel% AND (SPH.PH_PD = SPI.PI_PD OR SP6.P6_EVENTO = SPI.PI_PD) AND SPH.PH_MAT = SPI.PI_MAT AND SPH.PH_DATA = SPI.PI_DATA 
		WHERE
			%Exp:cWhere% AND SPH.%NotDel%
		ORDER BY SPH.PH_DATA, SPH.PH_PD
	
	EndSql 	
Else
	cJoinFil:= "%" + FWJoinFilial("SPC", "SP9") + "%"
	cJoinSPI:= "%" + FWJoinFilial("SPC", "SPI") + "%"
	cJoinSP6:= "%" + FWJoinFilial("SPC", "SP6") + "%"
	
	BeginSql Alias cAliasQry
	
	 	SELECT             
			SPC.PC_DATA, SPC.PC_PD, SPC.PC_PDI ,SPC.PC_QUANTC, SPC.PC_QUANTI, SPC.PC_TPMARCA ,SP9.P9_CLASEV, SP9.P9_IDPON, SP6.P6_CODIGO, SP6.P6_EVENTO, SPI.PI_QUANTV 
		FROM 
			%Table:SPC% SPC
		INNER JOIN %Table:SP9% SP9
		ON %exp:cJoinFil% AND SP9.%NotDel% AND SPC.PC_PD = SP9.P9_CODIGO
		LEFT JOIN  %Table:SP6% SP6
		ON %exp:cJoinSP6% AND SP6.%NotDel% AND SPC.PC_ABONO = SP6.P6_CODIGO
		LEFT JOIN  %Table:SPI% SPI
		ON %exp:cJoinSPI% AND SPI.%NotDel% AND (SPC.PC_PD = SPI.PI_PD OR SP6.P6_EVENTO = SPI.PI_PD) AND SPC.PC_MAT = SPI.PI_MAT AND SPC.PC_DATA = SPI.PI_DATA 
		WHERE
			%Exp:cWhere%  AND SPC.%NotDel%
		ORDER BY SPC.PC_DATA, SPC.PC_PD	
	EndSql 	
EndIf
While !(cAliasQry)->(Eof())

	//Hora Extra
	If (cAliasQry)->P9_CLASEV == "01"
		// Filtra hora extra de acordo com tipo selecionado no par�metro MV_PAR14 (Autorizada/ N�o autorizada)
		If cAutoriza == '*' .or. ( cAutoriza != 'N' .AND. (cAliasQry)->P9_IDPON == "029A")  //Tratamento incluido para considerar InterJornada no Relat�rio.
			If aScan(aEvtHe,{|x| x[1] == &(cPrefixo+"DATA") .And. x[2] == If(&(cPrefixo+"QUANTI")>0,&(cPrefixo+"QUANTI"),&(cPrefixo+"QUANTC")) .And. x[3] == &(cPrefixo+"TPMARCA") .And. x[4] == &(cPrefixo+"PD")}) > 0
				(cAliasQry)->(aAdd(aResult,{&(cPrefixo+"DATA"),"1",0,If(&("PI_QUANTV") > 0,&("PI_QUANTV"),"")}))
			Else
				(cAliasQry)->(aAdd(aResult,{&(cPrefixo+"DATA"),"1",If(&(cPrefixo+"QUANTI")>0,&(cPrefixo+"QUANTI"),&(cPrefixo+"QUANTC")),If(&("PI_QUANTV") > 0,&("PI_QUANTV"),"")}))
				aAdd(aEvtHe,{&(cPrefixo+"DATA"),If(&(cPrefixo+"QUANTI")>0,&(cPrefixo+"QUANTI"),&(cPrefixo+"QUANTC")),&(cPrefixo+"TPMARCA"),&(cPrefixo+"PD")})
			EndIf
		ElseIf Ascan(aCodAut, { |x| x[3] == Iif(Empty((cAliasQry)->(&(cPrefixo+"PDI"))),(cAliasQry)->(&(cPrefixo+"PD")),(cAliasQry)->(&(cPrefixo+"PDI"))) .AND. x[4] == cAutoriza } ) > 0
			If aScan(aEvtHe,{|x| x[1] == &(cPrefixo+"DATA") .And. x[2] == If(&(cPrefixo+"QUANTI")>0,&(cPrefixo+"QUANTI"),&(cPrefixo+"QUANTC")) .And. x[3] == &(cPrefixo+"TPMARCA") .And. x[4] == &(cPrefixo+"PD")}) > 0
				(cAliasQry)->(aAdd(aResult,{&(cPrefixo+"DATA"),"1",0,If(&("PI_QUANTV") > 0,&("PI_QUANTV"),"")}))
			Else
				(cAliasQry)->(aAdd(aResult,{&(cPrefixo+"DATA"),"1",If(&(cPrefixo+"QUANTI")>0,&(cPrefixo+"QUANTI"),&(cPrefixo+"QUANTC")),If(&("PI_QUANTV") > 0,&("PI_QUANTV"),"")}))
				aAdd(aEvtHe,{&(cPrefixo+"DATA"),If(&(cPrefixo+"QUANTI")>0,&(cPrefixo+"QUANTI"),&(cPrefixo+"QUANTC")),&(cPrefixo+"TPMARCA"),&(cPrefixo+"PD")})
			EndIf
		EndIf

	//Faltas/Atrasos/Saida antecipada
	ElseIf (cAliasQry)->P9_CLASEV $ "02*03*04*05"
		If aScan(aEvtDesc,{|x| x[1] == &(cPrefixo+"DATA") .And. x[2] == If(&(cPrefixo+"QUANTI")>0,&(cPrefixo+"QUANTI"),&(cPrefixo+"QUANTC")) .And. x[3] == &(cPrefixo+"TPMARCA") .And. x[6] == &(cPrefixo+"PD")}) > 0
			(cAliasQry)->(aAdd(aResult,{&(cPrefixo+"DATA"),"2",0,If(&("PI_QUANTV") > 0,&("PI_QUANTV"),"")}))
		Else
			If &("PI_QUANTV") > 0
				lSomaValo := aScan(aEvtDesc,{|x| x[1] == &(cPrefixo+"DATA") .And. x[4] == &("P6_EVENTO") .And. x[5] == &("PI_QUANTV")}) == 0
			EndIf
			(cAliasQry)->(aAdd(aResult,{&(cPrefixo+"DATA"),"2",If(&(cPrefixo+"QUANTI")>0,&(cPrefixo+"QUANTI"),&(cPrefixo+"QUANTC")),If(&("PI_QUANTV") > 0 .And. lSomaValo, &("PI_QUANTV"),"")}))
			aAdd(aEvtDesc,{&(cPrefixo+"DATA"),If(&(cPrefixo+"QUANTI")>0,&(cPrefixo+"QUANTI"),&(cPrefixo+"QUANTC")),&(cPrefixo+"TPMARCA"), &("P6_EVENTO"), &("PI_QUANTV"), &(cPrefixo+"PD")})
		EndIf

	//Adicional Noturno
	ElseIf (cAliasQry)->P9_IDPON $ "003N*004A*027N*028A"
		// Filtra adicional noturno de acordo com tipo selecionado no par�metro MV_PAR14 (Autorizada/ N�o autorizada)
		If cAutoriza == '*'
			(cAliasQry)->(aAdd(aResult,{&(cPrefixo+"DATA"),"3",If(&(cPrefixo+"QUANTI")>0,&(cPrefixo+"QUANTI"),&(cPrefixo+"QUANTC")),If(&("PI_QUANTV") > 0,&("PI_QUANTV"),"")}))
		Elseif cAutoriza == 'A'
			If (cAliasQry)->P9_IDPON $ "004A*028A"
				(cAliasQry)->(aAdd(aResult,{&(cPrefixo+"DATA"),"3",If(&(cPrefixo+"QUANTI")>0,&(cPrefixo+"QUANTI"),&(cPrefixo+"QUANTC")),If(&("PI_QUANTV") > 0,&("PI_QUANTV"),"")}))
			Endif
		Else
			If (cAliasQry)->P9_IDPON $ "003N*027N"
				(cAliasQry)->(aAdd(aResult,{&(cPrefixo+"DATA"),"3",If(&(cPrefixo+"QUANTI")>0,&(cPrefixo+"QUANTI"),&(cPrefixo+"QUANTC")),If(&("PI_QUANTV") > 0,&("PI_QUANTV"),"")}))
			Endif
		Endif
	EndIf
	(cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

RestArea(aArea)


If lPort671
	// Obtem a dura��o da jornada realizada
	For nCont := 1 To Len(aMarcacoes)
		If aMarcacoes[nCont][AMARC_DATAAPO] != dLastApo
			dLastApo := aMarcacoes[nCont][AMARC_DATAAPO]
			nHorasJor := CalcHoraJor(dLastApo, nCont, aMarcacoes, aTabCalend)
			If nHorasJor > 0
				aAdd(aResult, {DtoS(dLastApo), "4", nHorasJor, ""})
			EndIf
		EndIf
	Next nCont
EndIf

Return Nil

/*/{Protheus.doc} CalcHoraJor
Calcula a dura��o da jornada de acordo com as marca��es, considerando tamb�m as Horas extras e o Hor�rio noturno
@type  Static Function
@author C�cero Alves
@since 24/06/2022
@param dDataApo, Data, Dia que ser� avaliado
@param nPosMarc, Num�rico, Posi��o no aMarcacoes da primeira marca��o do dia
@param aMarcacoes, Array, Marca��es realizadas no per�odo
@param aTabCalend, Array, Calend�rio do ponto
@return nHorasJor, Num�rico, Dura��o da jornada realizada, incluindo as horas extras e considerado o hor�rio noturno reduzido
/*/
Static Function CalcHoraJor(dDataApo, nPosMarc, aMarcacoes, aTabCalend)

	Local nCont 		:= 0
	Local nHoras 		:= 0
	Local nHorasTot		:= 0
	Local nHorasNTot	:= 0
	Local nHorasNot		:= 0
	Local nHorasJor		:= 0
	Local nLenMarc		:= Len(aMarcacoes)
	Local nTab			:= AScan(aTabCalend, {|x| x[CALEND_POS_DATA_APO] == dDataApo })

	If nTab > 0 .And. aTabCalend[nTab][CALEND_POS_TIPO_DIA] == "S" // Apenas para dias trabalhados
		For nCont := nPosMarc To nLenMarc Step 2

			If nCont == nLenMarc .Or. aMarcacoes[nCont][AMARC_DATAAPO] != dDataApo .Or. aMarcacoes[nCont + 1 ][AMARC_DATAAPO] != dDataApo
				Exit
			EndIf

			If "E" $ aMarcacoes[nCont][AMARC_TIPOMARC]
				fCalHoras(	aMarcacoes[nCont][AMARC_DATA]			,;
							aMarcacoes[nCont][AMARC_HORA]			,;
							aMarcacoes[nCont + 1][AMARC_DATA]		,;
							aMarcacoes[nCont + 1][AMARC_HORA]		,;
							@nHoras    								,;	//05 -> <@>Horas Normais Apontadas
							@nHorasNot      						,;	//06 -> <@>Horas Noturnas Apontadas
							.T.										,;	//07 -> Apontar Horas Noturnas
							aMarcacoes[nCont][AMARC_DATA]			,;	//08 -> Data Inicial Para a Hora Noturna
							NIL										,;	//09 -> <@>Horas de Acrescimo Noturno
							aTabCalend[nTab][CALEND_POS_INI_H_NOT]	,;	//10 -> Inicio do Horario Noturno
							aTabCalend[nTab][CALEND_POS_FIM_H_NOT]	,;	//11 -> Final do Horario Noturno
							aTabCalend[nTab][CALEND_POS_MIN_H_NOT]	,;	//12 -> Minutos do Horario Noturno (N�o deve reduzir as horas noturnas)
							NIL     								,;	//13 -> Apenas Acrescimo Noturno
							NIL										 ;	//14 -> Periodo da Hora Noturna
						)

				nHorasTot := SomaHoras(nHorasTot, nHoras)
				nHorasNTot := SomaHoras(nHorasNTot, nHorasNot)
				nHoras := 0
				nHorasNot := 0
			EndIf
		Next

		nHorasJor := SomaHoras(nHorasTot, nHorasNTot)

	EndIf

Return nHorasJor

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fImpSign  � Autor � Leandro Dr.           � Data � 23.03.15 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime espa�o para assinatura do funcionario.             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Ponr010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function fImpSign(oPrinter)


	//Mensagem antes da assinatura
	If !Empty(cMenPad1) .or. !Empty(cMenPad2)
		oPrinter:SayAlign(nLinTot-15,nCol+2,cMenPad1 + cMenPad2,oFontM,500,100,,ALIGN_H_LEFT)
	EndIf

	oPrinter:SayAlign(nLinTot-20,nCol,Replicate("_",50),oFontP,nColTot,100,,ALIGN_H_CENTER)

	oPrinter:SayAlign(nLinTot-10,nCol,STR0013,oFontP,nColTot,100,,ALIGN_H_CENTER) // 'Assinatura do Funcionario'
Return Nil

/*/{Protheus.doc} fValMVCOL
Valida o Numero maximo de Entrada e Saida (MV_COLMARC).
@type	function
@author	Mick William da Silva
@since	09/06/2015
/*/
Static Function fValMVCOL()
	Local lRet := .T. //- Customizado para ignorar o MV_COLMARC
	/*
	Local lRet := .F.

	IF SuperGetmv("MV_COLMARC") <= 5 .And. SuperGetmv("MV_COLMARC") >= 1
		lRet := .T.
	Endif
	*/

			Return lRet

/*/{Protheus.doc} Imp_Cabec
Imprime o cabecalho do espelho do ponto
@type	function
@author	EQUIPE DE RH
@since	09/04/1996
/*/
Static Function Pnr010ImpBh(nSaldoAnt, nSaldoAtu, nCredito, nDebito, nTotHrVal)

	Local aArea 	:= GetArea()
	Local nValor 	:= 0
	Local nHrValori	:= 0
	Local lRet		:= .F.

	nSaldoAnt	:= 0
	nDebito		:= 0
	nCredito	:= 0
	nSaldoAtu	:= 0
	nTotHrVal	:= 0

	dbSelectArea( "SPI" )
	SPI->(dbSetOrder(2))
	SPI->(dbSeek( SRA->RA_FILIAL + SRA->RA_MAT ))
	While SPI->( !Eof() .And. PI_FILIAL + PI_MAT == SRA->( RA_FILIAL + RA_MAT ) )

		PosSP9(SPI->PI_PD, SRA->RA_FILIAL, "P9_TIPOCOD")
		// Totaliza Saldo Anterior
		If SPI->PI_DATA < dPerIni
			If !(SPI->PI_STATUS == 'B' .AND. SPI->PI_DTBAIX < dPerIni)
				If (SPI->PI_STATUS == 'B' .AND. SPI->PI_DTBAIX <= dPerFim)
					If SP9->P9_TIPOCOD $  "1*3"
						nValor := SPI->PI_QUANT
						If lSexagenal
							nSaldoAnt := __TimeSum(nSaldoAnt,nValor)
							nSaldoAtu := __TimeSub(nSaldoAtu,nValor)
						Else
							nSaldoAnt := nSaldoAnt + fConvhR(nValor,"D",,5)
							nSaldoAtu := nSaldoAtu - fConvhR(nValor,"D",,5)
						EndIf
					Else
						nValor := SPI->PI_QUANT
						If lSexagenal
							nSaldoAnt := __TimeSub(nSaldoAnt,nValor)
							nSaldoAtu := __TimeSum(nSaldoAtu,nValor)
						Else
							nSaldoAnt := nSaldoAnt - fConvhR(nValor,"D",,5)
							nSaldoAtu := nSaldoAtu + fConvhR(nValor,"D",,5)
						EndIf
					EndIf
				Else
					If SP9->P9_TIPOCOD $  "1*3"
						nValor := SPI->PI_QUANT
						If lSexagenal
							nSaldoAnt := __TimeSum(nSaldoAnt,nValor)
						Else
							nSaldoAnt := nSaldoAnt + fConvhR(nValor,"D",,5)
						EndIf
					Else
						nValor := SPI->PI_QUANT
						If lSexagenal
							nSaldoAnt := __TimeSub(nSaldoAnt,nValor)
						Else
							nSaldoAnt := nSaldoAnt - fConvhR(nValor,"D",,5)
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf SPI->PI_DATA <= dPerFim
			If !(SPI->PI_STATUS == 'B' .AND. SPI->PI_DTBAIX <= dPerFim)
				If SP9->P9_TIPOCOD $  "1*3"
					nValor := SPI->PI_QUANT
					nHrValori := SPI->PI_QUANTV
					If lSexagenal
						nCredito  := __TimeSum(nCredito,nValor)
						If lImpHrVal
							nTotHrVal := __TimeSum(nTotHrVal,nHrValori)
						EndIf
					Else
						nCredito  := nCredito + fConvhR(nValor,"D",,5)
						If lImpHrVal
							nTotHrVal += fConvhR(nHrValori,"D",,5)
						EndIf
					EndIf
				Else
					nValor		:= SPI->PI_QUANT
					nHrValori	:= SPI->PI_QUANTV
					If lSexagenal
						nDebito   := __TimeSum(nDebito,nValor)
						If lImpHrVal
							nTotHrVal := __TimeSub(nTotHrVal,nHrValori)
						EndIf
					Else
						nDebito	  := nDebito + fConvhR(nValor,"D",,5)
						If lImpHrVal
							nTotHrVal -= fConvhR(nHrValori,"D",,5)
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			Exit
		Endif

		dbSelectArea( "SPI" )
		dbSkip()

	Enddo

	If nSaldoAnt <> 0 .or. nCredito > 0 .or. nDebito > 0
		lRet := .T.
		If lSexagenal
			nSaldoAtu := __TimeSum(nSaldoAtu, __TimeSub( __TimeSum( nSaldoAnt , nCredito ) , nDebito ))
		Else
			nSaldoAtu := ( nSaldoAtu + nSaldoAnt + nCredito ) - nDebito
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} Pnr010Afas
Busca a situacao e afastamentos do funcionario.
@type	function
@author	M. Silveira
@since	09/02/2017
@history 21/03/2019, C�cero Alves, DRHPONTP-3178 - Alotera��o para mostrar apenas a situa��o atual do funcion�rio e o per�odo correto do afastamento
/*/
Static Function Pnr010Afas( dDtIniP, dDtFimP, aAfast )

	Local nX		:= 0
	Local nReg		:= 0
	Local cSitu		:= ""
	Local aAux  	:= {}
	Local aArea 	:= GetArea()
	Local aSitFunc  := RetSituacao( SRA->RA_FILIAL, SRA->RA_MAT, .F., dDtFimP,,,, dDtIniP )

	If Len(aSitFunc) > 0

		Do Case
		Case aSitFunc[1] == "A"
			cSitu := STR0090 //"AFASTADO"
		Case aSitFunc[1] == "F"
			cSitu := STR0091 //"FERIAS"
		Case aSitFunc[1] == "T"
			cSitu := STR0092 //"TRANSFERIDO"
		Case aSitFunc[1] == "D"
			cSitu := STR0093 //"DEMITIDO"
		OtherWise
			cSitu := STR0094 //"NORMAL"
		EndCase

		If aSitFunc[1] $ "A/F"

			aAfast	:= {}
			fRetAfas( dDtIniP, dDtFimP,,,,, @aAux )
			nReg := Len(aAux)
			aSort(aAux,,, {|x| x[3] > x[3]}) // Ordena do mais rescente para o mais antigo
			If nReg > 0
				For nX := 1 To nReg

					//Considera somente os afastamentos contidos, que come�am ou terminam no periodo de apontamento
					If ( dDtIniP >= aAux[nX][3] .And. dDtFimP <= aAux[nX][4] ) .Or.;
							( aAux[nX][4] >= dDtIniP .And. aAux[nX][4] <= dDtFimP ) .Or.;
							( aAux[nX][3] >= dDtIniP .And. aAux[nX][3] <= dDtFimP ) .Or.;
							( Empty(aAux[nX][4])     .And. aAux[nX][3] <= dDtFimP )

						// Exibe apenas o afastamento mais recente, para coicidir com a situa��o atual do funcion�rio
						aAdd( aAfast, { STR0088 + cSitu + " - " + STR0089 + dToC(aAux[nX][3]) + " a " + dToC(aAux[nX][4]) } ) // "Sit...: "#" Per�odo: "
						EXIT
					EndIf

				Next nX

				If Empty( aAfast )
					cSitu := STR0094 //"NORMAL"
					aAdd( aAfast, { STR0088 + cSitu } )
				EndIf

			EndIf
		Else
			aAdd( aAfast, { STR0088 + cSitu } )
		EndIf

	EndIf

	RestArea( aArea )

Return()

/*/{Protheus.doc} SetUpSign
intacia a classe FwTotvsSign e realiza o login no totvs assinatura eletr�nica
@type  Static Function
@author C�cero Alves
@since 02/02/2022
@param oSign, Objeto, Inst�ncia da classe FwTotvsSign - deve ser passado por refer�ncia
@return lRetorno, L�gico, Indica se foi poss�vel criar o objeto e realizar o login
/*/
Static Function SetUpSign(oSign)

	Local cUser     := AllTrim(GetMv('MV_RHTAEUS', , ""))
	Local cPassword := AllTrim(GetMv('MV_RHTAEPW', , ""))
	Local lRetorno 	:= .T.

	If !Empty(cUser) .And. !Empty(cPassword) .And. !("@" $ cUser )

		cUser := rc4crypt( cUser, "123456789", .F., .T.)
		cPassword := rc4crypt( cPassword, "123456789", .F., .T.)

		If FindFunction("FwTotvsSign")
			If !Empty(SuperGetMv('MV_SIGNURL',, ""))
				oSign := FwTotvsSign()
				If !oSign:isAuthenticated()
					oSign:authenticate( cUser, cPassword )
					If !oSign:isAuthenticated()
						// "N�o foi poss�vel efetuar autentica��o no TAE" - "Verifique os par�metros MV_SIGNURL, MV_RHTAEUS e MV_RHTAEPW"
						Help( ,, STR0086,, STR0102, 1,,,,,,, {STR0103} ) //
						lRetorno := .F.
					EndIf
				EndIf
			Else
				//"N�o foi poss�vel efetuar autentica��o no TAE" - "Verifique os par�metros MV_SIGNURL, MV_RHTAEUS e MV_RHTAEPW"
				Help( ,, STR0086,, STR0102, 1,,,,,,, {STR0103} )
				lRetorno := .F.
			EndIf
		Else
			// "LIB desatualizada" - "Para execu��o da integra��o com o Totvs Assinatura Eletr�nica � necess�rio que a LIB esteja atualizada com vers�o igual ou superior a 02/12/2021"
			Help( ,, STR0086,, STR0104, 1,,,,,,, {STR0105})
			lRetorno := .F.
		EndIf
	Else
		// 'Acesse a op��o "Config. Assina. Eletr." na rotina Controle de Espelho de Ponto
		// para configurar o usu�rio e senha de integra��o com o Totvs Assinatura Eletr�nica'
		Help( ,, STR0086,, STR0102, 1,,,,,,, {STR0110})
		lRetorno := .F.
	EndIf

Return lRetorno

/*/{Protheus.doc} SendEsp
Realiza o envio de um arquivo para o TAE e solicita a assinatura
@type  Static Function
@author C�cero Alves
@since 02/02/2022
@param cPathFile, Caractere, diret�rio e nome do arquivo que ser� enviado
@param cNameFile, Caractere, Nome do arquivo enviado para o TAE
@return lretorno, L�gico, Indica se o arquivo foi enviado com sucesso
/*/
Static Function SendEsp(cPathFile, cNameFile)

	Local lretorno 	:= .T.
	local nId
	Local cMsg		:= ""

	Default cPathFile := ""
	Default cNameFile := ""

	lOk := oSign:uploadDocument( cPathFile )
	jResponse := oSign:getResponse()

	If lOk
		nId := jResponse[ "data" ]

		//Envia solicita��o para o usu�rio assinar
		lOk := oSign:requestAction( jResponse[ "data" ], { { SRA->RA_EMAIL, "0" } } )
		jResponse := oSign:getResponse()

		// Atualiza a tabela RS4
		GravaSR4( cNameFile, nId )

		// "Solicita��o enviada para "
		aAdd(aLogTAE[1], SRA->RA_FILIAL + " - " + SRA->RA_MAT + ": " + STR0109 + AllTrim(SRA->RA_EMAIL))

		If Empty(aLogTitle[1])
			aLogTitle[1] := STR0106 // "Espelhos de Ponto enviados: "
		EndIf

	Else
		cMsg := If(jResponse[ "description" ] != NIL, jResponse[ "description" ], STR0114) //"N�o foi poss�vel realizar o upload do arquivo para o TAE. Verifique se o usu�rio utilizado para a integra��o possui permiss�o para enviar arquivos."
		aAdd(aLogTAE[2], SRA->RA_FILIAL + " - " + SRA->RA_MAT + ": " + cMsg)
		If Empty(aLogTitle[2])
			aLogTitle[2] := STR0107	//"Espelhos de Ponto n�o enviados:"
		EndIf
	EndIf

Return lretorno

/*/{Protheus.doc} GravaSR4
Grava na tabela SR4 o controle dos arquivos gerados com c�digo de barras ou que foram enviados para o TAE
@type  Static Function
@author C�cero Alves
@since 23/02/2022
@param cNomeDoc, Caractere, Nome do arquivo
@param cID, Caractere, ID do arquivo no TAE
/*/
Static Function GravaSR4(cNomeDoc, cID)

	Local aRS4Area	:= GetArea()
	Local cAliasRS4	:= GetNextAlias()
	Local lCriaRS4	:= .F.
	Local cPerIni	:= DtoS(dPerIni)
	Local cPerFim	:= DtoS(dPerFim)
	Local cFilRS4	:= xFilial("RS4",SRA->RA_FILIAL)

	Default cNomeDoc := ""
	Default cID := 0

	BeginSql alias cAliasRS4
		SELECT
			COUNT(*) AS registro
		FROM %table:RS4% RS4
		WHERE RS4.RS4_FILIAL = %exp:cFilRS4%
			AND RS4.RS4_MAT = %exp:SRA->RA_MAT%
			AND RS4.RS4_DATAI = %exp:cPerIni%
			AND RS4.RS4_DATAF = %exp:cPerFim%
			AND RS4.RS4_STATUS IN ('1','2')
			AND RS4.%notDel%
	EndSql

	If ((cAliasRS4)->registro == 0, lCriaRS4 := .T., Nil)

		(cAliasRS4)->(dbCloseArea())

		If lCriaRS4
			dbSelectArea("RS4")
			RecLock("RS4", .T.)
			RS4->RS4_FILIAL := SRA->RA_FILIAL
			RS4->RS4_MAT	:= SRA->RA_MAT
			RS4->RS4_PER	:= DtoS(dPerIni) + DtoS(dPerFim)
			RS4->RS4_DATAI	:= dPerIni
			RS4->RS4_DATAF	:= dPerFim
			RS4->RS4_CODEBA	:= cCodeBar
			RS4->RS4_STATUS	:= "2" //Pendente
			If RS4->(ColumnPos("RS4_TPDOC")) > 0
				RS4->RS4_TPDOC	:= If(lTAE, "1", "2")
				If lTAE
					RS4->RS4_NDOC	:= cNomeDoc
					RS4->RS4_ID		:= cId
					RS4->RS4_DTINTE	:= Date()
				EndIf
			EndIf

			MsUnLock()
		EndIf

		RestArea(aRS4Area)

		Return

/*/{Protheus.doc} GetHorarios
Retorna os hor�rios previstos para o funcion�rio de acordo com o calend�rio
@type Static Function
@author C�cero Alves
@since 27/06/2022
@return aHorarios, Array, Array com a data, turno e hor�rios
/*/
Static Function GetHorarios()

	Local aHorarios := {}
	Local nI		:= 0
	Local cOrdem	:= ""
	Local aAux		:= {}
	Local nSum		:= 0
	Local aLastAux	:= {}
	Local dDataAlt	:= cTod("//")

	For nI := 1 To Len(aTabCalend)

		nSum := 0
		aAux := {}
		cOrdem := aTabCalend[nI][CALEND_POS_ORDEM]
		dDataAlt := aTabCalend[nI][CALEND_POS_DATA]

		While nI <= Len(aTabCalend) .And. aTabCalend[nI][CALEND_POS_ORDEM] == cOrdem
			Aadd(aAux, aTabCalend[nI][CALEND_POS_HORA])
			nSum += aTabCalend[nI][CALEND_POS_HORA]
			nI++
		EndDo

		//Retorna para a sequ�ncia anterior
		nI--

		//Se tiver hor�rio cadastrado para o dia e for diferente do hor�rio anterior
		If nSum > 0  .And. !ArrayCompare( aAux, aLastAux)
			aLastAux := aAux

			Aadd(aHorarios, {})
			Aadd(aTail(aHorarios), dDataAlt)
			Aadd(aTail(aHorarios), aTabCalend[nI][CALEND_POS_TURNO] + " - " + fDescTno( SRA->RA_FILIAL, aTabCalend[nI][CALEND_POS_TURNO]))
			Aadd(aTail(aHorarios), aAux)

		EndIf
	Next nI

Return aHorarios

/*/{Protheus.doc} fQuebra
Realiza a quebra de p�gina no relat�rio
@type  Static Function
@author C�cero Alves
@since 06/10/2022
/*/
Static Function fQuebra(oPrinter, nTamLin, nColunas,  lTerminal)

	fImpSign(oPrinter)
	oPrinter:EndPage()
	oPrinter:StartPage()
	Imp_Cabec( nTamLin, nColunas,  lTerminal, 0, oPrinter )

Return

/*/{Protheus.doc} GetMarcDes
Carrega as marca��es desconsideradas no aMarcDes e as exclu� do aMarcacoes
@type  Static Function
@author C�cero Alves
@since 06/10/2022
/*/
Static Function GetMarcDes(aMarcacoes, aMarcDes)

	Local nI := 1
	Local nNewTam := Len(aMarcacoes)

	While nI <= nNewTam
		If aMarcacoes[nI, 27] == "D"
			aAdd(aMarcDes, {aMarcacoes[nI, 1], StrTran(StrZero(aMarcacoes[nI,2],5,2),'.',':'), aMarcacoes[nI, 29]})
			aDel(aMarcacoes, nI)
			nNewTam--
		Else
			nI++
		EndIf
	EndDo

	aSize(aMarcacoes, nNewTam)

Return

//Encapsulando por causa do Code Analysis
Static Function fGetParam(cParam, lHelp, cPadrao, cFilSist)
Return SuperGetMV(cParam, lHelp, cPadrao, cFilSist)
