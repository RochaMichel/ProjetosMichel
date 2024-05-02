#INCLUDE 'TOTVS.CH'


User Function NatRend()

	DbSelectArea("ZNR")
	ZNR->(DbSetOrder(1))
    If ZNR->(DbSeek(xFilial("ZNR")+CFORANTNFE+CLOJANTNFE+aCols[n][aScan( aHeader, { |x| Alltrim(x[2])=="D1_COD"})]))
        //aAdd(aColsDHR, {{aCols[n][aScan( aHeader, { |x| Alltrim(x[2])=="D1_ITEM"})]},{{{ZNR->ZNR_NATURE}}}})
        //aColsDHR[n][1]       := aCols[n][aScan( aHeader, { |x| Alltrim(x[2])=="D1_ITEM"})]
        aColsDHR[n][2][1][1] := ZNR->ZNR_NATURE
    EndIf

Return Posicione("SB1",1,xFilial("SB1")+aCols[n][aScan( aHeader, { |x| Alltrim(x[2])=="D1_COD"})],"B1_DESC")
