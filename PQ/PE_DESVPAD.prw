#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'


User Function MDESVPAD()
	Local aParam     := PARAMIXB
	Local xRet       := .T.
	Local oModel 	 := aParam[1]
	Local cQuery     := GetNextAlias()
	Local cIdPonto   := aParam[3]

	If oModel:GetOperation() == 5 .And. cIdPonto == 'MODELCOMMITNTTS'

		BeginSql Alias cQuery
			SELECT * FROM %Table:SF1% SF1 
			WHERE F1_DOC = %Exp:ZR2->ZR2_DOC%
			AND F1_SERIE = %Exp:ZR2->ZR2_SERIE%
			AND F1_FILIAL = %xFilial:SF1%
			AND F1_FORNECE = %Exp:ZR2->ZR2_FORN%
			AND F1_LOJA = %Exp:ZR2->ZR2_FLOJA%
			AND SF1.D_E_L_E_T_= ''
		EndSql

		If (cQuery)->(!Eof())
			DbSelectArea("SF1")
			SF1->(DbSetOrder(1))
			If SF1->(DbSeek(xFilial("SF1")+(cQuery)->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
				SF1->(RecLock("SF1", .F.))
					SF1->F1_XDESVPD := ""
				SF1->(MsUnlock())
			EndIf
		EndIf
		(cQuery)->(DbCloseArea())
	EndIf

Return xRet
