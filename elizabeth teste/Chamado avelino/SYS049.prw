         
#include "rwmake.ch"
#Include "Topconn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  SYS049     ºAutor  ³systop		 		 º Data ³  01/02/16  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RELACIONAR DATA DE ENTRADA NO CLIENTE COM NOTA DE SAIDA    º±±
±±º          ³  							                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Elizabeth Ceramica                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
    
¦¦+--------------+------------------------------------------+----------------------+----------------+¦¦
¦¦¦ Analista     ¦  SYSTOP			                        ¦ Data Alteracao 	   ¦ 12/04/2016 	 ¦¦
¦¦+--------------+------------------------------------------+----------------------+----------------+¦¦
¦¦¦ Alteração    ¦ INCLUIL TOTALIZADORES, ALTERADO REGRAS DE PREENCHIMENTOS DE CAMPOS MES E TRIMESTRE||
¦¦¦              |                                                           						 ||                                     
¦¦+--------------+-----------------------------------------------------------------------------------¦¦
¦¦+--------------+------------------------------------------+----------------------+----------------+¦¦
¦¦¦ Analista     ¦  SYSTOP			                        ¦ Data Alteracao 	   ¦ 18/04/2016 	 ¦¦
¦¦+--------------+------------------------------------------+----------------------+----------------+¦¦
¦¦¦ Alteração    ¦ INCLUIR FLITRO NAS NOTAS FISCAL DE ENTRADA QUANDO PARAMETRO MV_PAR09 = S 	     ||
¦¦¦              |                                                           						 ||                                     
¦¦+--------------+-----------------------------------------------------------------------------------¦¦
¦¦+--------------+------------------------------------------+----------------------+----------------+¦¦
¦¦¦ Analista     ¦  SYSTOP			                        ¦ Data Alteracao 	   ¦ 17/05/2016 	 ¦¦
¦¦+--------------+------------------------------------------+----------------------+----------------+¦¦
¦¦¦ Alteração    ¦ VALIDACAO DE DIGITACAO DE CAMPOS DE DATAS								 	     ||
¦¦¦              |                                                           						 ||                                     
¦¦+--------------+-----------------------------------------------------------------------------------¦¦
¦¦+--------------+------------------------------------------+----------------------+----------------+¦¦
¦¦¦ Analista     ¦  SYSTOP			                        ¦ Data Alteracao 	   ¦ 07/07/2016 	 ¦¦
¦¦+--------------+------------------------------------------+----------------------+----------------+¦¦
¦¦¦ Alteração    ¦ VALIDACAO DE DIGITACAO DE CAMPOS DE DATAS, INCLUSAO DE VALIDACAO EM BRANCO	     ||
¦¦¦              | SE BRANCO SISTEMA NAO VALIDA                               						 ||                                     
¦¦+--------------+-----------------------------------------------------------------------------------¦¦


*/                

 
 
User Function SYS049()
                       

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Declaração de cVariable dos componentes                                 ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Local nOpc := GD_UPDATE
Private aCoBrw1 := {}
Private aHoBrw1 := {}
Private noBrw1  := 0
cPerg:="SYS049"                       

                       
                               
ValidPerg()
If !Pergunte (cPerg,.T.)
	Return(.T.)
EndIf

//Processa({||  SYS049A() },"Processando dados...")
                                                                                                                                                                          
cBusca   := Space(12)               
nMEs     := 0
nTrimest := 0

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Declaração de Variaveis Private dos Objetos                             ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
SetPrvt("oDlg1","oBrw1","oSBtn1","oSBtn2","oBusca","oBtn1","oMes","oTrimest","oSBtn3")

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Definicao do Dialog e todos os seus componentes.                        ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
oDlg1      := MSDialog():New( 003,510,600,1316,"Notas fiscais de saida",,,.F.,,,,,,.T.,,,.T. )

