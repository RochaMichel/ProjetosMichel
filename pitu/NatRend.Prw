#INCLUDE 'TOTVS.CH'

*-------------------------------------------------------------------------------------
/*@nomeFunction: 	  					U_NatRend()							   	  */ *
/*--------------------------------------------------------------------------------*/ *
/*			Função utilizada no gatilho para sugerir a natureza de rendimento 	  */ *
/*			apartir da tabela ZNR - amarração Fornecedor x Produto x Natureza 	  */ *
/*--------------------------------------------------------------------------------*/ *
/*@author: 						Rivaldo JR - Cod.ERP							  */ *
/*@since: 				    	  	   19/04/2024								  */ *
*-------------------------------------------------------------------------------------
User Function NatRend()

	DbSelectArea("ZNR")
	ZNR->(DbSetOrder(1))
	If ZNR->(DbSeek(xFilial("ZNR")+CFORANTNFE+CLOJANTNFE+aCols[n][aScan( aHeader, { |x| Alltrim(x[2])=="D1_COD"})]))
		If INCLUI
			aColsDHR[n][2][1][1] := ZNR->ZNR_NATURE
		Else
			aadd(aColsDHR,{'000'+cValtochar(n),{{ZNR->ZNR_NATURE,.f.}}})
		EndIf
	EndIf

Return aCols[n][aScan( aHeader, { |x| Alltrim(x[2])=="D1_TES"})]
//Return Posicione("SB1",1,xFilial("SB1")+aCols[n][aScan( aHeader, { |x| Alltrim(x[2])=="D1_COD"})],"B1_DESC")
