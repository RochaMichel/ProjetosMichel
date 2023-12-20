#Include "Protheus.ch"
#Include "TopConn.Ch"
#Include "Font.Ch"
#Include "Colors.Ch"
 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MITO44   ºAutor   ³Michel Rocha       º Data ³  18/09/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Impressão de Etiquetas                                    º±±
±±º          ³  Tela incial para escolher o tipo de impressão que         º±±
±±º          ³  Ira ser feita                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grupo Total                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MITO44()

	Local aPergs   := {}
	Local cProd  := Space(TamSX3('B1_COD')[01])
	Local nQtdCp   := 0

	aAdd(aPergs, {1, "Produto",  cProd   ,"", ".T.", "SB1", ".T.", 80,  .T.})
	aAdd(aPergs, {2, "Modelo de etiqueta","Etiq_25x75", {"Etiq_25x75","Etiq_210x100","Etiq_250x100","Etiq_125x100","Etiq_125x100_2"} , 60 ,".T.",.T.})
	aAdd(aPergs, {1, "Qtde copias", nQtdCp , "@E 999", "Positivo()",    "", ".T.", 80, .T.})

	If !ParamBox(aPergs, "Informe os parâmetros")
		Return
	EndIf

	If MV_PAR02 == "Etiq_25x75"
		 U_Etiq25x75(MV_PAR01, MV_PAR03)
	ElseIf MV_PAR02 == "Etiq_210x100"
	     U_Etiq210x100(MV_PAR01, MV_PAR03)
	ElseIf MV_PAR02 == "Etiq_250x100"
	     U_Etiq250x100(MV_PAR01, MV_PAR03)//feito
	ElseIf MV_PAR02 == "Etiq_125x100"
	     U_Etiq125x100(MV_PAR01, MV_PAR03)//feito
	ElseIf MV_PAR02 == "Etiq_125x100_2"
         U_Et25x100_2(MV_PAR01, MV_PAR03) 
	EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MITO44   ºAutor   ³Michel Rocha       º Data ³  18/09/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Impressão de Etiquetas Etiq25x75                          º±±
±±º          ³  Impressão do relatorio Etiq25x75 com tela para informar   º±±
±±º          ³  Armazem e Lote                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grupo Total                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Etiq25x75(cProduto,nQtde)
	Local aPergs   := {}
	Local nX 	  := 0
	Local cReturn := "u_MITO44()"
	Local cAliaSB8 := GetNextAlias()
	Local aArea   := GetArea()
	//Local nSilaba

	aAdd(aPergs, {1, "Armazem do produto: "        ,  ""   ,"", ".T.", "", ".T.", 80,  .T.})// MV_PAR01
	aAdd(aPergs, {1, "Informe o lote do produto: " ,  ""   ,"", ".T.", "", ".T.", 80,  .T.})// MV_PAR02
	If ! ParamBox(aPergs, "Informe os parâmetros")
		Return &(cReturn)
	EndIf
	BeginSql alias cAliaSb8
		Select * from %table:SB8%
		where b8_produto = %Exp:cProduto%
		AND b8_local = %Exp:MV_PAR01%
		AND B8_LOTECTL = %Exp:MV_PAR02%
	EndSql
	SB8->(DbSetOrder(1))
	If !DbSeek(cFilant+cAliaSB8->(b8_produto+b8_local+B8_LOTECTL))
		MsgAlert("Produto não existe no cadastro, informe um código válido!")
		Return &(cReturn)
	EndIf

	For nX := 1 to nQtde

		MSCBPrinter("ZEBRA","LPT1",,,.F.,,,,,,.T.)

		cFonte :="B"
		cTamX  :="25"
		cTamY  :="25"
		nAlt   := 019

		MSCBCHKSTATUS(.F.) //Desativa a checagem do Status.

		MSCBBEGIN(1,6) //Inicia impressão 1º Eti	02queta

		//Codigo do Produto
				//ori//vert
		MSCBSAY( 010,002,"PRODUTO:"            ,"B",cFonte,cTamX)
		MSCBSAY( 010,008,AllTrim(posicione("SB1",1,xFilial('SB1')+SB8->B8_PRODUTO,"B1_DESC")),"B",cFonte,cTamX)
		//Descrição do Produto
		MSCBSAY( 010,014,"FAB: "+DtoC(SB8->B8_DATA)   ,"B",cFonte ,cTamX)
		MSCBSAY( 010,020,"VAL: "+cValToChar(DateDiffMonth(SB8->B8_DATA,SB8->B8_DTVALID))+" Meses" ,"B",cFonte ,cTamX)
		MSCBSAY( 050,020,"LOTE: "+AllTrim(SB8->B8_LOTECTL) ,"B",cFonte ,cTamX)

		MSCBEND() //Finaliza impressão 1º pag.

		MSCBCLOSEPRINTER()//Fecha Conexão

	Next
	(cAliaSB8)->(DbCloseArea())
	RestArea(aArea)

