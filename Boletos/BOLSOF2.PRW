#Include "rwmake.CH"
#Include "RPTDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#Include "Topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ BOLBRD	³ Autor ³ Nelson Bispo          ³ Data ³ 19/06/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao do Boleto - SOFISA                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Faz Santa Terezinha LTDA                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
¦¦+--------------+------------------------------------------+----------------------+----------------+¦¦
¦¦¦ Analista     ¦  SYSTOP			                        ¦ Data Alteracao 	   ¦ 23/09/2015 	 ¦¦
¦¦+--------------+------------------------------------------+----------------------+----------------+¦¦
¦¦¦ Alteração    ¦ BOLETO RECONFIGURADO LAYOUT, TROCADO FUNCAO DE IMPRESSAO. INCLUI FUNCAO DE        ||
¦¦¦              | ENVIAR BOLETO POR EMAIL.                                                          ||
¦¦+--------------+-----------------------------------------------------------------------------------¦¦
¦¦+--------------+------------------------------------------+----------------------+----------------+¦¦
¦¦¦ Analista     ¦  SYSTOP			                        ¦ Data Alteracao 	   ¦ 29/09/2015 	 ¦¦
¦¦+--------------+------------------------------------------+----------------------+----------------+¦¦
¦¦¦ Alteração    ¦ INLCUSAO DE FILTRO, PEGAR APENAS TITULOS PARA BANCO. INCLUSAO DE FILTRO POR       ||
¦¦¦              | VENCIMENTO				                                                         ||
¦¦+--------------+-----------------------------------------------------------------------------------¦¦
¦¦+--------------+------------------------------------------+----------------------+----------------+¦¦
¦¦¦ Analista     ¦  SYSTOP			                        ¦ Data Alteracao 	   ¦ 02/10/2015 	 ¦¦
¦¦+--------------+------------------------------------------+----------------------+----------------+¦¦
¦¦¦ Alteração    ¦ AJUSTE POSICIONAMENTO DA TABELA DE CLIENTE PARA GRAVAR NOME CERTO DO ARQUIVO      ||
¦¦¦              | 							                                                         ||
¦¦+--------------+-----------------------------------------------------------------------------------¦¦
*/

User Function BOLSOF()

	PRIVATE lExec    := .F.
	PRIVATE cIndexName := ''
	PRIVATE cIndexKey  := ''
	PRIVATE cFilter    := ''
	PRIVATE ELFIL	   := ''

	SetPrvt("NDIGBOL,NDIGBAR,CALIAS")
	SetPrvt("NFI,NFF,SERIE,_CLINHA,FATOR,ARQ,CGRUPO,PERG")
	SetPrvt("I,NVAL,FILTIMP,ARETURN,AINFO,NLASTKEY,CSTRING")
	SetPrvt("WNREL,NCONT,XI,_cCampo,NDIGITO,Nnumero")

	aArea:= SE1->(GetARea())

	_nTeste  :=0
	_nTipo	 :=0
	Tamanho  := "M"
	titulo   := "Impressao de Boleto com Codigo de Barras-Banco Sofisa"
	cDesc1   := "Este programa destina-se a impressao do Boleto com Codigo de Barras."
	cDesc2   := ""
	cDesc3   := ""
	cString  := "SE1"
	wnrel    := "BOLETO"
	lEnd     := .F.
	cPerg 	 := "ELIZ001"
	aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	nLastKey := 0

	dbSelectArea("SE1")

	If Funname()!="MATA410"
		ValidPerg()
		If !Pergunte (cPerg,.T.)
			Return(.T.)
		EndIf
	Else
		mv_par01:=SD2->D2_DOC
		mv_par02:=SD2->D2_DOC
		mv_par03:=SE1->E1_CLIENTE
		mv_par04:=SE1->E1_CLIENTE
		mv_par05:=1
		mv_par06:=1
		mv_par07:=8 //juros
		mv_par08:=1
		mv_par09:=10
		mv_par10:=""
		mv_par11:=SE1->E1_EMISSAO
		mv_par12:=SE1->E1_EMISSAO
	Endif

	ELFIL := xFilial("SE1")

	cIndexName	:= Criatrab(Nil,.F.)
	cIndexKey	:= "DTOS(E1_VENCREA)+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+DTOS(E1_EMISSAO)+E1_PORTADO+E1_CLIENTE"

	cFilter		+= "E1_FILIAL=='"+xFilial("SE1")+"'.And.E1_SALDO>0.And."
	cFilter		+= "E1_NUM>=MV_PAR01.And.E1_NUM<=MV_PAR02.And."
	cFilter		+= "E1_CLIENTE>=MV_PAR03.And.E1_CLIENTE<=MV_PAR04.And."
	cFilter		+= "E1_EMISSAO>=MV_PAR11.And.E1_EMISSAO<=MV_PAR12.And."
	cFilter		+= "E1_VENCREA>=MV_PAR13.And.E1_VENCREA<=MV_PAR14.And."
	cFilter		+= "E1_PORTADO!='001'.And.E1_PORTADO!='011'.And.E1_PORTADO!='399'.And. Alltrim(E1_TIPO)!='CH'.And. E1_TIPO<>'IR-'.AND. E1_TIPO<>'IN-'.AND.E1_TIPO<>'PI-'.AND."
	cFilter		+= "E1_XCARBAN = 'B' .And. "
	cFilter		+= "E1_PORTADO == '637' "

	IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")
	DbSelectArea("SE1")

	cMarca    := GetMark()

	#IFNDEF TOP
		DbSetIndex(cIndexName + OrdBagExt())
	#ENDIF
	dbGoTop()

	@ 001,001 TO 400,700 DIALOG oDlg TITLE "Seleção de Titulos"
	@ 001,001 TO 170,350 BROWSE "SE1" MARK "E1_OK"
	@ 180,310 BMPBUTTON TYPE 01 ACTION (lExec := .T.,Close(oDlg))
	@ 180,280 BMPBUTTON TYPE 02 ACTION (lExec := .F.,Close(oDlg))

	ACTIVATE DIALOG oDlg CENTERED

	dbGoTop()

	If lExec
		_x:=NIL
		Processa({|lEnd|MontaRel()})
	Endif

	RetIndex("SE1")
	Ferase(cIndexName+OrdBagExt())


	RestArea(aArea)

Return()




/* Inicio - Geracao de Boleto PDF */

