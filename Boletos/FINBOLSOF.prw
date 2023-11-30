#include "rwmake.ch"
#Include "PROTHEUS.CH"
#include "TopConn.Ch"
#INCLUDE "FWPrintSetup.ch"
#Include "RPTDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

/*/{Protheus.doc} FINF142
//TODO Descrição auto-gerada.
@author andre.lima
@since 02/04/2022
@version 1.0
@param aLista, array, descricao
@type function
/*/

User Function FINBOLSOF()

	Private lExec    	:= .F.
	Private cIndexName 	:= ''
	Private cIndexKey  	:= ''
	Private cFilter    	:= ''

	wnrel    := "BOLETO"
	lEnd     := .F.
	_cPerg   := Padr("BOLITAU",10)
	aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	nLastKey := 0

	dbSelectArea("SE1")
	ValidPerg()

	If !Pergunte (_cPerg,.T.)
		Return(.T.)
	endif

	cIndexName	:= Criatrab(Nil,.F.)
	cIndexKey	:= "E1_PORTADO+E1_CLIENTE+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+DTOS(E1_EMISSAO)"

	cFilter		+= "E1_FILIAL=='"+xFilial("SE1")+"'.And.E1_SALDO>0.And."
	cFilter		+= "E1_PREFIXO>='" + MV_PAR01 + "'.And.E1_PREFIXO<='" + MV_PAR02 + "'.And."
	cFilter		+= "E1_NUM>=    '" + MV_PAR03 + "'.And.E1_NUM<=    '" + MV_PAR04 + "'.And."
	cFilter		+= "E1_PARCELA>='" + MV_PAR05 + "'.And.E1_PARCELA<='" + MV_PAR06 + "'.And."
	cFilter		+= "E1_CLIENTE>='" + MV_PAR07 + "'.And.E1_CLIENTE<='" + MV_PAR08 + "'.And."
	cFilter		+= "E1_LOJA>=   '" + MV_PAR09 + "'.And.E1_LOJA<=   '" + MV_PAR10 + "'.And."
	cFilter		+= "DTOS(E1_EMISSAO)>='"+DTOS(mv_par11)+"'.and.DTOS(E1_EMISSAO)<='"+DTOS(mv_par12)+"'.And."
	cFilter		+= "DTOS(E1_VENCREA)>='"+DTOS(mv_par13)+"'.and.DTOS(E1_VENCREA)<='"+DTOS(mv_par14)+"'.And."
	cFilter		+= "E1_NUMBOR>= '" + MV_PAR15 + "'.And.E1_NUMBOR<= '" + MV_PAR16 + "'.And."
	cFilter		+= "!(E1_TIPO$MVABATIM)"
	cFilter		+= ".And. E1_PORTADO=='637' "

	IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")
	DbSelectArea("SE1")

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
		Processa({ |lEnd| MontaRel() })
	Endif

	RetIndex("SE1")
	Ferase(cIndexName+OrdBagExt())

Return

