#Include "Totvs.ch"
#Include "RPTDef.ch"
#include "TBICONN.ch"

/*/{Protheus.doc} RELDP2
Fonte para exibir Relatório de Apuração ISS
@type function
@author Felipe Henrique
@since 30/01/2023
@return 
/*/

User Function RELDP2()
	Local aPergs	 := {}
	Private oReport  := Nil
	Private oSecCab	 := Nil

	aAdd(aPergs,{1,"De filial: ",Space(TamSx3('P8_FILIAL')[1]),"","","SM0","",50,.F.})    //MV_PAR01
	aAdd(aPergs,{1,"Ate filial: ",Space(TamSx3('P8_FILIAL')[1]),"","","SM0","",50,.F.})   //MV_PAR02
	aAdd(aPergs, {1, "Data De       "         ,Date()   , "", ".T.", "", ".T.", 80 , .F.}) //MV_PAR03
	aAdd(aPergs, {1, "Data Até      "         ,Date()   , "", ".T.", "", ".T.", 80 , .T.}) //MV_PAR04
	aAdd(aPergs,{1,"De centro de custo  ",Space(TamSx3('CTT_CUSTO')[1]),"","","CTT","",50,.F.}) 		        //MV_PAR05
	aAdd(aPergs,{1,"Ate centro de custo ",Space(TamSx3('CTT_CUSTO')[1]),"","","CTT","",50,.F.})		        //MV_PAR06
	aAdd(aPergs, {2, "Selecione :"		, "" , {"1=Consolidado","2=Individual"}  , 60 ,".T.",.T.})	//MV_PAR07
	aAdd(aPergs,{1,"De matricula: ",Space(TamSx3('P8_MAT')[1]),"","","SP8","",50,.F.})    //MV_PAR08
	aAdd(aPergs,{1,"Ate matricula: ",Space(TamSx3('P8_MAT')[1]),"","","SP8","",50,.F.})   //MV_PAR09

	If !ParamBox(aPergs,"Informe os Parametros ")
		Return
	EndIf

	If MV_PAR07 == '1'
		BeginSql Alias "cQuery"
			SELECT P8_DATA , P8_MAT, P8_CC ,num_registros , p8_FILIAL, CTT_DESC01,RA_NOME
			FROM (
			    SELECT P8_DATA , P8_MAT, P8_cc, p8_filial, COUNT(*) AS num_registros
			    FROM SP8010
				WHERE P8_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% 
				AND P8_DATA BETWEEN %Exp:DtoS(MV_PAR03)% AND %Exp:DtoS(MV_PAR04)% 
				AND P8_CC BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06% 
				AND P8_MAT BETWEEN %Exp:MV_PAR08% AND %Exp:MV_PAR09% 
			    GROUP BY p8_filial, P8_MAT ,P8_cc , P8_DATA  
			) AS contagem_registros
			INNER JOIN %Table:CTT% ON P8_CC = CTT_CUSTO
			INNER JOIN %Table:SRA% ON P8_MAT = RA_MAT
        	Where num_registros < 4
	    	GROUP BY CTT_DESC01,P8_mat ,P8_cc,p8_filial , num_registros,RA_NOME ,P8_DATA 
			Order by CTT_DESC01
		EndSql
	Else
		BeginSql Alias "cQuery"
			SELECT P8_DATA , P8_MAT, P8_CC ,num_registros , p8_FILIAL, CTT_DESC01,RA_NOME
			FROM (
			    SELECT P8_DATA , P8_MAT, P8_cc, p8_filial, COUNT(*) AS num_registros
			    FROM SP8010
				WHERE P8_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% 
				AND P8_DATA BETWEEN %Exp:DtoS(MV_PAR03)% AND %Exp:DtoS(MV_PAR04)% 
				AND P8_CC BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06% 
				AND P8_MAT BETWEEN %Exp:MV_PAR08% AND %Exp:MV_PAR09% 
			    GROUP BY  P8_MAT,p8_filial,P8_cc , P8_DATA  
			) AS contagem_registros
			INNER JOIN %Table:CTT% ON P8_CC = CTT_CUSTO
			INNER JOIN %Table:SRA% ON P8_MAT = RA_MAT
        	Where num_registros < 4
	    	GROUP BY RA_NOME ,P8_mat,p8_filial,CTT_DESC01 ,P8_cc , num_registros,P8_DATA 
			Order By RA_NOME
		EndSql
	EndIf

	oReport := reportDef()
	oReport:printDialog()

Return

Static Function reportDef()
	local oReport
	Local oSection1
