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
    Local cStatus    := ''
    Local cContato   := ''
    Local cNome      := ''
    Local cMensagem  := ''
    Local cTBalcao   := ''
	Local oModel     := aParam[1]
	Local cIdPonto   := aParam[2]

	If Inclui .AND. cIdPonto == 'MODELCOMMITNTTS'//Commit das operações (após a gravação)
        
        lRet := U_ConsRest(oModel, .F.) //Chamo a Função principal para dar inicio a geração do Link de pagamento

        If lRet

            cContato := "55"+ZLP->ZLP_CONTCL
            cNome    := "RIVALDO JUNIOR"
            cMensagem:= "Segue link de pagamento referente a sua compra na Pharmapele."+CRLF
            cMensagem+= AllTrim(ZLP->ZLP_LINKPG)

            cStatus := U_Chat2Desk(cContato, cNome, cMensagem)

            If !Empty(cStatus)//lEnviou 
                FWAlertSuccess('Link de pagamento enviado ao cliente.','Sucesso!') 
            Else 
                Help(" ",1,"ATENÇÃO!",,"O link foi gerado, mas, não foi possivel enviar ao cliente.";
                ,3,1,,,,,,{""})    
            EndIf

        Else 
            Help(" ",1,"ATENÇÃO!",,"Não foi possível gerar o link de pagamento.";
                ,3,1,,,,,,{""})    
            Return .F.
        EndIf
	endif

Return lRet
