#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"

/*/{Protheus.doc} ZMFATR03
Relat�rio de Pedidos de Venda
@author Felipe(Newsiga) 
@since 15/06/2021
@version P12
@type function
/*/

User Function ZMFATR03(aTo,cAssunto,cMsg)
	Local cQuery      := ""
	Local oPrint      As object
	Local nX          := 0
	Private nRecCount := 0
	Private cAlias    := GetNextAlias()
	Default cAssunto  := "Seu pedido de compra N� "+SC5->C5_NUM+" foi recebido."
	Default cMsg := ""
	Default aTo := {}

	cQuery := "Select "
	cQuery += "Case When C5_TPFRETE = 'C' Then 'CIF' "
	cQuery += "     When C5_TPFRETE = 'F' Then 'FOB' "
	cQuery += "     Else 'SEM FRETE' End FRETE, * "
	cQuery += "from "+RetSqlName("SC5")+" C5 "
	cQuery += "Inner Join "+RetSqlName("SC6")+" C6 ON C6_FILIAL = C5_FILIAL And C6_NUM = C5_NUM And C6.D_E_L_E_T_ = '' "
	cQuery += "Where C6_FILIAL = '"+xFilial("SC6")+"' And C6_NUM = '"+SC5->C5_NUM+"' And C6.D_E_L_E_T_ ='' "
	cQuery:= ChangeQuery(cQuery)
	DBUseArea( .T.,"TOPCONN", TCGENQRY(,,cQuery),(cAlias), .F., .T.)

	Count to nRecCount
	(cAlias)->(DBGoTop())

	Impress(@oPrint, cAlias)// chamada para impress�o do pdf.
	oPrint:Print()

	For Nx := 1 to len(aTo)
		// Rotina antiga: GPEMail(cAssunto, cMsg, Alltrim(aTo[nX]), {"\SPOOl\ped"+AllTrim(SC5->C5_NUM)+".pdf"})//fun��o padr�o para envio de email
		U_tmail(Alltrim(aTo[nX]),cAssunto,cMsg,"\SPOOl\ped"+AllTrim(SC5->C5_NUM)+".pdf") //chamada de nova fun��o com tMailMessage e tMailManager
	Next
	FreeObj(oPrint)
	fErase("\spool\ped"+Alltrim(SC5->C5_NUM)+".pdf") //Apaga arquivo copiado para servidor
	fErase("\spool\ped"+Alltrim(SC5->C5_NUM)+".rel") //Apaga arquivo copiado para servidor
Return

