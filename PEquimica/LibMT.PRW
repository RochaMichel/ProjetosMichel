#INCLUDE 'protheus.ch'
#INCLUDE 'totvs.ch'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} User Function LibMT
Liberacao de Multiplos Titulos
@author Pedro Henrique Amaral de Almeida
@since 23/01/2024
@version 1.0
@type function
/*/

User Function LibMT()
	Local aArea 	:= FWGetArea()
	Local cUsuario 	:= RetCodUsr()
	Local lOk 		:= .F.
	//Local aGrupo 	:= FWSFUsrGrps(cUsuario)
	//Local cGrupo 	:= ArrTokStr(aGrupo, ";")
	//Local cGrupoApr := GetMV("MV_XGRPLIB",,"000000")
	Private cAliasTmp := GetNextAlias()
	
	If cUsuario $ GetMV("MV_XDIRTR",,"000000;000014;000043;000166;000162") .OR. cUsuario $ GetMV("MV_XUsuLib",,"000000;000050;000023;000027")  //Verifica se o usuario � da diretoria ou aprovador
		lOk := .T.
	Endif
	
	If !lOk
		Return Msginfo("Usuario n�o tem permiss�o para aprovar","Atencao")
	EndIf

	//If !cUsuario $ GetMV("MV_XUsuLib",,"000000,000050,000023,000027") //verifica se o usuario � aprovador/liberador
	////000023;000050;000027
	//	Return Msginfo("Usuario n�o tem permiss�o para aprovar","Atencao")
	//endif
	//Chama a tela
	fMontaTela()

	FWRestArea(aArea)
Return

/*/{Protheus.doc} fMontaTela
Monta a tela com a marcação de dados
@author Pedro Henrique Amaral de Almeida
@since 23/01/2024
@version 1.0
@type function
/*/

Static Function fMontaTela()
	Local aArea         := GetArea()
	Local aCampos := {}
	Local oTempTable := Nil
	Local aColunas := {}
	Local cFontPad  := 'Tahoma'
	Local oFontGrid := TFont():New(cFontPad, /*uPar2*/, -14)
	Local aSeek 	:= {}
	//Janela e componentes
	Private oDlgMark
	Private oPanGrid
	Private oMarkBrowse
	Private aRotina   := MenuDef()
	//Tamanho da janela
	Private aTamanho := MsAdvSize()
	Private nJanLarg := aTamanho[5]
	Private nJanAltu := aTamanho[6]


	//Adiciona as colunas que serão criadas na temporária
	aAdd(aCampos, { 'OK', 'C', 2, 0}) //Flag para marcação
	//aAdd(aCampos, { 'OK ', 'C', 	1, 0}) //OK
	aAdd(aCampos, { 'Filial', 'C', TamSx3('E2_FILIAL')[1]	, 0}) //Filial
	aAdd(aCampos, { 'Prefixo', 'C',TamSx3('E2_PREFIXO')[1]	, 0}) //Prefixo
	aAdd(aCampos, { 'Titulo', 'C', TamSx3('E2_NUM')[1]		, 0}) //Titulo
	aAdd(aCampos, { 'Parcela', 'C',TamSx3('E2_PARCELA')[1]	, 0}) //Parcela
	aAdd(aCampos, { 'Tipo', 'C',   TamSx3('E2_TIPO')[1]		, 0}) //Tipo
	aAdd(aCampos, { 'Nat', 'C',    TamSx3('E2_NATUREZ')[1]	, 0}) //Natureza
	aAdd(aCampos, { 'Porta', 'C',  TamSx3('E2_PORTADO')[1]	, 0}) //Portador
	aAdd(aCampos, { 'Fornec', 'C', TamSx3('E2_FORNECE')[1]	, 0}) //Fornecedor
	aAdd(aCampos, { 'NomeFor','C', TamSx3('E2_NOMFOR')[1]	, 0}) //Nome Fornecedor
	aAdd(aCampos, { 'Loja', 'C',   TamSx3('E2_LOJA')[1]		, 0}) //Loja
	aAdd(aCampos, { 'Emissao', 'D',TamSx3('E2_EMISSAO')[1]	, 0}) //Emissao
	aAdd(aCampos, { 'Entrada', 'D',TamSx3('E2_EMIS1')[1]	, 0}) //Entrada de nota
	aAdd(aCampos, { 'Vencim', 'D', TamSx3('E2_VENCTO')[1]	, 0}) //Vencimento
	aAdd(aCampos, { 'Valor', 'C',  TamSx3('E2_VALOR')[1]	, 0}) //Valor
	aAdd(aCampos, { 'Saldo', 'C',  TamSx3('E2_SALDO')[1]	, 0}) //Saldo
	aAdd(aCampos, { 'DataLib','D', TamSx3('E2_DATALIB')[1]	, 0}) //Data de Liberacao
	aAdd(aCampos, { 'Usuario','C', TamSx3('E2_USERLGI')[1]	, 0}) //Usuario
	aAdd(aCampos, { 'StatLib','C', TamSx3('E2_STATLIB')[1]	, 0}) //Status
	aAdd(aCampos, { 'CodApro','C', TamSx3('E2_CODAPRO')[1]	, 0}) //Codigo do Aprovador
	aAdd(aCampos, { 'Recno', 'N', 999999, 0}) //Codigo do Aprovador

	//Cria a tabela temporária
	oTempTable:= FWTemporaryTable():New(cAliasTmp)
	oTempTable:SetFields( aCampos )
	oTempTable:AddIndex("01", {"Titulo","Prefixo","Entrada"})
	oTempTable:AddIndex("02", {"Entrada"})
	oTempTable:AddIndex("03", {"OK"})
	oTempTable:Create()

	//Popula a tabela temporária
	Processa({|| fPopula()}, 'Processando...')

	//Adiciona as colunas que serão exibidas no FWMarkBrowse
	aColunas := fCriaCols()

	aAdd(aSeek,{"No. Titulo" ,{{"","C",6,0,"Titulo" ,"@!"}} } )
	aAdd(aSeek,{"Data de Entrada" ,{{"","D",8,0,"Entrada" ,"@!"}} })
	//Criando a janela
	DEFINE MSDIALOG oDlgMark TITLE 'Tela para Marcacao de dados' FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	//Dados
	oPanGrid := tPanel():New(001, 001, '', oDlgMark, /*oFont*/, /*lCentered*/, /*uParam7*/, RGB(000,000,000), RGB(254,254,254), (nJanLarg/2) - 1, (nJanAltu/2) - 1)
	oMarkBrowse := FWMarkBrowse():New()
	oMarkBrowse:SetAlias(cAliasTmp)
	oMarkBrowse:SetDescription('Liberacao de Multiplos Titulos')
	//oMarkBrowse:DisableFilter()
	//oMarkBrowse:DisableSeek()
	oMarkBrowse:SetSeek(.T.,aSeek)
	oMarkBrowse:DisableConfig()
	oMarkBrowse:DisableSaveConfig()
	oMarkBrowse:SetFontBrowse(oFontGrid)
	oMarkBrowse:SetFieldMark('OK')
	oMarkBrowse:SetTemporary(.T.)
	oMarkBrowse:SetColumns(aColunas)
	//oMarkBrowse:AllMark()
	oMarkBrowse:SetOwner(oPanGrid)
	oMarkBrowse:Activate()
	ACTIVATE MsDialog oDlgMark CENTERED

	//Deleta a temporária e desativa a tela de marcação
	oTempTable:Delete()
	oMarkBrowse:DeActivate()

	RestArea(aArea)