oSay1      := TSay():New( 008,008,{||"Numero da nota:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,044,008)
oBusca     := TGet():New( 007,052,{|u| If(PCount()>0,cBusca:=u,cBusca)},oDlg1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cBusca",,)

oBtn1      := TButton():New( 006,127,"Pesquisar",oDlg1,{ || fBusca()   },037,012,,,,.T.,,"",,,,.F. )


MHoBrw1()
          
AddDados()                

MCoBrw1()           
                                                                                

oSay2    := TSay():New( 008,180,{||"Mes:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,044,008)
oMes     := TGet():New( 007,200,{|u| If(PCount()>0,nMEs:=u,nMEs)},oDlg1,060,008,"@E 999,999,999.99",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nMEs",,)

oSay3      := TSay():New( 008,270,{||"Trimestre:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,044,008)
oTrimest   := TGet():New( 007,300,{|u| If(PCount()>0,nTrimest:=u,nTrimest)},oDlg1,060,008,"@E 999,999,999.99",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nTrimest",,)

                                                     
oSBtn3     := SButton():New( 006,360,18,{|| fSoma() },oDlg1,,"", )                                              


oBrw1      := MsNewGetDados():New(024,008,250,400,nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',oDlg1,aHoBrw1,aCoBrw1 )
oSBtn1     := SButton():New( 260,348,1,{|| fGrava(),oDlg1:End() },oDlg1,,"", )
oSBtn2     := SButton():New( 260,308,2,{|| oDlg1:End() },oDlg1,,"", )

oDlg1:Activate(,,,.T.)

Return
                                                                                        
/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MHoBrw1() - Monta aHeader da MsNewGetDados para o Alias: SF2
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MHoBrw1()

	noBrw1 := 9
	aHoBrw1	:= {}                                                                         
	
	Aadd(aHoBrw1,{"Tipo"          ,"F2_TIPO"      ,"@!"  ,2,0,".F.","û","C","","" } )	
	Aadd(aHoBrw1,{"Nfiscal/Ser"    ,"F2_COD"      ,"@!"  ,12,0,".F.","û","C","","" } )
	Aadd(aHoBrw1,{"Emissao"    ,"F2_EMISSAO"  ,"@!"  ,08,0,".F.","û","C","","" } )
	Aadd(aHoBrw1,{"Cliente"    ,"F2_CLIENTE"  ,"@!"	 ,06,0,".F.","û","C","","" } )
	Aadd(aHoBrw1,{"Loja"   	   ,"F2_LOJA"     ,"@!"   ,04,0,".F.","û","C","","" } )
	Aadd(aHoBrw1,{"Nome"       ,"A1_NOME"     ,"@!"   ,09,2,".F.","û","C","","" } )
	Aadd(aHoBrw1,{"Valor"      ,"F2_VALBRUT"  ,"@E 999,999,999.99"    ,14,2,".F.","û","N","","" } )
                
	If MV_PAR11 = 1 // se replicar sim deixa habilidade campos                                                     
		
		Aadd(aHoBrw1,{"Mensal"     ,"F2_XBONMES"    ,"@!"   ,06,0,"U_VALIDAD(M->F2_XBONMES)","û","C","","" } )
		Aadd(aHoBrw1,{"Trimestral" ,"F2_XBONTRI"    ,"@!"   ,06,0,"U_VALIDAD(M->F2_XBONTRI)","û","C","","" } )
	
    Else 

	    If MV_PAR10 = 1 // MENSAL	
			Aadd(aHoBrw1,{"Mensal"     ,"F2_XBONMES"    ,"@!"   ,06,0,"U_VALIDAD(M->F2_XBONMES)","û","C","","" } )
			Aadd(aHoBrw1,{"Trimestral" ,"F2_XBONTRI"    ,"@!"   ,06,0,".F.","û","C","","" } )
		Else 
			Aadd(aHoBrw1,{"Mensal"     ,"F2_XBONMES"    ,"@!"   ,06,0,".F.","û","C","","" } )
			Aadd(aHoBrw1,{"Trimestral" ,"F2_XBONTRI"    ,"@!"   ,06,0,"U_VALIDAD(M->F2_XBONTRI)","û","C","","" } )
		EndIF

    EndIF

Return


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MCoBrw1() - Monta aCols da MsNewGetDados para o Alias: SF2

ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MCoBrw1()

Local aAux := {}                      
      
QRY->(DbGoTop())
                 

cTri:= ""
cMes:=""
While !QRY->(Eof())
	    
	
	
	If MV_PAR10 = 1  //mensal
		If !Empty(QRY->F2_XBONMES)
			cTri:= "      "
			cMes:= QRY->F2_XBONMES
		Else 
			cTri:= "      "
			cMes:= MV_PAR08		
		EndIF
	Else  //trimestral
		If !Empty(QRY->F2_XBONTRI)
			cTri:= QRY->F2_XBONTRI
			cMes:= QRY->F2_XBONMES
		Else 
			cTri:= MV_PAR08
			cMes:=QRY->F2_XBONMES		
		EndIF
	EndIF
	         

	IF MV_PAR11 = 1  // replica sim
	
		IF Left(QRY->F2_XBONMES,2) $ "01|02|03"
			cTri:= '01'+right(QRY->F2_XBONMES,4)
		ElseIF Left(QRY->F2_XBONMES,2) $ "04|05|06"
			cTri:= '02'+right(QRY->F2_XBONMES,4)	
		ElseIF Left(QRY->F2_XBONMES,2) $ "07|08|09"
			cTri:= '03'+right(QRY->F2_XBONMES,4)
		ElseIF Left(QRY->F2_XBONMES,2) $ "10|11|12"
			cTri:= '04'+right(QRY->F2_XBONMES,4)
		EndIF
		
	EndIF
	                         
                                                    
	IF MV_PAR11 == 1  // replica sim
		AADD(aCoBrw1,{QRY->TIPO,;
		QRY->F2_DOC+QRY->F2_SERIE,;
		dtoc(stod(QRY->F2_EMISSAO)) ,;
		QRY->F2_CLIENTE,;                                        
		QRY->F2_LOJA,;
		QRY->A1_NOME,;
		QRY->F2_VALBRUT,;
		cMes  ,;
		cTri  ,;
		.F.})          
	Else 
	
		AADD(aCoBrw1,{QRY->TIPO,;
		QRY->F2_DOC+QRY->F2_SERIE,;
		dtoc(stod(QRY->F2_EMISSAO)) ,;
		QRY->F2_CLIENTE,;                                        
		QRY->F2_LOJA,;
		QRY->A1_NOME,;
		QRY->F2_VALBRUT,;
		cMes  ,;
		cTri   ,;
		.F.})          	
	
	EndIF                              
	
	
	   If !Empty(QRY->F2_XBONMES)
         nMEs +=  QRY->F2_VALBRUT    
       ElseIf !Empty(QRY->F2_XBONTRI)
         nTrimest+=  QRY->F2_VALBRUT  
	   EndIF 
	   
	
     QRY->(DbSkip())
EndDo
                       
Return()                       
                       
********************************************************************************
Static Function AddDados()
********************************************************************************

cQuery := " SELECT 'S' AS TIPO ,F2_DOC,F2_SERIE,F2_EMISSAO, F2_CLIENTE, F2_LOJA, A1_NOME, F2_VALBRUT, F2_XBONMES, F2_XBONTRI " //F2_DTENTRA CRIAR CAMPO   
cQuery += " FROM "+RetSqlName("SF2")+" SF2 JOIN  "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = ' ' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA "
cQuery += " WHERE F2_FILIAL = '"+xFilial("SF2")+"'  "
cQuery += " AND F2_EMISSAO BETWEEN '"+DTOS(MV_PAR06)+"' AND '"+DTOS(MV_PAR07)+"'  "
cQuery += " AND F2_CLIENTE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
cQuery += " AND F2_LOJA BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "

If !Empty(MV_PAR05)
	cQuery += " AND A1_GRPVEN = '"+MV_PAR05+"' "	
EndIF
           
           
                                
If MV_PAR09 = 1
	
    If MV_PAR10 = 1 // MENSAL
		cQuery += " AND F2_XBONMES = '"+MV_PAR08+"' "
	Else 
		cQuery += " AND F2_XBONTRI = '"+MV_PAR08+"' "
	EndIF
	
EndIF
                   

cQuery += " AND SF2.D_E_L_E_T_ = ' '  "
cQuery += " AND SA1.D_E_L_E_T_ = ' '  "


cQuery += " UNION  "

cQuery += " SELECT 'D' AS TIPO,F1_DOC AS F2_DOC, F1_SERIE AS F2_SERIE, F1_EMISSAO AS F2_EMISSAO, F1_FORNECE AS F2_CLIENTE, F1_LOJA as F2_LOJA, A1_NOME, F1_VALBRUT AS F2_VALBRUT, F1_XBONMES AS F2_XBONMES, F1_XBONTRI AS F2_XBONTRI "
cQuery += " FROM "+RetSqlName("SF1")+" SF1 JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = ' ' AND A1_COD = F1_FORNECE AND A1_LOJA = F1_LOJA  "
cQuery += " WHERE F1_FILIAL =  '"+xFilial("SF2")+"'  "
cQuery += " AND F1_EMISSAO BETWEEN '"+DTOS(MV_PAR06)+"' AND '"+DTOS(MV_PAR07)+"'  " 
cQuery += " AND F1_FORNECE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
cQuery += " AND F1_LOJA BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
cQuery += " AND F1_TIPO = 'D' "

If !Empty(MV_PAR05)
	cQuery += " AND A1_GRPVEN = '"+MV_PAR05+"' "	
EndIF
                     

If MV_PAR09 = 1
	

    If MV_PAR10 = 1 // MENSAL
		cQuery += " AND F1_XBONMES = '"+MV_PAR08+"' "
	Else 
		cQuery += " AND F1_XBONTRI = '"+MV_PAR08+"' "
	EndIF

	
EndIF


                              
cQuery += " AND SF1.D_E_L_E_T_ = ' '  "
cQuery += " AND SA1.D_E_L_E_T_ = ' '  "


cQuery += " ORDER BY F2_DOC, F2_EMISSAO, F2_CLIENTE, F2_LOJA  "
                            




If Select("QRY") > 0
	dbSelectArea("QRY")
	dbCloseArea()
EndIf

TCQUERY cQuery NEW ALIAS "QRY"

                                                      
                             
Return() 
                                           
                                  
                                  
************************************************************************************
Static Function fGrava()
************************************************************************************

LOcal X := 1
SF2->(DbSetOrder(1))
SF1->(DbSetOrder(1))

                
For X := 1 To Len(oBrw1:aCols)
                          

   //	If !Empty(oBrw1:aCols[x][09]) .Or. !Empty(oBrw1:aCols[x][08])
	    If oBrw1:aCols[x][1]  == "S"
			SF2->(DbGoTop())
			If SF2->(DbSeek(xFilial("SF2")+oBrw1:aCols[x][2]))
			    
	            If MV_PAR11 = 1 // SE REPLICA                             
				
				    If MV_PAR10 = 1 // MENSAL
	    				RecLock("SF2",.F.)
							SF2->F2_XBONMES :=oBrw1:aCols[x][8]
							SF2->F2_XBONTRI :=oBrw1:aCols[x][9]
						MsUnLock("SF2")
					EndIF                        
				Else 
				
					If MV_PAR10 = 1 // MENSAL
	    				RecLock("SF2",.F.)
							SF2->F2_XBONMES :=oBrw1:aCols[x][8]
						MsUnLock("SF2")
					Else 
	    				RecLock("SF2",.F.)
							SF2->F2_XBONTRI :=oBrw1:aCols[x][9]
						MsUnLock("SF2")
					EndIF                        
					
				
				EndIF
											
				
			EndIf
		Else
			SF1->(DbGoTop())
			If SF1->(DbSeek(xFilial("SF1")+oBrw1:aCols[x][2]+oBrw1:aCols[x][4]+oBrw1:aCols[x][5]    ))


	            If MV_PAR11 = 1 // SE REPLICA                             

				    If MV_PAR10 = 1 // MENSAL
	    				RecLock("SF1",.F.)
							SF1->F1_XBONMES :=oBrw1:aCols[x][8]
							SF1->F1_XBONTRI :=oBrw1:aCols[x][9]
						MsUnLock("SF1")
					EndIF

				Else
				    If MV_PAR10 = 1 // MENSAL
	    				RecLock("SF1",.F.)
							SF1->F1_XBONMES :=oBrw1:aCols[x][8]
						MsUnLock("SF1")
					Else 
	    				RecLock("SF1",.F.)
							SF1->F1_XBONTRI :=oBrw1:aCols[x][9]
						MsUnLock("SF1")
					EndIF
				                
                endIf


			EndIf
		
		EndIF
		
	//EndIF	

Next 
   


Return()                                  
                       
                       /*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³VALIDPERG º Autor ³ Nelson Bispo       º Data ³  22/02/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Verifica a existencia das perguntas criando-as caso seja   º±±
±±º          ³ necessario (caso nao existam).                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Faz Santa Terezinha LTDA                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

SX1->(dbSelectArea("SX1"))
SX1->(dbSetOrder(1))
cPerg := PADR(cPerg,10)                      

aAdd(aRegs,{cPerg,"01","Cliente de ?       ","","","mv_ch1","C",6,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","",""})
aAdd(aRegs,{cPerg,"02","Cliente ate ?      ","","","mv_ch2","C",6,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","",""})
aAdd(aRegs,{cPerg,"03","Loja de ?          ","","","mv_ch3","C",4,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Loja ate ?         ","","","mv_ch4","C",4,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Grupo Vendas  ?    ","","","mv_ch5","C",6,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","ACY","","","",""})
aAdd(aRegs,{cPerg,"06","Emissao de  ?     ","","","mv_ch6","D",8,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Emissao Ate ?     ","","","mv_ch7","D",8,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","MM/AAAA Chegada ?    ","","","mv_ch8","C",6,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09","Filtra dt Chegada?   ","","","mv_ch9","N",1,0,0,"C","","MV_PAR09","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","","",""}) 
aAdd(aRegs,{cPerg,"10","Apuracao? 		  ","","","mv_cha","N",1,0,0,"C","","MV_PAR10","Mensal","","","","","Trimestral","","","","","","","","","","","","","","","","","","","","","","",""}) 
aAdd(aRegs,{cPerg,"11","Replicar Mes/Tri? 		  ","","","mv_chb","N",1,0,0,"C","","MV_PAR11","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","","",""}) 



For i:=1 to Len(aRegs)
	If SX1->(!dbSeek(cPerg+aRegs[i,2]))
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)


Return(.T.)               
                         
******************************************************************************************************
Static Function fBusca() 
******************************************************************************************************
nPOs:=0

nPos:=aScan(oBrw1:aCols,{|x| LEft(x[2],9) = Alltrim(cBusca) } ) 
n:= nPos
                  
If nPOs > 0
	oBrw1:OBROWSE:NAT := nPos
Else 
	Alert("Nota nao encontrado!")
EndIF
//oBrw1:OBROWSE:Refresh()
//oBrw1:oBrowse:Refresh()


Return()

*******************************************************************************************************
Static Function fSoma()
*******************************************************************************************************
 
Local X := 1       
nMEs:=0             
nTrimest:=0
        
For X := 1 To Len(oBrw1:aCols)


	If !Empty(oBrw1:aCols[x][8])
		nMEs += oBrw1:aCols[x][7]
    EndIF
	
	If !Empty(oBrw1:aCols[x][9])
		nTrimest+= oBrw1:aCols[x][7]
	EndIF
	
        
Next

Return()
         

***********************************************************************************************************
User Function VALIDAD(cDado)
***********************************************************************************************************
      
cMes :=""
cAnos:=""      
       
cMes:=Left(cDado,2) 
cAno:=left(Right(cDado,4),2 )
          
//DEIXA PASSAR EM BRANCO           
If Empty(cDado)
	Return(.t.)
EndIF     
     
     
IF !(cMes $ '01|02|03|04|05|06|07|08|09|10|11|12')
    Alert("Mes digitado incorreto, favor digitar mes valido.")
	Return(.F.)
EndIF
                                                              
If cAno <> "20"
    Alert("Ano digitado incorreto, favor digitar ano valido.")
	Return(.F.)	
EndIF                        



Return(.T.)