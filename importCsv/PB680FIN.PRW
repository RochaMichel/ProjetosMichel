#INCLUDE "FILEIO.CH"
#INCLUDE "RWMAKE.CH"

Static cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR", GetADV97() )
Static cExtDir    := 'Extratos\'
Static cExtOut    := 'Proc\'
Static cCrLf      := Chr(13) + Chr(10)
Static cDirQuery  := 'Querys\

User Function JobPB680Fin()
StartJob("U_PB680Fin",GetEnvServer(),.T., { "01", "010101" } )
Return

// \system\fin_cr_n1_client.xnu

** Criado por: Alessandro de Farias - amjgfarias@gmail.com - Em: 19/11/2018
User Function PB680FIN(aCodigos)
Local lExecute	:= .T.
Local aButtons	:={}

If aCodigos == Nil
	Return
Endif

If Select("SX2") == 0
	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv( aCodigos[01], aCodigos[02],,, "FIN", "PB680FIN" )
	
	SetModulo( "SIGAFIN", "FIN" )
	__cLogSiga := "NNNNNNNNNN"
	__cUserID  := "000000"
	cUserName  := Padr("Administrador",25)
	//__cinternet := ""
Endif
SetFunName("PB680FIN")

If ! FWAliasInDic("ZA9",.F.)
	Return
Endif

ChkFile("SA6")
ChkFile("ZA9")
//ChkFile("ZA0")

MakeDir( cStartPath + cExtDir )
MakeDir( cStartPath + cExtDir + cExtOut )
MakeDir( cStartPath + cExtDir + cDirQuery )

If ExisteSX6( "EL_FINMOVB" )
	If Empty( GetMV( "EL_FINMOVB" ) )
		PutMv( "EL_FINMOVB", "20181031" )
	EndIf
Else
	CriarSX6( "EL_FINMOVB", "D", "Fechamento do Mov. Bancario", "20181031" )
EndIf


If ( U_PBProcName("FWPREEXECUTE",Nil) .Or. U_PBProcName("MDIEXECUTE",Nil) ) // so executar via menu
	If ! MsgBox("Deseja importar extratos bancarios ?","PB680FIN","YESNO")
		lExecute := .F.
	Else
		cDir  := ChooseRet()
		If Empty(cDir)
			lExecute := .F.
			MsgAlert( 'Informe um diretorio!' )
		Endif
	Endif
Endif


If lExecute
	
	ProcLogIni( aButtons, "PB680FIN" )
	ProcLogAtu("INICIO")
	MsgRun( "Importandos arquivos....", "AGUARDE", { || RnPB680Fin(cDir) } )
	ProcLogAtu("FIM")
	
Endif

//	U_PBMovDia()

Return


Static Function RnPB680Fin(_cDir)

Local aDir1File := {}
Local aDir2File := {}
Local aDir3File := {}
Local aDir4File := {}
Local dDataI    := GetMv("EL_FINMOVB")+1
Local dDataF    := Date()
Local cPBTimeI  := Time()
Local aDados
Local aTarHist
Local I, nXY, J
Local aSM0
Local cOldEmpAnt
Local cOldFilant
Local cOldNumEmp

//P3 Tecnologia - Code Analisys 17/06/2020
Local cNatDB := GetMv("MV_NATDPBC")

aSM0 := SM0->( GetArea() )
cOldEmpAnt := cEmpAnt
cOldFilant := cFilAnt
cOldNumEmp := cNumEmp

aDir4File := Directory(_cDir+"CC*.RET") // bradesco
aSort( aDir4File,,, { |x,y| DTOS(x[3]) < DTOS(y[3]) } )

For i:=1 To Len(aDir4File)
	
	If .T. // 'CC1711A01.RET' $ aDir4File[i][1]
		
		PB680Proces(aDir4File[i][1],'BRADESCO.REC',aDir4File[i][3],aDir4File[i][4],_cDir)
		
		cQuery := "SELECT ZA9_FILIAL, ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA " + cCrLf
		cQuery += "FROM "+RetSqlName("ZA9")+" ZA9 " + cCrLf
		cQuery += "WHERE ZA9_TPDC='D' AND ZA9_TIPO='3' AND ZA9_OCORRE = '104' AND ZA9_CODHIS = '0043' AND ZA9.D_E_L_E_T_ = ' ' " + cCrLf
		cQuery += "AND ZA9_FILIAL = '"+xFilial("ZA9")+"' " + cCrLf
		cQuery += "AND ZA9_DATA BETWEEN '"+DTOS(dDataI)+"' AND '"+DTOS(dDataF)+"' " + cCrLf
		cQuery += "GROUP BY ZA9_FILIAL, ZA9_DATA ,ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON " + cCrLf
		cQuery += "ORDER BY ZA9_FILIAL, ZA9_DATA ,ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON " + cCrLf
		MemoWrite( cStartPath + cExtDir + cDirQuery + 'ZA9_FONE.SQL',cQuery)
		dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRB1",.F.,.T.)
		TCSetField("TRB1", "ZA9_DATA"   , "D", 08, 0 )
		
		TRB1->(dbGoTop())
		Do While ! TRB1->(EOF())
			//ZA9_FONE( TRB1->ZA9_DATA, TRB1->ZA9_BANCO, TRB1->ZA9_AGENCI, TRB1->ZA9_NUMCON )
			TRB1->( dbSkip() )
		Enddo
		TRB1->(DbCloseArea())
		
		aTarHist := {}
		aAdd(aTarHist,'xxxx')
		
		For nXY:=1 to Len(aTarHist)
			
			cQuery := "SELECT ZA9.R_E_C_N_O_ AS ZA9RECNO " + cCrLf
			cQuery += "FROM "+RetSqlName("ZA9")+" ZA9 " + cCrLf
			cQuery += "WHERE ZA9_TPDC = 'D' AND ZA9_TIPO = '3' " + cCrLf
			cQuery += "AND ZA9_FILIAL = '"+xFilial("ZA9")+"' " + cCrLf
			cQuery += "AND ZA9_OCORRE = '105' AND ZA9.D_E_L_E_T_ = ' ' " + cCrLf
			cQuery += "AND ZA9_DATA >= '"+DTOS(dDataI)+"' " + cCrLf
			cQuery += "AND NOT EXISTS ( " + cCrLf
			cQuery += "                 SELECT E5_FILIAL FROM "+RetSqlName("SE5")+" SE5 " + cCrLf
			cQuery += "                 WHERE ZA9_VALOR = E5_VALOR " + cCrLf
			cQuery += "                 AND E5_BANCO = ZA9_BANCO 
			cQuery += "                 AND E5_AGENCIA = ZA9_AGENCI " + cCrLf
			cQuery += "                 AND E5_CONTA = ZA9_NUMCON " + cCrLf
			cQuery += "                 AND E5_DTDISPO = ZA9_DATA " + cCrLf
			cQuery += "                 AND E5_FILIAL  = ZA9_FILIAL " + cCrLf
			cQuery += "                 AND SE5.D_E_L_E_T_ = ' ' " + cCrLf
			cQuery += "                 AND E5_NATUREZ = '"+Alltrim(&(cNatDB/*GetMv("MV_NATDPBC")*/))+"' -- TARIFAS BANCARIAS " + cCrLf
			cQuery += "                 AND E5_RECPAG = 'P' AND E5_SITUACA NOT IN ('C','X','E') " + cCrLf
			cQuery += "               ) " + cCrLf
			cQuery += "ORDER BY ZA9_FILIAL, ZA9_DATA ,ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON " + cCrLf
			MemoWrite( cStartPath + cExtDir + cDirQuery + 'ZA9_TARIFA.SQL',cQuery)
			dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRB1",.F.,.T.)
			TCSetField("TRB1", "ZA9_DATA"   , "D", 08, 0 )
			TCSetField("TRB1", "ZA9_VALOR"  , "N", 17, 2 )
			
			TRB1->(dbGoTop())
			Do While ! TRB1->(EOF())
				ZA9->(dBGoto(TRB1->ZA9RECNO))
				ZA9_TARIFA()
				TRB1->( dbSkip() )
			Enddo
			TRB1->(DbCloseArea())
			
		Next nXY
		
		cQuery := "SELECT ZA9.R_E_C_N_O_ AS ZA9RECNO " + cCrLf
		cQuery += "FROM "+RetSqlName("ZA9")+" ZA9 " + cCrLf
		cQuery += "WHERE ZA9.D_E_L_E_T_ = ' ' " + cCrLf
		cQuery += "AND ZA9_FILIAL = '"+xFilial("ZA9")+"' " + cCrLf
		cQuery += "ORDER BY ZA9_FILIAL, ZA9_DATA ,ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON " + cCrLf
		MemoWrite( cStartPath + cExtDir + cDirQuery + 'CRIASE8.SQL',cQuery)
		dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRB1",.F.,.T.)
		
		TRB1->(dbGoTop())
		Do While ! TRB1->(EOF())
			ZA9->( dBGoto(TRB1->ZA9RECNO) )
			CRIASE8()
			TRB1->( dbSkip() )
		Enddo
		TRB1->(DbCloseArea())
		
		cQuery := "SELECT ZA9_FILIAL, ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA " + cCrLf
		cQuery += "FROM "+RetSqlName("ZA9")+" ZA9 " + cCrLf
		cQuery += "WHERE ZA9_TPDC='D' AND ZA9_TIPO='3' AND ZA9_OCORRE='112' AND ZA9.D_E_L_E_T_ = ' ' " + cCrLf
		cQuery += "AND ZA9_FILIAL = '"+xFilial("ZA9")+"' " + cCrLf
		cQuery += "AND ZA9_DATA BETWEEN '"+DTOS(dDataI)+"' AND '"+DTOS(dDataF)+"' " + cCrLf
		cQuery += "GROUP BY ZA9_FILIAL, ZA9_DATA ,ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON " + cCrLf
		cQuery += "ORDER BY ZA9_FILIAL, ZA9_DATA ,ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON " + cCrLf
		MemoWrite( cStartPath + cExtDir + cDirQuery + 'ZA9_112.SQL',cQuery)
		dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRB1",.F.,.T.)
		TCSetField("TRB1", "ZA9_DATA"   , "D", 08, 0 )
		
		TRB1->(dbGoTop())
		Do While ! TRB1->(EOF())
			ZA9_112( TRB1->ZA9_DATA, TRB1->ZA9_BANCO, TRB1->ZA9_AGENCI, TRB1->ZA9_NUMCON )
			TRB1->( dbSkip() )
		Enddo
		TRB1->(DbCloseArea())
		
		cQuery := "SELECT ZA9_FILIAL, ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA " + cCrLf
		cQuery += "FROM "+RetSqlName("ZA9")+" ZA9 " + cCrLf
		cQuery += "WHERE ZA9_TPDC='D' AND ZA9_TIPO='3' AND ZA9_OCORRE='104' AND ZA9_CODHIS='0086' AND ZA9.D_E_L_E_T_ = ' ' " + cCrLf
		cQuery += "AND ZA9_DATA BETWEEN '"+DTOS(dDataI)+"' AND '"+DTOS(dDataF)+"' " + cCrLf
		cQuery += "AND ZA9_FILIAL = '"+xFilial("ZA9")+"' " + cCrLf
		cQuery += "GROUP BY ZA9_FILIAL, ZA9_DATA ,ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON " + cCrLf
		cQuery += "ORDER BY ZA9_FILIAL, ZA9_DATA ,ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON " + cCrLf
		MemoWrite( cStartPath + cExtDir + cDirQuery + 'ZA9_FGTS.SQL',cQuery)
		dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRB1",.F.,.T.)
		TCSetField("TRB1", "ZA9_DATA"   , "D", 08, 0 )
		
		TRB1->(dbGoTop())
		Do While ! TRB1->(EOF())
			//ZA9_FGTS( TRB1->ZA9_DATA, TRB1->ZA9_BANCO, TRB1->ZA9_AGENCI, TRB1->ZA9_NUMCON )
			TRB1->( dbSkip() )
		Enddo
		TRB1->(DbCloseArea())
		
		cQuery := "SELECT ZA9_FILIAL, ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA " + cCrLf
		cQuery += "FROM "+RetSqlName("ZA9")+" ZA9 " + cCrLf
		cQuery += "WHERE ZA9_TPDC='D' AND ZA9_TIPO='3' AND ZA9_OCORRE='104' AND ZA9_CODHIS='4472' AND ZA9.D_E_L_E_T_ = ' ' " + cCrLf
		cQuery += "AND ZA9_FILIAL = '"+xFilial("ZA9")+"' " + cCrLf
		cQuery += "AND ZA9_DATA BETWEEN '"+DTOS(dDataI)+"' AND '"+DTOS(dDataF)+"' " + cCrLf
		cQuery += "GROUP BY ZA9_FILIAL, ZA9_DATA ,ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON " + cCrLf
		cQuery += "ORDER BY ZA9_FILIAL, ZA9_DATA ,ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON " + cCrLf
		MemoWrite( cStartPath + cExtDir + cDirQuery + 'ZA9_INSS.SQL',cQuery)
		dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRB1",.F.,.T.)
		TCSetField("TRB1", "ZA9_DATA"   , "D", 08, 0 )
		
		TRB1->(dbGoTop())
		Do While ! TRB1->(EOF())
			//ZA9_INSS( TRB1->ZA9_DATA, TRB1->ZA9_BANCO, TRB1->ZA9_AGENCI, TRB1->ZA9_NUMCON )
			TRB1->( dbSkip() )
		Enddo
		TRB1->(DbCloseArea())
		
		cQuery := "SELECT ZA9_FILIAL, ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA " + cCrLf
		cQuery += "FROM "+RetSqlName("ZA9")+" ZA9 " + cCrLf
		cQuery += "WHERE ZA9_TPDC='D' AND ZA9_TIPO='3' AND ZA9_OCORRE = '104' AND ZA9_CODHIS = '0060' AND ZA9.D_E_L_E_T_ = ' ' " + cCrLf
		cQuery += "AND ZA9_DATA BETWEEN '"+DTOS(dDataI)+"' AND '"+DTOS(dDataF)+"' " + cCrLf
		cQuery += "AND ZA9_FILIAL = '"+xFilial("ZA9")+"' " + cCrLf
		cQuery += "GROUP BY ZA9_FILIAL, ZA9_DATA ,ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON " + cCrLf
		cQuery += "ORDER BY ZA9_FILIAL, ZA9_DATA ,ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON " + cCrLf
		MemoWrite( cStartPath + cExtDir + cDirQuery + 'ZA9_TRBMUN.SQL',cQuery)
		dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRB1",.F.,.T.)
		TCSetField("TRB1", "ZA9_DATA"   , "D", 08, 0 )
		
		TRB1->(dbGoTop())
		Do While ! TRB1->(EOF())
			//ZA9_TRBMUN( TRB1->ZA9_DATA, TRB1->ZA9_BANCO, TRB1->ZA9_AGENCI, TRB1->ZA9_NUMCON )
			TRB1->( dbSkip() )
		Enddo
		TRB1->(DbCloseArea())
		
		cQuery := "SELECT ZA9_FILIAL, ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA " + cCrLf
		cQuery += "FROM "+RetSqlName("ZA9")+" ZA9 " + cCrLf
		cQuery += "WHERE ZA9_TPDC='D' AND ZA9_TIPO='3' AND ZA9_OCORRE = '104' AND ZA9_CODHIS = '0027' AND ZA9.D_E_L_E_T_ = ' ' " + cCrLf
		cQuery += "AND ZA9_DATA BETWEEN '"+DTOS(dDataI)+"' AND '"+DTOS(dDataF)+"' " + cCrLf
		cQuery += "AND ZA9_FILIAL = '"+xFilial("ZA9")+"' " + cCrLf
		cQuery += "GROUP BY ZA9_FILIAL, ZA9_DATA ,ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON " + cCrLf
		cQuery += "ORDER BY ZA9_FILIAL, ZA9_DATA ,ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON " + cCrLf
		MemoWrite( cStartPath + cExtDir + cDirQuery + 'ZA9_AGUA.SQL',cQuery)
		dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRB1",.F.,.T.)
		TCSetField("TRB1", "ZA9_DATA"   , "D", 08, 0 )
		
		TRB1->(dbGoTop())
		Do While ! TRB1->(EOF())
			//ZA9_AGUA( TRB1->ZA9_DATA, TRB1->ZA9_BANCO, TRB1->ZA9_AGENCI, TRB1->ZA9_NUMCON )
			TRB1->( dbSkip() )
		Enddo
		TRB1->(DbCloseArea())
		
		cQuery := "SELECT ZA9_FILIAL, ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA " + cCrLf
		cQuery += "FROM "+RetSqlName("ZA9")+" ZA9 " + cCrLf
		cQuery += "WHERE ZA9_TPDC='D' AND ZA9_TIPO='3' AND ZA9_OCORRE = '104' AND ZA9_CODHIS = '0035' AND ZA9.D_E_L_E_T_ = ' ' " + cCrLf
		cQuery += "AND ZA9_DATA BETWEEN '"+DTOS(dDataI)+"' AND '"+DTOS(dDataF)+"' " + cCrLf
		cQuery += "AND ZA9_FILIAL = '"+xFilial("ZA9")+"' " + cCrLf
		cQuery += "GROUP BY ZA9_FILIAL, ZA9_DATA ,ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON " + cCrLf
		cQuery += "ORDER BY ZA9_FILIAL, ZA9_DATA ,ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON " + cCrLf
		MemoWrite( cStartPath + cExtDir + cDirQuery + 'ZA9_LUZ.SQL',cQuery)
		dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRB1",.F.,.T.)
		TCSetField("TRB1", "ZA9_DATA"   , "D", 08, 0 )
		
		TRB1->(dbGoTop())
		Do While ! TRB1->(EOF())
			//ZA9_LUZ( TRB1->ZA9_DATA, TRB1->ZA9_BANCO, TRB1->ZA9_AGENCI, TRB1->ZA9_NUMCON )
			TRB1->( dbSkip() )
		Enddo
		TRB1->(DbCloseArea())
		
		
		SX1->( DbSetOrder(1) ) // grupo + ordem
		If SX1->( DbSeek( Padr("FIN210",10) + "01" ) ) // Do Banco
			RecLock("SX1",.F.)
			//P3 Tecnologia - Code Analisys 14/06/2020
			//SX1->X1_CNT01 := ""
			For j := 1 to FCount()
				If FieldName(j)=="X1_CNT01"
					FieldPut(j, "" )
					Exit
				Endif
			Next
			SX1->( MsUnLock() )
		Endif
		If SX1->( DbSeek( Padr("FIN210",10) + "02" ) ) // Ate o Banco
			RecLock("SX1",.F.)
			//P3 Tecnologia - Code Analisys 14/06/2020
			//SX1->X1_CNT01 := "zzz"
			For j := 1 to FCount()
				If FieldName(j)=="X1_CNT01"
					FieldPut(j, "zzz" )
					Exit
				Endif
			Next
			SX1->( MsUnLock() )
		Endif
		If SX1->( DbSeek( Padr("FIN210",10) + "03" ) ) // Da Agencia
			RecLock("SX1",.F.)
			//P3 Tecnologia - Code Analisys 14/06/2020
			//SX1->X1_CNT01 := ""
			For j := 1 to FCount()
				If FieldName(j)=="X1_CNT01"
					FieldPut(j, "" )
					Exit
				Endif
			Next
			SX1->( MsUnLock() )
		Endif
		If SX1->( DbSeek( Padr("FIN210",10) + "04" ) ) // Ate a Agencia
			RecLock("SX1",.F.)
			//P3 Tecnologia - Code Analisys 14/06/2020
			//SX1->X1_CNT01 := "zzzzz"
			For j := 1 to FCount()
				If FieldName(j)=="X1_CNT01"
					FieldPut(j, "zzzzz" )
					Exit
				Endif
			Next
			SX1->( MsUnLock() )
		Endif
		If SX1->( DbSeek( Padr("FIN210",10) + "05" ) ) // Da Conta
			RecLock("SX1",.F.)
			//P3 Tecnologia - Code Analisys 14/06/2020
			//SX1->X1_CNT01 := ""
			For j := 1 to FCount()
				If FieldName(j)=="X1_CNT01"
					FieldPut(j, "" )
					Exit
				Endif
			Next
			SX1->( MsUnLock() )
		Endif
		If SX1->( DbSeek( Padr("FIN210",10) + "06" ) ) // Ate a Conta
			RecLock("SX1",.F.)
			//P3 Tecnologia - Code Analisys 14/06/2020
			//SX1->X1_CNT01 := "zzzzzzzzzz"
			For j := 1 to FCount()
				If FieldName(j)=="X1_CNT01"
					FieldPut(j, "zzzzzzzzzz" )
					Exit
				Endif
			Next
			SX1->( MsUnLock() )
		Endif
		If SX1->( DbSeek( Padr("FIN210",10) + "07" ) ) // A partir da Data
			RecLock("SX1",.F.)
			//SX1->X1_CNT01 := "'19700101'"
			//P3 Tecnologia - Code Analisys 14/06/2020
			//SX1->X1_CNT01 := "'"+DTOC(dDataI)+"'"
			For j := 1 to FCount()
				If FieldName(j)=="X1_CNT01"
					FieldPut(j, "'"+DTOC(dDataI)+"'" )
					Exit
				Endif
			Next
			SX1->( MsUnLock() )
		Endif
		If SX1->( DbSeek( Padr("FIN210",10) + "08" ) ) // Seleciona Filiais
			RecLock("SX1",.F.)
			//P3 Tecnologia - Code Analisys 14/06/2020
			//SX1->X1_PRESEL := 2
			For j := 1 to FCount()
				If FieldName(j)=="X1_PRESEL"
					FieldPut(j, 2 )
					Exit
				Endif
			Next
			SX1->( MsUnLock() )
		Endif
		If SX1->( DbSeek( Padr("FIN210",10) + "09" ) ) // Da Filial
			RecLock("SX1",.F.)
			//P3 Tecnologia - Code Analisys 14/06/2020
			//SX1->X1_CNT01 := cFilAnt
			For j := 1 to FCount()
				If FieldName(j)=="X1_CNT01"
					FieldPut(j, cFilAnt )
					Exit
				Endif
			Next
			SX1->( MsUnLock() )
		Endif
		If SX1->( DbSeek( Padr("FIN210",10) + "10" ) ) // Ate a Filial
			RecLock("SX1",.F.)
			//P3 Tecnologia - Code Analisys 14/06/2020
			//SX1->X1_CNT01 := cFilAnt
			For j := 1 to FCount()
				If FieldName(j)=="X1_CNT01"
					FieldPut(j, cFilAnt )
					Exit
				Endif
			Next
			SX1->( MsUnLock() )
		Endif
		
		U_fPergunte("FIN210",.F.)//P3 Tecnologia - Code Analisys 27/06/2020
		
		cEmpAnt	:= cOldEmpAnt
		cFilAnt	:= cOldFilant
		cNumEmp	:= cOldNumEmp
		RestArea(aSM0)
		
	Endif
	
