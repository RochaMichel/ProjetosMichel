#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#Include "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA030TOK  ºAutor  ³TOTVS               º Data ³  04/15/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PONTO DE ENTRADA PARA BLOQUEAR O CADASTRO DE MAIS DE 1(UMA)º±±
±±º          ³ EMPRESA COM MESMO CNPJ E INSCRICAO ESTADUAL                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PROTHEUS 11                                                º±±   
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCod. GAP  ³ 05.01.02 - Seq.02                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±

//ALTERADO EM 26/12/2014 - Passagem de parametro/Validação rotina de Cond Especial

±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function MA030TOK
Local lRet := .T.
Local wAreaSA1 := {}
Local cCNPJ, cINSCR
Local cCodigo
Local cLoja
Local cBlqFin := ""
Local _cQuery := ""
Local xBlFin := SA1->A1_XBLQFIN
Local xBlFis := SA1->A1_MSBLQL
                              
wAreaSA1 := getArea()
 
	cCodigo := SA1->A1_COD
	cLoja 	:= SA1->A1_LOJA
	If Empty(SA1->A1_COD)  //Inclusão de Cliente pega posição de bloqueio da tela
		cCodigo := M->A1_COD
		cLoja 	:= M->A1_LOJA
		xBlFin 	:= M->A1_XBLQFIN
		xBlFis 	:= M->A1_MSBLQL
	EndIf 
lRet := .T.   
cCNPJ	:= M->A1_CGC
cINSCR	:= STRTRAN(M->A1_INSCR,".","")


	If EMPTY(Alltrim(M->A1_ENDCOB)) 
		Alert("É Obrigatório o preenchimento do endereço de cobrança.")
		RestArea( wAreaSA1 )
		Return .F. 
	EndIf 

// Verifica se é um CNPJ
if Len( allTrim( cCNPJ ) ) = 14
	
	// Valida se existe cadastro com o mesmo CNPJ e mesma Inscrição Estadual
	if ((alltrim(Posicione( "SA1" ,9, xFilial("SA1") + M->A1_CGC + STRTRAN(M->A1_INSCR,".","") , "A1_INSCR" ))==alltrim(M->A1_INSCR)) ;
		.and. !empty( M->A1_INSCR ) .and. inclui) .and. substr(M->A1_INSCR,1,1)!="I"
		Alert( "Existe cadastro com o mesmo CNPJ e IE." )
		lRet := .F.                                       		
	else
		lRet := .T. 
	endif

endif    

if empty( M->A1_CGC ) .and. alltrim(M->A1_EST)<>"EX"
	lRet := .F.     
Else     
	If altera
		//conout("- ALTERA - INICIO")
		//conout("- ALTERA - ACESSOU")

		
/*		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+M->A1_COD+M->A1_LOJA))
		//conout(M->A1_COND)
		//conout(SA1->A1_COND)		
			
		Endif
*/
		//conout("CONTINUA")
		cBlqFin := M->A1_XBLQFIN
		//conout(cCodigo)
		//conout(cBlqFin)
		//desbloqueio financeiro automatico do grupo de clientes
		_cQuery := "SELECT COUNT(*) QTD FROM "+RetSqlName("SA1")+" WHERE D_E_L_E_T_ = ' '  AND A1_COD='"+cCodigo+"' AND A1_XBLQFIN='S' AND A1_LOJA<>'"+cLoja+"'"
		
		If Select("TMP") > 0
			DBSELECTAREA("TMP")
			TMP->(DBCLOSEAREA())
		EndIf

		TcQuery _cQuery New Alias "TMP"
		DBSELECTAREA("TMP")
		TMP->(DBGOTOP())
		If TMP->QTD>0
			MsgAlert("ATENÇÃO, Existem clientes do grupo com bloqueio financeiro. A inclusão de pedidos ocorrerá apenas após liberação de todos os clientes do grupo. ")
		EndIf
		/*if !empty(M->A1_XBLQFIN) 
			_cQuery := "UPDATE SA1010 SET A1_XBLQFIN='"+cBlqFin+"' WHERE A1_COD='"+cCodigo+"' "
			//conout(_cQuery)
			If (nRet :=TcSqlExec(_cQuery)) <> 0
				_cError := TCSQLError()
				//conout(_cError)
				Memowrite("errorSA1.txt", _cError)
				//conout("SA1")
			Else
				TcSqlExec("COMMIT")
				//conout("COMMIT")
			EndIf	
		EndIf*/
		//conout("- ALTERA - FIM")	       
	EndIf
	
	if inclui
		M->A1_MSBLQL := "1"	
		M->A1_XSTPORT := "1"	//Aguardando autorização da área Fiscal
	endif
	U_LOGTAB("SA1","A1_COD",.F.)
                          
	/*If  M->A1_MSBLQL=='2'
		If !(u_CFGF02B("000000;000029;000030"))
			U_WWFSA101(M->A1_COD,M->A1_LOJA,"FIN")
		EndIf
	Else
		U_WWFSA101(M->A1_COD,M->A1_LOJA,"FIS")
	EndIf*/      
	
	If !Empty(M->A1_XCOND1)
	    If Alltrim(M->A1_XSTWF) <> 'P' .AND. !Empty(SA1->A1_XCOND1) .AND. alltrim(M->A1_XSTWF) <> 'R'
	    	If !Empty(M->A1_XSTWF)
	    		MsgInfo("Condicao especial em processo de aprovação!!")
	     	Else
	     		u_EWFCNDE("1",M->A1_COD,M->A1_LOJA,M->A1_XCOND1)
	    	EndIf
	    Else
		 u_EWFCNDE("1",M->A1_COD,M->A1_LOJA,M->A1_XCOND1)	
	    EndIf
	EndIf
	
