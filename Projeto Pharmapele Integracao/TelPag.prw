#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

#DEFINE  CABECALHO  "ZLP_FILIAL/ZLP_CODLP/ZLP_CODORC/ZLP_CODTB/ZLP_CODVEN/ZLP_NOMEVE/ZLP_CONTCL/ZLP_VALOR/ZLP_LINKPG/ZLP_DATA/ZLP_HORA/ZLP_STATUS/ZLP_BANCO/ZLP_IDLINK/ZLP_DESCT/"
#DEFINE  ITENS      "ZLK_FILIAL/ZLK_ITEM/ZLK_CODLP/ZLK_CODORC/ZLK_CODPRD/ZLK_DESC/ZLK_UM/ZLK_QUANT/ZLK_UNIT/ZLK_TOTAL/"
Static 	 cTitle :=  "Tela de Pagamentos"

*-------------------------------------------------------------------------------------
************************************************************************************ X
/*@nomeFunction: 	  					U_TelPag()						   		  */ *
/*--------------------------------------------------------------------------------*/ *
/*							  FunÁ„o de Montagem da Tela MVC	 				  */ *
/*					 	  Gravando os Dados nas Tabelas ZLP e ZLK				  */ *
/*					  Tela de Vinculo dos Produtos para TransformaÁ„o			  */ *
/*--------------------------------------------------------------------------------*/ *
/*@author: 						Jose.Machado - CodERP							  */ *
/*@since: 				    	  	   21/09/2022								  */ *
************************************************************************************ X
*-------------------------------------------------------------------------------------
User Function TelPag()
	Local oBrowse := NIL

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZLP')                               // Alias da tabela utilizada
	oBrowse:SetDescription(cTitle)
	oBrowse:DisableDetails()

	oBrowse:AddLegend( "ZLP->ZLP_STATUS == '1' ", "BLUE" ,    "Aguardando pagamento")
    oBrowse:AddLegend( "ZLP->ZLP_STATUS == '2' ", "RED"  ,    "Link Expirado"		)
    oBrowse:AddLegend( "ZLP->ZLP_STATUS == '3' ", "GREEN",    "Link Pago"    		)
    oBrowse:AddLegend( "ZLP->ZLP_STATUS == '4' ", "BLACK",    "Encerrado"    		)
    oBrowse:Activate()

Return

User Function MVCLegendas()
	Local aLegenda := {}

	//Monta as cores
	AADD(aLegenda,{"BR_AZUL"	,  "Aguardando pagamento"})
	AADD(aLegenda,{"BR_VERMELHO",  "Link Expirado"		 })
	AADD(aLegenda,{"BR_VERDE"	,  "Link Pago"			 })
	AADD(aLegenda,{"BR_PRETO"	,  "Encerrado"		 	 })

	BrwLegenda("Status do Link", "Link pagamento", aLegenda)
Return

	*-------------------------------------------------------------------------------------
	*************************************************************************************X
/*////////////////////////////////////////////////////////////////////////////////*/ *
/*@nomeFunction: 	  					MenuDef()							   	  */ *
/*--------------------------------------------------------------------------------*/ *
/*									Menu do Browser					  			  */ *
/*--------------------------------------------------------------------------------*/ *
/*@author: 						Rivaldo.J˙nior - CodERP							  */ *
/*@since: 				    	  	   20/09/2022								  */ *
/*////////////////////////////////////////////////////////////////////////////////*/ *
	*************************************************************************************X
	*-------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.TelPag' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.TelPag' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.TelPag' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.TelPag' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Legenda'    ACTION 'U_MVCLegendas'  OPERATION 6 ACCESS 0 
	ADD OPTION aRotina TITLE 'Gerar Novamente'   ACTION 'U_GeraNov' OPERATION 8 ACCESS 0

	//ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.TelPag' OPERATION 9 ACCESS 0

Return aRotina



	*-------------------------------------------------------------------------------------
	*************************************************************************************X
