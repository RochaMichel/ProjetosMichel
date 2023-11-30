#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "DBTREE.CH"


Static cHist := Space(40)
Static cFil_x_Ori := Space(4)

User Function MT100GE2()
Local aVar  := ParamIxb  //ExecBlock("MT100GE2",.F.,.F.,{aColsSE2[nX],nOpcA,aHeadSE2})
Local aArea

SE2->E2_HIST := cHist
SE2->E2_X_FILOR := cFil_x_Ori    // Para atender regras do BI - 02/06/2021 - Jorge Cintra

/*
CONTROLE DE EXCECAO PARA LIBERAÇÃO DE TITULOS CP
*/
If AllTrim(SE2->E2_NATUREZ) $ GetMV("MV_XNATUR")  //PARAMETRO RESPONSAVEL POR CONTROLE LIB. AUTOMATICA
	dbSelectArea("SE2")
	RecLock("SE2",.F.)
	SE2->E2_DATALIB := dDataBase
	SE2->E2_USUALIB := AllTrim(CUSERNAME)
	SE2->E2_STATLIB := '03'
	SE2->E2_XDIGIT  := SF1->F1_DTDIGIT
	MsUnLock()
EndIf

Return

User Function MT100TOK()
Local _aArea      := getArea()
Local _lRet       := .T.
Local _cCCusto    := Space(0)
Local _cNatureza  := Space(0)
Local _nValTot    := 0
Local _cTipo      := Space(0)
Local _lKeyOnOff  := U_fnkeyOrc()
Local _lOrc       := .F.
Local _lGrvAporte := .F.
Local _nVlrExc    := 0
Local _nSaldo     := 0
Local _nVlrExc    := 0
Local _nVlrApo    := 0
Local _cNatuCtrl  := ''
Local cNatNF      := MaFisRet(,"NF_NATUREZA")
Local i           := 0
Private cMemo     := space(01)
Private _cAporte  := space(06)
Private _cFilCC   := U_fnFilCC()//Localizar a filial na tabela ZZ2 para considerar como filial do Orçamento

If !IsInCallStack("MATA103")
	Return .T.
Endif

cNatuCtrl  := IIF(Empty(cNatNF),Posicione("SA2",1,xFilial("SA2")+CA100FOR+CLOJA,"A2_NATUREZ"), cNatNF)
_cNatuCtrl := Posicione("SED",1,xFilial("SED")+cNatuCtrl,"ED_X_BLORC")  

If !l103Auto
	If SF1->F1_TIPO <> "D"  //Devolução
		_lRet := FornValid()
		If _lKeyOnOff  .AND. _cNatuCtrl == 'S'
			If (ALLTRIM(CESPECIE) = 'NFS'  ) .OR. ;
				(ALLTRIM(CESPECIE) = 'NFSC' ) .OR. ;
				(ALLTRIM(CESPECIE) = 'NFCEE')
				fnNumAporte(@_cAporte)
				_lOrc       := .T.
			Endif
		Endif
	Endif
Endif

