#Include 'Protheus.ch'
#Include 'RwMake.ch'
#Include 'TopConn.ch'

user function MsgNota()

Local Cadastrar
Local Cancelar
Local oSay1
Private cCodV := SC5->C5_MENNOTA
Static oDlg


 DEFINE MSDIALOG oDlg TITLE "Tela de Cadastro" FROM 000, 000  TO 250, 550 COLORS 1, 12632256 PIXEL

    @ 025, 020 SAY oSay1 PROMPT "Mensagem para Nota Fiscal" SIZE 155, 010 OF oDlg COLORS 1, 16777215 PIXEL
    @ 085, 021 BUTTON Cadastrar PROMPT "Cadastrar" SIZE 051, 020 OF oDlg ACTION Cadast() PIXEL
    @ 085, 095 BUTTON Cancelar PROMPT "Cancelar" SIZE 051, 020 OF oDlg ACTION (oDlg:End()) PIXEL
    @ 055, 020 MSGET oCodV VAR cCodV SIZE 201, 015 OF oDlg COLORS 1, 16777215 PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

return

Static function Cadast()

If !Empty(cCodV)
    SC5->(Reclock('SC5',.F.))
    SC5->C5_MENNOTA := Alltrim(cCodV)
    SC5->(MsUnlock())
    FWAlertSuccess("Mensagem para NF incluida com sucesso!", "Mensagem")
    oDlg:End()
Else
    FwalertHelp('Campo de mensagem vazio' ,'Preencha o campo de mensagem')
EndIf
return
