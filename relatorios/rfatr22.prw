#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

*----------------------------------------------------------------------------
* Bruno Santos                                                   | 29/03/2011
*----------------------------------------------------------------------------
* Função: Mapa de faturamento
*----------------------------------------------------------------------------
* Objetivo :  Imprime o Mapa de faturamento
*----------------------------------------------------------------------------

User Function rfatr22z()

SetPrvt("cTitulo,cString,scDesc1,cDesc2,M_pag")
SetPrvt("cTamanho,aReturn,nLastKey,cPerg,_ABEC1,_ABEC2")
SetPrvt("cNomeprog,cCondicao,_Linha,_Query,Comp")
Private nLin
Private wnPag 		:= 0
Private lPrimeiro
Private nCont
Private cPerg		:= "RFAT22V"     

CTitulo    := "Mapa de Faturamento "
CABEC1     := "Mapa de Faturamento "
M_pag      :=  0
cString    := "SD2"
cWnrel     := "RFATR22Z"
cDesc1     := "Mapa de Faturamento"
CABEC2     := " "
cDesc2     := ""
cTamanho   := "P"
aReturn    := { "Zebrado", 1,"Estoque", 2, 2, 1, "",1 }
nLastKey   := 0
_abec1     := ""
_abec2     := ""
cnomeprog  := "rfatr22z"
cCondicao  := ""
_Linha     := 100
Comp       := 15 
nlin		:= 0

//ValidPerg()
/*
If !Pergunte(cPerg,.T.)
	Return
EndIf*/
Pergunte(cPerg,.t.)   

If MV_PAR12 = 2 
  // SetPrint(cString,wnrel,"RFAT22",titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho)
	cWnrel:=SetPrint(cString,cWnrel,cPerg,cTitulo,cDesc1,cDesc2,"",.F.,"",.T.,cTamanho,,.T.)
	If nLastKey == 27     
    	Set Filter To
		Return .T.
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27 
    	Set Filter To
		Return .T.
	Endif

Endif

cFileLogo 	:= "lgrl01.bmp"
//cFileLogo	:= GetSrvProfString('Startpath','') + 'lgrl01' + '.BMP'

MsAguarde({|| RPEDEVOL() }, OemToAnsi("Aguarde"), OemToAnsi("Selecionando registros para impressão..."))

Return

*************************************************************************
Static function RPEDEVOL()
*************************************************************************

//Definição das fontes a serem utilizadas pelo programa.
oFont08  := TFont():New("Courier New",08,08,.F.,.F.,,,,.T.,.F.)
oFont08A := TFont():New("Tahoma",08,08,.F.,.F.,,,,.T.,.F.)
oFont08B := TFont():New("Tahoma",08,08,.F.,.T.,,,,.T.,.F.) //NEGRITO
oFont09  := TFont():New("Tahoma",09,09,.F.,.F.,,,,.T.,.F.)
oFont09B := TFont():New("Tahoma",09,09,.F.,.T.,,,,.T.,.F.) //NEGRITO
oFont10  := TFont():New("Tahoma",10,10,.F.,.F.,,,,.T.,.F.)
oFont10B := TFont():New("Tahoma",10,10,.F.,.T.,,,,.T.,.F.) //NEGRITO
oFont14B := TFont():New("Tahoma",14,14,.F.,.T.,,,,.T.,.F.) //NEGRITO
oFont14BS:= TFont():New("Tahoma",14,14,.F.,.T.,,,,.T.,.T.) //NEGRITO E SUBLINHADO
oFont18BS:= TFont():New("Arial",18,18,.F.,.T.,,,,.T.,.T.) //NEGRITO E SUBLINHADO
oFont12  := TFont():New("Verdana",12,12,.T.,.F.,,,,.T.,.F.)
oFont11  := TFont():New("Courier New",10,10,.T.,.F.,,,,.T.,.F.)
oFont11B := TFont():New("Courier New",10,10,.T.,.T.,,,,.T.,.F.)

aValFAT := {}  //Array com os valores do faturamento das divisões 
aValDEV := {}  //Array com os valores das devoluções das divisões
aCart   := {}  //Array com os valores em carteira
aFatFert:= {}  //Array com os Valores do faturamento Fertilizante
aDevFert:= {}  //Array com os Valores da Devolução fertilizante
aFatPast:= {}  //Array com os valores do faturamento pastagem
aDevPast:= {}  //Array com os valores da devolução pastagem
aVEND1 := {}
Private nValFat 	:= 0, nValFat1 	:= 0, nValFat2 	:= 0, nValFat3 	:= 0, nValFat4 	:= 0
Private nValDev 	:= 0, nValDev1 	:= 0, nValDev2 	:= 0, nValDev3 	:= 0, nValDev4 	:= 0
Private nFatFert1 	:= 0, nCart 	:= 0, nCart1 	:= 0, nCart2 	:= 0, nCart3 	:= 0
Private nCart4 		:= 0, nCart5 	:= 0, nCart6	:= 0, nDevPast1 := 0, nFatPast1	:= 0
Private nDevFert1 	:= 0, nFatFert1	:= 0, nDevpast	:= 0, nFatPast	:= 0, nDevFert	:= 0
private nCount 		:= 0, nFatFert	:= 0
aCart   := {}  //Array com os valores em carteira

If SM0->M0_CODIGO = "01"
   cEmpresa := "EMIS"
ElseIf SM0->M0_CODIGO = "02"
   cEmpresa := "CATIVA"
ElseIf SM0->M0_CODIGO = "03"
   cEmpresa := "NUTIVA"
Endif   

*-----------------------------------------------------------------------------------------------------------
* Query com os valores do_ faturamento das divisões
* Agr.+Ata.+Vet.+Bay.+Pec
* 1 Agricola                     	
* 2 Atacado
* 3 Veterinaria
* 4 Bayer Pco
* 5 Pecas Jacto
*-----------------------------------------------------------------------------------------------------------
If MV_PAR09 = 1
		oPrint:= TMSPrinter():New(".: Mapa de Faturamento :.")
		oPrint:SetPortrait()			//SetLandscape()
ENDIF
cQRY := " SELECT A3_COD, A3_FILIAL									"
cQRY += " FROM "+RetSqlName('SA3')+" A3 							"
cQRY += " WHERE A3.D_E_L_E_T_ <> '*' 								"
cQRY += " AND A3_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' 		"
cQRY += " AND A3_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' 	"
cQRY += " AND A3_MSBLQL <> '1'									 	"
cQRY += " ORDER BY A3_COD, A3_FILIAL							 	"

TCQUERY cQRY ALIAS aVEND1 NEW
aVEND1 := {}
DbSelectArea("aVEND1")
While aVEND1->(!EoF())
	aAdd(aVEND1, { aVEND1->A3_FILIAL , aVEND1->A3_COD })
	aVEND1->(DbSkip())
Enddo

For nCount := 1 to Len(aVEND1)

