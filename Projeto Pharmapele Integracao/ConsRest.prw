#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'


*+-------------------------------------------------------------------------+
*|Funcao      | ConsRest()                                                 |
*+------------+------------------------------------------------------------+
*|Autor       | Rivaldo Jr. ( Cod.ERP Tecnologia LTDA )                    |
*+------------+------------------------------------------------------------+
*|Data        | 29/09/2023                                                 |
*+------------+------------------------------------------------------------|
*|Descricao   | Consome API para geração do link de pagamento              |
*+------------+------------------------------------------------------------+
*|Solicitante | Setor financeiro                                           |
*+------------+------------------------------------------------------------+
*|Partida     | REST                                                       |
*+------------+------------------------------------------------------------+

User Function ConsRest(nValor, lGeraNov, nParc )
    Local lGerou  := .F.
    Local aDados  := {}
    Default nParc := '1'

    * VERIFICO QUAL BANCO FOI SELECIONADO PARA GERAR O LINK *
    Do Case
        Case Iif(lGeraNov,ZLP->ZLP_BANCO,FWFldGet('ZLP_BANCO')) == '1' //CIELO

            aDados := U_Cielo( nValor,nParc )

        Case Iif(lGeraNov,ZLP->ZLP_BANCO,FWFldGet('ZLP_BANCO')) == '2' //SAFRAPAY

            aDados := U_SafraPay( nValor )

        Case Iif(lGeraNov,ZLP->ZLP_BANCO,FWFldGet('ZLP_BANCO')) == '3' //PAGSEGURO

            ** MONTAR AS ESPECIFICAÇÕES SOLICITADAS PARA CONSUMO DA API PAGSEGURO **

    EndCase

    If Len(aDados) > 1 // Grava o link no campo do cabeçalho
        
        lGerou := .T.
        ZLP->(RecLock('ZLP', .F.))
            ZLP->ZLP_IDLINK := aDados[1]
            ZLP->ZLP_LINKPG := aDados[2]
            ZLP->ZLP_HORA   := Time()   
            ZLP->ZLP_STATUS := '1'      
        ZLP->(MsUnlock())

    EndIf

Return lGerou



