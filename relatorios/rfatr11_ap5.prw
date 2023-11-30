#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 11/03/03
#INCLUDE "topconn.ch"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±úÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂ¿±?
±±³Funçào    ?RFATR11  ?Autor ?Ademberg              ?Data ?0.10.2000³±?
±±ÂÂÂÂÂÂÂÂÂÂÂÅÂÂÂÂÂÂÂÂÂÂÁÂÂÂÂÂÂÂÁÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÁÂÂÂÂÂÂÁÂÂÂÂÂÂÂÂÂÂ´±?
±±³Descriçào ?Listagem de precos                                         ³±?
±±ÁÂÂÂÂÂÂÂÂÂÂÁÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂú±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?

±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±úÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂ¿±?
±±³Funçào    ?RFATR11  ?Autor ?Ricardo               ?Data ?3.11.2007³±?
±±ÂÂÂÂÂÂÂÂÂÂÂÅÂÂÂÂÂÂÂÂÂÂÁÂÂÂÂÂÂÂÁÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÁÂÂÂÂÂÂÁÂÂÂÂÂÂÂÂÂÂ´±?
±±³Descriçào ?Listagem de precos futuros por filial                      ³±?
±±ÁÂÂÂÂÂÂÂÂÂÂÁÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂú±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?

*======================================================================================================*
| PROGRAMA | RFATR11           | CRIADO EM  | 30/10/2000 por Ademberg              |   ALTERADO POR    |
|----------------------------------------------------------------------------------|-------------------|
| Tabela de Preço Futura                                                           | EMIS              |
|                                                                                  |-------------------|
|                                                                                  | EM:   /  /        |
*======================================================================================================*
| ALTERACAO : Ajuste para usar query do sql e não dbfs                             |   ALTERADO POR    |
|                                                                                  | Adilson Jorge     |
|                                                                                  |-------------------|
|                                                                                  | EM: 10/09/2012    |
*======================================================================================================*
| ALTERACAO : Ajuste para considerar o parametro MV_MATKELL para os produtos da    |   ALTERADO POR    |
|             KELLDRIN                                                             | Adilson Jorge     |
|                                                                                  |-------------------|
|                                                                                  | EM: 26/02/2015    |
*======================================================================================================*
*/

User Function RFATR11()        // incluido pelo assistente de conversao do AP5 IDE em 11/03/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?

	SetPrvt("TITULO,CDESC1,CDESC2,CDESC3,TAMANHO,LIMITE")
	SetPrvt("CSTRING,ARETURN,NOMEPROG,ALINHA,NLASTKEY,CPERG")
	SetPrvt("CBTXT,NLIN,M_PAG,WNREL,CFOR01,NTIPO")
	SetPrvt("CABEC1,CABEC2,CTABELA,CARQTMP2,CNGUERRA,CCODFOR")
	SetPrvt("LIMPRIME,LD60F,NPRV1,CMENS,CCOD,CDIV")
	SetPrvt("LPRI,NRECATU,NITENS,CABECA,VFILIAL")

	titulo   := "LISTAGEM DE PRECOS PROMOCIONAIS"
	cDesc1   := "LISTAGEM DE PRECOS PROMOCIONAIS"
	cDesc2   := ""
	cDesc3   := ""
	tamanho  := "M"
	limite   := 132
	cString  := "SB1"
	aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	nomeprog := "RFATR11"
	aLinha   := { } ;nLastKey := 0
	cPerg    := "RFATR11Z"
	cbtxt    := SPACE(10)
	nLin     := 1000
	m_pag    := 1

	/*IF SM0->M0_CODIGO == "01"  //empresa 01 Emis
		cPerg    := "RFATR11"
	Else
		cPerg    := "ESTR05"
	Endif*/

pergunte(cPerg,.F.)	//Novo grupo de perguntas