If _lRet .And. _lKeyOnOff  .And. INCLUI .And. (_cNatuCtrl<>"N") .And. _lOrc
	If (ALLTRIM(CESPECIE) = 'NFS'  ) .OR. ;
		(ALLTRIM(CESPECIE) = 'NFSC' ) .OR. ;
		(ALLTRIM(CESPECIE) = 'NFCEE')
		_cNatureza  := IIF(Empty(cNatNF), Posicione("SA2",1,xFilial("SA2")+CA100FOR+CLOJA,"A2_NATUREZ"), cNatNF)
		For i:=1 To Len(aCOls)
			If !aCols[i,Len(aHeader)+1] //conto apenas as linhas nao removidas
				If !Empty(aCols[i][GDFieldPos("D1_CC")]).And. Empty(_cCCusto)
					_cCCusto := aCols[i][GDFieldPos("D1_CC")]
				Endif
				_nValTot+= aCols[i][GDFieldPos("D1_TOTAL")]
				_nVlrExc+=_nValTot
				//_cTipo  := aCols[i][GDFieldPos("D1_TIPO")]
			Endif
		Next
		If _lOrc .AND. _cNatuCtrl<>"N"
			
			dbSelectArea("ZZX")
			dbSetOrder(2)  //ZZX_FILIAL+ZZX_NATURE+ZZX_ANO+ZZX_MES+ZZX_CCUSTO
			
			If dbSeek(_cFilCC+_cNatureza+Left(DTOS(DDEMISSAO),4)+Substring(DTOS(DDEMISSAO),5,2)+_cCCusto)
				
				//tratamento de aportes se foi informado um codigo de aporte para este titulo no campo F1_XNRSCS
				If !empty(_cAporte) //Foi informado o numero de uma soliicitação de aporte  //M->F1_XNRSCS
					_cFilDoc:=xFilial("SF1")
					_nVlrApo:=u_fnCVAporte(_cFilDoc,"NS",_cAporte,_cCCusto,3) //Carregar o valor do aporte M->E2_X_FILOR
					If _nVlrApo = 9 // Tentou utilizar outro centro de custo para o aporte
						MsgAlert("Aporte nao pertence a este centro de custo " , "Rever centro de custo digitado")
						Return(.F.)
					Endif
				Endif
				
				//aqui devo jogar no saldo o valor a diferença que esta empenhada ou valor total apenas em caso e aporte
				// (_nValTot - _nVlrApo) = (Valor que devo adicinar ao saldo )
				If !empty(_cAporte)
					_nSaldo  :=  ZZX->ZZX_SALDO + (_nValTot - _nVlrApo ) //Basicamente devolvendo o empenho ao saldo
				Else
					_nSaldo  :=  ZZX->ZZX_SALDO
				Endif
				
				If _nSaldo  <  0
					_nSaldo  := 0
				Endif
				
				If ((_nSaldo+_nVlrApo) < _nValTot)
					_nVlrExc := (_nValTot - _nSaldo)
					//_nVlrExc:=(M->E2_VALOR - _nSaldo) //se o saldo nao for menor ou igual a zero mas for menor que o valor titulo o valor excedente será o valor do titulo menos o saldo
					If MSGYESNO( "Nota nao pode ser gravada por controle de orçamento - Deseja enviar e-mail solicitando aporte ?", "Alerta de orçamento" )
						fnDigMemo()
						_lGrvAporte:=.T.
						_lOrc      := .F.
					Endif
					_lRet   := .F.   //Titulo nao será gravado por falta de orçamento
				Else
					RecLock("ZZX",.F.)
					
					If !empty(_cAporte)
						If ZZX->ZZX_EMPENH > 0
							If ZZX->ZZX_EMPENH >= (_nValTot - _nVlrApo )
								ZZX->ZZX_EMPENH := (ZZX->ZZX_EMPENH - (_nValTot - _nVlrApo ) )
							Else
								ZZX->ZZX_EMPENH := 0 // Zerar o valor do saldo do empnho caso o empenho ficar menor que zero
							Endif
						Else
							ZZX->ZZX_EMPENH := 0// Zerar o valor do saldo do empnho caso o empenho esteja menor ou igual a  zero
						Endif
					Endif
					
					ZZX->ZZX_UTILIZ +=_nValTot
					ZZX->ZZX_SALDO  := ZZX->ZZX_ORCADO - ( ZZX->ZZX_UTILIZ + ZZX->ZZX_EMPENH)
					If ZZX->ZZX_SALDO < 0
						ZZX->ZZX_SALDO := 0
					Endif
					
					MsUnLock("ZZX")
					
					dbSelectArea("ZZQ")
					dbSetorder(1)  //ZZQ_FILIAL+ZZQ_NATURE+ZZQ_ANO+ZZQ_MES
					
					If dbSeek(_cFilCC+ZZX->ZZX_NATURE+ZZX->ZZX_ANO+ZZX->ZZX_MES)
						Reclock("ZZQ",.F.)   //(2)
						
						If !empty(_cAporte)
							If ZZQ->ZZQ_EMPENH > 0
								If ZZQ->ZZQ_EMPENH >= (_nValTot - _nVlrApo )
									ZZQ->ZZQ_EMPENH := (ZZQ->ZZQ_EMPENH - (_nValTot - _nVlrApo ) )
								Else
									ZZQ->ZZQ_EMPENH := 0 // Zerar o valor do saldo do empnho caso o empenho ficar menor que zero
								Endif
							Else
								ZZQ->ZZQ_EMPENH := 0// Zerar o valor do saldo do empnho caso o empenho esteja menor ou igual a  zero
							Endif
						Endif
						
						ZZQ->ZZQ_UTILIZ +=  _nValTot
						ZZQ->ZZQ_SALDO  := ZZQ->ZZQ_ORCADO - ( ZZQ->ZZQ_UTILIZ + ZZQ->ZZQ_EMPENH)
						If ZZQ->ZZQ_SALDO < 0
							ZZQ->ZZQ_SALDO  := 0
						Endif
						ZZQ->(MsUnlock())
					Endif
				Endif
				//Endif
			Else
				If MSGYESNO( "Nota nao pode ser gravada por controle de orçamento - Deseja enviar e-mail solicitando aporte ?", "Alerta de orçamento" )
					fnDigMemo()
					_lGrvAporte:=.T.
					_lRet   := .F.
				Endif
				_lRet   := .F.
			Endif
			
			If  _lGrvAporte  //ira gravar solicitação de aporte
				DbSelectArea("ZZP")
				dbSetOrder(3)
				_cQrCod1:= fnQrdCodCP()
				_cQrCod2:= _cQrCod1 //Strzero((Val(_cQrCod1) * 365 ),6)
				
				Reclock("ZZP",.T.)
				//Incluir Solicitação de aporte
				ZZP_FILIAL := xFilial("SF1")
				ZZP_SN     := "NAO"
				ZZP_TIPO   := "NS"
				ZZP_NRDOC  := CNFISCAL
				ZZP_DTDOC  := dDataBase
				ZZP_USUARI := Substr(CUSUARIO,7,15)
				ZZP_CCUSTO := _cCCusto
				ZZP_NATURE := _cNatureza
				ZZP_VALOR  := _nVlrExc // TRATAR ESSE VALOR
				ZZP_XMAORC := Substring(DTOS(DDEMISSAO),5,2)+Left(DTOS(DDEMISSAO),4)
				ZZP_STATUS :="AA"
				ZZP_VALDOC := _nValTot
				ZZP_SOLICI := u_FnEmailNat(_cNatureza,"N")
				ZZP_QRCOD1 := _cQrCod1
				ZZP_QRCOD2 := _cQrCod2
				ZZP_OBS    := cMemo
				ZZP_GESNAT := U_FnEmailNat(_cNatureza,"N")
				ZZP->(MsUnlock())
				
				RestArea(_aArea)
				Processa({||fRnMail(_nSaldo,_nVlrExc,_cQrCod1,_cNatureza,CNFISCAL,_cCCusto)},"Enviando Email para setor responsavel. Aguarde ...")
				Aviso("PROCESSO GRAVADO COM SUCESSO!"," Envio de Emails realizados "+chr(13)+ "Para os envolvidos no processo",{'Ok'})
				
				For i:=1 To Len(aCOls)
					If !aCols[i,Len(aHeader)+1] //conto apenas as linhas nao removidas
						aCols[i][GDFieldPos("D1_XMAORCD")]:= Substring(DTOS(DDEMISSAO),5,2)+Left(DTOS(DDEMISSAO),4) //Mes e Ano
						aCols[i][GDFieldPos("D1_XNRSCS")]:= _cAporte
					Endif
				Next
				
			Endif
		Endif
	Endif
