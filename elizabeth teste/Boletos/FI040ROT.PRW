#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������
//�������������������������������������������������������������������������ͻ��
//���Programa  �FI040ROT  � Autor � Sergio Arruda      � Data �  18/02/17   ���
//�������������������������������������������������������������������������͹��
//���Descricao � Ponto-de-Entrada: FI040ROT - Inclusao de Novas Opcoes      ���
//���          � na rotina de Contas a Receber, nas Opcoes Relacionadas.    ���
//���          �                                                            ���
//�������������������������������������������������������������������������͹��
//���Uso       � Grupo Elizabeth                                            ���
//�������������������������������������������������������������������������ͼ��
//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������
User Function FI040ROT()
	
	aRotinaNew := Paramixb
      
	AAdd( aRotinaNew, { "Boleto BNB" ,"U_BLTBNB()"  , 0 , 1, 0, Nil})   
	AAdd( aRotinaNew, { "Boleto Bradesco" ,"U_BOLBRD()"  , 0 , 1, 0, Nil})      
	AAdd( aRotinaNew, { "Bol. Banco do Brasil" ,"U_BOLBB()"  , 0 , 1, 0, Nil})      
	AAdd( aRotinaNew, { "Emit.Bol.Bradesco" ,"U_XBOLETO()"  , 0 , 1, 0, Nil})     
	AAdd( aRotinaNew, { "LIBERAR RA" ,"U_XLIBRA()"  , 0 , 1, 0, Nil})     
	AAdd( aRotinaNew, { "Identificar Deposito" ,"U_GeraIdent()"  , 0 , 1, 0, Nil})
	AAdd( aRotinaNew, { "Boleto Itau" ,"U_BOLITAU()"  , 0 , 1, 0, Nil}) 
	AAdd( aRotinaNew, { "Boleto Sicoob" ,"U_BOLSICOO()"  , 0 , 1, 0, Nil}) 
	AAdd( aRotinaNew, { "Boleto Santander","U_FINF142()"  , 0 , 1, 0, Nil}) 
	AAdd( aRotinaNew, { "Boleto Avante","U_BOLAVT()"  , 0 , 1, 0, Nil})
	AAdd( aRotinaNew, { "Boleto Sofisa","U_BOLSOF()"  , 0 , 1, 0, Nil})

Return(aRotinaNew)          
