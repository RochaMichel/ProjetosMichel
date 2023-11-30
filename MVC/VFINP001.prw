#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"
#Include "TOPCONN.ch"

// --------------------------------------------
/*/{protheusDoc.marcadores_ocultos} VFINP001
Função *
Digitação dos títulos do Pedido de Venda.

@author Anderson Almeida (Totvs Ne)

@historia
11/08/2021 - Desenvolvimento da Rotina.
/*/
// --------------------------------------------
User Function VFINP001()
	Local nId      := 0
	Local aCampos  := {}
	Local aButtons := {{.F.,Nil},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.T.,"Confirmar"},;
		{.T.,"Fechar"},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.F.,Nil},;
		{.F.,NIl}}

	Private aTpGerTi := StrTokArr2(SuperGetMv("VT_GERATIT",.F.,{}),";")    // Título gerado com o código do cliente
	Private aTpCobTx := StrTokArr2(SuperGetMv("VT_COBTAXA",.F.,{}),";")    // Tipo do título que tem taxa administrativas
	Private cTpGerTi := ""
	Private cTpCobTx := ""
	Private lRetRot  := .T.
	Private aRecibo  := {}

	// -- Montar Validação de campos
	// -----------------------------
	For nId := 1 To Len(aTpGerTi)
		If aTpGerTi[nId] <> 'NCC'
			cTpGerTi += PadR(aTpGerTi[nId],3) + "/"
		Endif
	Next

	For nId := 1 To Len(aTpCobTx)
		cTpCobTx += PadR(aTpCobTx[nId],3) + "/"
	Next

	// -- Criação da tabela temporária
	// -------------------------------
	aAdd(aCampos,{"T1_PEDIDO" ,"C",TamSX3("C5_NUM")[1],0})
	aAdd(aCampos,{"T1_CLIENTE","C",TamSX3("A1_COD")[1],0})
	aAdd(aCampos,{"T1_LOJA"   ,"C",TamSX3("A1_LOJA")[1],0})
	aAdd(aCampos,{"T1_NOME"   ,"C",TamSX3("A1_NOME")[1],0})
	aAdd(aCampos,{"T1_CGC"    ,"C",20,0})
	aAdd(aCampos,{"T1_EMISSAO","D",8,0})
	aAdd(aCampos,{"T1_VALOR"  ,"N",12,2})
	aAdd(aCampos,{"T1_VLRLANC","N",12,2})
	aAdd(aCampos,{"T1_DEBITO" ,"N",12,2})
	aAdd(aCampos,{"T1_NATUREZ","C",TamSX3("C5_NATUREZ")[1],0})
	aAdd(aCampos,{"T1_VLRDESC","N",12,2})
	aAdd(aCampos,{"T1_VLRBRUT","N",12,2})

	// --- Criar tabela temporária
	// ---------------------------
	oTempTCAB := FWTemporaryTable():New("TCAB")
	oTempTCAB:SetFields(aCampos)
	oTempTCAB:AddIndex("01", {"T1_PEDIDO"})
	oTempTCAB:Create()

	FWExecView("Pedido Venda - Pagamentos","VFINP001",MODEL_OPERATION_INSERT,,{|| .T.},,40,aButtons)

	oTempTCAB:Delete()
Return

//-------------------------------------------------------------------
/*/ Função ModelDef 

	Regra de negócio da tela.

	@author Anderson Almeida (TOTVS Ne)
	@version P12.1...
	@since   02/08/2021
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oStrCab  := fn01MCAB()
	Local oStrSZ3  := FWFormStruct(1,"SZ3")
	Local bLinePre := {|oGrid, nLine, cAction, cIDField, xValue, xCurrentValue|;
		fn01lPG(oGrid, nLine, cAction, cIDField, xValue, xCurrentValue)}
	Local bLinePos := {|oGrid, nLine| fn01LOk(oGrid, nLine)}
	Local aSZ3Rel  := {}

	oStrSZ3:AddField("Chave","Chave","Z3_CHVSZ3","C",9,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)

	// --- Validações
	// --------------
	oStrSZ3:SetProperty("Z3_VALOR",MODEL_FIELD_VALID,;
		FWBuildFeature(STRUCT_FEATURE_VALID,"U_fn01Pag(FWFldGet('Z3_VALOR'))"))

	oStrSZ3:SetProperty("Z3_BANCO",MODEL_FIELD_VALID,;
		FWBuildFeature(STRUCT_FEATURE_VALID,"ExistCpo('SA6',FWFldGet('Z3_BANCO'),1)"))

	oStrSZ3:SetProperty("Z3_AGENCIA",MODEL_FIELD_VALID,;
		FWBuildFeature(STRUCT_FEATURE_VALID,"ExistCpo('SA6',FWFldGet('Z3_BANCO') + FWFldGet('Z3_AGENCIA'),1)"))

	oStrSZ3:SetProperty("Z3_CONTA",MODEL_FIELD_VALID,;
		FWBuildFeature(STRUCT_FEATURE_VALID,"ExistCpo('SA6',FWFldGet('Z3_BANCO') + ";
		+ "FWFldGet('Z3_AGENCIA') + FWFldGet('Z3_CONTA'),1)"))

	oStrSZ3:SetProperty("Z3_CODADM",MODEL_FIELD_VALID,;
		FWBuildFeature(STRUCT_FEATURE_VALID,"U_fn01Adm(FWFldGet('Z3_CODADM'))"))



	// --- Trigger
	// -----------
	oStrSZ3:AddTrigger("Z3_TIPO","Z3_DESC",{||.T.},;
		{|oModelo| AllTrim(Posicione("SX5",1,FWxFilial("SX5") + "05" + FWFldGet("Z3_TIPO"),"X5_DESCRI"))})

	oStrSZ3:AddTrigger("Z3_BANCO","Z3_NOMEBCO",{||.T.},;
		{|oModelo| Posicione("SA6",1,FWxFilial("SA6") + FWFldGet("Z3_BANCO"),"A6_NREDUZ")})

	// --- Inicializador / Alteração
	// -----------------------------
	oStrSZ3:SetProperty("Z3_TIPO"   ,MODEL_FIELD_INIT,{|oModel| Space(TamSX3("E1_TIPO")[1])})
	oStrSZ3:SetProperty("Z3_ITEM"   ,MODEL_FIELD_WHEN,{|oModel| .F.})
	oStrSZ3:SetProperty("Z3_BANCO"  ,MODEL_FIELD_WHEN,{|oModel| ! (FWFldGet("Z3_TIPO") $ cTpGerTi)})
	oStrSZ3:SetProperty("Z3_AGENCIA",MODEL_FIELD_WHEN,{|oModel| ! (FWFldGet("Z3_TIPO") $ cTpGerTi)})
	oStrSZ3:SetProperty("Z3_CONTA"  ,MODEL_FIELD_WHEN,{|oModel| ! (FWFldGet("Z3_TIPO") $ cTpGerTi)})
	oStrSZ3:SetProperty("Z3_CODADM" ,MODEL_FIELD_WHEN,{|oModel| FWFldGet("Z3_TIPO") $ cTpCobTx})
	oStrSZ3:SetProperty("Z3_PARCELA",MODEL_FIELD_WHEN,{|oModel| FWFldGet("Z3_TIPO") $ cTpCobTx})
	oStrSZ3:SetProperty("Z3_DOCTEF" ,MODEL_FIELD_WHEN,{|oModel| FWFldGet("Z3_TIPO") $ cTpCobTx})
	oStrSZ3:SetProperty("Z3_NSUTEF" ,MODEL_FIELD_WHEN,{|oModel| FWFldGet("Z3_TIPO") $ cTpCObTx})
	oStrSZ3:SetProperty('Z3_PARCELA',MODEL_FIELD_VALID ,    FwBuildFeature(STRUCT_FEATURE_VALID,    'NAOVAZIO()'))
	oStrSZ3:SetProperty('Z3_PARCELA',MODEL_FIELD_INIT  ,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  '1')) //NUMERO DA PARCELA PADRAO SER 1


	// -----------------------------

	oModel := MPFormModel():New("Lançamento Pagamento",,,{|oModel| fn01VGrv(oModel)})

	oModel:SetDescription("Pagamento Pedido Venda")

	oModel:AddFields("MSTCAB",,oStrCab)
	oModel:AddGrid("DETSZ3","MSTCAB",oStrSZ3,bLinePre,bLinePos,,,)
	oModel:SetPrimaryKey({"Z3_FILIAL", "Z3_PEDIDO"})

	aAdd(aSZ3Rel, {"Z3_PEDIDO", "T1_PEDIDO"})

	/*oModel:SetRelation("DETSZ3",{{"Z3_PEDIDO","T1_PEDIDO"},;
		SZ3->(IndexKey(1))})*/

	oModel:SetRelation('DETSZ3', aSZ3Rel, SZ3->(IndexKey(1)))

