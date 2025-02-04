#Include "TOTVS.CH"

User Function M410PVNF()
	Local lRet := .T.
	Local cNum := ''
	Local N := 1
	Local Y := 1

	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))

	DbSelectArea('ZNC')
	ZNC->(DbSetOrder(1))
	SC6->(DbsetOrder(1))
	If SC6->(DbSeek(xFilial('SC6')+SC5->C5_NUM))
		cNum := SC6->C6_NUM
		While cNum = SC6->C6_NUM
			If SB1->(DbSeek(xFilial('SB1')+SC6->C6_PRODUTO))
				If SB1->B1_ORIGEM $ GetMV('MV_XORIPRD',,'1/6') .AND. ZNC->(DbSeek(xFilial('ZNC')+SB1->B1_POSIPI))
					If !(N == Y)
						lRet := .F.
						FWAlertError("Esses Produtos não podem estar junto na mesma nota fiscal","Mensagem de erro")
					EndIf
				EndIf
				If SB1->B1_ORIGEM $ GetMV('MV_XORIPRD',,'1/6') .AND. ZNC->(DbSeek(xFilial('ZNC')+SB1->B1_POSIPI))
					N++
				EndIf
			EndIf
			Y++
			SC6->(DbSkip())
		End
	EndIf
Return lRet
