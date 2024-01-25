#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
//ฑฑบPrograma  ณFI040ROT  บ Autor ณ Sergio Arruda      บ Data ณ  18/02/17   บฑฑ
//ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
//ฑฑบDescricao ณ Ponto-de-Entrada: FI040ROT - Inclusao de Novas Opcoes      บฑฑ
//ฑฑบ          ณ na rotina de Contas a Receber, nas Opcoes Relacionadas.    บฑฑ
//ฑฑบ          ณ                                                            บฑฑ
//ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
//ฑฑบUso       ณ Grupo Elizabeth                                            บฑฑ
//ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
User Function FI040ROT()
	
	aRotinaNew := Paramixb
      
	AAdd( aRotinaNew, { "Boleto BNB" ,"U_BLTBNB()"  , 0 , 1, 0, Nil})   
	AAdd( aRotinaNew, { "Boleto Bradesco" ,"U_BOLBRD()"  , 0 , 1, 0, Nil})      
	AAdd( aRotinaNew, { "Bol. Banco do Brasil" ,"U_BOLBB()"  , 0 , 1, 0, Nil})      
	AAdd( aRotinaNew, { "Emit.Bol.Bradesco" ,"U_XBOLETO()"  , 0 , 1, 0, Nil})     
	AAdd( aRotinaNew, { "LIBERAR RA" ,"U_XLIBRA()"  , 0 , 1, 0, Nil})     
	AAdd( aRotinaNew, { "Identificar Deposito" ,"U_GeraIdent()"  , 0 , 1, 0, Nil})
	AAdd( aRotinaNew, { "Boleto Itau" ,"U_BOLITAU()"  , 0 , 1, 0, Nil}) 
	AAdd( aRotinaNew, { "Boleto Sicoob" ,"U_BOLSICOO()"  , 0 , 1, 0, Nil}) 
	AAdd( aRotinaNew, { "Boleto Santander","U_FINF142()"  , 0 , 1, 0, Nil}) 
	AAdd( aRotinaNew, { "Boleto Avante","U_BOLAVT()"  , 0 , 1, 0, Nil})
	AAdd( aRotinaNew, { "Boleto Sofisa","U_BOLSOF()"  , 0 , 1, 0, Nil})

Return(aRotinaNew)          
