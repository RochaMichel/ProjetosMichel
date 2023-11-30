#include "PROTHEUS.CH"
#include "TBICONN.ch"


*-------------------------------------------------------------------------------------
************************************************************************************ X
/*@nomeFunction: 	  				  U_RelNtFim()						   		  */ *
/*--------------------------------------------------------------------------------*/ *
/*			Rotina de envio de relatorio MetaFim em Anexo e no corpo do e-mail	  */ *
/*--------------------------------------------------------------------------------*/ *
/*@author: 						Rivaldo.Júnior - CodERP							  */ *
/*@since: 				    	  	   10/11/2022								  */ *
************************************************************************************ X
*-------------------------------------------------------------------------------------
User Function RelNtFim(aParam)
	Local cSubject		As Character
	Local aDados		As Array
	Private _DaData		As Character
	Private _AteData	As Character

	If Isblind()
		Prepare Environment Empresa aParam[1] Filial aParam[2]
	EndIf

	_DaData 	:= dtoc(FirstDate(MonthSub(dDataBase,1)))
	_AteData 	:= dtoc(LastDate(MonthSub(dDataBase,1)))

	aDados		:= Relatorio()
	cTo			:= "fecona5393geekjun@outlook.com"
	cSubject 	:= EncodeUTF8("Relatorio NetaFim de " +_DaData+" Ate "+_AteData, "cp1251")


	U_pbMandaEmail(cTo,nil,nil,cSubject,nil,aDados[1],nil,aDados[2],nil,nil,nil)

	If Isblind()
		Reset Environment
	EndIf

Return


	*-------------------------------------------------------------------------------------
	************************************************************************************ X
/*@nomeFunction: 	  				  Relatorio()						   		  */ *
/*--------------------------------------------------------------------------------*/ *
/*					Faz a busca pelos dados que irão compor o relatório			  */ *
/*--------------------------------------------------------------------------------*/ *
/*@type: 							    function								  */ *
/*@author: 						Rivaldo.Júnior - CodERP							  */ *
/*@since: 				    	  	   10/11/2022								  */ *
/*@return: 				variant, path do rel. excel e body do html				  */ *
	************************************************************************************ X
	*-------------------------------------------------------------------------------------
