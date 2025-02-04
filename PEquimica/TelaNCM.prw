#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"
#Include "TOPCONN.ch"


user Function TelaNCM()
	local oBrowse

	oBrowse := FWMBrowse():NEW()

	oBrowse:SetAlias('ZNC')

	oBrowse:SetDescription(" NCM para documento de saida ")

	oBrowse:SetMenuDef('TelaNCM')

	oBrowse:AddLegend( "ZNC->ZNC_BLQL == '1'" , "GREEN", "Ativo" )
	oBrowse:AddLegend( "ZNC->ZNC_BLQL == '2'",  "RED" , "Bloqueado" )

	oBrowse:Activate()

Return

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.TelaNCM' OPERATION MODEL_OPERATION_INSERT  ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.TelaNCM' OPERATION MODEL_OPERATION_VIEW    ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Legenda'    ACTION 'u_zNCMLeg'       OPERATION 6                       ACCESS 0 //OPERATION X
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.TelaNCM' OPERATION MODEL_OPERATION_UPDATE  ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.TelaNCM' OPERATION MODEL_OPERATION_DELETE  ACCESS 0 //OPERATION 5

Return aRotina


Static Function ModelDef()

	local oModel    := MpFormModel():New("TelaNCMM",/*bPre*/, /*bPos*/,, )
	local oStruZED  := FWformStruct(1,'ZNC')

	oModel:AddFields('ZNC_TOPO',, oStruZED)

	oModel:SetPrimaryKey({'ZNC_FILIAL','ZNC_NCM'})

	oModel:SetDescription("Documentos Vencidos - MVC")

	oModel:GetModel('ZNC_TOPO'):SetDescription("Documento Vencido")

Return oModel

Static Function ViewDef()

	local oModel        := FwloadModel('TelaNCM')
	local cCampos      := "|ZNC_FILIAL|ZNC_NCM|ZNC_PROD|ZNC_BLQL|"
	local oStruZEDa     := FWformStruct(2,'ZNC', {|x| AllTrim(x) + "|" $ cCampos })
	local oView

	oView  := FwFormView():New()

	oView:SetModel(oModel)

	oView:AddField('VIEW_ZNCa',oStruZEDa,'ZNC_TOPO')

	oView:CreateHorizontalBox("CABEC" , 100)

	oView:EnableTitleView('VIEW_ZNCa', 'Dados do Documento' )

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.F.})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_ZNCa","CABEC")
Return oView


User Function zNCMLeg()
	Local aLegenda := {}

	//Monta as cores
	AADD(aLegenda,{"BR_VERDE",       "Ativo"  })
	AADD(aLegenda,{"BR_VERMELHO",    "Bloqueado"})

	BrwLegenda("NCM", "Procedencia", aLegenda)
Return

