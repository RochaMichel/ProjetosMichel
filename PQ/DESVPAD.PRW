#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'


#DEFINE  CABECALHO  "ZR2_FILIAL/ZR2_NPRO/ZR2_DOC/ZR2_SERIE/ZR2_FORN/ZR2_FLOJA/ZR2_FDESC/ZR2_CLI/ZR2_CLOJA/ZR2_CDESC/ZR2_TESE/ZR2_STATUS/ZR2_DATA/ZR2_USER/ZR2_PEDIDO/ZR2_DOCS/ZR2_SSERIE/ZR2_CONDPS/ZR2_CONDPE/ZR2_OPER/ZR2_OBS/"
#DEFINE  ITENS		"ZR3_FILIAL/ZR3_ITEM/ZR3_PROD/ZR3_DESC/ZR3_UM/ZR3_LOCAL/ZR3_QUANT/ZR3_PRCVEN/ZR3_VLRT/ZR3_NPRO/"
Static 	 cTitle :=  "Desvio padrão"

User Function DESVPAD()
	Local aArea   := GetArea()
	Local oBrowse := NIL

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZR2')
	oBrowse:SetDescription(cTitle)
	oBrowse:DisableDetails()

	//Legendas
	oBrowse:AddLegend( "ZR2_STATUS == '1'", "GREEN"  ,  "Não Efetivado" 	   )
	oBrowse:AddLegend( "ZR2_STATUS == '2'", "RED"    ,  "Efetivado" 		   )
	oBrowse:AddLegend( "ZR2_STATUS == '3'", "BLUE"   ,  "Pedido bloq. estoque" )
	oBrowse:AddLegend( "ZR2_STATUS == '4'", "YELLOW" ,  "Pedido bloq. credito" )

	oBrowse:Activate()
	RestArea(aArea)
Return

Static Function MenuDef()
	Private aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.DESVPAD' OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Efetivar'   ACTION 'U_Efetivar'	   OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.DESVPAD' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.DESVPAD' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.DESVPAD' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Legenda'    ACTION 'U_MVCLegDesvPad' OPERATION 6 ACCESS 0
	//ADD OPTION aRotina TITLE 'Importar'   ACTION 'VIEWDEF.DESVPAD' OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'Relatorio'  ACTION 'U_RelDvP' 	   OPERATION 7 ACCESS 0

Return aRotina

Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStPai   	:= FWFormStruct( 1, 'ZR2', { |cCampo|  AllTrim( cCampo ) + '/' $ CABECALHO } )
	Local oStFilho 	:= FWFormStruct( 1, 'ZR3', { |cCampo|  AllTrim( cCampo ) + '/' $ ITENS }  )
	Local bCamValid := {|oModel, cAction, cIDField, xValue|  CarGrid(oModel, cAction, cIDField, xValue)}

	oModel := MPFormModel():New("MDESVPAD",/*{ |oModel| ZD3VAL( oModel )}*/ , /*{ |oModel| U_GRVZR(oModel) }*/)
	oModel:AddFields('ZR2CAB',/*cOwner*/,oStPai,bCamValid /*bPreValid  bPreValidacao*/, /*bPosValidacao*/, /*{|oMdl| loadHidFld()}*/)
	oModel:AddGrid('ZR3GRID','ZR2CAB',oStFilho, /*{|oModel,nLine,cAction| linePreGrid(oModel,nLine, cAction)}*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,/*{|oStPai| CarGrid( oStPai ) }*/)
	oModel:SetPrimaryKey({'ZR2_FILIAL', 'ZR3_NPRO'})
	oModel:SetRelation('ZR3GRID', {{'ZR3_FILIAL','xFilial("ZR3")'},{'ZR3_NPRO','ZR2_NPRO'}}, ZR3->( IndexKey( 1 ) ))

	oStFilho:AddTrigger("ZR3_PROD","ZR3_PRCVEN",,{|oModel| ValMedio(oModel)})
	oStFilho:AddTrigger("ZR3_QUANT","ZR3_VLRT",,{|oModel| (oModel:GetValue('ZR3_QUANT')*oModel:GetValue('ZR3_PRCVEN'))})

	//Setando as descrições
	oModel:GetModel('ZR2CAB'):SetDescription('Cabecalho')
	oModel:GetModel('ZR3GRID'):SetDescription('Itens da Grid')
	oModel:GetModel("ZR3GRID"):SetNoDeleteLine(.T.)
	oModel:GetModel("ZR3GRID"):SetNoInsertLine(.T.)
	//oModel:GetModel("ZR3GRID"):SetNoUpdateLine(.T.)

	oModel:setActivate({ |oModel| onActivate(oModel)})

