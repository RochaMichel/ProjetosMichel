#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "Totvs.ch"
#include 'TBICONN.CH'

/*/{Protheus.doc} User Function VlrB2
    (Api REST para consulta de pedidos de venda)
    @type  Function
    @author Leandro Lemos
    @since 08/05/2020
    @version P12 
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

WSRESTFUL VlrB2 DESCRIPTION "Api REST para pegar saldo e custo "

	WSDATA CNPJ   As String
	WSDATA Codigo 	As String

	WSMETHOD GET VlrB2 DESCRIPTION 'Valor Do Saldo e Custo'
END WSRESTFUL

WSMETHOD GET VlrB2 WSRECEIVE CNPJ, Codigo  WSREST VlrB2

local nSaldo
Local cRetJson := ""
Local nPosCnpj := aScan(Self:AQueryString, {|x| AllTrim(Upper(x[1])) == "CNPJ"})
Local nPosCod  := aScan(Self:AQueryString, {|x| AllTrim(Upper(x[1])) == "CODIGO"})
Local cCNPJ    := Self:AQueryString[nPosCnpj][2]
Local cCod    := Self:AQueryString[nPosCod][2]

::SetContentType("application/json")

DbSelectArea("SM0") 
SM0->(DBSetOrder(1), DBGoTop()) 
While SM0->(!Eof())
    If SM0->M0_CGC == cCNPJ
        PREPARE ENVIRONMENT EMPRESA SM0->M0_CODIGO FILIAL SM0->M0_CODFIL 
        Exit
    EndIf
    SM0->(DbSkip())
End

DbSelectArea("SB1")
SB1->(DbSetOrder(1))

DbSelectArea("SB2")
SB2->(DbSetOrder(1))

DbSelectArea("DA1")
DA1->(DbSetOrder(2))
If SB1->(DbSeek(xFilial('SB1')+cCod)) 
	cRetJson := '{"Produto" : "'+cCod+'",' + CRLF
    cRetJson += '"Descrição" : "'+AllTrim(SB1->B1_DESC)+'" ,' + CRLF
    If SB2->(DbSeek(SM0->M0_CODFIL+cCod))
    nSaldo := ROUND((SB2->B2_QATU*SB1->B1_NEFATOR),0)
	cRetJson += '"Saldo" : "'+CValToChar(nSaldo)+'",' + CRLF
    Else
    cRetJson += '"Status" : "Sem Saldo",' + CRLF   
    cRetJson += '"Saldo" : "0",' + CRLF        
    EndIf   
else
	cRetJson := '{"Produto" : "'+cCod+'",' + CRLF
	cRetJson += '"Status" : "Produto não encontrado" }'
EndIf

Reset Environment

::SetResponse(EncodeUTF8(cRetJson))

Return(.T.)
