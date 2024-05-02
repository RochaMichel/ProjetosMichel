#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#include "topconn.ch"
#INCLUDE "FILEIO.CH"
#Include "Totvs.ch"

User Function SendWork(cCotacoes)
	Local cConsulta := ""
	Local aDados    := {}
	Local cFilInfo :=""
	Local cCotacao :=""
	Local cFornece :=""
	Local cLoja    :=""
	Default cCotacoes := "'000116'"

	cConsulta := "SELECT * FROM " + RetSqlName("SC8") + " WHERE C8_NUM IN ("+cCotacoes+") AND D_E_L_E_T_ = '' ORDER BY C8_FILIAL,C8_NUM,C8_FORNECE,C8_LOJA,C8_ITEM"

	MpSysOpenQuery(cConsulta, "TC8")
	if TC8->(Eof())
		return Conout("N�o foram encontrado dados da cotacao")
	Endif
	While TC8->(!Eof())
		cFilInfo := TC8->C8_FILIAL
		cCotacao := TC8->C8_NUM
		cFornece := TC8->C8_FORNECE
		cLoja    := TC8->C8_LOJA
		aDados   := {}
		While TC8->(!Eof()) .And. cFilInfo == TC8->C8_FILIAL .and. cCotacao == TC8->C8_NUM .and. cFornece == TC8->C8_FORNECE .AND. cLoja == TC8->C8_LOJA
			AADD(aDados,{TC8->C8_NUM,TC8->C8_PRODUTO ,TC8->C8_FORNECE, TC8->C8_QUANT, TC8->C8_UM, TC8->C8_ITEM})
			TC8->(DbSkip())
		End
		U_Workflow(aDados)
	End
	TC8->(DbCloseArea())

Return


