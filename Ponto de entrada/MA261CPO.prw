#INCLUDE'Protheus.ch'
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
 
User Function MA261CPO()
//Local nx
Local aTam := {}
//local aClone := {}
//local aFim := {}
//local nEndOrig := aScan(aHeader,{|x| AllTrim(x[1]) == 'Endereco Orig.' })
//local nProDest := aScan(aHeader,{|x| AllTrim(x[1]) == 'Prod.Destino' })
//local nDscDest := aScan(aHeader,{|x| AllTrim(x[1]) == 'Desc.Destino' })
//local nUmDest  := aScan(aHeader,{|x| AllTrim(x[1]) == 'UM Destino' })
//local nEndDest := aScan(aHeader,{|x| AllTrim(x[1]) == 'Endereco Destino' })
//local nSubL    := aScan(aHeader,{|x| AllTrim(x[1]) == 'Sub-Lote' })
//local nValid   := aScan(aHeader,{|x| AllTrim(x[1]) == 'Validade' })
//local nPotenc  := aScan(aHeader,{|x| AllTrim(x[1]) == 'Potencia' })
//local nSeq     := aScan(aHeader,{|x| AllTrim(x[1]) == 'Sequencia' })
//local nLoteDes := aScan(aHeader,{|x| AllTrim(x[1]) == 'Lote Destino' })
//local nValiDest:= aScan(aHeader,{|x| AllTrim(x[1]) == 'Validade Destino' })
//local nItemGr  := aScan(aHeader,{|x| AllTrim(x[1]) == 'Item Grade' })

//For nx := 1 to len(aHeader)
//    If nx <> nSubL .AND. nx <> nEndOrig .AND. nx <> nProDest .AND. nx <> nDscDest .AND. nx <> nUmDest .AND. nx <> nEndDest ;
//    .AND. nx <> nValid .AND. nx <> nPotenc .AND. nx <> nSeq .AND. nx <> nLoteDes .AND. nx <> nValiDest .AND. nx <> nItemGr
//        aadd(aClone,aHeader[nx])    
//    EndIf
//Next
//For nx := 1 to len(aHeader)
//    If nx == nSubL .OR. nx == nEndOrig .OR. nx == nProDest .OR. nx == nDscDest .OR. nx == nUmDest .OR. nx == nEndDest ;
//    .OR. nx == nValid .OR. nx == nPotenc .OR. nx == nSeq .OR. nx == nLoteDes .OR. nx == nValiDest .OR. nx == nItemGr  
//        aadd(aFim,aHeader[nx])
//    EndIf
//Next
//aHeader := aCLONE
aTam := TamSX3('D3_QTDREST')
Aadd(aHeader, {'Quantidade Necessária', 'D3_QTDREST', PesqPict('SD3', 'D3_QTDREST', aTam[1]), aTam[1], aTam[2], '', USADO, 'C', 'SD3', ''})
aTam := TamSX3('D3_SALDO')
Aadd(aHeader, {'Saldo', 'D3_SALDO', PesqPict('SD3', 'D3_SALDO', aTam[1]), aTam[1], aTam[2], '', USADO, 'C', 'SD3', ''})
aTam := TamSX3('D3_QTDOP')
Aadd(aHeader, {'Quant. Ja Transferida', 'D3_QTDOP', PesqPict('SD3', 'D3_QTDOP', aTam[1]), aTam[1], aTam[2], '', USADO, 'C', 'SD3', ''})
//For nx := 1 To len(aFim) 
//    Aadd(aHeader,aFim[nx])
//Next
Return Nil
