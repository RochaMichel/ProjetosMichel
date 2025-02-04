#include "rwmake.ch"
#INCLUDE "colors.ch"

/*/
-------------------------------------------------------------------------------------------
Funcao		|	MT100AGR                                                                  |
-------------------------------------------------------------------------------------------
Data		|	19/12/2023                                                                |
-------------------------------------------------------------------------------------------
Chamada		|	MT100AGR                                                                  |
-------------------------------------------------------------------------------------------
Descrição 	|	O ponto de entrada é chamado após a confirmação da NF,                     |
|	porém fora da transação. Isto foi feito pois clientes que                 |
|	utilizavam TTS e tinham interface com o usuario no ponto                  |
|	MATA100 "travavam" os registros utilizados, causando                      |
|	parada para outros usuarios que estavam acessando a base.                 |
-------------------------------------------------------------------------------------------
Uso		 	|   MT100AGR.prw			                                  	              |
-------------------------------------------------------------------------------------------
/*/

User Function MT100AGR()
	Local aArea    := GetArea()
	Local nPesoBR  := 0
	Local aRet     := {}
	Local aRetAp   := {}
	Local nQtde    := 0
	Local i        := 0
	Local cProduto := ""
	Local cGrupo   := ""
	Local cLocal   := ""
	Local cLote    := ""
	Local lContinua := .F.
	Local cChave   := SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
	Local aItenNF  := {}
	aRet     := RetQtdeD1(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
	IF !INCLUI .AND. !ALTERA
		dbSelectArea("SD1")
		dbSetOrder(1)
		If !dbSeek(xFilial()+cChave)
			lContinua := .T.
		Else
			If Empty(SD1->D1_TES)
				lContinua := .T.
			Endif
		Endif
		If lContinua
			u_DelAplic(cChave)
		Endif
	EndIf
	IF INCLUI .or. (ALTERA .and. l103Class)
		//If AllTrim(SF1->F1_ESPECIE) == GetMV('MV_XESPPG',,'NFPS')
		//	cCond := Posicione('SE4',1,xFilial('SE4')+SF1->F1_COND,'E4_COND')
		//	U_CriaPag(SF1->F1_FILIAL,SF1->F1_SERIE,SF1->F1_DOC,AllTrim(SED->ED_CODIGO),SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_EMISSAO,SRK->RK_VALORPA,SD1->D1_CC,AllTrim(cCond))
		//EndIf
		aRetAp := RtItensD1(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
		cGrupo := posicione("sb1",1,xfilial("sb1")+aretAp[1][1],"B1_GRUPO")
		If Alltrim(cGrupo) == GetMv('MV_XGPBASE',,'002') .AND. Posicione('SF4',1,xFilial('SF4')+SD1->D1_TES,'F4_ESTOQUE') == 'S'
			//If SF1->F1_XBASESC == '1'
			nPesoBR  := SF1->F1_PBRUTO
			cProduto := aRet[1]
			cLocal   := aRet[2]
			cLote    := aRet[4]
			nQtde    := aRet[3]
			U_BaseSeca(SF1->F1_DOC,cProduto, cLocal, nQtde, nPesoBR,cLote, cChave)
		EndIf
		//EndIf
		For i := 1 to len(aRetAp)
			If !Empty(aRetAp[i,4]) .and. CMPDIR(aRetAp[i])
				cTipo := posicione("sb1",1,xfilial("sb1")+aRetAp[i][1],"B1_TIPO")
				If cTipo $ GetMV('MV_XCMPDIR',,"07")
					//SD1->()
					//SD1->()
					//Reclock('SD1',.F.)
					//SD1->D1_XCMPDIR := 'Compra direta'
					//SD1->(MsUnlock())
					aadd(aItenNF, {aRetAp[i][1], aRetAp[i][2], aRetAp[i][3],aRetAp[i][6], cChave})
				EndIf
			EndIf
		Next
		If Len(aItenNF) > 0
			U_MovAplica(aItenNF)
		Endif
	EndiF
	RestArea(aArea)
Return

/*/
	-------------------------------------------------------------------------------------------
	Funcao		|	RetQtdeD1                                                                 |
	-------------------------------------------------------------------------------------------
	Data		|	19/12/2023                                                                |
	-------------------------------------------------------------------------------------------
	Chamada		|	RetQtdeD1                                                                 |
	-------------------------------------------------------------------------------------------
	Descrição 	|	Função para retornar o codigo do produto, armazem e quantidade da nota    |
	-------------------------------------------------------------------------------------------
	Uso		 	|   MT100AGR.prw			                                  	              |
	-------------------------------------------------------------------------------------------
/*/

Static Function CMPDIR(aRetAp)
	Local aArea    := GetArea()
	Local aAreaSC7 := SC7->(GetArea())
	local lRet     := .F.
	dbSelectArea("SC7")
	dbSetOrder(1)
	If dbSeek(xFilial()+aRetAp[4]+aRetAp[5]) .and. SC7->C7_PRODUTO == aRetAp[1] .and. SC7->C7_LOCAL == aRetAp[2] .and. SC7->C7_XCMPDIR == "1"
		lret := .T.
	EndIf
	RestArea(aAreaSC7)
	RestArea(aArea)
return lRet
//------------------------------------------------------------------------------------------------------------------
Static Function RetQtdeD1(cChave)
	Local aAreaSF1 := GetArea()
	Local nQtde    := 0
	Local cProduto := ""
	Local cLocal   := ""
	Local cLote   := ""

	DbSelectArea("SD1")
	SD1->(DbSetOrder(1))
	If SD1->(DbSeek(cChave))
		cProduto := SD1->D1_COD
		cLocal   := SD1->D1_LOCAL
		cLote  	 := SD1->D1_LOTECTL
		While SD1->(!EOF()) .And. cChave == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
			nQtde += SD1->D1_QUANT
			SD1->(DbSkip())
		End
	EndIf
	RestArea(aAreaSF1)

Return {cProduto, cLocal, nQtde, cLote}

Static Function RtItensD1(cChave)
	Local aAreaSF1 := GetArea()
	Local aDados := {}
	Local aLinha := {}
	DbSelectArea("SD1")
	SD1->(DbSetOrder(1))
	If SD1->(DbSeek(cChave))
		While SD1->(!EOF()) .And. cChave == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
			aLinha := {}
			aAdd(aLinha, SD1->D1_COD)
			aAdd(aLinha, SD1->D1_LOCAL)
			aAdd(aLinha, SD1->D1_QUANT)
			aAdd(aLinha, SD1->D1_PEDIDO)
			aAdd(aLinha, SD1->D1_ITEMPC)
			aAdd(aLinha, SD1->D1_CC)
			aAdd(aDados,aLinha)
			SD1->(DbSkip())
		End
	EndIf
	RestArea(aAreaSF1)

Return aDados


