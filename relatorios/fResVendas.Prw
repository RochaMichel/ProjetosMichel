//Bibliotecas
#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#include "TopConn.ch"
#include "COLOR.ch"
#include "COLORS.ch"

#define CLR_SILVER rgb(192,192,192)
#define CLR_LIGHTGRAY rgb(220,220,220)
/////////////////////
/// Ita - 30/08/2022
///     - Função fResVendas
///     - Resumo das Vendas por Produto(Sintético com pontuação do grupo)
///       https://tdn.totvs.com/display/public/framework/TREPORT
//////////////////////////////////////////////////////////////////////////
User Function fResVendas
   Local oReport
   Private _Enter    := chr(13) + Chr(10) 
   Private aOrdem    := {}	
   Private cAliasTop := GetNextAlias()
   Private oRelRVD
   Private _lBold := .F. //Controle de IMpressão em NEgrito
   Private lAutoSize := .T.
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Interface de impressao                                                  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   oReport:= fResVnd()
   oReport:PrintDialog()
Return

Static Function fResVnd()
    cPerg     := "XRELRVD"
    Gera_SX1(cPerg)
    _cTitulo  := "Resumo de Vendas - Por Produto(Sintético com pontuação do grupo)"
    oReport:= TReport():New("fResVendas",_cTitulo,cPerg, {|oReport| ReportPrint(oReport,aOrdem,cAliasTop)},_cTitulo)
    //oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
    //oReport:nFontBody	:= 12 // Define o tamanho da fonte.
    //oReport:nLineHeight	:= 50 // Define a altura da linha.
    oReport:SetLandscape() 

    //Parametriza o TReport para alinhamento a direita 
    oReport:SetRightAlignPrinter(.T.)

    //oReport:CFONTBODY := "Courier New"
    //oReport:NFONTBODY := 10
    //oReport:LBOLD := .T. //Imprime a fonte em negrito
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Criacao da Sessao 1                                          ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    oRelRVD:= TRSection():New(oReport,_cTitulo,{"SD2","SB1","SBM"} ,aOrdem)
    //oRelGrp:= TRSection():New(oReport,_cTitulo,{"SD2","SB1","SBM"} ,aOrdem)

    oRelRVD:SetTotalInLine(.F.)

           //New(oParent,cName             ,cAlias,cTitle,cPicture                       ,nSize                    ,lPixel    ,bBlock                           ,cAlign  ,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize      ,nClrBack  ,nClrFore ,lBold )
    TRCell():New(oRelRVD,'PRODUTO'         ,''    ,      ,PesqPict("SB1", "B1_COD")   ,TamSX3("B1_COD")[1]         ,/*lPixel*/,/*{|| code-block de impressao }*/, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
    TRCell():New(oRelRVD,'DESCRICAO'       ,''    ,      ,PesqPict("SB1", "B1_DESC")  ,40                          ,/*lPixel*/,/*{|| code-block de impressao }*/, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
    TRCell():New(oRelRVD,'Un'              ,''    ,      ,PesqPict("SB1", "B1_UM")    ,TamSX3("B1_UM")[1]          ,/*lPixel*/,/*{|| code-block de impressao }*/, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
    TRCell():New(oRelRVD,'QTD'             ,''    ,      ,"@E 9,999,999,999.99"       ,TamSX3("D2_QUANT")[1]       ,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
    TRCell():New(oRelRVD,'COEF_PROD'       ,''    ,      ,"@E 9,999,999,999.99"       ,TamSX3("B1_XCOEFI")[1]      ,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
    TRCell():New(oRelRVD,'Vol. Vend.'      ,''    ,      ,"@E 9,999,999,999.99"       ,TamSX3("D2_TOTAL")[1]       ,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
    TRCell():New(oRelRVD,'FATURAMENTO'     ,''    ,      ,"@E 9,999,999,999.99"       ,TamSX3("D2_TOTAL")[1]       ,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
    TRCell():New(oRelRVD,'R$ Medio'        ,''    ,      ,"@E 9,999,999,999.99"       ,TamSX3("D2_TOTAL")[1]       ,/*lPixel*/,/*{|| code-block de impressao }*/, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)

    /*
    oRelRVD:SetPageBreak(.F.)
    oRelRVD:SetLineBreak(.F.)
    oRelRVD:SetHeaderPage(.F.)
    oRelRVD:SetTotalInLine(.F.)
    oRelRVD:SetHeaderSection(.F.)
    */

Return(oReport)

Static Function ReportPrint(oReport,aOrdem,cAliasTop)

    Local nPrc, nMs, nX, nFil
    Local cOrderBy  := ''
    Local oRelRVD	:= oReport:Section(1)
    Local cIndexkey	:= ''
    Local nOrdem   	:= oRelRVD:GetOrder()
    Local cFilUser  := oReport:Section(1):GetAdvplExp()
        

    Private cFilSD2User := oRelRVD:GetSqlExp("SD2")
    Private cFilSB1User := oRelRVD:GetSqlExp("SB1")
    Private cFilSBMUser := oRelRVD:GetSqlExp("SBM")

    Pergunte(oReport:uParam,.F.)
    //MakeSqlExpr(oReport:uParam)
    MakeSqlExpr(oReport:GetParam())

    _DaData  := MV_PAR01
    _AteData := MV_PAR02
    _DoProd  := MV_PAR03
    _AtProd  := MV_PAR04
    _DoGrupo := MV_PAR05
    _AtGrupo := MV_PAR06
    _cDaFil  := MV_PAR07
    _cAteFil := MV_PAR08

    oReport:cTitle := "Relatório de Resumo das Vendas de "+dToc(_DaData)+" até "+dToc(_AteData)

    oReport:NFONTBODY:=08//09//10 //12 // nfontbody:=12 //6 - Altera o tamanho da fonte
    oreport:cfontbody:="Arial"
    
    //oReport:oFontBody:NAME := "Courier New"
    //oReport:oFontBody:NAME := "Arial"
    
    //oReport:oFontBody:BOLD := .T.
    /*
    oReport:oFontBody:ITALIC := .F.
    oReport:oFontBody:NHEIGHT := -8
    oReport:oFontBody:WIDTH := 0
    oReport:oFontBody:UNDERLINE := .F.
    */

    /*
    aSM0 := FWLoadSM0(.T.)
    aFiliais := {}
    For nX:=1 To Len(aSM0)
        If aSM0[nX][SM0_FILIAL] >= _cDaFil .And. aSM0[nX][SM0_FILIAL] <= _cAteFil //Se estiver dentro da faixa de filiais informadas nos parâmetros
            aAdd(aFiliais, {aSM0[nX][SM0_FILIAL],aSM0[nX][SM0_NREDUZ]})
        EndIf
    Next nX
    */
    
    
    For nPrc := 1 To 2
        
        If nPrc == 1
            cQrySED := " SELECT COUNT(*) XQTDREG " + _Enter
            cQrySED += "        FROM ( SELECT SD2.D2_FILIAL,SD2.D2_GRUPO,SD2.D2_COD,SB1.B1_DESC,SD2.D2_UM,SB1.B1_XCOEFI,SBM.BM_TPGRP,SUM(SD2.D2_QUANT) D2_QUANT,SUM(SD2.D2_TOTAL) D2_TOTAL " + _Enter
        Else
            cQrySED := " SELECT SD2.D2_FILIAL,SD2.D2_GRUPO,SD2.D2_COD,SB1.B1_DESC,SD2.D2_UM,SB1.B1_XCOEFI,SBM.BM_TPGRP,SUM(SD2.D2_QUANT) D2_QUANT,SUM(SD2.D2_TOTAL) D2_TOTAL " + _Enter
        EndIf
        
        cQrySED += "   FROM "+RetSQLName("SD2")+" SD2, "+RetSQLName("SB1")+" SB1, "+RetSQLName("SBM")+" SBM " + _Enter
        //cQrySED += "  WHERE SED.ED_FILIAL BETWEEN '"+_cDaFil+"' AND '"+_cAteFil+"' " + _Enter
        cQrySED += "  WHERE SD2.D2_FILIAL BETWEEN '"+_cDaFil+"' AND '"+_cAteFil+"' " + _Enter
        cQrySED += "    AND SD2.D2_FILIAL = SB1.B1_FILIAL " + _Enter
        cQrySED += "    AND SD2.D2_FILIAL = SBM.BM_FILIAL " + _Enter
        cQrySED += "    AND SD2.D2_EMISSAO BETWEEN '"+DTOS(_DaData)+"' AND '"+DTOS(_AteData)+"' " + _Enter
        cQrySED += "    AND SD2.D2_COD BETWEEN '"+_DoProd+"' AND '"+_AtProd+"' " + _Enter
        cQrySED += "    AND SD2.D2_GRUPO BETWEEN '"+_DoGrupo+"' AND '"+_AtGrupo+"' " + _Enter

        cQrySED += "    AND SD2.D2_COD = SB1.B1_COD" + _Enter
        cQrySED += "    AND SD2.D2_GRUPO = SBM.BM_GRUPO" + _Enter

        cQrySED += "    AND SD2.D_E_L_E_T_ <> '*' " + _Enter
        cQrySED += "    AND SB1.D_E_L_E_T_ <> '*' " + _Enter
        cQrySED += "    AND SBM.D_E_L_E_T_ <> '*' " + _Enter

        If !Empty(cFilSD2User)
            cQry += " AND ( "+cFilSD2User + " ) " + _Enter
        Endif   

        If !Empty(cFilSB1User)
            cQry += " AND ( "+cFilSB1User + " ) " + _Enter
        Endif   

        If !Empty(cFilSBMUser)
            cQry += " AND ( "+cFilSBMUser + " ) " + _Enter
        Endif   

        cQrySED += " GROUP BY SD2.D2_FILIAL,SD2.D2_GRUPO,SD2.D2_COD,SB1.B1_DESC,SD2.D2_UM,SB1.B1_XCOEFI,SBM.BM_TPGRP " + _Enter

        If nPrc == 1
            cQrySED += " ) TAB " + _Enter
        EndIf

        If nPrc > 1
            cQrySED += " ORDER BY SD2.D2_FILIAL, SD2.D2_GRUPO ASC " + _Enter
        EndIf

        MemoWrite("C:\TEMP\fResVendas.SQL",cQrySED)
        MemoWrite("fResVendas.SQL",cQrySED)

        TCQuery cQrySED NEW ALIAS "RVENDAS"

        If nPrc == 1

            TCSetField("RVENDAS","XQTDREG","N",10,00)
            DbSelectArea("RVENDAS")
            nRegPrc := RVENDAS->XQTDREG
            DbCloseArea()

        Else
            //TCSetField("RVENDAS","D2_EMISSAO","D",08,00)
            TCSetField("RVENDAS","D2_TOTAL","N",TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2])
            TCSetField("RVENDAS","D2_QUANT","N",TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2])
            TCSetField("RVENDAS","B1_XCOEFI","N",TamSX3("B1_XCOEFI")[1],TamSX3("B1_XCOEFI")[2])
        EndIf

    Next nPrc

    oReport:SetMeter(nRegPrc) //-> Indica quantos registros serao processados para a regua ³  
    nTtQtd := 0
    nTtCoe := 0
    nTtFat := 0
    nMdCUn := 0
    nQtdPr := 0
    nCt := 1
    //oCouOld08N	:= TFont():New("Courier New",,08,,.T.,,,,.T.,.F.)		// Negrito
    Do While !oReport:Cancel() .And. !RVENDAS->(Eof())

        oReport:IncMeter()
        oRelRVD:Init()
        //oRelRVD:oReport:CMSGPRINT := "Calculando registros ... "+CValToChar(nCt)+" / "+CValToChar(nRegPrc)
        oReport:SetMsgPrint( "Calculando Faturamento ... "+cValToChar(nCt)+" / "+cValToChar(nRegPrc) )        

        //oRelRVD:oRelRVD:LBOLD := .T. //Imprime a fonte em negrito
        //oRelRVD:oReport:CFONTBODY := "Courier New"
        //oRelRVD:oReport:NFONTBODY := 10

        //nDispSai := oReport:NDEVICE //Número do Dispositivo de saída - 6=PDF

        //Deixar Negrito
        //oRelRVD:Cell('PRODUTO'):lBold := .T.
        //oRelRVD:Cell('DESCRICAO'):lBold:= .T.

        //Cor de Fundo da Célula(nClrBack)

        oRelRVD:Cell('PRODUTO'):nClrBack := CLR_SILVER
        oRelRVD:Cell('DESCRICAO'):nClrBack := CLR_SILVER
        oRelRVD:Cell('Un'):nClrBack := CLR_SILVER
        oRelRVD:Cell('QTD'):nClrBack := CLR_SILVER
        oRelRVD:Cell('COEF_PROD'):nClrBack := CLR_SILVER
        oRelRVD:Cell('Vol. Vend.'):nClrBack := CLR_SILVER
        oRelRVD:Cell('FATURAMENTO'):nClrBack := CLR_SILVER
        oRelRVD:Cell('R$ Medio'):nClrBack := CLR_SILVER

        //Cor da Fonte da Célula(nClrFore)
        oRelRVD:Cell('PRODUTO'):nClrFore := CLR_BLACK
        oRelRVD:Cell('DESCRICAO'):nClrFore := CLR_BLACK
        oRelRVD:Cell('Un'):nClrFore := CLR_BLACK
        oRelRVD:Cell('QTD'):nClrFore := CLR_BLACK
        oRelRVD:Cell('COEF_PROD'):nClrFore := CLR_BLACK
        oRelRVD:Cell('Vol. Vend.'):nClrFore := CLR_BLACK
        oRelRVD:Cell('FATURAMENTO'):nClrFore := CLR_BLACK
        oRelRVD:Cell('R$ Medio'):nClrFore := CLR_BLACK

        oRelRVD:Cell('QTD'):SetPicture('@!')
        oRelRVD:Cell('COEF_PROD'):SetPicture('@!')
        oRelRVD:Cell('Vol. Vend.'):SetPicture('@!')
        oRelRVD:Cell('FATURAMENTO'):SetPicture('@!')
        oRelRVD:Cell('R$ Medio'):SetPicture('@!')

        oRelRVD:Cell('PRODUTO'):SetValue('GRUPO: '+RVENDAS->D2_GRUPO)
        _cDescGrp := Alltrim( Posicione("SBM",1,RVENDAS->D2_FILIAL+RVENDAS->D2_GRUPO,"BM_DESC") )
        oRelRVD:Cell('DESCRICAO'):SetValue(_cDescGrp)
        oRelRVD:Cell('Un'):SetValue('')
        oRelRVD:Cell('QTD'):SetValue('')
        oRelRVD:Cell('COEF_PROD'):SetValue('')
        oRelRVD:Cell('Vol. Vend.'):SetValue('')
        oRelRVD:Cell('FATURAMENTO'):SetValue('')
        oRelRVD:Cell('R$ Medio'):SetValue('')

        oRelRVD:Printline()
        oReport:SkipLine() //-- Salta Linha

        cChvGrp := RVENDAS->D2_FILIAL+RVENDAS->D2_GRUPO
        cGrpTip := RVENDAS->BM_TPGRP
        nGrTtQtd := 0
        nGrTtCoe := 0
        nGrTtFat := 0
        nGrMdCUn := 0
        ngrQtdPr := 0
        _lFormCel:= .T.
        While RVENDAS->D2_FILIAL+RVENDAS->D2_GRUPO == cChvGrp .And. !RVENDAS->(Eof())
        
            If _lFormCel

                //Retira Negrito
                _lFormCel:= .F.
                //oRelRVD:Cell('PRODUTO'):lBold := .F.
                //oRelRVD:Cell('DESCRICAO'):lBold:= .F.

                //Cor de Fundo da Célula(nClrBack)
                oRelRVD:Cell('PRODUTO'):nClrBack := CLR_WHITE
                oRelRVD:Cell('DESCRICAO'):nClrBack := CLR_WHITE
                oRelRVD:Cell('Un'):nClrBack := CLR_WHITE
                oRelRVD:Cell('QTD'):nClrBack := CLR_WHITE
                oRelRVD:Cell('COEF_PROD'):nClrBack := CLR_WHITE
                oRelRVD:Cell('Vol. Vend.'):nClrBack := CLR_WHITE
                oRelRVD:Cell('FATURAMENTO'):nClrBack := CLR_WHITE
                oRelRVD:Cell('R$ Medio'):nClrBack := CLR_WHITE

                //Cor da Fonte da Célula(nClrFore)
                oRelRVD:Cell('PRODUTO'):nClrFore := CLR_BLACK
                oRelRVD:Cell('DESCRICAO'):nClrFore := CLR_BLACK
                oRelRVD:Cell('Un'):nClrFore := CLR_BLACK
                oRelRVD:Cell('QTD'):nClrFore := CLR_BLACK
                oRelRVD:Cell('COEF_PROD'):nClrFore := CLR_BLACK
                oRelRVD:Cell('Vol. Vend.'):nClrFore := CLR_BLACK
                oRelRVD:Cell('FATURAMENTO'):nClrFore := CLR_BLACK
                oRelRVD:Cell('R$ Medio'):nClrFore := CLR_BLACK

            EndIf

            oRelRVD:Cell('QTD'):SetPicture("@E 9,999,999,999.99")
            oRelRVD:Cell('COEF_PROD'):SetPicture("@E 9,999,999,999.99")
            oRelRVD:Cell('Vol. Vend.'):SetPicture("@E 9,999,999,999.99")
            oRelRVD:Cell('FATURAMENTO'):SetPicture("@E 9,999,999,999.99")
            oRelRVD:Cell('R$ Medio'):SetPicture("@E 9,999,999,999.99")

            oRelRVD:Cell('PRODUTO'):SetValue(RVENDAS->D2_COD)
            oRelRVD:Cell('DESCRICAO'):SetValue(RVENDAS->B1_DESC)
            oRelRVD:Cell('Un'):SetValue(RVENDAS->D2_UM)
            oRelRVD:Cell('QTD'):SetValue(RVENDAS->D2_QUANT)
            oRelRVD:Cell('COEF_PROD'):SetValue(RVENDAS->B1_XCOEFI)
            _nTotCoef := ( RVENDAS->D2_QUANT * RVENDAS->B1_XCOEFI )
            oRelRVD:Cell('Vol. Vend.'):SetValue(_nTotCoef)
            oRelRVD:Cell('FATURAMENTO'):SetValue(RVENDAS->D2_TOTAL)
            //_nCoefUnt := ( RVENDAS->D2_TOTAL / _nTotCoef)
            _nCoefUnt := ( RVENDAS->D2_TOTAL / _nTotCoef * RVENDAS->B1_XCOEFI )
            oRelRVD:Cell('R$ Medio'):SetValue(_nCoefUnt)
            //Acumula Totais do Grupo
            nGrTtQtd += RVENDAS->D2_QUANT
            nGrTtCoe += _nTotCoef
            nGrTtFat += RVENDAS->D2_TOTAL
            nGrMdCUn += _nCoefUnt
            nGrQtdPr ++

            //Acumula Totais Gerais
            nTtQtd += RVENDAS->D2_QUANT
            nTtCoe += _nTotCoef
            nTtFat += RVENDAS->D2_TOTAL
            nMdCUn += _nCoefUnt
            nQtdPr ++

            oRelRVD:Printline()
            oReport:SkipLine() //-- Salta Linha

            DbSelectArea("RVENDAS")
            DbSkip()
            nCt ++

        EndDo

        oReport:SkipLine() //-- Salta Linha
            
        //Cor de Fundo da Célula(nClrBack)
        oRelRVD:Cell('PRODUTO'):nClrBack := CLR_LIGHTGRAY
        oRelRVD:Cell('DESCRICAO'):nClrBack := CLR_LIGHTGRAY
        oRelRVD:Cell('Un'):nClrBack := CLR_LIGHTGRAY
        oRelRVD:Cell('QTD'):nClrBack := CLR_LIGHTGRAY
        oRelRVD:Cell('COEF_PROD'):nClrBack := CLR_LIGHTGRAY
        oRelRVD:Cell('Vol. Vend.'):nClrBack := CLR_LIGHTGRAY
        oRelRVD:Cell('FATURAMENTO'):nClrBack := CLR_LIGHTGRAY
        oRelRVD:Cell('R$ Medio'):nClrBack := CLR_LIGHTGRAY

        oRelRVD:Cell('QTD'):SetPicture("@E 9,999,999,999.99")
        oRelRVD:Cell('COEF_PROD'):SetPicture("@!")
        oRelRVD:Cell('Vol. Vend.'):SetPicture("@E 9,999,999,999.99")
        oRelRVD:Cell('FATURAMENTO'):SetPicture("@E 9,999,999,999.99")
        oRelRVD:Cell('R$ Medio'):SetPicture("@E 9,999,999,999.99")

        oRelRVD:Cell('PRODUTO'):SetValue('')
        oRelRVD:Cell('DESCRICAO'):SetValue('Totais Grupo...')
        oRelRVD:Cell('Un'):SetValue('')
        oRelRVD:Cell('QTD'):SetValue(nGrTtQtd)
        oRelRVD:Cell('COEF_PROD'):SetValue('')
        oRelRVD:Cell('Vol. Vend.'):SetValue(nGrTtCoe)
        oRelRVD:Cell('FATURAMENTO'):SetValue(nGrTtFat)
        _nGrMdProd := ( nGrMdCUn / nGrQtdPr)
        oRelRVD:Cell('R$ Medio'):SetValue(_nGrMdProd)
        
        oRelRVD:Printline() 
        oReport:SkipLine() //-- Salta Linha

        n1CstGrp := (nGrTtFat / nGrTtCoe)
        n2CstGrp := n1CstGrp * If(cGrpTip=="1",30,1)

        oRelRVD:Cell('QTD'):SetPicture("@E 9,999,999,999.99")
        oRelRVD:Cell('COEF_PROD'):SetPicture("@E 9,999,999,999.99")
        oRelRVD:Cell('Vol. Vend.'):SetPicture('@!')
        oRelRVD:Cell('FATURAMENTO'):SetPicture('@!')
        oRelRVD:Cell('R$ Medio'):SetPicture('@!')

        oRelRVD:Cell('PRODUTO'):SetValue('')
        oRelRVD:Cell('DESCRICAO'):SetValue('Fatur.Médio...')
        oRelRVD:Cell('Un'):SetValue('')
        oRelRVD:Cell('QTD'):SetValue(n1CstGrp)
        oRelRVD:Cell('COEF_PROD'):SetValue(n2CstGrp)
        oRelRVD:Cell('Vol. Vend.'):SetValue('')
        oRelRVD:Cell('FATURAMENTO'):SetValue('')
        oRelRVD:Cell('R$ Medio'):SetValue('')

        oRelRVD:Printline() 
        oReport:SkipLine() //-- Salta Linha

    EndDo
    oReport:SkipLine() //-- Salta Linha

    //Cor de Fundo da Célula(nClrBack)
    oRelRVD:Cell('PRODUTO'):nClrBack := CLR_SILVER
    oRelRVD:Cell('DESCRICAO'):nClrBack := CLR_SILVER
    oRelRVD:Cell('Un'):nClrBack := CLR_SILVER
    oRelRVD:Cell('QTD'):nClrBack := CLR_SILVER
    oRelRVD:Cell('COEF_PROD'):nClrBack := CLR_SILVER
    oRelRVD:Cell('Vol. Vend.'):nClrBack := CLR_SILVER
    oRelRVD:Cell('FATURAMENTO'):nClrBack := CLR_SILVER
    oRelRVD:Cell('R$ Medio'):nClrBack := CLR_SILVER

    //oRelRVD:Cell('QTD'):SetPicture("@E 9,999,999,999.99")
    oRelRVD:Cell('QTD'):SetPicture("@!")
    oRelRVD:Cell('COEF_PROD'):SetPicture('@!')
    //oRelRVD:Cell('Vol. Vend.'):SetPicture("@E 9,999,999,999.99")
    oRelRVD:Cell('Vol. Vend.'):SetPicture("@!")
    oRelRVD:Cell('FATURAMENTO'):SetPicture("@E 9,999,999,999.99")
    //oRelRVD:Cell('R$ Medio'):SetPicture("@E 9,999,999,999.99")
    oRelRVD:Cell('R$ Medio'):SetPicture("@!")

    oRelRVD:Cell('PRODUTO'):SetValue('')
    oRelRVD:Cell('DESCRICAO'):SetValue('Total Geral...')
    oRelRVD:Cell('Un'):SetValue('')
    //oRelRVD:Cell('QTD'):SetValue(nTtQtd)
    oRelRVD:Cell('QTD'):SetValue('')
    oRelRVD:Cell('COEF_PROD'):SetValue('')
    //oRelRVD:Cell('Vol. Vend.'):SetValue(nTtCoe)
    oRelRVD:Cell('Vol. Vend.'):SetValue('')
    oRelRVD:Cell('FATURAMENTO'):SetValue(nTtFat)
    //_nMdProd := ( nMdCUn / nQtdPr)
    //oRelRVD:Cell('R$ Medio'):SetValue(_nMdProd)
    oRelRVD:Cell('R$ Medio'):SetValue('')

    oRelRVD:Printline() 

    DbSelectArea("RVENDAS")
    DbCloseArea() 
    oRelRVD:Finish()    

Return               

Static Function Gera_SX1(_cPerg)

	Local _aArea := GetArea()
	Local aRegs := {}
	Local i,j

	dbSelectArea("SX1")
	dbSetOrder(1)
	_cPerg := PADR(_cPerg,10)

	//-- Cria as perguntas.

	aAdd(aRegs,{_cPerg,"01","De ?"                 ,"","","mv_ch1","D",TamSX3("D2_EMISSAO")[1]   ,0   ,0 ,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""      })
	aAdd(aRegs,{_cPerg,"02","Até ?"                ,"","","mv_ch2","D",TamSX3("D2_EMISSAO")[1]   ,0   ,0 ,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""      })
    aAdd(aRegs,{_cPerg,"03","Do Produto ?"         ,"","","mv_ch3","C",TamSX3("B1_COD")[1]       ,0   ,0 ,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1"   })
    aAdd(aRegs,{_cPerg,"04","Até Produto ?"        ,"","","mv_ch4","C",TamSX3("B1_COD")[1]       ,0   ,0 ,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1"   })
    aAdd(aRegs,{_cPerg,"05","Do Grupo ?"           ,"","","mv_ch5","C",TamSX3("BM_GRUPO")[1]     ,0   ,0 ,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SBM"   })
    aAdd(aRegs,{_cPerg,"06","Até Grupo?"           ,"","","mv_ch6","C",TamSX3("BM_GRUPO")[1]     ,0   ,0 ,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SBM"   })
    aAdd(aRegs,{_cPerg,"07","Da Filial ?"          ,"","","mv_ch7","C",Len(xFilial())            ,0   ,0 ,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SM0"   })
    aAdd(aRegs,{_cPerg,"08","Até Filial?"          ,"","","mv_ch8","C",Len(xFilial())            ,0   ,0 ,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SM0"   })
    //aAdd(aRegs,{_cPerg,"07","Tipo Relatorio ?"      ,"","","mv_ch7","N",1                      ,0   ,0 ,"C","","mv_par07","Receitas","","","","","Despesas","","","","","","","","","","","","","","","","","","",""})


	For i:=1 to Len(aRegs)
		If !dbSeek(_cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
	RestArea(_aArea)
Return
