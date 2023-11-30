//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'


#DEFINE  CABECALHO  "ZED_COD/ZED_DESC/ZED_REC/"
#DEFINE  ITENS      "ZED_NATSED/ZED_CC/"
Static 	 cTitle :=  "Natureza ZED"

*-------------------------------------------------------------------------------------
************************************************************************************ X
/*@nomeFunction: 	  					U_MvcZed()						   		  */ *
/*--------------------------------------------------------------------------------*/ *
/*							  Função de Montagem da Tela MVC	 				  */ *
/*					 	      Gravando os Dados na Tabela ZED				  */ *
/*					  Tela de Vinculo das Naturezas e centro de custos			  */ *
/*--------------------------------------------------------------------------------*/ *
/*@author: 						Michel.Rocha - CodERP							  */ *
/*@since: 				    	  	   30/05/2023								  */ *
************************************************************************************ X
*-------------------------------------------------------------------------------------
User Function MvcZed()
	Local oBrowse := NIL

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZED')                               // Alias da tabela utilizada
	oBrowse:SetDescription(cTitle)
	oBrowse:DisableDetails()
	oBrowse:Activate()

Return
	*-------------------------------------------------------------------------------------
	*************************************************************************************X
/*////////////////////////////////////////////////////////////////////////////////*/ *
/*@nomeFunction: 	  					MenuDef()							   	  */ *
/*--------------------------------------------------------------------------------*/ *
/*									Menu do Browser					  			  */ *
/*--------------------------------------------------------------------------------*/ *
/*@author: 						Michel Rocha - CodERP							  */ *
/*@since: 				    	  	   30/05/2023								  */ *
/*////////////////////////////////////////////////////////////////////////////////*/ *
	*************************************************************************************X
	*-------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.MvcZed' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.MvcZed' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.MvcZed' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.MvcZed' OPERATION 5 ACCESS 0


Return aRotina

Static Function ModelDef()
	Local oModel   := Nil
	Local oStPai   := FWFormStruct( 1, 'ZED', { |cCampo|  AllTrim( cCampo ) + '/' $ CABECALHO } )
	Local oStFilho := FWFormStruct( 1, 'ZED', { |cCampo|  AllTrim( cCampo ) + '/' $ ITENS }  )

	oModel := MPFormModel():New("MMvcZed", , /*{|oModel| MDMVlPos( oModel ) }/*bPos*/, {|oModel|CommitZED(oModel)},/*bCancel*/)

	oModel:SetDescription(OemtoAnsi("Natureza GRE") )

	oModel:AddFields('ZEDMASTER',/*cOwner*/,oStPai,/*bPreValidacao*/, /*bPosValidacao*/, /*{ || AN001(oModel)}*/)

	oModel:AddGrid('ZEDDETAIL','ZEDMASTER',oStFilho,,, , ,{|oModel| loadGrid(oModel)})//, {|oModel|AN002( oModel ) } )

	oModel:SetPrimaryKey( { "ZED_FILIAL" , "ZED_COD" })
	//Setando as descries
	oModel:SetDescription("Produtos")

Return oModel


Static Function ViewDef()
	Local oView     := Nil
	Local oModel    := FWLoadModel('MvcZed')
	Local oStPai 	:= FWFormStruct( 2, 'ZED' ,{ |cCampo|  AllTrim( cCampo ) + '/' $ CABECALHO } )
	Local oStFilho 	:= FWFormStruct( 2, 'ZED' ,{ |cCampo|  AllTrim( cCampo ) + '/' $ ITENS } )

	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Adicionando os campos do cabealho e o grid dos filhos
	oView:AddField('VIEW_CAB',oStPai,'ZEDMASTER')
	oView:AddGrid('VIEW_DET',oStFilho,'ZEDDETAIL')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',20)
	oView:CreateHorizontalBox('GRID',80)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB','CABEC')
	oView:SetOwnerView('VIEW_DET','GRID')

Return oView

Static Function CommitZED(oModel)
	Local oGrid  := oModel:GetModel("ZEDDETAIL")
	Local oCab   := oModel:GetModel("ZEDMASTER")
	Local n := 0
	Local cCod  := oCab:GetValue('ZED_COD')
	Local cDesc := oCab:GetValue('ZED_DESC')
	Local cReceita := oCab:GetValue('ZED_REC')
	DbSelectArea('ZED')
	If oModel:GetOperation() == 5
		For n := 1 To oGrid:Length()
			oGrid:GoLine(n)
			DbSetOrder(2)
			IF DbSeek(cFilAnt+cCod+oGrid:GetValue('ZED_NATSED')+oGrid:GetValue('ZED_CC'))
				RecLock("ZED",.F.)
				ZED->(DbDelete())
				ZED->(MsUnLock())
			EndIf
		Next
	ElseIf Inclui
		For n := 1 To oGrid:Length()
			oGrid:GoLine(n)
			RecLock("ZED",.T.)
			ZED->ZED_FILIAL := cFilAnt
			ZED->ZED_COD    := cCod
			ZED->ZED_REC    := cReceita
			ZED->ZED_DESC   := cDesc
			ZED->ZED_NATSED := oGrid:GetValue('ZED_NATSED')
			ZED->ZED_CC     := oGrid:GetValue('ZED_CC')
			ZED->(MsUnlock())
		Next

	ElseIf Altera
		For n := 1 To oGrid:Length()
			oGrid:GoLine(n)
			DbSetOrder(2)
			IF DbSeek(cFilAnt+cCod+oGrid:GetValue('ZED_NATSED')+oGrid:GetValue('ZED_CC'))
				If (!oGrid:IsDeleted(n))
					RecLock("ZED",.F.)
					ZED->ZED_FILIAL := cFilAnt
					ZED->ZED_ALT    := ZED->ZED_ALT+1
					ZED->ZED_REC    := cReceita
					ZED->ZED_COD    := cCod
					ZED->ZED_DESC   := cDesc
					ZED->ZED_NATSED := oGrid:GetValue('ZED_NATSED')
					ZED->ZED_CC     := oGrid:GetValue('ZED_CC')
					ZED->(MsUnlock())
				Else
					RecLock("ZED",.F.)
					ZED->(DbDelete())
					ZED->(MsUnLock())
				EndIf
			Else
				RecLock("ZED",.T.)
				ZED->ZED_FILIAL := cFilAnt
				ZED->ZED_ALT    := ZED->ZED_ALT+1
				ZED->ZED_REC    := cReceita
				ZED->ZED_COD    := cCod
				ZED->ZED_DESC   := cDesc
				ZED->ZED_NATSED := oGrid:GetValue('ZED_NATSED')
				ZED->ZED_CC     := oGrid:GetValue('ZED_CC')
				ZED->(MsUnlock())
			EndIf
		Next
	EndIf
Return .T.

static function loadGrid(oModel)
	Local aRet   := {}
	Local cAlias := GetNextAlias()
	BeginSql Alias cAlias
	Select * FROM %table:ZED% ZED
	WHERE ZED_COD = %Exp:ZED->ZED_COD%
	AND ZED_DESC = %Exp:ZED->ZED_DESC%
	AND ZED.%NotDel%
	EndSql
	aRet := FwLoadByAlias(oModel, cAlias)
return aRet