Next I

aDados := {}
Aadd( aDados, { "Empresa     ", cEmpAnt + " - " + SM0->M0_NOMECOM   } )
Aadd( aDados, { "Processo    ", "Importacao dos extratos bancarios" } )
Aadd( aDados, { "Duracao     ", ElapTime( cPBTimeI, Time() )        } )
Aadd( aDados, { "Ambiente    ", Alltrim(Capital(GetEnvServer()))    } )
cBody		:= "" + CHR(13) + CHR(10)
cBody		+= MontaTabelaHTML(aDados, .f., "100%")
cBody		+= "" + CHR(13) + CHR(10)

//U_SduMandaEmail( "", "", "", "Conciliacao Automatica", Nil, cBody, Nil )

Return

//P3 Tecnologia - Code Analisys 27/06/2020
User Function fPergunte(cPerg,lAbre)
Return Pergunte(cPerg,lAbre)

Static Function PB680Proces(_cFile, _cFileCfg,_dDTFile,_cHrFile,__cDir)
Local nHdlConf
Local nHdlBco
Local nValor , dDataf, cNumCta, cDivCta, cCodBco, cCodAgc, dDtMov, NN
Local nLidos    := 0
Local aPosicoes :={ }
Local nSaldoInicial := 0
Local cSitLanc  := xBuffer := ""
Local lVez      := .T.
Local cFileCfg  := _cFileCfg
Local cFile     := _cFile
Local dData
Local lJob      := Iif(__cinternet == "AUTOMATICO", .T., .F.) // ExecSchedule()
Local aDatas    := {}
Local aFil

If !File(cFileCfg)
	Final("Erro: Arquivo "+cFileCfg+" nao localizado")
Endif

FT_FUSE(cFileCfg)
FT_FGOTOP()
While ! FT_FEOF()
	xBuffer := FT_FREADLN()
	If SubStr(xBuffer,1,1) == CHR(1)
		FT_FSKIP()
		Loop
	Endif
	Aadd( aPosicoes, { Substr(xBuffer,2,15),Val(Substr(xBuffer,17,3)),1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3))) })
	FT_FSKIP()
EndDo
FT_FUSE()

//VarInfo("aPosicoes",aPosicoes)

FT_FUSE(__cDir + cFile)
FT_FGOTOP()
xBuffer := FT_FREADLN()
FT_FUSE()

SA6->( DbSetOrder(1) )
//60,12 Left(Alltrim(Str(Val(Substr(xBuffer,62,10)))),      Len(Alltrim(Str(Val(Substr(xBuffer,62,10)))))-1     )
cCodBco	:= Padr(Substr(xBuffer,aPosicoes[1,2],aPosicoes[1,3]-0),Len(SA6->A6_COD))
cCodAgc  := Padr(Substr(xBuffer,aPosicoes[2,2],aPosicoes[2,3]-1),Len(SA6->A6_AGENCIA))
cNumCta  := Padr(Substr(xBuffer,aPosicoes[3,2],aPosicoes[3,3]-0),Len(SA6->A6_NUMCON))
cNumCta  := Left(Alltrim(Str(Val(Substr(xBuffer,aPosicoes[3,2],aPosicoes[3,3]-0)))),Len(Alltrim(Str(Val(Substr(xBuffer,aPosicoes[3,2],aPosicoes[3,3]-0)))))-1)
cNumCta  := Alltrim(StrTran(cNumCta," ",""))
cNumCta  := Padr(cNumCta,Len(SA6->A6_NUMCON))

If "001" $ cCodBco .And. ! "X" $ cNumCta
	cNumCta := Alltrim(Str(Val(cNumCta)))
Endif
If "104" $ cCodBco
	cNumCta := Alltrim(Str(Val(cNumCta)))
Endif

lFound     := .F.
aFil := FWLoadSM0(.F.,.F.)
For nn:=1 To Len(aFil)
	cEmpAnt := aFil[nn][1] // codigo
	cFilant := aFil[nn][2] // filial
	cNumEmp := cEmpAnt + cFilant
	SM0->( DbSeek ( cEmpAnt + cFilAnt ) )
	If SA6POS(cCodBco,cCodAgc,cNumCta)
		lFound := .T.
		Exit
	Endif
Next nn

If ! lFound
	// nao acho a conta do banco em nenhuma filial
	Return .F.
Endif

If ! lJob
	//	ProcRegua(nTamArq/Len(xBuffer)) // Numero de registros a processar
Endif