/*/{Protheus.doc} Impress
Impress�o do relat�rio
@author Felipe(Newsiga)
@since 25/05/2020
@version P12
@type function
/*/
Static Function Impress(oPrint, cAlias)
	Local lAdjustToLegacy := .F.
	Local lDisableSetup   := .F. //N�o abre tela de setup da impress�o
	Local nCount          := 0
	Local nVlrTotal       := 0
	Local nAliqICM        := 0
	Local nAliqIPI        := 0
	Local nAliqST         := 0
    local nSilaba         := 0
    
	Local nValIpi         := 0
	Local nIcmsRet        := 0
	Local nItem           := 0
    Local i := 0
	Local nTotSt   := 0
	Local nTotIPI  := 0

	Private oFont0  := TFont():New( "Arial", , -7)
	Private oFont1  := TFont():New( "Arial", , -8)
	Private oFont3  := TFont():New( "Arial", , -10)
	Private oFont4  := TFont():New( "Arial", , -11)
	Private oFont1n := TFont():New( "Arial", , -8, ,.T.)
	Private oFont2  := TFont():New( "Arial", , -20, ,.T.)
	Private oFont3n := TFont():New( "Arial", , -11, ,.T.)
	Private oFont2n := TFont():New( "Arial", , -9, ,.T.)
	Private oFont3ns:= TFont():New( "Arial", , -11, ,.T.,,,,,.T.)
    PRIVATE cOrign
	Private nLin       := 022
	Private nLinBox    := 0
	Private nSpace5    := 5
	Private nSpace10   := 10
	Private nSpace15   := 15
	Private nSpace20   := 20
	Private nSpace30   := 30
	Private nSpace40   := 40
	Private nSpace50   := 50
	Private nSpace60   := 60
    Private aSylls  := {}
	Private oHGRAY := TBrush():New( , CLR_HGRAY)

	//Inicializacao da pagina do objeto grafico
	oPrint:= FWMSPrinter():New("ped"+Alltrim(SC5->C5_NUM), IMP_PDF, lAdjustToLegacy,, lDisableSetup)

	oPrint:StartPage()
	fCabec(oPrint, cAlias)
	oPrint:Box(nLin+5,0015, nLin+20, 580, "-4")
	oPrint:Line(nLin,0035 ,nLin+20, 0035)//fim item
	oPrint:Line(nLin,0067 ,nLin+20, 0067)//fim codigo
	oPrint:Line(nLin,0235 ,nLin+20, 0235)//fim descri
	oPrint:Line(nLin,0255 ,nLin+20, 0255)//fim da um
	oPrint:Line(nLin,0300 ,nLin+20, 0300)//fim ncm
	oPrint:Line(nLin,0345 ,nLin+20, 0345)//fim quant
	oPrint:Line(nLin,0395 ,nLin+20, 0395)//fim pre�o
	oPrint:Line(nLin,0430 ,nLin+20, 0430)//fim icms
	oPrint:Line(nLin,0465 ,nLin+20, 0465)//fim vlr st
	oPrint:Line(nLin,0500 ,nLin+20, 0500)//fim ipi
	oPrint:Line(nLin,0535 ,nLin+20, 0535)//fim frete
	oPrint:Line(nLin,0580 ,nLin+20, 0580)//fim total

	nLin += nSpace15
	nLinBox := nLin

	MaFisIni(SC5->C5_CLIENTE,;                     // 1-Codigo Cliente/Fornecedor
	SC5->C5_LOJACLI,;                     // 2-Loja do Cliente/Fornecedor
	"C",;                                      // 3-C:Cliente , F:Fornecedor
	"N",;                                      // 4-Tipo da NF
	Posicione("SA1",1,FWxFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI, "A1_TIPO"),;                     // 5-Tipo do Cliente/Fornecedor
	MaFisRelImp("MT100",{"SF2","SD2"}),;       // 6-Relacao de Impostos que suportados no arquivo
	,;                                         // 7-Tipo de complemento
	,;                                         // 8-Permite Incluir Impostos no Rodape .T./.F.
	"SB1",;                                    // 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
	"MATA461")
   
	While !oPrint:Cancel() .And. !(cAlias)->(Eof())
		nCount++
		nItem++
		If nCount <> nRecCount .And. nRecCount <> 1
			If  len(AllTrim(SC6->C6_DESCRI)+" - ZUMMI ") > 100
				oPrint:Box(nLinBox-10,0015, nLinBox+11, 580, "-4")
				oPrint:Line(nLin-25,0035 ,nLinBox+11, 0035)//fim item
				oPrint:Line(nLin-25,0067 ,nLinBox+11, 0067)//fim codigo
				oPrint:Line(nLin-25,0235 ,nLinBox+11, 0235)//fim descri
				oPrint:Line(nLin-25,0255 ,nLinBox+11, 0255)//fim da um
				oPrint:Line(nLin-25,0300 ,nLinBox+11, 0300)//fim ncm
				oPrint:Line(nLin-25,0345 ,nLinBox+11, 0345)//fim quant
				oPrint:Line(nLin-25,0395 ,nLinBox+11, 0395)//fim pre�o
				oPrint:Line(nLin-25,0430 ,nLinBox+11, 0430)//fim icms
				oPrint:Line(nLin-25,0465 ,nLinBox+11, 0465)//fim vlr st
				oPrint:Line(nLin-25,0500 ,nLinBox+11, 0500)//fim ipi
				oPrint:Line(nLin-25,0535 ,nLinBox+11, 0535)//fim frete
				oPrint:Line(nLin-25,0580 ,nLinBox+11, 0580)//fim total
			Else
				oPrint:Box(nLinBox-10,0015, nLinBox+05, 580, "-4")
				oPrint:Line(nLin-25,0035 ,nLinBox+11, 0035)//fim item
				oPrint:Line(nLin-25,0067 ,nLinBox+11, 0067)//fim codigo
				oPrint:Line(nLin-25,0235 ,nLinBox+11, 0235)//fim descri
				oPrint:Line(nLin-25,0255 ,nLinBox+11, 0255)//fim da um
				oPrint:Line(nLin-25,0300 ,nLinBox+11, 0300)//fim ncm
				oPrint:Line(nLin-25,0345 ,nLinBox+11, 0345)//fim quant
				oPrint:Line(nLin-25,0395 ,nLinBox+11, 0395)//fim pre�o
				oPrint:Line(nLin-25,0430 ,nLinBox+11, 0430)//fim icms
				oPrint:Line(nLin-25,0465 ,nLinBox+11, 0465)//fim vlr st
				oPrint:Line(nLin-25,0500 ,nLinBox+11, 0500)//fim ipi
				oPrint:Line(nLin-25,0535 ,nLinBox+11, 0535)//fim frete
				oPrint:Line(nLin-25,0580 ,nLinBox+11, 0580)//fim total
			EndIF
		Endif

		//Posiciona no produto atual
		DbSelectArea("SB1")
		SB1->(DbSeek(FWxFilial("SB1") + (cAlias)->C6_PRODUTO))

		MaFisAdd(SB1->B1_COD,; // 1-Codigo do Produto ( Obrigatorio )
		(cAlias)->C6_TES,; // 2-Codigo do TES ( Opcional )
		(cAlias)->C6_QTDVEN,; // 3-Quantidade ( Obrigatorio )
		(cAlias)->C6_PRCVEN,; // 4-Preco Unitario ( Obrigatorio )
		0,; // 5-Valor do Desconto ( Opcional )
		,; // 6-Numero da NF Original ( Devolucao/Benef )
		,; // 7-Serie da NF Original ( Devolucao/Benef )
		0,; // 8-RecNo da NF Original no arq SD1/SD2
		0,; // 9-Valor do Frete do Item ( Opcional )
		0,; // 10-Valor da Despesa do item ( Opcional )
		0,; // 11-Valor do Seguro do item ( Opcional )
		0,; // 12-Valor do Frete Autonomo ( Opcional )
		(cAlias)->C6_VALOR,;// 13-Valor da Mercadoria ( Obrigatorio )
		0,; // 14-Valor da Embalagem ( Opiconal )
		SB1->(Recno()),; // 15-RecNo do SB1
		0) // 16-RecNo do SF4

		//Aliquotas
		nAliqICM := MaFisRet(nItem,"IT_ALIQICM")
		nAliqST  := MaFisRet(nItem,"IT_ALIQSOL")
		nAliqIPI := MaFisRet(nItem,"IT_ALIQIPI")

		//Valor
		nIcmsRet := MaFisRet(nItem,"IT_VALSOL" ) //Valor da Substitui��o Tribut�ria
		nValIpi  := MaFisRet(nItem,"IT_VALIPI")

		oPrint:Say(nLin,0022,(cAlias)->C6_ITEM ,oFont0)
		oPrint:Say(nLin,0043,(cAlias)->C6_PRODUTO ,oFont0)
		If len(AllTrim(SB1->B1_DESC)+" - "+AllTrim(SB1->B1_FABRIC)) > 45
            If len(AllTrim(SB1->B1_DESC)) > 41
                
                cTexto   := SB1->B1_DESC
                cTrecho  := ""
                nPos     := 41
                While !Empty(SubStr(cTexto,nPos,1))
                    cTrecho  += SubStr(cTexto,nPos,1)
                    nPos     := nPos - 1
                EndDo    
                
                cPalavra := ""
                n := Len(cTrecho)
                While n >= 1
                    cPalavra += SubSTr(cTrecho,n,1)
                    n := n - 1
                EndDo
                
                nPos := 42
                While !Empty(SubStr(cTexto,nPos,1))
                    cPalavra += SubStr(cTexto,nPos,1)
                    nPos     := nPos + 1
                EndDo
                SyllabDiv(cPalavra,aSylls)
                for i := 1 to len(aSylls)
                    nSilaba += len(aSylls[i])
                    If ((len(AllTrim(SB1->B1_DESC))-len(cPalavra))+ len(aSylls[i])) <= 4
                       oPrint:Say(nLin,0070,Substr(AllTrim(SB1->B1_DESC),1,(len(AllTrim(SB1->B1_DESC))-len(cPalavra))+nSilaba)+"-",oFont0)
			           oPrint:Say(nLin+8,0070,substr(cPalavra,nSilaba+1,len(cPalavra))+" - "+AllTrim(SB1->B1_FABRIC),oFont0)
                       exit
                    EndIf
                Next
            Else
			    oPrint:Say(nLin,0070,AllTrim(SB1->B1_DESC),oFont0)
			    oPrint:Say(nLin+8,0070," - "+AllTrim(SB1->B1_FABRIC),oFont0)
            EndIf
		else
			oPrint:Say(nLin,0070,AllTrim(SB1->B1_DESC)+" - "+AllTrim(SB1->B1_FABRIC),oFont0)
		EndIF
		oPrint:Say(nLin,0240,(cAlias)->C6_UM ,oFont0)
		oPrint:Say(nLin,0264,Posicione("SB1",1,xFilial("SB1") + (cAlias)->C6_PRODUTO, "B1_POSIPI") ,oFont0)
		oPrint:Say(nLin,0292,Transform((cAlias)->C6_QTDVEN, PesqPict("SC6","C6_QTDVEN")) ,oFont0)
		oPrint:Say(nLin,0340,Transform((cAlias)->C6_PRCVEN, PesqPict("SC6","C6_PRCVEN")) ,oFont0)
		oPrint:Say(nLin,0405,Transform(nAliqICM, PesqPict("SFT","FT_ALIQICM")) ,oFont0)
		oPrint:Say(nLin,0440,Transform(Iif(nIcmsRet>0,nAliqST,0), PesqPict("SFT","FT_ALIQICM") ) ,oFont0)
		oPrint:Say(nLin,0475,Transform(nAliqIPI, PesqPict("SB1","B1_IPI")) ,oFont0)
		oPrint:Say(nLin,0490,Transform((cAlias)->C6_XVALFRE, PesqPict("SC6","C6_XVALFRE")) ,oFont0)
		oPrint:Say(nLin,0537,Transform((cAlias)->C6_VALOR, PesqPict("SC6","C6_VALOR")) ,oFont0)

		If len(AllTrim(SB1->B1_DESC)+" - "+AllTrim(SB1->B1_FABRIC)) > 41
			nLin += nSpace20
			nLinBox+= nSpace20
		else
			nLin += nSpace15
			nLinBox+= nSpace15
		Endif

		nTotSt   += nIcmsRet
		nTotIPI  += nValIpi
		nVlrTotal += (cAlias)->C6_VALOR

		IF nLin > 750
			oPrint:EndPage()
			oPrint:StartPage()
			nLin := 022
			fCabec(oPrint, cAlias)
			nLin += nSpace15
			nLinBox := nLin
		EndIF

		(cAlias)->(dbSkip())

		If (cAlias)->(Eof())
				oPrint:Line(nLin-30,0015 ,nLinBox+5, 0015)
				oPrint:Line(nLin-30,0035 ,nLinBox+5, 0035)
				oPrint:Line(nLin-30,0067 ,nLinBox+5, 0067)
				oPrint:Line(nLin-30,0235 ,nLinBox+5, 0235)
				oPrint:Line(nLin-30,0255 ,nLinBox+5, 0255)
				oPrint:Line(nLin-30,0300 ,nLinBox+5, 0300)
				oPrint:Line(nLin-30,0345 ,nLinBox+5, 0345)
				oPrint:Line(nLin-30,0395 ,nLinBox+5, 0395)
				oPrint:Line(nLin-30,0430 ,nLinBox+5, 0430)
				oPrint:Line(nLin-30,0465 ,nLinBox+5, 0465)
				oPrint:Line(nLin-30,0500 ,nLinBox+5, 0500)
				oPrint:Line(nLin-30,0535 ,nLinBox+5, 0535)
				oPrint:Line(nLin-30,0580 ,nLinBox+5, 0580)
		Endif

	End

	MaFisEnd()
	nLin-= nSpace10
	//Total geral
	oPrint:Box(nLin,0015, nLin+015, 580, "-4")
	oPrint:FillRect({nLin+1, 0016, nLin+014, 579}, oHGRAY)
	oPrint:Line(nLin,0430 ,nLin+15, 0430)
	oPrint:Line(nLin,0465 ,nLin+15, 0465)
	oPrint:Line(nLin,0500 ,nLin+15, 0500)
	oPrint:Line(nLin,0535 ,nLin+15, 0535)
	oPrint:Line(nLin,0580 ,nLin+15, 0580)//fim total
	nLin+= nSpace10
	oPrint:Say(nLin,0017,OemToAnsi('TOTAL + FRETE + DESPESAS') 	,oFont2n)
	oPrint:Say(nLin,0415,Transform(nTotSt, PesqPict("SD2","D2_ICMSRET")) ,oFont2n)
	oPrint:Say(nLin,0450,Transform(nTotIPI, PesqPict("SD2","D2_VALIPI")) ,oFont2n)
	oPrint:Say(nLin,0485,Transform(SC5->C5_FRETE, PesqPict("SC6","C6_XVALFRE")) ,oFont2n)
	oPrint:Say(nLin,0532,Transform(nVlrTotal + SC5->C5_FRETE + SC5->C5_DESPESA + nValIpi + nTotSt, PesqPict("SC6","C6_VALOR")) ,oFont2n)

	If !Empty(SC5->C5_MENNOTA)
		nLin+= nSpace30
		oPrint:Say(nLin,0020,OemToAnsi('OBSERVA��ES:'),oFont3ns)
		nLin+= nSpace15
		oPrint:Say(nLin,0020,OemToAnsi(Alltrim(SC5->C5_MENNOTA)),oFont4)
	Endif

