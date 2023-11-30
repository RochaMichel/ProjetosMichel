#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//?????????????????????????????????????????????????????????????????????????????
//?????????????????????????????????????????????????????????????????????????????
//?????????????????????????????????????????????????????????????????????????????
//???Programa  ?SYS086    ? Autor ? RUBENS LOPES CASTRO ? Data ?  08/03/2021 ??
//?????????????????????????????????????????????????????????????????????????????
//???Descricao ? Carga atualizacao clientes/Compras para o sistema In Pulse ???
//???          ?                                                            ???
//?????????????????????????????????????????????????????????????????????????????
//???Uso       ? Elizabeth Sul                                              ???
//?????????????????????????????????????????????????????????????????????????????
//?????????????????????????????????????????????????????????????????????????????
//?????????????????????????????????????????????????????????????????????????????

//??+--------------+-----------------------------------------------------------------------------------??
//??? Analista     ?  RUBENS LOPES CASTRO                     ? Data Alteracao       ? 08/03/2021      ??
//??+--------------+------------------------------------------+----------------------+----------------+??
//??? Altera??o    ? Rotina refeita a partir da SYS086, pois estava demorando mais de 8 horas          ??
//??+              ?                                                                                   ??
//??+--------------+-----------------------------------------------------------------------------------??
//*??+--------------+-----------------------------------------------------------------------------------??
//??? Analista     ?  RUBENS LOPES CASTRO                     ? Data Alteracao       ? 10/03/2021      ??
//??+--------------+------------------------------------------+----------------------+----------------+??
//??? Alteracao    ? Alteradas as regiões filtradas e incluído novo campo no layout conforme chamados  ??
//??+              ? 145.755 e 194.828                                                                 ??
//??+--------------+-----------------------------------------------------------------------------------??
//??? Alteracao    ? Alteradas as regiões filtradas conforme chamado 245595 em 28/07/2021.             ??
//??+ Sérgio Arruda?                                                                                   ??
//??+--------------+-----------------------------------------------------------------------------------??

User Function SYS086

Local nOpca := 0
Local aSays:={}, aButtons:={}
Private cCadastro := OemToAnsi("Gera arquivo .txt para o sistema In Pulse")

cPerg := PADR("SYS086",10)

ValidPerg()

Pergunte(cPerg,.t.)

AADD(aSays,OemToAnsi( "  Este programa tem como objetivo gerar o arquivo .txt para o sistema in Pulse " ) )
AADD(aSays,OemToAnsi( "  referente a atualizacao de clientes e compras." ) )
AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
FormBatch( cCadastro, aSays, aButtons )

If ( nOpcA == 1)
	
	Processa({|lEnd| fInPulse()},"Gerando arquivo...")  
	
Endif

Return

*************************
Static Function fInPulse()

Local cQuery := ""
Local cRegioes := "'SL','SD','CO'"//"'SL','SD','CO','NE','NO'"

cArq1 := Alltrim(mv_par01)+"elizabethsulclientes"+StrTran(Dtoc(dDatabase),"/","")+".txt"
cArq2 := Alltrim(mv_par01)+"elizabethsulcompras"+StrTran(Dtoc(dDatabase),"/","")+".txt"

nHdl1    := fCreate(cArq1)
If nHdl1 == -1
    MsgAlert("O arquivo de nome "+cArq1+" nao pode ser gerado! Verifique o acesso.","Atencao!")
    Return
Endif

nHdl2    := fCreate(cArq2)
If nHdl2 == -1
    MsgAlert("O arquivo de nome "+cArq2+" nao pode ser gerado! Verifique o acesso.","Atencao!")
    Return
Endif

dbSelectArea("AI0")  // Cadastro de Complemento de Clientes
dbSetOrder(1)

dbSelectArea("SA1")
dbSetOrder(1)

// Agora (e não depois) vejo os clientes que já compraram
// Arquivo elizabethsulcompras.txt

