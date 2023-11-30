#Include "Protheus.ch"

/*/{Protheus.doc} MT410INC
Este ponto de entrada pertence � rotina de pedidos de venda, MATA410(). 
Est� localizado na rotina de altera��o do pedido, A410INCLUI(). � executado ap�s a grava��o das informa��es.
@type function
@version 12.1.33
@author Silvano Franca
@since 21/11/2022
/*/    
User Function MT410INC()

    // Envia e-mail para o cliente informando que o pedido recebido por API foi integrado ao EPR.
    U_ALW0001()

    

Return