// mv_par01 - Fornecedor
// mv_par02 - De Grupo
// mv_par03 - Até Grupo
// mv_par04 - Do  Produto
// mv_par05 - Ate Produto
// mv_par06 - Apos Ent.
// mv_par07 - Divisão
// mv_par08 - Consolida Divisão
// mv_par09 - Tabela
// mv_par10 - % Apos Ent - Grp 8
// mv_par11 - % 7 Dias - Grp 8
// mv_par12 - % 14 Dias - Grp 8
// mv_par13 - % 21 Dias - Grp
// mv_par14 - Inicio da Tabela
// mv_par15 - Separa Fornecedor?
// mv_par16 - Considerar MV_MATKELL

	wnrel := "Rfatr11"           //Nome Default do relatorio em Disco

	SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,)

	DBSelectArea("SZP")
	DBSetOrder(1)

	DBSelectArea("SX5")
	DBSetOrder(1)
	DBSeek("01"+"93"+mv_par01)
	cFor01:=Subs(x5_descri,1,16)

	If mv_par08 == 1
		mv_par07 := 9
	EndIf

	If mv_par07 == 1
		titulo :="TABELA DE PRECOS(FUTURA) "+cValToChar(mv_par09)+" - AGRICOLA"
	ElseIf mv_par07 == 2
		titulo :="TABELA DE PRECOS(FUTURA) "+cValToChar(mv_par09)+" - ATACADO"
	ElseIf mv_par07 == 3
		titulo :="TABELA DE PRECOS(FUTURA) "+cValToChar(mv_par09)+" - VETERINARIA"
	ElseIf mv_par07 == 4
		titulo :="TABELA DE PRECOS(FUTURA) "+cValToChar(mv_par09)+" - BAYER PCO"
	ElseIf mv_par07 == 5
		titulo :="TABELA DE PRECOS(FUTURA) "+cValToChar(mv_par09)+" - PECAS JACTO"
	Else
		titulo :="TABELA DE PRECOS(FUTURA) "+cValToChar(mv_par09)+" - CONSOLIDADO"
	EndIf

	If nLastKey == 27
		Set Filter To
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Set Filter To
		Return
	Endif

	n14D := U_PercZW9(14)
	n28D := U_PercZW9(28)
	n45D := U_PercZW9(45)
	n60D := U_PercZW9(60)
	n75D := U_PercZW9(75)

	nTipo  := IIF(aReturn[4]=1,15,18)
	cabec1 := chr(27)+chr(80)+chr(14)+chr(27)+chr(48)+Space(30)+cFor01
	cabec2 :=" . "
	cTabela:=Space(54)+Transform(mv_par06,"@E 99.99")+Space(7)+;
		Transform(n14D,"@E 99.99")+Space(6)+;
		Transform(n28D,"@E 99.99")+Space(6)+;
		Transform(n28D,"@E 99.99")+Space(6)+;
		Transform(n45D,"@E 99.99")+Space(6)+;
		Transform(n60D,"@E 99.99")+Space(6)+;
		Transform(n75D,"@E 99.99")

	DBSelectArea("SB1")
	DBSetOrder(9)
	DbGoTop()

	RptStatus({||Rptph01()},Titulo)// Substituido pelo assistente de conversao do AP5 IDE em 11/03/03 ==> RptStatus({||Execute(Rptph01)},Titulo)

	DbSelectArea("SB1")
	DbCloseArea()

Return

// Substituido pelo assistente de conversao do AP5 IDE em 11/03/03 ==> Function Rptph01
Static Function Rptph01()