/*    IF nLin > 500
        oPrint:EndPage()
        oPrint:StartPage()                
        nLin := 022                    
        fCabec(oPrint, cAlias)
    EndIF*/

Return

/*/{Protheus.doc} TSFATR03
Imprime cabe�alho
@author Felipe(Newsiga)
@since 25/05/2020
@version P12
@type function
/*/

Static Function fCabec(oPrint, cAlias)
    
	Local cStartPath:= GetSrvProfString("StartPath","")
    Local cLogo
  
  //Carrega vetor com dados da empresa
    Local aEmp      := fEmpFil()
    Local nLinAux   := 0
  
    //Carrega img
	If SubStr(cStartPath,Len(cStartPath),1) <> "\"
		cStartPath	+= "\"
	EndIf
	cLogo:= cStartPath+"lgrl01.bmp"
    //Logo da Empresa
    oPrint:SayBitmap(nLin,0040,cLogo,090,060)

    nLinAux := nLin
    //------------------------------- Dados da empresa --------------------------------//
    nLin +=nSpace15
    oPrint:Say(nLin,0225,OemToAnsi(AllTrim(aEmp[1])) 		,oFont3n) 
    nLin+=nSpace10
    oPrint:Say(nLin,0200,OemToAnsi( AllTrim(aEmp[2])+' - '+AllTrim(aEmp[3])+' - ' + AllTrim(aEmp[4])+' - '+AllTrim(aEmp[5])+' - CEP.: '+AllTrim(aEmp[6])  ) 		,oFont1)
    nLin+=nSpace10
    oPrint:Say(nLin,0235,OemToAnsi('CNPJ: '+AllTrim(aEmp[9]) +' - I.E.: '+AllTrim(aEmp[8]) )	,oFont1)
    nLin+=nSpace10
    //oPrint:Say(nLin,0250,OemToAnsi('Fone: '+AllTrim(aEmp[7])+' - www.tronst.com.br' ) ,oFont1)
    oPrint:Say(nLin,0220,OemToAnsi('Fone: (81) 3302-5620 - www.zummi.com.br' ) ,oFont1)

    nLin := nLinAux
    //------------------------------- Dados do Relat�rio --------------------------------//            
    nLin +=nSpace15+nSpace10
    oPrint:Say(nLin,0500,OemToAnsi('Data: '+DtoC(dDataBase)) 					,oFont0)	
    nLin+=nSpace10                     
    oPrint:Say(nLin,0500,OemToAnsi('Emiss�o: '+DtoC(SC5->C5_EMISSAO))			,oFont0)	
    nLin+=nSpace15                     
    oPrint:Say(nLin,0500,OemToAnsi('Pedido: ' +SC5->C5_NUM)                ,oFont3n,,CLR_HRED)


    //------------------------------- Dados do cliente --------------------------------//
    cCodVend := SC5->C5_VEND1 //Guarda c�digo do Vendedor
    dbSelectArea("SA1")
    dbSetOrder(1)
    dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI)

    nLin+=nSpace30
    oPrint:Box(nLin,0015, nLin+110, 580, "-4")
    oPrint:Box(nLin,0015, nLin+110, 290, "-4")
    oPrint:Line(nLin+15,0015,nLin+15,580)
    nLin+=nSpace10
    oPrint:Say(nLin,0115,OemToAnsi('DADOS CLIENTE'),oFont3n)
    oPrint:Say(nLin,0400,OemToAnsi('DADOS ENTREGA'),oFont3n)

    nLinAux := nLin
    nLin+=nSpace20
    oPrint:Say(nLin,0020,OemToAnsi('Cliente:'),oFont1n)
    oPrint:Say(nLin,0060,OemToAnsi(SA1->A1_COD+'/'+SA1->A1_LOJA+' - '+PadR(AllTrim(SA1->A1_NOME),50) ),oFont0)
    //oPrint:Say(nLin,0230,OemToAnsi('IE:'),oFont1n)
    //oPrint:Say(nLin,0245,OemToAnsi(Alltrim(TransForm(SA1->A1_INSCR,'@r 999.999.999.999'))) ,oFont0)

    nLin+=nSpace10
    oPrint:Say(nLin,0020,OemToAnsi('Endere�o:'),oFont1n)
    cEndFull := OemToAnsi (Alltrim(SA1->A1_END) +' - CEP: '+Transform(Alltrim(SA1->A1_CEP),PesqPict("SA1","A1_CEP")) )
    cBaiCida := OemToAnsi (Alltrim(SA1->A1_BAIRRO)+ /*' - Mun/UF: '*/' - '+Alltrim(SA1->A1_MUN)+' - '+Alltrim(SA1->A1_EST)  )
    oPrint:Say(nLin,0060,OemToAnsi(AllTrim(cEndFull)),oFont0)

    nLin+=nSpace10
    oPrint:Say(nLin,0020,OemToAnsi('Bairro:'),oFont1n)
    oPrint:Say(nLin,0060,OemToAnsi(AllTrim(cBaiCida)),oFont0)

    nLin+=nSpace10
    oPrint:Say(nLin,0020,OemToAnsi('Complen.:'),oFont1n)
    oPrint:Say(nLin,0060,OemToAnsi(AllTrim(SA1->A1_COMPLEM)),oFont0)

    oPrint:Say(nLin,0180,OemToAnsi('CFP/CNPJ:'),oFont1n)
    oPrint:Say(nLin,0220,OemToAnsi(TransForm(SA1->A1_CGC,iIF(SA1->A1_PESSOA=='J','@r 99.999.999/9999-99','@r 999.999.999-99'))) ,oFont0)

    nLin+=nSpace10
    oPrint:Say(nLin,0020,OemToAnsi('Contato:'),oFont1n)
    oPrint:Say(nLin,0060,OemToAnsi(Capital(Alltrim(SA1->A1_CONTATO))),oFont0)

    oPrint:Say(nLin,0180,OemToAnsi('Telefone:'),oFont1n)                                                     
    oPrint:Say(nLin,0220,OemToAnsi('('+AllTrim(SA1->A1_DDD)+') '+AllTrim(SA1->A1_TEL)) ,oFont0)

    nLin+=nSpace10
    oPrint:Say(nLin,0020,OemToAnsi('E-Mail:'),oFont1n)
    oPrint:Say(nLin,0060,OemToAnsi(SA1->A1_EMAIL),oFont0)                   
    
    nLin+=nSpace15
    oPrint:Line(nLin-10,0015,nLin-10,290)
    oPrint:Line(nLin,0290,nLin,580)
    nLin+=nSpace10
  
    DbSelectArea('SA3')
    dbSetOrder(1) 
    dbSeek(xFilial("SA3") + cCodVend ) 
    
    oPrint:Say(nLin-10,0020,OemToAnsi('Vend/Rep:'),oFont1n)
    //oPrint:Say(nLin,0130,OemToAnsi('Fone:'),oFont1n)
    oPrint:Say(nLin,0020,OemToAnsi('E-Mail:'),oFont1n)
    oPrint:Say(nLin-10,0060,OemToAnsi(PadR(AllTrim(SA3->A3_NREDUZ),15)),oFont0)  
    //oPrint:Say(nLin,0150,OemToAnsi('('+SA3->A3_DDDTEL+') '+AllTrim(SA3->A3_TEL)),oFont0)
    oPrint:Say(nLin,0060,OemToAnsi(Upper(AllTrim(SA3->A3_EMAIL))),oFont0)		
    nLin+=nSpace10


    //------------------------------- Dados da Entrega --------------------------------//
    nLin := nLinAux  
    nLin+=nSpace20  
    oPrint:Say(nLin,0295,OemToAnsi('Cliente:'),oFont1n)
    oPrint:Say(nLin,0335,OemToAnsi(SA1->A1_COD+'/'+SA1->A1_LOJA+' - '+AllTrim(SA1->A1_NOME)),oFont0)
        
    nLin+=nSpace10
    oPrint:Say(nLin,0295,OemToAnsi('Endere�o:'),oFont1n)
    oPrint:Say(nLin,0335,OemToAnsi(Alltrim(SA1->A1_ENDENT)+' - CEP: '+Alltrim(SA1->A1_CEPE)) ,oFont0)

    nLin+=nSpace10
    oPrint:Say(nLin,0295,OemToAnsi('Bairro'),oFont1n)
    oPrint:Say(nLin,0335,OemToAnsi(Alltrim(SA1->A1_BAIRROE)) +' - '+ OemToAnsi(Alltrim(SA1->A1_MUNE)+' - '+Alltrim(SA1->A1_ESTE)) ,oFont0)
    
    nLin+= nSpace5     
    oPrint:Line(nLin,0290,nLin,580)
    nLin+=nSpace10     
     //------------------------------- Dados da Cobran�a --------------------------------//
    oPrint:Say(nLin,0400,OemToAnsi('DADOS COBRAN�A'),oFont3n)
    nLin+= nSpace5 
    oPrint:Line(nLin,0290,nLin,580)
    nLin+=nSpace10
    
    oPrint:Say(nLin,0300,OemToAnsi('Cobran�a:'),oFont1n)
    oPrint:Say(nLin,0340,OemToAnsi(Alltrim(SA1->A1_ENDCOB)+' - CEP: '+Alltrim(SA1->A1_CEPC)) ,oFont1)
    nLin+=nSpace10
    oPrint:Say(nLin,0300,OemToAnsi('Bairro:'),oFont1n)
    oPrint:Say(nLin,0340,Alltrim(SA1->A1_BAIRROC)+' - '+OemToAnsi(Alltrim(SA1->A1_MUNC)+' - '+Alltrim(SA1->A1_ESTC)) ,oFont1)

    nLin+=nSpace15
    oPrint:Say(nLin,0300,OemToAnsi('Cond. de Pagto:'),oFont1n)
    oPrint:Say(nLin,0360,OemToAnsi(Posicione("SE4",1,xFilial("SE4") + SC5->C5_CONDPAG,"E4_DESCRI")) ,oFont1)
    oPrint:Say(nLin,0420,OemToAnsi('Tp. Frete:'),oFont1n)
    oPrint:Say(nLin,0460,OemToAnsi((cAlias)->FRETE) ,oFont1)
    oPrint:Say(nLin,0510,OemToAnsi('Frete:'),oFont1n)
    oPrint:Say(nLin,0530,Transform(SC5->C5_FRETE,PesqPict("SC5","C5_FRETE")) ,oFont1)
        
    fImpCbTit(oPrint, cAlias) //Imprime cabe�alho dos �tens

