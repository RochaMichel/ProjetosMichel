#Include "TOTVS.ch"

User Function wfProdutos(cProduto)
    Local lOk := .T.
    if MsgNoYes("Iniciar Teste?",'Teste')
        MsgInfo(cProduto,"Teste")
    endif
 
Return lOk

    wfPrdRet()
 
Return lOk
