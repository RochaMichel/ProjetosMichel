#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M030PALT  � Autor � Lucas Bortolin     � Data �  03/09/21   ���
�������������������������������������������������������������������������͹��
���Descricao � Ponto de entrada na valida��o da altera��o de clientes.    ���
���          � Atendimento chamado interno 212830                         ���
�������������������������������������������������������������������������͹��
���Uso       � Elizabeth                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function M030PALT()
	Local nOpcao	:= PARAMIXB[1]
	Local lRet	 	:= .T.

	If nOpcao == 1
		//SA1->(DbSetOrder(1))
		//SA1->(DbSeek(SA1->(A1_FILIAL+A1_COD+A1_LOJA)))
		//If SA1->A1_TIPO == 'X'
		//	RecLock("SA1", .F.)
		//	SA1->A1_EMAIL := 'Exportacao@grupoelizabeth.com.br'
		//	SA1->A1_HPAGE := 'Exportacao@grupoelizabeth.com.br'
		//	SA1->(MsUnlock())
		//	FWAlertInfo('clientes do tipo import/export ficara com o email exportacao@grupoelizabeth.com.br ','Atualiza��o de email de clientes import/export')
		//EndIf
		U_FATF174()
	EndIF
Return lRet
