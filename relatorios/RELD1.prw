#INCLUDE "MATR590.CH" 
#INCLUDE "PROTHEUS.CH"  
 
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � RELD1  � Autor � Marco Bianchi         � Data � 27/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faturamento por Cliente                                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAFAT - R4                                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function RELD1()
 
Local oReport
Local aPDFields	:= {}

If FindFunction("TRepInUse") .And. TRepInUse()
	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	aPDFields	:= {"A1_NOME"}
	FATPDLoad(Nil,Nil,aPDFields)
	RELD1R()
	FATPDUnLoad()   
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Marco Bianchi         � Data � 27/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ��� 
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local oReport
Local oFatCli
Local oFatCliSD2
//Local nRank		:= 0

Private cNomArq := ""
Private cNomArq2 := ""
Private nvalor1 := 0
Private nvalor2 := 0
Private nvalor3 := 0
Private nvalor4 := 0
Private nvalor5 := 0
Private nvalor6 := 0
Private nval01  := 0
Private nval02  := 0
Private nval03  := 0
Private nval04  := 0
Private nval05  := 0
Private nval06  := 0

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport := TReport():New("RELD1",STR0017,"MTR590", {|oReport| ReportPrint(oReport,oFatCli,oFatCliSD2)},STR0018 + " " + STR0019 + " " + STR0020)	// "Faturamento por Cliente"###"Este relatorio emite a relacao de faturamento. Podera ser"###"emitido por ordem de Cliente ou por Valor (Ranking).     "###"Se no TES estiver gera duplicata (N), nao sera computado."
oReport:SetPortrait() 
oReport:SetTotalInLine(.F.)

Pergunte(oReport:uParam,.F.)

