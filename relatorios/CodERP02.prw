#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#include "TopConn.ch"
#include "COLORS.ch"

#define CLR_SILVER rgb(192,192,192)
#define CLR_LIGHTGRAY rgb(220,220,220)

User Function CodERP02()

	PRIVATE cTitulo     := 'Relatório de Registro de Inventario'
	PRIVATE cDescri     := ""
	PRIVATE cFunName    := FunName()
	PRIVATE oRelatorio
	PRIVATE aPergs      := {}
	Private _lBold    := .F. //Controle de IMpressÃ£o em NEgrito
	Private lAutoSize := .T.

	aAdd(aPergs, {1, "Codigo de"        ,space(TamSX3("B1_COD")[1]) , "",  ".T."  , "SB1", ".T."   , 40, .F.}) //MV_Par01
	aAdd(aPergs, {1, "Codigo  até  "         ,space(TamSX3("B1_COD")[1]) , "",  ".T."  , "SB1", ".T."   , 40, .T.}) //MV_Par02
	aAdd(aPergs, {2, "Selecione :",1        , {"0023 - macro","0024 - micro",""}  , 60 ,".T.",.T.}) //MV_PAR03
	aAdd(aPergs, {1, "Data De"          ,Date()   , "", ".T.", "", ".T.", 80 , .F.}) //MV_PAR04
	aAdd(aPergs, {1, "Data Até "            ,Date()   , "", ".T.", "", ".T.", 80 , .T.}) //MV_PAR05

	If !parambox(aPergs,"Informe os parametros")
		Return
	EndIf

	oRelatorio  := TReport():New(cFunName, cTitulo,, {|oRelatorio| PrintReport(oRelatorio)}, cDescri)

	oSection1   := TRSection():New(oRelatorio, cTitulo , {'SB1','SB9','SB2','SD1','SD2'})

	TRCell():New(oSection1,'Codigo'             ,''    ,      ,PesqPict("SB1", "B1_COD") ,TamSX3("B1_COD")[1]         ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oSection1,'Descrição'          ,''    ,      ,PesqPict("SB1", "B1_DESC"),40                          ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oSection1,'UND'                ,''    ,      ,PesqPict("SB1", "B1_UM")  ,TamSX3("B1_UM")[1]          ,/*lPixel*/,, "LEFT" ,          ,"LEFT"      ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oSection1,'TP'                 ,''    ,      ,PesqPict("SB1","B1_TIPO") ,TamSX3("B1_TIPO")[1]        ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oSection1,'Estoque Inicial'    ,''    ,      ,"@E 9,999,999,999.99"     ,TamSX3("B9_VINI1")[1]       ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oSection1,'Custo Médio'        ,''    ,      ,"@E 9,999,999,999.99"     ,TamSX3("B2_CM1")[1]         ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oSection1,'Entradas'           ,''    ,      ,"@E 9,999,999,999.99"     ,TamSX3("D1_CUSTO")[1]       ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oSection1,'Consumo'            ,''    ,      ,"@E 9,999,999,999.99"     ,TamSX3("D2_CUSTO1")[1]      ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oSection1,'estoque final'      ,''    ,      ,"@E 9,999,999,999.99"     ,TamSX3("D2_CUSTO1")[1]      ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)
	TRCell():New(oSection1,'Previsão de estoque',''    ,      ,"@E 9,999,999,999.99"     ,TamSX3("D2_CUSTO1")[1]      ,/*lPixel*/,, "RIGHT",          ,"RIGHT"     ,          ,         ,lAutoSize      ,          ,         ,_lBold)


	oRelatorio:printDialog()
Return

Static Function PrintReport(oRelatorio)
	Local oSection1 := oRelatorio:section(1)