Return            

/*/{Protheus.doc} xEmpFil
Retorna dados da empresa corrente
@author Felipe(Newsiga)
@since 25/05/2020
@version P12
@type function
/*/

Static Function fEmpFil()

    Local aRet := {}
    aADD(aRet, AllTrim(RetField('SM0',1,cEmpAnt+cFilAnt,'M0_NOMECOM')))
    aADD(aRet, AllTrim(Capital(RetField('SM0',1,cEmpAnt+cFilAnt,'M0_ENDENT'))))
    aADD(aRet, AllTrim(Capital(RetField('SM0',1,cEmpAnt+cFilAnt,'M0_BAIRENT'))))
    aADD(aRet, AllTrim(Capital(RetField('SM0',1,cEmpAnt+cFilAnt,'M0_CIDENT'))))
    aADD(aRet, AllTrim(RetField('SM0',1,cEmpAnt+cFilAnt,'M0_ESTENT')))
    aADD(aRet, TransForm(RetField('SM0',1,cEmpAnt+cFilAnt,'M0_CEPENT'),'@r 99999-999'))
    aADD(aRet, RetField('SM0',1,cEmpAnt+cFilAnt,'M0_TEL'))
    aADD(aRet, TransForm(RetField('SM0',1,cEmpAnt+cFilAnt,'M0_INSC'),'@r 999.999.999.999'))
    aADD(aRet, TransForm(RetField('SM0',1,cEmpAnt+cFilAnt,'M0_CGC'),"@r 99.999.999/9999-99"))
    
