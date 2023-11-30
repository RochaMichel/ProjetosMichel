#include 'TOTVS.CH'
/*/{Protheus.doc} FSCR007
Ponto de entrada executado após preenchimento da linha da grid
@type function
@author Michel Rocha Cod.erp 
@since 23/03/2023
@return 
/*/
User Function MA261LIN()
	Local lRet := .T.
	Local i
    Local nQtd := 0
	Local nRest  := aScan(aHeader,{|x| AllTrim(x[2]) == 'D3_QTDREST' })
	Local nArmDest := aScan(aHeader,{|x| AllTrim(x[1]) == 'Armazem Destino' })
	Local nArmLoc := aScan(aHeader,{|x| AllTrim(x[2]) == 'D3_LOCAL' })
	Local nProd  := aScan(aHeader,{|x| AllTrim(x[2]) == 'D3_COD' })
	Local nSaldo := aScan(aHeader,{|x| AllTrim(x[2]) == 'D3_SALDO' })
	Local nQuant := aScan(aHeader,{|x| AllTrim(x[2]) == 'D3_QUANT' })
	Local nQtdOp := aScan(aHeader,{|x| AllTrim(x[2]) == 'D3_QTDOP' })
    Local aAreaD3 := SD3->(GetArea())
	//Local nLinha := PARAMIXB[1]  // numero da linha do aCols// 'Validações Adicionais do Usuario
	//DbSelectArea('SC2')
	//SC2->(DbSetOrder(1))
	//If SC2->(DbSeek(Alltrim(SD3->D3_OP)))
	DbSelectArea('SB2')
	For i := 1 to len(aCols)
		Sb2->(DbSetOrder(1))
		If Sb2->(dbseek(SD3->D3_FILIAL+aCols[i][nProd]+aCols[i][nArmDest]))
			aCols[i][nSaldo] := SaldoSB2() // Está exibindo o Saldo do armazem destino
			 // exibindo a quantidade necessaria para a transferencia
		EndIf
        SD3->(DbsetOrder(1))
		If SD3->(dbseek(cFilant+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD+aCols[i][nProd]+aCols[i][nArmLoc]))
            while AllTrim(SD3->D3_OP) == AllTrim(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD) .AND. AllTrim(SD3->D3_COD) == AllTrim(aCols[i][nProd])
                If val(SD3->D3_TM) > 500 
                nQtd += SD3->D3_QUANT
                EndIf
                SD3->(dbSkip())
            End
            aCols[i][nQtdOp] := nQtd
			aCols[i][nRest] := aCols[i][nQuant] - nQtd
            nQtd := 0
        Else
            aCols[i][nQtdOp] := 0   
		EndIF
	Next
	oGet:Refresh()
    RestArea(aAreaD3)
	//EndIf
Return lRet

