#INCLUDE 'Totvs.ch'
#INCLUDE 'Protheus.ch'

User Function A010TOK()
    IF (INCLUI .OR. (ALTERA .and. !(SB1->B1_ZSITUA $ '03,04')))
        u_wfProdutos(SB1->B1_COD)
    EndIF
    
    {|oProcess| u_wfPrdRet(oProcess), {lExecuta := IIF(alltrim(oProcess:oHtml:RetByName("Aprovacao")) == 'S',lVar := .T., lVar := .F.) } }

Return lExecuta
