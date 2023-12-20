#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

#DEFINE  CABECALHO  "ZLP_FILIAL/ZLP_CODLP/ZLP_CODORC/ZLP_CODTB/ZLP_CODVEN/ZLP_NOMEC/ZLP_NOMEVE/ZLP_CONTCL/ZLP_VALOR/ZLP_LINKPG/ZLP_DATA/ZLP_HORA/ZLP_STATUS/ZLP_BANCO/ZLP_IDLINK/"
//#DEFINE  ITENS      "ZLK_FILIAL/ZLK_ITEM/ZLK_CODLP/ZLK_CODORC/ZLK_CODPRD/ZLK_DESC/ZLK_UM/ZLK_QUANT/ZLK_UNIT/ZLK_TOTAL/ZLK_DESCT/ZLK_SERIE/"
#DEFINE  ITENS      "ZLK_FILIAL/ZLK_ITEM/ZLK_CODLP/ZLK_CODORC/ZLK_UNIT/ZLK_TOTAL/ZLK_SERIE/"
//#DEFINE  ITENS2     "ZLL_FILIAL/ZLL_ITEM/ZLL_CODLP/ZLL_CODORC/ZLL_CODPRD/ZLL_DESC/ZLL_UM/ZLL_QUANT/ZLL_UNIT/ZLL_TOTAL/ZLL_DESCT/"
#DEFINE  ITENS2     "ZLL_FILIAL/ZLL_ITEM/ZLL_CODLP/ZLL_CODORC/ZLL_CODPRD/ZLL_DESC/ZLL_UM/ZLL_QUANT/ZLL_UNIT/ZLL_TOTAL/"
Static 	 cTitle :=  "Tela de Pagamentos"


*+-------------------------------------------------------------------------+
*|Funcao      | TelPag()                                                   |
*+------------+------------------------------------------------------------+
*|Autor       | Rivaldo Jr. ( Cod.ERP Tecnologia LTDA )                    |
*+------------+------------------------------------------------------------+
*|Data        | 27/11/2023                                                 |
*+------------+------------------------------------------------------------|
*|Descricao   | FunÁ„o de Montagem da Tela MVC / tabelas ZLP e ZLK         |
*+------------+------------------------------------------------------------+
*|Solicitante | Setor financeiro                              			   |
*+------------+------------------------------------------------------------*

User Function TelPag()
	Local oBrowse := NIL

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZLP')                               // Alias da tabela utilizada
	oBrowse:SetDescription(cTitle)
	//oBrowse:DisableDetails()

	oBrowse:AddLegend( "ZLP->ZLP_STATUS == '1' ", "BLUE" , "Aguardando pagamento")
    oBrowse:AddLegend( "ZLP->ZLP_STATUS == '3' ", "RED"  , "Link Expirado"		 )
    oBrowse:AddLegend( "ZLP->ZLP_STATUS == '2' ", "GREEN", "Link Pago"    		 )
    oBrowse:AddLegend( "ZLP->ZLP_STATUS == '4' ", "BLACK", "Encerrado"    		 )
    oBrowse:Activate()

Return

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | MVCLegendas    | Autor |    Rivaldo Jr.  ( Cod.ERP )             |*
*+------------+------------------------------------------------------------------+*
*|Data        | 27.11.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao que contÈm as legendas da tela		                     |*
**********************************************************************************/
User Function MVCLegendas()
	Local aLegenda := {}

	//Monta as cores
	AADD(aLegenda,{"BR_AZUL"	,  "Aguardando pagamento"})
	AADD(aLegenda,{"BR_VERMELHO",  "Link Expirado"		 })
	AADD(aLegenda,{"BR_VERDE"	,  "Link Pago"			 })
	AADD(aLegenda,{"BR_PRETO"	,  "Encerrado"		 	 })

	BrwLegenda("Status do Link", "Link pagamento", aLegenda)
Return


/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | MenuDef    | Autor |    Rivaldo Jr.  ( Cod.ERP )                 |*
*+------------+------------------------------------------------------------------+*
*|Data        | 27.11.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Menu do Browser								                     |*
**********************************************************************************/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar'      ACTION 'VIEWDEF.TelPag' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'         ACTION 'VIEWDEF.TelPag' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'         ACTION 'VIEWDEF.TelPag' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'         ACTION 'VIEWDEF.TelPag' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Legenda'         ACTION 'U_MVCLegendas'  OPERATION 6 ACCESS 0 
	//ADD OPTION aRotina TITLE 'Gerar Novamente' ACTION 'U_GeraNovo()' OPERATION 8 ACCESS 0
	//ADD OPTION aRotina TITLE 'Gerar Novamente' ACTION 'VIEWDEF.TelPag' OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.TelPag' OPERATION 9 ACCESS 0

