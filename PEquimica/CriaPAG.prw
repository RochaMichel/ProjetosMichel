#Include "TOTVS.CH"
#Include "RESTFUL.CH"
#Include "tbiconn.ch"
#Include "topconn.ch"

User Function CriaPag(cFilx,cPrefixo,cNumero,cNatureza,cFornece,cLoja,dEmissao,nValor,cCusto,cCond)
	Local aSe2Val := {}

	aAdd(aSe2Val, {"E2_FILIAL",  cFilx,                                     Nil})
	aAdd(aSe2Val, {"E2_NUM",     cNumero,                                   Nil})
	aAdd(aSe2Val, {"E2_PREFIXO", cPrefixo,                                  Nil})
	aAdd(aSe2Val, {"E2_PARCELA", "",                                        Nil})
	aAdd(aSe2Val, {"E2_TIPO",    "RPA",                                     Nil})
	aAdd(aSe2Val, {"E2_NATUREZ", cNatureza,                                 Nil})
	aAdd(aSe2Val, {"E2_FORNECE", cFornece,                                  Nil})
	aAdd(aSe2Val, {"E2_LOJA",    cLoja,                                     Nil})
	aAdd(aSe2Val, {"E2_EMISSAO", dEmissao,                                  Nil})
	aAdd(aSe2Val, {"E2_VENCTO",  dEmissao+GetDToVal(cCond),                 Nil})
	aAdd(aSe2Val, {"E2_VENCREA", DataValida(dEmissao+GetDToVal(cCond),.T.), Nil})
	aAdd(aSe2Val, {"E2_VALOR",   nValor  ,                                  Nil})
	aAdd(aSe2Val, {"E2_CCUSTO",  cCusto  ,                                  Nil})
	aAdd(aSe2Val, {"E2_MOEDA",   1,                                         Nil})

	DbSelectArea("SE2")
	Begin Transaction
		//Chama a rotina autom�tica
		lMsErroAuto := .F.
		MSExecAuto({|x,y| FINA050(x,y)}, aSe2Val, 3)

		//Se houve erro, mostra o erro ao usu�rio e desarma a transa��o
		If lMsErroAuto
			MostraErro()
		EndIf
    //Finaliza a transa��o
	End Transaction
return
