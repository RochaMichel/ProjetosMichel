#Include 'Protheus.ch'


/*
============================================================================
|Func : calPrOrc()                                                         |
|Gatilho: (CK_PRODUTO,CK_XCUSTO,CK_XFRETE,CK_XRENT,CK_LOCAL) -> CK_PRCVEN  |
|Desc : Gatilho para calcular o valor do preço unitário                    |
|       sempre atualiza o preço caso um dos campos acima forem atualizados |
|Autor: Carolina Tavares --- 30/11/2023                                    |
============================================================================
*/

User Function calPrOrc()
    Local aArea
    Local cCli      := M->CJ_CLIENTE
    Local cLoja     := M->CJ_LOJA
    Local cEstDest  := ''
    Local cMVEst    := GetMV("MV_ESTADO")
    Local cMVNorte  := GetMV("MV_NORTE")
    Local nMVtxPis     := GetMV("MV_TXPIS")
    Local nMVtxCofin   := GetMV("MV_TXCOFIN")
    Local icms      := GetMV("MV_ICMPAD")
    Local icmInt    := GetMV("MV_XICMINT", , 12)
    Local nPos      := 0
    Local pisCofin  :=nMVtxPis + nMVtxCofin


    /* Posiciona na SA1 para achar o estado destino do cliente */
    aArea := SA1->(GetArea())
    DbSelectArea("SA1")
    SA1->(DbSetOrder(1)) //Posiciona no indice 1
    SA1->(DbGoTop())

    cEstDest := Posicione("SA1",1,FWxFilial("SA1") + cCli + cLoja,"A1_EST")

    RestArea(aArea)

    nPos := At(cEstDest, cMVNorte) //caso a alíquota seja 7% (não usado no momento)


    If cEstDest == cMVEst // se o estado de destino for igual ao estado de origem (PE) o icms é 20,5%
        fator := (100 - (pisCofin - ((pisCofin * icms) / 100 ) + icms)) / 100
        nPrcNet := TMP1->CK_XPRECO / fator
    else // alíquota é 12%
        fator := (100 - (pisCofin - ((pisCofin * icmInt) / 100 ) + icmInt)) / 100
        nPrcNet := TMP1->CK_XPRECO  / fator
    EndIf



return nPrcNet


/*
============================================================================
|Func : ReajPrOrc()                                                        |
|Gatilho: CK_PRCVEN -> CK_XPRECO                                           |
|Desc : Gatilho para reajustar o Preço Net quando o Preço unitário         |
|       for atualizado pelo usuário (arredondado)                          |
|Autor: Carolina Tavares --- 30/11/2023                                    |
============================================================================
*/

User Function ReajPrOrc()
    Local aArea
    Local cCli      := M->CJ_CLIENTE
    Local cLoja     := M->CJ_LOJA
    Local cEstDest  := ''
    Local nPrcN     := 0
    Local cMVEst    := GetMV("MV_ESTADO")
    Local cMVNorte  := GetMV("MV_NORTE")
    Local nMVtxPis  := GetMV("MV_TXPIS")
    Local nMVtxCofin := GetMV("MV_TXCOFIN")
    Local icms      := GetMV("MV_ICMPAD")
    Local icmInt    := GetMV("MV_XICMINT", , 12)
    Local nPos      := 0
    Local pisCofin  :=nMVtxPis + nMVtxCofin


    aArea := SA1->(GetArea())
    DbSelectArea("SA1")
    SA1->(DbSetOrder(1)) //Posiciona no indice 1
    SA1->(DbGoTop())

    cEstDest := Posicione("SA1",1,FWxFilial("SA1") + cCli + cLoja,"A1_EST")

    RestArea(aArea)

    nPos := At(cEstDest, cMVNorte) //caso a alíquota seja 7% (não usado no momento)

    If cEstDest == cMVEst // se o estado de destino for igual ao estado de origem (PE) o icms é 20,5%
        fator := (100 - (pisCofin - ((pisCofin * icms) / 100 ) + icms)) / 100 //calculo do fator icms
        nPrcN := TMP1->CK_PRCVEN * fator
    else // alíquota é 12%
        fator := (100 - (pisCofin - ((pisCofin * icmInt) / 100 ) + icmInt)) / 100
        nPrcN := TMP1->CK_PRCVEN * fator
    EndIf