QERYE := "select B1_cod, b1_desc, b1_Um, b1_classi , b1_tipo, SUM(b2_cm1) CustoM , sum(B9_QINI) estoque, "
QERYE += " (select Sum(D1_custo+D3_custo1) from sd1010 sd1 " 
QERYE += "    inner join "+RetSqlName('sd3')+" sd3 on b1_cod = d3_cod "
QERYE += "    inner join "+RetSqlName('sf4')+" sf4 on d1_tes = f4_codigo "
QERYE += "    where d3_cf='RE0' AND F4_Estoque = 'S'  AND SF4.D_E_L_E_T_='' "
QERYE += "    AND SD3.D_E_L_E_T_='' AND SD1.D_E_L_E_T_=''  ) As custoE, "
QERYE += " (select Sum(D2_custo1+D3_custo1) from sd2010 sd2 "
QERYE += "    inner join "+RetSqlName('sd3')+" sd3 on b1_cod = d3_cod "
QERYE += "   inner join "+RetSqlName('sf4')+" sf4 on d2_tes = f4_codigo "
QERYE += "    where d3_cf='DE0'  AND F4_Estoque = 'S'  AND SD2.D_E_L_E_T_='' "
QERYE += "    AND SD3.D_E_L_E_T_=''  AND SF4.D_E_L_E_T_='' ) As custoS "
QERYE += "From "+RetSqlName('sb1')+" sb1 "
QERYE += "inner join "+RetSqlName('sb2')+" sb2 "
QERYE += "  on b1_cod = b2_cod "
QERYE += "inner join "+RetSqlName('sb9')+" sb9 "
QERYE += "  on b1_cod = b9_cod "
QERYE += "WHERE SB1.D_E_L_E_T_='' "
QERYE += "AND SB2.D_E_L_E_T_='' "
QERYE += "AND SB9.D_E_L_E_T_='' "
QERYE += "AND b1_cod between '" +MV_PAR01+ "' AND '" +MV_PAR02+ "' "
QERYE += "AND B1_DATREF BETWEEN '" + DTOS(MV_PAR04) + "' AND '" + DTOS(MV_PAR05) +"' "
QERYE += "Group by B1_cod, b1_desc, b1_Um , b1_classi ,b1_tipo "
QERYE += "Order by b1_Cod "

TCQuery QERYE NEW ALIAS "QERY"

/*
QERYS := "Select B1_cod, b1_desc, b1_Um, b1_classi , b1_tipo ,SUM(b2_cm1) CustoM ,sum(b9_vini1) estoque, "
QERYS += "Sum(d2_custo1+D3_custo1) custoS From sb1010 sb1 "
QERYS += "inner join "+RetSqlName('sb2')+" sb2 ON b1_cod = b2_cod "
QERYS += "inner join "+RetSqlName('Sd2')+" sd2 ON b1_cod = d2_cod "
QERYS += "inner join "+RetSqlName('sd3')+" sd3 ON b1_cod = d3_cod "
QERYS += "inner join "+RetSqlName('sb9')+" sb9 ON b1_cod = b9_cod "
QERYS += "inner join "+RetSqlName('sf4')+" sf4 ON d2_Tes = f4_codigo "
QERYS += "Where SB1.D_E_L_E_T_='' AND SD2.D_E_L_E_T_='' AND SD3.D_E_L_E_T_='' AND SF4.D_E_L_E_T_='' "
QERYS += "AND F4_Estoque = 'S' AND SB9.D_E_L_E_T_='' AND d3_cf = 'RE0' "
QERYS += "AND b1_cod between '" +MV_PAR01+ "' AND '" +MV_PAR02+ "' "
QERYS += "AND B1_DATREF BETWEEN '" + DTOS(MV_PAR04) + "' AND '" + DTOS(MV_PAR05) +"' "
QERYS += "Group by B1_cod, b1_desc, b1_Um , b1_classi ,b1_tipo "
QERYS += "Order by b1_Cod "

TCQuery QERYS NEW ALIAS "QERYSA"*/

