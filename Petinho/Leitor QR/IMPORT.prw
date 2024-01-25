#Include 'Protheus.ch'


/*/{Protheus.doc}
Função para importar os dados do arquivo e gravá-los na tabela.
@type   : Static Function
@author : Paulo Felipe Silva (contato@alldevsys.com.br)
@since  : 23/11/2019
@version: 1.00
/*/
User Function ImpFile()
    Local aArea := GetArea()
	Local aFiles	:= {}
	Local nFile		:= 0
	Local cDiretorio := " "
	Local cAlias := ''
    Private lAtivAmb := .F.
	// Prepara o ambiente caso precise
	If Select("SX2") == 0
		RPCClearEnv()
		RpcSetType( 3 )
		RpcSetEnv( "01",'010101', , , "",,, , , ,  )
		lAtivAmb := .T. // Seta se precisou montar o ambiente
	Endif
	cDiretorio := Alltrim(GetMV("MV_XDIREXT",,"C:\FKM\CSV\OK\"))
	cDest := Alltrim(GetMV("MV_XDESEXT",,"C:\FKM\CSV\ENV\"))
	// Coleta todos arquivos da pasta.
	aFiles := Directory(cDiretorio + "*.csv")

	For nFile := 1 To Len(aFiles)
		cAlias := GetNextAlias()
	    FT_FUSE(cDiretorio+aFiles[nFile][1])
		DbSelectArea('SB1')
	    Do While !FT_FEOF()
	    	cBuffer := FT_FREADLN()
	    	aDados := Separa(cBuffer,',',.T.)
			SB1->(DbSetOrder(5))
			If SB1->(DbSeek(xFilial('SB1')+adados[3]))			
				BeginSql Alias cAlias
					Select * From %Table:ZOP% ZOP
					Where ZOP_PROD = %EXP:Alltrim(SB1->B1_COD)%
					AND ZOP.%notdel% 
					AND ZOP_DATA = %EXP:DtoS(dDatabase)%
				EndSql 
				If (cAlias)->(!EOF())
	    			U_ApontaOp(Alltrim((cAlias)->ZOP_NUMOP), GetMV('MV_XQRLEN',,'001'),GetMV('MV_XMAQUI',,'01'), Alltrim((cAlias)->ZOP_LOTE))
				EndIf
			EndIf
	    	FT_FSKIP()
	    Enddo
	    FT_FUSE()
		
		__CopyFile(cDiretorio+aFiles[nFile][1], cDest+aFiles[nFile][1])

		If FERASE(cDiretorio+aFiles[nFile][1]) == -1
			MsgStop('Arquivo original não deletado!')
		Endif
		(cAlias)->(DbCloseArea())
	Next nFile
	RestArea(aArea)
	If lAtivAmb
		RPCClearEnv()
	Endif
Return