Static Function Relatorio()
	Local cPath		As Character
	Local cQry		As Character
	Local aProd		As Array
	Local aCli		As Array
	Local aVend		As Array
	Local aVendas	As Array

	*** AQUI O CADASTRO DE PRODUTOS ***
	cQry := "	SELECT CODIGO=B1_COD,DESCRI=B1_DESC,CODFOR=B1_CODFOR,NGUERRA=B1_NGUERRA	"
	cQry += "	FROM "+RetSqlName("SB1")+" B1 											"
	cQry += "	WHERE B1_CODFOR= 'F1'													"
	cQry += "	AND B1.D_E_L_E_T_=''													"
	MpSysOpenQuery(cQry,"cQry")
	DbSelectArea("cQry")
	aProd := {}

	While cQry->(!Eof())
		aAdd(aProd			,;
			{cQry->CODIGO	,;
			cQry->DESCRI	,;
			cQry->CODFOR	,;
			cQry->NGUERRA	})
		cQry->(DbSkip())
	End
	cQry->(DbCloseArea())

	*** AQUI CADASTRO CLIENTES ***
	cQry := "	SELECT RAZAO=A1_NOME, MUN=A1_MUN, UF=A1_EST,VENDEDOR=A3_NENOME,DISTRIBUICAO='NE ATACADO',												"
	cQry += "	FILIAL=(CASE WHEN D2_FILIAL='01' THEN 'RECIFE' ELSE																						"
	cQry += "	       (CASE WHEN D2_FILIAL='03' THEN 'FORTALEZA' ELSE																					"
	cQry += "	       (CASE WHEN D2_FILIAL='04' THEN 'PETROLINA' ELSE																					"
	cQry += "	       (CASE WHEN D2_FILIAL='06' THEN 'FEIRA' ELSE																						"
	cQry += "	       (CASE WHEN D2_FILIAL='08' THEN 'ITABAIANA' ELSE																					"
	cQry += "	       (CASE WHEN D2_FILIAL='10' THEN 'TERESINA' ELSE																					"
	cQry += "	       (CASE WHEN D2_FILIAL='11' THEN 'CONQUISTA' END)END)END)END)END)END)END)															"
	cQry += "	FROM "+RetSqlName("SD2")+" D2, "+RetSqlName("SA1")+" A1, "+RetSqlName("SB1")+" B1, "+RetSqlName("SF2")+" F2, "+RetSqlName("SA3")+" A3	"
	cQry += "	WHERE  A1.D_E_L_E_T_='' AND B1.D_E_L_E_T_='' AND  A3.D_E_L_E_T_='' AND F2.D_E_L_E_T_='' AND D2.D_E_L_E_T_=''							"
	cQry += "	AND D2_CLIENTE=A1_COD AND D2_LOJA=A1_LOJA AND F2.F2_FILIAL=D2.D2_FILIAL AND F2.F2_DOC=D2.D2_DOC 										"
	cQry += "	AND F2.F2_SERIE = D2.D2_SERIE AND B1_COD=D2_COD AND A3_COD=F2_VEND1																		"
	cQry += "	AND D2_EMISSAO BETWEEN '"+_DaData+"' AND '"+_AteData+"'  																				"
	cQry += "	AND SUBSTRING(D2.D2_CF,2,3) IN ('12 ','102','922','108')																				"
	cQry += "	and B1_CODFOR= 'F1'  																													"
	cQry += "	GROUP BY A1_NOME, A1_MUN, A1_EST,A3_NENOME,D2_FILIAL																					"
	cQry += "	ORDER BY 6,4																															"
	MpSysOpenQuery(cQry,"cQry")
	DbSelectArea("cQry")
	aCli := {}

	While cQry->(!Eof())
		aAdd(aCli				,;
			{cQry->RAZAO			,;
			cQry->MUN			,;
			cQry->UF			,;
			cQry->VENDEDOR		,;
			cQry->DISTRIBUICAO	,;
			cQry->FILIAL		})
		cQry->(DbSkip())
	End
	cQry->(DbCloseArea())

	*** AQUI CADASTRO VENDEDORES ***
	cQry := "	SELECT VENDEDOR=A3_NENOME,DISTRIBUICAO='NE ATACADO',																					"
	cQry += "	FILIAL=(CASE WHEN D2_FILIAL='01' THEN 'RECIFE' ELSE																						"
	cQry += "	       (CASE WHEN D2_FILIAL='03' THEN 'FORTALEZA' ELSE																					"
	cQry += "	       (CASE WHEN D2_FILIAL='04' THEN 'PETROLINA' ELSE																					"
	cQry += "	       (CASE WHEN D2_FILIAL='06' THEN 'FEIRA' ELSE																						"
	cQry += "	       (CASE WHEN D2_FILIAL='08' THEN 'ITABAIANA' ELSE																					"
	cQry += "	       (CASE WHEN D2_FILIAL='10' THEN 'TERESINA' ELSE																					"
	cQry += "	          (CASE WHEN D2_FILIAL='11' THEN 'CONQUISTA' END)END)END)END)END)END)END)														"
	cQry += "	FROM "+RetSqlName("SD2")+" D2, "+RetSqlName("SA1")+" A1, "+RetSqlName("SB1")+" B1, "+RetSqlName("SF2")+" F2, "+RetSqlName("SA3")+" A3	"
	cQry += "	WHERE  A1.D_E_L_E_T_='' AND B1.D_E_L_E_T_='' AND  A3.D_E_L_E_T_='' AND F2.D_E_L_E_T_='' AND D2.D_E_L_E_T_=''							"
	cQry += "	AND D2_CLIENTE=A1_COD AND D2_LOJA=A1_LOJA AND F2.F2_FILIAL=D2.D2_FILIAL 																"
	cQry += "	AND F2.F2_DOC=D2.D2_DOC AND F2.F2_SERIE = D2.D2_SERIE AND B1_COD=D2_COD AND A3_COD=F2_VEND1												"
	cQry += "	AND D2_EMISSAO BETWEEN '"+_DaData+"' AND '"+_AteData+"'  																				"
	cQry += "	AND SUBSTRING(D2.D2_CF,2,3) IN ('12 ','102','922','108')																				"
	cQry += "	and B1_CODFOR= 'F1'  																													"
	cQry += "	GROUP BY A3_NENOME,D2_FILIAL																											"
	cQry += "	ORDER BY 3,1																															"
	MpSysOpenQuery(cQry,"cQry")
	DbSelectArea("cQry")
	aVend := {}

	While cQry->(!Eof())
		aAdd(aVend				,;
			{cQry->VENDEDOR		,;
			cQry->DISTRIBUICAO	,;
			cQry->FILIAL		})
		cQry->(DbSkip())
	End
	cQry->(DbCloseArea())

	*** AQUI VENDAS ***
	cQry := "	SELECT DISTRIBUICAO='NE ATACADO',																										"
	cQry += "	FILIAL=(CASE WHEN D2_FILIAL='01' THEN 'RECIFE' ELSE																						"
	cQry += "	       (CASE WHEN D2_FILIAL='03' THEN 'FORTALEZA' ELSE																					"
	cQry += "	       (CASE WHEN D2_FILIAL='04' THEN 'PETROLINA' ELSE																					"
	cQry += "	       (CASE WHEN D2_FILIAL='06' THEN 'FEIRA' ELSE																						"
	cQry += "	       (CASE WHEN D2_FILIAL='08' THEN 'ITABAIANA' ELSE																					"
	cQry += "	       (CASE WHEN D2_FILIAL='10' THEN 'TERESINA' ELSE																					"
	cQry += "	       (CASE WHEN D2_FILIAL='11' THEN 'CONQUISTA' END)END)END)END)END)END)END), 														"
	cQry += "	DATA=SUBSTRING(F2.F2_EMISSAO,7,2)+'/'+SUBSTRING(F2.F2_EMISSAO,5,2)+'/'+LEFT(F2.F2_EMISSAO,4),											"
	cQry += "	CODPROD=B1_COD, DESCRI=B1_DESC, VENDEDOR=A3_NENOME, RAZAO_CLIENTE=A1_NOME, MUN=A1_MUN, UF=A1_EST, QTD=D2_QUANT, PRECO=D2_PRCVEN			"
	cQry += "	FROM "+RetSqlName("SD2")+" D2, "+RetSqlName("SA1")+" A1, "+RetSqlName("SB1")+" B1, "+RetSqlName("SF2")+" F2, "+RetSqlName("SA3")+" A3	"
	cQry += "	WHERE  A1.D_E_L_E_T_='' AND B1.D_E_L_E_T_='' AND  A3.D_E_L_E_T_='' AND F2.D_E_L_E_T_='' AND D2.D_E_L_E_T_=''							"
	cQry += "	AND D2_CLIENTE=A1_COD AND D2_LOJA=A1_LOJA AND F2.F2_FILIAL=D2.D2_FILIAL AND F2.F2_DOC=D2.D2_DOC 										"
	cQry += "	AND F2.F2_SERIE = D2.D2_SERIE AND B1_COD=D2_COD AND A3_COD=F2_VEND1																		"
	cQry += "	AND D2_EMISSAO BETWEEN '"+_DaData+"' AND '"+_AteData+"'  																				"
	cQry += "	AND SUBSTRING(D2.D2_CF,2,3) IN ('12 ','102','922','108')																				"
	cQry += "	and B1_CODFOR= 'F1' "																													"
	cQry += "	ORDER BY 2,D2_EMISSAO																													"
	MpSysOpenQuery(cQry,"cQry")
	DbSelectArea("cQry")
	aVendas := {}

	While cQry->(!Eof())
		aAdd(aVendas			,;
			{cQry->DISTRIBUICAO	,;
			cQry->FILIAL		,;
			cQry->DATA			,;
			cQry->CODPROD		,;
			cQry->DESCRI		,;
			cQry->VENDEDOR		,;
			cQry->RAZAO_CLIENTE	,;
			cQry->MUN			,;
			cQry->UF			,;
			cQry->QTD			,;
			cQry->PRECO			})
		cQry->(DbSkip())
	End
	cQry->(DbCloseArea())

	cPath := GeraExcel(aProd, aCli, aVend, aVendas)
	cBody := FormaBody(aProd, aCli, aVend, aVendas)