Return aRotina


/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | ModelDef    | Autor |    Rivaldo Jr.  ( Cod.ERP )                |*
*+------------+------------------------------------------------------------------+*
*|Data        | 27.11.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Modelo do cabecalho e grid					                     |*
**********************************************************************************/
Static Function ModelDef()
	Local oModel   := Nil
	Local oStPai   := FWFormStruct( 1, 'ZLP')//, { |cCampo|  AllTrim( cCampo ) + '/' $ CABECALHO } )
	Local oStFilho := FWFormStruct( 1, 'ZLK')//, { |cCampo|  AllTrim( cCampo ) + '/' $ ITENS }  )
	Local oStFilho2:= FWFormStruct( 1, 'ZLL')//, { |cCampo|  AllTrim( cCampo ) + '/' $ ITENS2 }  )//fn01MCAB()//
	Local bCamValid:= {|oModel, cAction, cIDField, xValue|  ValCab(cAction, cIDField, xValue)}
	//Local bCamValid1:= {|oModel, cAction, cIDField, xValue|  ValGrid1(cAction, cIDField, xValue)}
	Local bCamValid2:= {|oModel, cAction, cIDField, xValue|  ValGrid2(cAction, cIDField, xValue)}
	//Local LineValid:= {|oModel, cAction, cIDField, xValue|  linePreGrid(cAction, cIDField, xValue)}

	oModel := MPFormModel():New("MTelPag", /*{|oModel| MDMVlPre( oModel ) }bPre*/, /*{|oModel| MDMVlPos( oModel ) }/*bPos*/,/*{||ComplZZ3( Self ) }bCommit*/,/*bCancel*/)
	oModel:SetDescription(OemtoAnsi("Produtos") )

	oModel:AddFields('ZLPMASTER',/*cOwner*/,oStPai, bCamValid /*bPreValidacao*/, /*bPosValidacao*/, /*{ || AN001(oModel)}*/)
	oModel:SetPrimaryKey({'ZLP_CODLP'})   
	oModel:AddGrid('ZLKDETAIL','ZLPMASTER' ,oStFilho,/*{|oModel,nLine,cAction,cIDField, xValue| linePreGrid(oModel,nLine, cAction, cIDField, xValue)}*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/)//, {|oModel|AN002( oModel ) } )
	oModel:AddGrid('ZLKDETAIL2','ZLPMASTER' ,oStFilho2, bCamValid2/*{|oModel,nLine,cAction| linePreGrid(oModel,nLine, cAction)}*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/)//, {|oModel|AN002( oModel ) } )

	//Relacionamento das tabelas
	oModel:SetRelation('ZLKDETAIL', {{'ZLK_FILIAL','fWXfilial("ZLK")'},{'ZLK_CODLP','ZLP_CODLP'}}, ZLK->( IndexKey( 1 ) ))
	oModel:GetModel('ZLKDETAIL'):SetUniqueLine({"ZLK_FILIAL","ZLK_ITEM"})	
	oModel:SetRelation('ZLKDETAIL2', {{'ZLL_FILIAL','fWXfilial("ZLL")'},{'ZLL_CODLP','ZLP_CODLP'}}, ZLL->( IndexKey( 1 ) )) //IndexKey -> quero a ordenaÁ„o e depois filtrado
	oModel:GetModel('ZLKDETAIL2'):SetUniqueLine({"ZLL_ITEM","ZLL_FILIAL","ZLL_CODPRD"})	

	oStFilho:AddTrigger('ZLK_QUANT','ZLK_TOTAL',,{|oStFilho| Grid1(oStFilho)})//(FwFldGet('ZLK_TOTAL')-FwFldGet('ZLK_DESCT'))})
	oStFilho2:AddTrigger('ZLL_QUANT','ZLL_TOTAL',,{|oStFilho2| Grid2(oStFilho2)})//(FwFldGet('ZLK_TOTAL')-FwFldGet('ZLK_DESCT'))})
	oStFilho2:AddTrigger('ZLL_DESCT','ZLL_TOTAL',,{|oStFilho2| Grid2(oStFilho2)})//(FwFldGet('ZLK_TOTAL')-FwFldGet('ZLK_DESCT'))})

	//Setando as descriùùes
	oModel:GetModel('ZLPMASTER'):SetDescription('Cabecalho')
	oModel:GetModel('ZLKDETAIL'):SetDescription('Itens do Grid')

	//Adicionando totalizadores
	oModel:AddCalc('TOT_SALDO', 'ZLPMASTER', 'ZLKDETAIL', 'ZLK_TOTAL', 'XX_TOTAL', 'FORMULA',{|| .T.},{|| 0}, "VAREJO TOTAL" ,;
	{|oModel| CalcFor(oModel)},10,2 )
	oModel:AddCalc('TOT_SALDO', 'ZLPMASTER', 'ZLKDETAIL', 'ZLK_TOTAL', 'XX_TOTAL', 'FORMULA',{|| .T.},{|| 0}, "VALOR TOTAL" ,;
	{|oModel| CalcFor(oModel)},10,2 )
	//oModel:GetModel("ZLKDETAIL"):SetNoDeleteLine(.T.)
	oModel:GetModel('ZLKDETAIL'):SetOptional(.T.)
	oModel:GetModel('ZLKDETAIL2'):SetOptional(.T.)

Return oModel

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | ViewDef    | Autor |    Rivaldo Jr.  ( Cod.ERP )                 |*
*+------------+------------------------------------------------------------------+*
*|Data        | 27.11.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | ExibiÁao do cabecalho e grid				                     |*
**********************************************************************************/
Static Function ViewDef()
	Local oView     := Nil
	Local oModel    := FWLoadModel('TelPag')
	Local oStPai 	:= FWFormStruct( 2, 'ZLP')// ,{ |cCampo|  AllTrim( cCampo ) + '/' $ CABECALHO } )
	Local oStFilho 	:= FWFormStruct( 2, 'ZLK')//,{ |cCampo|  AllTrim( cCampo ) + '/' $ ITENS } )
	Local oStFilho2	:= FWFormStruct( 2, 'ZLL')// ,{ |cCampo|  AllTrim( cCampo ) + '/' $ ITENS2 } ) //FWFormViewStruct():New()//
	Local oStTot    := FWCalcStruct(oModel:GetModel('TOT_SALDO'))

	// Campos que ser„o removidos da View
	// CABE«ALHO
	oStPai:removeField("ZLP_DATA")
	oStPai:removeField("ZLP_CODTB")
	oStPai:removeField("ZLP_STATUS")
	oStPai:removeField("ZLP_HORA")
	oStPai:removeField("ZLP_VALOR")
	oStPai:removeField("ZLP_IDOPER")
	oStPai:removeField("ZLP_IDCHAT")

	// ITENS GRID 1
	oStFilho:removeField("ZLK_CODLP")
	oStFilho:removeField("ZLK_UNIT")
	
	// ITENS GRID 2
	oStFilho2:removeField("ZLL_CODLP")
	oStFilho2:removeField("ZLL_CODORC")
	oStFilho2:removeField("ZLL_UNIT")

	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	//Adicionando os campos do cabeùalho e o grid dos filhos
	oView:AddField('VIEW_CAB' , oStPai  ,'ZLPMASTER' )
	oView:AddGrid( 'VIEW_DET' ,oStFilho ,'ZLKDETAIL' )
	oView:AddGrid( 'VIEW_DET2',oStFilho2,'ZLKDETAIL2')
	oView:AddField('VIEW_TOT' , oStTot  ,'TOT_SALDO' )

	oView:SetViewAction('DELETELINE', { |oView,cIdView,nNumLine| AtuaDel(oView,cIdView,nNumLine) } )
	oView:SetViewAction('UNDELETELINE', { |oView,cIdView,nNumLine| AtuaUnDel(oView,cIdView,nNumLine) } )
	
	oView:CreateHorizontalBox('SUPERIOR',25)
	oView:CreateHorizontalBox('CENTRAL1',35)
	oView:CreateHorizontalBox('CENTRAL2',30)
	oView:CreateHorizontalBox('INFERIOR',10)
	oView:CreateVerticalBox("BOX_INFERIOR_ESQUERDO",70, "INFERIOR")
	oView:CreateVerticalBox("BOX_INFERIOR_DIREITO",30, "INFERIOR")

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB' ,'SUPERIOR')
	oView:SetOwnerView('VIEW_DET' ,'CENTRAL1')
	oView:SetOwnerView('VIEW_DET2','CENTRAL2')
	oView:SetOwnerView('VIEW_TOT' ,'BOX_INFERIOR_DIREITO')
	oView:SetOwnerView('VIEW_TOT' ,'BOX_INFERIOR_DIREITO')

	//Habilitando tÌtulo
    oView:EnableTitleView('VIEW_DET','Formulas')
    oView:EnableTitleView('VIEW_DET2','Varejo')

	oView:AddIncrementField('VIEW_DET', 'ZLK_ITEM')
	oView:AddIncrementField('VIEW_DET2', 'ZLL_ITEM')

Return oView

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | FatPd    | Autor |    Rivaldo Jr.  ( Cod.ERP )                   |*
*+------------+------------------------------------------------------------------+*
*|Data        | 10.11.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao para gerar a nota fiscal do tipo NFCE                     |*
*+------------+------------------------------------------------------------------+*
*|Par‚metro   | Necessita do Array com os dados da nota                          |*
**********************************************************************************/
Static Function ValCab(cAction, cIDField, xValue)
	Local lRet 	    := .T.
	Local oModel    := FWModelActive()
	Local oGrid     := oModel:GetModel("ZLKDETAIL")

	If cAction == "SETVALUE" .AND. xValue <> NIL .AND. cIDField == "ZLP_CODORC"

		Processa({|| CarregaGrid(xValue) },"Aguarde um momento, Buscando dados do orÁamento...")

	ElseIf cAction == "SETVALUE" .AND. xValue <> NIL .AND. cIDField == "ZLP_CONTCL"

		If !FwAlertYesNo('O n˙mero digitado precisa ser idÍntico ao n˙mero da conversa no Chat2Desk - '+xValue+CRLF+'Esta correto?','AtenÁ„o!')
			lRet := .F.
		EndIf

	ElseIf cAction == "SETVALUE" .AND. xValue <> NIL .AND. cIDField == "ZLP_DESCON"

		M->ZLP_DESCON := xValue
		oGrid:Setvalue('ZLK_TOTAL', oGrid:GetValue('ZLK_TOTAL') )

	ElseIf cAction == "SETVALUE" .AND. xValue <> NIL .AND. cIDField == "ZLP_FRETE"

		M->ZLP_FRETE := xValue
		oGrid:Setvalue('ZLK_TOTAL', oGrid:GetValue('ZLK_TOTAL') )

	EndIf

Return lRet

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | FatPd    | Autor |    Rivaldo Jr.  ( Cod.ERP )                   |*
*+------------+------------------------------------------------------------------+*
*|Data        | 10.11.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao para gerar a nota fiscal do tipo NFCE                     |*
*+------------+------------------------------------------------------------------+*
*|Par‚metro   | Necessita do Array com os dados da nota                          |*
**********************************************************************************/

Static Function AtuaDel(oView,cIdView,nNumLine)
	Local oModel    := FWModelActive()
	Local oGrid2    := oModel:GetModel("ZLKDETAIL2")
	Local oGrid     := oModel:GetModel("ZLKDETAIL")

	If cIdView == 'ZLKDETAIL'
		oGrid:DeleteLine()
	Else 
		oGrid2:DeleteLine()
	EndIf
	oGrid:Setvalue('ZLK_TOTAL', oGrid:GetValue('ZLK_TOTAL') )
	oView:Refresh('VIEW_TOT')

Return

Static Function AtuaUnDel(oView,cIdView,nNumLine)
	Local oModel    := FWModelActive()
	Local oGrid2    := oModel:GetModel("ZLKDETAIL2")
	Local oGrid     := oModel:GetModel("ZLKDETAIL")

	If cIdView == 'ZLKDETAIL'
		oGrid:UnDeleteLine()
	Else 
		oGrid2:UnDeleteLine()
	EndIf
	oGrid:Setvalue('ZLK_TOTAL', oGrid:GetValue('ZLK_TOTAL') )
	oView:Refresh('VIEW_TOT')

Return


/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | FatPd    | Autor |    Rivaldo Jr.  ( Cod.ERP )                   |*
*+------------+------------------------------------------------------------------+*
*|Data        | 10.11.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao para gerar a nota fiscal do tipo NFCE                     |*
*+------------+------------------------------------------------------------------+*
*|Par‚metro   | Necessita do Array com os dados da nota                          |*
**********************************************************************************/
Static Function ValGrid2(nLine, cAction, cIDField)
	Local lRet 	    := .T.

	If cAction == "SETVALUE" .AND. cIDField == "ZLL_CODPRD"//xValue <> NIL .AND. 

		Processa({|| U_BuscaVarejo(M->ZLl_CODPRD)},"Aguarde um momento, Buscando dados do varejo...")

	EndIf

Return lRet

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | CalcTot    | Autor |    Rivaldo Jr.  ( Cod.ERP )                 |*
*+------------+------------------------------------------------------------------+*
*|Data        | 27.11.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao para atualizar o valor do totalizador	                 |*
*+------------+------------------------------------------------------------------+*
*|Par‚metro   | o Model da tela						                             |*
**********************************************************************************/
Static Function CalcFor(oModel)
	Local oGrid     := oModel:GetModel("ZLKDETAIL")
	Local oGrid2    := oModel:GetModel("ZLKDETAIL2")
	Local nX 	    := 0
	Local nVlrFinal := 0
	Local nTotalFor := 0
	Local nTotalVar := 0
	Local nTUnitFor := 0
	Local nTUnitVar := 0
	Local nLineBkFor:= oGrid:GetLine()
	Local nLineBkVar:= oGrid2:GetLine()

	If Inclui
		For nX := 1 To oGrid:Length()
			oGrid:GoLine(nX)
			If !oGrid:IsDeleted()
				nTotalFor += oGrid:GetValue('ZLK_TOTAL')
				nTUnitFor += oGrid:GetValue('ZLK_UNIT')
			EndIf	
		Next
		oGrid:GoLine(nLineBkFor)

		For nX := 1 To oGrid2:Length()
			oGrid2:GoLine(nX)
			If !oGrid2:IsDeleted()
				nTotalVar += oGrid2:GetValue('ZLL_TOTAL')
				nTUnitVar += (oGrid2:GetValue('ZLL_UNIT')*oGrid2:GetValue('ZLL_QUANT'))
			EndIf	
		Next
		oGrid2:GoLine(nLineBkVar)

		nDesconto := (((nTUnitFor+nTUnitVar)/100)*M->ZLP_DESCON)
		nVlrFinal := ((nTUnitFor + nTUnitVar + M->ZLP_FRETE) - nDesconto)
	Else 
		nVlrFinal := ZLP->ZLP_VALOR
	EndIf

Return nVlrFinal

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | Grid2    | Autor |    Rivaldo Jr.  ( Cod.ERP )                 	 |*
*+------------+------------------------------------------------------------------+*
*|Data        | 27.11.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao para atualizar o valor total do Item		                 |*
*+------------+------------------------------------------------------------------+*
*|Par‚metro   | o Model da tela						                             |*
**********************************************************************************/
Static Function Grid1(oStFilho)
	Local oModel     := FWModelActive()
	Local oGrid      := oModel:GetModel("ZLKDETAIL")
	Local nTotal	 := 0

	nTotal := (oGrid:GetValue('ZLK_UNIT')*oGrid1:GetValue('ZLK_QUANT'))

	oGrid:Setvalue('ZLK_TOTAL', oGrid:GetValue('ZLK_TOTAL') )
 
Return nTotal

Static Function Grid2(oStFilho2)
	Local oModel     := FWModelActive()
	Local oGrid      := oModel:GetModel("ZLKDETAIL")
	Local oGrid2     := oModel:GetModel("ZLKDETAIL2")
	Local nTotal	 := 0

	nTotal := (oGrid2:GetValue('ZLL_UNIT')*oGrid2:GetValue('ZLL_QUANT'))

	oGrid:Setvalue('ZLK_TOTAL', oGrid:GetValue('ZLK_TOTAL') )
 
Return nTotal


/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | CarregaGrid    | Autor |    Rivaldo Jr.  ( Cod.ERP )             |*
*+------------+------------------------------------------------------------------+*
*|Data        | 27.11.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao para carregar o grid com o retorno da API                 |*
*+------------+------------------------------------------------------------------+*
*|Par‚metro   | Recebe o valor corrente setado no campo                          |*
**********************************************************************************/
Static Function CarregaGrid(xValue)
	Local oModel  := FWModelActive()
	Local oGrid   := oModel:GetModel("ZLKDETAIL")
	Local oCab	  := oModel:GetModel("ZLPMASTER")
	Local oView   := FwViewActive()
	Local aItens  := {}
	Local nX      := 0
	Local nLine   := 0
	
	aItens := U_BuscOrc(xValue, SuperGetMV("MV_XFILFC",,"137"))

	If !Empty(oCab:GetValue('ZLP_CODORC'))//.And. oGrid:Length() > 1 //Limpando a grid
		oGrid:ClearData()
		oView:Refresh('VIEW_DET')
	EndIf

	If Len(aItens) > 0
		For nLine :=1 to (Len(aItens)-1)
			oGrid:AddLine()
		Next 
		For nX := 1 To Len(aItens)
			oGrid:GoLine(nX)
			oGrid:LoadValue("ZLK_CODORC", aItens[nx,1]                      ) //CÛdigo do OrÁamento
			oGrid:LoadValue("ZLK_SERIE" , aItens[nX,2]                      ) //Serie do OrÁamento
			oGrid:LoadValue("ZLK_QUANT" , 1		 				            ) //Quantidade inicia com 1
			oGrid:LoadValue("ZLK_UNIT"  , Val(StrTran(aItens[nX,3],",","."))) //Valor da serie
			oGrid:LoadValue("ZLK_TOTAL" , Val(StrTran(aItens[nX,3],",","."))) //Valor da serie
		Next
		oGrid:GoLine(1)
	Else
		oCab:ClearField("ZLP_CODORC")
		If oGrid:Length() >= 1 //Limpando a grid
			oGrid:ClearData()
			oView:Refresh('VIEW_DET')
		EndIf
	EndIf

Return


/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | GeraNov    | Autor |    Rivaldo Jr.  ( Cod.ERP )                 |*
*+------------+------------------------------------------------------------------+*
*|Data        | 10.11.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao para verificar se deve seguir e gerar o link novamente    |*
**********************************************************************************/
User Function GeraNov()
	Local lRet 	  := .T.

	If ZLP->ZLP_STATUS == '1'
		FWAlertWarning("Link n„o expirado, n„o È necess·rio gerar novamente.","AtenÁ„o!")
		Return .F.
	ElseIf ZLP->ZLP_STATUS == '2'
		FWAlertWarning("Link pago anteriormente, n„o È necess·rio gerar novamente.","AtenÁ„o!")
		Return .F.
	EndIf

	Processa({|| lRet := GeraNovo()},"Aguarde um momento, Gerando um novo registro, um novo link e enviando ao cliente...")

	If lRet 
		FWAlertSuccess('Novo Link de pagamento gerado e enviado ao cliente.','Sucesso!') 
	Else
		FWAlertError("N„o foi possÌvel gerar o link.","AtenÁ„o!")
	EndIf

Return lRet


/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | GeraNovo    | Autor |    Rivaldo Jr.  ( Cod.ERP )                |*
*+------------+------------------------------------------------------------------+*
*|Data        | 27.11.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao para gerar um novo link de pagamento                      |*
**********************************************************************************/
User Function GeraNovo()
	Local aAreaZLP  := ZLP->(GetArea())
	Local aAreaZLK  := ZLK->(GetArea())
	Local oModel    := FWLoadModel('TelPag')
	Local oGrid     := oModel:GetModel("ZLKDETAIL")
	Local oCab	    := oModel:GetModel("ZLPMASTER")
	Local oTot	    := oModel:GetModel("TOT_SALDO")
	Local cQuery    := GetNextAlias()
	Local lRet      := .F.
	Local aRetorno  := {}
	Local cContato  := ''
	Local cNome     := ''
	Local cIdOper   := ''
	Local cValLink  := ''
	Local cMensagem := ''
	//Local cCodLp    := ZLP->ZLP_CODLP

	oTot:LoadValue("XX_TOTAL" , ZLP->ZLP_VALOR)

	FWExecView( 'GERAR NOVAMENTE' ,; // "VisualizaÁ„o da Ficha de Ativo"
	'TELPAG',;
		9,;
		/*oDlg*/,;
		{ || .T. },;
		/*bOk*/,;
		/*nPercReducao*/,;
		/*aEnableButtons*/,;
		/*bCancel*/,;
		/*cOperatId*/,;
		/*cToolBar*/,;
		/*oModel*/)

/* 	DbSelectArea("ZLK")
	//Busco pelos itens do processo expirado
	BeginSql Alias cQuery
		SELECT * FROM %Table:ZLK% ZLK
		INNER JOIN %Table:ZLP% ZLP ON ZLP_FILIAL = ZLK_FILIAL AND ZLP_CODLP = ZLK_CODLP
		INNER JOIN %Table:ZLL% ZLL ON ZLL_FILIAL = ZLK_FILIAL AND ZLL_CODLP = ZLK_CODLP
		WHERE ZLK_FILIAL = %EXP:ZLP->ZLP_FILIAL% 
			AND ZLK_CODLP = %EXP:cCodLp%
			AND ZLP.%NOTDEL%
			AND ZLK.%NOTDEL%
			AND ZLL.%NOTDEL%
	EndSql

	If (cQuery)->(!Eof())
		
		ZLP->(ReckLock("ZLP",.T.))//Gero o novo processo 
			ZLP->ZLP_FILIAL	:= ZLP->ZLP_FILIAL	
			ZLP->ZLP_VALOR	:= ZLP->ZLP_VALOR	
			ZLP->ZLP_LINKPG	:= ZLP->ZLP_LINKPG	
			ZLP->ZLP_CODLP	:= GetSxENum("ZLP","ZLP_CODLP")// pego o cÛdigo do novo processo
			ZLP->ZLP_CODORC	:= ZLP->ZLP_CODORC	
			ZLP->ZLP_CODTB	:= ZLP->ZLP_CODTB	
			ZLP->ZLP_CODVEN	:= ZLP->ZLP_CODVEN	
			ZLP->ZLP_NOMEVE	:= ZLP->ZLP_NOMEVE	
			ZLP->ZLP_STATUS	:= '1'
			ZLP->ZLP_CONTCL	:= ZLP->ZLP_CONTCL	
			ZLP->ZLP_NOMEC	:= ZLP->ZLP_NOMEC	
			ZLP->ZLP_BANCO	:= ZLP->ZLP_BANCO	
			ZLP->ZLP_DATA	:= Date()	
			ZLP->ZLP_HORA	:= Time()	
			ZLP->ZLP_IDLINK	:= ZLP->ZLP_IDLINK	
			//ZLP->ZLP_DESCT	:= ZLP->ZLP_DESCT	
			ZLP->ZLP_IDOPER	:= ZLP->ZLP_IDOPER
			ZLP->ZLP_IDCHAT	:= ZLP->ZLP_IDCHAT
		ZLP->(MsUnLock())

		While (cQuery)->(!Eof())// gravo os itens do novo processo 
			// ITENS FORMULA
			ZLK->(ReckLock("ZLK",.T.))
				ZLK->ZLK_FILIAL	:= (cQuery)->ZLK_FILIAL
				ZLK->ZLK_ITEM	:= (cQuery)->ZLK_ITEM
				ZLK->ZLK_CODPRD	:= (cQuery)->ZLK_CODPRD
				ZLK->ZLK_SERIE	:= (cQuery)->ZLK_SERIE
				ZLK->ZLK_DESC	:= (cQuery)->ZLK_DESC
				ZLK->ZLK_UM		:= (cQuery)->ZLK_UM	
				ZLK->ZLK_CODORC	:= (cQuery)->ZLK_CODORC
				ZLK->ZLK_CODLP	:= ZLP->ZLP_CODLP
				ZLK->ZLK_QUANT	:= (cQuery)->ZLK_QUANT
				ZLK->ZLK_DESCT	:= (cQuery)->ZLK_DESCT
				ZLK->ZLK_UNIT	:= (cQuery)->ZLK_UNIT
				ZLK->ZLK_TOTAL	:= (cQuery)->ZLK_TOTAL
			ZLK->(MsUnLock())

			// ITENS VAREJO
			ZLL->(ReckLock("ZLL",.T.))
				ZLK->ZLK_FILIAL	:= (cQuery)->ZLL_FILIAL
				ZLK->ZLK_ITEM	:= (cQuery)->ZLL_ITEM
				ZLK->ZLK_CODPRD	:= (cQuery)->ZLL_CODPRD
				ZLK->ZLK_DESC	:= (cQuery)->ZLL_DESC
				ZLK->ZLK_UM		:= (cQuery)->ZLL_UM	
				ZLK->ZLK_CODORC	:= (cQuery)->ZLK_CODORC
				ZLK->ZLK_CODLP	:= ZLK->ZLK_CODLP
				ZLK->ZLK_QUANT	:= (cQuery)->ZLK_QUANT
				ZLK->ZLK_DESCT	:= (cQuery)->ZLK_DESCT
				ZLK->ZLK_UNIT	:= (cQuery)->ZLK_UNIT
				ZLK->ZLK_TOTAL	:= (cQuery)->ZLK_TOTAL
			ZLL->(MsUnLock())
			(cQuery)->(DbSkip())
		End 

		lRet := U_ConsRest(ZLP->ZLP_VALOR, .F.) //Chamo a FunÁ„o principal para dar inicio a geraÁ„o do Link de pagamento

        If lRet
            cContato := "55"+ZLP->ZLP_CONTCL
            cNome    := ZLP->ZLP_NOMEC
            cIdOper  := AllTrim(Posicione('SA3',1,xFilial("SA3")+ZLP->ZLP_CODVEN,'A3_IDOPER'))
            cValLink := AllTrim(Transform(ZLP->ZLP_VALOR, "@E 999,999,999.99"))

            cMensagem+= " Estou te enviando abaixo o link de pagamento. "+CRLF
            cMensagem+= " "+CRLF
            cMensagem+= " Valor: R$ "+cValLink+" "+CRLF
            cMensagem+= " Link: "+CRLF
            cMensagem+= " "+CRLF
            cMensagem+= " "+AllTrim(ZLP->ZLP_LINKPG)+""+CRLF
            cMensagem+= " "+CRLF
            cMensagem+= " "+CRLF
            cMensagem+= " * DADOS CADASTRAIS  "+CRLF
            cMensagem+= " Nome completo: "+CRLF
            cMensagem+= " CPF: "+CRLF
            cMensagem+= " Data de Nascimento: "+CRLF
            cMensagem+= " Telefone: "+CRLF
            cMensagem+= " E-mail: "+CRLF
            cMensagem+= "  "+CRLF
            cMensagem+= " --------------- "+CRLF
            cMensagem+= "  "+CRLF
            cMensagem+= " * OBS "+CRLF
            cMensagem+= " - Nosso prazo de entrega È de 24h ‡ 48h ˙teis apÛs a inclus„o do pedido *(Exceto SEDEX)*; "+CRLF
            cMensagem+= " (Exceto sachÍs, chocolates, pastilha sublingual, Gomas, "
            cMensagem+= " Gotas e C·psulas oleosas na retirada em loja e entrega em domicÌlio. Por necessitar de um tempo maior para manipulaÁ„o). "
            
            aRetorno := U_Chat2Desk(cContato, cNome, cIdOper, EncodeUtf8(cMensagem))

            If Len(aRetorno) > 0
                If aRetorno[1] == 'success'

                    U_AddTag('134816',aRetorno[2])// adiciono a Tag AGUARDANDO PAGAMENTO

                    ZLP->(RecLock('ZLP',.F.))
                        ZLP->ZLP_IDCHAT := aRetorno[2] // GRAVO O ID DA CONVERSA.
					ZLP->(MsUnlock())
				EndIf
			EndIf
		EndIf

		If ZLP->(DbSeek(xFilial("ZLP")+cCodLp)) //Marco o registro anterior com status de encerrado
			ZLP->(ReckLock("ZLP",.F.))
				ZLP->ZLP_STATUS	:= '4'
			ZLP->(MsUnLock())
		EndIf

	EndIf */

	RestArea(aAreaZLP)
	RestArea(aAreaZLK)

Return lRet


User Function BuscaVarejo(xValue)
    Local oRest      As Object
    Local oJson      As Object
    Local cBody      := ''
	Local cUrl       := 'http://pharmapeleapps.dynns.com:50465'
    Local aHeader    := {}
    Local cContent   := "Content-Type: application/json"
	Local oModel  	 := FWModelActive()
	Local oView   	 := FwViewActive()
	Local oGrid    	 := oModel:GetModel("ZLKDETAIL")
	Local oGrid2   	 := oModel:GetModel("ZLKDETAIL2")

	cBody += ' { '
    cBody += '   "id":"gradar",
    cBody += '   "codprod":'+xValue+' '
	cBody += ' } '

    Aadd(aHeader, cContent)

    oRest := FWRest():New(cUrl)
    oJson := JSonObject():New()

    oRest:setPath("/datasnap/rest/TSM/BuscaProd")
    oRest:SetPostParams(cBody)
    oRest:Post(aHeader)
    oJSon:fromJson(SubString(oRest:cResult,2,Len(oRest:cResult)-1))

	If oJson:GetJsonObject('StatusDescr') == "Erro"
        FWAlertWarning("Varejo n„o localizado.","AtenÁ„o!")
		oGrid2:ClearData()
		oGrid2:ClearField('ZLL_CODPRD')
		oView:Refresh('VIEW_DET2')
		oGrid:Setvalue('ZLK_TOTAL', oGrid:GetValue('ZLK_TOTAL') )
        Return 
    Endif
	
    If oRest:oResponseh:cStatusCode == "200"
		oGrid2:GoLine(oGrid2:GetLine())
		oGrid2:LoadValue("ZLL_CODORC", M->ZLP_CODORC 												   ) //Campo de OrÁamento
		oGrid2:LoadValue("ZLL_CODLP" , M->ZLP_CODLP 												   ) //Campo de OrÁamento
		oGrid2:LoadValue("ZLL_CODPRD", oJson["PRODUTOS",1]:GetJsonObject('COD') 					   ) //Campo de Produto
		oGrid2:LoadValue("ZLL_DESC"  , oJson["PRODUTOS",1]:GetJsonObject('PRODUTO')          		   ) //Campo de DescriÁ„o
		oGrid2:LoadValue("ZLL_UM"  	 , oJson["PRODUTOS",1]:GetJsonObject('UNID') 					   ) //Campo de Unid. Medida
		oGrid2:LoadValue("ZLL_QUANT" , 1 															   ) //Campo de Quantidade
		oGrid2:LoadValue("ZLL_UNIT"  , Val(StrTran(oJson["PRODUTOS",1]:GetJsonObject('PRECO'),",","."))) //Campo de Valor
		oGrid2:LoadValue("ZLL_TOTAL" , Val(StrTran(oJson["PRODUTOS",1]:GetJsonObject('PRECO'),",",".")))//(Val(StrTran(aItens[1,7],",","."))*Val(aItens[nx,6])) ) //Campo de Valor
    Endif

	oGrid:Setvalue('ZLK_TOTAL', oGrid:GetValue('ZLK_TOTAL') )

Return 
