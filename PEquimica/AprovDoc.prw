#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"
#Include "TOPCONN.ch"


user Function AprovDoc()
	local oBrowse

	oBrowse := FWMBrowse():NEW()

	oBrowse:SetAlias('ZF1')

	oBrowse:SetDescription(" Documentos Vencidos ")

	oBrowse:SetMenuDef('AprovDoc')

	oBrowse:AddLegend( "!Empty(ZF1->ZF1_USERAP)" , "GREEN", "Aprovado" )
	oBrowse:AddLegend( "Empty(ZF1->ZF1_USERAP)",  "RED" , "Aguardando Aprovacao" )

	oBrowse:Activate()

Return

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.AprovDoc' OPERATION 1                      ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Legenda'    ACTION 'u_zMVC01Leg'      OPERATION 6                      ACCESS 0 //OPERATION X
	ADD OPTION aRotina TITLE 'Aprovar'    ACTION 'u_Aprovar'        OPERATION MODEL_OPERATION_UPDATE   ACCESS 0 //OPERATION 3
	//ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.AprovDoc' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	//ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.AprovDoc' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRotina


Static Function ModelDef()

	local oModel    := MpFormModel():New("AprovDocM",/*bPre*/, /*bPos*/,, )
	local oStruZED  := FWformStruct(1,'ZF1')

	oModel:AddFields('ZF1_TOPO',, oStruZED)

	oModel:SetPrimaryKey({'ZF1_FILIAL','ZF1_DOC'})

	oModel:SetDescription("Documentos Vencidos - MVC")

	oModel:GetModel('ZF1_TOPO'):SetDescription("Documento Vencido")

Return oModel

Static Function ViewDef()

	local oModel        := FwloadModel('AprovDoc')
	local cCampos      := "ZF1_FILIAL|ZF1_DOC|ZF1_SERIE|ZF1_FORNEC|ZF1_LOJA|ZF1_TIPO"
	local oStruZEDa     := FWformStruct(2,'ZF1', {|x| AllTrim(x) + "|" $ cCampos })
	local oView

	oView  := FwFormView():New()

	oView:SetModel(oModel)

	oView:AddField('VIEW_ZF1a',oStruZEDa,'ZF1_TOPO')

	oView:CreateHorizontalBox("CABEC" , 100)

	oView:EnableTitleView('VIEW_ZF1a', 'Dados do Documento' )

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.F.})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_ZF1a","CABEC")
Return oView

User Function Aprovar()
	If ZF1->(!EOF())
		if MSGYESNO('Deseja aprovar a nota atrasada? ','Aprovação')
			Reclock('ZF1',.F.)
			ZF1->ZF1_USERAP := cUserName
			ZF1->(MsUnlock())
		EndIf
	EndIf
Return .T.
User Function zMVC01Leg()
	Local aLegenda := {}

	//Monta as cores
	AADD(aLegenda,{"BR_VERDE",       "Aprovado"  })
	AADD(aLegenda,{"BR_VERMELHO",    "Aguardando Aprovacao"})

	BrwLegenda("Documentos Vencidos", "Procedencia", aLegenda)
Return
