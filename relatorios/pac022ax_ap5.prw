#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"

User Function Pac022Ax()        // incluido pelo assistente de conversao do AP5 IDE em 11/03/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?

	SetPrvt("TITULO,CDESC1,CDESC2,CDESC3,TAMANHO,LIMITE,x,tfili")
	SetPrvt("CSTRING,ARETURN,NOMEPROG,ALINHA,NLASTKEY,CPERG")
	SetPrvt("CBTXT,CBCONT,LI,M_PAG,NTOTAL,NTOTGRUP")
	SetPrvt("NTOTCONS,NNORDES,NNORDESTOT,NNORDESVFU,NTESTE,NG1")
	SetPrvt("NG2,NG3,NG4,NG5,NG6,NG7,nfort,tnfort,ntotvf,guerra")
	SetPrvt("WNREL,NTIPO,CABEC1,CABEC2,CARQ,INDSZ9")
	SetPrvt("CFIL,CSZ9,CSZG,NTOTVF,GRUPO,caliasCCOD")
	SetPrvt("CCHVEMP,A_SALDO1,A_SALDO2,NVFUT,NZGCUSTO,")

/*/
	ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ?
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
	±±úÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂ¿±?
	±±?unçào    ?ESTGRUP  ?Autor ?Paulo Henrique        ?Data ?         ³±?
	±±ÂÂÂÂÂÂÂÂÂÂÂÅÂÂÂÂÂÂÂÂÂÂÁÂÂÂÂÂÂÂÁÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÁÂÂÂÂÂÂÁÂÂÂÂÂÂÂÂÂÂ´±?
	±±?escriçào ?MAPA DO ESTOQUE POR CUSTO DE REPOSICAO                     ³±?
	±±ÂÂÂÂÂÂÂÂÂÂÂÅÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂ´±?
	±±?Uso      ?Generico                                                   ³±?
	±±ÁÂÂÂÂÂÂÂÂÂÂÁÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂú±?
	±±?unçào    ?ALTERACAO?Autor ?Ricardo Miranda       ?Data ?22/12/07 ³±?
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
//úÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂ¿
//?Define Variaveis                                             ?
//ÁÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂú
// 21/12/2007 imprime os produtos em estoque e seu preco de custo.
// por filial

	titulo :="M A P A   D E   E S T O Q U E  - Pco Custo de Reposicao"
	cDesc1 :="Relatorio Por Grupo de Estoque valorizado a Preco de custo"
	cDesc2 :=""
	cDesc3 :=""
	tamanho:="M"
	limite :=132
	CALIAS := ALIAS()
	cString:="SZ9" 
//*                 1       2         3        4  5  6  7  8
	aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	nomeprog:="GRUPO"
	aLinha  := { } ;nLastKey := 0
	nfort:=tnfort:=ntotvf:=x:=0
	cPerg   :="GRUPO"
//úÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂ¿
//?Variaveis utilizadas para Impressao do Cabecalho e Rodape    ?
//ÁÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂú
	cbtxt      := SPACE(10)
	cbcont     := 0
	li         := 80
	m_pag      := 0
	ntotal     := 0
	ntotgrup   := 0
	nTotCons   := 0
	nNordes    := 0
	nNordesTOT := nNorDesVFu:=0
	nTeste     := 0
	ng1:=ng2:=ng3:=ng4:=ng5:=ng6:=ng7:=0
//úÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂ¿
//?Verifica as perguntas selecionadas                           ?
//ÁÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂú
	pergunte("GRUPO",.F.)
//úÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂ¿
//?Variaveis utilizadas para parametros                         ?
//?mv_par01         // DO GRUPO                                 ?
//?mv_par02         // Ate GRUPO                                ?
//?mv_par03         // Data Refencia                            ?
//ÁÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂú
//úÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂ¿
//?Envia controle para a funcao SETPRINT                        ?
//ÁÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂú
	wnrel:="Pac022ax"            //Nome Default do relatorio em Disco

	wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,TAMANHO)

	If LastKey() == 27 .Or. nLastKey == 27
		SET FILTER TO
		Return
	Endif

	SetDefault(aReturn,cString)
	If LastKey() == 27 .OR. nLastKey == 27
		SET FILTER TO
		Return
	Endif

	nTipo  := IIF(aReturn[4]=1,15,18)
	*                    0         0         0         0         0
	*                    1         2         3         4         5         6         7         8         9        10         11
	* Regua     01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789

	cabec1  := "Codigo NOME DO PRODUTO                            Complemento               Est.    Fut.   Saldo    Pco Custo    Valor Total"
//          xxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   xxxxxxxxxxxxxxxxxxxx     99999   99999   99999   999,999.99   9,999,999.99
//          0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//          0         1         2         3         4         5         6         7         8         9        10        11        12        13
	cabec2  := ""
	**
	**
	aCampos	:=	{}
	AADD(aCampos,{"B1_NGUERRA"       ,"C",013,0})
	AADD(aCampos,{"B1_codfor"        ,"C",2,0})
	AADD(aCampos,{"B1_COD"           ,"C",015,0})
	AADD(aCampos,{"B1_DESC"          ,"C",040,0})
	AADD(aCampos,{"B1_COMPL"         ,"C",020,0})
	AADD(aCampos,{"B1_EST"           ,"N",005,0})
	AADD(aCampos,{"B1_FUT"           ,"N",005,0})
	AADD(aCampos,{"B1_SALDO"         ,"N",005,0})
	AADD(aCampos,{"B1_CUSTO"         ,"N",008,2})
	AADD(aCampos,{"B1_TOT"           ,"N",014,2})
	cArq054	:=	CriaTrab(aCampos)
	cArq054A:=      Left(cArq054,7)+"A"

	dbUseArea(.T.,__LocalDriver,cArq054,"TMP",.T.,.F.)
	IndRegua("TMp",CARQ054,"B1_NGUERRA+B1_DESC",,,)
	IndRegua("TMp",cArq054A,"B1_COD",,, )

	DbSelectArea("TMP")
	DbClearIndex()
	DbSetIndex(cArq054+OrdBagExt())
	DbSetIndex(cArq054A+OrdBagExt())
	dbSetOrder(2)
	dbSelectArea(cAlias)

	DBSELECTAREA("SF4")
	DBSetOrder(1)

	DBSELECTAREA("SD1")
	DBSetOrder(7)

	DBSELECTAREA("SD2")
	DBSetOrder(6)

	DBSELECTAREA("SD3")
	DBSetOrder(7)

	Processa( {|| RunProc() } )// Substituido pelo assistente de conversao do AP5 IDE em 11/03/03 ==> Processa( {|| Execute(RunProc) } )
Return
// Substituido pelo assistente de conversao do AP5 IDE em 11/03/03 ==> Function RunProc
Static Function RunProc()

	ProcRegua(RECCOUNT())

	DbSelectArea("SZ9")
	dbGoTop()
	dbsetorder(4)
	DbSelectArea("SZG")

	dbGoTop()
	dbsetorder(1)
	RptStatus({||RptMemo()},Titulo)// Substituido pelo assistente de conversao do AP5 IDE em 11/03/03 ==> RptStatus({||Execute(RptMemo)},Titulo)
Return

// Substituido pelo assistente de conversao do AP5 IDE em 11/03/03 ==> Function RptMemo
Static Function RptMemo()
	//Local NR

	SetRegua(RecCount())
	DbSelectArea("SZ9")
	dbGoTop()
	dbsetorder(4)

	tfili:=sm0->m0_codfil
	dbseek(tfili)
	While tfili==SZ9->z9_filial .and. !Eof()
		cChave := SZ9->z9_filial

		while cChave == SZ9->z9_filial .and. !Eof()
			IncRegua()

			IF !(Z9_GRUPO$"0001.0002.0003.0004.0005.0006.0007.0008.0009")
				SKIP
				LOOP
			ENDIF

			IF Z9_COD<"1000"
				SKIP
				LOOP
			ENDIF

			nTotVF:=0
			DbSelectArea("SZ9")
			GRUPO:=TFILI+Z9_GRUPO
			while grupo==Z9_FILIAL+Z9_grupo

				cCod := z9_cod

				DBSelectArea("SM0")
				cChvEmp:=sm0->m0_codigo+sm0->m0_codfil

				if sm0->m0_codfil=="03"
					A_SALDO1:=CalcEst(cCod,"30",MV_PAR04+1)
				Elseif sm0->m0_codfil=="04"
					A_SALDO1:=CalcEst(cCod,"40",MV_PAR04+1)
				elseif sm0->m0_codfil=="01"
					A_SALDO1:=CalcEst(cCod,"01",MV_PAR04+1)
				elseif sm0->m0_codfil=="05"
					A_SALDO1:=CalcEst(cCod,"50",MV_PAR04+1)
				elseif sm0->m0_codfil=="06"
					A_SALDO1:=CalcEst(cCod,"60",MV_PAR04+1)
				elseif sm0->m0_codfil=="08" 						//Sergipe, Adilson Jorge em 07/06/2012
					A_SALDO1:=CalcEst(cCod,"80",MV_PAR04+1)
				elseif sm0->m0_codfil=="09" 						//Juazeiro, Adilson Jorge em 07/06/2012
					A_SALDO1:=CalcEst(cCod,"01",MV_PAR04+1)
				elseif sm0->m0_codfil=="10" 						//Teresina, Adilson Jorge em 01/12/2012
					A_SALDO1:=CalcEst(cCod,"01",MV_PAR04+1)
				elseif sm0->m0_codfil=="11" 						//Conquista, Adilson Jorge em 19/01/2021
					A_SALDO1:=CalcEst(cCod,"01",MV_PAR04+1)
				endif

				DBSeek(cChvEmp)

				nNordes:=A_SALDO1[1]//+A_SALDO2[1]

				DBSelectArea("SZ9")

				nVFut := 0
				DBSelectArea("SZI")
				DBSetOrder(1)
				DBSeek(sm0->m0_codfil+cCod)
				While zi_filial+zi_produto == sm0->m0_codfil+cCod
					nVFut := nVFut + (zi_qtdpedi-zi_qtdentr)
					Skip
				EndDO

				DBSelectArea("SZ9")
				If nNordes-nVFut #0
					//    @ li,00 Psay Z9_cod Picture "!!!!!!"

					DBSELECTAREA("TMP")
					DBSETORDER(2)
					DBSEEK(CCOD)
					IF !FOUND()
						RECLOCK("TMP",.T.)
						REPLACE B1_COD WITH CCOD
					ENDIF
					DbSelectArea("SB1")
					DbSetOrder(1)
					Dbseek(xfilial("SB1")+cCod)

					DBSELECTAREA("TMP")
					DBSETORDER(2)
					DBSEEK(CCOD)
					IF FOUND()
						RECLOCK("TMP",.F.)
						REPLACE B1_NGUERRA WITH SB1->B1_NGUERRA
						replace b1_codfor  with sb1->b1_codfor
						IF SB1->B1_CODFOR$"73.76"
							REPLACE B1_DESC  With SUBSTR(SB1->B1_DESC,9,30)+"  "+SUBSTR(SB1->B1_DESC,1,7)
						ELSE
							REPLACE B1_DESC  With SB1->B1_DESC
						ENDIF

						REPLACE B1_COMPL   WITH SB1->B1_COMPLEM
					ENDIF

					DbSelectArea("SZG")
					DbSetOrder(1)
					Dbseek(xfilial("SZG")+Left(DtoS(Mv_PAR04),6)+cCod)
					If Found()
						//          ALERT("ACHOU SZG")
						nZGCusto := zg_custo
					Else
						DbSelectArea("SZ9")
						nZGCusto := z9_custo
					EndIf

					DBSelectArea("SZ9")
					nTotGrup:=nTotGrup+(nZGCusto*nNordes)
					nTotVF  :=nTotVF  +(nZGCusto*nVFut)

					DBSELECTAREA("TMP")
					DBSETORDER(2)
					DBSEEK(CCOD)
					IF FOUND()
						RECLOCK("TMP",.F.)
						REPLACE B1_EST WITH nNordes
						REPLACE B1_FUT WITH NVFUT
						REPLACE B1_SALDO   WITH nNordes-nVFut
						REPLACE B1_CUSTO   WITH nZGCusto
						REPLACE B1_TOT   WITH nZGCusto*(nNordes)  //  WITH nZGCusto*(nNordes-nVFut)
					ENDIF
					nNordes:=0
					DBSelectArea("SZ9")
				endif                      //

				DBSelectArea("SZ9")
				dbskip()
				incregua()
			END
			
		end
		cabecFil()
	End
	DBSelectArea("SZ9")
	RetIndex("SZ9")
	DBSelectArea("TMP")
	TMP->(DBCloseArea())

	Set Device To Screen

	If aReturn[5] == 1
		Set Printer TO
		dbCommitAll()
		Ourspool(wnrel)
	Endif
	ft_pflush()
RETURN
Static function cabecFil()
//  AQUI
	M_pag++

	DBSelectArea("TMP")
	DBSETORDER(1)
	dbGoTop()
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	li:=8
	SetRegua(RecCount())

	While !EOF()

		IncRegua()
		IF LastKey()==27
			set device to screen
			@PROW()+1,001 pSay "CANCELADO PELO OPERADOR"
			Exit
		EndIF

		IF li > 58
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			li:=8
		EndIF

		//  nTotVF:=0
		nfort      := 0
		GUERRA := B1_NGUERRA
		if x==1 .AND. LI<>8
			li:=li+1
			x:=2
		endif
		@ li,00 Psay "Fornecedor: " +  b1_nguerra
		li:=li+1

		WHILE  GUERRA==B1_NGUERRA

			//     @ li,00 Psay "Forcecedor: " +  b1_nguerra
			//        li:=li+1
			@ li,00 Psay  b1_cod picture "!!!!!"
			@ li,07 Psay b1_desc
			@ li,49 Psay b1_compl
			@ li,75 Psay b1_est   Picture "@E 99999"
			@ li,83 Psay b1_fut    Picture "@E 99999"
			@ li,91 Psay B1_saldo   Picture "@E 99999"
			@ li,99 Psay B1_custo   Picture "@E 999,999.99"
			@ li,112 Psay B1_tot   Picture "@E 9,999,999.99"
			nNordesVFu:=nNordesVFu+ (b1_fut*b1_custo)
			tnfort := b1_tot+ tnfort
			li:=li+1

			IF li > 58
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
				li:=8
				@ li,00 Psay "Fornecedor: " +  b1_nguerra
				li:=li+1
			EndIF

			//               @ li,00 Psay "Forcecedor: " +  b1_nguerra
			//              li:=li+1
			nfort=B1_tot+nfort
			// nTotVF:=B1_fuT+nTotVF

			dbskip()
			incregua()
		enddo
		IF li > 58
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			LI:=8
			@ li,00 Psay "Fornecedor: " +  b1_nguerra
			li:=li+1
		else
			LI:=LI+1
			@ li,00 Psay "Total do Fornecedor: " + guerra
			@ li,41 Psay nfort Picture "@E 9,999,999.99"
			//      li:=li+1              aqui
			x:=1
		endif
		nfort:=0

	end
	if eof()
		li:=li+2
		If sm0->m0_codfil <> "04"
			@ LI,00 PSAY "Total Estoque "+sm0->m0_filial
		Else
			@ LI,00 PSAY "Total Estoque Somma.."
		EndIf

		@ li,30 psay tnfort    PICTURE '@E 9,999,999,999.99'

		if nNordesVFu   > 0
			//         If ntotvf  > 0
			li:=li+1

			If sm0->m0_codfil <> "04"
				@ LI,00 PSAY "(-) V.Futu. "+sm0->m0_filial
			Else
				@ LI,00 PSAY "(-) V.Futu. Somma.."
			EndIf

			@ li,30 psay nNordesVFu   PICTURE '@E 9,999,999,999.99'
			li:=li+1
			@ li,30 psay tnfort-nNordesVFu    PICTURE '@E 9,999,999,999.99'
		EndIf
	EndIf
	EJECT

//úÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂ¿
//?Restaura a integridade dos dados                             ?
//ÁÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂú
Return