//cQuery += "SELECT ZZZ.* FROM ( "
//cQuery := "SELECT SA1.A1_VEND,SA1.A1_COD,SA1.A1_LOJA, SA1.A1_NOME,SA1.A1_NREDUZ,SA1.A1_CGC,SA1.A1_END,SA1.A1_BAIRRO,SA1.A1_MUN,SA1.A1_CEP,SA1.A1_EST,SA1.A1_DDD,SA1.A1_TEL,SA1.A1_EMAIL,SA1.A1_TIPO,SA1.A1_CONTATO,SA1.A1_XTEL2,SA1.A1_ULTCOM, SA1.A1_VENCLC, "
cQuery := "SELECT SA1.A1_VEND,SA1.A1_COD,SA1.A1_LOJA, SA1.A1_NOME,SA1.A1_NREDUZ,SA1.A1_CGC,SA1.A1_END,SA1.A1_BAIRRO,SA1.A1_MUN,SA1.A1_CEP,SA1.A1_EST,SA1.A1_DDD,SA1.A1_TEL,' ' AS A1_EMAIL,SA1.A1_TIPO,SA1.A1_CONTATO,SA1.A1_XTEL2,SA1.A1_ULTCOM, SA1.A1_VENCLC, "
cQuery += "       SD2.D2_FILIAL,SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_EMISSAO, SD2.D2_QUANT, SD2.D2_TOTAL, SD2.D2_NUMLOTE, SD2.D2_UM, SD2.D2_PRCVEN, SD2.D2_COD, SD2.D2_ITEM, "
cQuery += "       sum(SD2.D2_TOTAL) over (partition by SD2.D2_FILIAL,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_SERIE,SD2.D2_DOC order by SD2.D2_FILIAL,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_SERIE,SD2.D2_DOC) as VLRLIQ, "
cQuery += "       SA4.A4_NOME, "
cQuery += "       SE4.E4_DESCRI, "
cQuery += "       SF2.F2_TRANSP, SF2.F2_VEND1, SF2.F2_VEND2, SF2.F2_EMISSAO, "
cQuery += "       SB1.B1_DESC "
cQuery += "FROM "+RetSqlName("SD2")+" SD2 " 
cQuery += " JOIN "+RetSqlName("SF2")+" SF2 ON SF2.D_E_L_E_T_ = ' ' AND SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE " 
//cQuery += " JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_COD = SD2.D2_COD AND SB1.B1_XFILFAB = '020202' AND SB1.B1_TIPO = '01' AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += " JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_COD = SD2.D2_COD AND SB1.B1_TIPO = '01' AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery += " JOIN "+RetSqlName("SA1")+" SA1 ON SA1.D_E_L_E_T_ = ' ' AND SA1.A1_COD = SD2.D2_CLIENTE AND SA1.A1_LOJA = SD2.D2_LOJA  AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery += " JOIN "+RetSqlName("SA4")+" SA4 ON SA4.D_E_L_E_T_ = ' ' AND SA4.A4_FILIAL = '"+xFilial("SA4")+"' AND SA4.A4_COD = SF2.F2_TRANSP "
//cQuery += " JOIN "+RetSqlName("SF4")+" SF4 ON SF4.D_E_L_E_T_ = ' ' AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_DUPLIC = 'S' AND SF4.F4_FILIAL = '"+xFilial("SF4")+"' " 
cQuery += " JOIN "+RetSqlName("SF4")+" SF4 ON SF4.D_E_L_E_T_ = ' ' AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_DUPLIC = 'S' AND SF4.F4_FILIAL = SD2.D2_FILIAL " 
cQuery += " JOIN "+RetSqlName("SE4")+" SE4 ON SE4.D_E_L_E_T_ = ' ' AND SE4.E4_FILIAL = '"+xFilial("SE4")+"' AND SE4.E4_CODIGO = SF2.F2_COND "
cQuery += "WHERE SD2.D_E_L_E_T_ = ' '  "
//cQuery += " AND SD2.D2_FILIAL = '"+xFilial("SD2")+"' "
cQuery += " AND SD2.D2_TIPO = 'N' "
cQuery += " AND (SD2.D2_CLIENTE,SD2.D2_LOJA) IN  "
cQuery += "     (SELECT SSA1.A1_COD,SSA1.A1_LOJA FROM "+RetSqlName("SA1") +" SSA1 "
cQuery += "         WHERE SSA1.D_E_L_E_T_ = ' ' "

