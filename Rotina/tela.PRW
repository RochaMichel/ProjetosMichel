#Include "PROTHEUS.CH"

User Function MyFunction()                        
Local age
Local cge := "Define variable value"
Local enddd
Local cnddd := "Define variable value"
Local inf
Local cnf := "Define variable value"
Local name
Local came := "Define variable value"
Local nume
Local cume := "Define variable value"
Local oBitmap1
Local oButton1
Local oButton2
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local pppp
Local cppp := "Define variable value"
Static oDlg

  DEFINE MSDIALOG oDlg TITLE "                                                     Cadastros Gerais" FROM 000, 000  TO 400, 500 COLORS 0, 14453168 PIXEL

    @ 057, 012 SAY oSay1 PROMPT " Nome :" SIZE 019, 014 OF oDlg COLORS 0, 16777215 PIXEL
    @ 068, 012 SAY oSay2 PROMPT "Idade :" SIZE 019, 014 OF oDlg COLORS 0, 16777215 PIXEL
    @ 082, 012 SAY oSay3 PROMPT "Tel : " SIZE 019, 014 OF oDlg COLORS 0, 16777215 PIXEL
    @ 055, 037 MSGET name VAR came SIZE 063, 010 OF oDlg COLORS 0, 16777215  PIXEL
    @ 069, 037 MSGET age VAR cge SIZE 031, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 082, 036 MSGET nume VAR cume SIZE 068, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 055, 131 SAY oSay4 PROMPT "End :" SIZE 019, 014 OF oDlg COLORS 0, 16777215 PIXEL
    @ 074, 131 SAY oSay5 PROMPT "Cep :" SIZE 019, 014 OF oDlg COLORS 0, 16777215 PIXEL
    @ 056, 156 MSGET enddd VAR cnddd SIZE 065, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 077, 156 MSGET pppp VAR cppp SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 108, 020 SAY oSay6 PROMPT "Informações gerais " SIZE 076, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 121, 016 MSGET inf VAR cnf SIZE 223, 034 OF oDlg COLORS 0, 16777215 PIXEL
    @ 158, 127 BUTTON oButton1 PROMPT "OK" SIZE 040, 017 OF oDlg ACTION OK PIXEL
    @ 159, 179 BUTTON oButton2 PROMPT "Cancelar" SIZE 054, 017 OF oDlg PIXEL
    @ 015, 023 BITMAP oBitmap1 SIZE 048, 037 OF oDlg FILENAME "C:\Users\Robert Callfman\Downloads\WhatsApp Image 2022-08-04 at 09.14.32.jpeg" NOBORDER ADJUST PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

Return
