#Include 'Protheus.ch'

User function Solict
	Local nNum   := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_NUMSC' })
	Local nItem  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_ITEMSC' })
	Local nCmpDir  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_XCMPDIR' })
	local n := 0
	local laltera := .T.
	DbSelectArea('SC1')
	DbSetOrder(1)
	for n := 1 to len(aCols)
		if !Empty(acols[n][nNum])
			if DbSeek(xFilial('SC1')+acols[n][nNum]+acols[n][nItem])
				aCols[n][nCmpDir] := SC1->C1_XCMPDIR
				laltera := .F.
			EndIf
		EndIf
	next n
	If laltera == .F.
		MsgInfo('Compra direta preenchida na Solicitação não pode ser alterada')
	EndIf
return laltera

User function GatSolict
	Local nNum   := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_NUMSC' })
	Local nItem  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_ITEMSC' })
	Local nCmpDir  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_XCMPDIR' })
	local i := 0
	DbSelectArea('SC1')
	DbSetOrder(1)
	for i := 1 to len(aCols)
		if DbSeek(xFilial('SC1')+acols[i][nNum]+acols[i][nItem])
			aCols[i][nCmpDir] := SC1->C1_XCMPDIR
		EndIf
	next i
return aCols[n][nCmpDir] 
