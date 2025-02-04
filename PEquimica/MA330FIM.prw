#Include "PROTHEUS.ch"
/*/{Protheus.doc} MA330FIM
	Ponto de entrada na finalização do custo médio
	Atualiza o campo D4_XCMEDIO
	@type  Function
	@author ricardo rotta
	@since 16/09/24
	@version 1.0
	@return , a Função não tem retorno 
/*/

User Function MA330FIM

	Local aArea  := GetArea()
	Local dDTFim := a330ParamZX[01]
	Processa ({||u_AtuCusSD4(dDTFim)})
	RestArea(aArea)
Return
//----------------------------------------------------------------------------------------
User Function AtuCusSD4(dDTFim)

	Local aArea     := GetArea()
	Local cAliasSD3 := GetNextAlias()
	Local dDataINI  := FirstDay(dDTFim)
	Local dDataFIM  := dDTFim
	Local cProduto  := CriaVar("D3_COD", .F.)
	Local cOP       := CriaVar("D3_OP", .F.)
	Local cTRT      := CriaVar("D3_TRT", .F.)
	Local nQuant    := 0
	Local nCusto    := 0
	Local nCM1      := 0

	BeginSql Alias cAliasSD3
    SELECT D3_OP, D3_TRT, D3_COD, D3_QUANT, SD4.D4_QTDEORI, D3_CUSTO1, SD4.D4_XCUST
    FROM %Table:SD3% SD3, %Table:SD4% SD4
    WHERE D3_FILIAL = %xFilial:SD3%
    AND D3_EMISSAO >= %Exp:Dtos(dDataINI)%
    AND D3_EMISSAO <= %Exp:Dtos(dDataFIM)%
    AND D3_ESTORNO = ' '
    AND D3_CF LIKE 'RE%'
    AND D3_OP = D4_OP
    AND D3_TRT = SD4.D4_TRT
    AND SD3.D3_COD = SD4.D4_COD
    AND SD3.%NotDel%
    AND SD4.%NotDel%
    ORDER BY D3_COD, D3_OP, D3_TRT
	EndSql
	While (cAliasSD3)->(!Eof())
		cProduto := (cAliasSD3)->D3_COD
		cOP      := (cAliasSD3)->D3_OP
		cTRT     := (cAliasSD3)->D3_TRT
		nQuant   := (cAliasSD3)->D4_QTDEORI
		nCusto   := QtdComp((cAliasSD3)->D3_CUSTO1)
		nCM1     := Round(nCusto / nQuant, TAMSX3("D4_XCMREAL")[2])
		SD4->(dbSetOrder(1))
		If SD4->(dbSeek(xFilial("SD4")+cProduto+cOP+cTRT))
			RecLock("SD4", .F.)
			Replace D4_XCMEDIO with nCusto,;
				D4_XCMREAL with nCM1
			MsUnLock()
		Endif
		(cAliasSD3)->(dbSkip())
	End
	(cAliasSD3)->(dbCloseArea())
	RestArea(aArea)
Return
//---------------------------------------------------------------------------------------
User Function PCustSD4

	Local oProcess  := MsNewProcess():New( { || u_AtuCusSD4(dDTFim) },"Processamento" + "...", "Aguarde..." + "...", .F. ) // Processamento //
	Local cPerg     := "PCUSTSD401"
	Local dDTFim    := Ctod("")

	AjustaSx1(cPerg)
	If Pergunte(cPerg)
		dDTFim := mv_par01
		If MsgYesNo("Este programa atualizará o campo D4_XCMEDIO de acordo com o custo médio calculado de acordo com as requisições"+;
				"Necessário rodar a rotina de custo para atualizar o campo de custo das requisições" + CRLF +;
				"Deseja continuar?","Atualização do custo nos Empenhos")
			oProcess:Activate()
		EndIf
	EndIf
Return
//--------------------------------------------------------------------------------
Static Function AjustaSx1(cPerg)

	Local aArea := GetArea()
	Local aRegs := {}
	Local i,j
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	Aadd(aRegs,{cPerg,"01","Data Custo      ?","Da Emissao           ?","Da Emissao          ?","mv_ch1","D",8                 ,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","" ," ","",""})
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
	RestArea(aArea)
Return