//MV_PAR14 < szp->zp_prxdat

	cSQL := " SELECT COD=B1_COD,
	cSQL += " DESCR=B1_DESC,
	cSQL += " UM=B1_UM,CODFOR=B1_CODFOR,FORN=B1_NGUERRA,MSG=BZ_MENSTAB,TAB=BZ_TABELA,
	cSQL += " DIVISAO=B1_DIVISAO, GRUPO=B1_GRUPO, DESCONTO=B1_CHASSI, ATUAL =BZ_PRV1,
	cSQL += " FUTURA=COALESCE((SELECT ZP_PRV1 FROM "+RetSqlName("SZP")+" SZP (NOLOCK) "
	cSQL += "                  WHERE ZP_COD = B1_COD
	cSQL += "                    AND ZP_PRXDAT >= '" + DTOS(MV_PAR14) + "'
	cSQL += "                    AND ZP_FILIAL  = '"+ xFilial("SZP")+"' AND SZP.D_E_L_E_T_=''),0)
	IF SM0->M0_CODIGO $ "02|03"  //empresa 02 Cativa
		cSQL += " ,CATEGORIA=(CASE WHEN B1_NECATEG = '1' THEN 'A' ELSE CASE WHEN B1_NECATEG = '2' THEN 'BC' ELSE CASE WHEN B1_NECATEG = '3' THEN 'D' ELSE '' END END END)
	Else
		cSQL += " ,CATEGORIA=''
	Endif
	cSQL += " FROM "+RetSqlName("SB1")+" B1 (NOLOCK), "+RetSqlName("SBZ")+" BZ (NOLOCK) "
	cSQL += " WHERE B1_GRUPO   BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' "
	If mv_par08 <> 1       //Se não consolidar divisão, emite s?a desejada
		cSQL += "   AND B1_DIVISAO = '"+Str(mv_par07,1)+"' "
	Endif
	cSQL += "   AND B1_CODFOR NOT IN ('73','76')
	If !Empty(mv_par01)    //Se desejar selecionar s?1 fornecedor
		cSQL += "   AND B1.B1_CODFOR IN " + FormatIn(MV_PAR01,",") + " " //Ajustado por Adilson Jorge em 30/10/2012
		//cSQL += "   AND B1_CODFOR  = '"+MV_PAR01+"' "
	Endif
//cSQL += "   AND B1_NGUERRA >= 'EUROFARMA' " //HABILITAR QUANDO QUISER TIRAR A PARTIR DE ALGUM FORNECEDOR
	cSQL += "   AND B1_COD     = BZ_COD
	cSQL += "   AND BZ_TABELA  = 'SIM' AND BZ_FILIAL = '"+ xFilial("SBZ")+"' "
	cSQL += "   AND B1.D_E_L_E_T_ = ''
	cSQL += "   AND BZ.D_E_L_E_T_ = ''
	cSQL += " ORDER BY B1_NGUERRA,B1_DESC

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRY",.T.,.T.)

	QRY->(DbGoTop())

	DbSelectArea("QRY")
	SetRegua(RecCount())
	DBGOTOP()

	nLin  := 100
//m_pag := 10 //HABILITAR PARA TIRAR A PARTIR DE PAGINAS ESPECIFICAS

// DBSeek(Trim(sm0->m0_codfil))

	While !QRY->(Eof())

		cCateg   := Alltrim(QRY->CATEGORIA)
		cNguerra := AllTrim(QRY->FORN)
		cCodFor  := QRY->CODFOR
		//   cabec1   := chr(27)+chr(80)+chr(14)+chr(27)+chr(48)+Space(30)+QRY->FORN
		//   cabec2   := " . "

//	If (nLin > 82 .OR. AllTrim(QRY->FORN) <> AllTrim(cNguerra)) .AND. !QRY->(Eof())
		If (nLin > 82 .OR. AllTrim(QRY->CODFOR) <> AllTrim(cCodfor)) .AND. !QRY->(Eof())
			cabec1 := chr(27)+chr(80)+chr(14)+chr(27)+chr(48)+Space(30)+QRY->FORN
			cabec2 := " . "
			cabec(titulo,cabec1,cabec2,nomeprog,titulo,nTipo)
			nLin:=08
			nLin:=nLin+1
//		If QRY->CODFOR == "C5"            
			//          1         2         3         4         5         6         7         8         9         10        11        12
			//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//			@ nLin,00 PSay "       P R O D U T O                          Desc      UM     C/Entrega   14 D AF.    28 D AF.   45 D AF.      Mensagem"
