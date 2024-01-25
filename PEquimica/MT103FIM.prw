#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT103FIM
O ponto de entrada MT103FIM encontra-se no final da função A103NFISCAL.
Após o destravamento de todas as tabelas envolvidas na gravação do documento de entrada, 
depois de fechar a operação realizada neste.
É utilizado para realizar alguma operação após a gravação da NFE
@type function
@author TOTVS NORDESTE, Izaias Arruda
@since 1/2024
@return variant, NULO
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6085406
/*/
User Function MT103FIM()

    Local nOpcao := PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina 
    Local nConfirma := PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFECODIGO DE APLICAÇÃO DO USUARIO

    /*/izaias arruda, nOpção
	1 "Pesquisar"
	2 "Visualizar"
	3 "Incluir"
	4 "Classificar"
	5 "Excluir"
	/*/

    If nConfirma != 0 //se não cancelou
		If (nOpcao == 4 .or. nOpcao == 3).and. SF1->F1_TIPO <> 'D' 
			/*verifcar se a NF informada está na tabela de pesagens. Caso positivo comparar os pesos. 
            Caso haja diferença, marcar pesagem.
            incluido na customização de integração com a balança*/
            MarkPesagem()
		EndIf
	EndIf

Return

/*/{Protheus.doc} MarkPesagem
função para comparar o peso da NF de entrada em relação à pesagem importada da balança
tentamos achar o pesagem da balança pelo número da NF informado no momento da pesagem.
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
        /*calcula a tolerância de diferença do peso*/
        nTolerancia := (cAliasTMP)->Z3_PESOLIQ * nPerTole / 100 /*calcula a tolerância de diferença do peso*/
        nMenor := (cAliasTMP)->Z3_PESOLIQ - nTolerancia
		nMaior := (cAliasTMP)->Z3_PESOLIQ + nTolerancia
        /*testa se a quantidade está dentro da tolerância*/
		If SD1->D1_QUANT >= nMenor .AND. SD1->D1_QUANT <= nMaior
            SZ3->( dbGoTo((cAliasTMP)->RECSZ3) )
            RecLock("SZ3",.F.)
            Replace Z3_PESOF1L	With SD1->D1_QUANT
            msUnLock()
        EndIf
	EndIf

    (cAliasTMP)->(dbCloseArea())

Return
