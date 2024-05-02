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
		AjSaldoBS(cNota ,cProduto, cLocal, nPesoB - nQtde, cLote)
	Endif

Return



user function DelBaseS(cDocumento)
	Local aArea    := FWGetArea()
    Local aAreaSD3
    Local aCab     := {}
    Local aItens   := {}
    Local aItem    := {}
    Local cChave   := ""
    Private lMsErroAuto := .F.
  
    DbSelectArea("SD3")
    SD3->(DbSetOrder(2)) // D3_FILIAL + D3_DOC + D3_COD
    If SD3->(MsSeek(FWxFilial('SD3') + cDocumento))
        aAreaSD3 := SD3->(FWGetArea())
        cChave   := SD3->D3_FILIAL + SD3->D3_DOC
  
        aCab := {;
            {"D3_DOC", SD3->D3_DOC, Nil};
        }
  
        ProcRegua(0)
        While ! SD3->(EoF()) .And. SD3->D3_FILIAL + SD3->D3_DOC == cChave
            IncProc("Adicionando produto " + Alltrim(SD3->D3_COD) + "...")
  
            aItem := {}
            aAdd(aItem, {"D3_COD",     SD3->D3_COD,   Nil})
            aAdd(aItem, {"D3_UM",      SD3->D3_UM,    Nil})
            aAdd(aItem, {"D3_QUANT",   SD3->D3_QUANT, Nil})
            aAdd(aItem, {"D3_LOCAL",   SD3->D3_LOCAL, Nil})
            aAdd(aItem, {"D3_ESTORNO", "S",           Nil})
            aAdd(aItens, aClone(aItem))
  
            SD3->(DbSkip())
        EndDo

        FWRestArea(aAreaSD3)
  
        MsExecAuto({|x, y, z| MATA241(x, y, z)}, aCab, aItens, 6)
  
        If lMsErroAuto
            MostraErro()
        Else
            FWAlertSuccess("Documento foi estornado com sucesso!", "Atenção")
        EndIf
  
    Else
        FWAlertError("Documento não foi encontrado!", "Atenção")
    EndIf
  
    FWRestArea(aArea)
return

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

	aCab := {{"D3_DOC", cNota    , NIL},;
		{"D3_TM"      , cCodTM   , NIL},;
		{"D3_EMISSAO" , dDataBase, NIL}}

	aItem := {{"D3_COD"  , cProduto , NIL},;
			{"D3_QUANT"  , nQtdAj   , NIL},;
			{"D3_LOCAL"  , cLocal   , NIL},;
			{"D3_CF"     , "DE6"    , NIL},;
			{"D3_CUSTO1" , 0.00     , NIL} ,;
			{"D3_LOTECTL", cLote    , NIL}}

	aadd(aItens, aItem)

	MSExecAuto({|x,y,z| MATA241(x,y,z)}, aCab, aItens, 3)

	If lMsErroAuto
		Mostraerro()
		DisarmTransaction()
		break
	Else
		RecLock('SD3',.F.)
		SD3->D3_CUSTO1 := 0
		SD3->D3_CF := "DE6"
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
