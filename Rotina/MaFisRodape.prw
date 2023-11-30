Function MaFisRodape(nTipo,;		// Quebra : 1 Imposto+Aliquota,  2-Imposto
	oJanela,;		// Janela onde sera montado
	aImpostos,;	// Relacao de Impostos que deverao aparecer ( Codigo )
	aPos,;			// Array contendo Posicao e Tamanho
	bValidPrg,;	// Validacao executada na Edicao dop Campo
	lVisual,; // So para visualizacao
	cFornIss,; //Fornecedor do ISS
	cLojaIss,; //Loja do Fornecedor do ISS
	aRecSE2,;
	cDirf,;
	cCodRet,;
	oCodRet,;	
	nCombo,;
	oCombo,;
	dVencIss,; 	//Vencimento ISS
	aCodR,;
	cRecIss,;	//Informa se recolhe o ISS ou nao
	oRecIss)

Local oList
Local aTemp                                              
Local aOpcoes := {"Sim","Nao"}
Local oFornIss
Local oLojaIss                     
Local oVencIss
Local oDescri 
                                                                  
Local cDescri  := ""
Local aAreaSE2 := {}
Local aAreaSA2 := {}
Local lFornIss     := .F.
Local nPosDum	:=	0
Local aAUTOISS	:= &(GetNewPar("MV_AUTOISS",'{"","","",""}'))
Local aMaPCCI  := {}
Local nI        := 0
Local nPosCodR  := 0
Local aOpcIss	:=	{"1="+STR0024,"2="+STR0025}

DEFAULT oCodRet := Nil
DEFAULT oCombo  := Nil
DEFAULT nCombo  := 2
DEFAULT dVencIss := CtoD("")
DEFAULT aCodR	:=	{}
DEFAULT oRecIss := Nil
DEFAULT cRecIss := "1"

If nTipo == 1
	If Empty(aNfCab) .OR. Empty(aNfCab[NF_IMPOSTOS])
		aTemp	:= {{"","",0,0,0}}
	Else
		aTemp	:= aNFCab[NF_IMPOSTOS]
	EndIf
Else
	If Empty(aNfCab) .OR. Empty(aNfCab[NF_IMPOSTOS2])
		aTemp	:= {{"","",0,0}}

	Else
		aTemp	:= aNFCab[NF_IMPOSTOS2]
	EndIf
EndIf

bFisRefresh	:= {|| MaFisRRefresh(oList,nTipo)}

