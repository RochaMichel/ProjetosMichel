
User Function RFATRANS()
	Local	aPergs	 := {}
	Private oReport  := Nil
	Private oSecCab	 := Nil

	//cria um array com as perguntas que serão passado como parâmetros
	aAdd( aPergs ,{1,"De  Cod Produto  "	, space(TamSX3("B1_COD")[1]),"@!",'.T.','','.T.',TamSX3("B1_COD")[1]+50,.F.})//MV_PAR01
	aAdd( aPergs ,{1,"Até Cod Produto "	, space(TamSX3("B1_COD")[1]),"@!",'.T.','','.T.',TamSX3("B1_COD")[1]+50,.F.})//MV_PAR02
	
	//se não criar as perguntas finaliza o processo  
	If !ParamBox(aPergs ,"Parametros ")
		Return
	EndIf

	//aqui é passado a query 
	cQry := " SELECT DESCRICAO=B1_DESC, TIPO=B1_TIPO, CODIGO=B1_COD, UNIDADE=B1_UM "
	cQry += " FROM "+RetSqlName("SB1")+" SB1"
	cQry += " WHERE B1_COD BETWEEN '"+(MV_PAR01)+"' AND '"+(MV_PAR02)+"' "
	cQry += " AND B1_TIPO  = 'MP' OR B1_TIPO = 'PA' "
	cQry += " AND SB1.D_E_L_E_T_ = '' "
	cQry += " GROUP BY B1_COD,B1_TIPO,B1_DESC,B1_UM "
	cQry += " ORDER BY B1_COD,B1_TIPO,B1_DESC,B1_UM "

	MpSysOpenQuery(cQry,"TEMP1")//passa o resultado da query para uma tabela temporaria 
	oReport := reportDef()
	oReport:printDialog()
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} reportDef
Função que monta o relatório
@type function
@version 1.0
@author Cod.ERP
@since 03/05/2022

/*/
//-------------------------------------------------------------------
static function reportDef()
	local oReport
	Local oSection1
	local cTitulo := 'RFATRANS - Relatório de PRODUTOS ACABADOS E MATERIA PRIMA' //titulo do relatório
	oReport := TReport():New('RFATRANS', cTitulo, , {|oReport| PrintReport(oReport)},"Impressão de Relatório de Produto")
	oReport:SetPortrait()

	//Primeira sessssão contendo os dados do vendedor
	oSection1:= TRSection():New(oReport, "Produtos acabados", {"QRY"}, , .F., .T., , , ,.F., .F.)
	oSection1:SetHeaderSection(.T.)

	TRCell():New(oSection1, "B1_DESC"	, "QRY", 'DESCRICAO',	PesqPict('SB1',"B1_DESC"),TamSX3("B1_DESC")[1]+2,,,"LEFT")
	TRCell():new(oSection1, "B1_TIPO"	, "QRY", 'TIPO'		,	PesqPict('SB1',"B1_TIPO"),TamSX3("B1_TIPO")[1]+2,,,"LEFT")
	TRCell():new(oSection1, "B1_COD"	, "QRY", 'CODIGO'	,	PesqPict('SB1',"B1_COD"),TamSX3("B1_COD")[1]+2,,,"LEFT")
	TRCell():new(oSection1, "B1_UM"		, "QRY", 'UNIDADE'	,	PesqPict('SB1',"B1_UM"),TamSX3("B1_UM")[1]+2,,,"LEFT")


return (oReport)
Static Function PrintReport(oReport)
	Local oSection1 := oReport:Section(1)

	DbSelectArea('TEMP1')//seleciona a tabela temporaria 

	dbGoTop()//parte do primeiro registro

	oReport:SetMeter(TEMP1->(RecCount()))
	oReport:IncMeter()
	IncProc("Imprimindo Relatório")

	oSection1:Init()//inicia a impressão
	
	//enquanto for diferente de final de arquivo
	While TEMP1->(!Eof())
		If oReport:Cancel() // se cancelar a impressão 
			Exit //sai da impressão
		EndIf

		//imprimo a primeira sessão
		oSection1:Cell("B1_DESC"):SetAlign("LEFT")
		oSection1:Cell("B1_DESC"):SetValue(TEMP1->DESCRICAO)
		oSection1:Cell("B1_TIPO"):SetAlign("LEFT")
		oSection1:Cell("B1_TIPO"):SetValue(TEMP1->TIPO)
		oSection1:Cell("B1_COD"):SetAlign("LEFT")
		oSection1:Cell("B1_COD"):SetValue(TEMP1->CODIGO)
		oSection1:Cell("B1_UM"):SetAlign("LEFT")
		oSection1:Cell("B1_UM"):SetValue(TEMP1->UNIDADE)
        oSection1:Printline()

		TEMP1->(DbSkip()) //pula para o próximo registro 

	Enddo

	oSection1:Finish() //finaliza a seção

	TEMP1->(DbCloseArea())//fecha a tabela temporaria 
Return