endif   
	
RestArea( wAreaSA1 )  
	
Return lRet 
//----------------------------------------------------------------------------------------------------------
User Function SA1LibFin(_nTipo)

If  M->A1_MSBLQL=='2' .AND. M->A1_XBLQFIN=='N' .AND. M->A1_XBLQFIN<>SA1->A1_XBLQFIN .and. SA1->A1_XHRST3 = '     '
	If _nTipo == 1	//Data
		_Retorno := dDatabase
	ElseIf _nTipo == 2 
		_Retorno := substring(time(),1,5)		
	Endif
	M->A1_XSTPORT := "3"	//Liberado
Else

	If M->A1_MSBLQL=='1' 		
		M->A1_XSTPORT := "1"	//Aguardando autorização da área Fiscal
	ElseIf M->A1_MSBLQL=='2' .AND. M->A1_XBLQFIN=='S' 
		M->A1_XSTPORT := "2"	//Aguardando autorização da área Financeira
	ElseIf M->A1_MSBLQL=='2' .AND. M->A1_XBLQFIN=='N'
		M->A1_XSTPORT := "3"	// Liberado
	Endif

	If _nTipo == 1	//Data
		_Retorno := M->A1_XDTST3
	ElseIf _nTipo == 2
		_Retorno := M->A1_XHRST3		
	Endif
Endif
/*			M->A1_XDTST3 := dDatabase
			M->A1_XHRST3 := substr(time(),1,5)
			If Reclock("SA1",.F.)	
					SA1->A1_XDTST3 := dDatabase
				SA1->A1_XHRST3 := substr(time(),1,5)
				SA1->(MsUnlock())
			Endif	*/


Return(_Retorno)


//----------------------------------------------------------------------------------------------------------
User Function SA1LbFis(_nTipo)

If  M->A1_MSBLQL=='2' .AND. M->A1_MSBLQL<>SA1->A1_MSBLQL .and. SA1->A1_XHRST2 = '     '
	If _nTipo == 1	//Data
		_Retorno := dDatabase
	ElseIf _nTipo == 2 
		_Retorno := substring(time(),1,5)		
	Endif
	If M->A1_XBLQFIN=='S' 
		M->A1_XSTPORT := "2"	//Aguardando autorização da área Financeira
	ElseIf M->A1_XBLQFIN=='N'
		M->A1_XSTPORT := "3"	// Liberado
	Endif

Else

	If M->A1_MSBLQL=='1' 		
		M->A1_XSTPORT := "1"	//Aguardando autorização da área Fiscal
	ElseIf M->A1_MSBLQL=='2' .AND. M->A1_XBLQFIN=='S' 
		M->A1_XSTPORT := "2"	//Aguardando autorização da área Financeira
	ElseIf M->A1_MSBLQL=='2' .AND. M->A1_XBLQFIN=='N'
		M->A1_XSTPORT := "3"	// Liberado
	Endif

	If _nTipo == 1	//Data
		_Retorno := M->A1_XDTST2
	ElseIf _nTipo == 2
		_Retorno := M->A1_XHRST2		
	Endif

Endif

/*				Reclock("SA1",.F.)
				SA1->A1_XDTST2 := date()
				SA1->A1_XHRST2 := time()
				MsUnlock()
			EndIf	*/
Return(_Retorno)
