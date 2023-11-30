#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/07/01
#include "topconn.ch"

*----------------------------------------------------------------------------
* Bruno Santos                                                   | 29/03/2011
*----------------------------------------------------------------------------
* Função: Mapa de faturamento
*----------------------------------------------------------------------------
* Objetivo :  Imprime o Mapa de faturamento
*----------------------------------------------------------------------------

User Function rfatr22k()


*---------------------------Declaracao de Variáveis-------------------------------------
SetPrvt("cTitulo,cString,cWnrel,cDesc1,cDesc2,M_pag")
SetPrvt("cTamanho,aReturn,nLastKey,cPerg,_ABEC1,_ABEC2")
SetPrvt("cNomeprog,cCondicao,_Linha,_Query,Comp")

CTitulo    := "Mapa de Faturamento "
CABEC1    := "Mapa de Faturamento "
M_pag      :=  1
cString    := "SD2"
cWnrel     := "RFATR22K"
cDesc1     := "Mapa de Faturamento"
CABEC2    := "Mapa de Faturamento "
cDesc2     := ""
cTamanho   := "P"
aReturn    := { "Zebrado", 1,"Estoque", 2, 2, 1, "",1 }
nLastKey   := 0
cPerg      := "RFAT22Z"
_abec1     := ""
_abec2     := ""
cnomeprog  := "RFATR22K"
cCondicao  := ""
_Linha     := 100
Comp       := 15



* -------------------------------------------------------*
* Envia controle para a funcao SETPRINT
* -------------------------------------------------------*
//ValidPerg()



pergunte(cPerg,.f.)
cWnrel:=SetPrint(cString,cWnrel,cPerg,Ctitulo,cDesc1,cDesc2,"",.F.,"",.T.,cTamanho,,.T.)

If nLastKey == 27     
    Set Filter To
	Return .T.
Endif

SetDefault(aReturn,cString)

If nLastKey == 27 
    Set Filter To
	Return .T.
Endif



RptStatus({|| Rest002Imp()},CTitulo)
Return

/*
 mv_par01   := 1        // Consolida: Sim / Nao
 mv_par02   := 1        // Agricola/Atacado/Veterinaria/Bayer Pco/Pecas Jacto
 MV_PAR04   := Space(6) // Vendedor
 MV_PAR05   := Date()   // Da  Emissao
 MV_PAR06   := Date()   // Ate Emissao
*/

Static Function Rest002Imp()
aValFAT := {}  //Array com os valores do faturamento     
aValDEV := {}  //Array com os valores das devoluções  

 
*-----------------------------------------------------------------------------------------------------------
* Query com os valores do_ faturamento das divisões
* Agr.+Ata.+Vet.+Bay.+Pec
* 1 Agricola
* 2 Atacado
* 3 Veterinaria
* 4 Bayer Pco
* 5 Pecas Jacto 
*-----------------------------------------------------------------------------------------------------------

For b := 1 to 5

_Query1 := " SELECT B1_DIVISAO,SUM(D2_TOTAL) AS TOTD2                                	"	+ chr(13)+chr(10)
_Query1 += "   FROM "+RetSqlName("SD2")+" D2 (NOLOCK)                                	"	+ chr(13)+chr(10)	
_Query1 += "   LEFT JOIN   "+RetSqlName("SF4")+" F4 (NOLOCK) ON F4.F4_CODIGO = D2_TES	"	+ chr(13)+chr(10)
_Query1 += "                                 AND F4.D_E_L_E_T_ =  ''                 	"	+ chr(13)+chr(10)
_Query1 += " 			 	 	 	         AND F4_DUPLIC     <> 'N' AND F4_CODIGO<>'706'  	"	+ chr(13)+chr(10)
_Query1 += "   JOIN "+RetSqlName("SB1")+" B1 (NOLOCK)   ON B1_COD = D2_COD        		"	+ chr(13)+chr(10)
_Query1 += "                                 AND B1.D_E_L_E_T_ = ''	                 	"	+ chr(13)+chr(10)
If 		b = 1	//Divisão Agricula                                 
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

_Query1 += " WHERE D2.D_E_L_E_T_ = ''													"	+ chr(13)+chr(10)
_Query1 += "   AND SUBSTRING(D2.D2_CF,2,3) IN('12','102','922','108')                	" 	+ chr(13)+chr(10)
_Query1 += "   AND D2_EMISSAO BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) +"'"	+ chr(13)+chr(10)





