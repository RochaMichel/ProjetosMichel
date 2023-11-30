#include "rwmake.ch"
#Include "PROTHEUS.CH"
#include "TopConn.Ch"
#INCLUDE "FWPrintSetup.ch"
#Include "RPTDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

User Function BOLSOF()

	Local cPerg     := "BOL001"
	Private lEnd  	:= .F.
	PRIVATE lExec    	:= .F.
	PRIVATE cIndexName 	:= ''
	PRIVATE cIndexKey  	:= ''
	PRIVATE cFilter    	:= ''



	Pergunte(cPerg,.T.)

	dbSelectArea("SE1")
	cIndexName := GetNextAlias()
	cIndexKey  := 	"E1_PORTADO+E1_CLIENTE+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+DTOS(E1_EMISSAO)"
	cFilter    := 	"E1_PREFIXO >= '" + MV_PAR01 + "' .And. E1_PREFIXO <= '" + MV_PAR02 + "' .And. " + ;
		"E1_NUM     >= '" + Padr(MV_PAR03,TamSx3('E1_NUM')[1]) +     "' .And. E1_NUM         <= '" + Padr(MV_PAR04,TamSx3('E1_NUM')[1]) +     "' .And. " + ;
		"E1_PARCELA >= '" + Padr(MV_PAR05,TamSx3('E1_PARCELA')[1]) + "' .And. E1_PARCELA     <= '" + Padr(MV_PAR06,TamSx3('E1_PARCELA')[1]) + "' .And. " + ;
		"E1_NUMBOR   = '" + Padr(MV_PAR24,TamSx3('E1_NUMBOR')[1]) +  "' .AND. E1_FILIAL = '" + cFilAnt + "'"

	IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")

	DbSelectArea("SE1")
	#IFNDEF TOP
		DbSetIndex(cIndexName + OrdBagExt())
	#ENDIF
/*	dbGoTop()

	@ 001,001 TO 400,700 DIALOG oDlg TITLE "Selecao de Titulos"
	@ 001,001 TO 170,350 BROWSE "SE1" MARK "E1_OK"
	@ 180,310 BMPBUTTON TYPE 01 ACTION (lExec := .T.,Close(oDlg))
	@ 180,280 BMPBUTTON TYPE 02 ACTION (lExec := .F.,Close(oDlg))
	ACTIVATE DIALOG oDlg CENTERED
	dbGoTop()

	If lExec*/
	Processa({ |lEnd| MontaRel(.F.) })
//	Endif

	RetIndex("SE1")
	fErase(cIndexName+OrdBagExt())

Return Nil