Endif

If !_lRet
	Aviso("ESTA NOTA NAO PODE SER GRAVADA!"," Limite de Orçamento ",{'Ok'})
ElseIf _nVlrApo > 0 //Utilizou Aporte
	//Colocar Utilizado no aporte   ZZP	 se houver
	dbSelectArea("ZZP")
	dbSetOrder(1)
	If dbSeek(xFilial("SF1")+"NS"+CNFISCAL)
		Reclock("ZZP",.F.)
		ZZP->ZZP_STATUS := "UT"
		ZZP->(MsUnlock())
	Endif
	For i:=1 To Len(aCOls)
		If !aCols[i,Len(aHeader)+1] //conto apenas as linhas nao removidas
			aCols[i][GDFieldPos("D1_XMAORCD")]:= Substring(DTOS(DDEMISSAO),5,2)+Left(DTOS(DDEMISSAO),4) //Mes e Ano
			aCols[i][GDFieldPos("D1_XNRSCS")]:= _cAporte
		Endif
	Next
ElseIf _lKeyOnOff .And. ( ALLTRIM(CESPECIE) = 'NFS'   .OR. ALLTRIM(CESPECIE) = 'NFSC' .OR. ALLTRIM(CESPECIE) = 'NFCEE' )	.And. _lOrc
	For i:=1 To Len(aCOls)
		If !aCols[i,Len(aHeader)+1] //conto apenas as linhas nao removidas
			aCols[i][GDFieldPos("D1_XMAORCD")]:= Substring(DTOS(DDEMISSAO),5,2)+Left(DTOS(DDEMISSAO),4) //Mes e Ano
			aCols[i][GDFieldPos("D1_XNRSCS")]:= _cAporte
		Endif
	Next
Endif

RestArea(_aArea)
Return _lRet

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------+----------+-------+-----------------------+------+----------+¦¦
¦¦¦ Programa ¦ FornValid¦ Autor ¦ Jorge Cintra Filho    ¦ Data ¦ 29/08/19 ¦¦¦
¦¦+----------+----------+-------+-----------------------+------+----------+¦¦
¦¦¦Descrição ¦ Obriga usuário colocar uma motivo para gravar no hist SE2  ¦¦¦
¦¦+----------+------------------------------------------------------------+¦¦
¦¦¦ Uso      ¦ PHARMAPELE                                                 ¦¦¦
¦¦+----------+------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function FornValid()

If cFilAnt >= '0201' .and. cFilAnt <= '0301'
	cFil_x_Ori := '0202'
Else
	cFil_x_Ori := cFilAnt
Endif

cHist := Space(40)

DEFINE MSDIALOG oDlg TITLE "Histórico de Documento de Entrada" FROM 5,0 To 18,55 OF oMainWnd  //"Border"
@ 16, 26   Say "REFERENTE:"
@ 1, 9.5 MSGET cHist Picture "@!"  SIZE 95,10
@ 25, 26   Say "FILIAL PAG:"
@ 2, 9.5 MSGET cFil_x_Ori Picture "@!"  SIZE 20,10 F3 'SM0'

DEFINE SBUTTON FROM 075,060 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 075,090 TYPE 2 ACTION (nOpca := 0,oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

if nOpca = 1
	If Empty(cFil_x_Ori)
		cFil_x_Ori := '0202'
	Endif
	if Empty(cHist)
		Alert("O campo REFERENTE deve ser preenchido!")
		Return .F.
	else
		Return .T.
	Endif
else
	Return .F.
endif

Return .T.

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------+----------+-------+-----------------------+------+----------+¦¦
¦¦¦ Programa ¦ fnNumAporte¦ Autor ¦ Josue Izidio        ¦ Data ¦ 29/08/19 ¦¦¦
¦¦+----------+----------+-------+-----------------------+------+----------+¦¦
¦¦¦Descrição ¦ Numero do aporte                                           ¦¦¦
¦¦+----------+------------------------------------------------------------+¦¦
¦¦¦ Uso      ¦ PHARMAPELE                                                 ¦¦¦
¦¦+----------+------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function fnNumAporte(_cAporte)
If MSGYESNO( "Possui um numero de aporte para informar ?", "Informar Aporte" )
	DEFINE MSDIALOG oDlg TITLE "Numero de aporte" FROM 5,0 To 18,55 OF oMainWnd  //"Border"
	@ 2.0, 2   Say "NUMERO:"
	@ 2.0, 9.5 MSGET _cAporte Picture "@!"  SIZE 60,10
	
	
	DEFINE SBUTTON FROM 055,060 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 055,100 TYPE 2 ACTION (nOpca := 0,oDlg:End()) ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
Endif

Return .T.

User Function A100DEL()
Local lExecuta := .T.
Local _cQryExc := " "
Local _cNfExc  := SF1->F1_DOC
Local _cFilExc := SF1->F1_FILIAL
Local _dEmisNf := SF1->F1_EMISSAO
Local _Status := 0

// Validações do usuário para exclusão da NF
_cQryExc :="SELECT * FROM "+RetSqlName('SE2')
//_cQryExc :=" UPDATE SE2010 SET  D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_"
_cQryExc +=" WHERE D_E_L_E_T_ = ' '"
_cQryExc +=" AND E2_NUM = '"+_cNfExc+"'"
_cQryExc +=" AND E2_PREFIXO = '"+SF1->F1_SERIE +"'"
_cQryExc +=" AND E2_EMISSAO ='"+DTOS(_dEmisNf)+"'"
_cQryExc +=" AND E2_SALDO < E2_VALOR"
_cQryExc +=" AND E2_BAIXA <> '        '"
_cQryExc +=" AND E2_FILIAL = '"+_cFilExc+"'"
_cQryExc +=" AND E2_FORNECE = '"+SF1->F1_FORNECE +"'"
_cQryExc +=" AND E2_LOJA    = '"+SF1->F1_LOJA +"'"
_cQryExc := ChangeQuery(_cQryExc)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQryExc),"F1TRB",.F.,.T.)
DBSELECTAREA("F1TRB")
dbGoTop()

