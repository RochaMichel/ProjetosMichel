#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"
#Include "TOPCONN.ch"


user Function MvcZed()
	local oBrowse
	
	oBrowse := FWMBrowse():NEW()

	oBrowse:SetAlias('ZED')

	oBrowse:SetDescription(" Naturezas DRE. ")

	oBrowse:SetMenuDef('MvcZed')

	oBrowse:Activate()

Return

Static Function MenuDef()
	Local aRotina := {}

    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.MvcZed' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.MvcZed' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.MvcZed' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.MvcZed' OPERATION 5 ACCESS 0

Return aRotina


Static Function ModelDef()

	local oModel    := MpFormModel():New("MvcZed1",/*bPre*/, /*bPos*/,{|oModel|Grava(oModel)}, )
	local oStruZED  := FWformStruct(1,'ZED')
	
	oModel:AddFields('ZED_TOPO',, oStruZED)
	
	oModel:SetPrimaryKey({'ZED_FILIAL', 'ZED_COD'})

	oModel:SetDescription("Naturezas DRE - MVC")

	oModel:GetModel('ZED_TOPO'):SetDescription("Natureza DRE")
	
Return oModel

Static Function ViewDef()

	local oModel        := FwloadModel('MvcZed')
    local cCampos1      := "ZED_COD|ZED_DESC|"
    local cCampos2      := "ZED_NATED|ZED_CC|"
	local oStruZEDa     := FWformStruct(2,'ZED', {|x| AllTrim(x) + "|" $ cCampos1 })
	local oView      
	local oStruZEDb     := FWformStruct(2,'ZED', {|x| AllTrim(x) + "|" $ cCampos2 })

	oView  := FwFormView():New()

	oView:SetModel(oModel)

	oView:AddField('VIEW_ZEDa',oStruZEDa,'ZED_TOPO')
	oView:AddGrid('VIEW_ZEDb',oStruZEDb,'ZED_GRIDc')

	oView:CreateHorizontalBox("CABEC" , 30)
	oView:CreateHorizontalBox("GRIDc" , 70)
	
	oView:EnableTitle("VIEW_ZEDa", "Naturezas DRE")
	oView:EnableTitle("VIEW_ZEDb"  , "Natureza e Conta contabil")
	
	oView:CreateFolder("Pastas","CABEC")
	oView:AddSheet('Pastas', 'ABA01', "Naturezas DRE")

	oView:CreateHorizontalBox("CABEC", 100, , ,"Pastas","ABA01")

	oView:CreateFolder("Pastas_Grid","GRIDc")
	oView:AddSheet('Pastas_Grid', 'ABA_Grid1', "Natureza e Conta contabil")

	oView:CreateHorizontalBox("GRIDc", 100, , ,"Pastas_Grid","ABA_Grid1")
	
	oView:SetOwnerView('VIEW_ZEDa'  , 'CABEC')
	oView:SetOwnerView('VIEW_ZEDb'  , 'GRIDc')

	oView:SetCloseOnOk({||.F.})

Return oView

Static Function Grava(oModel)
Local oCad    := oModel:GetModel("MvcZed")
DbSelectArea('ZED')
RecLock("ZED",.T.)
ZED->ZED_COD   :=  oCad:GetValue('ZED_COD')        
ZED->ZED_DESC  :=  oCad:GetValue('ZED_DESC')     
ZED->ZED_NATED :=  oCad:GetValue('ZED_NATED')   
ZED->ZED_CC    :=  oCad:GetValue('ZED_CC')   
ZED->(MsUnlock())
Return .T.

