//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'




#DEFINE  CABECALHO  "ZRQ_FILIAL/ZRQ_NUM/ZRQ_CLI/ZRQ_TOTAL/ZRQ_SALDO"
#DEFINE  ITENS      "ZRP_FILIAL/ZRP_NUM/ZRP_CLI/ZRP_COND/ZRP_PARC/ZRP_AUTC/ZRP_VLR/ZRP_DATA/ZRP_OBS/"

*-------------------------------------------------------------------------------------
************************************************************************************ X
/*@nomeFunction: 	  					U_STEZR01()						   		  */ *
/*--------------------------------------------------------------------------------*/ *
/*							  Fun��o de Montagem da Tela MVC	 				  */ *
/*					 	  Gravando os Dados nas Tabelas ZR0 e ZR1				  */ *
/*					  Tela de Vinculo dos Produtos para Transforma��o			  */ *
/*--------------------------------------------------------------------------------*/ *
/*@author: 						Rivaldo.J�nior - CodERP							  */ *
/*@since: 				    	  	   19/08/2022								  */ *
************************************************************************************ X
*-------------------------------------------------------------------------------------
User Function zTelaFat()
	Local aButtons := {{.F.,Nil},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.T.,"Confirmar"},;
		{.T.,"Cancelar"},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.F.,NIl}}
	Private nVlrSaldo := 0

	FWExecView("Pedido de Venda - Pagamentos","zTelaFat",3,,{|| .T.},,72,aButtons)
	MsgAlert('Finalizou')

Return



	*-------------------------------------------------------------------------------------
	*************************************************************************************X
/*////////////////////////////////////////////////////////////////////////////////*/ *
/*@nomeFunction: 	  					ModelDef()							   	  */ *
/*--------------------------------------------------------------------------------*/ *
/*							   Modelo do cabecalho e grid		  				  */ *
/*--------------------------------------------------------------------------------*/ *
/*@author: 						Rivaldo.J�nior - CodERP							  */ *
/*@since: 				    	  	   19/08/2022								  */ *
/*////////////////////////////////////////////////////////////////////////////////*/ *
	*************************************************************************************X
	*-------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel   := Nil
	//Local oStPai   := FWFormStruct( 1, 'ZRQ', { |cCampo|  AllTrim( cCampo ) + '/' $ CABECALHO } )
	//Local oStFilho := FWFormStruct( 1, 'ZRP', { |cCampo|  AllTrim( cCampo ) + '/' $ ITENS }  )
	Local oStPai   	:= CabecMd()
	Local oStFilho 	:= GridMd()
	Local oStNeto	:= FWFormModelStruct():New()
	Local bLinePre := {|oGrid, nLine, cAction, cIDField, xValue, xCurrentValue|;
		fn01lPG(oGrid, nLine, cAction, cIDField, xValue, xCurrentValue)}
	//Local aAux

	oStNeto:AddTable('ZRQ',,'')
	oStNeto:AddField(	"Saldo Restante",; //T�tulo do campo
	"",; //cToolTip
	"ZRQ_SALDO",;// Id do Campo
	"N",; //cTipo
	12,; //Tamanho do Campo
	2, ;       			            // [06] Decimal do campo
	{|| .t.}, ; 			        // [07] Code-block de valida��o do campo
	{|| .t.}, ; 			        // [08] Code-block de valida��o When do campo
	NIL, ;     			            // [09] Lista de valores permitido do campo
	.f., ;     			            // [10] Indica se o campo tem preenchimento obrigat�rio
	NIL, ;     			            // [11] Code-block de inicializacao do campo
	NIL, ;     			            // [12] Indica se trata-se de um campo chave
	NIL, ;     			            // [13] Indica se o campo pode receber valor em uma opera��o de update.
	.t.)       			            // [14] Indica se o campo � virtual

	//oStPai:SetProperty('ZRQ_NUM'  ,MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'SC5->C5_NUM'))
	oStPai:SetProperty('ZRQ_CLI'  ,MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NREDUZ")'))
	oStPai:SetProperty('ZRQ_TOTAL',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'U_PrVend1()'))
	oStFilho:SetProperty('ZRP_PARC',MODEL_FIELD_WHEN,{|oModel| Iif(alltrim(oModel:GetValue('ZRP_COND')) <> "CC",.F.,.T.)})

	oModel := MPFormModel():New("MZTELAFAT", , , {|oModel|Confirm(oModel)} , ) //, , { |oModel| ZD3VAL( oModel )} , { |oModel| ZD3GRV( oModel ) }
	oModel:SetDescription(OemtoAnsi("Pedidos") )

	oModel:AddFields('ZRQMASTER',/*cOwner*/,oStPai, /*bPreValidacao*/, /*bPosValidacao*/, /*{ || AN001(oModel)}*/)

	oModel:AddGrid('ZRPDETAIL','ZRQMASTER',oStFilho,bLinePre, , , , {|oModel|TUSACarga(oModel)})

	oModel:AddFields('ZRQCHEF','ZRQMASTER',oStNeto, /*bPreValidacao*/, /*bPosValidacao*/, /*{ || AN001(oModel)}*/)

	oModel:GetModel('ZRQMASTER'):SetPrimaryKey({})

	//Relacionamento da tabela Etapa com Projeto
	//aAdd(aRelacFNL,{ 'ZRP_NUM'	, 'ZRQ_NUM' 	})
	//oModel:SetRelation('ZRPDETAIL', aRelacFNL, ZRP->( IndexKey( 1 ) ))
	//oModel:GetModel("ZR1DETAIL"):SetUniqueLine({ })

	oStFilho:AddTrigger('ZRP_COND','ZRP_DATA',,{|oModel| U_DatRet(oModel)})

	//Setando as descri��es
	oModel:SetDescription('Pedidos')
	oModel:GetModel('ZRQMASTER'):SetDescription('Dados Produ��o')
	oModel:GetModel('ZRPDETAIL'):SetDescription('Itens Consumidos')
	oModel:GetModel('ZRQCHEF'):SetDescription('Dados')

	//oModel:AddCalc('ZRQCHEF', 'ZRQMASTER', 'ZRPDETAIL', 'ZRP_VLR', 'ZRP_VLR', 'SUM', /*{ | oModel | SaldoT( oModel, .T. ) }*/, , "Saldo Restante",,, )

	oModel:setActivate({ |oModel| onActivate(oModel)})
	//oModel:SetMaxLine(1)
