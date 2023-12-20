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
    Local nQtde    := 0
    Local cProduto := ""
    Local cLocal   := ""

    IF INCLUI
        nPesoBR  := SF1->F1_PBRUTO
        aRet     := RetQtdeD1(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
        cProduto := aRet[1]
        cLocal   := aRet[2]
        nQtde    := aRet[3]
        U_BaseSeca(cProduto, cLocal, nQtde, nPesoBR)
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

Static Function RetQtdeD1(cChave)
    Local aAreaSF1 := GetArea()
    Local nQtde    := 0
    Local cProduto := ""
    Local cLocal   := ""

    DbSelectArea("SD1")
    SD1->(DbSetOrder(1))
    If SD1->(DbSeek(cChave))
        cProduto := SD1->D1_COD
        cLocal   := SD1->D1_LOCAL
        While SD1->(!EOF()) .And. cChave == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
            nQtde += SD1->D1_QUANT
            SD1->(DbSkip())
        End
    End    
    RestArea(aAreaSF1)

Return {cProduto, cLocal, nQtde}
