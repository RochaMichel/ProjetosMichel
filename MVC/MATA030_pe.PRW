#INCLUDE "protheus.ch"
#INCLUDE "FWMVCDef.ch"

User Function MATA030()
    Local aParam        := PARAMIXB
    Local oObj          := NIL
    Local cIDponto      := ""
    Local cIdModel      := ""
    local nOper         := 0
    Local xRet          := .T.
    local cTipo         := ""
    local cCampo        := ""

    if aParam <> nil

        oObj      := aParam[1]
        cIDponto  := aParam[2]
        cIdModel  := aParam[3]
        IF aParam == "FORMPRE"
        nOper := oObj:GetModel(cIDponto):nOperation
        cTipo   := aParam[4]
        cCampo  := aParam[5]
            IF nOper == 4
                if cTipo == "SETVALUE" .and. (Alltrim(cCampo) == "A1_NOME")
                    Help(,, "Help",, "N�o � permitida a altera��o do Campo " +cCampo,1,0,,,,,,{"Realize outra opera��o"})
                    xRet:=.F.
                else 
                    xRet:=.T.  
                ENDIF
            ENDIF    
        ENDIF
    ENDIF
return
