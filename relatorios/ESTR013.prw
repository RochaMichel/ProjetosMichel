#Include "totvs.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#Include 'TopConn.ch'
#INCLUDE "PARMTYPE.CH"
#Include "TbiConn.Ch"
#Include "Colors.ch"
#Include "vkey.ch"
#include "rwmake.ch"
#include "Ap5Mail.ch"
#DEFINE LOC_ENTR01  "ELIZABETH PORCELANATO LTDA.(UNIDADE II)"
#DEFINE LOC_ENTR02  "RUA CAPITÃO JOSE RODRIGUES DO Ó, 870"
#DEFINE LOC_ENTR03  "DISTRITO INDUSTRIAL - CEP: 58082-060"
#DEFINE LOC_ENTR04  "CNPJ: 02.357.659/0002-06"
#DEFINE LOC_ENTR05  "IE: 16.290.493-8"
#DEFINE LOC_ENTR06  "TEL: (83) 2107-2000  FAX: (83) 3233-2791"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PedComprGr³ Autor ³ Walter Matsui         ³ Data ³ 10/04/18  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprime Pedido de Compras.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Elizabeth                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

//alteração 19/01/2022 - Alessandro. Alterado a linha 353 para pegar o campo correto da aprovação da C7 do pedido.

/*/
User Function ESTR013()

	Local aArea:=GetArea()
	Local _x,j := 1

	Private oDlg1
	Private oPrinter  // Objeto de Impressao

	Private oFont6		:= TFont():New('Calibri (Corpo)',06,06,,.F.,,,,.T.,.F.,.F.)
	Private oFont6N		:= TFont():New('Calibri (Corpo)',06,06,,.T.,,,,.T.,.F.,.F.)
	Private oFont7N		:= TFont():New('Calibri (Corpo)',07,07,,.T.,,,,.T.,.F.,.F.)
	Private oFont8		:= TFont():New('Calibri (Corpo)',08,08,,.F.,,,,.T.,.F.,.F.)
	Private oFont8N		:= TFont():New('Calibri (Corpo)',08,08,,.T.,,,,.T.,.F.,.F.)
	Private oFont8NX	:= TFont():New('Calibri (Corpo)',08,08.5,,.T.,,,,.T.,.F.,.F.)
	Private oFont9 		:= TFont():New('Calibri (Corpo)',09,09,,.F.,,,,.T.,.F.,.F.)
	Private oFont9N		:= TFont():New('Calibri (Corpo)',09,09,,.T.,,,,.T.,.F.,.F.)
	Private oFont10		:= TFont():New('Calibri (Corpo)',10,10,,.F.,,,,.T.,.F.,.F.)
	Private oFont10N	:= TFont():New('Calibri (Corpo)',10,10,,.T.,,,,.T.,.F.,.F.)
	Private oFont11		:= TFont():New('Calibri (Corpo)',11,11,,.F.,,,,.T.,.F.,.F.)
	Private oFont11N	:= TFont():New('Calibri (Corpo)',11,11,,.T.,,,,.T.,.F.,.F.)
	Private oFont11NS	:= TFont():New('Calibri (Corpo)',11,11,,.T.,,,,.T.,.T.,.F.)
	Private oFont12		:= TFont():New('Calibri (Corpo)',12,12,,.F.,,,,.T.,.F.,.F.)
	Private oFont12N	:= TFont():New('Calibri (Corpo)',12,12,,.T.,,,,.T.,.F.,.F.)
	Private oFont15		:= TFont():New('Calibri (Corpo)',15,15,,.F.,,,,.T.,.F.,.F.)
	Private oFont15N	:= TFont():New("Calibri (Corpo)",15,15,,.T.,,,,.T.,.F.)
	Private oFont18N	:= TFont():New("Calibri (Corpo)",15,15,,.T.,,,,.T.,.F.)
	Private oFont20N	:= TFont():New("Calibri (Corpo)",20,20,,.T.,,,,.T.,.F.)
	Private oFont25N	:= TFont():New("Times New Roman",25,25,,.T.,,,,.T.,.F.)
	Private oFont36N	:= TFont():New("Times New Roman",36,36,,.T.,,,,.T.,.F.)
	Private nPage       := 0
	Private nSubtotal   := 0
	Private nICMS       := 0
	Private nISS        := 0
	Private nIPI        := 0
	Private nTOTAL      := 0
	Private nDescB		:= 0
	Private sRef        := 0


	DEFINE FONT oFont1	NAME "Arial" Size 10,13

	cPerg :="PEDCOMPRGR"
	cPerg := Padr(cPerg, 10)

	ValidPerg()

	For _x := 1 to Len(ProcName())

		If ProcName(_x) == "MATA121"
			SX1->(dbSetOrder(1))
			SX1->(dbSeek(cPerg+"01"))
			If !SX1->(Eof())
				Reclock("SX1",.F.)
				//P3 Tecnologia - Code Analisys 11/07/2020
				For j := 1 to FCount()
					If FieldName(j)=="X1_CNT01"
						FieldPut(j, SC7->C7_NUM )
					Endif
				Next
				MV_PAR01 := SC7->C7_NUM
				MSUnlock()
			Endif
			SX1->(dbSeek(cPerg+"02"))
			If !SX1->(Eof())
				Reclock("SX1",.F.)
				//P3 Tecnologia - Code Analisys 11/07/2020
				For j := 1 to FCount()
					If FieldName(j)=="X1_CNT01"
						FieldPut(j, SC7->C7_NUM )
					Endif
				Next
				MV_PAR02 := SC7->C7_NUM
				MSUnlock()
			Endif
		Endif
	Next _x

	if !Pergunte(cPerg,.T.)
		Return
	EndIf

	DEFINE MSDIALOG oDlg1 TITLE "Impressao de Pedido de Compras" From 000,000 To 300,590 OF oMainWnd PIXEL
	@ 015,007 TO 122 ,290 LABEL " Parametros " OF oDlg1  PIXEL
	@ 35,15 SAY "Este programa imprime o Pedido de Compras                  "  Size 250,010 COLOR CLR_BLACK PIXEL OF oDlg1 FONT oFont1
	@ 45,15 SAY "                                                          "  Size 250,010 COLOR CLR_BLACK PIXEL OF oDlg1 FONT oFont1
	@ 126,110 BUTTON oButton1 PROMPT "Impressão     " SIZE 59, 012 OF oDlg1 PIXEL ACTION MsAguarde({|| PrcImpPed() },"Mensagem","Preparando Pedido(s) e Gerando arquivo temporário")
	@ 126,170 BUTTON oButton2 PROMPT "Parametros    " SIZE 59, 012 OF oDlg1 PIXEL ACTION Pergunte(cPerg,.T.)
	@ 126,230 BUTTON oButton3 PROMPT "Finalizar     " SIZE 59, 012 OF oDlg1 PIXEL ACTION (oDlg1:End())
	ACTIVATE DIALOG oDlg1 Centered

	RestArea(aArea)

Return


/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºFuncao    ³VALIDPERG º Autor ³ Rdmake             º Data ³  21/08/01   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescricao ³ Verifica a existencia das perguntas criando-as caso seja   º±±
	±±º          ³ necessario (caso nao existam).                             º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ Programa principal                                         º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ValidPerg

	Local _sAlias := Alias()
	Local aRegs := {}
	Local i,j
	dbSelectArea("SX1")
	dbSetOrder(1)
	aAdd(aRegs,{cPerg,"01","Do Pedido de Compras          ","","","mv_ch1","C",06,00,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SC7","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate o Pedido de Compras       ","","","mv_ch2","C",06,00,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SC7","","","","",""})
	aAdd(aRegs,{cPerg,"03","Da Emissao                    ","","","mv_ch3","D",08,00,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
	aAdd(aRegs,{cPerg,"04","Ate a Emissao                 ","","","mv_ch4","D",08,00,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","   ","","","","",""})

	aAdd(aRegs,{cPerg,"05","Da Filial                     ","","","mv_ch5","C",06,00,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","XM0","","","","",""})
	aAdd(aRegs,{cPerg,"06","Ate a Filial                  ","","","mv_ch6","C",06,00,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","XM0","","","","",""})

	aAdd(aRegs,{cPerg,"07","Apenas Pedidos Liberados?     ","","","mv_ch7","N",01,00,0,"C","","mv_par07","Sim","Si","Yes","","","Nao","No","No","","","","","","","","","","","","","","","","","   ","","","","",""})
	aAdd(aRegs,{cPerg,"08","Considera Parametros Abaixo?  ","","","mv_ch8","N",01,00,0,"C","","mv_par08","Sim","Si","Yes","","","Nao","No","No","","","","","","","","","","","","","","","","","   ","","","","",""})
	aAdd(aRegs,{cPerg,"09","Data da Aprovacao             ","","","mv_ch9","D",08,00,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","   ","","","","",""})
	aAdd(aRegs,{cPerg,"10","Codigo do Comprador           ","","","mv_cha","C",03,00,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","SY1","","","","",""})
	aAdd(aRegs,{cPerg,"11","Codigo do Usuario             ","","","mv_chb","C",06,00,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","USR","","","","",""})

	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
	dbSelectArea(_sAlias)
Return


/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ PrcImpPed ³ Autor ³ Walter Matsui        ³ Data ³ 10/04/18  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Imprime Pedido de Compras                                   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ Nenhum                                                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrcImpPed()

	Local aArea      :=GetArea()
	Local nRet
	Local cUltCodPrd := ""
	Local cUltLocali := ""
	Local cPedLib    := ""
	Local dUltAprv   := CTOD("  /  /  ")

	Private nMenorPrc  := 0
	Private nLin     := 035
	Private nLinBar  := 3.9
	Private xcPath   :="\SPOOL\"

	Private lAdjustToLegacy := .T.
	Private lDisableSetup  	:= .F.

	if !ExistDir(xcPath)
		nRet := makeDir( xcPath )
		if nRet != 0
			Aviso("Arquivo","Não foi possível criar o diretório - "+xcPath,{"OK"},3)
			return
		endif
	endif

	dbSelectArea("SC7")
	dbSetOrder(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta query                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par07 == 1   // Apenas Pedidos com Todos os Itens Liberados para Faturamento
		_cQuery    := "SELECT C7_FILIAL,C7_NUM,A2_COD,A2_LOJA,A2_NOME,C7_EMISSAO,B1_XREF1,C7_CONAPRO,C7_COMPRA,C7_USER,C7_XDHAPRO, C7_COND,"
		_cQuery    += "Sum(C7_TOTAL) AS C7_TOTAL ,"
		_cQuery    += "Sum(C7_QUANT) AS C7_QUANT ,"
		_cQuery    += "Sum(C7_QUJE) AS C7_QUJE ,"
		_cQuery    += "SUM(C7_QUJE*C7_PRECO) AS VLRECEBIDO ,"
		_cQuery    += "SUM(C7_QUANT-C7_QUJE) AS QTPENDENTE ,"
		_cQuery    += "SUM((C7_QUANT-C7_QUJE)*C7_PRECO) AS VLPENDENTE"
		_cQuery    += "FROM "+RetSQLName("SC7")+" "
		_cQuery    += "INNER JOIN "+RetSQLName("SB1")+" ON  B1_FILIAL='"+xFilial("SB1")+"' "
		_cQuery    += "AND B1_COD=C7_PRODUTO "
		_cQuery    += "AND "+RetSQLName("SB1")+".D_E_L_E_T_=' ' "
		_cQuery    += "INNER JOIN "+RetSQLName("SA2")+" ON  A2_FILIAL='"+xFilial("SA2")+"' "
		_cQuery    += "AND A2_COD=C7_FORNECE "
		_cQuery    += "AND A2_LOJA=C7_LOJA "
		_cQuery    += "AND "+RetSQLName("SA2")+".D_E_L_E_T_=' ' "
		_cQuery    += "AND C7_FILIAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
		_cQuery    += "AND C7_NUM BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
		_cQuery    += "AND C7_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
		_cQuery    += "AND "+RetSQLName("SC7")+".D_E_L_E_T_=' ' "
		_cQuery    += "AND C7_CONAPRO <> 'R' "
		_cQuery    += "AND C7_ENCER   <> 'E' "
		_cQuery    += "GROUP BY C7_FILIAL, C7_NUM,A2_COD ,A2_LOJA ,A2_NOME ,C7_EMISSAO ,B1_XREF1, C7_CONAPRO, C7_COMPRA, C7_USER,C7_XDHAPRO, C7_COND "
		_cQuery    += "ORDER BY C7_FILIAL, C7_NUM,A2_COD ,A2_LOJA ,A2_NOME ,C7_EMISSAO ,B1_XREF1, C7_CONAPRO, C7_COMPRA, C7_USER,C7_XDHAPRO , C7_COND"

	Else

		_cQuery    := "SELECT C7_FILIAL,C7_NUM,A2_COD,A2_LOJA,A2_NOME,C7_EMISSAO,B1_XREF1,C7_XDHAPRO, C7_COND, "
"
		_cQuery    += "Sum(C7_TOTAL) AS C7_TOTAL ,"
		_cQuery    += "Sum(C7_QUANT) AS C7_QUANT ,"
		_cQuery    += "Sum(C7_QUJE) AS C7_QUJE ,"
		_cQuery    += "SUM(C7_QUJE*C7_PRECO) AS VLRECEBIDO ,"
		_cQuery    += "SUM(C7_QUANT-C7_QUJE) AS QTPENDENTE ,"
		_cQuery    += "SUM((C7_QUANT-C7_QUJE)*C7_PRECO) AS VLPENDENTE"
		_cQuery    += "FROM "+RetSQLName("SC7")+" "
		_cQuery    += "INNER JOIN "+RetSQLName("SB1")+" ON  B1_FILIAL='"+xFilial("SB1")+"' "
		_cQuery    += "AND B1_COD=C7_PRODUTO "
		_cQuery    += "AND "+RetSQLName("SB1")+".D_E_L_E_T_=' ' "
		_cQuery    += "INNER JOIN "+RetSQLName("SA2")+" ON  A2_FILIAL='"+xFilial("SA2")+"' "
		_cQuery    += "AND A2_COD=C7_FORNECE "
		_cQuery    += "AND A2_LOJA=C7_LOJA "
		_cQuery    += "AND "+RetSQLName("SA2")+".D_E_L_E_T_=' ' "
		_cQuery    += "AND C7_FILIAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
		_cQuery    += "AND C7_NUM BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
		_cQuery    += "AND C7_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
		_cQuery    += "AND "+RetSQLName("SC7")+".D_E_L_E_T_=' ' "
		_cQuery    += "AND C7_CONAPRO <> 'R' "
		_cQuery    += "GROUP BY C7_FILIAL,C7_NUM,A2_COD ,A2_LOJA ,A2_NOME ,C7_EMISSAO ,B1_XREF1,C7_XDHAPRO, C7_COND "
		_cQuery    += "ORDER BY C7_FILIAL,C7_NUM,A2_COD ,A2_LOJA ,A2_NOME ,C7_EMISSAO ,B1_XREF1,C7_XDHAPRO , C7_COND"
	Endif

	_cQuery := ChangeQuery(_cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery),"TMP",.F.,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta estrutura da tabela temporaria                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCpoTRB := {}
	aAdd(aCpoTRB, {"M_OK"      ,"C",02,0})
	aAdd(aCpoTRB, {"M_FILIAL"  ,"C",06,0})
	aAdd(aCpoTRB, {"M_PEDIDO"  ,"C",06,0})
	aAdd(aCpoTRB, {"M_FORNECE" ,"C",06,0})
	aAdd(aCpoTRB, {"M_LOJA"    ,"C",04,0})
	aAdd(aCpoTRB, {"M_NOME"    ,"C",40,0})
	aAdd(aCpoTRB, {"M_EMISSAO" ,"D",08,0})
	aAdd(aCpoTRB, {"M_QUANT"   ,"N",13,2})
	aAdd(aCpoTRB, {"M_VL_TOTAL","N",13,2})
	aAdd(aCpoTRB, {"M_VL_RECEB","N",13,2})
	aAdd(aCpoTRB, {"M_QT_PENDE","N",13,2})
	aAdd(aCpoTRB, {"M_VL_PENDE","N",13,2})
	aAdd(aCpoTRB, {"M_CONAPRO" ,"C",01,0})
	aAdd(aCpoTRB, {"M_XREF1"   ,"C",25,0})
	aAdd(aCpoTRB, {"M_DTAPROV" ,"C",10,0})
	aAdd(aCpoTRB, {"M_COMPRA"  ,"C",03,0})
	aAdd(aCpoTRB, {"M_USER"    ,"C",06,0})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a tabela temporaria                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oTRB := FWTemporaryTable():New("TRB",aCpoTRB)
	oTRB:AddIndex("01", {"M_PEDIDO"} )
	oTRB:Create()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta estrutura do Mark browse                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCpoTRB := {}
	aAdd(aCpoTRB, {"M_OK"        ,""," "            ,"@!"})
	aAdd(aCpoTRB, {"M_FILIAL"    ,"","Filial"       ,"@!"})
	aAdd(aCpoTRB, {"M_PEDIDO"    ,"","Pedido"       ,"@!"})
	aAdd(aCpoTRB, {"M_FORNECE"   ,"","Fornecedor"   ,"@!"})
	aAdd(aCpoTRB, {"M_LOJA"      ,"","Loja"         ,"@!"})
	aAdd(aCpoTRB, {"M_NOME"      ,"","Razão Social" ,"@!"})
	aAdd(aCpoTRB, {"M_EMISSAO"   ,"","Emissão"      ,"@D"})
	aAdd(aCpoTRB, {"M_QUANT"     ,"","Quant."       ,"@E 999,999,999.99"})
	aAdd(aCpoTRB, {"M_VL_TOTAL"  ,"","Vl.Total"     ,"@E 999,999,999.99"})
	aAdd(aCpoTRB, {"M_VL_RECEB"  ,"","Vl.Receb."    ,"@E 999,999,999.99"})
	aAdd(aCpoTRB, {"M_QT_PENDE"  ,"","Qt.Pendente"  ,"@E 999,999,999.99"})
	aAdd(aCpoTRB, {"M_CONAPRO"   ,"","Liberacao"    ,"@!"})
	aAdd(aCpoTRB, {"M_DTAPROV"   ,"","Dt Aprovacao" ,"@C"})
	aAdd(aCpoTRB, {"M_COMPRA"    ,"","Cod Comprador","@!"})
	aAdd(aCpoTRB, {"M_USER"      ,"","Cod Usuario"  ,"@!"})
	aAdd(aCpoTRB, {"M_XREF1"     ,"","Referencia 1" ,"@!"})

	nTotReg    := 0
	cUltCodPrd := ""
	cUltLocali := ""

// Alteração feita por Sérgio Arruda conforme chamado 211590 visando que APENAS pedidos com TODOS os itens liberados
// possam ser enviados via e-mail aos fornecedores.

	dbSelectArea("TMP")
	TMP->( DbGoTop() )

	While !TMP->(Eof())

		If mv_par07 == 1     						// Apenas Pedidos Liberados = Sim
			cPedLib := TMP->C7_NUM
			If TMP->C7_CONAPRO == 'B'
				While TMP->C7_NUM == cPedLib .and. !TMP->(Eof())
					TMP->(dbSkip())
				EndDo
				Loop
			Endif

			//dUltAprv := CTOD(mUltAprv(TMP->C7_NUM))
			dUltAprv := CTOD(SUBSTR(TMP->C7_XDHAPRO,10,10))  

			If mv_par08 == 1							// Considera Parametros Abaixo = Sim


				If mv_par09 <> dUltAprv				// Filtra Data da Aprovacao
					While TMP->C7_NUM == cPedLib .and. !TMP->(Eof()) 
						TMP->(dbSkip())
					EndDo
					Loop
				Endif
				If mv_par10 <> TMP->C7_COMPRA			// Filtra Codigo do Comprador
					While TMP->C7_NUM == cPedLib .and. !TMP->(Eof())
						TMP->(dbSkip())
					EndDo
					Loop
				Endif
				If mv_par11 <> TMP->C7_USER  		// Filtra Codigo do Usuario
					While TMP->C7_NUM == cPedLib .and. !TMP->(Eof())
						TMP->(dbSkip())
					EndDo
					Loop
				Endif

			Endif



			If !Empty(TMP->C7_NUM)
				Reclock("TRB",.T.)
				Replace TRB->M_OK		 	with Space(02)
				Replace TRB->M_FILIAL    	with TMP->C7_FILIAL
				Replace TRB->M_PEDIDO    	with TMP->C7_NUM
				Replace TRB->M_FORNECE   	with TMP->A2_COD
				Replace TRB->M_LOJA      	with TMP->A2_LOJA
				Replace TRB->M_NOME      	with TMP->A2_NOME
				Replace TRB->M_EMISSAO   	with STOD(TMP->C7_EMISSAO)
				Replace TRB->M_QUANT     	with TMP->C7_QUANT
				Replace TRB->M_VL_TOTAL  	with TMP->C7_TOTAL
				Replace TRB->M_VL_RECEB  	with TMP->VLRECEBIDO
				Replace TRB->M_QT_PENDE  	with TMP->QTPENDENTE
				Replace TRB->M_QT_PENDE  	with TMP->QTPENDENTE
				Replace TRB->M_CONAPRO		with TMP->C7_CONAPRO
				//Replace TRB->M_DTAPROV		with dUltAprv          
				Replace TRB->M_DTAPROV		with SUBSTR(TMP->C7_XDHAPRO,10,10)
				Replace TRB->M_COMPRA		with TMP->C7_COMPRA
				Replace TRB->M_USER			with TMP->C7_USER
				Replace TRB->M_XREF1		with TMP->B1_XREF1


				TRB->(MsUnlock())

				nTotReg++
			Endif

			TMP->(dbSkip())
			

		Else

			Reclock("TRB",.T.)
			Replace TRB->M_OK			with Space(02)
			Replace TRB->M_FILIAL    	with TMP->C7_FILIAL
			Replace TRB->M_PEDIDO    	with TMP->C7_NUM
			Replace TRB->M_FORNECE   	with TMP->A2_COD
			Replace TRB->M_LOJA      	with TMP->A2_LOJA
			Replace TRB->M_NOME      	with TMP->A2_NOME
			Replace TRB->M_EMISSAO   	with STOD(TMP->C7_EMISSAO)
			Replace TRB->M_DTAPROV		with SUBSTR(TMP->C7_XDHAPRO,10,10)
			Replace TRB->M_QUANT     	with TMP->C7_QUANT
			Replace TRB->M_VL_TOTAL  	with TMP->C7_TOTAL
			Replace TRB->M_VL_RECEB  	with TMP->VLRECEBIDO
			Replace TRB->M_QT_PENDE  	with TMP->QTPENDENTE
			Replace TRB->M_XREF1		with TMP->B1_XREF1

			TRB->(MsUnlock())


			nTotReg++

			TMP->(dbSkip())
		Endif
	Enddo
	TMP->(dbCloseArea())

	// Dados da Markbrowse
	aSize    := MsAdvSize()
	aSize[1] := 1
	aObjects := {}
	aAdd(aObjects, {100, 100,.T.,.T.}) // Dados da Enchoice
	aAdd(aObjects, {200,200,.T.,.T.})  // Dados da getdados

	aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	aPosObj  := MsObjSize( aInfo, aObjects,.T.)
	aRotina  := MenuDef()
	aTpPesq  := {"M_PEDIDO"}
	cTpPesq  := Space(20)
	cPesq    := Space(100)
	lInverte := .F.
	cMark    := GetMark()
	Private aCores := ''

	Define MsDialog oDlg Title "Selecione os Pedidos a serem Impressos - Total: "+Str(nTotReg) From 0,0 to 350,800 COLORS 0,16777215 Pixel
	oDlg:lMaximized := .T.

	@ 08,(aPosObj[2,4] - 230) MsComboBox oTpPesq var cTpPesq Items aTpPesq Size 80,10 Of oDlg Pixel
	@ 08,(aPosObj[2,4] - 150) MsGet cPesq Size 100,09 Of oDlg Pixel
	@ 08,(aPosObj[2,4] - 050) Button "Pesquisar" Size 40,10 Of oDlg Pixel

	oMarkCtr := MSSelect():New("TRB","M_OK","",aCpoTRB,@lInverte,@cMarK, {(aPosObj[1,1] - 10),aPosObj[2,2],(aPosObj[2,3] - 25),aPosObj[2,4]},,,oDlg,,aCores)
	oMarkCtr:bMark := {|| ImpEtqMrk()}
	oMarkCtr:oBrowse:lhasMark    := .T.
	oMarkCtr:oBrowse:lCanAllmark := .T.
	oMarkCtr:oBrowse:bAllMark := {|| MarkAll()}
	oMarkCtr:oBrowse:SetHeaderImage(2, "COLRIGHT")
	oMarkCtr:oBrowse:SetHeaderImage(3, "COLDOWN")
	Eval(oMarkCtr:oBrowse:bGoTop)
	oMarkCtr:oBrowse:Refresh()

	@ (aPosObj[2,3] - 20),(aPosObj[2,4] - 230) Button "Imprimir"   Size 45,15 Action ImpPedCTRB() Of oDlg Pixel
	@ (aPosObj[2,3] - 20),(aPosObj[2,4] - 185) Button "Parâmetros" Size 45,15 Action Pergunte(cPerg,.T.) Of oDlg Pixel
	@ (aPosObj[2,3] - 20),(aPosObj[2,4] - 140) Button "Legenda"    Size 45,15 Action fn211Leg() Of oDlg Pixel
	@ (aPosObj[2,3] - 20),(aPosObj[2,4] - 095) Button "Enviar p E-Mail"   Size 45,15 Action ImpPeBr() Of oDlg Pixel  //Adicionado por Bruno Santos em 19/12/2019
	@ (aPosObj[2,3] - 20),(aPosObj[2,4] - 050) Button "Cancelar"    Size 45,15 Action oDlg:End() Of oDlg Pixel

	Activate MsDialog oDlg Centered

	dbSelectArea("TRB")
	oTRB:Delete()
	RestArea(aArea)

Return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ImpPedCTRB³ Autor ³ Walter Matsui         ³ Data ³ 10/04/18  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Imprime Pedido de compras loop TRB                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ Nenhum                                                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static function ImpPedCTRB()
	Local nConf
	Local nQtdPed := 0
	Private nLimMin := 40
	Private nColMin	:= 0
	Private nLinMax	:= 800
	Private nColMax	:= 535

	nConf := Aviso("Mensagem","Confirmar a impressão do Pedido de Compras?",{" Sim "," Nao "})
	If nConf == 2
		Return
	Endif

	//-----------------------------
	//Inicia processo de impressao
	//-----------------------------
	cNomeImpr := "ZDesigner ZT230-200dpi ZPL"
	oPrinter := FWMSPrinter():New("PedComp"+DTOS(dDatabase)+Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2)+".ped",IMP_PDF  ,.F./*lAdjustToLegacy*/,xcPath,.t./*lDisabeSetup*/,/*lTReport*/,@oPrinter,/*cPrinter*/,/*lServer*/,/*lPDFAsPNG*/,/*lRaw*/,.T./*lViewPDF*/,/*nQtdCopy*/)
	oPrinter:SetPortrait() //Retrato      SetLandscape() =Paisagem
	oPrinter:SetPaperSize(DMPAPER_A4)
	oPrinter:SetMargin(50,50,50,50)

	dbSelectArea("TRB")
	dbGotop()
	While !Eof()

		dbSelectArea("TRB")

		If Marked("M_OK")
			SC7->(DbSetOrder(1))
			SC7->(DbSeek(TRB->M_FILIAL+TRB->M_PEDIDO))
			SA2->(DbSetOrder(1))
			SA2->(DbSeek(xFilial("SA2")+TRB->M_FORNECE+TRB->M_LOJA))
			SY1->(DbSetOrder(1))
			SY1->(DbSeek(xFilial("SY1")+SC7->C7_COMPRA))

			oPrinter:StartPage()
			nPage++

			ImpHead()
			ImpBody()
			ImpFoot()
			ImpAnexo()

			oPrinter:EndPage()
			nQtdPed++
		Endif

		dbSelectArea("TRB")
		dbSkip()
	EndDo

	dbGotop()

	If nQtdPed>0
		//-----------------------------
		//Finaliza o processo de impressao
		//-----------------------------
		oPrinter:Print()
	Else
		Aviso("Seleção","Não foi selecionado nenhum item. Selecione pelo menos um item.",{"OK"},3)
	Endif

