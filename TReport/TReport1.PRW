#INCLUDE "TOTVS.ch"

user function TRep1()
Private cTitulo     := "Relatorio de produtos"
private cDesc       := "Emissão de relatorio de produtos"
Private cFunName    := FunName()
Private oRelatorio  

    oRelatorio := TReport():new(cFunName, cTitulo,, {|oRelatorio| PrintReport(oRelatorio)}, cDesc)
    oSection1 := TRSection():new(oRelatorio, "Produto", {"SB1"},{"COD", "DESC"} )


    TRCell():new(oSection1, "B1_COD", "SB1",,,15)
    TRCell():new(oSection1, "B1_TIPO", "SB1")
    TRCell():new(oSection1, "B1_UM", "SB1")
    TRCell():new(oSection1, "B1_LOCPAD", "SB1")
    TRCell():new(oSection1, "B1_DESC", "SB1")


   oRelatorio:PrintDialog()
   
return
static function PrintReport(oRelatorio)
    Local oSection1 := oRelatorio:Section(1)
    SB1->(DbSetOrder(oRelatorio:nOrder))
    SB1->(DBGOTOP() )

    oSection1:Print()


return
