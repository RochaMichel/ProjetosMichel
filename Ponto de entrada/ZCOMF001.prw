#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#include "topconn.ch"
#include "Ap5Mail.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³JOB Central ºAutor  ³	Drilltec         º Data ³  09/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Elizabeth                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ZCOMF001()

Local cPara		:= ''
Local cCopia	:= ''
Local cAssunto	:= ''
Local cTexto	:= ''
Public cFiles  	:= ""
Private aEmp	:= {}		// Array que armazena as empresas e filiais que irão executar o JOB
Private cDiaEmi := ""       // Dias permitidos para emissão de relatório via JOB
Private lEmitDia:= .F.      // Variável que informa se deve emitir no dia de via JOB
Private cEmpFil := ""       // Empresa e Filial que grupra os relatórios
Private cUnif
Private lUnif := .F.
Private cNumeroped := SC7->C7_NUM
Private aPerg := {}
Private aRetParam := {} 

AAdd(aPerg,{1,"E-mails",Space(200),"","","","",100,.F.})

DBSELECTAREA("SC7")
SC7->(DBSEEK(XFILIAL("SC7")+cNumeroped))

U_COMR013('SC7',SC7->(RecNo()),1)

DBSELECTAREA("SC7")
SC7->(DBSEEK(XFILIAL("SC7")+cNumeroped))
					
