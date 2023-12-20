#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

/*+------------------------------------------------------------------------+
*|Funcao      | MTelPag()                                                  |
*+------------+------------------------------------------------------------+
*|Autor       | Rivaldo Jr. ( Cod.ERP Tecnologia LTDA )                    |
*+------------+------------------------------------------------------------+
*|Data        | 17/10/2023                                                 |
*+------------+------------------------------------------------------------|
*|Descricao   | Ponto de entrada MVC da Tela de pagamentos                 |
*+------------+-----------------------------------------------------------*/

User Function MTelPag()
	Local aParam     := PARAMIXB
	Local lRet       := .T.
    Local aRetorno   := {}
    Local cContato   := ''
    Local cMensagem  := ''
    Local cIdOper    := ''
    Local nValLink   := 0
	Local oModel     := aParam[1]
	Local cIdPonto   := aParam[2]

    If Inclui
        If cIdPonto == 'MODELPOS' .AND. oModel:IsCopy() .AND. ZLP->ZLP_STATUS <> '2'
            ZLP->(RecLock('ZLP', .F.))
                ZLP->ZLP_STATUS := '4'
            ZLP->(MsUnlock())
        EndIf
    EndIf
	If Inclui .AND. cIdPonto == 'MODELCOMMITNTTS'//Commit das operações (após a gravação)

        ZLP->(RecLock('ZLP', .F.))
            ZLP->ZLP_VALOR := oModel:Getvalue('TOT_SALDO', 'XX_TOTAL')
        ZLP->(MsUnlock())
        
        lRet := U_ConsRest(ZLP->ZLP_VALOR, .F., ZLP->ZLP_PARCEL) //Chamo a Função principal para dar inicio a geração do Link de pagamento

        If lRet

            cContato  := "55"+ZLP->ZLP_CONTCL
            cIdOper   := AllTrim(Posicione('SA3',1,xFilial("SA3")+ZLP->ZLP_CODVEN,'A3_IDOPER'))
            nValLink  := AllTrim(Transform(ZLP->ZLP_VALOR, "@E 999,999,999.99"))

            cMensagem := CriaMsg() //Chamado para retornar a mensagem que será enviada para o cliente.
            cMensagem := StrTran(cMensagem,"( VALOR DO LINK )",nValLink)
            cMensagem := StrTran(cMensagem,"( LINK DE PAGAMENTO )",AllTrim(ZLP->ZLP_LINKPG))
            
            aRetorno := U_Chat2Desk(cContato , cIdOper, EncodeUtf8(cMensagem))
            //aRetorno := {'success',51256485}

            If Len(aRetorno) > 0
                If aRetorno[1] == 'success'

                    U_AddTag('134816',cValToChar(aRetorno[2]))// adiciono a Tag AGUARDANDO PAGAMENTO

                    ZLP->(RecLock('ZLP',.F.))
                        ZLP->ZLP_IDCHAT := cValToChar(aRetorno[2]) // GRAVO O ID DA CONVERSA.
                    ZLP->(MsUnlock())

                    FWAlertSuccess('Link de pagamento enviado ao cliente.','Sucesso!') 
                Else 
                    Help(" ",1,"ATENÇÃO!",,"O link foi gerado, mas, não foi possivel enviar ao cliente.";
                    ,3,1,,,,,,{""})    
                EndIf
            EndIf

        Else 
            Help(" ",1,"ATENÇÃO!",,"Não foi possível gerar o link de pagamento.";
                ,3,1,,,,,,{""})    
            Return .F.
        EndIf
    ElseIf Altera .And. ZLP->ZLP_STATUS == '2'
        Help(" ",1,"ATENÇÃO!",,"Não é possível alterar um registro onde o link já foi pago.";
            ,3,1,,,,,,{""})    
        Return .F.
	endif

Return lRet


Static Function CriaMsg()
    Local oFile := Nil
    Local cMensagem := ''
    Local nHandle   

    cMensagem+= " Estou te enviando abaixo o link de pagamento. "+CRLF
    cMensagem+= " "+CRLF
    cMensagem+= " Valor: R$ ( VALOR DO LINK ) "+CRLF
    cMensagem+= " Link: "+CRLF
    cMensagem+= " "+CRLF
    cMensagem+= " ( LINK DE PAGAMENTO )"+CRLF
    cMensagem+= " "+CRLF
    cMensagem+= " "+CRLF
    cMensagem+= " * DADOS CADASTRAIS  "+CRLF
    cMensagem+= " Nome completo: "+CRLF
    cMensagem+= " CPF: "+CRLF
    cMensagem+= " Data de Nascimento: "+CRLF
    cMensagem+= " Telefone: "+CRLF
    cMensagem+= " E-mail: "+CRLF
    cMensagem+= "  "+CRLF
    cMensagem+= " --------------- "+CRLF
    cMensagem+= "  "+CRLF
    cMensagem+= " * OBS "+CRLF
    cMensagem+= " - Nosso prazo de entrega é de 24h à 48h úteis após a inclusão do pedido *(Exceto SEDEX)*; "+CRLF
    cMensagem+= " (Exceto sachês, chocolates, pastilha sublingual, Gomas, "
    cMensagem+= " Gotas e Cápsulas oleosas na retirada em loja e entrega em domicílio. Por necessitar de um tempo maior para manipulação). "

    cArquivo := GetSrvProfString("RootPath","")+"\TEXTOLINKPG.TXT"
    If !File(cArquivo)
        nHandle := fcreate(cArquivo)
        if nHandle != -1
            FWrite(nHandle, cMensagem)
            FClose(nHandle)
        EndIf
    EndIf

    //Definindo o arquivo a ser lido
    oFile := FWFileReader():New(cArquivo)
    If (oFile:Open())//Se o arquivo pode ser aberto
        If !(oFile:EoF())//Se não for fim do arquivo
            cMensagem  := oFile:FullRead()
        EndIf
        oFile:Close()//Fecha o arquivo e finaliza o processamento
    EndIf

Return cMensagem