Return

/*/{Protheus.doc} fPopula
Popula essa informação na tabela temporária usada no browse
@author Pedro Henrique Amaral de Almeida
@since 23/01/2024
@version 1.0
@type function
/*/

Static Function fPopula()
	Local cQryDados := ''
	Local nTotal := 0
	Local nAtual := 0
	Local cUsuario := RetCodUsr()

	//Verifica se o usuario � o que realiza as liberacoes, se for, pode ver todas as notas especificas
	If cUsuario $ GetMV("MV_XUsuLib",,"000000,000050,000023,000027")

		cQryDados+= "SELECT * FROM " + RetSQLName('SE2') + "  "
		cQryDados+= "	WHERE D_E_L_E_T_ =''					"
		cQryDados+= " AND E2_STATLIB IN ('01',' ')					"
		cQryDados+= " AND E2_TIPO IN (" + GetMV("MV_XE2TIPO",,"'NF','RPA'")+ ")
		cQryDados+= " ORDER BY E2_EMIS1,E2_FILIAL,E2_PREFIXO,E2_NUM	"
	Else
		//Caso n�o seja o usuario de liberacoes, vai ser algu�m da diretoria, logo n�o v� os titulos 'NF', 'TX', 'INS', 'SES', 'RPA'"
		cQryDados += "SELECT * FROM " + RetSQLName('SE2') + " 
		cQryDados += "	WHERE D_E_L_E_T_ = ''	"		                        		
		cQryDados += "  AND E2_STATLIB IN ('01',' ')	  "		                       			
		cQryDados += "  AND E2_TIPO NOT IN (" + GetMV("MV_XE2TIPO",,"'NF','RPA'")+ ")	                       			
		cQryDados += " ORDER BY E2_EMIS1,E2_FILIAL,E2_PREFIXO,E2_NUM"
	Endif
	//Monta a consulta
	MPSysOpenQuery(cQryDados, 'QRYDADTMP')

	//Definindo o tamanho da régua
	DbSelectArea('QRYDADTMP')
	Count to nTotal
	ProcRegua(nTotal)
	QRYDADTMP->(DbGoTop())

	//Enquanto houver registros, adiciona na temporária
	While ! QRYDADTMP->(EoF())
		nAtual++
		IncProc('Analisando registro ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')

		RecLock(cAliasTmp, .T.)
		(cAliasTmp)->OK := Space(2)
		//(cAliasTmp)->OK     := " "
		(cAliasTmp)->Filial := QRYDADTMP->E2_FILIAL
		(cAliasTmp)->Prefixo:= QRYDADTMP->E2_PREFIXO
		(cAliasTmp)->Titulo := QRYDADTMP->E2_NUM
		(cAliasTmp)->Parcela:= QRYDADTMP->E2_PARCELA
		(cAliasTmp)->Tipo   := QRYDADTMP->E2_TIPO
		(cAliasTmp)->Nat    := QRYDADTMP->E2_NATUREZ
		(cAliasTmp)->Porta  := QRYDADTMP->E2_PORTADO
		(cAliasTmp)->Fornec := QRYDADTMP->E2_FORNECE
		(cAliasTmp)->NomeFor:= QRYDADTMP->E2_NOMFOR
		(cAliasTmp)->Loja   := QRYDADTMP->E2_LOJA
		(cAliasTmp)->Emissao:= Stod(QRYDADTMP->E2_EMISSAO)
		(cAliasTmp)->Entrada:= Stod(QRYDADTMP->E2_EMIS1)
		(cAliasTmp)->Vencim := Stod(QRYDADTMP->E2_VENCTO)
		(cAliasTmp)->Valor  := TRANSFORM(QRYDADTMP->E2_VALOR, "@E 999,999,999.99")
		(cAliasTmp)->Saldo  := TRANSFORM(QRYDADTMP->E2_SALDO, "@E 999,999,999.99")
		(cAliasTmp)->DataLib:= Stod(QRYDADTMP->E2_DATALIB)
		(cAliasTmp)->Usuario:= UsrRetName(AllTrim(Substr(Embaralha(QRYDADTMP->E2_USERLGI,1),3,6)))
		(cAliasTmp)->StatLib:= QRYDADTMP->E2_STATLIB
		(cAliasTmp)->CodApro:= QRYDADTMP->E2_CODAPRO
		(cAliasTmp)->Recno  := QRYDADTMP->R_E_C_N_O_
		(cAliasTmp)->(MsUnlock())

		QRYDADTMP->(DbSkip())
	EndDo
	QRYDADTMP->(DbCloseArea())
	(cAliasTmp)->(DbGoTop())