Static Function MontaRel(lWSPDF,_filial,_titulo,_pref,_client,_loja,_parc)

	LOCAL oPrint
	LOCAL n := 0

	LOCAL aDadosEmp    := {SubStr( AllTrim(SM0->M0_NOMECOM), 1, Len(AllTrim(SM0->M0_NOMECOM))-6) ,; //[1]Nome da Empresa
	AllTrim(SM0->M0_ENDCOB)                                                            					 ,; //[2]EndereÃ§o
	AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB 					 ,; //[3]Complemento
	Transform(SM0->M0_CEPCOB,"@R 99.999-999")             					                     ,; //[4]CEP
	"PABX/FAX: "+SM0->M0_TEL                                                  					 ,; //[5]Telefones
	"CNPJ/CPF: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+          					  ; //[6]
	Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       					  ; //[6]
	Subs(SM0->M0_CGC,13,2)                                                    					 ,; //[6]CGC
	"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            					  ; //[7]
	Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                        					  } //[7]I.E

	LOCAL aDadosTit
	LOCAL aDadosBanco
	LOCAL aDatSacado
	LOCAL aBolText
	LOCAL i         := 1
	LOCAL CB_RN_NN  := {}
	//LOCAL nRec      := 0
	LOCAL _nTotEnc  := 0
	Local cEndc     := " "
	Local cMunic    := " "
	Local cBairc    := " "
	Local cEstc     := " "
	Local cCepc     := " "
	Local cFile 	:= " "
	Private cNroDoc := " "
	PRIVATE nDvnn		:= 0
	Default lWSPDF := .F.
	Default _filial	:= ''
	Default _titulo := ''
	Default _pref	:= ''
	Default _client	:= ''
	Default _loja	:= ''
	Default _parc	:= ''

	Private cStartPath:= GetSrvProfString("Startpath","")
	if lWSPDF
		dbSelectArea("SE1")
		SE1->(dbSetOrder(1))
		SE1->(dbSeek(_filial+_pref+_titulo+_parc+"NF "))

	elseif !empty(_titulo)
		cFile := _filial+_titulo+_pref
	else
		cFile := Substr(SE1->E1_CLIENTE+'-' + POSICIONE("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_NOME"  ),1,20) + '-' + Alltrim(SE1->E1_NUM) + '-' + Alltrim(SE1->E1_PARCELA)
	endif

	if lWSPDF
		cFile := MD5(ALLTRIM(SE1->E1_FILIAL+SE1->E1_NUM+SE1->E1_CLIENTE+SE1->E1_LOJA+ALLTRIM(SE1->E1_PARCELA)))
		cCaminho := "\web\ws\boleto\"
		FErase( cCaminho+MD5(cFile)+".pdf" )
	Else
		cCaminho := "\spool\"
		FErase( cCaminho+cFile+".pdf" )
	ENdIf

	If  lWSPDF
		oPrint := FwMSPrinter():New( cFile, IMP_PDF , .T. , cCaminho, .T., , , , , .F., ,.F. )
		oPrint:cPathPDF := cCaminho
	Else
		oPrint := FwMSPrinter():New( cFile, IMP_SPOOL , .T. , , .T., , , , , .T., ,.T. )
		oPrint:Setup()
		oPrint:SetPortrait()
		//	oPrint:StartPage()
	EndIf

	//dbGoTop()
	//Do While !EOF()
	//	nRec := nRec + 1
	//	dbSkip()
	//EndDo
	//dbGoTop()
	//ProcRegua(nRec)
	cDescBan := '' //DescriÃ§Ã£o do banco
	cDigB    := '' //Digito do banco
	If lWSPDF
	DbSelectArea("SE1")
	SE1->(DbSetOrder(1))
	SE1->(dbSeek(_filial+_pref+_titulo+_parc+"NF "))
	EndIF
	While !SE1->(EOF()) .AND.;
	 IIF(lWsPDF,SE1->(E1_FILIAL+E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA+E1_PARCELA) == _filial+_titulo+_pref+_client+_loja+_parc,.T.)
		If lWSPDF
			//Marca o campo E1_BOLETO do título como gerado ('1') - 02/05/2022
			U_FlagBol(SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA))
		ENDIF
		//Posiciona o SA1 (Cliente)
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(SE1->(xFilial("SA1")+E1_CLIENTE+E1_LOJA)))

		cEndc  := SA1->A1_END
		cMunic := SA1->A1_MUN
		cBairc := SA1->A1_BAIRRO
		cEstc  := SA1->A1_EST
		cCepc  := SA1->A1_CEP

		aDatSacado   := {AllTrim(SA1->A1_NOME)          ,; // [1]RazÃ£o Social
		AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA           ,; // [2]CÃ³digo
		Alltrim(cEndc)  						        ,; // [3]EndereÃ§o
		Alltrim(cBairc)+"  "+AllTrim(cMunic)            ,; // [4]Cidade
		cEstc                                           ,; // [5]Estado
		Transform(cCepc,"@R 99.999-999")                ,; // [6]CEP
		Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")  }  // [7]CGC

		//Posiciona o SA6 (Bancos)
		DbSelectArea("SA6")
		SA6->(DbSetOrder(1))
		SA6->(DbSeek(xFilial("SA6")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.))

		//Banco Sofisa 21-09-2020
		cDescBan  := 'Santander'
		cBanco 	  := '033'   //'BANCO SOFISA S/A'
		cDigB     := '-7'
		cAgencia  := "03689"
		cConvenio := "4845013"
		cCarteira := '101'

		_COD 		:= SA6->A6_COD
		_Agencia 	:= Alltrim(SA6->A6_AGENCIA)

		//cAgencia    := Alltrim(SA6->A6_AGENCIA)

		_NumCon		:= AllTrim(SA6->A6_NUMCON)
		_DVCTA   	:= Alltrim(SA6->A6_DVCTA)
		_DVAGE   	:= Alltrim(SA6->A6_DVAGE)
		//_cOpera     := '' // Apenas Daycoval como nÃ£o correspondente
		//_TemLimB    := SA6->A6_TEMLIMB

		aDadosBanco  := {cBanco+cDigB                   ,; // [1]Numero do Banco
		cDescBan										,;
		_Agencia 								   		,; // [3]AgÃªncia
		_NumCon    				                 		,; // [4]Conta Corrente
		_DVCTA                                  		,; // [5]DÃ­gito da conta corrente
		cCarteira                          	   			,; // [6]Codigo da Carteira
		_DVAGE							        		,; // [7]Digito da AgÃªncia
		SA6->A6_COD										,; // [8] Codigo do banco no ERP
		SA6->A6_NOME									,; // [9] Nome do banco
		Transform(SA6->A6_CGC,"@R 99.999-999")			,; // [10] CPF/CNPJ
		SA6->A6_END										,; // [11]endereço
		SA6->A6_MUN										,; // [12]municipio
		SA6->A6_BAIRRO									,; // [13]bairro
		SA6->A6_CEP										}  // [14] Cep

		_nTotEnc :=    0

		nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

		DbSelectArea("SEE")
		SEE->(DbSetOrder(1))
		SEE->(DbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.))
		If Empty(SE1->E1_NUMBCO)

			While SEE->( !RecLock('SEE',.F.) )
				LjMsgRun('BOLSOFISA - Aguardando LiberaÃ§Ã£o do Nosso NÃºmero')
			EndDo

			cNroDoc := StrZero(Val(Alltrim(SEE->EE_FAXATU))+1,12)

			RecLock("SEE",.F.)
			SEE->EE_FAXATU :=	RIGHT(cNroDoc,12)
			MsUnlock()

		Else
			cNroDoc := SubStr(AllTrim(SE1->E1_NUMBCO),1,Len(AllTrim(SE1->E1_NUMBCO))-1)
		Endif
		//cConvenio := Alltrim(SEE->EE_CODEMP)
		CB_RN_NN    := Ret_cBar637(Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],aDadosBanco[6],cNroDoc,(SE1->E1_SALDO - SE1->E1_DECRESC + SE1->E1_ACRESC),cConvenio)

		If Empty(SE1->E1_NUMBCO)
			RecLock("SE1",.F.)
			SE1->E1_NUMBCO := CB_RN_NN[3]//RIGHT(cNroDoc,15)
			MsUnlock()
		Endif

		aDadosTit    := {" "+AllTrim(iif(empty(ALLTRIM(SE1->E1_NRDOC)),SE1->E1_NUM,SE1->E1_NRDOC))+" "+AllTrim(SE1->E1_PARCELA) ,;  // [01] NÃºmero do tÃ­tulo
		SE1->E1_EMISSAO                                            													            ,;  // [02] Data da emissÃ£o do tÃ­tulo
		Date()                                                														            ,;  // [03] Data da emissÃ£o do boleto
		Substr(DtoS(SE1->E1_VENCREA),7,2)+'/'+Substr(DtoS(SE1->E1_VENCREA),5,2)+'/'+Substr(DtoS(SE1->E1_VENCREA),1,4)	        ,;  // [04] Data do vencimento
		(SE1->E1_SALDO - SE1->E1_DECRESC + SE1->E1_ACRESC)								                                        ,;  // [05] Valor do tÃ­tulo
		CB_RN_NN[3]                                     															            ,;  // [06]
		SE1->E1_PREFIXO                                            													            ,;  // [07] Prefixo da NF
		SE1->E1_TIPO                                                  												            ,;  // [08] Tipo do Titulo
		SE1->E1_IRRF                                                  												            ,;  // [09] IRRF
		SE1->E1_ISS                                                													            ,;  // [10] ISS
		SE1->E1_INSS                                               													            ,;  // [11] INSS
		SE1->E1_PIS                                                													            ,;  // [12] PIS
		SE1->E1_COFINS                                             													            ,;  // [13] COFINS
		SE1->E1_CSLL                                               													            ,;  // [14] CSLL
		0                                                     														            ,; 	// [15] Abatimentos
		AllTrim(SE1->E1_NFELETR)                                   					 									             }  // [16] NF Eletronica

		aBolText := {" " }

		Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN,lWSPDF)
		n := n + 1

		SE1->(dbSkip())
	    i := i + 1
	End
	oPrint:EndPage()     // Finaliza a pÃ¡gina
	oPrint:Preview()     // Visualiza antes de imprimir