Return(aRet)                                                                  

/*/{Protheus.doc} fImpCbTit
Retorna o cabe�alho dos �tens do relat�rio
@author Felipe(Newsiga)
@since 25/05/2020
@version P12
@type function
/*/

Static Function fImpCbTit(oPrint, cAlias)

    nLin+=nSpace10
    
    oPrint:Box(nLin,0015, nLin+015, 580, "-4")
    oPrint:FillRect({nLin+1, 0016, nLin+014, 579}, oHGRAY) 
 
    oPrint:Line(nLin,0035 ,nLin+15, 0035)//fim item
    oPrint:Line(nLin,0067 ,nLin+15, 0067)//fim codigo
    oPrint:Line(nLin,0235 ,nLin+15, 0235)//fim descri
    oPrint:Line(nLin,0255 ,nLin+15, 0255)//fim da um
    oPrint:Line(nLin,0300 ,nLin+15, 0300)//fim ncm
    oPrint:Line(nLin,0345 ,nLin+15, 0345)//fim quant
    oPrint:Line(nLin,0395 ,nLin+15, 0395)//fim pre�o
    oPrint:Line(nLin,0430 ,nLin+15, 0430)//fim icms
    oPrint:Line(nLin,0465 ,nLin+15, 0465)//fim vlr st
    oPrint:Line(nLin,0500 ,nLin+15, 0500)//fim ipi
    oPrint:Line(nLin,0535 ,nLin+15, 0535)//fim frete
    oPrint:Line(nLin,0580 ,nLin+15, 0580)//fim total 

    nLin+=nSpace10
    oPrint:Say(nLin,0017,OemToAnsi('ITEM') 		,oFont2n)
    oPrint:Say(nLin,0037,OemToAnsi('CODIGO') 	,oFont2n)
    oPrint:Say(nLin,0070,OemToAnsi('DESCRI��O / MARCA'),oFont2n)
    oPrint:Say(nLin,0239,OemToAnsi('UM') 		,oFont2n)
    oPrint:Say(nLin,0270,OemToAnsi('NCM') 		,oFont2n)
    oPrint:Say(nLin,0310,OemToAnsi('QUANT')     ,oFont2n)
    oPrint:Say(nLin,0357,OemToAnsi('PRE�O')	    ,oFont2n)
    oPrint:Say(nLin,0400,OemToAnsi('% ICMS')  ,oFont2n)
    oPrint:Say(nLin,0435,OemToAnsi('VLR ST')    ,oFont2n)
    oPrint:Say(nLin,0475,OemToAnsi('% IPI')   ,oFont2n)
    oPrint:Say(nLin,0505,OemToAnsi('FRETE'),oFont2n)
    oPrint:Say(nLin,0545,OemToAnsi('TOTAL')     ,oFont2n)    
    
