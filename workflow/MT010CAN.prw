
#INCLUDE 'Totvs.ch'
#INCLUDE 'Protheus.ch'

User Function MT010CAN()
 IF (INCLUI .OR. (ALTERA .and. !(SB1->B1_ZSITUA $ '03,04')))
 
        u_wfProdutos(SB1->B1_COD)
    EndIF

Return NIL
