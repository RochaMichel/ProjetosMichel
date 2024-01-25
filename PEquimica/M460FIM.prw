#Include 'Protheus.ch'
#Include 'RwMake.ch'
#Include 'TopConn.ch'

User Function M460FIM()
    Local cPedido  := ''
    Local aAreaSC5 := sc5->(GetArea())
    Local lContinua := .T.
     
    //Pega o pedido
    DbSelectArea("SD2")
    SD2->(DbSetorder(3))
    If SD2->(DbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
        cPedido := SD2->D2_PEDIDO
    Endif          
     
    //Se tiver pedido
    If !Empty(cPedido)
        DbSelectArea("SC5")
        SC5->(DbSetorder(1))
        //Se posiciona pega o tipo de pagamento
        If SC5->(DbSeek(FWxFilial('SC5')+cPedido))
            if FieldPos("C5_XCTENUM") > 0
                lContinua := empty(SC5->C5_XCTENUM)
            ENDIF
            IF lContinua
                MsgNota()
            ENDIF
        Endif
    Endif

    RestArea(aAreaSC5)
return

Static function MsgNota()

    Local Cadastrar
    Local Cancelar
    Local oSay1
    Private cCodV := space(1000)
    Static oDlg


    DEFINE MSDIALOG oDlg TITLE "Tela de Cadastro" FROM 000, 000  TO 300, 1200 COLORS 1, 12632256 PIXEL

        @ 025, 020 SAY oSay1 PROMPT "Mensagem do Lacre do pedido: "+SC5->C5_XMSGI SIZE 155, 010 OF oDlg COLORS 1, 16777215 PIXEL
        @ 085, 021 BUTTON Cadastrar PROMPT "Cadastrar" SIZE 051, 020 OF oDlg ACTION Cadast() PIXEL
        @ 085, 095 BUTTON Cancelar PROMPT "Cancelar" SIZE 051, 020 OF oDlg ACTION (oDlg:End()) PIXEL
        @ 055, 020 MSGET oCodV VAR cCodV SIZE 550, 015 OF oDlg COLORS 1, 16777215 PIXEL


    ACTIVATE MSDIALOG oDlg CENTERED

return

Static function Cadast()

    If !Empty(cCodV)
        SC5->(Reclock('SC5',.F.))
        SC5->C5_XMSGI := SC5->C5_XMSGI+Alltrim(cCodV)
        SC5->(MsUnlock())
        FWAlertSuccess("Lacre incluido com sucesso!", "Mensagem")
        oDlg:End()
    EndIf
return
