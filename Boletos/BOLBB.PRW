#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH" 
//#INCLUDE "PRTODEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BOL001    ºAutor  ³Andre Pessoa        º Data ³  01/0 7/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP    .                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±ad±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function BOLBB()

LOCAL   aCampos := {{"E1_NOMCLI"		,"Cliente"	,"@!"} ,;
					{"E1_PREFIXO"		,"Prefixo"	,"@!"},;
					{"E1_NUM"			,"Titulo"	,"@!"},;
					{"E1_PARCELA"		,"Parcela"	,"@!"},;
					{"E1_SALDO"			,"Saldo"	,"@E 9,999,999.99"},;
					{"E1_VENCTO"		,"Vencimento"}}
LOCAL   nOpc 		:= 0
LOCAL   aMarked 	:= {}
LOCAL   aDesc 		:= {"Este programa imprime os boletos de","cobranca bancaria de acordo com","os parametros informados"}
PRIVATE Exec    	:= .F.
PRIVATE cIndexName 	:= ''
PRIVATE cIndexKey  	:= ''
PRIVATE cFilter    	:= ''

Tamanho  := "M"
titulo   := "Impressao de boleto bancário"
cDesc1   := "Este programa destina-se a impressao do boleto bancário."
cDesc2   := ""
cDesc3   := ""
cString  := "SE1"
wnrel    := "BOL001"
lEnd     := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private padrao de todos os relatorios         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
nLastKey := 0

dbSelectArea("SE1")

cPerg     :="BOL001"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ValidPerg()

Pergunte ("BOL001",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Wnrel := SetPrint(cString,Wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,)

If nLastKey == 27
	Set Filter to
	Return
Endif                                    

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
	Return
Endif

nOpc := 1

If nOpc == 1
	cIndexName := GetNextAlias() 
	cIndexKey   := 	"E1_PORTADO+E1_CLIENTE+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+DTOS(E1_EMISSAO)"
	cFilter    	  := 	"E1_PREFIXO >= '" + MV_PAR01 + "' .And. E1_PREFIXO <= '" + MV_PAR02 + "' .And. " + ;
	"E1_NUM     >= '" + MV_PAR03 + "' .And. E1_NUM     <= '" + MV_PAR04 + "' .And. " + ;
	"E1_PARCELA >= '" + MV_PAR05 + "' .And. E1_PARCELA <= '" + MV_PAR06 + "' .And. " + ;
	"E1_NUMBOR = '" + MV_PAR07 + "' .AND. LEFT(E1_FILIAL,3) = '" + LEFT(cFilAnt,3) + "'"
	
	// .And. E1_NUMBOR <= '" + MV_PAR08 + "' "
	//	"E1_PORTADO = '001' .And. " + ;
	
	
	
	IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")
	
	DbSelectArea("SE1")
	#IFNDEF TOP
		DbSetIndex(cIndexName + OrdBagExt())
	#ENDIF
	dbGoTop()
	
	@ 001,001 TO 400,700 DIALOG oDlg TITLE "Selecao de Titulos"
	@ 001,001 TO 170,350 BROWSE "SE1" MARK "E1_OK"
	@ 180,310 BMPBUTTON TYPE 01 ACTION (Exec := .T.,Close(oDlg))
	@ 180,280 BMPBUTTON TYPE 02 ACTION (Exec := .F.,Close(oDlg))
	ACTIVATE DIALOG oDlg CENTERED
	
	
	If Exec == .F.
		RetIndex("SE1")
		fErase(cIndexName+OrdBagExt())
		
		Return()
	EndIf
	
	
	dbGoTop()
	Do While !Eof()
		If Marked("E1_OK")
			AADD(aMarked,.T.)
		Else
			AADD(aMarked,.F.)
		EndIf
		dbSkip()
	EndDo
	dbGoTop()
	If Exec
		Processa({|lEnd|MontaRel(aMarked)})
	Endif
	RetIndex("SE1")
	fErase(cIndexName+OrdBagExt())
	
EndIf
Return Nil


static  Function MontaRel(aMarked)
LOCAL oPrint
LOCAL n := 0
//LOCAL aBitmap      := {MV_PAR19,"\logos\CCN.bmp"}  //Logo da empresa

LOCAL aDadosEmp    := {SubStr( AllTrim(SM0->M0_NOMECOM), 1, Len(AllTrim(SM0->M0_NOMECOM))-6) ,; //[1]Nome da Empresa
SM0->M0_ENDCOB                                                            					 ,; //[2]Endereço
AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB 					 ,; //[3]Complemento
"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             					 ,; //[4]CEP
"PABX/FAX: "+SM0->M0_TEL                                                  					 ,; //[5]Telefones
"C.N.P.J.: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+          					  ; //[6]
Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       					  ; //[6]
Subs(SM0->M0_CGC,13,2)                                                    					 ,; //[6]CGC
"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            					  ; //[7]
Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                        					  } //[7]I.E

LOCAL aDadosTit
LOCAL aDadosBanco
LOCAL aDatSacado
LOCAL aDatAvalist
LOCAL aBolText
//LOCAL aBMP      := aBitMap
LOCAL i         := 1
LOCAL CB_RN_NN  := {}
LOCAL nRec      := 0
LOCAL _nTotEnc  := 0
Local nVlAtraso := 0
Local cEndc     := " "
Local cMunic    := " "
Local cBairc    := " "
Local cEstc     := " "
Local cCepc     := " "
Local lPedido   := .T.
Private cNroDoc := "0000000"

oPrint:= TMSPrinter():New( "Boleto Laser" )
oPrint:Setup()
oPrint:SetPortrait() // ou SetLandscape()
oPrint:StartPage()   // Inicia uma nova página
dbGoTop()
Do While !EOF()
	nRec := nRec + 1
	dbSkip()
EndDo
dbGoTop()
ProcRegua(nRec)
cDescBan := '' //Descrição do banco
cDigB    := '' //Digito do banco
Do While !SE1->(EOF())
	
	If !empty(alltrim(SE1->E1_PEDIDO))
		dbSelectArea("SC5")
		dbsetorder(dbNickOrder("SC5","SC5AAA"))   //FILIAL+NMOPORT
		dbSeek(SE1->E1_FILIAL+SE1->E1_NMOPOR)  //Buscar pelo codigo da oportunidade.
		
		//Posiciona o SA1 (Cliente)
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial()+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.T.)
	else
		
		//Posiciona o SA1 (Cliente)
		DbSelectArea("SA1")
		DbSetOrder(1)
		if !empty(alltrim(SE1->E1_CLCNAB))
			DbSeek(xFilial()+SE1->E1_CLCNAB+SE1->E1_LJCNAB,.T.) //(sacado)
		else
			DbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
		endif
	endif
	
	cEndc  := SA1->A1_END
	cMunic := SA1->A1_MUN
	cBairc := SA1->A1_BAIRRO
	cEstc  := SA1->A1_EST
	cCepc  := SA1->A1_CEP
	
	DbSelectArea("SE1")
	
	If aMarked[i]
		DbSelectArea("SEE")
		DbSetOrder(1)
		DbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.)
		If Empty(SE1->E1_NUMBCO)
			
			While SEE->( !RecLock('SEE',.F.) )
			   LjMsgRun('BOLBB - Aguardando Liberação do Nosso Número')
			EndDo
			    
			If SE1->E1_PORTADO == "033"  
				//Posiciona na Arq de Parametros CNAB
				cNroDoc := StrZero(Val(Alltrim(SEE->EE_FAXATU))+1,7)
			ElseIf SE1->E1_PORTADO='637'
                cNroDoc := StrZero(Val(Alltrim(SEE->EE_FAXATU))+1,12)
			ElseIf SE1->E1_PORTADO == "104"
				//Posiciona na Arq de Parametros CNAB
				cNroDoc := '000'+StrZero(Val(Alltrim(SEE->EE_FAXATU))+1,12)
			ElseIf SE1->E1_PORTADO == "237" .OR. SE1->E1_PORTADO == "998"
				//Posiciona na Arq de Parametros CNAB
				cNroDoc := StrZero(Val(Alltrim(SEE->EE_FAXATU))+1,11)
			ElseIf SE1->E1_PORTADO == "707"
				//Posiciona na Arq de Parametros CNAB
				cNroDoc := StrZero(Val(Alltrim(SEE->EE_FAXATU))+1,10)
			ElseIf SE1->E1_PORTADO == "246"
				//Posiciona na Arq de Parametros CNAB
				cNroDoc := StrZero(Val(Alltrim(SEE->EE_FAXATU))+1,10)
			else
				//Posiciona na Arq de Parametros CNAB
				cNroDoc := StrZero(Val(Alltrim(SEE->EE_FAXATU))+1,10)
			endif
			
			RecLock("SEE",.F.)
			SEE->EE_FAXATU :=	RIGHT(cNroDoc,12)
			MsUnlock()      
			
			RecLock("SE1",.F.)
			SE1->E1_NUMBCO :=	RIGHT(cNroDoc,15)
			MsUnlock()
		Else
			if  SE1->E1_PORTADO == "033" 
				cNroDoc := strzero(val(SE1->E1_NUMBCO),7)
		    ElseIf SE1->E1_PORTADO == "637"
				cNroDoc := strzero(val(SE1->E1_NUMBCO),12)
		    ElseIf SE1->E1_PORTADO == "104"
				//Posiciona na Arq de Parametros CNAB
				cNroDoc := strzero(val(SE1->E1_NUMBCO),15)
			ElseIf SE1->E1_PORTADO == "237" .OR. SE1->E1_PORTADO == "998"
				//Posiciona na Arq de Parametros CNAB
				cNroDoc := strzero(val(SE1->E1_NUMBCO),11)
			ElseIf SE1->E1_PORTADO == "707"
				//Posiciona na Arq de Parametros CNAB
				cNroDoc := strzero(val(SE1->E1_NUMBCO),10)
			ElseIf SE1->E1_PORTADO == "246"
				//Posiciona na Arq de Parametros CNAB
				cNroDoc := strzero(val(SE1->E1_NUMBCO),10)
			else
				cNroDoc := strzero(val(SE1->E1_NUMBCO),10)
			endif
		Endif
		cConvenio := Alltrim(SEE->EE_CODEMP)
	Endif                                       
   	  
	//Posiciona o SA6 (Bancos)
	DbSelectArea("SA6")
	DbSetOrder(1)
	DbSeek(xFilial("SA6")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.)
	
	cCarteira := '17'
	If SA6->A6_COD == '001'
		cDescBan := "BANCO DO BRASIL S/A"
		cDigB    := '-9'
	ElseIf SA6->A6_COD == '422'
		cDescBan := "BANCO SAFRA S/A"
		cDigB    := '-7'
	ElseIf SA6->A6_COD == '707' .AND. ;
	    (LEFT(cFilant ,3) = '002' .OR. LEFT(cFilant ,3) = '006' .OR. LEFT(cFilant ,3) = '008' .OR. LEFT(cFilant ,3) = '007') // BANCO DAYCOVAL UTILIZANDO OS SERVICOS DO DAYCOVAL.
		cDescBan := "BANCO DAYCOVAL"
		cDigB    := '-9'
		cCarteira := '121'
//	ElseIf SA6->A6_COD == '707' .AND. LEFT(cFilant ,3) = '006'  // BANCO DAYCOVAL UTILIZANDO OS SERVICOS DO DAYCOVAL.
//		cDescBan := "BANCO DAYCOVAL"
//		cDigB    := '-9'
//		cCarteira := '121'
	ElseIf SA6->A6_COD == '707'  								// BANCO DAYCOVAL UTILIZANDO OS SERVICOS DO BRADESCO.
		cDescBan := "BANCO BRADESCO"
		cDigB    := '-7'
		cCarteira := '19'
//		If cFilant $ "#006SP001#006RS002#010CE001#010TO002#011MA001#011PA002#012PI001#013CE001#014MA001#007GO001#008PR001#009RJ001#014TO002"	//incluido em 30/01/2017 por Geraldo para tratar empresas do grupo CEMAPAPITO.
		If cFilant $ "#006SP001#006RS002#007GO001#008PR001#009RJ001#009SP002#010CE001#010TO002#011MA001#011PA002#012PI001#013CE001#013CE003#013PI002#013PI004#014MA001#014TO002#014PA003014MA004#"
			cCarteira := '09'
		EndIf
	ElseIf SA6->A6_COD == '237'  .and. (cFilant $ "#002PE001#") // Factory RENDMAX FIDC MULTISSETORIAL   // Factory RENDMAX FIDC MULTISSETORIAL
		cDescBan := SA6->A6_NOME
		cDigB    := '-9'
		cCarteira := '09'
	ElseIf SA6->A6_COD == '237'  .OR. SA6->A6_COD == '998'
		cDescBan := "BANCO BRADESCO"
		cDigB    := '-2'
		cCarteira := '09'
	elseif SA6->A6_COD == '033'
		cDescBan  := 'Santander'
		cDigB     := '-7'
		cCarteira := '101'
	elseif SA6->A6_COD == '637'  //Banco Sofisa 21-09-2020
		cDescBan  := 'Santander' //'BANCO SOFISA S/A'
		cDigB     := '-7'
		cCarteira := '101'
	elseif SA6->A6_COD == '004'
		cDescBan  := 'Banco do Nordeste'
		cDigB     := '-3'
		cCarteira := '21'
	elseif SA6->A6_COD == '104'
//		cDescBan  := 'Caixa Econômica Federal'
		cDescBan  := 'CAIXA'
		cDigB     := '-0'
		cCarteira := '1'
	elseif SA6->A6_COD == '246'
		cDescBan  := 'BANCO ABC BRASIL'
		cDigB     := '-1'
		cCarteira := '110'
	ElseIf SA6->A6_COD == '237'  .and. (substring(cFilant,1,3) $ "#016") // RONDOTYRES
		cDescBan := SA6->A6_NOME
		cDigB    := '-2'
		cCarteira := '09'
	Endif
	
	//cDescBan := SA6->A6_NOME //NOME DO BANCO
	
	DbSelectArea("SE1")
	
	_COD 		:= SA6->A6_COD
	_Agencia 	:= Alltrim(SA6->A6_AGENCIA)
	_NumCon  	:= Alltrim(SA6->A6_NUMCON)
	_DVCTA   	:= Alltrim(SA6->A6_DVCTA)
	_DVAGE   	:= Alltrim(SA6->A6_DVAGE)
	_cOpera     := '' // Apenas Daycoval como não correspondente
    _TemLimB    := SA6->A6_TEMLIMB	
    
	If 	_TemLimB == 'S'    .AND. SA6->A6_COD == '707' .AND. LEFT(cFilant ,3) = '002'     // BANCO DAYCOVAL UTILIZANDO OS SERVICOS DO DAYCOVAL SEM SER CORRESPONDENTE.
//		_COD 		:= SA6->A6_COD
//		_Agencia 	:= Alltrim(SA6->A6_AGENCIA)
//		_NumCon  	:= Alltrim(SA6->A6_NUMCON)
//		_DVCTA   	:= Alltrim(SA6->A6_DVCTA)
//		_DVAGE   	:= Alltrim(SA6->A6_DVAGE)
		_cOpera     := "1416966"
    ElseIf _TemLimB == 'S' .AND. SA6->A6_COD == '707' .AND. LEFT(cFilant ,3) = '006'  // BANCO DAYCOVAL UTILIZANDO OS SERVICOS DO DAYCOVAL SEM SER CORRESPONDENTE.
//		_COD 		:= SA6->A6_COD
//		_Agencia 	:= Alltrim(SA6->A6_AGENCIA)
//		_NumCon  	:= Alltrim(SA6->A6_NUMCON)
//		_DVCTA   	:= Alltrim(SA6->A6_DVCTA)
//		_DVAGE   	:= Alltrim(SA6->A6_DVAGE)
		_cOpera     := "1422418"		
    ElseIf _TemLimB == 'S' .AND. SA6->A6_COD == '707' .AND. LEFT(cFilant ,3) = '007'  // BANCO DAYCOVAL UTILIZANDO OS SERVICOS DO DAYCOVAL SEM SER CORRESPONDENTE.
//		_COD 		:= SA6->A6_COD
//		_Agencia 	:= Alltrim(SA6->A6_AGENCIA)
//		_NumCon  	:= Alltrim(SA6->A6_NUMCON)
//		_DVCTA   	:= Alltrim(SA6->A6_DVCTA)
//		_DVAGE   	:= Alltrim(SA6->A6_DVAGE)
		_cOpera     := ""	
    ElseIf _TemLimB == 'S' .AND. SA6->A6_COD == '707' .AND. LEFT(cFilant ,3) = '008'  // BANCO DAYCOVAL UTILIZANDO OS SERVICOS DO DAYCOVAL SEM SER CORRESPONDENTE.