Return

/*/{Protheus.doc} fCriaCols
Função que gera as colunas usadas no browse
@author Pedro Henrique Amaral de Almeida
@since 23/01/2024
@version 1.0
@type function
/*/

Static Function fCriaCols()
	Local nAtual       := 0
	Local aColunas := {}
	Local aEstrut  := {}
	Local oColumn

	//Adicionando campos que serão mostrados na tela
	//[1] - Campo da Temporaria
	//[2] - Titulo
	//[3] - Tipo
	//[4] - Tamanho
	//[5] - Decimais
	//[6] - Mascara
	//aAdd(aEstrut, { 'OK '    , 'OK', 'C', 1, 0, ''})
	aAdd(aEstrut, { 'Filial' , 'Filial', 'C', 	 		TamSx3('E2_FILIAL')[1]		, 0, ''}) // + descricao de filial
	aAdd(aEstrut, { 'Prefixo', 'Prefixo', 'C',	 		TamSx3('E2_PREFIXO')[1]		, 0, ''})
	aAdd(aEstrut, { 'Titulo' , 'Titulo', 'C', 	 		TamSx3('E2_NUM')[1]			, 0, ''})
	aAdd(aEstrut, { 'Parcela', 'Parcela', 'C',   		TamSx3('E2_PARCELA')[1]		, 0, ''})
	aAdd(aEstrut, { 'Tipo'   , 'Tipo', 'C', 	 		TamSx3('E2_TIPO')[1]		, 0, ''})
	aAdd(aEstrut, { 'Nat'    , 'Natureza', 'C',	 		TamSx3('E2_NATUREZ')[1]		, 0, ''})
	aAdd(aEstrut, { 'Porta'  , 'Portador', 'C',  		TamSx3('E2_PORTADO')[1]		, 0, ''})
	aAdd(aEstrut, { 'Fornec' , 'Fornecedor', 'C',		TamSx3('E2_FORNECE')[1]		, 0, ''})
	aAdd(aEstrut, { 'NomeFor', 'Nome Fornecedor', 'C', 	TamSx3('E2_NOMFOR')[1]		, 0, ''})
	aAdd(aEstrut, { 'Loja'   , 'Loja', 'C', 			TamSx3('E2_LOJA')[1]		, 0, ''})
	aAdd(aEstrut, { 'Emissao', 'Emissao', 'D', 			TamSx3('E2_EMISSAO')[1]		, 0, ''})
	aAdd(aEstrut, { 'Entrada', 'Entrada', 'D', 			TamSx3('E2_EMIS1')[1]		, 0, ''})
	aAdd(aEstrut, { 'Vencim' , 'Vencimento', 'D', 		TamSx3('E2_VENCTO')[1]		, 0, ''})
	aAdd(aEstrut, { 'Valor'  , 'Valor', 'C', 			TamSx3('E2_VALOR')[1]		, 0, ''})
	aAdd(aEstrut, { 'Saldo'  , 'Saldo', 'C',			TamSx3('E2_SALDO')[1]		, 0, ''})
	aAdd(aEstrut, { 'Usuario', 'Usuario', 'C', 		TamSx3('E2_USERLGI')[1]		, 0, ''})

	//Percorrendo todos os campos da estrutura
	For nAtual := 1 To Len(aEstrut)
		//Cria a coluna
		oColumn := FWBrwColumn():New()
		oColumn:SetData(&('{|| ' + cAliasTmp + '->' + aEstrut[nAtual][1] +'}'))
		oColumn:SetTitle(aEstrut[nAtual][2])
		oColumn:SetType(aEstrut[nAtual][3])
		oColumn:SetSize(aEstrut[nAtual][4])
		oColumn:SetDecimal(aEstrut[nAtual][5])
		oColumn:SetPicture(aEstrut[nAtual][6])

		//Adiciona a coluna
		aAdd(aColunas, oColumn)
	Next
