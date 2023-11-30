#INCLUDE 'totvs.ch'
/*/{Protheus.doc} M410STTS
Valida��o da regra de neg�cio por campo customizado
@type function
@version 12.1.33 
@author Cod.Erp :: Mateus Ramos
@since 15/03/2023
@return variant, nil
/*/
User Function M410STTS()

	Local nOper     := PARAMIXB[1]
	Local aArea     := GetArea()
	Local aAreaC6   := SC6->(GetArea())
	Local aAreaAC   := ACN->(GetArea())
	Local lBlqRegr  := .F.
	Local cRegra    := ""
    
	If nOper == 3 .OR. nOper == 6   //Tratativa de bloqueio por regra de neg�cio na inclus�o e c�pia
		If SC6->(DbSeek(xFilial('SC6')+SC5->C5_NUM))
			ACN->(DbSetOrder(2))
			While SC6->C6_NUM == SC5->C5_NUM
				cRegra := POSICIONE('SB1',1,xFilial('SB1')+SC6->C6_PRODUTO,'B1_GRUPO')
				If ACN->(DbSeek(xFilial('ACN')+cRegra))
					If SC6->C6_XDESCON > ACN->ACN_DESCON
						lBlqRegr := .T.
						Exit
					EndIf
				EndIf
				SC6->(DbSkip())
			End
		EndIf
		If lBlqRegr
			RecLock('SC5', .F.)
			SC5->C5_BLQ := "1"
			SC5->(MsUnlock())
		EndIf

		EnvPdfZum()// chamada Envio de relatorio pdf para o Vendedor Representante

	EndIf

	RestArea(aAreaAC)
	RestArea(aAreaC6)
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} M410STTS
Envio de relatorio pdf para o Vendedor Representante
@type function
@version 12.1.33 
@author Cod.Erp :: Michel Rocha
@since 21/03/2023
@return variant, nil
/*/
Static Function EnvPdfZum()
	Local cAssunto  := "Seu pedido de compra N� "+SC5->C5_NUM+" foi recebido."
	Local cMsg      := ""
	Local cRaz�oSoc := AllTrim(Posicione("SA1",1,xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,"A1_NOME"))// Raz�o social do cliente 
	Local cCnpj		:= Posicione("SA1",1,xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,"A1_CGC")// Cnpj do cliente 
	Local aEmailCli := {}
	
	aEmailCli := Separa(AllTrim(Posicione("SA3",1,xFilial("SA3") + M->C5_VEND1,"A3_EMAIL")),";")// pegando Email do vendedor representante 

	cMsg := "Numero do pedido de venda: "+SC5->C5_NUM+"<br>"
	cMsg += "<br>"
	cMsg +=	"Cliente: "+cRaz�oSoc+"  |  CFP/CNPJ: "+cCnpj+"<br>"
	cMsg += "<br>"
	cMsg +=	"Prezado Cliente,<br>"
	cMsg += "<br>"
	cMsg +=	"Temos o prazer de informar que recebemos seu pedido, condi��es gerais de fornecimento ser�o destacadas no documento em anexo. <br>"
	cMsg +=	"Permanecemos � disposi��o para eventuais esclarecimentos. "
	
	If Len(aEmailCli) <= 0
		MsgInfo("Aten��o!","Vendedor representante sem Email cadastrado, n�o ser� possivel enviar o pdf do pedido.")
		Return
	EndIf

	//U_EnvPdfZum(aEmailCli,cAssunto,cMsg)// fun��o para montar o pdf e enviar para o representante
	U_ZMFATR03(aEmailCli,cAssunto,cMsg)// fun��o para montar o pdf e enviar para o representante

Return
 