#INCLUDE "protheus.CH"

user Function teste()
/*local ano
local cno := Space(8)
local Placa
local claca := Space(15)
local oSay1
local cSay2
local oSay3
local oSay4
local oSay5
local modcar
local codCar := Space(15)
local marcaCar
local carcaCar := Space(15)
local Tcor
local ccor := Space(16)
local Tchassi 
local cchassi := Space(16)
local oButton1
local oButton2*/
Private aSize := MsAdvSize(.F.)
Private nJanLini := aSize[1]
Private nJanLinF := aSize[3]
private nJanColi := aSize[2]
Private nJanColF := aSize[4]

Private oDlgPulo
                                                                                                          
	

//DEFINE MSDIALOG oDlg TITLE "                                                         Registros de automoveis" FROM 000, 000  TO 400, 550 COLORS 1,6984569 PIXEL

DEFINE MSDIALOG oDlgPulo TITLE "teste"  FROM nJanColi, nJanLini TO nJanColF, nJanLinF COLORS 1,6984569 PIXEL
 
/*@ 057, 012 SAY oSay1 PROMPT  " Placa :" SIZE 035, 030 OF oDlgPulo COLORS 0, 16777215 PIXEL
@ 077, 012 SAY cSay2 PROMPT " Ano :"   SIZE 035, 030 OF oDlgPulo COLORS 0, 16777215 PIXEL
@ 097, 012 SAY oSay3 PROMPT " Marca :" SIZE 035, 030 OF oDlgPulo COLORS 0, 16777215 PIXEL
@ 097, 131 SAY oSay3 PROMPT " Modelo :" SIZE 035, 030 OF oDlgPulo COLORS 0, 16777215 PIXEL
@ 057, 131 SAY oSay4 PROMPT " cor :" SIZE 035, 030 OF oDlgPulo COLORS 0, 16777215 PIXEL
@ 077, 131 SAY oSay5 PROMPT " chassi :" SIZE 035, 030 OF oDlgPulo COLORS 0, 16777215 PIXEL
@ 097, 168 MSGET modcar VAR codCar SIZE 063, 010 OF oDlgPulo COLORS 0, 16777215  PIXEL
@ 097, 060 MSGET marcaCar VAR carcaCar SIZE 063, 010 OF oDlgPulo COLORS 0, 16777215  PIXEL
@ 057, 168 MSGET Tcor VAR ccor SIZE 063, 010 OF oDlgPulo COLORS 0, 16777215  PIXEL
@ 057, 060 MSGET Placa VAR claca SIZE 063, 010 OF oDlgPulo COLORS 0, 16777215  PIXEL
@ 077, 060 MSGET ano VAR cno SIZE 063, 010 OF oDlgPulo COLORS 0, 16777215  PIXEL
@ 077, 168 MSGET Tchassi VAR cchassi SIZE 063, 010 OF oDlgPulo COLORS 0, 16777215  PIXEL
@ 159, 120 BUTTON oButton1 PROMPT "Cadastrar" SIZE 054, 017 OF oDlgPulo ACTION OK PIXEL
@ 159, 179 BUTTON oButton2 PROMPT "Cancelar" SIZE 054, 017 OF oDlgPulo PIXEL
*/
ACTIVATE MSDIALOG oDlgPulo CENTERED


Return 