Return oModel


Static Function CabecMd()

	Local oStructModelGrid	:= FWformModelStruct():New()

	oStructModelGrid:AddTable('ZRQ',,"")

	oStructModelGrid:AddField( ;
		'Pedido', ; 	 		        // [01] Titulo do campo
	'Pedido', ; 			        	// [02] ToolTip do campo
	'ZRQ_NUM', ;  				    	// [03] Id do Field
	'C', ;     			            // [04] Tipo do campo
	TamSx3("ZRQ_NUM")[1], ;       	// [05] Tamanho do campo
	0, ;       			            // [06] Decimal do campo
	{|| .T.}, ; 			        // [07] Code-block de valida��o do campo
	{|| .T.}, ; 			        // [08] Code-block de valida��o When do campo
	NIL, ;     			            // [09] Lista de valores permitido do campo
	.F., ;     			            // [10] Indica se o campo tem preenchimento obrigat�rio
	NIL, ;			   		        // [11] Code-block de inicializacao do campo
	NIL, ;					        // [12] Indica se trata-se de um campo chave
	NIL, ;					        // [13] Indica se o campo pode receber valor em uma opera��o de update.
	.T.)

	oStructModelGrid:AddField( ;
		'Cliente', ; 	 		    // [01] Titulo do campo
	'Cliente', ; 			        // [02] ToolTip do campo
	'ZRQ_CLI', ;  				    // [03] Id do Field
	'C', ;     			            // [04] Tipo do campo
	TamSx3("ZRQ_CLI")[1], ;       // [05] Tamanho do campo
	0, ;       			            // [06] Decimal do campo
	{|| .T.}, ; 			        // [07] Code-block de valida��o do campo
	{|| .F.}, ; 			        // [08] Code-block de valida��o When do campo
	NIL, ;     			            // [09] Lista de valores permitido do campo
	.F., ;     			            // [10] Indica se o campo tem preenchimento obrigat�rio
	NIL, ;			   		        // [11] Code-block de inicializacao do campo
	NIL, ;					        // [12] Indica se trata-se de um campo chave
	NIL, ;					        // [13] Indica se o campo pode receber valor em uma opera��o de update.
	.T.)

	oStructModelGrid:AddField( ;
		'Valor', ; 	 		// [01] Titulo do campo
	'Valor', ; 			    // [02] ToolTip do campo
	'ZRQ_TOTAL', ;  				    // [03] Id do Field
	'N', ;     			            // [04] Tipo do campo
	TamSx3("ZRQ_TOTAL")[1], ;      // [05] Tamanho do campo
	0, ;       			            // [06] Decimal do campo
	{|| .T.}, ; 			        // [07] Code-block de valida��o do campo
	{|| .F.}, ; 			        // [08] Code-block de valida��o When do campo
	NIL, ;     			            // [09] Lista de valores permitido do campo
	.F., ;     			            // [10] Indica se o campo tem preenchimento obrigat�rio
	NIL, ;			   		        // [11] Code-block de inicializacao do campo
	NIL, ;					        // [12] Indica se trata-se de um campo chave
	NIL, ;					        // [13] Indica se o campo pode receber valor em uma opera��o de update.
	.T.)

