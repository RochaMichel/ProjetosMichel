//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
 
//Constantes
#Define STR_PULA    Chr(13)+Chr(10)
 
/*/{Protheus.doc} u_PMPBHORAS()

@author: Robson Silva
@since 18/04/2023
@version 1.0
    @example
    u_PMPBHORAS()
/*/
 
User Function PMPBHORAS()
    Local  x
    Private aArea        := GetArea()
    Private cQuery        := ""
    Private oFWMsExcel  :=FWMSExcel():New()
    Private oExcel
    Private cArquivo    := GetTempPath()+'zrelbancohoras.xml'
    Private cSalHora    := 0.00
    Private cVlBcoHora  := 0.00
    //Local nHrnormais  := 0.00
    Private nHrpositivas := 0.00
    Private nHrsaldo := 0.00
    Private nHrVlPos := 0.00
	Private nHrVlNeg := 0.00
    Private nHrSaldoVl := 0.00
    Private nHrSld :=0.00
    Private nHrnegativas := 0.00
    Private cCC
    Private nConsolidado :=0
    Private nTHrSld := 0
    Private nThrnegativas:=0
    Private nThrpositivas:=0
    Private nTHrVlNeg:=0
    Private nTHrVlPos :=0
    Private aMatriz := {}
    //Private cDir    := "C:/temp/"
    //Private cArq    := "arquivo_teste.txt"
    //Private nHandle := FCreate(cDir+cArq)
    Private nCount  := 0
    Private cMat :=""
    Private _cFwilial :=""
    Private _cCCusto:=""
    Private _cCdesc:=""
    Private nTPsAn :=0
    Private nTPsNg  :=0
    Private nTpsVlNg :=0
    Private nTpsVlPos :=0
    Private nTpsVlHr :=0
    Private cDesc := ""
    Private nTPsAnt:=0.00
    Private nTPsNgt:=0.00
    Private nTpsVlNgt:=0.00
    Private nTpsVlPost:=0.00
    Private nTpsVlHrt:=0.00
    Private aTotalCC := {}
    Private cPerg := ""
	Private aMatrizAn :={}
    Private cPd
    Private nValHora :=0.00
    Private nValHoraV :=0.00
    //Definições da pergunta
	cPerg := "RELBHORAS  "
    //if nHandle == -1
    //MSGALERT( "txt nao criado" )
    //EndIf

	If !Pergunte(cPerg, .t.)
		Return .f.
	EndIf

    //Alert(MV_PAR09)
    nConsolidado := MV_PAR09


//Montando consulta de dados

cQuery += " SELECT													 			" + STR_PULA
cQuery += " PI_PD,														        " + STR_PULA
cQuery += " SRA.RA_FILIAL,														" + STR_PULA
cQuery += " SRA.RA_MAT,															" + STR_PULA
cQuery += " SRA.RA_NOME,														" + STR_PULA
cQuery += " PI_MAT,																" + STR_PULA
cQuery += " PI_PD,																" + STR_PULA
cQuery += " PI_DATA,																" + STR_PULA
cQuery += " RA_CC,																" + STR_PULA	
//cQuery += " CTT.CTT_DESC01,													    " + STR_PULA	
cQuery += " PI_QUANT,                                                             " + STR_PULA  
cQuery += " PI_QUANTV                                                            " + STR_PULA  
cQuery += " FROM        "+ RetSQLName('SRA') +" AS SRA							" + STR_PULA		
cQuery += " INNER JOIN  "+ RetSQLName('SPI') +" AS PE ON SRA.RA_MAT = PE.PI_MAT	" + STR_PULA		
cQuery += " INNER JOIN  "+ RetSQLName('CTT') +" AS CTT                          " + STR_PULA   
cQuery += " ON CTT_FILIAL = Substring(RA_FILIAL,1,2)  AND PI_CC =CTT_CUSTO	" + STR_PULA		
cQuery += " WHERE (SRA.D_E_L_E_T_ = ' ') AND (PE.D_E_L_E_T_ = ' ') AND (PE.D_E_L_E_T_ = ' ')" + STR_PULA
cQuery += " AND   (PE.PI_STATUS <>	'B')				                        " + STR_PULA	
cQuery += " AND   (SRA.RA_SITFOLH <> 'D')				                        " + STR_PULA	
cQuery += " AND    SRA.RA_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" + STR_PULA	
//cQuery += " AND    SRA.RA_NOME LIKE 'MARIA DE FAT%'" + STR_PULA	
cQuery += " AND    SRA.RA_MAT BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'   " + STR_PULA	
cQuery += " AND    SRA.RA_CC BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'    " + STR_PULA	
cQuery += " AND    PE.PI_DATA BETWEEN '" +DtoS(MV_PAR07)+ "' AND '" +DtoS(MV_PAR08)+ "' "+ STR_PULA
//cQuery += " AND    SRA.RA_MAT = '000652'				                        " + STR_PULA	
//If(nConsolidado == 1)
cQuery += " ORDER BY RA_FILIAL,RA_CC,RA_MAT " + STR_PULA
//else
//cQuery += " ORDER BY  RA_MAT  " + STR_PULA
//EndIf	
													