Return {cBody,cPath}


	*-------------------------------------------------------------------------------------
	************************************************************************************ X
/*@nomeFunction: 	  				  GeraExcel()						   		  */ *
/*--------------------------------------------------------------------------------*/ *
/*					Função para gerar a planilha em excel para anexo			  */ *
/*--------------------------------------------------------------------------------*/ *
/*@type: 								function								  */ *
/*@author: 						Rivaldo.Júnior - CodERP							  */ *
/*@since: 				    	  	   10/11/2022								  */ *
/*@return:     			character, cPath, caminho do arquivo salvo				  */ *
	************************************************************************************ X
	*-------------------------------------------------------------------------------------
Static Function GeraExcel(aProd, aCli, aVend, aVendas)
	Local cArquivo    := GetTempPath()+'zTstExc2c.xml'
	Local oFWMSEx        := FWMsExcelEx():New()
	Local oExcel
	local i

	oFWMSEx:SetCelBold(.F.)             
	oFWMSEx:SetCelFont('Calibri')         //estilo da fonte da tabela
	oFWMSEx:SetCelSizeFont(11)            //Tamanho da fonte da tabela
	oFWMSEx:SetBgGeneralColor('#FFFFFF')  //Cor do fundo da tabela 
	oFWMSEx:SetFrColorHeader('#FFFFFF')   //Cor da fonte do cabeçario
	oFWMSEx:SetBgColorHeader('#FF0000')   //Cor de fundo do cabeçario
	oFWMSEx:SetTitleFrColor('#000000')	  //Cor do titulo ta tabela
	oFWMSEx:SetTitleSizeFont(12)		  //Tamanho da fonte do titulo
	oFWMSEx:SetTitleBold(.T.)			  //Definindo o titulo como negrito
	//Criando a Aba Teste 1
	oFWMSEx:AddworkSheet("Prod")
	//Adicionando a tabela
	oFWMSEx:AddTable ("Prod","CADASTRO DE PRODUTOS")
	//Adicionando Colunas
	oFWMSEx:AddColumn("Prod","CADASTRO DE PRODUTOS","Código",2,1,.F.)
	oFWMSEx:AddColumn("Prod","CADASTRO DE PRODUTOS","Descrição",2,1,.F.)
	oFWMSEx:AddColumn("Prod","CADASTRO DE PRODUTOS","Fornecedor",2,1,.F.)
	oFWMSEx:AddColumn("Prod","CADASTRO DE PRODUTOS","NGuerra",2,1,.F.)

	for i:= 1 to len(aProd)
		oFWMSEx:AddRow("Prod","CADASTRO DE PRODUTOS",{aProd[i][1], aprod[i][2], aprod[i][3], aprod[i][4]})
	next i

	oFWMSEx:AddworkSheet("Cli")
	//Adicionando a tabela
	oFWMSEx:AddTable ("Cli","Cadastro De Clientes")
	//Adicionando Colunas
	oFWMSEx:AddColumn("Cli","Cadastro De Clientes","Razão",2,1,.F.)
	oFWMSEx:AddColumn("Cli","Cadastro De Clientes","Mun",2,1,.F.)
	oFWMSEx:AddColumn("Cli","Cadastro De Clientes","Uf ",2,1,.F.)
	oFWMSEx:AddColumn("Cli","Cadastro De Clientes","Vendedor",2,1,.F.)
	oFWMSEx:AddColumn("Cli","Cadastro De Clientes","Distribuição",2,1,.F.)
	oFWMSEx:AddColumn("Cli","Cadastro De Clientes","Filial",2,1,.F.)
	//Adicionando as Linhas
	for i:= 1 to len(aCli)
		oFWMSEx:AddRow("Cli","Cadastro De Clientes",{aCli[i][1], aCli[i][2], aCli[i][3], aCli[i][4], aCli[i][5], aCli[i][6] })
	next i

	oFWMSEx:AddworkSheet("Vend")
	//Adicionando a tabela
	oFWMSEx:AddTable ("Vend","Cadastro De Vendedores")
	//Adicionando Colunas
	oFWMSEx:AddColumn("Vend","Cadastro De Vendedores","Vendedor",2,1,.F.)
	oFWMSEx:AddColumn("Vend","Cadastro De Vendedores","Destribuição",2,1,.F.)
	oFWMSEx:AddColumn("Vend","Cadastro De Vendedores","Filial",2,1,.F.)
	//Adicionando as Linhas
	for i:= 1 to len(aVend)
		oFWMSEx:AddRow("Vend","Cadastro De Vendedores",{aVend[i][1], aVend[i][2], aVend[i][3] })
	next i

	oFWMSEx:AddworkSheet("Vendas")
	//Adicionando a tabela
	oFWMSEx:AddTable ("Vendas","Registro de Vendas")
	//Adicionando Colunas
	oFWMSEx:AddColumn("Vendas","Registro de Vendas","Distribuição",2,1,.F.)
	oFWMSEx:AddColumn("Vendas","Registro de Vendas","Filial",2,1,.F.)
	oFWMSEx:AddColumn("Vendas","Registro de Vendas","Data",2,1,.F.)
	oFWMSEx:AddColumn("Vendas","Registro de Vendas","CodProd",2,1,.F.)
	oFWMSEx:AddColumn("Vendas","Registro de Vendas","Descrição",2,1,.F.)
	oFWMSEx:AddColumn("Vendas","Registro de Vendas","Vendedor",2,1,.F.)
	oFWMSEx:AddColumn("Vendas","Registro de Vendas","Razão Cliente",2,1,.F.)
	oFWMSEx:AddColumn("Vendas","Registro de Vendas","Mun",2,1,.F.)
	oFWMSEx:AddColumn("Vendas","Registro de Vendas","UF",2,1,.F.)
	oFWMSEx:AddColumn("Vendas","Registro de Vendas","Quantidade",2,2,.F.)
	oFWMSEx:AddColumn("Vendas","Registro de Vendas","Preço",2,2,.F.)
	//Adicionando as Linhas
	for i:= 1 to len(aVendas)
		oFWMSEx:AddRow("Vendas","Registro de Vendas",{aVendas[i][1], aVendas[i][2], aVendas[i][3], aVendas[i][4], aVendas[i][5], aVendas[i][6], aVendas[i][7], aVendas[i][8], aVendas[i][9], CValToChar(aVendas[i][10]), CValToChar(aVendas[i][11]) })
	next i

	//Criando o XML
	oFWMSEx:Activate()
	oFWMSEx:GetXMLFile(cArquivo)

	oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
	oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
	oExcel:SetVisible(.T.)                 //Visualiza a planilha
	oExcel:Destroy()                        //Encerra o proc

