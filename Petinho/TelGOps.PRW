#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

#DEFINE  CABECALHO  "ZOP_FILIAL/ZOP_NPRO/ZOP_PROD/ZOP_DESC/ZOP_DATA/ZOP_HORA/ZOP_DATFIM/ZOP_HRFIM/ZOP_QUANT/ZOP_LEITUR/ZOP_NUMOP/ZOP_LOTE/ZOP_STATUS/"
#DEFINE  ITENS      "ZOS_FILIAL/ZOS_NPRO/ZOS_ITEM/ZOS_PROD/ZOS_DESC/ZOS_QUANT/ZOS_LOTE/"
Static 	 cTitle :=  "Tela de controle para geraÁ„o de OPs"

*******************************************************************************
// FunÁ„o : TelGOps()                                                      	  |
// Fonte  : TelGOps.PRW                                                       |
// Utilidade : Tela MVC modelo 2 - com dados do produto acabado (PA) e qual o |
//                   produto base para a produÁ„o do mesmo                    |
// ---------+-------------------------+---------------------------------------+
// Data     | Autor                   | Descricao                             |
// ---------+-------------------------+-------------------------------------- +
// 04/10/23 | Rivaldo J˙nior - CodERP | AlteraÁ„o salario do funcion·rio	  |
*******************************************************************************

User Function TelGOps()
	Local oBrowse := NIL

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZOP') // Alias da tabela utilizada
	oBrowse:SetDescription(cTitle)
	oBrowse:DisableDetails()

	oBrowse:AddLegend( "ZOP->ZOP_STATUS == '1' ", "GREEN" , "Criada" 	  )
    oBrowse:AddLegend( "ZOP->ZOP_STATUS == '2' ", "YELLOW", "Em andamento")
    oBrowse:AddLegend( "ZOP->ZOP_STATUS == '3' ", "RED"   , "Finalizada"  )
    oBrowse:Activate()

Return

User Function MVCLeg()
	Local aLegenda := {}

	//Monta as cores
	AADD(aLegenda,{"BR_VERDE"	,  "Criada"	     })
	AADD(aLegenda,{"BR_AMARELO"	,  "Em andamento"})
	AADD(aLegenda,{"BR_VERMELHO",  "Finalizada"	 })

	BrwLegenda("Status das Ops", "Ops e apontamentos", aLegenda)
Return


/*////////////////////////////////////////////////////////////////////////////////*/ *
/*@nomeFunction: 	  					MenuDef()							   	  */ *
/*--------------------------------------------------------------------------------*/ *
/*									Menu do Browser					  			  */ *
/*--------------------------------------------------------------------------------*/ *
/*@author: 						Rivaldo.J˙nior - CodERP							  */ *
/*@since: 				    	  	   04/10/2023								  */ *
/*////////////////////////////////////////////////////////////////////////////////*/ *

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.TelGOps' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    	ACTION 'VIEWDEF.TelGOps' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    	ACTION 'VIEWDEF.TelGOps' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    	ACTION 'VIEWDEF.TelGOps' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Legenda'    	ACTION 'U_MVCLeg'        OPERATION 6 ACCESS 0
	ADD OPTION aRotina TITLE 'Etiquetas OP' ACTION 'U_etqOP'         OPERATION 6 ACCESS 0

	//ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.TelGOps' OPERATION 8 ACCESS 0
	//ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.TelGOps' OPERATION 9 ACCESS 0

Return aRotina



/*////////////////////////////////////////////////////////////////////////////////*/ *
/*@nomeFunction: 	  					ModelDef()							   	  */ *
/*--------------------------------------------------------------------------------*/ *
/*							   Modelo do cabecalho e grid		  				  */ *
/*--------------------------------------------------------------------------------*/ *
/*@author: 						Rivaldo.J˙nior - CodERP							  */ *
/*@since: 				    	  	   04/10/2023								  */ *
/*////////////////////////////////////////////////////////////////////////////////*/ *

Static Function ModelDef()
	Local oModel   := Nil
	Local oStPai   := FWFormStruct( 1, 'ZOP', { |cCampo|  AllTrim( cCampo ) + '/' $ CABECALHO } )
	Local oStFilho := FWFormStruct( 1, 'ZOS', { |cCampo|  AllTrim( cCampo ) + '/' $ ITENS }  )

	oModel := MPFormModel():New("MTelGOps", /*{|oModel| MDMVlPre( oModel ) }bPre*/, /*{|oModel| MDMVlPos( oModel ) }/*bPos*/,/*{||ComplZZ3( Self ) }bCommit*/,/*bCancel*/)
	oModel:SetDescription(OemtoAnsi("Ops e apontamentos"))
	oModel:AddFields('ZOPMASTER',/*cOwner*/,oStPai, /*bCamValid bPreValidacao*/, /*bPosValidacao*/, /*{ || AN001(oModel)}*/)
	oModel:AddGrid('ZOSDETAIL','ZOPMASTER' ,oStFilho, /*{|oModel,nLine,cAction| linePreGrid(oModel,nLine, cAction)}*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/)//, {|oModel|AN002( oModel ) } )

	oModel:SetPrimaryKey( { "ZOP_FILIAL" , "ZOS_NPRO" })//Chave primaria
	oModel:SetRelation('ZOSDETAIL', {{'ZOS_FILIAL','xfilial("ZOS")'},{'ZOS_NPRO','ZOP_NPRO'}}, ZOS->( IndexKey( 1 ) ))//Relacionamento das tabelas

	//Setando as descriùùes
	oModel:GetModel('ZOPMASTER'):SetDescription('Produto acabado (PA)')
	oModel:GetModel('ZOSDETAIL'):SetDescription('Produto base')

Return oModel



/*////////////////////////////////////////////////////////////////////////////////*/ *
/*@nomeFunction: 	  					ViewDef()							   	  */ *
/*--------------------------------------------------------------------------------*/ *
/*							  ExibiÁao do cabecalho e grid		  				  */ *
/*--------------------------------------------------------------------------------*/ *
/*@author: 						Rivaldo.J˙nior - CodERP							  */ *
/*@since: 				    	  	   04/10/2023								  */ *
/*////////////////////////////////////////////////////////////////////////////////*/ *

Static Function ViewDef()
	Local oView     := Nil
	Local oModel    := FWLoadModel('TelGOps')
	Local oStPai 	:= FWFormStruct( 2, 'ZOP' ,{ |cCampo|  AllTrim( cCampo ) + '/' $ CABECALHO } )
	Local oStFilho 	:= FWFormStruct( 2, 'ZOS' ,{ |cCampo|  AllTrim( cCampo ) + '/' $ ITENS } )

	// Campos que ser„o removidos da View
	oStPai:removeField("ZOP_STATUS")
	oStFilho:removeField("ZOS_NPRO")

	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Adicionando os campos do cabeùalho e o grid dos filhos
	oView:AddField('VIEW_CAB', oStPai ,'ZOPMASTER')
	oView:AddGrid( 'VIEW_DET',oStFilho,'ZOSDETAIL')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',40)
	oView:CreateHorizontalBox('GRID' ,60)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB','CABEC')
	oView:SetOwnerView('VIEW_DET' ,'GRID')

	//Habilitando tÌtulo
	oView:EnableTitleView('VIEW_CAB','Produto acabado (PA)')
	oView:EnableTitleView('VIEW_DET','Produtos base')

	oView:AddIncrementField('VIEW_DET', 'ZOS_ITEM')

Return oView