If MV_PAR01 = 2 //Só traz a filial que esta logada no momento                                                                         
   _Query1 += "   AND D2_FILIAL  = '"+ xFilial("SD2")+"'   								"	+ chr(13)+chr(10)
EndIf   

_Query1 += " GROUP BY B1_DIVISAO														"	+ chr(13)+chr(10)
_Query1 += " ORDER BY B1_DIVISAO														"	+ chr(13)+chr(10)

Memowrit( "D:\Query\rfatr22.SQL", _QUERY1 )
TCQUERY _Query1 ALIAS QSD2 NEW 

*------------------------------------------------------------------------------------------------------------
* Carrego um array_ com os valores do_ faturamento por divisão          
*------------------------------------------------------------------------------------------------------------
If 		b = 1	//Divisão Agricula
	DbSelectArea("QSD2")      
	AADD(AVALFAT,QSD2->TOTD2)
	QSD2->(DBCloseArea())
ElseIf 	b = 2 	//Divisão Atacado
	DbSelectArea("QSD2")
	AADD(AVALFAT,QSD2->TOTD2)
	QSD2->(DBCloseArea())
ElseIf 	b = 3   //Divisão Veterinária
	DbSelectArea("QSD2")
	AADD(AVALFAT,QSD2->TOTD2)
	QSD2->(DBCloseArea())
ElseIf 	b = 4	//Divisão Bayer
	DbSelectArea("QSD2")
	AADD(AVALFAT,QSD2->TOTD2)
	QSD2->(DBCloseArea())
ElseIf 	b = 5	//Divisão Peças Costal
	DbSelectArea("QSD2")
	AADD(AVALFAT,QSD2->TOTD2)
	QSD2->(DBCloseArea())
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
_Query += "  JOIN "+RetSqlName("SB1")+" B1 (NOLOCK)   ON B1_COD        = D1_COD	"  	+ chr(13)+chr(10)	   	 							   
_Query += "					                              AND B1.D_E_L_E_T_ = ''		"  	+ chr(13)+chr(10)	   	 							   
If 		br = 1	//Divisão Agricula                                 
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
//	_Query1 += "                             AND B1.B1_GRUPO = '0009'					"	+ chr(13)+chr(10)
	_Query += "                             AND B1.B1_DIVISAO = '5'						"	+ chr(13)+chr(10)
	_Query += "                             AND B1.B1_CODFOR IN('73','76')				"	+ chr(13)+chr(10)
EndIf  
_Query += "   AND D1_DTDIGIT  BETWEEN  '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) +"' 		"	+ chr(13)+chr(10)
_Query += "   AND D1_TIPO = 'D'															"	+ chr(13)+chr(10)
_Query += "   AND SUBSTRING(D1_CF,2,3) IN('32','202')									"	+ chr(13)+chr(10)

If MV_PAR01 = 2 //Só traz a filial que esta logada no momento                                                                         
   _Query += "   AND D1_FILIAL  = '"+ xFilial("SD1")+"'   								"	+ chr(13)+chr(10)
EndIf   

_Query += "   AND D1.D_E_L_E_T_ = ''													"	+ chr(13)+chr(10)
_Query += " GROUP BY B1_DIVISAO															"	+ chr(13)+chr(10)
_Query += " ORDER BY B1_DIVISAO															"	+ chr(13)+chr(10)

Memowrit( "D:\Query\rfatr221.SQL", _QUERY )
TCQUERY _Query ALIAS QSD1 NEW      
                               
*------------------------------------------------------------------------------------------------------------
* Carrego um array_ com os valores do_ faturamento por divisão          
*------------------------------------------------------------------------------------------------------------
If 	br = 1	//Divisão Agricula
	DbSelectArea("QSD1")      
	AADD(AVALDEV,QSD1->TODD1)
	QSD1->(DBCloseArea())
ElseIf 	br = 2 	//Divisão Atacado
	DbSelectArea("QSD1")
	AADD(AVALDEV,QSD1->TODD1)
	QSD1->(DBCloseArea())
ElseIf 	br = 3   //Divisão Veterinária
	DbSelectArea("QSD1")
	AADD(AVALDEV,QSD1->TODD1)
	QSD1->(DBCloseArea())
