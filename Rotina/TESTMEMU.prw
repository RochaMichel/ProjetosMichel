#Include 'Totvs.ch'
#include "matxfunb.ch"
User function RetMemu()
    local aTexto := {}
    local i := 1
    local cSypalias := GetNextAlias()
	DbSelectArea('SB1')
	Sb1->(DBSetOrder(1))
	Sb1->(DbSeek(Xfilial('SB1')+"01010001001003"))
	Beginsql alias cSypalias
    SELECT
        YP_TEXTO 
    FROM
        SYP010 SYP
    WHERE
        YP_CHAVE = %Exp:SB1->B1_DESC_P%
        AND Yp_FILIAL = %Exp:xFilial('SYP')%
        AND SYP.D_E_L_E_T_ = ' '
	EndSql
    While (cSypalias)->(!EOF())
        Aadd(aTexto,(cSypalias)->(YP_TEXTO))
        (cSypalias)->(DBSKIP())
    End
    for i := 1 to len(aTexto)
    MsgAlert(aTexto[i])
    Next
Return