User Function B637WS(_filial,_titulo,_pref,_client,_loja,_parc)

	PRIVATE lExec    	:= .F.
	PRIVATE cIndexName 	:= ''
	PRIVATE cIndexKey  	:= ''
	PRIVATE cFilter    	:= ''

	Private cPERG		:= ''
	Private ARETURN		:= ''
	Private NLASTKEY	:= 0

	RpcSetType(3)
	RpcSetEnv( "01",_filial,,,'FIN')

	_nTeste  :=0
	_nTipo	 :=0
	Tamanho  := "M"
	titulo   := "Impressao de Boleto com Codigo de Barras-Banco Sofisa"
	cDesc1   := "Este programa destina-se a impressao do Boleto com Codigo de Barras."
	cDesc2   := ""
	cDesc3   := ""
	cString  := "SE1"
	wnrel    := "BOLETO"
	lEnd     := .F.
	cPerg 	 := "ELIZ001"
	aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	nLastKey := 0
	_cQry 	 := ""


	_cQry := " SELECT R_E_C_N_O_ REC "
	_cQry += " FROM "+RetsqlName("SE1") + " E1 "
	_cQry += " WHERE E1_FILIAL = '"+_filial+"' AND E1_PREFIXO = '"+_pref+"' AND e1.d_e_l_e_t_ <> '*' "
	_cQry += " and E1_NUM = '"+_titulo+"' and E1_PARCELA = '"+_parc+"' and e1.e1_TIPO ='NF' "

	TCQUERY _cQry NEW ALIAS "TITSOF"

	DBSELECTAREA("SE1")
	SE1->(dbGoTo(TITSOF->REC))

	if ALLTRIM(SE1->E1_NUM) == ""
		dbSelectArea("SE1")
		SE1->(dbSetOrder(1))
		SE1->(dbSeek(_filial+_pref+_titulo+_parc+"FT "))
	endif

	dbSelectArea("SF2")
	SF2->(dbSetOrder(1))
	SF2->(dbSeek(_filial+_titulo+"1  "+_client+_loja))

	mv_par01:=SF2->F2_DOC
	mv_par02:=SF2->F2_DOC
	mv_par03:=SE1->E1_CLIENTE
	mv_par04:=SE1->E1_CLIENTE
	mv_par05:=1
	mv_par06:=1
	mv_par07:=8 //juros
	mv_par08:=1
	mv_par09:=10
	mv_par10:=""
	mv_par11:=SE1->E1_EMISSAO
	mv_par12:=SE1->E1_EMISSAO

	cIndexName	:= Criatrab(Nil,.F.)
	cIndexKey	:= "DTOS(E1_VENCREA)+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+DTOS(E1_EMISSAO)+E1_PORTADO+E1_CLIENTE"

	cFilter		+= "E1_FILIAL=='"+_filial+"'.And.E1_SALDO>0.And."
	cFilter		+= "E1_NUM='"+SE1->E1_NUM+"'.And."
	cFilter		+= "E1_CLIENTE='"+SE1->E1_CLIENTE+"'.And."
	cFilter		+= "E1_PREFIXO='"+SE1->E1_PREFIXO+"'.And."
	cFilter 	+= "E1_PARCELA='"+SE1->E1_PARCELA+"'.And."
	cFilter		+= "E1_PORTADO!='001'.And.E1_PORTADO!='011'.And.E1_PORTADO!='399'.And. Alltrim(E1_TIPO)!='CH'.And. E1_TIPO<>'IR-'.AND. E1_TIPO<>'IN-'.AND.E1_TIPO<>'PI-'.AND."
	cFilter		+= "E1_XCARBAN = 'B' .And. "
	cFilter		+= "E1_PORTADO == '637' "

	IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")
	DbSelectArea("SE1")

	cMarca    := GetMark()

	#IFNDEF TOP
		DbSetIndex(cIndexName + OrdBagExt())
	#ENDIF

	dbGoTop()
	lExec := .T.
	If lExec
		_x:=NIL
		Processa({|lEnd|MontaRel(.T.)})
	Endif

	RetIndex("SE1")
	Ferase(cIndexName+OrdBagExt())
	SE1->(DBCLOSEAREA())
	TITSOF->(DBCLOSEAREA())

Return()