If SE2->(FieldPos("E2_FORNISS")) > 0 .AND. SE2->(FieldPos("E2_LOJAISS")) > 0 
	If cFornIss <> NIL .AND. cLojaIss <> NIL

		lFornIss := .T.
			
		aPos[2] := 85 
		aPos[3] -= 80
		@ 03,2 TO 58,84 LABEL '' OF oJanela PIXEL
		@ 06,10 SAY STR0023 Of oJanela PIXEL SIZE 80,09 //"Dados de Cobrança do ISS"
		@ 19,04 SAY RetTitle("E2_FORNISS") Of oJanela PIXEL SIZE 30,09

		If SE2->(FieldPos("E2_VENCISS")) > 0
			@ 46,04 SAY RetTitle("E2_VENCISS")Of oJanela PIXEL SIZE 30,09
		EndIf
		
		If lVisual 
		    
		    If Len(aRecSE2) > 0
		    	aAreaSE2 := SE2->(GetArea())
			    aAreaSA2 := SA2->(GetArea())
		    
			    SE2->(dbGoTo(aRecSE2[1]))
			    cFornIss := SE2->E2_FORNISS 
		    	cLojaIss := SE2->E2_LOJAISS
			    If SA2->(MsSeek(xFilial("SA2")+cFornIss+cLojaIss))
					cDescri := SA2->A2_NREDUZ
				Endif	
				If SE2->(FieldPos("E2_VENCISS")) > 0
			    	dVencIss := SE2->E2_VENCISS
			 	EndIf
			 	
			 	aMaPCCI	:=	MaPCCI()
			 	For nI := 1 To Len( aTemp )
				 	If (nTipo==1)
						If (nPosCodR := aScan(aMaPCCI, {|aX|aX[1]==aTemp[nI][6]}))>0
							aAdd( aCodR, {nI, aMaPCCI[nPosCodR][2], 1, aTemp[nI][6]} )
						EndIf
					Else
						If (nPosCodR := aScan(aMaPCCI, {|aX|aX[1]==aTemp[nI][5]}))>0
							aAdd( aCodR, {nI, aMaPCCI[nPosCodR][2], 1, aTemp[nI][5]} )
						EndIf
					EndIf
				Next
				
				RestArea(aAreaSE2)
				RestArea(aAreaSA2)
		    Endif
			
			@ 18,31 MSGET oFornIss VAR cFornIss ;
			PICTURE PesqPict('SE2','E2_FORNISS')  ;
			OF oJanela PIXEL SIZE 35,09 ;
			READONLY
			                         
			@ 18,67 MSGET oLojaIss VAR cLojaIss ;
			PICTURE PesqPict("SE2","E2_LOJAISS") ;
			OF oJanela PIXEL SIZE 15,09 ;
			READONLY

			If SE2->(FieldPos("E2_VENCISS")) > 0
				@ 44,38 MSGET oVencIss VAR dVencIss ;
				OF oJanela PIXEL READONLY
			EndIf

		Else
		
			// Para montar a descricao quando o fornecedor+loja vem preenchido pelo parametro MV_AUTOISS (Mata103)
			If !Empty(cFornISS) .AND. !Empty(cLojaISS)
			    If SA2->(MsSeek(xFilial("SA2")+cFornIss+cLojaIss))
					cDescri := SA2->A2_NREDUZ
				Endif	
			Endif

			@ 18,31 MSGET oFornIss VAR cFornIss ;
			PICTURE PesqPict('SE2','E2_FORNISS')  ;
			OF oJanela PIXEL SIZE 35,09 ;
			F3 CpoRetF3('E2_FORNISS') ;
			VALID MaVldForn(@cFornIss,@cLojaIss,@oDescri,@cDescri,@oLojaISS,@oFornIss,1)
			                         
			@ 18,67 MSGET oLojaIss VAR cLojaIss ;
			PICTURE PesqPict("SE2","E2_LOJAISS") ;
			OF oJanela PIXEL SIZE 15,09 ;
			F3 CpoRetF3("E2_LOJAISS") ;
			VALID MaVldForn(@cFornIss,@cLojaIss,@oDescri,@cDescri,@oLojaISS,@oFornIss,2) 

			If SE2->(FieldPos("E2_VENCISS")) > 0
				@ 44,38 MSGET oVencIss VAR dVencIss ;
				OF oJanela PIXEL
			EndIf
				
		EndIf 	
			
		@ 31,04 MSGET oDescri VAR cDescri OF oJanela PIXEL SIZE 78,09 WHEN .F. 

	Endif
Endif

