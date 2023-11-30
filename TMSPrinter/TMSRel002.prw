#INCLUDE 'protheus.ch'
#INCLUDE 'RWMAKE.ch'


user function TmsRel02()
    Private cTitulo         := "Relatório de autores"
    Private oRelatorio 
    Private oFont1          := TFont():new("Courier New",,-10,.T.,.F.,,,,,/*lUnderline*/,/*italic*/)
    Private oFont2          := TFont():new("Tahoma",,-15,.T.,.T.,,,,,/*lUnderline*/,/*italic*/)
    Private oFont3          := TFont():new("Courier New",,,.T.,.T.,,,,,/*lUnderline*/,/*italic*/)
    Private oFont4          := TFont():new("Times New Roman",,08,.T.,,,,,,/*lUnderline*/,/*italic*/)
    Private oFont5          := TFont():new("Courier New",,-15,.T.,.T.,,,,,/*lUnderline*/,/*italic*/)
    Private oDlg
    
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
    local nPosDesc     := 0900
    local nPosTipo     := 0400

    SB1 ->(DbSetOrder(1))
    SB1 ->(DBGOTOP())

    
    WHILE !SB1 ->(EOF())
        If nLin>=oRelatorio:nVertRes()
            if nLin <> 9999
                oRelatorio:EndPage()
                oRelatorio:StartPage()
            ENDIF 

            nLin := 0030
            oRelatorio:SAY(nLin, 0100, UPPER(cTitulo), oFont2 )
            oRelatorio:Box(nLin, 1150, nLin+100, 1800 )
            oRelatorio:SAY(nLin, 1200, "Data: "+ DTOC( dDataBase ), oFont3 )
            oRelatorio:SAY(nLin, 1550, "Pág.: "+ CValToChar(oRelatorio:nPage), oFont3 )
            nLin += 40 
            oRelatorio:SAY(nLin, 1200, "Usuario: "+ UsrFullName(RetCodUsr()), oFont3 )
            nLin += 200
            oRelatorio:Say(nLin, nPosCodigo, "Codigo ",oFont5)
            oRelatorio:Say(nLin, nPosDesc, "Descrição ",oFont5)
            oRelatorio:Say(nLin, nPosTipo, "Tipo ",oFont5) 
            nLin += 050 

            oRelatorio:Line(nLin, 0010, nLin, oRelatorio:nHorzRes() )
            nLin += 050
        ENDIF
        oRelatorio:Say(nLin, nPosCodigo, SB1->B1_COD,oFont4)
        oRelatorio:Say(nLin, nPosDesc, SB1->B1_DESC,oFont4) 
        oRelatorio:Say(nLin, nPosTipo, SB1->B1_TIPO,oFont4)  

        oBrush1  := TBrush():new(,CLR_YELLOW)
        oRelatorio:FillRect({nLin, 20, nlin+20, 40}, oBrush1)

         nLin += 0045        
        SB1 -> (DBSKIP())    
    ENDDO
    nLin += 0080

    oRelatorio:SayBitmap(nLin, 0010, "C:\Users\Robert Callfman\Downloads\fullmetal.bmp", 800, 300 )
return  