Return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ ImpHead ³ Autor ³ Walter Matsui         ³ Data ³ 10/04/18  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Imprime Cabeçalho do Pedido de Compras                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ Nenhum                                                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpHead()

	Local aArea:=GetArea()
	Local cLogo		:= "\system\"+SuperGetMv("EL_LOGPBMP",.F.,"logoeliza.jpg")
	Local nLin		:= 050

	SM0->( dbSeek(cEmpAnt+TRB->M_FILIAL))

	//---------------------------------------------------------------------------------------------------------
	oPrinter:Box( nLimMin,352 , 110, nColMax, "-6")
	//---------------------------------------------------------------------------------------------------------
	oPrinter:SayBitmap(nLin,010,cLogo,100,040)
	//---------------------------------------------------------------------------------------------------------
	cCNPJ := SUBSTR(SM0->M0_CGC,1,2)+"."+SUBSTR(SM0->M0_CGC,3,3)+"."+SUBSTR(SM0->M0_CGC,6,3)+"/"+SUBSTR(SM0->M0_CGC,9,4)+"-"+SUBSTR(SM0->M0_CGC,13,2)
	cIE   := Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)
	//---------------------------------------------------------------------------------------------------------
	cRazao := Alltrim(SM0->M0_NOMECOM)
	If Len(cRazao) <= 40
		oPrinter:Say(nLin,140,Alltrim(SM0->M0_NOMECOM)									,oFont11N)
	Else
		nPosCorte := ColunCorte(Substr(SM0->M0_NOMECOM,01,40),40)
		oPrinter:Say(nLin,140,Substr(SM0->M0_NOMECOM,01,nPosCorte)						,oFont11N)
		nLin+=010
		oPrinter:Say(nLin,140,Substr(SM0->M0_NOMECOM,nPosCorte+1,80)					,oFont11N)
	Endif

	nLin+=010
	cEndereco := Alltrim(SM0->M0_ENDENT)+"-"+Alltrim(SM0->M0_BAIRENT)
	If Len(cEndereco) <= 40
		oPrinter:Say(nLin,140,Pad(cEndereco,40),oFont11N)
		nLin+=010
		oPrinter:Say(nLin,140,"CEP: "+Subs(SM0->M0_CEPENT,1,5)+"-"+Subs(SM0->M0_CEPENT,6,3)	,oFont11N)
	Else
		cEndereco := Alltrim(SM0->M0_ENDENT)+"-"+Alltrim(SM0->M0_BAIRENT)+ " - CEP: "+Subs(SM0->M0_CEPENT,1,5)+"-"+Subs(SM0->M0_CEPENT,6,3)
		nPosCorte := ColunCorte(cEndereco,40)

		oPrinter:Say(nLin,140,Substr(cEndereco,01,nPosCorte),oFont11N)
		nLin+=010
		oPrinter:Say(nLin,140,Substr(cEndereco,nPosCorte+1,40),oFont11N)
	Endif
	nLin+=010
	oPrinter:Say(nLin,140,"CNPJ: "+cCNPJ												,oFont11N)
	nLin+=010
	oPrinter:Say(nLin,140,"IE: "+cIE													,oFont11N)
	nLin+=010
	oPrinter:Say(nLin,140,"TEL: "+SM0->M0_TEL+"  FAX: "+SM0->M0_FAX						,oFont11N)
	//---------------------------------------------------------------------------------------------------------
	nLin		:= 050
	oPrinter:Say(nLin+010,400,"PEDIDO DE COMPRAS          "									,oFont11N)
	oPrinter:Say(nLin+020,426, TRB->M_PEDIDO 												,oFont11N)
	oPrinter:Say(nLin+030,370,"Data de Emissão:  "+DTOC(TRB->M_EMISSAO)						,oFont11N)

	oPrinter:Say(nLin+040,370,"Data de Aprovação:"+TRB->M_DTAPROV        ,oFont11N) 	


	oPrinter:Say(nLin+050,424,"Página: "+StrZero(nPage,3)									,oFont9N)
	//---------------------------------------------------------------------------------------------------------
	RestArea(aArea)
