#INCLUDE "protheus.ch"
#INCLUDE "FWMVCDef.ch"

User Function MATA070()
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

        If cIDponto == "MODELVLDACTIVE"
            nOper := oObj:nOperation
            if nOper == 5
                xRet := .F.
                Help(,, "Help",, "Usuario sem acesso a está operação",1,0,,,,,,{"Realize outra operação"})
            else 
                xRet := .T.
            endif

        elseif cIDponto == "BUTTONBAR"
            xRet := {} 

            Aadd(xRet, {"botão 1", "", {||Alert("Botão 1 Acionado")}})
            Aadd(xRet, {"botão 2", "", {||Alert("Botão 2 Acionado")}})


        elseif cIDponto == "FORMPRE"

            nOper := oObj:GetModel(cIDponto):nOperation
            cTipo   := aParam[4]
            cCampo  := aParam[5]

            if nOper == 4
                if cTipo == "SETVALUE" .and. (Alltrim(cCampo) == "A6_DVAGE" .or. Alltrim(cCampo) == "A6_NUMBCO") 
                    Help(,, "Help",, "Não é permitida a alteração do Campo " +cCampo,1,0,,,,,,{"Realize outra operação"})
                    xRet:=.F.

                else 
                    xRet:=.T.            
                endif
            endif

        elseif cIDponto == "MODELPOS"
            IF Empty(FWFLDGET("A6_TEL"))
                xRet    := .F. 
                Help(,, "Help",, "o campo telefone está vazio " ,1,0,,,,,,{"preencha o telefone do banco "})
            endif
            
        elseif cIDponto == "MODELCANCEL"
            xRet    := .F. 

        ENDIF
         
    ENDIF

    
Return xRet