//cQuery += "       AND ((SSA1.A1_TIPO = 'R' AND (SSA1.A1_REGIAO IN ('SL','SD')      OR SSA1.A1_EST = 'DF' OR SSA1.A1_EST = 'GO' OR SSA1.A1_EST = 'MS' OR SSA1.A1_EST = 'AC' OR SSA1.A1_EST = 'TO' OR SSA1.A1_EST = 'RO')) OR SSA1.A1_CGC = '20585961000112'  OR (SSA1.A1_TIPO = 'F' AND SSA1.A1_REGIAO IN ('SL','SD','CO')) ) "  // RLC 10/03/2021 - Ajustadas Regioes conforme chamado 194.828
cQuery += "         AND ((SSA1.A1_TIPO = 'R' AND (SSA1.A1_REGIAO IN ("+cRegioes+") OR SSA1.A1_EST = 'AC' OR SSA1.A1_EST = 'TO' OR SSA1.A1_EST = 'RO')) OR SSA1.A1_CGC = '20585961000112' OR (SSA1.A1_TIPO = 'F' AND SSA1.A1_REGIAO IN ("+cRegioes+")) ) "  // RLC 28/07/2021 - Ajustadas Regioes conforme chamado 245595 - Sérgio Arruda

cQuery += "         AND SSA1.A1_PESSOA = 'J' "
cQuery += "         AND SSA1.A1_CGC NOT IN (SELECT SA3.A3_CGC FROM "+RetSQLName("SA3")+ " SA3 WHERE SA3.D_E_L_E_T_ = ' ') "
cQuery += "         AND SSA1.A1_CGC NOT IN (SELECT XSA4.A4_CGC FROM "+RetSQLName("SA4")+ " XSA4 WHERE XSA4.D_E_L_E_T_ = ' ') ) "//) ZZZ "
cQuery += "  ORDER BY D2_FILIAL, D2_CLIENTE, D2_LOJA, F2_EMISSAO DESC, D2_SERIE, D2_DOC "
		
If Select("QSD2") > 0
	QSD2->(dbCloseArea())
EndIf

MemoWrite("C:\temp\SYS086.sql",cQuery)

TcQuery cQuery Alias QSD2 New
count to nRegs

cEol    := CHR(13)+CHR(10)

ProcRegua(nRegs)

