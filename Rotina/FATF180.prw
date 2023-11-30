#include "PROTHEUS.ch"
#include "RESTFUL.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FATF180
 WebService para disponibilização do cadastro de produto
@author  RDS Tecnologia
@since   03/02/2022 
@version 1.0
/*/
//-------------------------------------------------------------------
WsRestful FATF180 Description "WebService de produtos"

	WsMethod GET Description "Disponibilização dos produtos" WsSyntax "/GET"

End WsRestful


WsMethod GET WsService FATF180

Local oBody       := u_GetProdutos()
Local cJson       := oBody:toJson()

	::SetContentType( 'application/json' )
	::SetResponse(cJson)

    /*
	SetRestFault(400,"Ops")
    Return .F.
    */
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetProdutos
 WebService para disponibilização do cadastro de produto
@author  RDS Tecnologia
@since   03/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------

User Function GetProdutos
Local cQuery      := ""
Local cCampos     := ""
Local lAtivAmb    := .F.
Local a           := 0
Local oBody       := JsonObject():new()
Local oLine       := Nil//JsonObject():new()
Private xConteudo := ""
Private aCampos   := {}

// Prepara o ambiente caso precise
If Select("SX2") == 0
	RPCClearEnv()
	RpcSetType( 3 )
	RpcSetEnv( "01",'020101', , , "FIN",,, , , ,  )
	lAtivAmb := .T. // Seta se precisou montar o ambiente
Endif

AADD(aCampos,"B1_COD")
AADD(aCampos,"B1_DESC")
AADD(aCampos,"B5_XTIPOPR")
AADD(aCampos,"B5_XDIMFAB")
AADD(aCampos,"B5_XTELAGE")
AADD(aCampos,"B1_XLINHA")
AADD(aCampos,"B5_ECTITU")
AADD(aCampos,"B5_XCORPRE")
AADD(aCampos,"B5_XACABAM")
AADD(aCampos,"B5_XACALAT")
AADD(aCampos,"B5_XVRTON")
AADD(aCampos,"B5_XCOF")
AADD(aCampos,"B5_XFACES")
AADD(aCampos,"B5_XQTEMB")
AADD(aCampos,"B5_XSUPEFI")
AADD(aCampos,"B5_XGRPABS")
AADD(aCampos,"B5_XGRAGUA")
AADD(aCampos,"B5_XPEI")
AADD(aCampos,"B5_XJUNTA")
AADD(aCampos,"B5_XCLSUSO")
AADD(aCampos,"B5_XPAREDE")
AADD(aCampos,"B5_XPISO")
AADD(aCampos,"B5_XEXTER")
AADD(aCampos,"B5_XCALCA")
AADD(aCampos,"B5_XRAMPA")
AADD(aCampos,"B5_XTALTIS")
AADD(aCampos,"B5_XTALTO")
AADD(aCampos,"B5_XTMEDI")
AADD(aCampos,"B5_XTLEVE")
AADD(aCampos,"B5_XBANHE")
AADD(aCampos,"B5_XBOXBAN")
AADD(aCampos,"B5_XCOZIN")
AADD(aCampos,"B5_XAREASR")
AADD(aCampos,"B5_XQUARTO")
AADD(aCampos,"B5_XSALA")
AADD(aCampos,"B5_XHALL")
AADD(aCampos,"B5_XTERRAC")
AADD(aCampos,"B5_XGARAGE")
AADD(aCampos,"B5_XPINTER")
AADD(aCampos,"B5_XPBANHE")
AADD(aCampos,"B5_XPCOZIN")
AADD(aCampos,"B5_XPMURO")
AADD(aCampos,"B5_XPARESR")
AADD(aCampos,"B5_XFACHAD")
AADD(aCampos,"B5_XPISCIN")

For a := 1 To Len(aCampos)
    cCampos := cCampos + aCampos[a] + ", "
Next

cCampos := SubStr(cCampos, 1, Len(cCampos) - 2) + Space(1)

cQuery += "SELECT "
cQuery += cCampos
cQuery += "FROM " + RetSqlName("SB1") + " SB1 "
cQuery += "INNER JOIN " + RetSqlName("SB5") + " SB5 ON B1_FILIAL = B5_FILIAL AND B1_COD = B5_COD AND SB5.D_E_L_E_T_ <> '*' "
cQuery += "WHERE SB1.D_E_L_E_T_ <> '*' AND B1_TIPO = '01' AND B1_XFORLIN <> 'S' "

cQuery := ChangeQuery(cQuery)

MpSysOpenQuery(cQuery, "TMP")

TMP->(DBGOTOP())
oBody["Produtos"] := {}
While TMP->(!EOF())
    oLine       := JsonObject():new()
    For a := 1 To Len(aCampos)
        xConteudo := &("TMP->"+aCampos[a])
        &('oLine["'+aCampos[a]+'"] := '+IIF(ValType(xConteudo) == 'N', Val(xConteudo), '"' + EncodeUtf8(Alltrim(xConteudo)) + '"') )
    Next
    AADD(oBody["Produtos"],oLine)
    TMP->(DbSkip())
EndDo

// Se montou o ambiente, desmonta
If lAtivAmb
	RPCClearEnv()
Endif

Return oBody
