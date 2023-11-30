#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} User Function AltDtC71
	Altera data de entrega
	@type  Function
	@author Helton Silva
	@since 02/12/2022
/*/
User Function AltDtC71()

	Local oModal
	Local oContainer
	Local cSC7Alias := GetNextAlias()
	Local aButtons := {}
	Private cPedCom   := SC7->C7_NUM
	Private aHeadSC7 := {}
	Private aArrayC7  := {}

	oModal  := FWDialogModal():New()
	oModal:SetEscClose(.T.)
	oModal:setTitle("Pedido de Compra")
	oModal:setSubTitle("Alteração da Data de Entrega")
	oModal:setSize(160, 300)
	oModal:createDialog()
	oModal:addCloseButton(nil, "Fechar")
	oContainer  := TPanel():New(01,100,, oModal:getPanelMain() )
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT

	TSay():New(03,03  ,{|| "Ped.Compra : " + cPedCom  },oContainer,,,,,,.T.,,,200,20,,,,,,.T.)

	aAdd(aHeadSC7, {"Item"          ,   "C7_ITEM"   ,   "",     TamSX3("C7_ITEM")[01]   ,   0,".T." ,".T.", "C", "",    ""} )
	aAdd(aHeadSC7, {"Cod. Produto"  ,   "C7_PRODUTO",   "",     TamSX3("C7_PRODUTO")[01],   0,".T." ,".T.", "C", "",    ""} )
	aAdd(aHeadSC7, {"Descr. Produto",   "C7_DESCRI" ,   "",     TamSX3("C7_DESCRI")[01] ,   0,".T." ,".T.", "C", "",    ""} )
	aAdd(aHeadSC7, {"DT. Entrega"   ,   "DATPRF"    ,   "",     TamSX3("C7_DATPRF")[01] ,   0,"U_AltDtC72(M->DATPRF)",".T.", "D", "",    ""} )

	BeginSql Alias cSC7Alias
			SELECT C7_ITEM, C7_PRODUTO, C7_DESCRI, C7_DATPRF AS DATPRF
			FROM %Table:SC7% SC7  
			WHERE SC7.%notdel%
			AND SC7.C7_FILIAL =  %xFilial:SC7%
            AND SC7.C7_NUM  = %Exp:SC7->C7_NUM%
			ORDER BY C7_ITEM
	EndSql

	DbSelectArea(cSC7Alias)
	While (cSC7Alias)->(!Eof())
		Aadd(aArrayC7, { (cSC7Alias)->C7_ITEM,(cSC7Alias)->C7_PRODUTO,;
			(cSC7Alias)->C7_DESCRI, STOD((cSC7Alias)->DATPRF) ,.F.})
		(cSC7Alias)->(DbSkip())
	End
	(cSC7Alias)->(DbCloseArea())
	oMsGetSBM := MsNewGetDados():New(    20,;                //nTop      - Linha Inicial
	03,;                			//nLeft     - Coluna Inicial
	110,;    						 //nBottom   - Linha Final
	297,;     						//nRight    - Coluna Final
	GD_UPDATE,;                   //nStyle    - Estilos para edição da Grid (GD_INSERT = Inclusão de Linha; GD_UPDATE = Alteração de Linhas; GD_DELETE = Exclusão de Linhas)
	"AllwaysTrue()",;    //cLinhaOk  - Validação da linha
	,;                   //cTudoOk   - Validação de todas as linhas
	"",;                 //cIniCpos  - Função para inicialização de campos
	{'DATPRF'},;                //aAlter    - Colunas que podem ser alteradas
	,;                   //nFreeze   - Número da coluna que será congelada
	9999,;               //nMax      - Máximo de Linhas
	,;                   //cFieldOK  - Validação da coluna
	,;                   //cSuperDel - Validação ao apertar '+'
	,;                   //cDelOk    - Validação na exclusão da linha
	oContainer,;            //oWnd      - Janela que é a dona da grid
	aHeadSC7,;           //aHeader   - Cabeçalho da Grid
	aArrayC7)
	AAdd(aButtons,{'',"Confirmar", {||Salvar(oModal),oModal:DeActivate()}, ,0,.T.,.F.} )
	oModal:addButtons(aButtons)
	oModal:Activate()
Return

Static Function Salvar(oModal)
    Local aColsAux := oMsGetSBM:aCols
    Local nL   := 0
    Local aAreaC7  := SC7->(GetArea())

    DbSelectArea('SC7')
    DbSetOrder(1)
    For nL := 1 To Len(aColsAux)
        If SC7->(DbSeek(xFilial('SC7')+cPedCom+aColsAux[nL,1]))
            SC7->(RecLock("SC7", .F.))
               SC7->C7_DATPRF := aColsAux[nL,4]
            SC7->(MsUnlock())
		Endif	
    Next
	RestArea(aAreaC7)
Return

User Function AltDtC72(dData)
	Local lRet := dData >= Date()
	If !lRet
		MsgStop("A data não pode ser menor que a data atual", "Data invalida")
	EndIf
Return lRet