MakeDir( cStartPath + cExtDir )
MakeDir( cStartPath + cExtDir + cDirQuery )
MakeDir( cStartPath + cExtDir + cExtOut )
MakeDir( cStartPath + cExtDir + cExtOut + cCodBco + '\' )
MakeDir( cStartPath + cExtDir + cExtOut + cCodBco + '\' + Alltrim(cCodAgc) + '\' )
MakeDir( cStartPath + cExtDir + cExtOut + cCodBco + '\' + Alltrim(cCodAgc) + '\' + Alltrim(cNumCta) + '\' )

_cFile := cStartPath + cExtDir + cExtOut + cCodBco + '\' + Alltrim(cCodAgc) + '\' + Alltrim(cNumCta) + '\' + cFile
fErase(_cFile)
lFileOk := .F.
If __CopyFile( __cDir + cFile, _cFile )
	lFileOk := .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ja existe movimento.                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT ZA9_FILIAL FROM "+RetSqlName("ZA9")+" ZA9 WHERE "
cQuery += "UPPER(ZA9_ARQCNA) = '"+Alltrim(cFile)+"' AND ZA9.D_E_L_E_T_=' ' AND ZA9_FILIAL = '"+xFilial("ZA9")+"' "
cQuery += "AND ZA9_BANCO = '"+cCodBco+"' AND ZA9_AGENCI = '"+cCodAgc+"' AND ZA9_NUMCON = '"+cNumCta+"' "
dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRB1",.F.,.T.)
TRB1->(dbGoTop())
If ! TRB1->(EOF())
	TRB1->(DbCloseArea())
	_cAssunto := "arquivo ja conciliacao"
	_cBody	 := "Empresa " + cEmpAnt + " " + cCodBco + ", " + cCodAgc + ", " + cNumCta + ",  arquivo " + cFile
	//U_SduMandaEmail( "alessandro@farias.net.br", "", "", _cAssunto, Nil, _cBody, Nil )
	_cFile := cStartPath + cExtDir + cExtOut + cCodBco + '\' + Alltrim(cCodAgc) + '\' + Alltrim(cNumCta) + '\' + cFile
	fErase(_cFile)
	If __CopyFile( __cDir + cFile, _cFile )
		//Ferase(cStartPath + cFile)
	Endif
	Return .F.
Endif
TRB1->(DbCloseArea())

If lFileOk
	Begin Transaction
	
	FT_FUSE(_cFile)
	FT_FGOTOP()
	
	While ! FT_FEOF()
		
		xBuffer := FT_FREADLN()
		
		If	Empty(xBuffer)
			Exit
		Endif
		
		If SubStr(xBuffer,aPosicoes[4,2],aPosicoes[4,3]) == "0" //.Or. ( Len(aPosicoes)>=21 .And. SubStr(xBuffer,aPosicoes[21,2],aPosicoes[21,3]) <> "0001" )
			FT_FSKIP()
			Loop
		EndIf
		
		cData  := SubStr(xBuffer,aPosicoes[6,2],aPosicoes[6,3] )
		dDtMov := CtoD(Substr(cData,1,2)+"/"+SubStr(cData,3,2)+"/"+SubStr( cData,5,4),"ddmmyy" )
		
		If	Empty(dDtMov)
			Exit
		Endif
		
		RecLock("ZA9",.T.)
		ZA9->ZA9_FILIAL  := xFilial("ZA9")
		ZA9->ZA9_ARQCNA  := cFile
		ZA9->ZA9_DTCNAB  := dDtMov
		
		If SubStr(xBuffer,aPosicoes[4,2],aPosicoes[4,3]) == "0"
			
			If ! lJob
				//IncProc()
			Endif
			
		ElseIf SubStr(xBuffer,aPosicoes[4,2],aPosicoes[4,3]) == "1"
			
			// SALDO INICIAL
			cData 	:= SubStr(xBuffer,aPosicoes[6,2],aPosicoes[6,3] )
			dData 	:= CtoD(Substr(cData,1,2)+"/"+SubStr(cData,3,2)+"/"+SubStr( cData,5,4),"ddmmyy" )
			cSitLanc := SubStr(xBuffer,aPosicoes[7,2],aPosicoes[7,3] )
			nSaldoInicial := Val(SubStr(xBuffer,aPosicoes[5,2],aPosicoes[5,3] ))/100
			
			ZA9->ZA9_DOCUME  := "000000"
			ZA9->ZA9_HIST    := "SALDO INICIAL"
			ZA9->ZA9_DATA    := dData
			ZA9->ZA9_TIPO    := "1"
			ZA9->ZA9_VALOR   := nSaldoInicial
			ZA9->ZA9_TPDC    := cSitLanc
			ZA9->ZA9_SEQ     := SubStr( xBuffer,aPosicoes[21][2],aPosicoes[21][3] )
			
			If ! lJob
				//IncProc()
			Endif
			
		ElseIf SubStr(xBuffer,aPosicoes[4,2],aPosicoes[4,3]) == "3"
			
			// LANCAMENTOS
			cData  	:= SubStr(xBuffer,aPosicoes[9,2],aPosicoes[9,3] )
			dData    := CtoD(Substr( cData,1,2)+"/"+SubStr( cData,3,2)+"/"+SubStr( cData,5,4),"ddmmyyyy" )
			cOcor    := SubStr(xBuffer,aPosicoes[11,2],aPosicoes[11,3] ) // SEJ
			cBcoHist := StrZero(Val(SubStr(xBuffer,aPosicoes[12,2],aPosicoes[12,3] )),4,0) // codigo interno por banco
			cNum   	:= SubStr(xBuffer,aPosicoes[8,2],aPosicoes[8,3] )
			cDesc    := SubStr(xBuffer,aPosicoes[13,2],aPosicoes[13,3] )+IIF(SubStr(xBuffer,aPosicoes[8,2]+7,aPosicoes[8,3]-7 ) <>  '', "-"+SubStr(xBuffer,aPosicoes[8,2]+7,aPosicoes[8,3] ),'')
			cSitLanc := SubStr(xBuffer,aPosicoes[7,2],aPosicoes[7,3])
			cOcorre  := Substr(xBuffer,aPosicoes[11,2],aPosicoes[11,3])
			cModLan  := Substr(xBuffer,aPosicoes[11,2]+3,aPosicoes[11,3]+5)
			nValor   := Val(SubStr(xBuffer,aPosicoes[10,2],aPosicoes[10,3] ))/100
			
			If cSitLanc == "C"
				nSaldoInicial += nValor
			Else
				nSaldoInicial -= nValor
			Endif
			
			ZA9->ZA9_DATA    := dData
			ZA9->ZA9_TIPO    := "3"
			ZA9->ZA9_HIST    := cDesc
			ZA9->ZA9_VALOR   := nValor
			ZA9->ZA9_TPDC    := cSitLanc
			ZA9->ZA9_OCORRE  := cOcorre
			ZA9->ZA9_CODHIS  := cBcoHist
			ZA9->ZA9_SEQ     := SubStr( xBuffer,aPosicoes[21][2],aPosicoes[21][3] )
			If !Empty(cNum) .And. "CH COMP" $ ZA9->ZA9_HIST
				cNum := Right(Alltrim(cNum),6)
			Endif
			ZA9->ZA9_DOCUME  := cNum
			If Empty(cNum)
				ZA9->ZA9_DOCUME  := SubStr( xBuffer,aPosicoes[22][2],aPosicoes[22][3] )
			Endif
			If cOcorre == "205"
				ZA9->ZA9_DOCUME  := StrZero(Val(SubStr( xBuffer,aPosicoes[8][2],aPosicoes[8][3] )),8)
			Endif
			If ! lJob
				//IncProc()
			Endif
			
		ElseIf (SubStr(xBuffer,aPosicoes[4,2],aPosicoes[4,3]) == "5")
			
			// SALDO FINAL
			cSitLanc := SubStr(xBuffer,aPosicoes[17,2],aPosicoes[17,3] )
			nValor   := Val(SubStr(xBuffer,aPosicoes[16,2],aPosicoes[16,3] ))/100
			cData    := SubStr(xBuffer,aPosicoes[15,2],aPosicoes[15,3] )
			dData    := CtoD(Substr( cData,1,2)+"/"+SubStr( cData,3,2)+"/"+SubStr( cData,5,4),"ddmmyyyy" )
			dDataf   := dData
			
			ZA9->ZA9_DOCUME  := "999999"
			ZA9->ZA9_HIST    := "SALDO FINAL"
			ZA9->ZA9_DATA    := dData
			ZA9->ZA9_TIPO    := "5"
			ZA9->ZA9_VALOR   := nValor
			ZA9->ZA9_TPDC    := cSitLanc
			ZA9->ZA9_SEQ     := SubStr( xBuffer,aPosicoes[21][2],aPosicoes[21][3] )
			
			If aScan( aDatas,dData ) == 0
				aAdd( aDatas,dData )
			EndIf
			
			If ! lJob
				//IncProc()
			Endif
			
		ElseIf SubStr(xBuffer,aPosicoes[4,2],aPosicoes[4,3]) == "9"
			
			If ! lJob
				//IncProc()
			Endif
			
		Endif
		
		ZA9->ZA9_BANCO  := cCodBco
		ZA9->ZA9_AGENCI := cCodAgc
		ZA9->ZA9_NUMCON := cNumCta
		ZA9->ZA9_DTARQ  := _dDTFile
		ZA9->ZA9_HRARQ  := _cHrFile
		
		ZA9->( MSUnLock() )
		
		FT_FSKIP()
		
	Enddo
	FT_FUSE()
	
	End Transaction
Endif

If .T. // Len(aDatas) > 1
	dDtMov := aDatas[01]
	For nn:=1 To Len(aDatas)
		If aDatas[nn] > dDtMov
			dDtMov := aDatas[nn]
		Endif
	Next nn
	//If ZA9->( DbSeek( xFilial("ZA9") + cCodBco + cCodAgc + cNumCta + DTOS(dDtMov) ) )
	//   CriaSE8()
	//Endif
Endif

_cFile := cStartPath + cExtDir + cExtOut + cCodBco + '\' + Alltrim(cCodAgc) + '\' + Alltrim(cNumCta) + '\' + cFile

Ferase(_cFile)
If __CopyFile( cStartPath + cFile, _cFile )
	// Ferase(cStartPath + cFile)
Endif

//Quando arquivo foi salvo na tabela ZA9 e processado.
//MsgAlert( 'Conciliação processada!' )

Return .T.

/* // TABELA SEJ
'101' = Cheques
'102' = Encargos
'103' = Estornos
'104' = Lançamento Avisado
'105' = Tarifas
'106' = Aplicação
'107' = Empréstimo / Financiamento
'108' = Câmbio
'109' = CPMF
'110' = IOF
'111' = Imposto de Renda
'112' = Pagamento Fornecedores
'113' = Pagamento Funcionários
'114' = Saque Eletrônico
'115' = Ações
'117' = Transferência entre Contas
'118' = Devolução da Compensação
'119' = Devolução de Cheque Depositado
'120' = Transferência Interbancária (DOC, TED)
'121' = Antecipação a Fornecedores
'122' = OC / AEROPS
Créditos:
'201' = Depósitos
'202' = Líquido de Cobrança
'203' = Devolução de Cheques
'204' = Estornos
'205' = Lançamento Avisado
'206' = Resgate de Aplicação
'207' = Empréstimo / Financiamento
'208' = Câmbio
'209' = Transferência Interbancária (DOC, TED)
'210' = Ações
'211' = Dividendos
'212' = Seguro
'213' = Transferência entre Contas
'214' = Depósitos Especiais
'215' = Devolução da Compensação
'216' = OCT
*/

*************** TELECOMUNICACOES
/*
----------------- TELECOMUNICACOES
SELECT ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, ZA9_VALOR,
E5_VALOR = (
SELECT ISNULL(SUM(E5_VALOR),0)
FROM SE5030 SE5
RIGHT JOIN SA6030 SA6 ON ( A6_COD = SE5.E5_BANCO  AND A6_AGENCIA = SE5.E5_AGENCIA AND A6_NUMCON = SE5.E5_CONTA AND SA6.D_E_L_E_T_=' ' )
WHERE SE5.D_E_L_E_T_=' ' AND E5_BANCO = ZA9_BANCO AND E5_AGENCIA = ZA9_AGENCI AND E5_CONTA = ZA9_NUMCON
AND SE5.E5_RECPAG = 'P'
AND SE5.E5_SITUACA <> 'C'
AND SE5.E5_TIPODOC NOT IN ('JR','MT','DC','CH')
AND SE5.E5_MOTBX IN ('NOR','DEB','FAT')
AND SE5.E5_FORNECE IN ('005005','005700','006040','007640','000034','004671','008415','010326','007013')
AND E5_DATA = ZA9_DATA
AND NOT EXISTS( SELECT E5_FILIAL FROM SE5030 ESTSE5 WHERE
ESTSE5.E5_FILIAL   = SE5.E5_FILIAL AND ESTSE5.E5_PREFIXO  = SE5.E5_PREFIXO AND
ESTSE5.E5_NUMERO   = SE5.E5_NUMERO AND ESTSE5.E5_PARCELA  = SE5.E5_PARCELA AND
ESTSE5.E5_TIPO     = SE5.E5_TIPO   AND ESTSE5.E5_CLIFOR   = SE5.E5_CLIFOR AND
ESTSE5.E5_LOJA     = SE5.E5_LOJA   AND ESTSE5.E5_SEQ      = SE5.E5_SEQ AND
ESTSE5.E5_TIPODOC  = 'ES' AND ESTSE5.E5_DATA <= '20491231' AND ESTSE5.D_E_L_E_T_=' ' )

)
FROM ZA9030
WHERE D_E_L_E_T_=' ' AND ZA9_TPDC='D' AND ZA9_TIPO='3'
AND ZA9_OCORRE = '104' AND ZA9_CODHIS = '0043'
ORDER BY ZA9_DATA DESC
*/

************************ FINAMES
/*
----------------- FINAMES
SELECT ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, ZA9_VALOR,
E5_VALOR = (
SELECT ISNULL(SUM(E5_VALOR),0)
FROM SE5030 SE5
RIGHT JOIN SA6030 SA6 ON ( A6_COD = SE5.E5_BANCO  AND A6_AGENCIA = SE5.E5_AGENCIA AND A6_NUMCON = SE5.E5_CONTA AND SA6.D_E_L_E_T_=' ' )
WHERE SE5.D_E_L_E_T_=' ' AND E5_BANCO = ZA9_BANCO AND E5_AGENCIA = ZA9_AGENCI AND E5_CONTA = ZA9_NUMCON
AND SE5.E5_RECPAG = 'P' AND SE5.E5_SITUACA <> 'C'  AND SE5.E5_TIPODOC NOT IN ('JR','MT','DC','CH') AND SE5.E5_MOTBX IN ('NOR','DEB','FAT')
AND SE5.E5_PREFIXO = 'FNM'
AND E5_DATA = ZA9_DATA
AND E5_VALOR = ZA9_VALOR
AND NOT EXISTS( SELECT E5_FILIAL FROM SE5030 ESTSE5 WHERE
ESTSE5.E5_FILIAL   = SE5.E5_FILIAL AND ESTSE5.E5_PREFIXO  = SE5.E5_PREFIXO AND
ESTSE5.E5_NUMERO   = SE5.E5_NUMERO AND ESTSE5.E5_PARCELA  = SE5.E5_PARCELA AND
ESTSE5.E5_TIPO     = SE5.E5_TIPO   AND ESTSE5.E5_CLIFOR   = SE5.E5_CLIFOR AND
ESTSE5.E5_LOJA     = SE5.E5_LOJA   AND ESTSE5.E5_SEQ      = SE5.E5_SEQ AND
ESTSE5.E5_TIPODOC  = 'ES' AND ESTSE5.E5_DATA <= '20491231' AND ESTSE5.D_E_L_E_T_=' ' )

)
FROM ZA9030
WHERE D_E_L_E_T_=' ' AND ZA9_TPDC='D' AND ZA9_TIPO='3'
AND ZA9_OCORRE = '104' AND ZA9_CODHIS = '2283'
ORDER BY ZA9_DATA DESC
*/
/*
SELECT ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, SUM(ZA9_VALOR) AS 'ZA9_VALOR'
FROM ZA9030
WHERE D_E_L_E_T_=' ' AND ZA9_TPDC='D' AND ZA9_TIPO='3'
AND ZA9_OCORRE = '112' AND ZA9_CODHIS IN ( '2100','2119')
AND ZA9_BANCO='399' AND ZA9_AGENCI='1764 ' AND ZA9_NUMCON='10943-90  '
--AND ZA9_DATA='20130627'
GROUP BY ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA

*/

*************************** CHEQUES
/*
----------------- CHEQUE COMPENSADO
SELECT *
FROM (
SELECT ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, SubsTring(ZA9_DOCUME,2,6) AS 'ZA9_CHEQUE' , CONVERT(MONEY,ISNULL(SUM(ZA9_VALOR),0)) AS 'ZA9_VALOR' ,
E5_VALOR = ( SELECT CONVERT(MONEY,ISNULL(SUM(E5_VALOR),0))
FROM SE5030 SE5
RIGHT JOIN SA6030 SA6 ON ( A6_COD = SE5.E5_BANCO  AND A6_AGENCIA = SE5.E5_AGENCIA AND A6_NUMCON = SE5.E5_CONTA AND SA6.D_E_L_E_T_=' ' )
WHERE SE5.D_E_L_E_T_=' ' AND E5_BANCO = ZA9_BANCO AND E5_AGENCIA = ZA9_AGENCI AND E5_CONTA = ZA9_NUMCON
AND SE5.E5_RECPAG = 'P' AND SE5.E5_TIPODOC = 'CH'
AND SE5.E5_NUMCHEQ =  SubsTring(ZA9_DOCUME,2,6)
)
FROM ZA9030 ZA9
WHERE D_E_L_E_T_=' ' AND ZA9_TPDC='D' AND ZA9_TIPO='3'
AND ZA9_OCORRE = '101' AND ZA9_CODHIS IN ('0019','1341')
AND ZA9_BANCO='399' AND ZA9_AGENCI='1764 ' AND ZA9_NUMCON='10943-90  '
AND ZA9_DATA='20130802'
GROUP BY ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, SubsTring(ZA9_DOCUME,2,6)
) TEMP1 WHERE ZA9_VALOR = E5_VALOR
ORDER BY ZA9_CHEQUE
*/

************************ FINAMES VERSAO 2
/*
----------------- FINAMES 2
SELECT *
FROM (
SELECT ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, CONVERT(MONEY,ISNULL(SUM(ZA9_VALOR),0)) AS 'ZA9_VALOR' ,
E5_VALOR = (
SELECT CONVERT(MONEY,ISNULL(SUM(E5_VALOR),0))
FROM SE5030 SE5
RIGHT JOIN SA6030 SA6 ON ( A6_COD = SE5.E5_BANCO  AND A6_AGENCIA = SE5.E5_AGENCIA AND A6_NUMCON = SE5.E5_CONTA AND SA6.D_E_L_E_T_=' ' )
WHERE SE5.D_E_L_E_T_=' ' AND E5_BANCO = ZA9_BANCO AND E5_AGENCIA = ZA9_AGENCI AND E5_CONTA = ZA9_NUMCON
AND SE5.E5_RECPAG = 'P' AND SE5.E5_SITUACA <> 'C'  AND SE5.E5_TIPODOC NOT IN ('JR','MT','DC','CH','BA') AND SE5.E5_MOTBX IN ('NOR','DEB','FAT')
AND SE5.E5_DATA = ZA9_DATA
AND SE5.E5_PREFIXO <> 'FNM' -- FINAMES
AND SE5.E5_NATUREZ IN ('1769','1734','1733','1722')
)
FROM ZA9030
WHERE D_E_L_E_T_=' ' AND ZA9_TPDC='D' AND ZA9_TIPO='3'
AND ZA9_OCORRE = '104' AND ZA9_CODHIS = '0370'
AND ZA9_BANCO='399' AND ZA9_AGENCI='1764 ' AND ZA9_NUMCON='10943-90  '
--AND ZA9_DATA='20130627'
GROUP BY ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA
) TEMP1 WHERE ZA9_VALOR = E5_VALOR
ORDER BY ZA9_DATA DESC
*/

********************* TRANSFERENCIAS BANCARIAS  - DEBITOS

/*
----------------- TRANSFERENCIAS BANCARIAS - DEBITOS
SELECT *
FROM (
SELECT ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, CONVERT(MONEY,ISNULL(SUM(ZA9_VALOR),0)) AS 'ZA9_VALOR' ,
E5_VALOR = ( SELECT CONVERT(MONEY,ISNULL(SUM(E5_VALOR),0))
FROM SE5030 SE5
RIGHT JOIN SA6030 SA6 ON ( A6_COD = SE5.E5_BANCO  AND A6_AGENCIA = SE5.E5_AGENCIA AND A6_NUMCON = SE5.E5_CONTA AND SA6.D_E_L_E_T_=' ' )
WHERE SE5.D_E_L_E_T_=' ' AND E5_BANCO = ZA9_BANCO AND E5_AGENCIA = ZA9_AGENCI AND E5_CONTA = ZA9_NUMCON
AND SE5.E5_MOEDA='TB' AND SE5.E5_PROCTRA<>'' AND SE5.E5_NUMERO = '' AND SE5.E5_SITUACA <> 'C' AND SE5.E5_TIPODOC IN ('TR','TE') AND E5_RECPAG='P'
AND SE5.E5_DATA = ZA9_DATA
)
FROM ZA9030
WHERE D_E_L_E_T_=' ' AND ZA9_TPDC='D' AND ZA9_TIPO='3'
AND ZA9_OCORRE = '117' AND ZA9_CODHIS = '7102'
AND ZA9_BANCO='399' AND ZA9_AGENCI='1764 ' AND ZA9_NUMCON='10943-90  '
AND ZA9_DATA='20130626'
GROUP BY ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA
) TEMP1 --WHERE ZA9_VALOR = E5_VALOR
ORDER BY ZA9_DATA DESC
*/

***************** TRANSFERENCIAS BANCARIAS - CREDITOS
/*
----------------- TRANSFERENCIAS BANCARIAS - CREDITOS
SELECT *
FROM (
SELECT ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, CONVERT(MONEY,ISNULL(SUM(ZA9_VALOR),0)) AS 'ZA9_VALOR' ,
E5_VALOR = ( SELECT CONVERT(MONEY,ISNULL(SUM(E5_VALOR),0))
FROM SE5030 SE5
RIGHT JOIN SA6030 SA6 ON ( A6_COD = SE5.E5_BANCO  AND A6_AGENCIA = SE5.E5_AGENCIA AND A6_NUMCON = SE5.E5_CONTA AND SA6.D_E_L_E_T_=' ' )
WHERE SE5.D_E_L_E_T_=' ' AND E5_BANCO = ZA9_BANCO AND E5_AGENCIA = ZA9_AGENCI AND E5_CONTA = ZA9_NUMCON
AND SE5.E5_MOEDA='TB' AND SE5.E5_PROCTRA<>'' AND SE5.E5_NUMERO = '' AND SE5.E5_SITUACA <> 'C' AND SE5.E5_TIPODOC IN ('TR','TE') AND E5_RECPAG='R'
AND SE5.E5_DATA = ZA9_DATA
)
FROM ZA9030
WHERE D_E_L_E_T_=' ' AND ZA9_TPDC='C' AND ZA9_TIPO='3'
AND ZA9_OCORRE = '209' AND ZA9_CODHIS = '1759'
AND ZA9_BANCO='399' AND ZA9_AGENCI='1764 ' AND ZA9_NUMCON='10943-90  '
AND ZA9_DATA='20130626'
GROUP BY ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA
) TEMP1 --WHERE ZA9_VALOR = E5_VALOR
ORDER BY ZA9_DATA DESC
*/

*********** TARIFAS - TAR CONNECTBANK MENSA
/*
SELECT *
FROM ZA9030
WHERE D_E_L_E_T_=' ' AND ZA9_TIPO='3' AND ZA9_TPDC='D'
AND ZA9_OCORRE <> '105' AND ZA9_CODHIS = '1392'
*/
*********** TARIFAS - TARIFA DE COBRANCA
/*
SELECT *
FROM ZA9030
WHERE D_E_L_E_T_=' ' AND ZA9_TIPO='3' AND ZA9_TPDC='D'
AND ZA9_OCORRE = '105' AND ZA9_CODHIS = '9229'
*/

*********** TARIFAS - TAR CTAS PAGAR
/*
SELECT *
FROM ZA9030
WHERE D_E_L_E_T_=' ' AND ZA9_TIPO='3' AND ZA9_TPDC='D'
AND ZA9_OCORRE = '105' AND ZA9_CODHIS = '9490'
*/
*********** TARIFAS - TAR CH IGUAL/ACIM 5MI
/*
SELECT *
FROM ZA9030
WHERE D_E_L_E_T_=' ' AND ZA9_TIPO='3' AND ZA9_TPDC='D'
AND ZA9_OCORRE = '105' AND ZA9_CODHIS = '5290'
*/
************ SISPAG TRIBUTOS
/*
SELECT *
FROM (
SELECT ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, CONVERT(MONEY,ISNULL(SUM(ZA9_VALOR),0)) AS 'ZA9_VALOR' ,
E5_VALOR = (
SELECT CONVERT(MONEY,ISNULL(SUM(E5_VALOR),0))
FROM SE5030 SE5
RIGHT JOIN SA6030 SA6 ON ( A6_COD = SE5.E5_BANCO  AND A6_AGENCIA = SE5.E5_AGENCIA AND A6_NUMCON = SE5.E5_CONTA AND SA6.D_E_L_E_T_=' ' )
WHERE SE5.D_E_L_E_T_=' ' AND E5_BANCO = ZA9_BANCO AND E5_AGENCIA = ZA9_AGENCI AND E5_CONTA = ZA9_NUMCON
AND SE5.E5_RECPAG = 'P' AND SE5.E5_SITUACA <> 'C'  AND SE5.E5_TIPODOC NOT IN ('JR','MT','DC','CH','BA') AND SE5.E5_MOTBX IN ('NOR','DEB','FAT')
AND SE5.E5_DATA = ZA9_DATA
AND SE5.E5_NATUREZ IN ('1822','1823')
)
FROM ZA9030
WHERE D_E_L_E_T_=' ' AND ZA9_TPDC='D' AND ZA9_TIPO='3'
AND ZA9_OCORRE = '104' AND ZA9_CODHIS IN ( '0071' )
GROUP BY ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA
) TEMP1 WHERE ZA9_VALOR <> E5_VALOR
ORDER BY ZA9_DATA DESC
*/

Static Function ZA9_112( _dData, _cBco, _cAge, _cCTA )
Local cQuery     := cQuery1    := cQuery2 := ""
Local cQuery3_I  := cQuery2_I  := cQuery1IF   := cQuery2F2 := ""
Local cQuery3_F  := cQuery2_F  := cQuery1_IF_S := cIF_S_Query := ""
Local cQuery2_1F := cQuery2_2F   := ""

DbSelectArea("SX6")

//If ! ExisteSX6( "PE_NATFINAM" )
//	CriarSX6( "PE_NATFINAM", "C", "Naturezas considerasas FINAMES no Sistema.", "1769,1734,1733,1722,1771,1758" )
//EndIf

cQuery := "SELECT SE5.R_E_C_N_O_ AS SE5RECNO, ZA9.R_E_C_N_O_ AS ZA9RECNO" + cCrLf
cQuery += "FROM "+RetSqlName("ZA9")+" ZA9 " + cCrLf
cQuery += "INNER JOIN "+RetSqlName("SE5")+" SE5 ON ( SE5.D_E_L_E_T_=' '  AND SE5.E5_FILIAL  = ZA9.ZA9_FILIAL " + cCrLf
cQuery += "                                 AND SE5.E5_BANCO   = ZA9.ZA9_BANCO  AND SE5.E5_AGENCIA = ZA9.ZA9_AGENCI " + cCrLf
cQuery += "                                 AND SE5.E5_CONTA   = ZA9.ZA9_NUMCON AND SE5.E5_DTDISPO = ZA9.ZA9_DATA " + cCrLf
cQuery += "                                 AND SE5.E5_VALOR   = ZA9.ZA9_VALOR ) " + cCrLf
cQuery += "WHERE ZA9.D_E_L_E_T_=' ' AND ZA9_TPDC = 'D' AND ZA9_TIPO = '3' " + cCrLf
cQuery += "AND ZA9_FILIAL = '"+xFilial("ZA9")+"' " + cCrLf
cQuery += "AND ZA9_OCORRE = '112' " + cCrLf
cQuery += "AND ZA9_BANCO = '"+_cBco+"' AND ZA9_AGENCI = '"+_cAge+"' AND ZA9_NUMCON = '"+_cCTA+"'  " + cCrLf
cQuery += "AND ZA9_DATA = '"+DTOS(_dData)+"' " + cCrLf
cQuery += "AND SE5.E5_RECPAG = 'P' " + cCrLf
cQuery += "AND SE5.E5_SITUACA NOT IN ( 'C' , 'E' , 'X' ) " + cCrLf
cQuery += "AND SE5.E5_TIPODOC NOT IN ('JR','MT','DC','CH','BA','ES') " + cCrLf
VarInfo("ZA9_112",cQuery)
MemoWrite( cStartPath + cExtDir + cDirQuery + 'ZA9_112.SQL',cQuery)

dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRBTMP",.F.,.T.)

TCSetField("TRBTMP", "E5_VALOR"   , "N", 17, 2 )
TCSetField("TRBTMP", "ZA9_VALOR"  , "N", 17, 2 )
TCSetField("TRBTMP", "ZA9_DATA"   , "D", 08, 0 )


TRBTMP->(dbGoTop())
Do While ! TRBTMP->(EOF())
	
	SE5->(dBGoto(TRBTMP->SE5RECNO))
	Reclock("SE5",.F.)
	SE5->E5_RECONC	 := 'x'
	SE5->(MsUnlock())
	
	ZA9->(dBGoto(TRBTMP->ZA9RECNO))
	Reclock("ZA9",.F.)
	ZA9->ZA9_RECONC := 'x'
	ZA9->(MsUnlock())
	
	TRBTMP->( dbSkip() )
	
Enddo

TRBTMP->(DbCloseArea())

Return


Static Function ZA9_FGTS( _dData, _cBco, _cAge, _cCTA )
Local cQuery     := cQuery1    := cQuery2 := ""
Local cQuery3_I  := cQuery2_I  := cQuery1IF   := cQuery2F2 := ""
Local cQuery3_F  := cQuery2_F  := cQuery1_IF_S := cIF_S_Query := ""
Local cQuery2_1F := cQuery2_2F   := ""

cQuery3_I   += "SELECT * " + cCrLf
cQuery3_I   += "FROM	( " + cCrLf

cQuery2_I   += "			SELECT ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, CONVERT(MONEY,ISNULL(SUM(ZA9_VALOR),0)) AS 'ZA9_VALOR', " + cCrLf
cQuery2_I   += "			E5_VALOR = ( " + cCrLf

cIF_S_Query += "   						SELECT CONVERT(MONEY,ISNULL(SUM(E5_VALOR),0)) " + cCrLf

cQuery1IF   += "   						FROM "+RetSqlName("SE5")+" SE5 " + cCrLf
cQuery1IF   += "   						RIGHT JOIN "+RetSqlName("SA6")+" SA6  ON ( A6_COD = SE5.E5_BANCO  AND A6_AGENCIA = SE5.E5_AGENCIA AND A6_NUMCON = SE5.E5_CONTA AND SA6.D_E_L_E_T_=' ' ) " + cCrLf
cQuery1IF   += "   						RIGHT JOIN "+RetSqlName("SED")+" SED  ON ( ED_CODIGO = SE5.E5_NATUREZ AND SED.D_E_L_E_T_=' ' AND ED_DESCRIC LIKE '%FGTS%' ) " + cCrLf
cQuery1IF   += "   						WHERE SE5.D_E_L_E_T_=' '  AND SE5.E5_RECPAG = 'P' AND SE5.E5_SITUACA <> 'C' " + cCrLf
cQuery1IF   += "   						AND SE5.E5_TIPODOC NOT IN ('JR','MT','DC','CH','BA','PA') AND SE5.E5_MOTBX IN ('NOR','DEB','FAT')  " + cCrLf
cQuery1IF   += "   						AND SE5.E5_BANCO = '"+_cBco+"' AND SE5.E5_AGENCIA = '"+_cAge+"' AND SE5.E5_CONTA = '"+_cCTA+"'  " + cCrLf
cQuery1IF   += "   						AND SE5.E5_DTDISPO = '"+DTOS(_dData)+"' " + cCrLf
cQuery1IF   += "   						AND NOT EXISTS( SELECT E5_FILIAL FROM "+RetSqlName("SE5")+" ESTSE5 WHERE " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_FILIAL   = SE5.E5_FILIAL AND ESTSE5.E5_PREFIXO  = SE5.E5_PREFIXO AND " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_NUMERO   = SE5.E5_NUMERO AND ESTSE5.E5_PARCELA  = SE5.E5_PARCELA AND " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_TIPO     = SE5.E5_TIPO   AND ESTSE5.E5_CLIFOR   = SE5.E5_CLIFOR AND " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_LOJA     = SE5.E5_LOJA   AND ESTSE5.E5_SEQ      = SE5.E5_SEQ AND  " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_TIPODOC  = 'ES' AND ESTSE5.E5_DATA <= '20491231' AND ESTSE5.D_E_L_E_T_=' ' ) " + cCrLf

cQuery2_1F  += "           			) " + cCrLf
cQuery2_1F  += "			FROM "+RetSqlName("ZA9")+" " + cCrLf
cQuery2F2   += "			WHERE D_E_L_E_T_=' ' AND ZA9_TPDC='D' AND ZA9_TIPO='3' " + cCrLf
cQuery2F2   += "			AND ZA9_OCORRE='104' AND ZA9_CODHIS='0086' " + cCrLf
cQuery2F2   += "			AND ZA9_BANCO='"+_cBco+"' AND ZA9_AGENCI = '"+_cAge+"' AND ZA9_NUMCON='"+_cCTA+"'  " + cCrLf
cQuery2F2   += "			AND ZA9_DATA='"+DTOS(_dData)+"' " + cCrLf
cQuery2_2F  += "			GROUP BY ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA " + cCrLf

cQuery3_F   += "			) " + cCrLf
cQuery3_F   += "TEMP1 WHERE ZA9_VALOR = E5_VALOR " + cCrLf
cQuery3_F   += "ORDER BY ZA9_DATA DESC " + cCrLf

cQuery += cQuery3_I
cQuery += cQuery2_I
cQuery += cIF_S_Query
cQuery += cQuery1IF
cQuery += cQuery2_1F + cQuery2F2 + cQuery2_2F
cQuery += cQuery3_F

MemoWrite( cStartPath + cExtDir + cDirQuery + 'ZA9_FGTS.SQL',cQuery)

dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRBTMP",.F.,.T.)

TCSetField("TRBTMP", "E5_VALOR"   , "N", 17, 2 )
TCSetField("TRBTMP", "ZA9_VALOR"  , "N", 17, 2 )
TCSetField("TRBTMP", "ZA9_DATA"   , "D", 08, 0 )

TRBTMP->(dbGoTop())
Do While ! TRBTMP->(EOF())
	
	cQuery1 := "UPDATE SE5 SET E5_RECONC = 'x', E5_YTPREC='A' " + cCrLf
	cQuery1 += cQuery1IF
	
	if SqlExecTC( cQuery1 ) <> 0
		// erro
	Else
		// ZA9_FILIAL, ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DTCNAB, ZA9_TIPO
		cQuery2 := "UPDATE "+RetSqlName("ZA9")+" SET ZA9_RECONC = 'x' " + cCrLf
		cQuery2 += cQuery2F2
		if SqlExecTC( cQuery2 ) <> 0
			// erro
		Endif
	Endif
	
	TRBTMP->( dbSkip() )
	
Enddo

TRBTMP->(DbCloseArea())

Return



Static Function ZA9_INSS( _dData, _cBco, _cAge, _cCTA )
Local cQuery     := cQuery1    := cQuery2 := ""
Local cQuery3_I  := cQuery2_I  := cQuery1IF   := cQuery2F2 := ""
Local cQuery3_F  := cQuery2_F  := cQuery1_IF_S := cIF_S_Query := ""
Local cQuery2_1F := cQuery2_2F   := ""

cQuery3_I   += "SELECT * " + cCrLf
cQuery3_I   += "FROM	( " + cCrLf

cQuery2_I   += "			SELECT ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, CONVERT(MONEY,ISNULL(SUM(ZA9_VALOR),0)) AS 'ZA9_VALOR', " + cCrLf
cQuery2_I   += "			E5_VALOR = ( " + cCrLf

cIF_S_Query += "   						SELECT CONVERT(MONEY,ISNULL(SUM(E5_VALOR),0)) " + cCrLf

cQuery1IF   += "   						FROM "+RetSqlName("SE5")+" SE5 " + cCrLf
cQuery1IF   += "   						RIGHT JOIN "+RetSqlName("SA6")+" SA6  ON ( A6_COD = SE5.E5_BANCO  AND A6_AGENCIA = SE5.E5_AGENCIA AND A6_NUMCON = SE5.E5_CONTA AND SA6.D_E_L_E_T_=' ' ) " + cCrLf
cQuery1IF   += "   						RIGHT JOIN "+RetSqlName("SED")+" SED  ON ( ED_CODIGO = SE5.E5_NATUREZ AND SED.D_E_L_E_T_=' ' AND ED_DESCRIC LIKE '%INSS%' ) " + cCrLf
cQuery1IF   += "   						WHERE SE5.D_E_L_E_T_=' '  AND SE5.E5_RECPAG = 'P' AND SE5.E5_SITUACA <> 'C' " + cCrLf
cQuery1IF   += "   						AND SE5.E5_TIPODOC NOT IN ('JR','MT','DC','CH','BA','PA') AND SE5.E5_MOTBX IN ('NOR','DEB','FAT')  " + cCrLf
cQuery1IF   += "   						AND SE5.E5_BANCO = '"+_cBco+"' AND SE5.E5_AGENCIA = '"+_cAge+"' AND SE5.E5_CONTA = '"+_cCTA+"'  " + cCrLf
cQuery1IF   += "   						AND SE5.E5_DTDISPO = '"+DTOS(_dData)+"' " + cCrLf
cQuery1IF   += "   						AND NOT EXISTS( SELECT E5_FILIAL FROM "+RetSqlName("SE5")+" ESTSE5 WHERE " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_FILIAL   = SE5.E5_FILIAL AND ESTSE5.E5_PREFIXO  = SE5.E5_PREFIXO AND " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_NUMERO   = SE5.E5_NUMERO AND ESTSE5.E5_PARCELA  = SE5.E5_PARCELA AND " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_TIPO     = SE5.E5_TIPO   AND ESTSE5.E5_CLIFOR   = SE5.E5_CLIFOR AND " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_LOJA     = SE5.E5_LOJA   AND ESTSE5.E5_SEQ      = SE5.E5_SEQ AND  " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_TIPODOC  = 'ES' AND ESTSE5.E5_DATA <= '20491231' AND ESTSE5.D_E_L_E_T_=' ' ) " + cCrLf

cQuery2_1F  += "           			) " + cCrLf
cQuery2_1F  += "			FROM "+RetSqlName("ZA9")+" " + cCrLf
cQuery2F2   += "			WHERE D_E_L_E_T_=' ' AND ZA9_TPDC='D' AND ZA9_TIPO='3' " + cCrLf
cQuery2F2   += "			AND ZA9_OCORRE='104' AND ZA9_CODHIS='4472' " + cCrLf
cQuery2F2   += "			AND ZA9_BANCO='"+_cBco+"' AND ZA9_AGENCI = '"+_cAge+"' AND ZA9_NUMCON='"+_cCTA+"'  " + cCrLf
cQuery2F2   += "			AND ZA9_DATA='"+DTOS(_dData)+"' " + cCrLf
cQuery2_2F  += "			GROUP BY ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA " + cCrLf

cQuery3_F   += "			) " + cCrLf
cQuery3_F   += "TEMP1 WHERE ZA9_VALOR = E5_VALOR " + cCrLf
cQuery3_F   += "ORDER BY ZA9_DATA DESC " + cCrLf

cQuery += cQuery3_I
cQuery += cQuery2_I
cQuery += cIF_S_Query
cQuery += cQuery1IF
cQuery += cQuery2_1F + cQuery2F2 + cQuery2_2F
cQuery += cQuery3_F

MemoWrite( cStartPath + cExtDir + cDirQuery + 'ZA9_INSS.SQL',cQuery)

dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRBTMP",.F.,.T.)

TCSetField("TRBTMP", "E5_VALOR"   , "N", 17, 2 )
TCSetField("TRBTMP", "ZA9_VALOR"  , "N", 17, 2 )
TCSetField("TRBTMP", "ZA9_DATA"   , "D", 08, 0 )

TRBTMP->(dbGoTop())
Do While ! TRBTMP->(EOF())
	
	cQuery1 := "UPDATE SE5 SET E5_RECONC = 'x', E5_YTPREC='A' " + cCrLf
	cQuery1 += cQuery1IF
	
	if SqlExecTC( cQuery1 ) <> 0
		// erro
	Else
		// ZA9_FILIAL, ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DTCNAB, ZA9_TIPO
		cQuery2 := "UPDATE "+RetSqlName("ZA9")+" SET ZA9_RECONC = 'x' " + cCrLf
		cQuery2 += cQuery2F2
		if SqlExecTC( cQuery2 ) <> 0
			// erro
		Endif
	Endif
	
	TRBTMP->( dbSkip() )
	
Enddo

TRBTMP->(DbCloseArea())

Return



Static Function ZA9_TRBMUN( _dData, _cBco, _cAge, _cCTA )
Local cQuery     := cQuery1    := cQuery2 := ""
Local cQuery3_I  := cQuery2_I  := cQuery1IF   := cQuery2F2 := ""
Local cQuery3_F  := cQuery2_F  := cQuery1_IF_S := cIF_S_Query := ""
Local cQuery2_1F := cQuery2_2F   := ""

cQuery3_I   += "SELECT * " + cCrLf
cQuery3_I   += "FROM	( " + cCrLf

cQuery2_I   += "			SELECT ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, CONVERT(MONEY,ISNULL(SUM(ZA9_VALOR),0)) AS 'ZA9_VALOR', " + cCrLf
cQuery2_I   += "			E5_VALOR = ( " + cCrLf

cIF_S_Query += "   						SELECT CONVERT(MONEY,ISNULL(SUM(E5_VALOR),0)) " + cCrLf

cQuery1IF   += "   						FROM "+RetSqlName("SE5")+" SE5 " + cCrLf
cQuery1IF   += "   						RIGHT JOIN "+RetSqlName("SA6")+" SA6  ON ( A6_COD = SE5.E5_BANCO  AND A6_AGENCIA = SE5.E5_AGENCIA AND A6_NUMCON = SE5.E5_CONTA AND SA6.D_E_L_E_T_=' ' ) " + cCrLf
cQuery1IF   += "   						RIGHT JOIN "+RetSqlName("SED")+" SED  ON ( ED_CODIGO = SE5.E5_NATUREZ AND SED.D_E_L_E_T_=' ' ) " + cCrLf
cQuery1IF   += "   						WHERE SE5.D_E_L_E_T_=' '  AND SE5.E5_RECPAG = 'P' AND SE5.E5_SITUACA <> 'C' " + cCrLf
cQuery1IF   += "   						AND SE5.E5_TIPODOC NOT IN ('JR','MT','DC','CH','BA','PA') AND SE5.E5_MOTBX IN ('NOR','DEB','FAT')  " + cCrLf
cQuery1IF   += "   						AND SE5.E5_BANCO = '"+_cBco+"' AND SE5.E5_AGENCIA = '"+_cAge+"' AND SE5.E5_CONTA = '"+_cCTA+"'  " + cCrLf
cQuery1IF   += "   						AND SE5.E5_DTDISPO = '"+DTOS(_dData)+"' " + cCrLf
cQuery1IF   += "   						AND SE5.E5_FORNECE IN ('000009') -- TRIBUTOS MUNICIPAIS " + cCrLf
cQuery1IF   += "   						AND NOT EXISTS( SELECT E5_FILIAL FROM "+RetSqlName("SE5")+" ESTSE5 WHERE " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_FILIAL   = SE5.E5_FILIAL AND ESTSE5.E5_PREFIXO  = SE5.E5_PREFIXO AND " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_NUMERO   = SE5.E5_NUMERO AND ESTSE5.E5_PARCELA  = SE5.E5_PARCELA AND " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_TIPO     = SE5.E5_TIPO   AND ESTSE5.E5_CLIFOR   = SE5.E5_CLIFOR AND " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_LOJA     = SE5.E5_LOJA   AND ESTSE5.E5_SEQ      = SE5.E5_SEQ AND  " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_TIPODOC  = 'ES' AND ESTSE5.E5_DATA <= '20491231' AND ESTSE5.D_E_L_E_T_=' ' ) " + cCrLf

