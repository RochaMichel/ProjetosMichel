#Include 'Totvs.ch'

User function FA050ALT()

    /* Realiza algumas validações que são executadas na inclusão do título */
	If !u_FA050INC( SE2->E2_VENCREA )
		Return .F.
	EndIf
	If SE2->E2_VENCREA <> M->E2_VENCREA
		RecLock("SE2",.F.)
		SE2->E2_DATALIB := CtoD("")
		SE2->E2_USUALIB := ""
		SE2->E2_XNEGAD  := ""
		SE2->E2_STATLIB := "01"
		SE2->E2_CODAPRO := ""
		SE2->(MsUnlock())
	EndIf


Return .T.