/*////////////////////////////////////////////////////////////////////////////////*/ *
/*@nomeFunction: 	  					ModelDef()							   	  */ *
/*--------------------------------------------------------------------------------*/ *
/*							   Modelo do cabecalho e grid		  				  */ *
/*--------------------------------------------------------------------------------*/ *
/*@author: 						Rivaldo.J˙nior - CodERP							  */ *
/*@since: 				    	  	   20/09/2022								  */ *
/*////////////////////////////////////////////////////////////////////////////////*/ *
	*************************************************************************************X
	*-------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel   := Nil
	Local oStPai   := FWFormStruct( 1, 'ZLP', { |cCampo|  AllTrim( cCampo ) + '/' $ CABECALHO } )
	Local oStFilho := FWFormStruct( 1, 'ZLK', { |cCampo|  AllTrim( cCampo ) + '/' $ ITENS }  )
	//Local oStNeto  := FWFormStruct( 1, 'ZLP', { |cCampo|  AllTrim( cCampo ) + '/' $ 'ZLP_VALOR' } )
	Local bCamValid:= {|oModel, cAction, cIDField, xValue|  ValidEx(cAction, cIDField, xValue)}

	oModel := MPFormModel():New("MTelPag", /*{|oModel| MDMVlPre( oModel ) }bPre*/, /*{|oModel| MDMVlPos( oModel ) }/*bPos*/,/*{||ComplZZ3( Self ) }bCommit*/,/*bCancel*/)
	oModel:SetDescription(OemtoAnsi("Produtos") )

	oModel:AddFields('ZLPMASTER',/*cOwner*/,oStPai, bCamValid /*bPreValidacao*/,/*bPosValidacao*/,/*{ || AN001(oModel)}*/)
	oModel:AddGrid('ZLKDETAIL','ZLPMASTER' ,oStFilho, /*{|oModel,nLine,cAction| linePreGrid(oModel,nLine, cAction)}*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/)//, {|oModel|AN002( oModel ) } )
	//oModel:AddFields('ZLPFNETO','ZLKDETAIL',oStNeto, /*bPreValidacao*/, /*bPosValidacao*/, /*{ || AN001(oModel)}*/)

	oModel:SetPrimaryKey( { "ZLP_FILIAL" , "ZLK_CODLP" })

	//Relacionamento das tabelas
	oModel:SetRelation('ZLKDETAIL', {{'ZLK_FILIAL','fWxfilial("ZLK")'},{'ZLK_CODLP','ZLP_CODLP'}}, ZLK->( IndexKey( 1 ) ))

	oStFilho:AddTrigger('ZLK_UNIT','ZLK_TOTAL',,{|oStFilho| (oStFilho:GetValue('ZLK_UNIT')*oStFilho:GetValue('ZLK_QUANT')) })
	oStFilho:AddTrigger('ZLK_QUANT','ZLK_TOTAL',,{|oStFilho| (oStFilho:GetValue('ZLK_UNIT')*oStFilho:GetValue('ZLK_QUANT')) })

	//Setando as descriùùes
	oModel:GetModel('ZLPMASTER'):SetDescription('Cabecalho')
	oModel:GetModel('ZLKDETAIL'):SetDescription('Itens do Grid')

	//Adicionando totalizadores
	oModel:AddCalc('TOT_SALDO', 'ZLPMASTER', 'ZLKDETAIL', 'ZLK_TOTAL', 'XX_TOTAL', 'FORMULA',{|| .T.},{|| 0}, "VALOR TOTAL" ,;
	{|oModel| CalcTot(oModel)},10,2 )

	oModel:setActivate({ |oModel| onActivate(oModel)})

Return oModel

static function onActivate(oModel)

//SÛ efetua a alteraÁ„o do campo para inserÁ„o
	if oModel:GetOperation() == MODEL_OPERATION_INSERT
		FwFldPut("ZLP_DESCT", 0 , /*nLinha*/, oModel)
	endif

return



	*-------------------------------------------------------------------------------------
	*************************************************************************************X
