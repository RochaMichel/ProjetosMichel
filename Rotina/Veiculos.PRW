#Include "PROTHEUS.CH"

User Function F002()                        
Local Cadastrar
Local Cancelar
Local oCodV
Local oCor 
Local oModVei 
Local oPlaca
Local oSay1
Local oSay2
Local oSay3
Local oSay4
local oSay5
local oSay6
Local oVeiAtivo
Private cNomeMot := Space(40)
Private nVeiAtivo := 1
Private cCodV := Space(10)
Private cModVei := Space(19)
Private cPlaca := Space(7)
Private cCor := Space(2)
Static oDlg


 DEFINE MSDIALOG oDlg TITLE "Tela de Cadastro" FROM 000, 000  TO 600, 1000 COLORS 0, 12632256 PIXEL

    @ 025, 014 SAY oSay1 PROMPT "Código do veiculo" SIZE 045, 008 OF oDlg COLORS 0, 12632256 PIXEL
    @ 260, 021 BUTTON Cadastrar PROMPT "Cadastrar" SIZE 051, 020 OF oDlg ACTION Cadast() PIXEL
    @ 260, 169 BUTTON Cancelar PROMPT "Cancelar" SIZE 051, 020 OF oDlg ACTION (oDlg:End()) PIXEL
    @ 035, 020 MSGET oCodV VAR cCodV SIZE 201, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 146, 020 MSCOMBOBOX oVeiAtivo VAR nVeiAtivo ITEMS {"1 - Sim","2 - Nao"} SIZE 201, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 055, 014 SAY oSay2 PROMPT "Modelo do veiculo" SIZE 045, 008 OF oDlg COLORS 0, 12632256 PIXEL
    @ 072, 020 MSGET oModVei VAR cModVei SIZE 201, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 091, 014 SAY oSay3 PROMPT "Placa" SIZE 045, 008 OF oDlg COLORS 0, 12632256 PIXEL
    @ 107, 020 MSGET oPlaca VAR cPlaca SIZE 201, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 127, 014 SAY oSay4 PROMPT "Veiculo disponivel para uso" SIZE 069, 008 OF oDlg COLORS 0, 12632256 PIXEL
    @ 165, 014 SAY oSay5 PROMPT "Código da Cor do Veiculo" SIZE 065, 008 OF oDlg COLORS 0, 12632256 PIXEL
    @ 183, 020 MSGET oCor VAR cCor SIZE 201, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 200, 014 SAY oSay6 PROMPT " Nome do motorista" SIZE 045, 008 OF oDlg COLORS 0, 12632256 PIXEL
    @ 220, 020 MSGET oCor VAR cNomeMot SIZE 201, 010 OF oDlg COLORS 0, 16777215 PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

Return





Static Function cadast()
  
	local oModel := nil
	local lOk := .F.
  local aFields :={}

if !Empty(cCodV).and. !Empty(cModVei).and. !Empty(cPlaca) .and. !Empty(cCor) .and. !Empty(cNomeMot)

      oModel := FWLoadModel("OMSA060")
      

      aAdd(aFields, {"DA3_COD",  alltrim(cCodV), Nil})
      aAdd(aFields, {"DA3_DESC", alltrim(cModVei), Nil})
      aAdd(aFields, {"DA3_DESCMO", alltrim(cNomeMot), Nil})
      aAdd(aFields, {"DA3_PLACA", cPlaca, Nil})
      aAdd(aFields, {"DA3_ATIVO", SubStr(cValToChar(nVeiAtivo), 1, 1), Nil})
      aAdd(aFields, {"DA3_CORVEI", cValToChar(cCor),nil})


    //Se conseguir executar a opera��o autom�tica
      If FWMVCRotAuto(oModel, "DA3", 3, {{"OMSA060_DA3", aFields}},,.T.)
        lOk := .T.
         FwAlertSuccess("veiculo cadastrado com sucesso", "Relatorio") 
      Else
        lOk := .F.
      EndIf
      If ! lOk
        //Busca o Erro do Modelo de Dados
        aErro := oModel:GetErrorMessage()

        //Monta o Texto que ser� mostrado na tela
        cMessage := "Id do formul�rio de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
        cMessage += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
        cMessage += "Id do formul�rio de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
        cMessage += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
        cMessage += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
        cMessage += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], '
        cMessage += "Mensagem da solu��o: "        + ' [' + cValToChar(aErro[07]) + '], '
        cMessage += "Valor atribu�do: "            + ' [' + cValToChar(aErro[08]) + '], '
        cMessage += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'

        //Mostra mensagem de erro
        lRet := .F.
        MsgAlert("Erro: " + cMessage ,"mensagem de erro ")

      Else
        lRet := .T.
        ConOut("Produto excluido")
      EndIf

    //Desativa o modelo de dados
      oModel:DeActivate()
else
  MsgAlert("algum campo n�o foi preenchido", "erro")

EndIf
Return