Return aColunas

/*/{Protheus.doc} User Function LibMTO
Função acionada pelo botão continuar da rotina
@author Pedro Henrique Amaral de Almeida
@since 23/01/2024
@version 1.0
@type function
/*/

User Function LibMTO()
	Processa({|| fProcessa()}, 'Processando...')
Return

/*/{Protheus.doc} fProcessa
Função que percorre os registros da tela
@author Pedro Henrique Amaral de Almeida
@since 23/01/2024
@version 1.0
@type function
/*/

Static Function fProcessa()
	Local aArea     := FWGetArea()
	Local cMarca    := oMarkBrowse:Mark()
	Local nAtual    := 0
	Local nTotal    := 0
	Local nTotMarc := 0
	//DbSelectArea("SE2")

	//Define o tamanho da régua
	DbSelectArea(cAliasTmp)
	(cAliasTmp)->(DbGoTop())
	(cAliasTmp)->(DbSetOrder(2))
	Count To nTotal
	ProcRegua(nTotal)

	(cAliasTmp)->(DbGoTop())

	//Percorrendo os registros
	DbSelectArea("SE2")
	DbSetOrder(1)
	SE2->(DbGoTop())
	//enquanto tiver registros, percorre
	While ! (cAliasTmp)->(EoF())
		SE2->(DbgoTo((cAliasTmp)->Recno))
		nAtual++
		IncProc('Analisando Titulos ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')
		//Caso esteja marcado
		If oMarkBrowse:IsMark(cMarca)
			nTotMarc++
			Begin Transaction
				RecLock("SE2",.F.)
				SE2->E2_DATALIB := dDataBase
				SE2->E2_USUALIB := cUsername
				SE2->E2_STATLIB := "03"
				SE2->E2_CODAPRO := Fa006User( __cUserId, .F., 2 )
				SE2->(MsUnlock())
			End Transaction
			F580GrvFI2()
		EndIf
		(cAliasTmp)->(DbSkip())
	EndDo

	//Mostra a mensagem de término e caso queria fechar a dialog, basta usar o método End()
	FWAlertInfo('Foram liberados ' + cValToChar(nTotMarc) + ' Titulos', 'Atencao')
	//oDlgMark:End()

	FWRestArea(aArea)
	oDlgMark:End()
