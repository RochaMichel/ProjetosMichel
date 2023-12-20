#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

Static cIniSeq := "00001"

User Function bolhib(cNumDe , cNumAte)

//LOCAL	  aPergs     	:= {}
PRIVATE lExec      	:= .F.
PRIVATE cIndexName 	:= ''
PRIVATE cIndexKey  	:= ''
PRIVATE cFilter    	:= ''

Tamanho  := "M"
titulo   := "Impressao de Boleto com Codigo de Barras"
cDesc1   := "Este programa destina-se a impressao do Boleto com Codigo de Barras."
cDesc2   := ""
cDesc3   := ""
cString  := "SE1"
wnrel    := "BOLETO"
lEnd     := .F.
cPerg    := "BOLET3"
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
nLastKey := 0
lNoNFE	 := .F.

dbSelectArea("SE1")


*--------------------------------------------------------
* Verifica as_ perguntas selecionadas
*--------------------------------------------------------
If FunName() <> "SPEDNFE"

	If !Pergunte("BOLET3",.T.)
   	Return
	EndIf
	lNoNFE := .T.
Endif
*-----------------------------------------------------------------
* Envia controle para a funcao setprint_
*-----------------------------------------------------------------

If nLastKey == 27
	Set Filter to
	Return
Endif

If nLastKey == 27
	Set Filter to
	Return
Endif


If lNoNFE
	cIndexName	:= Criatrab(Nil,.F.)
	cIndexKey	:= "E1_NUM+E1_PARCELA"
	cIndexKey	:= "E1_CARGA"
	cFilter		+= "E1_PORTADO = '001' .AND. "

	cFilter		+= "E1_NUMBCO <> '' .and. "

	cFilter		:= "E1_NUM   >= '" + MV_PAR01 + "' .And. E1_NUM <= '"+ MV_PAR02 +"' .And. "
	cFilter		+= "E1_FILIAL == '" + xFilial("SE1")    + "' .And. "
	cFilter		+= "E1_TIPO == 'NF ' .AND. E1_PORTADO <> '  ' .And. E1_XNUMBOL <> ' ' "

	IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")
	DbSelectArea("SE1")
	#IFNDEF TOP
		DbSetIndex(cIndexName + OrdBagExt() )
	#ENDIF
	dbGoTop()

	*---------------------------------
	* Tela para a selação dos titulos
	*---------------------------------
	@ 001,001 TO 400,700 DIALOG oDlg TITLE "Seleção de Titulos"
	@ 001,001 TO 170,350 BROWSE "SE1" MARK "E1_OK"
	@ 180,310 BMPBUTTON TYPE 01 ACTION (lExec := .T.,Close(oDlg))
	@ 180,280 BMPBUTTON TYPE 02 ACTION (lExec := .F.,Close(oDlg))
	ACTIVATE DIALOG oDlg CENTERED

	dbGoTop()
	//If lExec
		Processa({|lEnd|MontaRel()})
	//Endif
	//RetIndex("SE1")
	Ferase(cIndexName+OrdBagExt())

Else

	DbSelectArea("SE1")
	DbSetOrder(1)
	If DbSeek(FWxFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL)
		Processa({|lEnd|MontaRel(cNumDe, cNumAte)})
	EndIf

EndIf

Return Nil


*----------------------------------------------------------------------------
* Bruno Santos                                                   | 23/02/2011
*----------------------------------------------------------------------------
* Função   : MontaRel
*----------------------------------------------------------------------------
* Objetivo :  Faz o processamento e gera as_ informações para a impressão do_
*             boleto.
*----------------------------------------------------------------------------
Static Function MontaRel(cNumDe , cNumAte)
LOCAL oPrint
LOCAL nX := 0
Local cNroDoc := " "
Local cNota   := ""
//Local cCnpjNe := ""

//LOCAL aDadosEmp    := {	"EMIS COMERCIO E REPRESENTACOES LTDA "     		  ,;  //[1]Nome da Empresa
LOCAL aDadosEmp    := {	Alltrim(SM0->M0_NOMECOM) 					              			,;  //[1]Nome da Empresa
Alltrim(Upper(SM0->M0_ENDCOB))         						      	                    			,;  //[2]Endereço
AllTrim(SM0->M0_BAIRCOB)+" - "+AllTrim(SM0->M0_CIDCOB)+"/"+SM0->M0_ESTCOB	  			,;  //[3]Complemento
"CEP: "      + Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)         			,;  //[4]CEP
"PABX/FAX: " + SM0->M0_TEL                                                   			,;  //[5]Telefones
"CNPJ: "     + IIf(SM0->M0_CODIGO=="01","08.855.199/0001-41",IIF(SM0->M0_CODIGO=="02","30.845.573/0001-87","41.672.373/0001-96"))	,;  //[6]CNPJ -> Coloquei fixo, por que tem que ser o CNPJ que está cadastrado no banco
"I.E.: "	 +Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+      	      		 ;  //[7]
Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                        	          }  //[7]I.E

LOCAL aDadosTit
LOCAL aDadosBanco
LOCAL aDatSacado
LOCAL aBolText
LOCAL nI           	:= 1
LOCAL aCB_RN_NN    	:= {}
LOCAL nVlrAbat	   	:= 0
Private nBol       	:= 1
cNumTit 			:= ''  	//Numero do titulo
oPrint := FWMsPrinter():New( "Boleto Laser" )
oPrint:SetPortrait() 		// ou SetLandscape()  //Define se a impressão vai ser retrato ou paisagem
cNumTit:= SE1->E1_NUM+SE1->E1_PARCELA  		//Numero do titulo
nbol2 				:= 0
//dbGoTop()
ProcRegua(RecCount())

if oPrint:nModalResult <> PD_OK
	return
endif

Do While (SE1->E1_NUM <= cNumAte .AND. SE1->E1_NUM >= cNumDe .AND. !lNoNFE) .OR. lNoNFE .AND. !EOF()

	If Empty(SE1->E1_XNUMBOL)
		SE1->(DbSkip())
		Loop
	EndIf

	cNosNum := GERNNUM11()	//Gero o nosso número
	
	//if !empty(SE1->E1_PARCELA) //.and. nbol2 = 0
	//	NBOL2 := 1
	//Elseif empty(SE1->E1_PARCELA)
	//	NBOL2 := 0
	//ENDIF
	
	//IF cNumTit <> SE1->E1_NUM+SE1->E1_PARCELA   //Numero do titulo
	//	cNumTit := SE1->E1_NUM+SE1->E1_PARCELA  //Numero do titulo
		//nBol    := 1
		//if !empty(se1->e1_parcela )
			nbol2 := 1
		//else
		//	nbol2 := 0
		//endif
		oPrint:EndPage()     // Finaliza a página
	//ENDIF
	
	//Posiciona o SA1 (Cliente)
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
	
	*---------------------------
	* Posiciona o SA6 (Bancos)
	*---------------------------
	DbSelectArea("SA6")
	DbSetOrder(1)
	//DbSeek(xFilial("SA6")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.)
	DbSeek(xFilial("SA6")+alltrim(SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA)))

	cNumCar := Trim(SA6->A6_CARTEIR)  //Adilson Jorge em 26/01/2017, coletando a carteira do Bradesco, 09 Simples ou 02 Caucionada
		
	DbSelectArea("SE1")
	aDadosBanco  := {SA6->A6_COD                                		,;	 // [1]Numero do Banco
	IIF(SE1->E1_PORTADO = '001',"BANCO DO BRASIL S/A",SA6->A6_NREDUZ) ,;  // [2]Nome do Banco
	Alltrim(SA6->A6_AGENCIA) 											         ,;	 // SUBSTR(SA6->A6_AGENCIA, 1, Len(Alltrim(SA6->A6_AGENCIA))-1)                          ,; 	// [3]Agência
	SUBSTR(SA6->A6_NUMCON,1,Len(AllTrim(SA6->A6_NUMCON))-1)     		,;  // [4]Conta Corrente
	SUBSTR(SA6->A6_NUMCON,Len(AllTrim(SA6->A6_NUMCON)),1)       		,;  // [5]Dígito da conta corrente
	""                                                        			,;	 // SA6->A6_CARTEIR 	// [6]Codigo da Carteira
	""							                                  		      ,;  // 
	SUBSTR(SA6->A6_AGENCIA, 5, 1)                           			   }   // [8]Dígito da Agência
	
	If Empty(SA1->A1_ENDCOB)
		aDatSacado   := {AllTrim(SA1->A1_NOME)           				,;	// [1]Razão Social
		AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           				,;	// [2]Código
		AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO)				,;	// [3]Endereço
		AllTrim(SA1->A1_MUN )                            				,;	// [4]Cidade
		SA1->A1_EST                                      				,;	// [5]Estado
		SA1->A1_CEP                                      				,;	// [6]CEP
		SA1->A1_CGC										          		,;	// [7]CGC
		SA1->A1_PESSOA													}	// [8]PESSOA
	Else
		aDatSacado   := {AllTrim(SA1->A1_NOME)            	 			,;	// [1]Razão Social
		AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA              			,; 	// [2]Código
		AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC)			,; 	// [3]Endereço
		AllTrim(SA1->A1_MUNC)	                             			,; 	// [4]Cidade
		SA1->A1_ESTC	                                     			,; 	// [5]Estado
		SA1->A1_CEPC                                        			,; 	// [6]CEP
		SA1->A1_CGC												 		,;	// [7]CGC
		SA1->A1_PESSOA												 	}	// [8]PESSOA
	Endif
	
	nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	
	//Monta codigo de barras
	/*If Subs(aDadosBanco[1],1,3) = "237" 									//Bradesco
		cBarBru 	 := Alltrim(Posicione('ZBH',1,FWxFilial('ZBH')+SE1->E1_IDCNAB,'ZBH_CODBAR'))
		cLinBru 	 := Alltrim(Posicione('ZBH',1,FWxFilial('ZBH')+SE1->E1_IDCNAB,'ZBH_LINDIG'))
		aCB_RN_NN    := {cBarBru, cLinBru}
	ELSE*/   //Banco do Brasil
		cBarBru 	 := Alltrim(Posicione('ZBH',1,FWxFilial('ZBH')+SE1->E1_IDCNAB,'ZBH_CODBAR'))
		cLinBru 	 := Alltrim(Posicione('ZBH',1,FWxFilial('ZBH')+SE1->E1_IDCNAB,'ZBH_LINDIG'))
		aCB_RN_NN    := {cBarBru, cLinBru}
	//EndIf
	
	aDadosTit	:= {AllTrim(E1_NUM)+AllTrim(E1_PARCELA)	,;  // [1] Número do título
	E1_EMISSAO                              					,;  // [2] Data da emissão do título
	dDataBase                    									,;  // [3] Data da emissão do boleto
	E1_VENCTO                           	    				,;  // [4] Data do vencimento
	(E1_SALDO /*- E1_BONUS*/ - nVlrAbat)         			,;  // [5] Valor do título
	cNosNum   															,;  // [6] Nosso número (Ver fórmula para calculo)  ////	iif(E1_PORTADO = '237','09'+cNosNum,cNosNum)   ,;  // [6] Nosso número (Ver fórmula para calculo)
	E1_PREFIXO              	                 				,;  // [7] Prefixo da NF
	"DM"	                     		       				}   	 // [8] Tipo do Titulo