//	Local oBreak
	local cTitulo := ' Relatório de Batidas não registradas ' //titulo do relatorio

	oReport := TReport():New('RELDP2', cTitulo, , {|oReport| PrintReport(oReport)},'Relatório de Batidas não registradas')
	oReport:SetPortrait()
	oReport:nFontBody := 06
	If MV_PAR07 == '1'
		//Primeira sessao
		oSection1:= TRSection():New(oReport, "Relatório de Batidas não registradas por Setor Consolidado", {"cQuery"}, , .F., .T., , , ,.F., .F.)
		oSection1:SetHeaderSection(.T.)
		TRCell():new(oSection1, "P8_FILIAL" , "cQuery", 'FILIAL'	          ,PesqPict('SP8',"P8_FILIAL")   ,TamSX3("P8_FILIAL")   [1]+2  	   ,,,  "LEFT")
		TRCell():new(oSection1, "P8_CC"     , "cQuery", 'Cod. C. de custo' ,PesqPict('SP8',"P8_CC")      ,TamSX3("P8_CC")  	[1]+2      ,,,  "LEFT")
		TRCell():New(oSection1, "CTT_DESC01", "cQuery", 'Desc. C. de custo',PesqPict('CTT',"CTT_DESC01")      ,TamSX3("CTT_DESC01")      [1]+2      ,,,  "LEFT")
		TRCell():New(oSection1, "P8_MAT"	, "cQuery", 'Matricula'        ,PesqPict('SP8',"P8_MAT")     ,TamSX3("P8_MAT")     [1]+3      ,,,  "LEFT")
		TRCell():New(oSection1, "RA_NOME"	, "cQuery", 'Nome'             ,PesqPict('SRA',"RA_NOME")  ,TamSX3("RA_NOME")  [1]/*+2*/  ,,,  "LEFT")
		TRCell():New(oSection1, "QUANT"	    , "cQuery", 'Quant. de dias'	  ,PesqPict('SP8',"P8_MAT")  ,TamSX3("P8_MAT")	[1]/*+2*/  ,,,  "LEFT")

	Else
		oSection1:= TRSection():New(oReport, "Relatório de Batidas não registradas Individual", {"cQuery"}, , .F., .T., , , ,.F., .F.)
		oSection1:SetHeaderSection(.T.)
		TRCell():new(oSection1, "P8_FILIAL" , "cQuery", 'FILIAL'	          ,PesqPict('SP8',"P8_FILIAL")   ,TamSX3("P8_FILIAL")   [1]+2  	   ,,,  "LEFT")
		TRCell():new(oSection1, "P8_CC"     , "cQuery", 'Cod. C. de custo' ,PesqPict('SP8',"P8_CC")      ,TamSX3("P8_CC")  	[1]+2      ,,,  "LEFT")
		TRCell():New(oSection1, "CTT_DESC01", "cQuery", 'Desc. C. de custo',PesqPict('CTT',"CTT_DESC01")      ,TamSX3("CTT_DESC01")      [1]+2      ,,,  "LEFT")
		TRCell():New(oSection1, "P8_MAT"	, "cQuery", 'Matricula'        ,PesqPict('SP8',"P8_MAT")     ,TamSX3("P8_MAT")     [1]+3      ,,,  "LEFT")
		TRCell():New(oSection1, "RA_NOME"	, "cQuery", 'Nome'             ,PesqPict('SRA',"RA_NOME")  ,TamSX3("RA_NOME")  [1]/*+2*/  ,,,  "LEFT")
		TRCell():New(oSection1, "P8_DATA"	, "cQuery", 'Data'	          ,PesqPict('SP8',"P8_DATA")  ,TamSX3("P8_DATA")	[1]/*+2*/  ,,,  "LEFT")
	EndIf
return (oReport)

