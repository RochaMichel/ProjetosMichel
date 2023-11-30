#include "protheus.ch"
#INCLUDE "RWMAKE.CH"

User Function MT121BRW() 

	AAdd(aRotina,{"Imprimir Ped.Compra Mod.2","U_COMR001('00')",0,6})
	AAdd(aRotina,{"Env.Ped.Compra E-Mail","U_COMRA01('00')",0,6})
	AAdd(aRotina,{"Anexar Documentos","U_UpDocPC()",0,6})
	AAdd(aRotina,{"Visualizar Documentos","U_BxDocPC()",0,6})
	AAdd(aRotina,{"Incluir Historico","U_ECOMA001(SC7->C7_FILIAL,SC7->C7_NUM)",0,6})
	AAdd(aRotina,{"Listar Historico" ,"U_ECOMA1B('SC5',SC7->C7_FILIAL,SC7->C7_NUM)",0,6})
	AAdd(aRotina,{"Enviar Para Fornecedor" ,"U_ZCOMF001()",0,6})
	AAdd(aRotina,{"Alt.Data entrega" ,"U_ALTDTC7()",0,6})

Return

User Function BxDocPC(_cDOC)
	Local _cArquivo := ""
	Local _cDir := "C:\"
	Default _cDOC := SC7->C7_FILIAL+SC7->C7_NUM
	//_cArquivo := "http://192.168.1.165:8083/pp/TMKA260DOWN.php?USCGC="+_cCGC
	_cArquivo := "http://portal.grupoelizabeth.com.br/sigacom/d82c4e03cab04ae269be71f39cf0ae50/download.php?XDOC="+_cDOC
	//WinExec("C:\Program Files\Internet Explorer\iexplore.exe " + _cArquivo)
	If GetRemoteType()==2
		_cDir := "/"
	EndIf
	ShellExecute( "Open", _cArquivo, "",_cDir, 1 )
Return

User Function UpDocPC(_cDOC)
//http://192.168.1.150:8083/pp/upload.php?USCGC=00062195000102
	Local _cArquivo := ""
	Local _cDir := "C:\"
	Default _cDOC := SC7->C7_FILIAL+SC7->C7_NUM

	//_cArquivo := "http://192.168.1.165:8083/pp/upload.php?USCGC="+_cCGC
	_cArquivo := "http://portal.grupoelizabeth.com.br/sigacom/d82c4e03cab04ae269be71f39cf0ae50/upload.php?XDOC="+_cDOC
	//WinExec("C:\Program Files\Internet Explorer\iexplore.exe " + _cArquivo)
	If GetRemoteType()==2
		_cDir := "/"
	EndIf
	ShellExecute( "Open", _cArquivo, "",_cDir, 1 )
Return


//Helton Silva::Chamado 349316 
User Function ALTDTC7
	If SC7->C7_DATPRF <= DATE() .AND. SC7->C7_QUJE==0 .AND. SC7->C7_QTDACLA==0;
	 .AND. SC7->C7_XBLQAPR!= "S" .AND. SC7->C7_CONAPRO <> "R"
		U_AltDtC71()
	Else
		MsgStop("A data não pode ser alterada.", "Atenção")
	EndIf
Return
