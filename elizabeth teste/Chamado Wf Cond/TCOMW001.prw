#include "Protheus.ch"
#include "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"

/*-----------------------------------------------------------------------------+
* Programa  * TCOMW001   º  Compras				         * Data ³  26/09/2000 *
*-----------------------------------------------------------------------------*
* Objetivo  * Programa que envia e-mail para os fornecedores após a inclusão  *
*           * da cotação. //								                   *
*-----------------------------------------------------------------------------*
* Uso       * WorkFlow/AP5 - ELIZABETH                                          *
+-----------------------------------------------------------------------------
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteracoes³Cristina Cruz 27/07/2017 incluído os campo Peso/Largura/Alturaº±± 
±±º           Largura e volume  								          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteracoes³Andre Pessoa 24/09/2019 inclusão da opção vazia na condição  ±± 
±±º           de Pagamento 		  								          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteracoes³Andre Pessoa 01/10/2019 Colocando comprador em copia		   ±± 
±±º           de Pagamento 		  								          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteracoes Fabio Roberto 01/07/2020 Colocando o campo C8_XPRODFO		    
±±º       
±±ºAlteracoes Fabio Roberto 28/0792020 Colocando o campo A2_CGC e M0_CGC     		  								          
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±  
*/                                                  


User Function TCOMW001(MV_COTACAO,MV_FOR,MV_LOJA,MV_NUMPRO)

	Local aCond:={}, aFrete:= {}, aSubst:={}, nTotal := 0
	Local _cC8_NUM, _cC8_FORNECE, _cC8_LOJA
	Local _cEmlFor
	Local _cEmlCC	:=	""
	Local cMailid 	:= 	""
	Local cFilehtm 	:= 	""
	Local cmailto 	:= 	""
	Local chtmltexto:= 	""
	Local cNomeFor	:=	""
	Local _cNomeUsr := 	""  
	Local _cObs		:= 	""
	Local _cCObs    :=  ""       // Criado por Sérgio Arruda - Chamado 226234
	Local ciSeek	:=	""
	Local ciLoop	:=	""
	Local ciNumPro	:=	"" 
	Local ciEndWS	:=	GetMV("EL_PAR013")

	//P3 Tecnologia - Code Analisys 17/06/2020
	Local cWFMail := GetMV('MV_WFMAIL')
	Local cUsrNomCom := UsrFullName(CUSERNAME)
	Local cNomCompr := UsrFullName(RetCodUsr())
	Local UsrEmail	:= UsrRetMail(RetCodUsr())

	DEFAULT MV_COTACAO	:=	""
	DEFAULT MV_FOR		:=	""
	DEFAULT MV_LOJA		:=	""
	DEFAULT MV_NUMPRO	:=  "" 



	If !Empty(MV_FOR)     
		ciNumPro:= PadR(MV_NUMPRO,TamSX3("C8_NUMPRO")[1],"") 
		ciSeek	+= xFilial("SC8")+PadR(MV_COTACAO,TamSX3("C8_NUM")[1],"")+PadR(MV_FOR,TamSX3("C8_FORNECE")[1],"")+PadR(MV_LOJA,TamSX3("C8_LOJA")[1],"")
		ciLoop	:=	"SC8->C8_FILIAL+SC8->C8_NUM+SC8->C8_FORNECE+SC8->C8_LOJA"//+SC8->C8_NUMPRO" 
	Else
		ciSeek	+= xFilial("SC8")+PadR(MV_COTACAO,TamSX3("C8_NUM")[1],"")
		ciLoop	:=	"SC8->C8_FILIAL+SC8->C8_NUM"	
		ciNumPro:= PadR(MV_NUMPRO,TamSX3("C8_NUMPRO")[1],"01") 	
	EndIf

	dbSelectArea("SC8")
	OpenSM0()
	DbSelectArea("SM0")
	SC8->(dbSetOrder(1))
	If SC8->(dbSeek(ciSeek))
		Do while SC8->(!eof()) .and. ciSeek == &ciLoop

			_cC8_NUM     := SC8->C8_NUM
			_cC8_FORNECE := SC8->C8_FORNECE
			_cC8_LOJA    := SC8->C8_LOJA 
			_cC8_NUMPRO	 :=	SC8->C8_NUMPRO

			dbSelectArea('SA2')  // Tabela de Fornecedores
			dbSetOrder(1)
			dbSeek( xFilial('SA2') + _cC8_FORNECE + _cC8_LOJA )               

			_cEmlFor := SA2->A2_EMAIL
			_cEmlCC  := Posicione("SY1",3,xFilial("SY1")+__CUSERID,"Y1_EMAIL")   


			cNomeFor := SA2->A2_NREDUZ

			If Alltrim(_cEmlFor) <> ""


				oProcess := TWFProcess():New( "COMCOT", "Cotação de Preços" )
				oProcess :NewTask( "Fluxo de Compras", "\workflow\cotacao.htm" )
				oHtml    := oProcess:oHTML

				oHtml:ValByName( "C8_CONTATO" , SC8->C8_CONTATO  )

				PswOrder(1)
				if PswSeek(cUsuario,.t.)
					aInfo    := PswRet(1)
					_cUser   := aInfo[1,2]
				endIf

				_cNomeUsr := Posicione("SY1",3,xFilial("SY1")+__CUSERID,"Y1_NOME")
				oHtml:ValByName( "Y1_NOME"    , _cNomeUsr     )
				oHtml:ValByName( "X_EMAIL"    , Posicione("SY1",3,xFilial("SY1")+__CUSERID,"Y1_EMAIL")    )

				/*** Preenche os dados do cabecalho ***/
				oHtml:ValByName( "C8_NUM"    , SC8->C8_NUM     )
				oHtml:ValByName( "C8_VALIDA" , SC8->C8_VALIDA  )
				oHtml:ValByName( "C8_FORNECE", SC8->C8_FORNECE )
				oHtml:ValByName( "C8_LOJA"   , SC8->C8_LOJA    )

				dbSelectArea('SA2')  // Tabela de Fornecedores
				dbSetOrder(1)
				dbSeek( xFilial('SA2') + _cC8_FORNECE + _cC8_LOJA )
				oHtml:ValByName( "A2_NOME"   , SA2->A2_NOME   )
				oHtml:ValByName( "A2_END"    , SA2->A2_END    )
				oHtml:ValByName( "A2_MUN"    , SA2->A2_MUN    )
				oHtml:ValByName( "A2_NR_END" , SA2->A2_NR_END )
				oHtml:ValByName( "A2_BAIRRO" , SA2->A2_BAIRRO )
				oHtml:ValByName( "A2_TEL"    , SA2->A2_TEL    )
				oHtml:ValByName( "A2_FAX"    , SA2->A2_FAX    )
				oHtml:ValByName( "A2_FAX"    , SA2->A2_FAX    )
				oHtml:ValByName( "A2_CGC"    , SA2->A2_CGC    )

				oHtml:ValByName( "M0EMP"    , SM0->M0_NOME    )
				oHtml:ValByName( "M0END"    , SM0->M0_ENDENT + ", " + SM0->M0_BAIRENT  )
				oHtml:ValByName( "M0MUN"    , SM0->M0_CIDENT  )

				dbSelectArea("SE4")
				SE4->(dbSetOrder(1))
				aAdd( aCond, ' ' )
				if SE4->(dbSeek(xFilial("SE4") + SA2->A2_COND ))
					aAdd( aCond, SE4->E4_Codigo + " - " + SE4->E4_Descri )
				endif     

				SE4->(dbGoTop())              
				Do While SE4->(!eof()) 
					If (SE4->E4_Filial == xFilial("SE4")) .AND. SE4->E4_MSBLQL <> '1' .AND. SE4->E4_FORWEB == '1' //SE4->E4_Codigo<"500" 
						aAdd( aCond, SE4->E4_Codigo + " - " + SE4->E4_Descri )
					EndIf
					SE4->(dbSkip())
				enddo

				oHtml:ValByName( "C8_CONTATO" , SC8->C8_CONTATO  )

				Do While SC8->(!eof()) .and. SC8->C8_FILIAL = xFilial("SC8") ;
				.and. SC8->C8_NUM     = _cC8_NUM ;
				.and. SC8->C8_FORNECE = _cC8_FORNECE ;
				.and. SC8->C8_LOJA    = _cC8_LOJA; 
				.And. SC8->C8_NUMPRO  = _cC8_NUMPRO

					dbSelectArea("SB1")
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1") + SC8->C8_PRODUTO )) 

					aAdd( (oHtml:ValByName( "it.item"    )), SC8->C8_ITEM    )
					aAdd( (oHtml:ValByName( "it.produto" )), SC8->C8_PRODUTO )

					aAdd( (oHtml:ValByName( "it.numpro"  )), SC8->C8_NUMPRO   ) 

					//INICIO - CAMPOS SUBSTITUIDOS A PEDIDO DO CLIENTE

					aAdd( (oHtml:ValByName( "it.descri"  )), SB1->B1_XDESCOM    ) 
					aAdd( (oHtml:ValByName( "it.especif" )), SB1->B1_XREF1    )

					//FIM - CAMPOS SUBSTITUIDOS A PEDIDO DO CLIENTE

					aAdd( (oHtml:ValByName( "it.quant"   )), TRANSFORM( SC8->C8_QUANT,'@E 99,999.99' ) )
					aAdd( (oHtml:ValByName( "it.posipi"  )), " "      )			
					aAdd( (oHtml:ValByName( "it.prodfor" )), " "      )
					aAdd( (oHtml:ValByName( "it.marca" )), " "      )
					aAdd( (oHtml:ValByName( "it.um"      )), SC8->C8_UM      )		
					aAdd( (oHtml:ValByName( "it.preco"   )), TRANSFORM( 0.00,'@E 99,999.99' ) )
					aAdd( (oHtml:ValByName( "it.valor"   )), TRANSFORM( 0.00,'@E 99,999.99' ) )
					aAdd( (oHtml:ValByName( "it.descont" )), TRANSFORM( 0.00,'@E 99,999.99' ) )
					aAdd( (oHtml:ValByName( "it.ipi"     )), TRANSFORM( 0.00,'@E 99,999.99' ) )
					aAdd( (oHtml:ValByName( "it.icms"    )), TRANSFORM( 0.00,'@E 99,999.99' ) )
					aAdd( (oHtml:ValByName( "it.prazo"   )), " ")
					aAdd( (oHtml:ValByName( "it.dia"     )), str(day(SC8->C8_DATPRF))         )
					aAdd( (oHtml:ValByName( "it.mes"     )), padl( alltrim( str( month(SC8->C8_DATPRF) ) ),2,"0") )
					aAdd( (oHtml:ValByName( "it.ano"     )), right(str(year(SC8->C8_DATPRF)),2))
					aAdd( (oHtml:ValByName( "it.peso"    )), " " )     
					aAdd( (oHtml:ValByName( "it.largura"    )), "" )
					aAdd( (oHtml:ValByName( "it.altura"    )), "" )   
					aAdd( (oHtml:ValByName( "it.compri"    )), "" )    
					aAdd( (oHtml:ValByName( "it.volume"    )), "" )

					_cCompr	:= Posicione("SC1",1,xFilial("SC1")+SC8->C8_NUMSC,"C1_CODCOMP")
					_cCObs	:= Posicione("SC1",1,xFilial("SC1")+SC8->C8_NUMSC,"C1_XOBSCOM")

					RecLock('SC8')
					SC8->C8_WFID 	:= oProcess:fProcessID
					SC8->C8_XCODCOM := _cCompr
					SC8->C8_XOBSCOM := _cCObs 
					SC8->C8_XAPLIC	:= Posicione("SC1",1,xFilial("SC1")+SC8->C8_NUMSC,"C1_XAPLIC")
					SC8->C8_XURGEN	:= Posicione("SC1",1,xFilial("SC1")+SC8->C8_NUMSC,"C1_XURGEN")
					SC8->(MsUnlock())

					SC8->(dbSkip())
				EndDo

				_cObs := "OBS DO FORNECEDOR"
				
				
				oHtml:ValByName( "Pagamento", aCond    )
				oHtml:ValByName( "Frete"    , {"CIF","FOB"}   )
				oHtml:ValByName( "subtot"   , TRANSFORM( 0 ,'@E 999,999.99' ) )
				oHtml:ValByName( "vldesc"   , TRANSFORM( 0 ,'@E 999,999.99' ) )
				oHtml:ValByName( "aliipi"   , TRANSFORM( 0 ,'@E 999,999.99' ) )
				oHtml:ValByName( "valfre"   , TRANSFORM( 0 ,'@E 999,999.99' ) )
				oHtml:ValByName( "totped"   , TRANSFORM( 0 ,'@E 999,999.99' ) )

				oHtml:ValByName( "M0_ENDCOB"   	,  SM0->M0_ENDCOB)
				oHtml:ValByName( "M0_CIDCOB"   	,  SM0->M0_CIDCOB)
				oHtml:ValByName( "M0_ESTCOB"   	,  SM0->M0_ESTCOB)
				oHtml:ValByName( "M0_CEPCOB"   	,  SM0->M0_CEPCOB)
				oHtml:ValByName( "M0_TEL"   	,  SM0->M0_TEL)
				oHtml:ValByName( "M0_FAX"   	,  SM0->M0_FAX) 
				oHtml:ValByName( "M0_CGC"   	,  SM0->M0_CGC) 
				oHtml:ValByName( "C8_XTRANSP"   ,  " ")
				oHtml:ValByName( "C8_XOBS"   	,  _cObs)
				oHtml:ValByName( "C8_XOBSCOM"  	,  _cCObs)
				oHtml:ValByName( "EMPRESA"    	, SM0->M0_NOME    )
				oHtml:ValByName( "ENDENT"    	, Alltrim(SM0->M0_ENDENT) + ", " + Alltrim(SM0->M0_BAIRENT) + ", " + Alltrim(SM0->M0_CIDENT)  )


				oProcess:cSubject := "Processo de geração de Cotação de Preços " + _cC8_NUM
				oProcess:cTo      := ""
				oProcess:bReturn  := "U_COMW001A()"

				cMailid := oProcess:Start()
				RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,"COMCOT",'100300',"Email Enviado Para o Fornecedor:"+SA2->A2_NOME)
				cFilehtm := cMailid + ".htm"
				cmailto := "mailto:" + AllTrim( cWFMail/*GetMV('MV_WFMAIL')*/ )
				chtmltexto := oProcess:oHtml:HtmlCode() //wfloadfile("\workflow\emp"+cEmpAnt+"\temp\" + cFilehtm )
				chtmltexto := strtran( chtmltexto, cmailto, "WFHTTPRET.APL" )
				MakeDir("\web\wf\messenger\emp"+AllTrim(cEmpAnt)) // Caso o diretorio nao exista, criar
				wfsavefile("\web\wf\messenger\emp"+AllTrim(cEmpAnt) + cFilehtm+'l', chtmltexto)

				oProcess:Free()
				oProcess:= Nil

				oProcess:=TWFProcess():New("COMCOT", "Cotação de Preços")
				oHtml   := oProcess:oHtml

				oProcess:NewTask('LINK',"\WORKFLOW\WFCOM002_a.htm")
				oProcess:ohtml:ValByName("usuario",cUsrNomCom) 
				ciLink	:=	"http://"+Alltrim(ciEndWS)+"/wf/messenger/emp"+AllTrim(cEmpAnt) + cFilehtm+'l'
				oProcess:ohtml:ValByName("proc_link",ciLink)

				//Alteracao Lucas 13/06/2018. Chamado 17073
				oProcess:ohtml:ValByName("ccomprador",cNomCompr)
				oProcess:ohtml:ValByName("cempresa",SM0->M0_NOMECOM)
				oProcess:ohtml:ValByName("cfone",SM0->M0_TEL)
				oProcess:ohtml:ValByName("cemail",UsrEmail)

				oProcess:ohtml:ValByName("referente","cotação de nº " + _cC8_NUM)
				oProcess:cTo 		:= _cEmlFor
				oProcess:cCC		:= _cEmlCC

				cUser := Subs(cUsuario,7,15)
				oProcess:ClientName(cUser)

				oProcess:cSubject  	:= OemToAnsi("Cotação de Preço ELIZABETH Nº: " +_cC8_NUM ) 

				oProcess:Start()

				oProcess:Free()
				oProcess:= Nil

			Else
				// Atualizar SC8 para nao processar novamente
				RecLock('SC8')
				SC8->C8_WFID := "WF9999"
				SC8->(MsUnlock())
				SC8->(dbSkip())
			EndIf
		EndDo
	EndIf
