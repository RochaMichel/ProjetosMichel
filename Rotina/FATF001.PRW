#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fileio.ch'
#INCLUDE "TOPCONN.CH"

#define CRLF Chr(13)+Chr(10)

*******************************************************************
* @author      Catia Vieira
* @name        FATF001
* @date        20/08/2021
* @empresa     G.ELIZABETH
* @description Programa para geracao dos pedidos gerados no Mercanet
********************************************************************

User Function FATF001()
	
	AxCadastro("ZM2", OemToAnsi("CRIA TABLE"), 'U_A100VldExcl()')
	AxCadastro("ZM3", OemToAnsi("CRIA TABLE"), 'U_A100VldExcl()')
	AxCadastro("ZM1", OemToAnsi("CRIA TABLE"), 'U_A100VldExcl()')
	
Return

User Function FATF001A()
	
	Local aArea 	 := GetArea()
	
	Private lMSErroAuto := .F.
	Private cObsPed  := ""
	Private cLocaliz := ""
	Private cObsMerc := ""
	Private aObsItem := {}
	Private cPedFil	 := ""
	Private cFilBkp	 := ""
	Private cTabPreco:= ""

	nHdl := fCreate( GetPathSemaforo() + "FATF001A.LCK" )

	If nHDL < 0
		Return .F.
	EndIf
	
	If ! IsInCallStack("SIGAIXB")
		RpcClearEnv()
		RpcSetType(3)
		RpcSetEnv("01","020202",,,"FAT",,{})
	EndIf
	
	dbSelectArea("ZM2")
	ZM2->(dbSetOrder(1)) //FILIAL + PED MERC + CLIENTE + LOJA
    SET FILTER TO ZM2->ZM2_STATUS == 'INS'	//Filtra somente itens inseridos
	ZM2->(dbGoTop())
	While !ZM2->(Eof())
		
		If Upper(AllTrim(ZM2->ZM2_STATUS)) == "INS"	.And. Empty(ZM2->ZM2_NUM)	//Ainda nÃ£o gerado no Protheus
			
			//Grava horario de inicio de processo
			dbSelectArea("ZM2")
			If RecLock("ZM2",.F.)
				ZM2->ZM2_DTINI := dDataBase
				ZM2->ZM2_HRINI := Time()
				MsUnlock()
			EndIf
			
			cPedFil := ZM2->ZM2_FILIAL  
			//Verifica se pedido jÃ¡ foi incluÃ­do no sistema
			dbSelectArea("SC5")
			SC5->(dbSetOrder(15))	//C5_FILIAL + C5_XPEDMER
			SC5->(dbGoTop())
			SC5->(dbSeek(cPedFil+ZM2->ZM2_PEDMER))
			If Found()
				If RecLock("ZM2",.F.)
					ZM2->ZM2_ERRO2 := "Pedido já incluído no sistema! Num. Ped. Protheus: " + AllTrim(SC5->C5_NUM)
					ZM2->ZM2_STATUS := "PRO"
					ZM2->ZM2_NUM 	:= SC5->C5_NUM
					MsUnlock()
				EndIf
				ZM2->(dbSkip())
				Loop	//Pula o pedido
			EndIf
			
			//MsgAlert("Valida pedido")
			If ValidGeral()
				//Gera Pedido de Venda
				//MsgAlert("Gera pedido")
				GeraPedido()
			Else
				dbSelectArea("ZM2")
				If RecLock("ZM2",.F.)
					ZM2->ZM2_ERRO2 := cObsMerc
					ZM2->ZM2_STATUS := "ERR"
					MsUnlock()
				EndIf
			EndIf
			
			//Grava horario de fim de processo
			dbSelectArea("ZM2")
			If RecLock("ZM2",.F.)
				ZM2->ZM2_DTFIM := dDataBase
				ZM2->ZM2_HRFIM := Time()
				MsUnlock()
			EndIf
			
		EndIf
		
		ZM2->(dbSkip())
	End
	RestArea(aArea)
	
	If ! IsInCallStack("SIGAIXB")
		RpcClearEnv()
	EndIf

	FClose( nHDL )
	FErase( GetPathSemaforo() + "FATF001A.LCK" )
	
Return

