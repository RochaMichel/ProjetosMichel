#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | MTelPag  | Autor |    Rivaldo Jr.  ( Cod.ERP )                   |*
*+------------+------------------------------------------------------------------+*
*|Data        | 03.10.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Ponto de entrada MVC da Tela de pagamentos                       |*
**********************************************************************************/
User Function MTelPag()
	Local aParam     := PARAMIXB
	Local lRet       := .T.
    Local lEnviou    := .F.
	Local oModel     := aParam[1]
	Local cIdPonto   := aParam[2]

	If Inclui .AND. cIdPonto == 'MODELCOMMITNTTS'//Commit das opera��es (ap�s a grava��o)
        
        lRet := U_ConsRest(oModel, .F.) //Chamo a Fun��o principal para dar inicio a gera��o do Link de pagamento

        If lRet

            ** CHAMAR O CONSUMO DA CHAT2DESK PARA ENVIAR O LINK AO CLIENTE.**

            If lEnviou 
                FWAlertSuccess('Link de pagamento enviado ao cliente.','Sucesso!') 
            Else 
                Help(" ",1,"ATEN��O!",,"O link foi gerado, mas, n�o foi possivel enviar ao cliente.";
                ,3,1,,,,,,{""})    
            EndIf

        Else 
            Help(" ",1,"ATEN��O!",,"N�o foi poss�vel gerar o link de pagamento.";
                ,3,1,,,,,,{""})    
            Return .F.
        EndIf
	endif

Return lRet