QSD2->(dbGoTop())
While !QSD2->(Eof())

	// Alterado por Sérgio Arruda em 06/07/2021 conf Chamado 189629 
	//cOpera := Alltrim(IIF(Empty(QSD2->F2_VEND2),QSD2->F2_VEND1,QSD2->F2_VEND2))
	//If Empty(cOpera)
	//	cOpera := Alltrim(QSD2->A1_VEND)
	//EndIf
	
	cOpera := Alltrim(UPPER(QSD2->A1_VEND))
	
	cLinha := QSD2->A1_COD+QSD2->A1_LOJA+"|" //CODIGO
	cLinha += Alltrim(UPPER(QSD2->A1_NOME))+"|" //RAZAO SOCIAL
	cLinha += Alltrim(UPPER(QSD2->A1_NREDUZ))+"|" //NOME FANTASIA
	cLinha += Alltrim(QSD2->A1_CGC)+"|" //CNPJ/CPF
	cLinha +=  Alltrim(UPPER(QSD2->A1_END))+"|"//ENDERE?O
	cLinha +=  Alltrim(UPPER(QSD2->A1_BAIRRO))+"|"//BAIRRO
	cLinha +=  Alltrim(UPPER(QSD2->A1_MUN))+"|"//CIDADE
	cLinha +=  Alltrim(QSD2->A1_CEP)+"|"//CEP	
	cLinha +=  Alltrim(UPPER(QSD2->A1_EST))+"|"//ESTADO	
	
	A1DDD := Alltrim(IIF(Len(Alltrim(QSD2->A1_DDD))==3,Substr(QSD2->A1_DDD,2,2),QSD2->A1_DDD))
	
	cLinha +=  A1DDD+Alltrim(QSD2->A1_TEL)+"|"//AREA1+FONE1	
	cLinha +=  Alltrim(Lower(QSD2->A1_EMAIL))+"|"//EMAIL	
	cLinha +=  Alltrim(UPPER(QSD2->A4_NOME))+"|"//UNIDADE	
	cLinha +=  IIF(QSD2->A1_TIPO=="F","CONSUMIDOR FINAL","REVENDA")+"|"//SEGMENTO		
	cLinha +=  Alltrim(UPPER(QSD2->A1_CONTATO))+"|"//CONTATO
	cLinha +=  "|"//EMAIL CONTATO	
	cLinha +=  "|"//CARGO CONTATO		
	cLinha +=  A1DDD+Alltrim(QSD2->A1_XTEL2)+"|"//TEL CONTATO		
	
	// Alteracao feita por Sérgio Arruda em 25/11/2021 - Chamado 252974 
	// Trecho retornado por Walter Rodrigo em 06/02/2023 - chamado 353328
	cLinha +=  IIF(EMPTY(QSD2->A1_ULTCOM),"",DTOC(STOD(QSD2->A1_ULTCOM)))+"|"//DT ULT. COMPRA
	//If AI0->( dbSeek(xFilial("SA1")+QSD2->A1_COD+QSD2->A1_LOJA))
 	//   cLinha +=  IIF(EMPTY(AI0->AI0_XULTCO),"",DTOC(AI0->AI0_XULTCO))+"|"//DT ULT. COMPRA
	//Else 
 	//   cLinha +=  "|"
	//Endif 	

	cLinha +=  cOpera+"|"//OPERADOR 
	cLinha +=  "|"//SALDO
	cLinha +=  ""//POTENCIAL
	cLinha +=  "|||"+IIF(EMPTY(QSD2->A1_VENCLC),"",DTOC(STOD(QSD2->A1_VENCLC))) //DT VENC LIMITE DE CREDITO  // RLC 10/03/2021 - Incluído conforme chamado 145755 

	cLinha += cEol
		
	fWrite(nHdl1,cLinha,354)
	
	_nNF := 1
	_cCliente :=  QSD2->D2_FILIAL+QSD2->A1_COD+QSD2->A1_LOJA

	//Incluído por Sérgio Arruda em 14/09/2021 - Chamado 252974  
	While !QSD2->(Eof()) .and. (QSD2->D2_FILIAL+QSD2->A1_COD+QSD2->A1_LOJA) == _cCliente
		IncProc()
		If _nNf < 4
			//_nNF++
			cLinha :=  Alltrim(QSD2->D2_DOC)+"|"								//ID_COMPRA
			cLinha +=  QSD2->A1_COD+QSD2->A1_LOJA+"|"							//CODIGO_ERP_CLIENTE
			cLinha +=  DTOC(STOD(QSD2->F2_EMISSAO))+"|"							//DATA_COMPRA

			If AI0->( dbSeek(xFilial("SA1")+QSD2->A1_COD+QSD2->A1_LOJA))
			   If Empty(AI0->AI0_XULTCO)
					  RecLock("AI0",.F.)
					  Replace AI0_XULTCO  With STOD(QSD2->F2_EMISSAO)
					  MsUnLock()
					  AI0->( dbCommit() )
			   ElseIf STOD(QSD2->F2_EMISSAO) > AI0->AI0_XULTCO
					
					  RecLock("AI0",.F.)
					  Replace AI0_XULTCO  With STOD(QSD2->F2_EMISSAO)
					  MsUnLock()
					  AI0->( dbCommit() )
			   Endif
			Else 
			   RecLock("AI0",.T.) 
			   Replace AI0_FILIAL  With xFilial("AI0")
			   Replace AI0_CODCLI  With QSD2->A1_COD
			   Replace AI0_LOJA    With QSD2->A1_LOJA
			   Replace AI0_INTEG   With "2" 
			   Replace AI0_XULTCO  With STOD(QSD2->F2_EMISSAO)
			   MsUnLock()
			   AI0->( dbCommit() )
 			Endif         
			     	
			cLinha +=  Alltrim(Transform(QSD2->VLRLIQ,"@e 99999999.99"))+"|"	//VALOR TOTAL DA COMPRA	
			cLinha +=  Alltrim(UPPER(QSD2->E4_DESCRI))							//FORMA DE PAGAMENTO	
			cLinha += cEol

			_cNota := QSD2->D2_FILIAL+QSD2->D2_CLIENTE+QSD2->D2_LOJA+QSD2->D2_SERIE+QSD2->D2_DOC
			While !QSD2->(Eof()) .and. (QSD2->D2_FILIAL+QSD2->A1_COD+QSD2->A1_LOJA) == _cCliente .and. (QSD2->D2_FILIAL+QSD2->D2_CLIENTE+QSD2->D2_LOJA+QSD2->D2_SERIE+QSD2->D2_DOC) == _cNota 
				cLinha +=  Alltrim(QSD2->D2_DOC)+"|"										//ID_COMPRA		
				cLinha +=  Alltrim(QSD2->D2_COD)+"|"										//CODIGO			
				cLinha +=  Alltrim(UPPER(QSD2->B1_DESC))+" - "+Left(QSD2->D2_NUMLOTE,1)+"|"	//DESCRICAO
				cLinha +=  Alltrim(Transform(QSD2->D2_QUANT,"@e 99999999.99"))+"|"			//QUANTIDADE
				cLinha +=  Alltrim(QSD2->D2_UM)+"|"											//UNIDADE DE MEDIDA
				cLinha +=  Alltrim(Transform(QSD2->D2_PRCVEN,"@e 99999999.99"))+"|"			//VALOR UNITARIO		

				cLinha += cEol
			
				QSD2->(dbSkip())				

			Enddo 

			fWrite(nHdl2,cLinha,Len(cLinha))

		Else

			QSD2->(dbSkip())
			
		Endif

		_nNF++

	Enddo	