Return oModel

Static Function ViewDef()
	Local oView     := Nil
	Local oModel    := FWLoadModel('DESVPAD')
	Local oStPai 	:= FWFormStruct( 2, 'ZR2' ,{ |cCampo|  AllTrim( cCampo ) + '/' $ CABECALHO } )
	Local oStFilho 	:= FWFormStruct( 2, 'ZR3' ,{ |cCampo|  AllTrim( cCampo ) + '/' $ ITENS } )

	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_CAB',oStPai,'ZR2CAB')
	oView:AddGrid('VIEW_GRID',oStFilho,'ZR3GRID')

	//Remove os campos que não irão aparecer
	oStPai:RemoveField('ZR2_USER')
	oStPai:RemoveField('ZR2_PEDIDO')
	oStPai:RemoveField('ZR2_DOCS')
	oStPai:RemoveField('ZR2_SSERIE')
	oStPai:RemoveField('ZR2_STATUS')
	oStFilho:RemoveField('ZR3_NPRO')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',50)
	oView:CreateHorizontalBox('GRID',50)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB','CABEC')
	oView:SetOwnerView('VIEW_GRID','GRID')

	oView:AddIncrementField('VIEW_GRID', 'ZR3_ITEM')

Return oView

//função para exibição das legendas na tela
User Function MVCLegDesvPad()
	Local aLegenda := {}

	//Monta as cores
	AADD(aLegenda,{"BR_VERDE"	, "Não Efetivado"	    })
	AADD(aLegenda,{"BR_VERMELHO", "Efetivado"	 	    })
	AADD(aLegenda,{"BR_AZUL"	, "Pedido bloq. estoque"})
	AADD(aLegenda,{"BR_AMARELO"	, "Pedido bloq. credito"})

	BrwLegenda("Detalhes dos registros", "Procedencia", aLegenda)
Return

Static Function onActivate(oModel)

	If Inclui//oModel:GetOperation() == MODEL_OPERATION_INSERT
		FwFldPut("ZR2_USER", RetCodUsr() , /*nLinha*/, oModel)
		If Empty(M->ZR2_STATUS)
			FwFldPut("ZR2_STATUS", '1' , /*nLinha*/, oModel)
		EndIf
	endif

Return

Static Function ValMedio(oModel)
	Local aArea   := GetArea()
	Local aSaldos := {}
	Local cProd   := oModel:GetValue('ZR3_PROD')
	Local cLocal  := oModel:GetValue('ZR3_LOCAL')
	Local nTotal  := 0

	DbSelectArea("SB2")
	SB2->(DbSetOrder(1))
	If SB2->(DbSeek(xFilial("SB2")+cProd+cLocal))
		aSaldos:=CalcEst(SB2->B2_COD,SB2->B2_LOCAL,dDataBase)
		nTotal := aSaldos[2]/aSaldos[1]
	endif

	RestArea(aArea) 
Return nTotal


