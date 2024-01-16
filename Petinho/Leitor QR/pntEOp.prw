#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'


*******************************************************************************
// Função : | MTelGOps -> Ponto de entrada para validar a geração de OPs      |
// Modulo : ""                                                                |
// Fonte  : pntEOP.prw                                                        |
// ---------+--------------------------+--------------------------------------+
// Data     | Autor             	   | Descricao                            |
// ---------+--------------------------+--------------------------------------+
// 19/10/23 | Carolina Tavares         | Ponto de Entrada   		          |
*******************************************************************************


User Function MTelGOps()

Local aParam   := PARAMIXB
Local xRet     := .T.
Local oObj     := ''
Local cIdPonto := ''
Local cIdModel := ''
Local aRet     := {}
Local aItens   := {}
Local aItem    := {}
Local i        := 0
//Local j        := 0
Local nQuant   := 0
Local nLeitur
Local cProd
Local cNumOp
Local cLote

//cNumOp => SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN

If aParam <> NIL

    oObj       := aParam[1]
    cIdPonto   := aParam[2]
    cIdModel   := aParam[3]

    //Criar campo "ZOP_LEITU" que mostra quantos items foram lidos na esteira
    //Comparar com o campo ZOP_QUANT usando o ponto de entrada
    //Se forem iguais chamar a função apontamento de op.

    If cIdPonto == 'FORMPOS' //Validação total do formulario
    /*  Teste
        Preciso ver se depois de executar o 'GeraOP' eu consigo retornar o numero de OP resultante
        e atualizar o valor no formulário antes da gravação
        Se for possível guardar esse número eu vou poder usá-lo para gerar a MI e o Apontamento
    */
        nOpc    := oObj:GetOperation() //pega a operação


        If cIdModel == 'ZOPMASTER'
            cProd   := OOBJ:ADATAMODEL[1][3][2]//ZOP_PROD
            nQuant  := OOBJ:ADATAMODEL[1][9][2]//ZOP_QUANT
            nLeitur := OOBJ:ADATAMODEL[1][10][2]//ZOP_LEITUR
            cNumOp  := OOBJ:ADATAMODEL[1][12][2]//ZOP_NUMOP
            cLote   := OOBJ:ADATAMODEL[1][13][2]//ZOP_LOTE

        EndIf

        If nOpc == 3 .AND. cIdModel == 'ZOPMASTER' // Inclusão
            Aviso('Atenção', 'Uma nova Ordem de Produção será gerada!', {'OK'}, 03)
            //chama a função U_GeraOp
            aRet := U_GeraOp(cProd, nQuant)
            OOBJ:ADATAMODEL[1][12][2] := aRet[1]
            If EMPTY( aRet ) //validação
                xRet := .F.
            EndIf
        ElseIf nOpc == 4 //alteração
            OOBJ:ADATAMODEL[1][8][2] := TIME()
        EndIf


    ElseIf cIdPonto == 'FORMCOMMITTTSPOS' .AND. cIdModel == "ZOPMASTER"
    
        nOpc    := oObj:GetOperation() //pega a operação

        cNumOp  := OOBJ:OFORMMODEL:AMODELSTRUCT[1][3]:ADATAMODEL[1][12][2]//ZOP_NUMOP
        nQuant  := OOBJ:OFORMMODEL:AMODELSTRUCT[1][3]:ADATAMODEL[1][9][2]//ZOP_QUANT
        nLeitur := OOBJ:OFORMMODEL:AMODELSTRUCT[1][3]:ADATAMODEL[1][10][2]//ZOP_LEITUR
        cLote   := OOBJ:OFORMMODEL:AMODELSTRUCT[1][3]:ADATAMODEL[1][13][2]//ZOP_LOTE

/*         aArea := ZOS->(GetArea())
        DbSelectArea("ZOS")
        ZOS->(DbSetOrder(1)) //Posiciona no indice 1
        ZOS->(DbGoTop())

        cNPro := OOBJ:OFORMMODEL:AMODELSTRUCT[1][3]:ADATAMODEL[1][2][2]
        If ZOS->(dbSeek(FWXFilial("ZOS")+ cNPro))
            While !Eof() .AND. ZOS->(ZOS_FILIAL+ZOS_NPRO) == (FWXFilial("ZOS")+ cNPro)
                aadd(aItens, ZOS->ZOS_PROD)
                aadd(aItens, ZOS->ZOS_QUANT)
                aadd(aItens, ZOS->ZOS_LOTE)
                dbSkip()
                aadd(aItem, aItens)
            EndDo

        EndIf

        RestArea(aArea) */
        For i := 1 to len(OOBJ:ADATAMODEL[2][1][2])
            aItens := {}
            aadd(aItens, OOBJ:ADATAMODEL[2][1][2][i][1][1][4])
            aadd(aItens, OOBJ:ADATAMODEL[2][1][2][i][1][1][6])
            aadd(aItens, OOBJ:ADATAMODEL[2][1][2][i][1][1][7])
            aadd(aItem,aItens)

        next i

        If nOpc == 4 /* alteração */ .AND. nQuant == nLeitur .AND. !EMPTY( aItem );
            .AND. !EMPTY(cNumOp)
        Aviso('Atenção', 'Será gerado o apontamento da OP: ', {'OK'}, 03)
        /*  Gera o MI dos produtos base (formulário) e
            faz o apontamento do produto acabado (cabeçalho)
        */
        xRet := U_GeraMI(aItem, cNumOp, '501')
        //xRet := U_ApontaOp(cNumOp, '001','01', cLote) //precisa de nQuant?
        EndIf

    EndIf
EndIf

Return xRet