Return oModel

//-------------------------------------------------------------------
/*/ Função fn01lPG()
	Validação da linha do grid.

	@author Anderson Almeida (TOTVS NE)
	@version P12.1...
	@since   15/08/2021
/*/
//-------------------------------------------------------------------
Static Function fn01lPG(oGrid, nLine, cAction, cIDField, xValue, xCurrentValue)
	Local lRet    := .T.
	Local nId     := 0
	Local nVlPago := 0
	Local oModel  := FWModelActive()
	Local oCabTMP := oModel:GetModel("MSTCAB")


	oGrid:LoadValue("Z3_ITEM", StrZero(nLine,TamSX3("Z3_ITEM")[1]))

	Do Case
	Case cAction == "SETVALUE"

		For nId := 1 To oGrid:Length()
			//oGrid:GoLine(nId)
			If !oGrid:IsDeleted(nId)
				nVlPago += IIF(oGrid:GetValue("Z3_TIPO", nId) <> "NCC",oGrid:GetValue("Z3_VALOR", nId),-oGrid:GetValue("Z3_VALOR", nId))
			EndIf
		Next

		oCabTMP:LoadValue("T1_VLRLANC", nVlPago )
		oCabTMP:LoadValue("T1_DEBITO" , (oCabTMP:GetValue("T1_VALOR") - oCabTMP:GetValue("T1_VLRLANC")))

	Case cAction == "CANSETVALUE"

		If ! Empty(oGrid:GetValue("Z3_CHVSZ3"))
			oGrid:GetModel():SetErrorMessage("DETSE1","Z3_CHVSZ3","DETSE1","Z3_TIPO",;
				"Erro", "Não é possível alterar o registro já gerado.",;
				"Deve usar a rotina Contas a Receber no módulo Financeiro.")

			lRet := .F.
		EndIf

	Case cAction == "DELETE"
		nVlPago += IIF(oGrid:GetValue("Z3_TIPO") <> "NCC",-oGrid:GetValue("Z3_VALOR"),oGrid:GetValue("Z3_VALOR"))
		If ! Empty(oGrid:GetValue("Z3_CHVSZ3"))
			oGrid:GetModel():SetErrorMessage("DETSE1","Z3_CHVSZ3","DETSE1","Z3_TIPO",;
				"Erro", "Não é possível deletar registro já gerado.",;
				"Deve usar a rotina Contas a Receber no módulo Financeiro.")


			lRet := .F.
		else
			For nId := 1 To oGrid:Length()
				//oGrid:GoLine(nId)
				If !oGrid:IsDeleted(nId)
					nVlPago += IIF(oGrid:GetValue("Z3_TIPO", nId) <> "NCC",oGrid:GetValue("Z3_VALOR", nId),-oGrid:GetValue("Z3_VALOR", nId))
				EndIf
			Next

			oCabTMP:LoadValue("T1_VLRLANC", nVlPago )
			oCabTMP:LoadValue("T1_DEBITO" , (oCabTMP:GetValue("T1_VALOR") - oCabTMP:GetValue("T1_VLRLANC")))


		EndIf
	Case cAction == 'UNDELETE'
			For nId := 1 To oGrid:Length()
			//oGrid:GoLine(nId)
				If !oGrid:IsDeleted(nId)
					nVlPago += IIF(oGrid:GetValue("Z3_TIPO", nId) <> "NCC",oGrid:GetValue("Z3_VALOR", nId),-oGrid:GetValue("Z3_VALOR", nId))
				EndIf
			Next
			//oGrid:GoLine(nId)
			
			nVlPago += IIF(oGrid:GetValue("Z3_TIPO", nLine) <> "NCC",oGrid:GetValue("Z3_VALOR", nLine),-oGrid:GetValue("Z3_VALOR", nLine))
		

		oCabTMP:LoadValue("T1_VLRLANC", nVlPago )
		oCabTMP:LoadValue("T1_DEBITO" , (oCabTMP:GetValue("T1_VALOR") - oCabTMP:GetValue("T1_VLRLANC")))
	EndCase
Return lRet

//-------------------------------------------------------------------
/*/ Função fn01LOk()c
	Validação da linha do Grid.
	@author Anderson Almeida (TOTVS NE)
	@version P12.1...
	@since   23/08/2021
/*/
//-------------------------------------------------------------------
Static Function fn01LOk(oGrid, nLine)
	Local lRet := .T.
	Local nPos := 0

	nPos := aScan(aTpGerTi, {|x| AllTrim(x) == AllTrim(oGrid:GetValue("Z3_TIPO"))})

	If nPos == 0
		If Empty(oGrid:GetValue("Z3_BANCO")) .or. Empty(oGrid:GetValue("Z3_AGENCIA")) .or.;
				Empty(oGrid:GetValue("Z3_CONTA"))
			Help(" ",1,"ATENÇÃO",,"Banco / Agência / Conta é obrigatório para esse tipo de pagamento " + oGrid:GetValue("Z3_TIPO"),;
				3,1,,,,,,{"Verifique se o tipo de pagamento está correto, caso sim, informe Banco, Agência e Conta.",""})

			lRet := .F.
		EndIf
	else
		nPos := aScan(aTpCobTx, {|x| AllTrim(x) == AllTrim(oGrid:GetValue("Z3_TIPO"))})

		If oGrid:GetValue("Z3_TIPO") <> "NCC"
			If nPos > 0
				If Empty(oGrid:GetValue("Z3_CODADM"))
					Help(" ",1,"ATENÇÃO",,"Administradora é obrigatório para esse tipo de pagamento " + oGrid:GetValue("Z3_TIPO"),;
						3,1,,,,,,{"Verifique se o tipo de pagamento está correto, caso sim, informe Administradora.",""})

					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/ Função fn01VGrv()
	Validação da gravação.

	@author Anderson Almeida (TOTVS NE)
	@version P12.1...
	@since   02/08/2021