Enddo

QSD2->(dbCloseArea())



// Depois (e não primeiro) incluo os clientes que nunca compraram
// Arquivo elizabethsulclientes.txt
//cQuery    := " SELECT SA1.A1_VEND,SA1.A1_COD,SA1.A1_LOJA, SA1.A1_NOME,SA1.A1_NREDUZ,SA1.A1_CGC,SA1.A1_END,SA1.A1_BAIRRO,SA1.A1_MUN,SA1.A1_CEP,SA1.A1_EST,SA1.A1_DDD,SA1.A1_TEL,SA1.A1_EMAIL,SA1.A1_TIPO,SA1.A1_CONTATO,SA1.A1_XTEL2,SA1.A1_ULTCOM, SA1.A1_OUTRMUN, SA1.A1_VENCLC "
cQuery    := " SELECT SA1.A1_VEND,SA1.A1_COD,SA1.A1_LOJA, SA1.A1_NOME,SA1.A1_NREDUZ,SA1.A1_CGC,SA1.A1_END,SA1.A1_BAIRRO,SA1.A1_MUN,SA1.A1_CEP,SA1.A1_EST,SA1.A1_DDD,SA1.A1_TEL,' ' AS A1_EMAIL,SA1.A1_TIPO,SA1.A1_CONTATO,SA1.A1_XTEL2,SA1.A1_ULTCOM, SA1.A1_OUTRMUN, SA1.A1_VENCLC "
cQuery    += " FROM "+RetSQLName("SA1") + " SA1 "
cQuery    += " WHERE SA1.D_E_L_E_T_ = ' ' " 
cQuery    += " AND SA1.A1_PESSOA = 'J' "
cQuery    += " AND SA1.A1_CGC NOT IN (SELECT SA3.A3_CGC FROM "+RetSQLName("SA3")+ " SA3 WHERE SA3.D_E_L_E_T_ = ' ') "
cQuery    += " AND SA1.A1_CGC NOT IN (SELECT XSA4.A4_CGC FROM "+RetSQLName("SA4")+ " XSA4 WHERE XSA4.D_E_L_E_T_ = ' ') "

//cQuery  += "  AND ((SA1.A1_TIPO = 'R' AND (SA1.A1_REGIAO IN ('SL','SD')      OR SA1.A1_EST = 'DF' OR SA1.A1_EST = 'GO' OR SA1.A1_EST = 'MS' OR SA1.A1_EST = 'AC' OR SA1.A1_EST = 'TO' OR SA1.A1_EST = 'RO')) OR SA1.A1_CGC = '20585961000112'  OR (SA1.A1_TIPO = 'F' AND SA1.A1_REGIAO IN ('SL','SD','CO')) ) "  // RLC 10/03/2021 - Ajustadas Regioes conforme chamado 194.828
cQuery    += "  AND ((SA1.A1_TIPO = 'R' AND (SA1.A1_REGIAO IN ("+cRegioes+") OR SA1.A1_EST = 'AC' OR SA1.A1_EST = 'TO' OR SA1.A1_EST = 'RO')) OR SA1.A1_CGC = '20585961000112'  OR (SA1.A1_TIPO = 'F' AND SA1.A1_REGIAO IN ("+cRegioes+")) ) "  // RLC 28/07/2021 - Ajustadas Regioes conforme chamado 245595 - Sérgio Arruda

