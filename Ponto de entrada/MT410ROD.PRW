#Include "Protheus.ch"
#Include "TopConn.ch"
 
/*/{Protheus.doc} MT410ROD
P.E.:  MT410ROD :: Função para alterar os dados do rodapé do pedido.
Inclui os impostos no valor total do pedido, onde o mesmo é apresentado no rodapé. 
Obs. Solicitado por Rogerio.
@type function 
@version V1 
@author Helton Silva::RDS Tecnologia
@since 12/9/2021
@see http://tdn.totvs.com/pages/releaseview.action?pageId=6784352     
/*/
User Function MT410ROD()
    Local aArea     := GetArea()
    Local nI 
    Local oObjOrig  := ParamIXB[1]
    Local cDescCli  := ParamIXB[2]
    Local nValBruto := 0
    Local nValLiq   := 0
    Local nValDes   := 0
    For nI:=1 to Len(aCols) 
		nValBruto += GdFieldGet("C6_XPRCORI",nI)*GdFieldGet("C6_QTDVEN",nI)
    Next  
    For nI:=1 to Len(aCols)
		nVAldes += GdFieldGet("C6_XVALDES",nI)
    Next 
    For nI:=1 to Len(aCols)
		nValLiq   += GdFieldGet("C6_VALOR",nI)
    Next

    Eval(oObjOrig,cDescCli, nValBruto,nValDes,nValLiq)
     
    RestArea(aArea)

Return