Return nil

//=============================================
//  REPRESENTAÃ‡ÃƒO NUMERICA DO BOLETO          //
//=============================================

Static Function Ret_cBar637(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor,cConvenio)

	LOCAL cValorFinal   := strzero(nValor*100,10)
	LOCAL nDvcb			:= 0
	LOCAL nDv			:= 0
	LOCAL cNN			:= ''
	LOCAL cRN			:= ''
	LOCAL cCB			:= ''
	LOCAL cS			:= ''
	LOCAL cFator        := strzero(SE1->E1_VENCREA - ctod("07/10/97"),4)

	//Local cBanco      := "637"
//-----------------------------//
// Definicao do NOSSO NUMERO   //
// ----------------------------//

	cS    := Alltrim(StrZero(Val(cNroDoc),12))
	nDvnn := modulo11(cs,.T.)// digito verificador Nosso Num
	cNN   := cS + AllTrim(str(nDvnn))

//----------------------------------//
//	 Definicao do CODIGO DE BARRAS  //
//----------------------------------//

	cS    := cBanco + "9" + cFator +  cValorFinal + '9' + SUBSTR(Trim(cConvenio),1,7) + cNN + "0" + cCarteira
	nDvcb := modulo11(cS,.F.)
//	cCB   := SubStr(cS, 1, 4) + AllTrim(Str(nDvcb)) + SubStr(cS,5,39)
	cCB	  := cBanco + "9" + AllTrim(Str(nDvcb)) + cFator +  cValorFinal + '9' + SUBSTR(Trim(cConvenio),1,7) + cNN + "0" + cCarteira

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
	cRN   := cS + AllTrim(Str(nDv))