cQuery2_1F  += "           			) " + cCrLf
cQuery2_1F  += "			FROM "+RetSqlName("ZA9")+" " + cCrLf
cQuery2F2   += "			WHERE D_E_L_E_T_=' ' AND ZA9_TPDC='D' AND ZA9_TIPO='3' " + cCrLf
cQuery2F2   += "			AND ZA9_OCORRE = '104' AND ZA9_CODHIS = '0060' " + cCrLf
cQuery2F2   += "			AND ZA9_BANCO='"+_cBco+"' AND ZA9_AGENCI = '"+_cAge+"' AND ZA9_NUMCON='"+_cCTA+"'  " + cCrLf
cQuery2F2   += "			AND ZA9_DATA='"+DTOS(_dData)+"' " + cCrLf
cQuery2_2F  += "			GROUP BY ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA " + cCrLf

cQuery3_F   += "			) " + cCrLf
cQuery3_F   += "TEMP1 WHERE ZA9_VALOR = E5_VALOR " + cCrLf
cQuery3_F   += "ORDER BY ZA9_DATA DESC " + cCrLf

cQuery += cQuery3_I
cQuery += cQuery2_I
cQuery += cIF_S_Query
cQuery += cQuery1IF
cQuery += cQuery2_1F + cQuery2F2 + cQuery2_2F
cQuery += cQuery3_F

MemoWrite( cStartPath + cExtDir + cDirQuery + 'ZA9_TRBMUN.SQL',cQuery)

dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRBTMP",.F.,.T.)

TCSetField("TRBTMP", "E5_VALOR"   , "N", 17, 2 )
TCSetField("TRBTMP", "ZA9_VALOR"  , "N", 17, 2 )
TCSetField("TRBTMP", "ZA9_DATA"   , "D", 08, 0 )

TRBTMP->(dbGoTop())
Do While ! TRBTMP->(EOF())
	
	cQuery1 := "UPDATE SE5 SET E5_RECONC = 'x', E5_YTPREC='A' " + cCrLf
	cQuery1 += cQuery1IF
	
	if SqlExecTC( cQuery1 ) <> 0
		// erro
	Else
		// ZA9_FILIAL, ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DTCNAB, ZA9_TIPO
		cQuery2 := "UPDATE "+RetSqlName("ZA9")+" SET ZA9_RECONC = 'x' " + cCrLf
		cQuery2 += cQuery2F2
		if SqlExecTC( cQuery2 ) <> 0
			// erro
		Endif
	Endif
	
	TRBTMP->( dbSkip() )
	
Enddo

TRBTMP->(DbCloseArea())

Return




Static Function ZA9_AGUA( _dData, _cBco, _cAge, _cCTA )
Local cQuery     := cQuery1    := cQuery2 := ""
Local cQuery3_I  := cQuery2_I  := cQuery1IF   := cQuery2F2 := ""
Local cQuery3_F  := cQuery2_F  := cQuery1_IF_S := cIF_S_Query := ""
Local cQuery2_1F := cQuery2_2F   := ""

cQuery3_I   += "SELECT * " + cCrLf
cQuery3_I   += "FROM	( " + cCrLf

cQuery2_I   += "			SELECT ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, CONVERT(MONEY,ISNULL(SUM(ZA9_VALOR),0)) AS 'ZA9_VALOR', " + cCrLf
cQuery2_I   += "			E5_VALOR = ( " + cCrLf

cIF_S_Query += "   						SELECT CONVERT(MONEY,ISNULL(SUM(E5_VALOR),0)) " + cCrLf

cQuery1IF   += "   						FROM "+RetSqlName("SE5")+" SE5 " + cCrLf
cQuery1IF   += "   						RIGHT JOIN "+RetSqlName("SA6")+" SA6  ON ( A6_COD = SE5.E5_BANCO  AND A6_AGENCIA = SE5.E5_AGENCIA AND A6_NUMCON = SE5.E5_CONTA AND SA6.D_E_L_E_T_=' ' ) " + cCrLf
cQuery1IF   += "   						RIGHT JOIN "+RetSqlName("SED")+" SED  ON ( ED_CODIGO = SE5.E5_NATUREZ AND SED.D_E_L_E_T_=' ' ) " + cCrLf
cQuery1IF   += "   						WHERE SE5.D_E_L_E_T_=' '  AND SE5.E5_RECPAG = 'P' AND SE5.E5_SITUACA <> 'C' " + cCrLf
cQuery1IF   += "   						AND SE5.E5_TIPODOC NOT IN ('JR','MT','DC','CH','BA','PA') AND SE5.E5_MOTBX IN ('NOR','DEB','FAT')  " + cCrLf
cQuery1IF   += "   						AND SE5.E5_BANCO = '"+_cBco+"' AND SE5.E5_AGENCIA = '"+_cAge+"' AND SE5.E5_CONTA = '"+_cCTA+"'  " + cCrLf
cQuery1IF   += "   						AND SE5.E5_DTDISPO = '"+DTOS(_dData)+"' " + cCrLf
cQuery1IF   += "   						AND SE5.E5_FORNECE IN ('000237') -- COMPESA " + cCrLf
cQuery1IF   += "   						AND NOT EXISTS( SELECT E5_FILIAL FROM "+RetSqlName("SE5")+" ESTSE5 WHERE " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_FILIAL   = SE5.E5_FILIAL AND ESTSE5.E5_PREFIXO  = SE5.E5_PREFIXO AND " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_NUMERO   = SE5.E5_NUMERO AND ESTSE5.E5_PARCELA  = SE5.E5_PARCELA AND " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_TIPO     = SE5.E5_TIPO   AND ESTSE5.E5_CLIFOR   = SE5.E5_CLIFOR AND " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_LOJA     = SE5.E5_LOJA   AND ESTSE5.E5_SEQ      = SE5.E5_SEQ AND  " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_TIPODOC  = 'ES' AND ESTSE5.E5_DATA <= '20491231' AND ESTSE5.D_E_L_E_T_=' ' ) " + cCrLf

cQuery2_1F  += "           			) " + cCrLf
cQuery2_1F  += "			FROM "+RetSqlName("ZA9")+" " + cCrLf
cQuery2F2   += "			WHERE D_E_L_E_T_=' ' AND ZA9_TPDC='D' AND ZA9_TIPO='3' " + cCrLf
cQuery2F2   += "			AND ZA9_OCORRE = '104' AND ZA9_CODHIS = '0027' " + cCrLf
cQuery2F2   += "			AND ZA9_BANCO='"+_cBco+"' AND ZA9_AGENCI = '"+_cAge+"' AND ZA9_NUMCON='"+_cCTA+"'  " + cCrLf
cQuery2F2   += "			AND ZA9_DATA='"+DTOS(_dData)+"' " + cCrLf
cQuery2_2F  += "			GROUP BY ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA " + cCrLf

cQuery3_F   += "			) " + cCrLf
cQuery3_F   += "TEMP1 WHERE ZA9_VALOR = E5_VALOR " + cCrLf
cQuery3_F   += "ORDER BY ZA9_DATA DESC " + cCrLf

cQuery += cQuery3_I
cQuery += cQuery2_I
cQuery += cIF_S_Query
cQuery += cQuery1IF
cQuery += cQuery2_1F + cQuery2F2 + cQuery2_2F
cQuery += cQuery3_F

MemoWrite( cStartPath + cExtDir + cDirQuery + 'ZA9_AGUA.SQL',cQuery)

dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRBTMP",.F.,.T.)

TCSetField("TRBTMP", "E5_VALOR"   , "N", 17, 2 )
TCSetField("TRBTMP", "ZA9_VALOR"  , "N", 17, 2 )
TCSetField("TRBTMP", "ZA9_DATA"   , "D", 08, 0 )

TRBTMP->(dbGoTop())
Do While ! TRBTMP->(EOF())
	
	cQuery1 := "UPDATE SE5 SET E5_RECONC = 'x', E5_YTPREC='A' " + cCrLf
	cQuery1 += cQuery1IF
	
	if SqlExecTC( cQuery1 ) <> 0
		// erro
	Else
		// ZA9_FILIAL, ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DTCNAB, ZA9_TIPO
		cQuery2 := "UPDATE "+RetSqlName("ZA9")+" SET ZA9_RECONC = 'x' " + cCrLf
		cQuery2 += cQuery2F2
		if SqlExecTC( cQuery2 ) <> 0
			// erro
		Endif
	Endif
	
	TRBTMP->( dbSkip() )
	
Enddo

TRBTMP->(DbCloseArea())

Return



Static Function ZA9_LUZ( _dData, _cBco, _cAge, _cCTA )
Local cQuery     := cQuery1    := cQuery2 := ""
Local cQuery3_I  := cQuery2_I  := cQuery1IF   := cQuery2F2 := ""
Local cQuery3_F  := cQuery2_F  := cQuery1_IF_S := cIF_S_Query := ""
Local cQuery2_1F := cQuery2_2F   := ""

cQuery3_I   += "SELECT * " + cCrLf
cQuery3_I   += "FROM	( " + cCrLf

cQuery2_I   += "			SELECT ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, CONVERT(MONEY,ISNULL(SUM(ZA9_VALOR),0)) AS 'ZA9_VALOR', " + cCrLf
cQuery2_I   += "			E5_VALOR = ( " + cCrLf

cIF_S_Query += "   						SELECT CONVERT(MONEY,ISNULL(SUM(E5_VALOR),0)) " + cCrLf

