#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'

user function Usuarios()
    local bOK                :={|| fOk()}
    local bTTS               :={|| fTTS()}  

    Private lTran            := .F.

        BEGIN SEQUENCE 
    
        
            if !AliasInDic("SZ1")
            SHOWHELPDLG("SX",{"Dicionario de dados desatualizado"},5,{"Atualize o dicionario de dados para usar esta rotina."},5)
                BREAK
            ENDIF

            DbSelectArea("SZ1")
            SZ1->(DbSetOrder(1))

            AxCadastro("SZ1","Usuário",,,,,,bOK,bTTS)

            if lTran
                ConfirmSx8()
            else
                RollBackSx8()
            ENDIF

        END SEQUENCE

RETURN


Static Function fOK()
    local lRet     := .F.
    local aArea    := GetArea()
    local aAreaSZ6 := {}
    BEGIN SEQUENCE 

        if !INCLUI .And. !ALTERA

            if AliasInDic("SZ6")
                DbSelectArea("SZ6")
                aAreaSZ6 := SZ6->(GetArea())
                SZ6->(DbSetOrder(3))

                if SZ6->(MsSeek(SZ1->Z1_CODIGO))
                    SHOWHELPDLG("Empréstimo",{"Não é possivel excluir usuario com emprestimo realizado"},5,{"Somente usuarios sem emprestimo pode ser excluido"},5)
                    BREAK
                ENDIF

                RestArea(aAreaSZ6)
            ENDIF
        ENDIF

        lRet := .T.

    End SEQUENCE

    RestArea(aArea)

return lRet

Static Function fTTS()
    
    if INCLUI
        lTran := .T.
    endif

return
    
Return return_var

Return
