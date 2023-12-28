#Include "Totvs.ch"
#Include "RPTDef.ch"
#include "TBICONN.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ POR010Imp³ Autor ³ José vinicius  ³ Data ³ 29.10.2023³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Espelho do Ponto                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Pnr010Imp(lEnd)					                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd        - A‡Æo do Codelock                             ³±±
±±³          ³ cString     - Mensagem                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function MailPonto()
Private lAtivAmb := .F.
If Select("SX2") == 0
	RPCClearEnv()
	RpcSetType( 3 )
	RpcSetEnv( "01",'010101', , , "",,, , , ,  )
	lAtivAmb := .T. // Seta se precisou montar o ambiente
Endif
BeginSql Alias 'qry'
Select * from %Table:SRA% RA
WHERE RA.%NotDel%
EndSql    

While qry->(!EOF())
	U_RELBAT(qry->RA_MAT,FirstDate(dDatabase),dDatabase)
	GPEMAIL("FOLHA DE PONTO","teste","michel.tjs.futebol@gmail.com",{"C:/Users/trabalho/AppData/Local/Temp/totvsprinter/relbat.pdf"}) 
	qry->(DbSkip())
End

qry->(DbCloseArea())
If lAtivAmb
	RPCClearEnv()
Endif

Return
/*/{Protheus.doc} RELDP2
Fonte para exibir Relatório de Apuração ISS
@type function
@author Felipe Henrique
@since 30/01/2023
@return 
/*/

User Function RELBAT(MV_PAR01,MV_PAR02,MV_PAR03)
	Private oReport  := Nil
	Private oSecCab	 := Nil



	oReport := reportDef()
	oReport:printDialog()

Return

Static Function reportDef()
	local oReport
	Local oSection1
//	Local oBreak
	local cTitulo := ' Relatório de Batidas ' //titulo do relatorio
	Private cFile := 'RELBAT'+Alltrim(MV_PAR01)

	oReport := TReport():New(cFile, cTitulo, , {|oReport| PrintReport(oReport)},'Relatório de Batidas não registradas')
	oReport:SetPortrait()
	oReport:nFontBody := 06
		//Primeira sessao
		oSection1:= TRSection():New(oReport, "Relatório de Batidas não registradas por Setor Consolidado", {"cQuery"})

		TRCell():new(oSection1, "DATA"  , "cQuery","DATA" ,PesqPict('SP8',"P8_DATA")    ,TamSX3("P8_DATA")[1]  	   ,,,  "LEFT")
		TRCell():new(oSection1, "DIA"   , "cQuery","DIA"  ,PesqPict('SP8',"P8_CC")      ,TamSX3("P8_CC")  	[1]      ,,,  "LEFT")
		TRCell():New(oSection1, "1a E." , "cQuery","1a E.",PesqPict('SP8',"P8_HORA")    ,TamSX3("P8_HORA") [1]     ,,,  "LEFT")
		TRCell():New(oSection1, "1a S."	, "cQuery","1a S.",PesqPict('SP8',"P8_HORA")     ,TamSX3("P8_HORA") [1]     ,,,  "LEFT")
		TRCell():New(oSection1, "2a E."	, "cQuery","2a E.",PesqPict('SP8',"P8_HORA")    ,TamSX3("P8_HORA")  [1]/*+2*/  ,,,  "LEFT")
		TRCell():New(oSection1, "2a S."	, "cQuery","2a S.",PesqPict('SP8',"P8_HORA")     ,TamSX3("P8_HORA")	[1]/*+2*/  ,,,  "LEFT")
		TRCell():New(oSection1, "3a E."	, "cQuery","3a E.",PesqPict('SP8',"P8_HORA")    ,TamSX3("P8_HORA")  [1]/*+2*/  ,,,  "LEFT")
		TRCell():New(oSection1, "3a S."	, "cQuery","3a S.",PesqPict('SP8',"P8_HORA")     ,TamSX3("P8_HORA")	[1]/*+2*/  ,,,  "LEFT")
		TRCell():New(oSection1, "4a E."	, "cQuery","4a E.",PesqPict('SP8',"P8_HORA")    ,TamSX3("P8_HORA")  [1]/*+2*/  ,,,  "LEFT")
		TRCell():New(oSection1, "4a S."	, "cQuery","4a S.",PesqPict('SP8',"P8_HORA")     ,TamSX3("P8_HORA")	[1]/*+2*/  ,,,  "LEFT")