Return &(cReturn)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MITO44   ºAutor   ³Michel Rocha       º Data ³  18/09/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Impressão de Etiquetas Etiq210x100                        º±±
±±º          ³  Impressão do relatorio Etiq210x100 com tela para informar º±±
±±º          ³  Armazem,Lote e quantidade do lote                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grupo Total                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Etiq210x100(cProduto,nQtde)

	Local nX 	  := 0
	Local cReturn := "u_MITO44()"
	Local aArea   := GetArea()
	Local cAliaSB8 := GetNextAlias()

	aAdd(aPergs, {1, "Armazem do produto: "        ,  ""   ,"", ".T.", "", ".T.", 80,  .T.})// MV_PAR01
	aAdd(aPergs, {1, "Informe o lote do produto:" ,1   ,"",        ".T.", "", ".T.", 80,  .F.})// MV_PAR02
	aAdd(aPergs, {1, "E a Quantidade do Lote :"    ,1   ,"", "Positivo()", "", ".T.", 80,  .F.})// MV_PAR03
	If ! ParamBox(aPergs, "Informe os parâmetros")
		Return &(cReturn)
	EndIf
	BeginSql alias cAliaSb8
		Select * from %table:SB8%
		where b8_produto = %Exp:cProduto%
		AND b8_local = %Exp:MV_PAR01%
		AND B8_LOTECTL = %Exp:MV_PAR02%
	EndSql
	SB8->(DbSetOrder(1))
	If !DbSeek(cFilant+cAliaSB8->(b8_produto+b8_local+B8_LOTECTL))
		MsgAlert("Produto não existe no cadastro, informe um código válido!")
		Return &(cReturn)
	EndIf
	If (SB8->B8_QTDORI-SB8->B8_EMPENHO) < val(MV_PAR03)
		If !FWAlertYesNo("Saldo não disponivel deseja continuar mesmo assim? Sim / Não", "Obs")
			Return&(cReturn)
		EndIf
	EndIf

	For nX := 1 to nQtde

		MSCBPrinter("ZEBRA","LPT1",,,.F.,,,,,,.T.)

		cFonte :="B"
		cTamX  :="25"
		cTamY  :="25"

		// MSCBLOADGRF("LogoEtq.GRF") //Carrega Logo
		MSCBCHKSTATUS(.F.) //Desativa a checagem do Status.

		MSCBBEGIN(1,6) //Inicia impressão 1º Eti	02queta

		//Codigo do Produto
		MSCBSAY( 005,030,AllTrim(posicione("SB1",1,xFilial('SB1')+SB8->B8_PRODUTO,"B1_DESC")),"B",cFonte    ,cTamX)
		MSCBSAY( 005,060,"DATA: "+DtoC(SB8->B8_DATA),"B",cFonte    ,cTamX)
		MSCBSAY( 005,090,"VAL: "+cValtoChar(DateDiffDay(SB8->B8_DATA,SB8->B8_DTVALID))+" Dias"   ,"B",cFonte    ,cTamX)
		MSCBSAY( 005,120,"LOTE: "+AllTrim(SB8->B8_LOTECTL) ,"B",cFonte    ,cTamX)
		MSCBSAY( 005,150,"QUANT: "+cValToChar(MV_PAR03) ,"B",cFonte    ,cTamX)

		MSCBEND() //Finaliza impressão 1º pag.

		MSCBCLOSEPRINTER()//Fecha Conexão

	Next
	(cAliaSB8)->(DbCloseArea())
	RestArea(aArea)