/*////////////////////////////////////////////////////////////////////////////////*/ *
/*@nomeFunction: 	  					ViewDef()							   	  */ *
/*--------------------------------------------------------------------------------*/ *
/*							  ExibiÁao do cabecalho e grid		  				  */ *
/*--------------------------------------------------------------------------------*/ *
/*@author: 						Rivaldo.J˙nior - CodERP							  */ *
/*@since: 				    	  	   20/09/2022								  */ *
/*////////////////////////////////////////////////////////////////////////////////*/ *
	*************************************************************************************X
	*-------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oView     := Nil
	Local oModel    := FWLoadModel('TelPag')
	Local oStPai 	:= FWFormStruct( 2, 'ZLP' ,{ |cCampo|  AllTrim( cCampo ) + '/' $ CABECALHO })
	Local oStFilho 	:= FWFormStruct( 2, 'ZLK' ,{ |cCampo|  AllTrim( cCampo ) + '/' $ ITENS })
	Local oStNeto   := FWCalcStruct(oModel:GetModel('TOT_SALDO'))
 
	// Campos que ser„o removidos da View
	// CABE«ALHO
	oStPai:removeField("ZLP_CODLP")
	oStPai:removeField("ZLP_CODTB")
	oStPai:removeField("ZLP_STATUS")
	oStPai:removeField("ZLP_HORA")
	oStPai:removeField("ZLP_VALOR")

	// ITENS
	oStFilho:removeField("ZLK_CODLP")
	oStFilho:removeField("ZLK_CODORC")

	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	//Adicionando os campos do cabeùalho e o grid dos filhos
	oView:AddField('VIEW_CAB', oStPai ,'ZLPMASTER')
	oView:AddGrid( 'VIEW_DET',oStFilho,'ZLKDETAIL')
	oView:AddField('VIEW_TOT', oStNeto ,'TOT_SALDO')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',25)
	oView:CreateHorizontalBox('GRID' ,65)
	oView:CreateHorizontalBox('TOTAL',10)
	oView:CreateVerticalBox("BOX_INFERIOR_ESQUERDO",70, "TOTAL")
	oView:CreateVerticalBox("BOX_INFERIOR_DIREITO",30, "TOTAL")

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB','CABEC')
	oView:SetOwnerView('VIEW_DET','GRID')
	oView:SetOwnerView('VIEW_TOT','BOX_INFERIOR_DIREITO')

	oView:AddIncrementField('VIEW_DET', 'ZLK_ITEM')

Return oView

Static Function ValidEx(cAction, cIDField, xValue)
	Local oModel  := FWModelActive()
	//Local oTotal  := oModel:GetModel('TOT_SALDO')
	Local oGrid   := oModel:GetModel("ZLKDETAIL")
	Local nTotal  := 0
	Local nValor  := 0
	Local nX      := 0
	Local oView  

	If cAction == "SETVALUE" .AND. xValue <> NIL .AND. cIDField == "ZLP_DESCT"

 		For nX := 1 To oGrid:Length()
			oGrid:GoLine(nX)
			nTotal += oGrid:GetValue("ZLK_TOTAL")		
		Next
		nValor := (nTotal - xValue)

		oModel:SetValue("TOT_SALDO","XX_TOTAL", nValor )
		//oModel:LoadValue("TOT_SALDO","XX_TOTAL", nValor )
		oView := FWViewActive()

	ElseIf cAction == "SETVALUE" .AND. xValue <> NIL .AND. cIDField == "ZLP_CODORC"

		Processa({|| CarregaGrid(xValue) },"Aguarde um momento, Buscando dados do orÁamento...")

	EndIf

Return .T.



Static Function CalcTot(oModel)
	Local oGrid := oModel:GetModel("ZLKDETAIL")
	Local oCab  := oModel:GetModel("ZLPMASTER")
	Local nX 	:= 0
	Local nTotal:= 0

	For nX := 1 To oGrid:Length()
		oGrid:GoLine(nX)
		nTotal += oGrid:GetValue("ZLK_TOTAL")		
	Next

	oCab:LoadValue("ZLP_DESCT", 0 )

Return (nTotal-oCab:GetValue("ZLP_DESCT"))