DBSelectArea("CTT")
CTT->(DBSetOrder( 1 ))
MemoWrite("C:\TEMP\QRYHORAS.TXT",cQuery)
    TCQuery cQuery New Alias "QRYPRO"
     
      QRYPRO->(DBGOTOP(  ))
		_cFwilial:=QRYPRO->RA_FILIAL
        _cCdesc   := CCTDESC(Substring(_cFwilial,1,2),AllTrim(QRYPRO->RA_CC)) //Posicione("CTT",1,Substring(_cFwilial,1,2)+AllTrim(QRYPRO->RA_CC),"CTT_DESC01") 
        cCC := QRYPRO->RA_CC
        cMat :=QRYPRO->RA_MAT
        cNome :=QRYPRO->RA_NOME
        DbSelectArea("SPI")
        SPI->(DbSetOrder(1))
        SPI->(DbGoTop())
        While !(QRYPRO->(EoF()))
        cPd := QRYPRO->PI_PD
        nValHora:=QRYPRO->PI_QUANT
        nValHoraV:=QRYPRO->PI_QUANTV
        
       If AllTrim(QRYPRO->RA_MAT) == AllTrim(cMat)
        
        
        If (cPd $ "010#014#012#024")
        nHrnegativas := SomaHoras(nHrnegativas,(nValHora))
        nHrVlNeg:= SomaHoras(nHrVlNeg,(nValHoraV))
        EndIf
        If  (AllTrim(cPd) == "044")
        nHrpositivas := SomaHoras(nHrpositivas,nValHora)
        nHrVlPos :=SomaHoras(nHrVlPos,nValHoraV)
        EndIf
        
        Else
        //Imprimindo consolidaddo
        AADD(aMatriz,{_cFwilial,cMat,cNome,cCC,;
        _cCdesc,nHrpositivas,nHrnegativas,nHrVlPos,nHrVlNeg,nHrSld})
        nHrnegativas:=0
        nHrpositivas:=0
        nHrVlNeg:=0
        nHrVlPos:=0
        nHrSld:=0
        
        If (cPd $ "010#014#012#024")
        nHrnegativas := SomaHoras(nHrnegativas,(nValHora))
        nHrVlNeg:= SomaHoras(nHrVlNeg,(nValHoraV))
        EndIf
        If  (AllTrim(cPd)== "044")
        nHrpositivas := SomaHoras(nHrpositivas,nValHora)
        nHrVlPos :=SomaHoras(nHrVlPos,nValHoraV)
        EndIf
        
       //Setando Variaveis para nova linha
        _cFwilial:=QRYPRO->RA_FILIAL
        cMat:=QRYPRO->RA_MAT
        //cCC :=QRYPRO->PI_CC
        cCC :=QRYPRO->RA_CC
        cNome :=QRYPRO->RA_NOME
        //_cCdesc   := Posicione("CTT",1,Substring(_cFwilial,1,2)+QRYPRO->PI_CC,"CTT_DESC01")
          _cCdesc   := _cCdesc   := CCTDESC(Substring(_cFwilial,1,2),AllTrim(QRYPRO->RA_CC))
        EndIf
        
        
        QRYPRO->(DbSkip())
        EndDo
        QRYPRO->(DbCloseArea())
        RestArea(aArea) 
        
        //aSort(aMatriz, , , {|x, y|  (x[1] < y[1].AND.x[4] < y[4]) })
       
       /*************************************/
       // Imprime aba Por Filial           //
      /************************************/
       
        ImpLin(aMatriz)
    
       /*************************************/
       // Imprime aba total consolidado     //
      /************************************/
       
        x:=0
        _cSheet :=ImpCab("Consolidado") //Cria aba total Geral
        for x:= 1 to len(aTotalCC)
        //Nova linha 
        oFWMsExcel:AddRow(_cSheet,_cSheet,{aTotalCC[x][1],;
        aTotalCC[x][2],aTotalCC[x][3],aTotalCC[x][4],aTotalCC[x][5],aTotalCC[x][6],aTotalCC[x][7],SubHoras(aMatriz[x][6],aMatriz[x][7]),aTotalCC[x][8],;
        aTotalCC[x][9],SubHoras(aMatriz[x][8],aMatriz[x][9]),""})
        Next x
       oFWMsExcel:AddRow(_cSheet,_cSheet,{"","TOTAL GERAL--->",;
        "-->","","",nTPsNgt,nTPsAnt,SubHoras(nTPsAnt,nTPsNgt),nTpsVlNgt,nTpsVlPost,SubHoras(nTpsVlPost,nTpsVlNgt),""})
       
         //fClose(nHandle)
        oFWMsExcel:Activate()
        oFWMsExcel:GetXMLFile(cArquivo)
        //Abrindo o excel e abrindo o arquivo xml
        oExcel := MsExcel():New()               //Abre uma nova conexão com Excel
        oExcel:WorkBooks:Open(cArquivo)         //Abre uma planilha
        oExcel:SetVisible(.T.)                  //Visualiza a planilha
        oExcel:Destroy() 
