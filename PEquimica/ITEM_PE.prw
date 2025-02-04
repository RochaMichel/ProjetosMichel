#Include "Protheus.ch"
#Include "rwmake.ch"
#Include "tbiconn.ch"
/*/{Protheus.doc} ITEM
Exemplo de Ponto de Entrada em MVC 
@author Michel Rocha
@since 24/10/2024
@version 1.0 
@type function 
/*/

User Function ITEM()
	Local aParam := PARAMIXB
	Local xRet := .T.
	Local oObj := Nil
	Local cIdPonto := ""
	Local cIdModel := ""
	Local nOper := 0
	Local cCampo := ""
	Local cTipo := ""
	Local lEnd
	Local cAliasSD1 := GetNextAlias()
	Local cAliasSD2 := GetNextAlias()
	Local cAliasSD3 := GetNextAlias()
	Private lRet := .T.
	//Se tiver parâmetros
	If aParam != Nil
		ConOut("> "+aParam[2])

		//Pega informações dos parâmetros
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		//Commit das operações (após a gravação)
		If cIdPonto == "MODELCOMMITNTTS"
			nOper := oObj:nOperation

			//Mostrando mensagens no fim da operação
			If nOper == 3
				If !Empty(SB1->B1_XCODORG)

					cCodOrig := padr(SB1->B1_XCODORG,tamsx3('B1_COD')[1])
					cGrupo := SB1->B1_GRUPO
					cCodNew  := SB1->B1_COD
					DbselectArea("SB1")
					SB1->(DbSetOrder(1))
					SB1->(DbSeek(xFilial('SB1')+cCodOrig))

					dbSelectArea("SB2")
					Sb2->(DbSetOrder(1))
					SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD))
					nSaldo := SaldoSb2()
					// alteração SD1
					BeginSql Alias cAliasSD1
			        SELECT D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
			        FROM %Table:SD1% SD1
			        WHERE D1_COD = %Exp:cCodOrig%
                    AND D1_LOCAL = %Exp:SB1->B1_LOCPAD%
					AND SD1.%NotDel%
					EndSql

					DbselectArea('SD1')
					SD1->(DbSetOrder(1))
					While (cAliasSD1)->(!EOF())
						if SD1->(DbSeek((cAliasSD1)->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM)))
							RecLock('SD1',.F.)
							SD1->D1_GRUPO := cGrupo
							SD1->(MsUnlock())
						EndIf
						(cAliasSD1)->(dbSkip())
					End
					// alteração SD2
					BeginSql Alias cAliasSD2
			        SELECT D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_COD,D2_ITEM
			        FROM %Table:SD2% SD2 
			        WHERE D2_COD = %Exp:cCodOrig%
                    AND D2_LOCAL = %Exp:SB1->B1_LOCPAD%
					AND SD2.%NotDel%
					EndSql

					DbselectArea('SD2')
					SD2->(DbSetOrder(3))
					While (cAliasSD2)->(!EOF())
						If SD2->(DbSeek((cAliasSD2)->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM)))
							RecLock('SD2',.F.)
							SD2->D2_GRUPO := cGrupo
							SD2->(MsUnlock())
						EndIF
						(cAliasSD2)->(dbSkip())
					End
					// alteração SD3
					BeginSql Alias cAliasSD3
			        SELECT D3_FILIAL,D3_DOC,D3_COD
			        FROM %Table:SD3% SD3 
			        WHERE D3_COD = %Exp:cCodOrig%
                    AND D3_LOCAL = %Exp:SB1->B1_LOCPAD%
					AND SD3.%NotDel%
					EndSql
					DbselectArea('SD3')
					SD3->(DbSetOrder(2))
					While (cAliasSD3)->(!EOF())
						If SD3->(DbSeek((cAliasSD3)->(D3_FILIAL+D3_DOC+D3_COD)))
							RecLock('SD3',.F.)
							SD3->D3_GRUPO := cGrupo
							SD3->(MsUnlock())
						EndIf
						(cAliasSD3)->(dbSkip())
					End
					if nSaldo > 0
						lRet := MyMata261(cCodOrig,cCodNew,nSaldo)
					EndIf
					If lRet
						DbselectArea('SB1')
						SB1->(DbSetOrder(1))
						If SB1->(DbSeek(xFilial("SB1")+PadR(cCodOrig, tamsx3('D3_COD') [1])))
							RecLock('SB1',.F.)
							SB1->B1_MSBLQL := "1"
							lRet := .T.
							FWAlertInfo('Produto: '+cCodOrig+' foi desativado com sucesso! ', 'Informativo')
						EndIf
					EndIf
					(cAliasSD1)->(DbCloseArea())
					(cAliasSD2)->(DbCloseArea())
					(cAliasSD3)->(DbCloseArea())
					SB1->(DbCloseArea())
					SD1->(DbCloseArea())
					SD2->(DbCloseArea())
					SD3->(DbCloseArea())
					SB2->(DbCloseArea())

				EndIf
				//Alert("Fim da Inclusão")W
			EndIf
		EndIf
	EndIf
