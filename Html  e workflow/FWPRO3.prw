#Include "Totvs.ch"
#Include 'Protheus.ch'


Static Function wfNotifica(cUserAprov,cTo,cSubject,cLink)
	Local lOk         := .T.
	Local cHtml       := ''
	Local cFolderLyt  := 'workflow\html\'
	Local cLayoutHTML := 'tela.html'

	//Carregando arquivo
	cHtml := wfloadfile(cFolderLyt+cLayoutHTML)


	cHtml := strtran( cHtml, '%cLink%', cLink )                                 //Link para aprova�ao


	WFNotifyAdmin( cTo , cSubject, cHtml )

Return lOk


Static Function wfNoticaError(cTo , cErrorAuto, cMessage)
	Local aHtml     := {}
	Local cHtml     := ''
	Local nI        := 0

	aAdd(aHtml,"<html>")
	aAdd(aHtml,"<head>")
	aAdd(aHtml,"<meta charset='utf-8' />")
	aAdd(aHtml,"<title>Notifica��o WorkFlow al�ada de produtos - ERPLabs</title>")
	aAdd(aHtml,"</head>")
	aAdd(aHtml,"<body>")
	aAdd(aHtml,"<table>")
	aAdd(aHtml,"<tr>")
	aAdd(aHtml,"<td>")
	aAdd(aHtml,cErrorAuto)
	aAdd(aHtml,"</td>")
	aAdd(aHtml,"</tr>")
	aAdd(aHtml,"<tr>")
	aAdd(aHtml,"<td>")
	aAdd(aHtml,cMessage)
	aAdd(aHtml,"</td>")
	aAdd(aHtml,"</tr>")
	aAdd(aHtml,"</body>")
	aAdd(aHtml,"</html>")

	For nI := 1 to len(aHtml)
		cHtml += aHtml[nI]
	Next
	WFNotifyAdmin( 'fecona5393geekjun@outlook.com' , , cHtml )
Return