cQuery1IF   += "   						FROM "+RetSqlName("SE5")+" SE5 " + cCrLf
cQuery1IF   += "   						RIGHT JOIN "+RetSqlName("SA6")+" SA6  ON ( A6_COD = SE5.E5_BANCO  AND A6_AGENCIA = SE5.E5_AGENCIA AND A6_NUMCON = SE5.E5_CONTA AND SA6.D_E_L_E_T_=' ' ) " + cCrLf
cQuery1IF   += "   						RIGHT JOIN "+RetSqlName("SED")+" SED  ON ( ED_CODIGO = SE5.E5_NATUREZ AND SED.D_E_L_E_T_=' ' ) " + cCrLf
cQuery1IF   += "   						WHERE SE5.D_E_L_E_T_=' '  AND SE5.E5_RECPAG = 'P' AND SE5.E5_SITUACA <> 'C' " + cCrLf
cQuery1IF   += "   						AND SE5.E5_TIPODOC NOT IN ('JR','MT','DC','CH','BA','PA') AND SE5.E5_MOTBX IN ('NOR','DEB','FAT')  " + cCrLf
cQuery1IF   += "   						AND SE5.E5_BANCO = '"+_cBco+"' AND SE5.E5_AGENCIA = '"+_cAge+"' AND SE5.E5_CONTA = '"+_cCTA+"'  " + cCrLf
cQuery1IF   += "   						AND SE5.E5_DTDISPO = '"+DTOS(_dData)+"' " + cCrLf
cQuery1IF   += "   						AND SE5.E5_FORNECE IN ('000185') -- CELPE " + cCrLf
cQuery1IF   += "   						AND NOT EXISTS( SELECT E5_FILIAL FROM "+RetSqlName("SE5")+" ESTSE5 WHERE " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_FILIAL   = SE5.E5_FILIAL AND ESTSE5.E5_PREFIXO  = SE5.E5_PREFIXO AND " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_NUMERO   = SE5.E5_NUMERO AND ESTSE5.E5_PARCELA  = SE5.E5_PARCELA AND " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_TIPO     = SE5.E5_TIPO   AND ESTSE5.E5_CLIFOR   = SE5.E5_CLIFOR AND " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_LOJA     = SE5.E5_LOJA   AND ESTSE5.E5_SEQ      = SE5.E5_SEQ AND  " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_TIPODOC  = 'ES' AND ESTSE5.E5_DATA <= '20491231' AND ESTSE5.D_E_L_E_T_=' ' ) " + cCrLf

cQuery2_1F  += "           			) " + cCrLf
cQuery2_1F  += "			FROM "+RetSqlName("ZA9")+" " + cCrLf
cQuery2F2   += "			WHERE D_E_L_E_T_=' ' AND ZA9_TPDC='D' AND ZA9_TIPO='3' " + cCrLf
cQuery2F2   += "			AND ZA9_OCORRE = '104' AND ZA9_CODHIS = '0035' " + cCrLf
cQuery2F2   += "			AND ZA9_BANCO='"+_cBco+"' AND ZA9_AGENCI = '"+_cAge+"' AND ZA9_NUMCON='"+_cCTA+"'  " + cCrLf
cQuery2F2   += "			AND ZA9_DATA='"+DTOS(_dData)+"' " + cCrLf
cQuery2_2F  += "			GROUP BY ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA " + cCrLf

cQuery3_F   += "			) " + cCrLf
cQuery3_F   += "TEMP1 WHERE ZA9_VALOR = E5_VALOR " + cCrLf
cQuery3_F   += "ORDER BY ZA9_DATA DESC " + cCrLf

cQuery += cQuery3_I
cQuery += cQuery2_I
cQuery += cIF_S_Query
cQuery += cQuery1IF
cQuery += cQuery2_1F + cQuery2F2 + cQuery2_2F
cQuery += cQuery3_F

MemoWrite( cStartPath + cExtDir + cDirQuery + 'ZA9_LUZ.SQL',cQuery)

dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRBTMP",.F.,.T.)

TCSetField("TRBTMP", "E5_VALOR"   , "N", 17, 2 )
TCSetField("TRBTMP", "ZA9_VALOR"  , "N", 17, 2 )
TCSetField("TRBTMP", "ZA9_DATA"   , "D", 08, 0 )

TRBTMP->(dbGoTop())
Do While ! TRBTMP->(EOF())
	
	cQuery1 := "UPDATE SE5 SET E5_RECONC = 'x', E5_YTPREC='A' " + cCrLf
	cQuery1 += cQuery1IF
	
	if SqlExecTC( cQuery1 ) <> 0
		// erro
	Else
		// ZA9_FILIAL, ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DTCNAB, ZA9_TIPO
		cQuery2 := "UPDATE "+RetSqlName("ZA9")+" SET ZA9_RECONC = 'x' " + cCrLf
		cQuery2 += cQuery2F2
		if SqlExecTC( cQuery2 ) <> 0
			// erro
		Endif
	Endif
	
	TRBTMP->( dbSkip() )
	
Enddo

TRBTMP->(DbCloseArea())

Return




Static Function ZA9_FONE( _dData, _cBco, _cAge, _cCTA )
Local cQuery     := cQuery1    := cQuery2 := ""
Local cQuery3_I  := cQuery2_I  := cQuery1IF   := cQuery2F2 := ""
Local cQuery3_F  := cQuery2_F  := cQuery1_IF_S := cIF_S_Query := ""
Local cQuery2_1F := cQuery2_2F   := ""

cQuery3_I   += "SELECT * " + cCrLf
cQuery3_I   += "FROM	( " + cCrLf

cQuery2_I   += "			SELECT ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, CONVERT(MONEY,ISNULL(SUM(ZA9_VALOR),0)) AS 'ZA9_VALOR', " + cCrLf
cQuery2_I   += "			E5_VALOR = ( " + cCrLf

cIF_S_Query += "   						SELECT CONVERT(MONEY,ISNULL(SUM(E5_VALOR),0)) " + cCrLf

cQuery1IF   += "   						FROM "+RetSqlName("SE5")+" SE5 " + cCrLf
cQuery1IF   += "   						RIGHT JOIN "+RetSqlName("SA6")+" SA6  ON ( A6_COD = SE5.E5_BANCO  AND A6_AGENCIA = SE5.E5_AGENCIA AND A6_NUMCON = SE5.E5_CONTA AND SA6.D_E_L_E_T_=' ' ) " + cCrLf
cQuery1IF   += "   						RIGHT JOIN "+RetSqlName("SED")+" SED  ON ( ED_CODIGO = SE5.E5_NATUREZ AND SED.D_E_L_E_T_=' ' ) " + cCrLf
cQuery1IF   += "   						WHERE SE5.D_E_L_E_T_=' '  AND SE5.E5_RECPAG = 'P' AND SE5.E5_SITUACA <> 'C' " + cCrLf
cQuery1IF   += "   						AND SE5.E5_TIPODOC NOT IN ('JR','MT','DC','CH','BA','PA') AND SE5.E5_MOTBX IN ('NOR','DEB','FAT')  " + cCrLf
cQuery1IF   += "   						AND SE5.E5_BANCO = '"+_cBco+"' AND SE5.E5_AGENCIA = '"+_cAge+"' AND SE5.E5_CONTA = '"+_cCTA+"'  " + cCrLf
cQuery1IF   += "   						AND SE5.E5_DTDISPO = '"+DTOS(_dData)+"' " + cCrLf
cQuery1IF   += "   						AND SE5.E5_FORNECE IN ('005005','005700','006040','007640','000034','004671','008415','010326','007013') -- TELECOMUNICACOES " + cCrLf
cQuery1IF   += "   						AND NOT EXISTS( SELECT E5_FILIAL FROM "+RetSqlName("SE5")+" ESTSE5 WHERE " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_FILIAL   = SE5.E5_FILIAL AND ESTSE5.E5_PREFIXO  = SE5.E5_PREFIXO AND " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_NUMERO   = SE5.E5_NUMERO AND ESTSE5.E5_PARCELA  = SE5.E5_PARCELA AND " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_TIPO     = SE5.E5_TIPO   AND ESTSE5.E5_CLIFOR   = SE5.E5_CLIFOR AND " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_LOJA     = SE5.E5_LOJA   AND ESTSE5.E5_SEQ      = SE5.E5_SEQ AND  " + cCrLf
cQuery1IF   += "                          ESTSE5.E5_TIPODOC  = 'ES' AND ESTSE5.E5_DATA <= '20491231' AND ESTSE5.D_E_L_E_T_=' ' ) " + cCrLf

cQuery2_1F  += "           			) " + cCrLf
cQuery2_1F  += "			FROM "+RetSqlName("ZA9")+" " + cCrLf
cQuery2F2   += "			WHERE D_E_L_E_T_=' ' AND ZA9_TPDC='D' AND ZA9_TIPO='3' " + cCrLf
cQuery2F2   += "			AND ZA9_OCORRE = '104' AND ZA9_CODHIS = '0043' " + cCrLf
cQuery2F2   += "			AND ZA9_BANCO='"+_cBco+"' AND ZA9_AGENCI = '"+_cAge+"' AND ZA9_NUMCON='"+_cCTA+"'  " + cCrLf
cQuery2F2   += "			AND ZA9_DATA='"+DTOS(_dData)+"' " + cCrLf
cQuery2_2F  += "			GROUP BY ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA " + cCrLf

cQuery3_F   += "			) " + cCrLf
cQuery3_F   += "TEMP1 WHERE ZA9_VALOR = E5_VALOR " + cCrLf
cQuery3_F   += "ORDER BY ZA9_DATA DESC " + cCrLf

cQuery += cQuery3_I
cQuery += cQuery2_I
cQuery += cIF_S_Query
cQuery += cQuery1IF
cQuery += cQuery2_1F + cQuery2F2 + cQuery2_2F
cQuery += cQuery3_F

MemoWrite( cStartPath + cExtDir + cDirQuery + 'ZA9_FONE.SQL',cQuery)

dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRBTMP",.F.,.T.)

TCSetField("TRBTMP", "E5_VALOR"   , "N", 17, 2 )
TCSetField("TRBTMP", "ZA9_VALOR"  , "N", 17, 2 )
TCSetField("TRBTMP", "ZA9_DATA"   , "D", 08, 0 )

TRBTMP->(dbGoTop())
Do While ! TRBTMP->(EOF())
	
	cQuery1 := "UPDATE SE5 SET E5_RECONC = 'x', E5_YTPREC='A' " + cCrLf
	cQuery1 += cQuery1IF
	
	if SqlExecTC( cQuery1 ) <> 0
		// erro
	Else
		// ZA9_FILIAL, ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DTCNAB, ZA9_TIPO
		cQuery2 := "UPDATE "+RetSqlName("ZA9")+" SET ZA9_RECONC = 'x' " + cCrLf
		cQuery2 += cQuery2F2
		if SqlExecTC( cQuery2 ) <> 0
			// erro
		Endif
	Endif
	
	TRBTMP->( dbSkip() )
	
Enddo

TRBTMP->(DbCloseArea())

Return



Static Function ZA9_TARIFA()

Reclock("SE5",.T.)
SE5->E5_FILIAL   := xFilial("SE5")
SE5->E5_FILORIG  := cFilAnt
SE5->E5_VALOR    := ZA9->ZA9_VALOR
SE5->E5_BANCO    := ZA9->ZA9_BANCO
SE5->E5_AGENCIA  := ZA9->ZA9_AGENCI
SE5->E5_CONTA    := ZA9->ZA9_NUMCON
SE5->E5_DATA     := SE5->E5_VENCTO := SE5->E5_DTDISPO  := ZA9->ZA9_DATA
SE5->E5_DTDIGIT  := Date()
SE5->E5_HISTOR   := Padr(ZA9->ZA9_HIST,Len(SE5->E5_HISTOR))
SE5->E5_BENEF    := ZA9->ZA9_HIST
SE5->E5_NATUREZ  := Alltrim(&(GetMv("MV_NATDPBC")))
SE5->E5_RECPAG   := "P"
SE5->E5_MOEDA    := "M1"
SE5->E5_RATEIO   := "N"
SE5->E5_MODSPB   := "1"
SE5->E5_TIPOLAN  := "D"
SE5->E5_RECONC   := "x"
//SE5->E5_YTPREC   := 'A'
SE5->E5_ARQCNAB  := StrTran(ZA9->ZA9_ARQCNA,".RET","")
//SE5->E5_YCODTAR  := ZA9->ZA9_CODHIS
SE5->E5_ORIGEM   := "PB680FIN"
//SE5->E5_BCOCNAB  := "" // PREENCHER DEPOIS
SE5->(MsUnlock())

/*/
ZA0->( DbSetOrder(2) )
If ! ZA0->( DbSeek( xFilial("ZA0") + ZA9->ZA9_BANCO + ZA9->ZA9_CODHIS ) )
	RecLock("ZA0",.T.)
	ZA0->ZA0_FILIAL  := xFilial("ZA0")
	ZA0->ZA0_CODIGO  := ZA9->ZA9_CODHIS
	ZA0->ZA0_BANCO   := ZA9->ZA9_BANCO
	ZA0->ZA0_DESCTA  := ZA9->ZA9_HIST
	ZA0->( MSUnLock() )
Endif
/*/

RecLock("ZA9",.F.)
ZA9->ZA9_RECONC  := "x"
ZA9->( MSUnLock() )

// Atualiza Saldo Bancario padrao do sistema
AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DATA,SE5->E5_VALOR,"-") //pagar

Return

Static Function CriaSE8()

SE8->( DbSetOrder(1) )
If ! SE8->( dbSeek( xFilial("SE8") + ZA9->ZA9_BANCO + ZA9->ZA9_AGENCI + ZA9->ZA9_NUMCON + DTOS(ZA9->ZA9_DATA) ) )
	RecLock("SE8",.T.)
	SE8->E8_FILIAL   := xFilial("SE8")
	SE8->E8_BANCO    := ZA9->ZA9_BANCO
	SE8->E8_AGENCIA  := ZA9->ZA9_AGENCI
	SE8->E8_CONTA    := ZA9->ZA9_NUMCON
	SE8->E8_DTSALATU := ZA9->ZA9_DATA
	SE8->(MsUnlock())
Endif

Return


Static Function ZA9_MOVBLOQ()
Local lRet    := .F.
Local _aCabec := {}
Local dSave   := dDataBase

dDataBase := dBaixa  := dDtCredito := ZA9->ZA9_DATA

Aadd(_aCabec, {"E1_PREFIXO" 	, SE1->E1_PREFIXO, Nil})
Aadd(_aCabec, {"E1_NUM"		 	, SE1->E1_NUM	  , Nil})
Aadd(_aCabec, {"E1_PARCELA" 	, SE1->E1_PARCELA, Nil})
Aadd(_aCabec, {"E1_TIPO" 		, SE1->E1_TIPO	  , Nil})
Aadd(_aCabec, {"E1_CLIENTE"	, SE1->E1_CLIENTE, Nil})
Aadd(_aCabec, {"E1_LOJA"   	, SE1->E1_LOJA   , Nil})
Aadd(_aCabec, {"AUTJUROS"   	, 0			 	  , Nil})
Aadd(_aCabec, {"AUTMULTA"   	, 0 	    	     , Nil})
Aadd(_aCabec, {"AUTVALREC"		, ZA9->ZA9_VALOR , Nil})
Aadd(_aCabec, {"AUTDESCONT"  	, 0	 	        , Nil})
Aadd(_aCabec, {"AUTBANCO"     , ""             , Nil})
Aadd(_aCabec, {"AUTAGENCIA"   , ""             , Nil})
Aadd(_aCabec, {"AUTCONTA"     , ""             , Nil})
Aadd(_aCabec, {"AUTMOTBX" 		, "BLQ"			  , Nil})
Aadd(_aCabec, {"AUTHIST"		, 'VLR REF. AO FIN. N: '+ZA9->ZA9_DOCUME , Nil})
Aadd(_aCabec, {"AUTDTBAIXA" 	, ZA9->ZA9_DATA  , Nil})
Aadd(_aCabec, {"AUTDTCREDITO"	, ZA9->ZA9_DATA  , Nil})

lMsErroAuto := .F.
Begin Transaction

GetMv("MV_ANTCRED")
PutMv("MV_ANTCRED","T") // permitir baixas antecipadas a emissao

MSExecAuto({|x,y| fina070(x,y)},_aCabec,3) //3-Inclusao

GetMv("MV_ANTCRED")
PutMv("MV_ANTCRED","F") // NAO permitir baixas antecipadas a emissao é o padrao do sistema

IF lMsErroAuto
	DisarmTransaction()
	MostraErro()
Else
	lRet := .t.	// sucesso
Endif

End Transaction

dDataBase := dSave

Return lRet

Static Function ZA9_BLOQMOV()

Begin Transaction
Reclock("SE5",.T.)
SE5->E5_FILIAL   := xFilial("SE5")
SE5->E5_FILORIG  := cFilAnt
SE5->E5_VALOR    := ZA9->ZA9_VALOR
SE5->E5_BANCO    := ZA9->ZA9_BANCO
SE5->E5_AGENCIA  := ZA9->ZA9_AGENCI
SE5->E5_CONTA    := ZA9->ZA9_NUMCON
SE5->E5_DATA     := SE5->E5_VENCTO := SE5->E5_DTDISPO  := ZA9->ZA9_DATA
SE5->E5_DTDIGIT  := Date()
SE5->E5_HISTOR   := Padr('DEP BLOQ REF. AO FIN. N: '+Alltrim(ZA9->ZA9_DOCUME),Len(SE5->E5_HISTOR))
SE5->E5_BENEF    := Alltrim(ZA9->ZA9_HIST) + ' N: ' + ZA9->ZA9_DOCUME
SE5->E5_CC       := SE5->E5_CCD   := SE5->E5_CCC := '001' //SE1->E1_CC
SE5->E5_NATUREZ  := SE5->E5_ITEMC := SE5->E5_ITEMD := '5041'
SE5->E5_RECPAG   := "R"
SE5->E5_MOEDA    := "M1"
SE5->E5_RATEIO   := "N"
SE5->E5_MODSPB   := "1"
SE5->E5_TIPOLAN  := "C"
SE5->E5_RECONC   := "x"
//SE5->E5_YTPREC   := 'A'
SE5->E5_ARQCNAB  := ZA9->ZA9_ARQCNA
SE5->E5_YCODTAR  := ZA9->ZA9_CODHIS
SE5->E5_ORIGEM   := "PB680FIN"
SE5->E5_BCOCNAB  := "" // PREENCHER DEPOIS
SE5->(MsUnlock())
/*/
ZA0->( DbSetOrder(2) )
If ! ZA0->( DbSeek( xFilial("ZA0") + ZA9->ZA9_BANCO + ZA9->ZA9_CODHIS ) )
	RecLock("ZA0",.T.)
	ZA0->ZA0_FILIAL  := xFilial("ZA0")
	ZA0->ZA0_CODIGO  := ZA9->ZA9_CODHIS
	ZA0->ZA0_BANCO   := ZA9->ZA9_BANCO
	ZA0->ZA0_DESCTA  := ZA9->ZA9_HIST
	ZA0->( MSUnLock() )
Endif
/*/
RecLock("ZA9",.F.)
ZA9->ZA9_RECONC  := "x"
ZA9->( MSUnLock() )

End Transaction

// Atualiza Saldo Bancario padrao do sistema
AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DATA,SE5->E5_VALOR,"-") //pagar

Return