Return &(cReturn)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MITO44   ºAutor   ³Michel Rocha       º Data ³  18/09/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Impressão de Etiquetas Etiq250x100                        º±±
±±º          ³  Impressão do relatorio Etiq250x100 com tela para informar º±±
±±º          ³  Armazem,Lote e Peso Liquido                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grupo Total                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Etiq250x100(cProduto,nQtde)

	Local nX 	  := 0
	Local n 	  := 0
	Local ntam 	  := 0
	Local cReturn := "u_MITO44()"
	Local aArea   := GetArea()
	//Local cAliaSB8 := GetNextAlias()
	Local cAliaSBM := GetNextAlias()
	Local aMsgPer := {}
	Local aMsgPre := {}
	Local aPergs := {}
	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))
	If !SB1->(DbSeek(xfilial('SB1')+Padr(cProduto,TamSx3("B1_COD")[1])))
		MsgAlert("Produto não existe no cadastro, informe um código válido!")
		Return &(cReturn)
	EndIf
	aAdd(aPergs, {1, "Armazem do produto: "  , space(tamSx3("B8_Local")[1])   ,"", ".T.", "", ".T.", 80,  .T.})// MV_PAR01
	aAdd(aPergs, {1, "Informe o lote do produto: " ,space(tamSx3("B8_LOTECTL")[1])  ,"", ".T.", "", ".T.", 80,  .F.})// MV_PAR02
	aAdd(aPergs, {1, "Informe o peso liquido: " ,space(3)  ,"", ".T.", "", ".T.", 80,  .F.})// MV_PAR03
	If ! ParamBox(aPergs, "Informe os parâmetros")
		Return &(cReturn)
	EndIf

	//BeginSql alias cAliaSb8
	//	Select * from %table:SB8%
	//	where b8_produto = %Exp:cProduto%
	//	AND b8_local = %Exp:MV_PAR01%
	//	AND B8_LOTECTL = %Exp:MV_PAR02%
	//EndSql
    //
	BeginSql alias cAliaSBM
		Select * from %table:SBM%
		where BM_GRUPO = %Exp:SB1->B1_GRUPO%
	EndSql
	//DbSelectArea('SB8')
	//SB8->(DbSetOrder(1))
	//If !SB8->(DbSeek(xfilial('SB8')+(cAliaSB8)->(b8_produto+b8_local+B8_LOTECTL)))
	//	MsgAlert("Produto com Armazem ou lote invalidos, informe um código válido!")
	//	Return &(cReturn)
	//EndIf

	For nX := 1 to nQtde

		MSCBPrinter("ZEBRA","LPT1",,,.F.,,,,,,.T.)

		cFonte :="B"
		cTamX  :="25"
		cTamY  :="25"

		MSCBCHKSTATUS(.F.) //Desativa a checagem do Status.

		MSCBBEGIN(1,6) //Inicia impressão 1º Eti	02queta

		MSCBSAY( 002,090,subStr(AllTrim(SB1->B1_DESC),1,26),"B",cFonte    ,"55")
		MSCBSAY( 020,198,"Composição química:","B",cFonte    ,cTamX)
		//MSCBSAY( 020,001,"01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789 ","B",cFonte    ,cTamX)
		MSCBSAY( 025,180,"Substância.................             ","B",cFonte    ,cTamX)
		MSCBSAY( 030,180,"Sinônimo...................             ","B",cFonte    ,cTamX)
		MSCBSAY( 035,180,"Nome químico...............             ","B",cFonte    ,cTamX)
		MSCBSAY( 040,180,"N°CAS......................             ","B",cFonte    ,cTamX)
		MSCBSAY( 045,153,"PRODUTO CONTROLADO PELA POLICIA FEDERAL ","B",cFonte    ,cTamX)

		aMsgPer := U_RetMemu(SB1->B1_COD,SBM->BM_XMSGPER)
		MSCBSAY( 055,215,"perigos ","B",cFonte    ,"17")
		ntam := 055
		For n := 1 to len(aMsgPer)
			MSCBSAY( ntam,200,aMsgPer[n],"B",cFonte    ,"15")
			ntam += 005
		Next
		aMsgPre := U_RetMemu(SB1->B1_COD,SBM->BM_XMSGPER)
		MSCBSAY( 055,150,"Precauções ","B",cFonte    ,"17")
		ntam := 065
		For n := 1 to len(aMsgPre)
			MSCBSAY( 035,ntam,aMsgPre[n],"B",cFonte    ,"15")
			nTam += 005
		Next
		// informações do produto
		MSCBSAY( 086,088,MV_PAR03+"KG","B",cFonte                                     ,"26")
		MSCBSAY( 086,068,"2023","B",cFonte                                           ,"26")
		//MSCBSAY( 086,085,cValtoChar(DateDiffDay(SB8->B8_DATA,SB8->B8_DTVALID))+" Dias","B",cFonte,"10")
		MSCBSAY( 086,043,"250 Dias","B",cFonte,"26")
		MSCBSAY( 086,028,SBM->BM_XNUMONU+"2582","B",cFonte                                                          ,"26")
		MSCBSAY( 086,008,MV_PAR02,"B",cFonte                                                     ,"26")

		MSCBEND() //Finaliza impressão 1º pag.

		MSCBCLOSEPRINTER()//Fecha Conexão

	Next
	SB1->(DbCloseArea())
	//(cAliaSB8)->(DbCloseArea())
	(cAliaSBM)->(DbCloseArea())
	RestArea(aArea)