ElseIf 	br = 4	//Divisão Bayer
	DbSelectArea("QSD1")
	AADD(AVALDEV,QSD1->TODD1)
	QSD1->(DBCloseArea())
ElseIf 	br = 5	//Divisão Peças Costal
	DbSelectArea("QSD1")
	AADD(AVALDEV,QSD1->TODD1)
	QSD1->(DBCloseArea())
EndIf

Next







*------------------------------------------------------------------------------------------------------------
* Query com o faturamento de fertilizantes
*------------------------------------------------------------------------------------------------------------
cCond := " SELECT B1_DIVISAO,SUM(D2_TOTAL) AS TOTD2 									"	+ chr(13)+chr(10)
cCond += "  FROM "+RetSqlName("SD2")+" D2 (NOLOCK) 										"	+ chr(13)+chr(10)
cCond += "  LEFT JOIN   "+RetSqlName("SF4")+" F4 (NOLOCK) ON F4.F4_CODIGO = D2_TES		"	+ chr(13)+chr(10)
cCond += "				                                 AND F4.D_E_L_E_T_ = ''        	"	+ chr(13)+chr(10)						  
cCond += "				 						         AND F4_DUPLIC     <> 'N' AND F4_CODIGO<>'706'     	"	+ chr(13)+chr(10)						  
cCond += "  JOIN "+RetSqlName("SB1")+" B1 (NOLOCK)  ON B1_COD = D2_COD 					"	+ chr(13)+chr(10)						  
cCond += "			                               AND B1.D_E_L_E_T_ = ''				"	+ chr(13)+chr(10)						  
cCond += "			                               AND B1_GRUPO = '0009'		        "	+ chr(13)+chr(10)						  
cCond += "  JOIN "+RetSqlName("SF2")+" F2 (NOLOCK) ON F2_DOC = D2_DOC					"	+ chr(13)+chr(10)						  
cCond += "                                        AND F2_SERIE  = D2_SERIE  			"	+ chr(13)+chr(10)						  
cCond += "				                          AND F2_FILIAL = D2_FILIAL 			"	+ chr(13)+chr(10)						  
cCond += "				                          AND F2.D_E_L_E_T_ = ''  				"	+ chr(13)+chr(10)						  
cCond += "	WHERE D2.D_E_L_E_T_ = ''													"	+ chr(13)+chr(10)						  		
cCond += "    AND SUBSTRING(D2.D2_CF,2,3) IN('12','102','922','108')                	"	+ chr(13)+chr(10)							  

If MV_PAR01 = 2 //Só traz a filial que esta logada no momento                                                                         
   cCond += "   AND D2_FILIAL  = '"+ xFilial("SD2")+"'   								"	+ chr(13)+chr(10)
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
                                    
                                                                   


*------------------------------------------------------------------------------------------------------------
* Query com as_ devoluções de  fertilizantes
*------------------------------------------------------------------------------------------------------------

cCond := " SELECT B1_DIVISAO,SUM(D1_TOTAL) AS TOTD1 									"	+ chr(13)+chr(10)						  		
cCond += "   FROM "+RetSqlName("SD1")+" D1 (NOLOCK) 									"	+ chr(13)+chr(10)						  			   				  
cCond += "   LEFT JOIN   "+RetSqlName("SF4")+" F4 (NOLOCK) ON F4.F4_CODIGO  = D1_TES	"	+ chr(13)+chr(10)						  			   				  
cCond += " 					                              AND F4.D_E_L_E_T_ = ''        "	+ chr(13)+chr(10)
cCond += "					   					          AND F4_DUPLIC     <> 'N'      "	+ chr(13)+chr(10)
cCond += "   JOIN "+RetSqlName("SB1")+" B1 (NOLOCK)   ON B1_COD = D1_COD				"	+ chr(13)+chr(10)
cCond += "                                                AND B1.D_E_L_E_T_ = ''		"	+ chr(13)+chr(10)
cCond += "					                              AND B1_GRUPO = '0009'			"	+ chr(13)+chr(10)	        
cCond += "  WHERE D1.D_E_L_E_T_ = ''													"	+ chr(13)+chr(10)	        
cCond += "    AND D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) +"' "	+ chr(13)+chr(10)
cCond += "    AND SUBSTRING(D1_CF,2,3) IN('32','202')									"	+ chr(13)+chr(10)

