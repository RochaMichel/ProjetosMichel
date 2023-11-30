#include "TOTVS.CH"

user Function Email(cTo,cAssunto,cMsg,cAnexo)

  Local oServer
  Local oMessage
  DEFAULT cTo      := ""
  DEFAULT cAssunto := ""
  DEFAULT cMsg     := ""
  DEFAULT cAnexo   := ""

   
  //Cria a conexão com o server STMP ( Envio de e-mail )
  oServer := TMailManager():New()
  oServer:SetUseTLS( .T. ) 
  oServer:SetUseSSL( .F. )
  oServer:Init( "", "smtp.gmail.com", "noreply@zummi.com.br", "zummi@2021", , 587 )
   
  //seta um tempo de time out com servidor de 1min
  If oServer:SetSmtpTimeOut( 60 ) != 0
    Conout( "Falha ao setar o time out" )
    Return .F.
  EndIf
   
  //realiza a conexão SMTP
  If oServer:SmtpConnect() != 0
    Conout( "Falha ao conectar" )
    Return .F.
  EndIf
   
  //Apos a conexão, cria o objeto da mensagem
  oMessage := TMailMessage():New()
   
  //Limpa o objeto
  oMessage:Clear()
   
  //Popula com os dados de envio
  oMessage:cDate := cValToChar( Date() )
  oMessage:cFrom              := "noreply@zummi.com.br"
  oMessage:cTo                := cTo
 // oMessage:cCc                := "microsiga@microsiga.com.br"
 // oMessage:cBcc               := "microsiga@microsiga.com.br"
  oMessage:cSubject           := cAssunto
  oMessage:cBody              := cMsg
  xRet := oMessage:AttachFile( cAnexo )
  if xRet < 0
    cMsg := "Could not attach file " + cAnexo
    conout( cMsg )
  endif
   
  //Envia o e-mail
  If oMessage:Send(oServer) != 0
    Conout( "Erro ao enviar o e-mail" )
    Return .F.
  EndIf
   
  //Desconecta do servidor
  If oServer:SmtpDisconnect() != 0
    Conout( "Erro ao disconectar do servidor SMTP" )
    Return .F.
  EndIf
   
Return .T.