Static Function MontaRel(lWSPDF,_filial,_titulo,_pref,_client,_loja,_parc)

	Local oBol
	Local nX			:= 0
	Local aDadosEmp   	:= {	SM0->M0_NOMECOM                                    					,; //[1]Nome da Empresa
	SM0->M0_ENDCOB                                   						,; //[2]Endereço
	AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
	"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
	"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
	"CNPJ: "+TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99")				 ,; //[6]CNPJ
	"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ; //[7]
	Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                        }  //[7]I.E

	Local aDadosTit   := {}
	Local aDadosBanco := {}
	Local aDatSacado  := {}

	Local aCB_RN_NN   := {}
	Local nVlrAbat	:= 0
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

		if ALLTRIM(SE1->E1_NUM) = ""
			SE1->(DBCLOSEAREA())
			dbSelectArea("SE1")
			SE1->(dbSetOrder(1))
			SE1->(dbSeek(_filial+_pref+_titulo+_parc+"FT "))
		endif
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
		oBol := FwMSPrinter():New( cFile, IMP_PDF , .T. , cCaminho, .T., , , , , .F., ,.F. )
		oBol:cPathPDF := cCaminho
		//Marca o campo E1_BOLETO do título como gerado ('1') - 02/05/2022
		U_FlagBol(SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA))
	Else
		oBol := FwMSPrinter():New( cFile, IMP_SPOOL , .T. , , .T., , , , , .T., ,.T. )
		oBol:Setup()

	EndIf

	oBol:SetPortrait() // ou SetLandscape()

	DbGoTop()
	ProcRegua(RecCount())
	if !lWSPDF
		Do While !EOF()

			If Empty(MV_PAR17)
				//Posiciona o SA6 (Bancos)
				DbSelectArea("SA6")
				DbSetOrder(1)
				DbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,.T.)

				//Posiciona na Arq de Parametros CNAB
				DbSelectArea("SEE")
				DbSetOrder(1)
				DbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.)

			Else

				//Posiciona o SA6 (Bancos)
				DbSelectArea("SA6")
				DbSetOrder(1)
				DbSeek(xFilial("SA6")+MV_PAR17+MV_PAR18+MV_PAR19,.T.)

				//Posiciona na Arq de Parametros CNAB
				DbSelectArea("SEE")
				DbSetOrder(1)
				DbSeek(xFilial("SEE")+MV_PAR17+MV_PAR18+MV_PAR19,.T.)

			Endif

			//Posiciona o SA1 (Cliente)
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)

			DbSelectArea("SE1")

			aAdd(aDadosBanco, Alltrim(SEE->EE_CODIGO))            	// [1]Numero do Banco
			aAdd(aDadosBanco, Alltrim(SA6->A6_NOME))              	// [2]Nome do Banco
			aAdd(aDadosBanco, alltrim(SEE->EE_AGENCIA))   			// [3]Agência
			aAdd(aDadosBanco, Alltrim(SEE->EE_CONTA)) // [4]Conta Corrente
			aAdd(aDadosBanco,Alltrim(SEE->EE_DVCTA))    			// [5]Dígito da conta corrente
			aAdd(aDadosBanco, Alltrim('1'))                	// [6]Codigo da Carteira
			aAdd(aDadosBanco, Alltrim(SE1->E1_PARCELA))  			// [7] PARCELA
			aAdd(aDadosBanco, Alltrim(SEE->EE_CODEMP))

			If Empty(SA1->A1_ENDCOB)
				aDatSacado   := {AllTrim(SA1->A1_NOME)           	,;  // [1]Razão Social
				AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           	,;  // [2]Código
				AllTrim(SA1->A1_END )								,;  // [3]Endereço
				AllTrim(SA1->A1_MUN )                            	,;  // [4]Cidade
				SA1->A1_EST                                      	,;	// [5]Estado
				SA1->A1_CEP                                      	,;  // [6]CEP
				SA1->A1_CGC											,;  // [7]CGC
				SA1->A1_PESSOA										,;  // [8]PESSOA
				AllTrim(SA1->A1_BAIRRO)                           	}   // [9]Bairro
			Else
				aDatSacado   := {AllTrim(SA1->A1_NOME)            	,;   	// [1]Razão Social
				AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA            ,;   	// [2]Código
				AllTrim(SA1->A1_ENDCOB)						,;   	// [3]Endereço
				AllTrim(SA1->A1_MUNC)	                           ,;   	// [4]Cidade
				SA1->A1_ESTC	                                    ,;   		// [5]Estado
				SA1->A1_CEPC                                      ,;   	// [6]CEP
				SA1->A1_CGC									,;		// [7]CGC
				SA1->A1_PESSOA								,;		// [8]PESSOA
				AllTrim(SA1->A1_BAIRRO)                            }      	// [9]Bairro
			Endif

			nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
			nVlrTitulo := (E1_SALDO+E1_SDACRES-nVlrAbat)

			/*
			----------------------
			Monta codigo de barras
			----------------------
			*/
			aCB_RN_NN := ReprNum(aDadosBanco[3]   				,;  // Codigo da Agencia
			aDadosBanco[4]      								,;  // Codigo da Conta
			aDadosBanco[5]      								 )  // DV da Conta

			aDadosTit	:= {AllTrim(E1_NUM)+AllTrim(E1_PARCELA)	,;  // [1] Número do título
			E1_EMISSAO                          				,;  // [2] Data da emissão do título
			dDataBase                    						,;  // [3] Data da emissão do boleto
			E1_VENCTO                           				,;  // [4] Data do vencimento
			nVlrTitulo		               						,;  // [5] Valor do título
			aCB_RN_NN[3]                        				,;  // [6] Nosso número (Ver fórmula para calculo)
			E1_PREFIXO                          				,;  // [7] Prefixo da NF
			E1_TIPO	                           					}   // [8] Tipo do Titulo


			If Marked("E1_OK")
				Impress(oBol,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,,aCB_RN_NN)
			EndIf

			nX := nX + 1
			dbSkip()
		EndDo
	else

		dbSelectArea("SE1")
		SE1->(dbSetOrder(1))
		SE1->(dbSeek(_filial+_pref+_titulo+_parc+"NF "))

		if ALLTRIM(SE1->E1_NUM) = ""
			SE1->(DBCLOSEAREA())
			dbSelectArea("SE1")
			SE1->(dbSetOrder(1))
			SE1->(dbSeek(_filial+_pref+_titulo+_parc+"FT "))
		endif

		//Posiciona o SA6 (Bancos)
		DbSelectArea("SA6")
		DbSetOrder(1)
		DbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,.T.)


		//Posiciona na Arq de Parametros CNAB
		DbSelectArea("SEE")
		DbSetOrder(1)
		DbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.)

		//Posiciona o SA1 (Cliente)
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)

		DbSelectArea("SE1")

		aAdd(aDadosBanco, Alltrim(SEE->EE_CODIGO))            	// [1]Numero do Banco
		aAdd(aDadosBanco, Alltrim(SA6->A6_NOME))              	// [2]Nome do Banco
		aAdd(aDadosBanco, alltrim(SEE->EE_AGENCIA))   			// [3]Agência
		aAdd(aDadosBanco, Alltrim(SEE->EE_CONTA)) // [4]Conta Corrente
		aAdd(aDadosBanco,Alltrim(SEE->EE_DVCTA))    			// [5]Dígito da conta corrente
		aAdd(aDadosBanco, Alltrim('1'))                	// [6]Codigo da Carteira
		aAdd(aDadosBanco, Alltrim(SE1->E1_PARCELA))  			// [7] PARCELA
		aAdd(aDadosBanco, Alltrim(SEE->EE_CODEMP))


		If Empty(SA1->A1_ENDCOB)
			aDatSacado   := {AllTrim(SA1->A1_NOME)           	,;  // [1]Razão Social
			AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           	,;  // [2]Código
			AllTrim(SA1->A1_END )								,;  // [3]Endereço
			AllTrim(SA1->A1_MUN )                            	,;  // [4]Cidade
			SA1->A1_EST                                      	,;	// [5]Estado
			SA1->A1_CEP                                      	,;  // [6]CEP
			SA1->A1_CGC											,;  // [7]CGC
			SA1->A1_PESSOA										,;  // [8]PESSOA
			AllTrim(SA1->A1_BAIRRO)                           	}   // [9]Bairro
		Else
			aDatSacado   := {AllTrim(SA1->A1_NOME)            	,;   	// [1]Razão Social
			AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA            ,;   	// [2]Código
			AllTrim(SA1->A1_ENDCOB)						,;   	// [3]Endereço
			AllTrim(SA1->A1_MUNC)	                           ,;   	// [4]Cidade
			SA1->A1_ESTC	                                    ,;   		// [5]Estado
			SA1->A1_CEPC                                      ,;   	// [6]CEP
			SA1->A1_CGC									,;		// [7]CGC
			SA1->A1_PESSOA								,;		// [8]PESSOA
			AllTrim(SA1->A1_BAIRRO)                            }      	// [9]Bairro
		Endif

		nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
		nVlrTitulo := (SE1->E1_SALDO+SE1->E1_SDACRES-nVlrAbat)

		/*
		----------------------
		Monta codigo de barras
		----------------------
		*/
		aCB_RN_NN := ReprNum(aDadosBanco[3]   				,;  // Codigo da Agencia
		aDadosBanco[4]      								,;  // Codigo da Conta
		aDadosBanco[5]      								 )  // DV da Conta

		aDadosTit	:= {AllTrim(E1_NUM)+AllTrim(E1_PARCELA)	,;  // [1] Número do título
		E1_EMISSAO                          				,;  // [2] Data da emissão do título
		dDataBase                    						,;  // [3] Data da emissão do boleto
		E1_VENCTO                           				,;  // [4] Data do vencimento
		nVlrTitulo		               						,;  // [5] Valor do título
		aCB_RN_NN[3]                        				,;  // [6] Nosso número (Ver fórmula para calculo)
		E1_PREFIXO                          				,;  // [7] Prefixo da NF
		E1_TIPO	                           					}   // [8] Tipo do Titulo

		Impress(oBol,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,,aCB_RN_NN)


	endif
	oBol:EndPage()     // Finaliza a página

	oBol:Print()