IF !Eof()
	DBCLOSEAREA("F1TRB")
	lExecuta := .F.
	MsgInfo ("Esta nota contem titulos baixados, cancele as baixas antes de exclui-la", "PE_A100DEL")
	//conout("MT103FIM NAO FOI POSSIVEL EXCLUIR A NOTA, FILIAL "+_cFilExc+" NF "+_cNfExc+" "+SF1->F1_SERIE+" EXISTEM TITULOS BAIXADOS")
	_Status := -1
ELSE
	DBCLOSEAREA("F1TRB")
	_cQryExc :="UPDATE "+RetSqlName('SE2') +" SET  D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_"
	_cQryExc +=" WHERE D_E_L_E_T_ = ' '"
	_cQryExc +=" AND E2_NUM = '"+_cNfExc+"'"
	_cQryExc +=" AND E2_EMISSAO ='"+DTOS(_dEmisNf)+"'"
	_cQryExc +=" AND E2_SALDO = E2_VALOR"
	_cQryExc +=" AND E2_TIPO = 'ISS'"
	_cQryExc +=" AND E2_FILIAL = '"+_cFilExc+"'"
	_Status := TCSqlExec(_cQryExc)
	lExecuta := .T.
	Conout(_cQryExc)
	conout("A100DEL EXCLUINDO TITULOS DE ISS DA NOTA, FILIAL "+_cFilExc+" NF "+_cNfExc+" "+SF1->F1_SERIE)
ENDIF
If _Status < 0
	conout("A100DEL NAO FOI POSSIVEL EXCLUIR O TITULO DA NOTA, FILIAL "+_cFilExc+" NF "+_cNfExc+" "+SF1->F1_SERIE)
Endif

return(lExecuta)

/*/{Protheus.doc} MT103FIM
//TODO Descrição auto-gerada.
@author Joeldson P Sousa
@since 22/08/2019
@version 1.0
@return Null, Retorno Nulo
@description Ponto de entrada no final da criação do documento de entrada
@type function
/*/

User Function MT103FIM()

Local nBotao    := PARAMIXB[1]
Local nConfirma := PARAMIXB[2]
Local _aAreaAtu := GetArea()
Local _aAreaSL1 := GetArea("SL1")
Local _aAreaSD1 := SD1->(GetArea())
Local cIPFCerta := SUPERGETMV("MV_XIPFC", .T., "10.10.1.218:2780")  //ip 218 = base de teste
Local lIntegra  := GetMv("PH_INTFCNF")
Local cFornFC   := GetMv("PH_FORFCNF")
Local aDados 	:= {}
DbSelectArea("SL1")
SL1->(DbSetOrder(2))

If !l103Auto
	If SF1->F1_TIPO == "D"  //Devolução
		
		If SL1->(DbSeek(xFilial("SL1") + SD1->D1_SERIORI + SD1->D1_NFORI))
			
			//Alert("ORCAMENTO - " + SL1->L1_NUM)
			//Alert("http://" + cIPFCerta + "/datasnap/rest/TSM/Orcamento/" + SL1->L1_NUM)
			
			aHeadOut := {}
			oRest := FWRest():New("http://" + cIPFCerta + "/datasnap/rest/TSM/Orcamento/" + SL1->L1_NUM)
			oRest:SetPath("")
			//oRest:SetPostParams(cUniJason)
			
			If oRest:Delete(aHeadOut)
				cRet := oRest:GetResult()
			Else
				cRet := oRest:GetLastError()
			Endif
			
			// 	conOut(cRetv+" PE_MATA103")
			
		EndIf
	ElseIf lIntegra
		If SF1->F1_TIPO = "N" .AND. nBotao == 3 .AND. nConfirma > 0 .AND. SF1->F1_FILIAL >= '0201' .AND. SF1->F1_FILIAL <= '0299' .AND.;
			!SF1->F1_FORNECE $ cFornFC
			//29/10/2020 - JORGE CINTRA - INTEGRAÇÃO COM FORMULA CERTA.(GERAÇÃO DA NF DENTRO DO BANCO DO FC).
			U_ImpPgto()
		Endif
	Endif 
