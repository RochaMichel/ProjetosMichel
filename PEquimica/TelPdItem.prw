#Include 'Protheus.ch'
#Include 'RwMake.ch'
#Include 'TopConn.ch'

user function TelPdItem()

	local oBrowse := nil
	Local cAliasSC6 := GetNextAlias()
	Local aDados := {}
	Static oDlg

	BeginSql ALias cAliasSC6
	    Select C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, C6_QTDVEN, C6_VALOR, C6_ENTREG
	    FROM %Table:SC6% SC6
	    WHERE C6_NUM = %Exp:SC5->C5_NUM%
	    AND C6_FILIAL = %Exp:SC5->C5_FILIAL%
	    AND SC6.%notDel%
        ORDER BY C6_ITEM
	EndSql

	DEFINE MSDIALOG oDlg TITLE "Tela de Cadastro" FROM 000, 000  TO 300, 1100 COLORS 1, 12632256 PIXEL
	While (cAliasSC6)->(!EOF())
		aAdd( aDados, { (cAliasSC6)->C6_FILIAL, (cAliasSC6)->C6_NUM, (cAliasSC6)->C6_ITEM,;
			Posicione('SB1',1,xFilial('SB1')+(cAliasSC6)->C6_PRODUTO,'B1_DESC'),cValToChar((cAliasSC6)->C6_QTDVEN),;
			cValToChar((cAliasSC6)->C6_VALOR),DtoC(StoD((cAliasSC6)->C6_ENTREG)) })
		(cAliasSC6)->(dbSkip())
	End
	oBrowse := MsBrGetDBase():new( 0, 0, 580, 170,,,, oDlg,,,,,,,,,,,, .F., "", .T.,, .F.,,, )

	oBrowse:setArray( aDados )

	oBrowse:addColumn( TCColumn():new( "Filial", { || aDados[oBrowse:nAt, 1] },,,, "LEFT",, .F., .F.,,,, .F. ) )
	oBrowse:addColumn( TCColumn():new( "Número", { || aDados[oBrowse:nAt, 2] },,,, "LEFT",, .F., .F.,,,, .F. ) )
	oBrowse:addColumn( TCColumn():new( "Item", { || aDados[oBrowse:nAt, 3] },,,, "LEFT",, .F., .F.,,,, .F. ) )
	oBrowse:addColumn( TCColumn():new( "Desc. Produto", { || aDados[oBrowse:nAt, 4] },,,, "LEFT",, .F., .F.,,,, .F. ) )
	oBrowse:addColumn( TCColumn():new( "quantidade", { || aDados[oBrowse:nAt, 5] },,,, "RIGHT",, .F., .F.,,,, .F. ) )
	oBrowse:addColumn( TCColumn():new( "valor", { || aDados[oBrowse:nAt, 6] },,,, "RIGHT",, .F., .F.,,,, .F. ) )
	oBrowse:addColumn( TCColumn():new( "Dt. entrega", { || aDados[oBrowse:nAt, 7] },,,, "CENTER",, .F., .F.,,,, .F. ) )
	oBrowse:Refresh()

	ACTIVATE MSDIALOG oDlg CENTERED

return