Return &(cReturn)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MITO44   ºAutor   ³Michel Rocha       º Data ³  18/09/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Impressão de Etiquetas Etiq125x100                        º±±
±±º          ³  Impressão do relatorio Etiq125x100 com tela para informar º±±
±±º          ³  Armazem,Lote e Peso Liquido                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grupo Total                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Etiq125x100(cProduto,nQtde)
	Local n 	  := 0
	Local ntam 	  := 0
	Local nX 	  := 0
	Local cReturn := "u_MITO44()"
	Local aArea   := GetArea()
	//Local cAliaSB8 := GetNextAlias()
	Local cAliaSBM := GetNextAlias()
	Local aMsgPre := {}
	Local aPergs := {}
	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))
	If !SB1->(DbSeek(xfilial('SB1')+Padr(cProduto,TamSx3("B1_COD")[1])))
		MsgAlert("Produto não existe no cadastro, informe um código válido!")
		Return &(cReturn)
	EndIf
	aAdd(aPergs, {1, "Armazem do produto: "  , space(tamSx3("B8_Local")[1])   ,"", ".T.", "", ".T.", 80,  .T.})// MV_PAR01
	aAdd(aPergs, {1, "Informe o lote do produto: " ,space(tamSx3("B8_LOTECTL")[1])  ,"", ".T.", "", ".T.", 80,  .F.})// MV_PAR02
	aAdd(aPergs, {1, "Informe o peso liquido: " ,space(3)  ,"", ".T.", "", ".T.", 80,  .F.})// MV_PAR03
	If ! ParamBox(aPergs, "Informe os parâmetros")
		Return &(cReturn)
	EndIf

	//BeginSql alias cAliaSb8
	//	Select * from %table:SB8%
	//	where b8_produto = %Exp:cProduto%
	//	AND b8_local = %Exp:MV_PAR01%
	//	AND B8_LOTECTL = %Exp:MV_PAR02%
	//EndSql

	BeginSql alias cAliaSBM
		Select * from %table:SBM%
		where BM_GRUPO = %Exp:SB1->B1_GRUPO%
	EndSql

	//SB8->(DbSetOrder(1))
	//If !DbSeek(xFilial('SB8')+cAliaSB8->(b8_produto+b8_local+B8_LOTECTL))
	//	MsgAlert("Produto não existe no cadastro, informe um código válido!")
	//	Return &(cReturn)
	//EndIf

	For nX := 1 to nQtde

		MSCBPrinter("ZEBRA","LPT1",,,.F.,,,,,,.T.)

		cFonte :="B"
		cTamX  :="20"
		cTamY  :="25"
		cDesc := AllTrim(SB1->B1_DESC)
		// MSCBLOADGRF("LogoEtq.GRF") //Carrega Logo
		MSCBCHKSTATUS(.F.) //Desativa a checagem do Status.

		MSCBBEGIN(1,6) //Inicia impressão 1º Eti	02queta

		//Codigo do Produto
		MSCBBOX(04,51,51,71)
		//If len(cDesc) > 27
			MSCBSAY(010,064,SubStr(cDesc,1,18),"I",cFonte    ,"25")
			MSCBSAY(010,057,SubStr(cDesc,19,17),"I",cFonte    ,"25")
		//Else
		//	MSCBSAY(062,015,cDesc,"I",cFonte    ,"30")
		//EndIf
		
		aMsgPre := U_RetMemu(SB1->B1_COD,SBM->BM_XMSGPER)
		ntam := 30
		For n := 1 to len(aMsgPre)
		MSCBSAY(52,nTam,aMsgPre[n],   "I"      ,cFonte    ,cTamX)
		nTam -= 005
		Next		
		MSCBSAY( 69,25,"Lote: "+MV_PAR02,   "I"      ,cFonte    ,cTamX)
		//MSCBSAY( 010,nTam+005,"Data De Fabricação: "+DtoC(SB8->B8_DATA),   "I"      ,cFonte    ,cTamX)
		MSCBSAY( 25,20,"Data De Fabricação: "+DtoC(DDATABASE),   "I"      ,cFonte    ,cTamX)
		MSCBSAY( 35,15,"Prazo De Validade: 01 ano",   "I"      ,cFonte    ,cTamX)
		//MSCBSAY( 010,nTam+010,"Prazo De Validade: "+cValtoChar(DateDiffYear(SB8->B8_DATA,SB8->B8_DTVALID))+IIF(DateDiffYear(SB8->B8_DATA,SB8->B8_DTVALID)>1," anos"," ano"),   "I"      ,cFonte    ,cTamX)
		MSCBSAY( 51,10,"Peso Liquido "+MV_PAR03+"kg","I",cFonte                                                ,cTamX)

		MSCBEND() //Finaliza impressão 1º pag.

		MSCBCLOSEPRINTER()//Fecha Conexã

	Next
	SB1->(DbCloseArea())
	//(cAliaSB8)->(DbCloseArea())
	(cAliaSBM)->(DbCloseArea())
	RestArea(aArea)