/* Fim - Geracao de Boleto PDF */

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa ³MontaRel³Autor³ Nelson Bispo                 ³Data³20/06/09  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o³ IMPRESSAO DO BOLETO BANCO SOFISA COM CODIGO DE BARRAS     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso      ³ Faz Santa Terezinha LTDA                                    ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MontaRel(lWSPDF)
	 lWSPDF := .F.
	//LOCAL aDadosEmp := {}

	/*
	aSM0  := FWSM0Util():GetSM0Data( '01' , SE1->E1_FILIAL , {"M0_NOMECOM", "M0_ENDCOB", "M0_BAIRCOB", "M0_CIDCOB", "M0_ESTCOB", "M0_CGC", "M0_INSC", "M0_TEL", "M0_CEPCOB"} )
	cCGC  := aSM0[Ascan(aSM0,{|x| x[1] == "M0_CGC"}),2]
	cInsc := aSM0[Ascan(aSM0,{|x| x[1] == "M0_INSC"}),2]
	cCEP  := aSM0[Ascan(aSM0,{|x| x[1] == "M0_CEPCOB"}),2]

	aDadosEmp    := {	aSM0[Ascan(aSM0,{|x| x[1] == "M0_NOMECOM"}),2]   ,; //[1]Nome da Empresa
	aSM0[Ascan(aSM0,{|x| x[1] == "M0_ENDCOB"}),2]      					 ,; //[2]Endereço
	AllTrim(aSM0[Ascan(aSM0,{|x| x[1] == "M0_BAIRCOB"}),2])+", ";			//[3]Complemento
	+AllTrim(aSM0[Ascan(aSM0,{|x| x[1] == "M0_CIDCOB"}),2])+", ";		    //[3]Complemento	
	+aSM0[Ascan(aSM0,{|x| x[1] == "M0_ESTCOB"}),2] ,; 						//[3]Complemento
	"CEP: "+Transform(cCEP,"@R 99999-999")             			,;          //[4]CEP
	"PABX/FAX: "+aSM0[Ascan(aSM0,{|x| x[1] == "M0_TEL"}),2]     ,;          //[5]Telefones
	"CNPJ: "+Transform(cCGC,"@R 99.999.999/9999-99")            ,;          //[6] CNPJ
	"I.E.: "+Transform(cInsc,"@R 999.999.999.")           }                 //[7]I.E
	*/
	DbSelectArea("SM0")
	SM0->(DbSetOrder(1))
	SM0->(DbSeek('01'+SE1->E1_FILIAL))

	

	cFile := Substr(SE1->E1_CLIENTE+'-' + POSICIONE("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_NOME"  ),1,20) + '-' + Alltrim(SE1->E1_NUM) + '-' + Alltrim(SE1->E1_PARCELA)
	if lWSPDF
		cFile := MD5(ALLTRIM(SE1->E1_FILIAL+SE1->E1_NUM+SE1->E1_CLIENTE+SE1->E1_LOJA+ALLTRIM(SE1->E1_PARCELA)))
		cCaminho := "\web\ws\boleto\"
		FErase( cCaminho+cFile+".pdf" )
		lEmail := .F.
	Else
		cCaminho := "\spool\"
		FErase( cCaminho+cFile+".pdf" )

		lEmail:= MsgYesNo("Deseja enviar por email ?")

	ENdIf

	If lEmail .or. lWSPDF
		oPrn := FwMSPrinter():New( cFile, IMP_PDF , .T. , cCaminho, .T., , , , , .F., ,.F. )
		oPrn:cPathPDF := cCaminho

		//Marca o campo E1_BOLETO do título como gerado ('1') - 02/05/2022
		U_FlagBol(SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA))
	Else
		oPrn := FwMSPrinter():New( cFile, IMP_SPOOL , .T. , , .T., , , , , .T., ,.F. )
		oPrn:Setup()

	EndIf

	oPrn:SetPortrait() // ou SetLandscape()
	oPrn:SetPaperSize(9) //A4 LEITESOL

	DbSelectArea("SE1")
	dbGotop()
	ProcRegua(RecCount())

	Private _nCont  := 1
	Private cPerg
	Private _aTitulos := {}
	Private _nDig     := 0  // Variável para Dígito
	Private _vSoma	  := 0  // Soma variável apra cálculo do nosso número
	Private _vResto	  := 0
	Private _vCalc 	  := 0
	Private _nDigbar  := "1"
	Private _cNum     := ""
	Private _cFiltro  := ""
	Private _cNumBorde:= ""

	While SE1->(!EOF())
		IncProc("Lendo títulos para geração de boletos...")

		//Quando nao estiver selecionado despreza o registro

		if !lWSPDF
			If !Marked("E1_OK")
				DbSkip()
				Loop
			EndIf
		EndIf

		//Posiciona o SA6 (Bancos)
		DbSelectArea("SA6")
		DbSetOrder(1)
		DbSeek(xFilial("SA6") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA,.T.)
		xDigAg := SA6->A6_DVAGE
		xDigCt := SA6->A6_DVCTA

		//Posiciona o SA1 (Cliente)
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA,.T.)

		DbSelectArea("SE1")

		Aadd(_aTitulos,{"","",0,"","","","","","","","","","","","","",""})
		If Alltrim(SE1->E1_PREFIXO)=="99"
			_cNum := "1 - "+Alltrim(SE1->E1_NUM)+" "+SE1->E1_PARCELA
		Else
			_cNum := Alltrim(SE1->E1_PREFIXO)+" - "+Alltrim(SE1->E1_NUM)+" "+SE1->E1_PARCELA
		Endif

		_aTitulos[_nCont][01] := _cNum            				//[01] Prexifo+Numero+Parcela do Titulo
		_aTitulos[_nCont][02] := SE1->E1_VENCTO   				//[02] Vencimento
		_aTitulos[_nCont][03] := SE1->E1_SALDO+SE1->E1_SDACRES  //[03] Saldo
		_aTitulos[_nCont][07] := alltrim(Posicione("SEE",1,SE1->E1_FILIAL+SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA,"EE_CODCART"))                    		//[07] Carteira
		_aTitulos[_nCont][07] := alltrim(Posicione("SEE",1,SE1->E1_FILIAL+SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA,"EE_CODCART"))                    		//[07] Carteira

		//Nosso Numero........................................... Cria número sequencial para nosso número E1.
		If !Empty(SE1->E1_NUMBCO)
			_aTitulos[_nCont][04] := SUBSTR(AllTrim(SE1->E1_NUMBCO),1,12) //[04] Nosso número
		Else
			//P3 Tecnologia - Code Analisys 29/05/2020
			_aTitulos[_nCont][04] := Soma1(fRetMV("MV_XSEQ637"))
			PutMV("MV_XSEQ637",_aTitulos[_nCont][04])
			NNumDV(_aTitulos[_nCont][04],SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_FILIAL)
		EndIf

		_aTitulos[_nCont][05] :=StrZero(Val(SE1->E1_AGEDEP),4)          		//[05] Agência
		_aTitulos[_nCont][06] :=StrZero(Val(SE1->E1_CONTA),7)		 	   	//[06] Conta Corrente
		_aTitulos[_nCont][08] := StrZero(Day(SE1->E1_EMISSAO),2)+"/"+StrZero(Month(SE1->E1_EMISSAO),2)+"/"+StrZero(Year(SE1->E1_EMISSAO),4)
		_aTitulos[_nCont][09] := "("+SA1->A1_COD+") "+Alltrim(SA1->A1_NOME)  // [09]Código + Razão Social
		_aTitulos[_nCont][10] := Alltrim(SA1->A1_END)			//[10]Endereco
		_aTitulos[_nCont][11] := Alltrim(SA1->A1_MUN)     		//[11] Cidade
		_aTitulos[_nCont][12] := SA1->A1_EST                	//[12] Estado
		_aTitulos[_nCont][13] := SA1->A1_CEP                    //[13] CEP
		_aTitulos[_nCont][14] := SA1->A1_CGC					//[14] CGC
		_aTitulos[_nCont][15] := StrZero(Day(dDatabase),2)+"/"+StrZero(Month(dDatabase),2)+"/"+StrZero(Year(dDatabase),4)
		_aTitulos[_nCont][16] := StrZero(Val(SE1->E1_CONTA),7)       //[16] Numero da Conta Corrente
		_aTitulos[_nCont][17] := SA1->A1_PESSOA					//[17] Pessoa Física ou Jurídica

		if !lWSPDF
			If Marked("E1_OK")
				Impress(oPrn,_aTitulos)
			EndIf
		Else
			Impress(oPrn, _aTitulos)
		EndIf
		dbSkip()
	EndDo

	oPrn:EndPage()     // Finaliza a página

	oPrn:Preview()     // Visualiza antes de imprimir

	If lEmail

		cEmail     := SA1->A1_EMAIL+Space(200)

		SetPrvt("oDlg1","oSay1","oEmail","oSBtn1")

		oDlg1      := MSDialog():New( 092,232,204,938,"Informar Email",,,.F.,,,,,,.T.,,,.T. )
		oSay1      := TSay():New( 016,012,{||"E-mail:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oEmail     := TGet():New( 015,045,{|u| If(PCount()>0,cEmail:=u,cEmail)},oDlg1,288,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cEmail",,)
		oSBtn1     := SButton():New( 032,307,1,{|| fEnviaE(),oDlg1:End() },oDlg1,,"", )

		oDlg1:Activate(,,,.T.)

	EndIf

Return()


Static Function fEnviaE()//envia email do boleto

	Local  _assunto
	Local cAccount, cPassword, cServer
	Local lMailAut := .T.

	cAccount := GetMv("EL_RLCONTA")
	cPassword := GetMv("EL_RLSENHA")
	cServer  := GetMv("EL_RLSERV")
	lMailAut := GetMv("EL_RLAUTEN")

	cMV1  := "MV_RELSSL"
	cMV2  := "MV_RELTLS"

	_assunto:="Boletos Elizabeth "

	xTxt:= " Prezados "+chr(13)+chr(10)
	xTxt+= " Segue boleto em anexo. "+chr(13)+chr(10)
	xTxt+= chr(13)+chr(10)
	xTxt+= " SOFISA : Se desejar atualizá-la use o link http://www.sofisa.com.br/html/classic/produtos-servicos/outros/2-via-de-boleto.shtm   "+chr(13)+chr(10)
	xTxt+= " Prazo para o titulo receber Instrução de Banco para Cartório SOFISA (637): 08 Dias CORRIDOS (Contando Sábado, Domingos e Feriados) "


	U_ACSENDM(cAccount,cPassword,cServer,GetMv("EL_RLMAIL"),cEmail,_assunto, xTxt ,cCaminho+cFile+".pdf")

	MsgInfo("Email enviado !")

Return ()


Static Function Impress(oPrint,_aTitulos)

	Private _cBarra  := SPACE(44)
	Private _nPosHor := 0
	Private _nLinha  := 0
	Private _nEspLin := 0
	Private _nTxtBox := 0
	Private _nPosVer := 0

	nDigbol    := SPACE(1)
	nDigbar    := SPACE(1)
	NFi        := Space(6)
	NFf        := Space(6)
	Serie      := Space(3)
	Nnumero    := Space(11)
	_cLinha     := ""
	Fator      := CTOD("07/10/1997")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela de Entrada de Dados                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	FiltImp    := ""
	aInfo      := {}
	nHeight    := 15
	lBold      := .F.
	lUnderLine := .F.
	lPixel     := .T.
	lPrint     := .F.

	oFont06  := TFont():New( "Arial",,06,,.F.,,,,,.F. )
	oFont06B := TFont():New( "Arial",,06,,.T.,,,,,.F. )
	oFont07  := TFont():New( "Arial",,07,,.F.,,,,,.F. )
	oFont07B := TFont():New( "Arial",,07,,.T.,,,,,.F. )
	oFont08  := TFont():New( "Arial",,12,,.F.,,,,,.F. )
	oFont08B := TFont():New( "Arial",,12,,.T.,,,,,.F. )
	oFont09  := TFont():New( "Arial",,09,,.F.,,,,,.F. )
	oFont09B := TFont():New( "Arial",,14,,.T.,,,,,.F. )
	oFont10  := TFont():New( "Arial",,10,,.F.,,,,,.F. )
	oFont10B := TFont():New( "Arial",,10,,.T.,,,,,.F. )
	oFont11  := TFont():New( "Arial",,11,,.F.,,,,,.F. )
	oFont11B := TFont():New( "Arial",,11,,.T.,,,,,.F. )
	oFont12  := TFont():New( "Arial",,12,,.F.,,,,,.F. )
	oFont12B := TFont():New( "Arial",,12,,.T.,,,,,.F. )
	oFont13  := TFont():New( "Arial",,13,,.F.,,,,,.F. )
	oFont13B := TFont():New( "Arial",,13,,.T.,,,,,.F. )
	oFont14  := TFont():New( "Arial",,14,,.F.,,,,,.F. )
	oFont14B := TFont():New( "Arial",,21,,.T.,,,,,.F. )
	oFont15  := TFont():New( "Arial",,15,,.F.,,,,,.F. )
	oFont15B := TFont():New( "Arial",,20,,.T.,,,,,.F. )
	oFont16  := TFont():New( "Arial",,16,,.F.,,,,,.F. )
	oFont16B := TFont():New( "Arial",,16,,.T.,,,,,.F. )
	oFont17  := TFont():New( "Arial",,17,,.F.,,,,,.F. )
	oFont17B := TFont():New( "Arial",,17,,.T.,,,,,.F. )
	oFont18  := TFont():New( "Arial",,18,,.F.,,,,,.F. )
	oFont18B := TFont():New( "Arial",,18,,.T.,,,,,.F. )
	oFont19  := TFont():New( "Arial",,19,,.F.,,,,,.F. )
	oFont19B := TFont():New( "Arial",,19,,.T.,,,,,.F. )
	oFont20  := TFont():New( "Arial",,20,,.F.,,,,,.F. )
	oFont20B := TFont():New( "Arial",,20,,.T.,,,,,.F. )
	oFont21  := TFont():New( "Arial",,21,,.F.,,,,,.F. )
	oFont21B := TFont():New( "Arial",,21,,.T.,,,,,.F. )
	oFont22  := TFont():New( "Arial",,22,,.F.,,,,,.F. )
	oFont22B := TFont():New( "Arial",,27,,.T.,,,,,.F. )
	oFont23  := TFont():New( "Arial",,23,,.F.,,,,,.F. )
	oFont23B := TFont():New( "Arial",,23,,.T.,,,,,.F. )
	oFont24  := TFont():New( "Arial",,24,,.F.,,,,,.F. )
	oFont24B := TFont():New( "Arial",,24,,.T.,,,,,.F. )
	oFont25  := TFont():New( "Arial",,25,,.F.,,,,,.F. )
	oFont25B := TFont():New( "Arial",,25,,.T.,,,,,.F. )
	oFont26  := TFont():New( "Arial",,26,,.F.,,,,,.F. )
	oFont26B := TFont():New( "Arial",,26,,.T.,,,,,.F. )
	oFont27  := TFont():New( "Arial",,27,,.F.,,,,,.F. )
	oFont27B := TFont():New( "Arial",,27,,.T.,,,,,.F. )
	oFont28  := TFont():New( "Arial",,28,,.F.,,,,,.F. )
	oFont28B := TFont():New( "Arial",,28,,.T.,,,,,.F. )
	oFont29  := TFont():New( "Arial",,29,,.F.,,,,,.F. )
	oFont29B := TFont():New( "Arial",,29,,.T.,,,,,.F. )
	oFont30  := TFont():New( "Arial",,30,,.F.,,,,,.F. )
	oFont30B := TFont():New( "Arial",,30,,.T.,,,,,.F. )

	npag  :=1
	serie := ""
	nfi   := ""
	nff   := ""
	_nPosHor := 20
	_nLinha  := 01
	_nEspLin := 75//84

// Posicionamento Vertical
	_nPosVer := 20

// Posicionamento do Texto Dentro do Box
	_nTxtBox := 25//05

	oprn:SETPAPERSIZE(9) // <==== ajuste para papel A4

	oprn:StartPage()
	MIRFT07A()
	oprn:EndPage()

	npag:= npag + 1

Return(.T.)

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao	 ³ MIRFT07A	³ Autor ³ Nelson Bispo          ³ Data ³ 05/05/03 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Impressao do Boleto                                        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso		 ³ Faz Santa Terezinha LTDA                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MIRFT07A()

	Local cMsgBrad1 := getMV("MV_MSGSOF1")
	Local cMsgBrad2 := getMV("MV_MSGSOF2")
	Local cMsgBrad3 := getMV("MV_MSGSOF3")
	Local cMsgBrad4 := getMV("MV_MSGSOF4")
	Local elNomCom := SM0->M0_NOMECOM

// Monta codigo de barras do titulo
	MIRFT07B()

// Monta Linha digitavel
	MIRFT07D()

// Recibo do Sacado
// Box Cedente
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+25,_nTxtBox+0140,"Sofisa",ofont15B,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+25,_nTxtBox+380,"|637-7|",ofont22B,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+10,_nPosVer+1600,"Comprovante de Entrega",ofont14B,100)

	_nLinha  := _nLinha + 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0830)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Cedente",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox,_nPosVer+0010,elNomCom,ofont09B,100)

