#Include 'Protheus.ch'

/*/
-------------------------------------------------------------------------------------------
Funcao		|	BaseSeca                                                                  |
-------------------------------------------------------------------------------------------
Data		|	19/12/2023                                                                |
-------------------------------------------------------------------------------------------
Chamada		|	MT100AGR                                                                  |
-------------------------------------------------------------------------------------------
Descrição 	|	Função para verificar a diferença no peso e gerar o movimento de ajuste   |
-------------------------------------------------------------------------------------------
Uso		 	|   MT100AGR.prw			                                  	              |
-------------------------------------------------------------------------------------------
/*/
User Function BaseSeca(cProduto, cLocal, nQtde, nPesoB)

    If nQtde < nPesoB
        //Realiza movimento de ajuste de saldo
        AjSaldoBS(cProduto, cLocal, nPesoB - nQtde)
    Endif

Return

/*/
-------------------------------------------------------------------------------------------
Funcao		|	AjSaldoBS                                                                 |
-------------------------------------------------------------------------------------------
Data		|	19/12/2023                                                                |
-------------------------------------------------------------------------------------------
Chamada		|	BaseSeca                                                                  |
-------------------------------------------------------------------------------------------
Descrição 	|	Função para gerar o movimento de ajuste de estoque                        |
-------------------------------------------------------------------------------------------
Uso		 	|   BaseSeca.prw			                                  	              |
-------------------------------------------------------------------------------------------
/*/

Static Function AjSaldoBS(cProduto, cLocal, nQtdAj)
    Local aCab      := {}
    Local aItem     := {}
    Local aItens    := {}
    Local cCodTM    := GETMV("MV_XTMBASE",,"001")

    Private lMsErroAuto := .f. //necessario a criacao

    aCab := {{"D3_DOC"     , NextNumero("SD3",2,"D3_DOC",.T.) , NIL},;
             {"D3_TM"      , cCodTM                           , NIL},;
             {"D3_EMISSAO" , dDataBase                        , NIL}}


    aItem := {{"D3_COD"     , cProduto , NIL},;
              {"D3_QUANT"   , nQtdAj   , NIL},;
              {"D3_LOCAL"   , cLocal   , NIL} }

    aadd(aItens, aItem) 
    
    MSExecAuto({|x,y,z| MATA241(x,y,z)}, aCab, aItens, 3)

    If lMsErroAuto 
        Mostraerro() 
        DisarmTransaction() 
        break
    EndIf

Return
