//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#Include "PRTOPDEF.ch"


//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2

// Cores
#Define COR_CINZA   RGB(180, 180, 180)
#Define COR_PRETO   RGB(000, 000, 000)

//Colunas
#Define COL_NUM   0015
#Define COL_EMISSAO   0095
#Define COL_PRODUTO   0095
#Define COL_QUANT   0095

/*/{Protheus.doc} zTstRel
Exemplos de FWMSPrinter
@author Atilio
@since 27/01/2019
@version 1.0
@type function
/*/

User Function etqOP()
    Local aArea := GetArea()
    //Se a pergunta for confirmada
    If MsgYesNo("Deseja gerar as etiquetas das OPs?", "Aten��o") 
        Processa({|| fMontaRel()}, "Processando...")
    EndIf

    RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fMontaRel                                                    |
 | Desc:  Função que monta o relatório                              |
 *---------------------------------------------------------------------*/

Static Function fMontaRel()
    Local aArea
    Local cCaminho    := ""
    Local cArquivo    := ""
    Local cQryAux     := ""
    Local nAtual      := 0
    Local nTotal      := 0
    //Linhas e colunas
    Private nLinAtu   := 000
    Private nTamLin   := 010
    Private nLinFin   := 820
    Private nColIni   := 010
    Private nColFin   := 550
    Private nColMeio  := (nColFin-nColIni)/2
    //Objeto de Impressão
    Private oPrintPvt
    //Variáveis auxiliares
    Private dDataGer  := Date()
    Private cHoraGer  := Time()
    Private nPagAtu   := 1
    Private cNomeUsr  := UsrRetName(RetCodUsr())
    //Fontes
    Private cNomeFont := "Arial"
    Private oFontDet  := TFont():New(cNomeFont, 9, 160, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontLeg  := TFont():New(cNomeFont, 9, 22, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontDetN := TFont():New(cNomeFont, 9, 20, .T., .T., 5, .T., 5, .T., .F.)
    Private oFontRod  := TFont():New(cNomeFont, 9, -08, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontTit  := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)

    //Definindo o diretório como a temporária do S.O. e o nome do arquivo com a data e hora (sem dois pontos)
    cCaminho  := GetTempPath()
    cArquivo  := "zTstRel_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-')

    //Criando o objeto do FMSPrinter
    oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., "", .T., , @oPrintPvt, "", , , , .T.)

    //Setando os atributos necessários do relatório
    oPrintPvt:SetResolution(72)
    oPrintPvt:SetLandScape()
    oPrintPvt:SetMargin(60, 60, 60, 60)

    //Imprime o cabeçalho
    fImpCab()

    //Montando a consulta
    cQryAux := " SELECT "                                       + CRLF
    cQryAux += "     C2_NUM, "                                  + CRLF
    cQryAux += "     C2_EMISSAO, "                              + CRLF
    cQryAux += "    C2_PRODUTO, "                               + CRLF
    cQryAux += "    C2_QUANT, "                                  + CRLF
    cQryAux += "    C2_UM"                                  + CRLF
    cQryAux += " FROM "                                         + CRLF
    cQryAux += "     " + RetSQLName('SC2') + " SC2 "            + CRLF
    cQryAux += " WHERE "                                        + CRLF 
    cQryAux += "     C2_FILIAL = '" + FWxFilial('SC2') + "' "   + CRLF
    cQryAux += "     AND SC2.D_E_L_E_T_ = ' ' "                 + CRLF
    cQryAux += " ORDER BY "                                     + CRLF
    cQryAux += "     C2_NUM "                                 + CRLF
    TCQuery cQryAux New Alias "QRY_SC2"

    //Conta o total de registros, seta o tamanho da régua, e volta pro topo
    Count To nTotal
    ProcRegua(nTotal)
    QRY_SC2->(DbGoTop())
    nAtual := 0

    //Enquanto houver registros
    While ! QRY_SC2->(EoF())
        nAtual++
        IncProc("Imprimindo grupo " + QRY_SC2->C2_NUM + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")

        //Se a linha atual mais o espaço que será utilizado forem maior que a linha final, imprime rodapé e cabeçalho
        If nLinAtu + nTamLin > nLinFin
            fImpRod()
            fImpCab()
        EndIf

        aArea := SB1->(GetArea())
        DbSelectArea("SB1")
        SB1->(DbSetOrder(1)) //Posiciona no indice 1
        SB1->(DbGoTop())

        /*  18/10/2023 --- Carolina Tavares
            Posiciona o item para obter a descri��o e exibir na etiqueta
        */
        cProdDesc := rtrim(capital(Posicione("SB1",1,FWxFilial("SB1") + QRY_SC2->C2_PRODUTO,"B1_DESC")))

        RestArea(aArea)

        //Imprimindo a linha atual
        oPrintPvt:SayAlign(nLinAtu+180, 0180, QRY_SC2->C2_NUM, oFontDet, 0800, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+420, 0075, "Data: "+ dToC(dDataGer) , oFontLeg, 0200, nTamLin+10, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+420, 0320, "Hora: "+ cHoraGer , oFontLeg, 0200, nTamLin+10, COR_PRETO, PAD_LEFT, 0)
        //oPrintPvt:SayAlign(nLinAtu+420, 0525, "Item: "+QRY_SC2->C2_PRODUTO, oFontLeg, 0200, nTamLin+10, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+420, 0525, "Item: "+cProdDesc, oFontLeg, 0200, nTamLin+10, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu+480, 0320, "Qtd: "+ CVALTOCHAR(QRY_SC2->C2_QUANT)+ " "+QRY_SC2->C2_UM, oFontLeg, 0200, nTamLin+10, COR_PRETO, PAD_LEFT, 0)

        //nLinAtu += nTamLin
        nLinAtu += nLinFin //18/10/2023 --- Carolina Tavares

        QRY_SC2->(DbSkip())
    EndDo
    QRY_SC2->(DbCloseArea())

    //Se ainda tiver linhas sobrando na página, imprime o rodapé final
    If nLinAtu <= nLinFin
        fImpRod()
    EndIf

    //Mostrando o relatório
    oPrintPvt:Preview()
Return

/*---------------------------------------------------------------------*
 | Func:  fImpCab                                                      |
 | Desc:  Função que imprime o cabeçalho                               |
 *---------------------------------------------------------------------*/
 
Static Function fImpCab()
    Local nLinCab  := 030

    //Iniciando Página
    oPrintPvt:StartPage()

    //Cabeçalho das colunas
    nLinCab += nTamLin
    oPrintPvt:SayAlign(nLinCab+50, 0310, "OP",     oFontDet, 0800, nTamLin, COR_PRETO, PAD_LEFT, 0)


    nLinCab += nTamLin
    //Atualizando a linha inicial do relatório
    nLinAtu := nLinCab + 3
Return

/*---------------------------------------------------------------------*
 | Func:  fImpRod                                                      |
 | Desc:  Função que imprime o rodapé                                  |
 *---------------------------------------------------------------------*/

Static Function fImpRod()
    Local nLinRod   := nLinFin + nTamLin
    //Linha Separatória
    oPrintPvt:Line(nLinRod, nColIni, nLinRod, nColFin, COR_CINZA)

    //Finalizando a página e somando mais um
    oPrintPvt:EndPage()
    nPagAtu++
Return