// Box Agencia/Codigo Cedente
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0830,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1180)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0840,"Agência/Código Cedente",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox,_nPosVer+0850,transform(_aTitulos[_nCont][05],"@R 9999")+"-"+xDigAg+" / "+transform(_aTitulos[_nCont][06],"@R 9999999")+"-"+xDigCt,ofont08B,100)

// Box Motivos nao entrega
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1180,_nPosHor+(_nLinha*_nEspLin)+(2*_nEspLin),_nPosVer+2230)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1290,"Motivos de não entrega(para uso da empresa entregadora)",ofont08,100)

	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0050)+_nTxtBox,_nPosVer+1210,"( )Mudou-se",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0050)+_nTxtBox,_nPosVer+1490,"( )Ausente",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0050)+_nTxtBox,_nPosVer+1820,"( )Não existe n. indicado",ofont08,100)

	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0100)+_nTxtBox+0025,_nPosVer+1210,"( )Recusado",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0100)+_nTxtBox+0025,_nPosVer+1490,"( )Não Procurado",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0100)+_nTxtBox+0025,_nPosVer+1820,"( )Falecido",ofont08,100)

	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0150)+_nTxtBox+0045,_nPosVer+1210,"( )Desconhecido",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0150)+_nTxtBox+0045,_nPosVer+1490,"( )Endereço Insuficiente",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin+0150)+_nTxtBox+0045,_nPosVer+1820,"( )Outros (anotar no verso)",ofont08,100)

// Box Sacado
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0830)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Sacado",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0010,_aTitulos[_nCont][09],ofont08B,100) // Alteração 06032014 - Modificado fonte ofont09B para ofont08B devido a fonte estar muito grande no boleto

// Box Nosso Numero
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0830,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1180)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0840,"Nosso Número",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0860,Substr(_aTitulos[_nCont][07],1,3)+"/"+alltrim(SE1->E1_NUMBCO),ofont08B,100)

// Box Vencimento
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0200)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Vencimento",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0030,StrZero(Day(_aTitulos[_nCont][02]),2)+"/"+StrZero(Month(_aTitulos[_nCont][02]),2)+"/"+StrZero(Year(_aTitulos[_nCont][02]),4),ofont08B,100)

// Box Numero do Documento
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0200,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0520)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0210,"N° do documento",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0220,_aTitulos[_nCont][01],ofont08B,100)

// Box Especie Moeda
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0520,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0830)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0530,"Espécie Moeda",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0650,"R$",ofont08,100)

// Box Valor do Documento
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0830,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1180)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0840,"Valor do Documento",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0940,transform(_aTitulos[_nCont][03],"@E 999,999,999.99"),ofont08B,100)

// Box Recebimento bloqueto
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0340)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Recebi(emos) o bloqueto",ofont08,100)

// Box Data
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0340,_nPosHor+(_nLinha*_nEspLin),_nPosVer+560)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0350,"Data",ofont08,100)

// Box Assinatura
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0560,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1180)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0570,"Assinatura",ofont08,100)

// Box Data
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1180,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1520)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1190,"Data",ofont08,100)

// Box Entregador
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1520,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1530,"Entregador",ofont08,100)

// Box Local de Pagamento
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer    ,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1910)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox    ,_nPosVer+0010,"Local de Pagamento",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox    ,_nPosVer+0275,"BANCO SOFISA S.A.",ofont09B,150)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+33 ,_nPosVer+0275,"PAGAR PREFERENCIALMENTE EM QUALQUER AGENCIA SOFISA.",ofont09B,150)