//		Else
			IF SM0->M0_CODIGO == "01"  //empresa 01 Emis
				@ nLin,00 PSay "       P R O D U T O                              UM C/Entrega  14 D AF.  28 D AF.  45 D AF.  60 D AF.  75 D AF.  90 D AF. Mensagem
				//@ nLin,00 PSay "       P R O D U T O                              UM   C/Entrega   14 D AF.    28 D AF.    45 D AF.   60 D AF.  Mensagem"
			Else
				@ nLin,00 PSay "       P R O D U T O                          Cat UM   C/Entrega   14 D AF.    28 D AF.    45 D AF.   60 D AF.  Mensagem"
				//@ nLin,00 PSay "       P R O D U T O                          UM   C/Entrega   14 D AF.    28 D AF.    45 D AF.   60 D AF. Cat  Mensagem"
			Endif
//		Endif
			nLin:=nLin+1
			@ nLin,00 PSay Replicate("-",137)
			nLin:=nLin+1
		Endif

//	While AllTrim(QRY->FORN) == AllTrim(cNguerra)
		While AllTrim(QRY->CODFOR) == AllTrim(cCodfor) .and. !QRY->(Eof())

			//		ALERT("GERANDO TABELA - "+cFor+" / "+SB1->B1_NGUERRA )
			IncRegua()

			lD60F:=.f.
			DBSelectArea("SZ4")
			DBSetOrder(1)
			DBSeek(XFILIAL("SZ4")+QRY->COD)
			If Found() .and. z4_d60f > 0 .and. QRY->DIVISAO == "1"
				lD60F:=.t.
			ElseIf QRY->DIVISAO == "1"
				DBSelectArea("SZ5")
				DBSetOrder(1)
				DBSeek(XFILIAL("SZ5")+QRY->GRUPO)
				If Found() .and. z5_d60f > 0
					lD60F:=.t.
				EndIf
			EndIf

			DBSelectArea("QRY")

			If nLin > 82
				cabec1 := chr(27)+chr(80)+chr(14)+chr(27)+chr(48)+Space(30)+QRY->FORN
				cabec2 := " . "
				cabec(titulo,cabec1,cabec2,nomeprog,titulo,nTipo)
				nLin:=08
				nLin:=nLin+1
//			If QRY->CODFOR == "C5"            
				//          1         2         3         4         5         6         7         8         9         10        11        12
				//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//				@ nLin,00 PSay "       P R O D U T O                          Desc      UM     C/Entrega   14 D AF.    28 D AF.   45 D AF.      Mensagem"
//			Else
				IF SM0->M0_CODIGO == "01"  //empresa 01 Emis
					@ nLin,00 PSay "       P R O D U T O                              UM C/Entrega  14 D AF.  28 D AF.  45 D AF.  60 D AF.  75 D AF.  90 D AF. Mensagem
					//@ nLin,00 PSay "       P R O D U T O                              UM   C/Entrega   14 D AF.    28 D AF.    45 D AF.   60 D AF.  Mensagem"
				Else
					@ nLin,00 PSay "       P R O D U T O                          Cat UM   C/Entrega   14 D AF.    28 D AF.    45 D AF.   60 D AF.  Mensagem"
					//@ nLin,00 PSay "       P R O D U T O                          UM   C/Entrega   14 D AF.    28 D AF.    45 D AF.   60 D AF. Cat  Mensagem"
				Endif
//			Endif
				nLin:=nLin+1
				@ nLin,00 PSay Replicate("-",137)
				nLin:=nLin+1
			Endif

			nPrv1 := QRY->ATUAL
			cMens := QRY->MSG

			If QRY->FUTURA > 0
				nPrv1 := QRY->FUTURA
			EndIf

			//Crítica inserida por Adilson Jorge em 26/02/2015, s?imprimir produtos Kelldrin que podem ser vendidos por todos os vendedores
			//No parâmetro 22 - Considera MV_MATKELL = SIM, se for NAO vai imprimir a tabela completa de Kleiton
			If Trim(sm0->m0_codfil) == "01" .AND. QRY->CODFOR == "C7" .AND. MV_PAR22 == 1 .AND. !ALLTRIM(QRY->COD) $ GETMV("MV_MATKELL")
				DBSelectArea("QRY")
				DBSkip()
				Loop
			Endif