RETURN oStructModelGrid

/*/{Protheus.doc} MontaGridMd
Montagem do Grid do Model
@type function
@version 12.1.33 
@author Cod.Erpw
@since 30/08/2022
@return variant, object
/*/
Static Function GridMd()

	Local oStructModelGrid	:= FWformModelStruct():New()

	oStructModelGrid:AddTable('ZRP',,"")

//C�digo da Filial
	oStructModelGrid:AddField( ;
		"Cond. Pagamento", ;		            // [01] Titulo do campo
	"Cond. Pagamento", ;		            	// [02] ToolTip do campo
	'ZRP_COND', ;			            // [03] Id do Field
	'C', ;     			            // [04] Tipo do campo
	TamSx3("ZRP_COND")[1], ;      	// [05] Tamanho do campo
	0, ;       			            // [06] Decimal do campo
	{|| .T.}, ; 			        // [07] Code-block de valida��o do campo
	{|| .T.}, ; 			        // [08] Code-block de valida��o When do campo
	NIL, ;     			            // [09] Lista de valores permitido do campo
	.T., ;     			            // [10] Indica se o campo tem preenchimento obrigat�rio
	NIL, ;     			            // [11] Code-block de inicializacao do campo
	NIL, ;     			            // [12] Indica se trata-se de um campo chave
	NIL, ;     			            // [13] Indica se o campo pode receber valor em uma opera��o de update.
	.T.)       			            // [14] Indica se o campo � virtual

