#Include 'Totvs.ch'

User Function GFEA1183()
    Local _oXML := PARAMIXB[1]
    Local _lRet := .T.
    Local _cData := XmlValid(_oXML,{"_INFCTE","_COMPL","_ENTREGA","_COMDATA"},"_DPROG")
    If _cData
    EndIf
Return _lRet
