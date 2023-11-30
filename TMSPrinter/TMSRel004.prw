#INCLUDE 'protheus.ch'
#INCLUDE 'RWMAKE.ch'


user function TmsRel04()
    Private cTitulo         := "Relatório de Produtos separados por armazem"
    Private aPergs          := {}
    Private oRelatorio 
    Private oFont1          := TFont():new( "Courier New",,-10,.T.,.F.,,,,,/*lUnderline*/,/*italic*/)
    Private oFont2          := TFont():new( "Tahoma",,-25,.T.,.T.,,,,,/*lUnderline*/,/*italic*/)
    Private oFont3          := TFont():new( "Courier New",,,.T.,.T.,,,,,/*lUnderline*/,/*italic*/)
    Private oFont4          := TFont():new( "Times New Roman",,08,.T.,,,,,,/*lUnderline*/,/*italic*/)
    Private oFont5          := TFont():new( "Courier New",,-15,.T.,.T.,,,,,/*lUnderline*/,/*italic*/)
    Private oFont6          := TFont():new("Arial",07,07,,.F.,,,,.T.,.F.)
    Private oDlg
    Private cProg           := FunName()

    aAdd( aPergs ,{1,"De  Cod Produto  "	, space(TamSX3("B1_COD")[1]),"@!",'.T.','SB1','.T.',TamSX3("B1_COD")[1]+50,.F.})//MV_PAR01
	aAdd( aPergs ,{1,"Até Cod Produto "	, space(TamSX3("B1_COD")[1]),"@!",'.T.','SB1','.T.',TamSX3("B1_COD")[1]+50,.F.})//MV_PAR02

    If !ParamBox(aPergs ,"Parametros ")
		Return
	EndIf
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
        @ 60,050 Button "&Exportar img"     Size 036,012 Action SalvaJPG()              of oDlg PIXEL
        @ 60,100 Button "&Exportar HTML"    Size 036,012 Action SalvaHTML()             of oDlg PIXEL


    ACTIVATE MSDIALOG oDlg CENTERED 

return  

Static FUnction Imprimir()
    Local nLin         := 9999
    local nPosCodigo   := 0100
    local nPosDesc     := 1400
    local nPosTipo     := 0850
    local nPosUni      := 0550
    local nHorzRes     := oRelatorio:nHorzRes()
    local nVertRes     := oRelatorio:nVertRes()
    local cCodArma     := ""


    SB1 ->(DbSetOrder(1))
    SB1 ->(DBGOTOP())

    
    WHILE !SB1 ->(EOF())
        If SB1->B1_COD >= MV_PAR01 .AND. SB1->B1_COD <= MV_PAR02
            If nLin>=oRelatorio:nVertRes() .or. cCodArma <> SB1->B1_TIPO 
                if nLin <> 9999 
                    oRelatorio:EndPage()
                    oRelatorio:StartPage()
                ENDIF 
                cCodArma := SB1->B1_TIPO
                nLin := 0020
                oRelatorio:Box(nLin, 20, 150, nHorzRes)

                
                oRelatorio:SAY(0025, 040, "RELATORIO: TMSREL03"+ cProg, oFont6)
                oRelatorio:SAY(0055, 040, "Emissão "+ DToC(dDataBase), oFont6)
                oRelatorio:SAY(0085, 040, "Impressora"+ oRelatorio:PrinterName(), oFont6)
                
                oRelatorio:SAY(0035, 500, SB1->B1_TIPO, oFont2)
                oRelatorio:SAY(0025, 500, UPPER(cTitulo) , oFont4)

                
                oRelatorio:SAY(0055, nHorzRes - 400, "Usuario: "+ UsrFullName(RetCodUsr()), oFont6)
                oRelatorio:SAY(0085, nHorzRes - 400, "Pagina: "+ CValToChar(oRelatorio:nPage), oFont6)

                oRelatorio:SayBitmap(025, nHorzRes - 800, "C:\Users\Robert Callfman\Downloads\fullmetal.bmp", 300, 120 )


                nLin := 0200
                oRelatorio:Say(nLin, nPosCodigo,"Codigo",oFont5)
                oRelatorio:Say(nLin, nPosDesc, "Descrição",oFont5) 
                oRelatorio:Say(nLin, nPosTipo, "Tipo",oFont5) 
                oRelatorio:Say(nlin, nPosUni, "Unidade", oFont5)

                oRelatorio:Line(nLin, nPosCodigo - 50, nVertRes - 100, nPosCodigo - 50 )
                oRelatorio:Line(nLin, nPosDesc - 50, nVertRes - 100, nPosDesc - 50 )
                oRelatorio:Line(nLin, nPosTipo - 50, nVertRes - 100, nPosTipo - 50 )
                oRelatorio:Line(nLin, nPosUni - 50, nVertRes - 100, nPosUni - 50 )

                nLin += 55

                oRelatorio:Line(nLin, 10 ,nLin, nHorzRes)
                nLin += 35

            ENDIF

            oRelatorio:Say(nlin, nPosDesc, SB1->B1_DESC, oFont5)
            oRelatorio:Say(nlin, nPosTipo, SB1->B1_TIPO, oFont5)
            oRelatorio:Say(nlin, nPosUni, SB1->B1_UM, oFont5)
            oRelatorio:Say(nlin, nPosCodigo, SB1->B1_COD, oFont5)
            
            nLin += 0045
        ENDIF
                    
        SB1 -> (DBSKIP())    
    ENDDO
    IF nLin ==  9999
        nLin := 200
        oRelatorio:Say(nLin, nPosCodigo, "NÃO EXISTE REGISTRO NO RELATORIO!!!!!", oFont4)

    EndIf 
return  

Static Function SalvaJPG()
    oRelatorio:SaveAllAsJpeg("\relatorio\TmsRel04", 1200, 800, 200, 100)
    
Return 
Static Function SalvaHTML()
   oRelatorio:SaveAsHTML("\relatorio\TmsRel04.html")
  
    
Return 