//Numero do Pedido

	oStructModelGrid:AddField( ;
		'Parcelas', ; 	 		        // [01] Titulo do campo
	'Parcelas', ; 			        	// [02] ToolTip do campo
	'ZRP_PARC', ;  				    	// [03] Id do Field
	'C', ;     			            // [04] Tipo do campo
	TamSx3("ZRP_PARC")[1], ;       	// [05] Tamanho do campo
	0, ;       			            // [06] Decimal do campo
	{|| .T.}, ; 			        // [07] Code-block de valida��o do campo
	{|| .T.}, ; 			        // [08] Code-block de valida��o When do campo
	NIL, ;     			            // [09] Lista de valores permitido do campo
	.F., ;     			            // [10] Indica se o campo tem preenchimento obrigat�rio
	NIL, ;			   		        // [11] Code-block de inicializacao do campo
	NIL, ;					        // [12] Indica se trata-se de um campo chave
	NIL, ;					        // [13] Indica se o campo pode receber valor em uma opera��o de update.
	.T.)

	oStructModelGrid:AddField( ;
		'No Aut.', ; 	 		    // [01] Titulo do campo
	'No Aut.', ; 			        // [02] ToolTip do campo
	'ZRP_AUTC', ;  				    // [03] Id do Field
	'C', ;     			            // [04] Tipo do campo
	TamSx3("ZRP_AUTC")[1], ;       // [05] Tamanho do campo
	0, ;       			            // [06] Decimal do campo
	{|| .T.}, ; 			        // [07] Code-block de valida��o do campo
	{|| .T.}, ; 			        // [08] Code-block de valida��o When do campo
	NIL, ;     			            // [09] Lista de valores permitido do campo
	.F., ;     			            // [10] Indica se o campo tem preenchimento obrigat�rio
	NIL, ;			   		        // [11] Code-block de inicializacao do campo
	NIL, ;					        // [12] Indica se trata-se de um campo chave
	NIL, ;					        // [13] Indica se o campo pode receber valor em uma opera��o de update.
	.T.)

	oStructModelGrid:AddField( ;
		'Valor', ; 	 		// [01] Titulo do campo
	'Valor', ; 			    // [02] ToolTip do campo
	'ZRP_VLR', ;  				    // [03] Id do Field
	'N', ;     			            // [04] Tipo do campo
	TamSx3("ZRP_VLR")[1], ;      // [05] Tamanho do campo
	0, ;       			            // [06] Decimal do campo
	{|| .T.}, ; 			        // [07] Code-block de valida��o do campo
	{|| .T.}, ; 			        // [08] Code-block de valida��o When do campo
	NIL, ;     			            // [09] Lista de valores permitido do campo
	.T., ;     			            // [10] Indica se o campo tem preenchimento obrigat�rio
	NIL, ;			   		        // [11] Code-block de inicializacao do campo
	NIL, ;					        // [12] Indica se trata-se de um campo chave
	NIL, ;					        // [13] Indica se o campo pode receber valor em uma opera��o de update.
	.T.)

	oStructModelGrid:AddField( ;
		'Data', ; 	 		    // [01] Titulo do campo
	'Data', ; 			        // [02] ToolTip do campo
	'ZRP_DATA', ;  				    // [03] Id do Field
	'D', ;     			            // [04] Tipo do campo
	TamSx3("ZRP_DATA")[1], ;       // [05] Tamanho do campo
	0, ;       			            // [06] Decimal do campo
	{|| .T.}, ; 			        // [07] Code-block de valida��o do campo
	{|| .T.}, ; 			        // [08] Code-block de valida��o When do campo
	NIL, ;     			            // [09] Lista de valores permitido do campo
	.T., ;     			            // [10] Indica se o campo tem preenchimento obrigat�rio
	NIL, ;			   		        // [11] Code-block de inicializacao do campo
	NIL, ;					        // [12] Indica se trata-se de um campo chave
	NIL, ;					        // [13] Indica se o campo pode receber valor em uma opera��o de update.
	.T.)   				            // [14] Indica se o campo � virtual

//Item do PV
	oStructModelGrid:AddField( ;
		'OBS', ; 	 		    	// [01] Titulo do campo
	'OBS', ; 			        	// [02] ToolTip do campo
	'ZRP_OBS', ;  				    // [03] Id do Field
	'C', ;     			            // [04] Tipo do campo
	TamSx3("ZRP_OBS")[1], ;       	// [05] Tamanho do campo
	0, ;       			            // [06] Decimal do campo
	{|| .T.}, ; 			        // [07] Code-block de valida��o do campo
	{|| .T.}, ; 			        // [08] Code-block de valida��o When do campo
	NIL, ;     			            // [09] Lista de valores permitido do campo
	.F., ;     			            // [10] Indica se o campo tem preenchimento obrigat�rio
	NIL, ;			   		        // [11] Code-block de inicializacao do campo
	NIL, ;					        // [12] Indica se trata-se de um campo chave
	NIL, ;					        // [13] Indica se o campo pode receber valor em uma opera��o de update.
	.T.)   				            // [14] Indica se o campo � virtual
RETURN oStructModelGrid



	*-------------------------------------------------------------------------------------
	*************************************************************************************X
