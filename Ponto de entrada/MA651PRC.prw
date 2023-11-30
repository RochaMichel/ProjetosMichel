#include 'protheus.ch'

/*/{Protheus.doc} MA651PRC
Validação de saldos disponivel dos componentes das OPs antes de firmar.
Esse P.E está configurado no cliente que sempre inicia as OPs como previstas.
@see https://tdn.totvs.com/pages/releaseview.action?pageId=322149288      
@author Normando NewSiga
@since 20/01/2020
@version 1.0
@return logical, Se continua o processo de firmar OPs
@type function
/*/
User Function MA651PRC()
	Local lRet:= .T.

	If GetMv("MV_ESTNEG") == "N"
		ValEstoque()
	EndIf

Return lRet

/*/{Protheus.doc} ValEstoque
Verifica o saldo disponivel dos componentes em todos os armazens
gerando a lista dos componentes sem saldo disponivel.
@author Normando NewSiga
@since 20/01/2020
@version 1.0
@type function
/*/
Static Function ValEstoque()
	Local aAreaSC2:= SC2->(GetArea())
	Local aAreaSB1:= SB1->(GetArea())
	Local aSaldo:= {}, aSaldoNeg:= {}
	Local aOpMark:= {}
	Local nPosOp:= 0, nPosSld:= 0
	local oDlg:= Nil
	Local oEdit:= Nil
	Local cFile:= ""
	Local cHtml:= ""
	Local cMarca:= PARAMIXB[1]
	Local cQuery:= ""
	Local lGeraOPI := SuperGetMv("MV_GERAOPI", .F., .T.)
	Local cAliasEmp:= GetNextAlias()
	Local cAliasSld:= GetNextAlias()
	Local nConsArm:= Posicione("SX1", 1, "MTA650    02", "X1_PRESEL")
	Local cArmDe := AllTrim(Posicione("SX1", 1, "MTA650    03", "X1_CNT01"))
	Local cArmAte:= AllTrim(Posicione("SX1", 1, "MTA650    04", "X1_CNT01"))

	//Tabela temporaria para gerenciar o saldo atual
	cQuery:= " SELECT B2_COD, "
	cQuery+= " Sum(B2_QATU-(B2_RESERVA+B2_QEMP+B2_QACLASS+B2_QEMPSA+B2_QEMPPRJ)) as SALDO "
	//cQuery+= "        Sum(B2_QATU+B2_SALPEDI-(B2_RESERVA+B2_QEMP+B2_QACLASS+B2_QEMPSA+B2_QEMPPRJ)) as SALDO "
	cQuery+= " FROM   "+RetSQLName("SB2")+" SB2 "
	If nConsArm == 1 //Pergunta MTA650 - Apenas armazem padrao
		cQuery+= "   INNER JOIN "+RetSQLName("SB1")+" B1 "
		cQuery+= "   ON B1_COD = B2_COD "
		cQuery+= "   AND B1_LOCPAD = B2_LOCAL "
		cQuery+= "   AND B1.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery+= " WHERE " + RetSqlCond("SB2")
	cQuery+= " AND B2_COD IN ( SELECT D4_COD "
	cQuery+= " FROM    "+RetSQLName("SD4")+" D4 "
	cQuery+= " WHERE  Substring(D4_OP, 1, 6) IN (SELECT DISTINCT C2_NUM "
	cQuery+= " FROM   "+RetSQLName("SC2")
	cQuery+= " WHERE  C2_FILIAL = "+ValToSQL(FWxFilial("SC2"))
	cQuery+= " AND C2_OK = "+ValToSQL(cMarca)
	cQuery+= " AND D_E_L_E_T_ = ' ') "
	cQuery+= "        AND D4.D_E_L_E_T_ = ' ' ) "
	If nConsArm == 2 //Pergunta MTA650 - Range de armazens
		cQuery+= "        AND B2_LOCAL BETWEEN "+ValToSQL(cArmDe)+" AND "+ValToSQL(cArmAte)
	EndIf
	cQuery+= " GROUP  BY B2_COD  "
	cQuery:= ChangeQuery(cQuery)

	MPSysOpenQuery(cQuery, cAliasSld)
	//Array como tabela temporaria dos saldos atuais dos componentes
	While (cAliasSld)->(!EOF())
		aAdd(aSaldo, {(cAliasSld)->B2_COD, (cAliasSld)->SALDO})

		(cAliasSld)->(DBSkip())
	EndDo

	cQuery:= " SELECT D4_COD, "
	cQuery+= "        D4_OP, "
	cQuery+= "        D4_QUANT AS EMP "
	cQuery+= " FROM    "+RetSQLName("SD4")+" SD4 "
	cQuery+= " WHERE  " + RetSqlCond("SD4")
	cQuery+= " AND Substring(D4_OP, 1, 6) IN (SELECT DISTINCT C2_NUM "
	cQuery+= "                                   FROM   "+RetSQLName("SC2")
	cQuery+= "                                   WHERE  C2_FILIAL = "+ValToSQL(FWxFilial("SC2"))
	cQuery+= "                                          AND C2_OK = "+ValToSQL(cMarca)
	cQuery+= "                                          AND D_E_L_E_T_ = ' ') "
	cQuery+= " ORDER  BY D4_OP, "
	cQuery+= "           D4_COD  "
	cQuery:= ChangeQuery(cQuery)

	MPSysOpenQuery(cQuery, cAliasEmp)

	If len(aSaldo) < 0
		While (cAliasEmp)->(!EOF())

			SB1->(MSSeek(FWxFilial("SB1")+(cAliasEmp)->D4_COD))
			//Não valida mão de obra
			If IsProdMod(SB1->B1_COD, 1, 3)
				(cAliasEmp)->(DBSkip())
				Loop
			EndIf
			//Não verifica saldo desses tipos de produto, pois com o parametro ativo
			//eles sao gerados automaticamente, logo não tem saldo ate serem apontados pelas OPs filha
			If lGeraOPI
				If SB1->B1_TIPO $ "PA,PI"
					(cAliasEmp)->(DBSkip())
					Loop
				EndIf
			EndIf
			//Alterar array com os dados dos saldos atuais

			nPosSld:= aScan(aSaldo, {|x| AllTrim(x[1]) == AllTrim((cAliasEmp)->D4_COD)})
			aSaldo[nPosSld][2]-= (cAliasEmp)->EMP

			//Saldo insuficiente
			If aSaldo[nPosSld][2] < 0
				//Preenche array dos saldos negativos para exibir em tela
				aAdd(aSaldoNeg, {(cAliasEmp)->D4_COD, aSaldo[nPosSld][2], (cAliasEmp)->D4_OP, SB1->B1_UM})
				//Array com as OP para verificar marcação, caso um dos componentes não tenha o saldo sera retirada a marcação
				nPosOP:= aScan(aOpMark, {|x| AllTrim(x[1]) == Left((cAliasEmp)->D4_OP, TamSX3("C2_NUM")[1])})
				If nPosOP == 0
					aAdd(aOpMark, {Left((cAliasEmp)->D4_OP, TamSX3("C2_NUM")[1]), .F.})
				ElseIf nPosOP > 0 .AND. aOpMark[nPosOP][2]
					aOpMark[nPosOP][2]:= .F.
				EndIf
			Else
				nPosOP:= aScan(aOpMark, {|x| AllTrim(x[1]) == Left((cAliasEmp)->D4_OP, TamSX3("C2_NUM")[1])})
				If nPosOP == 0
					aAdd(aOpMark, {Left((cAliasEmp)->D4_OP, TamSX3("C2_NUM")[1]), .T.})
				EndIf
			EndIf

			(cAliasEmp)->(DBSkip())

		EndDo
	Else 
		MsgInfo('Produto sem saldo em estoque.')	
	EndIf
	//Exibição dos saldos insuficientes
	If !Empty(aSaldoNeg)

		cHtml:= ImpSaldos(aSaldoNeg)
		DEFINE FONT oFont NAME "Arial" SIZE 6,15
		oDlg:= MsDialog():New(003, 001, 510, 625, OemToAnsi("Validação de Estoque OP"),,,,, CLR_BLACK, CLR_WHITE,,,.T.)
		oEdit:= tSimpleEditor():New(0, 0, oDlg, 312, 230, , .T.)
		oEdit:Load(cHtml)
		SButton():New(235, 115, 13, {|| (cFile:=cGetFile("Arquivos Texto (*.HTML) |*.html|",""), If(cFile="",.t.,MemoWrite(cFile,cHtml))) }, oDlg, .T.,,)
		SButton():New(235, 175, 01, {|| oDlg:End() }, oDlg, .T.,,)
		oDlg:Activate( , , ,.T., , ,)

	EndIf
	//Marcação das OP
	UpdMark(aOpMark, cMarca)

	RestArea(aAreaSC2)
	RestArea(aAreaSB1)