Return Nil

//------------------------------------------
// Funcao: ReprNum  - Representacao numerica      
//------------------------------------------

Static Function ReprNum(cAgencia,cConta,DVX,lNF,_pref,_titulo,_parc)

	If Empty(SE1->E1_NUMBCO)

		NossoNum()
		_cNN :=strzero(Val(SE1->E1_NUMBCO),12)
		CalcDvNN := alltrim(STR(Mod11NN(_cNN)))       // Calculo do digito do nosso numero

		RecLock("SE1",.F.)
		Replace E1_NUMBCO  with _cNN + CalcDvNN
		Replace E1_XDVNBCO with CalcDvNN
		msUnLock()
	Else
		_cNN      := SubStr(SE1->E1_NUMBCO,1,12)    // Nosso numero (sem DV)
		CalcDvNN  := SubStr(SE1->E1_NUMBCO,13,1)     // DV do nosso numero
	EndIf

	cBanco       := '637'                                             // Codigo do banco Itaú
	_cfator      := StrZero(((SE1->E1_VENCTO)-ctod("07/10/1997")),4)   // fator de vencimento
	blvalorfinal := strzero(SE1->E1_VALOR*100,10)                                    // Valor do titulo
	_cConvenio   := alltrim(SEE->EE_CODEMP)
	_cCart	    := '101'                                               // carteira de cobranca

	//	-------- Definicao do CODIGO DE BARRAS

	s        := cBanco + _cfator + blvalorfinal +'9'+ _cConvenio + _cNN + CalcDvNN + '0' + _cCart
	dvcb     := alltrim(STR(modulo11(s)))          // digito verificador codigo de barra
	CB       := SubStr(s, 1, 4) + dvcb + SubStr(s,5)

	//-------------------------------------------------
    /* 1º Bloco
        Posição     Tamanho Picture     Conteúdo
        01-03           3     9 (03)    Banco = 033
        04-04           1     9 (01)    Código da moeda = 9 (real) 
        05-05           1     9 (01)    Fixo “9”
        06-09           4     9 (04)    Código do Beneficiário padrão 
        10-10           1     9 (01)    Código verificador do primeiro grupo
    */
    s := cBanco + '9' + Substr(_cConvenio,1,4)
    DV := Modulo10(s)
    RN   := s + '.' + dv + ' '

    /* 2º Bloco
        Posição     Tamanho     Picture     Conteúdo
        11-13           3          9 (03)       Restante do código do beneficiário
        14-20           7          9 (07)       7 primeiros campos do N/N
        21-21           1          9 (01)       Dígito verificador do segundo grupo
    */
    
    s := Substr(_cConvenio,5,3) + substr(_cNN,1,7)
    DV := Modulo10(s)
    RN   := RN + s + '.' + DV + ' '

    /* 3º Bloco
        Posição     Tamanho     Picture     Conteúdo
        22-27           6        9 (06)         Restante do Nosso Número com DV
        28-28           1        9 (01)         Fixo “0” 
        29-31           3        9 (03)         Tipo de Modalidade Carteira 
        32-32           1        9 (01)         Dígito verificador do terceiro grupo
    */

    s := substr(_cNN,8,5) + CalcDvNN + '0' + _cCart
    DV := Modulo10(s)
    RN   := RN + s + '.' + DV + ' '

    /* 4º Bloco
        33-33 DV CodBar
    */
    RN   := RN + dvcb + ' '

    /* 5º Bloco
        Posição     Tamanho     Picture     Conteúdo
        34-37           4        9 (04)     Fator de Vencimento
        38-47           10       9 (10)     Valor do Boleto
    */

    RN   := RN + _cfator + blvalorfinal