If MV_PAR01 = 2 //Só traz a filial que esta logada no momento                                                                         
   cCond += "   AND D1_FILIAL  = '"+ xFilial("SD1")+"'   								"	+ chr(13)+chr(10)
EndIf 

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
                     
                     


*------------------------------------------------------------------------------------------------------------
* Query com o faturamento de pastagem
*------------------------------------------------------------------------------------------------------------

_Quer := " SELECT B1_DIVISAO ,SUM(D2_TOTAL) AS TOTD2 								"	+ chr(13)+chr(10)
_Quer += "   FROM "+RetSqlName("SD2")+" D2 (NOLOCK) 									"	+ chr(13)+chr(10)
_Quer += "   LEFT JOIN   "+RetSqlName("SF4")+" F4 (NOLOCK) ON F4.F4_CODIGO = D2_TES		"	+ chr(13)+chr(10)
_Quer += "					                              AND F4.D_E_L_E_T_ = ''        "	+ chr(13)+chr(10)							  
_Quer += "					  					          AND F4_DUPLIC     <> 'N' AND F4_CODIGO<>'706'      "	+ chr(13)+chr(10)							  
_Quer += "  JOIN "+RetSqlName("SB1")+" B1 (NOLOCK)    ON B1_COD        = D2_COD     	"	+ chr(13)+chr(10)							  
_Quer += "  				                              AND B1.D_E_L_E_T_ = ''		"	+ chr(13)+chr(10)							  
_Quer += "				                                  AND B1.B1_CODFOR IN('A4','83','A7','A8') "	+ chr(13)+chr(10)							  
_Quer += " WHERE D2.D_E_L_E_T_ = ''														"	+ chr(13)+chr(10)							  
_Quer += "   AND SUBSTRING(D2.D2_CF,2,3) IN('12','102','922','108')                		"	+ chr(13)+chr(10) 
_Quer += "   AND D2_EMISSAO  BETWEEN  '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) +"' "	+ chr(13)+chr(10)					  

If MV_PAR01 = 2 //Só traz a filial que esta logada no momento                                                                         
   _Quer += "   AND D2_FILIAL  = '"+ xFilial("SD2")+"'   								"	+ chr(13)+chr(10)
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



*------------------------------------------------------------------------------------------------------------
* Query com as_ devoluções de pastagem
*------------------------------------------------------------------------------------------------------------
_Quer1 := " SELECT B1_DIVISAO ,SUM(D1_TOTAL) AS TOTD1 									"	+ chr(13)+chr(10)								
_Quer1 += "   FROM "+RetSqlName("SD1")+" D1 (NOLOCK) 									"	+ chr(13)+chr(10)								
_Quer1 += "   LEFT JOIN   "+RetSqlName("SF4")+" F4 (NOLOCK) ON F4.F4_CODIGO = D1_TES	"	+ chr(13)+chr(10)									
_Quer1 += "	  				                               AND F4.D_E_L_E_T_ = ''       "	+ chr(13)+chr(10)									 
_Quer1 += " 					  					       AND F4_DUPLIC     <> 'N'     "	+ chr(13)+chr(10)									 
_Quer1 += "   JOIN "+RetSqlName("SB1")+" B1 (NOLOCK)    ON B1_COD        = D1_COD     	"	+ chr(13)+chr(10)									 
_Quer1 += "				                               AND B1.D_E_L_E_T_ = ''		  	"	+ chr(13)+chr(10)									 
_Quer1 += "			                                   AND B1.B1_CODFOR IN('A4','83','A7','A8') "	+ chr(13)+chr(10)									 
_Quer1 += "  WHERE D1.D_E_L_E_T_ = ''													"	+ chr(13)+chr(10)									 

_Quer1 += "    AND D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) +"' "	+ chr(13)+chr(10)
_Quer1 += "    AND SUBSTRING(D1_CF,2,3) IN('32','202')									"	+ chr(13)+chr(10)

If MV_PAR01 = 2 //Só traz a filial que esta logada no momento                                                                         
   _Quer1 += "   AND D1_FILIAL  = '"+ xFilial("SD1")+"'   								"	+ chr(13)+chr(10)
EndIf 

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


*------------------------------------------------------------------------------------------------------------
* Query com os valores em carteira
*------------------------------------------------------------------------------------------------------------