Return



/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ ImpBody ³ Autor ³ Walter Matsui         ³ Data ³ 10/04/18  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Imprime Corpo do Pedido de Compras                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ Nenhum                                                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                    ³±±
	±±³ Alteração³ Adicionado o digito no telefone do fornecedor, adicionado   ³±±
	±±³			   mais dois digitos no valor unitario						   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpBody()

	Local aArea:=GetArea()
	Local nLineLength 	:= 110
	Local nTabSize 		:= 3
	Local lWrap 		:= .T.
	Local nCurrentLine
	Local _i
	Local nLines 		:= MLCOUNT(SC7->C7_XOBS, nLineLength, nTabSize, lWrap)
	Local nSoma

	nLin			:= 050
	nCol			:= 000

	//---------------------------------------------------------------------------------------------------------
	oPrinter:Box( 115, nColMin, 190, nColMax, "-6")
	oPrinter:Box( 195, nColMin, 230, nColMax, "-6")
	oPrinter:Box( 235, nColMin    , 320, nColMax/2-3, "-6")
	oPrinter:Box( 235, nColMax/2+3, 320, nColMax, "-6")
	oPrinter:Box( 325, nColMin    , 360, nColMax/2-3, "-6")
	oPrinter:Box( 325, nColMax/2+3, 360, nColMax, "-6")
	//---------------------------------------------------------------------------------------------------------
	oPrinter:Say(nLin+080,010,"Fornecedor: "+TRB->M_FORNECE+"/"+TRB->M_LOJA					,oFont11N)
	oPrinter:Say(nLin+090,010,Alltrim(TRB->M_NOME)											,oFont11N)
	oPrinter:Say(nLin+100,010,Alltrim(SA2->A2_END)											,oFont11N)
	oPrinter:Say(nLin+110,010,Alltrim(SA2->A2_BAIRRO)+" - CEP: "+Alltrim(SA2->A2_CEP)		,oFont11N)
	oPrinter:Say(nLin+120,010,Alltrim(SA2->A2_MUN)+" - "+Alltrim(SA2->A2_EST)				,oFont11N)
	If !Empty(SA2->A2_CGC)
		cCNPJ := SUBSTR(SA2->A2_CGC,1,2)+"."+SUBSTR(SA2->A2_CGC,3,3)+"."+SUBSTR(SA2->A2_CGC,6,3)+"/"+SUBSTR(SA2->A2_CGC,9,4)+"-"+SUBSTR(SA2->A2_CGC,13,2)
	Else
		cCNPJ := ""
	Endif
	If !Empty(SA2->A2_INSCR)
		cIE   := Subs(SA2->A2_INSCR,1,3)+"."+Subs(SA2->A2_INSCR,4,3)+"."+Subs(SA2->A2_INSCR,7,3)+"."+Subs(SA2->A2_INSCR,10,3)
	Else
		cIE   := ""
	Endif
	oPrinter:Say(nLin+130,010,"CNPJ: "+cCNPJ+"         IE: "+cIE							,oFont11N)
	//---------------------------------------------------------------------------------------------------------
	oPrinter:Say(nLin+080,280,"Contato: "													,oFont11N)
	If !Empty(SC7->C7_CONTATO)
		oPrinter:Say(nLin+090,280,Alltrim(SC7->C7_CONTATO)									,oFont11N)
	Else
		oPrinter:Say(nLin+090,280,Alltrim(SA2->A2_CONTATO)									,oFont11N)
	Endif
	oPrinter:Say(nLin+100,280,Alltrim(SA2->A2_TEL)											,oFont11N)
	oPrinter:Say(nLin+100,260,"("+Alltrim(SA2->A2_DDD)+")"				           			,oFont11N)
	oPrinter:Say(nLin+110,280,Alltrim(SA2->A2_EMAIL)										,oFont11N)
	//---------------------------------------------------------------------------------------------------------
	oPrinter:Say(nLin+160,010,"Comprador: "													,oFont11N)
	oPrinter:Say(nLin+170,010,Alltrim(SY1->Y1_NOME)											,oFont11N)
	oPrinter:Say(nLin+160,280,Alltrim(SY1->Y1_TEL)											,oFont11N)
	oPrinter:Say(nLin+170,280,Alltrim(SY1->Y1_EMAIL)										,oFont11N)
	//---------------------------------------------------------------------------------------------------------
	oPrinter:Say(nLin+200,010,"Local de Entrega: "											,oFont11N)

	SM0->( dbSeek(cEmpAnt+TRB->M_FILIAL))

	If AllTrim(SM0->M0_CODFIL)<>"020401"
		cCNPJ := SUBSTR(SM0->M0_CGC,1,2)+"."+SUBSTR(SM0->M0_CGC,3,3)+"."+SUBSTR(SM0->M0_CGC,6,3)+"/"+SUBSTR(SM0->M0_CGC,9,4)+"-"+SUBSTR(SM0->M0_CGC,13,2)
		cIE   := Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)
		If Substr(SM0->M0_NOMECOM,49,1) == " "
			oPrinter:Say(nLin+210,010,Pad(SM0->M0_NOMECOM,48)									,oFont11N)
		Else
			oPrinter:Say(nLin+210,010,Pad(SM0->M0_NOMECOM,54)									,oFont10N)
		Endif

		cEndereco := Alltrim(SM0->M0_ENDENT)+"-"+Alltrim(SM0->M0_BAIRENT)
		nPosCorte := ColunCorte(cEndereco,48)

		If Len(cEndereco) <= 48
			oPrinter:Say(nLin+220,010,Pad(cEndereco,48),oFont11N)
			oPrinter:Say(nLin+230,010,"CEP: "+Subs(SM0->M0_CEPENT,1,5)+"-"+Subs(SM0->M0_CEPENT,6,3)	,oFont11N)
		Else
			cEndereco := Alltrim(SM0->M0_ENDENT)+"-"+Alltrim(SM0->M0_BAIRENT)+ " - CEP: "+Subs(SM0->M0_CEPENT,1,5)+"-"+Subs(SM0->M0_CEPENT,6,3)
			oPrinter:Say(nLin+220,010,Substr(cEndereco,01,nPosCorte),oFont11N)
			oPrinter:Say(nLin+230,010,Substr(cEndereco,nPosCorte+1,48),oFont11N)
		Endif

		oPrinter:Say(nLin+240,010,"CNPJ: "+cCNPJ											,oFont11N)
		oPrinter:Say(nLin+250,010,"IE: "+cIE												,oFont11N)
		oPrinter:Say(nLin+260,010,"TEL: "+SM0->M0_TEL+"  FAX: "+SM0->M0_FAX					,oFont11N)
	Else
		oPrinter:Say(nLin+210,010,LOC_ENTR01												,oFont11N)
		oPrinter:Say(nLin+220,010,LOC_ENTR02												,oFont11N)
		oPrinter:Say(nLin+230,010,LOC_ENTR03												,oFont11N)
		oPrinter:Say(nLin+240,010,LOC_ENTR04												,oFont11N)
		oPrinter:Say(nLin+250,010,LOC_ENTR05												,oFont11N)
		oPrinter:Say(nLin+260,010,LOC_ENTR06												,oFont11N)
	Endif
	//---------------------------------------------------------------------------------------------------------
	oPrinter:Say(nLin+200,nColMax/2+10,"Local de Cobrança."									,oFont11N)
	oPrinter:Say(nLin+210,nColMax/2+10,"Departamento Financeiro"							,oFont11N)
	If AllTrim(SM0->M0_CODFIL)<>"020202"
		oPrinter:Say(nLin+220,nColMax/2+10,LOC_ENTR02										,oFont11N)
		oPrinter:Say(nLin+230,nColMax/2+10,LOC_ENTR03										,oFont11N)
	Else
		oPrinter:Say(nLin+220,nColMax/2+10,Pad(cEndereco,40)											,oFont11N)
		oPrinter:Say(nLin+230,nColMax/2+10,"CEP: "+Subs(SM0->M0_CEPENT,1,5)+"-"+Subs(SM0->M0_CEPENT,6,3),oFont11N)
	Endif
	//---------------------------------------------------------------------------------------------------------
	oPrinter:Say(nLin+290,010,"Modadlidade de Entrega: "									,oFont11N)
	oPrinter:Say(nLin+300,010,IIF(SC7->C7_TPFRETE=="C","CIF","FOB")							,oFont11N)
	//---------------------------------------------------------------------------------------------------------
	//SE4->(dbSetOrder(1))
	//SE4->(dbSeek(xFilial("SE4")+SC7->C7_COND))
	oPrinter:Say(nLin+290,nColMax/2+10,"Condição de Pagamento"							,oFont11N)
	oPrinter:Say(nLin+300,nColMax/2+10,Posicione("SE4",1,padr(SubSTr(SC7->C7_FILIAL,1,2),TamSx3("C7_FILIAL")[1])+SC7->C7_COND,"E4_DESCRI")	,oFont11N)
	//oPrinter:Say(nLin+300,nColMax/2+10,SE4->E4_DESCRI										,oFont11N)
	//---------------------------------------------------------------------------------------------------------


	//---------------------------------------------------------------------------------------------------------
	// Observações
	//---------------------------------------------------------------------------------------------------------
	oPrinter:Box( 365, nColMin    , 385, nColMax, "-6")
	//---------------------------------------------------------------------------------------------------------
	oPrinter:Say(nLin+328,010,"Observações: "												,oFont11N)
	//---------------------------------------------------------------------------------------------------------
	cTexto := MEMOREAD(SC7->C7_XOBS)

	//---------------------------------------------------------------------------------------------------------
	// Observações - Calcula a posição para o BOX da Observação
	//---------------------------------------------------------------------------------------------------------
	nSoma  := 350
	For nCurrentLine := 1 TO nLines
		nSoma += 10
	Next nCurrentLine

	//---------------------------------------------------------------------------------------------------------
	//  Limite de linhas do campo de observação antes de quebra de página
	nLimLinObs := 36
	//---------------------------------------------------------------------------------------------------------

	If nLines <= nLimLinObs
		nLinFinal := 400+( nLines     *10)
	Else
		nLinFinal := 410+( nLimLinObs *10)
	Endif
	oPrinter:Box( 390, nColMin    ,nLinFinal , nColMax, "-6")

	//---------------------------------------------------------------------------------------------------------
	// Observações - Conteudo
	//---------------------------------------------------------------------------------------------------------
	nLin   := 400
	nSoma  := 000
	For nCurrentLine := 1 TO nLines

		If  Mod(nCurrentLine , nLimLinObs + 1)==0  // nCurrentLine > nLimLinObs + 2
			oPrinter:EndPage()
			oPrinter:StartPage()
			nPage++
			ImpHead()
			nLinIni := 115
			oPrinter:Box( nLinIni, nColMin, (nLinIni+20+ (10 * (nLines-nCurrentLine))) , nColMax, "-6")
			nLin  := 120
			nSoma := 005
		Endif

		oPrinter:Say(nLin+nSoma,010,MEMOLINE(SC7->C7_XOBS, nLineLength, nCurrentLine, nTabSize, lWrap) 	,oFont10N)


		nSoma += 10

	Next nCurrentLine


	//---------------------------------------------------------------------------------------------------------
	// Itens do Pedido de Compras
	//---------------------------------------------------------------------------------------------------------
	nLin += nSoma

	If nLin > 750
		oPrinter:EndPage()
		oPrinter:StartPage()
		nPage++
		ImpHead()
		nLin  := 130
		nSoma := 000
	Endif

	//---------------------------------------------------------------------------------------------------------------------------------------------------
	// Cab. Itens do Pedido de Compras
	oPrinter:Box( nLin+05, nColMin    , nLin+30, nColMax, "-6")
	oPrinter:Say( nLin+15, 005,"     Código      Material                                    Preço                     Preço   Data de"	,oFont11N)
	oPrinter:Say( nLin+25, 005,"Item Produto     Descrição                      Quant.UM     Unit.   ICMS     IPI      Total   Entrega"	,oFont11N)
	//---------------------------------------------------------------------------------------------------------------------------------------------------

	SC7->(DbSetOrder(1))
	SC7->(DbSeek(TRB->M_FILIAL+TRB->M_PEDIDO))

	nSubtotal    := 0
	nICMS        := 0
	nISS         := 0
	nIPI         :=	0
	nDescB       := 0
	nTOTAL       :=	0

	// TROCADO C7_DESCRI PADRAO POR B1_XDESCOM
	nQuebrDes1 := 32   // Tamanho da Descriçao que indica a quebra da linha 1
	nQuebrDes2 := 52   // Tamanho da Descriçao que indica a quebra da linha 2 em diante
	nLin += 45
	While !SC7->(Eof()) .And. SC7->C7_FILIAL==TRB->M_FILIAL .And. SC7->C7_NUM==TRB->M_PEDIDO

		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SC7->C7_PRODUTO))

		cConteudo := SC7->C7_ITEM + " " + SC7->C7_PRODUTO + " " + Pad(AllTrim(SB1->B1_XDESCOM),nQuebrDes1) + "" + Transf(SC7->C7_QUANT,"@E 99,999,999.99") + " " + ;
			SC7->C7_UM + "" + Transf(SC7->C7_PRECO,"@E 99,999.9999") + "  " + Transf(IIF(SC7->C7_UM = 'SV',0,SC7->C7_VALICM),"@E 99,999.99") + "" + ;
			Transf(SC7->C7_VALIPI,"@E 99,999.99") + "" + Transf(SC7->C7_TOTAL + SC7->C7_VALIPI,"@E 9999,999,999.99") + " " + DTOC(SC7->C7_DATPRF) + " "

		cConteudo1 := SB1->B1_XREF1

		nLin += 000
		nCol := 010

		If nLin > 750
			oPrinter:EndPage()
			oPrinter:StartPage()
			nPage++
			ImpHead()
			nLin  := 125
			nSoma := 000
		Endif

		oPrinter:Say( nLin, 005		,cConteudo	,oFont9N)
		nLin += 10


		// Imprime a descrição acima de 30 caractere pulando linhas
		If Len(AllTrim(SB1->B1_XDESCOM)) >  nQuebrDes1
			For _i := 33 to Len(AllTrim(SB1->B1_XDESCOM) ) Step nQuebrDes2
				cConteudo := Space(00) + Substr(SB1->B1_XDESCOM, _i ,nQuebrDes2)

				nLin += 000
				nCol := 010

				If nLin > 750
					oPrinter:EndPage()
					oPrinter:StartPage()
					nPage++
					ImpHead()
					nLin  := 125
					nSoma := 000
				Endif

				oPrinter:Say( nLin, 005		,cConteudo+ "" + cConteudo1  ,oFont9N)
				nLin += 10

			Next _i
		Endif


		nSubtotal    += SC7->C7_TOTAL
		nICMS        += IIF(SC7->C7_UM = 'SV',0,IF(SC7->C7_VALSOL >0,SC7->C7_VALSOL,SC7->C7_VALICM))
		nISS         += SC7->C7_VALISS
		nIPI         +=	SC7->C7_VALIPI
		nDescB		 += SC7->C7_VLDESC

		//Alterado por Sergio Arruda em 18/05/2021
		nTOTAL       +=	SC7->C7_TOTAL + SC7->C7_VALFRE + SC7->C7_VALIPI + SC7->C7_VALSOL - SC7->C7_VLDESC

		// Linha separatória de produtos
		oPrinter:Box( nLin, nColMin    , nLin, nColMax, "-6")

		nLin += 10
		SC7->(dbSkip())

	End
	RestArea(aArea)