Return



	*-------------------------------------------------------------------------------------
	************************************************************************************ X
/*@nomeFunction: 	  				  FormaBody()						   		  */ *
/*--------------------------------------------------------------------------------*/ *
/*							Forma o corpo do email em HTML						  */ *
/*--------------------------------------------------------------------------------*/ *
/*@type: 								function								  */ *
/*@author: 						Rivaldo.Júnior - CodERP							  */ *
/*@since: 				    	  	   10/11/2022								  */ *
/*@return:	 variant, corpo em html do email									  */ *
	************************************************************************************ X
	*-------------------------------------------------------------------------------------
Static Function FormaBody(aProd, aCli, aVend, aVendas)
	Local cBody 	As Character
	Local nX		As Numeric

	cBody :=  "   <div style='font-family: arial; font-size: 14px;'> "
	cBody +=  "       <div fr-original-style='' style='box-sizing: border-box;'>&nbsp;</div> "
	cBody +=  "       <table border='0' cellpadding='0' cellspacing='0' fr-original-style='border-collapse: collapse;width:986pt;' "
	cBody +=  "           id='isPasted' "
	cBody +=  "           style='border-collapse: collapse; width: 986pt; box-sizing: border-box; border: none; empty-cells: show; max-width: 100%;' "
	cBody +=  "           width='1312'> "
	cBody +=  "           <tbody fr-original-style='' style='box-sizing: border-box;'> "
	cBody +=  "       			  <td fr-original-class='xl64' ; colspan='2'
	cBody +=  "       		    	  fr-original-style='color:black; font-size:18px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;background:#F2F2F2;height:15.0pt;0.5pt solid windowtext;'
	cBody +=  "       		    	  height='20'
	cBody +=  "       		    	  style='color: black; font-size: 18px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext;border-left:  0.5pt solid windowtext; height: 18pt; box-sizing: border-box; user-select: text;'>
	cBody +=  "       		    	  CADASTRO DE PRODUTOS DE " +_DaData+" ATÉ "+_AteData+"</td>
	cBody +=  "    			</tr> "
	cBody +=  "               <tr fr-original-style='' style='box-sizing: border-box; user-select: none;'> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Calibri, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;height:15.0pt;0.5pt solid windowtext;' "
	cBody +=  "                       height='20' "
	cBody +=  "                       style='color: white; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-left: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); height: 15pt; border-top: 0.5pt solid windowtext; box-sizing: border-box; width: 30%; user-select: text;'> "
	cBody +=  "                       CODIGO </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Calibri, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: white; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 50%; user-select: text;'> "
	cBody +=  "                       DESCRIÇÃO </td> "
	cBody +=  "               </tr> "
	For nX:=1 To Len(aProd)
		cBody +=  "               <tr fr-original-style='' style='box-sizing: border-box; user-select: none;'> "
		cBody +=  "                   <td fr-original-class='xl65' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:400;font-style:normal;text-decoration:none;font-family:Calibri, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;height:15.0pt;0.5pt solid windowtext;' "
		cBody +=  "                       height='20' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-left: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); height: 15pt; border-top: 0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "+Alltrim(aProd[nX,1])+"</td> "
		cBody +=  "                   <td fr-original-class='xl65' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:400;font-style:normal;text-decoration:none;font-family:Calibri, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "+Alltrim(aProd[nX,2])+"</td> "
		cBody +=  "               </tr> "
	Next nX
	cBody +=  "           </tbody> "
	cBody +=  "       </table> "
	cBody +=  "   </div> "
	cBody +=  " <tr> "
	cBody +=  " 	<td> "
	cBody +=  "     	<br/>  "
	cBody +=  "    		<br/>  "
	cBody +=  "         <br/>  "
	cBody +=  "         <br/>  "
	cBody +=  " 	</td> "
	cBody +=  " </tr> "
	cBody +=  "   <div style='font-family: arial; font-size: 14px;'> "
	cBody +=  "       <div fr-original-style='' style='box-sizing: border-box;'>&nbsp;</div> "
	cBody +=  "       <table border='0' cellpadding='0' cellspacing='0' fr-original-style='border-collapse: collapse;width:986pt;' "
	cBody +=  "           id='isPasted' "
	cBody +=  "           style='border-collapse: collapse; width: 986pt; box-sizing: border-box; border: none; empty-cells: show; max-width: 100%;' "
	cBody +=  "           width='1312'>
	cBody +=  "           <tbody fr-original-style='' style='box-sizing: border-box;'> "
	cBody +=  "       			  <td fr-original-class='xl64' ; colspan='3'
	cBody +=  "       		    	  fr-original-style='color:black; font-size:18px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;background:#F2F2F2;height:15.0pt;0.5pt solid windowtext;'
	cBody +=  "       		    	  height='20'
	cBody +=  "       		    	  style='color: black; font-size: 18px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext;border-left:  0.5pt solid windowtext; height: 18pt; box-sizing: border-box; user-select: text;'>
	cBody +=  "       		    	  CAD. DE VENDEDORES DE " +_DaData+" ATÉ "+_AteData+"</td>
	cBody +=  "    			</tr> "
	cBody +=  "               <tr fr-original-style='' style='box-sizing: border-box; user-select: none;'> "
	cBody +=  "                   <td fr-original-class='xl65' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:400;font-style:normal;text-decoration:none;font-family:Calibri, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: white; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
	cBody +=  "                       VENDEDOR </td> "
	cBody +=  "                   <td fr-original-class='xl66' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:400;font-style:normal;text-decoration:none;font-family:Calibri, sans-serif;text-align:general;vertical-align:bottom;border:.5pt solid windowtext;text-align:center;background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: white; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; text-align: center; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
	cBody +=  "                       DISTRIBUIÇÃO </td> "
	cBody +=  "                   <td fr-original-class='xl66' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:400;font-style:normal;text-decoration:none;font-family:Calibri, sans-serif;text-align:general;vertical-align:bottom;border:.5pt solid windowtext;text-align:center;background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: white; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; text-align: center; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
	cBody +=  "                       FILIAL </td> "
	cBody +=  "               </tr> "
	For nX:=1 to Len(aVend)
		cBody +=  "               <tr fr-original-style='' style='box-sizing: border-box; user-select: none;'> "
		cBody +=  "                   <td fr-original-class='xl65' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:400;font-style:normal;text-decoration:none;font-family:Calibri, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "+aVend[nX,1]+"</td> "
		cBody +=  "                   <td fr-original-class='xl66' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:400;font-style:normal;text-decoration:none;font-family:Calibri, sans-serif;text-align:Center;vertical-align:bottom;border:.5pt solid windowtext;text-align:center;background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; text-align: center; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "  					  "+aVend[nX,2]+"</td> "
		cBody +=  "                   <td fr-original-class='xl66' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:400;font-style:normal;text-decoration:none;font-family:Calibri, sans-serif;text-align:Center;vertical-align:bottom;border:.5pt solid windowtext;text-align:center;background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; text-align: center; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "						  "+aVend[nX,3]+"</td> "
		cBody +=  "               </tr> "
	Next nX
	cBody +=  "           </tbody> "
	cBody +=  "       </table> "
	cBody +=  "   </div> "
	cBody +=  " <tr> "
	cBody +=  " 	<td> "
	cBody +=  "     	<br/>  "
	cBody +=  "    		<br/>  "
	cBody +=  "         <br/>  "
	cBody +=  "         <br/>  "
	cBody +=  " 	</td> "
	cBody +=  " </tr> "
	cBody +=  "   <div style='font-family: arial; font-size: 14px;'> "
	cBody +=  "       <div fr-original-style='' style='box-sizing: border-box;'>&nbsp;</div> "
	cBody +=  "       <table border='0' cellpadding='0' cellspacing='0' fr-original-style='border-collapse: collapse;width:1300pt;' "
	cBody +=  "           id='isPasted' "
	cBody +=  "           style='border-collapse: collapse; width: 1300pt; box-sizing: border-box; border: none; empty-cells: show; max-width: 100%;' "
	cBody +=  "           width='1312'>
	cBody +=  "           <tbody fr-original-style='' style='box-sizing: border-box;'> "
	cBody +=  "       			  <td fr-original-class='xl64' ; colspan='6'
	cBody +=  "       		    	  fr-original-style='color:black; font-size:18px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;background:#F2F2F2;height:15.0pt;0.5pt solid windowtext;'
	cBody +=  "       		    	  height='20'
	cBody +=  "       		    	  style='color: black; font-size: 18px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext;border-left:  0.5pt solid windowtext; height: 18pt; box-sizing: border-box; user-select: text;'>
	cBody +=  "       		    	  REGISTRO DE VENDAS DE " +_DaData+" ATÉ "+_AteData+"</td>
	cBody +=  "    			</tr> "
	cBody +=  "               <tr fr-original-style='' style='box-sizing: border-box; user-select: none;'> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;height:15.0pt;0.5pt solid windowtext;' "
	cBody +=  "                       height='20' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-left: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); height: 15pt; border-top: 0.5pt solid windowtext; box-sizing: border-box; width: 10%; user-select: text;'> "
	cBody +=  "                       RAZÃO </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 10%; user-select: text;'> "
	cBody +=  "                       MUNICIPIO </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 6%; user-select: text;'> "
	cBody +=  "                       UF </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 5%; user-select: text;'> "
	cBody +=  "                       VENDEDOR </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 20%; user-select: text;'> "
	cBody +=  "                       DISTRIBUIÇÃO </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 20%; user-select: text;'> "
	cBody +=  "                       FILIAL </td> "
	cBody +=  "               </tr> "
	For nX:=1 To Len(aVendas)
		cBody +=  "               <tr fr-original-style='' style='box-sizing: border-box; user-select: none;'> "
		cBody +=  "                   <td fr-original-class='xl65' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;height:15.0pt;0.5pt solid windowtext;' "
		cBody +=  "                       height='20' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-left: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); height: 15pt; border-top: 0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "+AllTrim(aVendas[nX,1])+"</td> "
		cBody +=  "                   <td fr-original-class='xl65' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;0.5pt solid windowtext;border-center: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "+AllTrim(aVendas[nX,2])+"</td> "
		cBody +=  "                   <td fr-original-class='xl66' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:Center; vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align:Center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "/*  &nbsp; &nbsp; &nbsp; &nbsp; "*/
		cBody +=  "                       "+AllTrim(aVendas[nX,3])+"</td> "
		cBody +=  "                   <td fr-original-class='xl66' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:Center; vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align:Center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "/*  &nbsp; &nbsp; &nbsp; &nbsp; "*/
		cBody +=  "                       "+AllTrim(aVendas[nX,4])+"</td> "
		cBody +=  "                   <td fr-original-class='xl66' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:Center; vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align:Center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "/*  &nbsp; &nbsp; &nbsp; &nbsp; "*/
		cBody +=  "                       "+AllTrim(aVendas[nX,5])+"</td> "
		cBody +=  "                   <td fr-original-class='xl66' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:Center; vertical-align:bottom;border:.5pt solid windowtext; background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align:Center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "/*  &nbsp; &nbsp; &nbsp; &nbsp; "*/
		cBody +=  "                       "+AllTrim(aVendas[nX,6])+"</td> "
		cBody +=  "                   </td> "
		cBody +=  "               </tr> "
	Next nX
	cBody +=  "           </tbody> "
	cBody +=  "       </table> "
	cBody +=  "   </div> "
	cBody +=  " <tr> "
	cBody +=  " 	<td> "
	cBody +=  "     	<br/>  "
	cBody +=  "    		<br/>  "
	cBody +=  "         <br/>  "
	cBody +=  "         <br/>  "
	cBody +=  " 	</td> "
	cBody +=  " </tr> "
	cBody +=  "   <div style='font-family: arial; font-size: 14px;'> "
	cBody +=  "       <div fr-original-style='' style='box-sizing: border-box;'>&nbsp;</div> "
	cBody +=  "       <table border='0' cellpadding='0' cellspacing='0' fr-original-style='border-collapse: collapse;width:1300pt;' "
	cBody +=  "           id='isPasted' "
	cBody +=  "           style='border-collapse: collapse; width: 1300pt; box-sizing: border-box; border: none; empty-cells: show; max-width: 100%;' "
	cBody +=  "           width='1312'> "
	cBody +=  "           <tbody fr-original-style='' style='box-sizing: border-box;'> "
	cBody +=  "       			  <td fr-original-class='xl64' ; colspan='11'
	cBody +=  "       		    	  fr-original-style='color:black; font-size:18px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;background:#F2F2F2;height:15.0pt;0.5pt solid windowtext;'
	cBody +=  "       		    	  height='20'
	cBody +=  "       		    	  style='color: black; font-size: 18px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext;border-left:  0.5pt solid windowtext; height: 18pt; box-sizing: border-box; user-select: text;'>
	cBody +=  "       		    	  CADASTRO DE CLIENTES DE " +_DaData+" ATÉ "+_AteData+"</td>
	cBody +=  "    			</tr> "
	cBody +=  "               <tr fr-original-style='' style='box-sizing: border-box; user-select: none;'> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;height:15.0pt;0.5pt solid windowtext;' "
	cBody +=  "                       height='20' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-left: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); height: 15pt; border-top: 0.5pt solid windowtext; box-sizing: border-box; width: 10%; user-select: text;'> "
	cBody +=  "                       DISTRIBUIÇÃO </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 10%; user-select: text;'> "
	cBody +=  "                       FILIAL </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 6%; user-select: text;'> "
	cBody +=  "                       DATA </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 5%; user-select: text;'> "
	cBody +=  "                       CODPROD </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 20%; user-select: text;'> "
	cBody +=  "                       DESCRIÇÃO </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 20%; user-select: text;'> "
	cBody +=  "                       VENDEDOR </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 20%; user-select: text;'> "
	cBody +=  "                       RAZÃO_CLIENTE </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 7%; user-select: text;'> "
	cBody +=  "                       MUN </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 4%; user-select: text;'> "
	cBody +=  "                       UF </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 4%; user-select: text;'> "
	cBody +=  "                       QUANTD. </td> "
	cBody +=  "                   <td fr-original-class='xl64' "
	cBody +=  "                       fr-original-style='color:white;font-size:15px;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:##FF0000;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
	cBody +=  "                       style='color: White; font-size: 15px; font-weight: 700; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(255,0,0); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; width: 7%; user-select: text;'> "
	cBody +=  "                       PREÇO </td> "
	cBody +=  "               </tr> "
	For nX:=1 To Len(aVendas)
		cBody +=  "               <tr fr-original-style='' style='box-sizing: border-box; user-select: none;'> "
		cBody +=  "                   <td fr-original-class='xl65' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:300;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;height:15.0pt;0.5pt solid windowtext;' "
		cBody +=  "                       height='20' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 300; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-left: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); height: 15pt; border-top: 0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "+AllTrim(aVendas[nX,1])+"</td> "
		cBody +=  "                   <td fr-original-class='xl65' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:300;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:center;vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;0.5pt solid windowtext;border-center: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 300; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "+AllTrim(aVendas[nX,2])+"</td> "
		cBody +=  "                   <td fr-original-class='xl66' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:300;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:Center; vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 300; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align:Center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "/*  &nbsp; &nbsp; &nbsp; &nbsp; "*/
		cBody +=  "                       "+cValToChar(aVendas[nX,3])+"</td> "
		cBody +=  "                   <td fr-original-class='xl66' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:300;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:Center; vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 300; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align:Center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "/*  &nbsp; &nbsp; &nbsp; &nbsp; "*/
		cBody +=  "                       "+cValToChar(aVendas[nX,4])+"</td> "
		cBody +=  "                   <td fr-original-class='xl66' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:300;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:Center; vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 300; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align:Center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "/*  &nbsp; &nbsp; &nbsp; &nbsp; "*/
		cBody +=  "                       "+cValToChar(aVendas[nX,5])+"</td> "
		cBody +=  "                   <td fr-original-class='xl66' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:300;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:Center; vertical-align:bottom;border:.5pt solid windowtext; background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 300; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align:Center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "/*  &nbsp; &nbsp; &nbsp; &nbsp; "*/
		cBody +=  "                       "+cValToChar(aVendas[nX,6])+"</td> "
		cBody +=  "                   <td fr-original-class='xl65' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:300;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:Center; vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 300; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: Center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "/*  &nbsp; &nbsp; &nbsp; &nbsp; "*/
		cBody +=  "                       "+cValToChar(aVendas[nX,7])+"</td> "
		cBody +=  "                   <td fr-original-class='xl65' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:300;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:Center; vertical-align:bottom;border:.5pt solid windowtext;background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 300; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align: Center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "/*  &nbsp; &nbsp; &nbsp; &nbsp; "*/
		cBody +=  "                       "+cValToChar(aVendas[nX,8])+"</td> "
		cBody +=  "                   <td fr-original-class='xl66' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:300;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:Center; vertical-align:bottom;border:.5pt solid windowtext; background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 300; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align:Center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "/*  &nbsp; &nbsp; &nbsp; "*/
		cBody +=  "                       "+cValToChar(aVendas[nX,9])+"</td> "
		cBody +=  "                   <td fr-original-class='xl66' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:300;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:Center; vertical-align:bottom;border:.5pt solid windowtext; background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 300; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align:Center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "/*  &nbsp; &nbsp; &nbsp; "*/
		cBody +=  "                       "+cValToChar(aVendas[nX,10])+"</td> "
		cBody +=  "                   <td fr-original-class='xl66' "
		cBody +=  "                       fr-original-style='color:black;font-size:15px;font-weight:300;font-style:normal;text-decoration:none;font-family:Arial, sans-serif; text-align:Center; vertical-align:bottom;border:.5pt solid windowtext; background:#F2F2F2;0.5pt solid windowtext;border-left: 0.5pt solid windowtext;' "
		cBody +=  "                       style='color: black; font-size: 15px; font-weight: 300; font-style: normal; text-decoration: none; font-family: Arial, sans-serif; text-align:Center; vertical-align: bottom; border-right: 0.5pt solid windowtext; border-bottom: 0.5pt solid windowtext; border-image: initial; background: rgb(242, 242, 242); border-top: 0.5pt solid windowtext; border-left:  0.5pt solid windowtext; box-sizing: border-box; min-width: 5px; user-select: text;'> "
		cBody +=  "                       "/*  &nbsp; &nbsp; &nbsp; "*/
		cBody +=  "                       "+cValToChar(aVendas[nX,11])+"</td> "
		cBody +=  "                   </td> "
		cBody +=  "               </tr> "
	Next nX
	cBody +=  "           </tbody> "
	cBody +=  "       </table> "
	cBody +=  "   </div> "


Return cBody