Static Function CarregaGrid(xValue)
	Local oModel  := FWModelActive()
	Local oGrid   := oModel:GetModel("ZLKDETAIL")
	Local oCab	  := oModel:GetModel("ZLPMASTER")
	Local aItens  := {}
	Local nX      := 0

	aItens := U_BuscOrc(xValue, cFilAnt)

	If xValue <> oCab:GetValue("ZLP_CODORC") .And. oGrid:Length() > 1 //Limpando a grid
		oGrid:ClearData()
	EndIf

	If Len(aItens) > 0
		DbSelectArea("SB1")
		For nX := 1 To Len(aItens)
			oGrid:GoLine(nX)
			SB1->(MsSeek(xFilial("SB1")+aItens[nx,3]))
			oGrid:LoadValue("ZLK_CODORC", aItens[nx,1] ) //Campo de OrÁamento
			oGrid:LoadValue("ZLK_CODPRD", aItens[nx,3] ) //Campo de Produto
			oGrid:LoadValue("ZLK_DESC"  , iIf(Empty(aItens[nx,4]),SB1->B1_DESC,aItens[nx,4]) ) //Campo de DescriÁ„o
			oGrid:LoadValue("ZLK_UM"  	, iIf(Empty(aItens[nx,5]),SB1->B1_DESC,aItens[nx,5]) ) //Campo de Unid. Medida
			oGrid:LoadValue("ZLK_QUANT" , Val(aItens[nx,6]) ) //Campo de Quantidade
			oGrid:LoadValue("ZLK_UNIT"  , Val(StrTran(aItens[1,7],",",".")) ) //Campo de Valor
			oGrid:LoadValue("ZLK_TOTAL" , (Val(StrTran(aItens[1,7],",","."))*Val(aItens[nx,6])) ) //Campo de Valor
			If oGrid:Length() < Len(aItens)
				oGrid:AddLine()
			EndIf
		Next nX
		oGrid:GoLine(1)
	Else 
		oCab:ClearField("ZLP_CODORC")
		If oGrid:Length() > 1 //Limpando a grid
			oGrid:ClearData()
		EndIf
	EndIf

Return


User Function GeraNov()
	Local lRet 	  := .T.

	If ZLP->ZLP_STATUS == '1'
		FWAlertWarning("Link n„o expirado, n„o È necess·rio gerar novamente.","AtenÁ„o!")
		Return .F.
	ElseIf ZLP->ZLP_STATUS == '3'
		FWAlertWarning("Link j· pago, n„o È necess·rio gerar novamente.","AtenÁ„o!")
		Return .F.
	EndIf

	Processa({|| lRet := GeraNovo()},"Aguarde um momento, Gerando um novo registro, um novo link e enviando ao cliente...")

	If lRet 
		FWAlertSuccess('Novo Link de pagamento gerado e enviado ao cliente.','Sucesso!') 
	Else
		FWAlertError("N„o foi possÌvel gerar o link.","AtenÁ„o!")
	EndIf

Return lRet