Return({CB,RN,_cNN+CalcDvNN})


//------------------------------------------------
// Modulo 10 : Calculo do digito do nosso numero    
//------------------------------------------------

Static Function Modulo10(cData)
	LOCAL L,D,P := 0
	LOCAL B     := .F.
	L := Len(cData)
	B := .T.
	D := 0
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
Return Str(D,1)

// ----------------------------------------------------------------------------------------------------
// Modulo11 : Calculo do digito verificador dos blocos que compoem a linha digitavel do codigo de barras  
// ----------------------------------------------------------------------------------------------------

Static Function Modulo11(cData)
	LOCAL L, D, P := 0
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
	If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
		D := 1
	End
Return(D)

// ----------------------------------------------------------------------------------------------------
// Mod11NN : Calculo do digito verificador do Nosso Numero  
// ----------------------------------------------------------------------------------------------------

Static Function Mod11NN(cData)
	LOCAL L, D, P := 0
	L := Len(cdata)
	D := 0
	P := 1
	While L > 0
		P := P + 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P == 9
			P := 1
		EndIf
		L := L - 1
	EndDo
	D := 11 - (mod(D,11))
	If D == 10
		D := 1
	elseif D == 1
		D := 0
	EndIf
Return(D)

Static Function Impress(oBol,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
	Local nW, _nLin
	// ---------------------------------------------------------------------
	// Cria os objetos de fontes que serao utilizadas na impressao do boleto
	// ---------------------------------------------------------------------
	Local oFont1	 := TFont():New( "Arial",,8,,.F.,,,,,.F. )//
	Local oFont2	 := TFont():New( "Verdana",,8,,.t.,,,,.f.,.f. )
	Local oFont13b	 := TFont():New( "Verdana",,13,,.t.,,,,.f.,.f. )
	Local oFont20b	 := TFont():New( "Arial",,18,,.t.,,,,.f.,.f. )
	Local oFont09B 	 := TFont():New( "Arial",,14,,.T.,,,,,.F. )
	Local oFont01B 	 := TFont():New( "Arial",,13,,.T.,,,,,.F. )

	Set Century on

	// ------------------------------
	// Impressao do boleto bancario
	// ------------------------------
	oBol:SETPAPERSIZE(9)
	oBol:StartPage()  	//Inicia uma nova pagina

	_nLin  := 0
	_nLin2 := -60

	// ---------------------------------------
	// Impressao das caixas,linhas e tracos 1
	// ---------------------------------------
	oBol:Box(_nLin+050,0640,_nLin+120,0641) // 1. linha_coluna divisoria da logomarca
	oBol:Box(_nLin+050,0811,_nLin+120,0811) // 2. linha_coluna divisoria da logomarca

	oBol:Box(_nLin+120,0000,_nLin+180,1650) // Local Pagamento
	oBol:Box(_nLin+120,1650,_nLin+180,2200) // Vencimento

	oBol:Box(_nLin+180,0000,_nLin+250,1650) // Cedente
	oBol:Box(_nLin+180,1650,_nLin+250,2200) // Agencia / Codigo Cedente

	oBol:Box(_nLin+250,0000,_nLin+320,0400) // Data do Documento ,,,500
	oBol:Box(_nLin+250,0400,_nLin+320,0800) // Numero do Documento
	oBol:Box(_nLin+250,0800,_nLin+320,1100) // Especie Doc.
	oBol:Box(_nLin+250,1100,_nLin+320,1300) // Aceite
	oBol:Box(_nLin+250,1300,_nLin+320,1655) // Dia Processamento
	oBol:Box(_nLin+250,1650,_nLin+320,2200) // Nosso numero

	oBol:Box(_nLin+320,0000,_nLin+390,0400) // No. Conta
	oBol:Box(_nLin+320,0400,_nLin+390,0700) // Carteira
	oBol:Box(_nLin+320,0700,_nLin+390,1000) // Especie Moeda
	oBol:Box(_nLin+320,1300,_nLin+345,1301) // Quantidade
	oBol:Box(_nLin+365,1300,_nLin+390,1301) // Valor
	oBol:Say(_nLin+355,1295,"X",oFont1,1100) // Sinal de X
	oBol:Box(_nLin+320,1650,_nLin+390,2200) // Valor do Documento

	oBol:Box(_nLin+385,0000,_nLin+670,2200) // Instrucoes para o banco
	oBol:Box(_nLin+385,1650,_nLin+460,2200) // (-)Desconto/Abatimento
	oBol:Box(_nLin+460,1650,_nLin+530,2200) // (-)Outras Deduções
	oBol:Box(_nLin+530,1650,_nLin+600,2200) // (-)Mora/Multa
	oBol:Box(_nLin+600,1650,_nLin+670,2200) // (-)Outros Acrescimos
	oBol:Box(_nLin+670,0000,_nLin+800,2200) // Sacado


	// ---------------------------------------
	// Impressao das caixas,linhas e tracos 2
	// ---------------------------------------
	oBol:Box(1000+050,0640,1000+120,0641) // 1. linha_coluna divisoria da logomarca
	oBol:Box(1000+050,0811,1000+120,0811) // 2. linha_coluna divisoria da logomarca

	oBol:Box(1000+120,0000,1000+180,1650) // Local Pagamento
	oBol:Box(1000+120,1650,1000+180,2200) // Vencimento

	oBol:Box(1000+180,0000,1000+250,1650) // Cedente
	oBol:Box(1000+180,1650,1000+250,2200) // Agencia / Codigo Cedente

	oBol:Box(1000+250,0000,1000+320,0400) // Data do Documento ,,,500
	oBol:Box(1000+250,0400,1000+320,0800) // Numero do Documento
	oBol:Box(1000+250,0800,1000+320,1100) // Especie Doc.
	oBol:Box(1000+250,1100,1000+320,1300) // Aceite
	oBol:Box(1000+250,1300,1000+320,1650) // Dia Processamento
	oBol:Box(1000+250,1650,1000+320,2200) // Nosso numero

	oBol:Box(1000+320,0000,1000+390,0400) // No. Conta
	oBol:Box(1000+320,0400,1000+390,0700) // Carteira
	oBol:Box(1000+320,0700,1000+390,1000) // Especie Moeda
	oBol:Box(1000+320,1300,1000+345,1301) // Quantidade
	oBol:Box(1000+365,1300,1000+390,1301) // Valor
	oBol:Say(1000+355,1295,"X",oFont1,1100) // Sinal de X
	oBol:Box(1000+320,1650,1000+390,2200) // Valor do Documento

	oBol:Box(1000+385,0000,1000+670,2200) // Instrucoes para o banco
	oBol:Box(1000+385,1650,1000+460,2200) // (-)Desconto/Abatimento
	oBol:Box(1000+460,1650,1000+530,2200) // (-)Outras Deduções
	oBol:Box(1000+530,1650,1000+600,2200) // (-)Mora/Multa
	oBol:Box(1000+600,1650,1000+670,2200) // (-)Outros Acrescimos
	oBol:Box(1000+670,0000,1000+800,2200) // Sacado


	// ---------------------------------------
	// Impressao das caixas,linhas e tracos 3
	// ---------------------------------------
	oBol:Box(2000+050,0640,2000+120,0641) // 1. linha_coluna divisoria da logomarca
	oBol:Box(2000+050,0811,2000+120,0811) // 2. linha_coluna divisoria da logomarca

	oBol:Box(2000+120,0000,2000+180,1650) // Local Pagamento
	oBol:Box(2000+120,1650,2000+180,2200) // Vencimento

	oBol:Box(2000+180,0000,2000+250,1650) // Cedente
	oBol:Box(2000+180,1650,2000+250,2200) // Agencia / Codigo Cedente

	oBol:Box(2000+250,0000,2000+320,0400) // Data do Documento ,,,500
	oBol:Box(2000+250,0400,2000+320,0800) // Numero do Documento
	oBol:Box(2000+250,0800,2000+320,1100) // Especie Doc.
	oBol:Box(2000+250,1100,2000+320,1300) // Aceite
	oBol:Box(2000+250,1300,2000+320,1650) // Dia Processamento
	oBol:Box(2000+250,1650,2000+320,2200) // Nosso numero

	oBol:Box(2000+320,0000,2000+390,0400) // No. Conta
	oBol:Box(2000+320,0400,2000+390,0700) // Carteira
	oBol:Box(2000+320,0700,2000+390,1000) // Especie Moeda
	oBol:Box(2000+320,1300,2000+345,1301) // Quantidade
	oBol:Box(2000+365,1300,2000+390,1301) // Valor
	oBol:Say(2000+355,1295,"X",oFont1,1100) // Sinal de X
	oBol:Box(2000+320,1650,2000+390,2200) // Valor do Documento

	oBol:Box(2000+385,0000,2000+670,2200) // Instrucoes para o banco
	oBol:Box(2000+385,1650,2000+460,2200) // (-)Desconto/Abatimento
	oBol:Box(2000+460,1650,2000+530,2200) // (-)Outras Deduções
	oBol:Box(2000+530,1650,2000+600,2200) // (-)Mora/Multa
	oBol:Box(2000+600,1650,2000+670,2200) // (-)Outros Acrescimos
	oBol:Box(2000+670,0000,2000+800,2200) // Sacado


	// --------------------------------------
	// Impressao dos textos fixos das caixas
	// --------------------------------------
	For nW:= 1 to 3
		oBol:Say(_nLin+100,0020,"Santander ",oFont20b,100)           // Nome do banco
		oBol:Say(_nLin+100,0648,"637-7",oFont20b,100)                // Codigo do banco
		oBol:Say(_nLin+135,0020,"Local de Pagamento",oFont1,100)     // Local de Pagamento
		oBol:Say(_nLin+135,1660,"Vencimento",oFont1,100)             // Vencimento
		oBol:Say(_nLin+195,0020,"Beneficiario",oFont1,100)                // Nome do Cedente"
		oBol:Say(_nLin+195,1660,"AGÊNCIA/CÓDIGO BENEFICIARIO",oFont1,100) // Agencia e conta corrente com digito verificador

		oBol:Say(_nLin+265,0020,"Data do Documento",oFont1,100)      // Data do Documento
		oBol:Say(_nLin+265,0420,"No. do Documento",oFont1,100)       // Numero do Documento
		oBol:Say(_nLin+265,0820,"Espécie Doc",oFont1,100)            // Especie de documento
		oBol:Say(_nLin+265,1120,"Aceite",oFont1,100)                 // Aceite
		oBol:Say(_nLin+265,1320,"Data de Processamento",oFont1,100)  // Dia Processamento do titulo
		oBol:Say(_nLin+265,1660,"Nosso Número",oFont1,100)           // Nosso numero

		oBol:Say(_nLin+335,0020,"Uso Banco",oFont1,100)              // Uso Banco
		oBol:Say(_nLin+335,0420,"Carteira",oFont1,100)               // Carteira
		oBol:Say(_nLin+335,0720,"Espécie Moeda",oFont1,100)          // Especie Moeda
		oBol:Say(_nLin+335,1020,"Quantidade",oFont1,100)             // Quantidade
		oBol:Say(_nLin+335,1320,"Valor",oFont1,100)                  // Valor
		oBol:Say(_nLin+335,1670,"(=) Valor Documento",oFont1,100)    // Valor documento

		oBol:Say(_nLin+400,0020,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do beneficiario)",oFont1,100)
		oBol:Say(_nLin+400,1670,"(-) Desconto / Abatimento",oFont1,100)   // (-)Desconto / Abatimento
		oBol:Say(_nLin+545,1670,"(+) Mora / Multa",oFont1,100)        // (+)Mora / Multa
		oBol:Say(_nLin+615,1670,"(=) Valor Cobrado",oFont1,100)       // (=)Valor Cobrado
		oBol:Say(_nLin+685,0020,"PAGADOR ",oFont1,100)                 // Sacado
		oBol:Say(_nLin+790,0020,"Beneficiario final",oFont1,100)       // Sacador/Avalista

		if nW = 1
			oBol:Say(_nLin+815,1450,"Autenticação Mecânica-Ficha de Compensação",oFont2,100)
			oBol:Say(_nLin+1000,0000, Replicate(".",300))
		elseif nW = 2
			oBol:Say(_nLin+815,1450,"Autenticação Mecânica-Ficha de Compensação",oFont2,100)
		endif

		// ------------------------------------------
		// Impressao dos dados variaveis / Conteudo
		// ------------------------------------------

		oBol:Say(_nLin+175,0020,"Local de Pagamento" ,oFont01B,100)  // Local de Pagamento
		oBol:Say(_nLin+175,1820,dtoc(aDadosTit[4]),oFont09B,100)	   //Vencimento

		oBol:Say(_nLin+245,0020,Left(SM0->M0_NOMECOM,40)+"                   CNPJ: "+Transf(SM0->M0_CGC,"@R 99.999.999/9999-99"),oFont09B,100) // Nome da empresa e CNPJ
		oBol:Say(_nLin+245,1720,aDadosBanco[3] + ' / ' + aDadosBanco[8],oFont09B,100) // Agencia / conta

		oBol:Say(_nLin+310,0020,dtoc(aDadosTit[2]),oFont09B,100)      // Data do Documento
		oBol:Say(_nLin+310,0420,aDadosTit[1],oFont09B,100) 			// Numero do Documento (NFE + parcela do boleto)
		oBol:Say(_nLin+310,1320,dtoc(dDataBase),oFont09B,100)         // Data Processamento
		oBol:Say(_nLin+310,1720, Substr(aCB_RN_NN[3],1,12) +'-'+ Substr(aCB_RN_NN[3],13,1),oFont09B,100)   // Nosso numero (carteira/sequencia de 8 numeros)


		oBol:Say(_nLin+380,0420,"101",oFont09B,100)                   // Carteira
		oBol:Say(_nLin+380,0720,"R$",oFont09B,100)                    // Especie Moeda
		oBol:Say(_nLin+380,1850,Transf(aDadosTit[5],"@E 9,999,999.99"),oFont09B,100)  // Valor do documento (boleto)

		// Fixas
		oBol:Say(_nLin+460,0020," Valor do Documento = Valor do Titulo R$ "+Transf(aDadosTit[5],"@E 9,999,999.99"),oFont09B,100)   //Mensagem 1
		oBol:Say(_nLin+510,0020," Após o vencimento juros de 8 % A.M.  -  0.2 % A.D.",oFont09B,100)                                  //Mensagem 2
		oBol:Say(_nLin+560,0020," Sujeito a protesto após 5 dias de vencimento.",oFont09B,00)  
		//oBol:Say(_nLin+460,0020," BOLETO DE PROPOSTA ",oFont09B,100)   //Mensagem 1
		//oBol:Say(_nLin+510,0020," ESTE BOLETO SE REFERE A UMA PROPOSTA JÁ FEITA A VOCÊ E O SEU PAGAMENTO",oFont09B,100)                                  //Mensagem 2
		//oBol:Say(_nLin+560,0020," NÃO É OBRIGATÓRIO..",oFont09B,00)                                        //Mensagem 3
        //oBol:Say(_nLin+560,0020," NÃO É OBRIGATÓRIO..",oFont09B,00)
        //oBol:Say(_nLin+560,0020," NÃO É OBRIGATÓRIO..",oFont09B,00)
        //oBol:Say(_nLin+560,0020," NÃO É OBRIGATÓRIO..",oFont09B,00)
        //oBol:Say(_nLin+560,0020," NÃO É OBRIGATÓRIO..",oFont09B,00)
        //oBol:Say(_nLin+560,0020," NÃO É OBRIGATÓRIO..",oFont09B,00)

		// -----------------
		// Dados do sacado
		// -----------------
		oBol:Say(_nLin+700,0130,aDatSacado[1],oFont09B,100)          // Nome do Sacado (cliente)
		oBol:Say(_nLin+700,1150,Transform(Trim(aDatSacado[7]),If(" "$aDatSacado[7],"@R 999.999.999-99","@R 99.999.999/9999-99")),oFont09B,100)  // CGC
		oBol:Say(_nLin+730,0130,aDatSacado[3]+"-"+aDatSacado[9],oFont09B,100)          // Endereço e bairro
		oBol:Say(_nLin+760,0130,aDatSacado[6]+" "+aDatSacado[4]+"-"+aDatSacado[5],oFont09B,100)          // CEP, municipio e UF

		if nW = 1
			oBol:Say(_nLin+105, 1750,"Recibo do Pagador",oFont13b,100)
		elseif nW = 2
			oBol:Say(_nLin+105, 1842,"Ficha de Caixa",oFont13b,100)
		elseif nW = 3
			// ----------------
			// Linha digitavel
			// ----------------
			oBol:Say(_nLin+40,0000, Replicate(".",300))
			oBol:Say(_nLin+110,840,Transf(aCB_RN_NN[2],"@R 99999.99999  99999.999999  99999.999999  9  99999999999999"),oFont09B,100)
			oBol:Say(_nLin+815,1450,"Autenticação Mecânica - Ficha de Compensação",oFont2,100)


			//------------------
			// Codigo de barras
			//------------------

			oBol:FWMSBAR("INT25",65,1.6,aCB_RN_NN[1],oBol,.F.,,.T.,0.02,1.0,nil,nil,NIL,.F.,1,1,.F.)

		endif
		_nLin += 1000
	Next nW


	/* Função padrão de impressão do codigo de barras

	MSBAR("INT25"	,;  //01 cTypeBar - String com o tipo do codigo de barras ("EAN13","EAN8","UPCA","SUP5","CODE128","INT25","MAT25,"IND25","CODABAR","CODE3_9")
	nLinBar		   ,;  //02 nRow	   - Numero da Linha em centimentros 28       
	1.6		      ,;  //03 nCol	   - Numero da coluna em centimentros
	aGerabol[nK,15],;  //04 cCode	   - String com o conteudo do codigo     
	oBol		   	,;  //05 oPr	   - Objecto Printer
	.F.		   	,;  //06 lcheck   - Se calcula o digito de controle
	Nil		   	,;  //07 Cor 	   - Numero da Cor, utilize a "common.ch"
	.T.		   	,;  //08 lHort	   - Se imprime na Horizontal
	nTamBar	   	,;  //09 nWidth   - Numero do Tamanho da barra em centimetros	0.025
	nAltBar		   ,;  //10 nHeigth  - Numero da Altura da barra em milimetros		1.6
	Nil			   ,;  //11 lBanner  - Se imprime o linha em baixo do codigo
	Nil		   	,;  //12 cFont	   - String com o tipo de fonte
	"A"			   ,;  //13 cMode	   - String com o modo do codigo de barras INT25
	.F.)	             //14 lImprime - Imprime direto sem preview
	*/ 

	oBol:EndPage()       // Finaliza impressao do boleto

	MS_FLUSH()

	Set Century off
Return()

Static Function ValidPerg()

	Local _sAlias  	:= Alias()
	Local _cPerg	:= Padr("BOLITAU",10)
	Local aRegs    	:= {}
	Local i,j
	dbSelectArea("SX1")
	dbSetOrder(1)

	AADD(aRegs,{_cPerg,"01","De Prefixo    :" ,"De Prefixo"    ,"De Prefixo"    ,"mv_ch1" ,"C",03,0,0,"G","","mv_par01",""            ,"","","","",""	         ,"","","","","","","","","","","","","","","","","","","" 	     	,"",""})
	AADD(aRegs,{_cPerg,"02","Ate Prefixo   :" ,"Ate Prefixo"   ,"Ate Prefixo"   ,"mv_ch2" ,"C",03,0,0,"G","","mv_par02",""            ,"","","","",""	         ,"","","","","","","","","","","","","","","","","","","" 	     	,"",""})
	AADD(aRegs,{_cPerg,"03","De Numero     :" ,"De Numero"     ,"De Numero"     ,"mv_ch3" ,"C",09,0,0,"G","","mv_par03",""            ,"","","","",""	         ,"","","","","","","","","","","","","","","","","","","" 	     	,"",""})
	AADD(aRegs,{_cPerg,"04","Ate Numero    :" , "Ate Numero"   ,"Ate Numero"    ,"mv_ch4" ,"C",09,0,0,"G","","mv_par04",""            ,"","","","",""	         ,"","","","","","","","","","","","","","","","","","","" 	     	,"",""})
	AADD(aRegs,{_cPerg,"05","De Parcela    :" ,"De Parcela"    ,"De Parcela"    ,"mv_ch5" ,"C",03,0,0,"G","","mv_par05",""            ,"","","","",""	         ,"","","","","","","","","","","","","","","","","","","" 	     	,"",""})
	AADD(aRegs,{_cPerg,"06","Ate Parcela   :" ,"Ate Parcela"   ,"Ate Parcela"   ,"mv_ch6" ,"C",03,0,0,"G","","mv_par06",""            ,"","","","",""	         ,"","","","","","","","","","","","","","","","","","","" 	     	,"",""})
	AADD(aRegs,{_cPerg,"07","De Cliente    :" ,"De Cliente"    ,"De Cliente"    ,"mv_ch7" ,"C",06,0,0,"G","","mv_par07",""            ,"","","","",""	         ,"","","","","","","","","","","","","","","","","","","SA1CLI"    ,"",""})
	AADD(aRegs,{_cPerg,"08","Ate Cliente   :" ,"Ate Cliente"   ,"Ate Cliente"   ,"mv_ch8","C",06,0,0,"G","","mv_par08",""            ,"","","","",""	         ,"","","","","","","","","","","","","","","","","","","SA1CLI"    ,"",""})
	AADD(aRegs,{_cPerg,"09","De Loja       :" ,"De Loja"       ,"De Loja"       ,"mv_ch9","C",04,0,0,"G","","mv_par09",""            ,"","","","",""	         ,"","","","","","","","","","","","","","","","","","","" 	     	,"",""})
	AADD(aRegs,{_cPerg,"10","Ate Loja      :" ,"Ate Loja"      ,"Ate Loja"      ,"mv_ch10","C",04,0,0,"G","","mv_par10",""            ,"","","","",""	         ,"","","","","","","","","","","","","","","","","","","" 	     	,"",""})
	AADD(aRegs,{_cPerg,"11","De Emissao    :" ,"De Emissao"    ,"De Emissao"    ,"mv_ch11","D",08,0,0,"G","","mv_par11",""            ,"","","","",""	         ,"","","","","","","","","","","","","","","","","","","" 	     	,"",""})
	AADD(aRegs,{_cPerg,"12","Ate Emissao   :" ,"Ate Emissao"   ,"Ate Emissao"   ,"mv_ch12","D",08,0,0,"G","","mv_par12",""            ,"","","","",""	         ,"","","","","","","","","","","","","","","","","","","" 	     	,"",""})
	AADD(aRegs,{_cPerg,"13","De Vencimento :" ,"De Vencimento" ,"De Vencimento" ,"mv_ch13","D",08,0,0,"G","","mv_par13",""            ,"","","","",""	         ,"","","","","","","","","","","","","","","","","","","" 	     	,"",""})
	AADD(aRegs,{_cPerg,"14","Ate Vencimento:" ,"Ate Vencimento","Ate Vencimento","mv_ch14","D",08,0,0,"G","","mv_par14",""            ,"","","","",""	         ,"","","","","","","","","","","","","","","","","","","" 	     	,"",""})
	AADD(aRegs,{_cPerg,"15","Do Bordero    :" ,"Do Bordero"    ,"Do Bordero"    ,"mv_ch15","C",06,0,0,"G","","mv_par15",""            ,"","","","",""	         ,"","","","","","","","","","","","","","","","","","","" 	     	,"",""})
	AADD(aRegs,{_cPerg,"16","Ate Bordero   :" ,"Ate Bordero"   ,"Ate Bordero"   ,"mv_ch16","C",06,0,0,"G","","mv_par16",""            ,"","","","",""	         ,"","","","","","","","","","","","","","","","","","","" 	     	,"",""})
	AADD(aRegs,{_cPerg,"17","Banco         :" ,"Banco"         ,"Banco"         ,"mv_ch17","C",03,0,0,"G","","mv_par17",""            ,"","","","",""	         ,"","","","","","","","","","","","","","","","","","","SEE" 	    ,"",""})
	AADD(aRegs,{_cPerg,"18","Agencia       :" ,"Agencia"       ,"Agencia"       ,"mv_ch18","C",05,0,0,"G","","mv_par18",""            ,"","","","",""	         ,"","","","","","","","","","","","","","","","","","","" 	     	,"",""})
	AADD(aRegs,{_cPerg,"19","Conta         :" ,"Conta"         ,"Conta"         ,"mv_ch19","C",10,0,0,"G","","mv_par19",""            ,"","","","",""	         ,"","","","","","","","","","","","","","","","","","","" 	     	,"",""})

	For i := 1 to Len(aRegs)
		If !DbSeek(_cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	DbSelectArea(_sAlias)
Return

User Function B637WS(_filial,_titulo,_pref,_client,_loja,_parc)

	Processa({|lEnd|MontaRel(.T.,_filial,_titulo,_pref,_client,_loja,_parc)})

Return()