For bru := 1 to 7
	
	cCart := " SELECT B1.B1_DIVISAO,SUM(((C6_QTDVEN-C6_QTDENT)*C6_PRCVEN)) 	AS TOTCAR		"	+ chr(13)+chr(10)
	cCart += "   FROM "+RetSqlName("SC6")+" SC6 (NOLOCK)									"	+ chr(13)+chr(10)
	cCart += "   JOIN "+RetSqlName("SF4")+" F4 (NOLOCK)  ON F4_CODIGO  = C6_TES				"	+ chr(13)+chr(10)
	cCart += "               						    AND F4.D_E_L_E_T_ = ''        		"	+ chr(13)+chr(10)
	cCart += "						                    AND F4_DUPLIC     <> 'N' AND F4_CODIGO<>'706'	"	+ chr(13)+chr(10)
	cCart += "   JOIN "+RetSqlName("SC5")+" SC5 (NOLOCK) ON C5_FILIAL  = C6_FILIAL    		"	+ chr(13)+chr(10)
	cCart += "                                          AND C5_NUM     = C6_NUM   			"	+ chr(13)+chr(10)
	cCart += "                                          AND C5_EMISSAO <= " + DTOS(MV_PAR06)	+ chr(13)+chr(10)
	
	if !EMPTY(MV_PAR04)
		cCart += "   											AND C5_VEND1 = '"+ MV_PAR04 +"' "  	+ chr(13)+chr(10)
	ENDIF
	
	cCart += "   JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK) ON C5_CLIENTE = A1_COD		   		"	+ chr(13)+chr(10)
	cCart += "                                          AND A1_LOJA = C5_LOJACLI			"	+ chr(13)+chr(10)
	
	If !empty(MV_PAR07)  //Filtrar por estado
		cCart += "                                      AND A1_EST = '"+ MV_PAR07 +"'"			+ chr(13)+chr(10)
	EndIf
	
	If !empty(MV_PAR08)  //Filtrar por estado
		cCart += "                                      AND A1_MUN = '"+ MV_PAR08 +"'"			+ chr(13)+chr(10)
	EndIf
	
	
	cCart += "   JOIN "+RetSqlName("SB1")+" B1 (NOLOCK)  ON B1_COD = C6_PRODUTO				"	+ chr(13)+chr(10)
	cCart += "                                          AND B1.D_E_L_E_T_ = ''				"	+ chr(13)+chr(10)
	If MV_PAR03 == 2
		
		If MV_PAR02 == 1
			cCart += "                             AND B1.B1_DIVISAO = '1'					"	+ chr(13)+chr(10)
		ElseIf MV_PAR02 == 2
			cCart += "                             AND B1.B1_DIVISAO = '2'					"	+ chr(13)+chr(10)
		ElseIf MV_PAR02 == 3
			cCart += "                             and b1.B1_GRUPO <> '0009'					"	+ chr(13)+chr(10)
			cCart += "                             AND B1_CODFOR NOT IN('01','A4','83','A7','A8') "	+ chr(13)+chr(10)
			cCart += "                             AND B1.B1_DIVISAO = '3'					"	+ chr(13)+chr(10)
		ElseIf MV_PAR02 == 4
			cCart += "                             AND B1.B1_CODFOR = '01'					"	+ chr(13)+chr(10)
			cCart += "                             AND B1.B1_DIVISAO = '4'					"	+ chr(13)+chr(10)
		ElseIf MV_PAR02 == 5
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
	
	If MV_PAR01 = 2 //Só traz a filial que esta logada no momento
		cCart += "   AND SC6.C6_FILIAL  = '"+ xFilial("SC6")+"'   							"	+ chr(13)+chr(10)
	EndIf
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
	ElseIf 	bru = 2 	//Divisão Atacado
		DbSelectArea("QSC6")
		AADD(ACart,QSC6->TOTCAR)
		QSC6->(DBCloseArea())
	ElseIf 	bru = 3   //Divisão Veterinária
		DbSelectArea("QSC6")
		AADD(ACart,QSC6->TOTCAR)
		QSC6->(DBCloseArea())
	ElseIf 	bru = 4	//Divisão Bayer
		DbSelectArea("QSC6")
		AADD(ACart,QSC6->TOTCAR)
		QSC6->(DBCloseArea())
	ElseIf 	bru = 5	//Divisão Peças Costal
		DbSelectArea("QSC6")
		AADD(ACart,QSC6->TOTCAR)
		QSC6->(DBCloseArea())
	ElseIf 	bru = 6	//Fertilizante
		DbSelectArea("QSC6")
		AADD(ACart,QSC6->TOTCAR)
		QSC6->(DBCloseArea())
	ElseIf 	bru = 7	//Pastagem
		DbSelectArea("QSC6")
		AADD(ACart,QSC6->TOTCAR)
		QSC6->(DBCloseArea())
	EndIf
	
