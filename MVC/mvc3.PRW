#Include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

user Function mvc1()
local oBrowse
Private cCadastro := "Cadastro de produtos -- MVC"


oBrowse := FWMBrowse():NEW()

oBrowse:SetAlias('SB1')

oBrowse:SetDescription("Cadastro de produtos -- MVC")

oBrowse:AddLegend("B1_tipo == 'PA'", "YELLOW"   ,   "Produto acabado")
oBrowse:AddLegend("B1_tipo == 'PI'", "ORANGE"   ,   "Produto intermediario")
oBrowse:AddLegend("B1_tipo == 'MP'", "BLUE"     ,   "Materia Prima ")
oBrowse:AddLegend("B1_tipo == 'MO'", "RED"      ,   "Mão de obra")
oBrowse:AddLegend("B1_tipo == 'EM'", "GREEN"    ,   "Embalagem")

oBrowse:SetFilterDefault("!Empty(B1_TIPO)")

oBrowse:SetMenuDef('mvc1')

oBrowse:Activate()


Return

Static Function MenuDef()
 Local aRotina := {} 


add Option aRotina TITLE "Pesquisar"    Action 'PesqBrw'        OPERATION 1 ACCESS 0
add Option aRotina TITLE "Vizualizar"   Action 'VIEWDEF.MVC1'   OPERATION 2 ACCESS 0
add Option aRotina TITLE "Incluir"      Action 'VIEWDEF.MVC1'   OPERATION 3 ACCESS 0
add Option aRotina TITLE "Alterar"      Action 'VIEWDEF.MVC1'   OPERATION 4 ACCESS 0
add Option aRotina TITLE "Excluir"      Action 'VIEWDEF.MVC1'   OPERATION 5 ACCESS 0
add Option aRotina TITLE "Legenda"      Action 'U_legMVC01'     OPERATION 6 ACCESS 0


Return aRotina


Static Function ModelDef()
local oModel
local oStruSB1

oModel := MpFormModel():New('MVCM')

oStruSB1 := FWformStruct(1,'SB1')

oModel:AddFields('SB1MASTER', ,oStruSB1)

oModel:SetDescription("Modelo de dados - cadastro de produtos")

oModel:GetModel('SB1MASTER'):SetDescription("Dados do produto")

oModel:SetPrimaryKey({'B1_FILIAL', 'B1_COD'})

Return oModel

Static Function ViewDef()
local oModel
local oStruSB1
local oView

oModel := FwloadModel('mvc1')

oStruSB1 := FWformStruct(2,'SB1')

oView := FwFormView():New()

oView:SetModel(oModel)

oView:AddFields('VIEW_SB1', oStruSB1, 'SB1MASTER')

oView:CreateHorizontalBox("Formulario", 100)

oView:SetOwnerView('VIEW_SB1', 'Formulario')





Return oView

user Function LegMVC01()
    local aLegenda := {}

    Aadd(aLegenda, {"BR_AMARELO"    , "produto acabado"         })
    Aadd(aLegenda, {"BR_LARANJA"    , "Produto intermediario"   })
    Aadd(aLegenda, {"BR_AZUL"       , "Materia Prima "          })
    Aadd(aLegenda, {"BR_VERMELHO"   , "Mão de obra"             })
    Aadd(aLegenda, {"BR_VERDE"      , "Embalagem"               })

    BrwLegenda("Tipos de produtos", "legenda", aLegenda)

Return 