//		_COD 		:= SA6->A6_COD
//		_Agencia 	:= Alltrim(SA6->A6_AGENCIA)
//		_NumCon  	:= Alltrim(SA6->A6_NUMCON)
//		_DVCTA   	:= Alltrim(SA6->A6_DVCTA)
//		_DVAGE   	:= Alltrim(SA6->A6_DVAGE)
		_cOpera     := "1434345"		
	elseif SA6->A6_COD == '246' .AND. LEFT(cFilant ,3) = '002'    // Banco ABC para as Distribuidoras (Empresa 002)
        _cOpera  := "5023437"	
	elseif SA6->A6_COD == '246' .AND. LEFT(cFilant ,3) = '006'    // Banco ABC para as Distribuidoras (Empresa 006)
        _cOpera  := "5023444"	
	elseif SA6->A6_COD == '246' .AND. LEFT(cFilant ,3) = '008'    // Banco ABC para as Distribuidoras (Empresa 008)
        _cOpera  := "5023443"	
	ElseIf SA6->A6_COD == '707' .and. (cFilant $ "#001CE002#001PB004#001PE001#001SC003#")
		_COD     := '237'     //Daycoval disse que tinha q ser o codigo do bradesco!!!
		_Agencia := '2374'
		_DVAGE   := '4'
		_NumCon  := '63221'
		_DVCTA   := '0'
	elseif SA6->A6_COD == '707' .and. (cFilant $ "#010CE001#010TO002#")                   	//INCLUIDO PARA TRATAR AS EMPESAS DO GRUPO CEMAPAPITO	25/01/2017
		_COD     := '237'     //Daycoval disse que tinha q ser o codigo do bradesco!!!
		_Agencia := '2374'
		_NumCon  := '01359'
		_DVCTA   := '5'
		_DVAGE   := '4'
	elseif SA6->A6_COD == '707' .and. (cFilant $ "#011MA001#011PA002#")						//INCLUIDO PARA TRATAR AS EMPESAS DO GRUPO CEMAPAPITO	25/01/2017
		_COD     := '237'     //Daycoval disse que tinha q ser o codigo do bradesco!!!
		_Agencia := '2374'
		_NumCon  := '01606'
		_DVCTA   := '3'
		_DVAGE   := '4'
	elseif SA6->A6_COD == '707' .and. (cFilant $ "#012PI001#")								//INCLUIDO PARA TRATAR AS EMPESAS DO GRUPO CEMAPAPITO   25/01/2017
		_COD     := '237'     //Daycoval disse que tinha q ser o codigo do bradesco!!!
		_Agencia := '2374'
		_NumCon  := '01604'
		_DVCTA   := '7'
		_DVAGE   := '4'
	elseif SA6->A6_COD == '707' .and. (cFilant $ "#013CE001#013PI002#013PI004#")								//INCLUIDO PARA TRATAR AS EMPESAS DO GRUPO CEMAPAPITO   25/01/2017
		_COD     := '237'     //Daycoval disse que tinha q ser o codigo do bradesco!!!
		_Agencia := '2374'
		_NumCon  := '03565'
		_DVCTA   := '3'
		_DVAGE   := '4'
	elseif SA6->A6_COD == '707' .and. (cFilant $ "#014MA001#014TO002#014PA003#014MA004#")								//INCLUIDO PARA TRATAR AS EMPESAS DO GRUPO CEMAPAPITO   25/01/2017
		_COD     := '237'     //Daycoval disse que tinha q ser o codigo do bradesco!!!
		_Agencia := '2374'
		_NumCon  := '03546'
		_DVCTA   := '7'
		_DVAGE   := '4'
	elseif SA6->A6_COD == '707' .and. (cFilant $ "#006SP001#006RS002#")								//INCLUIDO PARA TRATAR AS EMPESAS DO GRUPO CEMAPAPITO   25/01/2017
		_COD     := '237'     //Daycoval disse que tinha q ser o codigo do bradesco!!!
		_Agencia := '2374'
		_NumCon  := '03693'
		_DVCTA   := '5'
		_DVAGE   := '4'
	elseif 	SA6->A6_COD == '707' .and. LEFT(cFilant ,3) = '007'
	    cCarteira := '09'
		_COD     := '237'     //Daycoval disse que tinha q ser o codigo do bradesco!!!
		_Agencia := '2374'
		_NumCon  := '3829'
		_DVCTA   := '6'
		_DVAGE   := '4'
	elseif 	SA6->A6_COD == '707' .and. LEFT(cFilant ,3) = '008'
	    cCarteira := '09'
		_COD     := '237'     //Daycoval disse que tinha q ser o codigo do bradesco!!!
		_Agencia := '2374'
		_NumCon  := '3845'
		_DVCTA   := '8'
		_DVAGE   := '4'
	elseif 	SA6->A6_COD == '707' .and. LEFT(cFilant ,3) = '009'
		cCarteira := '09'
		_COD     := '237'     //Daycoval disse que tinha q ser o codigo do bradesco!!!
		_Agencia := '2374'
		_NumCon  := '4005'
		_DVCTA   := '3'
		_DVAGE   := '4' 
	elseif SA6->A6_COD == '707' //.and. !(cFilant $ "#001CE002#001PB004#001PE001#001SC003#")
		_COD     := '237'     //Daycoval disse que tinha q ser o codigo do bradesco!!!
		_Agencia := '2374'
		_NumCon  := '00421'
		_DVCTA   := '9'
		_DVAGE   := '4'
	elseif SA6->A6_COD == '004' .and. (cFilant $ "#001CE002#001PB004#001PE001#001SC003#002PE001#002PB015#") // BNB disse que conta vinculada deveria ser 570-0
		//		_NumCon  := '000570'  Comentado por Sarto em 09/08/17
		_Agencia := '0271'
		_NumCon  := '0000570'
		_DVCTA   := '0'
	elseif SA6->A6_COD == '104' // CAIXA disse que conta vinculada deveria ser 570-0
		cCarteira := '1'
	elseif SA6->A6_COD == '237' .and. (cFilant $ "#002PE001#") // Factory RENDMAX FIDC MULTISSETORIAL
		_COD     := '237'     
		_Agencia := '0682'
		_NumCon  := '21576'
		_DVCTA   := '7'
		_DVAGE   := '3'
	elseif SA6->A6_COD == '998'
		_COD     := '237'     
		_Agencia := Alltrim(SA6->A6_AGENCIA)
		_NumCon  := "0069000"
		_DVCTA   := Alltrim(SA6->A6_DVCTA)
		_DVAGE   := Alltrim(SA6->A6_DVAGE)
	endif
	
	aDadosBanco  := {_COD+cDigB                     ,; // [1]Numero do Banco
	cDescBan										,;
	_Agencia 								   		,; // [3]Agência
	_NumCon    				                 		,; // [4]Conta Corrente
	_DVCTA                                  		,; // [5]Dígito da conta corrente
	cCarteira                          	   			,; // [6]Codigo da Carteira
	_DVAGE							        		,; // [7]Digito da Agência
	SA6->A6_COD										}  // [8] Codigo do banco no ERP
	
	aDatSacado   := {AllTrim(SA1->A1_NOME)          ,; // [1]Razão Social
	AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA           ,; // [2]Código
	Alltrim(cEndc) + " - " + Alltrim(cBairc)        ,; // [3]Endereço
	AllTrim(cMunic)                                 ,; // [4]Cidade
	cEstc                                           ,; // [5]Estado
	Transform(cCepc,"@R 99.999-999")                ,; // [6]CEP
	SA1->A1_CGC                       		        } // [7]CGC
	
	//Posiciona o SA1 (Avalista)
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
	
	aDatAvalist  := {AllTrim(SA1->A1_NOME)   ,; // [1]Razão Social
	AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA    ,; // [2]Código
	Alltrim(cEndc) + " - " + Alltrim(cBairc) ,; // [3]Endereço
	AllTrim(cMunic)                          ,; // [4]Cidade
	cEstc                                    ,; // [5]Estado
	Transform(cCepc,"@R 99.999-999")         ,; // [6]CEP
	SA1->A1_CGC                       		}   // [7]CGC
	
	_nTotEnc :=    0
	
	DbSelectArea("SE1")
	
	
	nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	If     subs(aDadosBanco[1],1,3)=="001"
		CB_RN_NN    := Ret_cBar001(Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],;
		aDadosBanco[5],aDadosBanco[6],cNroDoc,(SE1->E1_SALDO - SE1->E1_DECRESC + SE1->E1_ACRESC/*-nVlrAbat*/),cConvenio )
	elseif subs(aDadosBanco[1],1,3)=="237"   // O banco daycoval utiliza os servicos do bradesco. 
	    If SA6->A6_COD = "998"  // BCF
		  CB_RN_NN    := Ret_cBar237(Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],;
		  aDadosBanco[5],aDadosBanco[6],cNroDoc,(SE1->E1_SALDO - SE1->E1_DECRESC + SE1->E1_ACRESC/*-nVlrAbat*/),cConvenio )
	    Elseif ( substring(cFilant,1,3) $ "#016") //Walter - removido o 0 antes do cNroDoc
		  CB_RN_NN    := Ret_cBar237(Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],;                                    
		  aDadosBanco[5],aDadosBanco[6],cNroDoc,(SE1->E1_SALDO - SE1->E1_DECRESC + SE1->E1_ACRESC/*-nVlrAbat*/),cConvenio )
		Else
		  CB_RN_NN    := Ret_cBar237(Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],;                                    
		  aDadosBanco[5],aDadosBanco[6],'0'+cNroDoc,(SE1->E1_SALDO - SE1->E1_DECRESC + SE1->E1_ACRESC/*-nVlrAbat*/),cConvenio )	  
		EndIf
	elseif subs(aDadosBanco[1],1,3)=="707"   // O banco daycoval utiliza os servicos do daycoval. 
//		  CB_RN_NN    := U_Ret_cBar707(Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],;
		  CB_RN_NN    := U_RBar707(Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],;		  
		  aDadosBanco[5],aDadosBanco[6],cNroDoc,(SE1->E1_SALDO - SE1->E1_DECRESC + SE1->E1_ACRESC),cConvenio, _cOpera )
	elseif subs(aDadosBanco[1],1,3)=="246"
//		CB_RN_NN      := U_Ret_cBar246(Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],;
		CB_RN_NN      := U_RBar246(Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],;
		aDadosBanco[5],aDadosBanco[6],cNroDoc,(SE1->E1_SALDO - SE1->E1_DECRESC + SE1->E1_ACRESC/*-nVlrAbat*/),cConvenio,_cOpera)
	elseif subs(aDadosBanco[1],1,3)=="033"
		CB_RN_NN    := Ret_cBar033(Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],aDadosBanco[6],cNroDoc,(SE1->E1_SALDO - SE1->E1_DECRESC + SE1->E1_ACRESC/*-nVlrAbat*/),cConvenio)
	elseif subs(aDadosBanco[1],1,3)=="004"
		CB_RN_NN    := Ret_cB004(Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],aDadosBanco[6],cNroDoc,(SE1->E1_SALDO - SE1->E1_DECRESC + SE1->E1_ACRESC/*-nVlrAbat*/),cConvenio)
	elseif subs(aDadosBanco[1],1,3)=="104"
		CB_RN_NN    := Ret_cB104(Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],aDadosBanco[6],cNroDoc,(SE1->E1_SALDO - SE1->E1_DECRESC + SE1->E1_ACRESC/*-nVlrAbat*/),cConvenio)
	elseif subs(aDadosBanco[1],1,3)=="637"
		CB_RN_NN    := Ret_cBar637(Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],aDadosBanco[6],cNroDoc,(SE1->E1_SALDO - SE1->E1_DECRESC + SE1->E1_ACRESC/*-nVlrAbat*/),cConvenio)
	endif
	
	aDadosTit    := {" "+AllTrim(iif(empty(ALLTRIM(SE1->E1_NRDOC)),SE1->E1_NUM,SE1->E1_NRDOC))+" "+AllTrim(SE1->E1_PARCELA) ,;  // [01] Número do título
	SE1->E1_EMISSAO                                            													,;  			// [02] Data da emissão do título
	Date()                                                														,;  			// [03] Data da emissão do boleto
	Substr(DtoS(SE1->E1_VENCREA),7,2)+'/'+Substr(DtoS(SE1->E1_VENCREA),5,2)+'/'+Substr(DtoS(SE1->E1_VENCREA),1,4)	,;  		// [04] Data do vencimento
	/*SE1->E1_VALOR-nVlrAbat*/(SE1->E1_SALDO - SE1->E1_DECRESC + SE1->E1_ACRESC)								,;  			// [05] Valor do título
	CB_RN_NN[3]                                     															,;  			// [06] 
	SE1->E1_PREFIXO                                            													,;  			// [07] Prefixo da NF
	SE1->E1_TIPO                                                  												,;  			// [08] Tipo do Titulo
	SE1->E1_IRRF                                                  												,;  			// [09] IRRF
	SE1->E1_ISS                                                													,;  			// [10] ISS
	SE1->E1_INSS                                               													,;  			// [11] INSS
	SE1->E1_PIS                                                													,;  			// [12] PIS
	SE1->E1_COFINS                                             													,;  			// [13] COFINS
	SE1->E1_CSLL                                               													,;  			// [14] CSLL
	0                                                     														,; 				// [15] Abatimentos
	AllTrim(E1_NFELETR)                                   					 									 }  			// [16] NF Eletronica
	
	aBolText :=    {;
	" " }
	
	If aMarked[i]                         
	   if subs(aDadosBanco[1],1,3)=="104"
		  Impr104(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN,aDatAvalist)
	   Else	  
		  Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN,aDatAvalist)
	   EndIf
	   n := n + 1
	EndIf
	
	dbSelectArea("SE1")
	
	dbSkip()
	IncProc()
	i := i + 1
EndDo


dbSelectArea("SE1")

oPrint:EndPage()     // Finaliza a página
oPrint:Preview()     // Visualiza antes de imprimir
Return nil


Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN,aDatAvalist)
LOCAL oFont8
LOCAL oFont10
LOCAL oFont16
LOCAL oFont16n
LOCAL oFont24
LOCAL i := 0
LOCAL aCoords1 := {0150,1900,0550,2300}
LOCAL aCoords2 := {0450,1050,0550,1900}
LOCAL aCoords3 := {0710,1900,0810,2300}
LOCAL aCoords4 := {0980,1900,1050,2300}
LOCAL aCoords5 := {1330,1900,1400,2300}
LOCAL aCoords6 := {2000,1900,2100,2300}
LOCAL aCoords7 := {2270,1900,2340,2300}
LOCAL aCoords8 := {2620,1900,2690,2300}
LOCAL oBrush
LOCAL cCGC := ""
LOCAL cCGCA := ""