Return xRet


Static Function MyMata261(cCodOrig,cCodNew,nQuant)
	Local aAuto := {}
	Local aItem := {}
	Local aLinha := {}
	//Local alista := {cCodOrig,cCodNew} //Produto Utilizado
	Local nX

	Local nOpcAuto := 3

	Private lMsErroAuto := .F.

//Cabecalho a Incluir
	aadd(aAuto,{GetSxeNum("SD3","D3_DOC"),dDataBase}) //Cabecalho

//Itens a Incluir 
	aItem := {}
	aLinha := {}
//Origem 
	DbselectArea('SB1')
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+PadR(cCodOrig, tamsx3('D3_COD') [1])))
		aadd(aLinha,{"ITEM",'00'+cvaltochar(nX),Nil})
		aadd(aLinha,{"D3_COD", SB1->B1_COD, Nil}) //Cod Produto origem
		aadd(aLinha,{"D3_DESCRI", SB1->B1_DESC, Nil}) //descr produto origem
		aadd(aLinha,{"D3_UM", SB1->B1_UM, Nil}) //unidade medida origem
		aadd(aLinha,{"D3_LOCAL", SB1->B1_LOCPAD, Nil}) //armazem origem
		aadd(aLinha,{"D3_LOCALIZ", PadR("ENDER01", tamsx3('D3_LOCALIZ') [1]),Nil}) //Informar endereço origem
	EndIf
//Destino 
	If SB1->(DbSeek(xFilial("SB1")+PadR(cCodNew, tamsx3('D3_COD') [1])))
		aadd(aLinha,{"D3_COD", SB1->B1_COD, Nil}) //cod produto destino
		aadd(aLinha,{"D3_DESCRI", SB1->B1_DESC, Nil}) //descr produto destino
		aadd(aLinha,{"D3_UM", SB1->B1_UM, Nil}) //unidade medida destino
		aadd(aLinha,{"D3_LOCAL", SB1->B1_LOCPAD, Nil}) //armazem destino
		aadd(aLinha,{"D3_LOCALIZ", PadR("ENDER02", tamsx3('D3_LOCALIZ') [1]),Nil}) //Informar endereço destino
	EndIf
	aadd(aLinha,{"D3_NUMSERI", "", Nil}) //Numero serie
	aadd(aLinha,{"D3_LOTECTL", "", Nil}) //Lote Origem
	aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote origem
	aadd(aLinha,{"D3_DTVALID", '', Nil}) //data validade
	aadd(aLinha,{"D3_POTENCI", 0, Nil}) // Potencia
	aadd(aLinha,{"D3_QUANT"  , nQuant, Nil}) //Quantidade
	aadd(aLinha,{"D3_QTSEGUM", 0, Nil}) //Seg unidade medida
	aadd(aLinha,{"D3_ESTORNO", "", Nil}) //Estorno
	aadd(aLinha,{"D3_NUMSEQ", "", Nil}) // Numero sequencia D3_NUMSEQ

	aadd(aLinha,{"D3_LOTECTL", "", Nil}) //Lote destino
	aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote destino
	aadd(aLinha,{"D3_DTVALID", '', Nil}) //validade lote destino
	aadd(aLinha,{"D3_ITEMGRD", "", Nil}) //Item Grade

	aadd(aLinha,{"D3_CODLAN", "", Nil}) //cat83 prod origem
	aadd(aLinha,{"D3_CODLAN", "", Nil}) //cat83 prod destino

	aAdd(aAuto,aLinha)

	MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)

	if lMsErroAuto
		lRet := .F.
		MostraErro()
	EndIf

Return lRet
