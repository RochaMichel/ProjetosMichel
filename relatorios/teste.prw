#INCLUDE 'RESTFUL.CH'
#include "Totvs.ch"
#INCLUDE 'TBICONN.CH'

/**********************************************************************************
+-------------------------------------------------------------------------------+
|Funcao      | PIXBBPORTAL | Autor | CodERP Tecnologia                          |
+------------+------------------------------------------------------------------+
|Data        | 15.08.2022                                                       |
+------------+------------------------------------------------------------------+
|Descricao   | Função para geracao e consulta do PIX                            |
**********************************************************************************/

WSRESTFUL PIXBBPORTAL DESCRIPTION "Serviço REST para geracao do PIX." //FORMAT APPLICATION_JSON
WSDATA Filial   As String
WSDATA Valor 	As String
WSDATA Cgc 		As String

WSMETHOD GET  DESCRIPTION "Realiza a geracao do PIX."
WSMETHOD POST DESCRIPTION "Realiza a consulta do PIX."

END WSRESTFUL

/**********************************************************************************
+-------------------------------------------------------------------------------+
|Funcao      | GerarPIXBB | Autor | CodERP Tecnologia                           |
+------------+------------------------------------------------------------------+
|Data        | 15.08.2022                                                       |
+------------+------------------------------------------------------------------+
|Descricao   | Função para geracao do PIX                                       |
**********************************************************************************/

WSMETHOD GET WSRECEIVE Filial, Valor, Cgc WSSERVICE PIXBBPORTAL
	Local aRet     := {}
	Local nX 	   := 0
	Local nPosFil  := 0
	Local nPosVal  := 0
	Local nPosCgc  := 0
	Local cFil 	   := ""
	Private cValor := 0
	Private cCGC   := ""

		If !Len(Self:AQueryString) > 0
			SetRestFault(400, "Parametro em branco")
			Return .F.
		ElseIf !Empty(Alltrim(Self:AQueryString[2][2])) .and. !Empty(Alltrim(Self:AQueryString[3][2]))
			nPosFil := aScan(Self:AQueryString,{|x| AllTrim(x[1]) == 'FILIAL'})
			nPosVal := aScan(Self:AQueryString,{|x| AllTrim(x[1]) == 'VALOR'})
			nPosCgc := aScan(Self:AQueryString,{|x| AllTrim(x[1]) == 'CGC'})
			cFil   := Self:AQueryString[nPosFil][2]
			cValor := Self:AQueryString[nPosVal][2]
			cCGC   := Self:AQueryString[nPosCgc][2]
		ElseIf Len(::aURLParms)
			For nX := 1 to Len(::aURLParms)
	    		If !Empty(Alltrim(::aURLParms[nX])) // Testa se foi passado o parametro da entidade via url 	
					FWJsonDeserialize(DecodeUTF8(::aURLParms[nX]),@oParams)
					// Testa os parametros   
					If '"VALOR":' $ Upper(::aURLParms[nX])
						cValor := oParams:Valor
					Elseif '"CGC":' $ Upper(::aURLParms[nX])
						cCGC 	:= oParams:Cgc
					Endif
				Endif
			Next
		Endif

	// define o tipo de retorno do método
	::SetContentType("application/json")     

	PREPARE ENVIRONMENT EMPRESA "01" FILIAL cFil

		aRet := U_BB(1,,cValor,,cCGC)

	RESET ENVIRONMENT

	IF Len(aRet) > 0
		cEMV  := aRet[1]
		cTxID := aRet[2]
		::SetResponse('{"EMV":"' + cEMV + '", "TXID":"'+cTxID+'"}')
	Else
		::SetResponse('{"EMV":"", "TXID":""}')
	Endif

Return .T.