User Function FATF001B()
	
	Local aArea := GetArea()
	
	Private lMSErroAuto := .F.
	Private lMSHelpAuto := .F.
	Private _aAuto		:= {}
	Private nOpc		:= 0
	Private aDados		:= {}
	
	// Se estiver sendo executado sem interface com o usuario, eh por que trata-se
	// de execucao em batch e deve preparar o ambiente
	If !IsInCallStack("SIGAIXB")
		//Inicia ambiente
		RpcClearEnv()
		RpcSetType(3)
		RpcSetEnv("01","020202",,,"FAT",,{})
	EndIf

	conout("Filial "+cFilAnt)
	 
	///MsgAlert("IMPORTACAO DE CLIENTES - VERSAO 17-01 - CHAMADO 102053")
	dbSelectArea("ZM1")
	ZM1->(dbSetOrder(1)) //FILIAL + CODMER
	//SET FILTER TO ZM1->ZM1_STATUS == 'INS' //Filtra somente itens inseridos e com Erro::Helton Silva:: 11/11/21
	ZM1->(dbGoTop())
	If ! Empty(ZM1->ZM1_CODMER)	//Se nÃ£o houver um registro preenchido, ou todos estÃ£o deletados, ou nÃ£o hÃ¡ dados na tabela
		While !ZM1->(Eof())
			
			If Upper(AllTrim(ZM1->ZM1_STATUS)) != "PRO"	.Or. Empty(ZM1->ZM1_COD)//Ainda nÃ£o gerado no Protheus
				//Grava horario de inicio de processo
				dbSelectArea("ZM1")
				If RecLock("ZM1",.F.)
					ZM1->ZM1_DTINI := dDataBase
					ZM1->ZM1_HRINI := Time()
					MsUnlock()
				EndIf
				
				aDados 	:= {}				
				dbSelectArea("SA1")
				SA1->(dbSetOrder(3)) //FILIAL + CGC
				SA1->(dbGoTop())
				SA1->(dbSeek(xFilial("SA1") + ZM1->ZM1_CGC))
				If ! Found()
					
					nOpc := 3
					if ZM1->ZM1_MATRIZ != ' '
						aAdd(aDados, {"A1_COD"		, PADR(ZM1->ZM1_MATRIZ			,TAMSX3("A1_COD")[1])						, 	Nil}) 
						aAdd(aDados, {"A1_LOJA"		, strzero(U_RetLoja(ZM1->ZM1_MATRIZ),4)	, 	Nil} )
					else
						cRet := GetSx8Num( "SA1" , "A1_COD" )
                        ConfirmSx8()
						aAdd(aDados, {"A1_COD"		, PADR(cRet			,TAMSX3("A1_COD")[1])						, 	Nil}) 							
						aAdd(aDados, {"A1_LOJA"		, strzero(U_RetLoja(ZM1->ZM1_MATRIZ),4)	, 	Nil} )
					endif
					aAdd(aDados, {"A1_FILIAL"	, xFilial("SA1")																,	Nil})
					aAdd(aDados, {"A1_NOME"   	, PADR(UPPER(ZM1->ZM1_NOME)			,TAMSX3("A1_NOME")[1])						,	Nil})
					aAdd(aDados, {"A1_NREDUZ" 	, PADR(UPPER(ZM1->ZM1_NREDUZ)		,TAMSX3("A1_NREDUZ")[1])					,	Nil})
					aAdd(aDados, {"A1_TIPO"   	, PADR(ZM1->ZM1_TIPO				,TAMSX3("A1_TIPO")[1])						,	Nil})
					aAdd(aDados, {"A1_PESSOA" 	, ZM1->ZM1_PESSOA					,	Nil})
					aAdd(aDados, {"A1_CGC"    	, PADR(ZM1->ZM1_CGC					,TAMSX3("A1_CGC")[1])						,	Nil})
					aAdd(aDados, {"A1_END"    	, PADR(UPPER(ZM1->ZM1_END)			,TAMSX3("A1_END")[1])						,	Nil})
					aAdd(aDados, {"A1_BAIRRO" 	, PADR(UPPER(ZM1->ZM1_BAIRRO)		,TAMSX3("A1_BAIRRO")[1])					,	Nil})
					aAdd(aDados, {"A1_EST"    	, PADR(ZM1->ZM1_EST					,TAMSX3("A1_EST")[1])						,	Nil})
					aAdd(aDados, {"A1_MUN"    	, PADR(UPPER(ZM1->ZM1_MUN)			,TAMSX3("A1_MUN")[1])						,	Nil})
					aAdd(aDados, {"A1_CEP"    	, PADR(ZM1->ZM1_CEP					,TAMSX3("A1_CEP")[1])					,	Nil})
					aAdd(aDados, {"A1_COD_MUN"	, PADR(ZM1->ZM1_COD_MU				,TAMSX3("A1_COD_MUN")[1])				,	Nil})
					aAdd(aDados, {"A1_DDD"    	, PADR(ZM1->ZM1_BCO1		    	,TAMSX3("A1_DDD")[1])					,	Nil})
					aAdd(aDados, {"A1_TEL"    	, PADR(ZM1->ZM1_TEL					,TAMSX3("A1_TEL")[1])					,	Nil})
					aAdd(aDados, {"A1_EMAIL"  	, PADR(lower(AllTrim(ZM1->ZM1_EMAIL)),TAMSX3("A1_EMAIL")[1])				,	Nil})
					/// CHAMADO 103106
					aAdd(aDados, {"A1_PAIS"   	, PADR(ZM1->ZM1_PAIS				,TAMSX3("A1_PAIS")[1])					,	Nil})
					aAdd(aDados, {"A1_CODPAIS"	, PADR(ZM1->ZM1_CODPAI		        ,TAMSX3("A1_CODPAIS")[1])				,	Nil})
					aAdd(aDados, {"A1_VEND"   	, PADR(ZM1->ZM1_VEND				,TAMSX3("A1_VEND")[1])					,	Nil})
					aAdd(aDados, {"A1_COND"   	, PADR(ZM1->ZM1_COND				,TAMSX3("A1_COND")[1])					,	Nil})
					aAdd(aDados, {"A1_MSBLQL" 	, PADR("2"							,TAMSX3("A1_MSBLQL")[1])				,	Nil})
					aAdd(aDados, {"A1_INSCR"  	, UPPER(ZM1->ZM1_INSCR)														,	Nil})
					aAdd(aDados, {"A1_LC"		, ZM1->ZM1_LC																,	Nil})
					aAdd(aDados, {"A1_ENDCOB"	, ZM1->ZM1_ENDCOB															,	Nil})
					aAdd(aDados, {"A1_CONTATO"	, ZM1->ZM1_CONTAT															,	Nil})
					aAdd(aDados, {"A1_BAIRROC"	, ZM1->ZM1_BAIRRC															,	Nil})
					aAdd(aDados, {"A1_CEPC"		, ZM1->ZM1_CEPC																,	Nil})
					aAdd(aDados, {"A1_ESTC"		, ZM1->ZM1_ESTC																,	Nil})
					aAdd(aDados, {"A1_MUNC"		, ZM1->ZM1_MUNC																,	Nil})
					aAdd(aDados, {"A1_XTPCOM"	, ZM1->ZM1_XTPCOM															,	Nil})
					aAdd(aDados, {"A1_XCANAL"	, ZM1->ZM1_XCANAL															,	Nil})
					aAdd(aDados, {"A1_SUPER"	, ZM1->ZM1_SUP																,	Nil})
					aAdd(aDados, {"A1_XBLQFIN"  ,"N"                														,	Nil}) //Helton Silva::11/11/21
					// campos vindos do cliente 2.0 - alteracao 06/12
					aAdd(aDados, {"A1_COMPLEM"	, ZM1->ZM1_COMPL															,	Nil})
					aAdd(aDados, {"A1_DTNASC"	, ZM1->ZM1_DTNASC 															,	Nil})
					aAdd(aDados, {"A1_B2B"	    , ZM1->ZM1_B2B 																,	Nil})
					aAdd(aDados, {"A1_GRPTRIB"	, ZM1->ZM1_GRPTR															,	Nil})
					aAdd(aDados, {"A1_CONTRIB"	, ZM1->ZM1_CONTRI															,	Nil})
					aAdd(aDados, {"A1_SIMPLES"	, ZM1->ZM1_SIMPLE															,	Nil})
					aAdd(aDados, {"A1_SIMPNAC"	, ZM1->ZM1_SIMPNA															,	Nil})
					aAdd(aDados, {"A1_SUFRAMA"	, ZM1->ZM1_SUFRAM															,	Nil})
					aAdd(aDados, {"A1_CODMUN"	, ZM1->ZM1_CODMUN 															,	Nil})
					aAdd(aDados, {"A1_XCARBAN"	, ZM1->ZM1_XCARBA															,	Nil})
					aAdd(aDados, {"A1_XLCSUGE"	, ZM1->ZM1_XLCSUG 															,	Nil})
					aAdd(aDados, {"A1_XPREDPR"	, ZM1->ZM1_XPREDP															,	Nil})
					aAdd(aDados, {"A1_XEMPIL"	, ZM1->ZM1_XEMPIL															,	Nil})
					aAdd(aDados, {"A1_XLISER"	, ZM1->ZM1_XLISER															,	Nil})
					aAdd(aDados, {"A1_XDTSER"	, ZM1->ZM1_XDTSER															,	Nil})
					aAdd(aDados, {"A1_VENCLC"	, ZM1->ZM1_VENCLC															,	Nil})
					aAdd(aDados, {"A1_RISCO"	, ZM1->ZM1_RISCO 															,	Nil})
					aAdd(aDados, {"A1_XPARECE"	, IIF(EMPTY(ZM1->ZM1_XPA), '2', '1')								 	    ,	Nil})
					// CHAMADO 10253
					aAdd(aDados, {"A1_TPESSOA"  , ZM1->ZM1_TPESSO														    ,	Nil})
					aAdd(aDados, {"A1_GRPVEN"   , ZM1->ZM1_GRPVEN														    ,	Nil})
                    aAdd(aDados, {"A1_XOBSFIN"  , ZM1->ZM1_XOBSFI														    ,	Nil})
					aAdd(aDados, {"A1_CALCSUF"	, ZM1->ZM1_CALCSU															,	Nil})
				Else
					//Verifica se cliente é estrangeiro
					If Alltrim(ZM1->ZM1_EST) == 'EX'
						//Verifica se existe na AI0 
						aClientes :=  ValidAI0(ZM1->ZM1_CODMER)
						If Empty(aClientes[1,1])
							nOpc := 3

							aAdd(aDados, {"A1_FILIAL"	, xFilial("SA1")															,	Nil})
							
							if ZM1->ZM1_MATRIZ != ' '
								aAdd(aDados, {"A1_COD"		, PADR(ZM1->ZM1_MATRIZ,TAMSX3("A1_COD")[1])	, 	Nil}) 
								aAdd(aDados, {"A1_LOJA"		, strzero(U_RetLoja(ZM1->ZM1_MATRIZ),4)	, 	Nil} )
							else
								cRet := GetSx8Num( "SA1" , "A1_COD" )
								ConfirmSx8()
								aAdd(aDados, {"A1_COD"		, PADR(cRet			,TAMSX3("A1_COD")[1])						, 	Nil}) 							
								aAdd(aDados, {"A1_LOJA"		, strzero(U_RetLoja(ZM1->ZM1_MATRIZ),4)	, 	Nil} )
							endif
							aAdd(aDados, {"A1_COD_MUN"	, PADR( IIF(Empty(ZM1->ZM1_COD_MU), "99999", ZM1->ZM1_COD_MU), TAMSX3("A1_COD_MUN")[1])	, Nil})
						
						Else
							If ZM1->ZM1_MATRIZ != ' '
								nOpc := 3

								aAdd(aDados, {"A1_FILIAL"	, xFilial("SA1")							,	Nil})
								aAdd(aDados, {"A1_COD"		, PADR(ZM1->ZM1_MATRIZ,TAMSX3("A1_COD")[1])	, 	Nil}) 
								aAdd(aDados, {"A1_LOJA"		, strzero(U_RetLoja(ZM1->ZM1_MATRIZ),4)	, 	Nil} )
							Else
								nOpc := 4
							
								aAdd(aDados, {"A1_FILIAL"	, xFilial("SA1")															,	Nil})
								aAdd(aDados, {"A1_COD"		, PADR(SA1->A1_COD					,TAMSX3("A1_COD")[1])					, 	Nil})
								aAdd(aDados, {"A1_LOJA"	    , PADR(SA1->A1_LOJA					,TAMSX3("A1_LOJA")[1])					, 	Nil})
							Endif	
						Endif
					else
						nOpc := 4
						aAdd(aDados, {"A1_FILIAL"	, xFilial("SA1")															,	Nil})
						aAdd(aDados, {"A1_COD"		, PADR(SA1->A1_COD					,TAMSX3("A1_COD")[1])					, 	Nil})
						aAdd(aDados, {"A1_LOJA"	    , PADR(SA1->A1_LOJA					,TAMSX3("A1_LOJA")[1])					, 	Nil})
					Endif	
					aAdd(aDados, {"A1_TIPO"   	, PADR(ZM1->ZM1_TIPO				,TAMSX3("A1_TIPO")[1])						,	Nil})
					aAdd(aDados, {"A1_PESSOA" 	, ZM1->ZM1_PESSOA					,	Nil})
					aAdd(aDados, {"A1_NOME"   	, PADR(UPPER(ZM1->ZM1_NOME)			,TAMSX3("A1_NOME")[1])					,	Nil})
					aAdd(aDados, {"A1_NREDUZ" 	, PADR(UPPER(ZM1->ZM1_NREDUZ)		,TAMSX3("A1_NREDUZ")[1])				,	Nil})
					aAdd(aDados, {"A1_END"    	, PADR(UPPER(ZM1->ZM1_END)			,TAMSX3("A1_END")[1])					,	Nil})
					aAdd(aDados, {"A1_BAIRRO" 	, PADR(UPPER(ZM1->ZM1_BAIRRO)		,TAMSX3("A1_BAIRRO")[1])				,	Nil})
					aAdd(aDados, {"A1_EST"    	, PADR(ZM1->ZM1_EST					,TAMSX3("A1_EST")[1])					,	Nil})
					aAdd(aDados, {"A1_MUN"    	, PADR(UPPER(ZM1->ZM1_MUN)			,TAMSX3("A1_MUN")[1])					,	Nil})
					aAdd(aDados, {"A1_CEP"    	, PADR(ZM1->ZM1_CEP					,TAMSX3("A1_CEP")[1])					,	Nil})
					aAdd(aDados, {"A1_COD_MUN"	, PADR(IIf(!Empty(ZM1->ZM1_COD_MU), ZM1->ZM1_COD_MU, IIF(!Empty(SA1->A1_COD_MUN), SA1->A1_COD_MUN, '99999') ), TAMSX3("A1_COD_MUN")[1])	, Nil})	
					aAdd(aDados, {"A1_DDD"    	, PADR(ZM1->ZM1_BCO1    			,TAMSX3("A1_DDD")[1])							,	Nil})
					aAdd(aDados, {"A1_TEL"    	, PADR(ZM1->ZM1_TEL					,TAMSX3("A1_TEL")[1])			 		,	Nil})
					aAdd(aDados, {"A1_EMAIL"  	, PADR(lower(AllTrim(ZM1->ZM1_EMAIL)),TAMSX3("A1_EMAIL")[1])				,	Nil})
					/// CHAMADO 103106
					aAdd(aDados, {"A1_PAIS"   	, PADR(ZM1->ZM1_PAIS				,TAMSX3("A1_PAIS")[1])					,	Nil})
					aAdd(aDados, {"A1_CODPAIS"	, PADR(ZM1->ZM1_CODPAI		        ,TAMSX3("A1_CODPAIS")[1])				,	Nil})
					aAdd(aDados, {"A1_VEND"   	, PADR(ZM1->ZM1_VEND				,TAMSX3("A1_VEND")[1])				    ,	Nil})
					aAdd(aDados, {"A1_COND"   	, PADR(ZM1->ZM1_COND				,TAMSX3("A1_COND")[1])					,	Nil})
					aAdd(aDados, {"A1_MSBLQL" 	, PADR("2"							,TAMSX3("A1_MSBLQL")[1])				,	Nil})
					aAdd(aDados, {"A1_INSCR"  	, UPPER(ZM1->ZM1_INSCR)														,	Nil})
					aAdd(aDados, {"A1_LC"		, ZM1->ZM1_LC																,	Nil})
					aAdd(aDados, {"A1_ENDCOB"	, ZM1->ZM1_ENDCOB															,	Nil})
					aAdd(aDados, {"A1_CONTATO"	, ZM1->ZM1_CONTAT															,	Nil})
					aAdd(aDados, {"A1_BAIRROC"	, ZM1->ZM1_BAIRRC															,	Nil})
					aAdd(aDados, {"A1_CEPC"		, ZM1->ZM1_CEPC																,	Nil})
					aAdd(aDados, {"A1_ESTC"		, ZM1->ZM1_ESTC																,	Nil})
					aAdd(aDados, {"A1_MUNC"		, ZM1->ZM1_MUNC																,	Nil})
					aAdd(aDados, {"A1_XTPCOM"	, ZM1->ZM1_XTPCOM															,	Nil})
					aAdd(aDados, {"A1_XCANAL"	, ZM1->ZM1_XCANAL															,	Nil})
					aAdd(aDados, {"A1_SUPER"    , ZM1->ZM1_SUP																,	Nil})
					aAdd(aDados, {"A1_XBLQFIN"  , "N"                														,	Nil}) //Helton Silva::11/11/21
					// campos vindos do cliente 2.0 - alteracao 06/12
					aAdd(aDados, {"A1_COMPLEM"	, ZM1->ZM1_COMPL															,	Nil})
					aAdd(aDados, {"A1_DTNASC"	, ZM1->ZM1_DTNASC 															,	Nil})
					aAdd(aDados, {"A1_B2B"	    , ZM1->ZM1_B2B 																,	Nil})
					aAdd(aDados, {"A1_GRPTRIB"	, ZM1->ZM1_GRPTR															,	Nil})
					aAdd(aDados, {"A1_CONTRIB"	, ZM1->ZM1_CONTRI															,	Nil})
					aAdd(aDados, {"A1_SIMPLES"	, ZM1->ZM1_SIMPLE															,	Nil})
					aAdd(aDados, {"A1_SIMPNAC"	, ZM1->ZM1_SIMPNA															,	Nil})
					aAdd(aDados, {"A1_SUFRAMA"	, ZM1->ZM1_SUFRAM															,	Nil})
					aAdd(aDados, {"A1_CODMUN"	, PADR(IIf(!Empty(ZM1->ZM1_CODMUN), ZM1->ZM1_CODMUN, IIF(!Empty(SA1->A1_CODMUN), SA1->A1_CODMUN, Space(5)) ), TAMSX3("A1_COD_MUN")[1])	, Nil})	
					aAdd(aDados, {"A1_XCARBAN"	, ZM1->ZM1_XCARBA															,	Nil})
					aAdd(aDados, {"A1_XLCSUGE"	, ZM1->ZM1_XLCSUG 															,	Nil})
					aAdd(aDados, {"A1_XPREDPR"	, ZM1->ZM1_XPREDP															,	Nil})
					aAdd(aDados, {"A1_XEMPIL"	, ZM1->ZM1_XEMPIL															,	Nil})
					aAdd(aDados, {"A1_XLISER"	, ZM1->ZM1_XLISER															,	Nil})
					aAdd(aDados, {"A1_XDTSER"	, ZM1->ZM1_XDTSER															,	Nil})
					aAdd(aDados, {"A1_VENCLC"	, ZM1->ZM1_VENCLC															,	Nil})
					aAdd(aDados, {"A1_RISCO"	, ZM1->ZM1_RISCO 															,	Nil})
					aAdd(aDados, {"A1_XPARECE"	, IIF(EMPTY(ZM1->ZM1_XPA), '2', '1')								 	    ,	Nil})
					// CHAMADO 10253
					aAdd(aDados, {"A1_TPESSOA"  , ZM1->ZM1_TPESSO														    ,	Nil})
					aAdd(aDados, {"A1_GRPVEN"   , ZM1->ZM1_GRPVEN														    ,	Nil})
					aAdd(aDados, {"A1_XOBSFIN"  , ZM1->ZM1_XOBSFI														    ,	Nil})
					aAdd(aDados, {"A1_CALCSUF"	, ZM1->ZM1_CALCSU															,	Nil})
				EndIf
				
				//************************************************
				//FWVetByDic FunÃ§Ã£o ordenar um vetor conforme o
				//dicionÃ¡rio para uso em, por exemplo, rotinas de MSExecAuto.
				//************************************************/
				aDados := FWVetByDic(aDados, "SA1")
								
				//Grava Cliente
				GeraCli(aDados, nOpc, ZM1->ZM1_EST)
				
				//Grava horario de fim de processo
				dbSelectArea("ZM1")
				If RecLock("ZM1",.F.)
					ZM1->ZM1_DTFIM := dDataBase
					ZM1->ZM1_HRFIM := Time()
					MsUnlock()
				EndIf
				
			EndIf
			
			ZM1->(dbSkip())
		End
	Else
		If IsInCallStack("SIGAIXB")	//SÃ³ apresenta msg por menu
			MsgAlert("Nao existem clientes a importar!")
		EndIf
		GeraLog("Não existem clientes cadastrados!", "", 2)
	EndIf
	
	RestArea(aArea)
	
	If ! IsInCallStack("SIGAIXB")
		//Finaliza Ambiente
		RpcClearEnv()
	EndIf
	