Return

/*/{Protheus.doc} MenuDef
Botões usados no Browse
@author Pedro Henrique Amaral de Almeida
@since 23/01/2024
@version 1.0
@type function
/*/

Static Function MenuDef()
	Local aRotina := {}

	//Criação das opções
	//ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'AXPESQUI' 	 OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Liberar'  ACTION 'u_LibMTO'      OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.LibMT' OPERATION 2 ACCESS 0
	//ADD OPTION aRotina TITLE 'Legenda' ACTION 'u_legenda' OPERATION 2 ACCESS 0

Return aRotina

Static Function ModelDef()
	Local oModel   := Nil
	Local oStPai   := CabecMd()
	oModel := MPFormModel():New("mLibMT", /*{|oModel| MDMVlPre( oModel ) }bPre*/, /*{|oModel| MDMVlPos( oModel ) }/*bPos*/,/*{||ComplZZ3( Self ) }bCommit*/,/*bCancel*/)

	oModel:AddFields((cAliasTmp),/*cOwner*/,oStPai)
	oModel:SetDescription("Liberacao Multipla de Titulos")
	oModel:GetModel( (cAliasTmp) ):SetDescription("Liberacao Multipla de Titulos")
	oModel:SetPrimaryKey({'Titulo'})
	

Return oModel

Static Function ViewDef()
	Local oView     := FWFormView():New()
	Local oModel    := FWLoadModel('LibMT')
	Local oStPai 	:= CabecVw()

	//Criando a ViewTituloTIT

	oView:SetModel(oModel)
	//Adicionando os campos do cabe�alho
	oView:AddField('VIEW_cAliasTmp', oStPai ,(cAliasTmp))
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('TELA',100)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_cAliasTmp','TELA')
Return oView

Static Function CabecMd()

	Local oStructModelCabec	:= FWformModelStruct():New()

	oStructModelCabec:AddTable((cAliasTmp),,"")