return (oReport)

Static Function PrintReport(oReport)
	Local oSection1 := oReport:Section(1)

	DbSelectArea("cQuery")
	cQuery->(dbGoTop())
	oReport:SetMeter(cQuery->(RecCount()))
	oReport:IncMeter()
	oReport:setFile(cFile)
	oReport:nRemoteType := NO_REMOTE        // FORMA DE GERAÇÃO DO RELATÓRIO
  	oReport:nDevice := IMP_PDF
	oReport:SetPreview(.F.)
	oReport:SetCustomText({||CriaCab(oReport)})
	oSection1:Init()
	oReport:SkipLine()
		While cQuery->(!Eof())
			If oReport:Cancel()
				Exit'
			EndIf
			cData := cQuery->P8_DATA

			oSection1:Cell("DATA"):SetValue(StoD(cData))
			oSection1:Cell("DATA"):SetAlign("LEFT")
			oSection1:Cell("DIA"):SetValue(DiaSemana(StoD(cQuery->P8_DATA)))
			oSection1:Cell("DIA"):SetAlign("LEFT")

			WHILE cData == cQuery->P8_DATA
				Do Case
					Case AllTrim(P8_TPMARCA) == '1E'
						oSection1:Cell("1a E."):SetValue(cQuery->P8_HORA)
						oSection1:Cell("1a E."):SetAlign("LEFT")
					Case AllTrim(P8_TPMARCA) == '1S'
						oSection1:Cell("1a S."):SetValue(cQuery->P8_HORA)
						oSection1:Cell("1a S."):SetAlign("LEFT")
					Case AllTrim(P8_TPMARCA) == '2E'
						oSection1:Cell("2a E."):SetValue(cQuery->P8_HORA)
						oSection1:Cell("2a E."):SetAlign("LEFT")
					Case AllTrim(P8_TPMARCA) == '1S'
						oSection1:Cell("2a S."):SetValue(cQuery->P8_HORA)
						oSection1:Cell("2a S."):SetAlign("LEFT")
					Case AllTrim(P8_TPMARCA) == '3E'
						oSection1:Cell("3a E."):SetValue(cQuery->P8_HORA)
						oSection1:Cell("3a E."):SetAlign("LEFT")
					Case AllTrim(P8_TPMARCA) == '3S'
						oSection1:Cell("3a S."):SetValue(cQuery->P8_HORA)
						oSection1:Cell("3a S."):SetAlign("LEFT")
					Case AllTrim(P8_TPMARCA) == '4E'
						oSection1:Cell("4a E."):SetValue(cQuery->P8_HORA)
						oSection1:Cell("4a E."):SetAlign("LEFT")
					Case AllTrim(P8_TPMARCA) == '4S'
						oSection1:Cell("4a S."):SetValue(cQuery->P8_HORA)
						oSection1:Cell("4a S."):SetAlign("LEFT")
				End Case
				cQuery->(DbSkip())
			End
			oSection1:Printline()
		EndDo
		oSection1:Finish()
		cQuery->(DbCloseArea())

Return

Static Function CriaCab(oReport)
	Local aArea		:= GetArea()
	Local aCabec	:= {}
	Local cChar		:= chr(160)
	local _cEmp 	:= FWCodEmp()

	aCabec := {TRANSFORM(oReport:Page(),'999999');
		, Padc(UPPER("Relatorio de Pontos - ") + FWFilialName(_cEmp),132);
		, Padc("--------------------------------------------------------------------------------------------------",132);
		, Padc("Matricula: "+cFilAnt+" - "+cQuery->P8_MAT+"          Nome: "+cQuery->RA_NOME,132);
		, Padc("Funcao: "+cQuery->RA_CODFUNC+"              C.C: "+cQuery->P8_CC+" - "+cQuery->CTT_DESC01,132);
		, Padc("--------------------------------------------------------------------------------------------------",132);
		, Padc("Departamento: "+cQuery->RA_DEPTO+" - "+AllTrim(cQuery->QB_DESCRIC)+"       Turno: "+Alltrim(cQuery->R6_DESC),132);
		, Padc("--------------------------------------------------------------------------------------------------",132);
		, "Hora: " + time() ;
		+ cChar + "          Emissão: " + Dtoc(dDataBase)}

	RestArea( aArea )

Return aCabec
