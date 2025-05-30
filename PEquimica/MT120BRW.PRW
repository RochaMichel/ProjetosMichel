#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"

// Fun��o principal que adiciona a rotina de altera��o "Alteracao PQ" ao sistema
User Function MT120BRW()
	// Adiciona a rotina no array de rotinas com a fun��o associada U_UPDSC7
	AAdd(aRotina, {'Alteracao PQ', 'U_UPDSC7', 0, 4})
	AAdd(aRotina, {'Eliminar Residuo', 'U_ELIMRESI', 0, 4})
Return

// Fun��o para realizar a altera��o de itens em um pedido
User Function ELIMRESI()
MATA235()
Return
User Function UPDSC7()

	// Defini��o de vari�veis locais e inicializa��es
	Local aButtons as array // Array de bot�es para a interface
	Local cTudoOk := "U_SC7TDOK()" // Fun��o de valida��o de todos os campos
	Local cLinhaOk := "U_SC7LIOK()" // Fun��o de valida��o de cada linha
	Local oDlg // Di�logo da interface
	Local cPedido // Vari�vel que guarda o n�mero do pedido
	Local cFieldEdit := SuperGetMV("MV_XCPCTBL",,"C7_DESCRI;C7_PRODUTO;C7_PRECO;C7_XSAVING") // Campos edit�veis
	Local cStdCpo := "C7_ITEM;C7_PRODUTO;C7_DESCRI;C7_PRECO;C7_QUANT;C7_TOTAL;C7_NUM;C7_SEQUEN;C7_XSAVING" // Campos padrao a serem exibidos no grid
	Local aStdCpo := StrTokArr(cStdCpo, ',;|.\/:') // Converte a string de campos em um array
	Local cCampos := SuperGetMV("MV_XCPOC7U",,"C7_ITEM;C7_PRODUTO;C7_DESCRI;C7_PRECO;C7_QUANT;C7_TOTAL;C7_NUM;C7_SEQUEN;C7_XSAVING") // Campos a serem exibidos no grid
	Local aCampos := StrTokArr(cCampos, ',;|.\/:') // Converte a string de campos em um array
	Local nCont := 0 // Contador para loops
	Local aAux := {} // Array auxiliar

	// Defini��o de vari�veis privadas e de controle de posi��o
	Private aCols2 := {} as array
	Private aHeader2 := {} as array
	Private aFieldEdit  := StrTokArr(cFieldEdit, ',;|.\/:') // Array com os campos edit�veis
	Private oGetPer
	Private oLista // Controle da lista do grid
	Private lConfirma := .F. // Flag para confirmar a altera��o
	Private nPosItem := 0, nPosProduto := 0, nPosDescri := 0, nPosPreco := 0, nPosQuant := 0, nPosTotal := 0, nPosNum := 0, nPosSequen := 0

	For nCont := 1 To Len(aCampos)
		If AScan(aStdCpo, {|x| x == aCampos[nCont]}) == 0
			aAdd(aStdCpo, aCampos[nCont])
		EndIf
	Next

	aCampos := aStdCpo

	// Atribui o n�mero do pedido � vari�vel cPedido
	cPedido := SC7->C7_NUM

	// Inicia uma consulta SQL para buscar os itens do pedido SC7
	BEGINSQL Alias "TSC7"
        SELECT SC7.*
        FROM %table:SC7% SC7
        WHERE SC7.C7_FILIAL = %xFilial:SC7%
              AND SC7.C7_NUM = %exp:cPedido%
              AND SC7.C7_QUJE = 0
              AND SC7.D_E_L_E_T_ = ' '
	ENDSQL

	// Monta o array aCols2 com os dados dos itens do pedido
	While !TSC7->(EOF()) .and. TSC7->C7_NUM == cPedido
		For nCont := 1 To Len(aCampos)
			aAdd(aAux, TSC7->&(aCampos[nCont]))
		Next
		aAdd(aAux, .F.) // Adiciona o flag de edi��o
		AADD(aCols2 , aAux) // Adiciona a linha ao array de colunas
		aAux := {}
		TSC7->(dbSkip()) // Avan�a para o pr�ximo registro
	EndDo
	TSC7->(dbCloseArea()) // Fecha a tabela

	// Monta o cabe�alho do grid (aHeader2) com base nos campos
	aHeader2 := {}
	For nCont := 1 To Len(aCampos)
		AADD(aHeader2, {GetSx3Cache(aCampos[nCont],"X3_TITULO"),; // T�tulo do campo
		aCampos[nCont],;                           // Nome do campo
		GetSx3Cache(aCampos[nCont],"X3_PICTURE"),; // Formata��o
		GetSx3Cache(aCampos[nCont],"X3_TAMANHO"),; // Tamanho
		GetSx3Cache(aCampos[nCont],"X3_DECIMAL"),; // Casas decimais
		"U_SC7CPOK('"+aCampos[nCont]+"')",;        // Fun��o de valida��o de campo
		GetSx3Cache(aCampos[nCont],"X3_USADO"),;   // Indica se o campo � usado
		GetSx3Cache(aCampos[nCont],"X3_TIPO"),;    // Tipo de campo
		GetSx3Cache(aCampos[nCont],"X3_F3"),;      // Fun��o associada
		GetSx3Cache(aCampos[nCont],"X3_CONTEXT")}) // Contexto do campo
	Next

	// Identifica as posi��es dos campos principais no array de cabe�alhos
	nPosItem := aScan(aHeader2, {|x| x[2] == "C7_ITEM"})
	nPosProduto := aScan(aHeader2, {|x| x[2] == "C7_PRODUTO"})
	nPosDescri := aScan(aHeader2, {|x| x[2] == "C7_DESCRI"})
	nPosPreco := aScan(aHeader2, {|x| x[2] == "C7_PRECO"})
	nPosQuant := aScan(aHeader2, {|x| x[2] == "C7_QUANT"})
	nPosTotal := aScan(aHeader2, {|x| x[2] == "C7_TOTAL"})
	nPosNum := aScan(aHeader2, {|x| x[2] == "C7_NUM"})
	nPosSequen := aScan(aHeader2, {|x| x[2] == "C7_SEQUEN"})

	// Cria a interface de di�logo para a edi��o dos itens
	oDlg := MSDIALOG():New(000,000,500,1000, "Altera��o - PEDIDO: " + cPedido,,,,,CLR_BLACK,,,,.T.)
	oLista := MsNewGetDados():New(035, 003, 230, 501, GD_UPDATE, cLinhaOk, cTudoOk, "AllwaysTrue", aFieldEdit,0, 5, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeader2, aCols2)
	oLista:oBrowse:blDblClick := {|| oLista:EditCell()}

	// Configura os bot�es do di�logo e sua intera��o
	oDlg:bInit := {|| EnchoiceBar(oDlg, {|| lConfirma := .T., If(!oLista:TudoOk(),lConfirma := .F.,oDlg:End())}, {|| oDlg:End()},,@aButtons)}
	oDlg:lCentered := .T.
	oDlg:Activate()

	// Se o usu�rio confirmou as altera��es, processa as mudan�as
	If lConfirma
		For nCont := 1 To Len(oLista:aCols)
			// Obt�m os valores editados de cada item
			cCntItem := oLista:aCols[nCont, nPosItem]
			cCntProduto := oLista:aCols[nCont, nPosProduto]
			cCntDescri := oLista:aCols[nCont, nPosDescri]
			cCntPreco := oLista:aCols[nCont, nPosPreco]
			cCntQuant := oLista:aCols[nCont, nPosQuant]
			cCntTotal := oLista:aCols[nCont, nPosTotal]
			cCntNum := oLista:aCols[nCont, nPosNum]
			cCntSequen := oLista:aCols[nCont, nPosSequen]

			// Monta a chave para localizar o item
			cChave := cCntNum + cCntItem + cCntSequen
			SC7->(DbSetOrder(1)) // Define a ordem de busca na tabela SC7
			If SC7->(MsSeek(FwXFilial("SC7") + cChave))
				Reclock("SC7") // Trava o registro para edi��o
				// Atualiza os campos com os novos valores
				REPLACE C7_PRODUTO WITH cCntProduto
				REPLACE C7_DESCRI WITH cCntDescri
				REPLACE C7_PRECO WITH cCntPreco
				REPLACE C7_TOTAL WITH cCntTotal
				SC7->(MsUnlock()) // Destrava o registro
			EndIf
		Next
	EndIf

