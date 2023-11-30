#Include "Protheus.ch"

// ___________________________________________________________________________
// Função : GetXML - Realiza o consumo do WS NFeSBRA para retorno do XML      |
// Modulo : Faturamento                                                       |
// Fonte  : GetXML.prw                                                        |
// ---------+-------------------+---------------------------------------------+
// Data     | Autor             | Descricao                                   |
// ---------+-------------------+---------------------------------------------+
// 25/05/22 | Walter Rodrigo    | Criação da rotina                           |
// ---------------------------------------------------------------------------

User Function GetXML(cDocumento, cSerie, cArqXML)
    Local aArea        := GetArea()
    Local cURLTss      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
    Local cIdEnt       := RetIdEnti()
    Local oWebServ
    Local cTextoXML    := ""
    Default cDocumento := ""
    Default cSerie     := ""
    Default cArqXML    := ""
        
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

                    //Gera o arquivo
                    If !Empty(cArqXML)
                        oFileXML := FWFileWriter():New(cArqXML, .T.)
                        oFileXML:SetEncodeUTF8(.T.)
                        oFileXML:Create()
                        oFileXML:Write(cTextoXML)
                        oFileXML:Close()
                    Endif    
                EndIf
            EndIf
        EndIf
    EndIf
    RestArea(aArea)

Return cTextoXML

// ___________________________________________________________________________
// Função : GerXML - Realiza o consumo do WS NFeSBRA para retorno do XML      |
// Modulo : Faturamento                                                       |
// Fonte  : GerXML.prw                                                        |
// ---------+-------------------+---------------------------------------------+
// Data     | Autor             | Descricao                                   |
// ---------+-------------------+---------------------------------------------+
// 25/05/22 | Walter Rodrigo    | Criação da rotina                           |
// ---------------------------------------------------------------------------

User Function ExpXML(cFilInfo)
 
    Local cQuery   := ""
    Local cPasta   := "D:\TOTVS\Microsiga\protheus_data\temp\XML\"

	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv("01",cFilInfo,,,"FIN",,{})

    cQuery := "SELECT F2_FILIAL, F2_DOC, F2_SERIE, F2_CHVNFE FROM "+RetSqlName("SF2")+" SF2 WHERE F2_EMISSAO >= '20221001' AND F2_CHVNFE <> ' ' AND F2_FILIAL = '"+cFilAnt+"' AND D_E_L_E_T_ <> '*' ORDER BY F2_EMISSAO "

    MpSysOpenQuery(cQuery, "TDF")

    While TDF->(!Eof())
        U_GetXML(TDF->F2_DOC, TDF->F2_SERIE, cPasta + TDF->F2_CHVNFE  + ".xml")
        TDF->(DbSkip())
    EndDo

    RpcClearEnv()

Return

// ___________________________________________________________________________
// Função : GerXML - Realiza o consumo do WS NFeSBRA para retorno do XML      |
// Modulo : Faturamento                                                       |
// Fonte  : GerXML.prw                                                        |
// ---------+-------------------+---------------------------------------------+
// Data     | Autor             | Descricao                                   |
// ---------+-------------------+---------------------------------------------+
// 25/05/22 | Walter Rodrigo    | Criação da rotina                           |
// ---------------------------------------------------------------------------

User Function JobXML()

    Local lAtivAmb := .F.
    Local cQuery   := ""
    Local aFiliais := {}
    Local a        := 0

    If Select("SX2") <= 0
	    RpcClearEnv()
	    RpcSetType(3)
	    RpcSetEnv("01","020201",,,"FIN",,{})
        lAtivAmb := .T.
    Endif 

    cQuery := "SELECT M0_CODFIL FROM SYS_COMPANY WHERE D_E_L_E_T_ <> '*' ORDER BY M0_FILIAL "

    MpSysOpenQuery(cQuery, "TM0")

    While TM0->(!Eof())
        AADD(aFiliais, Alltrim(TM0->M0_CODFIL))
        TM0->(DbSkip())
    EndDo

    For a := 1 To Len(aFiliais)
        //StartJob("U_ExpXML",GetEnvServer(),.T., aFiliais[a])
        U_ExpXML(aFiliais[a])
    Next

    If lAtivAmb
        RpcClearEnv()
    Endif

Return