Return

Static Function ValidGeral()

	Local lRet 		:= .T.
	Local nTotSaldo := 0

	aObsItem := {}
	cObsMerc := ""


	dbSelectArea("ZM3")
	ZM3->(dbSetOrder(1))	//FILIAL + PED MERC + ITEM PED MERC + PRODUTO + LOCAL
	ZM3->(dbGoTop())
	ZM3->(dbSeek(cPedFil+ZM2->ZM2_PEDMER))
	If Found()

		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))	//FILIAL + PRODUTO
		While !ZM3->(Eof()) .And. AllTrim(ZM3->ZM3_PEDMER) == AllTrim(ZM2->ZM2_PEDMER)

			dbSelectArea("SB1")
			SB1->(dbGoTop())
			SB1->(dbSeek(xFilial("SB1") + AllTrim(ZM3->ZM3_PRODUT)))
			If Found()

				If SB1->B1_MSBLQL == "2"	//Não bloqueado

					//Verifica Saldo
					dbSelectArea("SB2")
					SB2->(dbSetOrder(1))	//FILIAL + PRODUTO + LOCAL
					SB2->(dbGoTop())
					SB2->(dbSeek(xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD))
					If Found()
						//Saldo em estoque
						nSaldo := SB2->B2_QATU - SB2->B2_QEMP

						//Saldo em estoque deve ser maior ou igual ao requisitado
						If nSaldo < ZM3->ZM3_QTDVEN
							GeraLog("Não há saldo suficiente para o produto "+AllTrim(SB1->B1_COD), ZM2->ZM2_PEDMER, 1)
							ObsItem(aObsItem, AllTrim(SB1->B1_COD), "Não há saldo suficiente para o produto;", "SALDO")
						EndIf

						//Verifica Endereço
						If SB1->B1_LOCALIZ == "S"

							ObsItem(aObsItem, AllTrim(SB1->B1_COD), " Produto controla endereço, deve ser informado um endereço. ", "ENDEREÇO")

						EndIf

						//Verifica Lote
						If SB1->B1_RASTRO == "S"

							ObsItem(aObsItem, AllTrim(SB1->B1_COD), " Produto controla lote, deve ser informado um lote. ", "LOTE")

						EndIf

					Else
						GeraLog("Não há registro de saldo para o produto "+AllTrim(SB1->B1_COD) ,ZM2->ZM2_PEDMER, 1)
						ObsItem(aObsItem, AllTrim(SB1->B1_COD), "Não há registro de saldo para o produto;", "SALDO")
					EndIf

				Else
					GeraLog("Produto se encontra bloqueado no sistema: "+AllTrim(SB1->B1_COD), ZM2->ZM2_PEDMER, 1)
					cObsMerc += "Produto se encontra bloqueado no sistema: "+AllTrim(ZM3->ZM3_PRODUT)+";"
					lRet := .F.
				EndIf

			Else
				GeraLog("Produto não encontrado: "+AllTrim(ZM3->ZM3_PRODUT), ZM2->ZM2_PEDMER, 1)
				cObsMerc += "Produto não encontrado: "+AllTrim(ZM3->ZM3_PRODUT)+";"
				lRet := .F.
			EndIf

			dbSelectArea("ZM3")
			ZM3->(dbSkip())
		End
	Else
		GeraLog("Nenhum item encontrado para o pedido!", ZM2->ZM2_PEDMER, 1)
		cObsMerc += "Nenhum item encontrado para o pedido;"
		lRet := .F.
	EndIf


	//VERIFICAÇÃO DE TABELA DE PREÇO
	cTabPreco := ""
	If ! Empty(ZM2->ZM2_TABELA)
		dbSelectArea("DA0")
		DA0->(dbSetOrder(1))
		DA0->(dbGoTop())
		DA0->(dbSeek( xFilial("DA0")+ZM2->ZM2_TABELA ))
		If Found()
			cTabPreco := DA0->DA0_CODTAB
		Else
			GeraLog("Não foi encontrada a tabela de preço "+AllTrim(ZM2->ZM2_TABELA)+" para a Filial: "+cPedFil+"!", ZM2->ZM2_PEDMER, 1)
			cObsMerc +="Não foi encontrada a tabela de preço "+AllTrim(ZM2->ZM2_TABELA)+" para a Filial: "+cPedFil+"!"
			If RecLock("ZM2",.F.)
				ZM2->ZM2_OBS := AllTrim(ZM2->ZM2_OBS) + " Não foi encontrada a tabela de preço "+AllTrim(ZM2->ZM2_TABELA)+" para a Filial: "+cPedFil+";"
				MsUnlock()
			EndIf
		EndIf
	EndIf

	//VERIFICAÇÃO DE CONDIÇÃO DE PAGAMENTO
	If ! Empty(ZM2->ZM2_CONDPA)
		dbSelectArea("SE4")
		SE4->(dbSetOrder(1))
		SE4->(dbGoTop())
		SE4->(dbSeek( xFilial("SE4")+ZM2->ZM2_CONDPA ))
		If ! Found()
			GeraLog("Não foi encontrada condição de pagamento "+AllTrim(ZM2->ZM2_CONDPA)+" para a Filial: "+cPedFil+"!", ZM2->ZM2_PEDMER, 1)
			cObsMerc += "Não foi encontrada condição de pagamento "+AllTrim(ZM2->ZM2_CONDPA)+" para a Filial: "+cPedFil+";"
			lRet := .F.
		EndIf
	EndIf

	//VERIFICAÇÃO DE CLIENTE
	If ! Empty(ZM2->ZM2_CLIENT) .And. ! Empty(ZM2->ZM2_LOJACL)

		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		SA1->(dbGoTop())	//FILIAL + CLIENTE + LOJA
		SA1->(dbSeek(xFilial("SA1") + ZM2->ZM2_CLIENT + ZM2->ZM2_LOJACL))
		If Found()

			If SA1->A1_MSBLQL == "1"
				GeraLog("Cliente Bloqueado: "+AllTrim(ZM2->ZM2_CLIENT)+" Loja: "+AllTrim(ZM2->ZM2_LOJACL), ZM2->ZM2_PEDMER, 1)
				cObsMerc += "Cliente Bloqueado: "+AllTrim(ZM2->ZM2_CLIENT)+" Loja: "+AllTrim(ZM2->ZM2_LOJACL)+";"
				lRet := .F.
			EndIf

			//VERIFICAÇÃO DE LIMITE DE CRÉDITO
			dbSelectArea("SE1")
			SE1->(dbSetOrder(2))	//FILIAL + CLIENTE + LOJA
			SE1->(dbGoTop())
			SE1->(dbSeek(cPedFil + AllTrim(ZM2->ZM2_CLIENT) + AllTrim(ZM2->ZM2_LOJACL)))

			bWhile := {|| !SE1->(Eof()) .And. cPedFil == SE1->E1_FILIAL .And.;
				AllTrim(ZM2->ZM2_CLIENT) == AllTrim(SE1->E1_CLIENTE) .And.;
				AllTrim(ZM2->ZM2_LOJACL) == AllTrim(SE1->E1_LOJA) }
			While ( Eval(bWhile) )
				If SE1->E1_SALDO > 0
					nTotSaldo += SE1->E1_SALDO
				EndIf
				dbSelectArea("SE1")
				SE1->(dbSkip())
			End

			If (nTotSaldo + ZM2->ZM2_VTOT) > SA1->A1_LC

				If !("Limite de crédito do cliente ultrapassado." $ ZM2->ZM2_OBS)
					//Permite gerar o Pedido, mas adiciona aviso caso tenha ultrapassado o limite de crédito
					If RecLock("ZM2",.F.)
						ZM2->ZM2_OBS := AllTrim(ZM2->ZM2_OBS) + "; Limite de crédito do cliente ultrapassado. "
						MsUnlock()
					EndIf
					//MsgAlert("Limite de crédito ultrapassado, cliente: "+AllTrim(ZM2->ZM2_CLIENT)+" Loja: "+AllTrim(ZM2->ZM2_LOJACL))
					GeraLog("Limite de crédito ultrapassado, cliente: "+AllTrim(ZM2->ZM2_CLIENT)+" Loja: "+AllTrim(ZM2->ZM2_LOJACL), ZM2->ZM2_PEDMER, 1)
				EndIf

			EndIf

		Else
			GeraLog("Cliente inexistente: "+AllTrim(ZM2->ZM2_CLIENT)+" Loja: "+AllTrim(ZM2->ZM2_LOJACL), ZM2->ZM2_PEDMER, 1)
			cObsMerc += "Cliente inexistente: "+AllTrim(ZM2->ZM2_CLIENT)+" Loja: "+AllTrim(ZM2->ZM2_LOJACL)+";"
			lRet := .F.
		EndIf
	Else
		GeraLog("Campo cliente e/ou loja vazio!"+AllTrim(ZM2->ZM2_CLIENT)+" Loja: "+AllTrim(ZM2->ZM2_LOJACL), ZM2->ZM2_PEDMER, 1)
		cObsMerc += "Campo cliente e/ou loja vazio!"+AllTrim(ZM2->ZM2_CLIENT)+" Loja: "+AllTrim(ZM2->ZM2_LOJACL)+";"
		lRet := .F.
	EndIf


	//VERIFICAÇÃO DE TRANSPORTADORA
	If ! Empty(ZM2->ZM2_TRANSP)
		dbSelectArea("SA4")
		SA4->(dbSetOrder(1))	//FILIAL + CODIGO
		SA4->(dbGoTop())
		SA4->(dbSeek(xFilial("SA4") + ZM2->ZM2_TRANSP))
		If ! Found()
			GeraLog("Transportadora não cadastrada: "+AllTrim(ZM2->ZM2_TRANSP), ZM2->ZM2_PEDMER, 1)
		EndIf
	EndIf

	//VERIFICAÇÃO DE VENDEDOR
	If ! Empty(ZM2->ZM2_VEND1)
		dbSelectArea("SA3")
		SA3->(dbSetOrder(1))	//FILIAL + CODIGO
		SA3->(dbGoTop())
		SA3->(dbSeek(xFilial("SA3") + ZM2->ZM2_VEND1))
		If ! Found()
			GeraLog("Vendedor não cadastrado: "+AllTrim(ZM2->ZM2_VEND1), ZM2->ZM2_PEDMER, 1)
			cObsMerc += "Vendedor não cadastrado: "+AllTrim(ZM2->ZM2_VEND1)+";"
			lRet := .F.
		EndIf
	Else
		GeraLog("Vendedor não informado!", ZM2->ZM2_PEDMER, 1)
		cObsMerc += "Vendedor não informado;"
		lRet := .F.
	EndIf

	//VERIFICAÇÃO DO CAMPO TIPO DO PEDIDO
	If ! Empty(ZM2->ZM2_TIPVEN)
		If !(AllTrim(ZM2->ZM2_TIPVEN) $ "N|D|C|P|I|B")
			//N-> Pedidos Normais.
			//D-> Pedidos para Devolução de Compras. (Excl. Brasil)
			//C-> Compl. Preços.(Excl. Brasil)
			//P-> Compl. de IPI. (Excl. Brasil)
			//I-> Compl. de ICMS. (Excl. Brasil)
			//B-> Apres. Fornec. qdo material p/Benef.
			GeraLog("O tipo de venda informado no cabeçalho do pedido não é reconhecido no Protheus! Os tipos reconhecidos são N,D,C,P,I e B, "+;
				"foi informado o tipo: " + AllTrim(ZM2->ZM2_TIPVEN), ZM2->ZM2_PEDMER, 1)
			cObsMerc += "O tipo de venda informado não é reconhecido no Protheus;"
			lRet := .F.
		EndIf
	Else
		GeraLog("Não há tipo de venda informado para o pedido!", ZM2->ZM2_PEDMER, 1)
		cObsMerc += "Não há tipo de venda informado para o pedido;"
		lRet := .F.
	EndIf