/* 	oStructModelCabec:AddField(	'OK', ; 	 		            // [01] Titulo do campo X
	'OK', ; 			            // [02] ToolTip do campo X
	'OK', ;  				    // [03] Id do Field X
	'C', ;     			            // [04] Tipo do campo X
	1, ;                        	// [05] Tamanho do campoX
	,;
	,;
	,;
	,;
	,;
	,;
	.T.,) */

	oStructModelCabec:AddField(	'Filial.', ; 	 		        // [01] Titulo do campo
	'Filial.', ; 			        // [02] ToolTip do campo
	'Filial', ;  				// [03] Id do Field
	'C', ;     	   		            // [04] Tipo do campo
	TamSx3('E2_FILIAL')[1], ;      	                    // [05] Tamanho do campo
	,;
	,;
	,;
	,;
	,;
	,;
	.T.,)


	oStructModelCabec:AddField(	'Prefixo', ; 	 				    // [01] Titulo do campo
	'Prefixo', ; 			    	    // [02] ToolTip do campo
	'Prefixo', ;  					// [03] Id do Field
	'C', ;     			            // [04] Tipo do campo
	TamSx3('E2_PREFIXO')[1], ;      	                    // [05] Tamanho do campo
	,;
	,;
	,;
	,;
	,;
	,;
	.T.,)

	oStructModelCabec:AddField(	'Titulo', ; 	 			// [01] Titulo do campo
	'Titulo', ; 			    	// [02] ToolTip do campo
	'Titulo', ;  				// [03] Id do Field
	'C', ;     			            // [04] Tipo do campo
	TamSx3('E2_NUM')[1], ;      	                    // [05] Tamanho do campo
	,;
	,;
	,;
	,;
	,;
	,;
	.T.,)


	oStructModelCabec:AddField(	'Parcela', ; 	 				// [01] Titulo do campo
	'Parcela', ; 			    	// [02] ToolTip do campo
	'Parcela', ;  				// [03] Id do Field
	'C', ;     			            // [04] Tipo do campo
	TamSx3('E2_PARCELA')[1], ;      	                    // [05] Tamanho do campo
	,;
	,;
	,;
	,;
	,;
	,;
	.T.,)

	oStructModelCabec:AddField(	'Tipo', ; 	 				    // [01] Titulo do campo
	'Tipo', ; 			    	    // [02] ToolTip do campo
	'Tipo', ;  					// [03] Id do Field
	'C', ;     			            // [04] Tipo do campo
	TamSx3('E2_TIPO')[1], ;      	                    // [05] Tamanho do campo
	,;
	,;
	,;
	,;
	,;
	,;
	.T.,)

	oStructModelCabec:AddField(	'Natureza', ; 	 				// [01] Titulo do campo
	'Natureza', ; 			    	// [02] ToolTip do campo
	'Nat', ;  					// [03] Id do Field
	'C', ;     			            // [04] Tipo do campo
	TamSx3('E2_NATUREZ')[1], ;      	                    // [05] Tamanho do campo
	,;
	,;
	,;
	,;
	,;
	,;
	.T.,)

	oStructModelCabec:AddField(	'Portador', ; 	 				// [01] Titulo do campo
	'Portador', ; 			    	// [02] ToolTip do campo
	'Porta', ;  					// [03] Id do Field
	'C', ;     			            // [04] Tipo do campo
	TamSx3('E2_PORTADO')[1], ;      	                    // [05] Tamanho do campo
	,;
	,;
	,;
	,;
	,;
	,;
	.T.,)


	oStructModelCabec:AddField(	'Fornecedor', ; 	 			// [01] Titulo do campo
	'Fornecedor', ; 			    // [02] ToolTip do campo
	'Fornec', ;  				// [03] Id do Field
	'C', ;     			            // [04] Tipo do campo
	TamSx3('E2_FORNECE')[1], ;      	                    // [05] Tamanho do campo
	,;
		,;
		,;
		,;
		,;
		,;
		.T.,)

	oStructModelCabec:AddField(	'Nome Fornecedor', ; 	 	    // [01] Titulo do campo
	'Nome Fornecedor', ; 		    // [02] ToolTip do campo
	'NomeFor', ;  				// [03] Id do Field
	'C', ;     			            // [04] Tipo do campo
	TamSx3('E2_NOMFOR')[1], ;      	                    // [05] Tamanho do campo
	,;
	,;
	,;
	,;
	,;
	,;
	.T.,)


	oStructModelCabec:AddField(	'Loja', ; 	 				    // [01] Titulo do campo
	'Loja', ; 			    	    // [02] ToolTip do campo
	'Loja', ;  					// [03] Id do Field
	'C', ;     			            // [04] Tipo do campo
	TamSx3('E2_LOJA')[1], ;      	                    // [05] Tamanho do campo
	,;
	,;
	,;
	,;
	,;
	,;
	.T.,)

		oStructModelCabec:AddField(	'Entrada', ; 	 				    // [01] Titulo do campo
	'Entrada', ; 			    	    // [02] ToolTip do campo
	'Entrada', ;  					// [03] Id do Field
	'D', ;     			            // [04] Tipo do campo
	TamSx3('E2_EMISSAO')[1], ;      	                    // [05] Tamanho do campo
	,;
	,;
	,;
	,;
	,;
	,;
	.T.,)



	oStructModelCabec:AddField(		'Emissao', ; 	 			// [01] Titulo do campo
	'Emissao', ; 			    	// [02] ToolTip do campo
	'Emissao', ;  				// [03] Id do Field
	'D', ;     			            // [04] Tipo do campo
	TamSx3('E2_EMIS1')[1], ;      	                    // [05] Tamanho do campo
	,;
	,;
	,;
	,;
	,;
	,;
	.T.,)

	oStructModelCabec:AddField(	'Vencimento', ; 	 // [01] Titulo do campo
	'Vencimento', ; 			   					 // [02] ToolTip do campo
	'Vencim', ;  									// [03] Id do Field
	'D', ;     			          					  // [04] Tipo do campo
	TamSx3('E2_VENCTO')[1], ;      	                    // [05] Tamanho do campo
	,;
	,;
	,;
	,;
	,;
	,;
	.T.,)

	oStructModelCabec:AddField(	'Valor', ; 	 			// [01] Titulo do campo
	'Valor', ; 			    	    					// [02] ToolTip do campo
	'Valor', ;  										// [03] Id do Field
	'C', ;     			            					// [04] Tipo do campo
	TamSx3('E2_VALOR')[1], ;      	                    // [05] Tamanho do campo
	,;
	,;
	,;
	,;
	,;
	,;
	.T.,)

	oStructModelCabec:AddField(	'Saldo', ; 	 			// [01] Titulo do campo
	'Saldo', ; 			    	    					// [02] ToolTip do campo
	'Saldo', ;  										// [03] Id do Field
	'C', ;     			            					// [04] Tipo do campo
	TamSx3('E2_SALDO')[1], ;      	                    // [05] Tamanho do campo
	,;
	,;
	,;
	,;
	,;
	,;
	.T.,)

	oStructModelCabec:AddField(	'Usuario', ; 	// [01] Titulo do campo
	'Usuario Inclusao', ; 			        	// [02] ToolTip do campo
	'Usuario', ;  								// [03] Id do Field
	'C', ;     	   		            			// [04] Tipo do campo
	TamSx3('E2_USERLGI')[1], ;      	    	// [05] Tamanho do campo
	,;
	,;
	,;
	,;
	,;
	,;
	.T.,)


