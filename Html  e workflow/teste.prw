    oTable := FWTemporaryTable():New(GetNextAlias())
	oTable:SetFields(aCampos)
	oTable:Create()
	cArqTrb := oTable:GetAlias()

	(cAliasSQL)->(dbgotop())

	While .not. (cAliasSQL)->(eof())

		(cArqTrb)->(reclock(cArqTrb,.T.)		,;
			Mark 	:= cMarca					,;
			Tabela 	:= (cAliasSQL)->C5_YTABFIB	,;
			Pedido	:= (cAliasSQL)->C5_NUM		,;
			Cliente := (cAliasSQL)->C5_CLIENTE	,;
			Loja	:= (cAliasSQL)->C5_LOJACLI	,;
			Nome	:= (cAliasSQL)->A1_NOME		,;
			msunlock())

		(cAliasSQL)->(dbskip())

	Enddo

	(cAliasSQL)->(dbclosearea())

	(cArqTrb)->(dbgotop())