Return lRet

Static Function ObsItem(aObsItem, cProd, cMsg, cPalavChav)

	Local lFound := .F.
	Local i

	If Len(aObsItem) > 0
		For i := 1 To Len(aObsItem)

			If AllTrim(aObsItem[i,1]) == AllTrim(cProd)
				lFound := .T.

				//encontrou o produto no array já com mensagem
				If At(cPalavChav, Upper(aObsItem[i,2])) == 0	//Não encontrou a mesma mensagem, soma
					aObsItem[i,2] += cMsg
				EndIf

				Exit
			EndIf
		Next

		If !lFound	//Não achou o produto com mensagem
			aAdd(aObsItem, {AllTrim(cProd),cMsg})
		EndIf
	Else	//Nenhum produto possui mensagem
		aAdd(aObsItem, {AllTrim(cProd),cMsg})
	EndIf

Return

Static Function GeraPedido()

	Local aCabec    := {}
	Local aCabec2   := {}
	Local aItens    := {}
	Local cDocMerc  := ""
	Local cObsItem  := ""
	Local cErroExec := ""
	Local aErroExec := {}
	Local i, x

	lMsErroAuto := .F.

	dbSelectArea("ZM2")
	cDocMerc := AllTrim(ZM2->ZM2_PEDMER)

	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	SA1->(dbGoTop())	//FILIAL + CLIENTE + LOJA
	SA1->(dbSeek(xFilial("SA1") + ZM2->ZM2_CLIENT + ZM2->ZM2_LOJACL))

	//MsgAlert("SETA CAMPOS SC5")
	aAdd(aCabec2,{"C5_FILIAL"	,cPedFil			,Nil})
	aAdd(aCabec2,{"C5_TIPO" 	,ZM2->ZM2_TIPVEN	,Nil})
	aAdd(aCabec2,{"C5_CLIENTE"	,ZM2->ZM2_CLIENT	,Nil})
	aAdd(aCabec2,{"C5_LOJACLI"	,ZM2->ZM2_LOJACL	,Nil})
	aAdd(aCabec2,{"C5_LOJAENT"	,ZM2->ZM2_LOJACL	,Nil})
	aAdd(aCabec2,{"C5_CONDPAG"	,ZM2->ZM2_CONDPA	,Nil})
	aAdd(aCabec2,{"C5_EMISSAO" 	,ZM2->ZM2_EMISSA	,Nil})
	aAdd(aCabec2,{"C5_TIPOCLI"	,SA1->A1_TIPO		,Nil})
	aAdd(aCabec2,{"C5_VEND1"  	,ZM2->ZM2_VEND1		,Nil})
	aAdd(aCabec2,{"C5_MENNOTA"	,AllTrim(ZM2->ZM2_MENNOT),Nil})
	aAdd(aCabec2,{"C5_TPFRETE"	,ZM2->ZM2_TPFRET	,Nil})
	aAdd(aCabec2,{"C5_TABELA"	,cTabPreco			,Nil})
	aAdd(aCabec2,{"C5_BANCO"	,ZM2->ZM2_BANCO		,Nil})
	aAdd(aCabec2,{"C5_XPEDMER"	,ZM2->ZM2_PEDMER	,Nil})
	aAdd(aCabec2,{"C5_TRANSP"	,ZM2->ZM2_TRANSP	,Nil})
	//aAdd(aCabec2,{"C5_FECENT"	,ZM2->ZM2_FECENT	,Nil})
	aAdd(aCabec2,{"C5_NATUREZ "	,ZM2->ZM2_NATURE	,Nil})
	aAdd(aCabec2,{"C5_XCARBAN  ",ZM2->ZM2_XCARBA	,Nil})
	aAdd(aCabec2,{"C5_MOEDA    ",ZM2->ZM2_MOEDA	    ,Nil})
	aAdd(aCabec2,{"C5_DESPESA  ",ZM2->ZM2_VDESP	    ,Nil})
	aAdd(aCabec2,{"C5_XNORDEM  ",ZM2->ZM2_PEDCLI    ,Nil})

	dbSelectArea("ZM3")
	ZM3->(dbSetOrder(1))	//FILIAL + PED MERC + PRODUTO + LOCAL
	ZM3->(dbGoTop())
	ZM3->(dbSeek(cPedFil + ZM2->ZM2_PEDMER))
	If Found()
		While !ZM3->(Eof()) .And. AllTrim(ZM3->ZM3_PEDMER) == AllTrim(ZM2->ZM2_PEDMER)

			cObsItem := ""

			For i := 1 To Len(aObsItem)

				If AllTrim(aObsItem[i,1]) == AllTrim(ZM3->ZM3_PRODUT)
					cObsItem := aObsItem[i,2]
				EndIf
			Next
			//MsgAlert("SETA CAMPOS SC6")
			aLinha := {}
			aAdd(aLinha,{"C6_FILIAL"	,cPedFil			,Nil})
			aAdd(aLinha,{"C6_ITEM"		,ZM3->ZM3_ITPMER	,Nil})
			aAdd(aLinha,{"C6_PRODUTO"	,PadR(AllTrim(ZM3->ZM3_PRODUT),TamSX3("C6_PRODUTO")[1]," "),Nil})
			aAdd(aLinha,{"C6_QTDVEN"	,ZM3->ZM3_QTDVEN	,Nil})
			aAdd(aLinha,{"C6_PRCVEN"	,ZM3->ZM3_VLR_LI  	,Nil})
			aAdd(aLinha,{"C6_PRUNIT"	,ZM3->ZM3_VLR_LI  	,Nil}) //Ajuste de erro no valor do boleto::Helton Silva.
			//aAdd(aLinha,{"C6_PRUNIT"	,ZM3->ZM3_VLR_BR 	,Nil})
			aAdd(aLinha,{"C6_VALOR"		,ZM3->ZM3_VALOR		,Nil})
			aAdd(aLinha,{"C6_TES"		,ZM3->ZM3_TES		,Nil})
			aAdd(aLinha,{"C6_LOCAL"		,ZM3->ZM3_LOCAL		,Nil})
			aAdd(aLinha,{"C6_CLI"		,ZM3->ZM3_CLI		,Nil})
			aAdd(aLinha,{"C6_LOJA"		,ZM3->ZM3_LOJA		,Nil})
			aAdd(aLinha,{"C6_COMIS1"	,ZM3->ZM3_COMIS1	,Nil})
			aAdd(aLinha,{"C6_UM"		,Posicione("SB1",1,xFilial("SB1")+ZM3->ZM3_PRODUT,"B1_UM"),Nil})
			aAdd(aLinha,{"C6_ITMER"		,ZM3->ZM3_ITPMER	,Nil})
			aAdd(aLinha,{"C6_XQUALIO"	,ZM3->ZM3_XQUALI	,Nil})
			aAdd(aLinha,{"C6_SUGENTR"   ,ZM2->ZM2_FECENT	,Nil}) //Alessandro Bezerra: 15/08/2022
			aAdd(aLinha,{"C6_XALOCA"    ,"N"                ,Nil})
			aAdd(aLinha,{"C6_PEDCLI"    ,ZM2->ZM2_PEDCLI    ,Nil})
			aAdd(aLinha,{"C6_ENTREG"    ,ZM3->ZM3_SUGENT    ,Nil}) //Helton Silva:: 11/11/21 - Alessandro Bezerra: 15/08/2022

			if ZM3->ZM3_NUMLOT != 'Futuro' .And. ZM3->ZM3_NUMLOT != 'futuro' .And. ZM3->ZM3_NUMLOT != 'FUTURO'
				//aAdd(aLinha,{"C6_LOTECTL"   ,ZM3->ZM3_LOTECT    ,Nil}) n?o popular mais conforme solicitado rogerio
				aAdd(aLinha,{"C6_XNLOT"   ,ZM3->ZM3_NUMLOT    ,Nil})
			endif

			aAdd(aItens, aClone(OrdCampos(aLinha)))

			ZM3->(dbSkip())
		End

	Endif

	cFilBkp := cFilAnt	//Bkp da filial do sistema
	cFilAnt := cPedFil	//Carrega a filial desejada para o pedido, para geração do numero do documento

	dbSelectArea("SM0")
	SM0->(dbSeek(cEmpAnt+cPedFil))    //M0_CODIGO + M0_CODFIL

	cDoc := NextNumero("SC5",1,"C5_NUM",.T.)
	aadd(aCabec2,{"C5_NUM"    ,cDoc            ,Nil})
	aCabec := aClone(OrdCampos(aCabec2))

	ConfirmSX8()

	if !(mExist(ZM2->ZM2_PEDMER))
		//MsgAlert("EXECUTA ROTINA AUTOMATICA")
		MSExecAuto({|x,y,z| Mata410(x,y,z)},aCabec,aItens,3)
	endIf

	//MsgAlert("RETORNA ROTINA AUTOMATICA")
	If !lMsErroAuto		//Gravou

		//Posiciona novamente no registro do pedido para gravar os dados
		ZM2->(dbSetOrder(1)) //FILIAL + PED MERC + CLIENTE + LOJA
		ZM2->(dbGoTop())
		ZM2->(dbSeek(cPedFil + cDocMerc))
		If RecLock("ZM2",.F.)
			ZM2->ZM2_STATUS := "PRO"	// PRO - Registro processado pelo Protheus e pedido Inserido com sucesso
			ZM2->ZM2_NUM 	:= SC5->C5_NUM//cDoc //Modificado para informar o numero do pedido gerado.
			MsUnlock()
		EndIf

		GeraLog("Usuário "+AllTrim(cUserName)+" incluiu pedido: "+AllTrim(cDoc)+" no ambiente: "+Upper(GetEnvServer())+" na filial: "+cFilAnt, cDocMerc, 1)

	Else

		cErroExec := ""
		If IsInCallStack("SIGAIXB")
			aErroExec := StrTokArr( MostraErro(), Chr(13) + Chr(10))

			For i := 1 To Len(aErroExec)
				If At("INVALIDO", Upper(aErroExec[i])) > 0
					cErroExec := AllTrim(aErroExec[i])
				EndIf
			Next
			For i := 1 To Len(aErroExec)
				If At("HELP: OBRIGAT", Upper(aErroExec[i])) > 0
					For x := i+1 To 4
						cErroExec += AllTrim(aErroExec[x]) + " "
					Next
				EndIf
			Next
			For i := 1 To Len(aErroExec)
				If At("HELP: A410VZ", Upper(aErroExec[i])) > 0
					For x := i+1 To 4
						cErroExec += AllTrim(aErroExec[x]) + " "
					Next
				EndIf
			Next
		EndIf

		dbSelectArea("ZM2")
		If RecLock("ZM2",.F.)
			ZM2->ZM2_STATUS := "ERR"	// ERR - Status utilizado quando o registro for processado pelo Protheus e ocorreu erro durante o processamento
			ZM2->ZM2_ERRO 	:= "Pedido não gerado devido ao seguinte erro: " + cErroExec
			MsUnlock()
		EndIf

		GeraLog("Pedido não gerado devido ao seguinte erro: " + cErroExec, ZM2->ZM2_PEDMER, 1)

	EndIf

	cFilAnt := cFilBkp	//Retorna filial do sistema