EndIf

If nBotao == 3 .AND. nConfirma = 1 //Se é inclusão e foi clicado em Confirmar
                DbSelectArea('SB1') 
		While Alltrim(SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA);
				==;
				Alltrim(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)	
            //Caso seja NF de serviço TES 401 e tenha OP
            If SD1->D1_TES == '401' .AND. !Empty(SD1->D1_OP) .AND. cFilAnt == SuperGetMv("MV_XAUTOOP", .F., "")
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial('SB1')+Posicione('SC2',1,FWxFilial('SC2')+SD1->D1_OP,'C2_PRODUTO')))
			    lMsErroAuto := .F.
			    aDados := {;
			    	    {"D3_TM"        , "003"         												    , NIL   },;
			    	    {"D3_QUANT"     , SD1->D1_QUANT 												    , NIL   },;
			    	    {"D3_OP"        , SD1->D1_OP							    					    , NIL   },;
			    	    {"D3_EMISSAO"   , dDataBase     												    , NIL   },;
			    	    {"D3_LOCAL"     , SB1->B1_LOCPAD     												    , NIL   },;
			    	    {"D3_DTVALID"   , SD1->D1_DTVALID     												, NIL   },;
			    	    {"D3_LOTECTL"   , SD1->D1_LOTECTL     												, NIL   },;
			    	    {"D3_COD"       , Posicione('SC2',1,FWxFilial('SC2')+SD1->D1_OP,'C2_PRODUTO')   , NIL   }}
			    MSExecAuto({|x, y| mata250(x, y)},aDados, 3 )
			    If lMsErroAuto
			    	Mostraerro()
			    Else
			    	FWAlertSuccess("Apontamento de produção automático realizado", "Concluído")
			    Endif
            Endif
            SD1->(DbSkip())
		End
	EndIf

RestArea(_aAreaSL1)
RestArea(_aAreaSD1)
RestArea(_aAreaAtu)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fnDigMemoºAutor  ³Josue Izidio         º Data ³  09/24/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Digitar  campo Memo                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fnDigMemo()
Local oDlgMemo
Local _nOpc := 0
cMemo := CRIAVAR("ZZP_OBS")

DEFINE MSDIALOG oDlgMemo FROM 0,0 TO 240,400 PIXEL TITLE "Incluir justificativa para aporte financeiro"

oMemo:= tMultiget():New(10,10,{|u|if(Pcount()>0,cMemo:=u,cMemo)};
,oDlgMemo,180,80,,.T.,,,,.T.)

@ 100,060 BUTTON oBtn PROMPT "&Sair"   OF oDlgMemo PIXEL ACTION (oDlgMemo:End())
@ 100,120 BUTTON oBtn PROMPT "&Gravar" OF oDlgMemo PIXEL ACTION (_nOpc:=1,oDlgMemo:End())

ACTIVATE MSDIALOG oDlgMemo CENTERED


If  _nOpc = 0
	cMemo:= SPACE(1)
Endif

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fnQrdCodCP   º Autor ³ Josue Izidio     º Data ³  05/09/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gerar Qrdcod                                               º±±
±±º          ³                                                            º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fnQrdCodCP()
Local nSeed := 5
Do While  .T.
	nSeed := Aleatorio(100,nSeed)
	If !dbSeek(xFilial("ZZP")+StrZero(nSeed,6))
		Exit
	Endif
Enddo
Return(StrZero(nSeed,6))


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fRnMailP   º Autor ³ Josue Izidio     º Data ³  07/02/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Enviar email de aporte                                     º±±
±±º          ³                                                            º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fRnMail(_nSaldo,_nVlrExc,_cQrCod1,_cNatureza,_cNumDoc,_cCCusto)
Local aAnexo	    := ""
Local cServer    	:= GetMv( "MV_RELSERV" )//Nome do Servidor de Envio de E-mail utilizado nos  -- 127.0.0.1
Local cMailUser 	:= GetMv( "MV_RELACNT" ) //Conta a ser utilizada no envio de E-Mail para os  -- workflow@workflow.com
Local cMailPass 	:= GetMv( "MV_RELPSW" ) //Senha da Conta de E-Mail para envio de relatorios  -- wf
Local cMensagem     := fLstBorder(_nSaldo,_nVlrExc,_cNatureza,_cNumDoc,_cCCusto)
Local cPara         := U_FnEmailNat(_cNatureza,"E")   //ALLTRIM(GETMV("MV_JISEMDR"))   //Email da diretoria de aportes
Local cParacc       := SPACE(0) //ALLTRIM(GETMV("MV_JISEMGF"))   //Email do Gestor financeiro
Local cTitulo       := "Nota fiscal de serviço não nao pode ser gravado por controle de orçamento "

If !Empty(cParacc)
	cPara+=";"+cParacc
Endif

cPara:= "totvs@pharmapele.com.br"

CONNECT SMTP SERVER cServer ACCOUNT cMailUser PASSWORD cMailPass RESULT lRes
If lRes
	lRes := MailAuth( cMailUser, cMailPass )
	If lRes
		If EMPTY(cPara)
			MsgAlert("Este e-mail será encaminhado para "+Alltrim(cEmailVazio),"E-mail não localizado no cadastro")
			SEND MAIL FROM cMailUser TO Alltrim(cEmailVazio) SUBJECT cTitulo BODY cMensagem ATTACHMENT aAnexo RESULT lRes
		Else
			SEND MAIL FROM cMailUser TO cPara  SUBJECT cTitulo BODY cMensagem ATTACHMENT aAnexo RESULT lRes
		Endif
	EndIf