cPara		:= POSICIONE("SA2",1,XFILIAL("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_EMAIL") + ";" + POSICIONE("SY1",1,XFILIAL("SY1")+SC7->C7_COMPRA,"Y1_EMAIL")    
//cPara		:= "jose.junior@drilltecsolucoes.com.br"    
cCopia	    :=  ''                    
cAssunto    := "Pedido de Compra No."+SC7->C7_NUM

cTexto := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> '
cTexto += '  <html> 
cTexto += '  <head> 
cTexto += '  <meta http-equiv="Content-Type" content="text/html; charset=utf-8"> 
cTexto += '  <title>Aprovacao</title> 
cTexto += '  <style type="text/css"> 
cTexto += '  <!-- 
cTexto += '  .style1 { 
cTexto += '	font-family: "Courier New", Courier, monospace; 
cTexto += '	font-weight: bold; 
cTexto += '} '
cTexto += '#apDiv1 { 
cTexto += '	position:absolute; 
cTexto += '	left:1149px; 
cTexto += '	top:25px; 
cTexto += '	width:160px; 
cTexto += '	height:85px; 
cTexto += '	z-index:1; 
cTexto += '} 
cTexto += '#apDiv2 { 
cTexto += '	position:absolute; 
cTexto += '	left:1126px; 
cTexto += '	top:20px; 
cTexto += '	width:174px; 
cTexto += '	height:92px; 
cTexto += '	z-index:1; 
cTexto += '} 
cTexto += '#apDiv3 { 
cTexto += '	position:absolute; 
cTexto += '	left:12px; 
cTexto += '	top:105px; 
cTexto += '	width:338px; 
cTexto += '	height:47px; 
cTexto += '	z-index:1; 
cTexto += '} 
cTexto += '#apDiv4 { 
cTexto += '	position:absolute; 
cTexto += '	left:156px; 
cTexto += '	top:91px; 
cTexto += '	width:226px; 
cTexto += '	height:19px; 
cTexto += '	z-index:1; 
cTexto += '}
cTexto += '.aaaaa {	color: #FFF;
cTexto += '}
cTexto += '.bbbbbb {
cTexto += '	color: #FFF;
cTexto += '}
cTexto += '.Numero {
cTexto += '	text-align: right;
cTexto += '}
cTexto += '.RIGHT {
cTexto += '	text-align: right;
cTexto += '}
cTexto += '.Branco {
cTexto += '	color: #FFFFFF;
cTexto += '}
cTexto += '.table.table-striped.table-bordered.table-hover.table.table-sm tr td div {
cTexto += '	text-align: justify;
cTexto += '}
cTexto += '-->
cTexto += '  </style>

cTexto += '<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css">
cTexto += '		<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
cTexto += '		<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"></script>
cTexto += '		<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"></script>
cTexto += '</head>

cTexto += '<body>

cTexto += '<fieldset>
cTexto += '<legend class="style1"></legend>
cTexto += '<form name="form1" method="post" action="mailto:%WFMailTo%">
cTexto += '  <p class="font-weight-normal"><span class="Branco">O</span></p>
cTexto += '  <table width="100%" border="1" bordercolor="#B2CBE7" class="table table-striped table-bordered table-hover table table-sm">
cTexto += '    <tr bgcolor="#B2CBE7">
cTexto += '      <td colspan="1" align="center" bgcolor="#1D5692"><strong class="bbbbbb"><span class="font-weight-normal">Pedido de Compras No. '+SC7->C7_NUM+'.</span></strong></td>
cTexto += '    </tr>
cTexto += '    <tr bgcolor="#B2CBE7">
cTexto += '      <td width="100%"><div align="justify">
cTexto += '        <p>&nbsp;</p>
cTexto += '        <p>Prezado  fornecedor, </p>
cTexto += '        <p><br>
cTexto += '          Anexo  a este segue nossa confirmação de compra. <br>
cTexto += '  <strong>Pedimos atenção/fiel  cumprimento dos informativos abaixo:</strong></p>
cTexto += '        <ol>
cTexto += '          <li>O número do pedido de compra deverá <u>obrigatoriamente</u> estar destacado de forma visível na nota fiscal; </li>
cTexto += '          <li>Atentar ao recebimento automático de pedido de compra, a fim  de evitar fornecimento em duplicidade; </li>
cTexto += '          <li>O prazo de entrega pactuado deverá  ser respeitado. Qualquer eventualidade quanto a este prazo ou ainda quanto à entrega  parcial, deverá ser comunicada de forma prévia ao comprador responsável.</li>
cTexto += '          <li>A Nota Fiscal deverá estar com todos os itens em <u>conformidade</u> (CPNJ, preço, quantidade, especificação, dentre outros aspectos) com o pedido  de compra. </li>
cTexto += '          <li>Enviar <u>obrigatoriamente</u> o  XML da NF para o endereço eletrônico: <a href="mailto:nf@grupoelizabeth.com.br">nf@grupoelizabeth.com.br</a></li>
cTexto += '        </ol>
cTexto += '        <p><u>HORÁRIO  DE RECEBIMENTO</u>:  SEG A SEXT: 07:30 as 11:30 / 12:30 as 15:00<br>
cTexto += '          </p>
cTexto += '        <p>&nbsp;</p>
cTexto += '        <p><strong>Departamento de Compras</strong> <br>
cTexto += '          (83)2107-2000 </p>
cTexto += '        <p><strong><br>
cTexto += '          </strong><br>
cTexto += '        </p>
cTexto += '            </div></td>
     
cTexto += '      </tr>
cTexto += '</table>
cTexto += '  <p>&nbsp;</p>
cTexto += '  <table width="294" border="1" align="justify" bordercolor="#B2CBE7" class="table table-striped table-bordered table-hover table table-sm">
cTexto += '  </table>
cTexto += '</form>
cTexto += '</fieldset>
cTexto += '</body>
cTexto += '</html>
					
If cFiles <> ''

    ciTexto:= "Pedido de Compras No."+SC7->C7_NUM+" " + CRLF + CRLF
	ciTexto+= POSICIONE("SA2",1,XFILIAL("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME") + CRLF + CRLF
	ciTexto+= "E-mail: " + POSICIONE("SA2",1,XFILIAL("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_EMAIL") + CRLF
	
	lAviso := AVISO("Pedido de Compras No."+SC7->C7_NUM,ciTexto, { "Confirmar Envio","Fechar","Adicionar e-mails" }, 3)
    
    If lAviso == 3
      If ParamBox(aPerg ,"Parametros",aRetParam)
         If !Empty(aRetParam[1])
          cPara += ";" + Alltrim(aRetParam[1])
         
          If MsgYesNo("Confirma Envio?")
           U_DrillEmail(GetMv("EL_RLMAIL"),cPara,"","","Pedido de Compras No."+SC7->C7_NUM,cTexto,.f.,cFiles)
          Else
           MsgInfo("Processo de envio cancelado!!")
          EndIf          
         EndIf
      EndIf
    EndIf
    
	If lAviso == 1
  	 U_DrillEmail(GetMv("EL_RLMAIL"),cPara,"","","Pedido de Compras No."+SC7->C7_NUM,cTexto,.f.,cFiles)
    EndIf
EndIf
					
Return

User Function XPRZCOT()

Local nPrazo := POSICIONE("SC8",3,SC7->C7_FILIAL+PADR(Alltrim(SC7->C7_NUMCOT),6)+PADR(Alltrim(SC7->C7_PRODUTO),15)+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_NUM+SC7->C7_ITEM,"C8_PRAZO")

Return nPrazo