Return

/** GERA CLIENTE **/
Static Function GeraCli(aDados, nOpc, cEstado)
	
	Local i, x
	lMSErroAuto := .F.
	
	dbSelectArea("ZM1")
	cCodMerc := ZM1->ZM1_CODMER
	cFiliall := ZM1->ZM1_FILIAL
	
	dbSelectArea("SA1")

	If Alltrim(cEstado) == "EX"
		conout("Cliente EX")
		aAI0Auto := {}
		//Adiciona o complemento de produto para salvar na AI0
		aAdd(aAI0Auto,{"AI0_XCODME"  , cCodMerc  ,Nil}) 
		MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aDados, nOpc, aAI0Auto)
	Else
		conout("Cliente BR")
		//MsgAlert("EXECUTA ROTINA AUTOMATICA") 
		MSExecAuto({|x,y| Mata030(x,y)},aDados,nOpc) //3- Inclusão, 4- Alteração
		//MsgAlert("VOLTA DA ROTINA AUTOMATICA") 
	Endif	

	If !lMsErroAuto		//Gravou
		
		//Verifica o codigo informado no array
		If Alltrim(cEstado) == "EX"
			cCli  := aDados[Ascan( aDados, { |x| Alltrim(x[ 1 ]) == "A1_COD"} ) ,2]
			cLoja := aDados[Ascan( aDados, { |x| Alltrim(x[ 1 ]) == "A1_LOJA"} ),2]
		Else	
			cCli  := SA1->A1_COD
			cLoja := SA1->A1_LOJA
		Endif	

		DbSelectArea("ZB8")
		ZB8->(DbSetOrder(1))
		if !dbSeek(Xfilial("ZB8")+SA1->A1_COD+SA1->A1_LOJA)
			Reclock("ZB8",.T.)
			ZB8->ZB8_FILIAL := "020204"
			ZB8->ZB8_CODCLI := SA1->A1_COD
			ZB8->ZB8_LOJCLI := SA1->A1_LOJA
			ZB8->ZB8_COND   := SA1->A1_COND
			ZB8->ZB8_DATA 	:= dDataBase
			ZB8->ZB8_USUARI := '000000'
			ZB8->(MSUNLOCK())

			Reclock("ZB8",.T.)
			ZB8->ZB8_FILIAL := "020201"
			ZB8->ZB8_CODCLI := 	SA1->A1_COD
			ZB8->ZB8_LOJCLI := 	SA1->A1_LOJA
			ZB8->ZB8_COND   := SA1->A1_COND
			ZB8->ZB8_DATA 	:=  dDataBase
			ZB8->ZB8_USUARI := '000000'
			ZB8->(MSUNLOCK())

			Reclock("ZB8",.T.)
			ZB8->ZB8_FILIAL := "020203"
			ZB8->ZB8_CODCLI := 	SA1->A1_COD
			ZB8->ZB8_LOJCLI := 	SA1->A1_LOJA
			ZB8->ZB8_COND   := SA1->A1_COND
			ZB8->ZB8_DATA 	:=  dDataBase
			ZB8->ZB8_USUARI := '000000'
			ZB8->(MSUNLOCK())

			Reclock("ZB8",.T.)
			ZB8->ZB8_FILIAL := "020103"
			ZB8->ZB8_CODCLI := 	SA1->A1_COD
			ZB8->ZB8_LOJCLI := 	SA1->A1_LOJA
			ZB8->ZB8_COND   :=  SA1->A1_COND
			ZB8->ZB8_DATA 	:=  dDataBase
			ZB8->ZB8_USUARI := '000000'
			ZB8->(MSUNLOCK())

			Reclock("ZB8",.T.)
			ZB8->ZB8_FILIAL := "020202"
			ZB8->ZB8_CODCLI := 	SA1->A1_COD
			ZB8->ZB8_LOJCLI := 	SA1->A1_LOJA
			ZB8->ZB8_COND   := SA1->A1_COND
			ZB8->ZB8_DATA 	:=  dDataBase
			ZB8->ZB8_USUARI := '000000'
			ZB8->(MSUNLOCK())
		Endif
		
		If RecLock("ZM1",.F.)
			ZM1->ZM1_STATUS := "PRO"	// PRO - Registro processado pelo Protheus e pedido Inserido com sucesso
			ZM1->ZM1_COD 	:= cCli
			ZM1->ZM1_LOJA	:= cLoja
			MsUnlock()
		EndIf
		
		//LOG
		GeraLog("Usuário "+AllTrim(cUserName)+" incluiu cliente: "+AllTrim(cCli)+" loja: "+AllTrim(cLoja)+" no ambiente: "+Upper(GetEnvServer())+" na filial: "+cFilAnt, cCodMerc, 2)
		
	Else
		cErroExec := ""
		
		If IsInCallStack("SIGAIXB")	//Menu
			aErroExec := StrTokArr( MostraErro(), Chr(13) + Chr(10))

			For i := 1 To Len(aErroExec)
				If At("INVALIDO", Upper(aErroExec[i])) > 0	//Campo inválido
					cErroExec := AllTrim(aErroExec[i])
				EndIf
			Next
			For i := 1 To Len(aErroExec)
				If At("HELP: OBRIGAT", Upper(aErroExec[i])) > 0	//Campo obrigatório
					For x := i+1 To 4
						cErroExec += AllTrim(aErroExec[i]) + " "
					Next
					Exit
				EndIf
			Next
			For i := 1 To Len(aErroExec)
				If At("HELP: A410VZ", Upper(aErroExec[i])) > 0	//Campo obrigatório
					For x := i+1 To 4
						cErroExec += AllTrim(aErroExec[i]) + " "
					Next
					Exit
				EndIf
			Next
		Else	//Automatico
			aErroExec := StrTokArr( MemoRead(NomeAutoLog()), Chr(13) + Chr(10))
			
			For i := 2 To Len(aErroExec)
				If At("TABELA", Upper(aErroExec[i])) > 0
					Exit
				EndIf
				cErroExec += AllTrim(aErroExec[i]) + " "
			Next
			
		EndIf
		
		dbSelectArea("ZM1")
		If RecLock("ZM1",.F.)
			ZM1->ZM1_STATUS := "ERR"	// ERR - Status utilizado quando o registro for processado pelo Protheus e ocorreu erro durante o processamento
			ZM1->ZM1_ERRO 	:= "Cliente não gerado devido ao seguinte erro: " + cErroExec
			ZM1->ZM1_ERRO 	:= "Inconformidade: " + cErroExec
			MsUnlock()
		EndIf
		
		Conout("Cliente  não gerado devido ao seguinte erro: " + cErroExec, ZM1->ZM1_CODMER, 2)

		GeraLog("Cliente  não gerado devido ao seguinte erro: " + cErroExec, ZM1->ZM1_CODMER, 2)
		
	EndIf
	
