#Include "TOTVS.ch"
#Include 'Protheus.ch'

USER FUNCTION MT010COR ()
 
Local aCores:={}
aAdd(aCores,{'B1_ZSITUA == ""','BR_VERMELHO',Nil})   //Não Enviado
aAdd(aCores,{'B1_ZSITUA == "01"','BR_VERMELHO',Nil}) //Não Enviado
aAdd(aCores,{'B1_ZSITUA == "02"','BR_AZUL',Nil})     //Aguardando aprovação
aAdd(aCores,{'B1_ZSITUA == "03"','BR_VERDE',Nil})    //Aprovado
aAdd(aCores,{'B1_ZSITUA == "04"','BR_LARANJA',Nil})  //Recusado
RETURN aCores
