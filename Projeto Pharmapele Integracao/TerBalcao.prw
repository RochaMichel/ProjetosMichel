#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

#Define cUrl "http://pharmapeleapps.dynns.com:50465/datasnap/rest/TSM"

/*+------------------------------------------------------------------------+
*|Funcao      | RetTB()                                                    |
*+------------+------------------------------------------------------------+
*|Autor       | Rivaldo Jr. ( Cod.ERP Tecnologia LTDA )                    |
*+------------+------------------------------------------------------------+
*|Data        | 29/09/2023                                                 |
*+------------+------------------------------------------------------------|
*|Descricao   | Consome API para retorno do Terminal Balcão                |
*+------------+------------------------------------------------------------+
*|Solicitante | Setor financeiro                                           |
*+------------+------------------------------------------------------------+
*|Partida     | REST                                                       |
*+------------+-----------------------------------------------------------*/
User Function RetTB(cCodLp)
    Local oRest      As Object
    Local oJson      As Object
    Local cPath      := "/FinalizaOrcamento"
    Local cJsonBody  := ""
    Local cErro      := ""
    Local cTermBalcao:= ""
    Local aHeader    := {"Content-Type: application/json"}
    Local cItensFor  := GetNextAlias()
    Local cItensVar  := GetNextAlias()
    Default cFil     := '2'

	BeginSql Alias cItensFor
        SELECT ZLP_DESCON DESCT, ZLP_FRETE FRETE, ZLK_CODORC, ZLK_SERIE ,  ZLP_CONTCL
        FROM %Table:ZLP% ZLP
        INNER JOIN  %Table:ZLK% ZLK ON ZLK_CODLP = ZLP_CODLP AND ZLK_FILIAL = ZLP_FILIAL 
        WHERE ZLP.R_E_C_N_O_ <> ZLP.R_E_C_D_E_L_  
            AND ZLP_STATUS = '2' 
            AND ZLP_CODLP = %Exp:cCodLp%
            AND ZLK.R_E_C_N_O_ <> ZLK.R_E_C_D_E_L_ 
        ORDER BY ZLK_SERIE
	EndSql

	BeginSql Alias cItensVar
        SELECT ZLL_CODPRD PROD, ZLL_QUANT QUANT ,ZLP_CLIENT
        FROM %Table:ZLP% ZLP
        INNER JOIN  %Table:ZLL% ZLL ON ZLL_CODLP = ZLP_CODLP AND ZLL_FILIAL = ZLP_FILIAL 
        WHERE ZLP.R_E_C_N_O_ <> ZLP.R_E_C_D_E_L_  
            AND ZLP_STATUS = '2' 
            AND ZLP_CODLP = %Exp:cCodLp%
            AND ZLL.R_E_C_N_O_ <> ZLL.R_E_C_D_E_L_ 
        ORDER BY ZLL_ITEM
	EndSql

    If (cItensFor)->(Eof()) .AND. (cItensVar)->(Eof())
        (cItensFor)->(DbCloseArea())
        (cItensVar)->(DbCloseArea())
        Return
    EndIf

    oRest := FWRest():New(cUrl)
    oJson := JSonObject():New()

    cDescont := AllTrim(Transform((cItensFor)->DESCT,"@E 999,999,999.99"))
    cTaxa := AllTrim(Transform((cItensFor)->FRETE,"@E 999,999,999.99"))
    

    cJsonBody:= ' { '
    cJsonBody+= ' 	"TELEFONE":"55'+AllTrim((cItensFor)->ZLP_CONTCL)+'", '
    cJsonBody+= ' 	"PEDIDO":{ '
    cJsonBody+= ' 	    "ORCAMENTOS": [ '
    While (cItensFor)->(!Eof())
        cJsonBody+= ' 		{ '
        cJsonBody+= ' 			"FILORC":"'+cFil+'", '
        cJsonBody+= '  			"NRORC":"'+AllTrim((cItensFor)->ZLK_CODORC)+'", '
        cJsonBody+= '  			"SERIEORC":"'+AllTrim((cItensFor)->ZLK_SERIE)+'", '
        cJsonBody+= '  			"DESCONTO":"0", ' 
        cJsonBody+= '  			"TAXA":"0", '
        (cItensFor)->(DbSkip())
        If (cItensFor)->(!Eof())
            cJsonBody+= ' 		}, '
        Else 
            cJsonBody+= ' 		} '
        EndIf
    End
    cJsonBody+= ' 	                 ], '
    cJsonBody+= ' 	    "VAREJOS": [ '
    While (cItensVar)->(!Eof())
        cJsonBody+= ' 		{ '
        cJsonBody+= ' 			"FILVAR":"'+cFil+'", '
        cJsonBody+= '  			"CODPROD":"'+AllTrim((cItensVar)->PROD)+'", '
        cJsonBody+= '  			"CODCLI":"'+AllTrim((cItensVar)->ZLP_CLIENT)+'", '
        cJsonBody+= '  			"CODFUN":"1", '
        cJsonBody+= '  			"QTD":"'+cValToChar((cItensVar)->QUANT)+'", ' 
        cJsonBody+= '  			"DESCONTO":"0", ' 
        cJsonBody+= '  			"TAXA":"0",' 
        (cItensVar)->(DbSkip())
        If (cItensVar)->(!Eof())
            cJsonBody+= ' 		}, '
        Else 
            cJsonBody+= ' 		} '
        EndIf
    End
    cJsonBody+= ' 	                 ], '
    cJsonBody+= '    "TAXASGLOBAL":{
    cJsonBody+= '    "DESC":"'+cDescont+'",
    cJsonBody+= '    "TXA":"'+cTaxa+'" }
    cJsonBody+= '   }
    cJsonBody+= ' } '

    oRest:setPath(cPath)
    oRest:SetPostParams(cJsonBody)
    oRest:Post(aHeader)
    cErro := oJSon:fromJson(oRest:GetResult())

    If !empty(cErro)
        //MsgStop(cErro,"JSON PARSE ERROR")
        Return
    Endif

    cTermBalcao  := oJson:GetJSonObject('TerminalBalcao')
    If !Empty(cTermBalcao)
        DbSelectArea('ZLP')
        ZLP->(DbSetOrder(1))
        If ZLP->(DbSeek(xFilial('ZLP')+cCodLp))
            ZLP->(RecLock('ZLP', .F.))
                ZLP->ZLP_CODTB := cTermBalcao
            ZLP->(MsUnlock())
        EndIf
    EndIf
    (cItensFor)->(DbCloseArea())
    (cItensVar)->(DbCloseArea())

Return 
