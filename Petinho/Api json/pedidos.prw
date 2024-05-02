#Include 'Protheus.ch'
#DEFINE cURL "https://www.rajsolucoes.com.br/"

User Function EnvPedRaj(cNumRaj,ctexto,lconfirm)
	Local oRest     := FWRest():New(cURL)
	Local oBody         As object
	//Aadd(aHeader, ckey)
	if lconfirm 
		oRest:setPath("easyapplication/petinhoerp/wstotvs/ws_recebeloteprotheus.php")
		oBody := JsonObject():new()
		oBody["code"] :=  200
		oBody["codigo_raj"] :=  cNumRaj
		oBody["codigo_protheus"] := cTexto
		oBody["key_acount"] :=  "5c84930eirn3231ebb9d0a2b31fd4"
		oRest:SetPostParams(oBody:toJson())
		oRest:Post()
	Else
		oRest:setPath("easyapplication/petinhoerp/wstotvs/ws_recebeloteprotheus.php")
		oBody := JsonObject():new()
		oBody["code"] :=  400
		oBody["codigo_raj"] :=  cNumRaj
		oBody["error_protheus"] := cTexto
		oBody["key_acount"] :=  "5c84930eirn3231ebb9d0a2b31fd4"
		oRest:SetPostParams(oBody:toJson())
		oRest:Post()
	EndIf

return