Next
*------------------------------------------
* Chama a função de impressão do_ relatório
*------------------------------------------
ImpriFat()                                 

return










*----------------------------------------------------------------------------
* Bruno Santos                                                   | 29/03/2011
*----------------------------------------------------------------------------
* Função: ImpriFat
*----------------------------------------------------------------------------
* Objetivo :  Impressão propriamente dita do_ mapa de faturamento
*----------------------------------------------------------------------------

Static Function ImpriFat()
                           
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



// SetRegua(RecCount())
// GoTo Top
 @ 00,00 PSay CHR(18)+Repli("*",80)
 @ 01,00 PSay "EMIS"
 //@ 01,62 PSay "Folha..: "+StrZero(nPag,1)
 @ 02,23 PSay PADC(Cabec1,20)    + "   " + mv
 @ 03,00 PSay "RFATR22K"
 @ 03,63 PSay "Emissao: "+dtoc(Date())
 @ 04,00 PSay Repli("*",80)
// @ 05,00 PSay Cabec2
 @ 05,00 PSay  "Período : "+dtoc(MV_PAR05) +" A "+ dtoc(MV_PAR06) + space(5) + cFila
 nLin:=6   
 /*
 If !EmpTy(MV_PAR04)
    DBSelectArea("SA3")
    DBSeek("  "+MV_PAR04)
    @ nLin,01 PSay "Vendedor : ("+MV_PAR04+") "+sa3->a3_nome
    nLin++
 EndIf*/
 @ nLin,00 PSay Repli("*",80)
 
 nlin:=nlin+2
 @ nLin,04 PSay "DIVISAO AGRICOLA   :" +Space(45)+"CARTEIRA";nLin++
 @ nLin,23 PSay "Faturamento : "+Transform(aValFat[1]             	,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Devolucao   : "+Transform(aValDev[1]             	,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Saldo       : "+Transform(aValFat[1]-aValDev[1]  	,'@E 9,999,999,999.99')
 @ nLin,64 PSay aCart[1] Picture '@E 99,999,999.99'
 
 nlin:=nlin+2
 @ nLin,04 PSay "DIVISAO FERTILIZANTE:" +Space(44);nLin++
 @ nLin,23 PSay "Faturamento : "+Transform(nFatFert         		,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Devolucao   : "+Transform(nDevFert         		,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Saldo       : "+Transform(nFatFert-nDevFert		,'@E 9,999,999,999.99')
 @ nLin,64 PSay aCart[6] Picture '@E 99,999,999.99'

 nLin:=nlin+2
 @ nLin,04 PSay "TOTAL DIV.AGRICOLA :" +Space(45);nLin++
 @ nLin,23 PSay "Faturamento : "+Transform(aValFat[1]				,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Devolucao   : "+Transform(aValDev[1]+nDevFert		,'@E 9,999,999,999.99');nliN++
 nSaldo3 :=(aValFat[1] +nFatFert)-(aValDev[1]+nDevFert)
 @ nLin,23 PSay "Saldo       : "+Transform(nSaldo3					,'@E 9,999,999,999.99')
  @ nLin,64 PSay aCart[6]+aCart[1] Picture '@E 99,999,999.99'
 nLin:=nlin+2

 @ nLin,04 PSay "DIVISAO ATACADO    :" +Space(43);nLin++
 @ nLin,23 PSay "Faturamento : "+Transform(aValFat[2]         		,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Devolucao   : "+Transform(aValDev[2]          		,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Saldo       : "+Transform(aValFat[2]-aValDev[2]	,'@E 9,999,999,999.99')
 @ nLin,64 PSay aCART[2] Picture '@E 99,999,999.99'
 nLin:=nlin+2


 @ nLin,04 PSay "DIVISAO PASTAGEM   :" +Space(43);nLin++
 @ nLin,23 PSay "Faturamento : "+Transform(nFatPast         		,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Devolucao   : "+Transform(nDevPast         		,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Saldo       : "+Transform(nFatPast-nDevPast		,'@E 9,999,999,999.99')
 @ nLin,64 PSay aCART[7] Picture '@E 99,999,999.99'
 nLin:=nlin+2



 @ nLin,04 PSay "DIVISAO VETERINA.  :" +Space(45);nLin++
 @ nLin,23 PSay "Faturamento : "+Transform(aValFat[3]         		,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Devolucao   : "+Transform(aValDev[3]         		,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Saldo       : "+Transform(aValFat[3]-aValDev[3]	,'@E 9,999,999,999.99')
 @ nLin,64 PSay aCART[3] Picture '@E 99,999,999.99'
 nLin:=nlin+2

 @ nLin,04 PSay "DIVISAO BAYER PCO  :" +Space(43);nLin++
 @ nLin,23 PSay "Faturamento : "+Transform(aValFat[4]         		,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Devolucao   : "+Transform(aValDev[4]         		,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Saldo       : "+Transform(aValFat[4]-aValDev[4]	,'@E 9,999,999,999.99')
 @ nLin,64 PSay aCART[4] Picture '@E 99,999,999.99'
 nLin:=nlin+2

 @ nLin,04 PSay "DIVISAO PECAS COSTAL:" +Space(43);nLin++
 @ nLin,23 PSay "Faturamento : "+Transform(aValFat[5]         		,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Devolucao   : "+Transform(aValDev[5]         		,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Saldo       : "+Transform(aValFat[5]-aValDev[5]	,'@E 9,999,999,999.99')
 @ nLin,64 PSay aCART[5] Picture '@E 99,999,999.99'
 nLin:=nlin+2

 @ nLin,04 PSay "TOTAL DIV.ATACADO :" +Space(45);nLin++
 @ nLin,23 PSay "Faturamento : "+Transform(aValFat[2]+aValFat[3]+aValFat[4]+aValFat[5]+nFatPast,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Devolucao   : "+Transform(aValDev[2]+aValDev[3]+aValDev[4]+aValDev[5]+nDevPast,'@E 9,999,999,999.99');nliN++
 nSaldo1 :=(aValFat[2]+aValFat[3]+aValFat[4]+aValFat[5]+nFatPast)-(aValDev[2]+aValDev[3]+aValDev[4]+aValDev[5]+nDevPast)
 @ nLin,23 PSay "Saldo       : "+Transform(nSaldo1,'@E 9,999,999,999.99')
 @ nLin,64 PSay aCART[2]+ aCART[7]+ aCART[3]+ aCART[4]+ aCART[5] Picture '@E 99,999,999.99'
//
 nLin:=nlin+2

 @ nLin,04 PSay "TOTAL GERAL        :" +Space(45);nLin++
 @ nLin,23 PSay "Faturamento : "+Transform(aValFat[1]+aValFat[2]+aValFat[3]+aValFat[4]+aValFat[5]+nFatPast+nFatFert,'@E 9,999,999,999.99');nliN++
 @ nLin,23 PSay "Devolucao   : "+Transform(aValDev[1]+aValDev[2]+aValDev[3]+aValDev[4]+aValDev[5]+nDevPast+nDevFert,'@E 9,999,999,999.99');nliN++
 nSaldo :=(aValFat[1]+aValFat[2]+aValFat[3]+aValFat[4]+aValFat[5]+nFatPast+nFatFert)-(aValDev[1]+aValDev[2]+aValDev[3]+aValDev[4]+aValDev[5]+nDevPast+nDevFert)
 @ nLin,23 PSay "Saldo       : "+Transform(nSaldo,'@E 9,999,999,999.99')
 @ nLin,64 PSay aCART[2]+ aCART[7]+ aCART[3]+ aCART[4]+ aCART[5]+aCART[1]+aCART[6] Picture '@E 99,999,999.99'
 nLin:=nlin+3  
 @ nLin,00 PSay CHR(18)+Repli("*",80)
 nLin++
 @ nLin,63 PSay  "Hora...: "+Time()
 nLin++ 
 @ nLin,00 PSay CHR(18)+Repli("*",80)


 Set Filter To
 If aReturn[5] == 1
 	Set Printer To
 	Commit
     ourspool(cwnrel) //Chamada do Spool de Impressao
 Endif
 MS_FLUSH() //Libera fila de relatorios em spool
Return