EndIf
GET MAIL ERROR cMensagem

DISCONNECT SMTP SERVER
Return


Static Function fLstBorder(_nSaldo,_nVlrExc,_cNatureza,_cNumDoc,_cCCusto)
Local _aRet := AllUsers()
Local cHtmLst := Space(0)

U_fnHtml(@cHtmLst,1)

cHtmLst += '	<h3>PHARMAPELE</h3>	 <p> </p> 	<h1>NOTA FISCAL DE SERVIÇO - SEM ORÇAMENTO  </h1>        <tr>'
cHtmLst += '          <td width="30%">&nbsp;	</td></tr>'
cHtmLst += '<p>Segue abaixo detalhes: </p>'

cHtmLst += '<table width="450" border="1">'

cHtmLst += '    <tr>'
cHtmLst += '      <td >Filial</td>'
cHtmLst += '      <td>'+cFilAnt+'-'+Alltrim(FWFilialName())+'</td>'
cHtmLst += '    </tr>'

cHtmLst += '    <tr>'
cHtmLst += '      <td >NR. DOCUMENTO</td>'
cHtmLst += '      <td>'+Alltrim(_cNumDoc)+" - "+Right(DTOS(DDEMISSAO),2)+'/'+Substr(DTOS(DDEMISSAO),5,2)+'/'+Left(DTOS(DDEMISSAO),4)+'</td>'
cHtmLst += '    </tr>'


cHtmLst += '    <tr>'
cHtmLst += '      <td >DATA EMISÃO</td>'
cHtmLst += '      <td>'+Right(DTOS(DDEMISSAO),2)+'/'+Substr(DTOS(DDEMISSAO),5,2)+'/'+Left(DTOS(DDEMISSAO),4)+'</td>'
cHtmLst += '    </tr>'

cHtmLst += '    <tr>'
cHtmLst += '      <td >RESPONSAVEL</td>'
cHtmLst += '      <td>'+Upper(UsrRetName(RetCodUsr())) + '</td>'
cHtmLst += '    </tr>'



cHtmLst += '    <tr>'
cHtmLst += '      <td >VALOR</td>'
cHtmLst += '      <td>'+Transform(_nVlrExc,"@E 9,999,999,999.99")+'</td>'
cHtmLst += '    </tr>'

cHtmLst += '    <tr>'
cHtmLst += '      <td >FAVORECIDO</td>'
cHtmLst += '      <td>'+ Alltrim(CA100FOR)+"-"+Alltrim(CLOJA) + "  - " + Alltrim(Posicione("SA2",1,xFilial("SA2")+CA100FOR+CLOJA,"A2_NREDUZ"))+'</td>'
cHtmLst += '    </tr>'

cHtmLst += '    <tr>'
cHtmLst += '      <td >CENTRO DE CUSTO</td>'
cHtmLst += '      <td>'+Alltrim(_cCCusto)+"-"+Rtrim(Posicione("CTT",1,xFilial("CTT")+padr(Alltrim(_cCCusto),9),"CTT_DESC01"))+'</td>'
cHtmLst += '    </tr>'

cHtmLst += '    <tr>'
cHtmLst += '      <td>SALDO ORÇAMENTO </td>'
cHtmLst += '      <td>'+Transform(_nSaldo,"@E 9,999,999,999.99")+'</td>'
cHtmLst += '    </tr>'

cHtmLst += '    <tr>'
cHtmLst += '      <td scope="col">VALOR EXCEDIDO </td>'
cHtmLst += '      <td>'+Transform(_nVlrExc,"@E 9,999,999,999.99")+'</td>'
cHtmLst += '    </tr>'

cHtmLst += '  </table>'

cHtmLst += '<br><br>'
cHtmLst += '  <p>&nbsp;</p>'

cHtmLst += '<p> Responder para: '+ UsrRetMail(RetCodUsr()) +'</p>'

cHtmLst += '  <p>	<p>	<br>	</p>	<p>&nbsp;	  </p></form><p id="credits">Copyright Todos os Direitos Reservados </strong>.<br /><a href="http://www.pharmapele.com.br/">PHARMAPELE</a>.</p></body></html>'

//MemoWrite("C:\temp\003.html",cHtmLst)

Return(cHtmLst)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT103EXCºAutor  ³Microsiga           º Data ³  13/02/2020   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Valiar exclusão do documento de entrada                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT103EXC()
Local _aArea := GetArea()
Local _lRet := .T.
Local _lKeyOnOff  := U_fnkeyOrc()
Local _cCCusto   := Space(0)
Local _cNatureza:=  Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NATUREZ")
Local _cAnoMes := Space(06)
Local _cAporte := Space(06)
Local i        := 0
Private _cFilCC     := U_fnFilCC()//Localizar a filial na tabela ZZ2 para considerar como filial do Orçamento

For i:=1 To Len(aCOls)
	If !aCols[i,Len(aHeader)+1] //conto apenas as linhas nao removidas
		_cAnoMes:= aCols[i][GDFieldPos("D1_XMAORCD")]
		_cAporte:= aCols[i][GDFieldPos("D1_XNRSCS")]
		_cCCusto := aCols[i][GDFieldPos("D1_CC")]
	Endif
Next

