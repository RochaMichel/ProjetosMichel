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
User Function BaseSeca(cNota,cProduto, cLocal, nQtde, nPesoB,cLote)

	If nQtde < nPesoB
		//Realiza movimento de ajuste de saldo
		AjSaldoBS(cNota ,cProduto, cLocal, nPesoB - nQtde, cLote)
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

Static Function AjSaldoBS(cNota,cProduto, cLocal, nQtdAj,cLote)
	Local aCab      := {}
	Local aItem     := {}
	Local aItens    := {}
	Local cCodTM    := GETMV("MV_XTMBASE",,"002")

	Private lMsErroAuto := .f. //necessario a criacao

	aCab := {{"D3_DOC"     , cNota , NIL},;
		{"D3_TM"      , cCodTM   , NIL},;
		{"D3_EMISSAO" , dDataBase, NIL}}

	aItem := {{"D3_COD"     , cProduto , NIL},;
		{"D3_QUANT"   , nQtdAj   , NIL},;
		{"D3_LOCAL"   , cLocal   , NIL},;
		{"D3_CUSTO1"  , 0.00     , NIL} ,;
		{"D3_LOTECTL"  , cLote     , NIL} }

	aadd(aItens, aItem)

	MSExecAuto({|x,y,z| MATA241(x,y,z)}, aCab, aItens, 3)

	If lMsErroAuto
		Mostraerro()
		DisarmTransaction()
		break
	Else
		RecLock('SD3',.F.)
		SD3->D3_CUSTO1 := 0
		SD3->(MsUnlock())
		//Identifica que será executado via JOB
		lJob := .T.

		cPerg := "MTA300"
		DbSelectArea('SB2')
		SB2->(DbSetOrder(1))
		SB2->(DbSeek(xFilial('SB2')+cProduto))
		Pergunte(cPerg, .F.)
		lMsErroAuto := .F.
		MSExecAuto({|x| MATA300(x)}, lJob)
	EndIf

Return