/*		If QRY->CODFOR == "C5"
		
			@ nLin,00  PSay Alltrim(QRY->COD)
			@ nLin,07  PSay Subs(QRY->DESCR,1,37)
			@ nLin,46  PSay Alltrim(QRY->DESCONTO)
			@ nLin,56  PSay QRY->UM		
			@ nLin,63  PSay nPrv1 * (1-mv_par06/100) Picture "@E 99,999.99"
			@ nLin,74  PSay nPrv1 * (1-n14D/100) Picture "@E 99,999.99"
			@ nLin,86  PSay nPrv1 * (1-n28D/100) Picture "@E 99,999.99"
			@ nLin,97  PSay nPrv1 * (1-n60D/100) Picture "@E 99,999.99"

//			If LD60F
//				@ nLin,95 PSay nPrv1 * (1-n75D/100) Picture "@E 99,999.99"
//			EndIf
			@ nLin,111 PSay chr(27)+chr(80)+chr(14)+chr(27)+chr(48)+Subs(cMens,1,15)
		
			nLin:=nLin+1
			@ nLin,00 PSay Replicate("-",137)
			nLin:=nLin+1

		Else
*/		
			@ nLin,00  PSay Alltrim(QRY->COD)
			@ nLin,07  PSay Subs(QRY->DESCR,1,37)

			IF SM0->M0_CODIGO $ "02|03"  //empresa 02 Cativa
				@ nLin,46 PSay Trim(QRY->CATEGORIA)
				@ nLin,50  PSay QRY->UM
				@ nLin,54  PSay nPrv1 * (1-mv_par06/100) Picture "@E 99,999.99"
				@ nLin,66  PSay nPrv1 * (1-n14D/100) Picture "@E 99,999.99"
				@ nLin,77  PSay nPrv1 * (1-n28D/100) Picture "@E 99,999.99"
				@ nLin,88  PSay nPrv1 * (1-n60D/100) Picture "@E 99,999.99"
				IF QRY->DIVISAO == "1"
					@ nLin,99 PSay nPrv1 * (1-n75D/100) Picture "@E 99,999.99"
				ENDIF
				@ nLin,111 PSay chr(27)+chr(80)+chr(14)+chr(27)+chr(48)+Subs(cMens,1,15)
			Else
				@ nLin,050 PSay QRY->UM
				@ nLin,053 PSay nPrv1 * (1-mv_par06/100) Picture "@E 99,999.99"
				@ nLin,063 PSay nPrv1 * (1-n14D/100) Picture "@E 99,999.99"
				@ nLin,073 PSay nPrv1 * (1-n28D/100) Picture "@E 99,999.99"
				@ nLin,083 PSay nPrv1 * (1-n28D/100) Picture "@E 99,999.99"
				@ nLin,093 PSay nPrv1 * (1-n45D/100) Picture "@E 99,999.99"
				@ nLin,103 PSay nPrv1 * (1-n60D/100) Picture "@E 99,999.99"
				@ nLin,113 PSay nPrv1 * (1-n75D/100) Picture "@E 99,999.99"
				@ nLin,123 PSay Subs(cMens,1,15)
				//@ nLin,123 PSay chr(27)+chr(80)+chr(14)+chr(27)+chr(48)+Subs(cMens,1,15)
			Endif

//			@ nLin,50  PSay QRY->UM
//			@ nLin,54  PSay nPrv1 * (1-mv_par06/100) Picture "@E 99,999.99"
//			@ nLin,66  PSay nPrv1 * (1-n14D/100) Picture "@E 99,999.99"
//			@ nLin,77  PSay nPrv1 * (1-n28D/100) Picture "@E 99,999.99"
//			@ nLin,88  PSay nPrv1 * (1-n28D/100) Picture "@E 99,999.99"