Static Function CarGrid(oSt, cAction, cIDField, xValue )
	Local oModel  := FWModelActive()
	Local oCab    := oModel:GetModel("ZR2CAB")
	Local oGrid   := oModel:GetModel("ZR3GRID")
	Local cSD2QRY := GetNextAlias()
	Local nCount  := 0

	If cAction == "SETVALUE" .AND. xValue <> NIL .AND. cIDField == "ZR2_DOC"

		BeginSql Alias cSD2QRY
		SELECT D1_COD, D1_LOCAL, D1_UM, D1_QUANT, D1_VUNIT, D1_TOTAL, D1_TES, SF1.*, A2_NOME AS NOME
		FROM %Table:SF1% SF1
		INNER JOIN %Table:SD1% SD1 ON D1_FILIAL = F1_FILIAL AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA
		INNER JOIN %Table:SA2% SA2 ON A2_COD = F1_FORNECE AND A2_LOJA = F1_LOJA
		WHERE F1_FILIAL = %xFilial:SF1%	
			AND F1_DOC = %Exp:xValue%
			AND F1_SERIE = %Exp:SF1->F1_SERIE%
			AND F1_FORNECE = %Exp:SF1->F1_FORNECE%
			AND F1_LOJA = %Exp:SF1->F1_LOJA%
			AND SF1.%NOTDEL% 
			AND SD1.%NOTDEL% 
			AND SA2.%NOTDEL% 
		EndSql

		If (cSD2QRY)->(Eof())
			FwAlertWarning("Nota fiscal não encontrada.","Atenção!")
			Return .F.
		EndIf

		DbSelectArea("ZR2")
		ZR2->(DbSetOrder(2))
		If ZR2->(DbSeek(xFilial("ZR2")+(cSD2QRY)->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
			FwAlertWarning("Nota fiscal já amarrada a um processo de desvio padrão.","Atenção!")
			Return .F.
		EndIf

		If oGrid:Length() > 0 //Limpando a grid
			oGrid:ClearData()
		EndIf

		oCab:LoadValue("ZR2_TESE", (cSD2QRY)->D1_TES ) //Campo de Orçamento

		If (cSD2QRY)->(!Eof())
			While (cSD2QRY)->(!Eof())
				nCount++
				oGrid:GoLine(nCount)
				oGrid:LoadValue("ZR3_PROD"	, (cSD2QRY)->D1_COD ) //Campo de Orçamento
				oGrid:LoadValue("ZR3_DESC"	, AllTrim(Posicione("SB1",1,xFilial("SB1")+(cSD2QRY)->D1_COD,"B1_DESC")) ) //Campo de Produto
				oGrid:LoadValue("ZR3_LOCAL" , AllTrim((cSD2QRY)->D1_LOCAL) ) //Campo de Descrição
				oGrid:LoadValue("ZR3_UM"    , (cSD2QRY)->D1_UM ) //Campo de Descrição
				oGrid:LoadValue("ZR3_QUANT" , (cSD2QRY)->D1_QUANT ) //Campo de Unid. Medida
				oGrid:LoadValue("ZR3_PRCVEN", (cSD2QRY)->D1_VUNIT ) //Campo de Quantidade
				oGrid:LoadValue("ZR3_VLRT"  , (cSD2QRY)->D1_TOTAL ) //Campo de Valor
				(cSD2QRY)->(DbSkip())
				If (cSD2QRY)->(!Eof())
					oGrid:AddLine()
				EndIf
			End
			oGrid:GoLine(1)
		EndIf
		ZR2->(DbSetOrder(1))
	EndIf

Return




//Inicia a efetivação gerando o documento de entrada 
User Function Efetivar()
	Local aArea := GetArea()
	Local aStatus:= {.F.,"1"}

	// Valido se o processo já foi efetivado, para não repetir a mesma efetivação
	If ZR2->ZR2_STATUS $ '2|3' 
		FwAlertWarning("Processo já efetivado anteriormente.","ATENÇÃO!")
		Return
	EndIf

	Processa({|| aStatus := U_Efetiva2()},"Aguarde um momento, Efetivando o processo...")

	If aStatus[1]
		//FwAlertError("Erro no processo, não foi possível efetivar. Pedido com bloqueio ou erro de validação no cliente.","Atenção!")
		Help(" ",1,"Erro no processo",,"Não foi possível efetivar. Pedido com bloqueio, erro de validação no cliente ou inconsistência nas informações.",3,1,,,,,,{""})
	ElseIf aStatus[2] == '2'
		FWAlertSuccess('Processo efetivado com sucesso.','Sucesso!')
	EndIf

	RestArea(aArea)
Return


User Function Efetiva2()
Return StartJob("U_Efetiva3",GetEnvServer(),.T., { cEmpAnt, cFilAnt, ZR2->ZR2_NPRO, RetCodUsr() } )

User Function Efetiva3(aValor)
	Local aArea 	       := GetArea()
	Local cQuery    	   := GetNextAlias()
	Local nS 		  	   := 0
	Local ciErro	   	   := ''
	Local cProcesso 	   := ''
	Local aCabAuto 		   := {}
	Local aiErro		   := {}
	Local aItensAuto	   := {}
	Local aItem			   := {}
	//Local aDados		   := {.F.,"1"}
	Local aStatus		   := {.F.,"1"}
	Local lEfetivou        := .F.
	Private lMsErroAuto    := .F.
	Private lMsHelpAuto	   := .T.   
	Private lAutoErrNoFile := .T.

	RpcSetEnv( aValor[1], aValor[2], aValor[4] )

	DbSelectArea("ZR2")
	ZR2->(DbSetOrder(1))
	If ZR2->(DbSeek(xFilial("ZR2")+aValor[3]))

		DbSelectArea("SF1")
		DbSelectArea("SD1")
		DbSelectArea("ZR3")
		ZR3->(DbSetOrder(1))

		DbSelectArea("SB8")
		SB8->(DbSetOrder(1))
		DbSelectArea("SBF")
		SBF->(DbSetOrder(1))

		cProcesso := ZR2->ZR2_NPRO

		BeginSql Alias cQuery
			SELECT * FROM %Table:SF1% SF1 
			WHERE F1_DOC = %Exp:ZR2->ZR2_DOC%
			AND F1_SERIE = %Exp:ZR2->ZR2_SERIE%
			AND F1_FILIAL = %xFilial:SF1%
			AND F1_FORNECE = %Exp:ZR2->ZR2_FORN%
			AND F1_LOJA = %Exp:ZR2->ZR2_FLOJA%
			AND SF1.D_E_L_E_T_= ''
		EndSql
		ProcRegua(4)

		If (cQuery)->(!Eof()) .And. Empty((cQuery)->F1_STATUS)// Para classificar

			//IncProc("1/4 Classificando pré doc. de entrada")

			If ZR3->(DbSeek(xFilial("ZR3")+cProcesso)) 

				//	Cabeçalho da nota de entrada
				aadd(aCabAuto,{"F1_FILIAL"   	,ZR2->ZR2_FILIAL 							       ,Nil})//1
				aadd(aCabAuto,{"F1_TIPO"   		,"N"										       ,Nil})//2
				aadd(aCabAuto,{"F1_FORMUL"  	,"N"										       ,Nil})//3
				aadd(aCabAuto,{"F1_DOC"     	,Padr((cQuery)->F1_DOC	,TamSx3("F1_DOC")[1]) 	   ,Nil})//4
				aadd(aCabAuto,{"F1_SERIE"   	,Padr((cQuery)->F1_SERIE,TamSx3("F1_SERIE")[1])	   ,Nil})//5
				aadd(aCabAuto,{"F1_EMISSAO" 	,Date()										 	   ,Nil})//6
				aadd(aCabAuto,{"F1_DTDIGIT" 	,Date()										 	   ,Nil})//7
				aadd(aCabAuto,{"F1_FORNECE" 	,Padr((cQuery)->F1_FORNECE,TamSx3("F1_FORNECE")[1]),Nil})//8
				aadd(aCabAuto,{"F1_LOJA"    	,Padr((cQuery)->F1_LOJA	  ,TamSx3("F1_LOJA")[1])   ,Nil})//9
				aadd(aCabAuto,{"F1_ESPECIE" 	,"SPED"									           ,Nil})//10
				aadd(aCabAuto,{"F1_COND" 		,Padr(ZR2->ZR2_CONDPE,TamSx3("F1_COND")[1])	       ,Nil})//11
				aadd(aCabAuto,{"F1_STATUS" 		,"A" 										       ,Nil})//12

				While ZR3->(!Eof()) .And. ZR3->ZR3_NPRO == cProcesso // Percorro as linhas do grid para pegar os itens
					aItem := {}

					aadd(aItem,{"D1_FILIAL"  ,ZR3->ZR3_FILIAL							    ,Nil})//1
					aadd(aItem,{"D1_ITEM"  	 ,ZR3->ZR3_ITEM							  	    ,Nil})//2
					aadd(aItem,{"D1_COD"  	 ,Padr(ZR3->ZR3_PROD,TamSx3("D1_COD")[1])       ,Nil})//3
					aadd(aItem,{"D1_QUANT"	 ,ZR3->ZR3_QUANT							    ,Nil})//4
					aadd(aItem,{"D1_VUNIT"	 ,ZR3->ZR3_PRCVEN							    ,Nil})//5
					aadd(aItem,{"D1_TOTAL"	 ,ZR3->ZR3_VLRT				  		   		    ,Nil})//6
					aadd(aItem,{"D1_TES"	 ,ZR2->ZR2_TESE				 		   		    ,Nil})//7
					If SB8->(DbSeek(xFilial("SB8")+ZR3->(ZR3_PROD+ZR3_LOCAL))) // Posiciono na B8 para pegar o Lote e validade
						aadd(aItem,{"D1_LOTECTL" ,Padr('',TamSx3("D1_LOTECTL")[1])  		,Nil})//9
						aadd(aItem,{"D1_DFABRIC" ,''						   				,Nil})//11
						aadd(aItem,{"D1_DTVALID" ,''						   				,Nil})//12
					EndIf
					If SBF->(DbSeek(xFilial("SBF")+ZR3->(ZR3_PROD+ZR3_LOCAL)))
						aadd(aItem,{"D1_NUMLOTE" ,sPace(TamSx3("D1_NUMLOTE")[1])			,Nil})//10
					EndIf
					aadd(aItem,{"D1_LOCAL"	 ,Padr(ZR3->ZR3_LOCAL,TamSx3("D1_LOCAL")[1])    ,Nil})//13
					aadd(aItensAuto,aClone(aItem)) // Clono o array para o formato exigido pelo execauto
					ZR3->(DbSkip())
				End

				MsExecAuto({|x,y,z|Mata103(x,y,z)},aCabAuto,aItensAuto,4)// chamo a rotina automática para inclusão
				If lMsErroAuto
					aiErro := GetAutoGRLog()
					For nS:=1 To Len(aiErro)
						ciErro += aiErro[nS] + Chr(13)+Chr(10)
					Next
					RollBackSx8()
					aStatus[1] := .T.
					//FwAlertError("Não foi possivel gerar o documento de entrada.","Atenção!")
				Else
					ConFirmSX8()
					// Chamo a função de geração do pedido de venda e documento de saida, enviando o processo como parâmetro
					lEfetivou := U_GpdvFat(cProcesso)
				Endif
			EndIf
		Else 
			// Chamo a função de geração do pedido de venda e documento de saida, enviando o processo como parâmetro
			lEfetivou := U_GpdvFat(cProcesso)
		EndIf

		If lEfetivou
			If ZR2->(DbSeek(xFilial("ZR2")+cProcesso))
				ZR2->(RecLock("ZR2", .F.))
					ZR2->ZR2_STATUS := "2"
				ZR2->(MsUnlock())
				aStatus[2] := "2"
				If SF1->(DbSeek(xFilial("SF1")+(cQuery)->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
					SF1->(RecLock("SF1", .F.))
						SF1->F1_XDESVPD := "1"
					SF1->(MsUnlock())
				EndIf
			EndIf
		Else
			aStatus[1] := .T.
		EndIf
		(cQuery)->(DbCloseArea())
	EndIf
	RestArea(aArea)
	RpcClearEnv()
Return aStatus


User Function VForn()
Return AllTrim(Posicione("SA2",1,xFilial("SA2")+ACPORET[3]+ACPORET[4],"A2_NOME"))
