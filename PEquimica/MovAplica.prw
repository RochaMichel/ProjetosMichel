
#Include 'Protheus.ch'
#Include 'RwMake.ch'
#Include 'TopConn.ch'


User Function MovAplica(aItenNF)
	Local aCab      := {}
	Local aItem     := {}
	Local aItens    := {}
	Local nT        := 1
	Local cCodTM    := GETMV("MV_XTMAPLI",,"501")
	Local cDoc		:= GetSxeNum("SD3","D3_DOC")
	Private lMsErroAuto := .f. //necessario a criacao

	//Verifica sequencia de documento
	If dbSeek(xFilial("SD3")+cDoc)
		cMay := "SD3"+Alltrim(xFilial("SD3"))+cDoc
		While SD3->(D3_FILIAL+D3_DOC)==xFilial("SD3")+cDoc .Or. !MayIUseCode(cMay)
			If SD3->(D3_FILIAL+D3_DOC)==xFilial("SD3")+cDoc
				If D3_ESTORNO # "S"
					cDoc := Soma1(cDoc)
				EndIf
				SD3->(dbSkip())
			Else
				cDoc := Soma1(cDoc)
			EndIf
			cMay := "SD3"+Alltrim(xFilial("SD3"))+cDoc
		EndDo
	Endif

	aCab := {{"D3_DOC",  cDoc		, NIL},;
		{"D3_TM"      , cCodTM      , NIL},;
        {"D3_CC"      , aItenNF[1,4], NIL},;
		{"D3_EMISSAO" , dDataBase   , NIL}}

	For nT:=1 to Len(aItenNF)

		aItem := {{"D3_COD" , aItenNF[nT,1] 	, NIL},;
			{"D3_QUANT"   	, aItenNF[nT,3]   	, NIL},;
			{"D3_XCHVTR"	, aItenNF[nT,5]   	,NIL},;
			{"D3_LOCAL"   	, aItenNF[nT,2]   	, NIL}}

		aadd(aItens, aItem)
	Next
	MSExecAuto({|x,y,z| MATA241(x,y,z)}, aCab, aItens, 3)
	If lMsErroAuto
		Mostraerro()
		DisarmTransaction()
		break
	EndIf
Return
//--------------------------------------------------------------------------------------------------
User function DelAplic(cChave)

	Local aArea := GetArea()
	Local cDocumento := ""
	Local lFound     := .F.
	Local aCab       := {}
	Local aItens     := {}
	Local aTotItem   := {}
	Local cCodTM     := GETMV("MV_XTMAPLI",,"501")
	Private lMsErroAuto := .f. //necessario a criacao
	dbSelectArea("SD3")
	dbOrderNickName("CHVSD1")
	dbSeek(xFilial()+cChave)
	While !Eof() .and. xFilial()+Alltrim(cChave) == SD3->(D3_FILIAL+Alltrim(D3_XCHVTR))
		If Empty(SD3->D3_ESTORNO) .and. Alltrim(cCodTM) == Alltrim(SD3->D3_TM)
			cDocumento := SD3->D3_DOC
			lFound := .T.
			Exit
		Endif
		dbSkip()
	End
	If lFound .and. !Empty(cDocumento)
		dbSelectArea("SD3")
		dbSetOrder(2)
		If dbSeek(xFilial()+cDocumento)
			aCab 	:= {{"D3_DOC"		,cDocumento      ,nil},;
				{"D3_TM"		,SD3->D3_TM      ,NIL},;
				{"D3_EMISSAO"   ,SD3->D3_EMISSAO ,nil}}
			While !Eof() .and. xFilial()+cDocumento == SD3->(D3_FILIAL+D3_DOC)
				If Alltrim(cChave) == Alltrim(SD3->D3_XCHVTR)
					aItens:={}
					aAdd(aItens,{"D3_COD"		,SD3->D3_COD})
					aAdd(aItens,{"D3_LOCAL"		,SD3->D3_LOCAL})
					aAdd(aItens,{"D3_QUANT"		,SD3->D3_QUANT})
					aAdd(aItens,{"D3_LOTECTL"	,SD3->D3_LOTECTL})
					aAdd(aItens,{"D3_NUMLOTE"	,SD3->D3_NUMLOTE})
					aAdd(aItens,{"D3_DTVALID"	,SD3->D3_DTVALID})
					aAdd(aItens,{"D3_NUMSEQ"	,SD3->D3_NUMSEQ})
					aAdd(aItens,{"INDEX",2,})
					Aadd(aTotItem, aItens)
				Endif
				dbSkip()
			End
			If Len(aCab) > 0 .and. Len(aTotItem) > 0
				dbSelectArea("SD3")
				dbSetOrder(2)
				dbSeek(xFilial()+cDocumento)
				MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,atotitem, 6)
				If lMsErroAuto
					// Erro no estorno da SD3 pelo MsExecAuto
					MostraErro()
				EndIf
			Endif
		Endif
	Endif
	RestArea(aArea)
Return