Return


Static Function GeraLog(cConteudo, cCodigo, nTipo)

	Local cDir		:= "C:\Temp\Mercanet\"
	Local cArq		:= "LogErros.txt"
	Local nHandle

	If !IsInCallStack("SIGAIXB")
		cDir		:= "D:\Mercanet\Temp"
	EndIF

	If !ExistDir(cDir)
		MakeDir(cDir)
	EndIf

	If ! File(cDir + cArq)
		nHandle := FCreate(cDir + cArq)

		If nTipo == 1
			FWrite(nHandle, "[ "+ DToC(dDataBase) + " | " + Time() + " ] Num. Pedido: " + AllTrim(cCodigo) + " - " + cConteudo + CRLF)
		Else
			FWrite(nHandle, "[ "+ DToC(dDataBase) + " | " + Time() + " ] Cod. Cliente: " + AllTrim(cCodigo) + " - " + cConteudo + CRLF)
		EndIf
		FClose(nHandle)
	Else
		nHandle := FOpen(cDir + cArq , FO_READWRITE + FO_DENYWRITE )
		FSeek(nHandle, 0, FS_END)         	//Posiciona no fim do arquivo

		If nTipo == 1
			FWrite(nHandle, "[ "+ DToC(dDataBase) + " | " + Time() + " ] Num. Pedido: " + AllTrim(cCodigo) + " - " + cConteudo + CRLF) 	//Insere texto no arquivo
		Else
			FWrite(nHandle, "[ "+ DToC(dDataBase) + " | " + Time() + " ] Cod. Cliente: " + AllTrim(cCodigo) + " - " + cConteudo + CRLF)
		EndIf
		FClose(nHandle)                   	//Fecha arquivo
	EndIf


