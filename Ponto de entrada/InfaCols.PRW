#INCLUDE 'totvs.ch'

User Function InfaCols()

    Local cProd := AllTrim(SD3->D3_COD)
    Local cDesc := AllTrim(SD3->D3_DESCRI)
	Local oModal
	Local oContainer
	//Local cSC2Alias := GetNextAlias()
	Local aButtons := {}
	Private aHeadSC2 := {}
	Private aArrayC2  := {}

	oModal  := FWDialogModal():New()
	oModal:SetEscClose(.T.)
	oModal:setTitle("transferencia OP")
	oModal:setSubTitle("Visualiza��o das OPs do produto")
	oModal:setSize(160, 300)
	oModal:createDialog()
	oModal:addCloseButton(nil, "Fechar")
	oContainer  := TPanel():New(01,100,, oModal:getPanelMain() )
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT

	TSay():New(03,03  ,{|| "Produto : " + cProd + "               Descri��o : " +cDesc       },oContainer,,,,,,.T.,,,200,20,,,,,,.T.)

	aAdd(aHeadSC2, {"Cod. Produto"  ,   "C2_PRODUTO",   "",     TamSX3("C2_PRODUTO")[01],   0,".T." ,".T.", "C", "",    ""} )
	aAdd(aHeadSC2, {"Armazem Prod. Origem",    "C2_LOCAL" ,   "",     TamSX3("C2_LOCAL")[01] ,   0,".T." ,".T.", "C", "",    ""} )
	aAdd(aHeadSC2, {"Armazem Prod. Destino",    "C2_LOCAL" ,   "",     TamSX3("C2_LOCAL")[01] ,   0,".T." ,".T.", "C", "",    ""} )
	aAdd(aHeadSC2, {"Quant. Estoque Origem",   "C2_QUANT"    ,   "",     TamSX3("C2_QUANT")[01] ,   0,".T.",".T.", "N", "",    ""} )
	aAdd(aHeadSC2, {"Quant. Estoque Destino",   "C2_QUANT"    ,   "",     TamSX3("C2_QUANT")[01] ,   0,".T.",".T.", "N", "",    ""} )

	//BeginSql Alias cSC2Alias
	//		SELECT C2_NUM , C2_PRODUTO, C2_ITEM, C2_LOCAL , C2_QUANT
	//		FROM %Table:SC2% SC2  
	//		WHERE SC2.%notdel%
	//		AND SC2.C2_FILIAL =  %xFilial:SC2%
    //        AND C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD IN %Exp:SD3->D3_OP%
	//		ORDER BY C7_ITEM
	//EndSql

	//DbSelectArea(cSC2Alias)
	//While (cSC2Alias)->(!Eof())
		Aadd(aArrayC2, { "asdsadasdads","asdasdasdas","",233, 233,.F.})
		Aadd(aArrayC2, { cProd,"asdasdasdas","sadsadsd" ,244,233,.F.})
	//	(cSC2Alias)->(DbSkip())
	// End
	//(cSC2Alias)->(DbCloseArea())
	oMsGetSBM := MsNewGetDados():New(    20,;                //nTop      - Linha Inicial
	03,;                			//nLeft     - Coluna Inicial
	110,;    						 //nBottom   - Linha Final
	297,;     						//nRight    - Coluna Final
	,;                   //nStyle    - Estilos para edi��o da Grid (GD_INSERT = Inclus�o de Linha; GD_UPDATE = Altera��o de Linhas; GD_DELETE = Exclus�o de Linhas)
	"AllwaysTrue()",;    //cLinhaOk  - Valida��o da linha
	,;                   //cTudoOk   - Valida��o de todas as linhas
	"",;                 //cIniCpos  - Fun��o para inicializa��o de campos
	{},;                //aAlter    - Colunas que podem ser alteradas
	,;                   //nFreeze   - N�mero da coluna que ser� congelada
	9999,;               //nMax      - M�ximo de Linhas
	,;                   //cFieldOK  - Valida��o da coluna
	,;                   //cSuperDel - Valida��o ao apertar '+'
	,;                   //cDelOk    - Valida��o na exclus�o da linha
	oContainer,;            //oWnd      - Janela que � a dona da grid
	aHeadSC2,;           //aHeader   - Cabe�alho da Grid
	aArrayC2)
	AAdd(aButtons,{'',"Voltar", , ,0,.T.,.F.} )
	oModal:addButtons(aButtons)
	oModal:Activate()
Return 0


