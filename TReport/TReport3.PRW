#INCLUDE "TOTVS.ch"

user function TRep3()
Private cTitulo     := "Relatorio de clientes"
private cDesc       := "Emissão de relatorio de clientes"
Private cFunName    := FunName()
Private oRelatorio  

    oRelatorio := TReport():new(cFunName, cTitulo,, {|oRelatorio| PrintReport(oRelatorio)}, cDesc)
    oSection1 := TRSection():new(oRelatorio, "Cliente", {"SB1"},{"COD", "DESC"} )
      

    TRCell():new(oSection1, "B1_COD"    , "SB1",,,,,{||QRYRPT -> B1_COD})
    TRCell():new(oSection1, "B1_DESC"   , "SB1",,,,,{||QRYRPT -> B1_DESC})
    TRCell():new(oSection1, "B1_TIPO"   , "SB1",,,,,{||QRYRPT -> B1_TIPO})
    TRCell():new(oSection1, "B1_UM"     , "SB1",,,,,{||QRYRPT -> B1_UM}) 

  

    oRelatorio:PrintDialog()
return
static function PrintReport(oRelatorio)
    Local oSection1 := oRelatorio:Section(1)


    if Select ("QRYRPT") > 0

        QRYRPT->(DBCLOSEAREA())
    endif
    
    BEGINSQL ALIAS "QRYRPT"

    SELECT      B1_COD,
                B1_DESC,
                B1_TIPO,
                B1_UM
                FROM  SB1990
    ENDSQL
    QRYRPT ->( DBGOTOP())
    while !QRYRPT->(EOF() )
        SB1->( DBSEEK( QRYRPT->B1_COD ))
        oSection1:Init()
        oSection1:Print()
        oSection1:Finish()
        cCOD := QRYRPT->B1_DESC
        oSection1:Init()
        WHILE !QRYRPT->(EOF()) .and. QRYRPT->B1_DESC == cCOD
            oSection1:Print()
            QRYRPT->(DBSKIP() )  
        ENDDO
        oSection1:Finish()

          
    end


return