For b := 1 to 5
	
	_Query1 := " SELECT B1_DIVISAO,SUM(D2_TOTAL) AS TOTD2                                	"	+ chr(13)+chr(10)
	_Query1 += "   FROM "+RetSqlName("SD2")+" D2 (NOLOCK)                                	"	+ chr(13)+chr(10)
	_Query1 += "   LEFT JOIN   "+RetSqlName("SF4")+" F4 (NOLOCK) ON F4.F4_CODIGO = D2_TES	"	+ chr(13)+chr(10)
	_Query1 += "                                 AND F4.D_E_L_E_T_ =  ''                 	"	+ chr(13)+chr(10)
	_Query1 += " 			 	 	 	         AND F4_DUPLIC     <> 'N'                	"	+ chr(13)+chr(10)
	if !empty(mv_par11)	
		_Query1 += "   JOIN "+RetSqlName("SA1")+" A1 (NOLOCK)   ON A1_COD = D2_CLIENTE     		"	+ chr(13)+chr(10)
		_Query1 += "	                                       AND A1_LOJA = D2_LOJA      		"	+ chr(13)+chr(10)
		_Query1 += "                                           AND A1_MUN = '" + MV_PAR11  +"'	"	+ chr(13)+chr(10)
	endif	
	_Query1 += "   JOIN "+RetSqlName("SB1")+" B1 (NOLOCK)   ON B1_COD = D2_COD        		"	+ chr(13)+chr(10)
	_Query1 += "                                 AND B1.D_E_L_E_T_ = ''	                 	"	+ chr(13)+chr(10)
	If MV_PAR07 == 2
		If MV_PAR06 == 1
			_Query1 += "                             AND B1.B1_DIVISAO = '1'					"	+ chr(13)+chr(10)
		ElseIf MV_PAR06 == 2
			_Query1 += "                             AND B1.B1_DIVISAO = '2'					"	+ chr(13)+chr(10)
		ElseIf MV_PAR06 == 3
			_Query1 += "                             and b1.B1_GRUPO <> '0009'					"	+ chr(13)+chr(10)
			_Query1 += "                             AND B1_CODFOR NOT IN('01','A4','83','A7','A8') "	+ chr(13)+chr(10)
			_Query1 += "                             AND B1.B1_DIVISAO = '3'					"	+ chr(13)+chr(10)
		ElseIf MV_PAR06 == 4
			_Query1 += "                             AND B1.B1_CODFOR = '01'					"	+ chr(13)+chr(10)
			_Query1 += "                             AND B1.B1_DIVISAO = '4'					"	+ chr(13)+chr(10)
		ElseIf MV_PAR06 == 5
			//	_Query1 += "                             AND B1.B1_GRUPO = '0009'					"	+ chr(13)+chr(10)
			_Query1 += "                             AND B1.B1_DIVISAO = '5'					"	+ chr(13)+chr(10)
			_Query1 += "                             AND B1.B1_CODFOR IN('73','76')				"	+ chr(13)+chr(10)
		EndIf
		EXIT
		
	ELSE
		If 		b = 1	//Divisão Agricola
			_Query1 += "                             AND B1.B1_DIVISAO = '1'					"	+ chr(13)+chr(10)
		ElseIf 	b = 2 	//Divisão Atacado
			_Query1 += "                             AND B1.B1_DIVISAO = '2'					"	+ chr(13)+chr(10)
		ElseIf 	b = 3   //Divisão Veterinária
			_Query1 += "                             and b1.B1_GRUPO <> '0009'					"	+ chr(13)+chr(10)
			_Query1 += "                             AND B1_CODFOR NOT IN('01','A4','83','A7','A8') "	+ chr(13)+chr(10)
			_Query1 += "                             AND B1.B1_DIVISAO = '3'					"	+ chr(13)+chr(10)
		ElseIf 	b = 4	//Divisão Bayer
			_Query1 += "                             AND B1.B1_CODFOR = '01'					"	+ chr(13)+chr(10)
			_Query1 += "                             AND B1.B1_DIVISAO = '4'					"	+ chr(13)+chr(10)
		ElseIf 	b = 5	//Divisão Peças Costal
			//	_Query1 += "                             AND B1.B1_GRUPO = '0009'					"	+ chr(13)+chr(10)
			_Query1 += "                             AND B1.B1_DIVISAO = '5'					"	+ chr(13)+chr(10)
			_Query1 += "                             AND B1.B1_CODFOR IN('73','76')				"	+ chr(13)+chr(10)
		EndIf
	ENDIF
	_Query1 += "    JOIN "+RetSqlName("SF2")+"  F2 (NOLOCK)  ON D2_DOC = F2_DOC				"	+ chr(13)+chr(10)
	_Query1 += "                                            AND F2_SERIE = D2_SERIE			"	+ chr(13)+chr(10)
	_Query1 += "				                            AND D2_FILIAL = F2_FILIAL		"	+ chr(13)+chr(10)
	_Query1 += "   											AND F2_VEND1 = '"+ aVEND1[nCount][2] +"' "  	+ chr(13)+chr(10)
	_Query1 += " WHERE D2.D_E_L_E_T_ = ''													"	+ chr(13)+chr(10)
	_Query1 += "   AND SUBSTRING(D2.D2_CF,2,3) IN('12','102','922','108')                	" 	+ chr(13)+chr(10)
	
	_Query1 += "   AND D2_EMISSAO BETWEEN '" + DTOS(MV_PAR08) + "' AND '" + DTOS(MV_PAR09) +"'"	+ chr(13)+chr(10)
	
		_Query1 += "   AND D2_FILIAL  = '"+ aVEND1[nCount][1]+"'   									"	+ chr(13)+chr(10)
	
	If !empty(MV_PAR10) //Filtrar por estado também
		_Query1 += "   AND D2_EST  = '"+ MV_PAR10+"'			   								"	+ chr(13)+chr(10)
	EndIf
	
	_Query1 += " GROUP BY B1_DIVISAO															"	+ chr(13)+chr(10)
	_Query1 += " ORDER BY B1_DIVISAO															"	+ chr(13)+chr(10)
	
	Memowrit( "D:\Query\rfatr22.SQL", _QUERY1 )
	TCQUERY _Query1 ALIAS QSD2 NEW
	
	*------------------------------------------------------------------------------------------------------------
	* Carrego um array_ com os valores do_ faturamento por divisão
	*------------------------------------------------------------------------------------------------------------
	If b = 1 	//Divisão Agricola
		DbSelectArea("QSD2")
		AADD(AVALFAT,QSD2->TOTD2)
		QSD2->(DBCloseArea())
		nValFat += AVALFAT[1]	
	
	ElseIf 	b = 2 	//Divisão Atacado
		DbSelectArea("QSD2")
		AADD(AVALFAT,QSD2->TOTD2)
		QSD2->(DBCloseArea())
		nValFat1 += AVALFAT[2]
		
	ElseIf 	b = 3   //Divisão Veterinária
		DbSelectArea("QSD2")
		AADD(AVALFAT,QSD2->TOTD2)
		QSD2->(DBCloseArea())
		nValFat2 += AVALFAT[3]
	
	ElseIf 	b = 4	//Divisão Bayer
		DbSelectArea("QSD2")
		AADD(AVALFAT,QSD2->TOTD2)
		QSD2->(DBCloseArea())
		nValFat3 += AVALFAT[4]
	
	ElseIf 	b = 5	//Divisão Peças Costal
		DbSelectArea("QSD2")
		AADD(AVALFAT,QSD2->TOTD2)
		QSD2->(DBCloseArea())
		nValFat4 += AVALFAT[5]	
	EndIf
	
Next



*-----------------------------------------------------------------------------------------------------------
* Query com os valores das devoluções das divisões
* Agr.+Ata.+Vet.+Bay.+Pec
* 1 Agricola
* 2 Atacado
* 3 Veterinaria
* 4 Bayer Pco
* 5 Pecas Jacto
*-----------------------------------------------------------------------------------------------------------

For br := 1 to 5
	_Query := " SELECT B1_DIVISAO,SUM(D1_TOTAL)-SUM(D1_VALDESC) AS TODD1					"  	+ chr(13)+chr(10)
	_Query += "   FROM "+RetSqlName("SD1")+" D1 (NOLOCK) 									"  	+ chr(13)+chr(10)
	_Query += "   LEFT JOIN   "+RetSqlName("SF4")+" F4 (NOLOCK) ON F4.F4_CODIGO = D1_TES	"  	+ chr(13)+chr(10)
	_Query += "				                                   AND F4.D_E_L_E_T_ = ''       "  	+ chr(13)+chr(10)
	_Query += "											       AND F4_DUPLIC     <> 'N'     "  	+ chr(13)+chr(10)
	_Query += "  JOIN "+RetSqlName("SA1")+" A1 (NOLOCK)  ON A1_COD = D1_FORNECE 			"  	+ chr(13)+chr(10)
	_Query += "                                         AND A1_LOJA = D1_LOJA				"  	+ chr(13)+chr(10)
	
	If !empty(MV_PAR10) //Filtra por estado
		_Query += " AND A1_EST ='"+ MV_PAR10 +"'											"  	+ chr(13)+chr(10)
	EndIf
	
	If !empty(MV_PAR11) //Filtra por municipio
		_Query += " AND A1_MUN ='"+ MV_PAR11 +"'											"  	+ chr(13)+chr(10)
	EndIf
	
	_Query += "  JOIN "+RetSqlName("SB1")+" B1 (NOLOCK)   ON B1_COD        = D1_COD			"  	+ chr(13)+chr(10)
	_Query += "					                              AND B1.D_E_L_E_T_ = ''			"  	+ chr(13)+chr(10)
	If MV_PAR07 == 2
		
		If MV_PAR06 == 1
			_Query += "                             AND B1.B1_DIVISAO = '1'						"	+ chr(13)+chr(10)
		ElseIf MV_PAR06 == 2
			_Query += "                             AND B1.B1_DIVISAO = '2'						"	+ chr(13)+chr(10)
		ElseIf MV_PAR06 == 3
			_Query += "                             and b1.B1_GRUPO <> '0009'					"	+ chr(13)+chr(10)
			_Query += "                             AND B1_CODFOR NOT IN('01','A4','83','A7','A8') "	+ chr(13)+chr(10)
			_Query += "                             AND B1.B1_DIVISAO = '3'						"	+ chr(13)+chr(10)
		ElseIf MV_PAR06 == 4
			_Query += "                             AND B1.B1_CODFOR = '01'						"	+ chr(13)+chr(10)
			_Query += "                             AND B1.B1_DIVISAO = '4'						"	+ chr(13)+chr(10)
		ElseIf MV_PAR06 == 5
			//	_Query1 += "                             AND B1.B1_GRUPO = '0009'					"	+ chr(13)+chr(10)
			_Query += "                             AND B1.B1_DIVISAO = '5'				   		"	+ chr(13)+chr(10)
			_Query += "                             AND B1.B1_CODFOR IN('73','76')				"	+ chr(13)+chr(10)
		EndIf
		EXIT
	ELSE
		If 		br = 1	//Divisão Agricola
			_Query += "                             AND B1.B1_DIVISAO = '1'				   		"	+ chr(13)+chr(10)
		ElseIf 	br = 2 	//Divisão Atacado
			_Query += "                             AND B1.B1_DIVISAO = '2'						"	+ chr(13)+chr(10)
		ElseIf 	br = 3   //Divisão Veterinária
			_Query += "                             and b1.B1_GRUPO <> '0009'					"	+ chr(13)+chr(10)
			_Query += "                             AND B1_CODFOR NOT IN('01','A4','83','A7','A8') "	+ chr(13)+chr(10)
			_Query += "                             AND B1.B1_DIVISAO = '3'						"	+ chr(13)+chr(10)
		ElseIf 	br = 4	//Divisão Bayer
			_Query += "                             AND B1.B1_CODFOR = '01'				   		"	+ chr(13)+chr(10)
			_Query += "                             AND B1.B1_DIVISAO = '4'						"	+ chr(13)+chr(10)
		ElseIf 	br = 5	//Divisão Peças Costal
			_Query += "                             AND B1.B1_DIVISAO = '5'						"	+ chr(13)+chr(10)
			_Query += "                             AND B1.B1_CODFOR IN('73','76')				"	+ chr(13)+chr(10)
		EndIf
	ENDIF
	_Query += "   AND D1_DTDIGIT  BETWEEN  '" + DTOS(MV_PAR08) + "' AND '" + DTOS(MV_PAR09) +"' "	+ chr(13)+chr(10)
	_Query += "   AND D1_TIPO = 'D'																"	+ chr(13)+chr(10)
	_Query += "   AND SUBSTRING(D1_CF,2,3) IN('32','202')										"	+ chr(13)+chr(10)
	
	_Query += "   AND D1_FILIAL  = '"+aVEND1[nCount][1]+"'   										"	+ chr(13)+chr(10)
	
	_Query += "   AND D1.D_E_L_E_T_ = ''														"	+ chr(13)+chr(10)
	_Query += " GROUP BY B1_DIVISAO																"	+ chr(13)+chr(10)
	_Query += " ORDER BY B1_DIVISAO																"	+ chr(13)+chr(10)
	
	Memowrit( "D:\Query\rfatr221.SQL", _QUERY )
	TCQUERY _Query ALIAS QSD1 NEW
	
	*------------------------------------------------------------------------------------------------------------
	* Carrego um array_ com os valores do_ faturamento por divisão
	*------------------------------------------------------------------------------------------------------------
	If 	br = 1	//Divisão Agricola
		DbSelectArea("QSD1")
		AADD(AVALDEV,QSD1->TODD1)
		QSD1->(DBCloseArea())
		nValDev += AVALDEV[1]
	ElseIf 	br = 2 	//Divisão Atacado
		DbSelectArea("QSD1")
		AADD(AVALDEV,QSD1->TODD1)
		QSD1->(DBCloseArea())
		nValDev1 += AVALDEV[2]
	ElseIf 	br = 3   //Divisão Veterinária
		DbSelectArea("QSD1")
		AADD(AVALDEV,QSD1->TODD1)
		QSD1->(DBCloseArea())
		nValDev2 += AVALDEV[3]
	ElseIf 	br = 4	//Divisão Bayer
		DbSelectArea("QSD1")
		AADD(AVALDEV,QSD1->TODD1)
		QSD1->(DBCloseArea())
		nValDev3 += AVALDEV[4]
	ElseIf 	br = 5	//Divisão Peças Costal
		DbSelectArea("QSD1")
		AADD(AVALDEV,QSD1->TODD1)
		QSD1->(DBCloseArea())
		nValDev4 += AVALDEV[5]
	EndIf
	
	
