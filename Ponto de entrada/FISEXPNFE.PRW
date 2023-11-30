#include "rwmake.ch"
#include "Totvs.ch"

User Function FISEXPNFE()
	Local cXML 		:= PARAMIXB[1]
	Local cDe       := GetMv("EL_RLMAIL")
	Local cAssunto       := "XML NF FATURAMENTO"
	Local cTexto         := "Segue em anexo o xml de faturamento"
	If !Empty(cXML)
		U_DrillEmail(cDe,"contato.michelrocha@gmail.com",,,cAssunto,cTexto,.F.,cXML)
	EndIF
Return
 
User Function FISENVNFE()
Local aIdNfe    := PARAMIXB[1]
Local cIdsNfe   := ""
Local nX        := 0
 
    If Len(aIdNfe) > 0
 
        For nX := 1 To Len(aIdNfe)
            cIdsNfe += aIdNfe[Nx]
            If nX < Len(aIdNfe)
                cIdsNfe += " - "
            EndIf
        Next nX    
        msgalert("Id(s) da(s) NF-e no TSS: " + cIdsNfe )
 
    Else
 
        msgalert("Transmissão da NF-e Falhou")
 
    EndIf
 
Return Nil