return nPrcN

/*
============================================================================
|Func : calCustOrc()                                                       |
|Gatilho: (CK_PRODUTO, CK_LOCAL) -> CK_XCUSTO                              |
|Desc : Gatilho para calcular o custo do produto. Calcula sempre           |
|       que o produto ou o armazém forem atualizados                       |
|Autor: Carolina Tavares --- 13/12/2023                                    |
============================================================================
*/
User Function calCustOrc()
    Local nRet := 0
    Local cProd     := TMP1->CK_PRODUTO
    Local cLocal    := TMP1->CK_LOCAL

    nRet := calcest(cProd, cLocal,dDataBase)[2]/calcest(cProd, cLocal,dDataBase)[1]

Return nRet

/*
============================================================================
|Func : calPr()                                                            |
|Gatilho: (CK_PRODUTO,CK_XCUSTO,CK_XFRETE,CK_XRENT,CK_LOCAL) -> CK_XPRECO  |
|Desc : Gatilho para calcular o Preço Net. Atualiza sempre que um          |
|       dos campos mudarem                                                 |
|Autor: Carolina Tavares --- 13/12/2023                                    |
============================================================================
*/
User Function calPr()
    Local nCusto    := TMP1->CK_XCUSTO
    Local nFrete    := TMP1->CK_XFRETE
    Local nRent     := TMP1->CK_XRENT
    Local nPrc      := nCusto + nFrete + nRent

Return nPrc


/* (M->CK_PRCVEN - M->CK_XCUSTO) - M->CK_XFRETE                                                         */


/* Gatilhos

    CK_PRODUTO -> CK_XCUSTO -> U_calCustOrc()
    CK_PRODUTO -> CK_XPRECO -> U_calPr()
    CK_PRODUTO -> CK_PRCVEN -> U_calPrOrc()
    CK_PRODUTO -> CK_VALOR  -> M->CK_QTDVEN * M->CK_PRCVEN

    CK_XCUSTO -> CK_XPRECO -> U_calPr()
    CK_XCUSTO -> CK_PRCVEN -> U_calPrOrc()
    CK_XCUSTO -> CK_VALOR  -> M->CK_QTDVEN * M->CK_PRCVEN

    CK_XFRETE -> CK_XPRECO -> U_calPr()
    CK_XFRETE -> CK_PRCVEN -> U_calPrOrc()
    CK_XFRETE -> CK_VALOR  -> M->CK_QTDVEN * M->CK_PRCVEN

    CK_XRENT -> CK_XPRECO -> U_calPr()
    CK_XRENT -> CK_PRCVEN -> U_calPrOrc()
    CK_XRENT -> CK_VALOR  -> M->CK_QTDVEN * M->CK_PRCVEN

    Caso o usuário decida trocar de armazém refaz todos os cálculos
    CK_LOCAL -> CK_XCUSTO -> U_calCustOrc()
    CK_LOCAL -> CK_XPRECO -> U_calPr()
    CK_LOCAL -> CK_PRCVEN -> U_calPrOrc()
    CK_LOCAL -> CK_VALOR  -> M->CK_QTDVEN * M->CK_PRCVEN

    Caso o usuário decida reajustar o preço unitário ajusta o preço net e a rentabilidade
    CK_PRCVEN -> CK_XPRECO -> U_ReajPrOrc()
    CK_PRCVEN -> CK_XRENT -> (M->CK_XPRECO - M->CK_XCUSTO) - M->CK_XFRETE


*/
