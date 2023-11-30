#include 'Totvs.ch'

User function GatNoper() 
Local cOper := ""

If Empty(M->D1_NFORI) //--> UTILIZE A VARIAVEL AO INVES DO NOME DO CAMPO
     cOper := ""
Else
     cOper := "A8"
EndIf

aCols[n][GdFieldPos ("D1_OPER")]:= cOper
MaTesInt(1,cOper,cA100For,cLoja,If(cTipo$"DB","C","F"),M->D1_COD,"D1_TES")

Return (cOper)