Return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Função    ³ ImpFoot  ³ Autor ³ Walter Matsui         ³ Data ³ 10/04/18  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Imprime Rodape do Pedido de Compras                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ Nenhum                                                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpFoot()
	nLin += 15

	If nLin > 730
		oPrinter:EndPage()
		oPrinter:StartPage()
		nPage++
		ImpHead()
		nLin  := 130
		nSoma := 000
	Endif

	oPrinter:Say( nLin+00, 410		,"RESUMO "														,oFont10N)
	oPrinter:Say( nLin+10, 410		,"Subtotal    "+	Transf(nSubtotal	,"@E 999,999,999.99")	,oFont10N)
	oPrinter:Say( nLin+20, 410		,"ICMS        "+	Transf(nICMS		,"@E 999,999,999.99")	,oFont10N)
	oPrinter:Say( nLin+30, 410		,"ISS         "+	Transf(nISS			,"@E 999,999,999.99")	,oFont10N)
	oPrinter:Say( nLin+40, 410		,"IPI         "+	Transf(nIPI			,"@E 999,999,999.99")	,oFont10N)
	oPrinter:Say( nLin+50, 410		,"DESCONTO    "+	Transf(nDescB		,"@E 999,999,999.99")	,oFont10N)
	oPrinter:Say( nLin+60, 410		,"TOTAL       "+	Transf(nTOTAL		,"@E 999,999,999.99")	,oFont10N)

	SC7->(DbSetOrder(1))
	SC7->(dbSeek(TRB->M_FILIAL+TRB->M_PEDIDO))

	oPrinter:EndPage()