User Function asdf
/*/
SELECT ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, A6_NREDUZ, ZA9_DATA, SUM(ZA9_VALOR) AS 'ZA9_SALDO', ZA9_TPDC,
E8_SALDO = ( SELECT CONVERT(MONEY,ISNULL(SUM(E8_SALATUA),0)) FROM SE8030 SE8
WHERE E8_BANCO = ZA9_BANCO  AND E8_AGENCIA = ZA9_AGENCI AND E8_CONTA = ZA9_NUMCON AND E8_DTSALAT = ZA9_DATA AND SE8.D_E_L_E_T_=' ' )
FROM (
SELECT A6_NREDUZ, ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, ZA9_TPDC, CONVERT(MONEY,ISNULL(SUM(ZA9_VALOR),0)) AS 'ZA9_VALOR'
FROM ZA9030 ZA9
RIGHT JOIN SA6030 SA6 ON ( A6_COD = ZA9_BANCO  AND A6_AGENCIA = ZA9_AGENCI AND A6_NUMCON = ZA9_NUMCON AND SA6.D_E_L_E_T_=' ' )
WHERE ZA9.D_E_L_E_T_=' ' AND ZA9_TIPO='5' --AND ZA9_DATA = '20130502'
AND ZA9_DATA BETWEEN '20130801' AND '20130831'
GROUP BY A6_NREDUZ, ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, ZA9_TPDC
) TEMP
GROUP BY A6_NREDUZ, ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, ZA9_TPDC
ORDER BY ZA9_DATA, ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON

1.00
SELECT A6_NREDUZ, EA_PORTADO, EA_AGEDEP, EA_NUMCON, E2_VENCREA, CONVERT(MONEY,ISNULL(SUM(E2_SALDO),0)) AS 'A_PAGAR', 'D' AS 'TIPO'
FROM SE2030 SE2, SEA030 SEA
RIGHT JOIN SA6030 SA6 ON ( A6_COD = EA_PORTADO AND A6_AGENCIA = EA_AGEDEP AND A6_NUMCON = EA_NUMCON AND SA6.D_E_L_E_T_=' ' )
WHERE E2_VENCREA BETWEEN '20130901' AND '20130930' AND E2_SALDO > 0 AND E2_NUMBOR<>''
AND E2_PORTADO <> '' AND SE2.D_E_L_E_T_=' '
AND EA_CART    = 'P' AND EA_PORTADO NOT IN ('CX1')
AND E2_FILIAL  = EA_FILIAL  AND E2_NUMBOR  = EA_NUMBOR  AND E2_PREFIXO = EA_PREFIXO AND E2_NUM     = EA_NUM
AND E2_PARCELA = EA_PARCELA AND E2_TIPO    = EA_TIPO    AND E2_FORNECE = EA_FORNECE AND E2_LOJA    = EA_LOJA
GROUP BY A6_NREDUZ, EA_PORTADO, EA_AGEDEP, EA_NUMCON, E2_VENCREA


SELECT A6_NREDUZ, EA_PORTADO, EA_AGEDEP, EA_NUMCON, E1_VENCREA, CONVERT(MONEY,ISNULL(SUM(E1_SALDO),0)) AS 'A_RECEBER', 'C' AS 'TIPO'
FROM SE1030 SE1, SEA030 SEA
RIGHT JOIN SA6030 SA6 ON ( A6_COD = EA_PORTADO AND A6_AGENCIA = EA_AGEDEP AND A6_NUMCON = EA_NUMCON AND SA6.D_E_L_E_T_=' ' )
WHERE E1_VENCREA BETWEEN '20130901' AND '20130930' AND E1_SALDO > 0 AND E1_NUMBOR<>''
AND E1_PORTADO <> '' AND SE1.D_E_L_E_T_=' ' AND SEA.D_E_L_E_T_=' '
AND EA_CART    = 'R' AND EA_PORTADO NOT IN ('CX1')
AND E1_FILIAL  = EA_FILIAL  AND E1_NUMBOR  = EA_NUMBOR    AND E1_PREFIXO = EA_PREFIXO AND E1_NUM     = EA_NUM
AND E1_PARCELA = EA_PARCELA AND E1_TIPO    = EA_TIPO
GROUP BY A6_NREDUZ, EA_PORTADO, EA_AGEDEP, EA_NUMCON, E1_VENCREA

--CREATE NONCLUSTERED INDEX SE2030_LIXO01
--ON [dbo].[SE2030] ([E2_VENCREA],[E2_NUMBOR],[D_E_L_E_T_],[E2_TIPO],[E2_SALDO])

--CREATE NONCLUSTERED INDEX SE1030_LIXO01
--ON [dbo].[SE1030] ([E1_VENCREA],[E1_NUMBOR],[D_E_L_E_T_],[E1_TIPO],[E1_SALDO])

1.01
SELECT *,
SEM_BORDERO = ( SELECT CONVERT(MONEY,ISNULL(SUM(E2_SALDO),0))
FROM SE2030 SE2
WHERE E2_VENCREA = VENCTO AND SE2.D_E_L_E_T_=' ' AND E2_TIPO NOT IN ('PA','PR','NDF','NCF')
AND E2_SALDO > 0 AND E2_NUMBOR='' AND E2_TIPO NOT LIKE '%-%')
FROM (
SELECT A6_NREDUZ, EA_PORTADO, EA_AGEDEP, EA_NUMCON, E2_VENCREA AS 'VENCTO' , CONVERT(MONEY,ISNULL(SUM(E2_SALDO),0)) AS 'BORDERO', 'D' AS 'TIPO'
FROM SE2030 SE2, SEA030 SEA
RIGHT JOIN SA6030 SA6 ON ( A6_COD = EA_PORTADO AND A6_AGENCIA = EA_AGEDEP AND A6_NUMCON = EA_NUMCON AND SA6.D_E_L_E_T_=' ' )
WHERE E2_VENCREA BETWEEN '20130901' AND '20130930' AND E2_SALDO > 0 AND E2_NUMBOR<>''
AND E2_TIPO NOT IN ('PA','PR','NDF')  AND E2_TIPO NOT LIKE '%-%'
AND E2_PORTADO <> '' AND SE2.D_E_L_E_T_=' '
AND EA_CART    = 'P' AND EA_PORTADO NOT IN ('CX1')
AND E2_FILIAL  = EA_FILIAL  AND E2_NUMBOR  = EA_NUMBOR  AND E2_PREFIXO = EA_PREFIXO AND E2_NUM     = EA_NUM
AND E2_PARCELA = EA_PARCELA AND E2_TIPO    = EA_TIPO    AND E2_FORNECE = EA_FORNECE AND E2_LOJA    = EA_LOJA
GROUP BY A6_NREDUZ, EA_PORTADO, EA_AGEDEP, EA_NUMCON, E2_VENCREA
) TEMP1
ORDER BY VENCTO, EA_PORTADO, EA_AGEDEP, EA_NUMCON



SELECT *,
SEM_BORDERO = ( SELECT CONVERT(MONEY,ISNULL(SUM(E1_SALDO),0))
FROM SE1030 SE1
WHERE E1_VENCREA = VENCTO AND SE1.D_E_L_E_T_=' ' AND E1_TIPO NOT IN ('RA','PR','NDC','NCC')
AND E1_SALDO > 0 AND E1_NUMBOR='' AND E1_TIPO NOT LIKE '%-%')
FROM (
SELECT A6_NREDUZ, EA_PORTADO, EA_AGEDEP, EA_NUMCON, E1_VENCREA AS 'VENCTO', CONVERT(MONEY,ISNULL(SUM(E1_SALDO),0)) AS 'A_RECEBER', 'C' AS 'TIPO'
FROM SE1030 SE1, SEA030 SEA
RIGHT JOIN SA6030 SA6 ON ( A6_COD = EA_PORTADO AND A6_AGENCIA = EA_AGEDEP AND A6_NUMCON = EA_NUMCON AND SA6.D_E_L_E_T_=' ' )
WHERE E1_VENCREA BETWEEN '20130901' AND '20130930' AND E1_SALDO > 0 AND E1_NUMBOR<>''
AND E1_PORTADO <> '' AND SE1.D_E_L_E_T_=' ' AND SEA.D_E_L_E_T_=' '
AND E1_TIPO NOT IN ('RA','PR','NDC','NCC')  AND E1_TIPO NOT LIKE '%-%'
AND EA_CART    = 'R' AND EA_PORTADO NOT IN ('CX1')
AND E1_FILIAL  = EA_FILIAL  AND E1_NUMBOR  = EA_NUMBOR    AND E1_PREFIXO = EA_PREFIXO AND E1_NUM     = EA_NUM
AND E1_PARCELA = EA_PARCELA AND E1_TIPO    = EA_TIPO
GROUP BY A6_NREDUZ, EA_PORTADO, EA_AGEDEP, EA_NUMCON, E1_VENCREA
) TEMP1
ORDER BY VENCTO, EA_PORTADO, EA_AGEDEP, EA_NUMCON


2.0
SELECT *, ZA9_SALDO = ( SELECT CONVERT(MONEY,ISNULL(SUM(ZA9_VALOR),0)) FROM ZA9030 ZA9
WHERE EA_PORTADO = ZA9_BANCO  AND EA_AGEDEP = ZA9_AGENCI AND EA_NUMCON = ZA9_NUMCON AND '20130926' = ZA9_DATA AND ZA9.D_E_L_E_T_=' ' )
FROM
(
-- PAGAR
SELECT *
FROM (
SELECT A6_NREDUZ, EA_PORTADO, EA_AGEDEP, EA_NUMCON, E2_VENCREA AS 'VENCTO' , CONVERT(MONEY,ISNULL(SUM(E2_SALDO),0)) AS 'BORDERO', 'D' AS 'TIPO'
FROM SE2030 SE2, SEA030 SEA
RIGHT JOIN SA6030 SA6 ON ( A6_COD = EA_PORTADO AND A6_AGENCIA = EA_AGEDEP AND A6_NUMCON = EA_NUMCON AND SA6.D_E_L_E_T_=' ' )
WHERE E2_VENCREA BETWEEN '20130917' AND '20130930' AND E2_SALDO > 0 AND E2_NUMBOR<>''
AND E2_TIPO NOT IN ('PA','PR','NDF')  AND E2_TIPO NOT LIKE '%-%'
AND E2_PORTADO <> '' AND SE2.D_E_L_E_T_=' '
AND EA_CART    = 'P' AND EA_PORTADO NOT IN ('CX1')
AND E2_FILIAL  = EA_FILIAL  AND E2_NUMBOR  = EA_NUMBOR  AND E2_PREFIXO = EA_PREFIXO AND E2_NUM     = EA_NUM
AND E2_PARCELA = EA_PARCELA AND E2_TIPO    = EA_TIPO    AND E2_FORNECE = EA_FORNECE AND E2_LOJA    = EA_LOJA
GROUP BY A6_NREDUZ, EA_PORTADO, EA_AGEDEP, EA_NUMCON, E2_VENCREA
UNION ALL
SELECT 'Sem_Bordero' AS A6_NREDUZ, 'zzz' AS EA_PORTADO, 'zzzzz' AS EA_AGEDEP, 'zzzzzzzzzz' AS EA_NUMCON, E2_VENCREA AS 'VENCTO', CONVERT(MONEY,ISNULL(SUM(E2_SALDO),0)) AS 'SEM_BORDERO', 'D' AS 'TIPO'
FROM SE2030 SE2 WHERE SE2.D_E_L_E_T_=' ' AND E2_TIPO NOT IN ('PA','PR','NDF','NCF') AND E2_SALDO > 0 AND E2_NUMBOR='' AND E2_TIPO NOT LIKE '%-%'
AND E2_VENCREA BETWEEN '20130917' AND '20130930'
GROUP BY E2_VENCREA
) TEMP1

UNION ALL
-- RECEBER
SELECT *
FROM (
SELECT A6_NREDUZ, EA_PORTADO, EA_AGEDEP, EA_NUMCON, E1_VENCREA AS 'VENCTO', CONVERT(MONEY,ISNULL(SUM(E1_SALDO),0)) AS 'A_RECEBER', 'C' AS 'TIPO'
FROM SE1030 SE1, SEA030 SEA
RIGHT JOIN SA6030 SA6 ON ( A6_COD = EA_PORTADO AND A6_AGENCIA = EA_AGEDEP AND A6_NUMCON = EA_NUMCON AND SA6.D_E_L_E_T_=' ' )
WHERE E1_VENCREA BETWEEN '20130917' AND '20130930' AND E1_SALDO > 0 AND E1_NUMBOR<>''
AND E1_PORTADO <> '' AND SE1.D_E_L_E_T_=' ' AND SEA.D_E_L_E_T_=' '
AND E1_TIPO NOT IN ('PR','NDC','NCC')  AND E1_TIPO NOT LIKE '%-%'
AND EA_CART    = 'R' AND EA_PORTADO NOT IN ('CX1')
AND E1_FILIAL  = EA_FILIAL  AND E1_NUMBOR  = EA_NUMBOR    AND E1_PREFIXO = EA_PREFIXO AND E1_NUM     = EA_NUM
AND E1_PARCELA = EA_PARCELA AND E1_TIPO    = EA_TIPO
GROUP BY A6_NREDUZ, EA_PORTADO, EA_AGEDEP, EA_NUMCON, E1_VENCREA
UNION ALL
SELECT 'Sem_Bordero' AS A6_NREDUZ, 'zzz' AS EA_PORTADO, 'zzzzz' AS EA_AGEDEP, 'zzzzzzzzzz' AS EA_NUMCON, E1_VENCREA AS 'VENCTO', CONVERT(MONEY,ISNULL(SUM(E1_SALDO),0)) AS 'SEM_BORDERO', 'C' AS 'TIPO'
FROM SE1030 SE1 WHERE SE1.D_E_L_E_T_=' ' AND E1_TIPO NOT IN ('RA','PR','NDC','NCC') AND E1_SALDO > 0 AND E1_NUMBOR='' AND E1_TIPO NOT LIKE '%-%'
AND E1_VENCREA BETWEEN '20130917' AND '20130930'
GROUP BY E1_VENCREA
) TEMP1
) TEMP2
ORDER BY EA_PORTADO, EA_AGEDEP, EA_NUMCON, VENCTO, TIPO

/*/

Return

//+-----------------------------------------------+
//|Funçao : CADZA9                                |
//|Autor  : Diógenes Dauster                      |
//|Modulo : Financeiro                            |
// |Data   : 30/09/2013                            |
//|Uso    : Vizualisação dos extratos importados  |
//+-----------------------------------------------+
USER FUNCTION CADZA9()

LOCAL cAlias := "ZA9"
PRIVATE cCadastro := "Extratos Importados"
PRIVATE aRotina   := { }

AADD(aRotina, { "Pesquisar"  , "AxPesqui"  , 0, 1 })
AADD(aRotina, { "Vizualisar" , "AxVisual"  , 0, 2 })


dbSelectArea(cAlias)
dbSetOrder(1)
mBrowse(6, 1, 22, 75, cAlias)

Return Nil

/*
BANRISUL.REM
BANRISUL.RET
BBRASIL.2RE
BBRASIL.2RR
BBRASIL2.2RE
BB_IPOJ.2RR
BRADCOB.REM
BRADESCO.RET
CEF.2RE
CEF.2RR
HSBC.2RE
HSBC.2RR
ITAU.REM
ITAU.RET
SANT.2RR
SANTAND.REM
*/
/*
SELECT *, ZA9_SALDO = ( SELECT CONVERT(MONEY,ISNULL(SUM(ZA9_VALOR),0)) FROM ZA9030 ZA9
WHERE EA_PORTADO = ZA9_BANCO  AND EA_AGEDEP = ZA9_AGENCI AND EA_NUMCON = ZA9_NUMCON AND '20140218' = ZA9_DATA AND ZA9.D_E_L_E_T_=' ' )
FROM
(
-- PAGAR
SELECT *
FROM (
SELECT A6_NREDUZ, EA_PORTADO, EA_AGEDEP, EA_NUMCON, E2_VENCREA AS 'VENCTO' , CONVERT(MONEY,ISNULL(SUM(E2_SALDO),0)) AS 'BORDERO', 'D' AS 'TIPO'
FROM SE2030 SE2, SEA030 SEA
RIGHT JOIN SA6030 SA6 ON ( A6_COD = EA_PORTADO AND A6_AGENCIA = EA_AGEDEP AND A6_NUMCON = EA_NUMCON AND SA6.D_E_L_E_T_=' ' )
WHERE E2_VENCREA BETWEEN '20140218' AND '20140320' AND E2_SALDO > 0 AND E2_NUMBOR<>''
AND E2_TIPO NOT IN ('PA','PR','NDF')  AND E2_TIPO NOT LIKE '%-%'
AND E2_PORTADO <> '' AND SE2.D_E_L_E_T_=' '
AND EA_CART    = 'P' AND EA_PORTADO NOT IN ('CX1')
AND E2_FILIAL  = EA_FILIAL  AND E2_NUMBOR  = EA_NUMBOR  AND E2_PREFIXO = EA_PREFIXO AND E2_NUM     = EA_NUM
AND E2_PARCELA = EA_PARCELA AND E2_TIPO    = EA_TIPO    AND E2_FORNECE = EA_FORNECE AND E2_LOJA    = EA_LOJA
GROUP BY A6_NREDUZ, EA_PORTADO, EA_AGEDEP, EA_NUMCON, E2_VENCREA
UNION ALL
SELECT 'Sem_Bordero' AS A6_NREDUZ, 'zzz' AS EA_PORTADO, 'zzzzz' AS EA_AGEDEP, 'zzzzzzzzzz' AS EA_NUMCON, E2_VENCREA AS 'VENCTO', CONVERT(MONEY,ISNULL(SUM(E2_SALDO),0)) AS 'SEM_BORDERO', 'D' AS 'TIPO'
FROM SE2030 SE2 WHERE SE2.D_E_L_E_T_=' ' AND E2_TIPO NOT IN ('PR','NDF','NCF') AND E2_SALDO > 0 AND E2_NUMBOR='' AND E2_TIPO NOT LIKE '%-%'
AND E2_VENCREA BETWEEN '20140218' AND '20140320'
GROUP BY E2_VENCREA
) TEMP1

UNION ALL
-- RECEBER
SELECT *
FROM (
SELECT A6_NREDUZ, EA_PORTADO, EA_AGEDEP, EA_NUMCON, E1_VENCREA AS 'VENCTO', CONVERT(MONEY,ISNULL(SUM(E1_SALDO),0)) AS 'A_RECEBER', 'C' AS 'TIPO'
FROM SE1030 SE1, SEA030 SEA
RIGHT JOIN SA6030 SA6 ON ( A6_COD = EA_PORTADO AND A6_AGENCIA = EA_AGEDEP AND A6_NUMCON = EA_NUMCON AND SA6.D_E_L_E_T_=' ' )
WHERE E1_VENCREA BETWEEN '20140218' AND '20140320' AND E1_SALDO > 0 AND E1_NUMBOR<>''
AND E1_PORTADO <> '' AND SE1.D_E_L_E_T_=' ' AND SEA.D_E_L_E_T_=' '
AND E1_TIPO NOT IN ('PR','NDC','NCC')  AND E1_TIPO NOT LIKE '%-%'
AND EA_CART    = 'R' AND EA_PORTADO NOT IN ('CX1')
AND E1_FILIAL  = EA_FILIAL  AND E1_NUMBOR  = EA_NUMBOR    AND E1_PREFIXO = EA_PREFIXO AND E1_NUM     = EA_NUM
AND E1_PARCELA = EA_PARCELA AND E1_TIPO    = EA_TIPO
GROUP BY A6_NREDUZ, EA_PORTADO, EA_AGEDEP, EA_NUMCON, E1_VENCREA
UNION ALL
SELECT 'Sem_Bordero' AS A6_NREDUZ, 'zzz' AS EA_PORTADO, 'zzzzz' AS EA_AGEDEP, 'zzzzzzzzzz' AS EA_NUMCON, E1_VENCREA AS 'VENCTO', CONVERT(MONEY,ISNULL(SUM(E1_SALDO),0)) AS 'SEM_BORDERO', 'C' AS 'TIPO'
FROM SE1030 SE1 WHERE SE1.D_E_L_E_T_=' ' AND E1_TIPO NOT IN ('RA','PR','NDC','NCC') AND E1_SALDO > 0 AND E1_NUMBOR='' AND E1_TIPO NOT LIKE '%-%' AND E1_SITUACA='0'
AND E1_VENCREA BETWEEN '20140218' AND '20140320'
GROUP BY E1_VENCREA
) TEMP1
) TEMP2
ORDER BY EA_PORTADO, EA_AGEDEP, EA_NUMCON, VENCTO, TIPO


--SELECT * FROM ZA9030 ORDER BY R_E_C_N_O_ DESC


SELECT * FROM (
SELECT ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, ZA9_SEQ, ZA9_TPDC, SUM(ZA9_VALOR) AS 'ZA9_SALDO'
FROM ZA9030 ZA9
WHERE ZA9.D_E_L_E_T_=' ' AND LEFT(ZA9_DATA,4)='2014' AND ZA9_TIPO = '5'  AND ZA9_BANCO='341' AND ZA9_SEQ = '0002'
GROUP BY ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, ZA9_SEQ, ZA9_TPDC
UNION ALL
SELECT ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, ZA9_SEQ, ZA9_TPDC, SUM(ZA9_VALOR) AS 'ZA9_SALDO'
FROM ZA9030 ZA9
WHERE ZA9.D_E_L_E_T_=' ' AND LEFT(ZA9_DATA,4)='2014' AND ZA9_TIPO = '5' AND ZA9_BANCO<>'341' AND ZA9_SEQ = '0001'
GROUP BY ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA, ZA9_SEQ, ZA9_TPDC
) TEMP1
ORDER BY ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON, ZA9_DATA
*/

/*
SELECT * FROM SE5030 SE5
WHERE E5_NATUREZ = '5041'
AND E5_ORIGEM = 'PB680FIN' AND E5_BENEF LIKE '%COB LIQBLQ%'
AND EXISTS ( SELECT * FROM SE5030 XE5 WHERE XE5.E5_DATA = SE5.E5_DATA AND XE5.E5_VALOR = SE5.E5_VALOR AND XE5.E5_NATUREZ <> '5041' )


UPDATE SE5
SET D_E_L_E_T_ = '*'
FROM SE5030 SE5
WHERE E5_NATUREZ = '5041'
AND E5_ORIGEM = 'PB680FIN' AND E5_BENEF LIKE '%COB LIQBLQ%'
AND EXISTS ( SELECT * FROM SE5030 XE5 WHERE XE5.E5_DATA = SE5.E5_DATA AND XE5.E5_VALOR = SE5.E5_VALOR AND XE5.E5_NATUREZ <> '5041' )
*/


User Function PBMovDia(aCodigos)

Local aStru1 := {}
Local aDias  := {}
Local dDia
Local nn, nx, cMes

Set Date British
SET(4,"DD/MM/YY")

