#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "TBIConn.ch"
#Include "Colors.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

User function GetNota()
	Local cAliasSF2
	Local cDe
	Local cAssunto       := "XML NF FATURAMENTO"
	Local cTexto         := ""
	Local cXml           := ""
	Local cArq           := ""
	Local cArq1           := ""
	Local aSm0  		 := {}
	Local nX

	OpenSm0("01",.F.) //Abre o SIGAMAT para obter acesso as empresas
	aSm0		:= FWLoadSM0()
	For nX := 1 to Len(aSm0)
		RpcClearEnv()
		RpcSetType(3)
		RpcSetEnv(aSm0[nX][1],aSm0[nX][2],,,"FIN",,{})
		cAliasSF2 := GetNextAlias()
		cDe       := GetMv("EL_RLMAIL")
		BeginSql Alias cAliasSF2
        Select * From %Table:SF2% SF2
            Inner join %Table:SA1% SA1 
            ON SA1.A1_COD = SF2.F2_cliente AND SA1.A1_loja = SF2.F2_loja 
        where SF2.%NotDel% 
            AND SA1.%NotDel%
            AND A1_TIPO = 'X'
		    AND F2_CHVNFE <> ' ' 
		    AND F2_FIMP = 'S'
		    AND F2_FILIAL = %exp:cFilAnt%
		    AND F2_EMISSAO = %exp:Date()%
		EndSql
		While (cAliasSF2)->(!Eof())
			IF ! File("\spool\XML\"+(cAliasSF2)->F2_CHVNFE+".Xml") .AND. ! File("\spool\XML\"+(cAliasSF2)->F2_CHVNFE+".Pdf")
				If !Empty((cAliasSF2)->F2_DOC)
					cTexto := " Xml da Nf :"+(cAliasSF2)->F2_DOC+"</br>"
					cTexto += " Chave da Nf :"+(cAliasSF2)->F2_CHVNFE+" </br>"
					cTexto += " Data de Emissão : "+DtoC(StoD(((cAliasSF2)->F2_EMISSAO)))
					cXml := U_GetXML((cAliasSF2)->F2_DOC,(cAliasSF2)->F2_SERIE)
					MemoWrite("\spool\XML\"+(cAliasSF2)->F2_CHVNFE+".Xml", cXml )
					U_zGerDanfe((cAliasSF2)->F2_DOC,(cAliasSF2)->F2_SERIE,"\spool\XML\",(cAliasSF2)->F2_CHVNFE)
					cArq := "\spool\XML\"+(cAliasSF2)->F2_CHVNFE+".Xml"
					cArq1 := "\spool\XML\"+(cAliasSF2)->F2_CHVNFE+".Pdf"
					IF File("\spool\XML\"+(cAliasSF2)->F2_CHVNFE+".Xml")
					U_DrillEmail(cDe,'Exportacao@grupoelizabeth.com.br','','',cAssunto,cTexto,.F.,cArq)
					EndIf
					IF File("\spool\XML\"+(cAliasSF2)->F2_CHVNFE+".Pdf")
					U_DrillEmail(cDe,'Exportacao@grupoelizabeth.com.br','','',cAssunto,cTexto,.F.,cArq1)
					EndIf
				EndIf                                                  
			EndIF 
			(cAliasSF2)->(DbSkip())
		End
		RpcClearEnv()
	Next
Return

User Function zGerDanfe(cNota, cSerie, cPasta,cChv)
	Local aArea     := GetArea()
	Local cIdent    := ""
	Local cArquivo  := ""
	Local oDanfe    := Nil
	Local lEnd      := .F.
	Local nTamNota  := TamSX3('F2_DOC')[1]
	Local nTamSerie := TamSX3('F2_SERIE')[1]
	Local dDataDe   := sToD("20190101")
	Local dDataAt   := Date()
	Private PixelX
	Private PixelY
	Private nConsNeg
	Private nConsTex
	Private oRetNF
	Private nColAux
	Default cNota   := ""
	Default cSerie  := ""
	Default cPasta  := GetTempPath()

	//Se existir nota
	If ! Empty(cNota)
		//Pega o IDENT da empresa
		cIdent := RetIdEnti()

		//Se o último caracter da pasta não for barra, será barra para integridade
		If SubStr(cPasta, Len(cPasta), 1) != "\"
			cPasta += "\"
		EndIf

		//Gera o XML da Nota
		cArquivo := cChv+".Xml"

		//Define as perguntas da DANFE
		Pergunte("NFSIGW",.F.)
		MV_PAR01 := PadR(cNota,  nTamNota)     //Nota Inicial
		MV_PAR02 := PadR(cNota,  nTamNota)     //Nota Final
		MV_PAR03 := PadR(cSerie, nTamSerie)    //Série da Nota
		MV_PAR04 := 2                          //NF de Saida
		MV_PAR05 := 1                          //Frente e Verso = Sim
		MV_PAR06 := 2                          //DANFE simplificado = Nao
		MV_PAR07 := dDataDe                    //Data De
		MV_PAR08 := dDataAt                    //Data Até

		//Cria a Danfe
		oDanfe := FWMSPrinter():New(cArquivo, IMP_PDF,.F.,cPasta, .T.)

		//Propriedades da DANFE
		oDanfe:SetResolution(78)
		oDanfe:SetPortrait()
		oDanfe:SetPaperSize(DMPAPER_A4)
		oDanfe:SetMargin(60, 60, 60, 60)

		//Força a impressão em PDF
		oDanfe:nDevice  := 6
		oDanfe:cPathPDF := cPasta
		oDanfe:lServer  := .T.
		oDanfe:lViewPDF := .F.

		//Variáveis obrigatórias da DANFE (pode colocar outras abaixo)
		PixelX    := oDanfe:nLogPixelX()
		PixelY    := oDanfe:nLogPixelY()
		nConsNeg  := 0.4
		nConsTex  := 0.5
		oRetNF    := Nil
		nColAux   := 0

		//Chamando a impressão da danfe no RDMAKE
	    u_DanfeProc(@oDanfe, @lEnd, cIdent, , , .F.)
		oDanfe:Print()
	EndIf

	RestArea(aArea)
Return