// Box Data de Processamento
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1910,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1920,"Data de Processamento",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+1980,_aTitulos[_nCont][15],ofont08B,100)

	_nLinha  += 1
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,Replicate("-",200),ofont12,100)

// Box Recibo do Sacado
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+25,_nTxtBox+0140,"Sofisa",ofont15B,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+25 ,_nTxtBox+0380,"|637-7|",ofont22B,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+25 ,_nPosVer+1720,"Recibo do Sacado",ofont14B,100)

// Box Local de Pagamento
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer    ,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1650)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox    ,_nPosVer+0010,"Local de Pagamento",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox    ,_nPosVer+0275,"BANCO SOFISA S.A.",ofont09B,150)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+33 ,_nPosVer+0275,"PAGAR PREFERENCIALMENTE EM QUALQUER AGENCIA SOFISA.",ofont09B,150)

// Box Logotipo
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin)+4*_nEspLin,_nPosVer+2230)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1740,"|637-7|",ofont12B,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1870,"Recibo do Sacado",ofont11B,100)

// Box Cedente
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1650)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Cedente",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox,_nPosVer+0010,elNomCom,ofont09B,100)

// Box Data do documento
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0420)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Data do documento",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0100,_aTitulos[_nCont][08],ofont08B,100)

// Box Numero do Documento
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0420,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0790)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0430,"N° do documento",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0450,_aTitulos[_nCont][01],ofont08B,100)

// Box Especie Doc
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0790,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1050)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0800,"Espécie Doc",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0900,"DM",ofont08,100)

// Box Aceite
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1050,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1170)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1060,"Aceite",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+1080,"Não",ofont08,100)

// Box Data do Processamento
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1170,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1650)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1180,"Data do Processamento",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+1280,_aTitulos[_nCont][15],ofont08B,100)

// Box Uso do Banco
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0300)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Uso do Banco",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0050,"  ",ofont08,100)

// Box Cip
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0300,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0420)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0310,"Cip",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0315,"000",ofont08,100)

// Box Carteira
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0420,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0552)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0430,"Carteira",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0480,alltrim(_aTitulos[_nCont][07]),ofont08,100)

// Box Especie Moeda
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0552,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0790)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0562,"Espécie moeda",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0652,"R$",ofont08,100)

// Box Quantidade
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0790,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1170)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0800,"Quantidade",ofont08,100)

// Box Valor
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1170,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1650)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1180,"Valor",ofont08B,100)

// Box Logotipo
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+70,_nPosVer+1700,"Sofisa",ofont30B,100)

// Box Instrucoes
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin)+9*_nEspLin,_nPosVer+1650)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+1680,"Pagável nas agências Sofisa",ofont10B,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+10,_nPosVer+0010,"Instruções de responsabilidade do cedente.",ofont09B,100)

// Box Vencimento
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"Vencimento",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+2060,StrZero(Day(_aTitulos[_nCont][02]),2)+"/"+StrZero(Month(_aTitulos[_nCont][02]),2)+"/"+StrZero(Year(_aTitulos[_nCont][02]),4),ofont08B,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0010,"Sujeito a protesto após vencimento",ofont09B,100)
	mv_par07:=iif(CtoD('18/03/2015')<=CtoD(_aTitulos[_nCont][8]),8,5)
	oprn:say(_nPosHor+(((_nLinha+1)-1)*_nEspLin),_nPosVer+0010,"Valor Juros mora dia "+Str(Round(Val(str(_aTitulos[_nCont][03]*(mv_par07/100)/30)),3),10,2),ofont09B,100)
	oprn:say(_nPosHor+(((_nLinha+2)-1)*_nEspLin),_nPosVer+0010,mv_par10,ofont09B,100)
	oprn:say(_nPosHor+(((_nLinha+3)-1)*_nEspLin),_nPosVer+0010,"Não pagar através de depósito em conta",ofont09B,100)

// Box Agencia/Codigo Cedente
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"Agência/Código Cedente",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox,_nPosVer+1940,transform(_aTitulos[_nCont][05],"@R 9999")+"-"+xDigAg+" / "+transform(_aTitulos[_nCont][06],"@R 9999999")+"-"+xDigCt,ofont08B,100)

// Box Cart./nosso numero
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"Cart./nosso número",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+1960,alltrim(_aTitulos[_nCont][07])+"/"+Alltrim(SE1->E1_NUMBCO),ofont08B,100)

// Box Valor do documento
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"1(=) Valor do documento",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+2000,transform(_aTitulos[_nCont][03],"@E 999,999,999.99"),ofont08B,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0010,cMsgBrad1,ofont09B,100)

// Box Desconto / Abatimento
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"2(-) Desconto/abatimento",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0010,Alltrim(cMsgBrad2),ofont09B,100)   // mensagem texto livre
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0050,Alltrim(cMsgBrad3),ofont09B,100)   // mensagem texto livre
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0090,Alltrim(cMsgBrad4),ofont09B,100)   // mensagem texto livre

// Box Outras deducoes
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"3(-) Outras deduções",ofont08,100)

// Box Mora / Multa
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"4(+) Mora/Multa",ofont08,100)

// Box Outros acrescimos
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"5(+) Outros Acréscimos",ofont08,100)

// Box Valor cobrado
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"6(=) Valor cobrado",ofont08,100)

// Box Sacado
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin)+_nEspLin,_nPosVer+2230)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Sacado:",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0150,_aTitulos[_nCont][09],ofont08B,100) // Nome Sacado
	If _aTitulos[_nCont][17]=="F"
		oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1400,"CPF.: "+Transform(_aTitulos[_nCont][14],"@R 999.999.999-99"),ofont08B,100) // CPF Sacado
	ElseIf _aTitulos[_nCont][17]=="J"
		oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1400,"CNPJ.: "+Transform(_aTitulos[_nCont][14],"@R 99.999.999/9999-99"),ofont08B,100) // CNPJ Sacado
	Endif
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+0030,_nPosVer+0150,_aTitulos[_nCont][10],ofont08B,100) // End. Sacado
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+0060,_nPosVer+0150,Transform(_aTitulos[_nCont][13],"@R 99999-999"),ofont08B,100) // CEP Sacado
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+0060,_nPosVer+0550,_aTitulos[_nCont][11],ofont08B,100) // Cidade Sacado
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+0060,_nPosVer+1000,_aTitulos[_nCont][12],ofont08B,100) // Estado Sacado
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+0120,_nPosVer+0010,"Sacador/Avalista:",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+0170,_nPosVer+1750,"Autenticação Mecânica",ofont08,100)

// Ficha de compensacao
	_nLinha  += 3
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,Replicate("-",200),ofont12,100)
// Linha Digitavel
	_nLinha  += 1
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+25,_nTxtBox+0140,"Sofisa",ofont15B,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+25 ,_nTxtBox+0380,"|637-7|",ofont22B,100)

	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+0045,_nTxtBox+0700,_clinha,oFont15B,100)

// Box Local de Pagto
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer    ,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1650)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox    ,_nPosVer+0010,"Local de Pagamento",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox    ,_nPosVer+0275,"BANCO SOFISA S.A.",ofont09B,150)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+33 ,_nPosVer+0275,"PAGAR PREFERENCIALMENTE EM QUALQUER AGENCIA SOFISA.",ofont09B,150)

// Box Vencimento
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"Vencimento",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+2060,StrZero(Day(_aTitulos[_nCont][02]),2)+"/"+StrZero(Month(_aTitulos[_nCont][02]),2)+"/"+StrZero(Year(_aTitulos[_nCont][02]),4),ofont08B,100)

// Box Cedente
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1650)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Cedente",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox,_nPosVer+0010,elNomCom,ofont09B,100)

