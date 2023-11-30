#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#include "TopConn.ch"
#include "Color.ch"
#include "COLORS.ch"

#DEFINE SM0_FILIAL	02
#DEFINE SM0_NREDUZ 07

#define CLR_SILVER rgb(192,192,192)
#define CLR_LIGHTGRAY rgb(220,220,220)

User Function MFINR002
	Local oReport
	Local cPerg    := "MFINR002"
	Private _Enter    := chr(13) + Chr(10)
	Private oRel
	Private _lBold := .F. //Controle de IMpressão em NEgrito
	Private _nSize := TamSX3("E5_VALOR")[1]
	Private _lPixel := .F.
	Private lAutoSize := .T.
	PRIVATE aPergs      := {}

	//aAdd(aPergs, {1, "Filial" ,space(TamSX3("E1_FILIAL")[1]),"@!",'.T.','','.T.',TamSX3("E1_FILIAL")[1],.F.}) //MV_PAR01
	//aAdd(aPergs, {1, "Cliente" ,space(TamSX3("E1_CLIENTE")[1]),"@!",'.T.','','.T.',TamSX3("E1_CLIENTE")[1],.F.}) //MV_PAR02
	If !Pergunte(cPerg, .T.)
    Return
    EndIf
	
	_cTitulo  := "Relatorio posição dos titulos a receber"
	oReport:= TReport():New("fRunTit",_cTitulo,, {|oReport| ReportPrint(oReport)},_cTitulo)
	oReport:SetLandscape()

	//Parametriza o TReport para alinhamento a direita
	oReport:SetRightAlignPrinter(.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criacao da Sessao 1                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oRel:= TRSection():New(oReport,_cTitulo,{"SA1"} )

	//New(oParent,cName ,cAlias,cTitle,cPicture                       ,nSize                      ,lPixel    ,bBlock                           ,cAlign ,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize      ,nClrBack  ,nClrFore ,lBold)
	TRCell():New(oRel,'XSEGM'   ,''    ,      ,PesqPict("SA1", "A1_XSEGM")      ,TamSX3("A1_XSEGM")[1]   )
	TRCell():New(oRel,'Codigo'  ,''    ,      ,PesqPict("SA1", "A1_COD")      ,TamSX3("A1_COD")[1]   )
	TRCell():New(oRel,'Loja'    ,''    ,      ,PesqPict("SA1", "A1_LOJA")     ,TamSX3("A1_LOJA")[1]	)
	TRCell():New(oRel,'Nome'    ,''    ,      ,PesqPict("SA1", "A1_NOME")     ,TamSX3("A1_NOME")[1]  )
	TRCell():New(oRel,'A vencer',''    ,      ,PesqPict("SE1", "E1_SALDO")    ,TamSX3("E1_SALDO")[1]	)
	TRCell():New(oRel,'Vencido' ,''    ,      ,PesqPict("SE1", "E1_SALDO")    ,TamSX3("E1_SALDO")[1]	)
	TRCell():New(oRel,'Total'   ,''    ,      ,PesqPict("SE1", "E1_SALDO")    ,TamSX3("E1_SALDO")[1]	)


	oReport:PrintDialog()
Return

Static Function ReportPrint(oReport)
	Local oRel	:= oReport:Section(1)
	Local cQuery    := ""
	Local cGrupo 	:= ''
	Local nTotal 	:= 0
	Local nTotalV 	:= 0
	Local nTotalAV 	:= 0
	
	cQuery := "SELECT A1_XSEGM, A1_COD, A1_LOJA, A1_NOME, SUM(AVENCER) AS AVENCER, "
	cQuery += "SUM(VENCIDO) AS VENCIDO, SUM(AVENCER) + SUM(VENCIDO) AS TOTAL FROM ( "
	cQuery += "SELECT A1_XSEGM, A1_COD, A1_LOJA, A1_NOME, "
	cQuery += "CASE WHEN E1_VENCREA >= '"+DtoS(dDataBase)+"' THEN E1_SALDO ELSE 0 END AS AVENCER, "
	cQuery += "CASE WHEN E1_VENCREA < '"+DtoS(dDataBase)+"' THEN E1_SALDO ELSE 0 END AS VENCIDO FROM "+RetsqlName('SE1')+" SE1 "
	cQuery += "INNER JOIN "+RetsqlName('SA1')+" SA1 ON A1_FILIAL = SUBSTRING(E1_FILIAL,1,4) AND A1_COD = E1_CLIENTE "
	cQuery += "AND A1_LOJA = E1_LOJA AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += "WHERE E1_SALDO > 0 AND SE1.D_E_L_E_T_ <> '*' "
	cQuery += "AND E1_TIPO <> 'RA' "
	cQuery += "AND E1_FILIAL = '"+cFilAnt+"' "
	cQuery += "AND E1_CLIENTE BETEWEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cQuery += ") AS A "
	cQuery += "GROUP BY A1_XSEGM, A1_COD, A1_LOJA, A1_NOME "
	cQuery += "ORDER BY A1_XSEGM, A1_COD, A1_LOJA"
	
	MpSysOpenQuery(cQuery, "Qery")

	oRel:SetHeaderSection(.T.)
	While Qery->(!EOF())
		oRel:Init()
		cGrupo := Qery->A1_XSEGM
		cTipo := X3Combo("A1_XSEGM",cGrupo )
		nTotal := 0
		nTotalV := 0
		nTotalAV := 0
		While Qery->(!EOF()) .AND. cGrupo == Qery->A1_XSEGM
			//oRel:PrintHeader()
			oRel:Cell('XSEGM'):SetValue(Qery->A1_XSEGM)
			oRel:Cell('Codigo'):SetValue(Qery->A1_COD)
			oRel:Cell('Loja'):SetValue(Qery->A1_LOJA)
			oRel:Cell('Nome'):SetValue(Qery->A1_NOME)
			oRel:Cell('A vencer'):SetValue(Qery->AVENCER)
			oRel:Cell('Vencido'):SetValue(Qery->VENCIDO)
			oRel:Cell('Total'):SetValue(Qery->TOTAL)
			oRel:Printline()
			nTotal += Qery->TOTAL
			nTotalV += Qery->VENCIDO
			nTotalAV += Qery->AVENCER
			Qery->(DbSkip())
		End
		oRel:Cell('Codigo'):SetValue('')
		oRel:Cell('Loja'):SetValue('')
		oRel:Cell('Nome'):SetValue('Total do '+cTipo+' ------------>')
		oRel:Cell('A vencer'):SetValue(nTotalAV)
		oRel:Cell('Vencido'):SetValue(nTotalV)
		oRel:Cell('Total'):SetValue(nTotal)
		oRel:Printline()
		oRePort:SkipLine(3)
		//If Qery->(!EOF())
		//oRel:Cell('Codigo'):SetValue('Codigo')
		//oRel:Cell('Loja'):SetValue('Loja')
		//oRel:Cell('Nome'):SetValue('Nome')
		//oRel:Cell('A vencer'):SetValue('A Vencer')
		//oRel:Cell('Vencido'):SetValue('Vencido')
		//oRel:Cell('Total'):SetValue('Total')
		//oRel:ThinLine()
		//oRel:Printline()
		//EndIf
	End
	Qery->(DbCloseArea())
Return