Return

Static Function ImpLin(aMatriz)
        Local  cCCTot := aMatriz[1][4]
        Local  _cWfIL := aMatriz[1][1]
        Local x
        _cSheet :=ImpCab(_cWfIL)
        for x:= 1 to len(aMatriz)
        If AllTrim(_cWfIL) == AllTrim(aMatriz[x][1])
        If AllTrim(cCCTot) == AllTrim(aMatriz[x][4]) 
        oFWMsExcel:AddRow(_cSheet,_cSheet,{aMatriz[x][1],aMatriz[x][2],;
        aMatriz[x][3],cCCTot,aMatriz[x][5],aMatriz[x][6],aMatriz[x][7],SubHoras(aMatriz[x][6],aMatriz[x][7]),aMatriz[x][8],;
        aMatriz[x][9],SubHoras(aMatriz[x][8],aMatriz[x][9]),FvalSal(SubHoras(aMatriz[x][9],aMatriz[x][8]),aMatriz[x][1],aMatriz[x][2])})
        nTPsAn :=SomaHoras(nTPsAn,aMatriz[x][7]) 
        nTPsNg :=SomaHoras(nTPsNg,aMatriz[x][6])
        nTpsVlNg :=SomaHoras(nTpsVlNg,aMatriz[x][8])
        nTpsVlPos  :=SomaHoras(nTpsVlPos,aMatriz[x][9])
        nTpsVlHr:=SomaHoras(nTpsVlHr,aMatriz[x][10])
        ELSE 
        //Imprime Total do CC anterior 
        oFWMsExcel:AddRow(_cSheet,_cSheet,{aMatriz[x][1],"TOTAL--->",;
        "-->",cCCTot,"",nTPsNg,nTPsAn,SubHoras(nTPsAn,nTPsNg),nTpsVlNg,nTpsVlPos,SubHoras(nTpsVlPos,nTpsVlNg),""})
       
        AADD(aTotalCC,{aMatriz[x][1],"TOTAL--->","-->",cCCTot,"",nTPsNg,nTPsAn,SubHoras(nTPsAn,nTPsNg),nTpsVlNg,nTpsVlPos,SubHoras(nTpsVlPos,nTpsVlNg),""})
       
        //Contabiliza para o Total Geral
        nTPsAnt :=SomaHoras(nTPsAnt,nTPsAn) 
        nTPsNgt :=SomaHoras(nTPsNgt,nTPsNg)
        nTpsVlNgt :=SomaHoras(nTpsVlNgt,nTpsVlNg)
        nTpsVlPost :=SomaHoras(nTpsVlPost,nTpsVlPos)
        nTpsVlHrt:=SomaHoras(nTpsVlHrt,nTpsVlHr)
        //Zera Variaveis 
        nTPsAn:=0.00
        nTPsNg:=0.00
        nTpsVlNg:=0.00
        nTpsVlPos:=0.00
        nTpsVlHr:=0.00
        //Pega dados da novalinha
        nTPsAn :=SomaHoras(nTPsAn,aMatriz[x][7]) 
        nTPsNg :=SomaHoras(nTPsNg,aMatriz[x][6])
        nTpsVlNg :=SomaHoras(nTpsVlNg,aMatriz[x][8])
        nTpsVlPos  :=SomaHoras(nTpsVlPos,aMatriz[x][9])
        nTpsVlHr:=SomaHoras(nTpsVlHr,aMatriz[x][10])
        cCCTot :=aMatriz[x][4]
        cDesc:=aMatriz[x][5]
        //Imprime nova linha
         oFWMsExcel:AddRow(_cSheet,_cSheet,{aMatriz[x][1],aMatriz[x][2],;
        aMatriz[x][3],cCCTot,aMatriz[x][5],aMatriz[x][6],aMatriz[x][7],SubHoras(aMatriz[x][6],aMatriz[x][7]),aMatriz[x][8],;
        aMatriz[x][9],SubHoras(aMatriz[x][8],aMatriz[x][9]),FvalSal(SubHoras(aMatriz[x][9],aMatriz[x][8]),aMatriz[x][1],aMatriz[x][2])})
        EndIf
        else
        
        If AllTrim(cCCTot) == AllTrim(aMatriz[x][4]) 
         oFWMsExcel:AddRow(_cSheet,_cSheet,{aMatriz[x][1],aMatriz[x][2],;
        aMatriz[x][3],cCCTot,aMatriz[x][5],aMatriz[x][6],aMatriz[x][7],SubHoras(aMatriz[x][6],aMatriz[x][7]),aMatriz[x][8],;
        aMatriz[x][9],SubHoras(aMatriz[x][8],aMatriz[x][9]),FvalSal(SubHoras(aMatriz[x][9],aMatriz[x][8]),aMatriz[x][1],aMatriz[x][2])})
        nTPsAn :=SomaHoras(nTPsAn,aMatriz[x][7]) 
        nTPsNg :=SomaHoras(nTPsNg,aMatriz[x][6])
        nTpsVlNg :=SomaHoras(nTpsVlNg,aMatriz[x][8])
        nTpsVlPos  :=SomaHoras(nTpsVlPos,aMatriz[x][9])
        nTpsVlHr:=SomaHoras(nTpsVlHr,aMatriz[x][10])
        ELSE 
        //Imprime Total do CC anterior 
         oFWMsExcel:AddRow(_cSheet,_cSheet,{aMatriz[x][1],"TOTAL--->",;
        "-->",cCCTot,"",nTPsNg,nTPsAn,SubHoras(nTPsAn,nTPsNg),nTpsVlNg,nTpsVlPos,SubHoras(nTpsVlPos,nTpsVlNg),""})

        AADD(aTotalCC,{aMatriz[x][1],"TOTAL--->","-->",cCCTot,"",nTPsNg,nTPsAn,SubHoras(nTPsAn,nTPsNg),nTpsVlNg,nTpsVlPos,SubHoras(nTpsVlPos,nTpsVlNg),""})
        
        //Contabiliza para o Total Geral
        nTPsAnt :=SomaHoras(nTPsAnt,nTPsAn) 
        nTPsNgt :=SomaHoras(nTPsNgt,nTPsNg)
        nTpsVlNgt :=SomaHoras(nTpsVlNgt,nTpsVlNg)
        nTpsVlPost :=SomaHoras(nTpsVlPost,nTpsVlPos)
        nTpsVlHrt:=SomaHoras(nTpsVlHrt,nTpsVlHr)
        //Zera Variaveis 
        nTPsAn:=0.00
        nTPsNg:=0.00
        nTpsVlNg:=0.00
        nTpsVlPos:=0.00
        nTpsVlHr:=0.00
        //Pega dados da novalinha
        _cWfIL := aMatriz[x][1]
        _cSheet :=ImpCab(_cWfIL)
        nTPsAn :=SomaHoras(nTPsAn,aMatriz[x][7]) 
        nTPsNg :=SomaHoras(nTPsNg,aMatriz[x][6])
        nTpsVlNg :=SomaHoras(nTpsVlNg,aMatriz[x][8])
        nTpsVlPos  :=SomaHoras(nTpsVlPos,aMatriz[x][9])
        nTpsVlHr:=SomaHoras(nTpsVlHr,aMatriz[x][10])
        cCCTot :=aMatriz[x][4]
        cDesc:=aMatriz[x][5]
        //Imprime nova linha
         oFWMsExcel:AddRow(_cSheet,_cSheet,{aMatriz[x][1],aMatriz[x][2],;
        aMatriz[x][3],cCCTot,aMatriz[x][5],aMatriz[x][6],aMatriz[x][7],SubHoras(aMatriz[x][6],aMatriz[x][7]),aMatriz[x][8],;
        aMatriz[x][9],SubHoras(aMatriz[x][8],aMatriz[x][9]),FvalSal(SubHoras(aMatriz[x][9],aMatriz[x][8]),aMatriz[x][1],aMatriz[x][2])})
        EndIf
        Endif
        next x
        oFWMsExcel:AddRow(_cSheet,_cSheet,{"","TOTAL GERAL--->",;
        "-->",cCCTot,"",nTPsNgt,nTPsAnt,SubHoras(nTPsAnt,nTPsNgt),nTpsVlNgt,nTpsVlPost,SubHoras(nTpsVlPost,nTpsVlNgt),""})
