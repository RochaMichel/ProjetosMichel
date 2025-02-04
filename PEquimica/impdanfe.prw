#Include "Protheus.ch"
#Include "TBIConn.ch"
#Include "Colors.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

/*/{Protheus.doc} zGerDanfe
Função que gera a danfe e o xml de uma nota em uma pasta passada por parâmetro
@author Michel rocha
@since 05/11/2024
@version 1.0
@param cNota, characters, Nota que será buscada
@param cSerie, characters, Série da Nota
@param cPasta, characters, Pasta que terá o XML e o PDF salvos
@type function
@example u_zGerDanfe("000123ABC", "1", "C:\TOTVS\NF")
@obs Para o correto funcionamento dessa rotina, é necessário:
    1. Ter baixado e compilado o rdmake danfeii.prw
    2. Ter baixado e compilado o zSpedXML.prw - https://terminaldeinformacao.com/2017/12/05/funcao-retorna-xml-de-uma-nota-em-advpl/
/*/

User Function TestSelec()
	Local _stru:={}
	Local aCpoBro := {}
	Local oDlg
	Local aPergs   := {}
	Local cDoc  := Space(TamSX3("F2_DOC")[01])
	Local cFil  := Space(TamSX3("F2_FILIAL")[01])
	Local cCli  := Space(TamSX3("F2_DOC")[01])
	Local cALiasSF2 := GetNextAlias()
	Private lInverte := .F.
	Private cMark   := GetMark()
	Private oMark

	aAdd(aPergs, {1, "Filial de",  cFil, "", ".T.", "",    ".T.", 65, .F.})
	aAdd(aPergs, {1, "Filial Até", "ZZZZZZ", "", ".T.", "",    ".T.", 65, .T.})
	aAdd(aPergs, {1, "Doc De",  cDoc,  "", ".T.", "SF2", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Doc Até", "ZZZZZZZZZ",  "", ".T.", "SF2", ".T.", 80,  .T.})
	aAdd(aPergs, {1, "Cliente De ", cCli,  "", ".T.", "SA1", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Cliente Até", "ZZZZZZZZZ",  "", ".T.", "SA1", ".T.", 80,  .T.})
	aAdd(aPergs, {1, "Emissao De",  Date(),  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Emissao Até", Date(),  "", ".T.", "", ".T.", 80,  .T.})

	If !ParamBox(aPergs, "Informe os parâmetros")
		Return
	EndIf

	//Cria um arquivo de Apoio
	AADD(_stru,{"OK"      ,"C",2 ,0})
	AADD(_stru,{"FILIAL"  ,"C",6 ,0})
	AADD(_stru,{"DOC"     ,"C",9 ,0})
	AADD(_stru,{"SERIE"   ,"C",3 ,0})
	AADD(_stru,{"CLIENTE" ,"C",80 ,0})
	AADD(_stru,{"CODCLI"  ,"C",8 ,0})
	AADD(_stru,{"LOJA"    ,"C",4 ,0})
	AADD(_stru,{"EMISSAO" ,"D",8 ,0})

	cArq := Criatrab(_stru,.T.)
	DBUSEAREA(.t.,,carq,"TEMP_DOC")

	BeginSql Alias cALiasSF2
    Select F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO
    From %Table:SF2% SF2
    WHERE F2_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% 
    AND F2_DOC BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
    AND F2_CLIENTE BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
    AND F2_EMISSAO BETWEEN %Exp:DtoS(MV_PAR07)% AND %Exp:DtoS(MV_PAR08)%
	EndSql
	//Alimenta o arquivo de apoio com os registros do cadastro de clientes (SA1)

	While (cALiasSF2)->(!Eof())
		DbSelectArea("TEMP_DOC")
		RecLock("TEMP_DOC",.T.)
		TEMP_DOC->FILIAL   :=  (cALiasSF2)->F2_FILIAL
		TEMP_DOC->DOC      :=  (cALiasSF2)->F2_DOC
		TEMP_DOC->SERIE    :=  (cALiasSF2)->F2_SERIE
		TEMP_DOC->CODCLI   :=  (cALiasSF2)->F2_CLIENTE
		TEMP_DOC->CLIENTE  :=  Posicione('SA1',1,xFilial('SA1')+(cALiasSF2)->F2_CLIENTE+(cALiasSF2)->F2_LOJA,'A1_NOME')
		TEMP_DOC->LOJA	   :=  (cALiasSF2)->F2_LOJA
		TEMP_DOC->EMISSAO  :=  StoD((cALiasSF2)->F2_EMISSAO)
		TEMP_DOC->(MsunLock())
		(cALiasSF2)->(DbSkip())
	Enddo
	//Define as cores dos itens de legenda.

	aCpoBro	:= {{ "OK"	,, "Mark"         ,"@!"},;
		{ "FILIAL"		,, "Filial"       ,"@!"},;
		{ "DOC"	        ,, "Documento"    ,"@!"},;
		{ "SERIE"		,, "Serie"        ,"@!"},;
		{ "CLIENTE"		,, "Cliente"      ,"@!"},;
		{ "CODCLI"      ,, "Cod. Cliente" ,"@!"},;
		{ "LOJA"        ,, "Loja"         ,"@!"},;
		{ "EMISSAO"     ,, "Emissao"      ," "}}
	//Cria uma Dialog
	DEFINE MSDIALOG oDlg TITLE "Imprimir Danfe" From 9,0 To 350,1000 PIXEL
	DbSelectArea("TEMP_DOC")
	TEMP_DOC->(DbGotop())
	//Cria a MsSelect
	oMark := MsSelect():New("TEMP_DOC","OK","",aCpoBro,@lInverte,@cMark,{37,1,180,500},,,oDlg,,)
	oMark:bMark := {| | Disp()}
	//Exibe a Dialog
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| Processa({|| ImpDanf(oDlg)}, "Imprimindo...")},{|| oDlg:End()})
	//Fecha a Area e elimina os arquivos de apoio criados em disco.
	TEMP_DOC->(DbCloseArea())
	Iif(File(cArq + GetDBExtension()),FErase(cArq  + GetDBExtension()) ,Nil)
Return
	//Funcao executada ao Marcar/Desmarcar um registro.
Static Function Disp()
	RecLock("TEMP_DOC",.F.)
	If Marked("OK")
		TEMP_DOC->OK := cMark
	Else
		TEMP_DOC->OK := ""
	Endif
	MSUNLOCK()
	oMark:oBrowse:Refresh()
Return

Static Function ImpDanf(oDlg)
 	oDlg:End()
	Local cTemp := cGetFile(  , 'Arquivos', 1, 'C:\', .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )//GetTempPath()
	TEMP_DOC->(DbGotop())
	While TEMP_DOC->(!EOF())
		If !Empty(TEMP_DOC->OK)
			u_zGerDanfe(TEMP_DOC->DOC, TEMP_DOC->SERIE,TEMP_DOC->EMISSAO, cTemp)
		EndIF
		TEMP_DOC->(DbSkip())
	End
Return

User Function zGerDanfe(cNota, cSerie,dData, cPasta)
	Local aArea     := GetArea()
	Local cIdent    := ""
	Local cArquivo  := ""
	Local oDanfe    := Nil
	Local lEnd      := .F.
	//Local nTamNota  := TamSX3('F2_DOC')[1]
	//Local nTamSerie := TamSX3('F2_SERIE')[1]
	Local dDataDe   := dData
	Local dDataAt   := dData
	Private PixelX
	Private PixelY
	Private nConsNeg
	Private nConsTex
	Private oRetNF
	Private nColAux
	Default cNota   := ""
	Default cSerie  := ""
	Default cPasta  := GetTemp_DOCPath()

	//Se existir nota
	If ! Empty(cNota)
		//Pega o IDENT da empresa
		cIdent := RetIdEnti()

		//Se o último caracter da pasta não for barra, será barra para integridade
		If SubStr(cPasta, Len(cPasta), 1) != "\"
			cPasta += "\"
		EndIf

		//Gera o XML da Nota
		cArquivo := cNota + "_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-")
		u_zSpedXML(cNota, cSerie, cPasta + cArquivo  + ".xml", .F.)

		//Define as perguntas da DANFE
		Pergunte("NFSIGW",.F.)
		MV_PAR01 := cNota                     //Nota Inicial
		MV_PAR02 := cNota                     //Nota Final
		MV_PAR03 := cSerie                    //Série da Nota
		MV_PAR04 := 2                          //NF de Saida
		MV_PAR05 := 1                          //Frente e Verso = Sim
		MV_PAR06 := 2                          //DANFE simplificado = Nao
		MV_PAR07 := dDataDe                    //Data De
		MV_PAR08 := dDataAt                    //Data Até

		//Cria a Danfe
		oDanfe := FWMSPrinter():New(cArquivo, IMP_PDF, .F., , .T.)

		//Propriedades da DANFE
		oDanfe:SetResolution(78)
		oDanfe:SetPortrait()
		oDanfe:SetPaperSize(DMPAPER_A4)
		oDanfe:SetMargin(60, 60, 60, 60)

		//Força a impressão em PDF
		oDanfe:nDevice  := 6
		oDanfe:cPathPDF := cPasta
		oDanfe:lServer  := .F.
		oDanfe:lViewPDF := .F.

		//Variáveis obrigatórias da DANFE (pode colocar outras abaixo)
		PixelX    := oDanfe:nLogPixelX()
		PixelY    := oDanfe:nLogPixelY()
		nConsNeg  := 0.4
		nConsTex  := 0.5
		oRetNF    := Nil
		nColAux   := 0

		//Chamando a impressão da danfe no RDMAKE
		RptStatus({|lEnd| u_DanfeProc(@oDanfe, @lEnd, cIdent, , , .F.)}, "Imprimindo Danfe...")
		oDanfe:Print()
	EndIf

	RestArea(aArea)

Return

User Function zSpedXML(cDocumento, cSerie, cArqXML, lMostra)
    Local aArea        := GetArea()
    Local cURLTss      := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    Local oWebServ
    Local cIdEnt       := RetIdEnti()
    Local cTextoXML    := ""
    Local oFileXML
    Default cDocumento := ""
    Default cSerie     := ""
    Default cArqXML    := GetTempPath()+"arquivo_"+cSerie+cDocumento+".xml"
    Default lMostra    := .F.
        
    //Se tiver documento
    If !Empty(cDocumento)
        cDocumento := PadR(cDocumento, TamSX3('F2_DOC')[1])
        cSerie     := PadR(cSerie,     TamSX3('F2_SERIE')[1])
            
        //Instancia a conexão com o WebService do TSS    
        oWebServ:= WSNFeSBRA():New()
        oWebServ:cUSERTOKEN        := "TOTVS"
        oWebServ:cID_ENT           := cIdEnt
        oWebServ:oWSNFEID          := NFESBRA_NFES2():New()
        oWebServ:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
        aAdd(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
        aTail(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2):cID := (cSerie+cDocumento)
        oWebServ:nDIASPARAEXCLUSAO := 0
        oWebServ:_URL              := AllTrim(cURLTss)+"/NFeSBRA.apw"
            
        //Se tiver notas
        If oWebServ:RetornaNotas()
            
            //Se tiver dados
            If Len(oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
                
                //Se tiver sido cancelada
                If oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA != Nil
                    cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML
                        
                //Senão, pega o xml normal (foi alterado abaixo conforme dica do Jorge Alberto)
                Else
                    cTextoXML := '<?xml version="1.0" encoding="UTF-8"?>'
                    cTextoXML += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="4.00">'
                    cTextoXML += oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML
                    cTextoXML += oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXMLPROT
                    cTextoXML += '</nfeProc>'
                EndIf
                    
                //Gera o arquivo
                oFileXML := FWFileWriter():New(cArqXML, .T.)
                oFileXML:SetEncodeUTF8(.T.)
                oFileXML:Create()
                oFileXML:Write(cTextoXML)
                oFileXML:Close()
                    
                //Se for para mostrar, será mostrado um aviso com o conteúdo
                If lMostra
                    Aviso("zSpedXML", cTextoXML, {"Ok"}, 3)
                EndIf
                    
            //Caso não encontre as notas, mostra mensagem
            Else
                ConOut("zSpedXML > Verificar parâmetros, documento e série não encontrados ("+cDocumento+"/"+cSerie+")...")
                    
                If lMostra
                    Aviso("zSpedXML", "Verificar parâmetros, documento e série não encontrados ("+cDocumento+"/"+cSerie+")...", {"Ok"}, 3)
                EndIf
            EndIf
            
        //Senão, houve erros na classe
        Else
            ConOut("zSpedXML > "+IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3))+"...")
                
            If lMostra
                Aviso("zSpedXML", IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3)), {"Ok"}, 3)
            EndIf
        EndIf
    EndIf
    RestArea(aArea)
Return