Next







*------------------------------------------------------------------------------------------------------------
* Query com o faturamento de fertilizantes
*------------------------------------------------------------------------------------------------------------
cCond := " SELECT B1_DIVISAO,SUM(D2_TOTAL) AS TOTD2 									"	+ chr(13)+chr(10)
cCond += "  FROM "+RetSqlName("SD2")+" D2 (NOLOCK) 										"	+ chr(13)+chr(10)
cCond += "  LEFT JOIN   "+RetSqlName("SF4")+" F4 (NOLOCK) ON F4.F4_CODIGO = D2_TES		"	+ chr(13)+chr(10)
cCond += "				                                 AND F4.D_E_L_E_T_ = ''        	"	+ chr(13)+chr(10)
cCond += "				 						         AND F4_DUPLIC     <> 'N'      	"	+ chr(13)+chr(10)
if !empty(MV_PAR11)
	cCond += "   JOIN "+RetSqlName("SA1")+" A1 (NOLOCK)   ON A1_COD = D2_CLIENTE     	"	+ chr(13)+chr(10)
	cCond += "	                                       AND A1_LOJA = D2_LOJA      		"	+ chr(13)+chr(10)
	cCond += "                                           AND A1_MUN = '" + MV_PAR11 +"'	"	+ chr(13)+chr(10)
ENDIF
cCond += "  JOIN "+RetSqlName("SB1")+" B1 (NOLOCK)  ON B1_COD = D2_COD 					"	+ chr(13)+chr(10)
cCond += "			                               AND B1.D_E_L_E_T_ = ''				"	+ chr(13)+chr(10)
cCond += "			                               AND B1_GRUPO = '0009'		        "	+ chr(13)+chr(10)
If MV_PAR07 == 2
	
	If MV_PAR06 == 1
		cCond += "                             AND B1.B1_DIVISAO = '1'					"	+ chr(13)+chr(10)
	ElseIf MV_PAR06 == 2
		cCond += "                             AND B1.B1_DIVISAO = '2'					"	+ chr(13)+chr(10)
	ElseIf MV_PAR06 == 3
		cCond += "                             and b1.B1_GRUPO <> '0009'					"	+ chr(13)+chr(10)
		cCond += "                             AND B1_CODFOR NOT IN('01','A4','83','A7','A8') "	+ chr(13)+chr(10)
		cCond += "                             AND B1.B1_DIVISAO = '3'					"	+ chr(13)+chr(10)
	ElseIf MV_PAR06 == 4
		cCond += "                             AND B1.B1_CODFOR = '01'					"	+ chr(13)+chr(10)
		cCond += "                             AND B1.B1_DIVISAO = '4'					"	+ chr(13)+chr(10)
	ElseIf MV_PAR06 == 5
		//	_Query1 += "                             AND B1.B1_GRUPO = '0009'					"	+ chr(13)+chr(10)
		cCond += "                             AND B1.B1_DIVISAO = '5'					"	+ chr(13)+chr(10)
		cCond += "                             AND B1.B1_CODFOR IN('73','76')				"	+ chr(13)+chr(10)
	EndIf
ENDIF
cCond += "  JOIN "+RetSqlName("SF2")+" F2 (NOLOCK) ON F2_DOC = D2_DOC					"	+ chr(13)+chr(10)
cCond += "                                        AND F2_SERIE  = D2_SERIE  			"	+ chr(13)+chr(10)
cCond += "				                          AND F2_FILIAL = D2_FILIAL 			"	+ chr(13)+chr(10)
cCond += "				                          AND F2.D_E_L_E_T_ = ''  				"	+ chr(13)+chr(10)
cCond += "   											AND F2_VEND1 = '"+ aVEND1[nCount][2] +"' "  	+ chr(13)+chr(10)
cCond += "	WHERE D2.D_E_L_E_T_ = ''													"	+ chr(13)+chr(10)
cCond += "    AND SUBSTRING(D2.D2_CF,2,3) IN('12','102','922','108')                	"	+ chr(13)+chr(10)
cCond += "   AND D2_FILIAL  = '"+aVEND1[nCount][1]+"'   								"	+ chr(13)+chr(10)

If !empty(MV_PAR10) //Filtrar por estado também
	cCond += "   AND D2_EST  = '"+ MV_PAR10+"'			   								"	+ chr(13)+chr(10)
EndIf

cCond += " GROUP BY B1_DIVISAO															"	+ chr(13)+chr(10)
cCond += " ORDER BY B1_DIVISAO															"	+ chr(13)+chr(10)

Memowrit( "D:\Query\rfatr224.SQL", cCond )
TCQUERY cCond ALIAS QSD24 NEW

*------------------------------------------------------------------------------------------------------------
* Guardo o valor do_ faturamento por fertilizante
*------------------------------------------------------------------------------------------------------------
DbSelectArea("QSD24")
nFatFert := QSD24->TOTD2
QSD24->(DBCloseArea())
nFatFert1 += nFatFert



*------------------------------------------------------------------------------------------------------------
* Query com as_ devoluções de  fertilizantes
*------------------------------------------------------------------------------------------------------------

cCond := " SELECT B1_DIVISAO,SUM(D1_TOTAL) AS TOTD1 									"	+ chr(13)+chr(10)
cCond += "   FROM "+RetSqlName("SD1")+" D1 (NOLOCK) 									"	+ chr(13)+chr(10)
cCond += "   LEFT JOIN   "+RetSqlName("SF4")+" F4 (NOLOCK) ON F4.F4_CODIGO  = D1_TES	"	+ chr(13)+chr(10)
cCond += " 					                              AND F4.D_E_L_E_T_ = ''        "	+ chr(13)+chr(10)
cCond += "					   					          AND F4_DUPLIC     <> 'N'      "	+ chr(13)+chr(10)
cCond += "  JOIN "+RetSqlName("SA1")+" A1 (NOLOCK)  ON A1_COD = D1_FORNECE 		 		"  	+ chr(13)+chr(10)
cCond += "                                         AND A1_LOJA = D1_LOJA				"  	+ chr(13)+chr(10)

If !empty(MV_PAR10) //Filtra por estado
	cCond += " AND A1_EST ='"+ MV_PAR10 +"'												"  	+ chr(13)+chr(10)
EndIf

If !empty(MV_PAR11) //Filtra por municipio
	cCond += " AND A1_MUN ='"+ MV_PAR11 +"'						  						"  	+ chr(13)+chr(10)
EndIf


cCond += "   JOIN "+RetSqlName("SB1")+" B1 (NOLOCK)   ON B1_COD = D1_COD				"	+ chr(13)+chr(10)
cCond += "                                                AND B1.D_E_L_E_T_ = ''		"	+ chr(13)+chr(10)
cCond += "					                              AND B1_GRUPO = '0009'			"	+ chr(13)+chr(10)
If MV_PAR07 == 2
	
	If MV_PAR06 == 1
		cCond += "                             AND B1.B1_DIVISAO = '1'					"	+ chr(13)+chr(10)
	ElseIf MV_PAR06 == 2
		cCond += "                             AND B1.B1_DIVISAO = '2'					"	+ chr(13)+chr(10)
	ElseIf MV_PAR06 == 3
		cCond += "                             and b1.B1_GRUPO <> '0009'					"	+ chr(13)+chr(10)
		cCond += "                             AND B1_CODFOR NOT IN('01','A4','83','A7','A8') "	+ chr(13)+chr(10)
		cCond += "                             AND B1.B1_DIVISAO = '3'					"	+ chr(13)+chr(10)
	ElseIf MV_PAR06 == 4
		cCond += "                             AND B1.B1_CODFOR = '01'					"	+ chr(13)+chr(10)
		cCond += "                             AND B1.B1_DIVISAO = '4'					"	+ chr(13)+chr(10)
	ElseIf MV_PAR06 == 5
		//	_Query1 += "                             AND B1.B1_GRUPO = '0009'					"	+ chr(13)+chr(10)
		cCond += "                             AND B1.B1_DIVISAO = '5'					"	+ chr(13)+chr(10)
		cCond += "                             AND B1.B1_CODFOR IN('73','76')				"	+ chr(13)+chr(10)
	EndIf
ENDIF
cCond += "  WHERE D1.D_E_L_E_T_ = ''													"	+ chr(13)+chr(10)
cCond += "    AND D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR08) + "' AND '" + DTOS(MV_PAR09) +"' "	+ chr(13)+chr(10)
cCond += "    AND SUBSTRING(D1_CF,2,3) IN('32','202')									"	+ chr(13)+chr(10)
cCond += "   AND D1_FILIAL  = '"+ AVEND1[nCount][1] +"'   								"	+ chr(13)+chr(10)