Return

static function SyllabDiv(cOrign,aSylls)

	local cDitong := "AI.AO.AU.UA.EI.EU.IO.OE"
	local cTriton := "AIA.UAI"
	local cIndiv  := "CH.LH.NH.PN"
	local lDiv    :=  .F.
	local cTail
	local i
	local c
	local k
    DEFAULT aSylls  :=  {}
	priva cSyll           // s�laba j� separada
	priva cWord := cOrign // a palavra original
    priva _g_SignSet := "!"+Chr(34)+"#$%&'()*+,-./:;<=>?@[\]^_`{|}~"
    priva _g_VogsSet := "AEIOU"
    priva _g_ConsSet := "BCDFGHJKLMNPQRSTVWXYZ"

	if Len(cWord := AllTrim(cWord)) <= 3
	   return {cWord}
	end
	 
	// Padronizar a palavra, convertendo-a para mai�sculas,
	// removendo acentos e caracteres especiais
	cTail := ""
	for i := 1 to Len(cWord)
	    if SubStr(cWord,i,1) $ StrTran(_g_SignSet,"-")+" "
	       cTail := SubStr(cWord,i)
	       cWord := Left(cWord,i-1)
	       exit
	    end
	next
	cWord := AllTrim(Upper(cWord))
	cSyll := ""
	 
	while Len(cWord) > 0
	   Attach()
	   *
	   if     Len(cWord) = 0
	          lDiv := .T.
	          *
	   elseif Right(cSyll,1) $ _g_VogsSet
	          if Left(cWord,1) $ _g_ConsSet
	             lDiv := .T.
	             if Len(cWord)=1
	                Attach()
	             else
	                 if At(SubStr(cWord,1,2),cIndiv) = 0
	                    if !(Left(cWord,1) $ "BCDFGPTV" .and. SubStr(cWord,2,1) $ "LR"       ) .and.;
	                       ((Left(cWord,1) $ "LMNRS"    .and. SubStr(cWord,2,1) $ _g_ConsSet )  .or.;
	                         SubStr(cWord,2,1) $ _g_ConsSet)
	                         Attach()
	                    end
	                 end
	             end
	             if Left(cWord,1) = "S" .and. SubStr(cWord,2,1) $ _g_ConsSet
	                Attach()
	             end
	          else
	             if At(Right(cSyll,1)+Left(cWord,1),cDitong)=0 .and. At(Right(cSyll,1)+Left(cWord,2),cTriton)=0 .and.;
	                Right(cSyll,1) == Left(cWord,1)
	                lDiv := .T.
	             end
	          end
	          *
	   elseif Right(cSyll,1) $ _g_ConsSet
	          if Len(aSylls)=0 .and. Len(cSyll)=1 .and. Left(cWord,1) $ _g_ConsSet
	             Attach()
	          end
	   end
	 
	   // Forma��o definitiva da s�laba
	   if lDiv
	      lDiv := .F.
	      AAdd(aSylls,cSyll)
	      cSyll := ""
	   end
	end
	 
	// Recomposi��o da string, para recuperar a caixa, a
	// acentua��o original e os sinais suprimidos
	if Len(aSylls) > 0
	   aSylls[Len(aSylls)] += cTail
	   *
	   c := 0
	   for i := 1 to Len(aSylls)
	       for k := 1 to Len(aSylls[i])
	           c ++
	           aSylls[i] := Stuff(aSylls[i],k,1,SubStr(cOrign,c,1))
	       next
	   next
	else
	   AAdd(aSylls,cTail) 
	end
	return aSylls
	 
	//**********************************************************
	static function Attach()
	cSyll += Left(cWord,1)   // a s�laba j� formada
	cWord := SubStr(cWord,2) // o resto da palavra
	return nil


