/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ M030Inc  ³ Autor ³                       ³ Data ³ 18/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ponto de entrada na inclusao do cliente.                   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Solicit.  ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracoes³ 12/03/15 - Walter                                          ³±±
±±³          ³ Desabilitada funcao automica de geracao de amarracao de    ³±±
±±³          ³ ponto por setor.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³UpDate    ³ Elizabeth                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#INCLUDE "PROTHEUS.CH"


User Function M030Inc    
Local wArea := {}
Local aAreaSA1 := SA1->(GetArea())
Local aAreaCTD := CTD->(GetArea())
        
	/*
	If PARAMIXB == 3	
		//Alert( "Usuário cancelou inclusão!" )
	Else
		
		//Complementado por: Handerson L. Duarte  - 18/11/2013
		//Chama a Rotina de Contatos para que entre no fluxo de WorkFlow de Novo Cliente
		If !l030Auto// Não poderá ser executado quando utilizado Rotina Automática.
			DBSelectArea("AC8")
			AC8->(DBSetOrder(2))//AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON 
			ciEntidade	:=	PadR("SA1",TamSx3("AC8_ENTIDA")[1]," ") 
			ciFilEnt	:=	Space(TamSx3("AC8_FILENT")[1])                                                                                                          
			If !AC8->(DBSeek(xFilial("AC8")+ciEntidade+ciFilEnt+SA1->A1_COD+SA1->A1_LOJA)) .And.  Empty(SA1->A1_XIDWF)                                                                                                      
				FtContato( "SA1", SA1->(RecNo()), 4 )//Chamada da Rotina Padrão para Inclusão de Contatos.
				//WorkFlow para novo cliente
				MsgRun("Enviando Workflow...","",{|| CursorWait(), U_WFSA1001(SA1->A1_COD,SA1->A1_LOJA) ,CursorArrow()})
			EndIf
		EndIf
		//Fim da Complementação dos contatos
		 	
	EndIf	                               
	*/
	//if A1_TIPO == 'X' // emails para clientes do tipo exportação e importação.
	//	A1_EMAIL := 'Exportacao@grupoelizabeth.com.br'
	//	A1_HPAGE := 'Exportacao@grupoelizabeth.com.br'
	//EndIf

	If PARAMIXB <> 3
		DbSelectArea("CTD")                                	
		CTD->(DbSetOrder(1))
		
		If !(CTD->(DbSeek(xFilial("CTD")+"C"+SA1->A1_COD+SA1->A1_LOJA)))	                     
			RecLock("CTD",.T.)
			CTD->CTD_FILIAL	:= xFilial("CTD")
			CTD->CTD_ITEM  	:= "C"+SA1->A1_COD+SA1->A1_LOJA
			CTD->CTD_CLASSE	:= "2"
			CTD->CTD_DESC01	:= SA1->A1_NOME
			CTD->CTD_BLOQ	:= "2"
		   	CTD->CTD_DTEXIS := CTOD("01/01/1980")
		   	CTD->CTD_ITLP   := "C"+SA1->A1_COD+SA1->A1_LOJA
			CTD->(MsUnLock())	     
		EndIF
	Endif  

	If PARAMIXB == 1              
		//MSGINFO("Será aberto o cadastro de pontos por setor para continuação do cadastro do cliente!","CADASTRO DE CLIENTES")		

		//CalcCod()
		
		//RotIncPontoPSetor() //chama o cadastro de pontos por setor
		
	EndIf	

	
RestArea(aAreaSA1)                            
RestArea(aAreaCTD)

Return                  



Static Function RotIncPontoPSetor
Local nModAnt
Local cModAnt
Local wArea := {}
Local CSEQUENCIA := 0

wArea := getArea()

cModAnt := cmodulo
nModAnt := nmodulo

cmodulo := "OMS"
nmodulo := 39

//------------------------------------------------------------------------
// Alterado para gerar o DA7 (Pontos por Setor) automaticamente.
// OMSA090() // abre o cadastro de pontos por setor
// 

_aOldArea := GetArea()
_aOldCC2  := CC2->(GetArea())

dbSelectArea("CC2")
dbSetOrder(1)
dbSeek(xFilial("CC2")+SA1->A1_EST + SA1->A1_COD_MUN)

dbSelectArea("DA7")
dbSetOrder(1)
dbSeek(xFilial("DA7")+CC2->CC2_XZONA+CC2->CC2_XSETOR)
While !Eof() .And.  CC2->CC2_XZONA==DA7_PERCUR .And.CC2->CC2_XSETOR==DA7_ROTA 
	CSEQUENCIA := Val(DA7_SEQUEN)
	dbSkip()
End
CSEQUENCIA += 10

dbSelectArea("CC2")
If !Eof()
	dbSelectArea("DA7")
	RecLock("DA7",.T.)
	Replace DA7_FILIAL With xFilial("DA7")
	Replace DA7_PERCUR With CC2->CC2_XZONA
	Replace DA7_ROTA   With CC2->CC2_XSETOR
	Replace DA7_SEQUEN With STRZERO(CSEQUENCIA,6)
	Replace DA7_CLIENT With SA1->A1_COD
	Replace DA7_LOJA   With SA1->A1_LOJA
	MSUnlock()
Endif
	
RestArea(_aOldCC2)
RestArea(_aOldArea)
//-------------------------------------------------------------
	
cmodulo := cModAnt
nmodulo := nModAnt

RestArea(wArea)	

Return





Static Function CalcCod()
Local nSeq		:= 1 
Local wAreaSA1	:= {}
Local aCampo	:= { {"A1_COD","A1_CGC","A1_LOJA"} , {"A2_COD","A2_CGC","A2_LOJA"} }
Local cCampo
      
wAreaSA1 := getArea()

ROLLBACKSXE() //descarta qualquer numeração gerada pelo GetSxeNum

if Len( allTrim( cCNPJ )) = 14

	dbSelectArea("SA1")
	dbSetOrder(1)
		
	Set Filter To substr( SA1->A1_CGC ,1 , 8 ) = substr( cCNPJ ,1 , 8 ) //Filtra o CNPJ
	dbGoTop()
                                                  
	if Eof() .and. Bof() 
		M->A1_COD := GetSxeNum( aTabela[ nPrm ] , aCampo[ nPrm , 1 ] )
		ConfirmSx8()
		M->A1_LOJA := "01"
   	else                                                                 
		M->A1_COD := SA1->A1_COD
		
		dbGoBottom()
		M->A1_LOJA := StrZero(val( A1_LOJA ) + 1 ,4)  //Em caso de CNPJ, pega a partir da posicao 9 os 4 proximos dígitos
	endif                                     
		
else
	M->A1_COD := GetSxeNum( "SA1" , "A1_COD" ) //Em caso de pessoa física
	M->A1_LOJA := "01"
endif

RestArea( wAreaSA1 )

Return