/*	oSection1:BeginQuery()

	BEGINSQL ALIAS 'QERY'

    select B1_cod, b1_desc, b1_Um, b1_classi , b1_tipo, d3_cf ,SUM(b2_cm1) CustoM ,sum(b9_QINI) estoque, 
        CASE When D3_Cf = 'RE0' THEN Sum(D1_custo+D3_custo1)  When D3_Cf = 'DE0' THEN Sum(D2_custo1+D3_custo1) END AS Custo,
        Sum ((b9_vini1+D1_custo+d3_custo1)-(d2_custo1+d3_custo1)) estoqueFim 
        From %table:sb1% sb1, 
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
										*/

	//IF mv_par03 == "0023 - macro" .OR. mv_par03 == ""

		
	while !oRelatorio:Cancel() .and. !QERY->(Eof()) //.and. QERY->b1_classi = '0023 - macro'
				oRelatorio:IncMeter()
				oSection1:Init()

				oRelatorio:SetMsgPrint( "Calculando ... ")

				oSection1:Cell('Codigo'):nClrBack := CLR_SILVER
				oSection1:Cell('Descrição'):nClrBack := CLR_SILVER
				oSection1:Cell('UND'):nClrBack := CLR_SILVER
				oSection1:Cell('TP'):nClrBack := CLR_SILVER
				oSection1:Cell('Estoque Inicial'):nClrBack := CLR_SILVER
				oSection1:Cell('Custo Médio'):nClrBack := CLR_SILVER
				oSection1:Cell('Entradas'):nClrBack := CLR_SILVER
				oSection1:Cell('Consumo'):nClrBack := CLR_SILVER
				oSection1:Cell('Estoque Final'):nClrBack := CLR_SILVER
				oSection1:Cell('Previsão de Estoque'):nClrBack := CLR_SILVER


				oSection1:Cell('Codigo'):nClrFore := CLR_BLACK
				oSection1:Cell('Descrição'):nClrFore := CLR_BLACK
				oSection1:Cell('UND'):nClrFore := CLR_BLACK
				oSection1:Cell('TP'):nClrFore := CLR_BLACK
				oSection1:Cell('Estoque Inicial'):nClrFore := CLR_BLACK
				oSection1:Cell('Custo Médio'):nClrFore := CLR_BLACK
				oSection1:Cell('Entradas'):nClrFore := CLR_BLACK
				oSection1:Cell('Consumo'):nClrFore := CLR_BLACK
				oSection1:Cell('Estoque Final'):nClrFore := CLR_BLACK
				oSection1:Cell('Previsão de Estoque'):nClrFore := CLR_BLACK 

				oSection1:Cell('Estoque Inicial'):SetPicture("@E 9,999,999,999.99")
				oSection1:Cell('Custo Médio'):SetPicture("@E 9,999,999,999.99")
				oSection1:Cell('Entradas'):SetPicture("@E 9,999,999,999.99")
				oSection1:Cell('Consumo'):SetPicture("@E 9,999,999,999.99")
				oSection1:Cell('Estoque Final'):SetPicture("@E 9,999,999,999.99")
				oSection1:Cell('Previsão de Estoque'):SetPicture("@E 9,999,999,999.99")

				oSection1:Cell('Codigo'):SetValue(QERY->B1_COD)
				oSection1:Cell('Descrição'):SetValue(QERY->B1_DESC)
				oSection1:Cell('UND'):SetValue(QERY->B1_UM)
				oSection1:Cell('TP'):SetValue(QERY->B1_TIPO)
				oSection1:Cell('Estoque Inicial'):SetValue(QERY->estoque)
				oSection1:Cell('Custo Médio'):SetValue(QERY->CustoM)
				oSection1:Cell('Entradas'):SetValue(QERY->custoE)
				oSection1:Cell('Consumo'):SetValue(QERY->CustoS)
				oSection1:Cell('Estoque Final'):SetValue((QERY->estoque+QERY->custoE)-QERY->custoS)
				oSection1:Cell('Previsão de Estoque'):SetValue((((QERY->estoque+QERY->custoE)-QERY->custoS)/QERY->custoS)*(Day(mv_par05)-Day(mv_par04)))
				oSection1:Printline()

                DbSelectArea("QERY")
                DbSkip()

		    END
		 oRelatorio:SkipLine()
	//ENDIF