cCond += " GROUP BY B1_DIVISAO  														"	+ chr(13)+chr(10)
cCond += " ORDER BY B1_DIVISAO  														"	+ chr(13)+chr(10)
Memowrit( "D:\Query\rfatr225.SQL", cCond )
TCQUERY cCond ALIAS QSD25 NEW

*------------------------------------------------------------------------------------------------------------
* Guardo o valor do_ faturamento por fertilizante
*------------------------------------------------------------------------------------------------------------
DbSelectArea("QSD25")
nDevFert := QSD25->TOTD1
QSD25->(DBCloseArea())
nDevFert1 += nDevFert


*------------------------------------------------------------------------------------------------------------
* Query com o faturamento de pastagem
*------------------------------------------------------------------------------------------------------------

_Quer := " SELECT B1_DIVISAO ,SUM(D2_TOTAL) AS TOTD2 								"	+ chr(13)+chr(10)
_Quer += "   FROM "+RetSqlName("SD2")+" D2 (NOLOCK) 									"	+ chr(13)+chr(10)
_Quer += "   LEFT JOIN   "+RetSqlName("SF4")+" F4 (NOLOCK) ON F4.F4_CODIGO = D2_TES		"	+ chr(13)+chr(10)
_Quer += "					                              AND F4.D_E_L_E_T_ = ''        "	+ chr(13)+chr(10)
_Quer += "					  					          AND F4_DUPLIC     <> 'N'      "	+ chr(13)+chr(10)
_Quer += "  JOIN "+RetSqlName("SB1")+" B1 (NOLOCK)    ON B1_COD        = D2_COD     	"	+ chr(13)+chr(10)
_Quer += "  				                              AND B1.D_E_L_E_T_ = ''		"	+ chr(13)+chr(10)
_Quer += "				                                  AND B1.B1_CODFOR IN('A4','83','A7','A8') "	+ chr(13)+chr(10)
If MV_PAR07 == 2
	
	If MV_PAR06 == 1
		_Quer += "                             AND B1.B1_DIVISAO = '1'					"	+ chr(13)+chr(10)
	ElseIf MV_PAR06 == 2
		_Quer += "                             AND B1.B1_DIVISAO = '2'					"	+ chr(13)+chr(10)
	ElseIf MV_PAR06 == 3
		_Quer += "                             and b1.B1_GRUPO <> '0009'					"	+ chr(13)+chr(10)
		_Quer += "                             AND B1_CODFOR NOT IN('01','A4','83','A7','A8') "	+ chr(13)+chr(10)
		_Quer += "                             AND B1.B1_DIVISAO = '3'					"	+ chr(13)+chr(10)
	ElseIf MV_PAR06 == 4
		_Quer += "                             AND B1.B1_CODFOR = '01'					"	+ chr(13)+chr(10)
		_Quer += "                             AND B1.B1_DIVISAO = '4'					"	+ chr(13)+chr(10)
	ElseIf MV_PAR06 == 5
		//	_Query1 += "                             AND B1.B1_GRUPO = '0009'					"	+ chr(13)+chr(10)
		_Quer += "                             AND B1.B1_DIVISAO = '5'					"	+ chr(13)+chr(10)
		_Quer += "                             AND B1.B1_CODFOR IN('73','76')				"	+ chr(13)+chr(10)
	EndIf
ENDIF

_quer += "  JOIN "+RetSqlName("SF2")+" F2 (NOLOCK) ON F2_DOC = D2_DOC					"	+ chr(13)+chr(10)
_Quer += "                                        AND F2_SERIE  = D2_SERIE  			"	+ chr(13)+chr(10)
_Quer += "				                          AND F2_FILIAL = D2_FILIAL 			"	+ chr(13)+chr(10)
_Quer += "				                          AND F2.D_E_L_E_T_ = ''  				"	+ chr(13)+chr(10)
_Quer += "   											AND F2_VEND1 = '"+ aVEND1[nCount][2] +"' "  	+ chr(13)+chr(10)

_Quer += " WHERE D2.D_E_L_E_T_ = ''														"	+ chr(13)+chr(10)
_Quer += "   AND SUBSTRING(D2.D2_CF,2,3) IN('12','102','922','108')                		"	+ chr(13)+chr(10)
_Quer += "   AND D2_EMISSAO  BETWEEN  '" + DTOS(MV_PAR08) + "' AND '" + DTOS(MV_PAR09) +"' "	+ chr(13)+chr(10)
_Quer += "   AND D2_FILIAL  = '"+AVEND1[nCount][1]+"'   								"	+ chr(13)+chr(10)

If !empty(MV_PAR10) //Filtrar por estado também
	_Quer += "   AND D2_EST  = '"+ MV_PAR10+"'			   								"	+ chr(13)+chr(10)
EndIf

_Quer += " GROUP BY B1_DIVISAO  														"	+ chr(13)+chr(10)
_Quer += " ORDER BY B1_DIVISAO  														"	+ chr(13)+chr(10)
Memowrit( "D:\Query\rfatr222.SQL", _QUER )
TCQUERY _Quer ALIAS QSD21 NEW

*------------------------------------------------------------------------------------------------------------
* Guardo o valor do_ faturamento por pastagem
*------------------------------------------------------------------------------------------------------------
DbSelectArea("QSD21")
nFatPast := QSD21->TOTD2
QSD21->(DBCloseArea())
nFatPast1 += nFatPast



*------------------------------------------------------------------------------------------------------------
* Query com as_ devoluções de pastagem
*------------------------------------------------------------------------------------------------------------
_Quer1 := " SELECT B1_DIVISAO ,SUM(D1_TOTAL) AS TOTD1 									"	+ chr(13)+chr(10)
_Quer1 += "   FROM "+RetSqlName("SD1")+" D1 (NOLOCK) 									"	+ chr(13)+chr(10)
_Quer1 += "   LEFT JOIN   "+RetSqlName("SF4")+" F4 (NOLOCK) ON F4.F4_CODIGO = D1_TES	"	+ chr(13)+chr(10)
_Quer1 += "	  				                               AND F4.D_E_L_E_T_ = ''       "	+ chr(13)+chr(10)
_Quer1 += " 					  					       AND F4_DUPLIC     <> 'N'     "	+ chr(13)+chr(10)
_Quer1 += "  JOIN "+RetSqlName("SA1")+" A1 (NOLOCK)  ON A1_COD = D1_FORNECE 			"  	+ chr(13)+chr(10)
_Quer1 += "                                         AND A1_LOJA = D1_LOJA				"  	+ chr(13)+chr(10)

If !empty(MV_PAR10) //Filtra por estado
	_Quer1 += " AND A1_EST ='"+ MV_PAR10 +"'											"  	+ chr(13)+chr(10)
EndIf

If !empty(MV_PAR11) //Filtra por municipio
	_Quer1 += " AND A1_MUN ='"+ MV_PAR11 +"'						  					"  	+ chr(13)+chr(10)
EndIf

_Quer1 += "   JOIN "+RetSqlName("SB1")+" B1 (NOLOCK)    ON B1_COD        = D1_COD     	"	+ chr(13)+chr(10)
_Quer1 += "				                               AND B1.D_E_L_E_T_ = ''		  	"	+ chr(13)+chr(10)
_Quer1 += "			                                   AND B1.B1_CODFOR IN('A4','83','A7','A8') "	+ chr(13)+chr(10)
If MV_PAR07 == 2
	
	If MV_PAR06 == 1
		_Quer1 += "                             AND B1.B1_DIVISAO = '1'					"	+ chr(13)+chr(10)
	ElseIf MV_PAR06 == 2
		_Quer1 += "                             AND B1.B1_DIVISAO = '2'					"	+ chr(13)+chr(10)
	ElseIf MV_PAR06 == 3
		_Quer1 += "                             and b1.B1_GRUPO <> '0009'				"	+ chr(13)+chr(10)
		_Quer1 += "                             AND B1_CODFOR NOT IN('01','A4','83','A7','A8') "	+ chr(13)+chr(10)
		_Quer1 += "                             AND B1.B1_DIVISAO = '3'					"	+ chr(13)+chr(10)
	ElseIf MV_PAR06 == 4
		_Quer1 += "                             AND B1.B1_CODFOR = '01'					"	+ chr(13)+chr(10)
		_Quer1 += "                             AND B1.B1_DIVISAO = '4'					"	+ chr(13)+chr(10)
	ElseIf MV_PAR06 == 5
		//	_Query1 += "                             AND B1.B1_GRUPO = '0009'					"	+ chr(13)+chr(10)
		_Quer1 += "                             AND B1.B1_DIVISAO = '5'					"	+ chr(13)+chr(10)
		_Quer1 += "                             AND B1.B1_CODFOR IN('73','76')				"	+ chr(13)+chr(10)
	EndIf
ENDIF
_Quer1 += "  WHERE D1.D_E_L_E_T_ = ''													"	+ chr(13)+chr(10)

_Quer1 += "    AND D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR08) + "' AND '" + DTOS(MV_PAR09) +"' " + chr(13)+chr(10)
_Quer1 += "    AND SUBSTRING(D1_CF,2,3) IN('32','202')									"	+ chr(13)+chr(10)
_Quer1 += "   AND D1_FILIAL  = '"+ AVEND1[nCount][1]+"'   								"	+ chr(13)+chr(10)

_Quer1 += " GROUP BY B1_DIVISAO  														"	+ chr(13)+chr(10)
_Quer1 += " ORDER BY B1_DIVISAO  														"	+ chr(13)+chr(10)
Memowrit( "D:\Query\rfatr226.SQL", cCond )
TCQUERY _Quer1 ALIAS QSD26 NEW

*------------------------------------------------------------------------------------------------------------
* Guardo o valor do_ faturamento por pastagem
*------------------------------------------------------------------------------------------------------------
DbSelectArea("QSD26")
nDevPast := QSD26->TOTD1
QSD26->(DBCloseArea())
nDevPast1 += nDevpast


*------------------------------------------------------------------------------------------------------------
* Query com os valores em carteira
*------------------------------------------------------------------------------------------------------------