Return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Função    ³ ImpAnexo ³ Autor ³ Walter Matsui         ³ Data ³ 10/04/18  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Imprime Anexo do Pedido de Compras                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ Nenhum                                                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpAnexo()

	nLin := 0130
	//---------------------------------------------------------------------------------------------------------
	oPrinter:StartPage()
	nPage++

	ImpHead()
	//---------------------------------------------------------------------------------------------------------
	oPrinter:Box( 115, nColMin, nLinMax, nColMax, "-6")
	//---------------------------------------------------------------------------------------------------------
	oPrinter:Say(nLin+010,200,'ANEXO DO PEDIDO DE COMPRAS'																							,oFont12N)

	oPrinter:Say(nLin+030,010,'OBSERVAÇÕES:'																										,oFont12N)
	oPrinter:Say(nLin+040,010,'CONDIÇÕES GERAIS'																									,oFont12N)

	oPrinter:Say(nLin+060,010,'1-   Observar, no PEDIDO, o CNPJ de faturamento. Emissão de NF’s em CNPJ  diferente  implicará  na'					,oFont11N)
	oPrinter:Say(nLin+070,010,'substituição da mesma;'																								,oFont11N)

	oPrinter:Say(nLin+090,010,'2-   Os materiais  ou  equipamentos  entregues  pelo  fornecedor  em  desacordo  com  as  condições,'				,oFont11N)
	oPrinter:Say(nLin+100,010,'especificações ou descrições técnicas estabelecidas no Pedido de Compra serão devolvidos para  fins'					,oFont11N)
	oPrinter:Say(nLin+110,010,'de sua adequação ou substituição, conforme  o  caso.  Todas  as  despesas  necessárias  à  referida'					,oFont11N)
	oPrinter:Say(nLin+120,010,'adequação ou substituição, inclusive custos com transportes, correrão exclusivamente por  conta  do'					,oFont11N)
	oPrinter:Say(nLin+130,010,'fornecedor;'																											,oFont11N)

	If cFilAnt == "020202"
		oPrinter:Say(nLin+150,010,'3-   Entrega de materiais devem ser realizadas de segundas-feiras as sextas-feiras em observância ,'					,oFont11N)
		oPrinter:Say(nLin+160,010,'aos horários das 07:30 às 12:00 e de 13:00 às 16:30;'																,oFont11N)
	Else
		oPrinter:Say(nLin+150,010,'3-   Entrega de materiais devem ser realizadas de segundas-feiras as sextas-feiras em observância ,'					,oFont11N)
		oPrinter:Say(nLin+160,010,'aos horários das 07:00 às 11:00 e de 12:00 às 15:00;'																,oFont11N)
	EndIf
	oPrinter:Say(nLin+180,010,'4-   É obrigatório mencionar o número do Pedidos de Compras no DANFE;'												,oFont11N)

	oPrinter:Say(nLin+200,010,'5-   É obrigatório mencionar no arquivo XML o número do pedido de compras na tag "xPed" e o número '					,oFont11N)
	oPrinter:Say(nLin+210,010,'do item do pedido de compras na tag "nItemPed";'																		,oFont11N)

	oPrinter:Say(nLin+230,010,'6-   É obrigatório mencionar na nota fiscal de serviço eletrônica o número do pedido de compras. Na'	 				,oFont11N)
	oPrinter:Say(nLin+240,010,'hipótese de prestação de serviços a serem pagos por medição, o fornecedor deverá enviar as respectivas'				,oFont11N)
	oPrinter:Say(nLin+250,010,'planilhas de medição para aprovação do gestor técnico;' 																,oFont11N)
	oPrinter:Say(nLin+265,010,'6.1- Para os prestadores de serviço que irão executar as atividades dentro das plantas fabris da ' 																,oFont11N)
	oPrinter:Say(nLin+275,010,'Elizabeth deverão passar pelo processo de integração junto a área de segurança da Elizabeth.' 																,oFont11N)
	oPrinter:Say(nLin+285,010,'Todos deverão estar devidamente identificados com crachá funcional da empresa contratada com foto,' 																,oFont11N)
	oPrinter:Say(nLin+295,010,"nome e função, fardado e portar todos os EPI's, EPC's e ferramentas necessárias para o desempenho" 																,oFont11N)
	oPrinter:Say(nLin+305,010,'de suas atividades.' 																                                ,oFont11N)
								
	oPrinter:Say(nLin+325,010,'7-   A emissão da nota fiscal de serviço ficará condicionada ao recebimento da Termo de Aceite do '					,oFont11N)
	oPrinter:Say(nLin+335,010,'Serviço a ser emitido pelo gestor técnico do serviço;'																,oFont11N)

	oPrinter:Say(nLin+355,010,'8-   É obrigatório  o envio das notas fiscais eletrônicas, de acordo com seu tipo, obedecendo os '				,oFont11N)
	oPrinter:Say(nLin+365,010,'os seguintes prazos para emissão:'				                                                            ,oFont11N)
	oPrinter:Say(nLin+380,037,"Serviços:",oFont11NS)
	oPrinter:Say(nLin+390,037,"MEI e Avulsos:",oFont11NS)
	oPrinter:Say(nLin+400,037,"Materiais em geral:",oFont11NS)
	oPrinter:Say(nLin+380,010,'8.1-            deverá ser emitida até o dia 25 do mês vigente;'																					,oFont11N)
	oPrinter:Say(nLin+390,010,'8.2-  		               deverá ser emitida até o dia 20 do mês vigente;'																					,oFont11N)
	oPrinter:Say(nLin+400,010,'8.3-                     deverá ser emitido até o dia 28 do mês vigente.'																					,oFont11N)

	oPrinter:Say(nLin+420,010,'9-   Caso o fornecedor seja optante do simples, deverá enviar junto com a nota fiscal a declaração de'				,oFont11N)
	oPrinter:Say(nLin+430,010,'optante, de acordo com anexo IV da IN 791/207;'																		,oFont11N)

	oPrinter:Say(nLin+450,010,'10-  O fornecedor deverá emitir, via e-mail, a confirmação de recebimento do Pedido de compra '						,oFont11N)
	oPrinter:Say(nLin+460,010,'imediatamente após o seu efetivo recebimento;'																		,oFont11N)

	oPrinter:Say(nLin+480,010,'11-  Pedido aprovado eletronicamente.'																				,oFont11N)

	oPrinter:Say(nLin+500,010,'12- Todos pagamentos são feitos via depósito bancário. Sempre que tiver alguma alteração nos dados '					,oFont11N)
	oPrinter:Say(nLin+510,010,'bancários deve ser informado ao comprador.'																			,oFont11N)

	oPrinter:Say(nLin+530,010,'13- ATENÇÃO: Comunicamos aos nossos fornecedores e prestadores de serviço que, a partir do dia'                      ,oFont11N)
	oPrinter:Say(nLin+540,010,'01/08/2023, os pagamentos realizados pela Elizabeth Revestimentos Cerâmicos passam a ser realizados' 				,oFont11N)
	oPrinter:Say(nLin+550,010,'somente nos dias 11, 21 e 30 de cada mês. Caso a data do vencimento seja no final de semana ou'                      ,oFont11N)
	oPrinter:Say(nLin+560,010,'feriado, o pagamento será no próximo dia útil. '					                                                    ,oFont11N)
	oPrinter:Say(nLin+570,010,'Para demais informações sobre o tema, os interessados devem contatar o setor de suprimentos;'						,oFont11N)

	//---------------------------------------------------------------------------------------------------------
	oPrinter:EndPage()

