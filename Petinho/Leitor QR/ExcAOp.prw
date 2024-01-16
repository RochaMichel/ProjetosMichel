#INCLUDE "TOTVS.CH"

*******************************************************************************
// Função : GeraOp - Função Automática para gerar uma Ordem de produção       |
// Modulo : ""                                                                |
// Fonte  : ExcAOp.prw                                                       |
// ---------+--------------------------+--------------------------------------+
// Data     | Autor             	   | Descricao                            |
// ---------+--------------------------+--------------------------------------+
// 05/10/23 | Pedro Almeida - Cod.ERP  | Rotina Automática			          |
*******************************************************************************

User Function GeraOp(cProduto, nQuant)

    //campos obrigatórios C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,C2_LOCAL,C2_QUANT,C2_UM,C2_DATPRI,C2_DATPRF,C2_EMISSAO,C2_TPPR,C2_TPOP
	Local aItens := {}
    Local cNumOp := ""
	Local aInfos := {}

	private lMsErroAuto := .F.
	DBSelectArea("SC2")
    DBSetOrder(1)

	aadd(aItens,{"C2_FILIAL" ,   cFilAnt 	              ,    Nil})
	aadd(aItens,{"C2_PRODUTO",   cProduto				  ,    Nil})
	aadd(aItens,{"C2_QUANT"  ,   nQuant				      ,    Nil})
	aadd(aItens,{"C2_DATPRI" ,   dDataBase		          ,    Nil})
	aadd(aItens,{"C2_DATPRF" ,   dDataBase + 1	          ,    Nil})

/*	Não é necessário --- 24/10/23 --- Carolina Tavares
    cCodFor := GetNumSc2()
    //cCodFor := GetSXENum("SC2","C2_NUM") não usar
	//aadd(aItens,{"C2_LOCAL"  ,   cLocal				      ,    Nil})
	//aadd(aItens,{"C2_NUM"    ,   cCodFor                  ,    Nil})
	//aadd(aItens,{"C2_TPPR"   ,   cTipoProd		          ,    Nil})
	//aadd(aItens,{"C2_TPOP"   ,   cTipoOp	              ,    Nil})
*/

	MsExecAuto({|x,y| Mata650(x,y)},aItens,3)

	If  lMsErroAuto
		MSGINFO( "Erro na rotina automática", "Atenção" )
		Mostraerro()
		/* aadd(aInfos,  cProduto) 
		aadd(aInfos,   nQuant)
		aadd(aInfos, cNumOp )
		aadd(aInfos,  cLocal)  */
		SC2->(DBCLOSEAREA())
	else
		MsgInfo("Ordem de Produção gerada com sucesso","Aviso")
        cNumOp := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN //retirar depois
		ConfirmSX8()
/*         aadd(aInfos,  cProduto)
		aadd(aInfos,   nQuant)
		aadd(aInfos,  cLocal) */
		aadd(aInfos, cNumOp)
		SC2->(DBCLOSEAREA())
	Endif
SC2->(DBCLOSEAREA())
return aInfos

*******************************************************************************
// Função : GeraMI - Função Automática para movimentar estoque interno para OP|
// Modulo : ""                                                                |
// Fonte  : ExcAOp.prw                                                        |
// ---------+--------------------------+--------------------------------------+
// Data     | Autor             	   | Descricao                            |
// ---------+--------------------------+--------------------------------------+
// 05/10/23 | Pedro Almeida - Cod.ERP  | Rotina Automática			          |
*******************************************************************************

