#include "PROTHEUS.ch"
#include "RESTFUL.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"
#INCLUDE "restful.ch"

WsRestful TESTE Description "WebService de TESTE"
	WSDATA CODIGO AS STRING OPTIONAL
	WsMethod GET Description "Disponibilização dos TESTE" WsSyntax "/GET"

End WsRestful

WSMETHOD GET WSSERVICE CODIGO WSREST TESTE

Return .T.