Return &(cReturn)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MITO44   ºAutor   ³Michel Rocha       º Data ³  18/09/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Impressão de Etiquetas Et25x100_2                         º±±
±±º          ³  Impressão do relatorio Et25x100_2 com tela para informar  º±±
±±º          ³  Armazem,Lote e Peso Liquido                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grupo Total                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Et25x100_2(cProduto,nQtde)

	Local nX 	  := 0
	Local n 	  := 0
	Local cReturn := "u_MITO44()"
	Local aArea   := GetArea()
	Local cAliaSB8 := GetNextAlias()
	Local cAliaSBM := GetNextAlias()
	Local aMsgMan := {}
	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))
	If !DbSeek(cFilant+cProduto)
		MsgAlert("Produto não existe no cadastro, informe um código válido!")
		Return &(cReturn)
	EndIf
	aAdd(aPergs, {1, "Armazem do produto: "        ,  ""   ,"", ".T.", "", ".T.", 80,  .T.})// MV_PAR01
	aAdd(aPergs, {1, "Informe o lote do produto:" ,1   ,"", ".T.", "", ".T.", 80,  .F.})// MV_PAR02
	aAdd(aPergs, {1, "Peso Líquido :"    ,1   ,"", "Positivo()", "", ".T.", 80,  .F.})// MV_PAR03
	If ! ParamBox(aPergs, "Informe os parâmetros")
		Return &(cReturn)
	EndIf

	BeginSql alias cAliaSb8
		Select * from %table:SB8%
		where b8_produto = %Exp:cProduto%
		AND b8_local = %Exp:MV_PAR01%
		AND B8_LOTECTL = %Exp:MV_PAR02%
	EndSql
	BeginSql alias cAliaSBM
		Select * from %table:SBM%
		where BM_GRUPO = %Exp:SB1->B1_GRUPO%
	EndSql

	SB8->(DbSetOrder(1))
	If !DbSeek(cFilant+cAliaSB8->(b8_produto+b8_local+B8_LOTECTL))
		MsgAlert("Produto não  no cadastro, informe um código válido!")
		Return &(cReturn)
	EndIf
	For nX := 1 to nQtde

		MSCBPrinter("ZEBRA","LPT1",,,.F.,,,,,,.T.)

		cFonte :="B"
		cTamX  :="10"
		cTamY  :="25"
		cDesc := AllTrim(posicione("SB1",1,xFilial('SB1')+SB8->B8_PRODUTO,"B1_DESC"))
		MSCBCHKSTATUS(.F.) //Desativa a checagem do Status.

		MSCBBEGIN(1,6) //Inicia impressão 1º Eti	02queta
		//Empresa
		MSCBSAY( 010,005,SM0->M0_NOME,"B",cFonte                                                ,"30")
		MSCBSAY( 010,015,SM0->M0_ENDENT,"B",cFonte                                                ,cTamX)
		MSCBSAY( 010,020,"Fone: "+SM0->M0_TEL,"B",cFonte                                                ,cTamX)
		MSCBSAY( 010,025,"Fax: "+SM0->M0_FAX,"B",cFonte                                                ,cTamX)
		MSCBSAY( 010,030,"Cnpj: "+SM0->M0_CGC,"B",cFonte                                                ,cTamX)
		MSCBSAY( 010,035,"Email: silicato@pernambucoquimica.com.br","B",cFonte                                                ,cTamX)

		//Codigo do Produto
		MSCBBOX(70,05,115,25)
		If len(cDesc) > 22
			MSCBSAY(072,010,SubStr(cDesc,1,22),"B",cFonte    ,"30")
			MSCBSAY(072,020,SubStr(cDesc,22,len(cDesc)),"B",cFonte    ,"30")
		Else
			MSCBSAY(072,015,cDesc,"B",cFonte    ,"30")
		EndIf

		MSCBSAY(070,30,"Lote: "+MV_PAR02,   "B"      ,cFonte    ,cTamX)
		MSCBSAY(070,35,"Data De Fabricação: "+DtoC(SB8->B8_DATA),   "B"      ,cFonte    ,cTamX)
		MSCBSAY(070,40,"Prazo De Validade: "+cValtoChar(DateDiffYear(SB8->B8_DATA,SB8->B8_DTVALID))+IIF(DateDiffYear(SB8->B8_DATA,SB8->B8_DTVALID)>1," anos"," ano"),   "B"      ,cFonte    ,cTamX)
		MSCBSAY(070,45,"Peso Liquido"+cValToChar(MV_PAR03)+"kg","B",cFonte                                                ,cTamX)
		
		ntam := 045
		aMsgMan := RetMemu(SB1->B1_COD,"SBM->BM_XMSGMAN")
		MSCBSAY( 010,ntam,"Peso Liquido"+cValToChar(MV_PAR03)+"kg","B",cFonte                                                ,cTamX)
		For n := 1 to len(aMsgMan)
		MSCBSAY( 010,nTam,aMsgMan[n],   "B"      ,cFonte    ,cTamX)
		nTam += 005
		Next	

		MSCBEND() //Finaliza impressão 1º pag.

		MSCBCLOSEPRINTER()//Fecha Conexão

	Next
	SB1->(DbCloseArea())
	(cAliaSB8)->(DbCloseArea())
	(cAliaSBM)->(DbCloseArea())
	RestArea(aArea)