For bru := 1 to 7
	
	cCart := " SELECT B1.B1_DIVISAO,SUM(((C6_QTDVEN-C6_QTDENT)*C6_PRCVEN)) 	AS TOTCAR		"	+ chr(13)+chr(10)
	cCart += "   FROM "+RetSqlName("SC6")+" SC6 (NOLOCK)									"	+ chr(13)+chr(10)
	cCart += "   JOIN "+RetSqlName("SF4")+" F4 (NOLOCK)  ON F4_CODIGO  = C6_TES				"	+ chr(13)+chr(10)
	cCart += "               						    AND F4.D_E_L_E_T_ = ''        		"	+ chr(13)+chr(10)
	cCart += "						                    AND F4_DUPLIC     <> 'N'      		"	+ chr(13)+chr(10)
	cCart += "   JOIN "+RetSqlName("SC5")+" SC5 (NOLOCK) ON C5_FILIAL  = C6_FILIAL    		"	+ chr(13)+chr(10)
	cCart += "                                          AND C5_NUM     = C6_NUM   			"	+ chr(13)+chr(10)
	cCart += "                                          AND C5_EMISSAO <= " + DTOS(MV_PAR09)	+ chr(13)+chr(10)
	cCart += "   											AND C5_VEND1 = '"+ aVEND1[nCount][2] +"' "  	+ chr(13)+chr(10)
	
	cCart += "   JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK) ON C5_CLIENTE = A1_COD		   		"	+ chr(13)+chr(10)
	cCart += "                                          AND A1_LOJA = C5_LOJACLI			"	+ chr(13)+chr(10)
	
	If !empty(MV_PAR10)  //Filtrar por estado
		cCart += "                                      AND A1_EST = '"+ MV_PAR10 +"'"			+ chr(13)+chr(10)
	EndIf
	
	If !empty(MV_PAR11)  //Filtrar por MUNICIPIO
		cCart += "                                      AND A1_MUN = '"+ MV_PAR11 +"'"			+ chr(13)+chr(10)
	EndIf
	
	
	cCart += "   JOIN "+RetSqlName("SB1")+" B1 (NOLOCK)  ON B1_COD = C6_PRODUTO				"	+ chr(13)+chr(10)
	cCart += "                                          AND B1.D_E_L_E_T_ = ''				"	+ chr(13)+chr(10)
	If MV_PAR07 == 2
		
		If MV_PAR06 == 1
			cCart += "                             AND B1.B1_DIVISAO = '1'					"	+ chr(13)+chr(10)
		ElseIf MV_PAR06 == 2
			cCart += "                             AND B1.B1_DIVISAO = '2'					"	+ chr(13)+chr(10)
		ElseIf MV_PAR06 == 3
			cCart += "                             and b1.B1_GRUPO <> '0009'					"	+ chr(13)+chr(10)
			cCart += "                             AND B1_CODFOR NOT IN('01','A4','83','A7','A8') "	+ chr(13)+chr(10)
			cCart += "                             AND B1.B1_DIVISAO = '3'					"	+ chr(13)+chr(10)
		ElseIf MV_PAR06 == 4
			cCart += "                             AND B1.B1_CODFOR = '01'					"	+ chr(13)+chr(10)
			cCart += "                             AND B1.B1_DIVISAO = '4'					"	+ chr(13)+chr(10)
		ElseIf MV_PAR06 == 5
			//	_Query1 += "                             AND B1.B1_GRUPO = '0009'					"	+ chr(13)+chr(10)
			cCart += "                             AND B1.B1_DIVISAO = '5'					"	+ chr(13)+chr(10)
			cCart += "                             AND B1.B1_CODFOR IN('73','76')				"	+ chr(13)+chr(10)
		EndIf
		EXIT
	ELSE
		If bru = 1      //Divisão agrícola
			cCart += "                                       AND B1.B1_DIVISAO = '1'				"	+ chr(13)+chr(10)
		ElseIf bru = 2  //Divisao atacado
			cCart += "                                       AND B1.B1_DIVISAO = '2'				"	+ chr(13)+chr(10)
		ElseIf bru = 3  //Divisao veterinaria
			cCart += "                             and b1.B1_GRUPO <> '0009'					"	+ chr(13)+chr(10)
			cCart += "                             AND B1_CODFOR NOT IN('01','A4','83','A7','A8') "	+ chr(13)+chr(10)
			cCart += "                             AND B1.B1_DIVISAO = '3'				  		"	+ chr(13)+chr(10)
		ElseIf bru = 4  //Divisao Bayer PCO
			cCart += "                             AND B1.B1_CODFOR = '01'				   		"	+ chr(13)+chr(10)
			cCart += "                             AND B1.B1_DIVISAO = '4'						"	+ chr(13)+chr(10)
		ElseIf bru = 5  //Peça Costal
			cCart += "                             AND B1.B1_DIVISAO = '5'						"	+ chr(13)+chr(10)
			cCart += "                             AND B1.B1_CODFOR IN('73','76')				"	+ chr(13)+chr(10)
		ElseIf bru = 6  //Fertilizantes
			cCart += "	                           AND B1_GRUPO = '0009' 						"	+ chr(13)+chr(10)
		ElseIf bru = 7  //Pastagem
			cCart += "                             AND B1_CODFOR IN('A4','83','A7','A8')		"	+ chr(13)+chr(10)
		EndIf
	ENDIF
	
	cCart += "  WHERE SC6.D_E_L_E_T_ = ''													"	+ chr(13)+chr(10)
	cCart += "   AND SC6.C6_FILIAL  = '"+AVEND1[nCount][1]+"'   							"	+ chr(13)+chr(10)
	cCart += "    AND (C6_QTDVEN-C6_QTDENT) > 0												"	+ chr(13)+chr(10)
	cCart += "    AND C6_BLQ <> 'R'															"	+ chr(13)+chr(10)
	cCart += "    AND SUBSTRING(C6_CF,2,3) IN('12 ','102','922','108')						"	+ chr(13)+chr(10)
	cCart += "  GROUP BY B1_DIVISAO 														"	+ chr(13)+chr(10)
	cCart += "  ORDER BY B1_DIVISAO 														"	+ chr(13)+chr(10)
	
	Memowrit( "D:\Query\rfatr228.SQL", cCart )
	TCQUERY cCart ALIAS QSC6 NEW
	
	*------------------------------------------------------------------------------------------------------------
	* Carrego um array_ com os valores em carteira
	*------------------------------------------------------------------------------------------------------------
If 	bru = 1	//Divisão Agricola
		DbSelectArea("QSC6")
		AADD(ACart,QSC6->TOTCAR)
		QSC6->(DBCloseArea())
		nCart += ACart[1]
	ElseIf 	bru = 2 	//Divisão Atacado
		DbSelectArea("QSC6")
		AADD(ACart,QSC6->TOTCAR)
		QSC6->(DBCloseArea())
		nCart1 += ACart[2]
	ElseIf 	bru = 3   //Divisão Veterinária
		DbSelectArea("QSC6")
		AADD(ACart,QSC6->TOTCAR)
		QSC6->(DBCloseArea())
		nCart2 += ACart[3]
	ElseIf 	bru = 4	//Divisão Bayer
		DbSelectArea("QSC6")
		AADD(ACart,QSC6->TOTCAR)
		QSC6->(DBCloseArea())
		nCart3 += ACart[4]
	ElseIf 	bru = 5	//Divisão Peças Costal
		DbSelectArea("QSC6")
		AADD(ACart,QSC6->TOTCAR)
		QSC6->(DBCloseArea())
		nCart4 += ACart[5]
	ElseIf 	bru = 6	//Fertilizante
		DbSelectArea("QSC6")
		AADD(ACart,QSC6->TOTCAR)
		QSC6->(DBCloseArea())
		nCart5 += ACart[6]
	ElseIf 	bru = 7	//Pastagem
		DbSelectArea("QSC6")
		AADD(ACart,QSC6->TOTCAR)
		QSC6->(DBCloseArea())
		nCart6 += ACart[7]
	EndIf
	
	
Next


/*

*------------------------------------------------------------------------------------------------------------
* Divisao de fertilizante
*------------------------------------------------------------------------------------------------------------

_Que := " SELECT B1_DIVISAO,SUM(D2_TOTAL) AS TOTD2										"	+ chr(13)+chr(10)
_Que += "   FROM "+RetSqlName("SD2")+" D2 (NOLOCK) 										"	+ chr(13)+chr(10)
_Que += "  LEFT JOIN   "+RetSqlName("SF4")+" F4 (NOLOCK) ON F4.F4_CODIGO     = D2_TES	"	+ chr(13)+chr(10)
_Que += "                                AND F4.D_E_L_E_T_ = ''        					"   + chr(13)+chr(10)
_Que += " 						         AND F4_DUPLIC     <> 'N'      					"   + chr(13)+chr(10)
_Que += "  JOIN "+RetSqlName("SB1")+" B1 (NOLOCK)   ON B1_COD        = D2_COD 		"   + chr(13)+chr(10)
_Que += "  			                                    AND B1.D_E_L_E_T_ = ''			"   + chr(13)+chr(10)
_Que += "				                                AND B1.B1_GRUPO = '0009' 		"   + chr(13)+chr(10)
_Que += "				                                and B1.B1_DIVISAO = 1  			"   + chr(13)+chr(10)
_Que += "  JOIN "+RetSqlName("SB1")+" F2 (NOLOCK) ON F2_DOC    = D2_DOC					"   + chr(13)+chr(10)
_Que += "				                         AND F2_SERIE  = D2_SERIE  				"   + chr(13)+chr(10)
_Que += "				                         AND F2_FILIAL = D2_FILIAL 				"   + chr(13)+chr(10)
_Que += "				                         AND F2.D_E_L_E_T_ = '' 				"   + chr(13)+chr(10)
_Que += " WHERE D2.D_E_L_E_T_ = ''  													"   + chr(13)+chr(10)
_Que += "   AND SUBSTRING(D2.D2_CF,2,3) IN('12','102','922','108')                		"   + chr(13)+chr(10)
_Que += "   AND D2_DTDIGIT  BETWEEN  '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) +"' 			"	+ chr(13)+chr(10)
_Que += "    AND SUBSTRING(D1_CF,2,3) IN('32','202')									"	+ chr(13)+chr(10)

If MV_PAR01 = 2 //Só traz a filial que esta logada no momento
_Que += "   AND D2_FILIAL  = '"+ xFilial("SD2")+"'   								"	+ chr(13)+chr(10)
EndIf

_Que += " GROUP BY B1_DIVISAO  															"	+ chr(13)+chr(10)
_Que += " ORDER BY B1_DIVISAO  															"	+ chr(13)+chr(10)
Memowrit( "D:\Query\rfatr223.SQL", _QUE )
TCQUERY _Que ALIAS QSD22 NEW
*------------------------------------------------------------------------------------------------------------
* Guardo o valor do_ Faturamento de Fertilizando
*------------------------------------------------------------------------------------------------------------
DbSelectArea("QSD22")
nValFert := QSD22->TOTD2
QSD22->(DBCloseArea())

*/