//Parâmetros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
oFont8   := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont9n  := TFont():New("Arial",9,9 ,.T.,.F.,5,.T.,5,.T.,.F.) // Negrito
oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16  := TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.) //modificado de 16 para 12 JCNS
oFont16n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.) //modificado de 16 para 14 JCNS
oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10m := TFont():New("Arial",9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:StartPage()   // Inicia uma nova página
 
// Inicia aqui a alteracao para novo layout - RAI
oPrint:Line (0150,550,0050, 550)
oPrint:Line (0150,800,0050, 800)
If aDadosBanco[8] == '104'
  cBitMap        := "system\caixa.bmp"
//  cRaizBitMap    := FisxLogo("1")
  oPrint:SayBitmap(0045,100,cBitMap,400,110)	//															,oFont10 )  // [2]Nome do Banco
Else
  oPrint:Say  (0084,100,aDadosBanco[2]																,oFont10 )  // [2]Nome do Banco
EndIf
oPrint:Say  (0062,567,aDadosBanco[1]																,oFont24 )  // [1]Numero do Banco
oPrint:Say  (0084,1900,"Comprovante de Entrega"														,oFont10 )
oPrint:Line (0150,100,0150,2300)
//DAYCOVAL E STD
if aDadosBanco[8] == '707' .OR. aDadosBanco[8] == '033' .OR. aDadosBanco[8] == '004'  .OR.;
   aDadosBanco[8] == '104' .OR. aDadosBanco[8] == '237' .OR. aDadosBanco[8] == '246' .OR. aDadosBanco[8] == '637'
	oPrint:Say  (0150,100 ,"Beneficiário"                                      						,oFont8	 )
else
	oPrint:Say  (0150,100 ,"Cedente"                                        						,oFont8	 )
endif
oPrint:Say  (0200,100 ,aDadosEmp[1]                                  								,oFont10m) //Nome + CNPJ
oPrint:Say  (0150,1060,"Agência / Beneficiário"                         							,oFont8	 )

If aDadosBanco[8] == '033'
	oPrint:Say  (0200,1060,alltrim(aDadosBanco[3])+" - "+alltrim(aDadosBanco[7])+"/"+alltrim(cConvenio),oFont10 )
ElseIf aDadosBanco[8] == '637'
	oPrint:Say  (0200,1060,alltrim(aDadosBanco[3])+" - "+alltrim(aDadosBanco[7])+"/"+alltrim(cConvenio),oFont10 )
ElseIf aDadosBanco[8] == '004'
	oPrint:Say  (0200,1060,alltrim(aDadosBanco[3])+"/"+alltrim(aDadosBanco[4])+"-"+alltrim(aDadosBanco[5])	,oFont10 )
ElseIf aDadosBanco[8] == '104'
	oPrint:Say  (0200,1060,alltrim(aDadosBanco[3])+"/"+alltrim(cConvenio)+"-"+alltrim(CalDigCV(cConvenio))	,oFont10 )
ElseIf  aDadosBanco[8] == '707' .AND.;
    (Left(cFilAnt,3) = '002' .OR. Left(cFilAnt,3) = '006' .OR. Left(cFilAnt,3) = '008')
	oPrint:Say  (0200,1060,alltrim(aDadosBanco[3])+" - "+alltrim(aDadosBanco[7])+"/"+alltrim(aDadosBanco[4])+" - "+alltrim(aDadosBanco[5])	,oFont10 )
ElseIf  aDadosBanco[8] == '246'
	oPrint:Say  (0200,1060,alltrim(aDadosBanco[3])+" - "+alltrim(aDadosBanco[7])+"/"+alltrim(aDadosBanco[4])+" - "+alltrim(aDadosBanco[5])	,oFont10 )
Else
	oPrint:Say  (0200,1060,alltrim(aDadosBanco[3])+" - "+alltrim(aDadosBanco[7])+"/"+alltrim(aDadosBanco[4])+" - "+alltrim(aDadosBanco[5])	,oFont10 )
endif
oPrint:Say  (0150,1510,"Nro.Documento"                                  							,oFont8  )
oPrint:Say  (0200,1510,/*aDadosTit[7]+*/aDadosTit[1]                  								,oFont10 ) //Prefixo +Numero+Parcela
//DAYCOVAL, STD, BNBe CAIXA
if aDadosBanco[8] == '707' .OR. aDadosBanco[8] == '033'  .OR. aDadosBanco[8] == '004'  .OR. aDadosBanco[8] == '104' .OR.;
   aDadosBanco[8] == '237' .OR. aDadosBanco[8] == '246'  .OR. aDadosBanco[8] == '637' 
	oPrint:Say  (0250,100 ,"Pagador"                                        						,oFont8  )
else
	oPrint:Say  (0250,100 ,"Sacado"                                         						,oFont8  )
endif
oPrint:Say  (0300,100 ,SubsTr(aDatSacado[1],1,40)                 									,oFont10 ) //Nome + Codigo
oPrint:Say  (0250,1060,"Vencimento"                                     							,oFont8  )
oPrint:Say  (0300,1060,If((aDadosTit[4])=="11/11/11","C/Apresentação",(aDadosTit[4]))				,oFont10 )
oPrint:Say  (0250,1510,"Valor do Documento"                             							,oFont8  )
oPrint:Say  (0300,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99"))							,oFont10 )
oPrint:Say  (0400,0100,"Recebi(emos) o bloqueto/título"                 							,oFont10 )
oPrint:Say  (0450,0100,"com as características acima."                  							,oFont10 )
oPrint:Say  (0350,1060,"Data"                                           							,oFont8  )
oPrint:Say  (0350,1410,"Assinatura"                                  								,oFont8  )
oPrint:Say  (0450,1060,"Data"                                           							,oFont8  )
oPrint:Say  (0450,1410,"Entregador"                                  								,oFont8  )

oPrint:Line (0250, 100,0250,1900 )
oPrint:Line (0350, 100,0350,1900 )
oPrint:Line (0450,1050,0450,1900 ) //---
oPrint:Line (0550, 100,0550,2300 )

oPrint:Line (0550,1050,0150,1050 )
oPrint:Line (0550,1400,0350,1400 )
oPrint:Line (0350,1500,0150,1500 ) //--
oPrint:Line (0550,1900,0150,1900 )

oPrint:Say  (0160,1910,"(  )Mudou-se"                                   ,oFont8)
oPrint:Say  (0200,1910,"(  )Ausente"                                    ,oFont8)
oPrint:Say  (0240,1910,"(  )Não existe nº indicado"                     ,oFont8)
oPrint:Say  (0280,1910,"(  )Recusado"                                   ,oFont8)
oPrint:Say  (0320,1910,"(  )Não procurado"                              ,oFont8)
oPrint:Say  (0360,1910,"(  )Endereço insuficiente"                   	,oFont8)
oPrint:Say  (0400,1910,"(  )Desconhecido"                               ,oFont8)
oPrint:Say  (0440,1910,"(  )Falecido"                                   ,oFont8)
oPrint:Say  (0480,1910,"(  )Outros(anotar no verso)"                    ,oFont8)

For i := 100 to 2300 step 50
	oPrint:Line( 0600, i, 0600, i+30)
Next i

oPrint:Line (0710,100,0710,2300)
oPrint:Line (0710,550,0610, 550)
oPrint:Line (0710,800,0610, 800)
If aDadosBanco[8] == '104'
  cBitMap        := "system\caixa.bmp"
  oPrint:SayBitmap(0602,100,cBitMap,400,110)	//															,oFont10 )  // [2]Nome do Banco
Else
  oPrint:Say  (0640,100,aDadosBanco[2],oFont10 )  // [2]Nome do Banco
EndIf
//oPrint:Say  (0644,100,aDadosBanco[2],oFont10 )  // [2]Nome do Banco
oPrint:Say  (0622,567,aDadosBanco[1],oFont24 )  // [1]Numero do Banco
//oPrint:Say  (0644,1900,"Recibo do Sacado",oFont10)
oPrint:Say  (0644,820,CB_RN_NN[2],oFont16n)     //Linha Digitavel do Codigo de Barras
oPrint:Line (0810,100,0810,2300 )
oPrint:Line (0910,100,0910,2300 )
oPrint:Line (0980,100,0980,2300 )
oPrint:Line (1050,100,1050,2300 )

nYCIP := 370
nYNossoNum := 1910
cNumCIP := "504"

oPrint:Line (0910,500,1050,500)
oPrint:Line (0980,750,1050,750)
oPrint:Line (0910,1000,1050,1000)
oPrint:Line (0910,1350,0980,1350)
oPrint:Line (0910,1550,1050,1550)

cDVNN := U_CalcDig(alltrim(cConvenio)+cNroDoc)

oPrint:Say  (0710,100 ,"Local de Pagamento"                             						,oFont8 )
if aDadosBanco[8] == '104'
  oPrint:Say  (0750,100 ,"PREFERENCIALMENTE NAS CASAS LOTERICAS ATÉ O VALOR LIMITE"				,oFont10)
Elseif aDadosBanco[8] == '237'
  oPrint:Say  (0750,100 ,"Pagável Preferencialmente na rede Bradesco ou no Bradesco expresso"	,oFont10)
Elseif aDadosBanco[8] == '998'
  oPrint:Say  (0750,100 ,"Pagável Preferencialmente na rede Bradesco ou no Bradesco expresso"	,oFont10)
Else
  oPrint:Say  (0730,400 ,"PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO"     						,oFont10)
EndIf

oPrint:Say  (0760,400 ,"										  "     						,oFont10)

oPrint:Say  (0710,1910,"Vencimento"                                     						,oFont8 )
oPrint:Say  (0750,2010,If((aDadosTit[4])=="11/11/11","C/Apresentação",(aDadosTit[4]))			,oFont10)
//DAYCOVAL, STD, BNB e CAIXA
if aDadosBanco[8] == '707' .OR. aDadosBanco[8] == '033' .OR. aDadosBanco[8] == '004' .OR. aDadosBanco[8] == '104' .OR.;
   aDadosBanco[8] == '237' .OR. aDadosBanco[8] == '246' .OR. aDadosBanco[8] == '637' 
	oPrint:Say  (0810,100 ,"Beneficiário"                                        				,oFont8 )
Elseif  aDadosBanco[8] == '998'
	oPrint:Say  (0810,100 ,"Beneficiário"                                        				,oFont8 )
else
	oPrint:Say  (0810,100 ,"Cedente"                                        					,oFont8 )
endif

if aDadosBanco[8] == '104'
   oPrint:Say  (0819,225 ,Alltrim(aDadosEmp[1])+" - "+Alltrim(aDadosEmp[6])						,oFont10) //Nome + CNPJ
   oPrint:Say  (0852,100 ,Alltrim(aDadosEmp[2])+","+Alltrim(aDadosEmp[3])+","+Alltrim(aDadosEmp[4]) 	,oFont10) //Endereço + Complemento + CEP
Elseif aDadosBanco[8] == '237' .and. !( substring(cFilant,1,3) $ "#016") 
   oPrint:Say  (0852,100 ,"RENDMAX FIDC MULTISSETORIAL" + " - " + "CNPJ: " + "10.989.464/0001-26" + ")"	,oFont10) //Nome + CNPJ
Elseif aDadosBanco[8] == '237' .and. ( substring(cFilant,1,3) $ "#016") //Walter - Adicionado por solicitação do Bradesco, acrescentar o endereço.
   oPrint:Say  (0819,225 ,aDadosEmp[1]+" - "+aDadosEmp[6] 											,oFont10) //Nome + CNPJ   
   oPrint:Say  (0852,100 ,aDadosEmp[2]+" - "+aDadosEmp[3]+" - "+aDadosEmp[4] 	,oFont10) //Endereço + Complemento + CEP
Elseif aDadosBanco[8] == '998'
//   oPrint:Say  (0852,100 ,"BFC FIDC" + " - " + "CNPJ: " + "11.507.489/0001-09" + ")"	,oFont10) //Nome + CNPJ
   oPrint:Say  (0819,225 ,"BFC FIDC" + " - " + "CNPJ: " + "11.507.489/0001-09" + ")"	,oFont10) //Nome + CNPJ
   oPrint:Say  (0852,100 ,"AV. BRIGADEIRO FARIA LIMA,1355-3º ANDAR, JARDIM PAULISTANO, SÃO PAULO-SP CEP:01.452-002" 	,oFont10) //Endereço + Complemento + CEP
Else
   oPrint:Say  (0850,100 ,aDadosEmp[1]+" - "+aDadosEmp[6] 											,oFont10) //Nome + CNPJ   
EndIf


oPrint:Say  (0810,1910,"Agência/ Beneficiário"                         							,oFont8 )       // Geraldo em 25/04/2017

If aDadosBanco[8] == '033'
	oPrint:Say  (0850,1980,alltrim(aDadosBanco[3])+" - "+alltrim(aDadosBanco[7])+"/"+alltrim(cConvenio)	,oFont10 )
ElseIf aDadosBanco[8] == '637'
	oPrint:Say  (0850,1980,alltrim(aDadosBanco[3])+" - "+alltrim(aDadosBanco[7])+"/"+alltrim(cConvenio)	,oFont10 )
ElseIf aDadosBanco[8] == '004'
	oPrint:Say  (0850,1980,alltrim(aDadosBanco[3])+"/"+alltrim(aDadosBanco[4])+"-"+alltrim(aDadosBanco[5])	,oFont10 )
ElseIf aDadosBanco[8] == '104'
//	oPrint:Say  (0850,1980,alltrim(aDadosBanco[3])+"/"+alltrim(aDadosBanco[4])+"-"+alltrim(aDadosBanco[5])	,oFont10 )
	oPrint:Say  (0850,1980,alltrim(aDadosBanco[3])+"/"+alltrim(cConvenio)+"-"+alltrim(CalDigCV(cConvenio))	,oFont10 )
else
	oPrint:Say  (0850,1980,alltrim(aDadosBanco[3])+" - "+alltrim(aDadosBanco[7])+"/"+alltrim(aDadosBanco[4])+" - "+alltrim(aDadosBanco[5])	,oFont10 )
endif

oPrint:Say  (0910,100 ,"Data do Documento"                              						,oFont8 )

oPrint:Say  (0940,100 ,DTOC(aDadosTit[2])                               						,oFont10) // Emissao do Titulo (E1_EMISSAO)

oPrint:Say  (0910,505 ,"Nro.Documento"                                  						,oFont8 )
oPrint:Say  (0940,605 ,/*aDadosTit[7]+*/aDadosTit[1]               								,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (0910,1005,"Espécie Doc."                                   						,oFont8 )
oPrint:Say  (0940,1050,"DM"     																,oFont10) //Tipo do Titulo

oPrint:Say  (0910,1355,"Aceite"                                         						,oFont8 )
oPrint:Say  (0940,1455,"N"                                             							,oFont10)

oPrint:Say  (0910,1555,"Data do Processamento"                          						,oFont8 )
oPrint:Say  (0940,1655,DTOC(aDadosTit[3])                               						,oFont10) // Data impressao

oPrint:Say  (0910,1910,"Nosso Número"                                   						,oFont8 )

If aDadosBanco[8] == '707' .and. ;
    ( Left(cFilAnt,3) = '002' .or. Left(cFilAnt,3) = '006'  .or. Left(cFilAnt,3) = '008')//DAYCOVAL
	oPrint:Line (0980,nYCIP,1050,nYCIP) //linha CIP
	oPrint:Say  (0940,1910,alltrim(aDadosBanco[6])+'/'+substr(alltrim(aDadosTit[6]),8,len(alltrim(aDadosTit[6])))						    ,oFont10)
	oPrint:Say  (0980,nYCIP+5 ,"CIP"    	                                   					,oFont8 )
	oPrint:Say  (1010,nYCIP+50 ,cNumCIP	                                						,oFont10)
ElseIf aDadosBanco[8] == '707' //DAYCOVAL
	oPrint:Line (0980,nYCIP,1050,nYCIP) //linha CIP
	oPrint:Say  (0940,1910,alltrim(aDadosBanco[6])+'/'+substr(alltrim(aDadosTit[6]),3,len(alltrim(aDadosTit[6])))						    ,oFont10)
	oPrint:Say  (0980,nYCIP+5 ,"CIP"    	                                   					,oFont8 )
	oPrint:Say  (1010,nYCIP+50 ,cNumCIP	                                						,oFont10)
Elseif aDadosBanco[8] == '246'  // ABC BRASIL
	oPrint:Say  (0940,1910,"00019/" + alltrim(aDadosBanco[6]) + '/' + Right(alltrim(aDadosTit[6]),14),oFont10)
Elseif aDadosBanco[8] == '237'             // BRADESCO
	oPrint:Say  (0940,1910,alltrim(aDadosBanco[6])+' / '+alltrim(aDadosTit[6]),oFont10)
Elseif aDadosBanco[8] == '998'             // BRADESCO // 998
	oPrint:Say  (0940,1910,alltrim(aDadosBanco[6])+' / ' + Substr(alltrim(aDadosTit[6]),3, Len(alltrim(aDadosTit[6]))-2)      ,oFont10)
elseif aDadosBanco[8] == '033'
	oPrint:Say  (0940,1960,alltrim(aDadosTit[6]),oFont10)
elseif aDadosBanco[8] == '637'
	oPrint:Say  (0940,1960,alltrim(aDadosTit[6]),oFont10)
elseif aDadosBanco[8] == '004'
	oPrint:Say  (0940,1960,alltrim(aDadosTit[6])+Space(15)+aDadosBanco[6],oFont10)
elseif aDadosBanco[8] == '104'
	oPrint:Say  (0940,1960,alltrim(aDadosTit[6])												,oFont10)
else
	oPrint:Say  (0940,1960,alltrim(cConvenio)+cNroDoc/*+"-"+cDVNN*/								,oFont10)//SubsTr(aDadosTit[6],1,3)+"/"+SubsTr(aDadosTit[6],4,11)+"-"+SubsTr(aDadosTit[6],12,1)
endif

oPrint:Say  (0980,100 ,"Uso do Banco"                                   						,oFont8 )
if aDadosBanco[8] = '707' //DAYCOVAL
	oPrint:Say  (1010,155 ,"8600"                                         						,oFont10)
endif

oPrint:Say  (0980,505 ,"Carteira"                                       						,oFont8 )
if  aDadosBanco[8] == '104'
   oPrint:Say  (1010,555 ,"RG" 				                               						,oFont10)
Else
   oPrint:Say  (1010,555 ,aDadosBanco[6]                                						,oFont10)
EndIf

oPrint:Say  (0980,755 ,"Espécie"                                        						,oFont8 )
oPrint:Say  (1010,805 ,"R$"                                             						,oFont10)

oPrint:Say  (0980,1005,"Quantidade"                                     						,oFont8 )
oPrint:Say  (0980,1555,"Valor"                                          						,oFont8 )

oPrint:Say  (0980,1910,"Valor do Documento"                             						,oFont8 )
oPrint:Say  (1010,2010,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99"))						,oFont10)

If aDadosBanco[8] == '237' .or. aDadosBanco[8] == '998'
  oPrint:Say  (1050,100 ,"Instruções",oFont8)
  oPrint:Say  (1100,100 ,"SR. CAIXA, NÃO CONCEDER DESCONTO"             ,oFont10)
  oPrint:Say  (1150,100 ,"NO 5º (QUINTO) DIA ÚTIL APÓS O VENCIMENTO, O TITULO SERÁ ENVIADO A CARTÓRIO"                    ,oFont10)
  oPrint:Say  (1200,100 ,"COBRAR JUROS DE R$"+AllTrim(Transform(aDadosTit[5]*5/100/30,"@E 999,999,999.99"))+" AO DIA"          ,oFont10)
ElseIf aDadosBanco[8] == '246'
  oPrint:Say  (1050,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiário)",oFont8)
  oPrint:Say  (1100,100 ,"Título transferido a favor do Banco ABC Brasil" ,oFont10)
  oPrint:Say  (1150,100 ,""                                               ,oFont10)
  oPrint:Say  (1200,100 ,"COBRAR JUROS DE R$"+AllTrim(Transform(aDadosTit[5]*5/100/30,"@E 999,999,999.99"))+" AO DIA"          ,oFont10)
Else
  oPrint:Say  (1050,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiário)",oFont8)
  oPrint:Say  (1100,100 ,""                                             ,oFont10)
  oPrint:Say  (1150,100 ,""                                             ,oFont10)
  oPrint:Say  (1200,100 ,"COBRAR JUROS DE R$"+AllTrim(Transform(aDadosTit[5]*5/100/30,"@E 999,999,999.99"))+" AO DIA"          ,oFont10)
EndIf

//oPrint:Say  (1050,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiário)",oFont8)
//oPrint:Say  (1100,100 ,""                                      ,oFont10)

//oPrint:Say  (1150,100 ,"PROTESTAR APÓS 07 DIAS DO VENCIMENTO"  ,oFont10)
//oPrint:Say  (1150,100 ,""  ,oFont10)
//oPrint:Say  (1200,100 ,"COBRAR JUROS DE R$ "+ AllTrim(Transform(aDadosTit[5]*5/100/30,"@E 999,999,999.99")) +" AO DIA"          ,oFont10)
oPrint:Say  (1250,100 ,""                           		   ,oFont10)
//oPrint:Say  (1300,100 ,"NÃO DEPOSITAR NA CONTA CORRENTE DO BOLETO",oFont10) // SUBSTITUIDO PELA LINHA ABAIXO CONFORME CHAMADO GLPI-6014 EM 11042018 POR GERALDO GOMES
oPrint:Say  (1300,100 ,"ATENÇÃO:O Depósito em conta corrente sem a devida autorização do cedente, não garante a quitação do débito!",oFont10)
oPrint:Say  (1350,100 ,""                                      ,oFont10)
oPrint:Say  (1400,100 ,""                                      ,oFont10)
oPrint:Say  (1450,100 ,""                                      ,oFont10)
oPrint:Say  (1500,100 ,""                                      ,oFont10)

oPrint:Say  (1050,1910,"(-)Desconto/Abatimento"                         ,oFont8)
If aDadosTit[15] > 0
	oPrint:Say  (1080,2010,AllTrim(Transform(aDadosTit[15],"@E 999,999,999.99")),oFont10)
Endif
oPrint:Say  (1120,1910,"(-)Outras Deduções"                             ,oFont8)
oPrint:Say  (1190,1910,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (1260,1910,"(+)Outros Acréscimos"                           ,oFont8)
oPrint:Say  (1330,1910,"(=)Valor Cobrado"                               ,oFont8)

If Len(AllTrim(aDatSacado[7]))==11
	cCGC := cCGC + SubsTr(AllTrim(aDatSacado[7]),1,3)+"."
	cCGC := cCGC + SubsTr(AllTrim(aDatSacado[7]),4,3)+"."
	cCGC := cCGC + SubsTr(AllTrim(aDatSacado[7]),7,3)+"-"
	cCGC := cCGC + SubsTr(AllTrim(aDatSacado[7]),10,2)
Elseif Len(AllTrim(aDatSacado[7]))==14
	cCGC := cCGC + SubsTr(AllTrim(aDatSacado[7]),1,2)+"."
	cCGC := cCGC + SubsTr(AllTrim(aDatSacado[7]),3,3)+"."
	cCGC := cCGC + SubsTr(AllTrim(aDatSacado[7]),6,3)+"/"
	cCGC := cCGC + SubsTr(AllTrim(aDatSacado[7]),9,4)+"-"
	cCGC := cCGC + SubsTr(AllTrim(aDatSacado[7]),13,2)
Endif

//Dados do Avalista
If Len(AllTrim(aDatAvalist[7]))==11
	cCGCA := cCGCA + SubsTr(AllTrim(aDatAvalist[7]),1,3)+"."
	cCGCA := cCGCA + SubsTr(AllTrim(aDatAvalist[7]),4,3)+"."
	cCGCA := cCGCA + SubsTr(AllTrim(aDatAvalist[7]),7,3)+"-"
	cCGCA := cCGCA + SubsTr(AllTrim(aDatAvalist[7]),10,2)
Elseif Len(AllTrim(aDatAvalist[7]))==14
	cCGCA := cCGCA + SubsTr(AllTrim(aDatAvalist[7]),1,2)+"."
	cCGCA := cCGCA + SubsTr(AllTrim(aDatAvalist[7]),3,3)+"."
	cCGCA := cCGCA + SubsTr(AllTrim(aDatAvalist[7]),6,3)+"/"
	cCGCA := cCGCA + SubsTr(AllTrim(aDatAvalist[7]),9,4)+"-"
	cCGCA := cCGCA + SubsTr(AllTrim(aDatAvalist[7]),13,2)
Endif

If aDadosBanco[8] == '707' .or. aDadosBanco[8] == '033' .or. aDadosBanco[8] == '004' .or. aDadosBanco[8] == '104' .or.;
   aDadosBanco[8] == '237' .or. aDadosBanco[8] == '998' .or. aDadosBanco[8] == '246' .or. aDadosBanco[8] == '637'
	oPrint:Say  (1400,100 ,"Pagador"                                        ,oFont8)
else
	oPrint:Say  (1400,100 ,"Sacado"                                         ,oFont8)
endif
oPrint:Say  (1430,100 ,aDatSacado[1]+" ("+aDatSacado[2]+") CPF: "+cCGC  ,oFont10)
oPrint:Say  (1483,100 ,aDatSacado[3]                                    ,oFont10)
oPrint:Say  (1536,100 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado
//oPrint:SayBitmap( 1420,1870,aBitMap[1],400,200 )
oPrint:Say  (1605,100 ,"Sacador/Avalista"                               ,oFont8)
If aDadosBanco[8] == '707' .OR. aDadosBanco[8] == '237'
  If aDatSacado[2] <> aDatAvalist[2]
    oPrint:Say  (1605,350 ,aDatAvalist[1]+" ("+aDatAvalist[2]+") CPF: "+cCGCA ,oFont10)
  EndIf
ElseIf aDadosBanco[8] == '998'   
  oPrint:Say  (1605,350 ,aDadosEmp[1]+"-"+aDadosEmp[6] ,oFont10)
Else
  oPrint:Say  (1605,350 ,aDatAvalist[1]+" ("+aDatAvalist[2]+") CPF: "+cCGCA ,oFont10)
EndIf
//oPrint:Say  (1645,1500,"Autenticação Mecânica -"                      ,oFont8)
//oPrint:Say  (2895,100 ,"Sacador/Avalista"                               ,oFont8)
//oPrint:Say  (2895,350 ,aDatAvalist[1]+" ("+aDatAvalist[2]+") CPF: "+cCGCA ,oFont10)
//oPrint:Say  (2895,505 ,""                                        ,oFont8)
if aDadosBanco[8] == '104'
  oPrint:Say  (1260,100,"SAC CAIXA: ",oFont9n)
  oPrint:Say  (1260,100,"SAC CAIXA: 0800 726 0101 (informações, reclamações, sugestões e elogios)",oFont9n)

  oPrint:Say  (1290,100,"Para pessoas com deficiência auditiva ou de fala: 0800 726 2492",oFont9n)
  oPrint:Say  (1320,100,"Ouvidoria: ",oFont9n)
  oPrint:Say  (1320,100,"Ouvidoria: 0800 725 7474",oFont9n)
  
  oPrint:Say  (1350,100,"caixa.gov.br" , oFont9n)
  oPrint:Say  (1350,100,"caixa.gov.br" , oFont9n)

  oPrint:Say  (1645,1500,"Autenticação Mecânica -"                     ,oFont8)
  oPrint:Say  (1645,1850,"Recibo do Pagador"                           ,oFont10)
EndIf

oPrint:Line (0710,1900,1400,1900 )
oPrint:Line (1120,1900,1120,2300 )
oPrint:Line (1190,1900,1190,2300 )
If aDadosBanco[8] == '104'
  oPrint:Line (1260,100 ,1260,1900 ) // Dados do SAC
Endif
oPrint:Line (1260,1900,1260,2300 )
oPrint:Line (1330,1900,1330,2300 )
oPrint:Line (1400,100 ,1400,2300 )
oPrint:Line (1640,100 ,1640,2300 )

For i := 100 to 2300 step 50
	oPrint:Line( 1850, i, 1850, i+30)
Next i

// Encerra aqui a alteracao para o novo layout - RAI

oPrint:Line (2000,100,2000,2300)
oPrint:Line (2000,550,1900, 550)
oPrint:Line (2000,800,1900, 800)
If aDadosBanco[8] == '104'
  cBitMap        := "system\caixa.bmp"
  oPrint:SayBitmap(1890,100,cBitMap,400,110)	//															,oFont10 )  // [2]Nome do Banco
Else
  oPrint:Say  (1934,100,aDadosBanco[2],oFont10 )  // [2]Nome do Banco
//  oPrint:Say  (1934,100,aDadosBanco[2],oFont10 )  // [2]Nome do Banco
EndIf
//oPrint:Say  (1934,100,aDadosBanco[2],oFont10 )  // [2]Nome do Banco
oPrint:Say  (1912,567,aDadosBanco[1],oFont24 )  // [1]Numero do Banco
oPrint:Say  (1934,820,CB_RN_NN[2],oFont16n)     //Linha Digitavel do Codigo de Barras

oPrint:Line (2100,100,2100,2300 )
oPrint:Line (2200,100,2200,2300 )
oPrint:Line (2270,100,2270,2300 )
oPrint:Line (2340,100,2340,2300 )

oPrint:Line (2200,500,2340,500)
oPrint:Line (2270,750,2340,750)
oPrint:Line (2200,1000,2340,1000)
oPrint:Line (2200,1350,2270,1350)
oPrint:Line (2200,1550,2340,1550)

oPrint:Say  (2000,100 ,"Local de Pagamento"                        ,oFont8)
if aDadosBanco[8] == '104'
  oPrint:Say  (2040,100 ,"PREFERENCIALMENTE NAS CASAS LOTERICAS ATE O VALOR LIMITE"				,oFont10)
Elseif aDadosBanco[8] == '237'
  oPrint:Say  (2040,100 ,"Pagável Preferencialmente na rede Bradesco ou no Bradesco expresso"	,oFont10)
Elseif aDadosBanco[8] == '998'
  oPrint:Say  (2040,100 ,"Pagável Preferencialmente na rede Bradesco ou no Bradesco expresso"	,oFont10)
Else
  oPrint:Say  (2020,400 ,"PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO",oFont10)
EndIf
//oPrint:Say  (2020,400 ,"PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO",oFont10)
oPrint:Say  (2050,400 ,"                                          ",oFont10)

oPrint:Say  (2000,1910,"Vencimento"                                     ,oFont8)
oPrint:Say  (2040,2010,If((aDadosTit[4])=="11/11/11","C/Apresentação",(aDadosTit[4])),oFont10)

if aDadosBanco[8] == '707' .or. aDadosBanco[8] == '033' .or. aDadosBanco[8] == '004' .or. aDadosBanco[8] == '104'.or.;
   aDadosBanco[8] == '237' .or. aDadosBanco[8] == '998' .or. aDadosBanco[8] == '246' .or. aDadosBanco[8] == '637'
	oPrint:Say  (2100,100 ,"Beneficiário"                                   ,oFont8)
else
	oPrint:Say  (2100,100 ,"Cedente"                                        ,oFont8)
endif
if aDadosBanco[8] == '104'
   oPrint:Say  (2109,225 ,Alltrim(aDadosEmp[1])+" - "+Alltrim(aDadosEmp[6])						,oFont10) //Nome + CNPJ
   oPrint:Say  (2141,100 ,Alltrim(aDadosEmp[2])+","+Alltrim(aDadosEmp[3])+","+Alltrim(aDadosEmp[4]) 	,oFont10) //Endereço + Complemento + CEP
Elseif aDadosBanco[8] == '237' .and. !(substring(cFilant,1,3) $ "#016") // RONDOTYRES
   oPrint:Say  (2142,100 ,"RENDMAX FIDC MULTISSETORIAL" + " - " + "CNPJ: " + "10.989.464/0001-26" + ")"						,oFont10) //Nome + CNPJ
Elseif aDadosBanco[8] == '998'
//   oPrint:Say  (2142,100 ,"BFC FIDC" + " - " + "CNPJ: " + "11.507.489/0001-09" + ")",oFont10) //Nome + CNPJ
//   oPrint:Say  (2141,100 ,Alltrim(aDadosEmp[2])+","+Alltrim(aDadosEmp[3])+","+Alltrim(aDadosEmp[4]) 	,oFont10) //Endereço + Complemento + CEP
   oPrint:Say  (2109,225 ,"BFC FIDC" + " - " + "CNPJ: " + "11.507.489/0001-09" + ")"	,oFont10) //Nome + CNPJ
   oPrint:Say  (2141,100 ,"AV. BRIGADEIRO FARIA LIMA,1355-3º ANDAR, JARDIM PAULISTANO, SÃO PAULO-SP CEP:01.452-002" 	,oFont10) //Endereço + Complemento + CEP
Else
   oPrint:Say  (2140,100 ,aDadosEmp[1]+" - "+aDadosEmp[6] 											,oFont10) //Nome + CNPJ   
EndIf

//oPrint:Say  (2140,100 ,aDadosEmp[1]+" - "+aDadosEmp[6] ,oFont10) //Nome + CNPJ

oPrint:Say  (2100,1910,"Agência / Beneficiário"                         ,oFont8)     //geraldo 25/04/2017
if  aDadosBanco[8] == '033'
	oPrint:Say  (2140,1980,alltrim(aDadosBanco[3])+" - "+alltrim(aDadosBanco[7])+"/"+alltrim(cConvenio)	,oFont10 )
ElseIf aDadosBanco[8] == '637'
	oPrint:Say  (2140,1980,alltrim(aDadosBanco[3])+" - "+alltrim(aDadosBanco[7])+"/"+alltrim(cConvenio)	,oFont10 )
ElseIf aDadosBanco[8] == '004'
	oPrint:Say  (2140,1980,alltrim(aDadosBanco[3])+"/"+alltrim(aDadosBanco[4])+"-"+alltrim(aDadosBanco[5])	,oFont10 )
ElseIf aDadosBanco[8] == '104'
	oPrint:Say  (2140,1980,alltrim(aDadosBanco[3])+"/"+alltrim(cConvenio)+"-"+alltrim(CalDigCV(cConvenio))	,oFont10 )
else
	oPrint:Say  (2140,1980,alltrim(aDadosBanco[3])+" - "+alltrim(aDadosBanco[7])+"/"+alltrim(aDadosBanco[4])+" - "+alltrim(aDadosBanco[5])	,oFont10 )
endif
oPrint:Say  (2200,100 ,"Data do Documento"                              ,oFont8)
oPrint:Say  (2230,100 ,DTOC(aDadosTit[2])                               ,oFont10) // Emissao do Titulo (E1_EMISSAO)

oPrint:Say  (2200,505 ,"Nro.Documento"                                  ,oFont8)
oPrint:Say  (2230,605 ,/*aDadosTit[7]+*/aDadosTit[1]                  		,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (2200,1005,"Espécie Doc."                                   ,oFont8)
oPrint:Say  (2230,1050,"DM"     ,oFont10) //Tipo do Titulo

oPrint:Say  (2200,1355,"Aceite"                                         ,oFont8)
oPrint:Say  (2230,1455,"N"                                              ,oFont10)

oPrint:Say  (2200,1555,"Data do Processamento"                          ,oFont8)
oPrint:Say  (2230,1655,DTOC(aDadosTit[3])                               ,oFont10) // Data impressao

oPrint:Say  (2200,1910,"Nosso Número"                                   ,oFont8)

If aDadosBanco[8] == '707' .and. ;
    ( Left(cFilAnt,3) = '002' .or. Left(cFilAnt,3) = '006'  .or. Left(cFilAnt,3) = '008')//DAYCOVAL
	oPrint:Line (2270,nYCIP,2340,nYCIP) //linha CIP
	oPrint:Say  (2230,1910,alltrim(aDadosBanco[6])+'/'+substr(alltrim(aDadosTit[6]),8,len(alltrim(aDadosTit[6]))),oFont10)
	oPrint:Say  (2270,nYCIP+5 	,"CIP"    	                             ,oFont8)
	oPrint:Say  (2300,nYCIP+50 	,cNumCIP	                             ,oFont10)
Elseif aDadosBanco[8] == '707'  //DAYCOVAL
	oPrint:Line (2270,nYCIP,2340,nYCIP) //linha CIP
	oPrint:Say  (2230,1910,alltrim(aDadosBanco[6])+'/'+substr(alltrim(aDadosTit[6]),3,len(alltrim(aDadosTit[6]))),oFont10)
	oPrint:Say  (2270,nYCIP+5 	,"CIP"    	                             ,oFont8)
	oPrint:Say  (2300,nYCIP+50 	,cNumCIP	                             ,oFont10)
Elseif aDadosBanco[8] == '246'             // ABC BRASIL
	oPrint:Say  (2230,1910,"00019/" + alltrim(aDadosBanco[6])+'/' + RIght(alltrim(aDadosTit[6]),14),oFont10)
Elseif aDadosBanco[8] == '237'             // BRADESCO
	oPrint:Say  (2230,1910,alltrim(aDadosBanco[6])+' / '+alltrim(aDadosTit[6]),oFont10)
Elseif aDadosBanco[8] == '998'             // BRADESCO
	oPrint:Say  (2230,1910,alltrim(aDadosBanco[6])+' / ' + Substr(alltrim(aDadosTit[6]),3, Len(alltrim(aDadosTit[6]))-2)		,oFont10)
//	oPrint:Say  (0940,1910,alltrim(aDadosBanco[6])+' / ' + Substr(alltrim(aDadosTit[6]),3, Len(alltrim(aDadosTit[6]))-2)      	,oFont10)
elseif aDadosBanco[8] == '033'
	oPrint:Say  (2230,1960,alltrim(aDadosTit[6]),oFont10)
elseif aDadosBanco[8] == '637'
	oPrint:Say  (2230,1960,alltrim(aDadosTit[6]),oFont10)
elseif  aDadosBanco[8] == '004'
	oPrint:Say  (2230,1960,alltrim(aDadosTit[6])+Space(10)+aDadosBanco[6],oFont10)
elseif  aDadosBanco[8] == '104'
	oPrint:Say  (2230,1960,alltrim(aDadosTit[6])				 ,oFont10)
else
	oPrint:Say  (2230,1960,alltrim(cConvenio)+cNroDoc/*+"-"+cDVNN*/,oFont10)
endif

oPrint:Say  (2270,100 ,"Uso do Banco"                                       ,oFont8)
if aDadosBanco[8] = '707' //DAYCOVAL
	oPrint:Say  (2300,155 ,"8600"                                           ,oFont10)
endif

oPrint:Say  (2270,505 ,"Carteira"                                           ,oFont8)
if  aDadosBanco[8] == '104'
   oPrint:Say  (2300,555 ,"RG" 				                               	,oFont10)
Else
   oPrint:Say  (2300,555 ,aDadosBanco[6]                                	,oFont10)
EndIf

oPrint:Say  (2270,755 ,"Espécie"                                        ,oFont8)
oPrint:Say  (2300,805 ,"R$"                                             ,oFont10)

oPrint:Say  (2270,1005,"Quantidade"                                     ,oFont8)
oPrint:Say  (2270,1555,"Valor"                                          ,oFont8)

oPrint:Say  (2270,1910,"Valor do Documento"                             ,oFont8)
oPrint:Say  (2300,2010,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

If aDadosBanco[8] == '237' .or. aDadosBanco[8] == '998'
  oPrint:Say  (2340,100 ,"Instruções",oFont8)
  oPrint:Say  (2390,100 ,"SR. CAIXA, NÃO CONCEDER DESCONTO"             ,oFont10)
  oPrint:Say  (2440,100 ,"NO 5º (QUINTO) DIA ÚTIL APÓS O VENCIMENTO, O TITULO SERÁ ENVIADO A CARTÓRIO"                    ,oFont10)
//  oPrint:Say  (2440,100 ,""                                             ,oFont10)
  oPrint:Say  (2490,100 ,"COBRAR JUROS DE R$"+AllTrim(Transform(aDadosTit[5]*5/100/30,"@E 999,999,999.99"))+" AO DIA"          ,oFont10)
ElseIf aDadosBanco[8] == '246'
  oPrint:Say  (2340,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiário)",oFont8)
  oPrint:Say  (2390,100 ,"Título transferido a favor do Banco ABC Brasil" ,oFont10)
  oPrint:Say  (2440,100 ,""                                             ,oFont10)
  oPrint:Say  (2490,100 ,"COBRAR JUROS DE R$"+AllTrim(Transform(aDadosTit[5]*5/100/30,"@E 999,999,999.99"))+" AO DIA"          ,oFont10)
Else
  oPrint:Say  (2340,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiário)",oFont8)
  oPrint:Say  (2390,100 ,""                                             ,oFont10)
  oPrint:Say  (2440,100 ,""                                             ,oFont10)
  oPrint:Say  (2490,100 ,"COBRAR JUROS DE R$"+AllTrim(Transform(aDadosTit[5]*5/100/30,"@E 999,999,999.99"))+" AO DIA"          ,oFont10)
EndIf
oPrint:Say  (2540,100 ,""   						   					,oFont10)
//oPrint:Say  (2590,100 ,"NÃO DEPOSITAR NA CONTA CORRENTE DO BOLETO",oFont10) // SUBSTITUIDO PELA LINHA ABAIXO CONFORME CHAMADO GLPI-6014 EM 11042018 POR GERALDO GOMES
oPrint:Say  (2590,100 ,"ATENÇÃO:O Depósito em conta corrente sem a devida autorização do cedente, não garante a quitação do débito!",oFont10)
oPrint:Say  (2640,100 ,""                                      			,oFont10)
oPrint:Say  (2690,100 ,""                                      			,oFont10)
oPrint:Say  (2740,100 ,""                                      			,oFont10)
oPrint:Say  (2790,100 ,""                                      			,oFont10)

oPrint:Say  (2340,1910,"(-)Desconto/Abatimento"                         ,oFont8)
If aDadosTit[15] > 0
	oPrint:Say  (2370,2010,AllTrim(Transform(aDadosTit[15],"@E 999,999,999.99")),oFont10)
Endif
oPrint:Say  (2410,1910,"(-)Outras Deduções"                             ,oFont8)
oPrint:Say  (2480,1910,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (2550,1910,"(+)Outros Acréscimos"                           ,oFont8)
oPrint:Say  (2620,1910,"(=)Valor Cobrado"                               ,oFont8)
if aDadosBanco[8] == '707' .or. aDadosBanco[8] == '033' .or. aDadosBanco[8] == '004' .or. aDadosBanco[8] == '104' .or.;
   aDadosBanco[8] == '998' .or. aDadosBanco[8] == '246' .or. aDadosBanco[8] == '637'
	oPrint:Say  (2690,100 ,"Pagador"                                        ,oFont8)
else
	oPrint:Say  (2690,100 ,"Sacado"                                         ,oFont8)
endif
oPrint:Say  (2720,100 ,aDatSacado[1]+" ("+aDatSacado[2]+") CPF: "+cCGC  ,oFont10)
oPrint:Say  (2773,100 ,aDatSacado[3]                                    ,oFont10)
oPrint:Say  (2826,100 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado
//oPrint:SayBitmap( 2720,1870,aBitMap[1],400,200 )
oPrint:Say  (2895,100 ,"Sacador/Avalista"                               ,oFont8)
If aDadosBanco[8] == '707'
  If aDatSacado[2] <> aDatAvalist[2]
    oPrint:Say  (2895,350 ,aDatAvalist[1]+" ("+aDatAvalist[2]+") CPF: "+cCGCA ,oFont10)
  EndIf                     
ElseIf aDadosBanco[8] == '998'   
  oPrint:Say  (2895,350 ,aDadosEmp[1]+"-"+aDadosEmp[6] ,oFont10)
Else
  oPrint:Say  (2895,350 ,aDatAvalist[1]+" ("+aDatAvalist[2]+") CPF: "+cCGCA ,oFont10)
EndIf
//oPrint:Say  (2895,505 ,""                                        ,oFont8)
oPrint:Say  (2935,1500,"Autenticação Mecânica -"                        ,oFont8)
oPrint:Say  (2935,1850,"Ficha de Compensação"                           ,oFont10)
oPrint:Line (2000,1900,2690,1900 )
oPrint:Line (2410,1900,2410,2300 )
oPrint:Line (2480,1900,2480,2300 )
oPrint:Line (2550,1900,2550,2300 )
oPrint:Line (2620,1900,2620,2300 )
oPrint:Line (2690,100 ,2690,2300 )
oPrint:Line (2940,100,2940,2300  )

MSBAR("INT25",25.5,1.5,CB_RN_NN[1],oPrint,.F.,,,0.025,1.3,,,,.F.)

For i := 100 to 2300 step 50
	oPrint:Line( 3230, i, 3230, i+30)
Next i

oPrint:EndPage() // Finaliza a página

Return Nil
//***************************************************************************************************************************************
// Boleto Caixa
//***************************************************************************************************************************************
Static Function Impr104(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN,aDatAvalist)
LOCAL oFont8
LOCAL oFont10
LOCAL oFont16
LOCAL oFont16n
LOCAL oFont24
LOCAL i := 0
//LOCAL aCoords1 := {0150,1900,0550,2300}
//LOCAL aCoords2 := {0450,1050,0550,1900}
//LOCAL aCoords3 := {0710,1900,0810,2300}
//LOCAL aCoords4 := {0980,1900,1050,2300}
//LOCAL aCoords5 := {1330,1900,1400,2300}
//LOCAL aCoords6 := {2000,1900,2100,2300}
//LOCAL aCoords7 := {2270,1900,2340,2300}
//LOCAL aCoords8 := {2620,1900,2690,2300}
LOCAL oBrush
LOCAL cCGC := ""
LOCAL cCGCA := ""

oBrushCinza := TBrush():New(,Rgb(214,214,214)) 
    
oFont8   := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont9n  := TFont():New("Arial",9,9 ,.T.,.F.,5,.T.,5,.T.,.F.) // Negrito
oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16  := TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.) //modificado de 16 para 12 JCNS
oFont16n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.) //modificado de 16 para 14 JCNS
oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10m := TFont():New("Arial",9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:StartPage()   // Inicia uma nova página
 
// Inicia aqui a alteracao para novo layout - RAI
// oPrint:Line (0150,550,0050, 550)
// oPrint:Line (0150,800,0050, 800)

// cBitMap        := "system\caixa.bmp"
// oPrint:SayBitmap(0045,100,cBitMap,400,110)	//															,oFont10 )  // [2]Nome do Banco

//oPrint:Say  (0062,567,aDadosBanco[1]																,oFont24 )  // [1]Numero do Banco
//oPrint:Say  (0084,1900,"Comprovante de Entrega"														,oFont10 )
//oPrint:Line (0150,100,0150,2300)
//DAYCOVAL E STD
//oPrint:Say  (0150,100 ,"Beneficiário"                                      						,oFont8	 )

//oPrint:Say  (0200,100 ,aDadosEmp[1]                                  								,oFont10m) //Nome + CNPJ
//oPrint:Say  (0150,1060,"Agência / Beneficiário"                         							,oFont8	 )

//oPrint:Say  (0200,1060,alltrim(aDadosBanco[3])+"/"+alltrim(cConvenio)+"-"+alltrim(CalDigCV(cConvenio))	,oFont10 )

//oPrint:Say  (0150,1510,"Nro.Documento"                                  							,oFont8  )
//oPrint:Say  (0200,1510,/*aDadosTit[7]+*/aDadosTit[1]                  								,oFont10 ) //Prefixo +Numero+Parcela
//DAYCOVAL, STD, BNBe CAIXA
//oPrint:Say  (0250,100 ,"Pagador"                                        						,oFont8  )

//oPrint:Say  (0300,100 ,SubsTr(aDatSacado[1],1,40)                 									,oFont10 ) //Nome + Codigo
//oPrint:Say  (0250,1060,"Vencimento"                                     							,oFont8  )
//oPrint:Say  (0300,1060,If((aDadosTit[4])=="11/11/11","C/Apresentação",(aDadosTit[4]))				,oFont10 )
//oPrint:Say  (0250,1510,"Valor do Documento"                             							,oFont8  )
//oPrint:Say  (0300,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99"))							,oFont10 )
//oPrint:Say  (0400,0100,"Recebi(emos) o bloqueto/título"                 							,oFont10 )
//oPrint:Say  (0450,0100,"com as características acima."                  							,oFont10 )
//oPrint:Say  (0350,1060,"Data"                                           							,oFont8  )
//oPrint:Say  (0350,1410,"Assinatura"                                  								,oFont8  )
//oPrint:Say  (0450,1060,"Data"                                           							,oFont8  )
//oPrint:Say  (0450,1410,"Entregador"                                  								,oFont8  )

//oPrint:Line (0250, 100,0250,1900 )
//oPrint:Line (0350, 100,0350,1900 )
//oPrint:Line (0450,1050,0450,1900 ) //---
//oPrint:Line (0550, 100,0550,2300 )

//oPrint:Line (0550,1050,0150,1050 )
//oPrint:Line (0550,1400,0350,1400 )
//oPrint:Line (0350,1500,0150,1500 ) //--
//oPrint:Line (0550,1900,0150,1900 )

//oPrint:Say  (0160,1910,"(  )Mudou-se"                                   ,oFont8)
//oPrint:Say  (0200,1910,"(  )Ausente"                                    ,oFont8)
//oPrint:Say  (0240,1910,"(  )Não existe nº indicado"                     ,oFont8)
//oPrint:Say  (0280,1910,"(  )Recusado"                                   ,oFont8)
//oPrint:Say  (0320,1910,"(  )Não procurado"                              ,oFont8)
//oPrint:Say  (0360,1910,"(  )Endereço insuficiente"                   	,oFont8)
//oPrint:Say  (0400,1910,"(  )Desconhecido"                               ,oFont8)
//oPrint:Say  (0440,1910,"(  )Falecido"                                   ,oFont8)
//oPrint:Say  (0480,1910,"(  )Outros(anotar no verso)"                    ,oFont8)

//For i := 100 to 2300 step 50
//	oPrint:Line( 0600, i, 0600, i+30)
//Next i

oPrint:FillRect({0810, 1000, 0910 ,1900}, oBrushCinza)

oPrint:Line (0710, 100, 0710, 2300)
oPrint:Line (0710, 550, 0610,  550)
oPrint:Line (0710, 800, 0610,  800)

cBitMap        := "system\caixa.bmp"
oPrint:SayBitmap(0600,100,cBitMap,400,110)	//															,oFont10 )  // [2]Nome do Banco

//oPrint:Say  (0644,100,aDadosBanco[2],oFont10 )  // [2]Nome do Banco
oPrint:Say  (0622,567,aDadosBanco[1],oFont24 )  // [1]Numero do Banco
//oPrint:Say  (0644,1900,"Recibo do Sacado",oFont10)
oPrint:Say  (0644,820,CB_RN_NN[2],oFont16n)     //Linha Digitavel do Codigo de Barras

oPrint:Line (0810,100,0810,2300 )
oPrint:Line (0910,100,0910,2300 )
oPrint:Line (1010,100,1010,2300 )
oPrint:Line (1110,100,1110,2300 )
oPrint:Line (1210,100,1210,1480 ) // Penultima Linha horizontal
//oPrint:Line (1310,100,1310,2300 )


nYCIP := 370
nYNossoNum := 1910
cNumCIP := "504"

If Len(AllTrim(aDatSacado[7]))==11
	cCGC := cCGC + SubsTr(AllTrim(aDatSacado[7]),1,3)+"."
	cCGC := cCGC + SubsTr(AllTrim(aDatSacado[7]),4,3)+"."
	cCGC := cCGC + SubsTr(AllTrim(aDatSacado[7]),7,3)+"-"
	cCGC := cCGC + SubsTr(AllTrim(aDatSacado[7]),10,2)
Elseif Len(AllTrim(aDatSacado[7]))==14
	cCGC := cCGC + SubsTr(AllTrim(aDatSacado[7]),1,2)+"."
	cCGC := cCGC + SubsTr(AllTrim(aDatSacado[7]),3,3)+"."
	cCGC := cCGC + SubsTr(AllTrim(aDatSacado[7]),6,3)+"/"
	cCGC := cCGC + SubsTr(AllTrim(aDatSacado[7]),9,4)+"-"
	cCGC := cCGC + SubsTr(AllTrim(aDatSacado[7]),13,2)
Endif

oPrint:Line (0810,  500,  910,  500 )
//oPrint:Line (0810,  750,  910,  750 )
oPrint:Line (0810, 1000,  910, 1000 )
oPrint:Line (0810, 1400,  910, 1400 )
//oPrint:FillRect({0810, 1000, 0910 ,1900}, oBrushCinza)
//oPrint:Line (0910, 1400, 1050, 1400 )

cDVNN := U_CalcDig(alltrim(cConvenio)+cNroDoc)

oPrint:Say  (0710,100 ,"Pagador"                             		            				,oFont8 )
oPrint:Say  (0770,100 ,Alltrim(aDatSacado[1]+" ("+aDatSacado[2]+")" )				                                    ,oFont10)

oPrint:Say  (0710,1910,"CPF/CNPJ do Pagador"                                     	            ,oFont8 )
oPrint:Say  (0770,1950,Alltrim(cCGC)    											            ,oFont10)

oPrint:Say  (0810,100,"Nosso Número"                                   						    ,oFont8 )
oPrint:Say  (0870,100,alltrim(aDadosTit[6])												        ,oFont10)

oPrint:Say  (0810,505 ,"Nro.Documento"                                  						,oFont8 )
oPrint:Say  (0870,520 ,aDadosTit[1]                  							                ,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (0810,1005,"Vencimento"                                   						    ,oFont8 )
oPrint:Say  (0870,1050,aDadosTit[4]																,oFont10) //Tipo do Titulo

oPrint:Say  (0810,1410,"Valor do Documento"                             						 ,oFont8 )
//oPrint:Say  (0870,1460,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99"))						 ,oFont10)
oPrint:Say  (0870,1710,Transform(aDadosTit[5],"@E 999,999,999.99")						 ,oFont10)

oPrint:Say  (0810,1910,"Valor Cobrado"                                   						 ,oFont8 )

oPrint:Say  (0910,100  ,"Beneficiário"                                        					 ,oFont8 )
oPrint:Say  (0910,1910 ,"CPF/CNPJ do Beneficiário"                                        		 ,oFont8 )
oPrint:Say  (0970,100  ,Alltrim(aDadosEmp[1])													 ,oFont10) //Nome
oPrint:Say  (0970,1950 ,substr(Alltrim(aDadosEmp[6]),11,len(Alltrim(aDadosEmp[6])))				 ,oFont10) //CNPJ

oPrint:Say  (1010,100 ,"Endereço do Beneficiário"                         					     ,oFont8 )       // Geraldo em 25/04/2017
oPrint:Say  (1070,100 ,Alltrim(aDadosEmp[2])+","+Alltrim(aDadosEmp[3])+","+Alltrim(aDadosEmp[4]) ,oFont10) //Endereço + Complemento + CEP

oPrint:Say  (1110,100,"Agência/ Código do Beneficiário"                         						,oFont8 )       // Geraldo em 25/04/2017
oPrint:Say  (1170,100,alltrim(aDadosBanco[3])+"/"+alltrim(cConvenio)+"-"+alltrim(CalDigCV(cConvenio))	,oFont10 )


//Dados do Avalista
If Len(AllTrim(aDatAvalist[7]))==11
	cCGCA := cCGCA + SubsTr(AllTrim(aDatAvalist[7]),1,3)+"."
	cCGCA := cCGCA + SubsTr(AllTrim(aDatAvalist[7]),4,3)+"."
	cCGCA := cCGCA + SubsTr(AllTrim(aDatAvalist[7]),7,3)+"-"
	cCGCA := cCGCA + SubsTr(AllTrim(aDatAvalist[7]),10,2)
Elseif Len(AllTrim(aDatAvalist[7]))==14
	cCGCA := cCGCA + SubsTr(AllTrim(aDatAvalist[7]),1,2)+"."
	cCGCA := cCGCA + SubsTr(AllTrim(aDatAvalist[7]),3,3)+"."
	cCGCA := cCGCA + SubsTr(AllTrim(aDatAvalist[7]),6,3)+"/"
	cCGCA := cCGCA + SubsTr(AllTrim(aDatAvalist[7]),9,4)+"-"
	cCGCA := cCGCA + SubsTr(AllTrim(aDatAvalist[7]),13,2)
Endif

oPrint:Say  (1260,100,"SAC CAIXA: 0800 726 0101 (informações, reclamações, sugestões e elogios)",oFont10)

oPrint:Say  (1310,100,"Para pessoas com deficiência auditiva ou de fala: 0800 726 2492",oFont10)
oPrint:Say  (1360,100,"Ouvidoria: 0800 725 7474",oFont10)
  
oPrint:Say  (1410,100,"caixa.gov.br" , oFont10)

oPrint:Say  (1110,1550,"Autenticação Mecânica -"                     ,oFont8)
oPrint:Say  (1110,1900,"Recibo do Pagador"                           ,oFont10)

oPrint:Line (0710, 1900, 1010, 1900 )
oPrint:Line (1110, 1480, 1640, 1480 ) // Linha vertical que une a última linha do recibo pagador a linha abaixo do endereço do beneficiário.
//oPrint:Line (1120,1900,1120,2300 )
//oPrint:Line (1190,1900,1190,2300 )

//oPrint:Line (1260,100 ,1260,1900 ) // Dados do SAC

//oPrint:Line (1260,1900,1260,2300 )
//oPrint:Line (1330,1900,1330,2300 )
//oPrint:Line (1400,100 ,1400,2300 )
oPrint:Line (1640,100 ,1640,2300 )

For i := 100 to 2300 step 50
	oPrint:Line( 1810, i, 1810, i+30)
Next i

// Encerra aqui a alteracao para o novo layout - RAI

oPrint:Line (2000,100,2000,2300)
oPrint:Line (2000,550,1900, 550)
oPrint:Line (2000,800,1900, 800)
If aDadosBanco[8] == '104'
  cBitMap        := "system\caixa.bmp"
  oPrint:SayBitmap(1888,100,cBitMap,400,110)	//															,oFont10 )  // [2]Nome do Banco
Else
  oPrint:Say  (1934,100,aDadosBanco[2],oFont10 )  // [2]Nome do Banco
//  oPrint:Say  (1934,100,aDadosBanco[2],oFont10 )  // [2]Nome do Banco
EndIf
//oPrint:Say  (1934,100,aDadosBanco[2],oFont10 )  // [2]Nome do Banco
oPrint:Say  (1912,567,aDadosBanco[1],oFont24 )  // [1]Numero do Banco
oPrint:Say  (1934,820,CB_RN_NN[2],oFont16n)     //Linha Digitavel do Codigo de Barras

oPrint:Line (2100,  100, 2100, 2300 )
oPrint:Line (2200,  100, 2200, 2300 )
oPrint:Line (2270,  100, 2270, 2300 )
oPrint:Line (2340,  100, 2340, 2300 )

oPrint:Line (2200,  500, 2340,  500 )
oPrint:Line (2270,  750, 2340,  750 )
oPrint:Line (2200, 1000, 2340, 1000 )
oPrint:Line (2200, 1350, 2270, 1350 )
oPrint:Line (2200, 1550, 2340, 1550 )

oPrint:Say  (2000,100 ,"Local de Pagamento"                        ,oFont8)
if aDadosBanco[8] == '104'
  oPrint:Say  (2040,100 ,"PREFERENCIALMENTE NAS CASAS LOTERICAS ATE O VALOR LIMITE"				,oFont10)
Else
  oPrint:Say  (2020,400 ,"PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO",oFont10)
EndIf
//oPrint:Say  (2020,400 ,"PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO",oFont10)
oPrint:Say  (2050,400 ,"                                          ",oFont10)

oPrint:Say  (2000,1910,"Vencimento"                                     ,oFont8)
oPrint:Say  (2040,2010,If((aDadosTit[4])=="11/11/11","C/Apresentação",(aDadosTit[4])),oFont10)

if aDadosBanco[8] == '707' .or. aDadosBanco[8] == '033' .or. aDadosBanco[8] == '004' .or. aDadosBanco[8] == '104' //DAYCOVAL
	oPrint:Say  (2100,100 ,"Beneficiário"                                   ,oFont8)
else
	oPrint:Say  (2100,100 ,"Cedente"                                        ,oFont8)
endif
if aDadosBanco[8] == '104'
   oPrint:Say  (2109,240 ,Alltrim(aDadosEmp[1])+" - "+Alltrim(aDadosEmp[6])						,oFont10) //Nome + CNPJ
   oPrint:Say  (2155,100 ,Alltrim(aDadosEmp[2])+","+Alltrim(aDadosEmp[3])+","+Alltrim(aDadosEmp[4]) 	,oFont10) //Endereço + Complemento + CEP
Else
   oPrint:Say  (2140,100 ,aDadosEmp[1]+" - "+aDadosEmp[6] 											,oFont10) //Nome + CNPJ   
EndIf

//oPrint:Say  (2140,100 ,aDadosEmp[1]+" - "+aDadosEmp[6] ,oFont10) //Nome + CNPJ

oPrint:Say  (2100,1910,"Agência / Beneficiário"                         ,oFont8)     //geraldo 25/04/2017
if  aDadosBanco[8] == '033'
	oPrint:Say  (2140,1980,alltrim(aDadosBanco[3])+" - "+alltrim(aDadosBanco[7])+"/"+alltrim(cConvenio)	,oFont10 )
ElseIf aDadosBanco[8] == '637'
	oPrint:Say  (2140,1980,alltrim(aDadosBanco[3])+" - "+alltrim(aDadosBanco[7])+"/"+alltrim(cConvenio)	,oFont10 )
ElseIf aDadosBanco[8] == '004'
	oPrint:Say  (2140,1980,alltrim(aDadosBanco[3])+"/"+alltrim(aDadosBanco[4])+"-"+alltrim(aDadosBanco[5])	,oFont10 )
ElseIf aDadosBanco[8] == '104'
//	oPrint:Say  (0200,1060,alltrim(aDadosBanco[3])+"/"+alltrim(cConvenio)+"-"+alltrim(CalDigCV(cConvenio))	,oFont10 )
	oPrint:Say  (2140,1980,alltrim(aDadosBanco[3])+"/"+alltrim(cConvenio)+"-"+alltrim(CalDigCV(cConvenio))	,oFont10 )
else
	oPrint:Say  (2140,1980,alltrim(aDadosBanco[3])+" - "+alltrim(aDadosBanco[7])+"/"+alltrim(aDadosBanco[4])+" - "+alltrim(aDadosBanco[5])	,oFont10 )
endif
oPrint:Say  (2200,100 ,"Data do Documento"                              ,oFont8)
oPrint:Say  (2230,100 ,DTOC(aDadosTit[2])                               ,oFont10) // Emissao do Titulo (E1_EMISSAO)

oPrint:Say  (2200,505 ,"Nro.Documento"                                  ,oFont8)
oPrint:Say  (2230,605 ,/*aDadosTit[7]+*/aDadosTit[1]                  		,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (2200,1005,"Espécie Doc."                                   ,oFont8)
oPrint:Say  (2230,1050,"DM"     ,oFont10) //Tipo do Titulo

oPrint:Say  (2200,1355,"Aceite"                                         ,oFont8)
oPrint:Say  (2230,1455,"N"                                              ,oFont10)

oPrint:Say  (2200,1555,"Data do Processamento"                          ,oFont8)
oPrint:Say  (2230,1655,DTOC(aDadosTit[3])                               ,oFont10) // Data impressao

oPrint:Say  (2200,1910,"Nosso Número"                                   ,oFont8)

If aDadosBanco[8] == '707'              //DAYCOVAL
	oPrint:Line (2270,nYCIP,2340,nYCIP) //linha CIP
	oPrint:Say  (2230,1910,alltrim(aDadosBanco[6])+'/'+substr(alltrim(aDadosTit[6]),3,len(alltrim(aDadosTit[6]))),oFont10)
	oPrint:Say  (2270,nYCIP+5 	,"CIP"    	                             ,oFont8)
	oPrint:Say  (2300,nYCIP+50 	,cNumCIP	                             ,oFont10)
elseif aDadosBanco[8] == '033'
	oPrint:Say  (2230,1960,alltrim(aDadosTit[6]),oFont10)
elseif aDadosBanco[8] == '637'
	oPrint:Say  (2230,1960,alltrim(aDadosTit[6]),oFont10)
elseif  aDadosBanco[8] == '004'
	oPrint:Say  (2230,1960,alltrim(aDadosTit[6])+Space(10)+aDadosBanco[6],oFont10)
elseif  aDadosBanco[8] == '104'
	oPrint:Say  (2230,1945,alltrim(aDadosTit[6])				 ,oFont10)
else
  oPrint:Say  (2230,1960,alltrim(cConvenio)+cNroDoc/*+"-"+cDVNN*/,oFont10)
endif

oPrint:Say  (2270,100 ,"Uso do Banco"                                    ,oFont8)
if aDadosBanco[8] = '707' //DAYCOVAL
	oPrint:Say  (2300,155 ,"8600"                                        ,oFont10)
endif

oPrint:Say  (2270,505 ,"Carteira"                                        ,oFont8)
if  aDadosBanco[8] == '104'
   oPrint:Say  (2300,555 ,"RG" 				                             ,oFont10)
Else
   oPrint:Say  (2300,555 ,aDadosBanco[6]                                 ,oFont10)
EndIf

oPrint:Say  (2270,755 ,"Espécie"                                         ,oFont8)
oPrint:Say  (2300,805 ,"R$"                                              ,oFont10)

oPrint:Say  (2270,1005,"Quantidade"                                      ,oFont8)
oPrint:Say  (2270,1555,"Valor"                                           ,oFont8)

oPrint:Say  (2270,1910,"Valor do Documento"                             ,oFont8)
oPrint:Say  (2300,2010,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

oPrint:Say  (2340,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiário)",oFont8)
oPrint:Say  (2390,100 ,""                                               ,oFont10)
oPrint:Say  (2440,100 ,""                                               ,oFont10)
oPrint:Say  (2490,100 ,"COBRAR JUROS DE R$"+AllTrim(Transform(aDadosTit[5]*5/100/30,"@E 999,999,999.99"))+" AO DIA"          ,oFont10)
oPrint:Say  (2540,100 ,""   						   ,oFont10)
//oPrint:Say  (2590,100 ,"NÃO DEPOSITAR NA CONTA CORRENTE DO BOLETO",oFont10) // SUBSTITUIDO PELA LINHA ABAIXO CONFORME CHAMADO GLPI-6014 EM 11042018 POR GERALDO GOMES
oPrint:Say  (2590,100 ,"ATENÇÃO:O Depósito em conta corrente sem a devida autorização do cedente, não garante a quitação do débito!",oFont10)
oPrint:Say  (2640,100 ,""                                      ,oFont10)
oPrint:Say  (2690,100 ,""                                      ,oFont10)
oPrint:Say  (2740,100 ,""                                      ,oFont10)
oPrint:Say  (2790,100 ,""                                      ,oFont10)

oPrint:Say  (2340,1910,"(-)Desconto/Abatimento"                         ,oFont8)
If aDadosTit[15] > 0
	oPrint:Say  (2370,2010,AllTrim(Transform(aDadosTit[15],"@E 999,999,999.99")),oFont10)
Endif
oPrint:Say  (2410,1910,"(-)Outras Deduções"                             ,oFont8)
oPrint:Say  (2480,1910,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (2550,1910,"(+)Outros Acréscimos"                           ,oFont8)
oPrint:Say  (2620,1910,"(=)Valor Cobrado"                               ,oFont8)
if aDadosBanco[8] == '707' .or. aDadosBanco[8] == '033' .or. aDadosBanco[8] == '004' .or. aDadosBanco[8] == '104'
	oPrint:Say  (2690,100 ,"Pagador"                                        ,oFont8)
else
	oPrint:Say  (2690,100 ,"Sacado"                                         ,oFont8)
endif
oPrint:Say  (2720,100 ,aDatSacado[1]+" ("+aDatSacado[2]+") CPF: "+cCGC  ,oFont10)
oPrint:Say  (2773,100 ,aDatSacado[3]                                    ,oFont10)
oPrint:Say  (2826,100 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado
//oPrint:SayBitmap( 2720,1870,aBitMap[1],400,200 )
oPrint:Say  (2895,100 ,"Sacador/Avalista"                               ,oFont8)
oPrint:Say  (2895,350 ,aDatAvalist[1]+" ("+aDatAvalist[2]+") CNPJ/CPF: "+cCGCA ,oFont10)
//oPrint:Say  (2895,505 ,""                                        ,oFont8)
oPrint:Say  (2935,1500,"Autenticação Mecânica -"                        ,oFont8)
oPrint:Say  (2935,1850,"Ficha de Compensação"                           ,oFont10)
oPrint:Line (2000,1900,2690,1900 )
oPrint:Line (2410,1900,2410,2300 )
oPrint:Line (2480,1900,2480,2300 )
oPrint:Line (2550,1900,2550,2300 )
oPrint:Line (2620,1900,2620,2300 )
oPrint:Line (2690,100 ,2690,2300 )
oPrint:Line (2940,100,2940,2300  )

MSBAR("INT25",25.5,1.5,CB_RN_NN[1],oPrint,.F.,,,0.025,1.3,,,,.F.)	

For i := 100 to 2300 step 50
	oPrint:Line( 3230, i, 3230, i+30)
Next i

oPrint:EndPage() // Finaliza a página

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
?????????????????????????????????????????????????????????????????????????????
??ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ???
???Programa  ? Modulo10  ? Autor ?                      ? Data ?          ???
??ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ???
???Descri??o ? IMPRESSAO DO BOLETO LASE DO B.BRASIL COM CODIGO DE BARRAS  ???
??ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ???
???Uso       ? Especifico para Clientes Microsiga                         ???
??ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ??
?????????????????????????????????????????????????????????????????????????????
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Modulo10(cData)
LOCAL L, D, P, nInt := 0
L := Len(cdata)
D := 0
P := 2
N := 0
nMult := 10

While L > 0
	N := (Val(SubStr(cData, L, 1)) * P)
	If N > 9
		D := D + (Val(SubsTr(Str(N,2),1,1)) + Val(SubsTr(Str(N,2),2,1)))
	Else
		D := D + N
	Endif
	If P = 2
		P := 1
	Elseif P = 1
		P := 2
	EndIf
	L := L - 1
End

While nMult < D
	nMult := nMult + 10
endDo
//D := Mod(D,10)
D := nMult - D

If D == 10
	D:=0
Endif

Return(D)

Static Function Mod10ABC(cData)
LOCAL L, D, P, _nResto, nInt := 0
L := Len(cdata)   // Tamanho do Campo
D := 0
P := 2            // Peso
N := 0
nMult := 10

While L > 0
	N := (Val(SubStr(cData, L, 1)) * P)
	// Soma os Dígitos, quando o resultado da multiplicação for igual ou maior que 10
	If N > 9
		D := D + (Val(SubsTr(Str(N,2),1,1)) + Val(SubsTr(Str(N,2),2,1)))
	Else
		D := D + N
	Endif                                                                            
	
	If P = 2
		P := 1
	Elseif P = 1
		P := 2
	EndIf
	L := L - 1
End

_nResto := (D%10)

D := 10 - _nResto

If D == 10
	D := 0
Endif

Return(D)
// Cálculo Dìgito Campo Linha Digitável - Módulo 10 - Caixa Econômica Federal
Static Function Mod10CEF(cData)
LOCAL L, D, P, _nResto, nInt := 0
L := Len(cdata)   // Tamanho do Campo
D := 0
P := 2            // Peso
N := 0
nMult := 10

While L > 0
	N := (Val(SubStr(cData, L, 1)) * P)
	// Soma os Dígitos, quando o resultado da multiplicação for igual ou maior que 10
	If N > 9
		D := D + (Val(SubsTr(Str(N,2),1,1)) + Val(SubsTr(Str(N,2),2,1)))
	Else
		D := D + N
	Endif                                                                            
	
	If P = 2
		P := 1
	Elseif P = 1
		P := 2
	EndIf
	L := L - 1
End

//While nMult < D
//	nMult := nMult + 10
//endDo

//D := Mod(D,10)
_nResto := (D%10)

D := 10 - _nResto

If D == 10
	D := 0
Endif

Return(D)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
?????????????????????????????????????????????????????????????????????????????
??ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ???
???Programa  ? Mod11Day ? Autor ?                       ? Data ?          ???
??ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ???
???Descri??o ? IMPRESSAO DO BOLETO LASE DO B.BRASIL COM CODIGO DE BARRAS  ???
??ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ???
???Uso       ? Especifico para Clientes Microsiga                         ???
??ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ??
?????????????????????????????????????????????????????????????????????????????
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function Mod11Day(_cCampo) //Modulo 11 com base 7
Local _nCnt       := 0
Local _nPeso      := 2
Local _nJ         := 1
Local _nResto     := 0
Local aItem       := {}
Local _cCampo1    := ""
Local nPeso   := 7

For _nJ := Len(_cCampo) To 1 Step -1
	_nCnt  := _nCnt + Val(SUBSTR(_cCampo,_nJ,1))*_nPeso
	_nPeso :=_nPeso+1
	if _nPeso > nPeso
		_nPeso := 2
	endif
Next _nJ

_nResto:=(_ncnt%11)

If _nResto == 1
	_nDigbar:='P'
elseif _nResto == 0
	_nDigbar:='0'
else
	_nResto:=11 - _nResto
	_nDigbar:=Str(_nResto,1)
endif

cRet := _nDigbar

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
?????????????????????????????????????????????????????????????????????????????
??ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ???
???Programa  ? Mod11BNB ? Autor ?                       ? Data ?          ???
??ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ???
???Descri??o ? IMPRESSAO DO BOLETO LASE DO BNB COM CODIGO DE BARRAS  ???
??ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ???
???Uso       ? Especifico para Clientes Microsiga                         ???
??ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ??
?????????????????????????????????????????????????????????????????????????????
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function Mod11BNB(_cCampo) //Modulo 11 com base 7
Local _nCnt       := 0
Local _nPeso      := 2
Local _nJ         := 1
Local _nResto     := 0
Local aItem       := {}
Local _cCampo1    := ""
Local nPeso   := 7

For _nJ := Len(_cCampo) To 1 Step -1
	_nCnt  := _nCnt + Val(SUBSTR(_cCampo,_nJ,1))*_nPeso
	_nPeso :=_nPeso+1
	if _nPeso > nPeso
		_nPeso := 2
	endif
Next _nJ

_nResto:=(_ncnt%11)

If _nResto == 1
	_nDigbar:='0'
elseif _nResto == 0
	_nDigbar:='0'
else
	_nResto:=11 - _nResto
	_nDigbar:=Str(_nResto,1)
endif

cRet := _nDigbar

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
?????????????????????????????????????????????????????????????????????????????
??ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ???
???Programa  ? Mod11CB  ? Autor ?                       ? Data ?          ???
??ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ???
???Descri??o ? IMPRESSAO DO BOLETO LASE DO B.BRASIL COM CODIGO DE BARRAS  ???
??ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ???
???Uso       ? Especifico para Clientes Microsiga                         ???
??ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ??
?????????????????????????????????????????????????????????????????????????????
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Mod11CB(cData) // Modulo 11 com base 9

LOCAL CBL, CBD, CBP := 0
CBL := Len(cdata)
CBD := 0
CBP := 1

While CBL > 0
	CBP := CBP + 1
	CBD := CBD + (Val(SubStr(cData, CBL, 1)) * CBP)
	If CBP = 9
		CBP := 1
	Endif
	CBL := CBL - 1
Enddo
_nCBResto := mod(CBD,11)  //Resto da Divisao
CBD := 11 - _nCBResto
If (CBD == 0 .Or. CBD == 10 .Or. CBD == 11)
	CBD := 1
EndIf

Return(CBD)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
?????????????????????????????????????????????????????????????????????????????
??ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ???
???Programa  ? CalDigCL ? Autor ?                       ? Data ?          ???
??ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ???
???Descri??o ? 
??ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ???
???Uso       ? Especifico para Clientes Microsiga                         ???
??ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ??
?????????????????????????????????????????????????????????????????????????????
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalDigCL(_cCampo) //Modulo 11 com base 9 / Cobrança Caixa CEF-104
Local _nCnt       := 0
Local _nPeso      := 2
Local _nJ         := 1
Local _nResto     := 0
Local aItem       := {}
Local _cCampo1    := ""
Local nPeso       := 9

For _nJ := Len(_cCampo) To 1 Step -1
	_nCnt  := _nCnt + Val(SUBSTR(_cCampo,_nJ,1))*_nPeso
	_nPeso :=_nPeso+1
	if _nPeso > nPeso
		_nPeso := 2
	endif
Next _nJ

_nResto:=(_ncnt%11)

If (11 - _nResto) > 9
  _nDigbar   := '0'
else
  _nResto  := 11 - _nResto
  _nDigbar := Str(_nResto,1)
endif

cRet := _nDigbar

Return(cRet)

Static Function CalDigDG(_cCampo) // Digito Geral Código de Barras //Modulo 11 com base 9 / Cobrança Caixa CEF-104
Local _nCnt       := 0
Local _nPeso      := 2
Local _nJ         := 1
Local _nResto     := 0
Local aItem       := {}
Local _cCampo1    := ""
Local nPeso       := 9
_cQuery := "Campo => "+_cCampo + chr(13)+chr(10)
For _nJ := Len(_cCampo) To 1 Step -1            
	_nCnt  := _nCnt + Val(SUBSTR(_cCampo,_nJ,1))*_nPeso
    _cQuery += "CampoDig/Peso/Soma => (" + SUBSTR(_cCampo,_nJ,1) + ") / (" + AllTrim(Str(_nPeso)) + ") / (" + AllTrim(Str(_nCnt)) + ")" + chr(13)+chr(10)
	_nPeso :=_nPeso+1
	if _nPeso > nPeso
		_nPeso := 2
	endif
Next _nJ
_cQuery += "Soma => " + AllTrim(Str(_nCnt)) + chr(13)+chr(10)

_nResto:=(_ncnt%11)
_cQuery += "Resto => " + AllTrim(Str(_nResto)) + chr(13)+chr(10)

If (11 - _nResto) = 0
  _nDigbar   := '1'  
ElseIf (11 - _nResto) > 9  
  _nDigbar   := '1'  
else
  _nResto  := 11 - _nResto
  _nDigbar := Str(_nResto,1)
endif
_cQuery += "Digito => " + AllTrim(_nDigbar) + chr(13)+chr(10)

Memowrite("\LOG\OPOR\DIG" + _cCampo + ".TXT",_cQuery) 		

cRet := _nDigbar

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
?????????????????????????????????????????????????????????????????????????????
??ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ???
???Programa  ? CalDigCV ? Autor ?                       ? Data ?          ???
??ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ???
???Descri??o ? IMPRESSAO DO BOLETO LASE DO BNB COM CODIGO DE BARRAS  ???
??ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ???
???Uso       ? Especifico para Clientes Microsiga                         ???
??ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ??
?????????????????????????????????????????????????????????????????????????????
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalDigCV(_cCampo) //Calcula Digito do Convênio da CEF
Local _nCnt       := 0
Local _nPeso      := 2
Local _nJ         := 1
Local _nResto     := 0
Local aItem       := {}
Local _cCampo1    := ""
Local nPeso       := 7

For _nJ := Len(_cCampo) To 1 Step -1
	_nCnt  := _nCnt + Val(SUBSTR(_cCampo,_nJ,1))*_nPeso
	_nPeso :=_nPeso+1
	if _nPeso > nPeso
		_nPeso := 2
	endif
Next _nJ

_nResto:=(_ncnt%11)
_nResto:= 11 - _nResto

If _nResto > 9
	_nDigbar := 0
endif
_nDigbar:=Str(_nResto,1)

cRet := _nDigbar

Return(cRet)

//Retorna os strings para inpressão do Boleto
//CB = String para o cód.barras, RN = String com o número digitável
//Cobrança não identificada, número do boleto = Título + Parcela
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
?????????????????????????????????????????????????????????????????????????????
??ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ???
???Programa  ?Ret_cBarra ?Autor ?                       ? Data ?          ???
??ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ???
?????????????????????????????????????????????????????????????????????????????
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ret_cBar001(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor,cConvenio)

LOCAL bldocnufinal := AllTrim(cNroDoc)
LOCAL blvalorfinal := strzero(nValor*100,10)
LOCAL dvnn         := 0
LOCAL dvcb         := 0
LOCAL dv           := 0
LOCAL NN           := ''
LOCAL RN           := ''
LOCAL CB           := ''
LOCAL s            := ''
Local dDtBase     := ctod("07/10/1997")
Local cFatorVencto := ""
LOCAL cBanB		   := cBanco

//Calculo do Fator de Vencimento do Titulo
cFatorVencto := Str(SE1->E1_VENCREA - dDtBase,4)

//Montagem no NOSSO NUMERO
snn  := alltrim(cConvenio)+bldocnufinal     // Convenio + Nosso Numero

//dvnn := CalcDig(snn)  // Digito verificador no Nosso Numero
NN   := snn//+" - "+dvnn//BlDocNuFinal //+ AllTrim(Str(dvnn))

//Codigo de Barras
scb  := cBanB + "9" + cFatorVencto + blvalorfinal + "000000" + snn + "17"
dvcb := mod11CB(scb) //digito verificador do codigo de barras
CB   := SubStr(scb,1,4)+AllTrim(Str(dvcb))+SubStr(scb,5,39)

//LINHA DIGITAVEL
//CAMPO 1
srn:= substr(CB,1,3)+substr(CB,4,1)+substr(CB,20,5)
dv := modulo10(srn)
RN := SubStr(srn, 1, 5) + '.' + SubStr(srn,6,4)+AllTrim(Str(dv))+' '

//CAMPO 2
srn:= substr(CB,25,10)
dv := modulo10(srn)
RN := RN + SubStr(srn,1,5)+'.'+SubStr(srn,6,5)+AllTrim(Str(dv))+' '

//CAMPO 3
srn:=substr(CB,35,10)
dv := modulo10(srn)
RN := RN + SubStr(srn,1,5)+'.'+SubStr(srn,6,5)+AllTrim(Str(dv)) + ' '

//CAMPO 4
RN := RN + ' ' + substr(CB,5,1) + ' '

//CAMPO 5
RN := RN + substr(CB,6,4)+substr(CB,10,10)

Return({CB,RN,NN})

//Retorna os strings para inpressão do Boleto
//CB = String para o cód.barras, RN = String com o número digitável
//Cobrança não identificada, número do boleto = Título + Parcela
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Ret_cBarra ³Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ret_cBar237(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor,cConvenio)

LOCAL bldocnufinal := AllTrim(cNroDoc)
LOCAL blvalorfinal := strzero(nValor*100,10)
LOCAL dvnn         := 0
LOCAL dvcb         := 0
LOCAL dv           := 0
LOCAL NN           := ''
LOCAL RN           := ''
LOCAL CB           := ''
LOCAL s            := ''
Local dDtBase     := ctod("07/10/1997")
Local cFatorVencto := ""
LOCAL cBanB		   := cBanco
Local cCmpLv	   := ""
	
//Calculo do Fator de Vencimento do Titulo
cFatorVencto := Str(SE1->E1_VENCREA - dDtBase,4)

//Montagem no NOSSO NUMERO
snn  := alltrim(cCarteira)+bldocnufinal     // Convenio + Nosso Numero

dvnn := Alltrim(u_Mod11Day(snn))  // Digito verificador no Nosso Numero
NN   := snn+" - "+dvnn

cCmpLv := strzero(Val(cAgencia),4) + alltrim(cCarteira) + bldocnufinal + strzero(Val(cConta),7)+"0"

//Codigo de Barras
//scb  := cBanB + "9" + cFatorVencto + blvalorfinal + strzero(Val(cAgencia),4)+ snn + strzero(Val(cConta),7)+"0"
scb  := cBanB + "9" + cFatorVencto + blvalorfinal + cCmpLv
dvcb := mod11CB(scb) //digito verificador do codigo de barras
CB   := SubStr(scb,1,4)+AllTrim(Str(dvcb))+SubStr(scb,5,39)

//LINHA DIGITAVEL
//CAMPO 1
srn:= substr(CB,1,3)+substr(CB,4,1)+substr(CB,20,5)
dv := modulo10(srn)
RN := SubStr(srn, 1, 5) + '.' + SubStr(srn,6,4)+AllTrim(Str(dv))+' '

//CAMPO 2
srn:= substr(CB,25,10)
dv := modulo10(srn)
RN := RN + SubStr(srn,1,5)+'.'+SubStr(srn,6,5)+AllTrim(Str(dv))+' '

//CAMPO 3
//srn:=substr(CB,35,10)
srn:=substr(cCmpLv,16,10)
dv := modulo10(srn)
RN := RN + SubStr(srn,1,5)+'.'+SubStr(srn,6,5)+AllTrim(Str(dv)) + ' '

//CAMPO 4
RN := RN + ' ' + substr(CB,5,1) + ' '

//CAMPO 5
RN := RN + substr(CB,6,4)+substr(CB,10,10)

Return({CB,RN,NN})

//User Function Ret_cBar707(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor,cConvenio, pcOpera)
User Function RBar707(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor,cConvenio, pcOpera)

LOCAL bldocnufinal := AllTrim(cNroDoc)
LOCAL blvalorfinal := strzero(nValor*100,10)
LOCAL dvnn         := 0
LOCAL dvcb         := 0
LOCAL dv           := 0
LOCAL NN           := ''
LOCAL RN           := ''
LOCAL CB           := ''
LOCAL s            := ''
Local dDtBase     := ctod("07/10/1997")
Local cFatorVencto := ""
LOCAL cBanB		   := cBanco
Local cCmpLv	   := ""
//Local cOperac	   := "1416966"
Local cOperac	   := pcOpera
	
//Calculo do Fator de Vencimento do Titulo
cFatorVencto := Str(SE1->E1_VENCREA - dDtBase,4)

//Montagem no NOSSO NUMERO
//snn  := alltrim(cCarteira)+bldocnufinal     // Convenio + Nosso Numero
snn  := strzero(Val(cAgencia),4) + alltrim(cCarteira) + bldocnufinal     // Convenio + Nosso Numero

//dvnn := Alltrim(u_Mod11Day(snn))  // Digito verificador no Nosso Numero
dvnn := Alltrim(u_MOD10DAY(snn))  // Digito verificador no Nosso Numero
NN   := snn + " - " + dvnn
                                     //121
//cCmpLv := strzero(Val(cAgencia),4) + alltrim(cCarteira) + cOperac + bldocnufinal + strzero(Val(cConta),7)+"0"
cCmpLv := strzero(Val(cAgencia),4) + alltrim(cCarteira) + cOperac + bldocnufinal + dvnn

//Codigo de Barras
//scb  := cBanB + "9" + cFatorVencto + blvalorfinal + strzero(Val(cAgencia),4)+ snn + strzero(Val(cConta),7)+"0"
scb  := cBanB + "9" + cFatorVencto + blvalorfinal + cCmpLv
//dvcb := mod11CB(scb) //digito verificador do codigo de barras
//dvcb := mod11CB(SubStr(scb,1,4)) //digito verificador do codigo de barras
dvcb := mod11CB(scb) //digito verificador do codigo de barras
CB   := SubStr(scb,1,4) + AllTrim(Str(dvcb)) + SubStr(scb,5,39)

//LINHA DIGITAVEL
//CAMPO 1
srn:= substr(CB,1,3)+substr(CB,4,1)+substr(CB,20,5)
dv := modulo10(srn)
//RN := SubStr(srn, 1, 5) + '.' + SubStr(srn,6,4)+AllTrim(Str(dv))+' '
RN := SubStr(srn, 1, 5) + '.' + SubStr(srn,6,4) + AllTrim(Str(dv)) + ' '

//CAMPO 2
srn:= substr(CB,25,10)
dv := modulo10(srn)
RN := RN + SubStr(srn,1,5) + '.' + SubStr(srn,6,5) + AllTrim(Str(dv)) + ' '

//CAMPO 3
//srn:=substr(CB,35,10)
srn:=substr(cCmpLv,16,10)
dv := modulo10(srn)
RN := RN + SubStr(srn,1,5) + '.' + SubStr(srn,6,5) + AllTrim(Str(dv)) + ' '

//CAMPO 4
//RN := RN + ' ' + substr(CB,5,1) + ' '
RN := RN + ' ' + AllTrim(Str(dvcb)) + ' '

//CAMPO 5
RN := RN + substr(CB,6,4)+substr(CB,10,10)

Return({ CB, RN, NN })


Static Function Ret_cBar033(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor,cConvenio)

LOCAL cValorFinal := strzero(nValor*100,10)
LOCAL nDvnn			:= 0
LOCAL nDvcb			:= 0
LOCAL nDv			:= 0
LOCAL cNN			:= ''
LOCAL cRN			:= ''
LOCAL cCB			:= ''
LOCAL cS			:= ''
LOCAL cFator        := strzero(SE1->E1_VENCREA - ctod("07/10/97"),4)
LOCAL cCart			:= "101"
Local cBanco        := "033"

//-----------------------------//
// Definicao do NOSSO NUMERO   //
// ----------------------------//

cS    := Alltrim(StrZero(Val(cNroDoc),12))
nDvnn := modulo11(cS,.T.) // digito verificador Nosso Num
cNN   := cS + AllTrim(Str(nDvnn))


//----------------------------------//
//	 Definicao do CODIGO DE BARRAS  //
//----------------------------------//

cS    := cBanco + "9" + cFator +  cValorFinal + '9' + SUBSTR(Trim(cConvenio),1,7) + cNN + "0" + cCart
nDvcb := modulo11(cS,.F.)
cCB   := SubStr(cS, 1, 4) + AllTrim(Str(nDvcb)) + SubStr(cS,5,39)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	  Campo 1		   Campo 2		   Campo 3			Campo 4
//	AAABC.DDDDE		FFFFF.FFFNNY	NNNNN.NNNNNZ	UUUUVVVVVVVVVV

// 	CAMPO 1:
//  AAA = Codigo do banco na Camara de Compensacao
//    B = Codigo da moeda, sempre 9 Nacional 8 Outras Moedas
//    C = Fixo 9
// DDDD = Codigo Cedente (4 primeiros digitos)
//    E = calculado pelo Modulo 10

cS    := cBanco + "99"  + SubStr(cConvenio,1,4)  //03399
nDv   := modulo10(cS)
cRN   := cS + "." + AllTrim(Str(nDv)) + " "

// 	CAMPO 2:
//    FFFF = Codigo do Dedente (4 ultimos digitos)
// NNNNNNN = 2 primeiros digitos do nosso numero
//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS    := SUBSTR(cConvenio,5,3) + substr(cNN,1,7)
nDv   := modulo10(cS)
cRN   := cRN + cS + "." + Alltrim(Str(nDv)) + " "

// 	CAMPO 3:
//	  N = Restante do Nosso Numero
//	  N = FIXO '0'
//	NNN = TIPO DE MODALIDADE CARTEIRA
//	  Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
cS    := SUBSTR(cNN,8,6) + "0" + cCart
nDv   := modulo10(cS)
cRN   := cRN + cS + "." + Alltrim(Str(nDv)) + " "

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
cRN   := cRN + AllTrim(Str(nDvcb)) + " "

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
cRN   := cRN + cFator + StrZero((nValor*100),10)


Return({cCB,cRN,cNN})


Static Function Ret_cBar637(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor,cConvenio)

LOCAL cValorFinal := strzero(nValor*100,10)
LOCAL nDvnn			:= 0
LOCAL nDvcb			:= 0
LOCAL nDv			:= 0
LOCAL cNN			:= ''
LOCAL cRN			:= ''
LOCAL cCB			:= ''
LOCAL cS			:= ''
LOCAL cFator        := strzero(SE1->E1_VENCREA - ctod("07/10/97"),4)
LOCAL cCart			:= "101"
Local cBanco        := "033"

//-----------------------------//
// Definicao do NOSSO NUMERO   //
// ----------------------------//

cS    := Alltrim(StrZero(Val(cNroDoc),12))
nDvnn := modulo11(cS,.T.) // digito verificador Nosso Num
cNN   := cS + AllTrim(Str(nDvnn))


//----------------------------------//
//	 Definicao do CODIGO DE BARRAS  //
//----------------------------------//

cS    := cBanco + "9" + cFator +  cValorFinal + '9' + SUBSTR(Trim(cConvenio),1,7) + cNN + "0" + cCart
nDvcb := modulo11(cS,.F.)
cCB   := SubStr(cS, 1, 4) + AllTrim(Str(nDvcb)) + SubStr(cS,5,39)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	  Campo 1		   Campo 2		   Campo 3			Campo 4
//	AAABC.DDDDE		FFFFF.FFFNNY	NNNNN.NNNNNZ	UUUUVVVVVVVVVV

// 	CAMPO 1:
//  AAA = Codigo do banco na Camara de Compensacao
//    B = Codigo da moeda, sempre 9 Nacional 8 Outras Moedas
//    C = Fixo 9
// DDDD = Codigo Cedente (4 primeiros digitos)
//    E = calculado pelo Modulo 10

cS    := cBanco + "99"  + SubStr(cConvenio,1,4)  //03399
nDv   := modulo10(cS)
cRN   := cS + "." + AllTrim(Str(nDv)) + " "

// 	CAMPO 2:
//    FFFF = Codigo do Dedente (4 ultimos digitos)
// NNNNNNN = 2 primeiros digitos do nosso numero
//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS    := SUBSTR(cConvenio,5,3) + substr(cNN,1,7)
nDv   := modulo10(cS)
cRN   := cRN + cS + "." + Alltrim(Str(nDv)) + " "

// 	CAMPO 3:
//	  N = Restante do Nosso Numero
//	  N = FIXO '0'
//	NNN = TIPO DE MODALIDADE CARTEIRA
//	  Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
cS    := SUBSTR(cNN,8,6) + "0" + cCart
nDv   := modulo10(cS)
cRN   := cRN + cS + "." + Alltrim(Str(nDv)) + " "

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
cRN   := cRN + AllTrim(Str(nDvcb)) + " "

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
cRN   := cRN + cFator + StrZero((nValor*100),10)


Return({cCB,cRN,cNN})

Static Function Ret_cB004(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor,cConvenio)

LOCAL bldocnufinal := AllTrim(cNroDoc)
LOCAL blvalorfinal := strzero(nValor*100,10)
LOCAL dvnn         := 0
LOCAL dvcb         := 0
LOCAL dv           := 0
LOCAL NN           := ''
LOCAL RN           := ''
LOCAL CB           := ''
LOCAL s            := ''
Local dDtBase     := ctod("07/10/1997")
Local cFatorVencto := ""
LOCAL cBanB		   := cBanco

//Calculo do Fator de Vencimento do Titulo
cFatorVencto := Str(SE1->E1_VENCREA - dDtBase,4)

//Montagem no NOSSO NUMERO
//snn  := alltrim(cCarteira)+bldocnufinal     // Convenio + Nosso Numero
snn  := RIGHT(bldocnufinal,7)     // Convenio + Nosso Numero

dvnn := Alltrim(u_Mod11BNB(snn))  // Digito verificador no Nosso Numero
NN   := snn+"-"+dvnn

//Codigo de Barras
scb  := cBanB 						+ ; // ok Banco                         000
"9" 						+ ; // ok Moeda                         0
cFatorVencto 				+ ; // Fator de Vencimento              0000
blvalorfinal 				+ ; // Valor do Título                  1500
strzero(Val(cAgencia),4) 	+ ; // Agencia                          0000
strzero(Val(cConta),7)		+ ; //                                  0000000
cDacCC                      + ; //                                  0
snn 						+ ; // Nosso Numero                     0000000
dvnn                        + ; // Digito Nosso Número              0
alltrim(cCarteira)          + ; // Carteira                         00
'000'

dvcb := mod11CB(scb) //digito verificador do codigo de barras
//      ok                ok
CB   := SubStr(scb,1,4) + AllTrim(Str(dvcb)) + SubStr(scb,5,39)

//LINHA DIGITAVEL
//CAMPO 1
srn:= substr(CB,1,3)+substr(CB,4,1)+substr(CB,20,5)
dv := modulo10(srn)
RN := SubStr(srn, 1, 5) + '.' + SubStr(srn,6,4)+AllTrim(Str(dv))+' '

//CAMPO 2
srn:= substr(CB,25,10)
dv := modulo10(srn)
RN := RN + SubStr(srn,1,5)+'.'+SubStr(srn,6,5)+AllTrim(Str(dv))+' '

//CAMPO 3
srn:=substr(CB,35,10)
dv := modulo10(srn)
RN := RN + SubStr(srn,1,5)+'.'+SubStr(srn,6,5)+AllTrim(Str(dv)) + ' '

//CAMPO 4
RN := RN + ' ' + substr(CB,5,1) + ' '

//CAMPO 5
RN := RN + substr(CB,6,4)+substr(CB,10,10)

//Return({cCB,cRN,cNN})
Return({CB,RN,NN})
//
Static Function Ret_cB104(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor,cConvenio)

LOCAL bldocnufinal := AllTrim(cNroDoc)
LOCAL blvalorfinal := strzero(nValor*100,10)
LOCAL dvnn         := 0
LOCAL dvcb         := 0
LOCAL dv           := 0
LOCAL NN           := ''
LOCAL RN           := ''
LOCAL CB           := ''
LOCAL s            := ''
Local dDtBase     := ctod("07/10/1997")
Local cFatorVencto := ""
LOCAL cBanB		   := cBanco

//Calculo do Fator de Vencimento do Titulo
cFatorVencto := Str(SE1->E1_VENCREA - dDtBase,4)

//Montagem no NOSSO NUMERO
snn  := '1'+'4'+RIGHT(bldocnufinal,17)     // Nosso Numero

dvnn := Alltrim(Mod11CEF(snn))  // Digito verificador no Nosso Numero

NN   := snn+"-"+dvnn

//DigConv := RIGHT(Strzero(VAL(cConvenio),12),6)
//Campo LIvre
CmpAuxLv := cConvenio                           + ;    		// Convênio - Beneficiario          000000
		    CalDigCV(cConvenio)  				+ ; 		// Dígito Convênio - Beneficiario   0
		    SUBSTR(snn,3,3)						+ ;
		    LEFT(snn,1)							+ ;
		    SUBSTR(snn,6,3)						+ ;
		    SUBSTR(snn,2,1)						+ ;
		    SUBSTR(snn,9,9)                    
		    
// Cálculo do Dígito Verificador do Campo Livre
CmpLivre := CmpAuxLv + CalDigCL(CmpAuxLv)

CmpAuxCB := cBanB 								+ ;        	// Banco                         000
		    "9" 								+ ; 		// Moeda                         0
		    cFatorVencto 						+ ; 		// Fator de Vencimento              0000
		    blvalorfinal 						+ ; 		// Valor do Título                  1500
            CmpLivre                                        // Campo Livre com Digito Verificador

//Cálculo do Dígito Verificador Geral do Código de Barras
DiGerCB := CalDigDG(CmpAuxCB)                            

//Codigo de Barras
scb  := cBanB 								+ ;        	// Banco                         000
		"9" 								+ ; 		// Moeda                         0
		DiGerCB                             + ;         // Dígito Verificador Geral do Código de Barras
		cFatorVencto 						+ ; 		// Fator de Vencimento              0000
		blvalorfinal 						+ ; 		// Valor do Título                  1500
        CmpLivre                                        // Campo Livre com Digito Verificador
//		cConvenio                           + ;    		// Convênio - Beneficiario          000000
//		CalDigCV(cConvenio)  				+ ; 		// Dígito Convênio - Beneficiario   0
//		SUBSTR(snn,3,3)						+ ;
//		LEFT(snn,1)							+ ;
//		SUBSTR(snn,6,3)						+ ;
//		SUBSTR(snn,2,1)						+ ;
//		SUBSTR(snn,9,9)                     + ; 
//        CalDigCL(CmpLivre)                         // íto Verificador do Campo Livre 

dcmpl   := LEFT(CmpLivre,1)
 
//Mod11CEF(CmpLivre) // Digito Verificador do Campo Livre

//If 	val(dcmpl) > 10     
//	scb := scb + '0'
//Else
//	scb := scb + StrZero(val(dcmpl),1)
//EndIf

dvcb := DiGerCB //digito verificador do codigo de barras
//      ok                ok
CB  := SubStr(scb,1,4) + AllTrim(dvcb) + SubStr(scb,6,39)

//LINHA DIGITAVEL
//CAMPO 1
srn := substr(scb,1,4)+substr(CmpLivre,1,5)
dv  := Mod10CEF(srn)
RN  := SubStr(srn, 1, 5) + '.' + SubStr(srn,6,4)+AllTrim(Str(dv))+' '

//CAMPO 2
srn := substr(CmpLivre, 6, 10)
dv  := Mod10CEF(srn)
RN  := RN + SubStr(srn,1,5)+'.'+SubStr(srn,6,5)+AllTrim(Str(dv))+' '

//CAMPO 3
srn := substr(CmpLivre, 16, 10)
dv  := Mod10CEF(srn)
RN  := RN + SubStr(srn,1,5)+'.'+SubStr(srn,6,5)+AllTrim(Str(dv)) + ' '

//CAMPO 4
RN := RN + dvcb + ' '

//CAMPO 5
RN := RN + substr(CB,6,4)+substr(CB,10,10)

//Return({cCB,cRN,cNN})
Return({CB, RN, NN})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALCDIG  ºAutor  ³Andre Pessoa         º Data ³  01/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CalcDig(_cNossoNum)

Local xVNUM := 0, sumdig := 0

cbase  := _cNossoNum
lbase  := LEN(cBase)
base   := 9
sumdig := 0
xVNUM  := 0
iDig   := lBase
While iDig >= 1
	If base == 1
		base := 9
	EndIf
	xVNUM   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+xVNUM
	base   := base - 1
	iDig   := iDig-1
EndDo
xVNUM := mod(Sumdig,11)
If xVNUM == 10
	xVNUM := "X"
Else
	xVNUM := str(xVNUM,1,0)
EndIf

Return(xVNUM)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³VALIDPERG ³ Autor ³ Andre Pessoa          ³ Data ³ 01/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ValidPerg()
_sAlias := Alias()
/*
DBSelectArea("SX1")
DBSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
Aadd(aRegs,{cPerg,"01","Do Prefixo           ?","","","mv_ch1","C", 3,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"02","Ate o Prefixo        ?","","","mv_ch2","C", 3,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"03","Do Titulo            ?","","","mv_ch3","C", 9,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Ate o Titulo         ?","","","mv_ch4","C", 9,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"05","Da Parcela           ?","","","mv_ch5","C", 1,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"06","Ate a Parcela        ?","","","mv_ch6","C", 1,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"07","Bordero              ?","","","mv_ch7","C", 6,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})
//AADD(aRegs,{cPerg,"08","Ate o Bordero        ?","","","mv_ch8","C", 6,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If ! DBSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to Max(39, Len(aRegs[i])) //fCount()
			FieldPut(j,aRegs[i,j])
		Next
		MsUnlock()
	Endif
Next

DBSkip()

do while x1_grupo == cPerg
	RecLock("SX1", .F.)
	DBDelete()
	DBSkip()
Enddo
*/
DBSelectArea(_sAlias)

Return

Static Function Modulo11(cData,lNossoNum_DV)
Local L := Len(cdata)
Local D := 0
Local P := 1
While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 9
		P := 1
	End
	L := L - 1
End
If lNossoNum_DV
	D := mod(D,11)
	If D == 10
		D := 1
	ElseIf D == 0 .OR. D == 1
		D := 0
	Else
		D := 11 - D
	EndIf
Else
	D := D * 10
	D := mod(D,11)
	If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
		D := 1
	EndIf
EndIf
Return(D)

Static Function Mod11CEF(cData)
Local L := Len(cdata)
Local D := 0
Local P := 2
While L > 0
	D := D + (Val(SubStr(cData, L, 1)) * P)
	P := P + 1
	If P > 9
		P := 2
	End
	L := L - 1
End
D := mod(D, 11)
D := 11 - D
If D > 9
  D := 0
EndIf
Return(Alltrim(Str(D)))                                   

//=======================================================-
// Calculo do Dígito do Nosso Número - Banco Daycoval
//========================================================
User Function DIGNNDAY()
Return U_MOD10DAY(StrZero(Val(SEE->EE_AGENCIA),4) + StrZero(Val(SEE->EE_CODCART),3) + StrZero(Val(SE1->E1_NUMBCO),10))

User Function MOD10DAY(cNumCalc)
Local cDigCalc    := ''
Local nPeso       := 2
Local nCont       := Len(AllTrim(cNumCalc))
Local nSoma       := 0
Local nResto      := 0

While nCont > 0 
  nMulti := Val((SubStr(cNumCalc, nCont, 1))) * nPeso                         
  
  If nMulti > 9
    nSoma  := nSoma + (Val(SubStr(Alltrim(Str(nMulti)),1,1)) + Val(SubStr(Alltrim(Str(nMulti)),2,1)))
  Else
    nSoma  := nSoma + nMulti
  EndIf

  If nPeso = 2    
    nPeso := 1
  Else
    nPeso := 2
  EndIf
    
  nCont  := nCont - 1
End  
nResto := Mod(nSoma, 10)     
If nResto = 0
   cDigCalc := '0'
Else
   cDigCalc := AllTrim(StrZero((10 - nResto),1))
EndIf
//Len(cNumCalc)
Return cDigCalc 

//User Function Ret_cBar246(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor,cConvenio,_cOpera)
User Function RBar246(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor,cConvenio,_cOpera)

LOCAL cValorFinal := strzero(nValor*100,10)
LOCAL nDvnn			:= 0
LOCAL nDvcb			:= 0
LOCAL nDv			:= 0
LOCAL cNN			:= ''
LOCAL cRN			:= ''
LOCAL cCB			:= ''
LOCAL cS			:= ''
LOCAL cFator        := strzero(SE1->E1_VENCREA - ctod("07/10/97"),4)
LOCAL cCart			:= "110"
Local cBanco        := "246"


//-----------------------------//
// Definicao do NOSSO NUMERO   //
// ----------------------------//

cS    := Alltrim(StrZero(Val(cNroDoc),10))
//nDvnn := modulo11(cS,.T.) // digito verificador Nosso Num
//nDvnn := MOD10ABC(cS,.T.) // digito verificador Nosso Num
nDvnn := MOD10ABC(cAgencia+cCart+cS,.T.) // digito verificador Nosso Num
cNN   := cS + AllTrim(Str(nDvnn))

//_________________________________//
//           Campo Livre           // 
//_________________________________//
cCL := substring(cAgencia,1,4) + cCarteira + _cOpera + cNN


//----------------------------------//
//	 Definicao do CODIGO DE BARRAS  //
//----------------------------------//

cS    := cBanco + "9" + cFator +  cValorFinal + cCL    //Considera para o calculo o codigo sem o digito (43Posicoes)
nDvcb := modulo11(cS,.F.)
cCB   := SubStr(cS, 1, 4) + AllTrim(Str(nDvcb)) + SubStr(cS,5,39)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	  Campo 1		   Campo 2		   Campo 3			Campo 4     CAMPO 5
//	AAABC.CCCD		FFFFF.FFFFFY	NNNNN.NNNNNZ	       K        UUUUVVVVVVVVVV

// 	CAMPO 1:
//  AAA = Codigo do banco na Camara de Compensacao
//    B = Codigo da moeda, sempre 9 Nacional 8 Outras Moedas
//    C = 5 PRIMEIRAS POSICOES DO CAMPO LIVRE
//    D = calculado pelo Modulo 10


cS    := cBanco + "9"  + SubStr(cCL,1,5)  
nDv   := modulo10(cS)
cRN   := substring(cS,1,5) +  "." + substring(cS,6,4) + AllTrim(Str(nDv)) + " "

// 	CAMPO 2:
//    FFFFFFFFFF = 6 A 15POSIÇÃO DO CAMPO LIVRE.
//	     Y = Calculado pelo modulo 10

cS    := SubStr(cCL,6,10)  
nDv   := modulo10(cS)
cRN   := cRN + substring(cS,1,5) + "." + substring(cS,6,5) + Alltrim(Str(nDv)) + " "

// 	CAMPO 3:
//	  NNNNN.NNNNN = 16 A 25POSIÇÃO DO CAMPO LIVRE.
//	  Z = Calculado pelo modulo 10

cS    := SubStr(cCL,16,10) 
nDv   := modulo10(cS)
cRN   := cRN + substring(cS,1,5) + "." + substring(cS,6,5) + Alltrim(Str(nDv)) + " "

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
cRN   := cRN + AllTrim(Str(nDvcb)) + " "

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
cRN   := cRN + cFator + cValorFinal


Return({cCB,cRN,cNN})

USER FUNCTION Mod11SOF(cData)
Local cData:=alltrim(cData)
Local L := Len(cdata)
Local D := 0
Local P := 1
Local lNossoNum_DV:=.t.
While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 9
		P := 1
	End
	L := L - 1
End
If lNossoNum_DV
	D := mod(D,11)
	If D == 10
		D := 1
	ElseIf D == 0 .OR. D == 1
		D := 0
	Else
		D := 11 - D
	EndIf
Else
	D := D * 10
	D := mod(D,11)
	If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
		D := 1
	EndIf
EndIf
Return(alltrim(cData)+alltrim(str(D)))