Return

 

/*======================================================
--  Função: Mostrar legenda Enderecamento.            --
--                                                    --
========================================================*/
Static Function fn211Leg()
	Local aLegenda 
	
	aLegenda := {{"BR_VERDE"     ,"Normal"     },;
	{"BR_LARANJA"   ,"PENDENTE"    }}
Return .T.


/*----------------------------------------------
--  Função: MenuDef no MarkBrowser.           --
--                                            --
------------------------------------------------*/
Static Function MenuDef()
	Local aRotina := {{"Legenda","U_fn211Leg()",0,5}}
Return(aRotina)


/*----------------------------------------------
--  Função: Marcar registro no MarkBrowser.   --
--                                            --
------------------------------------------------*/
Static Function ImpEtqMrk()
	Private cQuant
	If Marked("M_OK")
		RecLock("TRB",.F.)
		Replace TRB->M_OK with cMark
		TRB->(MsUnLock())

	else
		RecLock("TRB",.F.)
		Replace TRB->M_OK with ""
		TRB->(MsUnLock())
	Endif

	oMarkCtr:oBrowse:Refresh()

Return


/*----------------------------------------------
--  Função: Marcar todos os Registros.       --
--                                           --
----------------------------------------------*/
Static Function MarkAll()
	dbSelectArea("TRB")
	TRB->(dbGotop())

	While ! TRB->(Eof())
		Reclock("TRB",.F.)
		If TRB->M_OK == Space(02)
			Replace TRB->M_OK with cMark
		else
			Replace TRB->M_OK with ""
		EndIf
		TRB->(MsUnlock())

		TRB->(dbSkip())
	EndDo

	oMarkCtr:oBrowse:Gotop()
	oMarkCtr:oBrowse:Refresh()