cQuery    += " AND (SA1.A1_COD,SA1.A1_LOJA) NOT IN (SELECT SD2.D2_CLIENTE, SD2.D2_LOJA FROM "+RetSQLName("SD2")+ " SD2  "
cQuery    += "  JOIN "+RetSQLName("SF2")+ " SF2 ON SF2.D_E_L_E_T_ = ' ' AND SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE "
cQuery    += "  JOIN "+RetSQLName("SB1")+ " SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_COD = SD2.D2_COD AND SB1.B1_XFILFAB = '020202' AND SB1.B1_TIPO = '01' "
cQuery    += "  JOIN "+RetSQLName("SA1")+ " XSA1 ON XSA1.D_E_L_E_T_ = ' ' AND XSA1.A1_COD = SD2.D2_CLIENTE AND XSA1.A1_LOJA = SD2.D2_LOJA  AND XSA1.A1_PESSOA = 'J' "  
cQuery    += "                                            AND XSA1.A1_CGC NOT IN (SELECT SA3.A3_CGC FROM "+RetSQLName("SA3")+ " SA3 WHERE SA3.D_E_L_E_T_ = ' ') "
cQuery    += "                                            AND XSA1.A1_CGC NOT IN (SELECT TSA4.A4_CGC FROM "+RetSQLName("SA4")+ " TSA4 WHERE TSA4.D_E_L_E_T_ = ' ') "  
//cQuery  += "                                            AND ((XSA1.A1_TIPO = 'R' AND (XSA1.A1_REGIAO IN ('SL','SD') OR XSA1.A1_EST = 'DF' OR XSA1.A1_EST = 'GO' OR XSA1.A1_EST = 'MS' OR XSA1.A1_EST = 'AC' OR XSA1.A1_EST = 'TO' OR XSA1.A1_EST = 'RO')) OR XSA1.A1_CGC = '20585961000112'  OR (XSA1.A1_TIPO = 'F' AND XSA1.A1_REGIAO IN ('SL','SD','CO')) ) " // RLC 10/03/2021 - Ajustadas Regioes conforme chamado 194.828
cQuery    += "                                            AND ((XSA1.A1_TIPO = 'R' AND (XSA1.A1_REGIAO IN ("+cRegioes+") OR XSA1.A1_EST = 'AC' OR XSA1.A1_EST = 'TO' OR XSA1.A1_EST = 'RO')) OR XSA1.A1_CGC = '20585961000112'  OR (XSA1.A1_TIPO = 'F' AND XSA1.A1_REGIAO IN ("+cRegioes+")) ) " // RLC 28/07/2021 - Ajustadas Regioes conforme chamado 245595 - Sergio
cQuery    += "  JOIN "+RetSQLName("SA4")+ " SA4 ON SA4.D_E_L_E_T_ = ' ' AND SA4.A4_COD = SF2.F2_TRANSP "
cQuery    += "  JOIN "+RetSQLName("SF4")+ " SF4 ON SF4.D_E_L_E_T_ = ' ' AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_DUPLIC = 'S' AND SF4.F4_FILIAL = '"+xFilial("SF4")+"' " 
cQuery    += "  JOIN "+RetSQLName("SE4")+ " SE4 ON SE4.D_E_L_E_T_ = ' ' AND SE4.E4_FILIAL = '"+xFilial("SE4")+"' AND SE4.E4_CODIGO = SF2.F2_COND "
cQuery    += " WHERE SD2.D_E_L_E_T_ = ' '  "
cQuery    += "  AND SD2.D2_FILIAL = '"+xFilial("SD2")+"' "
cQuery    += "  AND SD2.D2_TIPO = 'N' )"
		
If Select("QSA1") > 0
	QSA1->(dbCloseArea())
EndIf

TcQuery cQuery Alias QSA1 New
count to nRegs

cEol    := CHR(13)+CHR(10)

ProcRegua(nRegs)