Return

User Function WFTimeout(cEMail ,nTmOut, oWF)

	oWF:Finish()       // Finaliza o processo anterior.

	If nTmOut == 1     // Ocorrencia do primeiro timeout.

		// Cria uma nova tarefa para o reenvio da mensagem ao mesmo destinatario.
		oWF:NewTask("000001", "\workflow\cotacao.htm", .T.)  // Parametro .T. --> repete os dados do HTML anterior.
		oWF:bReturn  := "U_COMW001A()"
		oWF:bTimeOut := {{"U_WFTimeout(2)",0,0,10}}
		oWF:cSubject += " (Timeout processo: " + oWF:fProcessID + ") REENVIO"

	Else               // Segundo timeout.

		// Cria uma nova tarefa para o envio da mensagem para outro destinatario.
		oWF:NewTask("000001", "\workflow\cotacao.htm", .T.)  // Parametro .T. --> repete os dados do HTML anterior.
		oWF:cTo := cEMail
		oWF:cSubject += " (Timeout processo: " + oWF:fProcessID + ") REENVIO"

	EndIf

	// Reenvia a mensagem.
	oWF:Start()

Return Nil

/*-----------------------------------------------------------------------------+
* Programa  * COMW001A  º  Business Inteligence         * Data ³  29/09/2000  *
*-----------------------------------------------------------------------------*
*Objetivo   * Programa executado durante retorno de cotacoes preenchidas      *
*             fornecedores,                                                   *
*-----------------------------------------------------------------------------*
* Uso       * WorkFlow/AP5 - WorkFlow                                         *
*-----------------------------------------------------------------------------+
| Starting  | Rotina de Retorno no Processo de WorkFlow                       |
+-----------------------------------------------------------------------------*/