If _lKeyOnOff .And. ;
	!Empty(_cAnoMes) .And. ;
	( ALLTRIM(CESPECIE) = 'NFS'   .OR. ALLTRIM(CESPECIE) = 'NFSC' .OR. ALLTRIM(CESPECIE) = 'NFCEE' )
	If MSGYESNO( "Esta exclusão irá gerar estornos do orçamento deseja continuar ?", "Alerta de orçamento" )
		//Estorno
		dbSelectArea("ZZX")
		dbSetOrder(2)  //ZZX_FILIAL+ZZX_NATURE+ZZX_ANO+ZZX_MES+ZZX_CCUSTO
		
		If dbSeek(_cFilCC+_cNatureza+Left(DTOS(DDEMISSAO),4)+Substring(DTOS(DDEMISSAO),5,2)+_cCCusto)
			RecLock("ZZX",.F.)
			ZZX->ZZX_UTILIZ := ZZX->ZZX_UTILIZ - SF1->F1_VALBRUT
			ZZX->ZZX_SALDO  := ZZX->ZZX_ORCADO - ( ZZX->ZZX_UTILIZ + ZZX->ZZX_EMPENH)
			If ZZX->ZZX_SALDO < 0
				ZZX->ZZX_SALDO := 0
			Endif
			If !Empty(_cAporte)
				ZZX->ZZX_APORTE := (ZZX->ZZX_APORTE - SF1->F1_VALBRUT)
				If ZZX->ZZX_APORTE < 0
					ZZX->ZZX_APORTE := 0
				Endif
			Endif
			MsUnLock("ZZX")
		Endif
		
		dbSelectArea("ZZQ")
		dbSetorder(1)//ZZQ_FILIAL+ZZQ_NATURE+ZZQ_ANO+ZZQ_MES
		
		If dbSeek(_cFilCC+ZZX->ZZX_NATURE+ZZX->ZZX_ANO+ZZX->ZZX_MES)
			Reclock("ZZQ",.F.)   //(2)
			
			ZZQ->ZZQ_UTILIZ :=  ZZQ->ZZQ_UTILIZ  - SF1->F1_VALBRUT
			ZZQ->ZZQ_SALDO  :=  ZZQ->ZZQ_ORCADO - ( ZZQ->ZZQ_UTILIZ + ZZQ->ZZQ_EMPENH)
			
			If ZZQ->ZZQ_SALDO < 0
				ZZQ->ZZQ_SALDO  := 0
			Endif
			
			If !Empty(_cAporte)
				ZZQ->ZZQ_APORTE := (ZZQ->ZZQ_APORTE - SF1->F1_VALBRUT)
				If ZZQ->ZZQ_APORTE < 0
					ZZQ->ZZQ_APORTE := 0
				Endif
			Endif
			ZZQ->(MsUnlock())
			
		Endif
		
		//remover do aporte se existir
		If !Empty(_cAporte)
			U_fnCEAporte(XFILIAL("SF1"),"NS",SF1->F1_DOC,"E",_cAporte)
		Endif
		
	Else
		_lRet := .F.
	Endif
Endif
RestArea(_aArea)
Return(_lRet)


// este PE trabalha em conjunto com o PE "MT103FIN"
User Function MT103GET
Public a103aCols := aClone(aCols) // nao remover
Public a103aHead := aClone(aHeader) // nao remover
Public aHeadFin  := {} // nao remover
Public aColsFin  := {} // nao remover
Public aNewRatCC  := {}  // NAO REMOVER
Public aContratos := {}  // NAO REMOVER


Return .F.

User Function MT103FIN() //FINANCEIRO
// este PE trabalha em conjunto com o PE "MT103GET"
Local aLocHead    := PARAMIXB[1] // aHeader do getdados apresentado no folter Financeiro.
Local aLocCols    := PARAMIXB[2] // aCols do getdados apresentado no folter Financeiro.
Local lRet        := PARAMIXB[3] // Flag de validações anteriores padrões do sistema.
Local nPosVencto  := aScan(aLocHead, {|x| UPPER(Alltrim(x[2])) == "E2_VENCTO"  })
Local nPosValor   := aScan(aLocHead, {|x| UPPER(Alltrim(x[2])) == "E2_VALOR"   })
Local nPosParcela := aScan(aLocHead, {|x| UPPER(Alltrim(x[2])) == "E2_PARCELA" })
Local nPosIss     := aScan(aLocHead, {|x| UPPER(Alltrim(x[2])) == "E2_ISS"     })
Local nX, nY, nXY, X
Local aAreaSC7    := SC7->( GetArea() )
/*
Local nPosPed     := aScan(a103aHead, {|x| UPPER(Alltrim(x[2])) == "D1_PEDIDO" })
Local nPosItPed   := aScan(a103aHead, {|x| UPPER(Alltrim(x[2])) == "D1_ITEMPC" })
Local nPosProd    := aScan(a103aHead, {|x| UPPER(Alltrim(x[2])) == "D1_COD"    })
Local nPosUM      := aScan(a103aHead, {|x| UPPER(Alltrim(x[2])) == "D1_UM"     })
Local nPosLocal   := aScan(a103aHead, {|x| UPPER(Alltrim(x[2])) == "D1_LOCAL"  })
Local nPosTES     := aScan(a103aHead, {|x| UPPER(Alltrim(x[2])) == "D1_TES"    })
Local nPITEMCTA	:= aScan(a103aHead, {|x| UPPER(Alltrim(x[2])) == "D1_ITEMCTA"})
Local nPCC        := aScan(a103aHead, {|x| UPPER(Alltrim(x[2])) == "D1_CC"     })
*/