// Box Agencia/Codigo Cedente
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"Agência/Código Cedente",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin+30)+_nTxtBox,_nPosVer+1940,transform(_aTitulos[_nCont][05],"@R 9999")+"-"+xDigAg+" / "+transform(_aTitulos[_nCont][06],"@R 9999999")+"-"+xDigCt,ofont08B,100)

// Box Data do documento
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0420)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Data do documento",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0100,_aTitulos[_nCont][08],ofont08B,100)

// Box Numero do Documento
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0420,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0790)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0430,"N° do documento",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0450,_aTitulos[_nCont][01],ofont08B,100)

// Box Especie Doc
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0790,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1050)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0800,"Espécie Doc",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0900,"DM",ofont08,100)

// Box Aceite
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1050,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1170)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1060,"Aceite",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+1080,"Não",ofont08,100)


// Box Data do Processamento
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1170,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1650)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1180,"Data do Processamento",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+1280,_aTitulos[_nCont][15],ofont08B,100)

// Box Cart./nosso numero
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"Cart./nosso número",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+1960,alltrim(_aTitulos[_nCont][07])+"/"+alltrim(SE1->E1_NUMBCO),ofont08B,100)

// Box Uso do Banco
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0300)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Uso do Banco",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0050,"  ",ofont08,100)

// Box Cip
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0300,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0420)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0310,"Cip",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0315,"000",ofont08,100)

// Box Carteira
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0420,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0552)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0430,"Carteira",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0480,alltrim(_aTitulos[_nCont][07]),ofont08,100)

// Box Espécie Moeda
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0552,_nPosHor+(_nLinha*_nEspLin),_nPosVer+0790)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0562,"Espécie moeda",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+0662,"R$",ofont08,100)

// Box Quantidade
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0790,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1170)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0800,"Quantidade",ofont08,100)

// Box Valor
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1170,_nPosHor+(_nLinha*_nEspLin),_nPosVer+1650)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1180,"Valor",ofont08B,100)

// Box Valor do documento
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"1(=) Valor do documento",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+30,_nPosVer+2000,transform(_aTitulos[_nCont][03],"@E 999,999,999.99"),ofont08B,100)

	_nLinha  += 1

// Box Desconto / Abatimento
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"2(-) Desconto/abatimento",ofont08,100)

// Box Instrucoes
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin)+4*_nEspLin,_nPosVer+1650)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+20,_nPosVer+0010,"Instruções de responsabilidade do cedente.",ofont09B,100)

// Box Outras deducoes
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"3(-) Outras deduções",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,cMsgBrad1,ofont09B,100)

// Box Mora / Multa
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"4(+) Mora/Multa",ofont08,100)

// Box Outros acrescimos
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"5(+) Outros Acréscimos",ofont08,100)

// Box Valor cobrado
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+1650,_nPosHor+(_nLinha*_nEspLin),_nPosVer+2230)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1660,"6(=) Valor cobrado",ofont08,100)
	oprn:say(_nPosHor+((_nLinha-3)*_nEspLin),_nPosVer+0010,"Sujeito a protesto após vencimento",ofont09B,100)
	mv_par07:=iif(CtoD('18/03/2015')<=CtoD(_aTitulos[_nCont][8]),8,5)
	oprn:say(_nPosHor+((_nLinha-2)*_nEspLin),_nPosVer+0010,"Valor Juros mora dia "+Str(Round(Val(str(_aTitulos[_nCont][03]*(mv_par07/100)/30)),3),10,2),ofont09B,100)
	oprn:say(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer+0010,"Não pagar através de depósito em conta",ofont09B,100)

// Box Sacado
	_nLinha  += 1
	oPrn:Box(_nPosHor+((_nLinha-1)*_nEspLin),_nPosVer,_nPosHor+(_nLinha*_nEspLin)+_nEspLin,_nPosVer+2230)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0010,"Sacado:",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+0150,_aTitulos[_nCont][09],ofont08B,100) // Nome Sacado
	If _aTitulos[_nCont][17]=="F"
		oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1400,"CPF.: "+Transform(_aTitulos[_nCont][14],"@R 999.999.999-99"),ofont08B,100) // CPF Sacado
	ElseIf _aTitulos[_nCont][17]=="J"
		oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox,_nPosVer+1400,"CNPJ.: "+Transform(_aTitulos[_nCont][14],"@R 99.999.999/9999-99"),ofont08B,100) // CNPJ Sacado
	Endif
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+0030,_nPosVer+0150,_aTitulos[_nCont][10],ofont08B,100) // End. Sacado
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+0060,_nPosVer+0150,Transform(_aTitulos[_nCont][13],"@R 99999-999"),ofont08B,100) // CEP Sacado
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+0060,_nPosVer+0550,_aTitulos[_nCont][11],ofont08B,100) // Cidade Sacado
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+0060,_nPosVer+1000,_aTitulos[_nCont][12],ofont08B,100) // Estado Sacado
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+0120,_nPosVer+0010,"Sacador/Avalista:",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+0170,_nPosVer+1530,"Autenticação Mecânica",ofont08,100)
	oPrn:Say(_nPosHor+((_nLinha-1)*_nEspLin)+_nTxtBox+0170,_nPosVer+1860,"Ficha de Compensação",ofont09,100)

// Imprime Logotipo do Banco
	oPrn:Saybitmap(0015,0060,"SOFISA.BMP",0080,0070)

// Imprime Logotipo do Banco
	oPrn:Saybitmap(0550,0060,"SOFISA.BMP",0080,0070)

// Imprime Logotipo da Doce Mel
	oPrn:Saybitmap(0660,1820,"SOFISA.BMP",0240,0210)

// Imprime Logotipo do Banco
	oPrn:Saybitmap(1960,0060,"SOFISA.BMP",0080,0070)

// Imprime codigo de barras
	_nLinha  += 2

	oPrn:FWMSBAR("INT25" /*cTypeBar*/,66.0/*nRow*/ ,1.6/*nCol*/, _cbarra/*cCode*/,oPrn/*oPrint*/,.F./*lCheck*/,/*Color*/,.T./*lHorz*/,0.020/*nWidth*/,0.7/*nHeigth*/,nil/*lBanner*/,nil/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,1/*nPFWidth*/,1/*nPFHeigth*/,.F./*lCmtr2Pix*/)

Return(.T.)

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºFuncao    ³ MIRFT07B º Autor ³ Nelson Bispo       º Data ³  11/05/03   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescricao ³ Monta codigo de barras que sera impresso.                  º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ Faz Santa Terezinha LTDA                                   º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MIRFT07B()

	Local _nAgen   := ""
	Local _nCntCor := ""
	Local _nI      := 0

/*
- Posicoes fixas padrao Banco Central
Posicao  Tam       Descricao
01 a 03   03   Codigo de Compensacao do Banco (637)
04 a 04   01   Codigo da Moeda (Real => 9, Outras => 0)
05 a 05   01   Digito verificador do codigo de barras
06 a 19   14   Valor Nominal do Documento sem ponto

- Campo Livre Padrao Sofisa
Posicao  Tam       Descricao
20 a 23   03   Agencia Cedente sem digito verificador
24 a 25   02   Carteira
25 A 36   11   Nosso Numero sem digito verificador
37 A 43   07   Conta Cedente sem digiro verificador
44 A 44   01   Zero
*/

// Monta numero da Agencia sem dv e com 4 caracteres
// Retira separador de digito se houver
	For _nI := 1 To Len(_aTitulos[_nCont][05])
		If Subs(_aTitulos[_nCont][05],_nI,1) $ "0/1/2/3/4/5/6/7/8/9/"
			_nAgen += Subs(_aTitulos[_nCont][05],_nI,1)
		Endif
	Next _nI