// 	CAMPO 2:
//    FFFF = Codigo do Dedente (4 ultimos digitos)
// NNNNNNN = 2 primeiros digitos do nosso numero
//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

	cS    := SUBSTR(cConvenio,5,3) + substr(cNN,1,7)
	nDv   := modulo10(cS)
	cRN   := cRN + cS + Alltrim(Str(nDv))

// 	CAMPO 3:
//NNNNNN = Restante do Nosso Numero
//	   N = FIXO '0'
// 	 NNN = TIPO DE MODALIDADE CARTEIRA
//	   Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

	cS    := SUBSTR(cNN,8,6) + "0" + cCarteira
	nDv   := modulo10(cS)
	cRN   := cRN + cS + Alltrim(Str(nDv))

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
	cRN   := cRN + AllTrim(Str(nDvcb))

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
	cRN   := cRN + cFator + StrZero((nValor*100),10)

Return({cCB,cRN,cNN})



Static Function Modulo11(cData,lNossoNum_DV)

	Local L := Len(cdata)
	Local D := 0
	Local P := 1
	While L > 0
		P := P + 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P = 9
			P := 1
		End
		L := L - 1
	End
	If lNossoNum_DV
		D := mod(D,11)
		If D == 10
			D := 1
		ElseIf D == 0 .OR. D == 1
			D := 0
		Else
			D := 11 - D
		EndIf
	Else
		D := D * 10
		D := mod(D,11)
		If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
			D := 1
		EndIf
	EndIf

Return(D)


Static Function Modulo10(cData)

	Local L := 0
	Local D := 0
	Local P := 0
	//Local nInt := 0

	L := Len(cdata)
	D := 0
	P := 2
	N := 0
	nMult := 10

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

	While nMult < D
		nMult := nMult + 10
	endDo

	D := nMult - D

	If D == 10
		D:=0
	Endif

Return(D)



//=============================================
//  IMPRESSÃƒO DO BOLETO                      //
//=============================================

Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN,lWSPDF)
	LOCAL oFont8
	LOCAL oFont10
	LOCAL oFont16
	LOCAL oFont16n
	LOCAL oFont24
	LOCAL i := 0


