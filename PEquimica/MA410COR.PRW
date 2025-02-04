#INCLUDE 'TOTVS.CH'

User Function MA410COR()
	Local aCores := {} // PARAMIXB traz a estrutura do array padrão

	aAdd(aCores, {"U_M4410C01() == 'E' .AND. U_M4410C02() =='S'", "BR_PRETO", "Bloqueio de Estoque"})
	aAdd(aCores, {"U_M4410C01() == 'F' .AND. U_M4410C02() =='S'", "BR_BRANCO", "Bloqueio de Credito"})
	aAdd(aCores, {"U_M4410C01() == 'A' .AND. U_M4410C02() =='S'", "BR_VIOLETA", "Bloqueio de Credito/Estoque"})
	aAdd(aCores, {"Empty(C5_LIBEROK) .And. Empty(C5_NOTA) .And. Empty(C5_BLQ)", "ENABLE", "Pedido em Aberto"})
	aAdd(aCores, {"!Empty(C5_NOTA) .Or. C5_LIBEROK=='E' .And. Empty(C5_BLQ)", "DISABLE", "Pedido Encerrado"})
	aAdd(aCores, {"!Empty(C5_LIBEROK) .And. Empty(C5_NOTA) .And. Empty(C5_BLQ)", "BR_AMARELO", "Pedido Liberado"})
	aAdd(aCores, {"C5_BLQ == '1'", "BR_AZUL"})
	aAdd(aCores, {"C5_BLQ == '2'", "BR_LARANJA"})

Return aCores

User Function M4410C01()
	Local cRet := 'X'
	Local lEst := .F.
	Local lFin := .F.
	Local cAlias := GetNextAlias()
	Local aArea := GetArea()
	Local aAreaSC5 := SC5->(GetArea())
	Local aAreaSC9 := SC9->(GetArea())

	BEGINSQL ALIAS cAlias
        SELECT
            SC9.*
        FROM %Table:SC9% AS SC9
        WHERE
            SC9.%NotDel%
			AND SC9.C9_FILIAL = %xFilial:SC9%
            AND SC9.C9_PEDIDO = %exp:SC5->C5_NUM%
	ENDSQL

	While !(cAlias)->(Eof())

		If Alltrim((cAlias)->C9_BLEST) != ''
			lEst := .T.
		EndIf

		If Alltrim((cAlias)->C9_BLCRED) != ''
			lFin := .T.
		EndIf
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())


	If lEst .AND. lFin
		cRet := 'A'
	EndIf

	If lEst .AND. !lFin
		cRet := 'E'
	EndIf

	If !lEst .AND. lFin
		cRet := 'F'
	EndIf

	SC9->(RestArea(aAreaSC9))
	SC5->(RestArea(aAreaSC5))
	RestArea(aArea)
Return cRet

User Function M4410C02()
	Local cAlias := GetNextAlias()
	Local aArea := GetArea()
	Local aAreaSC5 := SC5->(GetArea())
	Local aAreaSC9 := SC9->(GetArea())
	Local cSobrepoe := 'N'

	BEGINSQL ALIAS cAlias
        SELECT
            SC5.*
        FROM %Table:SC5% AS SC5
        WHERE
            SC5.%NotDel%
            AND SC5.C5_NUM = %exp:SC5->C5_NUM%
	ENDSQL

	While !(cAlias)->(Eof())
		
		//Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ) //Pedido em Aberto
		If Empty((cAlias)->C5_LIBEROK) .AND. Empty((cAlias)->C5_NOTA) .AND. Empty((cAlias)->C5_BLQ)
			cSobrepoe := 'N'
			Exit
		EndIf
		
		//!Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ) //Pedido Encerrado
		If !Empty((cAlias)->C5_NOTA) .OR. (cAlias)->C5_LIBEROK == 'E'.AND. Empty((cAlias)->C5_BLQ)
			cSobrepoe := 'N'
			Exit
		EndIf
		
		//!Empty(C5_LIBEROK).And.Empty(C5_NOTA).And. Empty(C5_BLQ) //Pedido Liberado
		If !Empty((cAlias)->C5_LIBEROK) .AND. Empty((cAlias)->C5_NOTA) .AND. Empty((cAlias)->C5_BLQ)
			cSobrepoe := 'S'
			Exit
		EndIf

		//C5_BLQ == '1' //
		If (cAlias)->C5_BLQ == '1'
			cSobrepoe := 'N'
			Exit
		EndIf

		//C5_BLQ == '2'
		If (cAlias)->C5_BLQ == '2'
			cSobrepoe := 'N'
			Exit
		EndIf
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

	SC9->(RestArea(aAreaSC9))
	SC5->(RestArea(aAreaSC5))
	RestArea(aArea)
Return cSobrepoe