User Function tmail(cPara,cAssunto,cMsg,cArquivo) //fun��o para configura��o de autentica��o do email e conte�do.

	cMsg := ""
	DEFAULT cAssunto := ''
	DEFAULT cMsg := ''
	DEFAULT cArquivo := ''
	Local xRet
	Local oServer, oMessage
	//Local nPorta := 587
	Private cMailConta	:= NIL
	Private cSmtpServer	:= NIL
	Private cMailSenha	:= NIL


	cMailConta :=If(cMailConta == NIL,ALLTRIM(GETMV("MV_RELACNT")),cMailConta)  //Conta utilizada para envio do email
	cSmtpServer:=If(cSmtpServer == NIL,ALLTRIM(GETMV("MV_RELSERV")),cSmtpServer)//Servidor SMTP
	cMailSenha :=If(cMailSenha == NIL,ALLTRIM(GETMV("MV_RELPSW")),cMailSenha)   //Senha da conta de e-mail utilizada para envio

	oMessage:= TMailMessage():New() 
	oMessage:Clear()
	
	oMessage:cDate	:= cValToChar( Date() )
	oMessage:cFrom 	:= cMailConta
	oMessage:cTo 	:= cPara
	oMessage:cSubject:= cAssunto
	oMessage:cBody 	:= cMsg
	
     xRet := oMessage:AttachFile( cArquivo ) 
	if xRet < 0
		cAlerta := "O arquivo " + cArquivo + " n�o foi anexado!"
		alert( cAlerta ) 
	endif 
	
	oServer := tMailManager():New()  //Construtor para a classe TMailManager
	oServer:SetUseTLS( .T. ) //Indica se ser� utilizar� a comunica��o segura atrav�s de SSL/TLS (.T.) ou n�o (.F.)
	xRet := oServer:Init("",cSmtpServer,cMailConta,cMailSenha, 0,587) //inicializa��o do server
	if xRet != 0
		alert("O servidor SMTP n�o foi inicializado: " + oServer:GetErrorString( xRet ) )
		return
	endif
	xRet := oServer:SetSMTPTimeOut( 60 ) //Indica o tempo de espera em segundos.
	if xRet != 0
		alert("N�o foi poss�vel definir conex�o, tempo limite para " + cValToChar( nTimeout ))
	endif
 
	xRet := oServer:SMTPConnect() //conex�o com o servidor smtp
	if xRet != 0
		alert("N�o foi poss�vel conectar ao servidor SMTP: " + oServer:GetErrorString( xRet ))
		return
	endif
		//SMTPAuth verifica se pode realizar autentica��o do usu�rio no servidor de email, checa a chave AuthSmtp
		xRet := oServer:SmtpAuth(cMailConta,cMailSenha ) //Autentica��o do smtp com conta e senha
		if xRet !=0
			cInfo := "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet )
			alert( cInfo )
			return
		endif
	
	xRet :=  oMessage:Send(oServer) //Metodo para enviar o email 
	If xRet != 0 
 		alert( "Erro ao enviar o e-mail" )
    Return   
  EndIf
	 xRet := oServer:SMTPDisconnect()
  	if xRet != 0
    Alert( "Could not disconnect from SMTP server: " + oServer:GetErrorString( xRet ) )
  	endif
return
