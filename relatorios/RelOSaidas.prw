#INCLUDE "Totvs.ch"
/*/{Protheus.doc} CodERP01
RelatÃ³rio CODERP01
@type function
@version 12.1.33
@author Michel Rocha CodERP
@since 13/10/2022
@return variant, Nill
/*/
User Function RelOSaidas()
    PRIVATE cTitulo     := 'Relatorio de Outras Saidas'
	PRIVATE cDescri     := 'Estoque'
	PRIVATE cFunName    := FunName()
	PRIVATE oRelatorio
	PRIVATE aPergs      := {}

	aAdd(aPergs, {1, "Filial"      ,space(TamSX3("D2_FILIAL")[1]),PesqPict("SD2","D2_FILIAL"),,"SM0",,40, .F.}) //MV_PAR01
	aAdd(aPergs, {1, "Ate Filial"  ,space(TamSX3("D2_FILIAL")[1]),PesqPict("SD2","D2_FILIAL"),,"SM0",,40, .T.}) //MV_PAR02
	aAdd(aPergs, {1, "Data"        ,Date()   , "", ".T.", "", ".T.", 80 , .F.}) //MV_PAR03
	aAdd(aPergs, {1, "Ate Data"    ,Date()   , "", ".T.", "", ".T.", 80 , .T.}) //MV_PAR04
	aAdd(aPergs, {2, "Selecione o tipo de relatorio ","analitico" , {"analitico" , "sintetico"}  , 60 ,".T.",.F.}) //MV_PAR05
	aAdd(aPergs, {1, "Grupo",  space(TamSX3("B1_GRUPO")[1]),  "", ".T.", "SBM", ".T.", 80,  .F.}) //MV_PAR06
	aAdd(aPergs, {1, "Ate Grupo",  space(TamSX3("B1_GRUPO")[1]),  "", ".T.", "SBM", ".T.", 80,  .T.}) //MV_PAR07

	If !parambox(aPergs,"Informe os parametros")
		Return
	EndIf

	oRelatorio  := TReport():New(cFunName, cTitulo,, {|oRelatorio| PrintReport(oRelatorio)}, cDescri)
	oRelatorio:SetCustomText({||CriaCab(oRelatorio)})

	oSection1   := TRSection():New(oRelatorio, 'Outras saidas'+" da Data "+Dtoc(MV_PAR03)+" Até "+Dtoc(MV_PAR04), {'SD2'})

	If MV_PAR05 == "sintetico"
		TRCell():New(oSection1, "D2_COD"     , "SD2" ,"Codigo"           ,PesqPict( "SD2", "D2_COD"  )     ,TamSX3("D2_COD"  )[1],/*lPixel*/  ,{|| QERY->D2_COD   },"LEFT",,"LEFT",,,,,,,)
		TRCell():New(oSection1, "B1_DESC"    , "SB1" ,"Desc do produto"  ,PesqPict( "SB1", "B1_DESC"  )    ,TamSX3("B1_DESC"  )[1],/*lPixel*/,{|| QERY->B1_DESC   },"LEFT",,"LEFT",,,,,,,)
		TRCell():New(oSection1, "D2_UM"      , "SD2" ,"Und"          ,PesqPict( "SD2", "D2_UM" )       ,TamSX3("D2_UM")[1],/*lPixel*/           ,{|| QERY->D2_UM  },"CENTER",,"CENTER",,,,,,,)
		TRCell():New(oSection1, "D2_LOCAL"   , "SD2" ,"Codigo do Armazem",PesqPict( "SD2", "D2_LOCAL" )    ,TamSX3("D2_LOCAL" )[1],/*lPixel*/,{|| QERY->D2_LOCAL  },"CENTER",,"CENTER",,,,,,,)
		TRCell():New(oSection1, "D2_CONTA"   , "SD2" ,"Conta contabil",PesqPict( "SD2", "D2_CONTA" )    ,TamSX3("D2_CONTA" )[1],/*lPixel*/   ,{|| QERY->D2_CONTA  },"CENTER",,"CENTER",,,,,,,)
		TRCell():New(oSection1, "D2_Quant"   , "SD2" ,"Quantidade"       ,PesqPict( "SD2", "D2_QUANT" )    ,TamSX3("D2_QUANT" )[1],/*lPixel*/   ,{|| QERY->QUANT  },"RIGHT",,"RIGHT",,,,,,,)
		TRCell():New(oSection1, "D2_CUSTO1"  , "SD2" ,"Custo"      ,PesqPict( "SD2", "D2_CUSTO1"   ) ,TamSX3("D2_CUSTO1"   )[1],/*lPixel*/    ,{|| QERY->CUSTO    },"RIGHT",,"RIGHT",,,,,,,)
	Else
		TRCell():New(oSection1, "D2_COD"     , "SD2"  ,"Codigo"           ,PesqPict( "SD2", "D2_COD"  )     ,TamSX3("D2_COD"  )[1],/*lPixel*/  ,{|| QERY->D2_COD   },"LEFT",,"LEFT",,,,,,,)
		TRCell():New(oSection1, "B1_DESC"    , "SB1"  ,"Desc do produto"  ,PesqPict( "SB1", "B1_DESC"  )    ,TamSX3("B1_DESC"  )[1],/*lPixel*/,{|| QERY->B1_DESC   },"LEFT",,"LEFT",,,,,,,)
		TRCell():New(oSection1, "D2_UM"      , "SD2"  ,"Und"          ,PesqPict( "SD2", "D2_UM" )       ,TamSX3("D2_UM")[1],/*lPixel*/           ,{|| QERY->D2_UM  },"CENTER",,"CENTER",,,,,,,)
		TRCell():New(oSection1, "D2_LOCAL"   , "SD2"  ,"Arm",PesqPict( "SD2", "D2_LOCAL" )    ,TamSX3("D2_LOCAL" )[1],/*lPixel*/              ,{|| QERY->D2_LOCAL  },"CENTER",,"CENTER",,,,,,,)
		TRCell():New(oSection1, "D2_CONTA"   , "SD2"  ,"Conta contabil",PesqPict( "SD2", "D2_CONTA" )    ,TamSX3("D2_CONTA" )[1],/*lPixel*/   ,{|| QERY->D2_CONTA  },"CENTER",,"CENTER",,,,,,,)
		TRCell():New(oSection1, "D2_TES"     , "SD2"  ,"Tipo de Mov."     ,PesqPict( "SD2", "D2_TES")        ,TamSX3("D2_TES")[1],/*lPixel*/     ,{|| QERY->D2_TES },"CENTER",,"CENTER",,,,,,,)
		TRCell():New(oSection1, "D2_CF"      , "SD2"  ,"Tipo de Req."          ,PesqPict( "SD2", "D2_CF")        ,TamSX3("D2_CF")[1],/*lPixel*/   ,{|| QERY->D2_CF },"CENTER",,"CENTER",,,,,,,)
		TRCell():New(oSection1, "D2_DOC"     , "SD2"  ,"Doc"     ,PesqPict( "SD2", "D2_DOC")        ,TamSX3("D2_DOC")[1],/*lPixel*/              ,{|| QERY->D2_DOC },"CENTER",,"CENTER",,,,,,,)
		TRCell():New(oSection1, "D2_EMISSAO" , "SD2" ,"Data"  ,PesqPict( "SD2", "D2_EMISSAO"  ) ,12,/*lPixel*/                               ,{|| QERY->D2_EMISSAO },"CENTER",,"CENTER",,,,,,,)
		TRCell():New(oSection1, "D2_Quant"   , "SD2" ,"Quantidade"       ,PesqPict( "SD2", "D2_QUANT" )    ,TamSX3("D2_QUANT" )[1],/*lPixel*/ ,{|| QERY->D2_QUANT  },"RIGHT",,"RIGHT",,,,,,,)
		TRCell():New(oSection1, "D2_CUSTO1"  , "SD2" ,"custo"      ,PesqPict( "SD2", "D2_CUSTO1"   ) ,TamSX3("D2_CUSTO1"   )[1],/*lPixel*/     ,{|| QERY->CUSTO    },"RIGHT",,"RIGHT",,,,,,,)
	EndIf
	oRelatorio:PrintDialog()