Return


/*----------------------------------------------
--  Função: ColunCorte               .        --
--  Retorna a coluna na qual deve ser cortada --
--  para não cortar a palavra no meio.        --
-----------------------------------------------*/
Static Function ColunCorte(cString,nTamanho)
	Local nRet
	nRet := nTamanho

	While nRet > 0 .And. Substr(cString,nRet,1) <> " " .And. Substr(cString,nRet+1,1) <> " "
		If Substr(cString,nRet,1) <> " " .And. Substr(cString,nRet+1,1) <> " "
			// Se a posição de corte não for branco e nem a próxima => precisa ser retrocedida.
			nRet--
		Endif
	End

Return nRet

Static Function mUltAprv(_cAux)

	Local cQuery 	:= " "
	Local cRet		:= " "

	cQuery := "select * from "+RetSQLName("SCR")+" SCR1 "
	cQuery += "where SCR1.D_E_L_E_T_ <> '*' "
   	cQuery += "AND CR_FILIAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	cQuery += "and CR_NUM = '"+_cAux+"' "
	cQuery += "and CR_STATUS = '03' "
	cQuery += "and CR_NIVEL = (select MAX(CR_NIVEL) from "+RetSQLName("SCR")+" SCR2 "
	cQuery += "where SCR2.D_E_L_E_T_ <> '*' "
   	cQuery += "AND CR_FILIAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	cQuery += "and CR_NUM = '"+_cAux+"')"

	TCQUERY cQuery NEW ALIAS "APR"

	DBSELECTAREA("APR")
	APR->(DBGOTOP())

	If !APR->(EOF())
		cRet := dtoc(STOD(APR->CR_DATALIB))
	endif

	DBSELECTAREA("APR")
	APR->(DBCLOSEAREA())

Return cRet


/*------------------------------------------------------------------------
* Autor		: Bruno Santos
*------------------------------------------------------------------------
* Nome		: ImpPeBr
*------------------------------------------------------------------------
* Data_		: 19/12/2019
*------------------------------------------------------------------------
* Objetivo	: Salva o pedido de compras como PDF
*------------------------------------------------------------------------*/

