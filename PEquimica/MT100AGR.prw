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
Descrição 	|	O ponto de entrada é chamado após a confirmação da NF,                    |
|	porém fora da transação. Isto foi feito pois clientes que                 |
|	utilizavam TTS e tinham interface com o usuario no ponto                  |
|	MATA100 "travavam" os registros utilizados, causando                      |
|	parada para outros usuarios que estavam acessando a base.                 |
-------------------------------------------------------------------------------------------
Uso		 	|   MT100AGR.prw			                                  	              |
-------------------------------------------------------------------------------------------
/*/

User Function MT100AGR()
	Local nPesoBR  := 0
	Local aRet     := {}
	Local aRetAp   := {}
	Local nQtde    := 0
	Local i        := 0
	Local cProduto := ""
	Local cGrupo   := ""
	Local cLocal   := ""
	Local cLote    := ""

	aRet     := RetQtdeD1(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
	IF !INCLUI .AND. !ALTERA
		cGrupo := posicione("sb1",1,xfilial("sb1")+aRet[1],"B1_GRUPO")
		If Alltrim(cGrupo) == GetMv('MV_XGPBASE',,'002') .AND. Posicione('SF4',1,xFilial('SF4')+SD1->D1_TES,'F4_ESTOQUE') == 'S'
			U_DelBaseS(SF1->F1_DOC)
		EndIF
	EndIf
	IF INCLUI
		aRetAp   := RtItensD1(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
		cGrupo := posicione("sb1",1,xfilial("sb1")+aretAp[1][1],"B1_GRUPO")
		If Alltrim(cGrupo) == GetMv('MV_XGPBASE',,'002') .AND. Posicione('SF4',1,xFilial('SF4')+SD1->D1_TES,'F4_ESTOQUE') == 'S'
			//If SF1->F1_XBASESC == '1'
			nPesoBR  := SF1->F1_PBRUTO
			cProduto := aRet[1]
			cLocal   := aRet[2]
			cLote    := aRet[4]
			nQtde    := aRet[3]
			U_BaseSeca(SF1->F1_DOC,cProduto, cLocal, nQtde, nPesoBR,cLote)
		EndIf
		//EndIf
		For i := 1 to len(aRetAp)
			If CMPDIR(aRetAp[i])
				U_MovAplica(aRetAp[i][1], aRetAp[i][2], aRetAp[i][3])
			EndIf
		Next
	EndiF
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
	Local aArea := GetArea()
	local		cAlias := GetNextAlias()
	local lRet := .F.
	BeginSql Alias cAlias
    	Select  C7_XCMPDIR From %Table:SD1% D1
    	INNER JOIN %Table:SC7% C7 On C7_FILIAL = D1_FILIAL AND C7_NUM = D1_PEDIDO AND C7_ITEM = D1_ITEMPC
    	WHERE D1.%NotDel% And C7.%NotDel% 
    	And C7_NUM = %Exp:aRetAp[4]% AND C7_ITEM = %Exp:aRetAp[5]%  AND C7_FILIAL = %Exp:SF1->F1_FILIAL%
    	And D1_COD = %Exp:aRetAp[1]% AND D1_LOCAL = %Exp:aRetAp[2]% 
	EndSql
	If (cAlias)->C7_XCMPDIR == '1'
		lret := .T.
	EndIf
	(cAlias)->(DbCloseArea())
	RestArea(aArea)
return lRet

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
			aAdd(aDados,aLinha)
			SD1->(DbSkip())
		End
	EndIf
	RestArea(aAreaSF1)

Return aDados


