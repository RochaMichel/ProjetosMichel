#Include "Protheus.ch"
#Include "TopConn.ch"

user function FA070CHK
	lRet := .T.
	If MsgYesNo("Você deseja executar a baixa do titulo?", "Baixa a receber")
	Else
        lRet := .F.
	EndIf

return lRet