User Function GeraMI(/* cCodProd,nQuant,cLote,  */aArray, cNumOp,cCodigoTM)

	/*	27/10/23 --- Carolina Tavares
		aArray[i][1] // COD
		aArray[i][2] // QUANT
		aArray[i][3] // LOTE
	*/

	Local aItens := {}
	local aCab := {}
	Local aItem := {}
	Local i := 0
	Local xRet := .F.

	lMsErroAuto := .F.
	DBSelectArea("SD3")
    DBSetOrder(1)
	aCab 	:= {{"D3_TM" ,			cCodigoTM 				, 	NIL},;
				{"D3_EMISSAO" ,		ddatabase		   	    , 	NIL}}
		/* {"D3_DOC" , GetSXENum("SC3","D3_DOC"), 	NIL},; */

	For i := 1 to len(aArray)

		aItens := { {"D3_COD"	  ,     aArray[i][1]   ,    Nil},;
				{"D3_QUANT"       ,     aArray[i][2]   ,    Nil},;
				{"D3_LOTECTL"     ,     aArray[i][3]  ,    Nil},;
				{"D3_OP"	      ,     cNumOp         ,    Nil}}
				//{"D3_LOCAL"   ,       	cLocal     ,    Nil},;

		aadd(aItem,aItens)

	Next i
		MsExecAuto({|x,y,z| Mata241(x,y,z)},aCab,aItem,3)

	If  lMsErroAuto
		MSGINFO( "Erro na rotina automática", "Atenção" )
		Mostraerro()
	else
		xRet := .T.
		MsgInfo("Requisição gerada com sucesso","Aviso")
	Endif
	SD3->(DBCLOSEAREA())

return xRet

*******************************************************************************
// Função : ApontaOp - Função Automática para apontar uma ordem de produção   |
// Modulo : ""                                                                |
// Fonte  : ExcAOp.prw                                                        |
// ---------+--------------------------+--------------------------------------+
// Data     | Autor             	   | Descricao                            |
// ---------+--------------------------+--------------------------------------+
// 05/10/23 | José Antônio Machado - Cod.ERP  | Rotina Automática	          |
*******************************************************************************

User Function ApontaOp(cNumOp,cTPMovime, cMaq, cLote)

    //campos obrigatórios D3_OP,D3_TM
	Local aItens := {}
	Local xRet := .F.

	lMsErroAuto := .F.

	aadd(aItens,{"D3_OP"   ,       	cNumOp  ,    Nil})
	aadd(aItens,{"D3_TM"   ,       	cTPMovime     ,    Nil})
	aadd(aItens,{"D3_PERDA",     	  0 	,    Nil})
	aadd(aItens,{"D3_XRECURS",     	  cMaq 	,    Nil})
	aadd(aItens,{"D3_QUANT",     	  1 	,    Nil})
	aadd(aItens,{"D3_LOTECTL",     	 cLote  	,    Nil})

	MsExecAuto({|x,y| Mata250(x,y)},aItens,3)

	If  lMsErroAuto
		MSGINFO( "Erro na rotina automática." , "Atenção"  )
		Mostraerro()
	else
		
		xRet := .T.
		MsgInfo("Apontamento de Produção gerado com sucesso!","Aviso")
	Endif

return xRet


User Function  tstch() //rotina de teste p chamar

    Local aArray:= {}
    Local cTPMovime := "001"
	Local cMaq := "01"
	Local cLote := "L223585" //Local cLote := "FAN270723"    //
	Local nQuant := 11
	Local cProduto := "0201000003" //Local cProduto := "11"
/* 	Local cLocal := "01"
	Local cTipoProd := "1"
	Local cTipoOp := "F"
 	Local cCodigoTM := "501"
*/



	//gera a op retornando as informações para os movimentos internos
/* 	aArray := u_GeraOp("0201000002","02",10,"1","F")
 */	aArray := u_GeraOp(cProduto, nQuant)

	//u_GeraMI(cProCod,nQuant,cNumOp,cLocal,cLote,"501")
	//gera o movimento interno de requisição para a op, ainda para testar, necessário que o ambiente da petinho esteja como exclusivo(já solicitado)

	//u_GeraMI(aArray[1],aArray[2],aArray[3],aArray[4],cLote,cCodigoTM)
	//Criar apontamento para a op
	u_ApontaOp(aArray[3],cTPMovime,cMaq,cLote)

return

//op->mov interna->apontamento de produção