//cNum,cProd,cFornece,nQuant,cUM,cItem
//{{"000003","000094","101021",10,"UN","0001"},{"000003","000094","101021",10,"UN","0002"}}
User Function Workflow(aDados)
	Local oWf
	Local cPasta	:= "WORKFLOW"
	Local cPula     := ""
	Local cArqLink	:= "cotacaolink.html"
	Local cArq		:= "cotacao.html"
	Local cMailTo   := Alltrim(posicione("SA2",1,xFilial('SA2')+Alltrim(aDados[1][3]),"A2_EMAIL"))
	Local cCopia 	:= "rivaldo.junior@coderp.inf.br"
	Local aArea		:= GetArea()
	Local cProcesso	:= "PROD"
	Local aInfos 	:= {}
	Local cBody 	:= ""
	Local cLink 	:= ""
	Local nX		:= 0

	oWf := TWFProcess():New(cProcesso,"PRAZO")

	oWf:NewTask("Criacao HTML","\workflow\HTML\" + cArq)
	oHtml := oWf:oHTML
	aInfos := FWLoadSM0()
	oWf:oHtml:ValByName( "FilAnt"     ,Alltrim(aInfos[1][17]) +" - " + Alltrim(aInfos[1][7]) +" "+ Alltrim(aInfos[1][2]))
	oWf:oHtml:ValByName( "Endereco"     ,"-"+Alltrim(SM0->M0_ENDENT))
	//oWf:oHtml:ValByName( "Table" 	  ,MactroTr(aDados) /* MactroTr(aDados) */)

	For nX := 1 to Len (aDados)
		aadd(oWf:oHtml:ValByName("produto.item")  , aDados[nX][06])//item
		aadd(oWf:oHtml:ValByName("produto.codigo"), aDados[nX][02])//produto
		aadd(oWf:oHtml:ValByName("produto.quant"), aDados[nX][04])//quantidade
		aadd(oWf:oHtml:ValByName("produto.um")	 , aDados[nX][05])//Unidade de Medida
		aadd(oWf:oHtml:ValByName("produto.desc") ,Alltrim(posicione("SB1",1,xFilial('SB1')+aDados[nX][02],"B1_DESC")))//Descricao
		aadd(oWf:oHtml:ValByName("produto.vlrunit") , "")
		aadd(oWf:oHtml:ValByName("produto.ipi") , "")
		aadd(oWf:oHtml:ValByName("produto.icms") , "")
		aadd(oWf:oHtml:ValByName("produto.ncm") , Alltrim(posicione("SB1",1,xFilial('SB1')+aDados[nX][02],"B1_POSIPI")))
	Next
	oWf:oHtml:ValByName( "C8_NUM"     ,aDados[1][1])
	oWf:oHtml:ValByName( "C8_PRAZO"   ,dDatabase)
	//oWf:oHtml:ValByName( "TotalItens" ,cValtoChar(Len(aDados)))
	oWf:oHtml:ValByName( "A2_COD" 	  ,Alltrim(aDados[1][3])) //cfornece
	oWf:oHtml:ValByName( "A2_NOME" 	  ,Alltrim(posicione("SA2",1,xFilial('SA2')+Alltrim(aDados[1][3]),"A2_NOME")))
	oWf:oHtml:ValByName( "A2_END" 	  ,Alltrim(posicione("SA2",1,xFilial('SA2')+Alltrim(aDados[1][3]),"A2_END")))
	oWf:oHtml:ValByName( "A2_BAIRRO"  ,Alltrim(posicione("SA2",1,xFilial('SA2')+Alltrim(aDados[1][3]),"A2_BAIRRO")))
	oWf:oHtml:ValByName( "A2_MUN" 	  ,Alltrim(posicione("SA2",1,xFilial('SA2')+Alltrim(aDados[1][3]),"A2_MUN")))
	oWf:oHtml:ValByName( "A2_TEL" 	  ,Alltrim(posicione("SA2",1,xFilial('SA2')+Alltrim(aDados[1][3]),"A2_TEL")))

	oWF:cTo			:= cPasta
	oWF:cSubject	:= EncodeUtf8("Solicita��o de Preenchimento do Formul�rio de Cota��o de Pre�os - " + Alltrim(posicione("SB1",1,xFilial('SB1')+aDados[1,2],"B1_DESC"))) //perguntar sobre os aDados na posicao 1
	oWF:bReturn	    := "U_WFRETCOT()"

	cPula:= oWF:Start()

	//Primeiro processo, o que vai fazer o link clicavel no email
	oWf:NewTask("Envio E-mail","\workflow\HTML\" + cArqLink)
	oWF:cTo 	 := cMailTo
	oWf:cCC 	 := cCopia

	cBody := " Prezado(a) Fornecedor(a),
	cBody += " Espero que esteja tudo bem.
	cBody += " Somos da LAJES PATAGONIA IND E COM LTDA uma empresa dedicada a fornecer produtos/servi�os de alta qualidade aos nossos clientes. Estamos buscando melhorar nossa rede de fornecedores e aprimorar nossas opera��es comerciais.
	cBody += " Gostar�amos de convid�-lo(a) a participar do nosso processo de cota��o de pre�os. Por favor, preencha o formul�rio de cota��o de pre�os acessando o link abaixo:"

	oWf:cBody 	 := cBody

	oWF:cSubject := EncodeUtf8("Solicita��o de Preenchimento do Formul�rio de Cota��o de Pre�os - " + Alltrim(posicione("SB1",1,xFilial('SB1')+aDados[1,2],"B1_DESC")))

	cLink := "http://192.168.10.122:8091/messenger/emp"+Alltrim(cEmpAnt)+"/workflow/"+cPula+".htm"

	oWF:ohtml:ValByName("proc_link",cLink)
	oWF:ohtml:ValByName("Body"	   ,oWf:cBody)

	oWF:Start()

	oWf:Free()
	oWf := nil

	u_Mensagem("Rivaldo", "5581992375383", cLink)
	restArea(aArea)

Return .T.

User Function WFRETCOT(oProcess)
	Local aCabec := {}
	Local aItens := {}
	Local nX
	Local nY 
	Local cNum 		 := Alltrim(oProcess:oHTML:RetByName("C8_NUM"))
	Local cForn		 := Alltrim(oProcess:oHTML:RetByName("A2_COD"))
	PRIVATE lMsErroAuto := .F.
	Private lMsHelpAuto	   := .T.
	Private lAutoErrNoFile := .T.


	dbSelectArea("SC8")
	SC8->(dbSetOrder(1))
	If SC8->(dbSeek(xFilial("SC8")+ Padr(cNum,TAMSX3("C8_NUM")[1])+Padr(cForn,TAMSX3("C8_FORNECE")[1])))

		aadd(aCabec,{"C8_FORNECE" 	,SC8->C8_FORNECE})
		aadd(aCabec,{"C8_LOJA" 	  	,SC8->C8_LOJA})
		aadd(aCabec,{"C8_COND"    	,"000"}) //CondPg
		aadd(aCabec,{"C8_CONTATO" 	,""})
		aadd(aCabec,{"C8_FILENT"  	,SC8->C8_FILENT})
		aadd(aCabec,{"C8_MOEDA"   	,SC8->C8_MOEDA})
		aadd(aCabec,{"C8_EMISSAO" 	,SC8->C8_EMISSAO})
		aadd(aCabec,{"C8_TOTFRE" 	,0})
		aadd(aCabec,{"C8_VALDESC" 	,0})
		aadd(aCabec,{"C8_DESPESA" 	,0})
		aadd(aCabec,{"C8_SEGURO" 	,0})
		aadd(aCabec,{"C8_DESC1" 	,0})
		aadd(aCabec,{"C8_DESC2" 	,0})
		aadd(aCabec,{"C8_DESC3" 	,0})

		SC8->(dbSetOrder(3))
		For nX := 1 to len(oProcess:oHTML:RetByName("produto.item"))

			If SC8->(dbSeek(xFilial("SC8")+ Padr(cNum,TAMSX3("C8_NUM")[1])+Padr(oProcess:oHTML:RetByName("produto.codigo")[nX],TAMSX3("C8_PRODUTO")[1])+Padr(cForn,TAMSX3("C8_FORNECE")[1])))

				aadd(aItens,{{"C8_NUMPRO",SC8->C8_NUMPRO ,Nil},;
					{"C8_PRODUTO"  ,SC8->C8_PRODUTO,Nil},;
					{"C8_ITEM" 	   ,SC8->C8_ITEM,Nil},;
					{"C8_UM" 	   ,SC8->C8_UM,Nil},;
					{"C8_QUANT"    ,SC8->C8_QUANT,Nil},;
					{"C8_VALIPI"   ,Val(Strtran(oProcess:oHTML:RetByName("produto.ipi")[nX],"%","")),Nil},;
					{"C8_VALICM"   ,Val(Strtran(oProcess:oHTML:RetByName("produto.icms")[nX],"%","")),Nil},;
					{"C8_OBS"      ,"",Nil},;
					{"C8_PRECO"    ,Val(Strtran(oProcess:oHTML:RetByName("produto.vlrunit")[nX],"R$","")),NIL}})
					//{"C8_PRAZO"    ,aArray[8],Nil},;
			EndIf
		Next

		MSExecAuto({|v,x,y| MATA150(v,x,y)},aCabec,aItens,3)

		If lMsErroAuto
			//Alert("Erro na atualiza��o de cota��o!","Aten��o")
			//MostraErro()
			aiErro := GetAutoGRLog()
			For nY :=1 To Len(aiErro)
				ciErro += aiErro[nY] + Chr(13)+Chr(10)
			Next nY
			//Alert(ciErro)
		Else
			Conout("Cota��o atualizada com sucesso!","Aten��o")
			lSucesso := .T.
		EndIf

	Endif

	SC8->(DbCloseArea())

Return lSucesso

//Fun��o para Execauto de Atualiza��o de Cota��o
/* User Function Exec150(cProd,cNum,cForn,cConPg,nPreco,nIpi,nICMS,nPrazo,nFrete,cObs)

	Local lSucesso := .F.
	Local aCabec := {}
	Local aItens := {}
	Local ciErro := ''
	Local aiErro:=  {}
	Local nS
	PRIVATE lMsErroAuto := .F.
	Private lMsHelpAuto	   := .T.
	Private lAutoErrNoFile := .T.

	aCabec:={}
	aItens:={}

	dbSelectArea("SC8")
	dbSetOrder(3)
	If dbSeek(xFilial("SC8")+ Padr(cNum,TAMSX3("C8_NUM")[1])+ Padr(cProd,TAMSX3("C8_PRODUTO")[1]) +Padr(cForn,TAMSX3("C8_FORNECE")[1]))

		aadd(aCabec,{"C8_FORNECE" ,SC8->C8_FORNECE})
		aadd(aCabec,{"C8_LOJA" 	  ,SC8->C8_LOJA})
		aadd(aCabec,{"C8_COND"    ,cConPg})
		aadd(aCabec,{"C8_CONTATO" ,""})
		aadd(aCabec,{"C8_FILENT"  ,SC8->C8_FILENT})
		aadd(aCabec,{"C8_MOEDA"   ,SC8->C8_MOEDA})
		aadd(aCabec,{"C8_EMISSAO" ,SC8->C8_EMISSAO})
		aadd(aCabec,{"C8_TOTFRE" ,0})
		aadd(aCabec,{"C8_VALDESC" ,0})
		aadd(aCabec,{"C8_DESPESA" ,0})
		aadd(aCabec,{"C8_SEGURO" ,0})
		aadd(aCabec,{"C8_DESC1" ,0})
		aadd(aCabec,{"C8_DESC2" ,0})
		aadd(aCabec,{"C8_DESC3" ,0})

		aadd(aItens,{{"C8_NUMPRO" 	  ,SC8->C8_NUMPRO ,Nil},;
			{"C8_PRODUTO"  ,SC8->C8_PRODUTO ,Nil},;
			{"C8_ITEM" 	   ,SC8->C8_ITEM,Nil},;
			{"C8_UM" 	   ,SC8->C8_UM,Nil},;
			{"C8_QUANT"    ,SC8->C8_QUANT,Nil},;
			{"C8_VALIPI"   ,nIpi,Nil},;
			{"C8_VALICM"   ,nICMS,Nil},;
			{"C8_PRAZO"    ,nPrazo,Nil},;
			{"C8_OBS"      ,cObs,Nil},;
			{"C8_PRECO"    ,nPreco,NIL}})
		//{"C8_TOTAL" , ,NIL}})
		//{"C8_VALFRE"   ,nFrete,Nil},;

		MSExecAuto({|v,x,y| MATA150(v,x,y)},aCabec,aItens,3)

		If lMsErroAuto
			//Alert("Erro na atualiza��o de cota��o!","Aten��o")
			//MostraErro()
			aiErro := GetAutoGRLog()
			For nS:=1 To Len(aiErro)
				ciErro += aiErro[nS] + Chr(13)+Chr(10)
			Next nS
			//Alert(ciErro)
		Else
			MsgInfo("Cota��o atualizada com sucesso!","Aten��o")
			lSucesso := .T.
		EndIf
	Else
		Alert("N�o foi possivel atualizar a cota��o desejada","Aten��o")

	Endif

Return lSucesso */
/* Static Function MactroTr(aInfos)

	Local cBody := ""
	Local nx := 1
		
		oWf:oHtml:ValByName( "C8_ITEM2"     ,aDados[2,6])
		oWf:oHtml:ValByName( "B1_COD2"      ,aDados[2,2])
		oWf:oHtml:ValByName( "B1_DESC2"     ,Alltrim(posicione("SB1",1,xFilial('SB1')+aDados[2,2],"B1_DESC")))
		oWf:oHtml:ValByName( "C8_QUANT2"   	,aDados[2,4])
		oWf:oHtml:ValByName( "C8_UM2"       ,aDados[2,5])
		
	For nX := 1 to len(aInfos)
		cNX := cValtochar(nx)
		cBody += ' <tr>
		cBody += ' <td align="center" width="48">
		cBody += ' <font size="1" face="Arial">'+aInfos[nX,6]+'</font>
		cBody += ' </td>
		cBody += ' <td width="66" align="Center">
		cBody += '     <font size="1" face="Arial">'+aInfos[nX,2]+' </font>
		cBody += ' </td>
		cBody += ' <td align="center" width="60">
		cBody += '     <font size="1" face="Arial">'+cValToChar(aInfos[nX,4])+'</font>
		cBody += ' </td>
		cBody += ' <td align="center" width="60">
		cBody += '     <font size="1" face="Arial">'+aInfos[nX,5]+'</font>
		cBody += ' </td>
		cBody += ' <td align="center" width="60">
		cBody += '     <font size="1" face="Arial">'+Alltrim(posicione("SB1",1,xFilial('SB1')+aInfos[nX,2],"B1_DESC"))+'</font>
		cBody += ' </td>
		cBody += ' <td align="center" width="90">
		cBody += ' <input type="text" size="8" maxlength="12" name="%Valor%" value="" onkeyup="formatCurrency(this);">
		cBody += ' </td>
		cBody += ' <td align="center" width="90">
		cBody += ' <input type="text" size="5" maxlength="12"  step="0.01"  name="%IPI%" value="" onkeyup="formatCurrencyPC(this);">
		cBody += ' </td>
		cBody += ' <td align="center" width="90">
		cBody += ' <input type="text" size="5" maxlength="12" step="0.01" name="%ICMS%" value="" onkeyup="formatCurrencyPC(this);" >
		cBody += ' </td>
		cBody += ' <td align="center" width="90">
		cBody += ' <input type="text" size="5" maxlength="12" name="%VlTotal%" value="" onkeyup="formatCurrency(this);" >
		cBody += ' </td>
		cBody += ' <td align="center" width="88">
		cBody += ' <input type="text" size="4" maxlength="5" name="%NCM%" value="">
		cBody += ' </td>
		cBody += ' <td align="center" width="88">
		cBody += ' <input type="text" size="4" maxlength="5" name="%CondPg%" value="">
		cBody += ' </td>
		cBody += ' <td align="center" width="88">
		cBody += ' <input type="text" size="4" maxlength="16" name="%FormPg%" value="">
		cBody += ' </td>
		cBody += ' <td align="center" width="88">
		cBody += ' <input type="text" size="4" maxlength="5" name="%Prazo%" value="">
		cBody += ' </td>
		cBody += ' <td align="center" width="88">
		cBody += ' <input type="text" size="4" maxlength="5" name="%Frete%" value="" onkeyup="formatCurrency(this);">
		cBody += ' </td>
		cBody += ' <td align="center" width="88">
		cBody += ' <input type="text" size="4" name="%Obs%" value="">
		cBody += ' </td>
		cBody += ' </tr>

	Next nX

return cBody */

/* 
<body>
    <table id="ItensCot">
        <tbody>
            <!-- As Cotacoes ser�o adicionadas aqui via JavaScript -->
        </tbody>
    </table>

	<div hiden id=monstrodopedro>
		input %codigo%
	</div>

   <script>
        // Fun��o para adicionar itens � tabela

		
        function adicionarItens(array) {
            // Lista de itens de cota��o
            	var ItensCot = %Table%"; //array.map(function(item, index)
                var dados = ItensCot.split(';');
				var Item = []
                Item: dados[0],
                ProdCod: dados[1],
                Quant: dados[2],
                UM: dados[3],
                Descri: dados[4]
            
            });

			

            // Refer�ncia � tabela
            var tabela = document.getElementById('ItensCot').getElementsByTagName('tbody')[0];

            // Iterar sobre a lista de itens de cota��o e preencher a tabela
            ItensCot.forEach(function(item) {
                var row = tabela.insertRow();
                row.insertCell(0).innerHTML = item.Item;
                row.insertCell(1).innerHTML = item.ProdCod;
                row.insertCell(2).innerHTML = item.Quant;
                row.insertCell(3).innerHTML = item.UM;
                row.insertCell(4).innerHTML = item.Descri;
            });
        }

    </script>
</body>
</html> */
 
