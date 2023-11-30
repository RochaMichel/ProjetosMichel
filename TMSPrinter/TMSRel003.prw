#INCLUDE 'protheus.ch'
#INCLUDE 'RWMAKE.ch'


user function TmsRel03()
    Private cTitulo         := "Relatório de Produtos"
    Private oRelatorio 
    Private oFont1          := TFont():new( "Courier New",,-10,.T.,.F.,,,,,/*lUnderline*/,/*italic*/)
    Private oFont2          := TFont():new( "Tahoma",,-25,.T.,.T.,,,,,/*lUnderline*/,/*italic*/)
    Private oFont3          := TFont():new( "Courier New",,,.T.,.T.,,,,,/*lUnderline*/,/*italic*/)
    Private oFont4          := TFont():new( "Times New Roman",,08,.T.,,,,,,/*lUnderline*/,/*italic*/)
    Private oFont5          := TFont():new( "Courier New",,-15,.T.,.T.,,,,,/*lUnderline*/,/*italic*/)
    Private oFont6          := TFont():new("Arial",07,07,,.F.,,,,.T.,.F.)
    Private oDlg
    Private cProg           := FunName()

    oRelatorio:= TMSPrinter():new( cTitulo )
    oRelatorio:Setup()
    oRelatorio:SetLandscape()
    oRelatorio:SetPaperSize(9)
    
    Ms_Flush()  // Descarrega o Spool de impressão

    oRelatorio:StartPage()

    Imprimir()

    oRelatorio:EndPage()
    oRelatorio:End()

    Define MSDIALOG oDlg From 264,182 to 441,613 Title cTitulo Of oDlg PIXEL
        @ 004,010 to 082,157 Label "" Of oDlg PIXEL
        @ 015,017 SAY "Esta Rotina tem por objetivo imprimir"   Of oDlg PIXEL size 150,010 Font oFont3 Color CLR_HBLUE
        @ 030,017 SAY "o Relatorio customizado:"                Of oDlg PIXEL size 150,010 Font oFont3 Color CLR_HBLUE
        @ 045,017 SAY cTitulo                                   Of oDlg PIXEL size 150,010 Font oFont3 Color CLR_HBLUE
        @ 06,167 Button "&Imprime"          Size 036,012 Action oRelatorio:Print()      of oDlg PIXEL 
        @ 28,167 Button "&Preview"          Size 036,012 Action oRelatorio:Preview()    of oDlg PIXEL 
        @ 49,167 Button "&Sair"             Size 036,012 Action oDlg:End()              of oDlg PIXEL
    ACTIVATE MSDIALOG oDlg CENTERED 

return  

Static FUnction Imprimir()
    Local nLin         := 9999
    local nPosCodigo   := 0100
    local nPosDesc     := 1400
    local nPosTipo     := 0850
    local nPosArma     := 1050
    local nPosUni      := 0550
    local nHorzRes     := oRelatorio:nHorzRes()
    local nVertRes     := oRelatorio:nVertRes()


    SB1 ->(DbSetOrder(1))
    SB1 ->(DBGOTOP())

    
    WHILE !SB1 ->(EOF())
        If nLin>=oRelatorio:nVertRes()
            if nLin <> 9999 
                oRelatorio:EndPage()
                oRelatorio:StartPage()
            ENDIF 
            
            nLin := 0020
            oRelatorio:Box(nLin, 20, 150, nHorzRes)

            
            oRelatorio:SAY(0025, 040, "RELATORIO: TMSREL03"+ cProg, oFont6)
            oRelatorio:SAY(0055, 040, "Emissão "+ DToC(dDataBase), oFont6)
            oRelatorio:SAY(0085, 040, "Impressora"+ oRelatorio:PrinterName(), oFont6)

            oRelatorio:SAY(0035, 500, UPPER(cTitulo) , oFont2)

            
            oRelatorio:SAY(0055, nHorzRes - 400, "Usuario: "+ UsrFullName(RetCodUsr()), oFont6)
            oRelatorio:SAY(0085, nHorzRes - 400, "Pagina: "+ CValToChar(oRelatorio:nPage), oFont6)

            oRelatorio:SayBitmap(025, nHorzRes - 800, "C:\Users\Robert Callfman\Downloads\fullmetal.bmp", 300, 120 )


            nLin := 0200
            oRelatorio:Say(nLin, nPosCodigo,"Codigo",oFont5)
            oRelatorio:Say(nLin, nPosDesc, "Descrição",oFont5) 
            oRelatorio:Say(nLin, nPosTipo, "Tipo",oFont5) 
            oRelatorio:Say(nLin, nPosArma, "Cod. Armazem",oFont5)
            oRelatorio:Say(nlin, nPosUni, "Unidade", oFont5)

            oRelatorio:Line(nLin, nPosCodigo - 50, nVertRes - 100, nPosCodigo - 50 )
            oRelatorio:Line(nLin, nPosDesc - 50, nVertRes - 100, nPosDesc - 50 )
            oRelatorio:Line(nLin, nPosTipo - 50, nVertRes - 100, nPosTipo - 50 )
            oRelatorio:Line(nLin, nPosArma - 50, nVertRes - 100, nPosArma - 50 )
            oRelatorio:Line(nLin, nPosUni - 50, nVertRes - 100, nPosUni - 50 )

            nLin += 55

            oRelatorio:Line(nLin, 10 ,nLin, nHorzRes)
            nLin += 35

        ENDIF

        oRelatorio:Say(nlin, nPosDesc, SB1->B1_DESC, oFont5)
        oRelatorio:Say(nlin, nPosTipo, SB1->B1_TIPO, oFont5)
        oRelatorio:Say(nlin, nPosArma, SB1->B1_LOCPAD, oFont5)
        oRelatorio:Say(nlin, nPosUni, SB1->B1_UM, oFont5)
        oRelatorio:Say(nlin, nPosCodigo, SB1->B1_COD, oFont5)
        

      
         nLin += 0045        
        SB1 -> (DBSKIP())    
    ENDDO
    
return  