User Function COMW001A(oProcess)

	Local ciNumPro	:=	""
	Local _cC8_NUM     := "" //PadR(AllTrim(oProcess:oHtml:RetByName("C8_NUM"     )),TamSX3("C8_NUM")[1],"")
	Local _cC8_FORNECE := "" //PadR(AllTrim(oProcess:oHtml:RetByName("C8_FORNECE" )),TamSX3("C8_FORNECE")[1],"")
	Local _cC8_LOJA    := "" //PadR(AllTrim(oProcess:oHtml:RetByName("C8_LOJA"    )),TamSX3("C8_LOJA")[1],"")
	Local aiAreaSC8		:=	SC8->(GetArea())
	Local _cCompr	:=  ""
	Local _cEmail	:=  ""
	Local _cOBS := " "
	Local _cCObs:= " "
	Local _nind := 1

	_cC8_NUM     := PadR(AllTrim(oProcess:oHtml:RetByName("C8_NUM"     )),TamSX3("C8_NUM")[1],"")
	_cC8_FORNECE := PadR(AllTrim(oProcess:oHtml:RetByName("C8_FORNECE" )),TamSX3("C8_FORNECE")[1],"")
	_cC8_LOJA    := PadR(AllTrim(oProcess:oHtml:RetByName("C8_LOJA"    )),TamSX3("C8_LOJA")[1],"")

	dbSelectArea("SC8")
	SC8->(dbSetOrder(1))//C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD
	SC8->(DBGoTop())                                                                                                
	If SC8->(dbSeek( xFilial("SC8") + _cC8_NUM + _cC8_FORNECE + _cC8_LOJA ))

		_cCompr	:= Posicione("SC1",1,xFilial("SC1")+SC8->C8_NUMSC,"C1_CODCOMP")

		RastreiaWF("COMCOT"+'.'+oProcess:fTaskID,"COMCOT",'100400',"Email respondido pelo Fornecedor:"+_cC8_FORNECE)

		_cC8_VLDESC := oProcess:oHtml:RetByName("VLDESC" )
		_cC8_ALIIPI := oProcess:oHtml:RetByName("ALIIPI" )
		_cC8_VALFRE := oProcess:oHtml:RetByName("VALFRE" )  

		_cOBS 		:= oProcess:oHtml:RetByName("C8_XOBS")
		_cCOBS 		:= oProcess:oHtml:RetByName("C8_XOBSCOM")

		if oProcess:oHtml:RetByName("Frete") = "FOB"
			_cC8_RATFRE := 0
		endif


		for _nind := 1 to len(oProcess:oHtml:RetByName("it.preco"))	
			_cC8_ITEM := oProcess:oHtml:RetByName("it.item")[_nind]
			ciNumPro	:= PadR(AllTrim(oProcess:oHtml:RetByName("it.numpro")[_nind]),TamSX3("C8_NUMPRO")[1],"")

			If SC8->(dbSeek( xFilial("SC8") + _cC8_NUM+ _cC8_FORNECE + _cC8_LOJA + _cC8_ITEM +ciNumPro))

				If empty(SC8->C8_NUMPED)

					RecLock("SC8",.f.)
					SC8->C8_POSIPI := oProcess:oHtml:RetByName("it.posipi")[_nind]
					SC8->C8_PRECO  := Val(StrTran(oProcess:oHtml:RetByName("it.preco")[_nind],',','.'))
					SC8->C8_XVLFORN:= Val(StrTran(oProcess:oHtml:RetByName("it.preco")[_nind],',','.'))
					if SC8->C8_XVLRORI == 0
						SC8->C8_XVLRORI := Val(StrTran(oProcess:oHtml:RetByName("it.preco")[_nind],',','.'))
					endif
					SC8->C8_TOTAL  := Val(StrTran(oProcess:oHtml:RetByName("it.valor")[_nind],',','.'))
					SC8->C8_VLDESC := Val(StrTran(oProcess:oHtml:RetByName("it.descont")[_nind],',','.'))
					SC8->C8_ALIIPI := Val(StrTran(oProcess:oHtml:RetByName("it.ipi"  )[_nind],',','.'))
					SC8->C8_PICM   := Val(StrTran(oProcess:oHtml:RetByName("it.icms"  )[_nind],',','.'))
					SC8->C8_PRAZO  := Val(StrTran(oProcess:oHtml:RetByName("it.prazo")[_nind],',','.'))
					_C8_DATPRF     :=     oProcess:oHtml:RetByName("it.dia"  )[_nind] + "/" + ;
					oProcess:oHtml:RetByName("it.mes"  )[_nind] + "/" + ;
					oProcess:oHtml:RetByName("it.ano"  )[_nind]
					SC8->C8_XDTENTR := CTOD(_C8_DATPRF)
					SC8->C8_XDTRETO := date()
					SC8->C8_XHRRETO := substr(time(),1,5)
					SC8->C8_COND    := Substr(alltrim(oProcess:oHtml:RetByName("pagamento")),1,3)
					SC8->C8_TPFRETE := Substr(oProcess:oHtml:RetByName("Frete"),1,1)
					//if (SC8->C8_EMISSAO>=StoD("20170411") .and. SC8->C8_XHORA>='09:10')
					SC8->C8_XMARCA	:= oProcess:oHtml:RetByName("it.marca")[_nind]
					SC8->C8_XNOMTRA	:= Substr(oProcess:oHtml:RetByName("C8_XTRANSP"),1,30)
					//EndIf
					SC8->C8_XPESO1	:=  oProcess:oHtml:RetByName("it.peso"  )[_nind]
					SC8->C8_XLARGUR	:=  oProcess:oHtml:RetByName("it.largura"  )[_nind]
					SC8->C8_XALTURA	:=  oProcess:oHtml:RetByName("it.altura"  )[_nind]
					SC8->C8_XCOMPRI	:=  oProcess:oHtml:RetByName("it.compri"  )[_nind]  
					SC8->C8_XVOLUM	:=  oProcess:oHtml:RetByName("it.volume"  )[_nind]
					SC8->C8_XPRODFO	:=  oProcess:oHtml:RetByName("it.prodfor"  )[_nind]
					
					//CALCULO PARA O VALOR DO FRETE
					iif( oProcess:oHtml:RetByName("Frete") = "FOB", ;
					SC8->C8_VALFRE := 0, ;
					SC8->C8_VALFRE := Val(oProcess:oHtml:RetByName("it.quant")[_nind]) * ;
					Val(StrTran(oProcess:oHtml:RetByName("it.preco")[_nind],',','.')) / ;
					Val(StrTran(oProcess:oHtml:RetByName("totped"),',','.') ) * Val(StrTran(oProcess:oHtml:RetByName("valfre"),',','.') ) )

					//CALCULO PARA O VALOR DO DESCONTO NA SC8
					iif( Val(oProcess:oHtml:RetByName("vldesc")) == 0 ,;
					SC8->C8_VLDESC := 0, ;
					SC8->C8_VLDESC := Val(StrTran(oProcess:oHtml:RetByName("it.quant")[_nind],',','.')) * ;
					Val(StrTran(oProcess:oHtml:RetByName("it.preco")[_nind],',','.')) / Val(StrTran(oProcess:oHtml:RetByName("totped"),',','.') ) * ;
					Val(StrTran(oProcess:oHtml:RetByName("vldesc"),',','.') ) )

					//CALCULO PARA O VALOR DO IPI E ICMS
					SC8->C8_VALIPI 	:= SC8->C8_TOTAL * SC8->C8_ALIIPI /100		
					SC8->C8_VALICM	:= SC8->C8_TOTAL * SC8->C8_PICM /100	

					SC8->C8_XOBS 	:= _cOBS  +" - Prazo entrega: "+_C8_DATPRF
				  //SC8->C8_XOBSCOM := _cCOBS 

					SC8->(MsUnlock())

				EndIf

			EndIf
		Next _nind
		oProcess:Finish()
		oProcess:Free()
		oProcess:= Nil	

		_cEmail := Posicione("SY1",1,xFilial("SY1")+_cCompr,"Y1_EMAIL")
		IF !Empty(_cEmail)
		   _cEmail := Alltrim(_cEmail)
		   U_EnviaMail(_cEmail,"O Fornecedor " + _cC8_FORNECE + " respondeu a cotação " + _cC8_NUM,"TCOMW001 - Resposta da cotacao " + _cC8_NUM )   
		EndIf

	EndIf


	RestArea(aiAreaSC8)
