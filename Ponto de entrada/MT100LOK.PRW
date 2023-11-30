#Include 'Protheus.ch'

User Function MT100LOK()
Local _nCC := acols[1][20] // centro de custo da primeira linha.
Local bRet

IF Empty(_nCC)
  bRet := MsgNoYes('Não tem centro de Custo, deseja bloquear?','Bloqueio')
ELSE 
   bRet := .t. 
ENDIF

Return bRet