If Select("SX2") == 0
	If aCodigos == Nil
		aCodigos := {"01","010101"}
	Endif
	RpcClearEnv()
	RpcSetType( 3 )
	RpcSetEnv( aCodigos[01], aCodigos[02],,, "FIN", "PBMOVDIA" )

	SetModulo( "SIGAFIN", "FIN" )
	SetFunName("PBMovDia")
	__cLogSiga := "NNNNNNNNNN"
	//__cinternet := ""
Endif

dDia   := Date()-2 // NAO HA EXTRATO DO DIA //STOD('20140326')

If     Dow(Date()) == 2 // Segunda
	dDia := Date()-5
EndIf

For nn:=1 to 15
	aAdd(aDias, { Strzero(nn,2), DTOS(dDia+nn), 0 } )
Next nn

aAdd(aStru1,{"BANCO"      ,"C",03,0} )
aAdd(aStru1,{"AGENCIA"    ,"C",05,0} )
aAdd(aStru1,{"CONTA"      ,"C",10,0} )
aAdd(aStru1,{"DESCRIC"    ,"C",40,0} )

For nn:=1 To Len(aDias)
	cMes := "SLD_" + aDias[nn][1]
	aAdd(aStru1,{cMes ,"N",12,2} )
	
	cMes := "IDC_" + aDias[nn][1]
	aAdd(aStru1,{cMes ,"C",01,0} )
	
	cMes := "BOR_" + aDias[nn][1]
	aAdd(aStru1,{cMes ,"N",12,2} )
	
	cMes := "OUT_" + aDias[nn][1]
	aAdd(aStru1,{cMes ,"N",12,2} )
	
	cMes := "INC_" + aDias[nn][1]
	aAdd(aStru1,{cMes ,"N",12,2} )
	
	cMes := "SER_" + aDias[nn][1]
	aAdd(aStru1,{cMes ,"N",12,2} )
	
	cMes := "ATU_" + aDias[nn][1]
	aAdd(aStru1,{cMes ,"N",12,2} )
	
	cMes := "ADC_" + aDias[nn][1]
	aAdd(aStru1,{cMes ,"C",01,0} )
Next nn
aAdd(aStru1,{"SLD_99"     ,"N",12,2} )

//cArqTrab := UPPER(CriaTrab(aStru1,.T.))
//dbUseArea(.T.,__LocalDriver,cArqTrab,"TRB",.F.,.F.) // modo exclusivo
//cInd := StrTran(cArqTrab,".DBF","")
//IndRegua("TRB",cInd,"BANCO+AGENCIA+CONTA",,,"Selecionando Registros...")

//P3 Tecnologia - Code Analisys 20/06/2020
oTRB := FWTemporaryTable():New("TRB",aStru1)
oTRB:AddIndex("01", {"BANCO","AGENCIA","CONTA"} )
oTRB:Create()

RecLock( "TRB", .T. )
TRB->BANCO     := 'xxx'
TRB->AGENCIA   := 'xxxxx'
TRB->CONTA     := 'xxxxxxxxxx'
TRB->DESCRIC   := 'SEM BORDERO (A CLASSIFICAR)'

For nn:=1 To Len(aDias)
	cQuery := "SELECT CONVERT(MONEY,ISNULL(SUM(E2_SALDO),0)) AS 'OUTROS' FROM "+RetSqlName("SE2")+" SE2 "
	cQuery += "WHERE E2_VENCREA = '"+aDias[nn][2]+"' AND D_E_L_E_T_=' ' AND E2_TIPO NOT IN ('NDF','NCF') AND E2_SALDO > 0 AND E2_NUMBOR='' "
	dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRB1",.F.,.T.)
	TCSetField("TRB1", "OUTROS"  , "N", 17, 2 )
	cCampo  := "TRB->OUT_" + aDias[nn][1]
	&cCampo := TRB1->OUTROS
	TRB1->(DbCloseArea())
Next nn
// RECEBIMENTOS EM INCORPORACAO
For nn:=1 To Len(aDias)
	cQuery := "SELECT CONVERT(MONEY,ISNULL(SUM(E1_SALDO),0)) AS 'INCORP' FROM "+RetSqlName("SE1")+" SE1 "
	cQuery += "WHERE E1_VENCREA = '"+aDias[nn][2]+"' AND SE1.D_E_L_E_T_=' ' AND E1_TIPO NOT IN ('PR','NCC') AND E1_SALDO > 0 "
	cQuery += "AND E1_TIPO IN ('NP','REF') "
	dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRB1",.F.,.T.)
	TCSetField("TRB1", 'INCORP'  , "N", 17, 2 )
	cCampo  := "TRB->INC_" + aDias[nn][1]
	&cCampo := TRB1->INCORP
	TRB1->(DbCloseArea())
Next nn
// RECEBIMENTOS DE SERVICOS
For nn:=1 To Len(aDias)
	cQuery := "SELECT CONVERT(MONEY,ISNULL(SUM(E1_SALDO),0)) AS 'SERVICE' FROM "+RetSqlName("SE1")+" SE1 "
	cQuery += "WHERE E1_VENCREA = '"+aDias[nn][2]+"' AND SE1.D_E_L_E_T_=' ' AND E1_TIPO NOT IN ('PR','NCC') AND E1_SALDO > 0 "
	cQuery += "AND E1_TIPO = 'NF' "
	dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRB1",.F.,.T.)
	TCSetField("TRB1", 'SERVICE'  , "N", 17, 2 )
	cCampo  := "TRB->SER_" + aDias[nn][1]
	&cCampo := TRB1->SERVICE
	TRB1->(DbCloseArea())
Next nn
TRB->( MsUnlock() )

SA6->(DbCloseArea())

cQuery := "SELECT * FROM "+RetSqlName("SA6")+" SA6 " // REMOVER DEPOIS TOP 10
cQuery += "WHERE D_E_L_E_T_=' ' AND  A6_BLOCKED <> '1' "// AND A6_COD IN ('341') " // '104','033',
cQuery += "ORDER BY A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON "
dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "SA6",.F.,.T.)

SA6->( DbGoTop() )
Do While ! SA6->( Eof() )
	
	If SA6->A6_BLOCKED == '1' .Or. Left(SA6->A6_COD,2) $ "CX,CL"
		SA6->( DbSkip() )
		Loop
	Endif
	
	RecLock( "TRB", .T. )
	TRB->BANCO     := SA6->A6_COD
	TRB->AGENCIA   := SA6->A6_AGENCIA
	TRB->CONTA     := SA6->A6_NUMCON
	TRB->DESCRIC   := SA6->A6_NOME
	
	// SALDOS BANCARIOS
	For nn:=1 To Len(aDias)
		cQuery := "SELECT ZA9_TIPO, CONVERT(MONEY,ISNULL(SUM(ZA9_VALOR),0)) AS SALDO, ZA9_TPDC FROM "+RetSqlName("ZA9")+" ZA9 "
		cQuery += "WHERE ZA9_DATA = '"+aDias[nn][2]+"' AND ZA9_BANCO = '"+SA6->A6_COD+"' AND ZA9_AGENCI = '"+SA6->A6_AGENCIA+"' "
		cQuery += "AND ZA9_NUMCON = '"+Alltrim(SA6->A6_NUMCON)+"' AND ZA9.D_E_L_E_T_=' ' AND ZA9_TIPO IN ('1','5') "
		cQuery += "GROUP BY ZA9_TPDC, ZA9_TIPO "
		cQuery += "ORDER BY ZA9_TIPO "
		dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRB1",.F.,.T.)
		TCSetField("TRB1", "SALDO"  , "N", 17, 2 )
		// sempre virá 2 registros da query acima, pois a importacao do extrato tem sempre saldo inicial e final
		cCampo  := "TRB->SLD_" + aDias[nn][1]
		&cCampo := TRB1->SALDO
		cCampo  := "TRB->IDC_" + aDias[nn][1]
		&cCampo := IIF(Empty(TRB1->ZA9_TPDC),'',TRB1->ZA9_TPDC)
		
		TRB1->(DbSkip())
		
		//cCampo  := "TRB->ATU_" + aDias[nn][1]
		//&cCampo := TRB1->SALDO
		//cCampo  := "TRB->ADC_" + aDias[nn][1]
		//&cCampo := IIF(Empty(TRB1->ZA9_TPDC),'',TRB1->ZA9_TPDC)
		
		TRB1->(DbCloseArea())
	Next nn
	
	// PAGAMENTOS EM BORDERO
	For nn:=1 To Len(aDias)
		cQuery := "SELECT CONVERT(MONEY,ISNULL(SUM(E2_SALDO),0)) AS 'BORDERO' FROM "+RetSqlName("SE2")+" SE2, "+RetSqlName("SEA")+" SEA "
		cQuery += "WHERE E2_VENCREA = '"+aDias[nn][2]+"' AND SE2.D_E_L_E_T_=' ' AND E2_TIPO NOT IN ('PR','NDF','NCF') AND E2_SALDO > 0 AND E2_NUMBOR<>'' "
		cQuery += "AND E2_PORTADO<>'' AND SEA.EA_CART = 'P' "
		cQuery += "AND EA_PORTADO = '"+SA6->A6_COD+"' AND EA_AGEDEP = '"+SA6->A6_AGENCIA+"' AND EA_NUMCON = '"+SA6->A6_NUMCON+"' AND SEA.D_E_L_E_T_=' ' "
		cQuery += "AND E2_FILIAL  = EA_FILIAL  AND E2_NUMBOR  = EA_NUMBOR  AND E2_PREFIXO = EA_PREFIXO AND E2_NUM  = EA_NUM "
		cQuery += "AND E2_PARCELA = EA_PARCELA AND E2_TIPO    = EA_TIPO    AND E2_FORNECE = EA_FORNECE AND E2_LOJA = EA_LOJA "
		dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRB1",.F.,.T.)
		TCSetField("TRB1", "BORDERO"  , "N", 17, 2 )
		cCampo  := "TRB->BOR_" + aDias[nn][1]
		&cCampo := TRB1->BORDERO
		TRB1->(DbCloseArea())
	Next nn
	/*
	// RECEBIMENTOS EM INCORPORACAO
	For nn:=1 To Len(aDias)
	cQuery := "SELECT CONVERT(MONEY,ISNULL(SUM(E1_SALDO),0)) AS 'BORDERO' FROM "+RetSqlName("SZB")+" SZB, "+RetSqlName("SE1")+" SE1, "+RetSqlName("SEA")+" SEA "
	cQuery += "WHERE E1_VENCREA = '"+aDias[nn][2]+"' AND SE1.D_E_L_E_T_=' ' AND E1_TIPO NOT IN ('PR','RA','NCC') AND E1_SALDO > 0 AND E1_NUMBOR <> '' "
	cQuery += "AND E1_PORTADO <> ' ' AND SEA.EA_CART = 'R' "
	cQuery += "AND EA_PORTADO = '"+SA6->A6_COD+"' AND EA_AGEDEP = '"+SA6->A6_AGENCIA+"' AND EA_NUMCON = '"+SA6->A6_NUMCON+"' AND SEA.D_E_L_E_T_=' ' "
	cQuery += "AND E2_FILIAL  = EA_FILIAL  AND E2_NUMBOR  = EA_NUMBOR  AND E2_PREFIXO = EA_PREFIXO AND E2_NUM  = EA_NUM "
	cQuery += "AND E2_PARCELA = EA_PARCELA AND E2_TIPO    = EA_TIPO "
	cQuery += "AND ZB_NUM     = E1_NUM     AND ZB_SEQ     = E1_PARCELA  AND ZB_CLIENTE = E1_CLIENTE AND ZB_LOJA = E1_LOJA AND SZB.D_E_L_E_T_=' ' "
	dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRB1",.F.,.T.)
	TCSetField("TRB1", "BORDERO"  , "N", 17, 2 )
	cCampo  := "TRB->BOR_" + aDias[nn][1]
	&cCampo := TRB1->BORDERO
	TRB1->(DbCloseArea())
	Next nn
	*/
	TRB->( MsUnlock() )
	
	SA6->( DbSkip() )
	
Enddo
SA6->(DbCloseArea())
ChkFile("SA6")

//cPatchTemp := Upper(AllTrim(GetTempPath()))

TRB->( DbGoTop() )
Do While ! TRB->( Eof() )
	nVlr := 0
	For nn:=1 To Len(aDias)
		cCampo  := "TRB->SLD_" + aDias[nn][1]
		nVlr    += &cCampo
		cCampo  := "TRB->BOR_" + aDias[nn][1]
		nVlr    += &cCampo
		cCampo  := "TRB->OUT_" + aDias[nn][1]
		nVlr    += &cCampo
		cCampo  := "TRB->INC_" + aDias[nn][1]
		nVlr    += &cCampo
		cCampo  := "TRB->SER_" + aDias[nn][1]
		nVlr    += &cCampo
	Next nn
	If .F. // nVlr == 0
		Reclock( "TRB", .F. )
		TRB->( dbDelete() )
		TRB->( MsUnlock() )
	Endif
	TRB->( DbSkip() )
Enddo
cCampo := ""

//cArqTrab := UPPER(CriaTrab(aStru1,.T.))
//dbUseArea(.T.,__LocalDriver,cArqTrab,"TOTAL",.F.,.F.) // modo exclusivo
//cInd := StrTran(cArqTrab,".DBF","")
//IndRegua("TOTAL",cInd,"BANCO",,,"Selecionando Registros...")

//P3 Tecnologia - Code Analisys 20/06/2020
oTOTAL := FWTemporaryTable():New("TOTAL",aStru1)
oTOTAL:AddIndex("01", {"BANCO"} )
oTOTAL:Create()

TRB->( DbGoTop() )
cBanco := TRB->BANCO

Do While ! TRB->( Eof() ) .And. cBanco == TRB->BANCO
	If TRB->BANCO $ 'xxx'
		TRB->( DbSkip() )
		Loop
	Endif
	If ! TOTAL->( DbSeek(cBanco) )
		Reclock( "TOTAL", .T. )
	Else
		Reclock( "TOTAL", .F. )
	Endif
	TOTAL->BANCO   := cBanco
	TOTAL->AGENCIA := 'zzzzz'
	TOTAL->CONTA   := 'zzzzzzzzzz'
	TOTAL->DESCRIC := 'SUB-TOTAL EM ' + DTOC(dDia)
	
	For nn:=1 To Len(aDias)
		
		cCampoS  :=   "TRB->SLD_" + aDias[nn][1]
		cCampoT  := "TOTAL->SLD_" + aDias[nn][1]
		cCampo   :=   "TRB->IDC_" + aDias[nn][1]
		If &cCampo == 'D'
			&cCampoT -= &cCampoS
		Else
			&cCampoT += &cCampoS
		Endif
		
		cCampoS  :=   "TRB->BOR_" + aDias[nn][1]
		cCampoT  := "TOTAL->BOR_" + aDias[nn][1]
		&cCampoT += &cCampoS
		
		cCampoS  :=   "TRB->OUT_" + aDias[nn][1]
		cCampoT  := "TOTAL->OUT_" + aDias[nn][1]
		&cCampoT += &cCampoS
		
		cCampoS  :=   "TRB->INC_" + aDias[nn][1]
		cCampoT  := "TOTAL->INC_" + aDias[nn][1]
		&cCampoT += &cCampoS
		
		cCampoS  :=   "TRB->SER_" + aDias[nn][1]
		cCampoT  := "TOTAL->SER_" + aDias[nn][1]
		&cCampoT += &cCampoS
		
		cCampoS  :=   "TRB->ATU_" + aDias[nn][1]
		cCampoT  := "TOTAL->ATU_" + aDias[nn][1]
		cCampo   :=   "TRB->ADC_" + aDias[nn][1]
		If &cCampo == 'D'
			&cCampoT -= &cCampoS
		Else
			&cCampoT += &cCampoS
		Endif
		
	Next nn
	
	TOTAL->( MsUnlock() )
	
	TRB->( DbSkip() )
	
	If cBanco <> TRB->BANCO
		cBanco := TRB->BANCO
	Endif
	
Enddo



TRB->( DbGoTop() )

Reclock( "TOTAL", .T. )
TOTAL->BANCO   := 'zzz'
TOTAL->AGENCIA := 'zzzzz'
TOTAL->CONTA   := 'zzzzzzzzzz'
TOTAL->DESCRIC := 'TOTAL GERAL EM ' + DTOC(dDia)
Do While ! TRB->( Eof() )
	If TRB->AGENCIA $ 'zzzzz'
		TRB->( DbSkip() )
		Loop
	Endif
	For nn:=1 To Len(aDias)
		cCampoS  :=   "TRB->SLD_" + aDias[nn][1]
		cCampoT  := "TOTAL->SLD_" + aDias[nn][1]
		cCampo   :=   "TRB->IDC_" + aDias[nn][1]
		If &cCampo == 'D'
			&cCampoT -= &cCampoS
		Else
			&cCampoT += &cCampoS
		Endif
		cCampoS  :=   "TRB->BOR_" + aDias[nn][1]
		cCampoT  := "TOTAL->BOR_" + aDias[nn][1]
		&cCampoT += &cCampoS
		cCampoS  :=   "TRB->OUT_" + aDias[nn][1]
		cCampoT  := "TOTAL->OUT_" + aDias[nn][1]
		&cCampoT += &cCampoS
		cCampoS  :=   "TRB->INC_" + aDias[nn][1]
		cCampoT  := "TOTAL->INC_" + aDias[nn][1]
		&cCampoT += &cCampoS
		cCampoS  :=   "TRB->SER_" + aDias[nn][1]
		cCampoT  := "TOTAL->SER_" + aDias[nn][1]
		&cCampoT += &cCampoS
		cCampoS  :=   "TRB->ATU_" + aDias[nn][1]
		cCampoT  := "TOTAL->ATU_" + aDias[nn][1]
		cCampo   :=   "TRB->ADC_" + aDias[nn][1]
		If &cCampo == 'D'
			&cCampoT -= &cCampoS
		Else
			&cCampoT += &cCampoS
		Endif
	Next nn
	TRB->( DbSkip() )
Enddo
TOTAL->( MsUnlock() )

DbSelectArea("TOTAL")
//DbCloseArea()
oTotal:Delete()
DbSelectArea("TRB")
__DbPack()
Append From ( cArqTrab + ".dbf" )


TRB->( DbGoTop() )

aDados1  := {}
aDados11 := {}
For nn:=1 To Len(aDias)
	aAdd( aDados11, DTOC(STOD(aDias[nn][2])) )
Next nn
aAdd( aDados1,{ 'Banco + Agencia + Conta','Descricao', aDados11 } )

aDados2   := {}
aDadosDia := {}
For nn:=1 To Len(aDias)
	aAdd( aDadosDia, { 'Sld Anterior', 'DC', 'Borderos', 'Outros', 'Incorporacao', 'Servicos', 'Sld Atual', 'DC' } )
Next nn
aAdd( aDados2,{ 'Banco + Agencia + Conta','Descricao', aDadosDia } )
Do While ! TRB->( Eof() )
	aDadosDia := {}
	For nn:=1 To Len(aDias)
		cCpo1 := "SLD_" + aDias[nn][1]
		cCpo2 := "IDC_" + aDias[nn][1]
		cCpo3 := "BOR_" + aDias[nn][1]
		cCpo4 := "OUT_" + aDias[nn][1]
		cCpo5 := "INC_" + aDias[nn][1]
		cCpo6 := "SER_" + aDias[nn][1]
		cCpo7 := "ATU_" + aDias[nn][1]
		cCpo8 := "ADC_" + aDias[nn][1]
		aAdd( aDadosDia, { &cCpo1, &cCpo2, &cCpo3, &cCpo4, &cCpo5, &cCpo6, &cCpo7, &cCpo8 } )
	Next nn
	aAdd( aDados2,{ Padr(TRB->BANCO + '-' + TRB->AGENCIA + '-' + TRB->CONTA,25), Padr(TRB->DESCRIC,40), aDadosDia } )
	TRB->( DbSkip() )
Enddo

aAdd( aDados1, { aDados2 } )

//TRB->( DbGoTop() )
//Copy To LIXO.DBF
//MakeDir( "C:\TEMP\" )
//__CopyFile('LIXO.DBF','C:\TEMP\LIXO.DBF')

aDados0 := {}
Aadd( aDados0,{ 'Empresa'                               ,'Data de Referencia', 'Periodo'} )
Aadd( aDados0,{  cEmpAnt + " - " + Capital(SM0->M0_NOME),     dtoc(dDataBase), '15 Dias'} )

aDadosMail  := { aDados0,aDados1,aDados2 }

cBody	:= ExecBlock( "MMENSF11",.F.,.F.,aDadosMail )

cFile := cStartPath + "Saldos_Bancarios_"+cEmpAnt+"_"+dtos(date())+'.html'

MemoWrite(cFile,cBody)
//__CopyFile(cFile,'c:\temp\'+cFile)