//	E1_TIPO	                    		       				}   	 // [8] Tipo do Titulo
	     
	nValDesc := 0 												//(E1_SALDO - E1_BONUS - nVlrAbat)*(getmv("MV_PERDESC")/100)
	nValMora := 0 												//(E1_SALDO - E1_BONUS - nVlrAbat)*(getmv("MV_TXMORA")/100)
	nMul001  := ((E1_SALDO - nVlrAbat)/100 * 0.2)
	nDescAnt := NoRound( (((E1_SALDO - nVlrAbat) * 0.01) / 30) ,2) //acrescentado por Adilson em 11/03/2019 vai ser usado só para Cativa
//	aBolText     := {"SUJEITO A PROTESTO APOS 10 DIAS.",;
// Ajustado por Adilson em 21/05/2013, solicitado por Sr. Marcus e Alexandre
// Ajustado por Adilson em 11/03/2019, para contemplar bonificação por antecipação, desconto diário
	If SM0->M0_CODIGO == "01"  //Se Emis
		aBolText     := {"SUJEITO A PROTESTO APOS 05 DIAS.",;
		"APOS O VENCIMENTO, COBRAR R$ " + alltrim(str(nMul001,14,2)) + " POR DIA DE ATRASO.",;
		"ATENCAO: Pagamento exclusivo com boleto bancario, nao efetuar deposito em conta corrente.",;
		"  "}
	Else
		If SE1->E1_EMISSAO < CTOD("19/03/2019")	//a partir de 19/03/2019 vai imprimir o desconto por antecipação, Adilson Jorge - 19/03/2019
			aBolText     := {"SUJEITO A PROTESTO APOS 05 DIAS.",;
			"APOS O VENCIMENTO, COBRAR R$ " + alltrim(str(nMul001,14,2)) + " POR DIA DE ATRASO.",;
			"ATENCAO: Pagamento exclusivo com boleto bancario, nao efetuar deposito em conta corrente.",;
			"  "}
		Else
			If SM0->M0_CODIGO == "02"       //Se Cativa
				aBolText     := {"SUJEITO A PROTESTO APOS 05 DIAS.",;
				"APOS O VENCIMENTO, COBRAR R$ " + alltrim(str(nMul001,14,2)) + " POR DIA DE ATRASO.",;
				"ATENCAO: Pagamento exclusivo com boleto bancario, nao efetuar deposito em conta corrente.",;
				"DESCONTO DE R$ " + alltrim(str(nDescAnt,14,2)) + " POR DIA DE ANTECIPACAO."}
			ElseIf SM0->M0_CODIGO == "03"   //Se Nutiva, Adilson Jorge em 13/08/2021
				If SE1->E1_EMISSAO < CTOD("04/11/2021") // Incluído por Adilson Jorge em 03/11/2021 para poder imprimir ou não o desconto por antecipação na Nutiva
					aBolText     := {"SUJEITO A PROTESTO APOS 05 DIAS.",;
					"APOS O VENCIMENTO, COBRAR R$ " + alltrim(str(nMul001,14,2)) + " POR DIA DE ATRASO.",;
					"ATENCAO: Pagamento exclusivo com boleto bancario, nao efetuar deposito em conta corrente.",;
					"  "}
				Else  //Voltou o desconto de 1% ao mês, Adilson Jorge em 03/11/2021, vigorar a partir de 04/11/2021
					aBolText     := {"SUJEITO A PROTESTO APOS 05 DIAS.",;
					"APOS O VENCIMENTO, COBRAR R$ " + alltrim(str(nMul001,14,2)) + " POR DIA DE ATRASO.",;
					"ATENCAO: Pagamento exclusivo com boleto bancario, nao efetuar deposito em conta corrente.",;
					"DESCONTO DE R$ " + alltrim(str(nDescAnt,14,2)) + " POR DIA DE ANTECIPACAO."}
				Endif
			Endif
		Endif			
	Endif		
	
	//If Marked("E1_OK")
		IF nBol = 1 .OR. cNota <> SE1->E1_NUM
			nBol := 1
			oPrint:StartPage()  //Inicia uma nova página
			//Linhas pontilhadas
			For nI := 100 to 2360 step 50
				oPrint:Line(1520, nI, 1520, nI+30)
				//oPrint:Line(2900, nI, 2900, nI+30)
			Next nI
		Endif
		Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN,nBol,nbol2)  //Imprime o boleto
		nBol++
		IF nBol > 2
			nBol := 1
			oPrint:EndPage()     // Finaliza a página
		Endif
		nX := nX + 1
	//EndIf
	cNota := SE1->E1_NUM
	dbSkip()
	if !empty(SE1->E1_PARCELA)
		NBOL2++
	ENDIF
	IncProc()
	nI := nI + 1
EndDo
oPrint:EndPage()   			  	// Finaliza a página
oPrint:Preview()     			// Visualiza antes de imprimir
Return nil



*----------------------------------------------------------------------------
* Bruno Santos                                                   | 23/02/2011
*----------------------------------------------------------------------------
* Função   : Impress
*----------------------------------------------------------------------------
* Objetivo : Função para a impressão propriamente dia do_ boleto
*----------------------------------------------------------------------------
Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN,_nBol,nbol2)
LOCAL oFont8
LOCAL oFont11c
LOCAL oFont10
LOCAL oFont14
LOCAL oFont16n
LOCAL oFont15
LOCAL oFont14n
LOCAL oFont24
LOCAL nI := 0
LOCAL cEMV := ""
Local nPos1 := 28
Local nPos2 := 11

nBol1 := nbol2

Private aLinhas  := {30,1200,2315}
Private aPosbar  := {}  //coordenadas de linha e coluna do código de barras

//If Subs(aDadosBanco[1],1,3) = "104"
	AADD(aPosBar,{04,5.4})
	AADD(aPosBar,{08.8,3.4})
	AADD(aPosBar,{13.7,3.4})
	
//Else
	AADD(aPosBar,{07.6,5.4})
	AADD(aPosBar,{17.0,5.4})
	AADD(aPosBar,{26.4,5.4})
//EndIf

oFont5   := TFont():New("Arial",9,5,.T.,.F.,5,.T.,5,.T.,.F.)
oFont5n  := TFont():New("Arial",9,5,.T.,.T.,5,.T.,5,.T.,.F.)

oFont6   := TFont():New("Arial",9,6,.T.,.F.,5,.T.,5,.T.,.F.)
oFont6n  := TFont():New("Arial",9,6,.T.,.T.,5,.T.,5,.T.,.F.)

oFont7   := TFont():New("Arial",9,7,.T.,.F.,5,.T.,5,.T.,.F.)
oFont7n  := TFont():New("Arial",9,7,.T.,.T.,5,.T.,5,.T.,.F.)

oFont8   := TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
oFont8n  := TFont():New("Arial",9,8,.T.,.T.,5,.T.,5,.T.,.F.)

oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10c := TFont():New("Courier New",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont11  := TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont11n := TFont():New("Arial",9,11,.T.,.F.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12n := TFont():New("Arial",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont20  := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
oFont21  := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont15  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont13n := TFont():New("Arial",9,13,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

nRow3 := aLinhas[_nbol]

*------------------------------------------------------------
*  INICIO -> RECIBO DO_ SACADO
*------------------------------------------------------------

If _nbol == 1 // primeira pagina
	For nI := nRow3 + 40 to nRow3+1250 step 30
		oPrint:Line(NI, 475, NI+15, 475)
	Next nI
	nRow3 := nRow3 - 50  //Bruno mudou
else
	For nI := nRow3 + 400 to nRow3+1650 step 30
		oPrint:Line(NI, 475, NI+15, 475)
	Next nI
	nRow3 := nRow3 + 300
	npos1 += 32
Endif

IF Subs(aDadosBanco[1],1,3) == "237"
   oPrint:Say  (nRow3+0084,100,"BRADESCO ",oFont14n)
else
   oPrint:Say  (nRow3+0084,100,aDadosBanco[2],oFont8n )		   // 	[2]Nome do Banco 
endif

oPrint:Line (nRow3+0120,100,nRow3+0120,450)

oPrint:Say  (nRow3+0150,130 ,"RECIBO DO PAGADOR",oFont8n)
oPrint:Line (nRow3+0170,100,nRow3+0170,450)

oPrint:Say  (nRow3+0197,100 ,"Nº Documento",oFont8n)
IF Subs(aDadosBanco[1],1,3) <> "237"
	oPrint:Say  (nRow3+0224,150 ,xFilial("SE1")+aDadosTit[7]+aDadosTit[1],oFont8)
else
	oPrint:Say  (nRow3+0224,150 ,xFilial("SE1")+aDadosTit[1],oFont8)
endif
oPrint:Line (nRow3+0240,100,nRow3+0240,450)

oPrint:Say  (nRow3+0267,100 ,"Vencimento",oFont8n)
cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
oPrint:Say  (nRow3+0294,150,cString,oFont8)
oPrint:Line (nRow3+0310,100,nRow3+0310,450)

oPrint:Say  (nRow3+0337,100 ,"Ag./Cód. Beneficiário",oFont8n)
If Subs(aDadosBanco[1],1,3) == "104"
	cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+/*"-"+*/aDadosBanco[5])
ElseIF Subs(aDadosBanco[1],1,3) == "237"
	cString := SUBSTR(aDadosBanco[3],1,Len(AllTrim(aDadosBanco[3]))-1)+"-"+SUBSTR(aDadosBanco[3],Len(AllTrim(aDadosBanco[3])),1)+"/"+aDadosBanco[4]+/*"-"+*/aDadosBanco[5]
ELSE
	cString := SUBSTR(aDadosBanco[3],1,Len(AllTrim(aDadosBanco[3]))-1)+"-"+SUBSTR(aDadosBanco[3],Len(AllTrim(aDadosBanco[3])),1)+"/"+aDadosBanco[4]+/*"-"+*/aDadosBanco[5]
EndIf
oPrint:Say  (nRow3+0364,150 ,cString,oFont8)
oPrint:Line (nRow3+0380,100,nRow3+0380,450)

oPrint:Say  (nRow3+0407,100 ,"Nosso Número",oFont8n)
* Banco Bradesco ou Caixa Econômica
If Subs(aDadosBanco[1],1,3) <> "104" .AND. Subs(aDadosBanco[1],1,3) <> "001"
//		cString := "09/"+substr(Alltrim(aDadosTit[6]),1,11)+"-"+substr(Alltrim(aDadosTit[6]),12,1)
//	If GETMV("MV_NECOBCA") == "N" // Adilson Jorge em 24/01/2017
//		cString := "09/"+substr(Alltrim(aDadosTit[6]),1,11)+"-"+substr(Alltrim(aDadosTit[6]),12,1)
//	Else
//		cString := "02/"+substr(Alltrim(aDadosTit[6]),1,11)+"-"+substr(Alltrim(aDadosTit[6]),12,1)
//	Endif
	cString := cNumCar+"/"+substr(Alltrim(aDadosTit[6]),1,11)+"-"+substr(Alltrim(aDadosTit[6]),12,1) //Adilson Jorge em 26/01/2017
Else
	* Banco do_ Brasil
	If SM0->M0_CODIGO == "01"  //Se Emis     		//Adilson Jorge em 22/11/2019
		cString := substr(Alltrim(aDadosTit[6]),1,11)+"-"+substr(Alltrim(aDadosTit[6]),12,1)
//	ElseIf SM0->M0_CODIGO == "02"  //Se Cativa   //Adilson Jorge em 22/11/2019
	ElseIf SM0->M0_CODIGO $ "02|03"  //Se Cativa e Nutiva   //Adilson Jorge em 05/08/2021
		cString := substr(Alltrim(aDadosTit[6]),1,17)
	Endif
EndIf
oPrint:Say  (nRow3+0434,150,cString,oFont8)
oPrint:Line (nRow3+0450,100,nRow3+0450,450)

oPrint:Say  (nRow3+0477,100 ,"Vl. Documento",oFont8n)
cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
oPrint:Say  (nRow3+0504,150 ,cString,oFont8)
oPrint:Line (nRow3+0520,100,nRow3+0520,450)

oPrint:Say  (nRow3+0547,100 ,"Desconto",oFont8n)
oPrint:Line (nRow3+0590,100,nRow3+0590,450)

oPrint:Say  (nRow3+0617,100 ,"Outras Deduções",oFont8n)
oPrint:Line (nRow3+0660,100,nRow3+0660,450)

oPrint:Say  (nRow3+0687,100 ,"Mora/Multa",oFont8n)
oPrint:Line (nRow3+0730,100,nRow3+0730,450)

oPrint:Say  (nRow3+0757,100 ,"Outros Acres.",oFont8n)
oPrint:Line (nRow3+0800,100,nRow3+0800,450)

oPrint:Say  (nRow3+0827,100 ,"Valor Cobrado",oFont8n)
oPrint:Line (nRow3+0870,100,nRow3+0870,450)

oPrint:Say  (nRow3+0897,100 ,"Pagador",oFont8n)
oPrint:Say  (nRow3+0951,100 ,LEFT(ALLTRIM(aDatSacado[1]),26),oFont6n)
oPrint:Say  (nRow3+0978,100 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont6n)  //Adilson Jorge em 29/11/2019
//"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99")
oPrint:Line (nRow3+0990,100,nRow3+0990,450)

*CAIXA ECONÔMICA FEDERAL
If Subs(aDadosBanco[1],1,3) = "104"
	cString := Alltrim(Substr(aDadosTit[6],1,3)+"/"+Substr(aDadosTit[6],4))
EndIf

//oPrint:Say  (nRow3+1010,100 ,"Beneficiário",oFont8n)
oPrint:Say  (nRow3+1010,100 ,Substr(ALLTRIM(aDadosEmp[1]),1,26),oFont6n) 									//Adilson Jorge em 02/12/2019
oPrint:Say  (nRow3+1037,100 ,aDadosEmp[6],oFont6n)																	//Adilson Jorge em 02/12/2019
oPrint:Say  (nRow3+1064,100 ,Substr(aDadosEmp[2]+"-"+aDadosEmp[3] +"-"+aDadosEmp[4], 1,40),oFont5) //Endereço, Bairro, Cidade, UF e CEP, Adilson Jorge em 29/11/2019
oPrint:Say  (nRow3+1091,100 ,Substr(aDadosEmp[2]+"-"+aDadosEmp[3] +"-"+aDadosEmp[4],41,40),oFont5) //Endereço, Bairro, Cidade, UF e CEP, Adilson Jorge em 29/11/2019

oPrint:Line (nRow3+1300,100,nRow3+1300,450)

*-------------------------------------------------------------
* FIM -> Recibo do_ sacado
*-------------------------------------------------------------

oPrint:Line (nRow3+0140,500,nRow3+0140,2400)
oPrint:Line (nRow3+0090,855,nRow3+0140, 855)
oPrint:Line (nRow3+0090,1045,nRow3+0140, 1045)

IF Subs(aDadosBanco[1],1,3) == "237"
   oPrint:Say  (nRow3+0084,500,"BRADESCO ",oFont14n)
else
   oPrint:Say  (nRow3+0084,500,aDadosBanco[2],oFont8n )		   // 	[2]Nome do Banco 
endif

If Subs(aDadosBanco[1],1,3) <> "104" .AND. Subs(aDadosBanco[1],1,3) <> "237"
	oPrint:Say  (nRow3+0075,870,aDadosBanco[1]+"-9",oFont16n )	// 	[1]Numero do Banco
Elseif Subs(aDadosBanco[1],1,3) = "237"
	oPrint:Say  (nRow3+0075,870,aDadosBanco[1]+"-2",oFont16n )	// 	[1]Numero do Banco
Else
	oPrint:Say  (nRow3+0075,870,aDadosBanco[1]+"-0",oFont16n )	// 	[1]Numero do Banco
EndIf
oPrint:Say  (nRow3+0090,1070,aCB_RN_NN[2],oFont12n)			    //	Linha Digitavel do Codigo de Barras

oPrint:Line (nRow3+0250,500,nRow3+0250,2400 )
oPrint:Line (nRow3+0350,500,nRow3+0350,2400 )
oPrint:Line (nRow3+0420,500,nRow3+0420,2400 )
oPrint:Line (nRow3+0490,500,nRow3+0490,2400 )

oPrint:Line (nRow3+0350,900 ,nRow3+0490,900 )
oPrint:Line (nRow3+0420,1150,nRow3+0490,1150)
oPrint:Line (nRow3+0350,1300,nRow3+0490,1300)
oPrint:Line (nRow3+0350,1550,nRow3+0420,1550)
oPrint:Line (nRow3+0350,1680,nRow3+0490,1680)

If Subs(aDadosBanco[1],1,3) == "237"
	oPrint:Line (nRow3+0420,800 ,nRow3+0490,800 )
Endif	

oPrint:Say  (nRow3+0160,500 ,"Local de Pagamento",oFont8)
If Subs(aDadosBanco[1],1,3) <> "237"
	//oPrint:Say  (nRow3+0180,500 ,"PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO",oFont8n)
	oPrint:Say  (nRow3+0190,500 ,"PAGÁVEL EM QUALQUER BANCO",oFont8n)
ELSE
	oPrint:Say  (nRow3+0190,500 ,"Preferencialmente nas agencias do Bradesco ou Correios. APÓS O VENCIMENTO, SOMENTE NO BRADESCO",oFont8n) //Documento Não Compensável – Pagável Exclusivamente no Bradesco
ENDIF

oPrint:Say  (nRow3+0160,2010,"Vencimento",oFont8)
cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol	 	 := 1930+(320-(len(cString)*22))
oPrint:Say  (nRow3+0190,nCol,cString,oFont10c)

oPrint:Say  (nRow3+0240,500 ,"Beneficiário",oFont8)
If SM0->M0_CODIGO == "01"  // Adilson Jorge em 30/10/2018, se for empresa 01 - Emis
	oPrint:Say  (nRow3+0290,500 ,aDadosEmp[1]+" - "+aDadosEmp[6]							,oFont10) //Nome + CNPJ
Else
	oPrint:Say  (nRow3+0290,500 ,aDadosEmp[1]+" - "+aDadosEmp[6]							,oFont8n) //Nome + CNPJ
	oPrint:Say  (nRow3+0320,500 ,aDadosEmp[2]+" - "+aDadosEmp[3] +" - "+aDadosEmp[4]	,oFont8) //Endereço, Bairro, Cidade, UF e CEP, Adilson Jorge em 06/11/2018
Endif

oPrint:Say  (nRow3+0240,2010,"Agência/Código Beneficiário",oFont8)
If Subs(aDadosBanco[1],1,3) =="104"
	cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+/*"-"+*/aDadosBanco[5])
ElseIF Subs(aDadosBanco[1],1,3) == "237"
	cString := SUBSTR(aDadosBanco[3],1,Len(AllTrim(aDadosBanco[3]))-1)+"-"+SUBSTR(aDadosBanco[3],Len(AllTrim(aDadosBanco[3])),1)+"/"+aDadosBanco[4]+/*"-"+*/aDadosBanco[5]
ELSE
	cString := SUBSTR(aDadosBanco[3],1,Len(AllTrim(aDadosBanco[3]))-1)+"-"+SUBSTR(aDadosBanco[3],Len(AllTrim(aDadosBanco[3])),1)+"/"+aDadosBanco[4]+/*"-"+*/aDadosBanco[5]
EndIf

IF Subs(aDadosBanco[1],1,3) == "237"
	nCol 	 := 2010+(310-(len(cString)*22))+35
ELSE
	nCol 	 := 2010+(310-(len(cString)*22))
ENDIf

oPrint:Say  (nRow3+0290,nCol,cString ,oFont10c)
oPrint:Say  (nRow3+0340,500 ,"Data do Documento"                              	,oFont8)
oPrint:Say  (nRow3+0380,500, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont10)

oPrint:Say  (nRow3+0340,905 ,"Nro.Documento"                                  	,oFont8)
IF Subs(aDadosBanco[1],1,3) <> "237"
	oPrint:Say  (nRow3+0380,980 ,xFilial("SE1")+aDadosTit[7]+aDadosTit[1] 		,oFont10) //Prefixo +Numero+Parcela
else
	oPrint:Say  (nRow3+0380,980 ,xFilial("SE1")+aDadosTit[7]+aDadosTit[1] 		,oFont10) //Prefixo +Numero+Parcela
//	oPrint:Say  (nRow3+0380,980 ,xFilial("SE1")+aDadosTit[1]					,oFont10) //Prefixo +Numero+Parcela
endif

oPrint:Say  (nRow3+0340,1305,"Espécie Doc."                                   	,oFont8)
oPrint:Say  (nRow3+0380,1350,aDadosTit[8]										,oFont10) //Tipo do Titulo

oPrint:Say  (nRow3+0340,1555,"Aceite"                                         	,oFont8)
oPrint:Say  (nRow3+0380,1585,"N"                                             	,oFont10)

oPrint:Say  (nRow3+0340,1685,"Data do Processamento"                          	,oFont8)
oPrint:Say  (nRow3+0380,1750,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4)                               ,oFont10) // Data impressao

oPrint:Say  (nRow3+0340,2010,"Nosso Número"                                   	,oFont8)

* Bradesco
If Subs(aDadosBanco[1],1,3) <> "104" .AND. Subs(aDadosBanco[1],1,3) <> "001"
//		cString := "09/"+substr(Alltrim(aDadosTit[6]),1,11)+"-"+substr(Alltrim(aDadosTit[6]),12,1)
//	If GETMV("MV_NECOBCA") == "N" // Adilson Jorge em 24/01/2017
//		cString := "09/"+substr(Alltrim(aDadosTit[6]),1,11)+"-"+substr(Alltrim(aDadosTit[6]),12,1)
//	Else
//		cString := "02/"+substr(Alltrim(aDadosTit[6]),1,11)+"-"+substr(Alltrim(aDadosTit[6]),12,1)
//	Endif
	cString := cNumCar+"/"+substr(Alltrim(aDadosTit[6]),1,11)+"-"+substr(Alltrim(aDadosTit[6]),12,1) // Adilson Jorge em 26/01/2017
	nCol 	 := 2010+(290-(len(cString)*22)) +70
Else
	//* Branco do_ Brasil
	//cString := substr(Alltrim(aDadosTit[6]),1,11)+"-"+substr(Alltrim(aDadosTit[6]),12,1)
	* Banco do_ Brasil
	If SM0->M0_CODIGO == "01"  //Se Emis     		//Adilson Jorge em 22/11/2019
		cString := substr(Alltrim(aDadosTit[6]),1,11)+"-"+substr(Alltrim(aDadosTit[6]),12,1)
		nCol 	  := 2010+(290-(len(cString)*22))
//	ElseIf SM0->M0_CODIGO == "02"  //Se Cativa   //Adilson Jorge em 22/11/2019
	ElseIf SM0->M0_CODIGO $ "02|03"  //Se Cativa e Nutiva  //Adilson Jorge em 05/08/2021
		cString := substr(Alltrim(aDadosTit[6]),1,17)
		nCol 	  := 2010 //+(290-(len(cString)*22))
	Endif
EndIf
oPrint:Say  (nRow3+0380,nCol,cString,oFont8)
//oPrint:Say  (nRow3+0380,nCol,cString,oFont10c)

oPrint:Say  (nRow3+0410,500 ,"Uso do Banco"                                 	,oFont8)

If Subs(aDadosBanco[1],1,3) == "237"
	oPrint:Say  (nRow3+0410,805 ,"Cip"                                        	,oFont8)
	oPrint:Say  (nRow3+0450,805 ,"000"                                       	,oFont10)
Endif	

oPrint:Say  (nRow3+0410,905 ,"Carteira"                                     	,oFont8)
* Banco do_ brasil
If Subs(aDadosBanco[1],1,3) <> "104" .AND. Subs(aDadosBanco[1],1,3) <> "237"
	oPrint:Say  (nRow3+0450,955 ,"17"                                       	,oFont10)
Else
	* CEF e BRADESCO
//		oPrint:Say  (nRow3+0450,955 ,"09"                                  			,oFont10)
//	If GETMV("MV_NECOBCA") == "N" // Adilson Jorge em 24/01/2017
//		oPrint:Say  (nRow3+0450,955 ,"09"                                  			,oFont10)
//	Else 
//		oPrint:Say  (nRow3+0450,955 ,"02"                                  			,oFont10)
//	Endif
	oPrint:Say  (nRow3+0450,955 ,cNumCar                                			,oFont10) //Adilson Jorge em 26/01/2017
endif
oPrint:Say  (nRow3+0410,1155 ,"Espécie"                                     	,oFont8)
oPrint:Say  (nRow3+0450,1205 ,"R$"                                          	,oFont10)

oPrint:Say  (nRow3+0410,1305,"Quantidade"                                   	,oFont8)
oPrint:Say  (nRow3+0410,1685,"Valor"                                        	,oFont8)

oPrint:Say  (nRow3+0410,2010,"Valor do Documento"                          		,oFont8)
cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol 	 := 2010+(260-(len(cString)*22))
oPrint:Say  (nRow3+0450,nCol,cString,oFont10c)

oPrint:Say  (nRow3+0480,500 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do beneficiário)",oFont8n)
//oPrint:SayBitmap(nRow3+0540, 1500,"system\lgrl01.bmp",429,123)
oPrint:Say  (nRow3+0540,500 ,aBolText[1] ,oFont8)
oPrint:Say  (nRow3+0575,500 ,aBolText[2] ,oFont8)
oPrint:Say  (nRow3+0610,500 ,aBolText[3] ,oFont8)
oPrint:Say  (nRow3+0645,500 ,aBolText[4] ,oFont8)

oPrint:Say  (nRow3+0480,2010,"(-)Desconto/Abatimento"                         ,oFont8)
oPrint:Say  (nRow3+0550,2010,"(-)Outras Deduções"                             ,oFont8)
oPrint:Say  (nRow3+0620,2010,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (nRow3+0690,2010,"(+)Outros Acréscimos"                           ,oFont8)
oPrint:Say  (nRow3+0760,2010,"(=)Valor Cobrado"                               ,oFont8)

oPrint:Say  (nRow3+0730,500 ,"Pagador"                                         ,oFont8)
oPrint:Say  (nRow3+0730,720 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont8)

if aDatSacado[8] = "J"
	oPrint:Say  (nRow3+0730,720 ,aDatSacado[1]+" ("+aDatSacado[2]+") CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont8) // CGC
Else
	oPrint:Say  (nRow3+0730,720 ,aDatSacado[1]+" ("+aDatSacado[2]+") CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont8) 	// CPF
EndIf

oPrint:Say  (nRow3+0760,720 ,aDatSacado[3]                                    ,oFont8)
oPrint:Say  (nRow3+0790,720 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont8) // CEP+Cidade+Estado

oPrint:Say  (nRow3+0810,500 ,"Sacador/Avalista"                               ,oFont8)
oPrint:Say  (nRow3+0865,0500,"Ficha de Compensação" ,oFont8n)
oPrint:Say  (nRow3+0895,0500,"Autenticação no verso",oFont8n)

cEMV := Alltrim(Posicione('ZBH',1,FWxFilial('ZBH')+SE1->E1_IDCNAB,'ZBH_EMV'))

If !Empty(cEMV) .AND. cEMV <> "TIPO DE DESCONTO NAO PERMITE PIX"
	oPrint:QRCode(nRow3+1235,1900,cEMV, 100)
	//oPrint:QRCode(nRow3+1090,1700,"http://google.com", 64)
	//oQrCode := FwQrCode():New({25,25,200,200},oPrint,cEMV)
EndIf

If nBol1 <> 0 
	oPrint:Say  (nRow3+980,1950,"BOLETO " + STRZERO(nBol1,2) + "/" + strzero(CalcPar(xFilial("SE1")+aDadosTit[7]+substr(aDadosTit[1],1,9)),2),oFont12n)
ENDIF

IF Subs(aDadosBanco[1],1,3) == "237"
   oPrint:Say  (nRow3+1050,1950,"BRADESCO ",oFont12n)
else
   oPrint:Say  (nRow3+0950,0500,"BANCO DO BRASIL ",oFont12n)
endif

oPrint:Say  (nRow3+1300,0100,Replicate("-",200),oFont14n) //Adilson Jorge em 03/08/11

oPrint:Line (nRow3+0150,2000,nRow3+0840,2000 )
oPrint:Line (nRow3+0560,2000,nRow3+0560,2400 )
oPrint:Line (nRow3+0630,2000,nRow3+0630,2400 )
oPrint:Line (nRow3+0700,0500,nRow3+0700,2400 )    //linha en cima de OUTROS ACRESCIMOS
oPrint:Line (nRow3+0770,2000,nRow3+0770,2400 )
oPrint:Line (nRow3+0840,0500,nRow3+0840,2400 )

*** Função de impressão do_ código de barras
//MSBAR("INT25",nRow3+1200,0500,"00198945900000001000000003386624000000143717",oPrint,.F.,,,0.023,1.4,,,,.F.)
//MSBAR("INT25",aPosBar[_nBol,1],aPosBar[_nBol,2],aCB_RN_NN[1],oPrint,.F.,,,0.023,1.4,,,,.F.)

//oPrint:FwMsBar("INT25",aPosBar[_nBol,1],aPosBar[_nBol,2],"00198945900000001000000003386624000000143717",oPrint,.F.,NIL,.T.,0.01,0.8,.F.,NIL,NIL,.F.)
oPrint:FWMSBAR("INT25",npos1,npos2,aCB_RN_NN[1],oPrint,.F.,,.T.,0.0164,1.0,nil,nil,NIL,.F.,1,1,.F.)
//oPrint:Code128C(nRow3+1200,0500,"00198945900000001000000003386624000000143717",40)
//"INT25" /*cTypeBar*/,1/*nRow*/ ,1/*nCol*/, cCodINt25/*cCode*/,oPrinter/*oPrint*/,.T./*lCheck*/,/*Color*/,.T./*lHorz*/,0.02/*nWidth*/,0.8/*nHeigth*/,.T./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)

DbSelectArea("SE1")

* Atualizo o nosso número
If EMPTY(SE1->E1_NUMBCO)
	RecLock("SE1",.f.)
	IF Subs(aDadosBanco[1],1,3) <> "237"
		If SM0->M0_CODIGO == "01"  //Se Emis     		//Adilson Jorge em 25/11/2019
			SE1->E1_NUMBCO 	:=	cNosNum //aCB_RN_NN[3]   // Nosso número (Ver fórmula para calculo)
//		ElseIf SM0->M0_CODIGO == "02"  //Se Cativa  		//Adilson Jorge em 25/11/2019
		ElseIf SM0->M0_CODIGO $ "02|03"  //Se Cativa e Nutiva  		//Adilson Jorge em 05/08/2021
			SE1->E1_NUMBCO 	:=	Substr(cNosNum,8,10) //SUBS(aCB_RN_NN[3],4,11)
		Endif
//		SE1->E1_BOLETO  :=	cNosNum //aCB_RN_NN[3]   // Nosso número (Ver fórmula para calculo)
	ELSE
		SE1->E1_NUMBCO 	:=	cNosNum //SUBS(aCB_RN_NN[3],4,11)
	ENDIF
	MsUnlock()
Endif

Return Nil


*------------------------------------------------------
*Montagem do_ código de barras sem o dígito verificador
*------------------------------------------------------
IF SM0->M0_CODIGO == "01"         				//Se Emis     	//Adilson Jorge em 25/11/2019
	cBarBru := "001"									//Código do banco
	cBarBru += "9"         					 		//Código da moeda
	cBarBru += cFatorValor 	 						//Fator de vencimento + valor
	cBarBru += left(cNosso,11) 					//Nosso Número sem o digito
	cBarBru += left(cAge,4) 						//Agência sem o digito
	cBarBru += strzero(val(left(cConta,5)),8)	//Código da conta sem o dígito
	cBarBru += "17"                         	//Código da Carteira
//ELSEIF SM0->M0_CODIGO == "02"     //Cativa     		//Adilson Jorge em 25/11/2019
ELSEIF SM0->M0_CODIGO $ "02|03"     //Cativa e Nutiva     		//Adilson Jorge em 05/08/2021
	cBarBru := "001"									//Código do banco
	cBarBru += "9"         					 		//Código da moeda
	cBarBru += cFatorValor 	 						//Fator de vencimento + valor
	cBarBru += "000000"    	 						//Zeros
	cBarBru += left(cNosso,17) 					//Nosso Número sem o digito
	cBarBru += "17"                         	//Código da Carteira
ENDIF	

*Cálculo do_ dígito verificador do_ código de barras
cDigBarN := ""
cDigBarN := U_CALC5p2(cBarBru)

//Alert(cDigBarn)
//alert(cbarbru)

*Montagem do_ cógito de barras completo
cBarBru := Substr(cBarBru,1,4) + cDigBarN + Substr(cBarBru,5,39)

*----------------------------
*Montagem da Linha digitável
*----------------------------

*Digitor verificador da linha
cLinDig1 := U_DIG2n("0019"+substr(cBarBru,20,1)+substr(cBarBru,21,4))
cLinDig2 := U_DIG2n(substr(cBarBru,25,5)+substr(cBarBru,30,5))
cLinDig3 := U_DIG2n(substr(cBarBru,35,5)+substr(cBarBru,40,5))

IF SM0->M0_CODIGO == "02"     //Cativa     		//Adilson Jorge em 28/11/2019
//IF SM0->M0_CODIGO == "02|03"    //Cativa e Nutiva  //Adilson Jorge em 05/08/2021
	cLinDig1 := U_Mod10("0019"+substr(cBarBru,20,1)+substr(cBarBru,21,4))
	cLinDig2 := U_Mod10(substr(cBarBru,25,5)+substr(cBarBru,30,5))
	cLinDig3 := U_Mod10(substr(cBarBru,35,5)+substr(cBarBru,40,5))
Endif	

cLinDig := U_CALC5p2(cBarBru)

*Primeiro campo da linha digitavel
cLinBru := "001"							//Código do banco
cLinBru += "9"								//Código da moeda
cLinBru += substr(cBarBru,20,1)		//Posição 20 do código de barras
cLinBru += "."								//Ponto para separação ds sequências da linha digitavel
cLinBru += substr(cBarBru,21,4)		//Posição 21 a 24  do código de barras
cLinBru += cLinDig1						//Digito verificador
cLinBru += " "

*Segundo campo da linha  digitavel
cLinBru += substr(cBarBru,25,5)		//Posição 25 a 29  do código de barras
cLinBru += "."								//Ponto para separação ds sequências da linha digitavel
cLinBru += substr(cBarBru,30,5)		//Posição 30 a 34  do código de barras
cLinBru += cLinDig2						//Digito verificador
cLinBru += " "

*Terceiro campo da linha digitavel
cLinBru += substr(cBarBru,35,5)		//Posição 35 a 39  do código de barras
cLinBru += "."								//Ponto para separação ds sequências da linha digitavel
cLinBru += substr(cBarBru,40,5)		//Posição 40 a 44  do código de barras
cLinBru += cLinDig3						//Digito verificador

cLinBru += " "
cLinBru += cDigBarN 						//Digito verificador do código de barras (Módulo 11)
cLinBru += " "

cLinBru += cFatorValor					//Fator de Vencimento + Valor do titulo

Aadd(aRet,cBarBru)
Aadd(aRet,cLinBru)
Aadd(aRet,cNosso)

Return aRet


*----------------------------------------------------------------------------
* Bruno Santos                                                   | 23/02/2011
*----------------------------------------------------------------------------
* Função   :  RetBarCEF
*----------------------------------------------------------------------------
* Objetivo :  Gera o código de barra e a linha digitavel da Caixa Econômica
*----------------------------------------------------------------------------
Static Function RetBarCEF(nValor, _xNumBco)
Local cNosso		:= ""
Local cNossoP       := ""
Local NNUM			:= ""
Local cBarra		:= ""
Local cParte1		:= ""
Local cParte2		:= ""
Local cParte3		:= ""
Local cParte4		:= ""
Local cParte5		:= ""
Local cDigital		:= ""
Local aRet			:= {}
Local nFatorVen		:= ""
Local cCodCed   	:= ""
Local cDVC      	:= 0
Local cNNS1     	:= 0
Local cNNS2     	:= 0
Local cNNS3     	:= 0
Local cConst1   	:= "2"
Local cConst2   	:= "4"
Local cCodBan   	:= "104"
Local cMoeda    	:= "9"
Local cDVG      	:= ""
Local cCmpLiv   	:= ""
Local nCntFor := 1

cNosso := ""

If !EMPTY(_xNumBco)
	NNUM:= alltrim(_xNumBco) //SE1->E1_NUMBCO
Else
	NNUM := cNosNum
Endif

dbSelectArea("SE1")

cNosso := NNUM

// COMPOSIÇÃO DO CÓDIGO DE BARRAS
// Identificação do banco
cCodBan 	:= "104"
// Código da moeda (9 - Real)
cMoeda  	:= "9"
// Fator de vencimento
nDataBase 	:= CtoD("07/10/1997") 			// data base para calculo do fator
nFatorVen 	:= alltrim(STR(SE1->E1_vencTO - nDataBase)) 	// acha a diferenca em dias para o fator de vencimento
// Valor do documento
nValor 		:= alltrim(str(nValor))
If "." $ nValor
	//descobrir a posicao do ponto
	If substring(nValor,len(nValor)-1,1) = "."
		nValor := substring(nValor,1,len(nValor)-2) + substring(nValor,len(nValor),len(nValor)) + "0"
	ElseIf substring(nValor,len(nValor)-2,1) = "."
		nValor := substring(nValor,1,len(nValor)-3) + substring(nValor,len(nValor)-1,len(nValor))
	End
Else
	nValor := nValor + "00"
EndIf

For nCntFor := 1 To (10 - len(nValor))
	nValor  := "0" + nValor
Next nCntFor

//nValor := STRZERO(nValor, 10)
// Campo Livre
// Código do cedente
cCodCed 	:= ALLTRIM(SA6->A6_AGENCIA)
// Dígito verificador do código do cedente
cDVC := DVM11(cCodCed)
// Nosso número SEQ1
cNNS1 := "000"
// Constante 1
cConst1 := "2"
// Nosso número SEQ2
cNNS2 := "000"
// Constante 2
cConst2 := "4"
// Nosso número SEQ3
If "-" $ NNUM
	cNNS3 := substring(NNUM, LEN(NNUM)-10, 9)
Else
	cNNS3 := substring(NNUM, LEN(NNUM)-8, LEN(NNUM))
EndIf
// Dígito verificador do campo livre
cCmpLiv := cCodCed + cDVC + cNNS1 + cConst1 + cNNS2 + cConst2 + cNNS3
cDVCL 	:= DVM11(cCmpLiv)
cCmpLiv := cCmpLiv + cDVCL
// Dígito verificador geral do código de barras
cDVG 	:= DVG(cCodBan + cMoeda + nFatorVen + nValor + cCmpLiv)
cBarra 	:= cCodBan + cMoeda + cDVG + nFatorVen + nValor + cCmpLiv
//------------------------------------------------------------
// composicao da linha digitavel
cParte1 := substring(cBarra,1,4) + substring(cBarra,20,5) + DVM10(substring(cBarra,1,4) + substring(cBarra,20,5))
cParte2 := substring(cBarra,25,10) + DVM10(substring(cBarra,25,10))
cParte3 := substring(cBarra,35,10) + DVM10(substring(cBarra,35,10))
cParte4 := substring(cBarra,5,1)
cParte5 := substring(cBarra,6,4) + substring(cBarra,10,10)

cDigital := substr(cParte1,1,5)+"."+substr(cParte1,6,4)+substring(cParte1,10,1)+" "+;
substr(cParte2,1,5)+"."+substr(cParte2,6,5)+substring(cParte2,11,1)+" "+;
substr(cParte3,1,5)+"."+substr(cParte3,6,5)+substring(cParte3,11,1)+" "+;
cParte4+" "+;
cParte5
cNossoP := "24" + cNNS1 + cNNS2 + cNNS3
cNosso  := cNossoP + "-" + DVM11(cNossoP)

If !EMPTY(_xNumBco)
	cNosso := alltrim(_xNumBco) //SE1->E1_NUMBCO
EndIf

Aadd(aRet,cBarra)
Aadd(aRet,cDigital)
Aadd(aRet,cNosso)

Return aRet

//módulo 11
Static Function DVM11(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base == 10
		base := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 1
	iDig   := iDig-1
EndDo
auxi := 11 - mod(Sumdig,11)

If auxi > 9
	auxi := "0"
Else
	auxi := str(auxi,1,0)
EndIf
Return(auxi)
//---------

//módulo 11
Static Function DVM10(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base == 0
		base := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	If auxi > 9
		auxi := val(substring(alltrim(str(auxi)),1,1)) + val(substring(alltrim(str(auxi)),2,1))
	EndIf
	sumdig := SumDig+auxi
	base   := base - 1
	iDig   := iDig - 1
EndDo
auxi := 10 - mod(Sumdig,10)

If auxi > 9
	auxi := "0"
Else
	auxi := str(auxi,1,0)
EndIf
Return(auxi)
//---------

Static Function DVG(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base == 10
		base := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 1
	iDig   := iDig-1
EndDo
auxi := mod(Sumdig,11)
If auxi = 0 .Or. auxi = 10 .Or. auxi = 1
	auxi := "1"
Else
	auxi := 11 - auxi
	auxi := str(auxi,1,0)
EndIf
Return(auxi)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSx1    ³ Autor ³ Microsiga            	³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica/cria SX1 a partir de matriz para verificacao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                    	  		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1(cPerg, aPergs)

//Local _sAlias	:= Alias()
Local aCposSX1	:= {}
Local nX 		:= 0
Local lAltera	:= .F.
//Local nCondicao
Local cKey		:= ""
Local nJ		:= 0

aCposSX1:={	"X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO",;
"X1_DECIMAL","X1_PRESEL","X1_GSC"    ,"X1_VALID"			 ,;
"X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
"X1_VAR02"  ,"X1_DEF02" ,"X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
"X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
"X1_VAR04"  ,"X1_DEF04" ,"X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
"X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
"X1_F3"     ,"X1_GRPSXG","X1_PYME"   ,"X1_HELP"				 }

dbSelectArea("SX1")
dbSetOrder(1)
For nX:=1 to Len(aPergs)
	lAltera := .F.
	If MsSeek(cPerg+Right(aPergs[nX][11], 2))
		If (ValType(aPergs[nX][Len(aPergs[nx])]) = "B" .And.;
			Eval(aPergs[nX][Len(aPergs[nx])], aPergs[nX] ))
			aPergs[nX] := ASize(aPergs[nX], Len(aPergs[nX]) - 1)
			lAltera := .T.
		Endif
	Endif
	
	If ! lAltera .And. Found() .And. X1_TIPO <> aPergs[nX][5]
		lAltera := .T.		// Garanto que o tipo da pergunta esteja correto
	Endif
	
	If ! Found() .Or. lAltera
		RecLock("SX1",If(lAltera, .F., .T.))
		Replace X1_GRUPO with cPerg
		Replace X1_ORDEM with Right(aPergs[nX][11], 2)
		For nj:=1 to Len(aCposSX1)
			If 	Len(aPergs[nX]) >= nJ .And. aPergs[nX][nJ] <> Nil .And.;
				FieldPos(AllTrim(aCposSX1[nJ])) > 0
				Replace &(AllTrim(aCposSX1[nJ])) With aPergs[nx][nj]
			Endif
		Next nj
		MsUnlock()
		cKey := "P."+AllTrim(X1_GRUPO)+AllTrim(X1_ORDEM)+"."
		
		If ValType(aPergs[nx][Len(aPergs[nx])]) = "A"
			aHelpSpa := aPergs[nx][Len(aPergs[nx])]
		Else
			aHelpSpa := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-1]) = "A"
			aHelpEng := aPergs[nx][Len(aPergs[nx])-1]
		Else
			aHelpEng := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-2]) = "A"
			aHelpPor := aPergs[nx][Len(aPergs[nx])-2]
		Else
			aHelpPor := {}
		Endif
		
		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
	Endif
Next

RETURN

STATIC FUNCTION QUEBRASTR(cStr)

RETURN


*----------------------------------------------------------------------------
* Bruno Santos                                                   | 23/02/2011
*----------------------------------------------------------------------------
* Função : Ret_237cBarra
*----------------------------------------------------------------------------
* Objetivo :  Calcula o código de barras e a linha digitavel do_ Bradesco
*----------------------------------------------------------------------------
Static Function Ret_237cBarra(cBanco  ,cAgencia,cConta  ,cDacCC,cCarteira,cNroDoc ,nValor,dvencimento,cConvenio,cSequencial,_lTemDesc,_cParcela,_cAgCompleta,_xNumBco)

Local cCodEmp 		:= StrZero(Val(SubStr(cConvenio,1,6)),6) //nao utiliza
Local cNumSeq 		:= strzero(val(cSequencial),5)           //nao utiliza
Local bldocnufinal 	:= strzero(val(cNroDoc),11)
Local blvalorfinal	:= strzero(nValor*100,10)
Local blvalorf2		:= strzero(nValor*100,14)
Local cNNumSDig		:= cCpoLivre := cCBSemDig := cCodBarra := cNNum := cFatVenc := ''
Local cNossoNum
Local _cDigito   	:= ""   //nao utiliza
Local _cSuperDig 	:= ""  //nao utiliza
Local aRet 			:= {}

If !EMPTY(_xNumBco)
	bldocnufinal	:= alltrim(_xNumBco) //SE1->E1_NUMBCO
Else
	bldocnufinal 	:= cNosNum
Endif

dbSelectArea("SE1")

_cParcela := NumParcela(_cParcela)     //nao utiliza

//Fator Vencimento - POSICAO DE 06 A 09
cFatVenc := STRZERO(dvencimento - CtoD("07/10/1997"),4)


//Campo Livre (Definir campo livre com cada banco)
//Nosso Numero sem digito
//cNNumSDig := cCarteira + bldocnufinal
cNNumSDig := bldocnufinal
//Nosso Numero
//cNNum := cCarteira + '/' + bldocnufinal + '-' + AllTrim( Str( modulo10( cNNumSDig ) ) )   //nao utiliza
cNNum := cCarteira + bldocnufinal
//Nosso Numero para impressao

//cNossoNum := "09" + '/' + bldocnufinal + '-' + AllTrim( U_Mod11n( cNNum ))
cNossoNum :=  bldocnufinal  + AllTrim( U_Mod11n( cNNum ))
//	cCpoLivre := cAgencia + "09" + cNNumSDig + StrZero(Val(cConta),7) + "0"
//If GETMV("MV_NECOBCA") == "N" // Adilson Jorge em 24/01/2017
//	cCpoLivre := cAgencia + "09" + cNNumSDig + StrZero(Val(cConta),7) + "0"
//Else
//	cCpoLivre := cAgencia + "02" + cNNumSDig + StrZero(Val(cConta),7) + "0"
//Endif
cCpoLivre := cAgencia + cNumCar + cNNumSDig + StrZero(Val(cConta),7) + "0" //Adilson Jorge em 26/01/2017

//Dados para Calcular o Dig Verificador Geral
cCBSemDig := cBanco + cFatVenc + blvalorfinal + cCpoLivre


*------------------------------------------------------
*Montagem do_ código de barras sem o dígito verificador
*------------------------------------------------------
cBarBra := "237"							   		//Código do banco
cBarBra += "9"         					 			//Código da moeda
cBarBra += cFatVenc									//Fator de vencimento
cBarBra += blvalorfinal	 							//Valor final
cBarBra += left(cAgencia,4) 						//Agência sem o digito
//cBarBra += "09"                     		   //Código da Carteira
//If GETMV("MV_NECOBCA") == "N" // Adilson Jorge em 24/01/2017
//	cBarBra += "09"                     		//Código da Carteira
//Else
//	cBarBra += "02"                    			//Código da Carteira
//Endif
cBarBra += cNumCar                     		//Código da Carteira   //Adilson Jorge em 26/01/2017

cBarBra += left(cNossoNum,11) 					//Nosso Número sem o digito
cBarBra += StrZero(Val(cConta),7) + "0"     	//Conta do cedente

//cBarBra += strzero(val(left(cConta,5)),8)  //Código da conta sem o dígito

*Cálculo do_ dígito verificador do_ código de barras
cDigBa := MODULO11(cBarBra)

*Montagem do_ cógito de barras completo
cBarBra := Substr(cBarBra,1,4) + cDigBa + Substr(cBarBra,5,39)



*---------------------------------------------------------------
* Montagem da linha digitável
*---------------------------------------------------------------

*Digitor verificador da linha
cLinDg1 := Modulo10("2379"+substr(cBarBra,20,1)+substr(cBarBra,21,4))
cLinDg2 := Modulo10(substr(cBarBra,25,5)+substr(cBarBra,30,5))
cLinDg3 := Modulo10(substr(cBarBra,35,5)+substr(cBarBra,40,5))

cLinDig := modulo11(cBarBra)

*Primeiro campo da linha digitavel
cLinBra := "237"							//Código do banco

cLinBra += "9"								//Código da moeda
cLinBra += alltrim(substr(cBarBra,20,1))	//Posição 20 do código de barras

cLinBra += "."								//Ponto para separação ds sequências da linha digitavel
cLinBra += alltrim(substr(cBarBra,21,4))	//Posição 21 a 24  do código de barras
cLinBra += alltrim(str(cLinDg1))			//Digito verificador
cLinBra += " "

*Segundo campo da linha  digitavel
cLinBra += alltrim(substr(cBarBra,25,5))	//Posição 25 a 29  do código de barras
cLinBra += "."								//Ponto para separação ds sequências da linha digitavel
cLinBra += alltrim(substr(cBarBra,30,5))	//Posição 30 a 34  do código de barras
cLinBra += alltrim(str(cLinDg2))			//Digito verificador
cLinBra += " "

*Terceiro campo da linha digitavel
cLinBra += alltrim(substr(cBarBra,35,5))	//Posição 35 a 39  do código de barras
cLinBra += "."								//Ponto para separação ds sequências da linha digitavel
cLinBra += alltrim(substr(cBarBra,40,5))	//Posição 40 a 44  do código de barras
cLinBra += alltrim(str(cLinDg3))			//Digito verificador

cLinBra += " "
cLinBra += alltrim(cDigBa)					//Digito verificador do código de barras (Módulo 11)
cLinBra += " "

cLinBra += alltrim(cFatVenc+blvalorfinal)


/*


//Codigo de Barras Completo
cCodBarra := cBanco + Modulo11(cCBSemDig) + cFatVenc + blvalorfinal + cCpoLivre

//Digito Verificador do Primeiro Campo
cPrCpo	 := cBanco + SubStr(cCodBarra,20,5)
cDvPrCpo := AllTrim(Str(Modulo10(cPrCpo)))

//Digito Verificador do Segundo Campo
cSgCpo 	 := SubStr(cCodBarra,25,10)
cDvSgCpo := AllTrim(Str(Modulo10(cSgCpo)))

//Digito Verificador do Terceiro Campo
cTrCpo   := SubStr(cCodBarra,35,10)
cDvTrCpo := AllTrim(Str(Modulo10(cTrCpo)))

//Digito Verificador Geral
cDvGeral := SubStr(cCodBarra,5,1)

//Linha Digitavel
cLindig  := SubStr(cPrCpo,1,5) + "." + SubStr(cPrCpo,6,4) + cDvPrCpo + " "   //primeiro campo
cLinDig  += SubStr(cSgCpo,1,5) + "." + SubStr(cSgCpo,6,5) + cDvSgCpo + " "   //segundo campo
cLinDig  += SubStr(cTrCpo,1,5) + "." + SubStr(cTrCpo,6,5) + cDvTrCpo + " "   //terceiro campo
cLinDig  += " "  + cDvGeral              //dig verificador geral
cLinDig  += " " + SubStr(cCodBarra,6,4)+SubStr(cCodBarra,10,10)  // fator de vencimento e valor nominal do titulo
*/
//cLinDig += "  " + cFatVenc +blvalorfinal  // fator de vencimento e valor nominal do titulo

//O RETORNO SERA DE ACORDO COM O EXISTENTE PARA O BANCO DO BRASIL.

//Aadd(aRet,cCodBarra)
//Aadd(aRet,cLinDig)
Aadd(aRet,cBarBra)
Aadd(aRet,cLinBra)
Aadd(aRet,cNossoNum)

//Return({cCodBarra,cLinDig,cNossoNum})
Return aRet

Static Function NumParcela(_cParcela)
Local _cRet := ""
If ASC(_cParcela) >= 65 .or. ASC(_cParcela) <= 90
	_cRet := StrZero(Val(Chr(ASC(_cParcela)-16)),2)
Else
	_cRet := StrZero(Val(_cParcela),2)
Endif
Return(_cRet)


Static Function Modulo10(cData)
Local L,D,P := 0
Local B     := .F.
L := Len(cData)  //TAMANHO DE BYTES DO CARACTER
B := .T.
D := 0 		    //DIGITO VERIFICADOR
While L > 0
	P := Val(SubStr(cData, L, 1))
	If (B)
		P := P * 2
		If P > 9
			P := P - 9
		End
	End
	D := D + P
	L := L - 1
	B := !B
End
D := 10 - (Mod(D,10))
If D = 10
	D := 0
End
Return(D)

Static Function Modulo11(cData)
Local L, D, P := 0
L := Len(cdata)
D := 0
P := 1
While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 9
		P := 1
	End
	L := L - 1
End
D := 11 - (mod(D,11))
If (D > 09 .OR. D==0 .OR. D==1)
	D := 1
End
D := AllTrim(Str(D))
Return(D)


*----------------------------------------------------------------------------
* Bruno Santos                                                   | 24/02/2011
*----------------------------------------------------------------------------
* Função   : GERNNUM11
*----------------------------------------------------------------------------
* Objetivo : Gera o nosso numero tanto para o Bradesco quanto para o Brasil
*----------------------------------------------------------------------------
STATIC FUNCTION GERNNUM11()
Local cNumbco := SE1->E1_NUMBCO

*----------------------------------------------------------
* Posiciona no arquivo de parametro CNAB do_ Bradesco
*----------------------------------------------------------
IF SE1->E1_PORTADO == '237'   //Bradesco
	If Empty(SE1->E1_NUMBCO) //se nosso numero estiver em branco
		dbSelectArea("SEE")
		dbSetOrder(1)
		//Alert(GETMV("MV_NECOBCA"))
		If GETMV("MV_NECOBCA") == "S" // Adilson Jorge em 31/10/2018, se for cobrança caucionada
			If !dbSeek(XFILIAL("SEE")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA+"004" )
				Alert("Banco não cadastrado nos Parâmetros CNAB SubConta 004")
				Return
			EndIf
		Else									// Adilson Jorge em 31/10/2018, se for cobrança simples
			If !dbSeek(XFILIAL("SEE")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA+"001" )
				Alert("Banco não cadastrado nos Parâmetros CNAB SubConta 001")
				Return
			EndIf
		Endif			
		//Ajuste feito por Adilson Jorge em 19/07/2018, para incrementar o numero do boleto, não tinha feito em 28/02/2012 para o Bradesco
		//antes de verificar se existe no SE1
		RecLock("SEE",.F.)
		SEE->EE_FAXATU := StrZero(Val(alltrim(SEE->EE_FAXATU))+1,12)
		MsUnlock()
		
		cNumCar := Trim(SEE->EE_CODCART)  //Adilson Jorge em 26/01/2017, coletando a carteira do Bradesco, 09 Simples ou 02 Caucionada
		cNumbco := StrZero(Val(SEE->EE_FAXATU),11) + digbrad(StrZero(Val(SEE->EE_FAXATU),11))

		If cEmpAnt == "01"
			cNumbco := NewBco(cNumbco,Nil)
		Endif

		lbru    := validn2(cNumbco) //Valida se já existe o nosso numero gerado
		if lbru
		   Alert(FunName()+":"+ProcName(0)+" O nosso numero " + cNumbco + " ja existe, avise o CPD !" )
			Return
		endif
		//RecLock("SEE",.F.)
		//SEE->EE_FAXATU := STRZERO(VAL(SUBSTR(cNumbco,1,11)),12)
		//MsUnlock()
	ELSE
		cNumbco := SE1->E1_NUMBCO
	endif
ELSE
	*--------------------------------------------------------
	*Posiciona no Arq de Parametros CNAB do_ Banco do_ Brasil
	*--------------------------------------------------------
	DbSelectArea("SEE")
	DbSetOrder(1)
	if DbSeek(FWxFilial('SEE')+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA+"005")
		If Empty(SE1->E1_NUMBCO)
			RecLock("SEE",.F.)
			SEE->EE_FAXATU := StrZero(Val(alltrim(SEE->EE_FAXATU))+1,12)
			MsUnlock()
			If SM0->M0_CODIGO == "01"  //Se Emis     		//Adilson Jorge em 22/11/2019
				cNumbco := alltrim(Str(Val(alltrim(SEE->EE_CODEMP)))+Strzero(Val(Alltrim(SEE->EE_FAXATU)),5)) + u_CALC_dig(alltrim(Str(Val(alltrim(SEE->EE_CODEMP)))+Strzero(Val(Alltrim(SEE->EE_FAXATU)),5)))
			ElseIf SM0->M0_CODIGO $ "02|03"  //Se Cativa	e Nutuva //Adilson Jorge em 05/08/2021
				cNumbco := alltrim(Str(Val(alltrim(SEE->EE_CODEMP)))+Strzero(Val(Alltrim(SEE->EE_FAXATU)),10))
			Endif			
			If cEmpAnt == "01"
				cNumbco := NewBco(cNumbco,Nil)
			Endif
			lbru := validn2(cNumbco) //Valida se já existe o nosso numero gerado
			if lbru
				Alert(FunName()+":"+ProcName(0)+" O nosso numero " + cNumbco + " ja existe, avise o CPD !" )
				Return
			endif
		Else
			If SM0->M0_CODIGO == "01"
				cNumbco :=  SE1->E1_NUMBCO  //Str(Val(alltrim(SEE->EE_CODEMP)))+Strzero(Val(Alltrim(SEE->EE_FAXATU)),5)
			ElseIf SM0->M0_CODIGO $ "02|03"  //Se Cativa	e Nutuva //Adilson Jorge em 05/08/2021
				cNumbco := alltrim(Str(Val(alltrim(SEE->EE_CODEMP)))+Substr(SE1->E1_NUMBCO,1,10))
			Endif
		Endif
	endif
ENDIF
RETURN(cNumBCO)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  BOL341  ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASE DO B.BRASIL COM CODIGO DE BARRAS  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Modu10(cData)
LOCAL L, D, P, nInt := 0
L := Len(cdata)
D := 0
P := 2
N := 0

While L > 0
	N := (Val(SubStr(cData, L, 1)) * P)
	If N > 9
		D := D + (Val(SubsTr(Str(N,2),1,1)) + Val(SubsTr(Str(N,2),2,1)))
	Else
		D := D + N
	Endif
	If P = 2
		P := 1
	Elseif P = 1
		P := 2
	EndIf
	L := L - 1
End

D := Mod(D,10)
D := 11 - D

If D == 10
	D:=0
Endif

Return(D)





*----------------------------------------------------------------------------
* Bruno Santos                                                   | 24/02/2011
*----------------------------------------------------------------------------
* Função   : digbrad
*----------------------------------------------------------------------------
* Objetivo : Gera o digito verificador do_ nosso numero do_ braqdesco
*----------------------------------------------------------------------------
Static function digbrad(cNumBco)
Local i

M->nCont   := 0
M->cPeso   := 2
//If GETMV("MV_NECOBCA") == "N" // Adilson Jorge em 24/01/2017
//	M->nBoleta :="09" + cNumBco
//Else
//	M->nBoleta :="02" + cNumBco
//Endif

M->nBoleta := cNumCar + cNumBco //Adilson Jorge em 26/01/2017

For i := 13 To 1 Step -1
	
	M->nCont := M->nCont + (Val(SUBSTR(M->nBoleta,i,1))) * M->cPeso
	M->cPeso := M->cPeso + 1
	If M->cPeso == 8
		M->cPeso := 2
	Endif
	
Next

M->Resto := ( M->nCont % 11 )

Do Case
	Case M->Resto == 1
		M->DV_NNUM := "P"
	Case M->Resto == 0
		M->DV_NNUM := "0"
	OtherWise
		M->Resto   := ( 11 - M->Resto )
		M->DV_NNUM := AllTrim(Str(M->Resto))
EndCase

//					cNumbco += M->DV_NNUM
return(M->DV_NNUM)



*----------------------------------------------------------------------------
* Bruno Santos                                                   | 13/04/2011
*----------------------------------------------------------------------------
* Função : validn2
*----------------------------------------------------------------------------
* Objetivo :  Valida se já existe o nosso número gerado
*----------------------------------------------------------------------------

Static function validn2(cNum)
Local cQuery := ''
Local lRet   := .F.
Local nRECNO := 0
cQuery := "SELECT COUNT(R_E_C_N_O_) NRECNO FROM "+RETSQLNAME("SE1") +" WHERE D_E_L_E_T_ = '' and E1_NUMBCO = '"+ cNum +"' AND E1_EMISSAO BETWEEN '"+Left(DTOS(dDataBase),4)+"0101' AND '"+DTOS(dDataBase)+"' "
nRECNO := MpSysExecScalar(cQuery,"NRECNO")
If nRECNO <> 0
	lRet := .T.
Endif
Return lRet




*----------------------------------------------------------------------------
* Bruno Santos                                                   | 19/04/2011
*----------------------------------------------------------------------------
* Função : CalcPar
*----------------------------------------------------------------------------
* Objetivo :  Calcula o número de parcelas do titulo
*----------------------------------------------------------------------------

Static function CalcPar(cNum)
Local aArea := Getarea()

If Select("QRY") > 0 
	QRY->(DbCloseArea())
Endif
nPar := 0
cQuery:=" SELECT COUNT(*) AS QTD FROM "+RETSQLNAME("SE1")
cQuery+="  WHERE D_E_L_E_T_ = ' ' and E1_FILIAL + E1_PREFIXO + E1_NUM = '" + cNum+ "' "
dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "QRY",.F.,.T.)
npar := QRY->QTD
If !(QRY->(EOF()) .AND. QRY->(BOF()))
	lRet := .T.
Endif
dbselectArea("QRY")
QRY->(DBCloseArea())
return(nPar)

Static Function NewBco(Numbco,cNext)
Local Query   := ""
Local cNewBco := ""
Local cSequen := Nil
Local cSeek   := ""
Local nTam    := 11
If cNext == Nil
	cSequen := cIniSeq
Else
	cSequen := cNext
Endif
cSeek := AllTrim(Numbco)
nTam  := Len(cSeek)-1
cSeek := Left(cSeek,nTam) // retirar o digito da pesquisa
Query := "SELECT SE1.R_E_C_N_O_ FROM " + RetSqlName("SE1") + " SE1 WITH (NOLOCK) "
Query += "WHERE LEFT(SE1.E1_NUMBCO,"+cValToChar(nTam)+") = '"+cSeek+"' AND SE1.D_E_L_E_T_ = ' ' "
MPSysOpenQuery( Query, "TRBTMP" )
TRBTMP->(DbGoTop())
If TRBTMP->(Eof()) .And. !"****" $ Numbco
	If Select("TRBTMP") > 0
		TRBTMP->(DbCloseArea())
	Endif
	DbSelectArea("SE1")
	Return Numbco
Else
	If Select("TRBTMP") > 0
		TRBTMP->(DbCloseArea())
	Endif
	DbSelectArea("SE1")
	cSequen := StrZero(Val(GetMv("NA_SEQNBCO"))+1,5)
	PutMv("NA_SEQNBCO",cSequen)
	//cSequen := Soma1(cSequen)
	cNewBco := Left(Numbco,6) + cSequen
	cNewBco := cNewBco + U_CALC_DIG(cNewBco) // '532751382493   '
	If "****" $ Numbco .And. !"****" $ cNewBco
		If validn2(cNewBco)
			Numbco  := NewBco(cNewBco,cSequen)
			Return Numbco
		Endif
		Return cNewBco
	Endif
	If validn2(cNewBco)	
		Numbco  := NewBco(cNewBco,cSequen)
	Endif
	Return Numbco
Endif
Return Numbco
