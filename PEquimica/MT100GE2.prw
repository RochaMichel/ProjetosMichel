#include 'protheus.ch'
#include 'parmtype.ch'

User Function MT100GE2()
Local aTitAtual := PARAMIXB[1]
Local nOpc := PARAMIXB[2]
Local aHeadSE2:= PARAMIXB[3]
Local aParcelas := ParamIXB[5]
Local nX := ParamIXB[4]
//.....Exemplo de customização
//If nOpc == 1 //.. inclusao
//     SE2->E2_CCUSTO := SD1->D1_CC
//Endif

Return (Nil)