Static Function PrintReport(oReport)
	Local oSection1 := oReport:Section(1)
	Local nTotalReg := 0

	DbSelectArea("cQuery")
	cQuery->(dbGoTop())
	oReport:SetMeter(cQuery->(RecCount()))
	oReport:IncMeter()
	oSection1:Init()
	oReport:SkipLine()

	If MV_PAR07 == '1'
		While cQuery->(!Eof())
			If oReport:Cancel()
				Exit'
			EndIf
			nTotalReg := 0
			cDescCC := cQuery->CTT_DESC01
			WHILE cQuery->CTT_DESC01 == cDescCC
				nTotalReg += 1
				oSection1:Cell("P8_FILIAL"):SetValue(cQuery->P8_FILIAL)
				oSection1:Cell("P8_FILIAL"):SetAlign("LEFT")
				oSection1:Cell("P8_CC"):SetValue(cQuery->P8_CC)
				oSection1:Cell("P8_CC"):SetAlign("LEFT")
				oSection1:Cell("CTT_DESC01"):SetValue(cQuery->CTT_DESC01)
				oSection1:Cell("CTT_DESC01"):SetAlign("LEFT")
				oSection1:Cell("P8_MAT"):SetValue(cQuery->P8_MAT)
				oSection1:Cell("P8_MAT"):SetAlign("LEFT")
				oSection1:Cell("RA_NOME"):SetValue(cQuery->RA_NOME)
				oSection1:Cell("RA_NOME"):SetAlign("LEFT")
				oSection1:Cell("QUANT"):SetValue("1")
				oSection1:Cell("QUANT"):SetAlign("RIGHT")
				oSection1:Printline()
				cQuery->(DbSkip())
			EndDO
			oSection1:Cell("P8_FILIAL"):SetValue(" ")
			oSection1:Cell("P8_FILIAL"):SetAlign("LEFT")
			oSection1:Cell("P8_CC"):SetValue("  ")
			oSection1:Cell("P8_CC"):SetAlign("LEFT")
			oSection1:Cell("CTT_DESC01"):SetValue(" TOTAL "+cDescCC+" ")
			oSection1:Cell("CTT_DESC01"):SetAlign("LEFT")
			oSection1:Cell("P8_MAT"):SetValue(" --------------> ")
			oSection1:Cell("P8_MAT"):SetAlign("LEFT")
			oSection1:Cell("RA_NOME"):SetValue(" ")
			oSection1:Cell("RA_NOME"):SetAlign("LEFT")
			oSection1:Cell("QUANT"):SetValue(cValToChar(nTotalReg))
			oSection1:Cell("QUANT"):SetAlign("RIGHT")
			oSection1:Printline()
			cQuery->(DbSkip())
		EndDo
		oSection1:Finish()
		cQuery->(DbCloseArea())
	Else
		While cQuery->(!Eof())
			If oReport:Cancel()
				Exit'
			EndIf
			nTotalReg := 0
			cDescCC := cQuery->RA_NOME
			WHILE cQuery->RA_NOME == cDescCC
				nTotalReg += 1
				oSection1:Cell("P8_FILIAL"):SetValue(cQuery->P8_FILIAL)
				oSection1:Cell("P8_FILIAL"):SetAlign("LEFT")
				oSection1:Cell("P8_CC"):SetValue(cQuery->P8_CC)
				oSection1:Cell("P8_CC"):SetAlign("LEFT")
				oSection1:Cell("CTT_DESC01"):SetValue(cQuery->CTT_DESC01)
				oSection1:Cell("CTT_DESC01"):SetAlign("LEFT")
				oSection1:Cell("P8_MAT"):SetValue(cQuery->P8_MAT)
				oSection1:Cell("P8_MAT"):SetAlign("LEFT")
				oSection1:Cell("RA_NOME"):SetValue(cQuery->RA_NOME)
				oSection1:Cell("RA_NOME"):SetAlign("LEFT")
				oSection1:Cell("P8_DATA"):SetValue(cQuery->P8_DATA)
				oSection1:Cell("P8_DATA"):SetAlign("LEFT")
				oSection1:Printline()
				cQuery->(DbSkip())
			EndDO
			oSection1:Cell("P8_FILIAL"):SetValue(" ")
			oSection1:Cell("P8_FILIAL"):SetAlign("LEFT")
			oSection1:Cell("P8_CC"):SetValue("  ")
			oSection1:Cell("P8_CC"):SetAlign("LEFT")
			oSection1:Cell("CTT_DESC01"):SetValue(" TOTAL "+cDescCC+" ")
			oSection1:Cell("CTT_DESC01"):SetAlign("LEFT")
			oSection1:Cell("P8_MAT"):SetValue(" --------------> ")
			oSection1:Cell("P8_MAT"):SetAlign("LEFT")
			oSection1:Cell("RA_NOME"):SetValue(" ")
			oSection1:Cell("RA_NOME"):SetAlign("LEFT")
			oSection1:Cell("P8_DATA"):SetValue(cValToChar(nTotalReg)+" DIAS" )
			oSection1:Cell("P8_DATA"):SetAlign("LEFT")
			oSection1:Printline()
			cQuery->(DbSkip())
		EndDo
		oSection1:Finish()
		cQuery->(DbCloseArea())
	EndIF

Return