U_CriaMV('','PH_DIASVEN','N','IMPLANTACAO TITULO - DIAS ANTECEDENCIA VENCIMENTO TITULO', '3')

If Len(aLocHead) > 0 .and. Len(aLocCols) > 0
	aHeadFin   := aClone(aLocHead) // variavel criada no PE "MT103GET"
	aColsFin   := aClone(aLocCols) // variavel criada no PE "MT103GET"
Endif

For nX:=1 To Len(aLocCols)
	If ! aLocCols[nX][Len(aLocCols[nX])] // Se a linha nao estiver deletada
		If aLocCols[nX][nPosValor] > 0 .And. aLocCols[nX][nPosVencto] < ( DataValida(Date() + GetMV('PH_DIASVEN')) )
			If Len(aLocCols) == 1
				MsgStop("Vencimento inferior a "+ AllTrim(STR(GetMV('PH_DIASVEN')))+" dias. O Vencimento correto é " + Dtoc( DataValida(Date() + GetMV('PH_DIASVEN')) ),"MT103FIN - PH_DIASVEN")
			Else
				MsgStop("Parcela "+aLocCols[nX][nPosParcela]+" com Vencimento inferior a "+ AllTrim(STR(GetMV('PH_DIASVEN'))) +" dias. Vencimento correto é " + Dtoc( DataValida(Date() + GetMV('PH_DIASVEN')) ),"MT103FIN - PH_DIASVEN")
			Endif
			If "TEST*HOMOLG" $ Alltrim(Upper(GetEnvServer()))
				MsgStop("LIBERADO PARA TESTE","MT103FIN - PH_DIASVEN")
				Return .T.
			EndIf
			Return .F.
		EndIf
	EndIf
Next nX

Return .T.

User Function MT103DNF
Local _lRet  := .t.
Local aDanfe := ParamIxb[01] // Execblock("MT103DNF",.F.,.F.,{aNFEDanfe})
// [01]: Cod. Transportadora // [02]: Peso Líquido // [03]: Peso Bruto
// [04]: Espécie 1 // [05]: Volume 1
// [06]: Espécie 2 // [07]: Volume 2
// [08]: Espécie 3 // [09]: Volume 3
// [10]: Espécie 4 // [11]: Volume 4
// [12]: Placa
// [13]: Chave Danfe
// [14]: Tipo Frete
// [15]: Valor Pedágio
// [16]: Fornecedor Retirada
// [17]: Loja Retirada
// [18]: Tipo Cte
// [19]: Fornecedor Entrega
// [20]: Loja Entrega
// [21]: N. AIDF
// [22]: Ano AIDF
// [23]: Modalidade
// [24]: Devolução Mercadoria não recebida
/*
If U_MyProcName("MATA920",Nil) .Or. U_MyProcName("FIN002",Nil)  .Or. U_MyProcName("MVCZZE",Nil)
Return .T.
Endif
*/
If (Alltrim(cEspecie) == "SPED" .OR. Alltrim(cEspecie) == "CTE") .And. "N" == cFormul //.And. U_VLDSDS(cNFiscal,cSerie,cA100For,cLoja)
	If Empty (alltrim(aDanfe[13]) )
		MsgInfo( "Para documentos do tipo SPED/CTE a chave da nota fiscal deve ser informada."  )
		//ConOut( "Para documentos do tipo SPED a chave da nota fiscal deve ser informada."  )
		_lRet := .F.
	Else
		_lRet := VLDCHVNFE(aDanfe[13],.T.)
	Endif
Endif

Return(_lRet)


/****************************************************************
| Rotina para validar a chave da nota fiscal digitada no campo. |
| Disparado pelo campo F1_CHVNFE. Quando o usuário digitar  uma |
| Chave errada o sistema validará o dígito verificador da mesma |
| Retornando uma mensagem ao usuário infromando que a chave  di |
| gitada é inválida.                                            |
****************************************************************/

// _Key  = Parametro com o número da chave da nota fiscal eletrônica para validação, o sistema validará somente se o mesmo estiver preenchido.
// _lMsg = Caso seja verdadeiro o sistema mostrará a mensagem de alerta se a chave é válida ou não.

Static Function VLDCHVNFE(_Key,_lMsg)
Local _lRet  := .t.
Local i,j,k,DV, DVChv

If !empty(alltrim(_Key))
	If Len(alltrim(_Key)) < 44
		If _lMsg
			MsgStop("A chave digitada possui somente "+alltrim(str(Len(alltrim(_Key))))+" caracteres. Verifique!","ATENÇÃO")
		Endif
		_lRet := .f.
	Else
		DVChv := Val(Substr(_Key,44,1))
		j = 1
		DV = 0.00
		For i = 43 To 1 Step -1
			j = Iif(j = 9, 2, j + 1)
			k = Alltrim(Str(i))
			A_&k. = j * Val(Substr(_Key, i, 1))
			DV = DV + A_&k.
		Next
		DV := DV - Int(DV / 11) * 11
		DV := If(Alltrim(Str(DV)) $ '0.1', 0, 11 - DV)
		If DV <> DVChv
			If _lMsg
				MsgStop("A chave digitada é inválida. Verifique!","ATENÇÃO")
			Endif
			_lRet := .f.
		Endif
	Endif
Endif

Return _lRet
