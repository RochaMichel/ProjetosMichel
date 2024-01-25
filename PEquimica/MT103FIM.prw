#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT103FIM
O ponto de entrada MT103FIM encontra-se no final da fun��o A103NFISCAL.
Ap�s o destravamento de todas as tabelas envolvidas na grava��o do documento de entrada, 
depois de fechar a opera��o realizada neste.
� utilizado para realizar alguma opera��o ap�s a grava��o da NFE
@type function
@author TOTVS NORDESTE, Izaias Arruda
@since 1/2024
@return variant, NULO
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6085406
/*/
User Function MT103FIM()

    Local nOpcao := PARAMIXB[1]   // Op��o Escolhida pelo usuario no aRotina 
    Local nConfirma := PARAMIXB[2]   // Se o usuario confirmou a opera��o de grava��o da NFECODIGO DE APLICA��O DO USUARIO

    /*/izaias arruda, nOp��o
	1 "Pesquisar"
	2 "Visualizar"
	3 "Incluir"
	4 "Classificar"
	5 "Excluir"
	/*/

    If nConfirma != 0 //se n�o cancelou
		If (nOpcao == 4 .or. nOpcao == 3).and. SF1->F1_TIPO <> 'D' 
			/*verifcar se a NF informada est� na tabela de pesagens. Caso positivo comparar os pesos. 
            Caso haja diferen�a, marcar pesagem.
            incluido na customiza��o de integra��o com a balan�a*/
            MarkPesagem()
		EndIf
	EndIf

Return

/*/{Protheus.doc} MarkPesagem
fun��o para comparar o peso da NF de entrada em rela��o � pesagem importada da balan�a
tentamos achar o pesagem da balan�a pelo n�mero da NF informado no momento da pesagem.
@type function
@author TOTVS NORDESTE, Izaias Arruda
@since 1/2024
@return variant, NULO
/*/
Static Function MarkPesagem

    Local cAliasTMP := GetNextAlias()
    Local nPerTole := SuperGetMV("MV_XTOLPES",,5)

    BEGINSQL Alias cAliasTMP
    SELECT
        SZ3.Z3_PESOLIQ, SZ3.R_E_C_N_O_ as RECSZ3
    FROM
        %table:SZ3% SZ3
    WHERE
        SZ3.Z3_FILIAL = %xFilial:SZ3% AND 
        SZ3.Z3_NF = %Exp:SF1->F1_DOC% AND
        SZ3.%notdel%
    ENDSQL

    If !(cAliasTMP)->(EOF())
        /*calcula a toler�ncia de diferen�a do peso*/
        nTolerancia := (cAliasTMP)->Z3_PESOLIQ * nPerTole / 100 /*calcula a toler�ncia de diferen�a do peso*/
        nMenor := (cAliasTMP)->Z3_PESOLIQ - nTolerancia
		nMaior := (cAliasTMP)->Z3_PESOLIQ + nTolerancia
        /*testa se a quantidade est� dentro da toler�ncia*/
		If SD1->D1_QUANT >= nMenor .AND. SD1->D1_QUANT <= nMaior
            SZ3->( dbGoTo((cAliasTMP)->RECSZ3) )
            RecLock("SZ3",.F.)
            Replace Z3_PESOF1L	With SD1->D1_QUANT
            msUnLock()
        EndIf
	EndIf

    (cAliasTMP)->(dbCloseArea())

Return
