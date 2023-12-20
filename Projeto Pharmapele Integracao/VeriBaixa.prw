#Include 'TOTVS.CH'

/*+------------------------------------------------------------------------+
*|Funcao      | VeriBx()                                                   |
*+------------+------------------------------------------------------------+
*|Autor       | Rivaldo Jr. ( Cod.ERP Tecnologia LTDA )                    |
*+------------+------------------------------------------------------------+
*|Data        | 17/10/2023                                                 |
*+------------+------------------------------------------------------------|
*|Descricao   | Baixa o titulo do resgistro do link de pagamento           |
*+------------+------------------------------------------------------------+
*|Solicitante | Setor financeiro                                           |
*+------------+-----------------------------------------------------------*/
User Function VeriBx(aParam)  
    Local cQuery := GetNextAlias()
    Private lAtivAmb := .T.
	// Prepara o ambiente caso precise

	If Select("SX2") == 0
		RPCClearEnv()
		RpcSetType(3)
		RpcSetEnv( aParam[1],aParam[2], , , "",,, , , ,  )
		lAtivAmb := .T. // Seta se precisou montar o ambiente
	Endif

    //Busco todos os registros de links pagos 
    BeginSql Alias cQuery
		SELECT * FROM %Table:ZLP% ZLP
		INNER JOIN %Table:ZLK% ZLK ON ZLK_FILIAL = ZLP_FILIAL AND ZLK_CODLP = ZLP_CODLP
		WHERE ZLP_FILIAL = %xFilial:ZLP% 
			AND ZLP_STATUS = '2' // Link Pago
            AND ZLP_CODTB <> ''
            AND ZLP_IDLINK <> ''
			AND ZLP.%NOTDEL%
			AND ZLK.%NOTDEL%
            ORDER BY ZLP_CODLP
	EndSql

    If (cQuery)->(Eof())
        (cQuery)->(DbCloseArea())
        return
    EndIf

    While (cQuery)->(!Eof())
        BaixaTit((cQuery)->ZLP_CODTB)// Chamo a função para baixar o titulo 
    (cQuery)->(DbSkip())
    End
    (cQuery)->(DbCloseArea())

    If lAtivAmb == .T.
		RpcClearEnv()
	EndIF
Return

/**********************************************************************************
*+-------------------------------------------------------------------------------+*
*|Funcao      | BaixaTit        | Autor |    Rivaldo Jr.  ( Cod.ERP )            |*
*+------------+------------------------------------------------------------------+*
*|Data        | 29.09.2023                                                       |*
*+------------+------------------------------------------------------------------+*
*|Descricao   | Funcao para baixar o titulo de um link de pagamento              |*
*+------------+------------------------------------------------------------------+*
*|Parâmetro   | Necessita do código do terminal balcão                           |*
**********************************************************************************/
Static Function BaixaTit(cCodBalcao)
    Local aArea  := GetArea()
    Local cQrySE1:= GetNextAlias()
    Local aiErro := {}
    Local nS     := 0
    Local ciErro := ''
    Private lMsHelpAuto	   := .T.   
	Private lAutoErrNoFile := .T.

    //Busco todos os registros de links pagos 
    BeginSql Alias cQrySE1
		SELECT * FROM %Table:SE1% SE1
		WHERE SE1_FILIAL = %xFilial:SE1% 
            AND E1_CODTB = %EXP:cCodBalcao%
			AND SE1.%NOTDEL%
	EndSql

    DbSelectArea('SE1')
    SE1->(DbSetOrder(1))
    cFilArq := cFilAnt
	While (cQrySE1)->(!eOF()) 
        If SE1->(DbSeek((cQrySE1)->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
            cFilAnt := SE1->E1_FILIAL

            _aCabec :=	{{"E1_FILIAL"   , SE1->E1_FILIAL 	  , Nil},;
                        {"E1_PREFIXO"   , SE1->E1_PREFIXO	  , Nil},;
                        {"E1_NUM"       , SE1->E1_NUM    	  , Nil},;
                        {"E1_TIPO"      , SE1->E1_TIPO   	  , Nil},;
                        {"E1_PARCELA"   , SE1->E1_PARCELA	  , Nil},;
                        {"AUTMOTBX"     , "NOR"       		  , Nil},;
                        {"AUTBANCO"     , SE1->E1_COD         , Nil},;
                        {"AUTAGENCIA"   , SE1->E1_AGENCIA     , Nil},;
                        {"AUTCONTA"     , SE1->E1_NUMCON      , Nil},;
                        {"AUTDTBAIXA"   , CtoD(cDate)		  , Nil},;
                        {"AUTDTCREDITO" , CtoD(cDate)		  , Nil},;
                        {"AUTHIST" 		, cHist				  , Nil},;
                        {"AUTJUROS"     , 0    				  , Nil},;
                        {"AUTDESCONT"   , 0 				  , Nil},;
                        {"AUTVALREC"    , SE1->E1_SALDO       , Nil}}

            Begin Transaction		
                MSExecAuto({|x,y| FINA070(x,y)},_aCabec,3) //3-Inclusao

                IF lMsErroAuto
                    aiErro := GetAutoGRLog()
                    For nS:=1 To Len(aiErro)
                        ciErro += aiErro[nS] + Chr(13)+Chr(10)
                    Next
                    DisarmTransaction()
                Endif
            End Transaction

        EndIf
        (cQrySE1)->(DbSkip()) 
    End
    (cQrySE1)->(DbCloseArea())
    cFilAnt := cFilArq
    RestArea(aArea)
Return