/*////////////////////////////////////////////////////////////////////////////////*/ *
/*@nomeFunction: 	  					ViewDef()							   	  */ *
/*--------------------------------------------------------------------------------*/ *
/*							  Exibi�ao do cabecalho e grid		  				  */ *
/*--------------------------------------------------------------------------------*/ *
/*@author: 						Rivaldo.J�nior - CodERP							  */ *
/*@since: 				    	  	   19/08/2022								  */ *
/*////////////////////////////////////////////////////////////////////////////////*/ *
	*************************************************************************************X
	*-------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oView     := Nil
	Local oModel    := FWLoadModel('zTelaFat')
	//Local oStPai 	:= FWFormStruct( 2, 'ZRQ' ,{ |cCampo|  AllTrim( cCampo ) + '/' $ CABECALHO } )
	//Local oStFilho 	:= FWFormStruct( 2, 'ZRP' ,{ |cCampo|  AllTrim( cCampo ) + '/' $ ITENS } )
	Local oStPai 	:= CabecVw()
	Local oStFilho 	:= GridVw()
	Local oStNeto   := FWformViewStruct():New()
	//Local oStTot    := FWCalcStruct(oModel:GetModel('ZRQCHEF'))

	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	oStNeto:AddField( ;
		'ZRQ_SALDO', ;	  		        // [01] Campo
	'001', ;   			            // [02] Ordem
	'Saldo Restante', ;			    // [03] Titulo
	'Saldo Restante', ;			    // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	PesqPict('ZRQ','ZRQ_SALDO'), ;     // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	0, ;      				        // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

	//Adicionando os campos do cabe�alho e o grid dos filhos
	oView:AddField('VIEW_CAB',oStPai,'ZRQMASTER')
	oView:AddGrid('VIEW_DET',oStFilho,'ZRPDETAIL')
	oView:AddField('VIEW_TOT', oStNeto,'ZRQCHEF')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',18)
	oView:CreateHorizontalBox('GRID',64)
	oView:CreateHorizontalBox('TOTAL',18)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB','CABEC')
	oView:SetOwnerView('VIEW_DET','GRID')
	oView:SetOwnerView('VIEW_TOT','TOTAL')

	//oView:RemoveField("ZRQ_FANT")

Return oView

Static Function CabecVw()
	Local oStructViewCabec	:= FWformViewStruct():New()

//C�digo da Filial
	oStructViewCabec:AddField( ;
		'ZRQ_NUM', ;	  		        // [01] Campo
	'001', ;   			            // [02] Ordem
	'Pedido', ;			            // [03] Titulo
	'Pedido', ;			            // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	PesqPict('ZRQ','ZRQ_NUM'), ;     // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	0, ;      				        // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

	oStructViewCabec:AddField( ;
		'ZRQ_CLI', ;  			        // [01] Campo
	'002', ;   			            // [02] Ordem
	'Cliente', ;			            // [03] Titulo
	'Cliente', ;			            // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	PesqPict('ZRQ','ZRQ_CLI'), ;    // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	0, ;      				        // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

	oStructViewCabec:AddField( ;
		'ZRQ_TOTAL', ;  			    // [01] Campo
	'003', ;   			            // [02] Ordem
	'Valor', ;			        // [03] Titulo
	'Valor', ;			        // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	PesqPict('ZRQ','ZRQ_TOTAL'), ;  // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	0, ;      				        // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

Return oStructViewCabec

Static Function GridVw()
	Local oStructViewGrid	:= FWformViewStruct():New()
	Local cCOMBO			:= "{'"+STRTRAN(Alltrim(GetSX3Cache("ZRP_COND", "X3_CBOX")), ";", "','")+"'}"

//C�digo da Filial
	oStructViewGrid:AddField( ;
		'ZRP_COND', ;	  		    // [01] Campo
	'001', ;   			            // [02] Ordem
	'Cond. Pagamento', ;			// [03] Titulo
	'Cond. Pagamento', ;			// [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	PesqPict('ZRP','ZRP_COND'), ;   // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.T., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	&(cCOMBO), ;    				        // [13] Lista Combo
	0, ;      				        // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

	oStructViewGrid:AddField( ;
		'ZRP_PARC', ;  			        // [01] Campo
	'002', ;   			            // [02] Ordem
	'Parcelas', ;			            // [03] Titulo
	'Parcelas', ;			            // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	PesqPict('ZRP','ZRP_PARC'), ;    // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.T., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	0, ;      				        // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

	oStructViewGrid:AddField( ;
		'ZRP_AUTC', ;  			    // [01] Campo
	'003', ;   			            // [02] Ordem
	'No Aut.', ;			        // [03] Titulo
	'No Aut.', ;			        // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	PesqPict('ZRP','ZRP_AUTC'), ;  // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.T., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	0, ;      				        // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

	oStructViewGrid:AddField( ;
		'ZRP_VLR', ;  			    // [01] Campo
	'004', ;   			            // [02] Ordem
	'Valor', ;			        // [03] Titulo
	'Valor', ;			        // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	PesqPict('ZRP','ZRP_VLR'), ; // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.T., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	0, ;      				        // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

	oStructViewGrid:AddField( ;
		'ZRP_DATA', ;  			    // [01] Campo
	'004', ;   			            // [02] Ordem
	'Data', ;			        // [03] Titulo
	'Data', ;			        // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	PesqPict('ZRP','ZRP_DATA'), ; // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.T., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	0, ;      				        // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

//Numero do PV
	oStructViewGrid:AddField( ;
		'ZRP_OBS', ;  			    // [01] Campo
	'005', ;   			            // [02] Ordem
	'OBS', ;			            // [03] Titulo
	'OBS', ;			            // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	PesqPict('ZRP','ZRP_OBS'), ;  // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.T., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	0, ;      				        // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

Return oStructViewGrid


	************************************************************ X
/*////////////////////////////////////////////////////////*/ *
/*			Atualiza o campo do cabe�alho				  */ *
/*////////////////////////////////////////////////////////*/ *
	************************************************************ X
static function onActivate(oModel)

	Local oCabTMP := oModel:GetModel("ZRQMASTER")
//S� efetua a altera��o do campo para inser��o
	if oModel:GetOperation() == MODEL_OPERATION_INSERT
		FwFldPut("ZRQ_NUM", SC5->C5_NUM , /*nLinha*/, oModel)
		FwFldPut("ZRQ_SALDO", oCabTMP:GetValue("ZRQ_TOTAL") , /*nLinha*/, oModel)
	endif

return



	************************************************************ X
/*////////////////////////////////////////////////////////*/ *
/*			Busca o Valor Total do Pedido          		  */ *
/*////////////////////////////////////////////////////////*/ *
	************************************************************ X
User Function PrVend1()
	Local aArea         := GetArea()
	Local nValor   		:= 0
	Local nValorTotal 	:= 0
	Local cPedido       := SC5->C5_NUM
	Local cQuery        := ""

	cQuery:="   SELECT C6_VALOR "
	cQuery+="   FROM "+RETSQLNAME("SC6")+" SC6 "
	cQuery+="   INNER JOIN "+RETSQLNAME("SC5")+" SC5 ON SC5.C5_NUM = SC6.C6_NUM"
	cQuery+="   WHERE C5_NUM = '"+cPedido+"'"
	cQuery+="   AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery+="   AND C6_FILIAL = '"+xFilial("SC6")+"' "
	cQuery+="   AND SC5.D_E_L_E_T_     <> '*'   "
	cQuery+="   AND SC6.D_E_L_E_T_     <> '*'   "
	cQuery := MPSysOpenQuery(cQuery)

	While (cQuery)->(!Eof())
		nValor += (cQuery)->C6_VALOR
		(cQuery)->(DbSkip())
	End
	nValorTotal := /*"R$ " +*/ Val(Alltrim(Transform(nValor, "@E 999,999.99")))

	(cQuery)->(DbCloseArea())

	RestArea(aArea)
Return nValorTotal




	************************************************************ X
/*////////////////////////////////////////////////////////*/ *
/*			Condi��o do Gatilho da Data           		  */ *
/*////////////////////////////////////////////////////////*/ *
	************************************************************ X
User Function DatRet(oModel)
	Local dData
	If AllTrim(oModel:GetValue('ZRP_COND')) <> 'Deposito'
		dData:= dDataBase
	Endif
Return dData



	****************************************************************************** X
/*//////////////////////////////////////////////////////////////////////////*/ *
/*				Modifica o Saldo de Acordo com o Campo ZRP_VLR         	    */ *
/*//////////////////////////////////////////////////////////////////////////*/ *
	****************************************************************************** X
Static Function fn01lPG(oGrid, nLine, cAction, cIDField, xValue, xCurrentValue)
	Local lRet    := .T.
	Local nId     := 0
	Local nVlPago := 0
	Local oModel  := FWModelActive()
	Local oTotS   := oModel:GetModel('ZRQCHEF')
	Local oCabTMP := oModel:GetModel("ZRQMASTER")

	If cAction == 'SETVALUE' .AND. cIdField == 'ZRP_VLR'

		For nId := 1 To oGrid:Length()
			If !oGrid:IsDeleted()
				If nId == nLine
					nVlPago += xValue
				Else
					nVlPago += oGrid:GetValue('ZRP_VLR', nId)
				EndIf
			EndIf
		Next
		oTotS:LoadValue('ZRQ_SALDO' , oCabTMP:GetValue('ZRQ_TOTAL') - nVlPago)
	elseif cAction == 'DELETE'

		nVlPago := oGrid:GetValue('ZRP_VLR', nLine)

		oTotS:LoadValue('ZRQ_SALDO' , oTotS:GetValue('ZRQ_SALDO') + nVlPago)
	EndIf

Return lRet

Static Function Confirm(oModel)
	Local nX 	  := 0
	Local oCabTMP := oModel:GetModel("ZRQMASTER")
	Local oGrdZRP := oModel:GetModel("ZRPDETAIL")
	Local oTotS   := oModel:GetModel('ZRQCHEF')
	Local nValTot := 0
	Local nValPix := 0

	If Round(oTotS:GetValue('ZRQ_SALDO'), 2) <> 0
		MsgAlert('Pagamento n�o pode ser fechado enquanto saldo n�o for igual a zero.')
		Return .F.
	EndIf

	RecLock("ZRQ", .T.)
	ZRQ->ZRQ_FILIAL := FWxFilial('ZRQ')
	ZRQ->ZRQ_NUM    := SC5->C5_NUM
	ZRQ->ZRQ_CLI    := SC5->C5_CLIENTE
	ZRQ->ZRQ_TOTAL  := oCabTMP:GetValue('ZRQ_TOTAL')
	ZRQ->ZRQ_SALDO  := oTotS:GetValue('ZRQ_SALDO')
	ZRQ->(MsUnlock())

	ZRP->(DbSetOrder(1))
	For nX := 1 to oGrdZRP:Length()
		Reclock("ZRP", .T.)
		ZRP->ZRP_FILIAL := FWxFilial('ZRP')
		ZRP->ZRP_NUM 	:= SC5->C5_NUM
		ZRP->ZRP_CLI 	:= SC5->C5_CLIENTE
		ZRP->ZRP_ITEM	:= IIF(nX < 10, "0"+CValToChar(nX), CValToChar(nX))
		ZRP->ZRP_VLR 	:= oGrdZRP:GetValue('ZRP_VLR', nX)
		ZRP->ZRP_DATA 	:= oGrdZRP:GetValue('ZRP_DATA', nX)
		ZRP->ZRP_OBS 	:= oGrdZRP:GetValue('ZRP_OBS', nX)
		ZRP->ZRP_COND 	:= oGrdZRP:GetValue('ZRP_COND', nX)
		ZRP->ZRP_PARC 	:= oGrdZRP:GetValue('ZRP_PARC', nX)
		ZRP->ZRP_AUTC 	:= oGrdZRP:GetValue('ZRP_AUTC', nX)
		ZRP->(MsUnlock())

		If oGrdZRP:GetValue('ZRP_COND', nX) <> "P"
			nValTot += oGrdZRP:GetValue('ZRP_VLR', nX)
		Else
			nValPix += oGrdZRP:GetValue('ZRP_VLR', nX)
		EndIf
	Next

	If nValTot > 0
		U_GeraNCC(cEmpAnt, cFilAnt, oCabTMP:GetValue('ZRQ_CLI'), nValTot)
	EndIf

	If nValPix > 0
		U_ExbQrCode(nValPix, .T.)
	EndIf

Return .T.

Static Function TUSACarga(oModel)
	Local aResult		:= {}
	Local cAliasZRP 	:= GetNextAlias()

	TUSAQuery(@cAliasZRP)//gera a query para a View

	aResult := FwLoadByAlias(oModel,(cAliasZRP))

Return aResult

Static Function TUSAQuery(cAliasZRP)

	Local cQuery 	:= ""

	cAliasZRP := GetNextAlias()

	cQuery += " SELECT ZRP_COND,ZRP_PARC,ZRP_AUTC,ZRP_VLR,ZRP_DATA,ZRP_OBS  "
	cQuery += " FROM "+RetSqlName('ZRP')+" ZRP "
	cQuery += " 	INNER JOIN "+RetSqlName('ZRQ')+" ZRQ ON ZRQ.ZRQ_NUM = ZRP.ZRP_NUM "
	cQuery += "   	AND ZRQ.ZRQ_FILIAL = ZRP.ZRP_FILIAL "
	cQuery += " WHERE ZRQ.ZRQ_NUM = '"+SC5->C5_NUM+"' AND ZRQ.ZRQ_FILIAL ='"+SC5->C5_FILIAL+"' "
	cQuery += "    	AND ZRQ.D_E_L_E_T_ <> '*' "
	cQuery += "   	AND ZRP.D_E_L_E_T_ <> '*' "
	cQuery += " 	ORDER BY ZRP_ITEM "

	MpSysOpenQuery(cQuery, cAliasZRP)
	(cAliasZRP)->(dbGoTop())

Return cAliasZRP