//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//� Secao detalhes - Section(1)  								 		   �
//��������������������������������������������������������������������������
oFatCli := TRSection():New(oReport,STR0031,{"SF2","SA1","TRB","SD2"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// "Faturamento por Cliente"
oFatCli:SetTotalInLine(.F.)
TRCell():New(oFatCli,"TB_CLI"		,cNomArq,RetTitle("A1_COD")	,PesqPict("SA1","A1_COD"	)	,TamSx3("A1_COD")		[1]	,/*lPixel*/,{|| (cNomArq)->TB_CLI })			// "Codigo"
TRCell():New(oFatCli,"TB_LOJA"		,cNomArq,RetTitle("A1_LOJA"),PesqPict("SA1","A1_LOJA"	)	,TamSx3("A1_LOJA")		[1]	,/*lPixel*/,{|| (cNomArq)->TB_LOJA })			// "Loja"
TRCell():New(oFatCli,"A1_NOME"		,"SA1"	,RetTitle("A1_NOME"),PesqPict("SA1","A1_NOME"	)	,TamSx3("A1_NOME")		[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)	// "Razao Social"
TRCell():New(oFatCli,"TB_VALOR1"	,cNomArq,STR0021			,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,{|| (cNomArq)->TB_VALOR1 })		// "Faturamento sem ICMS"
TRCell():New(oFatCli,"TB_VALOR2"	,cNomArq,STR0022			,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,{|| (cNomArq)->TB_VALOR2 })		// "Valor da Mercadoria"
TRCell():New(oFatCli,"TB_VALOR3"	,cNomArq,STR0023			,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,{|| (cNomArq)->TB_VALOR3 })		// "Valor Total"
TRCell():New(oFatCli,"TB_RANKIN"	,cNomArq,STR0024			,"@E 9999"						,4							,/*lPixel*/,{|| (cNomArq)->TB_RANKIN })		// "Ranking"
TRCell():New(oFatCli,"TB_VALOR4"	,cNomArq,STR0021			,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,{|| (cNomArq)->TB_VALOR4*-1 })		// "Faturamento sem ICMS"
TRCell():New(oFatCli,"TB_VALOR5"	,cNomArq,STR0022			,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,{|| (cNomArq)->TB_VALOR5*-1 })		// "Valor da Mercadoria"
TRCell():New(oFatCli,"TB_VALOR6"	,cNomArq,STR0023			,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,{|| (cNomArq)->TB_VALOR6*-1 })		// "Valor Total"
TRCell():New(oFatCli,"TB_TIPO" 		,cNomArq,"Tipo"				,/*Picture*/			 		,/*Tamanho*/				,/*lPixel*/,/*{|| code-block de impressao }*/)	// Se Devolucao imprime "DEV"
                           
//oFatCli:Cell("TB_CUSTO"):SetHeaderAlign("RIGHT") 
oFatCli:Cell("TB_VALOR1"):SetHeaderAlign("RIGHT") 
oFatCli:Cell("TB_VALOR2"):SetHeaderAlign("RIGHT") 
oFatCli:Cell("TB_VALOR3"):SetHeaderAlign("RIGHT") 
oFatCli:Cell("TB_VALOR4"):SetHeaderAlign("RIGHT") 
oFatCli:Cell("TB_VALOR5"):SetHeaderAlign("RIGHT") 
oFatCli:Cell("TB_VALOR6"):SetHeaderAlign("RIGHT") 

//������������������������������������������������������������������������Ŀ
//� Secao detalhes - Section(2)  								 		   �
//��������������������������������������������������������������������������
oFatCliSD2 := TRSection():New(oReport,STR0031,{"SF2","SA1","TRB","SD2"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// "Faturamento por Cliente"
oFatCliSD2:SetTotalInLine(.F.)
TRCell():New(oFatCliSD2,"TD_NOTA" ,cNomArq2,"NOTA"		        ,PesqPict("SF2","F2_DOC")	,20,/*lPixel*/,{||(cNomArq2)->TD_NOTA },"LEFT" ,,,,,)	// "Razao Social"
TRCell():New(oFatCliSD2,"TD_SERIE",cNomArq2,"SERIE"			    ,PesqPict("SF2","F2_SERIE")	,20,/*lPixel*/,{||(cNomArq2)->TD_SERIE},"LEFT" ,,,,,)	// "Razao Social"
TRCell():New(oFatCliSD2,"TD_COD"  ,cNomArq2,RetTitle("D2_COD")  ,PesqPict("SD2","D2_COD")	,20,/*lPixel*/,{||(cNomArq2)->TD_COD  },"LEFT" ,,,,,)	// "Razao Social"
TRCell():New(oFatCliSD2,"TD_ITEM" ,cNomArq2,RetTitle("D2_ITEM") ,PesqPict("SD2","D2_ITEM")	,20,/*lPixel*/,{||(cNomArq2)->TD_ITEM },"LEFT" ,,,,,)	// "Razao Social"
TRCell():New(oFatCliSD2,"TD_CUSTO",cNomArq2,RetTitle("D2_TOTAL"),PesqPict("SD2","D2_TOTAL")	,20,/*lPixel*/,{||(cNomArq2)->TD_CUSTO},"RIGHT",,"RIGHT",,,)	// "Razao Social"

//������������������������������������������������������������������������Ŀ
//� Secao Totalizadora Faturamento - Section(3)  		    			   �
//��������������������������������������������������������������������������
oTotal := TRSection():New(oReport,STR0032,"",/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// "Faturamento por Cliente"
oTotal:SetTotalInLine(.F.)
oTotal:SetEdit(.F.)
TRCell():New(oTotal,"CCLI"		,/*Tabela*/,RetTitle("A1_COD")	,PesqPict("SA1","A1_COD"	),TamSx3("A1_COD")		[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)	
TRCell():New(oTotal,"CLOJA"		,cNomArq,RetTitle("A1_LOJA")	,PesqPict("SA1","A1_LOJA"	),TamSx3("A1_LOJA")		[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)			// "Loja"
TRCell():New(oTotal,"CNOME"		,/*Tabela*/,RetTitle("A1_NOME")	,PesqPict("SA1","A1_NOME"	),TamSx3("A1_NOME")		[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)	
TRCell():New(oTotal,"NVALOR1"	,/*Tabela*/,STR0021				,PesqPict("SF2","F2_VALBRUT"),TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,{|| NVAL01 })	// "Faturamento sem ICMS"
TRCell():New(oTotal,"NVALOR2"	,/*Tabela*/,STR0022				,PesqPict("SF2","F2_VALBRUT"),TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,{|| NVAL02 })	// "Valor da Mercadoria"
TRCell():New(oTotal,"NVALOR3"	,/*Tabela*/,STR0023				,PesqPict("SF2","F2_VALBRUT"),TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,{|| NVAL03 })	// "Valor Total"

oTotal:Cell("NVALOR1"):SetHeaderAlign("RIGHT")    
oTotal:Cell("NVALOR2"):SetHeaderAlign("RIGHT") 
oTotal:Cell("NVALOR3"):SetHeaderAlign("RIGHT") 

//������������������������������������������������������������������������Ŀ
//� Secao Totalizadora Devolucoes - Section(4)  		    			   �
//��������������������������������������������������������������������������
oDev := TRSection():New(oReport,STR0033,"",/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// "Faturamento por Cliente"
oDev:SetTotalInLine(.F.)
oDev:SetEdit(.F.)
TRCell():New(oDev,"CCLI"	,/*Tabela*/,RetTitle("A1_COD")	,PesqPict("SA1","A1_COD"	)	,TamSx3("A1_COD")	 	[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)	// "Codigo"
TRCell():New(oDev,"CLOJA"	,/*Tabela*/,RetTitle("A1_LOJA")	,PesqPict("SA1","A1_LOJA"	)	,TamSx3("A1_COD")	 	[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)	// "Loja"
TRCell():New(oDev,"CNOME"	,/*Tabela*/,RetTitle("A1_NOME")	,PesqPict("SA1","A1_NOME"	)	,TamSx3("A1_NOME")	  	[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)	// "Razao Social"
TRCell():New(oDev,"NVALOR4"	,/*Tabela*/,STR0021				,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,{|| NVAL04*-1 })	// "Faturamento sem ICMS"
TRCell():New(oDev,"NVALOR5"	,/*Tabela*/,STR0022				,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,{|| NVAL05*-1 })	// "Valor da Mercadoria"
TRCell():New(oDev,"NVALOR6"	,/*Tabela*/,STR0023				,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,{|| NVAL06*-1 })	// "Valor Total"
TRCell():New(oDev,"CDEV"	,/*Tabela*/,"Tipo"			  	,/*Picture*/ 					,/*Tamanho*/ 						,/*lPixel*/,{|| "DEV" })	// "Valor Total"

oDev:Cell("NVALOR4"):SetHeaderAlign("RIGHT") 
oDev:Cell("NVALOR5"):SetHeaderAlign("RIGHT") 
oDev:Cell("NVALOR6"):SetHeaderAlign("RIGHT") 
                           

//������������������������������������������������������������������������Ŀ
//� Secao Totalizadora (Fat-Dev) - Section(5)    		    			   �
//��������������������������������������������������������������������������
oTotGer := TRSection():New(oReport,STR0034,"",/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// "Faturamento por Cliente"
oTotGer:SetTotalInLine(.F.)
oTotGer:SetEdit(.F.)
TRCell():New(oTotGer,"CCLI"		,/*Tabela*/,RetTitle("A1_COD")	,PesqPict("SA1","A1_COD"	)	,TamSx3("A1_COD")		[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)	// "Codigo"
TRCell():New(oTotGer,"CLOJA"	,/*Tabela*/,RetTitle("A1_LOJA")	,PesqPict("SA1","A1_LOJA"	)	,TamSx3("A1_LOJA")		[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)	// "Loja"
TRCell():New(oTotGer,"CNOME"	,/*Tabela*/,RetTitle("A1_NOME")	,PesqPict("SA1","A1_NOME"	)	,TamSx3("A1_NOME")		[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)	// "Razao Social"
TRCell():New(oTotGer,"NVALOR1"	,/*Tabela*/,STR0021					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,{|| NVAL01-NVAL04 })	// "Faturamento sem ICMS"
TRCell():New(oTotGer,"NVALOR2"	,/*Tabela*/,STR0022					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,{|| NVAL02-NVAL05 })	// "Valor da Mercadoria"
TRCell():New(oTotGer,"NVALOR3"	,/*Tabela*/,STR0023					,PesqPict("SF2","F2_VALBRUT")	,TamSx3("F2_VALBRUT")	[1]	,/*lPixel*/,{|| NVAL03-NVAL06 })	// "Valor Total"
TRCell():New(oTotGer,"CABAT"		,/*Tabela*/,"Tipo"			  				,/*Picture*/ 						,/*Tamanho*/ 						,/*lPixel*/,{|| IIf(mv_par12 == 1,"ABT","") })	

oTotGer:Cell("NVALOR1"):SetHeaderAlign("RIGHT") 
oTotGer:Cell("NVALOR2"):SetHeaderAlign("RIGHT") 
oTotGer:Cell("NVALOR3"):SetHeaderAlign("RIGHT") 



//������������������������������������������������������������������������Ŀ
//� Nao imprime cabecaho da secao                 	    			       �
//��������������������������������������������������������������������������
oReport:Section(3):SetHeaderSection(.F.)
oReport:Section(4):SetHeaderSection(.F.)
oReport:Section(5):SetHeaderSection(.F.)

//������������������������������������������������������������������������Ŀ
//� Posiciona Cadastro de Clientes antes da impressao de cada linha		   �
//��������������������������������������������������������������������������
TRPosition():New(oReport:Section(1),"SA1",1,{|| xFilial("SA1")+(cNomArq)->TB_CLI+(cNomArq)->TB_LOJA })

//Posiciona na tabela SF2 antes da impress�o de cada linha
TRPosition():New(oReport:Section(1),"SF2",2,{|| xFilial("SF2")+(cNomArq)->TB_CLI+(cNomArq)->TB_LOJA+(cNomArq)->TB_DOC+(cNomArq)->TB_SERIE })

//������������������������������������������������������������������������Ŀ
//� Impressao do Cabecalho no top da pagina                                �
//��������������������������������������������������������������������������
oReport:Section(1):SetHeaderPage()

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor � Marco Bianchi         � Data �27/06/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport,oFatCli,oFatCliSD2)

Local cEstoq   	:= If( (MV_PAR11== 1),"S",If( (MV_PAR11== 2),"N","SN" ) )
Local cDupli   	:= If( (MV_PAR10== 1),"S",If( (MV_PAR10== 2),"N","SN" ) )
Local aCampos  	:= {}
Local aCampos2  := {}
Local aTam	   	:= {}
Local aTam2	   	:= {}
Local nMoeda   	:= mv_par08
Local lImpPlan	:= (oReport:nDevice == 4 .And. oReport:lXlsTable)	//Verifica se a impress�o � do tipo 4-Planilha e do tipo Tabela
Local cChavePo	:= ""

Private oTempTable := NIl
Private oTempTable2:= NIl
Private nDecs	   := msdecimais(mv_par08)
Private aCodCli    := {}

//��������������������������������������������������������������Ŀ
//� Altera o Titulo do Relatorio de acordo com parametros	 	 �
//����������������������������������������������������������������
// Lista por: 1=Cliente, 2=Ranking, 3=Estado
oReport:SetTitle(oReport:Title() + " " + IIF(mv_par07 == 1,STR0026,IIF(mv_par07 == 2,STR0027,STR0028)) + " - "  + GetMv("MV_MOEDA"+STR(mv_par08,1)) )		// "Faturamento por Vendedor"###"(Ordem Decrescente por Vendedor)"###"(Por Ranking)"

//��������������������������������������������������������������Ŀ
//� Totalizadores da Secao                                       �
//����������������������������������������������������������������
TRFunction():New(oFatCli:Cell("TB_VALOR1"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,{|| nValor1 - nValor4},IIf(mv_par12 == 1 .or. mv_par07 == 3,.T.,.F.) /*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oFatCli:Cell("TB_VALOR2"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,{|| nValor2 - nValor5},IIf(mv_par12 == 1 .or. mv_par07 == 3,.T.,.F.) /*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oFatCli:Cell("TB_VALOR3"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,{|| nValor3 - nValor6},IIf(mv_par12 == 1 .or. mv_par07 == 3,.T.,.F.)/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)

//��������������������������������������������������������������Ŀ
//� Cria arquivo de trabalho                                     �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Cria array para gerar arquivo de trabalho                    �
//����������������������������������������������������������������
aTam:=TamSX3("F2_CLIENTE")
AADD(aCampos,{ "TB_CLI"    ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("F2_LOJA")
AADD(aCampos,{ "TB_LOJA"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("A1_EST")
AADD(aCampos,{ "TB_EST"    ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("F2_EMISSAO")
AADD(aCampos,{ "TB_EMISSAO","D",aTam[1],aTam[2] } )
AADD(aCampos,{ "TB_VALOR1" ,"N",16,nDecs } )		// Valores de Faturamento
AADD(aCampos,{ "TB_VALOR2" ,"N",16,nDecs } )
AADD(aCampos,{ "TB_VALOR3" ,"N",16,nDecs } )
AADD(aCampos,{ "TB_VALOR4" ,"N",16,nDecs } )		// Valores para devolucao
AADD(aCampos,{ "TB_VALOR5" ,"N",16,nDecs } )
AADD(aCampos,{ "TB_VALOR6" ,"N",16,nDecs } )
AADD(aCampos,{ "TB_RANKIN" ,"N",16,0 } )        		// Ranking conforme Valor faturamento
AADD(aCampos,{ "TB_TIPO"   ,"C",03,0 } )        		
AADD(aCampos,{ "TB_CONT"   ,"N",16,nDecs} )
//Campos para o posicionamento da tabela SF2
aTam:=TamSX3("F2_DOC")
AADD(aCampos,{ "TB_DOC"    ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("F2_SERIE")
AADD(aCampos,{ "TB_SERIE"    ,"C",aTam[1],aTam[2] } )


cNomArq := GetNextAlias()

//-------------------------------------------------------------------
// Instancia tabela tempor�ria.  
//-------------------------------------------------------------------

oTempTable	:= FWTemporaryTable():New( cNomArq )       

//-------------------------------------------------------------------
// Atribui o  os �ndices.  
//-------------------------------------------------------------------
oTempTable:SetFields( aCampos )
oTempTable:AddIndex("1",{"TB_CLI","TB_LOJA"})
oTempTable:AddIndex("2",{"TB_CONT"})
oTempTable:AddIndex("3",{"TB_EST","TB_CLI","TB_LOJA"})
oTempTable:AddIndex("4",{"TB_RANKIN"})

//------------------
//Cria��o da tabela
//------------------
oTempTable:Create()
(cNomArq)->(DbSetOrder(1))


aTam2:=TamSX3("F2_DOC")
AADD(aCampos2,{ "TD_NOTA"    ,"C",aTam2[1],aTam2[2] } )
aTam2:=TamSX3("F2_SERIE")
AADD(aCampos2,{ "TD_SERIE"   ,"C",aTam2[1],aTam2[2] } )
aTam2:=TamSX3("F2_CLIENTE")
AADD(aCampos2,{ "TD_CLI"    ,"C",aTam2[1],aTam2[2] } )
aTam2:=TamSX3("F2_LOJA")
AADD(aCampos2,{ "TD_LOJA"   ,"C",aTam2[1],aTam2[2] } )
aTam2:=TamSX3("A1_EST")
AADD(aCampos2,{ "TD_EST"    ,"C",aTam2[1],aTam2[2] } )
aTam2:=TamSX3("F2_EMISSAO")
AADD(aCampos2,{ "TD_EMISSAO","D",aTam2[1],aTam2[2] } )
aTam2:=TamSX3("D2_COD")
AADD(aCampos2,{ "TD_COD","C",aTam2[1],aTam2[2] } )
aTam2:=TamSX3("D2_ITEM")
AADD(aCampos2,{ "TD_ITEM","C",aTam2[1],aTam2[2] } )
AADD(aCampos2,{ "TD_CUSTO"  ,"N",16,nDecs } )	
AADD(aCampos2,{ "TD_RANKIN" ,"N",16,0 } )  
AADD(aCampos2,{ "TD_CONT"   ,"N",16,nDecs} )

cNomArq2 := GetNextAlias()
oTempTable2	:= FWTemporaryTable():New( cNomArq2 ) 
oTempTable2:SetFields( aCampos2 )
oTempTable2:AddIndex("1",{"TD_CLI","TD_LOJA"})
oTempTable2:AddIndex("2",{"TD_CONT"})
oTempTable2:AddIndex("3",{"TD_EST","TD_CLI","TD_LOJA"})
oTempTable2:AddIndex("4",{"TD_RANKIN"})
oTempTable2:AddIndex("5",{"TD_CLI","TD_LOJA","TD_NOTA","TD_SERIE","TD_ITEM"})
oTempTable2:Create()
(cNomArq2)->(DbSetOrder(1))

cNomArq3 := SubStr(cNomArq,1,7)+"3"
cNomArq4 := SubStr(cNomArq,1,7)+"4"

dbSelectArea("SF2")		// Cabecalho da Nota de Saida
dbSetOrder(2)			// Filial,Cliente,Loja,Documento,Serie

//��������������������������������������������������������������Ŀ
//� Chamada da Funcao para gerar arquivo de Trabalho             �
//����������������������������������������������������������������
If mv_par09 == 3		// Inclui Devolucao?: 1=Sim, 2=Nao, 3=Por N.F.
	cKey:="D1_FILIAL+D1_SERIORI+D1_NFORI+D1_FORNECE+D1_LOJA"
	cFiltro :="D1_FILIAL=='"+xFilial("SD1")+"'.And.!Empty(D1_NFORI)"
	cFiltro += ".And. !("+IsRemito(2,"SD1->D1_TIPODOC")+")"		

	#IFDEF SHELL
		cFiltro += '.And. D1_CANCEL <> "S"'
	#ENDIF
	IndRegua("SD1",cNomArq3,cKey,,cFiltro,OemToAnsi(STR0012))	//"Selecionando Registros..."
	nIndex:=RetIndex("SD1")

	dbSetOrder(nIndex+1)
	dbGotop()
Endif
//����������������������������������������Ŀ
//� Grava arquivo de trabalho.             �
//������������������������������������������ 
dbSelectArea("SD2")
GTrabR4(cEstoq,cDupli,nMoeda,oReport)

If mv_par09 == 1	   		// Inclui Devolucao?: 1=Sim, 2=Nao, 3=Por N.F.
	dbSelectArea("SF1")		// Cabecalho da Nota de entrada
	dbSetOrder(2)			// Filial,Fornecedor,Loja,Documento
	oReport:IncMeter()
	GTrab1R4(cEstoq,cDupli,nMoeda,oReport)
Endif

dbSelectArea(cNomArq)
dbCommit()  

// Lista por: 1=Cliente, 2=Ranking, 3=Estado
If mv_par07 == 1			// Listar por Cliente   
	(cNomArq)->(dbGoTop()) 
	While !Eof() 
		RecLock(cNomArq,.F.)
		(cNomArq)->TB_CONT :=   (cNomArq)->TB_VALOR3 + (cNomArq)->TB_VALOR6
		MsUnlock()
		(cNomArq)->(dbSkip()) 
	EndDo 
	  
	(cNomArq)->(DbSetOrder(2))
	(cNomArq)->(dbGoBottom())
	
	nRank:=1 
	While !Bof()  
		RecLock(cNomArq,.F.)
		(cNomArq)->TB_RANKIN := nRank 
		MsUnlock()
		nRank++
		(cNomArq)->(dbSkip(-1))
	EndDo

	nRank:=0
	(cNomArq)->(DbSetOrder(1))
	oReport:Section(1):SetTotalText(STR0035) // Total do Cliente

ElseIf mv_par07 == 2			// Listar por Ranking	

	(cNomArq)->(dbGoTop()) 
	While !Eof() 
		RecLock(cNomArq,.F.)
		(cNomArq)->TB_CONT :=   (cNomArq)->TB_VALOR3 + (cNomArq)->TB_VALOR6
		MsUnlock()
		(cNomArq)->(dbSkip()) 
	EndDo 
	  
	(cNomArq)->(DbSetOrder(2))
	(cNomArq)->(dbGoBottom())
	
	nRank:=1 
	While !Bof()  
		RecLock(cNomArq,.F.)
		(cNomArq)->TB_RANKIN := nRank 
		MsUnlock()
		nRank++
		(cNomArq)->(dbSkip(-1))
	EndDo
	
	nRank:=0
	(cNomArq)->(DbSetOrder(4))
	oReport:Section(1):SetTotalText(STR0036) // Total por Ranking
Else							// Listar por Estado	
	(cNomArq)->(DbSetOrder(3))
	oReport:Section(1):SetTotalText(STR0037) // Total do Estado
	oReport:Section(1):Cell("TB_RANKIN"):Disable()	
Endif

oReport:Section(2):SetHeaderSection(.T.)
dbSelectArea(cNomArq)
(cNomArq)->(dbGoTop())
dbSelectArea(cNomArq2)
(cNomArq2)->(dbGoTop())
If (cNomArq)->(RecCount()) > 0 .AND. (cNomArq2)->(RecCount()) > 0
	oReport:SetMeter(RecCount())		// Total de Elementos da regua
	
	nVal01 :=nVal02 := nVal03 := nVal04 := nVal05 := nVal06 := 0
	While !oReport:Cancel() .And. !(cNomArq)->(Eof())
	
		// Lista por: 1=Cliente, 2=Ranking, 3=Estado
		If mv_par07 == 1				// Listar por Cliente   
			cChave := (cNomArq)->TB_CLI+(cNomArq)->TB_LOJA
			cChave2 := (cNomArq2)->TD_CLI+(cNomArq2)->TD_LOJA
			bChave := {|| !oReport:Cancel() .And. !(cNomArq)->(Eof()) .And. (cNomArq)->TB_CLI+(cNomArq)->TB_LOJA == cChave }
			bChave2 := {|| !oReport:Cancel() .And. !(cNomArq2)->(Eof()) .And. (cNomArq2)->TD_CLI+(cNomArq2)->TD_LOJA == cChave }
		ElseIf mv_par07 == 2			// Listar por Ranking	
			cChave := (cNomArq)->TB_RANKIN	            
			bChave := {|| !oReport:Cancel() .And. !(cNomArq)->(Eof()) .And. (cNomArq)->TB_RANKIN == cChave }		
		Else							// Listar por Estado	
			cChave := (cNomArq)->TB_EST
			bChave := {|| !oReport:Cancel() .And. !(cNomArq)->(Eof()) .And. (cNomArq)->TB_EST == cChave }		
		Endif
		oReport:Section(1):Cell("TB_VALOR4"):Disable()
		oReport:Section(1):Cell("TB_VALOR5"):Disable()
		oReport:Section(1):Cell("TB_VALOR6"):Disable()
		oReport:Section(1):Cell("TB_TIPO"):Disable()
		oReport:Section(1):Init()
	
		While Eval(bChave)
		
			nValor1 := (cNomArq)->TB_VALOR1
			nValor2 := (cNomArq)->TB_VALOR2
			nValor3 := (cNomArq)->TB_VALOR3
			nValor4 := (cNomArq)->TB_VALOR4
			nValor5 := (cNomArq)->TB_VALOR5
			nValor6 := (cNomArq)->TB_VALOR6
			
			nVal01 += (cNomArq)->TB_VALOR1
			nVal02 += (cNomArq)->TB_VALOR2
			nVal03 += (cNomArq)->TB_VALOR3
			nVal04 += (cNomArq)->TB_VALOR4
			nVal05 += (cNomArq)->TB_VALOR5
			nVal06 += (cNomArq)->TB_VALOR6
			
			// Impressao das Devolucoes
			If (cNomArq)->TB_VALOR4 <> 0 .Or. (cNomArq)->TB_VALOR5 <> 0 .Or. (cNomArq)->TB_VALOR6 <> 0
                
				oReport:Section(1):Init()
				oReport:Section(1):PrintLine() 
				If lImpPlan
					oReport:Section(1):Finish() 
				EndIf
				
				oReport:Section(1):Cell("TB_CLI"):Hide()
				oReport:Section(1):Cell("TB_LOJA"):Hide()
				oReport:Section(1):Cell("A1_NOME"):Hide()
				oReport:Section(1):Cell("TB_VALOR1"):Disable()
				oReport:Section(1):Cell("TB_VALOR2"):Disable()
				oReport:Section(1):Cell("TB_VALOR3"):Disable()
				oReport:Section(1):Cell("TB_RANKIN"):Disable()
				oReport:Section(1):Cell("TB_VALOR4"):Enable()
				oReport:Section(1):Cell("TB_VALOR5"):Enable()
				oReport:Section(1):Cell("TB_VALOR6"):Enable()
				oReport:Section(1):Cell("TB_TIPO"):Enable()
				oReport:Section(1):Cell("TB_TIPO"):SetValue((cNomArq)->TB_TIPO)
				
				//Zera as variaveis para n�o duplicar o totalizador da section(1)
				NVALOR1 := 	NVALOR2 := 	NVALOR3 := NVALOR4 := NVALOR5 := NVALOR6 := 0
				 
				oReport:Section(1):Init()
				oReport:Section(1):PrintLine()
				If lImpPlan
					oReport:Section(1):Finish()
				EndIf
	
				oReport:Section(1):Cell("TB_CLI"):Show()
				oReport:Section(1):Cell("TB_LOJA"):Show()
				oReport:Section(1):Cell("A1_NOME"):Show()
				oReport:Section(1):Cell("TB_VALOR1"):Enable()
				oReport:Section(1):Cell("TB_VALOR2"):Enable()
				oReport:Section(1):Cell("TB_VALOR3"):Enable()
				If mv_par07 <> 3
					oReport:Section(1):Cell("TB_RANKIN"):Enable()
				EndIf	
				oReport:Section(1):Cell("TB_VALOR4"):Disable()
				oReport:Section(1):Cell("TB_VALOR5"):Disable()
				oReport:Section(1):Cell("TB_VALOR6"):Disable()
				oReport:Section(1):Cell("TB_TIPO"):Disable()	
				oReport:Section(1):Cell("TB_TIPO"):SetValue("")
			Else
				If lImpPlan	.And. mv_par07 == 3
					If mv_par09 == 1
						oReport:Section(1):Cell("TB_TIPO"):Enable()
					EndIf
					oReport:Section(1):PrintLine()
				Else
					oReport:Section(1):PrintLine()
				EndIf
			EndIf

			oReport:SkipLine() //-- Salta Linha
			(cNomArq2)->(DbSetOrder(5))
			If (cNomArq2)->(DbSeek((cNomArq)->(TB_CLI+TB_LOJA)))
				While Eval(bChave2)
					oReport:Section(2):Init()
					oReport:Section(2):Cell("TD_NOTA"):Show()
					oReport:Section(2):Cell("TD_SERIE"):Show()
					oReport:Section(2):Cell("TD_COD"):Show()
					oReport:Section(2):Cell("TD_ITEM"):Show()
					oReport:Section(2):Cell("TD_CUSTO"):Show()
					oReport:Section(2):PrintLine()
					(cNomArq2)->(DbSkip())
				End 
			EndIf
			oReport:SkipLine() //-- Salta Linha
			
			If mv_par07 == 1		// por cliente
				If (cNomArq)->TB_VALOR4 <> 0 .Or. (cNomArq)->TB_VALOR5 <> 0 .Or. (cNomArq)->TB_VALOR6 <> 0
					oReport:Section(1):SetTotalText(STR0035 +" "+ cChave + "( ABT )")
				Else	
					oReport:Section(1):SetTotalText(STR0035 +" "+ cChave)	
				EndIf
			ElseIf mv_par07 == 3	// por estado	                
				oReport:Section(1):SetTotalText(STR0030 +" "+ cChave)	
			EndIf	

//			oReport:SkipLine(2) //-- Salta Linha
			
			dbSelectArea(cNomArq)			
			(cNomArq)->(dbSkip())
		EndDo
		oReport:Section(2):Finish()
		oReport:Section(1):Finish()
		oReport:SkipLine(2) //-- Salta Linha
	EndDo
	oReport:Section(1):Finish()
	
	//��������������������������������������������������������������Ŀ
	//� Impressao das secoes totalizadoras no final do relatorio     �
	//����������������������������������������������������������������
	oReport:PrintText(STR0025)
	oReport:Section(3):Init()
	oReport:Section(3):PrintLine()
	oReport:Section(3):Finish()
	
	If mv_par09 <> 2 .And. (nval04+nval05+nval06<>0)
		oReport:Section(4):Init()
		oReport:Section(4):PrintLine()
		oReport:Section(4):Finish()
	EndIf	
	                
	If mv_par12 == 1 .And. (nval04+nval05+nval06<>0)
		oReport:Section(5):Init()
		oReport:Section(5):PrintLine()
		oReport:Section(5):Finish()
	EndIf	
EndIf
	
If( valtype(oTempTable) == "O")
	oTempTable:Delete()
	freeObj(oTempTable)
	oTempTable := nil
EndIf

//��������������������������������������������������������������Ŀ
//� Restaura a integridade dos dados                             �
//����������������������������������������������������������������
If mv_par09 == 3
	dbSelectArea("SD1")
	dbClearFilter()
	RetIndex()
	fErase(cNomArq3+OrdBagExt())
	dbSetOrder(1)
Endif

dbSelectArea("SF2")
dbClearFilter()
dbSetOrder(1)
dbSelectArea("SD2")
dbSetOrder(1)

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GTrabR4   � Autor � Wagner Xavier         � Data � 27/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera arquivo de Trabalho para emissao de Estat.de Fatur.    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � ReportPrint()                                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static FuncTion GTrabR4(cEstoq,cDupli,nMoeda,oReport)

Local cChaven    := ""
Local nTOTAL     := 0
Local nVALICM    := 0
Local nVALIPI    := 0
Local ImpNoInc   := 0    
Local nImpInc    := 0    
Local nTB_VALOR1 := 0
Local nTB_VALOR2 := 0
Local nTB_VALOR3 := 0
Local nY         := 0
Local aImpostos	 := {}
Local lAvalTes   := .F.                  
Local lProcessa  := .T.
Local cFilUsu    := ""
Local cFilSA1    := ""
Local nAdic      := 0
Local nValSImp   := 0
Local nTotDesp   := 0
Local lValadi	 := cPaisLoc == "MEX" .AND. SD2->(FieldPos("D2_VALADI")) > 0 .AND. VALTYPE(MV_PAR15)=="N" .AND. MV_PAR15==1 //  Adiantamentos Mexico
Local lComplIPI  := .F.
Local nComplIPI  := 0

Private cCampImp
                       
// Adiciona filtro do usuario no filtro do relatorio
If len(oReport:Section(1):GetAdvplExp("SF2")) > 0
	cFilUsu += " .AND. " + oReport:Section(1):GetAdvplExp("SF2")
EndIf	

dbSelectArea("SF2")
dbsetorder(1)
cKey := indexkey()
cFiltro := "DTOS(F2_EMISSAO) >= '"+ Dtos(mv_par01) +"'.AND. DTOS(F2_EMISSAO) <= '"+ dtos(mv_par02) +"' .AND."
cFiltro += "F2_CLIENTE >= '"+ mv_par03 + "' .AND. F2_CLIENTE <= '"+ mv_par04 + "' .and. " 
cFiltro += "F2_FILIAL = '" + xFilial("SF2") + "'"
cFiltro += cFilUsu
IndRegua("SF2",cNomArq4,cKey,,cFiltro,OemToAnsi(STR0012))	//"Selecionando Registros..."
nIndex:=RetIndex("SF2")

dbSetOrder(nIndex+1)
dbGotop()

If len(oReport:Section(1):GetAdvplExp("SA1")) > 0
	cFilSA1 += oReport:Section(1):GetAdvplExp("SA1")
EndIf

While !Eof() .And. xFilial()=SF2->F2_FILIAL 

	lProcessa := .T.
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek ( xFilial() + SF2->F2_CLIENTE+SF2->F2_LOJA )
	//Verifica filtro do ususario
	If !Empty(cFilSA1) .And. !(&cFilSA1)
		lProcessa := .F.
	EndIf	
	
	dbSelectArea("SF2")
	
	#IFDEF SHELL
		If SF2->F2_CANCEL == "S"
			lProcessa := .F.
		Endif
	#ENDIF
	
	If IsRemito(1,"SF2->F2_TIPODOC")
		lProcessa := .F.
	Endif	
	
	IF SA1->A1_EST 	 < mv_par05 .Or. SA1->A1_EST     > mv_par06	
		lProcessa := .F.
	EndIF
	
	If (At(SF2->F2_TIPO,"DB") != 0) .Or. (SF2->F2_TIPO == "I" .And. SF2->F2_ICMSRET == 0)
		lProcessa := .F.
	Endif

	If lProcessa
		
		dbSelectArea("SD2")
		dbSetOrder(3)
		dbSeek(xFilial()+SF2->F2_DOC+SF2->F2_SERIE)
		nTOTAL 		:=0
		nTOTALLIQ	:=0
		nVALICM		:=0
		nVALIPI		:=0
		nImpNoInc	:=0
		nImpInc  	:=0
		lAvalTes    := .F.
		nTotDesp    := 0
		nAdic 		:= 0

		If cPaisLoc <> "BRA" .and. Type("SF2->F2_TXMOEDA")#"U"
			nAdic    += xMoeda(SF2->F2_SEGURO+SF2->F2_FRETE+SF2->F2_DESPESA,SF2->F2_MOEDA,nMoeda,SF2->F2_EMISSAO)
		Endif

		While !Eof() .And. xFilial()==SD2->D2_FILIAL .And.;
			SD2->D2_DOC+SD2->D2_SERIE == SF2->F2_DOC+SF2->F2_SERIE
			
			#IFDEF SHELL
				If SD2->D2_CANCEL == "S" .Or. !(Substr(SD2->D2_CF,2,2)$"12|73|74")
					SD2->(dbSkip())
					Loop
				Endif
			#ENDIF
			
			dbSelectArea("SF4")
			dbSeek(xFilial()+SD2->D2_TES)
			
			dbSelectArea("SD2")
			If AvalTes(D2_TES,cEstoq,cDupli)
				
				lAvalTes := .T.
				If cPaisLoc <> "BRA" .and. Type("SF2->F2_TXMOEDA")#"U"

					nTOTAL  += xMoeda(SD2->D2_TOTAL-Iif(lValadi,SD2->D2_VALADI,0),SF2->F2_MOEDA,nMoeda,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)

				Else
					If SF4->F4_AGREG <> "N"
					   	nTOTAL  += xMoeda(SD2->D2_TOTAL-Iif(lValadi,SD2->D2_VALADI,0),1,nMoeda,SF2->F2_EMISSAO,nDecs+1)
					    nAdic += xMoeda(SD2->D2_SEGURO+SD2->D2_VALFRE+SD2->D2_DESPESA,SF2->F2_MOEDA,nMoeda,SF2->F2_EMISSAO)
					Else
						nTOTAL  += xMoeda(SD2->D2_SEGURO+SD2->D2_VALFRE+SD2->D2_DESPESA,1,nMoeda,SF2->F2_EMISSAO,nDecs+1)
						nTotDesp += xMoeda(SD2->D2_SEGURO+SD2->D2_VALFRE+SD2->D2_DESPESA,1,nMoeda,SF2->F2_EMISSAO,nDecs+1)
						nAdic += xMoeda(SD2->D2_SEGURO+SD2->D2_VALFRE+SD2->D2_DESPESA,SF2->F2_MOEDA,nMoeda,SF2->F2_EMISSAO)
					EndIf
					If mv_par15 == 1  .And. SF4->F4_AGREG <> "N"
						nValSImp := TotSImp("SF2","SD2",SD2->D2_TES)
						nTOTALLIQ  += xMoeda(nValSImp,1,nMoeda,SF2->F2_EMISSAO,nDecs+1)
					EndIf
					lComplIPI := SF2->F2_TIPO == "P"
					If 	lComplIPI
						nComplIPI := SD2->D2_TOTAL
					EndIf	
				Endif
				If !lComplIPI
					If ( cPaisLoc=="BRA")
						nVALICM += xMoeda(SD2->D2_VALICM,1,nMoeda,SF2->F2_EMISSAO)
						nVALIPI += xMoeda(SD2->D2_VALIPI,1,nMoeda,SF2->F2_EMISSAO)
					Else
						//��������������������������������������������������������������Ŀ
						//� Pesquiso pelas caracteristicas de cada imposto               �
						//����������������������������������������������������������������
						aImpostos:=TesImpInf(SD2->D2_TES)
						For nY:=1 to Len(aImpostos)
							cCampImp:="SD2->"+(aImpostos[nY][2])
							If ( aImpostos[nY][3]=="1" )
								nImpInc 	+= xMoeda(&cCampImp,SF2->F2_MOEDA,nMoeda,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
							Else
								nImpNoInc 	+= xmoeda(&cCampImp,SF2->F2_MOEDA,nMoeda,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
							Endif
						Next
					EndIf
				EndIf
				
				DbSelectArea(cNomArq2)
				(cNomArq2)->(RecLock(cNomArq2,.T.))
					Replace TD_ITEM		With	SD2->D2_ITEM
					Replace TD_COD		With	SD2->D2_COD
					Replace TD_CUSTO	With	SD2->D2_TOTAL
					Replace TD_EMISSAO	With	SD2->D2_EMISSAO
					Replace TD_EST		With	SA1->A1_EST
					Replace TD_LOJA		With	SF2->F2_LOJA
					Replace TD_CLI		With	SF2->F2_CLIENTE
					Replace TD_NOTA		With	SF2->F2_DOC
					Replace TD_SERIE	With	SF2->F2_SERIE
				(cNomArq2)->(MsUnLock())
			Endif
			
			dbSelectArea("SD2")
			dbSkip()
		EndDo
		
		dbSelectArea("SF2")

		If lAvalTes
			nTOTAL  += nAdic
		Endif
		
		If nTOTAL > 0
			dbSelectArea(cNomArq)
			If dbSeek(SF2->F2_CLIENTE+SF2->F2_LOJA,.F.)
				RecLock(cNomArq,.F.)
			Else
				RecLock(cNomArq,.T.)
				Replace TB_CLI     With SF2->F2_CLIENTE
				Replace TB_LOJA    With SF2->F2_LOJA
				
				//Grava Doc e serie para posicionamento
				Replace TB_DOC 	With SF2->F2_DOC
				Replace TB_SERIE 	With SF2->F2_SERIE
				
			EndIF
			Replace TB_EST     With SA1->A1_EST
			Replace TB_EMISSAO With SF2->F2_EMISSAO
			
			If lAvalTes .And. MV_PAR14 == 2
				nTB_VALOR2 := IIF(SF2->F2_TIPO == "P",0,nTOTAL-nTotDesp)
			Else
				nTB_VALOR2 := IIF(SF2->F2_TIPO == "P",0,nTOTAL-nAdic-nTotDesp)
			EndIf
			
			If ( cPaisLoc=="BRA" )
				If nTOTALLIQ <> 0
					If !lComplIPI
						nTB_VALOR1 := nTOTALLIQ-nVALICM
					Else
						nTB_VALOR1 := nTOTALLIQ-nVALICM-nComplIPI
					EndIf	
				Else
					If !lComplIPI
						nTB_VALOR1 := nTOTAL-nVALICM-nAdic-nTotDesp
					Else
						nTB_VALOR1 := nTOTAL-nVALICM-nAdic-nTotDesp-nComplIPI
					EndIf	
				EndIf
				nTB_VALOR3 := IIF(SF2->F2_TIPO == "P",nComplIPI,nTOTAL-nTotDesp);
				+ nVALIPI+;
				IIF(SF2->F2_TIPO=="I" .And. SF2->F2_ICMSRET > 0,xMoeda(SF2->F2_FRETAUT,1,nMoeda,SF2->F2_EMISSAO),xMoeda(SF2->F2_ICMSRET+SF2->F2_FRETAUT,1,nMoeda,SF2->F2_EMISSAO))				

				
			Else
				nTB_VALOR1 := nTOTAL-nImpNoInc
				nTB_VALOR3 := IIF(SF2->F2_TIPO == "P",0,nTOTAL)+ nImpInc+xMoeda(SF2->F2_FRETAUT,SF2->F2_MOEDA,nMoeda,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
			EndIf
			
			Replace TB_VALOR1  With TB_VALOR1+ nTB_VALOR1
			Replace TB_VALOR2  With TB_VALOR2+ nTB_VALOR2
			Replace TB_VALOR3  With TB_VALOR3+ nTB_VALOR3
		
			
			// Sergio Fuzinaka - 16.10.01
			If Ascan( aCodCli, SF2->F2_CLIENTE+SF2->F2_LOJA ) == 0
				Aadd( aCodCli, SF2->F2_CLIENTE+SF2->F2_LOJA )
			Endif
			
			MsUnlock()
			
			//��������������������������������������������������������������Ŀ
			//� Grava Devolucao ref a Nota Fiscal posicionada                �
			//����������������������������������������������������������������
			If mv_par09 == 3
				GravaDevR4(SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,nMoeda,cEstoq,cDupli)
			Endif
		Endif

	Endif
		
	dbSelectArea("SF2")
	dbSkip()
EndDo

dbSelectArea("SF2")
dbClearFilter()
RetIndex()
fErase(cNomArq4+OrdBagExt())
dbSetOrder(1)

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GTrab1R4  � Autor � Adriano Sacomani      � Data � 27/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera arquivo de Trabalho para emissao de Estat.de Fatur.    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � ReportPrint()                                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static FuncTion GTrab1R4(cEstoq,cDupli,nMoeda,oReport)

Local nTOTAL     := 0
Local nVALICM    := 0
Local nVALIPI    := 0
Local nImpNoInc  := 0
Local nImpInc    := 0
Local nTB_VALOR4 := 0
Local nTB_VALOR5 := 0
Local nTB_VALOR6 := 0
Local nY         := 0 
Local aImpostos	 := {}
Local lAvalTes   := .F.
Local DtMoedaDev := SF1->F1_DTDIGIT
Local nAdic      := 0
Local nValSImp   := 0
Local cFilSA1	 := ""
Local lProcessa	 := .T.

dbSeek(xFilial()+mv_par03,.T.)

If len(oReport:Section(1):GetAdvplExp("SA1")) > 0
	cFilSA1 += oReport:Section(1):GetAdvplExp("SA1")
EndIf

While !Eof() .And. xFilial()==F1_FILIAL .And. F1_FORNECE <= mv_par04
	
	#IFDEF SHELL
		If SF1->F1_CANCEL == "S"
			SF1->(dbSkip())
			Loop
		Endif
	#ENDIF
	
	lProcessa := .T.
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek( xFilial() + SF1->F1_FORNECE + SF1->F1_LOJA)
	//Verifica filtro do ususario
	If !Empty(cFilSA1) .And. !(&cFilSA1)
		lProcessa := .F.
	EndIf	
	If lProcessa
		dbSelectArea("SF1")
		
		If IsRemito(1,"SF1->F1_TIPODOC")
			dbSkip()
			Loop
		Endif
			
		If SF1->F1_DTDIGIT < mv_par01 .Or. SF1->F1_DTDIGIT > mv_par02 .Or.;
			SA1->A1_EST     < mv_par05 .Or. SA1->A1_EST     > mv_par06
			dbSkip()
			Loop
		EndIf
		
		If SF1->F1_TIPO != "D"
			Dbskip()
			Loop
		Endif
		
		dbSelectArea("SD1")
		dbSetOrder(1)
		dbSeek(xFilial()+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
		nTOTAL 		:= 0.00
		nTOTALLIQ	:= 0.00
		nVALICM		:= 0.00
		nVALIPI		:= 0.00
		nImpNoInc	:= 0.00
		nImpInc 	:= 0.00
		lAvalTes    := .F.
		
		dbSelectArea("SF4")
		dbSeek(xFilial()+SD1->D1_TES)
		dbSelectArea("SD1")
		
		While !Eof() .and. xFilial()==SD1->D1_FILIAL .And.;
			SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA ==;
			SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
			
			If SD1->D1_TIPO != "D"
				dbSkip()
				Loop
			Endif
			
			#IFDEF SHELL
				If SD1->D1_CANCEL == "S"
					SD1->(dbSkip())
					Loop
				Endif
			#ENDIF
			
			dbSelectArea("SF4")
			dbSeek(xFilial()+SD1->D1_TES)
			dbSelectArea("SD1")
			
			If AvalTes(D1_TES,cEstoq,cDupli)
				
				If MV_PAR13 == 2
				   //���������������������������������������������������������������������������������������������������������Ŀ
				   //�Verifica se existe a N.F original de Saida , se existir usa a data de emissao da NF de saida             �
				   //�conforme o parametro MV_PAR13 se n�o encontrar usa o campo F1_DTDIGIT para converter a moeda da devolucao�
				   //�����������������������������������������������������������������������������������������������������������
				   dbSelectArea("SF2")
				   dbSetOrder(1)
				   If MsSeek(xFilial()+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA)
					  DtMoedaDev  := SF2->F2_EMISSAO
				   Else
					  DtMoedaDev  := SF1->F1_DTDIGIT
				   EndIf
				Else    
				   DtMoedaDev  := SF1->F1_DTDIGIT            
				EndIf
					  
				dbSelectArea("SD1")

				lAvalTes := .T.
				nTOTAL  +=xMoeda((SD1->D1_TOTAL-SD1->D1_VALDESC),SF1->F1_MOEDA,nMoeda,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA)
				
				If ( cPaisLoc=="BRA" ) 
					If mv_par15 == 1
						nValSImp := TotSImp("SF1","SD1",SD1->D1_TES)
						nTOTALLIQ  +=xMoeda((nValSImp),SF1->F1_MOEDA,nMoeda,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA)
					EndIf	
					nVALICM += xMoeda(SD1->D1_VALICM,1,nMoeda,DtMoedaDev)
					nVALIPI += xMoeda(SD1->D1_VALIPI,1,nMoeda,DtMoedaDev)
				Else
					aImpostos:=TesImpInf(SD1->D1_TES)
					For nY:=1 to Len(aImpostos)
						cCampImp:="SD1->"+(aImpostos[nY][2])
						If ( aImpostos[nY][3]=="1" )
							nImpInc 	+= xmoeda(&cCampImp,SF1->F1_MOEDA,nMoeda,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA)
						Else
							nImpNoInc	+= xmoeda(&cCampImp,SF1->F1_MOEDA,nMoeda,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA)
						Endif
					Next
				Endif
				
			Endif
			
			dbSelectArea("SD1")
			dbSkip()
		EndDo
		
		dbSelectArea("SF1")
		nAdic := 0
		If lAvalTes 
			nAdic := xMoeda(SF1->F1_FRETE+SF1->F1_SEGURO+SF1->F1_DESPESA,SF1->F1_MOEDA,nMoeda,DtMoedaDev)
			nTOTAL += nAdic
		Endif
		
		If nTOTAL > 0
			dbSelectArea(cNomArq)
			If dbSeek(SF1->F1_FORNECE+SF1->F1_LOJA,.F.)
				RecLock(cNomArq,.F.)
			Else
				RecLock(cNomArq,.T.)
				Replace TB_CLI     With SF1->F1_FORNECE
				Replace TB_LOJA	 With SF1->F1_LOJA
				
				//Grava Doc e serie para posicionamento
				Replace TB_DOC 	With SF2->F2_DOC
				Replace TB_SERIE 	With SF2->F2_SERIE
				
			EndIf
			Replace TB_EST     With SA1->A1_EST
			Replace TB_EMISSAO With SF1->F1_EMISSAO
			
			If lAvalTes .And. MV_PAR14 == 2			
				nTB_VALOR5 := nTOTAL
			Else
				nTB_VALOR5 := nTOTAL-nAdic
			EndIf
			
			If ( cPaisLoc=="BRA")
				If nTOTALLIQ <> 0
					nTB_VALOR4 := nTOTALLIQ-nVALICM
				Else
					nTB_VALOR4 := nTOTAL-nVALICM-nAdic
				EndIf
				nTB_VALOR6 := nTOTAL+nVALIPI+xMoeda(SF1->F1_ICMSRET,1,nMoeda,DtMoedaDev)
			Else
				nTB_VALOR4 := nTOTAL-nImpNoInc
				nTB_VALOR6 := nTotal + nImpInc
			Endif
			
			Replace TB_VALOR4  With TB_VALOR4+nTB_VALOR4
			Replace TB_VALOR5  With TB_VALOR5+nTB_VALOR5
			Replace TB_VALOR6  With TB_VALOR6+nTB_VALOR6
			Replace TB_TIPO	   With "DEV"
			MsUnLock()
		Endif
	EndIf
	dbSelectArea("SF1")
	dbSkip()
	
Enddo

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GravaDevR4�Revisor�Alexandre Inacio Lemes � Data � 27/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava item da devolucao ref a nota fiscal posicionada.      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GTrabR4()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static FuncTion GravaDevR4(cNumOri,cSerieOri,cClienteOri,cLojaOri,nMoeda,cEstoq,cDupli)

Local cNum        := ""
Local cSerie      := ""
Local cFornece    := ""
Local cLoja       := ""
Local cNumDocNfe  := ""
Local nX          := 0
Local nTOTAL      := 0
Local nVALICM     := 0
Local nVALIPI     := 0
Local nImpNoInc   := 0
Local nImpInc     := 0
Local nTB_VALOR4  := 0
Local nTB_VALOR5  := 0
Local nTB_VALOR6  := 0
Local nY          := 0
Local aImpostos   := {}
Local aNotDev     := {}
Local lAvalTes    := .F.
Local DtMoedaDev  := SF2->F2_EMISSAO
Local nAdic       := 0

dbSelectArea("SD1")
dbSetOrder(nIndex+1)
If dbseek(xFilial()+cSerieOri+cNumOri+cClienteOri+cLojaOri,.F.)
	
	cNumDocNfe := SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
	
	Aadd( aNotDev, cNumDocNfe )
	
	Do While !Eof() .And. xFilial()==SD1->D1_FILIAL .And. cSerieOri+cNumOri+cClienteOri+cLojaOri;
		== SD1->D1_SERIORI+SD1->D1_NFORI+SD1->D1_FORNECE+SD1->D1_LOJA
		
		If cNumDocNfe <> SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
			If Ascan( aCodCli, SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA) == 0
				Aadd( aNotDev, SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
				cNumDocNfe := SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
			Endif
		Endif
		
		dbSelectArea("SD1")
		dbSkip()
	Enddo
	
	dbSelectArea("SD1")
	dbSetOrder(nIndex+1)
	dbseek(xFilial()+cSerieOri+cNumOri+cClienteOri+cLojaOri,.F.)
	
	For nX :=1 to Len(aNotDev)
		
		dbSelectArea("SD1")
		cNum		:=D1_DOC 
		cSerie	    :=D1_SERIE
		cFornece	:=D1_FORNECE
		cLoja		:=D1_LOJA
		
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek( xFilial() + cFornece + cLoja)
		dbSelectArea("SF1")
		dbSetOrder(1)
		
		If dbSeek(aNotDev[nX])
			
			dbSelectArea("SD1")
			dbSetOrder(1)
			dbSeek(aNotDev[nX])
			
			dbSelectArea("SF1")
			dbSetOrder(1)
			If SF1->F1_DTDIGIT < mv_par01 .Or. SF1->F1_DTDIGIT > mv_par02 .Or.;
				SA1->A1_EST < mv_par05 .Or. SA1->A1_EST > mv_par06 .Or. SF1->F1_TIPO != "D"
				SD1->(dbSkip())
				Loop
			EndIf
			
			If IsRemito(1,"SF1->F1_TIPODOC")
				dbSkip()
				Loop
			Endif

			#IFDEF SHELL
				If SF1->F1_CANCEL == "S"
					SD1->(dbSkip())
					Loop
				Endif
			#ENDIF
			
			nTOTAL 		:=0.00
			nVALICM		:=0.00
			nVALIPI		:=0.00 
			nImpNoInc	:=0.00
			nImpInc 	:=0.00
			lAvalTes    := .F.

            DtMoedaDev  := IIF(MV_PAR13 == 1,SF1->F1_DTDIGIT,SF2->F2_EMISSAO)
			
			dbSelectArea("SF4")
			dbSeek(xFilial()+SD1->D1_TES)
			dbSelectArea("SD1")
			
			While !Eof() .and. xFilial()==SD1->D1_FILIAL .And.SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA ==SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
				
				If SD1->D1_TIPO != "D"
					dbSkip()
					Loop
				Endif
				
				If IsRemito(1,"SD1->D1_TIPODOC")
					dbSkip()
					Loop
				Endif

				#IFDEF SHELL
					If SD1->D1_CANCEL == "S"
						SD1->(dbSkip())
						Loop
					Endif
				#ENDIF
				
				dbSelectArea("SF4")
				dbSeek(xFilial()+SD1->D1_TES)
				
				If AvalTes(SD1->D1_TES,cEstoq,cDupli) .and. cSerieOri+cNumOri == SD1->D1_SERIORI+SD1->D1_NFORI
					
					lAvalTes := .T.
					
					dbSelectArea(cNomArq)
					nTOTAL  +=xMoeda((SD1->D1_TOTAL-SD1->D1_VALDESC),SF1->F1_MOEDA,nMoeda,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA)
					If ( cPaisLoc=="BRA" )
						nVALICM += xMoeda(SD1->D1_VALICM,1,nMoeda,DtMoedaDev)
						nVALIPI += xMoeda(SD1->D1_VALIPI,1,nMoeda,DtMoedaDev)
					Else
						//��������������������������������������������������������������Ŀ
						//� Pesquiso pelas caracteristicas de cada imposto               �
						//����������������������������������������������������������������
						aImpostos:=TesImpInf(SD1->D1_TES)
						For nY:=1 to Len(aImpostos)
							cCampImp:="SD1->"+(aImpostos[nY][2])
							If ( aImpostos[nY][3]=="1" )
								nImpInc 	+= xmoeda(&cCampImp,SF1->F1_MOEDA,nMoeda,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA)
							Else
								nImpNoInc	+= xmoeda(&cCampImp,SF1->F1_MOEDA,nMoeda,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA)
							EndIf
						Next
					EndIf
					
				Endif
				
				dbSelectArea("SD1")
				dbSkip()
			EndDo
			
			dbSelectArea("SF1")           
			nAdic := 0
			If lAvalTes 
				nAdic := xMoeda(SF1->F1_FRETE+SF1->F1_SEGURO+SF1->F1_DESPESA,SF1->F1_MOEDA,nMoeda,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA)
				nTOTAL += nAdic
			Endif
			
			If nTOTAL > 0
				dbSelectArea(cNomArq)
				If dbSeek(SF1->F1_FORNECE+SF1->F1_LOJA,.F.)
					RecLock(cNomArq,.F.)
				Else
					RecLock(cNomArq,.T.)
					Replace TB_CLI     With SF1->F1_FORNECE
					Replace TB_LOJA	 With SF1->F1_LOJA
				EndIf
				
				Replace TB_EST     With SA1->A1_EST
				Replace TB_EMISSAO With DtMoedaDev
				
				If lAvalTes .And. MV_PAR14 == 2			
					nTB_VALOR5 := nTOTAL
				Else
					nTB_VALOR5 := nTOTAL-nAdic
				EndIf
				
				If ( cPaisLoc=="BRA" )
					nTB_VALOR4 := nTOTAL-nVALICM-nAdic
					nTB_VALOR6 := nTOTAL+nVALIPI+xMoeda(SF1->F1_ICMSRET,1,nMoeda,DtMoedaDev)
				Else
					nTB_VALOR4 := nTOTAL-nImpInc
					nTB_VALOR6 := nTotal+nImpInc
				Endif
				
				Replace TB_VALOR4  With TB_VALOR4+nTB_VALOR4
				Replace TB_VALOR5  With TB_VALOR5+nTB_VALOR5
				Replace TB_VALOR6  With TB_VALOR6+nTB_VALOR6
				Replace TB_TIPO	   With "DEV"				
				MsUnLock()			
			EndIf
			
		Endif
		
	Next nX
	
endif

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � RELD1  � Autor � Wagner Xavier         � Data � 05.09.91 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faturamento por Cliente                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RELD1(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��� Marcello     �28/08/00�oooooo�Impressao de casas decimais de acordo   ���
���              �        �      �com a moeda selecionada.                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function RELD1R()
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL CbTxt
LOCAL wnrel
LOCAL titulo     := OemToAnsi(STR0001)  //"Faturamento por Cliente"
LOCAL cDesc1     := OemToAnsi(STR0002)	//"Este relatorio emite a relacao de faturamento. Podera ser"
LOCAL cDesc2     := OemToAnsi(STR0003)	//"emitido por ordem de Cliente ou por Valor (Ranking).     "
LOCAL cString    := "SF2"
LOCAL tamanho    := "M"
//LOCAL limite     := 132
PRIVATE aReturn  := { OemToAnsi(STR0005), 1,OemToAnsi(STR0006), 1, 2, 1, "",1 }	//"Zebrado"###"Administracao"
PRIVATE aCodCli  := {}
PRIVATE aLinha   := {}
PRIVATE nomeprog := "RELD1"
PRIVATE cPerg    := "MTR590"
PRIVATE nLastKey := 0

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
cbtxt    := SPACE(10)
li       := 80
m_pag    := 01

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte("MTR590",.F.)
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01        // Data de                  		         �
//� mv_par02        // Data ate  					       		 �
//� mv_par03        // Cliente de                                �
//� mv_par04 	    // Cliente ate                               �
//� mv_par05	    // Estado de                                 �
//� mv_par06	    // Estado ate                                �
//� mv_par07	    // Cliente  Valor  Estado                    �
//� mv_par08	    // Moeda                                     �
//� mv_par09        // Devolucao				                 �
//� mv_par10        // Duplicatas  			                     �
//� mv_par11        // Estoque   				                 �
//� mv_par12        // Abatimento  				                 �
//� mv_par13        // Converte a moeda da devolucao             �
//� mv_par14        // Desconsidera adicionais ?                 �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
wnrel  := "RELD1"
wnrel  := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,"",.F.,"",,Tamanho)

If nLastKey==27
	dbClearFilter()
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| C590Imp(@lEnd,wnRel,cString)},Titulo)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � C590IMP  � Autor � Rosane Luciane Chene  � Data � 09.11.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RELD1  		                                       	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function C590Imp(lEnd,WnRel,cString)

LOCAL titulo   := OemToAnsi(STR0001)
LOCAL cEstoq   := If( (MV_PAR11== 1),"S",If( (MV_PAR11== 2),"N","SN" ) )
LOCAL cDupli   := If( (MV_PAR10== 1),"S",If( (MV_PAR10== 2),"N","SN" ) )
LOCAL nAbto    := MV_PAR12
LOCAL cPict	   := ""
LOCAL CbTxt    := ""
LOCAL CbCont   := ""
LOCAL cabec1   := "" 
LOCAL cabec2   := ""
LOCAL cCliente := ""
LOCAL cLoja    := ""
LOCAL cEst     := ""
LOCAL cMoeda   := ""
LOCAL tamanho  := "M"
LOCAL nRank    := 0
LOCAL nMoeda   := 0
LOCAL nAg1     := 0
LOCAL nAg2     := 0
LOCAL nAg3     := 0
LOCAL nAg4     := 0
LOCAL nAg5     := 0
LOCAL nAg6     := 0
LOCAL nValor1  := 0
LOCAL nValor2  := 0
LOCAL nValor3  := 0
LOCAL nValor4  := 0
LOCAL nValor5  := 0
LOCAL nValor6  := 0
LOCAL nEstV1   := 0
LOCAL nEstV2   := 0
LOCAL nEstV3   := 0
LOCAL nEstV4   := 0
LOCAL nEstV5   := 0
LOCAL nEstV6   := 0
LOCAL aCampos  := {}
LOCAL aTam	   := {}
Local cNCliObf := ""
Local cNomeCli := ""

Private oTempTable := NIl
PRIVATE nDecs:=msdecimais(mv_par08)

cPict	:= "@E) 99,999,999,999" + IIf(nDecs > 0,"."+replicate("9",nDecs),"")

nTipo:=IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM"))

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
cbtxt    := SPACE(10)
cbcont   := 00
li       := 80
m_pag    := 01

nMoeda := mv_par08
cMoeda := GetMv("MV_MOEDA"+Ltrim(STR(nMoeda)))

IF mv_par07 = 1
	titulo := OemToAnsi(STR0007)+cmoeda 	//"FATURAMENTO POR CLIENTE  (CODIGO) - "
ElseIf mv_par07 == 2
	titulo := OemToAnsi(STR0008)+cmoeda		//"FATURAMENTO POR CLIENTE  (RANKING) - "
Else
	titulo := OemToAnsi(STR0009)+cmoeda		//"FATURAMENTO POR CLIENTE  (ESTADO) - "
EndIF

cabec1 := OemToAnsi(STR0010)	//"CODIGO/LOJA               RAZAO SOCIAL                                   FATURAMENTO          VALOR DA             VALOR RANKING"
cabec2 := OemToAnsi(STR0011)	//"                                                                             SEM ICM        MERCADORIA             TOTAL"
// 999999xxxxxxxxxxxxxx/XXxx XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99,999,999,999.99 99,999,999,999.99 99,999,999,999.99    9999 DEV
//           1         2         3         4         5         6         7         8         9         10        11        12        13
// 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901


//��������������������������������������������������������������Ŀ
//� Cria array para gerar arquivo de trabalho                    �
//����������������������������������������������������������������
aTam:=TamSX3("F2_CLIENTE")
AADD(aCampos,{ "TB_CLI"    ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("F2_LOJA")
AADD(aCampos,{ "TB_LOJA"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("A1_EST")
AADD(aCampos,{ "TB_EST"    ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("F2_EMISSAO")
AADD(aCampos,{ "TB_EMISSAO","D",aTam[1],aTam[2] } )
aTam:=TamSX3("D1_COD")
AADD(aCampos,{ "TB_COD","C",aTam[1],aTam[2] } )
aTam:=TamSX3("D1_ITEM")
AADD(aCampos,{ "TB_ITEM","C",aTam[1],aTam[2] } )
AADD(aCampos,{ "TB_CUSTO"  ,"N",16,nDecs } )		
AADD(aCampos,{ "TB_VALOR1 ","N",16,nDecs } )		// Valores de Faturamento
AADD(aCampos,{ "TB_VALOR2 ","N",16,nDecs } )
AADD(aCampos,{ "TB_VALOR3 ","N",16,nDecs } )
AADD(aCampos,{ "TB_VALOR4 ","N",16,nDecs } )		// Valores para devolucao
AADD(aCampos,{ "TB_VALOR5 ","N",16,nDecs } )
AADD(aCampos,{ "TB_VALOR6 ","N",16,nDecs } )
AADD(aCampos,{ "TB_RANKIN ","N",16,0 } )        // Ranking conforme Valor faturamento
AADD(aCampos,{ "TB_CONT"   ,"N",16,nDecs} )
cNomArq := GetNextAlias()

//-------------------------------------------------------------------
// Instancia tabela tempor�ria.  
//-------------------------------------------------------------------

oTempTable	:= FWTemporaryTable():New( cNomArq )

//-------------------------------------------------------------------
// Atribui o  os �ndices.  
//-------------------------------------------------------------------
oTempTable:SetFields( aCampos )
oTempTable:AddIndex("1",{"TB_CLI","TB_LOJA"})
oTempTable:AddIndex("2",{"TB_CONT"})
oTempTable:AddIndex("3",{"TB_EST","TB_CLI","TB_LOJA"})
oTempTable:AddIndex("4",{"TB_RANKIN"})

//------------------
//Cria��o da tabela
//------------------
oTempTable:Create()
(cNomArq)->(DbSetOrder(1))

cNomArq3 := SubStr(cNomArq,1,7)+"3"
cNomArq4 := SubStr(cNomArq,1,7)+"4"

dbSelectArea("SF2")
dbSetOrder(2)

SetRegua(RecCount())		// Total de Elementos da regua
//��������������������������������������������������������������Ŀ
//� Chamada da Funcao para gerar arquivo de Trabalho             �
//����������������������������������������������������������������
if mv_par09 == 3
	cKey:="D1_FILIAL+D1_SERIORI+D1_NFORI+D1_FORNECE+D1_LOJA"
	cFiltro :="D1_FILIAL=='"+xFilial("SD1")+"'.And.!Empty(D1_NFORI)"
	cFiltro += ".And. !("+IsRemito(2,"SD1->D1_TIPODOC")+")"		

	#IFDEF SHELL
		cFiltro += '.And. D1_CANCEL <> "S"'
	#ENDIF
	IndRegua("SD1",cNomArq3,cKey,,cFiltro,OemToAnsi(STR0012))	//"Selecionando Registros..."
	nIndex:=RetIndex("SD1")

	dbSetOrder(nIndex+1)
	dbGotop()
Endif
//����������������������������������������Ŀ
//� Grava arquivo de trabalho.             �
//������������������������������������������
GeraTrab(cEstoq,cDupli,nMoeda)

If mv_par09 == 1
	dbSelectArea("SF1")
	dbSetOrder(2)
	IncRegua()
	GeraTrab1(cEstoq,cDupli,nMoeda)
Endif

dbSelectArea(cNomArq)
dbCommit()

If mv_par07 == 1

	(cNomArq)->(dbGoTop())
	While !Eof() 
		RecLock(cNomArq,.F.)
		(cNomArq)->TB_CONT :=   (cNomArq)->TB_VALOR3 + (cNomArq)->TB_VALOR6
		MsUnlock()
		(cNomArq)->(dbSkip()) 
	Enddo 
	(cNomArq)->(DbSetOrder(2))
	(cNomArq)->(dbGoBottom())
	
	nRank:=1 

	While !Bof()  
		RecLock(cNomArq,.F.)
		(cNomArq)->TB_RANKIN := nRank 
		MsUnlock()
		nRank++
		(cNomArq)->(dbSkip(-1))
	Enddo
	nRank:=0
	(cNomArq)->(DbSetOrder(1))

ElseIf mv_par07 == 2

	(cNomArq)->(dbGoTop()) 
	While !Eof() 
		RecLock(cNomArq,.F.)
		(cNomArq)->TB_CONT :=   (cNomArq)->TB_VALOR3 + (cNomArq)->TB_VALOR6
		MsUnlock()
		(cNomArq)->(dbSkip()) 
	EndDo 

	(cNomArq)->(DbSetOrder(2))
	(cNomArq)->(dbGoBottom())
	
	nRank:=1 
	While !Bof()  
		RecLock(cNomArq,.F.)
		(cNomArq)->TB_RANKIN := nRank 
		MsUnlock()
		nRank++
		(cNomArq)->(dbSkip(-1))
	EndDo
	nRank:=0
	(cNomArq)->(DbSetOrder(4))
	(cNomArq)->(dbGoTop())
Else
	(cNomArq)->(DbSetOrder(3))
Endif

dbSelectArea(cNomArq)

dbGoTop()

While !Eof()
	IncRegua()
	
	If lEnd
		@Prow()+1,001 PSAY OemToAnsi(STR0013)	//"CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	If li > 55
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Endif
	
	If mv_par07 == 3
		If Empty(cEst)
			cEst := TB_EST
		ElseIf cEst != TB_EST
			li++
			@li, 00 PSAY OemToAnsi(STR0014) + cEst + "--->"	//"Total do Estado de "
			@li, 67 PSAY nEstV1		PicTure cPict
			@li, 85 PSAY nEstV2		PicTure cPict
			@li,103 PSAY nEstV3		PicTure cPict
			
			If nEstv4+nEstv5+nEstv6!=0
				li++
				@li, 67 PSAY nEstV4		PicTure cPict
				@li, 85 PSAY nEstV5		PicTure cPict
				@li,103 PSAY nEstV6		PicTure cPict
				@li,129 PSAY "DEV"
				If nAbto == 1
					li++
					@li, 67 PSAY nEstV1+nEstV4  PICTURE cPict
					@li, 85 PSAY nEstV2+nEstV5  PICTURE cPict
					@li,103 PSAY nEstV3+nEstV6  PICTURE cPict
					@li,129 PSAY "ABT"
				Endif
			Endif
			cEst := TB_EST
			li++
			nEstV1:=0
			nEstV2:=0
			nEstV3:=0
			nEstV4:=0
			nEstV5:=0
			nEstV6:=0
			li++
		EndIf
		@ li,00 PSAY OemToAnsi(STR0015) + cEst 	//"Estado: "
		li++
	EndIf
	
	cCliente := TB_CLI
	cLoja    := TB_LOJA
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial()+cCliente+cLoja)

	cNomeCli := Substr(SA1->A1_NOME,1,40)
	If Empty(cNCliObf) .And. FATPDIsObfuscate("A1_NOME")  
		cNCliObf := FATPDObfuscate(cNomeCli)
	EndIf 

	@li,00 PSAY SA1->A1_COD + "/"+ SA1->A1_LOJA
	@li,26 PSAY IIF(Empty(cNCliObf),cNomeCli,cNCliObf)
	
	dbSelectArea(cNomArq)
	
	nValor1:= TB_VALOR1
	nValor2:= TB_VALOR2
	nValor3:= TB_VALOR3
	nValor4:= TB_VALOR4
	nValor5:= TB_VALOR5
	nValor6:= TB_VALOR6
	
	nValor4*=(-1)
	nValor5*=(-1)
	nValor6*=(-1)
	
	@li, 67 PSAY nValor1  PICTURE cPict
	@li, 85 PSAY nValor2  PICTURE cPict
	@li,103 PSAY nValor3  PICTURE cPict
	
	IF mv_par07 == 1 .Or. mv_par07 == 2
		nRank:=TB_RANKIN
		@li,124 PSAY nRank	PICTURE "9999"
	EndIF
	
	If nValor4+nValor5+nValor6!=0
		li++
		@li, 67 PSAY nValor4  PICTURE cPict
		@li, 85 PSAY nValor5  PICTURE cPict
		@li,103 PSAY nValor6  PICTURE cPict
		@li,129 PSAY "DEV"
		If nAbto == 1
			li++
			@li, 67 PSAY nValor1+nValor4  PICTURE cPict
			@li, 85 PSAY nValor2+nValor5  PICTURE cPict
			@li,103 PSAY nValor3+nValor6  PICTURE cPict
			@li,129 PSAY "ABT"
		Endif
	Endif
	nEstV1+= nValor1
	nEstV2+= nValor2
	nEstV3+= nValor3
	nEstV4+= nValor4
	nEstV5+= nValor5
	nEstV6+= nValor6
	
	li++
	
	nAg1 += nValor1
	nAg2 += nValor2
	nAg3 += nValor3
	nAg4 += nValor4
	nAg5 += nValor5
	nAg6 += nValor6
	
	dbSkip()
EndDo

IF li != 80

	If li > 54
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Endif

	If mv_par07 == 3
		li++
		@li, 00 PSAY OemToAnsi(STR0014) + cEst + "--->"
		@li, 67 PSAY nEstV1		PicTure cPict
		@li, 85 PSAY nEstV2		PicTure cPict
		@li,103 PSAY nEstV3		PicTure cPict
		
		If (nEstV4+nEstV5+nEstV6)!=0
			li++
			@li, 67 PSAY nEstV4		PicTure cPict
			@li, 85 PSAY nEstV5		PicTure cPict
			@li,103 PSAY nEstV6		PicTure cPict
			@li,129 PSAY "DEV"
			If nAbto == 1
				li++
				@li, 67 PSAY nEstV1+nEstV4  PICTURE cPict
				@li, 85 PSAY nEstV2+nEstV5  PICTURE cPict
				@li,103 PSAY nEstV3+nEstV6  PICTURE cPict
				@li,129 PSAY "ABT"
			Endif
		Endif
		
		li:=li + 2
	EndIf
	li++
	@li, 00 PSAY OemToAnsi(STR0016)	//"T O T A L --->"
	@li, 67 PSAY nAg1		PicTure cPict
	@li, 85 PSAY nAg2		PicTure cPict
	@li,103 PSAY nAg3		PicTure cPict
	
	If (nAg4+nAg5+nAg6)!=0
		li++
		@li, 67 PSAY nAg4		PicTure cPict
		@li, 85 PSAY nAg5		PicTure cPict
		@li,103 PSAY nAg6		PicTure cPict
		@li,129 PSAY "DEV"
		If nAbto == 1
			li++
			@li, 67 PSAY nAg1+nAg4  PICTURE cPict
			@li, 85 PSAY nAg2+nAg5  PICTURE cPict
			@li,103 PSAY nAg3+nAg6  PICTURE cPict
			@li,129 PSAY "ABT"
		Endif
	Endif
	
	roda(cbcont,cbtxt)
EndIF

If( valtype(oTempTable) == "O")
	oTempTable:Delete()
	freeObj(oTempTable)
	oTempTable := nil
EndIf

//��������������������������������������������������������������Ŀ
//� Restaura a integridade dos dados                             �
//����������������������������������������������������������������
If mv_par09 == 3
	dbSelectArea("SD1")
	dbClearFilter()
	RetIndex()
	fErase(cNomArq3+OrdBagExt())
	dbSetOrder(1)
Endif

dbSelectArea("SF2")
dbClearFilter()
dbSetOrder(1)
dbSelectArea("SD2")
dbSetOrder(1)

If aReturn[5] == 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif
MS_FLUSH()
Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GeraTrab  � Autor � Wagner Xavier         � Data � 10.01.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera arquivo de Trabalho para emissao de Estat.de Fatur.    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GeraTrab()                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static FuncTion GeraTrab(cEstoq,cDupli,nMoeda)

//Local cChaven    := ""
Local nTOTAL     := 0
Local nVALICM    := 0
Local nVALIPI    := 0
//Local ImpNoInc   := 0    
Local nImpInc    := 0    
Local nTB_VALOR1 := 0
Local nTB_VALOR2 := 0
Local nTB_VALOR3 := 0
Local nY         := 0
Local aImpostos	 := {}
Local lAvalTes   := .F.                  
Local lProcessa  := .T.
Local nAdic      := 0
Local nValSImp   := 0
Local nTotDesp   := 0
Local lValadi	 := cPaisLoc == "MEX" .AND. SD2->(FieldPos("D2_VALADI")) > 0 .AND. VALTYPE(MV_PAR15) =="N" .AND. MV_PAR15==1 //  Adiantamentos Mexico
Local lComplIPI  := .F.
Local nComplIPI  := 0

Private cCampImp

dbSelectArea("SF2")
dbsetorder(1)
cKey := indexkey()
cFiltro := "DTOS(F2_EMISSAO) >= '"+ Dtos(mv_par01) +"'.AND. DTOS(F2_EMISSAO) <= '"+ dtos(mv_par02) +"' .AND."
cFiltro += "F2_CLIENTE >= '"+ mv_par03 + "' .AND. F2_CLIENTE <= '"+ mv_par04 + "' .and. " 
cFiltro += "F2_FILIAL = '" + xFilial("SF2") + "'"
IndRegua("SF2",cNomArq4,cKey,,cFiltro,OemToAnsi(STR0012))	//"Selecionando Registros..."
nIndex:=RetIndex("SF2")

dbSetOrder(nIndex+1)
dbGotop()

While !Eof() .And. xFilial()=SF2->F2_FILIAL 

	lProcessa := .T.
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek ( xFilial() + SF2->F2_CLIENTE+SF2->F2_LOJA )
	dbSelectArea("SF2")
	
	#IFDEF SHELL
		If SF2->F2_CANCEL == "S"
			lProcessa := .F.
		Endif
	#ENDIF
	
	If IsRemito(1,"SF2->F2_TIPODOC")
			lProcessa := .F.
	Endif	
	
	IF SA1->A1_EST 	 < mv_par05 .Or. SA1->A1_EST     > mv_par06	
		lProcessa := .F.
	EndIF
	
	If (At(SF2->F2_TIPO,"DB") != 0) .Or. (SF2->F2_TIPO == "I" .And. SF2->F2_ICMSRET == 0)
		lProcessa := .F.
	Endif

	If !Empty(aReturn[7])
		If !&(aReturn[7])
	      lProcessa := .F.
		Endif
	Endif		     

	If lProcessa
		
		IncRegua()
		
		dbSelectArea("SD2")
		dbSetOrder(3)
		dbSeek(xFilial()+SF2->F2_DOC+SF2->F2_SERIE)
		nTOTAL 		:=0
		nTOTALLIQ	:=0
		nVALICM		:=0
		nVALIPI		:=0
		nImpNoInc	:=0
		nImpInc  	:=0
		lAvalTes    := .F.
		nTotDesp    := 0					
		nAdic 		:= 0					

		If cPaisLoc <> "BRA" .and. Type("SF2->F2_TXMOEDA")#"U"
			nAdic    += xMoeda(SF2->F2_SEGURO+SF2->F2_FRETE+SF2->F2_DESPESA,SF2->F2_MOEDA,nMoeda,SF2->F2_EMISSAO)
		Endif

		While !Eof() .And. xFilial()==SD2->D2_FILIAL .And.;
			SD2->D2_DOC+SD2->D2_SERIE == SF2->F2_DOC+SF2->F2_SERIE
			
			#IFDEF SHELL
				If SD2->D2_CANCEL == "S" .Or. !(Substr(SD2->D2_CF,2,2)$"12|73|74")
					SD2->(dbSkip())
					Loop
				Endif
			#ENDIF
			
			dbSelectArea("SF4")
			dbSeek(xFilial()+SD2->D2_TES)
			
			dbSelectArea("SD2")
			If AvalTes(D2_TES,cEstoq,cDupli)
				
				lAvalTes := .T.
				
				If cPaisLoc <> "BRA" .and. Type("SF2->F2_TXMOEDA")#"U"
					nTOTAL  += xMoeda(SD2->D2_TOTAL-Iif(lValadi,SD2->D2_VALADI,0),SF2->F2_MOEDA,nMoeda,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
				Else
					If SF4->F4_AGREG <> "N"
						nTOTAL  += xMoeda(SD2->D2_TOTAL-Iif(lValadi,SD2->D2_VALADI,0),1,nMoeda,SF2->F2_EMISSAO,nDecs+1)						
						nAdic += xMoeda(SD2->D2_SEGURO+SD2->D2_VALFRE+SD2->D2_DESPESA,SF2->F2_MOEDA,nMoeda,SF2->F2_EMISSAO)
					Else
						nTOTAL  += xMoeda(SD2->D2_SEGURO+SD2->D2_VALFRE+SD2->D2_DESPESA,1,nMoeda,SF2->F2_EMISSAO,nDecs+1)
						nTotDesp += xMoeda(SD2->D2_SEGURO+SD2->D2_VALFRE+SD2->D2_DESPESA,1,nMoeda,SF2->F2_EMISSAO,nDecs+1)
						nAdic += xMoeda(SD2->D2_SEGURO+SD2->D2_VALFRE+SD2->D2_DESPESA,SF2->F2_MOEDA,nMoeda,SF2->F2_EMISSAO)
					EndIf
					If mv_par15 == 1 .And. SF4->F4_AGREG <> "N"
						nValSImp := TotSImp("SF2","SD2",SD2->D2_TES)
						nTOTALLIQ  += xMoeda(nValSImp,1,nMoeda,SF2->F2_EMISSAO,nDecs+1)
					EndIf
					lComplIPI := SF2->F2_TIPO == "P"
					If 	lComplIPI
						nComplIPI := SD2->D2_TOTAL
					EndIf	
				Endif
				If !lComplIPI
					If ( cPaisLoc=="BRA")       
						nVALICM += xMoeda(SD2->D2_VALICM,1,nMoeda,SF2->F2_EMISSAO)
						nVALIPI += xMoeda(SD2->D2_VALIPI,1,nMoeda,SF2->F2_EMISSAO)
					Else
						//��������������������������������������������������������������Ŀ
						//� Pesquiso pelas caracteristicas de cada imposto               �
						//����������������������������������������������������������������
						aImpostos:=TesImpInf(SD2->D2_TES)
						For nY:=1 to Len(aImpostos)
							cCampImp:="SD2->"+(aImpostos[nY][2])
							If ( aImpostos[nY][3]=="1" )
								nImpInc 	+= xMoeda(&cCampImp,SF2->F2_MOEDA,nMoeda,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
							Else
								nImpNoInc 	+= xmoeda(&cCampImp,SF2->F2_MOEDA,nMoeda,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
							Endif
						Next
					EndIf
				EndIf
			Endif
			
			dbSelectArea("SD2")
			dbSkip()
		EndDo
		
		dbSelectArea("SF2")

		If lAvalTes
			nTOTAL += nAdic
		Endif
		
		If nTOTAL > 0
			dbSelectArea(cNomArq)
			If dbSeek(SF2->F2_CLIENTE+SF2->F2_LOJA,.F.)
				RecLock(cNomArq,.F.)
			Else
				RecLock(cNomArq,.T.)
				Replace TB_CLI     With SF2->F2_CLIENTE
				Replace TB_LOJA    With SF2->F2_LOJA
			EndIF
			Replace TB_EST     With SA1->A1_EST
			Replace TB_EMISSAO With SF2->F2_EMISSAO
			
			If lAvalTes .And. MV_PAR14 == 2
				nTB_VALOR2 := IIF(SF2->F2_TIPO == "P",0,nTOTAL-nTotDesp)
			Else
				nTB_VALOR2 := IIF(SF2->F2_TIPO == "P",0,nTOTAL-nAdic-nTotDesp)
			EndIf

			If ( cPaisLoc=="BRA" )
				If nTOTALLIQ <> 0
					If !lComplIPI
						nTB_VALOR1 := nTOTALLIQ-nVALICM
					Else
						nTB_VALOR1 := nTOTALLIQ-nVALICM-nComplIPI
					EndIf
				Else
					If !lComplIPI
						nTB_VALOR1 := nTOTAL-nVALICM-nAdic-nTotDesp
					Else
						nTB_VALOR1 := nTOTAL-nVALICM-nAdic-nTotDesp-nComplIPI
					EndIf
				EndIf
				nTB_VALOR3 := IIF(SF2->F2_TIPO == "P",nComplIPI,nTOTAL-nTotDesp);
				+ nVALIPI+;
				IIF(SF2->F2_TIPO=="I" .And. SF2->F2_ICMSRET > 0,xMoeda(SF2->F2_FRETAUT,1,nMoeda,SF2->F2_EMISSAO),xMoeda(SF2->F2_ICMSRET+SF2->F2_FRETAUT,1,nMoeda,SF2->F2_EMISSAO))				
			Else
				nTB_VALOR1 := nTOTAL-nImpNoInc
				nTB_VALOR3 := IIF(SF2->F2_TIPO == "P",0,nTOTAL)+ nImpInc+xMoeda(SF2->F2_FRETAUT,SF2->F2_MOEDA,nMoeda,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
			EndIf
			
			Replace TB_VALOR1  With TB_VALOR1+ nTB_VALOR1
			Replace TB_VALOR2  With TB_VALOR2+ nTB_VALOR2
			Replace TB_VALOR3  With TB_VALOR3+ nTB_VALOR3
			
			// Sergio Fuzinaka - 16.10.01
			If Ascan( aCodCli, SF2->F2_CLIENTE+SF2->F2_LOJA ) == 0
				Aadd( aCodCli, SF2->F2_CLIENTE+SF2->F2_LOJA )
			Endif
			
			MsUnlock()
			
			//��������������������������������������������������������������Ŀ
			//� Grava Devolucao ref a Nota Fiscal posicionada                �
			//����������������������������������������������������������������
			If mv_par09 == 3
				GravaDev(SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,nMoeda,cEstoq,cDupli)
			Endif
		Endif

	Endif
		
	dbSelectArea("SF2")
	dbSkip()
EndDo

dbSelectArea("SF2")
dbClearFilter()
RetIndex()
fErase(cNomArq4+OrdBagExt())
dbSetOrder(1)

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GeraTrab1 � Autor � Adriano Sacomani      � Data � 09.08.94 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera arquivo de Trabalho para emissao de Estat.de Fatur.    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GeraTrab1)                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static FuncTion GeraTrab1(cEstoq,cDupli,nMoeda)
Local nTOTAL     := 0
Local nVALICM    := 0
Local nVALIPI    := 0
Local nImpNoInc  := 0
Local nImpInc    := 0
Local nTB_VALOR4 := 0
Local nTB_VALOR5 := 0
Local nTB_VALOR6 := 0
Local nY         := 0 
Local aImpostos	 := {}
Local lAvalTes   := .F.
Local DtMoedaDev := SF1->F1_DTDIGIT
Local nAdic      := 0
Local nValSImp   := 0

dbSeek(xFilial()+mv_par03,.T.)
While !Eof() .And. xFilial()==F1_FILIAL .And. F1_FORNECE <= mv_par04
	
	#IFDEF SHELL
		If SF1->F1_CANCEL == "S"
			SF1->(dbSkip())
			Loop
		Endif
	#ENDIF
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek( xFilial() + SF1->F1_FORNECE + SF1->F1_LOJA)
	dbSelectArea("SF1")
	
	If IsRemito(1,"SF1->F1_TIPODOC")
		dbSkip()
		Loop
	Endif
		
	If SF1->F1_DTDIGIT < mv_par01 .Or. SF1->F1_DTDIGIT > mv_par02 .Or.;
		SA1->A1_EST     < mv_par05 .Or. SA1->A1_EST     > mv_par06
		dbSkip()
		Loop
	EndIf
	
	If SF1->F1_TIPO != "D"
		Dbskip()
		Loop
	Endif
	
	IncRegua()

	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSeek(xFilial()+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	nTOTAL 		:=0.00
	nTOTALLIQ	:=0.00
	nVALICM		:=0.00
	nVALIPI		:=0.00
	nImpNoInc	:=0.00
	nImpInc 	:=0.00
	lAvalTes    := .F.
	
	dbSelectArea("SF4")
	dbSeek(xFilial()+SD1->D1_TES)
	dbSelectArea("SD1")
	
	While !Eof() .and. xFilial()==SD1->D1_FILIAL .And.;
		SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA ==;
		SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
		
		If SD1->D1_TIPO != "D"
			dbSkip()
			Loop
		Endif
		
		#IFDEF SHELL
			If SD1->D1_CANCEL == "S"
				SD1->(dbSkip())
				Loop
			Endif
		#ENDIF
		
		dbSelectArea("SF4")
		dbSeek(xFilial()+SD1->D1_TES)
		dbSelectArea("SD1")
		
		If AvalTes(D1_TES,cEstoq,cDupli)
			
			If MV_PAR13 == 2
               //���������������������������������������������������������������������������������������������������������Ŀ
               //�Verifica se existe a N.F original de Saida , se existir usa a data de emissao da NF de saida             �
               //�conforme o parametro MV_PAR13 se n�o encontrar usa o campo F1_DTDIGIT para converter a moeda da devolucao�
               //�����������������������������������������������������������������������������������������������������������
	           dbSelectArea("SF2")
	           dbSetOrder(1)
	           If MsSeek(xFilial()+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA)
                  DtMoedaDev  := SF2->F2_EMISSAO
               Else
                  DtMoedaDev  := SF1->F1_DTDIGIT
               EndIf
            Else    
               DtMoedaDev  := SF1->F1_DTDIGIT            
            EndIf
                  
		    dbSelectArea("SD1")

			lAvalTes := .T.
			
			nTOTAL  +=xMoeda((SD1->D1_TOTAL-SD1->D1_VALDESC),SF1->F1_MOEDA,nMoeda,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA)
			
			If ( cPaisLoc=="BRA" )
				If mv_par15 == 1
					nValSImp := TotSImp("SF1","SD1",SD1->D1_TES)
					nTOTALLIQ  +=xMoeda((nValSImp),SF1->F1_MOEDA,nMoeda,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA)
				EndIf				
				nVALICM += xMoeda(SD1->D1_VALICM,1,nMoeda,DtMoedaDev)
				nVALIPI += xMoeda(SD1->D1_VALIPI,1,nMoeda,DtMoedaDev)
			Else
				aImpostos:=TesImpInf(SD1->D1_TES)
				For nY:=1 to Len(aImpostos)
					cCampImp:="SD1->"+(aImpostos[nY][2])
					If ( aImpostos[nY][3]=="1" )
						nImpInc 	+= xmoeda(&cCampImp,SF1->F1_MOEDA,nMoeda,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA)
					Else
						nImpNoInc	+= xmoeda(&cCampImp,SF1->F1_MOEDA,nMoeda,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA)
					Endif
				Next
			Endif
			
		Endif
		
		dbSelectArea("SD1")
		dbSkip()
	EndDo
	
	dbSelectArea("SF1")
	nAdic := 0
	If lAvalTes 
		nAdic := xMoeda(SF1->F1_FRETE+SF1->F1_SEGURO+SF1->F1_DESPESA,SF1->F1_MOEDA,nMoeda,DtMoedaDev)
		nTOTAL  += nAdic
	Endif
	
	If nTOTAL > 0
		dbSelectArea(cNomArq)
		If dbSeek(SF1->F1_FORNECE+SF1->F1_LOJA,.F.)
			RecLock(cNomArq,.F.)
		Else
			RecLock(cNomArq,.T.)
			Replace TB_CLI     With SF1->F1_FORNECE
			Replace TB_LOJA	 With SF1->F1_LOJA
		EndIf
		Replace TB_EST     With SA1->A1_EST
		Replace TB_EMISSAO With SF1->F1_EMISSAO
		
		If lAvalTes .And. MV_PAR14 == 2			
			nTB_VALOR5 := nTOTAL
		Else
			nTB_VALOR5 := nTOTAL-nAdic
		EndIf
		
		If ( cPaisLoc=="BRA")
			If nTOTALLIQ <> 0
				nTB_VALOR4 := nTOTALLIQ-nVALICM
			Else
				nTB_VALOR4 := nTOTAL-nVALICM-nAdic
			EndIf
			nTB_VALOR6 := nTOTAL+nVALIPI+xMoeda(SF1->F1_ICMSRET,1,nMoeda,DtMoedaDev)
		Else
			nTB_VALOR4 := nTOTAL-nImpNoInc
			nTB_VALOR6 := nTotal + nImpInc
		Endif
		
		Replace TB_VALOR4  With TB_VALOR4+nTB_VALOR4
		Replace TB_VALOR5  With TB_VALOR5+nTB_VALOR5
		Replace TB_VALOR6  With TB_VALOR6+nTB_VALOR6
		MsUnlock()
	Endif
	
	dbSelectArea("SF1")
	dbSkip()
	
Enddo

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GravaDev  �Revisor�Alexandre Inacio Lemes � Data � 27/11/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava item da devolucao ref a nota fiscal posicionada.      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GravaDev                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static FuncTion GravaDev(cNumOri,cSerieOri,cClienteOri,cLojaOri,nMoeda,cEstoq,cDupli)
Local cNum        := ""
Local cSerie      := ""
Local cFornece    := ""
Local cLoja       := ""
Local cNumDocNfe  := ""
Local nX          := 0
Local nTOTAL      := 0
Local nVALICM     := 0
Local nVALIPI     := 0
Local nImpNoInc   := 0
Local nImpInc     := 0
Local nTB_VALOR4  := 0
Local nTB_VALOR5  := 0
Local nTB_VALOR6  := 0
Local nY          := 0
Local aImpostos   := {}
Local aNotDev     := {}
Local lAvalTes    := .F.
Local DtMoedaDev  := SF2->F2_EMISSAO
Local nAdic       := 0

dbSelectArea("SD1")
dbSetOrder(nIndex+1)
If dbseek(xFilial()+cSerieOri+cNumOri+cClienteOri+cLojaOri,.F.)
	
	cNumDocNfe := SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
	
	Aadd( aNotDev, cNumDocNfe )
	
	Do While !Eof() .And. xFilial()==SD1->D1_FILIAL .And. cSerieOri+cNumOri+cClienteOri+cLojaOri;
		== SD1->D1_SERIORI+SD1->D1_NFORI+SD1->D1_FORNECE+SD1->D1_LOJA
		
		If cNumDocNfe <> SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
			If Ascan( aCodCli, SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA) == 0
				Aadd( aNotDev, SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
				cNumDocNfe := SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
			Endif
		Endif
		
		dbSelectArea("SD1")
		dbSkip()
	Enddo
	
	dbSelectArea("SD1")
	dbSetOrder(nIndex+1)
	dbseek(xFilial()+cSerieOri+cNumOri+cClienteOri+cLojaOri,.F.)
	
	For nX :=1 to Len(aNotDev)
		
		dbSelectArea("SD1")
		cNum		:=D1_DOC
		cSerie	    :=D1_SERIE
		cFornece	:=D1_FORNECE
		cLoja		:=D1_LOJA
		
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek( xFilial() + cFornece + cLoja)
		dbSelectArea("SF1")
		dbSetOrder(1)
		
		If dbSeek(aNotDev[nX])
			
			dbSelectArea("SD1")
			dbSetOrder(1)
			dbSeek(aNotDev[nX])
			
			dbSelectArea("SF1")
			dbSetOrder(1)
			If SF1->F1_DTDIGIT < mv_par01 .Or. SF1->F1_DTDIGIT > mv_par02 .Or.;
				SA1->A1_EST < mv_par05 .Or. SA1->A1_EST > mv_par06 .Or. SF1->F1_TIPO != "D"
				SD1->(dbSkip())
				Loop
			EndIf
			
			If IsRemito(1,"SF1->F1_TIPODOC")
				dbSkip()
				Loop
			Endif

			#IFDEF SHELL
				If SF1->F1_CANCEL == "S"
					SD1->(dbSkip())
					Loop
				Endif
			#ENDIF
			
			nTOTAL 		:=0.00
			nVALICM		:=0.00
			nVALIPI		:=0.00
			nImpNoInc	:=0.00
			nImpInc 	:=0.00
			lAvalTes    := .F.

            DtMoedaDev  := IIF(MV_PAR13 == 1,SF1->F1_DTDIGIT,SF2->F2_EMISSAO)
			
			dbSelectArea("SF4")
			dbSeek(xFilial()+SD1->D1_TES)
			dbSelectArea("SD1")
			
			While !Eof() .and. xFilial()==SD1->D1_FILIAL .And.SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA ==SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
				
				If SD1->D1_TIPO != "D"
					dbSkip()
					Loop
				Endif
				
				If IsRemito(1,"SD1->D1_TIPODOC")
					dbSkip()
					Loop
				Endif

				#IFDEF SHELL
					If SD1->D1_CANCEL == "S"
						SD1->(dbSkip())
						Loop
					Endif
				#ENDIF
				
				dbSelectArea("SF4")
				dbSeek(xFilial()+SD1->D1_TES)
				
				If AvalTes(SD1->D1_TES,cEstoq,cDupli) .and. cSerieOri+cNumOri == SD1->D1_SERIORI+SD1->D1_NFORI
					
					lAvalTes := .T.
					
					dbSelectArea(cNomArq)
					nTOTAL  +=xMoeda((SD1->D1_TOTAL-SD1->D1_VALDESC),SF1->F1_MOEDA,nMoeda,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA)
					If ( cPaisLoc=="BRA" )
						nVALICM += xMoeda(SD1->D1_VALICM,1,nMoeda,DtMoedaDev)
						nVALIPI += xMoeda(SD1->D1_VALIPI,1,nMoeda,DtMoedaDev)
					Else
						//��������������������������������������������������������������Ŀ
						//� Pesquiso pelas caracteristicas de cada imposto               �
						//����������������������������������������������������������������
						aImpostos:=TesImpInf(SD1->D1_TES)
						For nY:=1 to Len(aImpostos)
							cCampImp:="SD1->"+(aImpostos[nY][2])
							If ( aImpostos[nY][3]=="1" )
								nImpInc 	+= xmoeda(&cCampImp,SF1->F1_MOEDA,nMoeda,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA)
							Else
								nImpNoInc	+= xmoeda(&cCampImp,SF1->F1_MOEDA,nMoeda,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA)
							EndIf
						Next
					EndIf
					
				Endif
				
				dbSelectArea("SD1")
				dbSkip()
			EndDo
			
			dbSelectArea("SF1")
			nAdic := 0
			If lAvalTes 
				nAdic := xMoeda(SF1->F1_FRETE+SF1->F1_SEGURO+SF1->F1_DESPESA,SF1->F1_MOEDA,nMoeda,DtMoedaDev,nDecs+1,SF1->F1_TXMOEDA)
				nTOTAL += nAdic
			Endif
			
			If nTOTAL > 0
				dbSelectArea(cNomArq)
				If dbSeek(SF1->F1_FORNECE+SF1->F1_LOJA,.F.)
					RecLock(cNomArq,.F.)
				Else
					RecLock(cNomArq,.T.)
					Replace TB_CLI     With SF1->F1_FORNECE
					Replace TB_LOJA	 With SF1->F1_LOJA
				EndIf
				
				Replace TB_EST     With SA1->A1_EST
				Replace TB_EMISSAO With DtMoedaDev
				
				If lAvalTes .And. MV_PAR14 == 2			
					nTB_VALOR5 := nTOTAL
				Else
					nTB_VALOR5 := nTOTAL-nAdic
				EndIf
				
				If ( cPaisLoc=="BRA" )
					nTB_VALOR4 := nTOTAL-nVALICM-nAdic
					nTB_VALOR6 := nTOTAL+nVALIPI+xMoeda(SF1->F1_ICMSRET,1,nMoeda,DtMoedaDev)
				Else
					nTB_VALOR4 := nTOTAL-nImpInc
					nTB_VALOR6 := nTotal+nImpInc
				Endif
				
				Replace TB_VALOR4  With TB_VALOR4+nTB_VALOR4
				Replace TB_VALOR5  With TB_VALOR5+nTB_VALOR5
				Replace TB_VALOR6  With TB_VALOR6+nTB_VALOR6
				MsUnlock()
			EndIf
			
		Endif
		
	Next nX
	
endif

Return   

/*/
�����������������������������������������������������������������������������
���Funcao    � TotSImp� Autor � Marco Bianchi         � Data �30/08/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula valor total do item sem impostos.                  ���
�����������������������������������������������������������������������������/*/
Static Function TotSImp(cAlias1,cAlias2,cTes)    

//Local nImp := 0,nValImp:=0
Local lDescInc   
//Local nImposto   :=  0 
Local nAgrPisPas :=	0
Local nFretAut   :=  0
Local nPisCofST  :=	0
Local cNF_OPERNF
Local nIT_VALPS2 
Local nIT_VALCF2 
Local cNF_RECISS
Local nIT_VALICA
Local nIT_VALPS3
Local nIT_VALCF3
Local cIT_TIPONF
Local nIT_TOTAL
Local nIT_VALIPI
Local nIT_VALSOL
Local nIT_VALEMB
Local nIT_VNAGREG
Local nIT_VALMERC
Local nIT_DESCONTO
Local nIT_VALICM
Local nIT_DEDICM
Local nIT_BASEDUP
Local nIT_ICMSDIF
Local nIT_VALISS
Local nIT_VALIMP

Local aRef1 		:= {}
Local aRef2 		:= {}

//� Salva Area e preenche array com referencias fiscais          �
aArea := GetArea()
aRef1 := MaFisSXRef(cAlias1) 
aRef2 := MaFisSXRef(cAlias2)   

//� Carrega referencias do cabecalho                             �
dbSelectArea(cAlias1)
If cAlias1 == "SF2"
	cNF_RECISS := &(aRef1[(aScan(aRef1,{|x| x[2] == "NF_RECISS"}))][1])
	cNF_OPERNF := "S"
Else	
	cNF_OPERNF := "N"
    If !Empty(SA1->A1_RECISS)
		cNF_RECISS := SA1->A1_RECISS
	Else 
		cNF_RECISS := "2"	
	EndIf	
EndIF	

//� Carrega referencias dos itens                                �
dbSelectArea(cAlias2)
nIT_VALPS2 := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_VALPS2"}))][1])
nIT_VALCF2 := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_VALCF2"}))][1])
nIT_VALICA := 0
nIT_VALPS3 := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_VALPS3"}))][1])
nIT_VALCF3 := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_VALCF3"}))][1])
cIT_TIPONF := SD2->D2_TIPO
If cAlias2 == "SD2"
	nIT_TOTAL    := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_TOTAL"}))][1])
	nIT_DEDICM   := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_DEDICM"}))][1])	
	nIT_DESCONTO := 0
Else
	nIT_TOTAL    := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_VALMERC"}))][1])
	nIT_DEDICM   := 0
    nIT_DESCONTO := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_DESCONTO"}))][1])
EndIf
nIT_VALIPI  := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_VALIPI"}))][1])
nIT_VALSOL  := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_VALSOL"}))][1])
nIT_VALEMB  := 0
nIT_VNAGREG := 0
nIT_VALMERC := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_VALMERC"}))][1])
nIT_VALICM  := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_VALICM"}))][1])
nIT_BASEDUP := 0
nIT_ICMSDIF := 0        
nIT_VALISS  := &(aRef2[(aScan(aRef2,{|x| x[2] == "IT_VALISS"}))][1])
nIT_VALIMP  := 0
	
lDescInc   :=	(cPaisLoc<>"BRA".AND. cNF_OPERNF =="S".AND. SuperGetMV("MV_DESCSAI")=='1')
nAgrPisPas :=	If( SF4->F4_AGRPIS=="1" .AND. SF4->F4_PSCFST <> "1",nIT_VALPS2,0) + If( SF4->F4_AGRCOF=="1" .AND. SF4->F4_PSCFST <> "1",nIT_VALCF2,0)
nFretAut   := nIT_VALICA
If !SuperGetMV("MV_FRETAUT")
	nFretAut := 0
EndIf

//� Calcula valor sem impostos                                   �
// Pis/Cofins Substituicao Tributaria - sera somado ao total do documento
If SF4->F4_PSCFST == "1" .And. SF4->F4_APSCFST == "1"
	nPisCofST := nIT_VALPS3 + nIT_VALCF3
Else
	nPisCofST := 0
Endif

Do Case
Case cIT_TIPONF == "P"
		nIT_TOTAL	:= 	nIT_VALIPI+IIf(SF4->F4_INCSOL$"A,N,D",0,nIT_VALSOL)+;
		nIT_VALEMB+nFretAut+nAgrPisPas+nPisCofST
OtherWise
	Do Case
	Case SF4->F4_AGREG == "N"
		nIT_TOTAL	:= IIf(SF4->F4_IPI == 'R',0,nIT_VALIPI) + IIf(SF4->F4_INCSOL$"A,N,D",0,nIT_VALSOL)+;
		nIT_VALEMB+nAgrPisPas+nPisCofST
		nIT_VNAGREG := nIT_VALMERC-nIT_DESCONTO
	Case SF4->F4_AGREG == "I" .OR. SF4->F4_AGREG == "B"
		nIT_TOTAL	:= nIT_VALMERC - ;
			IIf(SF4->F4_IPI == 'R',0,nIT_VALIPI)- IIf(SF4->F4_INCSOL$"A,N,D".AND.SF4->F4_ICM<>"N",0,nIT_VALSOL) - IIf(lDescInc,0,nIT_DESCONTO)-;
			If(cIT_TIPONF <>"I",nIT_VALICM,0) - nIT_VALEMB-nFretAut-nAgrPisPas-nPisCofST
			nIT_VNAGREG := 0
	OtherWise
		nIT_TOTAL	:= nIT_VALMERC - ;
			IIf(SF4->F4_INCSOL$"A,N,D",0,nIT_VALSOL) - IIf(lDescInc,0,nIT_DESCONTO)-;
			nIT_VALEMB+nFretAut - nAgrPisPas - nPisCofST - IIf(SF4->F4_AGREG$"DR",nIT_DEDICM,0)
			nIT_VNAGREG := 0
	EndCase
EndCase

// ICMS Diferido Incentivo abate de gado - o valor diferido sera somado ao total da NF e a duplicata
If SF4->F4_PICMDIF<>0 .AND. SF4->F4_ICMSDIF=="4"
	nIT_TOTAL += nIT_ICMSDIF
EndIf                    

nIT_BASEDUP := 0
If SF4->F4_DUPLIC <>"N"
	nIT_BASEDUP := nIT_TOTAL
	If SuperGetMV("MV_DPAGREG") .AND. SF4->F4_AGREG == "N"
		nIT_BASEDUP += nIT_VALMERC
	EndIf
	If SF4->F4_AGREG=="F"
		nIT_BASEDUP -= nIT_VALMERC
	EndIf
	If cIT_TIPONF =='I'
		nIT_BASEDUP	-= nIT_VALICM
	EndIf
	If SF4->F4_PICMDIF <>0 .AND. SF4->F4_ICMSDIF$" ,1,2"
		nIT_BASEDUP	-= nIT_ICMSDIF
	EndIf
	If (cNF_RECISS == "1".AND. SuperGetMV("MV_DESCISS") .AND. cNF_OPERNF =="S".AND. SuperGetMV("MV_TPABISS")=="1")	
		nIT_BASEDUP	-= nIT_VALISS
	EndIf
	If SF4->F4_INCSOL=="D"
		nIT_BASEDUP	-= nIT_VALSOL
	EndIf	
	If SF4->F4_AGREG=="E"
		nIT_BASEDUP	-= nIT_DEDICM
	EndIf
EndIf
//� Verifica se a TES possui tratamento para Impostos Variaveis  �


dbSelectArea("SFC")		// Cabecalho da Nota de Saida
dbSetOrder(1)
If MsSeek(xFilial("SFC")+SF4->F4_CODIGO)
	While !Eof() .And. SFC->FC_TES == SF4->F4_CODIGO
		If SF4->F4_DUPLIC <> "N" .AND. cIT_TIPONF <>'B'
			Do Case
				Case SFC->FC_INCDUPL=="1"
					nValImp := nIT_VALIMP
				Case SFC->FC_INCDUPL=="2"
					nValImp:=- nIT_VALIMP
				Case SFC->FC_INCDUPL=="3"
					nValImp:=0
			EndCase
			nIT_BASEDUP += nValImp
		Endif

		Do Case
			Case SFC->FC_INCNOTA=="1"
				nValImp:= nIT_VALIMP
			Case SFC->FC_INCNOTA=="2"
				nValImp:=- nIT_VALIMP
			Case SFC->FC_INCNOTA=="3"
				nValImp:=0
		EndCase
		nIT_TOTAL -= nValImp
		("SFC")->(dbSkip())
	Enddo
EndIf

Return(nIT_TOTAL)




//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usu�rio utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que ser�o verificados.
    @param aFields, Array, Array com todos os Campos que ser�o verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource


//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com prote��o de dados.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta fun��o deve utilizada somente ap�s 
    a inicializa��o das variaveis atravez da fun��o FATPDLoad.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, L�gico, Retorna se o campo ser� ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun��o que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  