QSA1->(dbGoTop())
While !QSA1->(Eof())
    
	IncProc()
		
	cOpera := Alltrim(UPPER(QSA1->A1_VEND))
	
	cLinha := QSA1->A1_COD+QSA1->A1_LOJA+"|" //CODIGO
	cLinha += Alltrim(UPPER(QSA1->A1_NOME))+"|" //RAZAO SOCIAL
	cLinha += Alltrim(UPPER(QSA1->A1_NREDUZ))+"|" //NOME FANTASIA
	cLinha += Alltrim(QSA1->A1_CGC)+"|" //CNPJ/CPF
	cLinha +=  Alltrim(UPPER(QSA1->A1_END))+"|"//ENDERE?O
	cLinha +=  Alltrim(UPPER(QSA1->A1_BAIRRO))+"|"//BAIRRO
	cLinha +=  Alltrim(UPPER(QSA1->A1_MUN))+"|"//CIDADE
	cLinha +=  Alltrim(QSA1->A1_CEP)+"|"//CEP	
	cLinha +=  Alltrim(UPPER(QSA1->A1_EST))+"|"//ESTADO	
	
	A1DDD := Alltrim(IIF(Len(Alltrim(QSA1->A1_DDD))==3,Substr(QSA1->A1_DDD,2,2),QSA1->A1_DDD))
	
	cLinha +=  A1DDD+Alltrim(QSA1->A1_TEL)+"|"//AREA1+FONE1	
	cLinha +=  Alltrim(Lower(QSA1->A1_EMAIL))+"|"//EMAIL	
	cLinha +=  " |"//UNIDADE	
	cLinha +=  IIF(QSA1->A1_TIPO=="F","CONSUMIDOR FINAL","REVENDA")+"|"//SEGMENTO		
	cLinha +=  Alltrim(UPPER(QSA1->A1_CONTATO))+"|"//CONTATO
	cLinha +=  "|"//EMAIL CONTATO	
	cLinha +=  "|"//CARGO CONTATO		
	cLinha +=  A1DDD+Alltrim(QSA1->A1_XTEL2)+"|"//TEL CONTATO		

	// Alteracao feita por Sérgio Arruda em 25/11/2021 - Chamado 252974 
	// cLinha +=  IIF(EMPTY(QSA1->A1_ULTCOM),"",DTOC(STOD(QSA1->A1_ULTCOM)))+"|"//DT ULT. COMPRA
	If AI0->( dbSeek(xFilial("SA1")+QSA1->A1_COD+QSA1->A1_LOJA))
 	   cLinha +=  IIF(EMPTY(AI0->AI0_XULTCO),DTOC(STOD(QSA1->A1_ULTCOM)),DTOC(AI0->AI0_XULTCO))+"|"//DT ULT. COMPRA
	Else 
	   cLinha +=  IIF(EMPTY(QSA1->A1_ULTCOM),"",DTOC(STOD(QSA1->A1_ULTCOM)))+"|"//DT ULT. COMPRA
	Endif 	

	cLinha +=  cOpera+"|"//OPERADOR 
	cLinha +=  "|"//SALDO
	cLinha +=  ""//POTENCIAL
	cLinha +=  "|||"+IIF(EMPTY(QSA1->A1_VENCLC),"",DTOC(STOD(QSA1->A1_VENCLC))) //DT VENC LIMITE DE CREDITO  // RLC 10/03/2021 - Incluído conforme chamado 145755 
	
	cLinha += cEol
		
	fWrite(nHdl1,cLinha,354)
	
//	fCompras()
    
    QSA1->(dbSkip())
End

QSA1->(dbCloseArea())

fClose(nHdl1)
fClose(nHdl2)

Return

/*                       
?????????????????????????????????????????????????????????????????????????????
???Funcao    ?VALIDPERG ?                                                  ??
?????????????????????????????????????????????????????????????????????????J??
???Descricao ? Verifica as perguntas inclu?ndo-as caso nao existam        ???
?????????????????????????????????????????????????????????????????????????J??
???Uso       ? Especifico para clientes Microsiga                         ???
????????????????????????????????????????????????????????????????????????????
*/
Static Function ValidPerg()
  
  	Local j:=1
  	Local i:=1
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	aRegs:={}

	AADD(aRegs,{cPerg,"01","Selecione o diretorio ?","","","mv_ch1","C",50,0,0,"G","U_SYS086A()","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	 
	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
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
Return               

**********************************
User Function SYS086A()

cFile := cGetFile('Local','Selecione a pasta',0,'C:\',.T.,GETF_LOCALHARD+GETF_RETDIRECTORY,.F.)
 
If !Empty(cFile)
	mv_par01:= cfile
EndIf	

Return(.t.)
**********************************
