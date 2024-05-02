/* ####################################################################### *\
|| #           PONTO DE ENTRADA UTILIZADO PELO IMPORTADOR GATI           # ||
|| #                                                                     # ||
|| #       FORÇA A CONDIÇÃO DE PAGAMENTO INFORMADA NO IMPORTADOR,        # ||
|| #     PARA NÃO SER SUBSTITUÍDA PELA INFORMADA NO PEDIDO DE COMPRA     # ||
\* ####################################################################### */

User Function MT100TOK()

Local lRet     := .T.
Local aArea	   := GetArea()
Local _cChvnf  := ""
Local _cStatus := ""
Local _cCNPJ   := ""
Local cItAlert := ""
Local nCount   := 0
Local cNat     := ""
Local cProduto := ""
Local nQuebra  := chr(13) + Chr(10)

Local nPosCod  := aScan( aHeader, { |x| Alltrim(x[2])=="D1_COD"} )
Local nPosIss  := aScan( aHeader, { |x| Alltrim(x[2])=="D1_CODISS"} )
Local nPosInss := aScan( aHeader, { |x| Alltrim(x[2])=="D1_BASEINS"})
Local nPosPis  := aScan( aHeader, { |x| Alltrim(x[2])=="D1_BASEPIS"})
Local nPosCsl  := aScan( aHeader, { |x| Alltrim(x[2])=="D1_BASECSL"})
Local nPosCof  := aScan( aHeader, { |x| Alltrim(x[2])=="D1_BASECOF"})
Local nPosIrr  := aScan( aHeader, { |x| Alltrim(x[2])=="D1_BASEIRR"})

Local cCodProd 
Local cCodIss  
Local nInss    
Local cPis     
Local cCsl     
Local cCof     
Local cIrr     

/*
    22/11/2023 --- Cod.ERP - Carolina Tavares

    1- ROTINA DOCUMENTO DE ENTRADA.
    QUANDO NA ABA TIVER VALORES DOS SEGUINTES IMPOSTOS PIS RETENÇÃO (D1_BASEPIS),COFINS RETENÇÃO (D1_BASECOF),
    CSLL RETENÇÃO (D1_BASECSL), IRRF (D1_BASEIRR), NÃO PERMITIR INCLUIR NF OU CLASSIFICAR SEM FAZER O SEGUINTE CAMINHO:
    OUTRAS AÇOES - NAT. RENDIMENTO, POR ITEM. (DHR_NATREN)

    D1_BASEPIS, D1_BASECSL, D1_BASECOF, D1_BASEIRR

    2- SE TIVER INSS
    Se houver registro na tabela CDN com o campo CDN_CODLST
    para o produto + cod.serviço informado em
    B1_CODISS
*/

//Validacao 1
//If !EMPTY( cPis ) .AND. !EMPTY( cCsl ) .AND. !EMPTY( cCof ) .AND. !EMPTY( cIrr ) //se esses valores estiverem preenchidos
DbSelectArea("ZNR")
ZNR->(DbSetOrder(2))
DbSelectArea("CDN")
CDN->(DbSetOrder(1))
For nCount := 1 to len(aCols)

	cCodProd := aCols[nCount,nPosCod]
	cCodIss  := aCols[nCount,nPosIss]
	nInss    := aCols[nCount,nPosInss]
	cPis     := aCols[nCount,nPosPis]
	cCsl     := aCols[nCount,nPosCsl]
	cCof     := aCols[nCount,nPosCof]
	cIrr     := aCols[nCount,nPosIrr]


	If ( !EMPTY(cPis) .AND. !EMPTY(cCsl) .AND. !EMPTY(cCof) ) .Or. !EMPTY(cIrr) .Or. ( !EMPTY(cPis) .AND. !EMPTY(cCsl) .AND. !EMPTY(cCof) .AND. !EMPTY(cIrr) )

		cProduto := aCols[nCount][aScan( aHeader, { |x| Alltrim(x[2])=="D1_COD"})]

		If Len(aColsDHR) >= nCount
			cNat 	 := aColsDHR[nCount][2][1][1]

			If Empty(aColsDHR[nCount][2][1][1]) //natureza de rendimento
				//MSGALERT( 'Informe a natureza de rendimento para o item NF ' + aColsDHR[nCount][1], 'Natureza de Rendimento' )
				//Return .F.
				cItAlert += 'Item : '+aColsDHR[nCount][1]+nQuebra
			EndIf
		EndIf

		If !Empty(cNat)
			BeginSQL Alias 'cQuery'
			Select * From %Table:ZNR%
			WHERE ZNR_FORNEC = %Exp:CFORANTNFE% 
			AND ZNR_LOJA = %Exp:CLOJANTNFE%
			AND ZNR_PROD = %Exp:cProduto%
			AND ZNR_NATURE = %Exp:cNat%
			EndSql
			// Se a natureza de rendimento não estiver cadastrada, salva na tabela
			If cQuery->(EOF())
				ZNR->(RecLock("ZNR",.T.))
				ZNR->ZNR_FILIAL := xFilial("ZNR")
				ZNR->ZNR_FORNEC := CFORANTNFE
				ZNR->ZNR_LOJA   := CLOJANTNFE
				ZNR->ZNR_NOME   := AllTrim(Posicione("SA2",1,xFilial("SA2")+CFORANTNFE+CLOJANTNFE,"A2_NOME"))
				ZNR->ZNR_PROD   := cProduto
				ZNR->ZNR_DESC   := AllTrim(aCols[nCount][aScan( aHeader, { |x| Alltrim(x[2])=="D1_DESCRI"})])
				ZNR->ZNR_NATURE := cNat
				ZNR->(MsUnLock())
			EndIf
			cQuery->(DbCloseArea())
		EndIf
	EndIf