Return

Static Function ImpCab(_cTipo)
Local _cSheet := "Banco de Horas - "+_cTipo

//Nova Aba
        oFWMsExcel:AddworkSheet(_cSheet)
        //Criando a Tabela
        oFWMsExcel:AddTable(_cSheet,_cSheet)
        //Criando Coluna
        oFWMsExcel:AddColumn(_cSheet,_cSheet,"Filial",1)
        oFWMsExcel:AddColumn(_cSheet,_cSheet,"Matricula",1)
        oFWMsExcel:AddColumn(_cSheet,_cSheet,"Nome",1)
        oFWMsExcel:AddColumn(_cSheet,_cSheet,"Centro de Custo",1)
        oFWMsExcel:AddColumn(_cSheet,_cSheet,"Desc. CC",1)
        oFWMsExcel:AddColumn(_cSheet,_cSheet,"Horas Normais Positivas",1)
        oFWMsExcel:AddColumn(_cSheet,_cSheet,"Horas Normais Negativas",1)
        oFWMsExcel:AddColumn(_cSheet,_cSheet,"Saldo Horas Normais",1)
        oFWMsExcel:AddColumn(_cSheet,_cSheet,"Horas Valorizadas Positivas",1)
        oFWMsExcel:AddColumn(_cSheet,_cSheet,"Horas Valorizadas Negativas",1)
        oFWMsExcel:AddColumn(_cSheet,_cSheet,"Saldo de Horas Valorizadas",1)
        oFWMsExcel:AddColumn(_cSheet,_cSheet,"Saldo em Valor Real",1)
Return  _cSheet       

Static Function FvalSal(nValHr,cFilw,cMatw)
Local cPesq := "."
Local nPos:= At(cPesq,cValToChar(nValHr))
Local cHora:= Substring(cValToChar(nValHr),1,(nPos-1))
Local cMin:=Substring(cValToChar(nValHr),(nPos+1),Len(cValToChar(nValHr)))
Local nValor := 0.00

nSalHora := Posicione("SRA",1,cFilw + cMatw, "RA_SALARIO / RA_HRSMES ")
nSalMin  :=(nSalHora/60)

nValor := (Val(cHora)*nSalHora)
nValor := nValor+(Val(cMin)*nSalHora) 

Return nValor 

Static Function CCTDESC(cFwFial,cCusto)
Local cQryCtt:= "SELECT CTT_DESC01 FROM CTT010 WHERE CTT_FILIAL ='"+cFwFial+"' AND CTT_CUSTO ='"+cCusto+"' " 
Local cDscCtt :=""
TCQuery cQryCtt New Alias "cQryCtt"
cDscCtt:= cQryCtt->CTT_DESC01
cQryCtt->(DbCloseArea())
Return cDscCtt

// Final do Fonte:  Robson Silva