// Monta numero da Conta Corrente sem dv e com 7 caracteres
// Retira separador de digito se houver
	For _nI := 1 To Len(_aTitulos[_nCont][16])
		If Subs(_aTitulos[_nCont][16],_nI,1) $ "0/1/2/3/4/5/6/7/8/9/"
			_nCntCor += Subs(_aTitulos[_nCont][16],_nI,1)
		Endif
	Next _nI

	_cCampo := ""
// Pos 01 a 03 - Identificacao do Banco
	_cCampo += "637"
// Pos 04 a 04 - Moeda
	_cCampo += "9"
// Pos 06 a 09 - Fator de vencimento
	_cCampo += Str((_aTitulos[_nCont][02] - Fator),4)
// Pos 10 a 19 - Valor
	_cCampo += StrZero(Int(_aTitulos[_nCont][03]*100),10)
// Pos 20 a 23 - Agencia
	_cCampo += _nAgen
// Pos 24 a 25 - Carteira
	_cCampo += _aTitulos[_nCont][07]
// Pos 26 a 36 - Nosso Numero
//_cCampo += Subs(SE1->E1_NUMBCO,1,11)
	_cCampo += Subs(_aTitulos[_nCont][04],1,11)
// Pos 37 a 43 - Conta do Cedente
	_cCampo += _nCntCor
// Pos 44 a 44 - Zero
	_cCampo += "0"
	_cDigitbar := MIRFT07C()

// Monta codigo de barras com digito verificador
	_cBarra := Subs(_cCampo,1,4)+_cDigitbar+Subs(_cCampo,5,43)

Return(.T.)

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºFuncao    ³ MIRFT07C º Autor ³ Nelson Bispo       º Data ³  11/05/03   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescricao ³ Calculo do Digito Verificador Codigo de Barras - MOD(11)   º±±
	±±º          ³ Pesos (2 a 9)                                              º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ Faz Santa Terezinha LTDA                                   º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MIRFT07C()

	Local _nCnt   := 0
	Local _nPeso  := 2
	Local _nJ     := 1
	Local _nResto := 0

	For _nJ := Len(_cCampo) To 1 Step -1
		_nCnt  := _nCnt + Val(SUBSTR(_cCampo,_nJ,1))*_nPeso
		_nPeso :=_nPeso+1
		if _nPeso > 9
			_nPeso := 2
		endif
	Next _nJ

	_nResto:=(_ncnt%11)

	_nResto:=11 - _nResto

	If _nResto == 0 .or. _nResto==1 .or. _nResto > 9
		_nDigbar:='1'
	Else
		_nDigbar:=Str(_nResto,1)
	Endif

Return(_nDigbar)

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºFuncao    ³ MIRFT07D º Autor ³ Nelson Bispo       º Data ³  11/05/03   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescricao ³ Monta da Linha Digitavel                                   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ Faz Santa Terezinha LTDA                                   º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static FUNCTION MIRFT07D()

	_cLinha     := ""
	_nDigito    := 0
	_cCampo     := ""

//..................................... Composição da Linha Digitável ............................................\\

//Primeiro Campo
//Posicao  Tam       Descricao
//01 a 03   03   Codigo de Compensacao do Banco (637)
//04 a 04   01   Codigo da Moeda (Real => 9, Outras => 0)
//05 a 09   05   Pos 1 a 5 do campo Livre(Pos 1 a 4 Dig Agencia + Pos 1 Dig Carteira)
//10 a 10   01   Digito Auto Correcao (DAC) do primeiro campo

//Segundo Campo
//11 a 20   10   Pos 6 a 15 do campo Livre(Pos 2 Dig Carteira + Pos 1 a 9 Nosso Num)
//21 a 21   01   Digito Auto Correcao (DAC) do segundo campo

//Terceiro Campo
//22 a 31   10   Pos 16 a 25 do campo Livre(Pos 10 a 11 Nosso Num + Pos 1 a 8 Conta Corrente + "0")
//32 a 32   01   Digito Auto Correcao (DAC) do terceiro campo

//Quarto Campo
//33 a 33   01   Digito Verificador do codigo de barras

//Quinto Campo
//34 a 37   04   Fator de Vencimento
//38 a 47   10   Valor


// Calculo do Primeiro Campo
	_cCampo := ""
	_cCampo := Subs(_cBarra,1,4)+Subs(_cBarra,20,5)
// Calculo do digito do Primeiro Campo
	MIRFT07E(2)
	_cLinha += Subs(_cCampo,1,5)+"."+Subs(_cCampo,6,4)+Alltrim(Str(_nDigito))

// Insere espaco
	_cLinha += " "

// Calculo do Segundo Campo
	_cCampo := ""
	_cCampo := Subs(_cBarra,25,10)
// Calculo do digito do Segundo Campo
	MIRFT07E(1)
	_cLinha += Subs(_cCampo,1,5)+"."+Subs(_cCampo,6,5)+Alltrim(Str(_nDigito))

// Insere espaco
	_cLinha += " "

// Calculo do Terceiro Campo
	_cCampo := ""
	_cCampo := Subs(_cBarra,35,10)
// Calculo do digito do Terceiro Campo
	MIRFT07E(1)
	_cLinha += Subs(_cCampo,1,5)+"."+Subs(_cCampo,6,5)+Alltrim(Str(_nDigito))

// Insere espaco
	_cLinha += " "

// Calculo do Quarto Campo
	_cCampo := ""
	_cCampo := Subs(_cBarra,5,1)
	_cLinha += _cCampo

// Insere espaco
	_cLinha += " "

// Calculo do Quinto Campo
	_cCampo := ""
	_cCampo := Subs(_cBarra,6,4)+Subs(_cBarra,10,10)
	_cLinha += _cCampo

Return(.T.)

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºFuncao    ³ MIRFT07E º Autor ³ Nelson Bispo       º Data ³  11/05/03   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescricao ³ Calculo do Digito Verificador da Linha Digitavel - Mod(10) º±±
	±±º          ³ Pesos (1 e 2)                                              º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ Faz Santa Terezinha LTDA                                   º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MIRFT07E (_nCnt)

	Local _nI   := 1
	Local _nAux := 0
	Local _nInt := 0
	_nDigito    := 0

	For _nI := 1 to Len(_cCampo)

		_nAux := Val(Substr(_cCampo,_nI,1)) * _nCnt
		If _nAux >= 10
			_nAux:= (Val(Substr(Str(_nAux,2),1,1))+Val(Substr(Str(_nAux,2),2,1)))
		Endif

		_nCnt += 1
		If _nCnt > 2
			_nCnt := 1
		Endif
		_nDigito += _nAux

	Next _nI

	If (_nDigito%10) > 0
		_nInt    := Int(_nDigito/10) + 1
	Else
		_nInt    := Int(_nDigito/10)
	Endif

	_nInt    := _nInt * 10
	_nDigito := _nInt - _nDigito

