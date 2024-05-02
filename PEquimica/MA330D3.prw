User Function MA330D3()
	If SD3->D3_TM == GETMV("MV_XTMBASE",,"002")
		RecLock('SD3',.F.)
		SD3->D3_CUSTO1 := 0
		SD3->(MsUnlock())
	EndIf
return