//ParÃ¢metros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
	oFont8   := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont9n  := TFont():New("Arial",9,9 ,.T.,.F.,5,.T.,5,.T.,.F.) // Negrito
	oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont16  := TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.) //modificado de 16 para 12 JCNS
	oFont16n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.) //modificado de 16 para 14 JCNS
	oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10m := TFont():New("Arial",9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont11n := TFont():New("Arial",9,13,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:StartPage()   // Inicia uma nova pÃ¡gina

	oPrint:Line (0150,100,0150,2200)
	oPrint:Line (0150,550,0060, 550)
	oPrint:Line (0150,800,0060, 800)
	oPrint:Say  (0140,567,aDadosBanco[1],oFont24 )  // [1]Numero do Banco
	oPrint:Say  (0140,1925,"Recibo Do Pagador" ,oFont11n,,,,1)
	oPrint:Line (0230,100,0230,2200 )
	oPrint:Line (0300,100,0300,2200 )
	oPrint:Line (0380,100,0380,2200 )
	oPrint:Line (0450,100,0450,2200 )
	oPrint:Saybitmap(0050,0300,"SYSTEM/033.PNG",0240,90)
	oPrint:Line (0300,500 ,0450,500)
	oPrint:Line (0380,750 ,0450,750)
	oPrint:Line (0300,1000,0450,1000)
	oPrint:Line (0300,1350,0380,1350)
	oPrint:Line (0300,1550,0450,1550)

	oPrint:Say  (0170,100 ,"Beneficiário"                             						,oFont8 )
	oPrint:Say  (0200,100 , "60.889.128/0001-80 - BANCO SOFISA S.A"		,oFont10)
	oPrint:Say  (0170,1910,"Vencimento"                                     						,oFont8 )
	oPrint:Say  (0200,1950,If((aDadosTit[4])=="11/11/11","C/Apresentação",(aDadosTit[4]))			,oFont10,,,,1)
	oPrint:Say  (0250,1910,"Agência/ Beneficiário"                         							,oFont8 )       // Geraldo em 25/04/2017

	oPrint:Say  (0275,1950,cAgencia+" "+alltrim(cConvenio)	,oFont10 ,,,,1)

	oPrint:Say  (0320,100 ,"Data do Documento"                              						,oFont8 )
	oPrint:Say  (0250,100 ,"Endereço Do Beneficiário"                                   ,oFont8)
	oPrint:Say  (0280,100 ,"Al.Santos 1496 Cerqueira Cesar 01.418-100 SAO PAULO/SP "  							,oFont10)
	oPrint:Say  (0350,100 ,DTOC(aDadosTit[2])                               						,oFont10) // Emissao do Titulo (E1_EMISSAO)

	oPrint:Say  (0320,505 ,"Nro.Documento"                                  						,oFont8 )
	oPrint:Say  (0350,505 ,/*aDadosTit[7]+*/aDadosTit[1]               								,oFont10) //Prefixo +Numero+Parcela

	oPrint:Say  (0320,1005,"Espécie Doc."                                   						,oFont8 )
	oPrint:Say  (0350,1005,"02"     																,oFont10) //Tipo do Titulo

	oPrint:Say  (0320,1355,"Aceite"                                         						,oFont8 )
	oPrint:Say  (0350,1355,"NAO"                                             							,oFont10)

	oPrint:Say  (0320,1555,"Data do Processamento"                          						,oFont8 )
	oPrint:Say  (0350,1555,DTOC(aDadosTit[3])                               						,oFont10) // Data impressao

	oPrint:Say  (0320,1910,"Nosso Número"                                   						,oFont8 )

	//oPrint:Say  (0340,2200,alltrim(aDadosTit[6])+"-"+AllTrim(Str(nDvnn)),oFont10,,,,1)
	oPrint:Say  (0350,1950,SubStr(alltrim(aDadosTit[6]),1,Len(alltrim(aDadosTit[6]))-1)+"-"+AllTrim(Str(nDvnn)) ,oFont10,,,,1)

	oPrint:Say  (0400,100 ,"Uso do Banco"                                   						,oFont8 )

	oPrint:Say  (0400,505 ,"Carteira"                                       						,oFont8 )
	oPrint:Say  (0430,505 ,"101"                                       						,oFont8 )

	oPrint:Say  (0400,755 ,"Espécie"                                        						,oFont8 )
	oPrint:Say  (0430,755 ,"R$"                                             						,oFont10)

	oPrint:Say  (0400,1005,"Quantidade"                                     						,oFont8 )
	oPrint:Say  (0400,1555,"Valor"                                          						,oFont8 )

	oPrint:Say  (0400,1910,"Valor do Documento"                             						,oFont8 )
	oPrint:Say  (0430,1950,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99"))	,oFont10,,,,1)
	oPrint:Say  (0650,100 ,""                           		   ,oFont10)
	oPrint:Say  (0470,100 ,"Informações de responsabilidade do beneficiário ",oFont8)
	oPrint:Say  (0500,100 ,"MORA DE 194,79 AO DIA, A PARTIR DE "+Dtoc(DaySum(CTOD(aDadosTit[4]),1)) ,oFont10)


	oPrint:Say  (0470,1910,"(-)Desconto/Abatimento"                         ,oFont8)
	If aDadosTit[15] > 0
		oPrint:Say  (1080,1950,AllTrim(Transform(aDadosTit[15],"@E 999,999,999.99")),oFont10,,,,1)
	Endif
	oPrint:Say  (0540,1910,"(-)Outras Deduções"                             ,oFont8)
	oPrint:Say  (0610,1910,"(+)Mora/Multa"                                  ,oFont8)
	oPrint:Say  (0680,1910,"(+)Outros Acréscimos"                           ,oFont8)
	oPrint:Say  (0750,1910,"(=)Valor Cobrado"                               ,oFont8)

	oPrint:Say  (0820,100 ,"Pagador"                                            ,oFont8)

	oPrint:Say  (0820,350 ,aDatSacado[1]          ,oFont10)
	oPrint:Say  (0820,1750 ,"CNPJ/CPF: "+aDatSacado[7]         ,oFont10,,,,1)
	oPrint:Say  (0860,350 ,aDatSacado[3]                                            ,oFont10)
	oPrint:Say  (0920,350 ,aDatSacado[4]+" - "+aDatSacado[5]+" "+aDatSacado[6]   ,oFont10) // CEP+Cidade+Estado
	oPrint:Say  (0980,100 ,"Beneficiário Final"    	                                   ,oFont8)
	oPrint:Say  (0980,350 ,aDadosEmp[1]    	                                   ,oFont10)
	oPrint:Say  (0980,1750 ,aDadosEmp[6]    	                                   ,oFont10,,,,1)
	oPrint:Say  (1000,350 ,aDadosEmp[2]+"    "+aDadosEmp[4]+"   "+aDadosEmp[3]               ,oFont10)
	oPrint:Line (0150,1900,0790,1900 )
	oPrint:Line (0520,1900,0520,2200 )
	oPrint:Line (0590,1900,0590,2200 )
	oPrint:Line (0660,1900,0660,2200 )
	oPrint:Line (0730,1900,0730,2200 )
	oPrint:Line (0790,100 ,0790,2200 )
	oPrint:Line (1020,100 ,1020,2200 )

	For i := 100 to 2200 step 50
		oPrint:Line(1050, i, 1050, i+30)
	Next i

	oPrint:Line (1160,100,1160,2200)
	oPrint:Line (1160,550,1060, 550)
	oPrint:Line (1160,800,1060, 800)
	oPrint:Say  (1142,567,aDadosBanco[1],oFont24 )  // [1]Numero do Banco
	oPrint:Say  (1144,1925,"Ficha De Caixa",oFont11n,,,,1)     //Linha Digitavel do Codigo de Barras
	//oPrint:Line (1410,100,1410,2200 )
	oPrint:Line (1230,100,1230,2200 )
	oPrint:Line (1300,100,1300,2200 )
	oPrint:Line (1370,100,1370,2200 )

	nYCIP := 370
	nYNossoNum := 1910
	cNumCIP := "504"

	oPrint:Line (1230,500 ,1370,500)
	oPrint:Line (1330,750 ,1370,750)
	oPrint:Line (1230,1000,1370,1000)
	oPrint:Line (1230,1350,1300,1350)
	oPrint:Line (1230,1430,1160,1430)
	oPrint:Line (1230,1550,1370,1550)

	oPrint:Say  (1180,100 ,"Beneficiário"                             						        ,oFont8 )
	oPrint:Say  (1220,100 , "60.889.128/0001-80 - BANCO SOFISA S.A"	  						,oFont10)
	oPrint:Say  (1180,1910,"Vencimento"                                     						,oFont8 )
	oPrint:Say  (1220,1950,If((aDadosTit[4])=="11/11/11","C/Apresentação",(aDadosTit[4]))			,oFont10,,,,1)
	oPrint:Say  (1180,1430,"Agência/ Beneficiário"                         							,oFont8 )       // Geraldo em 25/04/2017

	oPrint:Say  (1220,1430,cAgencia+" "+alltrim(cConvenio)	,oFont10 )

	oPrint:Say  (1260,100 ,"Data do Documento"                              						,oFont8 )

	oPrint:Say  (1290,100 ,DTOC(aDadosTit[2])                               						,oFont10) // Emissao do Titulo (E1_EMISSAO)

	oPrint:Say  (1260,505 ,"Nro.Documento"                                  						,oFont8 )
	oPrint:Say  (1290,505 ,/*aDadosTit[7]+*/aDadosTit[1]               								,oFont10) //Prefixo +Numero+Parcela

	oPrint:Say  (1260,1005,"Espécie Doc."                                   						,oFont8 )
	oPrint:Say  (1290,1005,"02"     																,oFont10) //Tipo do Titulo

	oPrint:Say  (1260,1355,"Aceite"                                         						,oFont8 )
	oPrint:Say  (1290,1355,"NAO"                                             							,oFont10)

	oPrint:Say  (1260,1555,"Data do Processamento"                          						,oFont8 )
	oPrint:Say  (1290,1555,DTOC(aDadosTit[3])                               						,oFont10) // Data impressao

	oPrint:Say  (1260,1910,"Nosso Número"                                   						,oFont8 )

	//oPrint:Say  (1460,2200,alltrim(aDadosTit[6])+"-"+AllTrim(Str(nDvnn)),oFont10,,,,1)
	oPrint:Say  (1290,1950,SubStr(alltrim(aDadosTit[6]),1,Len(alltrim(aDadosTit[6]))-1)+"-"+AllTrim(Str(nDvnn)) ,oFont10,,,,1)

	oPrint:Say  (1330,100 ,"Uso do Banco"                                   						,oFont8 )
	oPrint:Say  (1330,505 ,"Carteira"                                       						,oFont8 )
	oPrint:Say  (1360,505 ,"101"                                       						,oFont8 )

	oPrint:Say  (1330,755 ,"Espécie"                                        						,oFont8 )
	oPrint:Say  (1360,755 ,"R$"                                             						,oFont10)

	oPrint:Say  (1330,1005,"Quantidade"                                     						,oFont8 )
	oPrint:Say  (1330,1555,"Valor"                                          						,oFont8 )

	oPrint:Say  (1330,1910,"Valor do Documento"                             						,oFont8 )
	oPrint:Say  (1360,1950,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99"))						,oFont10,,,,1)
	oPrint:Say  (1600,100 ,""                           		   ,oFont10)
	oPrint:Say  (1390,100 ,"Informações de responsabilidade do beneficiário ",oFont8)
	oPrint:Say  (1430,100 ,"MORA DE 194,79 AO DIA, A PARTIR DE "+Dtoc(DaySum(CTOD(aDadosTit[4]),1)) ,oFont10)


	oPrint:Say  (1390,1910,"(-)Desconto/Abatimento"                         ,oFont8)
	If aDadosTit[15] > 0
		oPrint:Say  (1130,1950,AllTrim(Transform(aDadosTit[15],"@E 999,999,999.99")),oFont10,,,,1)
	Endif
	oPrint:Say  (1470,1910,"(-)Outras Deduções"                             ,oFont8)
	oPrint:Say  (1550,1910,"(+)Mora/Multa"                                  ,oFont8)
	oPrint:Say  (1630,1910,"(+)Outros Acréscimos"                           ,oFont8)
	oPrint:Say  (1710,1910,"(=)Valor Cobrado"                               ,oFont8)

	oPrint:Say  (1760,100 ,"Pagador"                                            ,oFont8)

	oPrint:Say  (1760,350 ,aDatSacado[1]         ,oFont10)
	//oPrint:Say  (0670,100 ,aDatSacado[3]                                            ,oFont10)
	//oPrint:Say  (0740,100 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5]   ,oFont10) // CEP+Cidade+Estado
	oPrint:Say  (1830,100 ,"Beneficiário Final"                                       ,oFont8)
	oPrint:Say  (1830,350 ,aDadosEmp[1]                                       ,oFont10)
	oPrint:Line (1160,1900,1740,1900 )
	oPrint:Line (1450,1900,1450,2200 )
	oPrint:Line (1530,1900,1530,2200 )
	oPrint:Line (1610,1900,1610,2200 )
	oPrint:Line (1690,1900,1690,2200 )
	oPrint:Line (1740,100 ,1740,2200 )
	oPrint:Line (1860,100 ,1860,2200 )

	For i := 100 to 2200 step 50
		oPrint:Line( 1900, i, 1900, i+30)
	Next i

// Encerra aqui a alteracao para o novo layout - RAI

	oPrint:Line (2000,100,2000,2200)
	oPrint:Line (2000,551,1900, 550)
	oPrint:Line (2000,801,1890, 800)
	oPrint:Say  (1982,567,aDadosBanco[1],oFont24 )  // [1]Numero do Banco
	oPrint:Say  (1984,1180,Transform(CB_RN_NN[2],"@R 99999.99999 99999.999999 99999.999999 9 99999999999999"),oFont16n,,,,1)     //Linha Digitavel do Codigo de Barras

	oPrint:Line (2100,100,2100,2200 )
	oPrint:Line (2200,100,2200,2200 )
	oPrint:Line (2270,100,2270,2200 )
	oPrint:Line (2340,100,2340,2200 )

	oPrint:Line (2200,500 ,2340,500)
	oPrint:Line (2270,750 ,2340,750)
	oPrint:Line (2200,1000,2340,1000)
	oPrint:Line (2200,1350,2270,1350)
	oPrint:Line (2200,1550,2340,1550)

	oPrint:Say  (2020,100 ,"Local de Pagamento"                        ,oFont8)
	oPrint:Say  (2050,100 ,"PAGÁVEL PREFERENCIALMENTE EM QUALQUER AGÊNCIA SANTANDER        ",oFont10)
	oPrint:Say  (2020,1910,"Vencimento"                                     ,oFont8)
	oPrint:Say  (2050,1950,If((aDadosTit[4])=="11/11/11","C/Apresentação",(aDadosTit[4])),oFont10,,,,1)

	oPrint:Say  (2120,100 ,"Beneficiário"                                   ,oFont8)
	oPrint:Say  (2160,100 ,"60.889.128/0001-80 - BANCO SOFISA S.A"	   		,oFont10)

	oPrint:Say  (2120,1910,"Ponto Venda /Ident. Beneficiário"                         ,oFont8)     //geraldo 25/04/2017

	oPrint:Say  (2160,1950,cAgencia+" "+alltrim(cConvenio)	,oFont10 ,,,,1)

	oPrint:Say  (2220,100 ,"Data do Documento"                              ,oFont8)
	oPrint:Say  (2250,100 ,DTOC(aDadosTit[2])                               ,oFont10) // Emissao do Titulo (E1_EMISSAO)

	oPrint:Say  (2220,505 ,"Nro.Documento"                                  ,oFont8)
	oPrint:Say  (2250,505 ,/*aDadosTit[7]+*/aDadosTit[1]                  		,oFont10) //Prefixo +Numero+Parcela

	oPrint:Say  (2290,505 , "Carteira"                 		,oFont8) //Prefixo +Numero+Parcela
	oPrint:Say  (2320,505 , "101"                 		,oFont10) //Prefixo +Numero+Parcela

	oPrint:Say  (2220,1005,"Espécie Doc."                                   ,oFont8)
	oPrint:Say  (2250,1005,"02"     ,oFont10) //Tipo do Titulo

	oPrint:Say  (2220,1355,"Aceite"                                         ,oFont8)
	oPrint:Say  (2250,1355,"NAO"                                              ,oFont10)

	oPrint:Say  (2220,1555,"Data do Processamento"                          ,oFont8)
	oPrint:Say  (2250,1555,DTOC(aDadosTit[3])                               ,oFont10) // Data impressao

	oPrint:Say  (2220,1910,"Nosso Número"                                   ,oFont8)

	//oPrint:Say  (2550,2200,alltrim(aDadosTit[6])+"-"+AllTrim(Str(nDvnn)),oFont10,,,,1)
	oPrint:Say  (2250,1950,SubStr(alltrim(aDadosTit[6]),1,Len(alltrim(aDadosTit[6]))-1)+"-"+AllTrim(Str(nDvnn)) ,oFont10,,,,1)

	oPrint:Say  (2290,100 ,"Uso do Banco"                                           ,oFont8)
	oPrint:Say  (2290,755 ,"Espécie"                                                ,oFont8)
	oPrint:Say  (2320,755 ,"R$"                                                     ,oFont10)

	oPrint:Say  (2290,1005,"Quantidade"                                             ,oFont8)
	oPrint:Say  (2290,1555,"Valor"                                                  ,oFont8)

	oPrint:Say  (2290,1910,"Valor do Documento"                                     ,oFont8)
	oPrint:Say  (2320,1950,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99"))     ,oFont10,,,,1)
	oPrint:Say  (2540,100 ,""   						   					        ,oFont10)
	oPrint:Say  (2360,100 ,"Informações de responsabilidade do beneficiário",oFont8)
	oPrint:Say  (2390,100 ,"MORA DE 194,79 AO DIA, A PARTIR DE "+Dtoc(DaySum(CTOD(aDadosTit[4]),1)) ,oFont10)

	oPrint:Say  (2360,1910,"(-)Desconto/Abatimento"                                 ,oFont8)

	If aDadosTit[15] > 0
		oPrint:Say  (2390,1950,AllTrim(Transform(aDadosTit[15],"@E 999,999,999.99")),oFont10,,,,1)
	Endif

	oPrint:Say  (2430,1910,"(-)Outras Deduções"                                     ,oFont8)
	oPrint:Say  (2500,1910,"(+)Mora/Multa"                                          ,oFont8)
	oPrint:Say  (2570,1910,"(+)Outros Acréscimos"                                   ,oFont8)
	oPrint:Say  (2640,1910,"(=)Valor Cobrado"                                       ,oFont8)

	oPrint:Say  (2710,100 ,"Pagador"                                            ,oFont8)

	oPrint:Say  (2720,350 ,aDatSacado[1]         ,oFont10)
	oPrint:Say  (2720,1800 ,"CNPJ/CPF: "+aDatSAcado[7]        ,oFont10,,,,1)
	oPrint:Say  (2750,350 ,aDatSacado[3]                                            ,oFont10)
	oPrint:Say  (2780,350 ,aDatSacado[4]+" - "+aDatSacado[5]+" "+aDatSacado[6]  ,oFont10) // CEP+Cidade+Estado
	oPrint:Say  (2830,100 ,"Beneficiário Final"                                       ,oFont8)
	oPrint:Say  (2830,350 ,aDadosEmp[1]                                       ,oFont10)
	oPrint:Say  (2830,1800 ,aDadosEmp[6]                                       ,oFont10,,,,1)
	oPrint:Say  (2900,1550,"Autenticação Mecânica -"                                ,oFont8)
	oPrint:Say  (2900,1800,"Ficha de Compensação"                                   ,oFont10,,,,1)
	oPrint:Line (2000,1900,2690,1900 )
	oPrint:Line (2410,1900,2410,2200 )
	oPrint:Line (2480,1900,2480,2200 )
	oPrint:Line (2550,1900,2550,2200 )
	oPrint:Line (2620,1900,2620,2200 )
	oPrint:Line (2690,100 ,2690,2200 )
	oPrint:Line (2880,100 ,2880,2200 )
	If !lWsPDF
		oPrint:FWMSBAR("INT25",62,1.6,CB_RN_NN[1],oPrint,.F.,,.T.,0.02,1.0,nil,nil,NIL,.F.,1,1,.F.)
	else
		oPrint:FWMSBAR("INT25",65.7,1.6,CB_RN_NN[1],oPrint,.F.,,.T.,0.02,1.0,nil,nil,NIL,.F.,1,1,.F.)
	EndIF	
	oPrint:EndPage() // Finaliza a pÃ¡gina

Return Nil

User Function B0SOFWS(_filial,_titulo,_pref,_client,_loja,_parc)

	Processa({|lEnd|MontaRel(.T.,_filial,_titulo,_pref,_client,_loja,_parc)})

Return()
