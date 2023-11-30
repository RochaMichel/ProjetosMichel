#INCLUDE "TOTVS.ch"

user function TRep4()
Private cTitulo     := "Relatorio de clientes"
private cDesc       := "Emissão de relatorio de clientes"
Private cFunName    := FunName()
Private oRelatorio  

    oRelatorio := TReport():new(cFunName, cTitulo,, {|oRelatorio| PrintReport(oRelatorio)}, cDesc)
    oSection1 := TRSection():new(oRelatorio, "Cliente", {"SA1"},{"COD", "DESC"} )   


    TRCell():new(oSection1, "A1_COD", "SA1",,,15)
    TRCell():new(oSection1, "A1_LOJA", "SA1")
    TRCell():new(oSection1, "A1_END", "SA1")
    TRCell():new(oSection1, "A1_TIPO", "SA1")
    TRCell():new(oSection1, "A1_NREDUZ", "SA1")

    oBreak := TRBreak():new( oRelatorio, {||SA1->A1_COD }, {||SA1->A1_COD }, ,"Codigo", .F.)
    oBreak:OnBreak( { || oRelatorio:PrtLeft( REPLICATE('-', 120)), oRelatorio:SkipLine(2) } )


    oRelatorio:PrintDialog()
return
static function PrintReport(oRelatorio)
    Local oSection1 := oRelatorio:Section(1)
    SB1->(DbSetOrder(oRelatorio:nOrder))
    SB1->(DBGOTOP() )

    oSection1:Print()


return
