#Include "Protheus.ch"
#Include "TopConn.Ch"
#Include "Font.Ch"
#Include "Colors.Ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EtqProd   ºAutor   ³Michel Rocha       º Data ³  18/09/2023 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Impressão de Etiquetas 5x11                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grupo Total                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function EtqProd(cPerg)

	Local aPergs   := {}
	Local cProdDe  := Space(TamSX3('B1_COD')[01])
	Local cProdAt  := Space(TamSX3('B1_COD')[01])
	Local nQtdCp   := 0
	Local lFlag   := .T.


	aAdd(aPergs, {1, "Produto De",  cProdDe,  ""     , ".T.", "SB1", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Produto Até", cProdAt,  ""     , ".T.", "SB1", ".T.", 80,  .T.})
	aAdd(aPergs, {1, "Qtde copias", nQtdCp , "@E 999", "Positivo()",    "", ".T.", 80, .F.})
	While lFlag
		If ParamBox(aPergs, "Informe os parâmetros")
			Processa( { || U_PrtEtiq(MV_PAR01, MV_PAR02, MV_PAR03) }, "Imprimindo etiquetas..." )
		else
			lFlag := .F.
		EndIf
	End
Return

//Impressão
User Function PrtEtiq(MV_PAR01,MV_PAR02,nQtde)
	Local nX 	  := 0
	Local aArea   := GetArea()
	//Local cReturn := "u_etqprod()"

	cQuery := "SELECT B1_COD FROM "+RetSqlName("SB1")+" WHERE B1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND D_E_L_E_T_ = '' "
	MpSysOpenQuery(cQuery, "TMP")
	While TMP->(!Eof())
		DbSelectArea("SB1")
		DbSetOrder(1)
		If !DbSeek(xFilial("SB1")+TMP->B1_COD)
			MsgAlert("Produto não existe no cadastro, informe um código válido!")
			Return
		EndIf
		cCodBarr := Alltrim(SB1->B1_COD)
		cDescPrd := Alltrim(SB1->B1_DESC)
		cGTINPrd := Alltrim(SB1->B1_COD)

		For nX := 1 to nQtde

			MSCBPrinter("ZEBRA","LPT1",,,.F.,,,,,,.T.)

			cFonte :="B"
			cTamX  :="25"
			cTamY  :="25"
			nTambar  := 10
			nAlt   := 019
			// MSCBLOADGRF("LogoEtq.GRF") //Carrega Logo
			MSCBCHKSTATUS(.F.) //Desativa a checagem do Status.

			MSCBBEGIN(1,6) //Inicia impressão 1º Eti	02queta

			//Codigo do Produto
			MSCBSAY( 020,081,"CODIGO:    "+Substr(cCodBarr,1,60),   "B"      ,cFonte    ,cTamX)
			//Descrição do Produto
			If len(AllTrim(cDescPrd)) > 30
				MSCBSAY( 030,020,"DESCRIÇÂO: "+Substr(AllTrim(cDescPrd),1,30)+"-" ,   "B"      ,cFonte    ,cTamX)
				MSCBSAY( 037,070, substr(cDescPrd,30,len(cDescPrd)) ,   "B"      ,cFonte    ,cTamX)
			Else
				MSCBSAY( 030,040,"DESCRIÇÂO: "+cDescPrd,   "B"      ,cFonte    ,cTamX)
			EndIf

			MSCBSAYBAR(047,040,cGTINPrd                   ,"B"      , "MB07"  , nTambar    ,.F.     ,.T.    , .F.      ,           , 4       ,3)
			//MSCBGRAFIC(065,020,"LOGOBR") //Exibe Brasil
			MSCBSAY(080,035,"EAN13","B"      ,cFonte   ,cTamY)

			//  Cód. Barras interno
			//MSCBSAYBAR(007,035,Alltrim(cCodBarr)                     ,"R"      , "MB07"  , nTambar     ,.F.     ,.T.    , .F.      ,           , 3       ,2)
			//MSCBSAY(002,035,"C.INT","B"      ,cFonte    ,cTamY)

			MSCBEND() //Finaliza impressão 1º pag.
			MSCBCLOSEPRINTER()//Fecha Conexão
		Next
		TMP->(DbSkip())
	EndDo

	TMP->(DbCloseArea())

	RestArea(aArea)
Return
