#INCLUDE 'TOTVS.CH'
User Function FA080TIT()
	local lret := .T.
	local cAlias := GetNextALias()
	BeginSql Alias cAlias
	Select F1_DTDIGIT from %Table:SF1%
	Where F1_FILIAL = %Exp:SE2->E2_FILIAL%
	AND F1_SERIE = %Exp:SE2->E2_PREFIXO%
	AND F1_DOC = %Exp:SE2->E2_NUM%
	AND F1_FORNECE = %Exp:SE2->E2_FORNECE%
	AND F1_LOJA = %Exp:SE2->E2_LOJA%
	EndSql
	If (cAlias)->(!EOF())
		If dDatabase < StoD((cAlias)->F1_DTDIGIT)
			Alert('A data da baixa é inferior a data de entrada, lançar adiantamento')
			lRet := .F.
		EndIf
	Else
		If dDatabase < SE2->E2_EMIS1
			Alert('A data da baixa é inferior a data de entrada, lançar adiantamento')
			lRet := .F.
		EndIf
	EndIf
	(cAlias)->(DbCloseArea())
return lret