/*/
//-------------------------------------------------------------------
Static Function fn01VGrv(oModel)
	Local lRet    := .T.
	Local nId     := 0
	Local aRet    := {}
	Local aRegPed := {}
	Local aRegSZ3 := {}
	Local oGrdCAB := oModel:GetModel("MSTCAB")
	Local oGrdSZ3 := oModel:GetModel("DETSZ3")

	Private lMsErroAuto := .F.

	dbSelectArea("SZ3")
	SZ3->(dbSetOrder(1))

	aAdd(aRegPed, {oGrdCAB:GetValue("T1_PEDIDO"),;
		oGrdCAB:GetValue("T1_DEBITO")})

	For nId := 1 To oGrdSZ3:Length()
		//oGrdSZ3:GoLine(nId)

		If oGrdSZ3:IsDeleted(nId)
			If DbSeek(xFilial('SZ3')+oGrdCAB:GetValue("T1_PEDIDO")+oGrdSZ3:GetValue("Z3_ITEM", nId))
				Reclock('SZ3',.F.)
				SZ3->(DbDelete())
				SZ3->(MsUnlock())
			EndIf
			Loop
		EndIf

		If Empty(oGrdSZ3:GetValue("Z3_CHVSZ3"))
			aAdd(aRegSZ3, {oGrdCAB:GetValue("T1_PEDIDO"),;
				oGrdSZ3:GetValue("Z3_ITEM", nId),;
				oGrdSZ3:GetValue("Z3_VALOR", nId),;
				oGrdSZ3:GetValue("Z3_TIPO", nId),;
				oGrdSZ3:GetValue("Z3_DTEMIS", nId),;
				oGrdSZ3:GetValue("Z3_BANCO", nId),;
				oGrdSZ3:GetValue("Z3_AGENCIA", nId),;
				oGrdSZ3:GetValue("Z3_CONTA", nId),;
				oGrdSZ3:GetValue("Z3_CODADM", nId),;
				oGrdSZ3:GetValue("Z3_PARCELA", nId),;
				oGrdSZ3:GetValue("Z3_DOCTEF", nId),;
				oGrdSZ3:GetValue("Z3_NSUTEF", nId),;
				oGrdSZ3:GetValue("Z3_IDMERPG", nId)})
		EndIf
	Next

	If Len(aRegSZ3) > 0
		aRet := U_fnP01SZ3(aRegPed, aRegSZ3)
		If !Empty(aRet[02])
			If ! aRet[01]
				lRet := aRet[01]

				If lMsErroAuto
					MostraErro()
				else
					Help(" ",1,"ATENÇÃO",,aRet[02],3,1,,,,,,{aRet[03],""})
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/ Função fn01MCAB()
	Estrutura do detalhe do nome do arquivo a importar.

	@author Anderson Almeida (TOTVS NE)
	@version P12.1...
	@since   02/08/2021
/*/
//-------------------------------------------------------------------
Static Function fn01MCAB()
	Local oStruct := FWFormModelStruct():New()

	oStruct:AddTable("TCAB",{"T1_PEDIDO"},"Pedido")
	oStruct:AddField("Pedido"     ,"Pedido"     ,"T1_PEDIDO" ,"C",TamSX3("C5_NUM")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
	oStruct:AddField("Cliente"    ,"Cliente"    ,"T1_CLIENTE","C",TamSX3("A1_COD")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
	oStruct:AddField("Loja"       ,"Loja"       ,"T1_LOJA"   ,"C",TamSX3("A1_LOJA")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
	oStruct:AddField("Nome"       ,"Nome"       ,"T1_NOME"   ,"C",TamSX3("A1_NOME")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
	oStruct:AddField("CNPJ / CPF" ,"CNPJ / CPF" ,"T1_CGC"    ,"C",20,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
	oStruct:AddField("Emissão"    ,"Emissão"    ,"T1_EMISSAO","D",8,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
	oStruct:AddField("Valor"      ,"Valor"      ,"T1_VALOR"  ,"N",12,2,Nil,Nil,{},.F.,,.F.,.F.,.F.)
	oStruct:AddField("Débito"     ,"Débito"     ,"T1_DEBITO" ,"N",12,2,Nil,Nil,{},.F.,,.F.,.F.,.F.)
	oStruct:AddField("Pago"       ,"Pago"       ,"T1_VLRLANC","N",12,2,Nil,Nil,{},.F.,,.F.,.F.,.F.)
	oStruct:AddField("Desconto"   ,"Desconto"   ,"T1_VLRDESC","N",12,2,Nil,Nil,{},.F.,,.F.,.F.,.F.)
	oStruct:AddField("Valor Bruto","Valor Bruto","T1_VLRBRUT","N",12,2,Nil,Nil,{},.F.,,.F.,.F.,.F.)
	oStruct:AddField("Natureza"   ,"Natureza"   ,"T1_NATUREZ","C",TamSX3("E1_NATUREZ")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)

	oStruct:SetProperty("T1_PEDIDO",MODEL_FIELD_VALID,;
		FWBuildFeature(STRUCT_FEATURE_VALID,"U_fn01VPV(FWFldGet('T1_PEDIDO'))"))
Return oStruct

//-------------------------------------------------------------------
/*/ Função ViewDef()
	Definição da View

	@author Anderson Almeida (TOTVS NE)
	@version P12.1.17
	@since  02/08/2021
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel  := ModelDef()
	Local oStrCAB := fn01VCAB()
	Local oStrSZ3 := FWFormStruct(2,"SZ3")
	Local oView

	oStrSZ3:RemoveField("Z3_PEDIDO")
	oStrSZ3:RemoveField("Z3_VLTAXA")

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField("FFIL",oStrCAB,"MSTCAB")
	oView:AddGrid("FDET",oStrSZ3,"DETSZ3")

	//oView:AddIncrementField("FDET","Z3_ITEM")

	// --- Definição da Tela
	// ---------------------
	oView:CreateHorizontalBox("BXFIL",53)
	oView:CreateHorizontalBox("BXREG",47)
	oView:AddUserButton("Visualizar Pedido","MAGIC_BMP",{|oView| fn01VisPV()},"Visualizar Pedido")

	// --- Definição dos campos
	// ------------------------
	oView:SetOwnerView("FFIL","BXFIL")
	oView:SetOwnerView("FDET","BXREG")

	oView:SetViewAction("ASKONCANCELSHOW",{|| .F.})          // Tirar a mensagem do final "Há Alterações não..."
Return oView

//---------------------------------------------------------------
/*/ Função fn01VisPV

	Chamada da rotina padrão de visualizar Pedido de Venda.

	@author Anderson Almeida (TOTVS NE)
	@version P12.1.17
	@since  23/08/2021
/*/
//---------------------------------------------------------------
Static Function fn01VisPV()
	Local oModel  := FWModelActive()
	Local oCabTMP := oModel:GetModel("MSTCAB")

	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))

	If SC5->(dbSeek(FWxFilial("SC5") + oCabTMP:GetValue("T1_PEDIDO")))
		A410Visual("SC5",SC5->(Recno()),1)
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/ Função fn01VCAB()
	Estrutura do cabeçalho, campos para filtro

	@author Anderson Almeida (TOTVS NE)
	@version P12.1...
	@since  11/082021
/*/
//-------------------------------------------------------------------
Static Function fn01VCAB()
	Local oViewCAB := FWFormViewStruct():New()

	// -- Montagem Estrutura
	//      01 = Nome do Campo
	//      02 = Ordem
	//      03 = Título do campo
	//      04 = Descrição do campo
	//      05 = Array com Help
	//      06 = Tipo do campo
	//      07 = Picture
	//      08 = Bloco de PictTre Var
	//      09 = Consulta F3
	//      10 = Indica se o campo é alterável
	//      11 = Pasta do Campo
	//      12 = Agrupamnento do campo
	//      13 = Lista de valores permitido do campo (Combo)
	//      14 = Tamanho máximo da opção do combo
	//      15 = Inicializador de Browse
	//      16 = Indica se o campo é virtual (.T. ou .F.)
	//      17 = Picture Variavel
	//      18 = Indica pulo de linha após o campo (.T. ou .F.)
	// ---------------------------------------------------------
	oViewCAB:AddField("T1_PEDIDO" ,"01","Pedido"     ,"Pedido"     ,Nil,"C","@!",Nil,"SC5",.T.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
	oViewCAB:AddField("T1_CLIENTE","02","Cliente"    ,"Cliente"    ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
	oViewCAB:AddField("T1_LOJA"   ,"03","Loja"       ,"Loja"       ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
	oViewCAB:AddField("T1_NOME"   ,"04","Nome"       ,"Nome"       ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
	oViewCAB:AddField("T1_CGC"    ,"05","CNPJ / CPF" ,"CNPJ / CPF" ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
	oViewCAB:AddField("T1_VALOR"  ,"06","Valor"      ,"Valor"      ,Nil,"N","@E 999,999,999.99",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
	oViewCAB:AddField("T1_DEBITO" ,"07","Débito"     ,"Débito"     ,Nil,"N","@E 999,999,999.99",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
	oViewCAB:AddField("T1_VLRLANC","08","Pago"       ,"Pago"       ,Nil,"N","@E 999,999,999.99",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
	oViewCAB:AddField("T1_VLRDESC","09","Desconto"   ,"Desconto"   ,Nil,"N","@E 999,999,999.99",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
	oViewCAB:AddField("T1_VLRBRUT","10","Valor Bruto","Valor Bruto",Nil,"N","@E 999,999,999.99",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
	oViewCAB:AddField("T1_EMISSAO","11","Emissão"    ,"Emissão"    ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
Return oViewCAB

//---------------------------------------------------------------
/*/ Função fn01VPV()

	Validar o Pedido de Venda.

	@author Anderson Almeida (TOTVS NE)
	@version P12.1.17
	@since  20/08/2021
/*/
//---------------------------------------------------------------
User Function fn01VPV(pPedido)
	Local lRet    := .T.
	Local cQuery  := ""
	Local cTES    := ""
	Local oModel  := FWModelActive()
	Local oCabTMP := oModel:GetModel("MSTCAB")
	Local aTESBon := StrToKArr(SuperGetMV("VT_TESBONI",.F.,{}),";")
	Local nVlPed  := 0
	Local nId     := 0

	For nId := 1 To Len(aTESBon)
		cTES += "'" + aTESBon[nId] + "',"
	Next

	cTES := SubStr(cTES,1,(Len(cTES) - 1))

	cQuery := "Select SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_EMISSAO, SA1.A1_NOME, SC5.C5_NATUREZ,"
	cQuery += "       SC5.C5_FRETE, SC5.C5_SEGURO, SC5.C5_DESPESA, SC5.C5_ACRSFIN, SC5.C5_DESC1,"
	cQuery += "       SC5.C5_DESCFI, SC5.C5_DESCONT, SA1.A1_PESSOA, SA1.A1_CGC, TMP.TOTAL"
	cQuery += "  from " + RetSqlName("SC5") + " SC5"
	cQuery += "  Left Join (Select SC6.C6_NUM, Sum(SC6.C6_VALOR) as TOTAL"
	cQuery += "               from " + RetSqlName("SC6") + " SC6"
	cQuery += "                where SC6.D_E_L_E_T_ <> '*'"
	cQuery += "                  and SC6.C6_FILIAL  = '" + FWxFilial("SC6") + "'"
	cQuery += "                  and SC6.C6_NUM     = '" + pPedido + "'"
	cQuery += "                  and not (SC6.C6_TES in (" + cTes + "))"
	cQuery += "                Group by SC6.C6_NUM) TMP"
	cQuery += "          on TMP.C6_NUM = SC5.C5_NUM"
	cQuery += "  , " + RetSqlName("SA1") + " SA1"
	cQuery += "   where SC5.D_E_L_E_T_ <> '*'"
	cQuery += "     and SC5.C5_FILIAL  = '" + FWxFilial("SC5") + "'"
	cQuery += "     and SC5.C5_NUM     = '" + pPedido + "'"
	cQuery += "     and SA1.D_E_L_E_T_ <> '*'"
	cQuery += "     and SA1.A1_FILIAL  = '" + FWxFilial("SA1") + "'"
	cQuery += "     and SA1.A1_COD     = SC5.C5_CLIENTE"
	cQuery += "     and SA1.A1_LOJA    = SC5.C5_LOJACLI"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TopConn",TCGenQry(,,cQuery),"QPED",.F.,.T.)

	If QPED->(Eof())
		Help(" ",1,"ATENÇÃO",,"Pedido de Venda não cadastrado.",3,1,,,,,,{"",""})

		lRet := .F.
	else
		nVlPed := QPED->TOTAL + Round(((QPED->TOTAL * QPED->C5_ACRSFIN) / 100),2)
		nVlPed := nVlPed - Round(((nVlPed * QPED->C5_DESC1) / 100),2)
		nVlPed := nVlPed - Round(((nVlPed * QPED->C5_DESCFI) / 100),2)
		nVlPed := (nVlPed - QPED->C5_DESCONT) + QPED->C5_FRETE + QPED->C5_DESPESA + QPED->C5_SEGURO



		oCabTMP:LoadValue("T1_CLIENTE", QPED->C5_CLIENTE)
		oCabTMP:LoadValue("T1_LOJA"   , QPED->C5_LOJACLI)
		oCabTMP:LoadValue("T1_NOME"   , QPED->A1_NOME)
		oCabTMP:LoadValue("T1_CGC"    , IIf(QPED->A1_PESSOA == "J",Transform(QPED->A1_CGC,"@R 99.999.999/9999-99"),;
			Transform(QPED->A1_CGC,"@R 999.999.999-99")))
		oCabTMP:LoadValue("T1_EMISSAO", SToD(QPED->C5_EMISSAO))
		oCabTMP:LoadValue("T1_VALOR"  , nVlPed)
		oCabTMP:LoadValue("T1_VLRLANC", 0)
		oCabTMP:LoadValue("T1_DEBITO" , 0)
		oCabTMP:LoadValue("T1_NATUREZ", QPED->C5_NATUREZ)
		oCabTMP:LoadValue("T1_VLRDESC", QPED->C5_DESCONT)
		oCabTMP:LoadValue("T1_VLRBRUT", (nVlPed + QPED->C5_DESCONT))

		fn01Lan(@oModel, @oCabTMP)
	EndIf

	QPED->(dbCloseArea())

Return lRet

//---------------------------------------------------------------
/*/ Função fn01Lan()
	Montar a tela com os lançamentos já realizados.

	@author Anderson Almeida (TOTVS NE)
	@version P12.1.17
	@since  24/08/2021
/*/
//---------------------------------------------------------------
Static Function fn01Lan(oModel,oCabTMP)
	Local cQuery  := ""
	Local nVlPago := 0
	Local oGrdSZ3 := oModel:GetModel("DETSZ3")

	cQuery := "Select SZ3.*, TMP.E1_XCHVSZ3, SX5.X5_DESCRI, SA6.A6_NREDUZ, SAE.AE_DESC"
	cQuery += "  from " + RetSqlName("SZ3") + " SZ3"
	cQuery += "   Left Join (Select Distinct SE1.E1_XCHVSZ3 from " + RetSqlName("SE1") + " SE1"
	cQuery += "                where SE1.D_E_L_E_T_ <> '*'"
	cQuery += "                  and SE1.E1_FILIAL  = '" + FWxFilial("SE1") + "'"
	cQuery += "                  and SE1.E1_XCHVSZ3 > 0) TMP"
	cQuery += "          on TMP.E1_XCHVSZ3 = (SZ3.Z3_PEDIDO + SZ3.Z3_ITEM)"
	cQuery += "   Left Join " + RetSqlName("SA6") + " SA6"
	cQuery += "          on SA6.D_E_L_E_T_ <> '*'"
	cQuery += "         and SA6.A6_FILIAL  = '" + FWxFilial("SA6") + "'"
	cQuery += "         and SA6.A6_COD     = SZ3.Z3_BANCO"
	cQuery += "         and SA6.A6_AGENCIA = SZ3.Z3_AGENCIA"
	cQuery += "         and SA6.A6_NUMCON  = SZ3.Z3_CONTA"
	cQuery += "   Left Join " + RetSqlName("SAE") + " SAE"
	cQuery += "          on SAE.D_E_L_E_T_ <> '*'"
	cQuery += "         and SAE.AE_FILIAL  = '" + FWxFilial("SAE") + "'"
	cQuery += "         and SAE.AE_COD     = SZ3.Z3_CODADM"
	cQuery += ", " + RetSqlName("SX5") + " SX5 "
	cQuery += "   where SZ3.D_E_L_E_T_ <> '*'"
	cQuery += "     and SZ3.Z3_FILIAL  = '" + FWxFilial("SZ3") + "'"
	cQuery += "     and SZ3.Z3_PEDIDO  = '" + oCabTMP:GetValue("T1_PEDIDO") + "'"
	cQuery += "     and SX5.D_E_L_E_T_ <> '*'"
	cQuery += "     and SX5.X5_FILIAL  = '" + FWxFilial("SX5") + "'"
	cQuery += "     and SX5.X5_TABELA  = '05'"
	cQuery += "     and SX5.X5_CHAVE   = SZ3.Z3_TIPO"
	cQuery += " ORDER BY Z3_ITEM "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TopConn",TCGenQry(,,cQuery),"QLAN",.F.,.T.)

	oModel:GetModel("DETSZ3"):ClearData(.T.)

	While ! QLAN->(Eof())
		oGrdSZ3:AddLine()

		oGrdSZ3:LoadValue("Z3_PEDIDO" , QLAN->Z3_PEDIDO)
		oGrdSZ3:LoadValue("Z3_ITEM"   , QLAN->Z3_ITEM)
		oGrdSZ3:LoadValue("Z3_VALOR"  , QLAN->Z3_VALOR)
		oGrdSZ3:LoadValue("Z3_TIPO"   , QLAN->Z3_TIPO)
		oGrdSZ3:LoadValue("Z3_DESC"   , AllTrim(QLAN->X5_DESCRI))
		oGrdSZ3:LoadValue("Z3_DTEMIS" , SToD(QLAN->Z3_DTEMIS))
		oGrdSZ3:LoadValue("Z3_BANCO"  , QLAN->Z3_BANCO)
		oGrdSZ3:LoadValue("Z3_NOMEBCO", QLAN->A6_NREDUZ)
		oGrdSZ3:LoadValue("Z3_AGENCIA", QLAN->Z3_AGENCIA)
		oGrdSZ3:LoadValue("Z3_CONTA"  , QLAN->Z3_CONTA)
		oGrdSZ3:LoadValue("Z3_CODADM" , QLAN->Z3_CODADM)
		oGrdSZ3:LoadValue("Z3_NMADM"  , QLAN->AE_DESC)
		oGrdSZ3:LoadValue("Z3_PARCELA", QLAN->Z3_PARCELA)
		oGrdSZ3:LoadValue("Z3_DOCTEF" , QLAN->Z3_DOCTEF)
		oGrdSZ3:LoadValue("Z3_NSUTEF" , QLAN->Z3_NSUTEF)
		oGrdSZ3:LoadValue("Z3_IDMERPG", QLAN->Z3_IDMERPG)
		oGrdsZ3:LoadValue("Z3_CHVSZ3" , QLAN->E1_XCHVSZ3)

		nVlPago +=  IIf(oGrdSZ3:GetValue("Z3_TIPO")<>'NCC',oGrdSZ3:GetValue("Z3_VALOR"),-oGrdSZ3:GetValue("Z3_VALOR"))

		QLAN->(dbSkip())
	EndDo

	QLAN->(dbCloseArea())

	If nVlPago > 0
		oCabTMP:LoadValue("T1_VLRLANC", nVlPago)
		oCabTMP:LoadValue("T1_DEBITO" , (oCabTMP:GetValue("T1_VALOR") - oCabTMP:GetValue("T1_VLRLANC")))
	EndIf

	oGrdSZ3:GoLine(1)
Return

//---------------------------------------------------------------
/*/ Função fn01Pag

	Validar o valor de pagamento

	@author Anderson Almeida (TOTVS NE)
	@version P12.1.17
	@since  06/08/2021
/*/
//---------------------------------------------------------------
User Function fn01Pag(pValor)
	Local lRet    := .T.
	Local nId     := 0
	Local nVlPago := 0
	Local oModel  := FWModelActive()
	Local oCabTMP := oModel:GetModel("MSTCAB")
	Local oGrdSZ3 := oModel:GetModel("DETSZ3")

	For nId := 1 To oGrdSZ3:Length()
		//oGrdSZ3:GoLine(nId)

		If !oGrdSZ3:IsDeleted(nId)
			nVlPago += IIf(oGrdSZ3:GetValue("Z3_TIPO")<>'NCC',oGrdSZ3:GetValue("Z3_VALOR"),-oGrdSZ3:GetValue("Z3_VALOR"))
		EndIf
	Next

	If nVlPago > oCabTMP:GetValue("T1_VALOR")
		Help(" ",1,"ATENÇÃO",,"Valores informados maior que o valor do Pedido de venda.",;
			3,1,,,,,,{"Verifique o campo débito para saber quanto falta de lançamento de pagamento.",""})

		lRet := .F.
	elseIf nVlPago > 0
		oCabTMP:LoadValue("T1_VLRLANC", nVlPago)
		oCabTMP:LoadValue("T1_DEBITO" , (oCabTMP:GetValue("T1_VALOR") - oCabTMP:GetValue("T1_VLRLANC")))
	EndIf
Return lRet

//---------------------------------------------------------------
/*/ Função fn01Adm

	Validar se Administradora é do tipo digitado.

	@author Anderson Almeida (TOTVS NE)
	@version P12.1.17
	@since  06/08/2021
/*/
//---------------------------------------------------------------
User Function fn01Adm(pCodAdm)
	Local lRet    := .T.
	Local oModel  := FWModelActive()
	Local oGrdSZ3 := oModel:GetModel("DETSZ3")

	dbSelectArea("SAE")
	SAE->(dbSetOrder(1))

	If SAE->(dbSeek(FWxFilial("SAE") + pCodAdm))
		If AllTrim(SAE->AE_TIPO) <>  AllTrim(oGrdSZ3:GetValue("Z3_TIPO")) .AND. AllTrim(oGrdSZ3:GetValue("Z3_TIPO")) <> 'NCC'
			Help(" ",1,"ATENÇÃO",,"Tipo de pagamento divergente da Administradora.",;
				3,1,,,,,,{"Verifique que tipo de pagamento a Administradora está cadastra.",""})

			lRet := .F.
		EndIf
	EndIf
Return lRet

//---------------------------------------------------------------
/*/ Função fnP01SZ3

	Gravação do Lançamento Financeiro do Pedido de Venda.

	@Parâmetro: aRegPed - Dados do Pedido Venda
	01 = Número do Pedido Venda
	02 = Valor do Débito

	aRegSZ3 - Matriz do Lançamento de Pagamento
	01 = Número do Pedido Venda
	02 = Item do lançamento
	03 = Valor do pagamento
	04 = Tipo do lançamneto
	05 = Data Emissão
	06 = Código do Banco
	07 = Agência do Banco
	08 = Conta do Banco
	09 = Código da Administradora
	10 = Quantidade de Parcela
	11 = Documento do TEF
	12 = NSU do TEF
	@author Anderson Almeida (TOTVS NE)
	@version P12.1.17
	@since  29/09/2021
/*/
//---------------------------------------------------------------
User Function fnP01SZ3(xRegPed, xRegSZ3)
	Local aRegPed   := xRegPed
	Local aRegSZ3   := xRegSZ3
	Local nX        := 0
	Local nY        := 0
	Local nY1       := 0
	Local nPos      := 0
	Local nQtDias   := 0
	Local nQtParc   := 0
	Local nVlTaxa   := 0
	Local nVlParc   := 0
	Local nVlVenda  := 0
	Local nVlDif    := 0
	Local cQuery    := ""
	Local aRet      := {.F.,"",""}
	Local aNatureza := {}
	Local aRegSE1   := {}
	Local aRegSAE   := {}
	Local aTpTitulo := StrTokArr2(SuperGetMv("VT_GERATIT",.F.,{}),";")    // Título gerado com o código do cliente
	Local aTpTxAdm  := StrTokArr2(SuperGetMv("VT_COBTAXA",.F.,{}),";")    // Tipo do título que tem taxa administrativas

	// -- Natureza do título
	// ---------------------
	aAdd(aNatureza,{"DH ", SuperGetMV("MV_NATDINH",.F.,"")})  // 01 - Natureza DINHEIRO
	aAdd(aNatureza,{"CH ", SuperGetMV("MV_NATCHEQ",.F.,"")})  // 02 - Natureza CHEQUE
	aAdd(aNatureza,{"CC ", SuperGetMV("MV_NATCART",.F.,"")})  // 03 - Natureza CARTÃO DE CRÉDITO
	aAdd(aNatureza,{"CD ", SuperGetMV("MV_NATTEF" ,.F.,"")})  // 04 - Natureza CARTAO DE DEBITO AUTOMATICO
	aAdd(aNatureza,{"FI ", SuperGetMV("MV_NATFIN" ,.F.,"")})  // 05 - Natureza FINANCIADO
	aAdd(aNatureza,{"VL ", SuperGetMV("MV_NATVALE",.F.,"")})  // 06 - Natureza VALES
	aAdd(aNatureza,{"CO ", SuperGetMV("MV_NATCONV",.F.,"")})  // 07 - Natureza CONVENIO
	aAdd(aNatureza,{"XXX", SuperGetMV("MV_NATOUTR",.F.,"")})  // 08 - Natureza OUTRAS
	aAdd(aNatureza,{"CR ", SuperGetMV("MV_NATCRED",.F.,"")})  // 09 - Natureza CREDITO
	aAdd(aNatureza,{"NCC", SuperGetMV("MV_NATNCC" ,.F.,"")})  // 10 - Natureza NOTA DE CRÉDITO
	aAdd(aNatureza,{"RA ", SuperGetMV("MV_NATRECE",.F.,"")})  // 11 - Natureza RECEBIMENTO
	aAdd(aNatureza,{"PX ", SuperGetMV("MV_NATPGPX",.F.,"")})  // 12 - Natureza PIX
	aAdd(aNatureza,{"PD ", SuperGetMV("MV_NATPGDG",.F.,"")})  // 13 - Natureza Pagamento Digital

	// -- Pegar Taxa da Administradora
	// -------------------------------
	cQuery := "Select * "
	cQuery += "  from (Select 'SAE' as TAB, SAE.AE_COD [COD], SAE.AE_CODCLI, SAE.AE_LOJCLI, SAE.AE_TAXA,"
	cQuery += "               SAE.AE_DIAS,  SAE.AE_VENCFIN, SAE.AE_XVLTAXA,0 [TAXADM],0 [PARINI],0 [PARFIN]"
	cQuery += "          from " + RetSqlName("SAE") + " SAE"
	cQuery += "           where SAE.D_E_L_E_T_ <> '*'"
	cQuery += "             and SAE.AE_FILIAL  = '" + FWxFilial("SAE") + "'"
	cQuery += "        Union
	cQuery += "        Select 'MEN' as TAB, MEN.MEN_CODADM [COD],'','',0,0,'',0,MEN.MEN_TAXADM [TAXADM], "
	cQuery += "               MEN.MEN_PARINI [PARINI], MEN.MEN_PARFIN [PARFIN]"
	cQuery += "          from " + RetSqlName("MEN") + " MEN"
	cQuery += "           where MEN.D_E_L_E_T_ <> '*'"
	cQuery += "             and MEN.MEN_FILIAL = '" + FWxFilial("MEN") + "') TMP"
	cQuery += "  order by TMP.TAB desc"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TopConn",TCGenQry(,,cQuery),"QSAE",.F.,.T.)

	While ! QSAE->(Eof())
		If QSAE->TAB == "SAE"
			aAdd(aRegSAE, {QSAE->COD,;     // 01 = Código da Administradora
			QSAE->AE_TAXA,;                // 02 = Taxa do Serviço
			0,;                            // 03 = Taxa do serviço para tipo de parcela
			0,;                            // 04 = Primeira parcela
			0,;                            // 05 = Última parcela
			QSAE->AE_CODCLI,;              // 06 = Código do cliente
			QSAE->AE_LOJCLI,;              // 07 = Loja do cliente
			QSAE->AE_DIAS,;                // 08 = Dias de vencimento
			QSAE->AE_VENCFIN,;             // 09 = Dias de vencimento financiamento
			QSAE->AE_XVLTAXA})             // 10 = Valor do Serviço
		else
			nPos := aScan(aRegSAE, {|x| x[1] == QSAE->COD})

			If nPos > 0
				aAdd(aRegSAE, {QSAE->COD,;  // 01 = Código da Administradora
				0,;                         // 02 = Taxa do Serviço
				QSAE->TAXADM,;              // 03 = Taxa do serviço para tipo de parcela
				QSAE->PARINI,;              // 04 = Primeira parcela
				QSAE->PARFIN,;              // 05 = Última parcela
				QSAE->AE_CODCLI,;           // 06 = Código do cliente
				QSAE->AE_LOJCLI,;           // 07 = Loja do cliente
				QSAE->AE_DIAS,;             // 08 = Dias de vencimento
				QSAE->AE_VENCFIN,;          // 09 = Dias de vencimento financiamento
				0})                         // 10 = Valor do Serviço
			EndIf
		EndIf

		QSAE->(dbSkip())
	EndDo

	QSAE->(dbCloseArea())

	// -- Lançamento
	// -------------
	dbSelectArea("SZ3")
	SZ3->(dbSetOrder(1))

	For nX := 1 To Len(aRegPed)
		// -- Pegar Pedido
		// ---------------
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))

		If ! SC5->(dbSeek(FWxFilial("SC5") + aRegPed[nX][01]))
			aRet[02] := "Não encontrou o Pedido: " + aRegPed[nX][01]
			DisarmTransaction()

			Return aRet
		EndIf

		For nY := 1 To Len(aRegSZ3)
			If aRegSZ3[nY][01] <> aRegPed[nX][01]
				Loop
			EndIf

			Begin Transaction
				nVlTaxa := 0

				If aScan(aTpTxAdm, {|x| AllTrim(x) == AllTrim(aRegSZ3[nY][04])}) > 0
					nPos := aScan(aRegSAE, {|x| x[01] == aRegSZ3[nY][09]})
					If  nPos == 0

						If aRegSZ3[nY][04] <> "NCC"
							aRet[02] := "Não encontrou a Administradora: " + aRegSZ3[nY][09]

							DisarmTransaction()

							Return aRet
						Else
							cCliente := SC5->C5_CLIENTE
							cLoja    := SC5->C5_LOJACLI
							nVlTaxa  := 0
							nVlVenda := aRegSZ3[nY][03] - nVlTaxa
							nVlParc  := Round((nVlVenda / aRegSZ3[nY][10]),2)
							nVlDif   := nVlVenda - (nVlParc * aRegSZ3[nY][10])
						Endif

					Else
						cCliente := aRegSAE[nPos][06]
						cLoja    := aRegSAE[nPos][07]

						If aRegSAE[nPos][08] > 0
							nQtDias := aRegSAE[nPos][08]
						else
							nQtDias := aRegSAE[nPos][09]
						EndIf

						Do Case
						Case aRegSAE[nPos][02] > 0
							nVlTaxa := Round(((aRegSZ3[nY][03] * aRegSAE[nPos][02]) / 100),2)
							nVlParc := aRegSZ3[nY][03] - nVlTaxa

						Case aRegSAE[nPos][10] > 0
							nVlTaxa := aRegSAE[nPos][10]
							nVlParc := aRegSZ3[nY][03] - aRegSAE[nPos][10]

						OtherWise
							If AllTrim(aRegSZ3[nY][04]) <> "FI"
								nPos := aScan(aRegSAE, {|x| x[01] == aRegSZ3[nY][09] .and.;     // Código Administradora
								x[02] == 0 .and.;
									x[04] <= aRegSZ3[nY][10] .and.;     // Parcela
								x[05] >= aRegSZ3[nY][10]})

								If nPos == 0
									aRet[02] := "Não encontrou as taxas para essa Administradora " + aRegSZ3[nY][09]
									aRet[03] :=  "Por Favor, cadastre as taxas para Administradora."

									DisarmTransaction()

									Return .F.
								EndIf
							EndIf

							nVlTaxa  := Round(((aRegSZ3[nY][03] * aRegSAE[nPos][03]) / 100),2)
							nVlVenda := aRegSZ3[nY][03] - nVlTaxa
							nVlParc  := Round((nVlVenda / aRegSZ3[nY][10]),2)
							nVlDif   := nVlVenda - (nVlParc * aRegSZ3[nY][10])
						EndCase
					Endif

					If aScan(aTpTitulo, {|x| AllTrim(x) == AllTrim(aRegSZ3[nY][04])}) > 0
						cTipo   := aRegSZ3[nY][04]
						nQtParc := aRegSZ3[nY][10]
					else
						cCliente := SC5->C5_CLIENTE
						cLoja    := SC5->C5_LOJACLI
						cTipo    := "RA"
						nQtParc  := 1

					EndIf


					dVencto := aRegSZ3[nY][05]
					// recebe	ncc e parcelas
					If aRegSZ3[nY][04] == "BOL"
						cNatureza := "1005002"

					ElseIf aRegSZ3[nY][04] == "NCC"
						cNatureza := "2001008"

					else
						nPos := aScan(aNatureza,{|x| AllTrim(x[01]) == AllTrim(cTipo)})

						If nPos == 0

							cNatureza := aNatureza[08][02]
						else
							cNatureza := aNatureza[nPos][02]

						EndIf
					EndIf



					For nY1 := 1 To nQtParc
						dVencto += nQtDias

						If cTipo ==""
							cTipo:= AllTrim(aRegSZ3[nY][04])

						Endif
						aRegSE1 := U_fnP01SE1(@aRegSZ3, @nY, nY1, @cCliente, @cLoja, (nVlParc + nVlDif), @dVencto, @cTIpo, @cNatureza)
						nVlDif  := 0

						lMsErroAuto := .F.



						MsExecAuto({|x,y| FINA040(x,y)},aRegSE1,3)           // Inclusão Contas a Receber

						If lMsErroAuto
							MostraErro()
							DisarmTransaction()

							Return aRet
						Else
							If Alltrim(cTIpo) == "NCC"
								BXPGTO()
							EndIf
						Endif
					Next
				else
					nY1      := 1
					cCliente := SC5->C5_CLIENTE
					cLoja    := SC5->C5_LOJACLI
					nVlParc  := aRegSZ3[nY][03]
					dVencto  := aRegSZ3[nY][05]
					cTipo    := "RA"
					nPos     := aScan(aNatureza,{|x| AllTrim(x[01]) == cTipo})

					If nPos == 0
						cNatureza := aNatureza[08][02]
					else
						cNatureza := aNatureza[nPos][02]
					EndIf

					aRegSE1 := U_fnP01SE1(@aRegSZ3, @nY, nY1, @cCliente, @cLoja, nVlParc, @dVencto, @cTipo, @cNatureza)

					lMsErroAuto := .F.

					MsExecAuto({|x,y| FINA040(x,y)},aRegSE1,3)           // Inclusão Contas a Receber

					If lMsErroAuto
						MostraErro()
						DisarmTransaction()

						Return aRet
					EndIf
				EndIf

				// -- Grava Lançamento
				// -------------------
				If SZ3->(dbSeek(FWxFilial("SZ3") + aRegSZ3[nY][01] + aRegSZ3[nY][02]))
					Reclock("SZ3",.F.)
					dbDelete()
					SZ3->(MsUnLock())
				EndIf

				Reclock("SZ3",.T.)
				Replace SZ3->Z3_FILIAL  with FWxFilial("SZ3")
				Replace SZ3->Z3_PEDIDO  with aRegSZ3[nY][01]
				Replace SZ3->Z3_ITEM    with aRegSZ3[nY][02]
				Replace SZ3->Z3_VALOR   with aRegSZ3[nY][03]
				Replace SZ3->Z3_TIPO    with aRegSZ3[nY][04]
				Replace SZ3->Z3_DTEMIS  with aRegSZ3[nY][05]
				Replace SZ3->Z3_BANCO   with aRegSZ3[nY][06]
				Replace SZ3->Z3_AGENCIA with aRegSZ3[nY][07]
				Replace SZ3->Z3_CONTA   with aRegSZ3[nY][08]
				Replace SZ3->Z3_CODADM  with aRegSZ3[nY][09]
				Replace SZ3->Z3_PARCELA with aRegSZ3[nY][10]
				Replace SZ3->Z3_DOCTEF  with aRegSZ3[nY][11]
				Replace SZ3->Z3_NSUTEF  with aRegSZ3[nY][12]
				Replace SZ3->Z3_IDMERPG with aRegSZ3[nY][13]
				Replace SZ3->Z3_VLTAXA  with nVlTaxa
				SZ3->(MsUnlock())
				// -------------------
			End Transaction
		Next

		// -- Liberar o pedido após todo o pagamento lançado
		// -------------------------------------------------
		If aRegPed[nX][02] == 0
			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))

			If SC5->(dbSeek(FWxFilial("SC5") + aRegPed[nX][01]))
				Reclock("SC5",.F.)
				Replace SC5->C5_XBLQCRE with "N"
				SC5->(MsUnlock())
			EndIf

			// -- Liberar Pedido Venda
			// -- Bloqueio de Crédito por Valor
			// --------------------------------
			cQuery := "Update " + RetSqlName("SC9") + " Set C9_BLCRED = ''"
			cQuery += "  where D_E_L_E_T_ <> '*'"
			cQuery += "    and C9_FILIAL  = '" + FWxFilial("SC9") + "'"
			cQuery += "    and C9_PEDIDO  = '" + aRegPed[nX][01] + "'"
			cQuery += "    and C9_NFISCAL = ''"
			cQuery += "    and C9_BLCRED not in ('09','10')"

			TCSQLEXEC(cQuery)
		EndIf
	Next
Return aRet

//-------------------------------------------------------------------
/*/ Função fnP01SE1()

	Montar registro do título para gravação.

	@author Anderson Almeida (TOTVS NE)
	@version P12.1...
	@since   15/08/2021
/*/
//-------------------------------------------------------------------
User Function fnP01SE1(aRegSZ3, nY, nParcela, cCliente, cLoja, cValor, cVencto, cTipo, cNatureza)
	Local aReg := {}

	aAdd(aReg, {"E1_FILIAL" , FWxFilial("SE1")                        ,Nil})
	aAdd(aReg, {"E1_PREFIXO", "M" + SubStr(aRegSZ3[nY][02],2,2)       ,Nil})
	aAdd(aReg, {"E1_NUM"    , StrZero(Val(aRegSZ3[nY][01]),TamSX3("E1_NUM")[1]) ,Nil})
	aAdd(aReg, {"E1_PARCELA", Strzero(nParcela,TamSX3("E1_PARCELA")[1]) ,Nil})
	aAdd(aReg, {"E1_TIPO"   , cTipo                                   ,Nil})
	aAdd(aReg, {"E1_CLIENTE", cCliente                                ,Nil})
	aAdd(aReg, {"E1_LOJA"   , cLoja                                   ,Nil})
	aAdd(aReg, {"E1_NATUREZ", cNatureza                               ,Nil})
	aAdd(aReg, {"E1_VALOR"  , cValor                                  ,Nil})
	aAdd(aReg, {"E1_VALLIQ" , cValor                                  ,Nil})
	aAdd(aReg, {"E1_SALDO"  , cValor                                  ,Nil})
	aAdd(aReg, {"E1_VLCRUZ" , cValor                                  ,Nil})
	aAdd(aReg, {"E1_NOMCLI" , Posicione("SA1",1,FWxFilial("SA1") + cCliente + cLoja,"A1_NREDUZ") ,Nil})
	aAdd(aReg, {"E1_PORTADO", aRegSZ3[nY][06]                         ,Nil})
	aAdd(aReg, {"E1_AGEDEP" , aRegSZ3[nY][07]                         ,Nil})
	aAdd(aReg, {"E1_CONTA"  , aRegSZ3[nY][08]                         ,Nil})
	aAdd(aReg, {"E1_EMISSAO", aRegSZ3[nY][05]                         ,Nil})
	aAdd(aReg, {"E1_VENCTO" , cVencto                                 ,Nil})
	aAdd(aReg, {"E1_VENCREA", cVencto                                 ,Nil})
	aAdd(aReg, {"E1_VENCORI", cVencto                                 ,Nil})
	aAdd(aReg, {"E1_HIST"   ,IIf(cTipo == "RA","ADT VENDA DO PAGTO TIPO " + aRegSZ3[nY][04],"") ,Nil})
	aAdd(aReg, {"E1_MOEDA"  , 1                                       ,Nil})
	aAdd(aReg, {"E1_SITUACA", "0"                                     ,Nil})
	aAdd(aReg, {"E1_PEDIDO" , aRegSZ3[nY][01]                         ,Nil})
	aAdd(aReg, {"E1_ORIGEM" , "FINA040"                               ,Nil})
	aAdd(aReg, {"E1_STATUS" , "A"                                     ,Nil})
	aAdd(aReg, {"E1_FLUXO"  , "S"                                     ,Nil})
	aAdd(aReg, {"E1_DOCTEF" , aRegSZ3[nY][11]                         ,Nil})
	aAdd(aReg, {"E1_NSUTEF" , aRegSZ3[nY][12]                         ,Nil})
	aAdd(aReg, {"E1_XCHVSZ3", aRegSZ3[nY][01] + aRegSZ3[nY][02]       ,Nil})
	aAdd(aReg, {"E1_XIDMEPG", aRegSZ3[nY][13]                         ,Nil})


Return aReg


Static Function BXPGTO()
	Local lRet    := .F.
	Local _aCabec := {}
	Local dSave   := dDataBase

	dDataBase := dBaixa  := dDtCredito := SE1->E1_EMISSAO

	Aadd(_aCabec, {"E1_PREFIXO" 	, SE1->E1_PREFIXO  ,Nil})
	Aadd(_aCabec, {"E1_NUM"		 	, SE1->E1_NUM	   ,Nil})
	Aadd(_aCabec, {"E1_PARCELA" 	, SE1->E1_PARCELA  ,Nil})
	Aadd(_aCabec, {"E1_TIPO" 		, SE1->E1_TIPO	   ,Nil})
	Aadd(_aCabec, {"E1_CLIENTE"		, SE1->E1_CLIENTE  ,Nil})
	Aadd(_aCabec, {"E1_LOJA"   		, SE1->E1_LOJA     ,Nil})
	Aadd(_aCabec, {"E1_BCOCLI"     	, SE1->E1_BCOCLI   ,Nil})
	Aadd(_aCabec, {"E1_AGEDEP"   	, SE1->E1_AGEDEP   ,Nil})
	Aadd(_aCabec, {"E1_CONTA"     	, SE1->E1_CONTA    ,Nil})
	Aadd(_aCabec, {"E1_FILIAL"     	, SE1->E1_FILIAL   ,Nil})
	Aadd(_aCabec, {"AUTMOTBX" 		, "D_V"	 , Nil})
	Aadd(_aCabec, {"AUTHIST"		, "VLR REF. AO TITULO "+ SE1->E1_NUM , Nil})
	Aadd(_aCabec, {"AUTDTBAIXA" 	, dDataBase  , Nil})
	Aadd(_aCabec, {"AUTDTCREDITO"	, dDataBase  , Nil})



	lMsErroAuto := .F.
	Begin Transaction

		GetMv("MV_ANTCRED")
		PutMv("MV_ANTCRED","T") // permitir baixas antecipadas a emissao

		MSExecAuto({|x,y| FINA070(x,y)},_aCabec,3) //3-Inclusao

		GetMv("MV_ANTCRED")
		PutMv("MV_ANTCRED","F") // NAO permitir baixas antecipadas a emissao é o padrao do sistema

		IF lMsErroAuto
			DisarmTransaction()
			MostraErro()
		Else
			lRet := .t.	// sucesso
		Endif

	End Transaction

	dDataBase := dSave

Return lRet