If MV_PAR12 = 1  //Impressora Laser
	
	//oPrint:= TMSPrinter():New(".: Mapa de Faturamento :.")
	//oPrint:SetPortrait()			//SetLandscape()
	
	fImpCabR("Mapa de Faturamento")
	
	*------------------------------------------------------------------
	* Chama a função de impressão do_ relatório na impressora Laser
	*------------------------------------------------------------------
	fImpDet()
	
	//oPrint:Preview()
	
else //Impressora Matricial
	*------------------------------------------------------------------
	* Chama a função de impressão do_ relatório na impressora Matricial
	*------------------------------------------------------------------
	
	ImpFat()
//	u_rfatr22k()
EndIf


NEXT

If nCount == Len(aVEND1)+1
	If MV_PAR12 = 1  //Impressora Laser

			fImpCabR("Mapa de Faturamento")
			*------------------------------------------------------------------
			* Chama a função de impressão do_ relatório na impressora Laser
			*------------------------------------------------------------------
			fImpDet()

	else //Impressora Matricial
			*------------------------------------------------------------------
			* Chama a função de impressão do_ relatório na impressora Matricial
			*------------------------------------------------------------------

			ImpFat()
		//	u_rfatr22k()
	EndIf
EndIf

	If MV_PAR12 = 1
		oPrint:Preview()
	else
		Set Filter To
		If aReturn[5] == 1
 			Set Printer To
 			Commit
    		ourspool(cwnrel) //Chamada do Spool de Impressao
		Endif
		MS_FLUSH() //Libera fila de relatorios em spool
	ENDIF

Return



*************************************************************************
Static Function fImpCabR(pCabec)
*************************************************************************

oPrint:StartPage()
lPrimeiro := .t.
wnPag ++

If File( cFileLogo )
	oPrint:SayBitmap(0085,0075, cFileLogo, 300,100) 		//oPrint:SayBitmap(0085,0075, cFileLogo)
EndIf

oPrint:Box  (0050, 0030, 0200, 2350)
oPrint:Box  (0210, 0030, 0310, 2350)
oPrint:Line (0050, 0450, 0200, 0450)
oPrint:Line (0050, 2000, 0200, 2000)

oPrint:Say  (0085 ,0550, pCabec         	,oFont12)



oPrint:Say  (0070 ,2020, "Data...:"			,oFont10)
oPrint:Say  (0070 ,2160, DtoC(dDataBase)	,oFont10)

oPrint:Say  (0140 ,0550, "Período : "+dtoc(MV_PAR05) +" A "+ dtoc(MV_PAR06),oFont10)

IF !EMPTY(MV_PAR07)
	oPrint:Say  (0140 ,1150, "Estado : " + MV_PAR07         	,oFont10)
ENDIF


IF !EMPTY(MV_PAR10)
	oPrint:Say  (0140 ,1600, "Municipio : " + MV_PAR10,oFont10)
ENDIF
oPrint:Say  (0140 ,2020, "Página:     01 "			,oFont10)
//oPrint:Say  (0140 ,2160, StrZero(wnPag,3)	,oFont10)

nLin := 240

If MV_PAR03 == 1
	W_DIV := ".T."
	cFila  := " Agr.+Ata.+Vet.+Bay.+Pec."
else
	If MV_PAR02 == 1
		cFila  := " Agricola"
	ElseIf MV_PAR02 == 2
		cFila  := " Atacado"
	ElseIf MV_PAR02 == 3
		cFila  := " Veterinaria"
	ElseIf MV_PAR02 == 4
		cFila  := " Bayer Pco"
	ElseIf MV_PAR02 == 5
		cFila  := " Pecas Jacto"
	EndIf
endif
If mv_par01==1
	mv:="CONSOLIDADO"
ELSE
	mv:=Trim(sm0->m0_filial)
ENDIF

oPrint:Say  (nLin ,0065, MV,oFont10)
//oPrint:Say  (nLin ,0250, "MOTIVO",oFont10)
//oPrint:Say  (nLin ,0500, "APROVADOR",oFont10)
//oPrint:Say  (nLin ,0720, "PED.",oFont10)
oPrint:Say  (nLin ,0850, cFila,oFont10)
//oPrint:Say  (nLin ,1420, "DT PED.",oFont10)
//oPrint:Say  (nLin ,1610, "REPRESENTANTE",oFont10)
oPrint:Say  (nLin ,2170, "RFATR22N",oFont10)
nLin := 340

Return

*------------------------------------------------------------------------------
* Bruno Santos                                                     | 06/04/2011
*------------------------------------------------------------------------------
* Função: fImpDet
*------------------------------------------------------------------------------
* Objetivo :  Impressão propriamente dita do_ mapa de faturamento em impressora
*             Laser
*------------------------------------------------------------------------------

**************************************************************************
Static Function fImpDet()
**************************************************************************

oPrint:Say  (nLin ,0065, PADR("DIVISAO AGRICOLA : " ,21), oFont12); oPrint:Say  (nLin ,1550, PADR("CARTEIRA" ,10), oFont12)
nLin += 050
oPrint:Say  (nLin ,0530, "FATURAMENTO" ,oFont10);   oPrint:Say  (nLin ,0762,  " : ",oFont10);	oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nValFat, aValFat[1]),'@E 999,999,999.99' ),14), oFont10)
nLin += 050
oPrint:Say  (nLin ,0530, "DEVOLUCAO" ,oFont10)	;   oPrint:Say  (nLin ,0762,  " : ",oFont10);	oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nValDev, aValDEV[1]),'@E 999,999,999.99' ),14), oFont10)
nLin += 050
oPrint:Say  (nLin ,0530, "SALDO" ,oFont10)		;   oPrint:Say  (nLin ,0762,  " : ",oFont10);	oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nValfat-nValDev,aValFat[1]-aValDev[1]), '@E 999,999,999.99' ),14), oFont10)
oPrint:Say  (nLin ,1550, padr(Transform(iif(nCount == len(aVEND1)+1,nCart,aCART[1]), '@E 999,999,999.99' ),14), oFont10)
nLin += 150

oPrint:Say  (nLin ,0065, padr("DIVISAO FERTILIZANTE : " ,100), oFont12)
nLin += 050
oPrint:Say  (nLin ,0530, "FATURAMENTO" ,oFont10);   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nFatFert1,nFatFert),              '@E 999,999,999.99' ),14), oFont10)
nLin += 050
oPrint:Say  (nLin ,0530, "DEVOLUCAO" ,oFont10)	;   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nDevFert1,nDevFert),        '@E 999,999,999.99' ),14), oFont10)
nLin += 050
oPrint:Say  (nLin ,0530, "SALDO" ,oFont10)		;   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nFatFert1-nDevFert1,nFatFert-nDevFert),     '@E 999,999,999.99' ),14), oFont10)
oPrint:Say  (nLin ,1550, padr(Transform(iif(nCount == len(aVEND1)+1,nCart5,aCART[6]), '@E 999,999,999.99' ),14), oFont10)
nLin += 150

oPrint:Say  (nLin ,0065, PADR("TOTAL DIV.AGRICOLA : "  ,100), oFont12)
nLin += 050
oPrint:Say  (nLin ,0530, "FATURAMENTO" ,oFont10);   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nValFat+nFatFert1,aValFat[1]+nFatFert),  '@E 999,999,999.99' ),14), oFont10)
nLin += 050
oPrint:Say  (nLin ,0530, "DEVOLUCAO" ,oFont10)	;   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nValDev+nDevFert1,aValDev[1]+nDevFert),   '@E 999,999,999.99' ),14), oFont10)
nLin += 050

nSaldo3 := (aValFat[1]+nFatFert)-(aValDev[1]+nDevFert)
nSaldo4 := (nValFat+nFatFert1)-(nValDev+nDevFert1)
oPrint:Say  (nLin ,0530, "SALDO" ,oFont10)		;   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nSaldo4,nSaldo3 ),              '@E 999,999,999.99' ),14), oFont10)
oPrint:Say  (nLin ,1550, padr(Transform(iif(nCount == len(aVEND1)+1,nCart+nCart5,aCART[1]+aCART[6]), '@E 999,999,999.99' ),14), oFont10)
nLin += 150

oPrint:Say  (nLin ,0065, PADR("DIVISAO ATACADO : "  ,100), oFont12)
nLin += 050
oPrint:Say  (nLin ,0530, "FATURAMENTO" ,oFont10);   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nValFat1,aValFat[2]),            '@E 999,999,999.99' ),14), oFont10)
nLin += 050
oPrint:Say  (nLin ,0530, "DEVOLUCAO" ,oFont10)	;   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nValDev1,aValDev[2]),            '@E 999,999,999.99' ),14), oFont10)
nLin += 050
oPrint:Say  (nLin ,0530, "SALDO" ,oFont10)		;   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nValFat1 - nValDev1,aValFat[2]-aValDev[2]) ,'@E 999,999,999.99' ),14), oFont10)
oPrint:Say  (nLin ,1550, padr(Transform(iif(nCount == len(aVEND1)+1,nCart1,aCART[2]), '@E 999,999,999.99' ),14), oFont10)
nLin += 150

