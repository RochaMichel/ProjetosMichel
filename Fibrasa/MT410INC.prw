#Include "Protheus.ch"

/*/{Protheus.doc} MT410INC
Este ponto de entrada pertence à rotina de pedidos de venda, MATA410(). 
Está localizado na rotina de alteração do pedido, A410INCLUI(). É executado após a gravação das informações.
@type function
@version 12.1.33
@author Silvano Franca
@since 21/11/2022
/*/    
User Function MT410INC()

    // Envia e-mail para o cliente informando que o pedido recebido por API foi integrado ao EPR.
    U_ALW0001()

    

Return