If SuperGetMv("MV_VISDIRF",.F.,"1") == "1"

	If cDirf <> NIL .AND. cCodRet <> NIL
	
	   If lVisual
		   cCodRet 	:= 	Space(TamSx3("E2_CODRET")[1])
	       cDirf   	:= 	"2"
	   Else	
			cDirf 	:= 	CriaVar("E2_DIRF",.T.)
			cCodRet := 	CriaVar("E2_CODRET")
			// Verifica se ha a configuracao para preenchimento automatico dos dados de cobranca do ISS
			If aAutoISS<>Nil .And. Len(aAutoISS)==4 .And. !Empty(aAutoISS[03])
				cDirf 	:= 	aAutoISS[03]
				cCodRet	:=	aAutoISS[04]
			EndIf			
		Endif	
	    nCombo	:= aOpcoes[VAL(cDirf)]
	    
		If lFornIss 
			aPos[2] := 170 
			aPos[3] -= 80
			@ 03,85 TO 42,169 LABEL '' OF oJanela PIXEL
			@ 06,93 SAY "DIRF" Of oJanela PIXEL SIZE 80,09 //"Dados de Cobrança do ISS"		
			
			@ 16,89 SAY RetTitle("E2_DIRF") Of oJanela PIXEL SIZE 30,09
			@ 16,125 MSCOMBOBOX oCombo VAR nCombo ITEMS aOpcoes ;					
					ON CHANGE (cDirf := StrZero(oCombo:nAt,1)) ;
					VALID MaGrvCdR(@cCodRet,oCombo,oList,@aCodR,@oCodRet,.F.);
					WHEN !lVisual ;
			        SIZE 40,50 OF oJanela PIXEL	
			@ 27,89 SAY RetTitle("E2_CODRET") Of oJanela PIXEL SIZE 50,09
			@ 27,125 MSGET oCodRet VAR cCodRet F3 "37" ;
					VALID MaGrvCdR(@cCodRet,oCombo,oList,@aCodR,@oCodRet,.T.) ;
					WHEN !lVisual ;
					OF oJanela PIXEL SIZE 40,09 
			@ 42,85 TO 58,169 LABEL '' OF oJanela PIXEL
			@ 47,89 SAY RetTitle("A2_RECISS") Of oJanela PIXEL SIZE 50,09
			@ 46,125 MSCOMBOBOX oRecIss VAR cRecIss ITEMS aOpcIss  ;
					VALID MaFisAlt( "NF_RECISS", cRecIss) ;
					WHEN !lVisual SIZE 40,50 OF oJanela PIXEL	
		Else
		
			aPos[2] := 85 
			aPos[3] -= 80
			@ 03,02 TO 42,84 LABEL '' OF oJanela PIXEL
			@ 06,10 SAY "DIRF" Of oJanela PIXEL SIZE 80,09 //"Dados de Cobrança do ISS"		
			
			@ 16,04 SAY RetTitle("E2_DIRF") Of oJanela PIXEL SIZE 30,09
			@ 16,40  MSCOMBOBOX oCombo VAR nCombo ITEMS aOpcoes ;
					ON CHANGE (cDirf := StrZero(oCombo:nAt,1)) ;
					VALID MaGrvCdR(@cCodRet,oCombo,oList,@aCodR,@oCodRet,.F.) ;
					WHEN !lVisual ;
					SIZE 40,50 OF oJanela PIXEL		
			@ 27,04 SAY RetTitle("E2_CODRET") Of oJanela PIXEL SIZE 50,09
			@ 27,40 MSGET oCodRet VAR cCodRet F3 "37" ;
						VALID MaGrvCdR(@cCodRet,oCombo,oList,@aCodR,@oCodRet,.T.) ;
					WHEN !lVisual ;
					OF oJanela PIXEL SIZE 40,09 
			@ 42,02 TO 58,84 LABEL '' OF oJanela PIXEL
			@ 47,04 SAY RetTitle("A2_RECISS") Of oJanela PIXEL SIZE 50,09
			@ 46,40 MSCOMBOBOX oRecIss VAR cRecIss ITEMS aOpcIss ;
					VALID MaFisAlt( "NF_RECISS", cRecIss) ;
					WHEN !lVisual SIZE 40,50 OF oJanela PIXEL
		Endif	
	Endif
Endif	

If nTipo == 1
	oList := TWBrowse():New( aPos[1],aPos[2],aPos[3],aPos[4],,{STR0003,STR0004,STR0005,STR0006,STR0007},{30,90,50,30,50},oJanela,,,,,,,,,,,,.F.,,.T.,,.F.,,, ) //"Cod."###"Descricao"###"Base Imposto"###"Aliquota"###"Vlr. Imposto"
Else
	oList := TWBrowse():New( aPos[1],aPos[2],aPos[3],aPos[4],,{STR0003,STR0004,STR0005,STR0007},{30,90,50,50},oJanela,,,,,,,,,,,,.F.,,.T.,,.F.,,, ) //"Cod."###"Descricao"###"Base Imposto"###"Vlr. Imposto"
EndIf
If cPaisLoc == "ARG"
	nPosDum	:=	Ascan(aTemp,{|x| x[1] == "DUM"})
	If nPosDum > 0
		aDel(aTemp,nPosDum)
		aSize(aTemp,Len(aTemp)-1)
	Endif	
Endif	
oList:SetArray(aTemp)
If !lVisual
	oList:bLDblClick 	:= {|| MaFisVRodape(oList,bValidPrg,nTipo,oList:nColPos) .AND. MaFisInsereImp(oList,bValidPrg,nTipo)}
EndIf
oList:bChange 		:= {|| MaAtuCdR(@cCodRet,aCodR,oList,oCodRet,oCombo,@nCombo,aOpcoes)}
oList:bLine 		:= {|| MaFisLine(oList,aTemp,nTipo) }
oList:lAutoEdit	:= !lVisual

Return oList