oPrint:Say  (nLin ,0065, PADR("DIVISAO PASTAGEM : "  ,100), oFont12)
nLin += 050
oPrint:Say  (nLin ,0530, "FATURAMENTO" ,oFont10);   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nFatPast1,nFatPast),              '@E 999,999,999.99' ),14), oFont10)
nLin += 050
oPrint:Say  (nLin ,0530, "DEVOLUCAO" ,oFont10)	;   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nDevPast1,nDevPast),              '@E 999,999,999.99' ),14), oFont10)
nLin += 050
oPrint:Say  (nLin ,0530, "SALDO" ,oFont10)		;   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nFatPast1-nDevPast1 ,nFatPast-nDevPast ),    '@E 999,999,999.99' ),14), oFont10)
oPrint:Say  (nLin ,1550, padr(Transform(iif(nCount == len(aVEND1)+1,nCart6,aCART[7]), '@E 999,999,999.99' ),14), oFont10)
nLin += 150

oPrint:Say  (nLin ,0065, PADR("DIVISAO VETERINA. : "  ,100), oFont12)
nLin += 050
oPrint:Say  (nLin ,0530, "FATURAMENTO" ,oFont10);   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nValFat2,aValFat[3]),            '@E 999,999,999.99' ),14), oFont10)
nLin += 050
oPrint:Say  (nLin ,0530, "DEVOLUCAO" ,oFont10)	;   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nValDev2,aValDev[3]),            '@E 999,999,999.99' ),14), oFont10)
nLin += 050
oPrint:Say  (nLin ,0530, "SALDO" ,oFont10)		;   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nValFat2 - nValDev2,aValFat[3]-aValDev[3] ),'@E 999,999,999.99' ),14), oFont10)
oPrint:Say  (nLin ,1550, padr(Transform(iif(nCount == len(aVEND1)+1,nCart2,aCART[3]), '@E 999,999,999.99' ),14), oFont10)
nLin += 150

oPrint:Say  (nLin ,0065, PADR("DIVISAO BAYER PCO : "  ,100), oFont12)
nLin += 050
oPrint:Say  (nLin ,0530, "FATURAMENTO" ,oFont10);   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nValFat3,aValFat[4]),            '@E 999,999,999.99' ),14), oFont10)
nLin += 050
oPrint:Say  (nLin ,0530, "DEVOLUCAO" ,oFont10)	;   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nValDev3,aValDev[4]),            '@E 999,999,999.99' ),14), oFont10)
nLin += 050
oPrint:Say  (nLin ,0530, "SALDO" ,oFont10)		;   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nValFat3 - nValDev3,aValFat[4]-aValDev[4]) ,'@E 999,999,999.99' ),14), oFont10)
oPrint:Say  (nLin ,1550, padr(Transform(iif(nCount == len(aVEND1)+1,nCart3,aCART[4]), '@E 999,999,999.99' ),14), oFont10)
nLin += 150

oPrint:Say  (nLin ,0065, PADR("DIVISAO PECAS COSTAL : "  ,100), oFont12)
nLin += 050
oPrint:Say  (nLin ,0530, "FATURAMENTO" ,oFont10);   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nValFat4,aValFat[5]),            '@E 999,999,999.99' ),14), oFont10)
nLin += 050
oPrint:Say  (nLin ,0530, "DEVOLUCAO" ,oFont10)	;   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nValDev4,aValDev[5]),            '@E 999,999,999.99' ),14), oFont10)
nLin += 050
oPrint:Say  (nLin ,0530, "SALDO" ,oFont10)		;   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nValFat4 - nValDev4,aValFat[5]-aValDev[5]) ,'@E 999,999,999.99' ),14), oFont10)
oPrint:Say  (nLin ,1550, padr(Transform(iif(nCount == len(aVEND1)+1,nCart4,aCART[5]), '@E 999,999,999.99' ),14), oFont10)
nLin += 150


oPrint:Say  (nLin ,0065, PADR("TOTAL DIV.ATACADO : "  ,100), oFont12)
nLin += 050
oPrint:Say  (nLin ,0530, "FATURAMENTO" ,oFont10);   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nValFat1+nValFat2+nValFat3+nValFat4+nFatPast1,aValFat[2]+aValFat[3]+aValFat[4]+aValFat[5]+nFatPast),'@E 999,999,999.99' ),14), oFont10)
nLin += 050
oPrint:Say  (nLin ,0530, "DEVOLUCAO" ,oFont10)	;   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nValDev1+nValDev2+nValDev3+nValDev4+nDevPast1,aValDev[2]+aValDev[3]+aValDev[4]+aValDev[5]+nDevPast),'@E 999,999,999.99' ),14), oFont10)
nLin += 050
nSaldo1 :=(aValFat[2]+aValFat[3]+aValFat[4]+aValFat[5]+nFatPast)-(aValDev[2]+aValDev[3]+aValDev[4]+aValDev[5]+nDevPast)
nSaldo2 :=(nValFat1+nValFat2+nValFat3+nValFat4+nFatPast1)-(nValDev1+nValDev2+nValDev3+nValDev4+nDevPast1)
oPrint:Say  (nLin ,0530, "SALDO" ,oFont10)		;   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nSaldo2,nSaldo1 ),              '@E 999,999,999.99' ),14), oFont10)
oPrint:Say  (nLin ,1550, padr(Transform(iif(nCount == len(aVEND1)+1,nCart1+ nCART6+ nCART2+ nCART3+ nCART4,aCART[2]+ aCART[7]+ aCART[3]+ aCART[4]+ aCART[5]), '@E 999,999,999.99' ),14), oFont10)
nLin += 150



oPrint:Say  (nLin ,0065, PADR("TOTAL GERAL : "  ,100), oFont12)
nLin += 050
oPrint:Say  (nLin ,0530, "FATURAMENTO" ,oFont10);   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nValFat+nValFat1+nValFat2+nValFat3+nValFat4+nFatPast1+nFatFert1,aValFat[1]+aValFat[2]+aValFat[3]+aValFat[4]+aValFat[5]+nFatPast+nFatFert),'@E 999,999,999.99' ),14), oFont10)
nLin += 050
oPrint:Say  (nLin ,0530, "DEVOLUCAO" ,oFont10)	;   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nValDev+nValDev1+nValDev2+nValDev3+nValDev4+nDevPast1+nDevFert1,aValDev[1]+aValDev[2]+aValDev[3]+aValDev[4]+aValDev[5]+nDevPast+nDevFert),'@E 999,999,999.99' ),14), oFont10)
nLin += 050
nSaldo :=(aValFat[1]+aValFat[2]+aValFat[3]+aValFat[4]+aValFat[5]+nFatPast+nFatFert)-(aValDev[1]+aValDev[2]+aValDev[3]+aValDev[4]+aValDev[5]+nDevPast+nDevFert)
nSaldo6 :=(nValFat+nValFat1+nValFat2+nValFat3+nValFat4+nFatPast1+nFatFert1)-(nValDev+nValDev1+nValDev2+nValDev3+nValDev4+nDevPast1+nDevFert1)
oPrint:Say  (nLin ,0530, "SALDO" ,oFont10)		;   oPrint:Say  (nLin ,0762," : ",oFont10);      oPrint:Say  (nLin ,0810, padr(Transform(iif(nCount == len(aVEND1)+1,nSaldo6,nSaldo ),               '@E 999,999,999.99' ),14), oFont10)
oPrint:Say  (nLin ,1550, padr(Transform(iif(nCount == len(aVEND1)+1,nCART1+ nCART6+ nCART2+ nCART3+ nCART4+nCART+nCART5,aCART[2]+ aCART[7]+ aCART[3]+ aCART[4]+ aCART[5]+aCART[1]+aCART[6]), '@E 999,999,999.99' ),14), oFont10)
nLin += 150

oPrint:Line (nLin, 0035, nLin, 2350)
nLin += 030
//oPrint:Say  (nLin ,0065,"Emissao: "+dtoc(Date()) , oFont08)
oPrint:Say  (nLin ,2050, "Hora...: "+Time(), oFont08)
nLin += 030
//PADR(Transform(nGERValor, '@E 999,999,999.99' ),14)
oPrint:Line (nLin, 0035, nLin, 2350)

oPrint:endpage()

Return




*------------------------------------------------------------------------------
* Bruno Santos                                                     | 06/04/2011
*------------------------------------------------------------------------------
* Função: ImpFat
*------------------------------------------------------------------------------
* Objetivo :  Impressão propriamente dita do_ mapa de faturamento em impressora
*             Matricial
*------------------------------------------------------------------------------

Static Function ImpFat()  

M_pag++

cabec2 := ''
IF !EMPTY(MV_PAR07)
	Cabec2 := "Estado : " + MV_PAR07
ENDIF


IF !EMPTY(MV_PAR10)
	Cabec2 := Cabec2 + space(30) + "Municipio : " + MV_PAR10
ENDIF
//oPrint:Say  (0140 ,2020, "Página:     01 "			,oFont10)
//oPrint:Say  (0140 ,2160, StrZero(wnPag,3)	,oFont10)

nLin := 240

If MV_PAR03 == 1
	//	W_DIV := ".T."
	cFila  := " Agr.+Ata.+Vet.+Bay.+Pec."
else	
	If MV_PAR02 == 1
		cFila  := " Agricola"
	ElseIf MV_PAR02 == 2
		cFila  := " Atacado"
	ElseIf MV_PAR02 == 3
		cFila  := " Veterinaria"
	ElseIf MV_PAR02 == 4
		cFila  := " Bayer Pco"
	ElseIf MV_PAR02 == 5
		cFila  := " Pecas Jacto"
	EndIf
endif
If mv_par01==1
	mv:="CONSOLIDADO"
ELSE
	mv:=Trim(sm0->m0_filial)
ENDIF


@ 00,00 PSay CHR(18)+Repli("*",79)
@ 01,00 PSay cEmpresa //"EMIS "
//@ 01,62 PSay "Folha..: "+StrZero(nPag,1)

@ 02,00 PSay "Mapa de Faturamento " + space(2) + mv//PADC(Cabec1,80)

@ 03,00 PSay "Hora...: "+Time()
@ 03,61 PSay "Emissao: "+dtoc(Date())