Return(.T.)

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºFun‡„o    ³VALIDPERG º Autor ³ Nelson Bispo       º Data ³  22/02/02   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescri‡„o ³ Verifica a existencia das perguntas criando-as caso seja   º±±
	±±º          ³ necessario (caso nao existam).                             º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ Faz Santa Terezinha LTDA                                   º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg

	Local _sAlias := Alias()
	Local aRegs := {}
	Local i,j

	SX1->(dbSelectArea("SX1"))
	SX1->(dbSetOrder(1))
	cPerg := PADR(cPerg,10)                       //mv_par10, mv_par07

	aAdd(aRegs,{cPerg,"01","Do Número?      ","","","mv_ch1","C",9,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Número?     ","","","mv_ch2","C",9,0,0,"G","","MV_PAR02","","","","ZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","De Cliente?     ","","","mv_ch3","C",6,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","",""})
	aAdd(aRegs,{cPerg,"04","Ate Cliente?    ","","","mv_ch4","C",6,0,0,"G","","MV_PAR04","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","SA1","","","",""})
	aAdd(aRegs,{cPerg,"05","Juros de Mora?  ","","","mv_ch5","C",1,0,0,"C","","MV_PAR05","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Multa?          ","","","mv_ch6","C",1,0,0,"C","","MV_PAR06","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","% Para Multa?   ","","","mv_ch7","N",2,0,0,"C","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","Protesto?       ","","","mv_ch8","C",1,0,0,"C","","MV_PAR08","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","Dias P/Protesto?","","","mv_ch9","N",2,0,0,"C","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"10","Texto Livre     ","","","mv_cha","C",60,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"11","Da Emissão?     ","","","mv_chb","D",8,0,0,"G","","MV_PAR11","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"12","Até Emissão?    ","","","mv_chc","D",8,0,0,"G","","MV_PAR12","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"13","De Vencimento?  ","","","mv_chd","D",8,0,0,"G","","MV_PAR13","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"14","Ate Vencimento? ","","","mv_che","D",8,0,0,"G","","MV_PAR14","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

	For i:=1 to Len(aRegs)
		If SX1->(!dbSeek(cPerg+aRegs[i,2]))
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)
Return(.T.)


Static function LimpaFlag()

	DbSelectArea("SE1")
	DbSetOrder(2)
	DbSeek(xFilial("SE1")+MV_PAR03+"00",.T. )
	ProcRegua(RecCount())
	While SE1->(!Eof()) .And. SE1->E1_NUM>=MV_PAR01 .And.;
			SE1->E1_NUM<=MV_PAR02 .And. SE1->E1_CLIENTE>=MV_PAR03 .And.;
			SE1->E1_CLIENTE<=MV_PAR04 .And. SE1->E1_EMISSAO>=MV_PAR11 .And.;
			SE1->E1_EMISSAO<=MV_PAR12 .And. SE1->E1_PORTADO!="002"
		IncProc("Limpando Flag.." )

		Reclock("SE1",.F.)
		SE1->E1_OK := Space(2)
		MsUnlock()

		DbSkip()
	End

Return(.T.)

Static Function NNumDV(_cAux,_cAux1,_cAux2,_cAux3,_cAux4,cFilInfo)

	Local _nCont   	:= 0
	Local _cPeso   	:= 2
	Local _cQuery	:= ""
	Local _cCart	:= ""
	Local _cBoleta	:= ""
	Local _nResto	:= 0
	Local _cDiv		:= ""
	Local i			:= 13

	_cQuery := " SELECT * FROM "+RETSQLNAME("SEE")+" WHERE D_E_L_E_T_ <> '*' AND EE_FILIAL='"+XFILIAL("SEE")+"' AND "
	_cQuery += " EE_XBOLETO='1' AND EE_CODIGO = '637' "

	If Select("TMP") > 0
		DBSELECTAREA("TMP")
		TMP->(DBCLOSEAREA())
	EndIf

	TcQuery _cQuery New Alias "TMP"
	DBSELECTAREA("TMP")
	TMP->(DBGOTOP())
	_cCart := alltrim(TMP->EE_CODCART)
	If cFilAnt == '020103'
		_cCart:= '02'
	endif
	_cBoleta :=	_cCart+_cAux
	For i := 13 To 1 Step -1

		_nCont := _nCont + (Val(SUBSTR(_cBoleta,i,1))) * _cPeso

		_cPeso := _cPeso + 1

		If _cPeso == 8
			_cPeso := 2
		Endif

	Next

	_nResto := ( _nCont % 11 )

	Do Case
	Case _nResto == 1
		_cDiv := "P"
	Case _nResto == 0
		_cDiv := "0"
	OtherWise
		_nResto   := ( 11 - _nResto )
		_cDiv := AllTrim(Str(_nResto,1))
	EndCase

	//Grava o Numero Bancario no Titulo
	DbSelectArea("SE1")
	DbSetOrder(1)
	DbGoTop()

	SE1->(DbSeek(cFilInfo+_cAux1+_cAux2+_cAux3+_cAux4))

	RecLock("SE1",.F.)

	SE1->E1_NUMBCO   := _cAux+_cDiv
	SE1->E1_XDVNBCO  := _cDiv  	//DV DO NOSSO NUMERO
	SE1->E1_XCARTEI  := "B" //AllTrim(M->Carteira)  //Numero da carteira
	SE1->E1_XINDSEE  := xFilial("SEE") + TMP->(EE_CODIGO + EE_AGENCIA + EE_CONTA + EE_SUBCTA)

	MsUnlock()
	TMP->(DBCLOSEAREA())

Return

//P3 Tecnologia - Code Analisys 29/05/2020
//Retorna Parametro da SX6
Static Function fRetMV(cMV)

Return AllTrim(GetMV(cMV))


User Function verdNN()
	// Prepara o ambiente
	RPCClearEnv()
	RpcSetType( 3 )
	RpcSetEnv( "01",'020202', , , "FIN",,, , , ,  )
	NNumDV(SUBSTR(AllTrim("00000245074P"),1,11),"1  ","000388072","   ","NF ","020202")
	RPCClearEnv()
Return

Static Function Ret_cBar637(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor,cConvenio)

LOCAL cValorFinal := strzero(nValor*100,10)
LOCAL nDvnn			:= 0
LOCAL nDvcb			:= 0
LOCAL nDv			:= 0
LOCAL cNN			:= ''
LOCAL cRN			:= ''
LOCAL cCB			:= ''
LOCAL cS			:= ''
LOCAL cFator        := strzero(SE1->E1_VENCREA - ctod("07/10/97"),4)
LOCAL cCart			:= "101"
Local cBanco        := "033"

//-----------------------------//
// Definicao do NOSSO NUMERO   //
// ----------------------------//

cS    := Alltrim(StrZero(Val(cNroDoc),12))
nDvnn := modulo11(cS,.T.) // digito verificador Nosso Num
cNN   := cS + AllTrim(Str(nDvnn))


//----------------------------------//
//	 Definicao do CODIGO DE BARRAS  //
//----------------------------------//

cS    := cBanco + "9" + cFator +  cValorFinal + '9' + SUBSTR(Trim(cConvenio),1,7) + cNN + "0" + cCart
nDvcb := modulo11(cS,.F.)
cCB   := SubStr(cS, 1, 4) + AllTrim(Str(nDvcb)) + SubStr(cS,5,39)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	  Campo 1		   Campo 2		   Campo 3			Campo 4
//	AAABC.DDDDE		FFFFF.FFFNNY	NNNNN.NNNNNZ	UUUUVVVVVVVVVV

// 	CAMPO 1:
//  AAA = Codigo do banco na Camara de Compensacao
//    B = Codigo da moeda, sempre 9 Nacional 8 Outras Moedas
//    C = Fixo 9
// DDDD = Codigo Cedente (4 primeiros digitos)
//    E = calculado pelo Modulo 10

cS    := cBanco + "99"  + SubStr(cConvenio,1,4)  //03399
nDv   := modulo10(cS)
cRN   := cS + "." + AllTrim(Str(nDv)) + " "

// 	CAMPO 2:
//    FFFF = Codigo do Dedente (4 ultimos digitos)
// NNNNNNN = 2 primeiros digitos do nosso numero
//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS    := SUBSTR(cConvenio,5,3) + substr(cNN,1,7)
nDv   := modulo10(cS)
cRN   := cRN + cS + "." + Alltrim(Str(nDv)) + " "

// 	CAMPO 3:
//	  N = Restante do Nosso Numero
//	  N = FIXO '0'
//	NNN = TIPO DE MODALIDADE CARTEIRA
//	  Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
cS    := SUBSTR(cNN,8,6) + "0" + cCart
nDv   := modulo10(cS)
cRN   := cRN + cS + "." + Alltrim(Str(nDv)) + " "

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
cRN   := cRN + AllTrim(Str(nDvcb)) + " "

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
cRN   := cRN + cFator + StrZero((nValor*100),10)


Return({cCB,cRN,cNN})