Return Nil

/*/{Protheus.doc} ImpSaldos
Monta HTML para exibir as OP com componentes com saldo insuficiente
@type function
@version 1.0
@author Normando NewSiga
@since 14/05/2020
@param aSaldoNeg, array, Lista de componentes com saldo insuficiente
@return character, Html com os saldos insuficientes
/*/
Static Function ImpSaldos(aSaldoNeg)
	Local cHtml:= ""
	Local nTamNum:= TamSX3("C2_NUM")[1]
	Local nTamSeq:= TamSX3("C2_SEQUEN")[1]
	Local cOp:= Space(nTamNum)
	Local cSeq:= Space(nTamSeq)
	local nI:= 0

	cHtml:= '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'+CRLF
	cHtml+= '<html xmlns="http://www.w3.org/1999/xhtml">'+CRLF
	cHtml+= '<head>'+CRLF
	cHtml+= '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
	//cHtml+= '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">'
	cHtml+= '    <style>   '+CRLF
	cHtml+= '    	table{ '+CRLF
	cHtml+= '    font-family:Arial, Helvetica, sans-serif; '+CRLF
	cHtml+= '    border-collapse:collapse; '+CRLF
	cHtml+= '        } '+CRLF
	cHtml+= '    </style>'+CRLF
	cHtml+= '</head>'+CRLF
	cHtml+= '<body>'+CRLF
	cHtml+= 'Filial: '+Right(cFilAnt, 2)+'<br>'+CRLF
	cHtml+= 'Tentativa de firmar OP'+CRLF

	For nI:= 1 To Len(aSaldoNeg)

		If Left(aSaldoNeg[nI][3], nTamNum) != Left(cOp, nTamNum)
			If !Empty(cOp) //Não é a primeira verificação, feche as tags
				cHtml+= '    </table>'+CRLF
			EndIf
			cOp:= aSaldoNeg[nI][3]
			cSeq:= " "
		EndIf

		If Substr(aSaldoNeg[nI][3], 9, nTamSeq) != cSeq
			If !Empty(cSeq) //Não é a primeira verificação, feche as tags
				cHtml+= '    </table>'+CRLF
			EndIf
			cSeq:= Substr(aSaldoNeg[nI][3], 9, nTamSeq)
			SC2->(MSSeek(xFilial("SC2")+aSaldoNeg[nI][3]))
			cHtml+= '<br><br>'+CRLF
			cHtml+= '    <table border="1" align="center" width="100%">'+CRLF
			cHtml+= '        <tr>'+CRLF
			cHtml+= '            <th colspan="3">ORDEM DE PRODUÇÃO '+aSaldoNeg[nI][3]+'</th>'+CRLF
			cHtml+= '        </tr>'+CRLF
			cHtml+= '        <tr>'+CRLF
			cHtml+= '            <th colspan="3">'+AllTrim(SC2->C2_PRODUTO)+" - "+AllTrim(Posicione("SB1", 1, xFilial("SB1")+SC2->C2_PRODUTO, "B1_DESC"));
				+" : "+AllTrim(Transform(SC2->C2_QUANT, "@E 9,999,999.99"))+'</th>'+CRLF
			cHtml+= '        </tr>'+CRLF
			cHtml+= '        <tr valign="middle">'+CRLF
			cHtml+= '            <th width="80%">PRODUTO</th>'+CRLF
			cHtml+= '            <th width="5%">U.M</th>'+CRLF
			cHtml+= '            <th width="15%">SALDO DISPONIVEL</th>'+CRLF
			cHtml+= '        </tr>'+CRLF
		EndIf
		cHtml+= '        <tr valign="middle">'+CRLF
		cHtml+= '            <td align="left"><b>'+AllTrim(aSaldoNeg[nI][1])+"</b> - "+AllTrim(Posicione("SB1", 1, xFilial("SB1")+aSaldoNeg[nI][1], "B1_DESC"))+'</td>'+CRLF
		cHtml+= '            <td align="center">'+aSaldoNeg[nI][4]+'</td>'+CRLF
		cHtml+= '            <td align="center">'+AllTrim(Transform(aSaldoNeg[nI][2], "@E 9,999,999.99"))+'</td>'+CRLF
		cHtml+= '        </tr>'+CRLF

		If nI == Len(aSaldoNeg) //Ultimo item
			cHtml+= '    </table>'+CRLF
			cHtml+= '</body>'+CRLF
			cHtml+= '</html>'+CRLF

			//FWMsgRun(, {|| U_EMAIL("normando.junior@newsiga.com.br","","Componentes sem saldo em estoque", cHtml, , .T.) }, "Aguarde...", "Enviando e-mail.")
		EndIf

	Next

Return cHtml

/*/{Protheus.doc} UpdMark
Verifica marcação das OP de acordo com o saldo dos componentes, se algum componente não tiver saldo desmarca.
@type function
@version 1.0
@author Normando NewSiga
@since 14/05/2020
@param aOpMark, array, Numero das ordens C2_NUM
@param cMarca, character, Marca do PARAMIXB[1]
/*/
Static Function UpdMark(aOpMark, cMarca)
	Local nI:= 1

	For nI:= 1 To Len(aOpMark)

		SC2->(MSSeek(xFilial("SC2")+aOpMark[nI][1]))
		While SC2->(!EOF()) .AND. aOpMark[nI][1] == SC2->C2_NUM
			SC2->(RecLock("SC2",.F.))
			If	aOpMark[nI][2]
				SC2->C2_OK:= cMarca
				SC2->C2_XDTFIRM:= DDATABASE
			Else
				SC2->C2_OK:= " "
			EndIf

			SC2->(MsUnlock())
			SC2->(DBSkip())
		EndDo

	Next

Return Nil