Return

// Fun��o de valida��o final, usada para verificar se todos os campos est�o corretos
User Function SC7TDOK()
	Local lRet := .T.
	// Exemplo de l�gica de valida��o comentada
	// Local nX := 0
	// Local lErro := .F.

	// For nX := 1 To Len(aCols2)
	//     If oLista:aCols[nX,4] > aCols2[nX, 4]
	//         Alert("O pre�o s� pode ser atualizado para baixo!")
	//         lErro := .T.
	//     EndIf
	// Next

	// If lErro
	//     lRet := .F.
	// EndIf
Return lRet

// Fun��o de valida��o de cada linha, usada no grid
User Function SC7LIOK()
	Local lRet := .T.
	Local lErro := .F.
	Local nLinha := oLista:nAt

	// Verifica se o pre�o foi aumentado, o que n�o � permitido
	If oLista:aCols[nLinha,nPosPreco] > aCols2[nLinha, nPosPreco]
		FwAlertError("O pre�o s� pode ser atualizado para baixo!", "Pre�o Inv�lido")
		lErro := .T.
	EndIf

	// Se houve erro, n�o permite continuar
	If lErro
		lRet := .F.
	EndIf
	GetdRefresh() // Atualiza a interface
Return lRet

// Fun��o de valida��o de campos espec�ficos durante a edi��o
User Function SC7CPOK(cCampo)
	Local nLinha := oLista:nAt
	Local cPrdAnt := aCols2[nLinha,nPosProduto]
	Local cCpoMem := &(ReadVar()) // Valor do campo em edi��o
	Local lRet := .T.
	Local lErro := .F.

	// Valida��es espec�ficas para o campo C7_PRODUTO
	If cCampo == "C7_PRODUTO"
		If ExistCPO("SB1", cCpoMem, 1)
			oLista:aCols[nLinha,nPosDescri] := ALLTRIM(POSICIONE("SB1", 1, FwXFilial("SB1") + cCpoMem, "B1_DESC"))
		Else
			lErro := .T.
		EndIf

		// Verifica se os produtos pertencem ao mesmo grupo
		If !lErro
			If SubStr(cPrdAnt, 4, 3) != SubStr(cCpoMem, 4, 3)
				FwAlertError("Apenas produtos que pertencem ao mesmo grupo podem substituir um ao outro", "Erro")
				lErro := .T.
			EndIf
		EndIf
	EndIf

	// Valida��o espec�fica para o campo C7_PRECO
	If cCampo == 'C7_PRECO'
		If cCpoMem > aCols2[nLinha,nPosPreco]
			FwAlertError("O pre�o s� pode ser atualizado para baixo!", "Pre�o Inv�lido")
			lErro := .T.
		EndIf
	EndIf

	// Se houver erro, retorna falso
	If lErro
		lRet := .F.
	EndIf
	GetdRefresh() // Atualiza a interface
Return lRet