U_VerEvento('F11','Saldo Bancarios')
cSubject		:= U_GetDescEvento('F11')
aUsers      := U_MyMenviaMail('F11')

//P3 Tecnologia - Code Analisys 17/06/2020
cAccount	:= GetMv("EL_RLCONTA")
cPassword	:= GetMv("EL_RLSENHA")
cServer		:= GetMv("EL_RLSERV")

For nX := 1 To Len(aUsers)
		//P3 Tecnologia - Code Analisys 17/06/2020
		/*
		cAccount	:= GetMv("EL_RLCONTA")
		cPassword	:= GetMv("EL_RLSENHA")
		cServer		:= GetMv("EL_RLSERV")
		*/
		U_ACSENDM(cAccount,cPassword,cServer,"erp@grupoelizabeth.com.br",aUsers[nX,2],cSubject,cBody,cFile)
Next nX



Return

//ProcWaiting( { || Relatorio() } , "Gerando Informe : "+(cAlias)->ZB_NUM , "Aguarde..." , 300 , .F. , .T. )

User Function MMENSF11()
Local cMsg
Local aNewDados := ParamIxb
Local aColunas  := { } // coluna que o valor sera apresentado alinhado a direita
Local aLinhas   := aNewDados[3]
Local aCabe1    := aNewDados[2][1][3]
Local xn := 1
Local nx:=1
Local nn:=1

cMsg := '<html><title></title><body>'
cMsg += '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1>'
cMsg += '  <tr><td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="606"'
cMsg += '    borderColorDark="#0099cc" bgColor="#0099cc" height="1">'
cMsg += '    <p align="center"><FONT face="Courier New" color="#ffffff" size="4">'
cMsg += '    <b>RESUMO FINANCEIRO</b></font></p></td></tr>'
cMsg += '  <tr><td align="left" width="100%" height="32"><p align="left"><b>'

cMsg += U_PBTabelaHTML(aNewDados[1], .T., "100%")

cMsg += "<TABLE BORDER ='1' cellpadding='10' >" + cCrLf
cMsg += "   <TR>" + cCrLf
cMsg += "		<TD COLSPAN ='2' align='center' >&nbsp;</TD>
For xn := 1 to Len(aCabe1)
	cMsg += "			<TD COLSPAN ='8' align='center' ><b>"+aCabe1[xn]+"</b></TD>"
Next xn
cMsg += "   </TR>" + cCrLf

cMsg += "	<TR>" + cCrLf
cMsg += "		<TD COLSPAN ='2' >&nbsp;</TD>
For xn := 1 to Len(aCabe1)
	cMsg += "			<TD align='center' ><b>Saldo</b></TD>
	cMsg += "			<TD>&nbsp;</TD>
	cMsg += "			<TD COLSPAN ='2' align='center' >Pagamentos</TD>
	cMsg += "			<TD COLSPAN ='2' align='center' >Recebimentos</TD>
	cMsg += "			<TD align='center' ><b>Saldo</b></TD>
	cMsg += "			<TD>&nbsp;</TD>
Next xn
cMsg += "	</TR>" + cCrLf

cMsg += "	<TR>" + cCrLf
cMsg += "		<TD>Banco/Agencia/Conta</TD>
cMsg += "		<TD>Descri&ccedil;&atilde;o</TD>
For xn := 1 to Len(aCabe1)
	cMsg += "			<TD align='center' ><b>Anterior</b></TD>
	cMsg += "			<TD align='center' >D/C</TD>
	cMsg += "			<TD align='center' >Bordero</TD>
	cMsg += "			<TD align='center' >Outros</TD>
	cMsg += "			<TD align='center' >Incorpora&ccedil;&atilde;o</TD>
	cMsg += "			<TD align='center' >Servi&ccedil;o</TD>
	cMsg += "			<TD align='center' ><b>Final</b></TD>
	cMsg += "			<TD align='center' >D/C</TD>
Next xn
cMsg += "	</TR>" + cCrLf

cMsg1 := ""
For nn:=1 To Len(aLinhas)
	If nn <> 1
		cMsg1 += "		<TR>" + cCrLf
		aLin1 := aLinhas[nn][3]
		nSaldoI := nSaldoF := 0
		For nx:=1 To Len(aLin1)
			If nx == 1
				cMsg1  += "		<TD>"+aLinhas[nn][1]+"</TD>" // codigo
				cMsg1  += "		<TD>"+aLinhas[nn][2]+"</TD>" // descricao
				nSaldoI := nSaldoF := 0
				nSaldoI := aLin1[nx][1] * iif(aLin1[1][2]=="D",-1,1)
			Endif
			nSaldoF := nSaldoI + aLin1[nx][5] + aLin1[nx][6] + (aLin1[nx][3]*-1) + (aLin1[nx][4]*-1)
			cMsg1 += "			<TD align='Right' ><b>"+Transform(nSaldoI,"@E 99,999,999.99")+"</b></TD>"
			cMsg1 += "			<TD align='center' >"+iif(!Empty(aLin1[nx][2]),aLin1[nx][2],"&nbsp;")+"</TD>
			// pagamentos
			cMsg1 += "			<TD align='Right' >"+Transform(aLin1[nx][3],"@E 99,999,999.99")+"</TD>
			cMsg1 += "			<TD align='Right' >"+Transform(aLin1[nx][4],"@E 99,999,999.99")+"</TD>
			// recebimentos
			cMsg1 += "			<TD align='Right' >"+Transform(aLin1[nx][5],"@E 99,999,999.99")+"</TD>
			cMsg1 += "			<TD align='Right' >"+Transform(aLin1[nx][6],"@E 99,999,999.99")+"</TD>
			
			cMsg1 += "			<TD align='Right' ><b>"+Transform(nSaldoF,"@E 99,999,999.99")+"</b></TD>
			cMsg1 += "			<TD align='center' >"+iif(!Empty(aLin1[nx][8]),aLin1[nx][8],"&nbsp;")+"</TD>
			nSaldoI := nSaldoF
		Next nn
		cMsg1 += "		</TR>" + cCrLf
	Endif
Next xn
cMsg += cMsg1
cMsg += "</TABLE>" + cCrLf

cMsg += '</b></p></td></tr>'
cMsg += '</table><br>'
cMsg += '  <tr><td align="left" width="606" height="32"><p align="left">Empresa.: '+Capital(Alltrim(SM0->M0_NOME))+'</p></td></tr>'
cMsg += ''

Return(cMsg)

User Function Job1QGFin(cxEmp,cxFil,cxDe,cxAte)

If cxAte = Nil .or. cxEmp = Nil
	StartJob("U_Job2QGFin",GetEnvServer(),.T., { "03", "01" } )
Else
	StartJob("U_Job2QGFin",GetEnvServer(),.T., { cxEmp, cxFil,cxDe,cxAte } )
Endif

Return

User Function Job2QGFin(aCodigos)
Local cPBTimeI  := Time()
Local cQuery    := ""
Local cDe 		:= ""
Local cAte		:= ""
Local aDados

If aCodigos == Nil
	aCodigos := {"03","01"}
Endif

RpcSetType(3)
RpcSetEnv( aCodigos[01], aCodigos[02],,, "FIN", "JOB2QGFIN" )

SetModulo( "SIGAFIN", "FIN" )
SetFunName("Job2QGFin")
__cLogSiga := "NNNNNNNNNN"

cQuery := "SELECT ZA9.R_E_C_N_O_ AS ZA9RECNO FROM "+RetSqlName("ZA9")+" ZA9 " + cCrLf
cQuery += "WHERE ZA9_TPDC = 'C' AND ZA9_TIPO = '3' " + cCrLf
cQuery += "AND ZA9_OCORRE = '205' AND ZA9_CODHIS IN ('0811','0533') AND ZA9.D_E_L_E_T_ = ' ' " + cCrLf
If Len(aCodigos) = 4
	cQuery += "AND ZA9_DATA BETWEEN  '"+aCodigos[03]+"' AND '"+aCodigos[04]+"' AND  ZA9_NUMCON = '2073' " + cCrLf
Else
	cQuery += "AND ZA9_DATA BETWEEN  '20140701' AND '20140731' AND  ZA9_NUMCON = '2073' " + cCrLf
ENdif
cQuery += "AND NOT EXISTS ( " + cCrLf
cQuery += "                 SELECT E5_FILIAL FROM "+RetSqlName("SE5")+" " + cCrLf
cQuery += "                 WHERE ZA9_VALOR = E5_VALOR AND E5_BANCO = ZA9_BANCO AND E5_AGENCIA = ZA9_AGENCI AND E5_CONTA = ZA9_NUMCON " + cCrLf
cQuery += "                 AND E5_DTDISPO = ZA9_DATA " + cCrLf
cQuery += "                 AND E5_NATUREZ IN( '5041','5018') -- DEPOSITOS BLOQUEADOS " + cCrLf
cQuery += "                 AND E5_RECPAG = 'R' AND E5_SITUACA NOT IN ('C','X','E') ) " + cCrLf
cQuery += "ORDER BY ZA9_FILIAL, ZA9_DATA ,ZA9_BANCO, ZA9_AGENCI, ZA9_NUMCON " + cCrLf

MemoWrite( cStartPath + cExtDir + cDirQuery + 'Job2QGFin.SQL',cQuery)
dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery), "TRB1",.F.,.T.)

TRB1->(dbGoTop())
Do While ! TRB1->(EOF())
	ZA9->(dBGoto(TRB1->ZA9RECNO))
	//ZA9_BLOQMOV() // FAZ A INCLUSAO DO MOVIMENTO BANCARIO
	TRB1->( dbSkip() )
Enddo
TRB1->(DbCloseArea())

aDados := {}
Aadd( aDados, { "Empresa     ", cEmpAnt + " - " + SM0->M0_NOMECOM   } )
Aadd( aDados, { "Processo    ", "Importacao dos extratos bancarios" } )
Aadd( aDados, { "Duracao     ", ElapTime( cPBTimeI, Time() )        } )
Aadd( aDados, { "Ambiente    ", Alltrim(Capital(GetEnvServer()))    } )
cBody		:= "" + CHR(13) + CHR(10)
cBody		+= U_PBTabelaHTML(aDados, .f., "100%")
cBody		+= "" + CHR(13) + CHR(10)

//U_SduMandaEmail( "alessandro@farias.net.br", "", "", "QG Conciliacao Automatica BLQ", Nil, cBody, Nil )

Return


Static Function SA6POS(cBco1,cAge1,cCta1)
Local cBco,cAge,cCta
Local xIx:=1

SA6->( Dbsetorder(1) )

cBco := cBco1
cAge := cAge1
cCta := cCta1
If ! SA6->( DbSeek( xFilial("SA6") + cBco + cAge + cCta ) )
	cAge := cAge1
	cCta := Alltrim(cCta1)
	cCta := Padr(Alltrim(Substr(cCta,1,Len(cCta)-1))+"-"+Right(cCta,1),10)
	If ! SA6->( DbSeek( xFilial("SA6") + cBco + cAge + cCta ) )
		cAge := Alltrim(cAge1)
		cAge := Padr(Left(cAge,4),5)
		cCta := Alltrim(cCta1)
		cCta := Padr(Alltrim(Substr(cCta,1,Len(cCta)-1))+"-"+Right(cCta,1),10)
		If ! SA6->( DbSeek( xFilial("SA6") + cBco + cAge + cCta ) )
			cAge := cAge1
			cCta := Alltrim(cCta1)
			cCta := Padr(Alltrim(Substr(cCta,1,Len(cCta)-1)),10)
			If ! SA6->( DbSeek( xFilial("SA6") + cBco + cAge + cCta ) )
				cAge := Alltrim(cAge1)
				cAge := Padr(Left(cAge,4),5)
				cCta := Alltrim(cCta1)
				cCta := Padr(Alltrim(Substr(cCta,1,Len(cCta)-1)),10)
				If ! SA6->( DbSeek( xFilial("SA6") + cBco + cAge + cCta ) )
					cAge := Left(cAge1,4)
					For xIx:=1 To 10
						cVar := Alltrim(iif(xIx==10,'0',Str(xIx)))
						cVar := cAge + cVar
						If SA6->( DbSeek( xFilial("SA6") + cBco + cVar ) )
							cAge := cVar
							Exit
						Endif
					Next xIx
					cCta := cCta1
					If ! SA6->( DbSeek( xFilial("SA6") + cBco + cAge + cCta ) )
						cCta := Alltrim(cCta1)
						cCta := Padr(Alltrim(Substr(cCta,1,Len(cCta)-1))+"-"+Right(cCta,1),10)
						If ! SA6->( DbSeek( xFilial("SA6") + cBco + cAge + cCta ) )
							//Loop
						Endif
					Endif
				Endif
			Endif
		Endif
	Endif
Endif

If SA6->(Eof())
	Return .F.
Endif

Return .T.

Static Function Z0SX5()
Local aSX5   	:= {}
Local aEstrut	:= aEstrut:= { "X5_FILIAL","X5_TABELA","X5_CHAVE","X5_DESCRI","X5_DESCSPA","X5_DESCENG"}
Local cFilX5	:= xFilial("SX5")
Local nX      	:= 0
Local nY      	:= 0

dbSelectArea("SX5")
dbSetOrder(1)

AADD(aSx5,{cFilX5,'00','Z0','TIPOS DE TARIFAS BANCARIAS' 	,'TIPOS DE TARIFAS BANCARIAS'		,'TIPOS DE TARIFAS BANCARIAS'		} )
AADD(aSx5,{cFilX5,'Z0','01','CADASTRO'						   	,'CADASTRO'						 		,'CADASTRO'					  			} )
AADD(aSx5,{cFilX5,'Z0','02','CARTAO MAGNETICO'					,'CARTAO MAGNETICO'				 	,'CARTAO MAGNETICO'			  		} )
AADD(aSx5,{cFilX5,'Z0','03','CHEQUE'            				,'CHEQUE'            			 	,'CHEQUE'            			  	} )
AADD(aSx5,{cFilX5,'Z0','04','CONTA CORRENTE' 					,'CONTA CORRENTE' 				 	,'CONTA CORRENTE' 				  	} )
AADD(aSx5,{cFilX5,'Z0','05','MOVIMENTACAO DE RECURSOS'   	,'MOVIMENTACAO DE RECURSOS'      ,'MOVIMENTACAO DE RECURSOS'      } )
AADD(aSx5,{cFilX5,'Z0','06','EXTRATO DE CONTA'       			,'EXTRATO DE CONTA'       		 	,'EXTRATO DE CONTA'       		  	} )
AADD(aSx5,{cFilX5,'Z0','07','COBRANCA'       					,'COBRANCA'       				 	,'COBRANCA'       				  	} )
AADD(aSx5,{cFilX5,'Z0','08','CREDITOS'       					,'CREDITOS'       				 	,'CREDITOS'       				  	} )
AADD(aSx5,{cFilX5,'Z0','09','CAPITAIS ESTRANGEIROS E CAMBIO','CAPITAIS ESTRANGEIROS E CAMBIO','CAPITAIS ESTRANGEIROS E CAMBIO'} )
AADD(aSx5,{cFilX5,'Z0','10','OUTROS SERVICOS'           		,'OUTROS SERVICOS'           	 	,'OUTROS SERVICOS'           	  	} )

dbSelectArea("SX5")
dbSetOrder(1)
For nX := 1 To Len(aSX5)
	If ! Empty(aSX5[nX][2])
		If ! dbSeek( aSX5[nX,1]+aSX5[nX,2]+aSX5[nX,3])
			RecLock("SX5",.T.)
			For nY := 1 To Len(aSX5[nX])
				If !Empty(FieldName(FieldPos(aEstrut[nY])))
					FieldPut(FieldPos(aEstrut[nY]),aSX5[nX,nY])
				EndIf
			Next nY
			SX5->(MsUnLock())
		Else
			/*/
			RecLock("SX5",.F.)
			For nY := 1 To Len(aSX5[nX])
				If !Empty(FieldName(FieldPos(aEstrut[nY])))
					FieldPut(FieldPos(aEstrut[nY]),aSX5[nX,nY])
				EndIf
			Next nY
			SX5->(MsUnLock())
			/*/
		EndIf
	EndIf
Next nX

Return

Static Function yZA9_TARIFA() // UTILIZANDO ROTINA AUTOMATICA
Local _dDtAtu		:= dDataBase
dDataBase	:= ZA9->ZA9_DATA

aCab := {}
aAdd(	aCab, {"E5_FILIAL" ,xFilial("SE5")	,Nil} )
aAdd(	aCab, {"E5_MOEDA"  ,"M1"				,Nil} )
aAdd(	aCab, {"E5_VALOR"  ,ZA9->ZA9_VALOR	,Nil} )
aAdd(	aCab, {"E5_NATUREZ",Alltrim(&(GetMv("MV_NATDPBC"))) ,Nil} )
aAdd(	aCab, {"E5_DATA"   ,ZA9->ZA9_DATA	,Nil} )
aAdd(	aCab, {"E5_VENCTO" ,ZA9->ZA9_DATA	,Nil} )
aAdd(	aCab, {"E5_DTDISPO",ZA9->ZA9_DATA	,Nil} )
aAdd(	aCab, {"E5_DTDIGIT",Date()				,Nil} )
aAdd(	aCab, {"E5_BANCO"  ,ZA9->ZA9_BANCO	,Nil} )
aAdd(	aCab, {"E5_AGENCIA",ZA9->ZA9_AGENCI	,Nil} )
aAdd(	aCab, {"E5_CONTA"  ,ZA9->ZA9_NUMCON ,Nil} )
aAdd(	aCab, {"E5_RECPAG" ,"P"					,Nil} )
aAdd(	aCab, {"E5_TPDESC" ,"C"					,Nil} )
aAdd(	aCab, {"E5_HISTOR" ,Padr(ZA9->ZA9_HIST,Len(SE5->E5_HISTOR)),Nil} )
aAdd(	aCab, {"E5_BENEF"  ,Padr(ZA9->ZA9_ARQCNA,Len(SE5->E5_BENEF)),Nil} )
aAdd(	aCab, {"E5_DOCUMEN",Padr(ZA9->ZA9_DOCUME,Len(SE5->E5_DOCUMEN)),Nil} )
aAdd(	aCab, {"E5_ORIGEM" ,"PB680FIN",Nil} )

lInclui := Inclui := .T.
lAltera := Altera := .F.

Private lMsErroAuto
Private lMsHelpAuto
Private lAutoErrNoFile

aCab  := FWVetByDic( aCab, 'SE5')     //--< Ordena o array de acordo com o sx3>>---

VarInfo("aCab",aCab)
Begin Transaction

MSExecAuto({|x,y,z,w| FINA100(x,y,z,w)},,aCab,3)

If lMsErroAuto
	DisarmTransaction()
	MostraErro()
Else
	/*/
	ZA0->( DbSetOrder(2) )
	If ! ZA0->( DbSeek( xFilial("ZA0") + ZA9->ZA9_BANCO + ZA9->ZA9_CODHIS ) )
		RecLock("ZA0",.T.)
		ZA0->ZA0_FILIAL  := xFilial("ZA0")
		ZA0->ZA0_CODIGO  := ZA9->ZA9_CODHIS
		ZA0->ZA0_BANCO   := ZA9->ZA9_BANCO
		ZA0->ZA0_DESCTA  := ZA9->ZA9_HIST
		ZA0->( MSUnLock() )
	Endif
	/*/
	RecLock("ZA9",.F.)
	ZA9->ZA9_RECONC  := "x"
	ZA9->( MSUnLock() )
EndIf

End Transaction

dDataBase := _dDtAtu

Return

Static Function SqlExecTC(cVar)
Local nRet := 0

VarInfo("SqlExecTC",cVar)

//nRet := TCSqlExec(cVar)

Return -1 // nRet

** Criado por: Alessandro de Farias - amjgfarias@gmail.com - Em: 21/08/2008
User Function PBProcName(cFuncao)
Local lRet := .F.
Local nPos := 0

Do While ProcName(nPos) <> ""
	If Alltrim(Upper(cFuncao)) $ Alltrim(Upper(ProcName(nPos)))
		lRet := .T.
		Exit
	Endif
	nPos++
EndDo

Return(lRet)

Static Function ChooseRet()
Local cTitle       := "Diretorio a ser processado"
Local cMask        := "Tipo do arquivo (cc*.ret)|cc*.ret"
Local cFile        := ""
Local nDefaultMask := 0
Local lSalvar		 := .T.
Local lArvore		 := .F. /*.T. = apresenta o árvore do servidor || .F. = não apresenta*/
Local cDefaultDir  := "C:\"
Local nOptions     := GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY // GETF_OVERWRITEPROMPT +
cFile := cGetFile( cMask, cTitle, nDefaultMask, cDefaultDir,lSalvar, nOptions, lArvore )
Return cFile
