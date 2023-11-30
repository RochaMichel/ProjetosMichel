#include "rwmake.ch"
#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ FA740BRW	³ Autor ³ SYSTOP			    ³ Data ³ 09/09/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ ADICAO DE ROTINA NO FUNCAO A RECEBER                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ 								                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

---------------------------------------------------------------------------- 
-- DATA: 28/09/2015 -- ANALISTA: NELSON BISPO DE LACERDA OLIVEIRA
----------------------------------------------------------------------------
-- OBS: ADICIONADO A FUNCAO SOLICITAR LIBERACAO PARA ATENDER NECESSIDADES
-- DO SETOR FINANCEIRO
----------------------------------------------------------------------------

---------------------------------------------------------------------------- 
-- DATA: 06/10/2015 -- ANALISTA: NELSON BISPO DE LACERDA OLIVEIRA
----------------------------------------------------------------------------
-- OBS: ADICIONADO A FUNCOES:
-- 1. BOLETO BNB
-- 2. LIBERAR RA
-- 3. IDENTIFICAR DEPOSITO
----------------------------------------------------------------------------


-- DATA: 06/10/2015 -- ANALISTA: SYSTOP
----------------------------------------------------------------------------
-- OBS: ADICIONADO A FUNCOES:
-- 1. BOLETO SAFRA

----------------------------------------------------------------------------
/*/                            


User Function FA740BRW()          
	Local aopcPrinc := {}                    
	Local aOpcoes   := {	{"Visualiza", "U_FA740Hist(1)", 0, 2},; 
	{"Atualizar", "U_FA740His(2)", 0, 2} }  
	Local aBotao := {}
	AAdd(aBotao, { "Boleto BNB" ,"U_BLTBNB()"  , 0 , 3 })  
	aAdd(aBotao, {'Boleto Bradesco',"U_BOLBRD",   0 , 3 })
	aAdd(aBotao, {'Boleto BB ',"U_BOLBB",   0 , 3 })
	aAdd(aBotao, {'Boleto Safra ',"U_BOLSAF",   0 , 3    })
	aAdd(aBotao, {'Solicitar Aprovacao',"U_ELLIBSE1",   0 , 3 })
	AAdd(aBotao, { "LIBERAR RA" ,"U_XLIBRA()"  , 0 , 3 })    
	AAdd(aBotao, { "Identificar Deposito" ,"U_GeraIdent()"  , 0 , 3 })
	AAdd(aBotao, { "Boleto Itau","U_BOLITAU()"  , 0 , 3 })
	AAdd(aBotao, { "Boleto Sicoob","U_BOLSICOO()"  , 0 , 3 }) 
	AAdd(aBotao, { "Boleto Santander","U_FINF142()"  , 0 , 3 })
	AAdd(aBotao, { "Boleto Avante","U_BOLAVT()"  , 0 , 3 })
	AAdd(aBotao, { "Boleto Sofisa","U_BOLSOF()"  , 0 , 3 })
	aAdd( aOpcPrinc,{ "Historico",aOpcoes, 0 , 3}) 

Return(aBotao)


User Function FA740His(nVis_Atu)  

	Private oHistDlg                        
	Private cGet5a   := Iif(nVis_atu=1,SE1->E1_XHSTCOB,"")                                     

	l740Edit := Iif(nVIs_Atu=1,.f.,.t.)

	If l740Edit
		DEFINE MSDIALOG oHistDlg TITLE "Atualizacao Titulo - Cobrança" From 4,0 To 350,700 PIXEL 
		oHistSay5      := TSay():New( 005,005,{||"Atualizando"},oHistDlg,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,055,008)
		oHistGet5      := TMultiget():New(003,040,{|u| If(PCount()>0,cGet5a:=u,cGet5a)},oHistDlg,270,120,,,,,,l740Edit,,,,,,)

		@ 150,140 BUTTON "Confirmar"  SIZE 050,010 PIXEL OF oHistDlg ACTION GrvHistSE1()
		@ 150,200 BUTTON "Cancelar"   SIZE 050,010 PIXEL OF oHistDlg ACTION oHistDlg:End()
	Else
		DEFINE MSDIALOG oHistDlg TITLE "Historico Titulo - Cobrança" From 4,0 To 350,700 PIXEL 
		oHistSay5      := TSay():New( 005,005,{||"Historico"},oHistDlg,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,055,008)
		oHistGet5      := TMultiget():New(001,005,{|u| If(PCount()>0,cGet5a:=u,cGet5a)},oHistDlg,270,120,,,,,,.t.,,,,,,.t.)
		oHistGet5:EnablevScroll(.t.)

		@ 150,160 BUTTON "Sair"   SIZE 050,010 PIXEL OF oHistDlg ACTION oHistDlg:End()
	Endif                          
	ACTIVATE MSDIALOG oHistDlg CENTERED// VALID VldMt110()

Return(Nil)

Static Function GrvHistSE1()

	oHistGet5:Refresh() 
	oHistDlg:End()
	If l740Edit
		RecLock("SE1",.f.)
		SE1->E1_XHSTCOB := Alltrim(SE1->E1_XHSTCOB)+" "+Alltrim(cGet5a)                                                      
		SE1->(MsUnLock())
	Endif   
Return(.t.)
