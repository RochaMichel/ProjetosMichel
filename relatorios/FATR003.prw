#INCLUDE "RWMAKE.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#include "topconn.ch"
//#include "Inkey.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO5     � Autor � Luciano J�nior      � Data �  09/01/14  ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o para Imprimir Pedidos N�o entregues.			      ���
���          � ANTES ATENDIDO PELO RELAT�RIO MATR680                      ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
/*/


/*


��+----------------------------------------------------------------------------------+��
���  ATUALIZACAO DE FONTES                                                           ���
��+--------------------+-------------+-----------------------------------------------+��
��� DATA               � CHAMADO     � USUARIO DO CHAMADO                            ���
��+--------------------+-------------+-----------------------------------------------+��
��� 01/12/2016 17:00   �             � NELSON BISPO - TI ELIZABETH                   ���
��+--------------------+-------------+-----------------------------------------------+��
��� AJUSTADO PARA GERACAO DE ARQUIVO EM EXCEL                                        ���
��+--------------------+-------------+-----------------------------------------------+��
��� 31/03/2017         �             �  ALESSANDRO MEDEIROS - TI ELIZABETH           ���
��+--------------------+-------------+-----------------------------------------------+��
��� ADICIONADO O FILTRO DE CLIENTE INICIAL AT� CLIENTE FINAL                         ���
��+--------------------+-------------+-----------------------------------------------+��
��� 17/10/2017         �             � NELSON BISPO - TI ELIZABETH                   ���
��+--------------------+-------------+-----------------------------------------------+��
��� REALIZADO AJUSTE PARA IMPRESSAO DE RELATORIO QUANDO O USUARIO FOR TELEVENDAS     ���
��+--------------------+-------------+-----------------------------------------------+��
���   /  /             �             �                                               ���
��+--------------------+-------------+-----------------------------------------------+��
���                                                                                  ���
��+--------------------+-------------+-----------------------------------------------+��


��+----------------------------------------------------------------------------------+��
���  HISTORICO DE ENVIO DE FONTES PARA ANALISTAS                                     ���
���  * USO EXCLUSIVO DO TI DO GRUPO ELIZABETH                                        ���
��+--------------------+-------------+-----------------------------------------------+��
��� DATA               � CHAMADO     � USUARIO DO CHAMADO                            ���
��+--------------------+-------------+-----------------------------------------------+��
��� 01/11/2016 09:27   � 13849       � LUCAS BORTOLIN - SYSTOP                       ���
���                    �             �                                               ���
���                    �             �                                               ���
���                    �             �                                               ���
��+--------------------+-------------+-----------------------------------------------+��   

��+----------------------------------------------------------------------------+��
���  HISTORICO DE COMPILACAO DE FONTES EM PRODUCAO                             ���
���  * USO EXCLUSIVO DO TI DO GRUPO ELIZABETH                                  ���
��+--------------+-------------+-----------------------------------------------+��
��� DATA         � CHAMADO     � USUARIO DO CHAMADO                            ���
��+--------------+-------------+-----------------------------------------------+��
���              �             �                                               ���
���              �             �                                               ���
���              �             �                                               ���
���              �             �                                               ���
��+--------------+-------------+-----------------------------------------------+��

*/
User Function FATR003

	//���������������������������������������������������������������������Ŀ
	//� Declaracao de Variaveis                                             �
	//�����������������������������������������������������������������������

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "RELAT�RIO DE PEDIDOS FATURADOS"
	Local cPict          := ""
	Local titulo       := "RELAT�RIO DE PEDIDOS FATURADOS"
	Local nLin         := 80
	//Local Cabec1     := "Cliente                      Municipio           CNPJ                UF   Ped.Repres     Emissao   Produto                            Qt.Pend.M2     TP   TN   BT   Vlr.Unit.   Prazo Pgto        Transp." 
	Local Cabec1       := "Cliente                                      UF   Data      Data      Nota Fiscal  Codigo          Produto                                       TP  TN    BT   Qtd.M2      Prc.Med.   Vlr.Liq.        Prazo" 
	//Cliente                                    UF    Emissao   Dt.Fat    Nota Fiscal    Ped.TOTVS    Produto                            TP  TN  BT  Qtd.M2    Prc.Med.     Vlr.Liq.  Prazo" 
	//12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//         10        20        30        40        50        60        70        80        90        100       110       120       130       140       150       160       170       180       190
	Local Cabec2       := "                                                  Entrada   Fatura                 Pedido                                                                                                                   "
	//Local Cabec2       := ""
	Local imprime      := .T.
	Local aOrd := {}
	Local cAux
	Local cUsuar 	:= RetCodUsr()
	Local xUsrT 	:= getMV("EL_TLVDUSR")
	Local xVenT 	:= getMV("EL_TLVDVEN")

	Static cPedido  := "" 
	Static cPedido2 := ""  
	Static cCliente := "" 
	Static cCliente2:= "" 
	Static dDataI	:= "" 
	Static dDataF	:= "" 
	Static cProduto := "" 
	Static cProduto2:= "" 

	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 80
	Private tamanho     := "G"
	Private nomeprog    := "FATR003" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "CARTEIRA PEDIDOS" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private aRecSel 	:= {}
	Private aRecExc		:= {}
	Private cString 	:= "SC5"
	Private cPerg 	 	:= "FATR003"

	CriaPerguntas(cPerg)

	If !Pergunte(cPerg,.T.)
		Return
	Endif

	//Pergunte(cPerg,.T.)

	//���������������������������������������������������������������������Ŀ
	//� Monta a interface padrao com o usuario...                           �
	//�����������������������������������������������������������������������

	//wnrel := SetPrint(cString,NomeProg,FILUSER(),@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)  

	If MV_PAR25 == 2
		wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

		If nLastKey == 27
			Return
		Endif
		SetDefault(aReturn,cString)
	endif
	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//���������������������������������������������������������������������Ŀ
	//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
	//�����������������������������������������������������������������������

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � AP6 IDE            � Data �  16/10/12   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal: FATR001                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	Local nX := 0
	Local nOrdem
	Local nCont, i
	Local cAlC5		:= ""
	Local nSaldo   	:= 0
	Local nTotVend	:=0
	Local nTotal	:=0
	Local nTotVl	:=0
	Local nTotVlG	:=0
	Local oMemo
	Local wArea
	Local _cTipoCli := "F"   
	Local cAux

	Local _aCarga := {}
	Local _aCabCrg := {}
	Local cArq
	Local nArq
	Local cPath
	Local cNomeAnt := ""
	Local cUsuar 	:= RetCodUsr()
	Local xUsrT 	:= getMV("EL_TLVDUSR")
	Local xVenT 	:= getMV("EL_TLVDVEN")


	dbSelectArea(cString)
	dbSetOrder(1)

	//Se Gerar em EXCEL
	If MV_PAR25==1   
		cArq  := CriaTrab(Nil, .F.)
		cPath := "C:\TEMP\"
		nArq  := FCreate(cPath + cArq + ".CSV")

		If nArq == -1
			MsgAlert("Nao conseguiu criar o arquivo!")
			Return Nil
		EndIf

		FWrite(nArq, "RELATORIO: ;FATURAMENTO REPRESENTANTE")  
		FWrite(nArq, Chr(13) + Chr(10))  
		FWrite(nArq, Chr(13) + Chr(10))  
		//FWrite(nArq,"NOTA FISCAL;PEDIDO;CARGA;CLIENTE;NOME DO CLIENTE;EMISSAO;VALOR;QUANTIDADE M2;TRANSPORTADORA;PLACA;MOTORISTA;REPRESENTANTE;PESO;MUNICIPIO;BAIRRO;ESTADO;E-MAIL REPRESENTANTE;OBS.NOTA FISCAL"+ Chr(13) + Chr(10))	  
		FWrite(nArq,"FILIAL;GERENTE;SUPERVISOR;VENDEDOR;TIPO COMERCIAL;CLIENTE;LOJA;NOME;CNPJ;UF;DDD;TEL;NOTA FISCAL;EMISSAO NF;COND.PAG.;DIMENSAO;PRODUTO;DESCRICAO;TIPO;TN;BT;QTD.M2;PRC.VEN;TOTAL;PESO;PEDIDO;EMISSAO PEDIDO;ORDEM COMPRA;TES"+ Chr(13) + Chr(10))	  

	EndIf	

	//���������������������������������������������������������������������Ŀ
	//� SETREGUA -> Indica quantos registros serao processados para a regua �
	//�����������������������������������������������������������������������

	SetRegua(RecCount())

	wArea	:= GetArea()

	If MV_PAR12=2
		_cTipoCli := 'F'
	EndIf        
	If MV_PAR12=3
		_cTipoCli := 'R'
	EndIf


	#IfDef TOP    // Base de dados SQL.

	If !empty(xUsrT)
		If cUsuar $ xUsrT
			MV_PAR07 := Alltrim(xVenT)
			MV_PAR08 := Alltrim(xVenT)
			//conout(cRet)
		EndIf
	EndIf


	* Retirado o distinct da query em 17/01/2020 por Bruno Santos - Chamado 54494
	//cQuery := " SELECT /*+ optimizer_features_enable('12.1.0.2') dynamic_sampling(4) */  DISTINCT F2_FILIAL,F2_DOC,F2_CLIENTE,F2_LOJA,F2_COND,F2_EMISSAO,C5_EMISSAO,F2_EST,F2_VEND1,D2_TOTAL, "
	cQuery := " SELECT /*+ optimizer_features_enable('12.1.0.2') dynamic_sampling(4) */DISTINCT  D2_TES,F2_FILIAL,F2_DOC,F2_CLIENTE,F2_LOJA,F2_COND,F2_EMISSAO,C5_EMISSAO,F2_EST,F2_VEND1,D2_TOTAL, "
	cQuery += " D2_COD,D2_QUANT,D2_PRCVEN,D2_PESO,D2_PEDIDO,B1_DESC,D2_XQUALIF,D2_XTONAL,D2_XBITOLA,SUBSTR(F2_FILIAL,1,2) FILIAL,E4_FILIAL,A1_NOME,C5_TIPOCLI,A1_CGC,E4_COND, "
	cQuery += " A1_DDD, A1_TEL,A1_XTEL2, "
	cQuery += " SA3.A3_NOME VENDEDOR, SA31.A3_NOME GERENTE, SA32.A3_NOME SUPERVISOR, A1_XTPCOM, SA3.A3_REGIAO, B1_XDIMEN, B1_XFAMILI "
	cQuery += " FROM "+RetSqlName("SA1")+" A, "+RetSqlName("SD2")+" D, "+RetSqlName("SB1")+" B, "+RetSqlName("SC5")+" C5, "+RetSqlName("SF4")+" F4, "+RetSqlName("SF2")+" F LEFT JOIN "+RetSqlName("SE4")+" E ON ( TRIM(E4_FILIAL)=SUBSTR(F2_FILIAL,1,2) AND E4_CODIGO=F2_COND AND E.D_E_L_E_T_=' ' ) " 
	cQuery += " LEFT JOIN "+RetSqlName("SA3")+" SA3  ON SA3.A3_FILIAL=F2_FILIAL AND SA3.A3_COD=F2_VEND1 AND  SA3.D_E_L_E_T_=' ' " 
	cQuery += " LEFT JOIN "+RetSqlName("SA3")+" SA31 ON SA31.A3_FILIAL=F2_FILIAL AND SA3.A3_GEREN=SA31.A3_COD AND  SA31.D_E_L_E_T_=' ' " 
	cQuery += " LEFT JOIN "+RetSqlName("SA3")+" SA32 ON SA32.A3_FILIAL=F2_FILIAL AND SA3.A3_SUPER=SA32.A3_COD AND  SA32.D_E_L_E_T_=' ' " 
	cQuery += " WHERE D2_FILIAL=F2_FILIAL AND D2_DOC=F2_DOC AND D2_SERIE=F2_SERIE AND B1_COD=D2_COD AND C5_FILIAL=D2_FILIAL AND C5_NUM=D2_PEDIDO " 
	cQuery += " AND F4_CODIGO = D2_TES AND trim(F4_FILIAL) = trim(F2_FILIAL)  "
	cQuery += " AND B.D_E_L_E_T_=' ' AND D.D_E_L_E_T_ = ' ' AND F.D_E_L_E_T_=' ' AND A.D_E_L_E_T_=' '  AND  F4.D_E_L_E_T_=' ' AND  C5.D_E_L_E_T_=' ' AND A1_LOJA=F2_LOJA  AND A1_COD=F2_CLIENTE "
	cQuery += " AND F2_FILIAL  BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'  AND F2_EMISSAO BETWEEN '" + DtoS(MV_PAR03) +"' AND '" + DtoS(MV_PAR04) + "' "
	cQuery += " AND F2_EST BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' AND F2_VEND1 BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "     
	cQuery += " AND D2_COD BETWEEN '"+MV_PAR13+"' AND '"+MV_PAR14+"'  "     
	cQuery += " AND F2_DOC BETWEEN '"+MV_PAR16+"' AND '"+MV_PAR17+"'  "     
	cQuery += " AND D2_PEDIDO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'  "
	cQuery += " AND A1_COD BETWEEN '"+MV_PAR28+"' AND '"+MV_PAR29+"'  "  


	If MV_PAR12<>1
		cQuery += " AND C5_TIPOCLI = '"+_cTipoCli+"' " 
	EndIF

	If !Empty(MV_PAR15)
		cQuery += " AND A1_CGC = '"+MV_PAR15+"' " 	
	EndIf

	IF MV_PAR11=2 
		cQuery += " AND D2_XQUALIF='A' "
	ENDIF
	IF MV_PAR11=3                                
		cQuery += " AND D2_XQUALIF='C' "
	ENDIF   

	If !Empty(MV_PAR18)
		cQuery += " AND SA3.A3_REGIAO = '"+MV_PAR18+"' " 
	EndIf

	If !Empty(MV_PAR20)
		cQuery += " AND SA3.A3_GEREN = '"+MV_PAR20+"' " 
	EndIf


	If !Empty(MV_PAR19)
		cQuery += " AND SA3.A3_SUPER = '"+MV_PAR19+"' " 
	EndIf


	If !Empty(MV_PAR21)
		cQuery += " AND B1_XDIMEN = '"+MV_PAR21+"' " 
	EndIf

	// Se gera financeiro
	If (mv_par22 == 1)
		cQuery += " AND F4_DUPLIC = 'S' "
	Else 
		If (mv_par22 == 2)
			cQuery += " AND F4_DUPLIC = 'N' "
		EndIf
	EndIf

	If !Empty(MV_PAR23)
		cQuery += " AND A1_XTPCOM = '"+MV_PAR23+"' " 
	EndIf

	If MV_PAR24 <> 3   
		If MV_PAR24 == 1
			cQuery += " AND B1_TIPO='01' AND B1_GRUPO IN('0104','0101') AND B1_XFAMILI = '001'  " 
		Else
			cQuery += " AND B1_TIPO='01' AND B1_GRUPO IN('0104','0101') AND B1_XFAMILI = '002' "  
		EndIf                                             

	EndIf


	If !Empty(MV_PAR26)
		cQuery += " AND D2_XBITOLA = '"+MV_PAR26+"' " 
	EndIf                                     

	If !Empty(MV_PAR27)
		cQuery += " AND D2_XTONAL = '"+MV_PAR27+"' " 
	EndIf  
	cQuery += "GROUP BY D.D2_TES, F.F2_FILIAL,F.F2_DOC ,F.F2_CLIENTE, F.F2_LOJA, F.F2_COND, F.F2_EMISSAO, C5.C5_EMISSAO, F.F2_EST,  F2_VEND1, D.D2_TOTAL, D.D2_COD, D.D2_QUANT,D.D2_PRCVEN, D.D2_PESO, D.D2_PEDIDO,B.B1_DESC, D.D2_XQUALIF, D.D2_XTONAL,"                                   
	cQuery += "D.D2_XBITOLA, E.E4_FILIAL, A.A1_NOME, C5.C5_TIPOCLI, A.A1_CGC, E.E4_COND, A.A1_DDD, A.A1_TEL, A.A1_XTEL2,  SA3.A3_NOME, SA31.A3_NOME, SA32.A3_NOME, A.A1_XTPCOM, SA3.A3_REGIAO, B.B1_XDIMEN, B.B1_XFAMILI"
	cQuery += "ORDER BY D2_COD, F2_VEND1,F2_CLIENTE,F2_EMISSAO,D2_COD "

	cQuery := ChangeQuery (cQuery)
	cAlC5 := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlC5,.F.,.T.)

	//conout(cQuery)

	DbSelectArea(cAlC5)
	(cAlC5)->(DbGoTop())
	While (cAlC5)->(!EOF())	
		AADD(aRecSel,{(cAlC5)->(Recno()),; 	//Posi��o 1
		(cAlC5)->F2_FILIAL,;		//Posi��o 2 - Filial
		(cAlC5)->F2_DOC,;           //Poci��o 3 - Num. Pedido 
		(cAlC5)->F2_CLIENTE,;		//Poci��o 4 -  Codigo cliente
		(cAlC5)->F2_LOJA,;			//Poci��o 5 -  Loja cliente
		(cAlC5)->F2_COND,;			//Poci��o 6 -  Condicao de pagamento
		(cAlC5)->F2_EMISSAO,;		//Poci��o 7 -  dt faturamento
		(cAlC5)->F2_EST,;			//Poci��o 8 -  Estado
		(cAlC5)->F2_VEND1,;			//Poci��o 9 -  Vendedor
		(cAlC5)->D2_COD,;			//Poci��o 10 - Codigo do Produto
		(cAlC5)->D2_QUANT,;			//Poci��o 11 - Quantidade
		(cAlC5)->D2_PRCVEN,;		//Poci��o 12 - preco de venda
		(cAlC5)->D2_PESO,;			//Poci��o 13 - Peso
		(cAlC5)->D2_PEDIDO,;		//Poci��o 14 - Pedido
		(cAlC5)->B1_DESC,;			//Poci��o 15 - Descricao produto
		(cAlC5)->D2_XQUALIF,;		//Poci��o 16 - Tipo
		(cAlC5)->D2_XTONAL,;		//Poci��o 17 - Tonalidade
		(cAlC5)->D2_XBITOLA,;		//Poci��o 18 - Bitola
		(cAlC5)->A1_NOME,;			//Poci��o 19 - Nome do Cliente
		(cAlC5)->C5_TIPOCLI,;		//Poci��o 20 - Tipo Cliente
		(cAlC5)->A1_CGC,;			//Poci��o 21 - CGC    
		(cAlC5)->C5_EMISSAO,;		//Poci��o 22 -  Emissao pedido
		Posicione("SA3",1,XFilial("SA3")+(cAlC5)->F2_VEND1,"A3_NOME"),;//23 - vendedor nome
		(cAlC5)->E4_COND,;		//Poci��o 24 -  Condi��o
		(cAlC5)->D2_TOTAL,;		//Poci��o 25 -  Total
		(cAlC5)->D2_TES,;		//Poci��o 26 -  TES
		})

		If MV_PAR25==1  


			FWrite(nArq, Chr(13) + Chr(10))   
			/*cLinha := " "+";"+";"+ ";."+QRYC->DB_PRODUTO+";"+Posicione("SB1",1,xFilial("SB1")+QRYC->DB_PRODUTO,"B1_DESC")+";"+;
			";"+";"+strtran(str(QRYC->DB_QUANT,15,2),".",",")+";"+QRYC->DB_LOCALIZ+";"+QRYC->DB_LOTECTL+";"+QRYC->DB_NUMLOTE+";"+QRYC->DB_LOCAL+";"+";"+";"+;
			";"+";"+";"+";"+SC6->C6_PEDCLI+";"
			*/
			cLinha := " "+(cAlC5)->F2_FILIAL+";"+(cAlC5)->GERENTE+";"+(cAlC5)->SUPERVISOR+";"+(cAlC5)->VENDEDOR+";"+POSICIONE("SX5",1,XFILIAL("SX5")+"CM"+(cAlC5)->A1_XTPCOM,"X5_DESCRI")+";"+;
			(cAlC5)->F2_CLIENTE+";"+(cAlC5)->F2_LOJA+";"+(cAlC5)->A1_NOME+";."+(cAlC5)->A1_CGC+";"+(cAlC5)->F2_EST+";"+(cAlC5)->A1_DDD+";"+(cAlC5)->A1_TEL+";"+(cAlC5)->F2_DOC+";"+substr((cAlC5)->F2_EMISSAO,7,2) +"/"+ substr((cAlC5)->F2_EMISSAO,5,2) +"/"+ substr((cAlC5)->F2_EMISSAO,3,2)+";"+;
			(cAlC5)->F2_COND+";"+POSICIONE("SX5",1,XFILIAL("SX5")+"Z3"+(cAlC5)->B1_XDIMEN,"X5_DESCRI")+";."+(cAlC5)->D2_COD+";"+(cAlC5)->B1_DESC+";"+(cAlC5)->D2_XQUALIF+";"+(cAlC5)->D2_XTONAL+";"+;
			(cAlC5)->D2_XBITOLA+";"+strtran(STR((cAlC5)->D2_QUANT),".",",")+";"+strtran(STR((cAlC5)->D2_PRCVEN),".",",")+";"+strtran(STR((cAlC5)->D2_TOTAL),".",",")+";"+strtran(STR((cAlC5)->D2_PESO),".",",")+";"+(cAlC5)->D2_PEDIDO+";"+;		//Poci��o 14 - Pedido
			substr((cAlC5)->C5_EMISSAO,7,2) +"/"+ substr((cAlC5)->C5_EMISSAO,5,2) +"/"+ substr((cAlC5)->C5_EMISSAO,3,2)+";"+;
			POSICIONE("SC6",1,(cAlC5)->F2_FILIAL+(cAlC5)->D2_PEDIDO,"C6_PEDCLI")+";"+(cAlC5)->D2_TES

			//conout(cLinha)
			FWrite(nArq, cLinha)

			//QRYC->(dbSkip())
			/*AADD(aRecExc,{(cAlC5)->F2_FILIAL,; 	//Posi��o 1
			(cAlC5)->GERENTE,;          
			(cAlC5)->SUPERVISOR,;
			(cAlC5)->VENDEDOR,; 
			POSICIONE("SX5",1,XFILIAL("SX5")+"CM"+(cAlC5)->A1_XTPCOM,"X5_DESCRI"),;
			(cAlC5)->F2_CLIENTE,;		//Poci��o 4 -  Codigo cliente
			(cAlC5)->F2_LOJA,;			//Poci��o 5 -  Loja cliente
			(cAlC5)->A1_NOME,;          // 
			"."+(cAlC5)->A1_CGC,;                                                                      
			(cAlC5)->F2_EST,;			//Poci��o 8 -  Estado
			(cAlC5)->A1_DDD,;
			(cAlC5)->A1_TEL,;
			(cAlC5)->A1_XTEL2,;			
			(cAlC5)->F2_DOC,;           //Poci��o 3 - Num. Pedido
			substr((cAlC5)->F2_EMISSAO,7,2) +"/"+ substr((cAlC5)->F2_EMISSAO,5,2) +"/"+ substr((cAlC5)->F2_EMISSAO,3,2),;
			(cAlC5)->F2_COND,;			//Poci��o 6 -  Condicao de pagamento
			POSICIONE("SX5",1,XFILIAL("SX5")+"Z3"+(cAlC5)->B1_XDIMEN,"X5_DESCRI"),;
			"."+(cAlC5)->D2_COD,;
			(cAlC5)->B1_DESC,;			//Poci��o 15 - Descricao produto
			(cAlC5)->D2_XQUALIF,;		//Poci��o 16 - Tipo
			(cAlC5)->D2_XTONAL,;		//Poci��o 17 - Tonalidade
			(cAlC5)->D2_XBITOLA,;		//Poci��o 18 - Bitola
			(cAlC5)->D2_QUANT,;			//Poci��o 11 - Quantidade
			(cAlC5)->D2_PRCVEN,;		//Poci��o 12 - preco de venda 
			(cAlC5)->D2_TOTAL,;		     //Poci��o 25 -  Total
			(cAlC5)->D2_PESO,;			//Poci��o 13 - Peso
			(cAlC5)->D2_PEDIDO,;		//Poci��o 14 - Pedido
			substr((cAlC5)->C5_EMISSAO,7,2) +"/"+ substr((cAlC5)->C5_EMISSAO,5,2) +"/"+ substr((cAlC5)->C5_EMISSAO,3,2),;
			POSICIONE("SC6",1,(cAlC5)->F2_FILIAL+(cAlC5)->D2_PEDIDO,"C6_PEDCLI"),;
			})*/
		EndIf		





		//���������������������������������������������������������������������Ŀ
		//� Verifica o cancelamento pelo usuario...                             �
		//�����������������������������������������������������������������������

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		dbSkip() // Avanca o ponteiro do registro no arquivo
	EndDo		
	(cAlC5)->(DbCloseArea()) 

	//Se Gerar em EXCEL
	If MV_PAR25==1           

		/*If !ApOleClient("MSExcel")
		MsgAlert("Microsoft Excel n�o instalado!")
		Return Nil
		EndIf

		aCabec := {"FILIAL","GERENTE","SUPERVISOR","VENDEDOR","TIPO COMERCIAL","CLIENTE","LOJA","NOME CLIENTE","CNPJ","UF","DDD","TEL 1","TEL 2","NOTA FISCAL","EMISS�O ","PRAZO", ;
		"DIMENS�O","PRODUTO","DESCRICAO","TIPO","TONALIDADE","BITOLA","QUANT","PRE�O VENDA","TOTAL","PESO","PEDIDO","EMISS�O","ORDEM DE COMPRA"}  
		DlgToExcel({ {"ARRAY","FATURAMENTO REPRESENTANTE", aCabec, aRecExc} })
		Return*/


		FClose(nArq)
		// Abre o Excel.                                                                                                                  
		//C:\Program Files (x86)\LibreOffice 5\program
		If file("c:\Program Files (x86)\LibreOffice 4\program\scalc.exe") .or. file("c:\Program Files\LibreOffice 4\program\scalc.exe")
			winexec("c:\Program Files (x86)\LibreOffice 4\program\scalc.exe "+ cPath +cArq + ".CSV")
			winexec("c:\Program Files\LibreOffice 4\program\scalc.exe "+ cPath +cArq + ".CSV")
		Else
			If file("c:\Program Files (x86)\LibreOffice 5\program\scalc.exe") .or. file("c:\Program Files\LibreOffice 5\program\scalc.exe")
				winexec("C:\Program Files (x86)\LibreOffice 5\program\scalc.exe "+ cPath +cArq + ".CSV")
				winexec("c:\Program Files\LibreOffice 5\program\scalc.exe "+ cPath +cArq + ".CSV")
			Else
				oExcel := MSExcel():New()
				oExcel:WorkBooks:Open(cPath + cArq + ".CSV")
				oExcel:SetVisible(.T.)
				oExcel:Destroy()    
			EndIf
		EndIf  

	EndIf






	//���������������������������������������������������������������������Ŀ
	//� Impressao do cabecalho do relatorio. . .                            �
	//�����������������������������������������������������������������������

	If nLin > 65 // Salto de P�gina. Neste caso o formulario tem 65 linhas...
		Cabec(Titulo,cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 7
	Endif		

	nLin  += 1       
	if len(aRecSel)>0             
		if !empty(aRecSel[1][9]) 
			@nLin,00 	PSAY "Vendedor: " + aRecSel[1][9]		//cod vendedor
			@nLin,18 	PSAY Substring(aRecSel[1][23],1,35)		//nome vendedor
		else                                        
			@nLin,00	PSAY "Vendedor: "
			@nLin,18	PSAY "REPRESENTANTE FABRICA"
		endif
		nLin  += 2                                             

		cAux 	:= aRecSel[1][9] //usado para controle de quebra
		cEmiss	:= StoD(aRecSel[1][7])            
	endif

	nTotVl		:= 0
	nTotVlG		:= 0

	IF Len(aRecSel) > 0	
		For nX := 1 to Len(aRecSel)
			If cAux = aRecSel[nX][9]   // Agrupamento e subtotal por vendedor
				@nLin,00 	PSAY aRecSel[nX][4]		//cod cliente
				@nLin,08 	PSAY Substring(aRecSel[nX][19],1,30)		//nome cliente
				@nLin,45 	PSAY aRecSel[nX][8]		//uf                                                                               
				@nLin,50 	PSAY substr(aRecSel[nX][22],7,2) +"/"+ substr(aRecSel[nX][22],5,2) +"/"+ substr(aRecSel[nX][22],3,2)//emissao 
				@nLin,60 	PSAY substr(aRecSel[nX][7],7,2) +"/"+ substr(aRecSel[nX][7],5,2) +"/"+ substr(aRecSel[nX][7],3,2)//emissao 
				//@nLin,50 	PSAY substr(aRecSel[nX][7],7,2) +"/"+ substr(aRecSel[nX][7],5,2) +"/"+ substr(aRecSel[nX][7],3,2)//emissao 
				//@nLin,60 	PSAY substr(aRecSel[nX][22],7,2) +"/"+ substr(aRecSel[nX][22],5,2) +"/"+ substr(aRecSel[nX][22],3,2)//emissao 
				@nLin,70 	PSAY aRecSel[nX][3]		//nota
				@nLin,82 	PSAY aRecSel[nX][14]		//pedido
				@nLin,100 	PSAY Substring(aRecSel[nX][15],1,30)		//descricao produto
				@nLin,145 	PSAY aRecSel[nX][16]		//tipo
				@nLin,150 	PSAY aRecSel[nX][17]		//tonalidade
				@nLin,155 	PSAY aRecSel[nX][18]		//bitola
				@nLin,160 	PSAY str(aRecSel[nX][11],8,2) //saldo m2
				@nLin,175 	PSAY str(aRecSel[nX][12],5,2) //preco medio
				@nLin,185 	PSAY str(aRecSel[nX][25],8,2) //valor liquido
				@nLin,200 	PSAY aRecSel[nX][24] //condicao de pagamento

				//@nLin,159 	PSAY str(aRecSel[nX][20],8,2)	//valor  

				nLin  += 1                              

				nTotVend	+= aRecSel[nX][11]
				nTotal 		+= aRecSel[nX][11]
				nTotVl		+= aRecSel[nX][25] 
				nTotVlG		+= aRecSel[nX][25]
			Else
				nLin  += 1
				@nLin,00 	PSAY "Total do Vendedor ->"
				@nLin,25 	PSAY cAux
				@nLin,152 	PSAY "M2" + TransForm(nTotVend,"@ze 999,999,999.99")
				@nLin,177 	PSAY "R$" + TransForm(nTotVl,"@ze 999,999,999.99") 

				nTotVend := aRecSel[nX][11]
				nTotal 	+= aRecSel[nX][11]
				nTotVl		:= aRecSel[nX][25] 
				nTotVlG		+= aRecSel[nX][25]

				cAux := aRecSel[nX][9]
				nLin  += 1
				@nLin,00 	PSAY Replicate("_",220)
				nLin  += 1

				if !empty(aRecSel[nX][9])
					@nLin,00 	PSAY "Vendedor: " + aRecSel[nX][9]		//cod vendedor
					@nLin,18 	PSAY Substring(aRecSel[nX][23],1,35)		//nome vendedor
				else                                        
					@nLin,00	PSAY "Vendedor: "
					@nLin,18	PSAY "REPRESENTANTE FABRICA"
				endif
				nLin  += 2                                             

				////////repeti os itens 
				@nLin,00 	PSAY aRecSel[nX][4]		//cod cliente
				@nLin,08 	PSAY Substring(aRecSel[nX][19],1,30)		//nome cliente
				@nLin,45 	PSAY aRecSel[nX][8]		//uf
				@nLin,50 	PSAY substr(aRecSel[nX][22],7,2) +"/"+ substr(aRecSel[nX][22],5,2) +"/"+ substr(aRecSel[nX][22],3,2)//emissao 
				@nLin,60 	PSAY substr(aRecSel[nX][7],7,2) +"/"+ substr(aRecSel[nX][7],5,2) +"/"+ substr(aRecSel[nX][7],3,2)//emissao 				
				//@nLin,50 	PSAY substr(aRecSel[nX][7],7,2) +"/"+ substr(aRecSel[nX][7],5,2) +"/"+ substr(aRecSel[nX][7],3,2)//emissao 
				//@nLin,60 	PSAY substr(aRecSel[nX][22],7,2) +"/"+ substr(aRecSel[nX][22],5,2) +"/"+ substr(aRecSel[nX][22],3,2)//emissao 
				@nLin,70 	PSAY aRecSel[nX][3]		//nota
				@nLin,82 	PSAY aRecSel[nX][14]		//pedido
				@nLin,100 	PSAY Substring(aRecSel[nX][15],1,30)		//descricao produto
				@nLin,145 	PSAY aRecSel[nX][16]		//tipo
				@nLin,150 	PSAY aRecSel[nX][17]		//tonalidade
				@nLin,155 	PSAY aRecSel[nX][18]		//bitola
				@nLin,160 	PSAY str(aRecSel[nX][11],8,2) //saldo m2
				@nLin,175 	PSAY str(aRecSel[nX][12],5,2) //preco medio
				@nLin,185 	PSAY str(aRecSel[nX][11],8,2) //valor liquido
				@nLin,200 	PSAY aRecSel[nX][24] //condicao de pagamento

				nLin  += 1                                                  


			EndIf

			If nLin > 65 // Salto de P�gina.
				Cabec(Titulo,cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 7
				nLin  += 1
			Endif		

		NEXT nX
	ENDIF

	nLin  += 1
	@nLin,00 	PSAY "Total do Vendedor ->"
	@nLin,25 	PSAY cAux
	@nLin,152 	PSAY "M2" + TransForm(nTotVend,"@ze 999,999,999.99") 
	@nLin,177 	PSAY "R$" + TransForm(nTotVl,"@ze 999,999,999.99") 
	nLin  += 1
	@nLin,00 	PSAY Replicate("_",220)

	nLin  += 1
	@nLin,00 	PSAY "Total Geral:"
	@nLin,152 	PSAY "M2" + TransForm(nTotal,"@ze 999,999,999,999.99")
	@nLin,177 	PSAY "R$" + TransForm(nTotVlg,"@ze 999,999,999,999.99") 


	#EndIf
	RestArea(wArea)

	//���������������������������������������������������������������������Ŀ
	//� Finaliza a execucao do relatorio...                                 �
	//�����������������������������������������������������������������������

	SET DEVICE TO SCREEN

	//aRecSel := {}

	//���������������������������������������������������������������������Ŀ
	//� Se impressao em disco, chama o gerenciador de impressao...          �
	//�����������������������������������������������������������������������

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

/*
�������������������������������������������������������������������������͹��
���Desc.     � FUN��O PARA CRIA��O DOS PAR�METROS DO USU�RIO              ���
�������������������������������������������������������������������������͹��
*/
Static Function CriaPerguntas(_grupo)

	Local _sAlias  := Alias()
	Local _cPerg	:= PADR(_grupo, 10)
	Local aRegs    := {}
	Local i,j
	dbSelectArea("SX1")
	dbSetOrder(1)

	AADD(aRegs,{_cPerg,"01","Filial de      :"   ,"","","mv_ch1" ,"C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SM0","",""})
	AADD(aRegs,{_cPerg,"02","Filial ate     :"   ,"","","mv_ch2" ,"C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SM0","",""})
	AADD(aRegs,{_cPerg,"03","Emissao de     :"   ,"","","mv_ch3" ,"D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","" 	 ,"",""})
	AADD(aRegs,{_cPerg,"04","Emissao ate    :"   ,"","","mv_ch4" ,"D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","" 	 ,"",""})
	AADD(aRegs,{_cPerg,"05","Pedido De      :"   ,"","","mv_ch5" ,"C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SC5","",""})
	AADD(aRegs,{_cPerg,"06","Pedido Ate     :"   ,"","","mv_ch6" ,"C",06,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SC5","",""})
	AADD(aRegs,{_cPerg,"07","Represent. De  :"   ,"","","mv_ch7" ,"C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SA3","",""})
	AADD(aRegs,{_cPerg,"08","Represent. Ate :"   ,"","","mv_ch8" ,"C",06,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SA3","",""})
	AADD(aRegs,{_cPerg,"09","UF De  		:"   ,"","","mv_ch9" ,"C",02,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","" 	 ,"",""})
	AADD(aRegs,{_cPerg,"10","UF Ate 		:"   ,"","","mv_ch10","C",02,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","" 	 ,"",""})
	AADD(aRegs,{_cPerg,"11","Tipo           :"   ,"","","mv_ch11","C",01,0,0,"C","","mv_par11","Tipo A"  ,"","","","","Tipo C" ,"","","","","Ambos","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{_cPerg,"12","Tipo de Cliente:"   ,"","","mv_ch12","C",01,0,0,"C","","mv_par12","T-Todos"  ,"","","","","F-Cons. Final","","","","","R-Revendedor","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{_cPerg,"13","Produto De     :"   ,"","","mv_ch13","C",15,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","SB1","",""})
	AADD(aRegs,{_cPerg,"14","Produto Ate    :"   ,"","","mv_ch14","C",15,0,0,"G","","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","SB1","",""})
	AADD(aRegs,{_cPerg,"15","CNPJ           :"   ,"","","mv_ch15","C",15,0,0,"G","","mv_par15","","","","","","","","","","","","","","","","","","","","","","","","","CNPJ","",""})
	AADD(aRegs,{_cPerg,"16","Nota De		:"   ,"","","mv_ch16","C",09,0,0,"G","","mv_par16",""  ,"","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{_cPerg,"17","Nota Ate		:"	 ,"","","mv_ch17","C",09,0,0,"G","","mv_par17",""  ,"","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{_cPerg,"18","Regiao		    :"   ,"","","mv_ch18","C",03,0,0,"C","","mv_par18","","","","","","","","","","","","","","","","","","","","","","","","","X1","",""})
	AADD(aRegs,{_cPerg,"19","Supervisor  	:"   ,"","","mv_ch19","C",06,0,0,"G","","mv_par19","","","","","","","","","","","","","","","","","","","","","","","","","SA3","",""})
	AADD(aRegs,{_cPerg,"20","Gerente		:"   ,"","","mv_ch20","C",03,0,0,"G","","mv_par20","","","","","","","","","","","","","","","","","","","","","","","","","SA3","",""})
	AADD(aRegs,{_cPerg,"21","Dimensao		:"   ,"","","mv_ch21","C",06,0,0,"G","","mv_par21","","","","","","","","","","","","","","","","","","","","","","","","","Z3","",""})
	AADD(aRegs,{_cPerg,"22","Gera Financeiro:"   ,"","","mv_ch22","C",01,0,0,"C","","mv_par22","Sim"  ,"","","","","Nao","","","","","Ambos","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{_cPerg,"23","Tipo Comercial :"   ,"","","mv_ch23","C",01,0,0,"C","","mv_par23","","","","","","","","","","","","","","","","","","","","","","","","","CM","",""})
	AADD(aRegs,{_cPerg,"24","Familia        :"   ,"","","mv_ch24","C",01,0,0,"C","","mv_par24","001-Normal"  ,"","","","","002-HD","","","","","003-Ambos","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{_cPerg,"25","Gerar Excel    :"   ,"","","mv_ch25","C",01,0,0,"C","","mv_par25","Sim"  ,"","","","","Nao","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{_cPerg,"26","Bitola			:"   ,"","","mv_ch26","C",01,0,0,"G","","mv_par26","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{_cPerg,"27","Tonalidade		:"   ,"","","mv_ch27","C",04,0,0,"G","","mv_par27","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{_cPerg,"28","Cliente De  	:"   ,"","","mv_ch28","C",06,0,0,"G","","mv_par28","","","","","","","","","","","","","","","","","","","","","","","","","SA1","",""})
	AADD(aRegs,{_cPerg,"29","Cliente Ate 	:"   ,"","","mv_ch29","C",06,0,0,"G","","mv_par29","","","","","","","","","","","","","","","","","","","","","","","","","SA1","",""})

	For i := 1 to Len(aRegs)
		If !DbSeek(_cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	DbSelectArea(_sAlias)          

Return
