#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#include "TopConn.ch"
#include "Color.ch"
#include "COLORS.ch"


User Function RelNFS() 
	Local oReport
	Private oRel
	PRIVATE aPergs      := {}

	aAdd(aPergs,{1,"De filial: ",Space(TamSx3('F1_FILIAL')[1]),"","","SM0","",50,.F.})    //MV_PAR01
	aAdd(aPergs,{1,"Ate filial: ",Space(TamSx3('F1_FILIAL')[1]),"","","SM0","",50,.F.})   //MV_PAR02
	aAdd(aPergs,{1, "De Emissão ",Date()   , "", ".T.", "", ".T.", 80 , .F.}) //MV_PAR03
	aAdd(aPergs,{1, "Até Emissão ",Date()   , "", ".T.", "", ".T.", 80 , .T.}) //MV_PAR04
	aAdd(aPergs,{1,"De  NF ",Space(TamSx3('F1_DOC')[1]),"","","SF1","",50,.F.}) 		        //MV_PAR05
	aAdd(aPergs,{1,"Ate NF ",Space(TamSx3('F1_DOC')[1]),"","","SF1","",50,.F.})		        //MV_PAR06
	aAdd(aPergs,{1,"De CFOP: ",Space(TamSx3('D2_CF')[1]),"","","","",50,.F.})    //MV_PAR07
	aAdd(aPergs,{1,"Ate CFOP: ",Space(TamSx3('D2_CF')[1]),"","","","",50,.F.})   //MV_PAR08
    aAdd(aPergs,{1,"De TES: ",Space(TamSx3('D2_TES')[1]),"","","SF4","",50,.F.})    //MV_PAR09
	aAdd(aPergs,{1,"Ate TES: ",Space(TamSx3('D2_TES')[1]),"","","SF4","",50,.F.})   //MV_PAR10
	If !Parambox(aPergs,'Informe os Parametros')
		Return
	EndIf

	_cTitulo  := "Relatorio NF de Saída com Entrada"
	oReport:= TReport():New("RELNFS",_cTitulo,, {|oReport| ReportPrint(oReport)},_cTitulo)
	oReport:SetLandscape()

	//Parametriza o TReport para alinhamento a direita
	oReport:SetRightAlignPrinter(.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criacao da Sessao 1                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oRel:= TRSection():New(oReport,_cTitulo,{"SF1","SD1","SD2"} )

	//New(oParent,cName ,cAlias,cTitle,cPicture                       ,nSize                      ,lPixel    ,bBlock                           ,cAlign ,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize      ,nClrBack  ,nClrFore ,lBold)
	TRCell():New(oRel,'DOC'    ,''    ,     ,PesqPict("SD2", "D2_DOC")    ,TamSX3("D2_DOC")[1]   ,,,  "LEFT",,"LEFT" )
	TRCell():New(oRel,'SERIE'  ,''    ,     ,PesqPict("SD2", "D2_SERIE")    ,TamSX3("D2_SERIE")[1]   ,,,  "LEFT",,"LEFT" )
	TRCell():New(oRel,'CLIENTE',''    ,     ,PesqPict("SD2", "D2_CLIENTE")    ,TamSX3("D2_CLIENTE")[1]	 ,,,  "LEFT",,"LEFT" )
	TRCell():New(oRel,'LOJA'   ,''    ,     ,PesqPict("SD2", "D2_LOJA")    ,TamSX3("D2_LOJA")[1]  ,,,  "LEFT",,"LEFT" )
	TRCell():New(oRel,'COD'    ,''    ,     ,PesqPict("SD2", "D2_COD")    ,TamSX3("D2_COD")[1]	 ,,,  "LEFT",,"LEFT" )
	TRCell():New(oRel,'DESC'   ,''    ,     ,PesqPict("SB1", "B1_DESC")    ,40  ,,,  "LEFT",,"LEFT" )
	TRCell():New(oRel,'TES'    ,''    ,     ,PesqPict("SD2", "D2_TES")    ,TamSX3("D2_TES")[1]	 ,,,  "LEFT",,"LEFT" )
	TRCell():New(oRel,'CFOP'   ,''    ,     ,PesqPict("SD2", "D2_CF")    ,TamSX3("D2_CF")[1]	 ,,,  "LEFT",,"LEFT" )
	TRCell():New(oRel,'EMISSAO',''    ,     ,PesqPict("SD2", "D2_EMISSAO")    ,TamSX3("D2_EMISSAO")[1]	 ,,,  "LEFT",,"LEFT" )
	TRCell():New(oRel,'BASEICM',''    ,     ,PesqPict("SD2", "D2_BASEICM")    ,TamSX3("D2_BASEICM")[1]	  ,,,  "RIGHT",,"RIGHT" )
	TRCell():New(oRel,'BASIMP5',''    ,     ,PesqPict("SD2", "D2_BASIMP5")    ,TamSX3("D2_BASIMP5")[1]	  ,,,  "RIGHT",,"RIGHT" )
	TRCell():New(oRel,'BASIMP6',''    ,     ,PesqPict("SD2", "D2_BASIMP6")    ,TamSX3("D2_BASIMP6")[1]	  ,,,  "RIGHT",,"RIGHT" )
	TRCell():New(oRel,'VALIMP5',''    ,     ,PesqPict("SD2", "D2_VALIMP5")    ,TamSX3("D2_VALIMP5")[1]	  ,,,  "RIGHT",,"RIGHT" )
	TRCell():New(oRel,'VALIMP6',''    ,     ,PesqPict("SD2", "D2_VALIMP6")    ,TamSX3("D2_VALIMP6")[1]	  ,,,  "RIGHT",,"RIGHT" )
	TRCell():New(oRel,'QUANT'  ,''    ,     ,PesqPict("SD2", "D2_QUANT")    ,TamSX3("D2_QUANT")[1]	  ,,,  "RIGHT",,"RIGHT" )
	TRCell():New(oRel,'PRCVEN' ,''    ,     ,PesqPict("SD2", "D2_PRCVEN")    ,TamSX3("D2_PRCVEN")[1]	 ,,,  "RIGHT",,"RIGHT" )
	TRCell():New(oRel,'TOTAL'  ,''    ,     ,PesqPict("SD2", "D2_TOTAL")    ,TamSX3("D2_TOTAL")[1]	 ,,,  "RIGHT",,"RIGHT" )


	oReport:PrintDialog()
Return

Static Function ReportPrint(oReport)
	Local oRel	:= oReport:Section(1)
	Local nTotal 	:= 0

	BeginSql Alias 'Qery'
        Select D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_EMISSAO, B1_DESC, 
        D2_CF, D2_TES, D2_BASEICM, D2_BASIMP5, D2_BASIMP6, D2_VALIMP5, D2_VALIMP6,
        SUM(D2_QUANT) AS QUANT, SUM(D2_PRCVEN) AS PRCVEN, SUM(D2_TOTAL) AS TOTAL
        From %Table:SF1% F1 
        Inner Join %Table:SD1% D1 On F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE
        AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA 
        INNER JOIN %Table:SD2% D2 On D2_DOC = D1_XNFSAI 
        AND D2_CF BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
        AND D2_TES BETWEEN %Exp:MV_PAR09% AND %Exp:MV_PAR10%
        Inner Join %Table:SB1% B1 On B1_COD = D2_COD
        WHERE F1.%NotDel% And D2.%NotDel% And D1.%NotDel% And B1.%NotDel%
        AND F1_FILIAL BETWEEN %EXP:MV_PAR01% And %Exp:MV_PAR02%
        AND F1_EMISSAO BETWEEN %EXP:DtoS(MV_PAR03)% And %Exp:DtoS(MV_PAR04)%
        AND F1_DOC BETWEEN %EXP:MV_PAR05% And %Exp:MV_PAR06%
        Group by D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_EMISSAO, B1_DESC
        ,D2_CF, D2_TES,D2_BASEICM, D2_BASIMP5, D2_BASIMP6, D2_VALIMP5, D2_VALIMP6
	EndSql

	oRel:SetHeaderSection(.T.)
	While Qery->(!EOF())
		oRel:Init()
		oRel:Cell('DOC'):SetValue(Qery->D2_DOC)
		oRel:Cell('SERIE'):SetValue(Qery->D2_SERIE)
		oRel:Cell('CLIENTE'):SetValue(Qery->D2_CLIENTE)
		oRel:Cell('LOJA'):SetValue(Qery->D2_LOJA)
		oRel:Cell('COD'):SetValue(Qery->D2_COD)
		oRel:Cell('DESC'):SetValue(Qery->B1_DESC)
		oRel:Cell('TES'):SetValue(Qery->D2_TES)
		oRel:Cell('CFOP'):SetValue(Qery->D2_CF)
		oRel:Cell('EMISSAO'):SetValue(StoD(Qery->D2_EMISSAO))
		oRel:Cell('BASEICM'):SetValue(Qery->D2_BASEICM)  
		oRel:Cell('BASIMP5'):SetValue(Qery->D2_BASIMP5)  
		oRel:Cell('BASIMP6'):SetValue(Qery->D2_BASIMP6)  
		oRel:Cell('VALIMP5'):SetValue(Qery->D2_VALIMP5)  
		oRel:Cell('VALIMP6'):SetValue(Qery->D2_VALIMP6)  
		oRel:Cell('QUANT'):SetValue(Qery->QUANT)
		oRel:Cell('PRCVEN'):SetValue(Qery->PRCVEN)
		oRel:Cell('TOTAL'):SetValue(Qery->TOTAL)
		oRel:Printline()
		nTotal += Qery->TOTAL
		Qery->(DbSkip())
	End
	oRel:Cell('DOC'):SetValue('')
	oRel:Cell('SERIE'):SetValue('')
	oRel:Cell('CLIENTE'):SetValue('')
	oRel:Cell('LOJA'):SetValue('')
	oRel:Cell('COD'):SetValue('Total')
    oRel:Cell('DESC'):SetValue('------------->')
	oRel:Cell('TES'):SetValue('')
	oRel:Cell('CFOP'):SetValue('')
	oRel:Cell('EMISSAO'):SetValue('')
    oRel:Cell('BASEICM'):SetValue('')  
	oRel:Cell('BASIMP5'):SetValue('')  
	oRel:Cell('BASIMP6'):SetValue('')  
	oRel:Cell('VALIMP5'):SetValue('')  
	oRel:Cell('VALIMP6'):SetValue('')  
	oRel:Cell('QUANT'):SetValue('')
	oRel:Cell('PRCVEN'):SetValue('')
	oRel:Cell('TOTAL'):SetValue(nTotal)
	oRel:Printline()

	Qery->(DbCloseArea())
Return