//			@ nLin,46  PSay QRY->UM
//			@ nLin,50  PSay nPrv1 * (1-mv_par06/100) Picture "@E 99,999.99"
//			@ nLin,62  PSay nPrv1 * (1-n14D/100) Picture "@E 99,999.99"
//			@ nLin,73  PSay nPrv1 * (1-n28D/100) Picture "@E 99,999.99"
//			@ nLin,84  PSay nPrv1 * (1-n60D/100) Picture "@E 99,999.99"

			//Ajustado por Adilson Jorge em 10/10/2018
			//If LD60F
			//	@ nLin,95 PSay nPrv1 * (1-n75D/100) Picture "@E 99,999.99"
			//EndIf

//Retirado em 25/09/2020 - Adilson Jorge			
/*
			IF SM0->M0_CODIGO == "01"  //empresa 01 Emis
//				If LD60F
					@ nLin,99 PSay nPrv1 * (1-n45D/100) Picture "@E 99,999.99"
					@ nLin,99 PSay nPrv1 * (1-n60D/100) Picture "@E 99,999.99"
					@ nLin,99 PSay nPrv1 * (1-n75D/100) Picture "@E 99,999.99"
//				EndIf
			ELSE                       //empresa 02 Cativa
				IF QRY->DIVISAO == "1"
					@ nLin,99 PSay nPrv1 * (1-n45D/100) Picture "@E 99,999.99"
				ENDIF					
			ENDIF
										
//         @ nLin,107 PSay Trim(QRY->CATEGORIA)

			@ nLin,111 PSay chr(27)+chr(80)+chr(14)+chr(27)+chr(48)+Subs(cMens,1,15)
*/
			nLin:=nLin+1
			@ nLin,00 PSay Replicate("-",137)
			nLin:=nLin+1

//		Endif

			DBSelectArea("QRY")
			DBSkip()

		End

		//QUEBRANDO PÁGINA A CADA FORNECEDOR, ADILSON JORGE EM 24/08/2012
		If MV_PAR15 == 1
			nLin := 100
		Endif

		If nLin <= 76 .AND. !QRY->(Eof())
//	If !QRY->(Eof())
			cabecA := chr(27)+chr(80)+chr(14)+chr(27)+chr(48)+Space(30)+QRY->FORN
			@ nLin,00 PSay Replicate("*",132)
			nLin:=nLin+1
			@ nLin,00 PSay CabecA
			nLin:=nLin+1
			@ nLin,00 PSay " . "
			nLin:=nLin+1
			@ nLin,00 PSay Replicate("*",132)
			nLin:=nLin+1

			//@ nLin,00 PSay "       P R O D U T O                          UM   C/Entrega   14 D AF.    28 D AF.    45 D AF    60 D AF       Mensagem"
			IF SM0->M0_CODIGO == "01"  //empresa 01 Emis
				@ nLin,00 PSay "       P R O D U T O                              UM C/Entrega  14 D AF.  28 D AF.  45 D AF.  60 D AF.  75 D AF.  90 D AF. Mensagem
				//@ nLin,00 PSay "       P R O D U T O                              UM   C/Entrega   14 D AF.    28 D AF.    45 D AF.   60 D AF.  Mensagem"
			Else
				@ nLin,00 PSay "       P R O D U T O                          Cat UM   C/Entrega   14 D AF.    28 D AF.    45 D AF.   60 D AF.  Mensagem"
//			@ nLin,00 PSay "       P R O D U T O                          UM   C/Entrega   14 D AF.    28 D AF.    45 D AF.   60 D AF. Cat  Mensagem"
			Endif

			nLin:=nLin+1
			@ nLin,00 PSay Replicate("-",137)
			nLin:=nLin+1
		Else
			nLin := 100
		Endif

		DBSelectArea("QRY")

	End

//Roda(0,"","M")

	DBSelectArea("QRY")
	QRY->(DBCloseArea())

	Set Device To Screen
	If aReturn[5] == 1
		Set Printer TO
		dbCommitAll()
		ourspool(wnrel)
	Endif
	MS_FLUSH() //Libera fila de relatorios em spool
Return

