#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'

User Function M030Alt()
// � Na fun��o de Altera��o do Programa de Clientes
	if A1_TIPO == 'X'
		A1_EMAIL := 'Exportacao@grupoelizabeth.com.br'
		A1_HPAGE := 'Exportacao@grupoelizabeth.com.br'
	EndIf
Return xRet