Return

Static Function PrintReport(oRelatorio)
	Local oSection1 := oRelatorio:section(1)

	oSection1:BeginQuery()

	If MV_PAR05 == "sintetico"
		BeginSql Alias "QERY"
	 		Select B1_DESC, Sum(D2_QUANT) Quant ,D2_COD,D2_UM, sum(D2_CUSTO1) custo ,D2_LOCAL,D2_CONTA from %Table:SD2% D2
	 		Inner Join %Table:SB1% B1 ON B1_COD = D2_COD 
	 		Where D2_CF In('6900','6901','6902','6903','6904','6905','6906','6907','6908','6909','6910','6911','6912','6913','6914','6915','6916','6917','6918','6919','6920','6921','6922','6923','6924','6925','6926','6927','6928','6929','6930','6931','6932','6933','6934','6935','6936','6937','6938','6939','6940','6941','6942','6943','6944','6945','6946','6947','6948','6949','5900','5901','5902','5903','5904','5905','5906','5907','5908','5909','5910','5911','5912','5913','5914','5915',	'5916','5917','5918','5919','5920','5921','5922','5923','5924','5925','5926','5927',	'5928',	'5929'	,'5930',	'5931',	'5932'	,'5933'	 ,'5934'	,'5935',	'5936',	'5937'	,'5938',	'5939',	'5940'	,'5941'	,'5942',	'5943',	'5944',	'5945'	,'5946'	,'5947'	,'5948','5949','5949','5124','5125','6124','6125')
     	    AND D2_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
	 		AND D2_EMISSAO BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			AND B1_GRUPO BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR07%
      		Group by B1_DESC, D2_LOCAL,D2_COD, D2_CONTA,D2_UM
		EndSql
	Else
		BeginSql Alias "QERY"
	 		Select B1_DESC, D2_QUANT ,D2_COD,D2_UM, D2_CUSTO1 as custo ,D2_LOCAL,D2_CF,D2_DOC, D2_TES, D2_EMISSAO,D2_CONTA from %Table:SD2% D2
	 		Inner Join %Table:SB1% B1 ON B1_COD = D2_COD
	 		Where D2_CF In('6900','6901','6902','6903','6904','6905','6906','6907','6908','6909','6910','6911','6912','6913','6914','6915','6916','6917','6918','6919','6920','6921','6922','6923','6924','6925','6926','6927','6928','6929','6930','6931','6932','6933','6934','6935','6936','6937','6938','6939','6940','6941','6942','6943','6944','6945','6946','6947','6948','6949','5900','5901','5902','5903','5904','5905','5906','5907','5908','5909','5910','5911','5912','5913','5914','5915','5916','5917','5918','5919','5920','5921','5922','5923','5924','5925','5926','5927',	'5928',	'5929'	,'5930',	'5931',	'5932'	,'5933'	,'5934','5935','5936','5937','5938','5939','5940','5941','5942','5943','5944','5945','5946','5947','5948','5949','5949','5124','5125','6124','6125')
			AND D2_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
	 		AND D2_EMISSAO BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			AND B1_GRUPO BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR07%
		EndSql
	EndIf

	oSection1:EndQuery()
	oSection1:Print()

Return

Static Function CriaCab( oRelatorio )
	Local aArea		:= GetArea()
	Local aCabec	:= {}
	Local cChar		:= chr(160)
	local _cEmp 	:= FWCodEmp()


	_DataDe := DToC(MV_PAR03)
	_DataAte:= DToC(MV_PAR04)

	aCabec := {TRANSFORM(oRelatorio:Page(),'999999');
		, Padc(UPPER("Relatorio de Outras Saidas - ") + FWFilialName(_cEmp),132);
		, Padc("",132);
		, Padc(UPPER('Período de '+_DataDe+' até '+_DataAte),132);
		, "Hora: " + time() ;
		+ cChar + "          Emissão: " + Dtoc(dDataBase)}

	RestArea( aArea )

Return aCabec