Return oStructModelCabec

Static Function CabecVw()

	Local oStructViewCabec	:= FWformViewStruct():New()

	//C�digo da Filial
/* 	oStructViewCabec:AddField( ;
	'OK ', ;	  		            // [01] Campo
	'001', ;   			            // [02] Ordem
	'OK.', ;			            // [03] Titulo
	'OK.', ;			            // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	NIL, ;                          // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	NIL, ;      				    // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual */

	oStructViewCabec:AddField( ;
	'Filial' , ;	  		            // [01] Campo
	'002', ;   			            // [02] Ordem
	'Filial.', ;			            // [03] Titulo
	'Filial.', ;			            // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	NIL, ;                          // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	NIL, ;      				    // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

	oStructViewCabec:AddField( ;
	'Prefixo', ;	  		        // [01] Campo
	'003', ;   			            // [02] Ordem
	'Prefixo.', ;			        // [03] Titulo
	'Prefixo.', ;			        // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	NIL, ;                          // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	NIL, ;      				    // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

    oStructViewCabec:AddField( ;
	'Titulo', ;	  		            // [01] Campo
	'004', ;   			            // [02] Ordem
	'Titulo.', ;			            // [03] Titulo
	'Titulo.', ;			            // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	NIL, ;                          // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	NIL, ;      				    // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

    oStructViewCabec:AddField( ;
	'Parcela', ;	  		            // [01] Campo
	'005', ;   			            // [02] Ordem
	'Parcela.', ;			            // [03] Titulo
	'Parcela.', ;			            // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	NIL, ;                          // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	NIL, ;      				    // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

    oStructViewCabec:AddField( ;
	'Tipo', ;	  		            // [01] Campo
	'006', ;   			            // [02] Ordem
	'Tipo.', ;			            // [03] Titulo
	'Tipo.', ;			            // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	NIL, ;                          // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	NIL, ;      				    // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

    oStructViewCabec:AddField( ;
	'Nat', ;	  		            // [01] Campo
	'007', ;   			            // [02] Ordem
	'Natureza.', ;			            // [03] Titulo
	'Natureza.', ;			            // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	NIL, ;                          // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	NIL, ;      				    // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

    oStructViewCabec:AddField( ;
	'Porta', ;	  		            // [01] Campo
	'008', ;   			            // [02] Ordem
	'Portador.', ;			            // [03] Titulo
	'Portador.', ;			            // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	NIL, ;                          // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	NIL, ;      				    // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

    oStructViewCabec:AddField( ;
	'Fornec', ;	  		            // [01] Campo
	'009', ;   			            // [02] Ordem
	'Fornecedor.', ;			            // [03] Titulo
	'Fornecedor.', ;			            // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	NIL, ;                          // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	NIL, ;      				    // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

    oStructViewCabec:AddField( ;
	'NomeFor', ;	  		            // [01] Campo
	'010', ;   			            // [02] Ordem
	'Nome Fornecedor.', ;			            // [03] Titulo
	'Nome Fornecedor.', ;			            // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	NIL, ;                          // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	NIL, ;      				    // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

    oStructViewCabec:AddField( ;
	'Loja', ;	  		            // [01] Campo
	'011', ;   			            // [02] Ordem
	'Loja.', ;			            // [03] Titulo
	'Loja.', ;			            // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	NIL, ;                          // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	NIL, ;      				    // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

    oStructViewCabec:AddField( ;
	'Loja', ;	  		            // [01] Campo
	'011', ;   			            // [02] Ordem
	'Loja.', ;			            // [03] Titulo
	'Loja.', ;			            // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	NIL, ;                          // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	NIL, ;      				    // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

    oStructViewCabec:AddField( ;
	'Emissao', ;	  		            // [01] Campo
	'012', ;   			            // [02] Ordem
	'Data de Emissao.', ;			            // [03] Titulo
	'Data de Emissao.', ;			            // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	NIL, ;                          // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	NIL, ;      				    // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

    oStructViewCabec:AddField( ;
	'Vencim', ;	  		            // [01] Campo
	'013', ;   			            // [02] Ordem
	'Vencimento.', ;			            // [03] Titulo
	'Vencimento.', ;			            // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	NIL, ;                          // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	NIL, ;      				    // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

    oStructViewCabec:AddField( ;
	'Valor', ;	  		            // [01] Campo
	'014', ;   			            // [02] Ordem
	'Valor.', ;			            // [03] Titulo
	'Valor.', ;			            // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	NIL, ;                          // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	NIL, ;      				    // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

    oStructViewCabec:AddField( ;
	'Saldo', ;	  		            // [01] Campo
	'015', ;   			            // [02] Ordem
	'Saldo.', ;			            // [03] Titulo
	'Saldo.', ;			            // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	NIL, ;                          // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	NIL, ;      				    // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual

	oStructViewCabec:AddField( ;
	'Usuario', ;	  		            // [01] Campo
	'016', ;   			            // [02] Ordem
	'Usuario Inclusao', ;			            // [03] Titulo
	'Usuario que lancou o Titulo', ;			            // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	NIL, ;                          // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	NIL, ;      				    // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual


    oStructViewCabec:AddField( ;
	'Entrada', ;	  		            // [01] Campo
	'017', ;   			            // [02] Ordem
	'Data de Entrada.', ;			            // [03] Titulo
	'Entrada.', ;			            // [04] Descricao
	NIL, ;    				        // [05] Help
	'GET', ;   			            // [06] Tipo do campo COMBO, Get ou CHECK
	NIL, ;                          // [07] Picture
	NIL, ;     			            // [08] PictVar
	'', ;     				        // [09] F3
	.F., ;    				        // [10] Editavel
	NIL, ;    				        // [11] Folder
	NIL, ;    				        // [12] Group
	NIL, ;    				        // [13] Lista Combo
	NIL, ;      				    // [14] Tam Max Combo
	'', ;     				        // [15] Inic. Browse
	.T.)      				        // [16] Virtual



Return oStructViewCabec