//if mv_par03 == "0024 - micro" .OR. mv_par03 == ""

  /*  WHILE !oRelatorio:Cancel() .and. !QERYSA->(Eof()) //.and. QERY->b1_classi = '0024 - micro'
        oRelatorio:IncMeter()
        oSection1:Init()

        oRelatorio:SetMsgPrint( "Calculando ... " )

        oSection1:Cell('Codigo'):nClrBack := CLR_LIGHTGRAY
        oSection1:Cell('Descrição'):nClrBack := CLR_LIGHTGRAY
        oSection1:Cell('UND'):nClrBack := CLR_LIGHTGRAY
        oSection1:Cell('TP'):nClrBack := CLR_LIGHTGRAY
        oSection1:Cell('Estoque Inicial'):nClrBack := CLR_LIGHTGRAY
        oSection1:Cell('Custo Médio'):nClrBack := CLR_LIGHTGRAY
        oSection1:Cell('Entradas'):nClrBack := CLR_LIGHTGRAY
        oSection1:Cell('Consumo'):nClrBack := CLR_LIGHTGRAY
        oSection1:Cell('Estoque Final'):nClrBack := CLR_LIGHTGRAY
        oSection1:Cell('Previsão de Estoque'):nClrBack := CLR_LIGHTGRAY


        oSection1:Cell('Codigo'):nClrFore := CLR_BLACK
        oSection1:Cell('Descrição'):nClrFore := CLR_BLACK
        oSection1:Cell('UND'):nClrFore := CLR_BLACK
        oSection1:Cell('TP'):nClrFore := CLR_BLACK
        oSection1:Cell('Estoque Inicial'):nClrFore := CLR_BLACK
        oSection1:Cell('Custo Médio'):nClrFore := CLR_BLACK
        oSection1:Cell('Entradas'):nClrFore := CLR_BLACK
        oSection1:Cell('Consumo'):nClrFore := CLR_BLACK
        oSection1:Cell('Estoque Final'):nClrFore := CLR_BLACK
        oSection1:Cell('Previsão de Estoque'):nClrFore := CLR_BLACK

        oSection1:Cell('Estoque Inicial'):SetPicture('@!')
        oSection1:Cell('Custo Médio'):SetPicture('@!')
        oSection1:Cell('Entradas'):SetPicture('@!')
        oSection1:Cell('Consumo'):SetPicture('@!')
        oSection1:Cell('Estoque Final'):SetPicture('@!')
        oSection1:Cell('Previsão de Estoque'):SetPicture('@!')

        oSection1:Cell('Codigo'):SetValue(QERY->B1_COD)
        oSection1:Cell('Descrição'):SetValue(QERY->B1_DESC)
        oSection1:Cell('UND'):SetValue(QERY->B1_UM)
        oSection1:Cell('TP'):SetValue(QERY->B1_TIPO)
        oSection1:Cell('Estoque Inicial'):SetValue(QERY->estoque)
        oSection1:Cell('Custo Médio'):SetValue(QERY->CustoM)
        oSection1:Cell('Entradas'):SetValue(custo)
        oSection1:Cell('Consumo'):SetValue(custo)
        oSection1:Cell('Estoque Final'):SetValue(estoqueFim)
        oSection1:Cell('Previsão de Estoque'):SetValue(((QERY->estoqueFim)/QERY->custo)*(Day(mv_par05)-Day(mv_par04))) 

		DbSelectArea("QERY")
        DbSkip()
    end
     oSection1:Printline()
     oRelatorio:SkipLine() 
//endif          

*/
RETURN	
