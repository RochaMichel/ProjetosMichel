#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FONT.CH"
#include "topconn.ch"
#INCLUDE "FILEIO.CH"
#Include "Totvs.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DWFCONT  บAutor  ณ Walter Rodrigo     บ Data ณ  09/03/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Workflow para preenchimento do campo conta contabil do     บฑฑ
ฑฑบ          ณ produto                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa็ใo de produtos                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DWFCONT0(cProduto)
	Local oWf 
	Local cPasta	:= "WORKFLOW"
	Local cPula     := ""
	Local cArq		:= "contaproduto0.htm"
	Local cArqLink	:= "contaprodutolink.htm"
	Local cMailTo   := "contato.michelrocha@gmail.com"
	Local aArea		:= GetArea()
	Local cProcesso	:= "WFSB1C"
	Private cSetor  := "" 

	oWf := TWFProcess():New(cProcesso,"PRAZO")

	oWf:NewTask("Criacao HTML","\workflow\" + cArq)

	oWf:oHtml:ValByName( "B1_COD" 	  ,EncodeUtf8(cProduto))
	oWf:oHtml:ValByName( "B1_DESC" 	  ,EncodeUtf8(posicione("SB1",1,xFilial('SB1')+cProduto,"B1_DESC") ))
	oWf:oHtml:ValByName( "B1_XDESCOM" ,Posicione("SB1",1,XFILIAL("SB1")+cProduto,"B1_XDESCOM"))
	oWf:oHtml:ValByName( "B1_POSIPI"  ,Posicione("SB1",1,XFILIAL("SB1")+cProduto,"B1_POSIPI"))
	oWf:oHtml:ValByName( "B1_CEST"    ,EncodeUtf8(alltrim( SB1->B1_CEST  )))
	

	oWF:cTo			:= cPasta
	oWF:cSubject	:= "WorkFLow Cod. Especificador ST  " + cProduto 
	oWF:bReturn	    := "U_DWFRCON0"
	cPula 			:= oWF:Start()

	cMailTo := U_RetEmail(xFilial("ZW2") + "000001" + "000007")

	oWf:NewTask("Envio E-mail","\workflow\" + cArqLink)
	oWF:cTo 	 := cMailTo
	oWF:cSubject := "WorkFLow Cod. Especificador ST  " + cProduto

	oWf:oHtml:ValByName( "B1_COD" 	  ,EncodeUtf8(cProduto))
	oWf:oHtml:ValByName( "B1_DESC" 	  ,EncodeUtf8(posicione("SB1",1,xFilial('SB1')+cProduto,"B1_DESC") ))
	oWf:oHtml:ValByName( "wfnome" ,"WorkFLow Cod. Especificador ST")

	//oWF:ohtml:ValByName("proc_prod",cProduto + " - " + Posicione("SB1",1,XFILIAL("SB1")+cProduto,"B1_DESC") )
	oWF:ohtml:ValByName("proc_link","http://10.0.0.243:8199/wf/messenger/emp"+Alltrim(cEmpAnt)+"/WORKFLOW/"+cPula+".htm")

	oWF:Start()

	oWf:Free() 
	oWf := nil

	restArea(aArea)

Return .T.

User Function DWFCONT(cProduto)

	Local oWf
	Local cPasta	:= "WORKFLOW"
	Local cPula     := ""
	Local cArq		:= "contaproduto.htm"
	Local cArqLink	:= "contaprodutolink.htm"
	Local cMailTo   := "contato.michelrocha@gmail.com"//U_RetEmail(xFilial("ZW2") + "000001" + "000007")
	Local aArea		:= GetArea()
	Local cProcesso	:= "WFSB1C"
	Private cSetor := ""

	oWf := TWFProcess():New(cProcesso,"PRAZO")

	oWf:NewTask("Criacao HTML","\workflow\" + cArq)

	oWF:oHtml:ValByName("B1_COD"   ,cProduto)
	oWF:oHtml:ValByName("B1_DESC"  ,Posicione("SB1",1,XFILIAL("SB1")+cProduto,"B1_DESC"))
	oWF:oHtml:ValByName("B1_XDESCOM",Posicione("SB1",1,XFILIAL("SB1")+cProduto,"B1_XDESCOM"))

	oWF:cTo			:= cPasta
	oWF:cSubject	:= "Conta contabil do produto " + cProduto
	oWF:bReturn	    := "U_DWFRCONT"
	cPula 			:= oWF:Start()

	cMailTo := U_RetEmail(xFilial("ZW2") + "000001" + "000001")

	oWf:NewTask("Envio E-mail","\workflow\" + cArqLink)
	oWF:cTo 	 := cMailTo
	oWF:cSubject := "Conta contabil do produto"

	oWF:oHtml:ValByName("B1_COD",cProduto)
	oWF:oHtml:ValByName("B1_DESC",Posicione("SB1",1,XFILIAL("SB1")+cProduto,"B1_DESC"))
	oWF:oHtml:ValByName( "wfnome" ,"Contabilidade")

	//oWF:ohtml:ValByName("proc_prod",cProduto + " - " + Posicione("SB1",1,XFILIAL("SB1")+cProduto,"B1_DESC") )
	oWF:ohtml:ValByName("proc_link","http://10.0.0.243:8199/wf/messenger/emp"+Alltrim(cEmpAnt)+"/WORKFLOW/"+cPula+".htm")
	//oWF:ohtml:ValByName("proc_link","http://"+Alltrim(GetMV("EL_PAR013"))+"/wf/messenger/emp"+Alltrim(cEmpAnt)+"/WORKFLOW/"+cPula+".htm")

	oWF:Start()

	oWf:Free()
	oWf := nil

	restArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DWFCONT1  บAutor  ณ Walter Rodrigo     บ Data ณ  09/03/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Workflow para preenchimento do campo conta contabil do     บฑฑ
ฑฑบ          ณ produto                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa็ใo de produtos                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DWFCONT1(cProduto)
	Local oWf
	Local cPasta	:= "WORKFLOW"
	Local cPula     := ""
	Local cArq		:= "contaproduto1.html"
	Local cArqLink	:= "contaprodutolink.htm"
	Local cMailTo   := "contato.michelrocha@gmail.com"
	Local aArea		:= GetArea()
	Local cProcesso	:= "WFSB1C"
	Private cSetor := ""

	oWf := TWFProcess():New(cProcesso,"PRAZO")

	oWf:NewTask("Criacao HTML","\workflow\" + cArq)

	oHtml := oWf:oHTML

    oHtml:ValByName( "B1_COD" 	  ,EncodeUtf8(cProduto))
	oHtml:ValByName( "B1_DESC" 	  ,EncodeUtf8(posicione("SB1",1,xFilial('SB1')+cProduto,"B1_DESC") ))
	oHtml:ValByName( "B1_XAPLICA" ,EncodeUtf8(alltrim( SB1->B1_XAPLICA)))
	oHtml:ValByName( "B1_XDFAMIL" ,EncodeUtf8(alltrim( SB1->B1_XDFAMIL)))
	oHtml:ValByName( "B1_XDSUBGR" ,EncodeUtf8(alltrim( SB1->B1_XDSUBGR)))
	oHtml:ValByName( "B1_XDIMEN"  ,EncodeUtf8(alltrim( SB1->B1_XDIMEN )))
	oHtml:ValByName( "B1_FABRIC"  ,EncodeUtf8(alltrim( SB1->B1_FABRIC )))
	oHtml:ValByName( "B1_XMARCA"  ,EncodeUtf8(alltrim( SB1->B1_XMARCA )))
	oHtml:ValByName( "B1_XFILFAB" ,EncodeUtf8(alltrim( SB1->B1_XFILFAB)))
	oHtml:ValByName( "B1_XDGRUPO" ,EncodeUtf8(alltrim( SB1->B1_XDGRUPO)))
	oHtml:ValByName( "B1_XAGRUP"  ,EncodeUtf8(alltrim( SB1->B1_XAGRUP)))
	oHtml:ValByName( "B5_XACABAM" ,EncodeUtf8(alltrim( SB5->B5_XACABAM)))
	oHtml:ValByName( "B5_XCORPRE" ,EncodeUtf8(alltrim( SB5->B5_XCORPRE)))
	oHtml:ValByName( "B5_XCOF"    ,EncodeUtf8(alltrim( SB5->B5_XCOF	  )))
	oHtml:ValByName( "B5_XACALAT" ,EncodeUtf8(alltrim( SB5->B5_XACALAT )))
	oHtml:ValByName( "B5_XCLSUSO" ,EncodeUtf8(alltrim( SB5->B5_XCLSUSO)))
	oHtml:ValByName( "B5_XVRTON"  ,EncodeUtf8(alltrim( SB5->B5_XVRTON )))
	oHtml:ValByName( "B5_XFACES"  ,EncodeUtf8(alltrim( SB5->B5_XFACES )))
	oHtml:ValByName( "B5_XSUPEFI" ,EncodeUtf8(alltrim( SB5->B5_XSUPEFI)))


	oWF:cTo			:= cPasta
	oWF:cSubject	:= "WorkFLow Marketing " + cProduto
	oWF:bReturn	    := "U_DWFRCON1"
	cPula 			:= oWF:Start()

	cMailTo := U_RetEmail(xFilial("ZW2") + "000001" + "000004")

	oWf:NewTask("Envio E-mail","\workflow\" + cArqLink)
	oWF:cTo 	 := cMailTo
	oWF:cSubject := "WorkFLow Marketing " + cProduto

	oHtml:ValByName( "B1_COD" 	  ,EncodeUtf8(cProduto))
	oHtml:ValByName( "B1_DESC" 	  ,EncodeUtf8(posicione("SB1",1,xFilial('SB1')+cProduto,"B1_DESC") ))
	oHtml:ValByName( "wfnome" ,"WorkFLow Marketing")

	//oWF:ohtml:ValByName("proc_prod",cProduto + " - " + Posicione("SB1",1,XFILIAL("SB1")+cProduto,"B1_DESC") )
	oWF:ohtml:ValByName("proc_link","http://10.0.0.243:8199/wf/messenger/emp"+Alltrim(cEmpAnt)+"/WORKFLOW/"+cPula+".htm")
	//oWF:ohtml:ValByName("proc_link","http://"+Alltrim(GetMV("EL_PAR013"))+"/wf/messenger/emp"+Alltrim(cEmpAnt)+"/WORKFLOW/"+cPula+".htm")

	oWF:Start()

	oWf:Free()
	oWf := nil

	restArea(aArea)

Return .T.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DWFCONT2  บAutor  ณ Walter Rodrigo     บ Data ณ  09/03/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Workflow para preenchimento do campo conta contabil do     บฑฑ
ฑฑบ          ณ produto                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa็ใo de produtos                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DWFCONT2(cProduto)
	Local oWf
	Local cPasta	:= "WORKFLOW"
	Local cPula     := ""
	Local cArq		:= "contaproduto2.html"
	Local cArqLink	:= "contaprodutolink.htm"
	Local cMailTo   := "ewerton.martins@grupoelizabeth.com.br;cyntia.cavalcanti@grupoelizabeth.com.br;carine.carbonera@grupoelizabeth.com.br;rayanne.costa@grupoelizabeth.com.br;flavio.filho@grupoelizabeth.com.br"//"cyntia.cavalcanti@grupoelizabeth.com.br;carine.carbonera@grupoelizabeth.com.br;rayanne.costa@grupoelizabeth.com.br"
	Local aArea		:= GetArea()
	Local cProcesso	:= "WFSB1C"
	Private cSetor := ""

	oWf := TWFProcess():New(cProcesso,"PRAZO")

	oWf:NewTask("Criacao HTML","\workflow\" + cArq)

	oHtml := oWf:oHTML

	oHtml:ValByName( "B1_COD" 	  ,EncodeUtf8(cProduto))
	oHtml:ValByName( "B1_DESC" 	  ,EncodeUtf8(posicione("SB1",1,xFilial('SB1')+cProduto,"B1_DESC") ))
	oHtml:ValByName( "B1_CONTA"   ,EncodeUtf8(alltrim( SB1->B1_CONTA  )))


	oWF:cTo			:= cPasta
	oWF:cSubject	:= "WorkFLow Contabilidade  " + cProduto
	oWF:bReturn	    := "U_DWFRCON2"
	cPula 			:= oWF:Start()

	cMailTo := U_RetEmail(xFilial("ZW2") + "000001" + "000001")

	oWf:NewTask("Envio E-mail","\workflow\" + cArqLink)
	oWF:cTo 	 := cMailTo
	oWF:cSubject := "WorkFLow Contabilidade  " + cProduto

	oHtml:ValByName( "B1_COD" 	  ,EncodeUtf8(cProduto))
	oHtml:ValByName( "B1_DESC" 	  ,EncodeUtf8(posicione("SB1",1,xFilial('SB1')+cProduto,"B1_DESC") ))
	oHtml:ValByName( "wfnome" ,"WorkFLow Contabilidade")

	//oWF:ohtml:ValByName("proc_prod",cProduto + " - " + Posicione("SB1",1,XFILIAL("SB1")+cProduto,"B1_DESC") )
	oWF:ohtml:ValByName("proc_link","http://10.0.0.243:8199/wf/messenger/emp"+Alltrim(cEmpAnt)+"/WORKFLOW/"+cPula+".htm")

	oWF:Start()

	oWf:Free()
	oWf := nil

	restArea(aArea)

Return .T.




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DWFCONT3 บAutor  ณ Walter Rodrigo     บ Data ณ  09/03/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Workflow para preenchimento do campo conta contabil do     บฑฑ
ฑฑบ          ณ produto                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa็ใo de produtos                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DWFCONT3(cProduto)
	Local oWf
	Local cPasta	:= "WORKFLOW"
	Local cPula     := ""
	Local cArq		:= "contaproduto3.html"
	Local cArqLink	:= "contaprodutolink.htm"
	Local cMailTo   := "ewerton.martins@grupoelizabeth.com.br;contato.michelrocha@gmail.com"//"cyntia.cavalcanti@grupoelizabeth.com.br;carine.carbonera@grupoelizabeth.com.br;rayanne.costa@grupoelizabeth.com.br"
	Local aArea		:= GetArea()
	Local aEmail	:= {";tais.carpintero@grupoelizabeth.com.br",";deivids.pontes@grupoelizabeth.com.br",";moacir.souza@grupoelizabeth.com.br",";barbara.rocha@grupoelizabeth.com.br"}
	Local cProcesso	:= "WFSB1C"
	Local cFil	:= ""
	Private cSetor := ""
	cFil := posicione("SB1",1,xFilial('SB1')+cProduto,"B1_XFILFAB")

	oWf := TWFProcess():New(cProcesso,"PRAZO")

	oWf:NewTask("Criacao HTML","\workflow\" + cArq)

	oHtml := oWf:oHTML

    oHtml:ValByName( "B1_COD" 	  ,EncodeUtf8(cProduto))
	oHtml:ValByName( "B1_DESC" 	  ,EncodeUtf8(posicione("SB1",1,xFilial('SB1')+cProduto,"B1_DESC") ))
	oHtml:ValByName( "B1_XCOMPRI" ,EncodeUtf8(alltrim( SB1->B1_XCOMPRI )))
	oHtml:ValByName( "B1_XPESBRU" ,EncodeUtf8(alltrim( SB1->B1_XPESBRU )))
	oHtml:ValByName( "B1_XLARGUR" ,EncodeUtf8(alltrim( SB1->B1_XLARGUR )))
	oHtml:ValByName( "B1_XPESLIQ" ,EncodeUtf8(alltrim( SB1->B1_XPESLIQ )))
	oHtml:ValByName( "B1_XALTURA" ,EncodeUtf8(alltrim( SB1->B1_XALTURA )))
	oHtml:ValByName( "B1_CONV"    ,EncodeUtf8(alltrim( SB1->B1_CONV    )))
	oHtml:ValByName( "B1_XPALETE" ,EncodeUtf8(alltrim( SB1->B1_XPALETE)))
	oHtml:ValByName( "B1_PESO"    ,EncodeUtf8(alltrim( SB1->B1_PESO   )))
	oHtml:ValByName( "B1_PESBRU"  ,EncodeUtf8(alltrim( SB1->B1_PESBRU  )))
	oHtml:ValByName( "B5_XACABAM" ,EncodeUtf8(alltrim( SB5->B5_XACABAMI)))
	oHtml:ValByName( "B5_XTELAGE" ,EncodeUtf8(alltrim( SB5->B5_XTELAGE )))
	oHtml:ValByName( "B5_XVRTON"  ,EncodeUtf8(alltrim( SB5->B5_XVRTON  )))
	oHtml:ValByName( "B5_XESPESS" ,EncodeUtf8(alltrim( SB5->B5_XESPESS )))
	oHtml:ValByName( "B5_XGRPABS" ,EncodeUtf8(alltrim( SB5->B5_XGRPABS )))
	oHtml:ValByName( "B5_XPCCAIX" ,EncodeUtf8(alltrim( SB5->B5_XPCCAIX )))
	oHtml:ValByName( "B5_GRAGUA"  ,EncodeUtf8(alltrim( SB5->B5_XGRAGUA )))
	oHtml:ValByName( "B5_XDIMFAB" ,EncodeUtf8(alltrim( SB5->B5_XDIMFAB )))
	oHtml:ValByName( "B5_XTIPOPR" ,EncodeUtf8(alltrim( SB5->B5_XTIPOPR )))

	oWF:cTo			:= cPasta
	oWF:cSubject	:= "WorkFLow SGQ" + cProduto
	oWF:bReturn	    := "U_DWFRCON3"
	cPula 			:= oWF:Start()

	cMailTo := U_RetEmail(xFilial("ZW2") + "000001" + "000007")
	Do Case
	Case AllTrim(cFil) == '020201'
		cMailTo += aEmail[1]
	Case AllTrim(cFIl) == '020203'
		cMailTo += aEmail[2]
	Case AllTrim(cFIl) == '020202'
		cMailTo += aEmail[3]
	Case AllTrim(cFIl) == '020103'
		cMailTo += aEmail[4]
	EndCase
	oWf:NewTask("Envio E-mail","\workflow\" + cArqLink)
	oWF:cTo 	 := cMailTo
	oWF:cSubject := "WorkFLow SGQ " + cProduto

	oHtml:ValByName( "B1_COD" 	  ,EncodeUtf8(cProduto))
	oHtml:ValByName( "B1_DESC" 	  ,EncodeUtf8(posicione("SB1",1,xFilial('SB1')+cProduto,"B1_DESC") ))
	oHtml:ValByName( "wfnome" ,"WorkFLow SGQ")

	//oWF:ohtml:ValByName("proc_prod",cProduto + " - " + Posicione("SB1",1,XFILIAL("SB1")+cProduto,"B1_DESC") )
	oWF:ohtml:ValByName("proc_link","http://10.0.0.243:8199/wf/messenger/emp"+Alltrim(cEmpAnt)+"/WORKFLOW/"+cPula+".htm")

	oWF:Start()
	
	oWf:Free()
	oWf := nil

	restArea(aArea)

Return .T.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DWFCONT4 บAutor  ณ Walter Rodrigo     บ Data ณ  09/03/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Workflow para preenchimento do campo conta contabil do     บฑฑ
ฑฑบ          ณ produto                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa็ใo de produtos                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DWFCONT4(cProduto)
	Local oWf
	Local cPasta	:= "WORKFLOW"
	Local cPula     := ""
	Local cArq		:= "contaproduto4.html"
	Local cArqLink	:= "contaprodutolink.htm"
	Local cMailTo   := "ewerton.martins@grupoelizabeth.com.br;contato.michelrocha@gmail.com"//"cyntia.cavalcanti@grupoelizabeth.com.br;carine.carbonera@grupoelizabeth.com.br;rayanne.costa@grupoelizabeth.com.br"
	Local aArea		:= GetArea()
	Local cProcesso	:= "WFSB1C"
	Private cSetor := ""

	oWf := TWFProcess():New(cProcesso,"PRAZO")

	oWf:NewTask("Criacao HTML","\workflow\" + cArq)

	oHtml := oWf:oHTML

	oHtml:ValByName( "B1_COD" 	  ,EncodeUtf8(cProduto))
	oHtml:ValByName( "B1_DESC" 	  ,EncodeUtf8(posicione("SB1",1,xFilial('SB1')+cProduto,"B1_DESC") ))
	oHtml:ValByName( "B1_IPI"     ,EncodeUtf8(alltrim( SB1->B1_IPI    )))
	oHtml:ValByName( "B1_CEST"    ,EncodeUtf8(alltrim( SB1->B1_CEST   )))
	oHtml:ValByName( "B1_GRTRIB"  ,EncodeUtf8(alltrim( SB1->B1_GRTRIB )))
	

	oWF:cTo			:= cPasta
	oWF:cSubject	:= "WorkFLow Fiscal " + cProduto
	oWF:bReturn	    := "U_DWFRCON4"
	cPula 			:= oWF:Start()

	cMailTo := U_RetEmail(xFilial("ZW2") + "000001" + "000006")

	oWf:NewTask("Envio E-mail","\workflow\" + cArqLink)
	oWF:cTo 	 := cMailTo
	oWF:cSubject := "WorkFLow Fiscal " + cProduto

	oHtml:ValByName( "B1_COD" 	  ,EncodeUtf8(cProduto))
	oHtml:ValByName( "B1_DESC" 	  ,EncodeUtf8(posicione("SB1",1,xFilial('SB1')+cProduto,"B1_DESC") ))
	oHtml:ValByName( "wfnome" ,"WorkFLow Fiscal")

	//oWF:ohtml:ValByName("proc_prod",cProduto + " - " + Posicione("SB1",1,XFILIAL("SB1")+cProduto,"B1_DESC") )
	oWF:ohtml:ValByName("proc_link","http://10.0.0.243:8199/wf/messenger/emp"+Alltrim(cEmpAnt)+"/WORKFLOW/"+cPula+".htm")

	oWF:Start()

	oWf:Free()
	oWf := nil

	restArea(aArea)

Return .T.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DWFCONT5  บAutor  ณ Walter Rodrigo     บ Data ณ  09/03/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Workflow para preenchimento do campo conta contabil do     บฑฑ
ฑฑบ          ณ produto                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa็ใo de produtos                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DWFCONT5(cProduto)
	Local oWf
	Local cPasta	:= "WORKFLOW"
	Local cPula     := ""
	Local cArq		:= "contaproduto5.html"
	Local cArqLink	:= "contaprodutolink.htm"
	Local cMailTo   := "ewerton.martins@grupoelizabeth.com.br;contato.michelrocha@gmail.com"//"cyntia.cavalcanti@grupoelizabeth.com.br;carine.carbonera@grupoelizabeth.com.br;rayanne.costa@grupoelizabeth.com.br"
	Local aArea		:= GetArea()
	Local cProcesso	:= "WFSB1C"
	Private cSetor := ""

	oWf := TWFProcess():New(cProcesso,"PRAZO")

	oWf:NewTask("Criacao HTML","\workflow\" + cArq)

	oHtml := oWf:oHTML

	oHtml:ValByName( "B1_COD" 	  ,EncodeUtf8(cProduto))
	oHtml:ValByName( "B1_DESC" 	  ,EncodeUtf8(posicione("SB1",1,xFilial('SB1')+cProduto,"B1_DESC") ))
	oHtml:ValByName( "B1_CODBAR"  ,EncodeUtf8(alltrim( SB1->B1_CODBAR  )))
	oHtml:ValByName( "B1_XCODBAR" ,EncodeUtf8(alltrim( SB1->B1_XCODBAR )))
	oHtml:ValByName( "B1_XDESC"   ,EncodeUtf8(alltrim( SB1->B1_XDESC   )))
	oHtml:ValByName( "B5_CEME"    ,EncodeUtf8(alltrim( SB5->B5_CEME   )))

	oWF:cTo			:= cPasta
	oWF:cSubject	:= "WorkFLow N๚cleo Cadastral " + cProduto
	oWF:bReturn	    := "U_DWFRCON5"
	cPula 			:= oWF:Start()

	cMailTo := U_RetEmail(xFilial("ZW2") + "000001" + "000007")

	oWf:NewTask("Envio E-mail","\workflow\" + cArqLink)
	oWF:cTo 	 := cMailTo
	oWF:cSubject := "WorkFLow N๚cleo Cadastral " + cProduto

	oHtml:ValByName( "B1_COD" 	  ,EncodeUtf8(cProduto))
	oHtml:ValByName( "B1_DESC" 	  ,EncodeUtf8(posicione("SB1",1,xFilial('SB1')+cProduto,"B1_DESC") ))
	oHtml:ValByName( "wfnome" ,"WorkFLow N๚cleo Cadastral")

	//oWF:ohtml:ValByName("proc_prod",cProduto + " - " + Posicione("SB1",1,XFILIAL("SB1")+cProduto,"B1_DESC") )
	oWF:ohtml:ValByName("proc_link","http://10.0.0.243:8199/wf/messenger/emp"+Alltrim(cEmpAnt)+"/WORKFLOW/"+cPula+".htm")

	oWF:Start()

	oWf:Free()
	oWf := nil

	restArea(aArea)


Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DWFCONT1  บAutor  ณ Walter Rodrigo     บ Data ณ  09/03/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Workflow para preenchimento do campo conta contabil do     บฑฑ
ฑฑบ          ณ produto                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa็ใo de produtos                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

user Function wfNoticaError(cTo , cErrorAuto, cMessage)
	Local aHtml     := {}
	Local cHtml     := ''
	Local nI        := 0

	aAdd(aHtml,"<html>")
	aAdd(aHtml,"<head>")
	aAdd(aHtml,"<meta charset='utf-8' />")
	aAdd(aHtml,"<title>Notifica็ใo WorkFlow al็ada de produtos - ERPLabs</title>")
	aAdd(aHtml,"</head>")
	aAdd(aHtml,"<body>")
	aAdd(aHtml,"<table>")
	aAdd(aHtml,"<tr>")
	aAdd(aHtml,"<td>")
	aAdd(aHtml,cErrorAuto)
	aAdd(aHtml,"</td>")
	aAdd(aHtml,"</tr>")
	aAdd(aHtml,"<tr>")
	aAdd(aHtml,"<td>")
	aAdd(aHtml,cMessage)
	aAdd(aHtml,"</td>")
	aAdd(aHtml,"</tr>")
	aAdd(aHtml,"</body>")
	aAdd(aHtml,"</html>")

	For nI := 1 to len(aHtml)
		cHtml += aHtml[nI]
	Next
	WFNotifyAdmin( cTo, , cHtml )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DWFCONT1  บAutor  ณ Walter Rodrigo     บ Data ณ  09/03/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Workflow para preenchimento do campo conta contabil do     บฑฑ
ฑฑบ          ณ produto                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa็ใo de produtos                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

user function NotFiFim(cProduto, cDescPro)

LOCAL cHtml
local cSubject := 'Confirma็ใo do Cadastro '
local cto := U_RetEmail(xFilial("ZW2") + "000001" + "000004")

//Notifica็ใo de e-mail caso o processo seja feito com sucesso
    cHtml := "<!DOCTYPE html>"
	cHtml += "<html>"
	cHtml += " "
	cHtml += "<head>"
	cHtml += "    <meta charset='utf-8' />"
	cHtml += "    <title>Cadastro</title>"
	cHtml += " "
	cHtml += "    <style>"
	cHtml += "        .invoice-box {"
	cHtml += "            max-width: 500px;"
	cHtml += "            margin: auto;"
	cHtml += "            padding: 30px;"
	cHtml += "            border: 1px solid #eee;"
	cHtml += "            box-shadow: 0 0 10px rgba(0, 0, 0, 0.15);"
	cHtml += "            font-size: 16px;"
	cHtml += "            line-height: 24px;"
	cHtml += "            font-family: 'Helvetica Neue', 'Helvetica', Helvetica, Arial, sans-serif;"
	cHtml += "            color: #555;"
	cHtml += "        }"
	cHtml += "      .invoice-box data td {position: static;}   "
	cHtml += "        .invoice-box table {"
	cHtml += "            width: 100%;"
	cHtml += "            line-height: inherit;"
	cHtml += "            text-align: left;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box table td {"
	cHtml += "            padding: 5px;"
	cHtml += "            vertical-align: top;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box table tr td:nth-child(2) {"
	cHtml += "            text-align: right;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box table tr.top table td {"
	cHtml += "            padding-bottom: 20px;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box table tr.top table td.title {"
	cHtml += "            font-size: 16px;"
	cHtml += "            line-height: 45px;"
	cHtml += "            color: #333;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box table tr.information table td {"
	cHtml += "            padding-bottom: 40px;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box table tr.heading td {"
	cHtml += "            background: #eee;"
	cHtml += "            border-bottom: 1px solid #ddd;"
	cHtml += "            font-weight: bold;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box table tr.details td {"
	cHtml += "            padding-bottom: 20px;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box table tr.item td {"
	cHtml += "            border-bottom: 1px solid #eee;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box table tr.item.last td {"
	cHtml += "            border-bottom: none;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box table tr.total td:nth-child(2) {"
	cHtml += "            border-top: 2px solid #eee;"
	cHtml += "            font-weight: bold;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .invoice-box a {"
	cHtml += "            background-color: #ffffff;"
	cHtml += "            border: solid 1px #eb0684;"
	cHtml += "            border-radius: 5px;"
	cHtml += "            box-sizing: border-box;"
	cHtml += "            color: #eb0684;"
	cHtml += "            cursor: pointer;"
	cHtml += "            display: inline-block;"
	cHtml += "            font-size: 14px;"
	cHtml += "            font-weight: bold;"
	cHtml += "            margin: 0;"
	cHtml += "            padding: 12px 25px;"
	cHtml += "            text-decoration: none;"
	cHtml += "            text-transform: capitalize;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        @media only screen and (max-width: 600px) {"
	cHtml += "            .invoice-box table tr.top table td {"
	cHtml += "                width: 100%;"
	cHtml += "                display: block;"
	cHtml += "                text-align: center;"
	cHtml += "            }"
	cHtml += "            .invoice-box table tr.information table td {"
	cHtml += "                width: 100%;"
	cHtml += "                display: block;"
	cHtml += "                text-align: center;"
	cHtml += "            }"
	cHtml += "        }"
	cHtml += "        /** RTL **/"
	cHtml += "         "
	cHtml += "        .rtl {"
	cHtml += "            direction: rtl;"
	cHtml += "            font-family: Tahoma, 'Helvetica Neue', 'Helvetica', Helvetica, Arial, sans-serif;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .rtl table {"
	cHtml += "            text-align: right;"
	cHtml += "        }"
	cHtml += "         "
	cHtml += "        .rtl table tr td:nth-child(2) {"
	cHtml += "            text-align: left;"
	cHtml += "        }"
	cHtml += "    </style>"
	cHtml += "</head>"
	cHtml += " "
	cHtml += "<body>"
	cHtml += "    <div class='invoice-box'>"
	cHtml += "        <table cellpadding='0' cellspacing='0'>"
	cHtml += "            <tr class='top'>"
	cHtml += "                <td colspan='4'>"
	cHtml += "                    <table>"
	cHtml += "                    <a href='href='https://imgbox.com/7xGvcLmO' target='_blank'><img src='https://images2.imgbox.com/5d/81/7xGvcLmO_o.png'  width='220' height='70' border='0' alt='image Elizabeth'/></a>"
	cHtml += "                        <tr>"
	cHtml += "                            <td class='title'></td>"
	cHtml += "                               <h4 style=' position: relative; bottom: 100px; left: 300px; '> Confirma็ใo de Cadastro <br/>data:"+DTOC(date())+"</h4>"
	cHtml += "                        </tr>"
	cHtml += "                    <h4 style=' position: relative; bottom: 70px'>Processo de inclusใo do produto concluida com "
    cHtml += "                        sucesso</h4></br> </br>"
    cHtml += "                    <h4 style=' position: relative; bottom: 130px'>Codigo: "+cProduto+"</h4>"
    cHtml += "                    </br>"
    cHtml += "                    <h4 style=' position: relative; bottom: 190px'>Descri็ใo: "+cDescPro+"</h4> "               
	cHtml += "                    </table>"
	cHtml += "                </td>"
	cHtml += "            </tr>"
	cHtml += "       " 
	cHtml += "        </table>"
	cHtml += "    </div>"
	cHtml += "</body>"
	cHtml += " "
	cHtml += "</html>"

	WFNotifyAdmin(cTo, cSubject, cHtml)

RETURN