Return()


/*-----------------------------------------------------------------------------+
* Programa  * EnviaMail   º  Compras				     * Data ³  26/09/2000  *
*------------------------------------------------------------------------------*
* Objetivo  * Envia email ao comprador notificando que o Fornecedor respondeu  *
*           * a cotação									                       *
*------------------------------------------------------------------------------*
* Uso       * WorkFlow/AP5 - elizabeth                                         *
*------------------------------------------------------------------------------+
| Starting  | Ponto de Entrada                                                 |
+-----------------------------------------------------------------------------*/

User Function EnviaMail(_email, _mensagem, _assunto)

	Local _aArea := GetArea()
	Local cAccount, cPassword, cServer
	Local lMailAut := .T.

	//ENVIAR PELO DOMINIO ELIZABETHTEC.COM.BR
	cAccount	:= GetMv("EL_RLCONTA")
	cPassword	:= GetMv("EL_RLSENHA")
	cServer		:= GetMv("EL_RLSERV")
	lMailAut	:= GetMv("EL_RLAUTEN")

	cMV1        := "MV_RELSSL"
	cMV2        := "MV_RELTLS"

	U_ACSENDM(cAccount,cPassword,cServer,cAccount,_email,_assunto,_mensagem,'')
	RestArea(_aArea)
Return ()