//@ 04,00 PSay Repli("*",80)

@ 05,00 PSay  "Período : "+dtoc(MV_PAR05) +" A "+ dtoc(MV_PAR06) + space(5) + cFila

nLin:=6

@ nLin,00 PSay Repli("*",80)

nlin:=nlin+2
 @ nLin,04 PSay "DIVISAO AGRICOLA   :" +Space(45)+"CARTEIRA";nLin++
 @ nLin,23 PSay "Faturamento : "+Transform(iif(nCount == len(aVEND1)+1,nValFat,aValFat[1] )            			,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Devolucao   : "+Transform(iif(nCount == len(aVEND1)+1,nValDev,aValDev[1] )            			,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Saldo       : "+Transform(iif(nCount == len(aVEND1)+1,nValFat - nValDev,aValFat[1]-aValDev[1])  	,'@E 9,999,999,999.99')
 @ nLin,64 PSay iif(nCount == len(aVEND1)+1,nCart,aCart[1]) Picture '@E 99,999,999.99'
 
 nlin:=nlin+2
 @ nLin,04 PSay "DIVISAO FERTILIZANTE:" +Space(44);nLin++
 @ nLin,23 PSay "Faturamento : "+Transform(iif(nCount == len(aVEND1)+1,nFatFert1,nFatFert)         					,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Devolucao   : "+Transform(iif(nCount == len(aVEND1)+1,nDevFert1,nDevFert)         					,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Saldo       : "+Transform(iif(nCount == len(aVEND1)+1,nFatFert1 - nDevFert1,nFatFert-nDevFert)		,'@E 9,999,999,999.99')
 @ nLin,64 PSay iif(nCount == len(aVEND1)+1,nCart5,aCart[6]) Picture '@E 99,999,999.99'

 nLin:=nlin+2
 @ nLin,04 PSay "TOTAL DIV.AGRICOLA :" +Space(45);nLin++
 @ nLin,23 PSay "Faturamento : "+Transform(iif(nCount == len(aVEND1)+1,nValFat,aValFat[1])						,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Devolucao   : "+Transform(iif(nCount == len(aVEND1)+1,nValdev+nDevFert1,aValDev[1]+nDevFert)		,'@E 9,999,999,999.99');nliN++
 nSaldo3 :=(aValFat[1] +nFatFert)-(aValDev[1]+nDevFert)
 nSaldo4 :=(nValFat +nFatFert1)-(nValDev +nDevFert1)
 @ nLin,23 PSay "Saldo       : "+Transform(iif(nCount == len(aVEND1)+1,nSaldo4,nSaldo3)							,'@E 9,999,999,999.99')
 @ nLin,64 PSay iif(nCount == len(aVEND1)+1,nCart5+nCart, aCart[6]+aCart[1]) Picture '@E 99,999,999.99'
 nLin:=nlin+2

 @ nLin,04 PSay "DIVISAO ATACADO    :" +Space(43);nLin++
 @ nLin,23 PSay "Faturamento : "+Transform(iif(nCount == len(aVEND1)+1,nValFat1,aValFat[2]         				),'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Devolucao   : "+Transform(iif(nCount == len(aVEND1)+1,nValDev1,aValDev[2]          				),'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Saldo       : "+Transform(iif(nCount == len(aVEND1)+1,nValFat1 - nValDev1,aValFat[2]-aValDev[2]	),'@E 9,999,999,999.99')
 @ nLin,64 PSay iif(nCount == len(aVEND1)+1,nCart1,aCART[2]) Picture '@E 99,999,999.99'
 nLin:=nlin+2


 @ nLin,04 PSay "DIVISAO PASTAGEM   :" +Space(43);nLin++
 @ nLin,23 PSay "Faturamento : "+Transform(iif(nCount == len(aVEND1)+1,nFatPast1, nFatPast         		),'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Devolucao   : "+Transform(iif(nCount == len(aVEND1)+1,nDevPast1, nDevPast         		),'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Saldo       : "+Transform(iif(nCount == len(aVEND1)+1,nFatPast1-nDevPast1, nFatPast-nDevPast	),'@E 9,999,999,999.99')
 @ nLin,64 PSay iif(nCount == len(aVEND1)+1,nCart6,aCART[7]) Picture '@E 99,999,999.99'
 nLin:=nlin+2



 @ nLin,04 PSay "DIVISAO VETERINA.  :" +Space(45);nLin++
 @ nLin,23 PSay "Faturamento : "+Transform(iif(nCount == len(aVEND1)+1,nValFat2 , aValFat[3]         				),'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Devolucao   : "+Transform(iif(nCount == len(aVEND1)+1,nValDev2 , aValDev[3]         				),'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Saldo       : "+Transform(iif(nCount == len(aVEND1)+1,nValFat2-nValDev2 , aValFat[3]-aValDev[3]	),'@E 9,999,999,999.99')
 @ nLin,64 PSay iif(nCount == len(aVEND1)+1,nCart2,aCART[3]) Picture '@E 99,999,999.99'
 nLin:=nlin+2

 @ nLin,04 PSay "DIVISAO BAYER PCO  :" +Space(43);nLin++
 @ nLin,23 PSay "Faturamento : "+Transform(iif(nCount == len(aVEND1)+1,nValFat3, aValFat[4]         				),'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Devolucao   : "+Transform(iif(nCount == len(aVEND1)+1,nValDev3, aValDev[4]         				),'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Saldo       : "+Transform(iif(nCount == len(aVEND1)+1,nValFat3-nValDev3, aValFat[4]-aValDev[4]	),'@E 9,999,999,999.99')
 @ nLin,64 PSay iif(nCount == len(aVEND1)+1,nCart3,aCART[4]) Picture '@E 99,999,999.99'
 nLin:=nlin+2

 @ nLin,04 PSay "DIVISAO PECAS COSTAL:" +Space(43);nLin++
 @ nLin,23 PSay "Faturamento : "+Transform(iif(nCount == len(aVEND1)+1,nValFat4 ,aValFat[5]         				),'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Devolucao   : "+Transform(iif(nCount == len(aVEND1)+1,nValDev4 ,aValDev[5]         				),'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Saldo       : "+Transform(iif(nCount == len(aVEND1)+1,nValFat4-nValDev4 ,aValFat[5]-aValDev[5]	),'@E 9,999,999,999.99')
 @ nLin,64 PSay iif(nCount == len(aVEND1)+1,nCart4,aCART[5]) Picture '@E 99,999,999.99'
 nLin:=nlin+2

 @ nLin,04 PSay "TOTAL DIV.ATACADO :" +Space(45);nLin++
 @ nLin,23 PSay "Faturamento : "+Transform(iif(nCount == len(aVEND1)+1,nValFat1+nValFat2+nValFat3+nValFat4+nFatPast1,aValFat[2]+aValFat[3]+aValFat[4]+aValFat[5]+nFatPast),'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Devolucao   : "+Transform(iif(nCount == len(aFIl)+1,nValDev1+nValDev2+nValDev3+nValDev4+nDevPast1,aValDev[2]+aValDev[3]+aValDev[4]+aValDev[5]+nDevPast),'@E 9,999,999,999.99');nliN++
 nSaldo1 :=(aValFat[2]+aValFat[3]+aValFat[4]+aValFat[5]+nFatPast)-(aValDev[2]+aValDev[3]+aValDev[4]+aValDev[5]+nDevPast)
 nSaldo5 :=(nValFat1+nValFat2+nValFat3+nValFat4+nFatPast1)-(nValDev1+nValDev2+nValDev3+nValDev4+nDevPast1)
 @ nLin,23 PSay "Saldo       : "+Transform(iif(nCount == len(aFIl)+1,nSaldo5,nSaldo1),'@E 9,999,999,999.99')
 @ nLin,64 PSay iif(nCount == len(aVEND1)+1,nCart1+ nCART6+ nCART2+ nCART3+ nCART4,aCART[2]+ aCART[7]+ aCART[3]+ aCART[4]+ aCART[5]) Picture '@E 99,999,999.99'
//
 nLin:=nlin+2

 @ nLin,04 PSay "TOTAL GERAL        :" +Space(45);nLin++
 @ nLin,23 PSay "Faturamento : "+Transform(iif(nCount == len(aVEND1)+1,nValFat+nValFat1+nValFat2+nValFat3+nValFat4+nFatPast1+nFatFert1,aValFat[1]+aValFat[2]+aValFat[3]+aValFat[4]+aValFat[5]+nFatPast+nFatFert),'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Devolucao   : "+Transform(iif(nCount == len(aVEND1)+1,nValDev+nValDev1+nValDev2+nValDev3+nValDev4+nDevPast1+nDevFert1,aValDev[1]+aValDev[2]+aValDev[3]+aValDev[4]+aValDev[5]+nDevPast+nDevFert),'@E 9,999,999,999.99');nliN++
 nSaldo :=(aValFat[1]+aValFat[2]+aValFat[3]+aValFat[4]+aValFat[5]+nFatPast+nFatFert)-(aValDev[1]+aValDev[2]+aValDev[3]+aValDev[4]+aValDev[5]+nDevPast+nDevFert)
 nSaldo6 :=(nValFat+nValFat1+nValFat2+nValFat3+nValFat4+nFatPast1+nFatFert1)-(nValDev+nValDev1+nValDev2+nValDev3+nValDev4+nDevPast1+nDevFert1)
 @ nLin,23 PSay "Saldo       : "+Transform(iif(nCount == len(aFIl)+1,nSaldo6,nSaldo),'@E 9,999,999,999.99')
 @ nLin,64 PSay iif(nCount == len(aVEND1)+1,nCART1+ nCART6+ nCART2+ nCART3+ nCART4+nCART+nCART5,aCART[2]+ aCART[7]+ aCART[3]+ aCART[4]+ aCART[5]+aCART[1]+aCART[6]) Picture '@E 99,999,999.99'
 nLin:=nlin+3  
 @ nLin,00 PSay CHR(18)+Repli("*",80)
 nLin++
 @ nLin,63 PSay  "Hora...: "+Time()
 nLin++ 
 @ nLin,00 PSay CHR(18)+Repli("*",80)


Return