Static function ImpPeBr()

	Local nQtdPed := 0
	Local cPedCom := ""

	Private nLimMin := 40
	Private nColMin	:= 0
	Private nLinMax	:= 800
	Private nColMax	:= 535	
	Private cNomArq := ''

	Public lConfTodos:= .F.

	//-----------------------------
	//Inicia processo de impressao
	//-----------------------------
	cNomeImpr := "ZDesigner ZT230-200dpi ZPL"
	dbSelectArea("TRB")
	dbGotop()


	While !Eof()
       
 	   cPedCom := TRB->M_PEDIDO	

	   cNomArq := "PedComp"+DTOS(dDatabase)+Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2)+".pdf"

	   oPrinter := FWMSPrinter():New(cNomArq,IMP_PDF  ,.F./*lAdjustToLegacy*/,xcPath,.t./*lDisabeSetup*/,/*lTReport*/,@oPrinter,/*cPrinter*/,/*lServer*/,/*lPDFAsPNG*/,/*lRaw*/,.F./*lViewPDF*/,/*nQtdCopy*/)

	   oPrinter:SetPortrait() //Retrato      SetLandscape() =Paisagem
	   oPrinter:SetPaperSize(DMPAPER_A4)
	   oPrinter:SetMargin(50,50,50,50)
	   oPrinter:cPathPDF := "c:\temp\"    

	   oPrinter:StartPage()
       nPage++

	   dbSelectArea("TRB")		  

		While cPedCom == TRB->M_PEDIDO .And. !Eof()
			If Marked("M_OK")
		     
			 SC7->(DbSetOrder(1))
			 SC7->(DbSeek(TRB->M_FILIAL+TRB->M_PEDIDO))
			 SA2->(DbSetOrder(1))
			 SA2->(DbSeek(xFilial("SA2")+TRB->M_FORNECE+TRB->M_LOJA))
			 SY1->(DbSetOrder(1))
			 SY1->(DbSeek(xFilial("SY1")+SC7->C7_COMPRA))

			 ImpHead()
			 ImpBody()
			 ImpFoot()
			 ImpAnexo()

			 nQtdPed++
			Endif

		  dbSelectArea("TRB")		  
	      dbSkip()

		EndDo

	   oPrinter:EndPage()

		If nQtdPed>0
		  //-----------------------------
		  //Finaliza o processo de impressao
		  //-----------------------------
		  //
		  oPrinter:Print()                         

		  *-----------------------------------------
		  * Copio o arquivo para o servidor, pois a 
		  * função que anexa o arquivo no email, só 
		  * consegue pegar o arquivo se estiver no servidor
		  *-----------------------------------------		
		  __CopyFile( "c:\temp\"+cNomArq, '\spool\'+cNomArq )  

		  *-----------------------------------------
		  * chamar a função aqui de envio de e-mail
		  *-----------------------------------------
		  EnvBr(cNomArq)

			If lConfTodos == .F.
		    	Alert('E-mail referente pedido '+ SC7->C7_NUM + ' enviado com sucesso!')
			Endif

		  FErase( '\SPOOL\'+cNomArq )       
		  oDlg:End()
		  oDlg1:End()		
		Else
			If Eof()
	        	Aviso("Finalização","O processo foi finalizado.",{"OK"},3)	
			Endif
		Endif
      
	  nQtdPed := 0

	EndDo

Return

/*------------------------------------------------------------------------
* Autor		: Bruno Santos
*------------------------------------------------------------------------
* Nome		: EnvBr
*------------------------------------------------------------------------
* Data_		: 20/12/2019
*------------------------------------------------------------------------
* Objetivo	: Envia o pedido por e-mail
*------------------------------------------------------------------------*/
Static Function EnvBr(CamB)

	Local cPara		:= ''
	Local cCopia	:= ''
	Local cAssunto	:= ''
	Local cTexto	:= ''
	Local nAviso    := 0

	Public cFiles  	:= "\SPOOL\"+CamB

	Private aEmp	:= {}		// Array que armazena as empresas e filiais que irão executar o JOB
	Private cDiaEmi := ""       // Dias permitidos para emissão de relatório via JOB
	Private lEmitDia:= .F.      // Variável que informa se deve emitir no dia de via JOB
	Private cEmpFil := ""       // Empresa e Filial que grupra os relatórios
	Private cUnif
	Private lUnif := .F.
	Private cNumeroPed := SC7->C7_NUM
	Private cFilialPed := SC7->C7_FILIAL
	Private aPerg := {}
	Private aRetParam := {} 

	AAdd(aPerg,{1,"E-mails",Space(200),"","","","",100,.F.})

	DBSELECTAREA("SC7")
	SC7->(DBSEEK(cFilialPed+cNumeroPed))

	DBSELECTAREA("SC7")
	SC7->(DBSEEK(cFilialPed+cNumeroPed))

	cPara		:= POSICIONE("SA2",1,XFILIAL("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_EMAIL") + ";" + POSICIONE("SY1",1,XFILIAL("SY1")+SC7->C7_COMPRA,"Y1_EMAIL")    
	cCopia	    :=  ''                    
	cAssunto    := "Pedido de Compra No."+SC7->C7_NUM

	cTexto := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> '
	cTexto += '  <html> ' 
	cTexto += '  <head> ' 
	cTexto += '  <meta http-equiv="Content-Type" content="text/html; charset=utf-8"> ' 
	cTexto += '  <title>Aprovacao</title> '
	cTexto += '  <style type="text/css"> ' 
	cTexto += '  <!-- '
	cTexto += '  .style1 { ' 
	cTexto += '	font-family: "Courier New", Courier, monospace; ' 
	cTexto += '	font-weight: bold; '
	cTexto += '} '
	cTexto += '#apDiv1 { '
	cTexto += '	position:absolute; ' 
	cTexto += '	left:1149px; '
	cTexto += '	top:25px; '
	cTexto += '	width:160px; '
	cTexto += '	height:85px; '
	cTexto += '	z-index:1; '
	cTexto += '} '
	cTexto += '#apDiv2 { ' 
	cTexto += '	position:absolute; ' 
	cTexto += '	left:1126px; '
	cTexto += '	top:20px; '
	cTexto += '	width:174px; '
	cTexto += '	height:92px; '
	cTexto += '	z-index:1; '
	cTexto += '} '
	cTexto += '#apDiv3 { ' 
	cTexto += '	position:absolute; ' 
	cTexto += '	left:12px; '
	cTexto += '	top:105px; '
	cTexto += '	width:338px; ' 
	cTexto += '	height:47px; '
	cTexto += '	z-index:1; '
	cTexto += '} '
	cTexto += '#apDiv4 { ' 
	cTexto += '	position:absolute; ' 
	cTexto += '	left:156px; '
	cTexto += '	top:91px; '
	cTexto += '	width:226px; ' 
	cTexto += '	height:19px; '
	cTexto += '	z-index:1; '
	cTexto += '} '
	cTexto += '.aaaaa {	color: #FFF; '
	cTexto += '} '
	cTexto += '.bbbbbb { '
	cTexto += '	color: #FFF; '
	cTexto += '} '
	cTexto += '.Numero { '
	cTexto += '	text-align: right; '
	cTexto += '} '
	cTexto += '.RIGHT { '
	cTexto += '	text-align: right; '
	cTexto += '} '
	cTexto += '.Branco { '
	cTexto += '	color: #FFFFFF; '
	cTexto += '} '
	cTexto += '.table.table-striped.table-bordered.table-hover.table.table-sm tr td div { '
	cTexto += '	text-align: justify; '
	cTexto += '} '
	cTexto += '--> '
	cTexto += '  </style> '

	cTexto += '<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css"> '
	cTexto += '		<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script> '
	cTexto += '		<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"></script> '
	cTexto += '		<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"></script> '
	cTexto += '</head> '

	cTexto += '<body> '

	cTexto += '<fieldset>'
	cTexto += '<legend class="style1"></legend>'
	cTexto += '<form name="form1" method="post" action="mailto:%WFMailTo%">'
	cTexto += '  <p class="font-weight-normal"><span class="Branco">O</span></p>'
	cTexto += '  <table width="100%" border="1" bordercolor="#B2CBE7" class="table table-striped table-bordered table-hover table table-sm">'
	cTexto += '    <tr bgcolor="#B2CBE7">'
	cTexto += '      <td colspan="1" align="center" bgcolor="#1D5692"><strong class="bbbbbb"><span class="font-weight-normal">Pedido de Compras No. '+SC7->C7_NUM+'.</span></strong></td>'
	cTexto += '    </tr>'
	cTexto += '    <tr bgcolor="#B2CBE7">'
	cTexto += '      <td width="100%"><div align="justify">'
	cTexto += '        <p>&nbsp;</p>'
	cTexto += '        <p>Prezado  fornecedor, </p>'
	cTexto += '        <p><br>'
	cTexto += '          Anexo  a este segue nossa confirmação de compra. <br>'
	cTexto += '  <strong>Pedimos atenção/fiel  cumprimento dos informativos abaixo:</strong></p>'
	cTexto += '        <ol>'
	cTexto += '          <li>O número do pedido de compra deverá <u>obrigatoriamente</u> estar destacado de forma visível na nota fiscal; </li>'
	cTexto += '          <li>Atentar ao recebimento automático de pedido de compra, a fim  de evitar fornecimento em duplicidade; </li>'
	cTexto += '          <li>O prazo de entrega pactuado deverá  ser respeitado. Qualquer eventualidade quanto a este prazo ou ainda quanto à entrega  parcial, deverá ser comunicada de forma prévia ao comprador responsável.</li>'
	cTexto += '          <li>A Nota Fiscal deverá estar com todos os itens em <u>conformidade</u> (CPNJ, preço, quantidade, especificação, dentre outros aspectos) com o pedido  de compra. </li>'
	cTexto += '          <li>Enviar <u>obrigatoriamente</u> o  XML da NF para o endereço eletrônico: <a href="mailto:nf@grupoelizabeth.com.br">nf@grupoelizabeth.com.br</a></li>'
	cTexto += '        </ol>'
	cTexto += '        <p><u>HORÁRIO  DE RECEBIMENTO</u>:  SEG A SEXT: 07:30 as 11:30 / 12:30 as 15:00<br>'
	cTexto += '          </p>'
	cTexto += '        <p>&nbsp;</p>'
	cTexto += '        <p><strong>Departamento de Compras</strong> <br>'
	cTexto += '          (83)2107-2000 </p>'
	cTexto += '        <p><strong><br>'
	cTexto += '          </strong><br>'
	cTexto += '        </p>'
	cTexto += '            </div></td>'

	cTexto += '      </tr>'
	cTexto += '</table>'
	cTexto += '  <p>&nbsp;</p>'
	cTexto += '  <table width="294" border="1" align="justify" bordercolor="#B2CBE7" class="table table-striped table-bordered table-hover table table-sm">'
	cTexto += '  </table>'
	cTexto += '</form>'
	cTexto += '</fieldset>'
	cTexto += '</body>'
	cTexto += '</html>'

	If cFiles <> ''

		ciTexto:= "Pedido de Compras No."+SC7->C7_NUM+" " + CRLF + CRLF
		ciTexto+= POSICIONE("SA2",1,XFILIAL("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME") + CRLF + CRLF
		ciTexto+= "E-mail: " + POSICIONE("SA2",1,XFILIAL("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_EMAIL") + CRLF
		ciTexto+= "E-mail: " + cPara 

		If lConfTodos == .F.

		   nAviso := AVISO("Pedido de Compras No."+SC7->C7_NUM,ciTexto, { "Confirmar","Fechar","Adicionar e-mails","Confirma Todos" }, 3)
           
			If nAviso == 4
		      lConfTodos := .T.
			Endif

			If nAviso == 3
				If ParamBox(aPerg ,"Parametros",aRetParam)
					If !Empty(aRetParam[1])
					cPara += ";" + Alltrim(aRetParam[1])

						If MsgYesNo("Confirma Envio?")
					    	MsgRun("Enviando Pedido de Compras No."+SC7->C7_NUM+"...","Aguarde...",{|| U_DrillEmail(GetMv("EL_RLMAIL"),cPara,"","","Pedido de Compras No."+SC7->C7_NUM,cTexto,.f.,cFiles)})
						Else
							MsgInfo("Processo de envio cancelado!!")
						EndIf
					EndIf
				EndIf
			EndIf
		Endif

		If nAviso == 1 .Or. lConfTodos
			MsgRun("Enviando Pedido de Compras No."+SC7->C7_NUM+"...","Aguarde...",{|| U_DrillEmail(GetMv("EL_RLMAIL"),cPara,"","","Pedido de Compras No."+SC7->C7_NUM,cTexto,.f.,cFiles)})
		EndIf
	EndIf

Return