//Validacao 2

	If nInss <> 0  //Se houver inss
		IF CDN->(DbSeek(FWxFilial("CDN") + cCodIss + cCodProd ))
			If !EMPTY(CDN->CDN_CODLST)
				lRet := .T.
			ENDIF
		Else
			MSGALERT( "Código de serviço inválido para esse produto: "+ cCodProd, "Código de Serviço" )
			return .F.
		ENDIF
	ENDIF
Next nCount

If Posicione('SA2',1,xFilial('SA2')+CFORANTNFE+CLOJANTNFE,'A2_TIPO') <> 'F'
	If !Empty(cItAlert)
		Help(" ",1,"ATENÇÃO!",,"Natureza de rendimento não informada nos Itens: "+nQuebra+cItAlert,3,1,,,,,,{"Informe as naturezas nos itens apontados para finalizar o processo com sucesso."})
		Return .F.
	EndIf
EndIf
RestArea(aArea)
//Fim

// Irá fazer as validações abaixo quando não for chamado através do Importador ConexãoNfe ou Quando for pelo ConexãoNfe e
// esteja na tela do Documento de Entrada
If !FwIsInCallStack('U_GATI001') .Or. IIf(Type('l103Auto') == 'U',.T.,!l103Auto)

	If lRet .And. !Empty(M->F1_CHVNFE)
		_cChvnf  := Posicione("SF1",RetOrdem( "SF1" , "F1_FILIAL+F1_CHVNFE" ),xFilial("SF1")+M->F1_CHVNFE,"F1_CHVNFE")
		_cStatus := Posicione("SF1",RetOrdem( "SF1" , "F1_FILIAL+F1_CHVNFE" ),xFilial("SF1")+M->F1_CHVNFE,"F1_STATUS")

		If _cChvnf == M->F1_CHVNFE .And. !Empty(_cStatus)
			lRet := .F.
			MSGALERT("A NF com chave "+_cChvnf+" já foi incluída." ,'')
		EndIf

		If Len(Alltrim(M->F1_CHVNFE)) < 44
			lRet := .F.
			MSGALERT("Tamanho da chave "+Alltrim(M->F1_CHVNFE)+" inválido. Verifique se a chave está correta." ,'')
		EndIf

	EndIf

	If lRet .And. M->cFormul <> "S" .And. Alltrim(M->cEspecie)=="SPED" .And. !Empty(M->F1_CHVNFE)

		If M->cTipo $ "D#B"
			_cCNPJ := Posicione("SA1",1,xFilial("SA1") + M->cA100for + M->cLoja, "A1_CGC" )
		Else
			_cCNPJ := Posicione("SA2",1,xFilial("SA2") + M->cA100for + M->cLoja, "A2_CGC" )
		EndIf

		If SUBS(M->F1_CHVNFE,3,4) <> SUBS(DTOS(M->Ddemissao),3,4)
			lRet := .F.
			MSGALERT("Verfiique a data de emissão. Não está de acordo com a chave da NF." ,'')
		EndIf

		If SUBS(M->F1_CHVNFE,7,14) <> _cCNPJ .And. !( SUBS(M->F1_CHVNFE,7,14) $ Formula("154") )
			lRet := .F.
			MSGALERT("CNPJ do emitente não bate com a chave. Confira os dados ou solicite ao Fiscal a exceção na Formula 154. Incluir CNPJ da chave na formula 154." ,'')
		EndIf

		If SUBS(M->F1_CHVNFE,23,3) <> M->cSerie
			lRet := .F.
			MSGALERT("Corrija a série!" ,'')
		EndIf

		If SUBS(M->F1_CHVNFE,26,9) <> M->cNfiscal
			lRet := .F.
			MSGALERT("Número da NF diverge da chave." ,'')
		EndIf
	EndIf

EndIf

If lRet
	// Ponto de chamada ConexãoNF-e sempre como última instrução.
	lRet:= U_GTPE005()
EndIf

RestArea(aArea)

Return lRet