Static Function GeraNovo()
	Local aAreaZLP  := ZLP->(GetArea())
	Local aAreaZLK  := ZLK->(GetArea())
	Local cQuery    := GetNextAlias()
	Local lRet      := .F.
	Local cStatus   := ''
    Local cContato  := ''
    Local cNome     := ''
    Local cMensagem := ''
	Local cFilPro   := ZLP->ZLP_FILIAL
	Local cCodLp    := ZLP->ZLP_CODLP
	Local cNomeVe   := ZLP->ZLP_NOMEVE
	Local cCodOrc   := ZLP->ZLP_CODORC
	Local nValor    := ZLP->ZLP_VALOR
	Local cCodTb    := ZLP->ZLP_CODTB
	Local cCodven   := ZLP->ZLP_CODVEN
	Local cContCl   := ZLP->ZLP_CONTCL
	Local cBanco    := ZLP->ZLP_BANCO
	Local nDescont  := ZLP->ZLP_DESCT

	DbSelectArea("ZLK")
	//Busco pelos itens do processo expirado
	BeginSql Alias cQuery
		SELECT * FROM %Table:ZLK% ZLK
		INNER JOIN %Table:ZLP% ZLP ON ZLP_FILIAL = ZLK_FILIAL AND ZLP_CODLP = ZLK_CODLP
		WHERE ZLK_FILIAL = %EXP:ZLP->ZLP_FILIAL% 
			AND ZLK_CODLP = %EXP:cCodLp%
			AND ZLP.%NOTDEL%
			AND ZLK.%NOTDEL%
	EndSql

	If (cQuery)->(!Eof())
		
		ZLP->(RecLock("ZLP",.T.))//Gero o novo processo 
			ZLP->ZLP_FILIAL	:= cFilPro
			ZLP->ZLP_NOMEVE	:= cNomeVe
			ZLP->ZLP_VALOR	:= nValor
			ZLP->ZLP_LINKPG	:= ''
			ZLP->ZLP_CODLP	:= GetSxENum("ZLP","ZLP_CODLP")// pego o cÛdigo do novo processo
			ZLP->ZLP_CODORC	:= cCodOrc
			ZLP->ZLP_CODTB	:= cCodTb
			ZLP->ZLP_CODVEN	:= cCodven
			ZLP->ZLP_STATUS	:= '1'
			ZLP->ZLP_CONTCL	:= cContCl
			ZLP->ZLP_BANCO	:= cBanco
			ZLP->ZLP_DATA	:= Date()
			ZLP->ZLP_HORA	:= ''	
			ZLP->ZLP_IDLINK	:= ''
			ZLP->ZLP_DESCT	:= nDescont	
		ZLP->(MsUnLock())

		While (cQuery)->(!Eof())// gravo os itens do novo processo 
			ZLK->(RecLock("ZLK",.T.))
				ZLK->ZLK_FILIAL	:= (cQuery)->ZLK_FILIAL
				ZLK->ZLK_ITEM	:= (cQuery)->ZLK_ITEM
				ZLK->ZLK_CODPRD	:= (cQuery)->ZLK_CODPRD
				ZLK->ZLK_DESC	:= (cQuery)->ZLK_DESC
				ZLK->ZLK_UM		:= (cQuery)->ZLK_UM	
				ZLK->ZLK_CODORC	:= (cQuery)->ZLK_CODORC
				ZLK->ZLK_CODLP	:= ZLP->ZLP_CODLP
				ZLK->ZLK_QUANT	:= (cQuery)->ZLK_QUANT
				ZLK->ZLK_UNIT	:= (cQuery)->ZLK_UNIT
				ZLK->ZLK_TOTAL	:= (cQuery)->ZLK_TOTAL
			ZLK->(MsUnLock())
			(cQuery)->(DbSkip())
		End 

		lRet := U_ConsRest(nil, .T.) //chamo a funÁ„o para gerar um novo link

		If lRet 
			cContato := "55"+ZLP->ZLP_CONTCL
			cNome    := "RIVALDO JUNIOR"
			cMensagem:= "Segue link de pagamento referente a sua compra na Pharmapele."+CRLF
			cMensagem+= AllTrim(ZLP->ZLP_LINKPG)

			cStatus := U_Chat2Desk(cContato, cNome, cMensagem)

			If ZLP->(DbSeek(xFilial("ZLP")+cCodLp)) //Marco o registro anterior com status de encerrado
				ZLP->(RecLock("ZLP",.F.))
					ZLP->ZLP_STATUS	:= '4'
				ZLP->(MsUnLock())
			EndIf

		Else 
			While ZLK->(!Eof()) .And. ZLK->(ZLK_CODLP+ZLK_FILIAL) == ZLP->ZLP_CODLP+cFilAnt// gravo os itens do novo processo 
				ZLK->(RecLock("ZLK",.F.))
					ZLK->(DbDelete())
				ZLK->(MsUnLock())
				ZLK->(DbSkip())
			End 

			ZLP->(RecLock("ZLP",.F.))
				ZLP->(DbDelete())
			ZLP->(MsUnLock())
		EndIf
	EndIf

	RestArea(aAreaZLP)
	RestArea(aAreaZLK)

Return lRet