Return &(cReturn)

User function RetMemu(cProd,cCampo)
	local aTexto := {}
	local cSypalias := GetNextAlias()
	DbSelectArea('SB1')
	Sb1->(DBSetOrder(1))
	Sb1->(DbSeek(Xfilial('SB1')+cProd))
	Beginsql alias cSypalias
    SELECT
        YP_TEXTO 
    FROM
        SYP010 SYP
    WHERE
        YP_CHAVE = %Exp:cCampo%
        AND Yp_FILIAL = %Exp:xFilial('SYP')%
        AND SYP.D_E_L_E_T_ = ' '
	EndSql
	While (cSypalias)->(!EOF())
		Aadd(aTexto,(cSypalias)->(YP_TEXTO))
		(cSypalias)->(DBSKIP())
	End
Return aTexto
/*
static function SyllabDiv(cOrign,aSylls)

	local cDitong := "AI.AO.AU.UA.EI.EU.IO.OE"
	local cTriton := "AIA.UAI"
	local cIndiv  := "CH.LH.NH.PN"
	local lDiv    :=  .F.
	local cTail
	local i
	local c
	local k
	DEFAULT aSylls  :=  {}
	priva cSyll           // sílaba já separada
	priva cWord := cOrign // a palavra original
	priva _g_SignSet := "!"+Chr(34)+"#$%&'()*+,-./:;<=>?@[\]^_`{|}~"
	priva _g_VogsSet := "AEIOU"
	priva _g_ConsSet := "BCDFGHJKLMNPQRSTVWXYZ"

	if Len(cWord := AllTrim(cWord)) <= 3
		return {cWord}
	end

	// Padronizar a palavra, convertendo-a para maiúsculas,
	// removendo acentos e caracteres especiais
	cTail := ""
	for i := 1 to Len(cWord)
		if SubStr(cWord,i,1) $ StrTran(_g_SignSet,"-")+" "
			cTail := SubStr(cWord,i)
			cWord := Left(cWord,i-1)
			exit
		end
	next
	cWord := AllTrim(Upper(cWord))
	cSyll := ""

	while Len(cWord) > 0
		Attach()
		*
		if     Len(cWord) = 0
			lDiv := .T.
			*
		elseif Right(cSyll,1) $ _g_VogsSet
			if Left(cWord,1) $ _g_ConsSet
				lDiv := .T.
				if Len(cWord)=1
					Attach()
				else
					if At(SubStr(cWord,1,2),cIndiv) = 0
						if !(Left(cWord,1) $ "BCDFGPTV" .and. SubStr(cWord,2,1) $ "LR"       ) .and.;
								((Left(cWord,1) $ "LMNRS"    .and. SubStr(cWord,2,1) $ _g_ConsSet )  .or.;
								SubStr(cWord,2,1) $ _g_ConsSet)
							Attach()
						end
					end
				end
				if Left(cWord,1) = "S" .and. SubStr(cWord,2,1) $ _g_ConsSet
					Attach()
				end
			else
				if At(Right(cSyll,1)+Left(cWord,1),cDitong)=0 .and. At(Right(cSyll,1)+Left(cWord,2),cTriton)=0 .and.;
						Right(cSyll,1) == Left(cWord,1)
					lDiv := .T.
				end
			end
			*
		elseif Right(cSyll,1) $ _g_ConsSet
			if Len(aSylls)=0 .and. Len(cSyll)=1 .and. Left(cWord,1) $ _g_ConsSet
				Attach()
			end
		end

		// Formação definitiva da sílaba
		if lDiv
			lDiv := .F.
			AAdd(aSylls,cSyll)
			cSyll := ""
		end
	end

	// Recomposição da string, para recuperar a caixa, a
	// acentuação original e os sinais suprimidos
	if Len(aSylls) > 0
		aSylls[Len(aSylls)] += cTail
		*
		c := 0
		for i := 1 to Len(aSylls)
			for k := 1 to Len(aSylls[i])
				c ++
				aSylls[i] := Stuff(aSylls[i],k,1,SubStr(cOrign,c,1))
			next
		next
	else
		AAdd(aSylls,cTail)
	end
return aSylls

	//**********************************************************
static function Attach()
	cSyll += Left(cWord,1)   // a sílaba já formada
	cWord := SubStr(cWord,2) // o resto da palavra
return nil
*/
