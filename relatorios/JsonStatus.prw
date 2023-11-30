#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#include "TBICONN.CH"

WSRESTFUL StsProd DESCRIPTION "Api REST Status Produto"
	WSDATA Cnpj AS STRING
	WSDATA Pedido AS STRING

	WSMETHOD GET StsProd DESCRIPTION 'Pedido SC5'
END WSRESTFUL

WSMETHOD GET StsProd WSRECEIVE Cnpj,Pedido WSREST StsProd

Local cRetJson 	 := ''
Local nPosCnpj := aScan(Self:AQueryString, {|x| AllTrim(Upper(x[1])) == "CNPJ"})
Local nPosPedido := aScan(Self:AQueryString, {|x| AllTrim(Upper(x[1])) == "PEDIDO"})
Local cCnpj		 := Self:AQueryString[nPosCnpj][2]
Local CPedido	 := Self:AQueryString[nPosPedido][2]

::SetContentType("application/json")

DbSelectArea("SM0")
SM0->(DBSetOrder(1), DBGoTop())
While SM0->(!Eof())
	If SM0->M0_CGC == cCnpj
		PREPARE ENVIRONMENT EMPRESA SM0->M0_CODIGO FILIAL SM0->M0_CODFIL
		Exit
	EndIf
	SM0->(DbSkip())
End

DBSelectArea("SC5")
SC5->(DBSetOrder(1))
iF SC5->(DbSeek(SM0->M0_CODFIL+cPedido))
	Do Case
	Case Empty(SC5->C5_LIBEROK)
		cRetJson := '{"Pedido ":"'+cPedido+'", '+CRLF
		cRetJson += '"Status ":"Em Aberto"}'
	Case !Empty(SC5->C5_NOTA)
		cRetJson := '{"Pedido ":"'+cPedido+'", '+CRLF
		cRetJson += '"Status ":"Encerrado"}'
	Case !Empty(SC5->C5_LIBEROK) .And. Empty(SC5->C5_NOTA)
		cRetJson := '{"Pedido ":"'+cPedido+'", '+CRLF
		cRetJson += '"Status ":"Liberado"}'
	Case SC5->C5_BLQ == '1'
		cRetJson := '{"Pedido ":"'+cPedido+'", '+CRLF
		cRetJson += '{"Status ":"Bloqueado Por Regra"}'
	Case SC5->C5_BLQ == '2'
		cRetJson := '{"Pedido ":"'+cPedido+'", '+CRLF
		cRetJson += '{"Status ":"Bloqueado Por Verba"}'
	EndCase
ELSE
	cRetJson := '{"Pedido ":"'+cPedido+'", '+CRLF
	cRetJson += '"Status ":"Pedido Não Encontrado"}'
Endif

Reset Environment

::SetResponse(EncodeUTF8(cRetJson))

Return(.T.)
