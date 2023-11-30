#INCLUDE "Totvs.ch"
/*/{Protheus.doc} CodERP01
Relatório CODERP01
@type function
@version 12.1.33
@author Lucas Antonio CodERP
@since 13/10/2022
@return variant, Nill
/*/
User Function CodERP03()
	PRIVATE cTitulo     := 'Relatório de Registro de Inventario'
	PRIVATE cDescri     := "Itens de venda"
	PRIVATE cFunName    := FunName()
	PRIVATE oRelatorio
    PRIVATE aPergs      := {}
   
    aAdd(aPergs, {1, "Codigo de"        ,space(TamSX3("B1_COD")[1]) , "",  ".T."  , "SB1", ".T."   , 40, .F.}) //MV_Par01
    aAdd(aPergs, {1,  "  até  "         ,space(TamSX3("B1_COD")[1]) , "",  ".T."  , "SB1", ".T."   , 40, .T.}) //MV_Par02
    aAdd(aPergs, {2, "Seleciona Filiais",1        , {"0023 - macro" , "0024 - micro",""}  , 60 ,".T.",.F.}) //MV_PAR03
    aAdd(aPergs, {1, "Data De"          ,Date()   , "", ".T.", "", ".T.", 80 , .F.}) //MV_PAR04
    aAdd(aPergs, {1, " Até "            ,Date()   , "", ".T.", "", ".T.", 80 , .T.}) //MV_PAR05

    If !parambox(aPergs,"Informe os parametros")
            Return
    EndIf

	oRelatorio  := TReport():New(cFunName, cTitulo,, {|oRelatorio| PrintReport(oRelatorio)}, cDescri) 

	oSection1   := TRSection():New(oRelatorio, 'Nota Fiscal', {'SB1'}) 

 	TRCell():New(oSection1, "B1_COD"  , "SB1","Codigo",PesqPict( "SB1", "B1_COD"  ),TamSX3("B1_COD"  )[1],/*lPixel*/,{|| QERY->B1_COD   })
	TRCell():New(oSection1, "B1_DESC" , "SB1","Descrição",PesqPict( "SB1", "B1_DESC" ),TamSX3("B1_DESC" )[1],/*lPixel*/,{|| QERY->B1_DESC  })
	TRCell():New(oSection1, "B1_UM"   , "SB1","unidade",PesqPict( "SB1", "B1_UM"   ),TamSX3("B1_UM"   )[1],/*lPixel*/,{|| QERY->B1_UM    })
	TRCell():New(oSection1, "B1_TIPO" , "SB1","tipo",PesqPict( "SB1", "B1_TIPO" ),TamSX3("B1_TIPO" )[1],/*lPixel*/,{|| QERY->B1_TIPO  })
	TRCell():New(oSection1, "B9_VINI1", "SB9","estoque",PesqPict( "SB9", "B9_VINI1"),TamSX3("B9_VINI1")[1],/*lPixel*/,{|| QERY->Estoque })
    TRCell():New(oSection1, "B2_CM1"  , "SB2","custo medio",PesqPict( "SB2", "B2_CM1"  ),TamSX3("B2_CM1"  )[1],/*lPixel*/,{|| QERY->CustoM })
    TRCell():New(oSection1, "", "","entrada",PesqPict( "SD1", "D1_custo"),TamSX3("D1_custo ")[1],/*lPixel*/,{||iif(QERY->d3_cf == 'RE0',QERY->custo,0) })
    TRCell():New(oSection1, "", "","Saida",PesqPict( "SD2", "D2_custo1"),TamSX3("D2_custo1")[1],/*lPixel*/,{|| iif(QERY->d3_cf == 'DE0',QERY->custo,0) })
    TRCell():New(oSection1, "", "","Estoque final",PesqPict( "SD2", "D2_custo1"),TamSX3("D2_custo1")[1],/*lPixel*/,{||QERY->estoqueFim })
    TRCell():New(oSection1, "", "","Previsão de estoque",PesqPict( "SD2", "D2_custo1"),TamSX3("D2_custo1")[1],/*lPixel*/,{|| ((QERY->estoqueFim)/iif(QERY->d3_cf == 'DE0',QERY->Custo,0))*(Day(mv_par05)-Day(mv_par04))})
	TRPosition():New(oSection1, 'SB1', 1, {|| QERY-> B1_COD})
  
    oRelatorio:PrintDialog()

Return

Static Function PrintReport(oRelatorio)
	Local oSection1 := oRelatorio:section(1)

	oSection1:BeginQuery()

    BEGINSQL ALIAS 'QERY'

    select B1_cod, b1_desc, b1_Um, b1_classi , b1_tipo, d3_cf ,SUM(b2_cm1) CustoM ,sum(b9_vini1) estoque, 
        CASE When D3_Cf = 'RE0' THEN Sum(D1_custo+D3_custo1)  When D3_Cf = 'DE0' THEN Sum(D2_custo1+D3_custo1) END AS Custo,
        Sum ((b9_vini1+D1_custo+d3_custo1)-(d2_custo1+d3_custo1)) estoqueFim 
        From %table:sb1% sb1
        inner join %table:Sb2% sb2
            on b1_cod = b2_cod
        inner join %table:sd1% sd1
            on b1_cod = d1_cod
        inner join %table:sd2% sd2
            on b1_cod = d2_cod
        inner join %table:sd3% sd3
            on b1_cod = d3_cod
        inner join %table:sb9% sb9
            on b1_cod = b9_cod
        inner join %table:sf4% sf4
            on d1_tes = f4_codigo   
        where SB1.%notDel%
        AND SD1.%notDel%
        AND SD3.%notDel%
        AND SB9.%notDel%
        AND SF4.%notDel%
        AND F4_Estoque = 'S'
        AND b1_cod between %Exp:MV_PAR01% and %Exp:MV_PAR02%
        and b1_datref between %Exp:MV_PAR04% and %Exp:MV_PAR05% 
        Group by B1_cod, b1_desc, b1_Um , b1_classi ,b1_tipo, b2_cm1, d3_cf
        Order by B1_cod, b1_desc, b1_Um, b1_classi ,b1_tipo, b2_cm1, d3_cf


	ENDSQL
        oSection1:EndQuery()
        oSection1:Print()

Return