Return

Static Function OrdCampos(aOrdenar)

	Local _aMat     := {}
	Local _aMatNova := {}
	Local _nLinha   := 0
	Local _sOrdem   := ""
	Local _aAreaSX3 := SX3->(GetArea())

	// Monta uma matriz equivalente, com a ordem dos campos no SX3
	SX3->(dbSetOrder(2))
	For _nLinha := 1 To Len(aOrdenar)

		If SX3->(dbSeek(aOrdenar[_nLinha, 1], .F.))
			_sOrdem = SX3->X3_ORDEM
		Else
			_sOrdem = IIf(_nLinha == 1, "  ", "ZZ")
		EndIf
		aAdd(_aMat, {aOrdenar[_nLinha,1], aOrdenar[_nLinha,2], aOrdenar[_nLinha,3], _sOrdem})
	next

	_aMat := aSort(_aMat,,, {|_x, _y| _x[4] < _y[4]})

	For _nLinha = 1 To Len(_aMat)
		aAdd(_aMatNova, {_aMat[_nLinha,1], _aMat[_nLinha,2], _aMat[_nLinha,3]})
	Next

	RestArea(_aAreaSX3)

Return _aMatNova

Static Function mExist(_cId)

	Local _cQuery 	:= ""
	Local _lRet 	:= .F.

	_cQuery := " select *  from "+RetSQLNAME("SC5")
	_cQuery += " where D_E_L_E_T_ <> '*' "
	_cQuery += " and C5_XPEDMER = '"+alltrim(_cId)+"' "

	TcQuery _cQuery New Alias "TMP"

	DBSELECTAREA("TMP")
	TMP->(DBGOTOP())

	IF !TMP->(EOF())
		ZM2->(dbSetOrder(1)) //FILIAL + PED MERC + CLIENTE + LOJA
		ZM2->(dbGoTop())
		ZM2->(dbSeek(TMP->C5_FILIAL +alltrim(_cId) ))
		If RecLock("ZM2",.F.)
			ZM2->ZM2_STATUS := "PRO"	// PRO - Registro processado pelo Protheus e pedido Inserido com sucesso
			ZM2->ZM2_NUM 	:= TMP->C5_NUM
			MsUnlock()
		EndIf
		lRet := .T.
	endif
		TMP->(dbCloseArea())
Return _lRet

Static Function  ValidAI0(cCodMer)
Local aArea    := GetArea()
Local aCliente := {}
Local cQuery   := "SELECT AI0_CODCLI, AI0_LOJA FROM "+RetSqlName("AI0")+" WHERE AI0_XCODME = '"+cCodMer+"' AND D_E_L_E_T_ <> '*' ORDER BY AI0_CODCLI, AI0_LOJA"

MpSysOpenQuery(cQuery, "TMP")

AADD(aCliente,{"",""})

While TMP->(!Eof())
	aCliente[1,1] := TMP->AI0_CODCLI
	aCliente[1,2] := TMP->AI0_LOJA
	TMP->(DbSkip())
EndDo	

RestArea(aArea)

Return aCliente
