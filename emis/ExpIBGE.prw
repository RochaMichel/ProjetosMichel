#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'

User Function ExpIBGE()
	Local aArea    := GetArea()
	Local cCaminho := GetTempPath()
	Local cArquivo := ""
	Local nHandle  := 0
	Local cDados   := ""
	Local cCgc     := ""
	Local cNumSede := ""
	Local cQuery := ""
	Local cQueryD := ""
	Local aPergs := {}

	aAdd(aPergs, {1,"Ramal  (SEDE): ",Space(5),"","","","",180,.F.})	//MV_PAR01
	aAdd(aPergs, {1,"E-mail (SEDE): ",Space(50),"","","","",180,.F.})	//MV_PAR02
	aAdd(aPergs, {1,"Descrição da principal atividade(maior receita) da empresa: ",Space(66),"","","","",180,.F.})	//MV_PAR03
	aAdd(aPergs, {1,"Ramal (UNIDADE DE COLETA): ",Space(5),"","","","",180,.F.})	//MV_PAR04
	aAdd(aPergs, {1,"Nome (responsável preenchimento): ",Space(55),"","","","",180,.F.})    //MV_PAR05
	aAdd(aPergs, {1,"Cargo (responsável preenchimento): ",Space(55),"","","","",180,.F.})   //MV_PAR06
	aAdd(aPergs, {1,"DDD  (responsável preenchimento): ",Space(2),"","","","",180,.F.})   //MV_PAR07
	aAdd(aPergs, {1,"Telefone (responsável preenchimento): ",Space(9),"","","","",180,.F.})   //MV_PAR08
	aAdd(aPergs, {1,"Ramal (responsável preenchimento): ",Space(5),"","","","",180,.F.})   //MV_PAR09
	aAdd(aPergs, {1,"E-mail (responsável preenchimento): ",Space(50),"","","","",180,.F.})   //MV_PAR10
	aAdd(aPergs, {2,"Situação Cadastral em 31/12/"+cValToChar((Year(dDataBase)-1))+": "	, "" , {"01=Em operação","03=Paralisada c/ informacao de receita","04=Extinta c/ informacao de receita"}  , 70 ,".T.",.T.})	//MV_PAR11
	aAdd(aPergs, {2,"Mudanças na Estrutura no Ano de "+cValToChar((Year(dDataBase)-1))+": "	, "" , {"01=Fusao ou cisao total","02=Cisao parcial", "03=Incorporacao de/ por outra(s) empresa(s)","06=Alteracao de CNPJ por outros motivos(esclareça em 'OBSERVACOES')","00=Nao houve mudancas"}  , 170 ,".T.",.T.})	//MV_PAR12
	aAdd(aPergs, {2,"Forma de Tributação Utilizada" , "" , { "1=Lucro Real","2=Lucro Presumido ou Arbitrado","3=Sistema 'Simples Nacional'","4=Imune ou Isenta"}  , 70 ,".T.",.T.})	//MV_PAR13
	aAdd(aPergs, {2,"O endereço UNIDADE DE COLETA mudou? " , "" , { "1=Sim","2=Não","3=Empresa NOVA na Pesquisa"}  , 70 ,".T.",.T.})	//MV_PAR14
	aAdd(aPergs, {2,"O endereço da sede mudou?" , "" , { "1=Sim","2=Não","3=Empresa NOVA na Pesquisa"}  , 70 ,".T.",.T.})	//MV_PAR15
	aAdd(aPergs, {2,"A Razão Social informada mudou?" , "" , { "1=Sim","2=Não"}  , 70 ,".T.",.T.})	//MV_PAR16



	If !Parambox(aPergs,'Informe os Parametros')
		Return
	EndIf

	cCgc     := AllTrim(SM0->M0_CGC)
	cSite    := '' //Site da empresa
	cNumSede := AllTrim(SM0->M0_ENDCOB)
	cNumSede := SubStr(cNumSede,At(cNumSede,',')+1,5)

	cQuery += " SELECT SUM(TotAtvF1) AS TotAtvF1, SUM(TotAtvF2) AS TotAtvF2, SUM(TotAtvF3) AS TotAtvF3, SUM(TotAtvF4) AS TotAtvF4  FROM (
	cQuery += " SELECT COUNT(*) as TotAtvF1 , 0 as TotAtvF2, 0 as TotAtvF3, 0 as TotAtvF4 FROM (
	cQuery += "        SELECT
	cQuery += "               RA_MAT AS MATRICULA
	cQuery += " FROM (
	cQuery += " SELECT * FROM "+RetSqlName("SRA")+" WHERE RA_SITFOLH IN (' ','A','F') "
	cQuery += " AND RA_CC IN('61503','61504') AND RA_ADMISSA <= '"+cValToChar((Year(dDataBase)-1))+"0331' AND RA_DEMISSA = ' '  AND D_E_L_E_T_ = ' '
	cQuery += " UNION ALL
	cQuery += " SELECT * FROM "+RetSqlName("SRA")+" WHERE RA_SITFOLH IN ('D')  "
	cQuery += " AND RA_ADMISSA <= '"+cValToChar((Year(dDataBase)-1))+"0331'  "
	cQuery += " AND RA_CC IN('61503','61504') AND RA_DEMISSA > '"+cValToChar((Year(dDataBase)-1))+"0331' AND D_E_L_E_T_ = ' '
	cQuery += " ) AS SRA ) AS TotAtvF1
	cQuery += "      UNION ALL
	cQuery += "        SELECT 0 as TotAtvF1 ,  COUNT(*) as TotAtvF2, 0 as TotAtvF3, 0 as TotAtvF4 FROM (
	cQuery += "       SELECT
	cQuery += "               RA_MAT AS MATRICULA
	cQuery += " FROM (
	cQuery += " SELECT * FROM "+RetSqlName("SRA")+" WHERE RA_SITFOLH IN (' ','A','F') "
	cQuery += " AND RA_CC IN('61503','61504') AND RA_ADMISSA <= '"+cValToChar((Year(dDataBase)-1))+"0630' AND RA_DEMISSA = ' '  AND D_E_L_E_T_ = ' '
	cQuery += " UNION ALL
	cQuery += " SELECT * FROM "+RetSqlName("SRA")+" WHERE RA_SITFOLH IN ('D')  "
	cQuery += " AND RA_ADMISSA <= '"+cValToChar((Year(dDataBase)-1))+"0630'  "
	cQuery += " AND RA_CC IN('61503','61504') AND RA_DEMISSA > '"+cValToChar((Year(dDataBase)-1))+"0630' AND D_E_L_E_T_ = ' '
	cQuery += " ) AS SRA ) AS TotAtvF2
	cQuery += "      UNION ALL
	cQuery += "        SELECT 0 as TotAtvF1 , 0 as TotAtvF2, COUNT(*) as TotAtvF3, 0 as TotAtvF4 FROM (
	cQuery += "       SELECT
	cQuery += "               RA_MAT AS MATRICULA
	cQuery += " FROM (
	cQuery += " SELECT * FROM "+RetSqlName("SRA")+" WHERE RA_SITFOLH IN (' ','A','F') "
	cQuery += " AND RA_CC IN('61503','61504') AND RA_ADMISSA <= '"+cValToChar((Year(dDataBase)-1))+"0930' AND RA_DEMISSA = ' '  AND D_E_L_E_T_ = ' '
	cQuery += " UNION ALL
	cQuery += " SELECT * FROM "+RetSqlName("SRA")+" WHERE RA_SITFOLH IN ('D')  "
	cQuery += " AND RA_ADMISSA <= '"+cValToChar((Year(dDataBase)-1))+"0930'  "
	cQuery += " AND RA_CC IN('61503','61504') AND RA_DEMISSA > '"+cValToChar((Year(dDataBase)-1))+"0930' AND D_E_L_E_T_ = ' '
	cQuery += " ) AS SRA ) AS TotAtvF3
	cQuery += "      UNION ALL
	cQuery += "        SELECT 0 as TotAtvF1 , 0 as TotAtvF2, 0 as TotAtvF3, COUNT(*) as TotAtvF4 FROM (
	cQuery += "       SELECT
	cQuery += "               RA_MAT AS MATRICULA
	cQuery += " FROM (
	cQuery += " SELECT * FROM "+RetSqlName("SRA")+" WHERE RA_SITFOLH IN (' ','A','F') "
	cQuery += " AND RA_CC IN('61503','61504') AND RA_ADMISSA <= '"+cValToChar((Year(dDataBase)-1))+"1231' AND RA_DEMISSA = ' '  AND D_E_L_E_T_ = ' '
	cQuery += " UNION ALL
	cQuery += " SELECT * FROM "+RetSqlName("SRA")+" WHERE RA_SITFOLH IN ('D')  "
	cQuery += " AND RA_ADMISSA <= '"+cValToChar((Year(dDataBase)-1))+"1231'  "
	cQuery += " AND RA_CC IN('61503','61504') AND RA_DEMISSA > '"+cValToChar((Year(dDataBase)-1))+"1231' AND D_E_L_E_T_ = ' '
	cQuery += " ) AS SRA ) AS TotAtvF4 ) as TOT



	cQueryD += " SELECT SUM(TotAtvD1) AS TotAtvD1, SUM(TotAtvD2) AS TotAtvD2, SUM(TotAtvD4) AS TotAtvD3, SUM(TotAtvD4) AS TotAtvD4  FROM (
	cQueryD += "        SELECT  COUNT(*) as TotAtvD1 , 0 as TotAtvD2, 0 as TotAtvD3, 0 as TotAtvD4 FROM (
	cQueryD += "        SELECT
	cQueryD += "               RA_MAT AS MATRICULA
	cQueryD += " FROM (
	cQueryD += " SELECT * FROM "+RetSqlName("SRA")+" WHERE RA_SITFOLH IN (' ','A','F') "
	cQueryD += " AND RA_CC IN('61501','61502') AND RA_ADMISSA <= '"+cValToChar((Year(dDataBase)-1))+"0331' AND RA_DEMISSA = ' '  AND D_E_L_E_T_ = ' '
	cQueryD += " UNION ALL
	cQueryD += " SELECT * FROM "+RetSqlName("SRA")+" WHERE RA_SITFOLH IN ('D')  "
	cQueryD += " AND RA_ADMISSA <= '"+cValToChar((Year(dDataBase)-1))+"0331'  "
	cQueryD += " AND RA_CC IN('61501','61502') AND RA_DEMISSA > '"+cValToChar((Year(dDataBase)-1))+"0331' AND D_E_L_E_T_ = ' '
	cQueryD += " ) AS SRA ) AS TotAtvD1
	cQueryD += "      UNION ALL
	cQueryD += "        SELECT 0 as TotAtvD1 , COUNT(*) as TotAtvD2, 0 as TotAtvD3, 0 as TotAtvD4 FROM (
	cQueryD += "        SELECT
	cQueryD += "               RA_MAT AS MATRICULA
	cQueryD += " FROM (
	cQueryD += " SELECT * FROM "+RetSqlName("SRA")+" WHERE RA_SITFOLH IN (' ','A','F') "
	cQueryD += " AND RA_CC IN('61501','61502') AND RA_ADMISSA <= '"+cValToChar((Year(dDataBase)-1))+"0630' AND RA_DEMISSA = ' '  AND D_E_L_E_T_ = ' '
	cQueryD += " UNION ALL
	cQueryD += " SELECT * FROM "+RetSqlName("SRA")+" WHERE RA_SITFOLH IN ('D')  "
	cQueryD += " AND RA_ADMISSA <= '"+cValToChar((Year(dDataBase)-1))+"0630'  "
	cQueryD += " AND RA_CC IN('61501','61502') AND RA_DEMISSA > '"+cValToChar((Year(dDataBase)-1))+"0630' AND D_E_L_E_T_ = ' '
	cQueryD += " ) AS SRA ) AS TotAtvD2
	cQueryD += "      UNION ALL
	cQueryD += "        SELECT 0 as TotAtvD1 , 0 as TotAtvD2, COUNT(*) as TotAtvD3, 0 as TotAtvD4 FROM (
	cQueryD += "        SELECT
	cQueryD += "               RA_MAT AS MATRICULA
	cQueryD += " FROM (
	cQueryD += " SELECT * FROM "+RetSqlName("SRA")+" WHERE RA_SITFOLH IN (' ','A','F') "
	cQueryD += " AND RA_CC IN('61501','61502') AND RA_ADMISSA <= '"+cValToChar((Year(dDataBase)-1))+"0930' AND RA_DEMISSA = ' '  AND D_E_L_E_T_ = ' '
	cQueryD += " UNION ALL
	cQueryD += " SELECT * FROM "+RetSqlName("SRA")+" WHERE RA_SITFOLH IN ('D')  "
	cQueryD += " AND RA_ADMISSA <= '"+cValToChar((Year(dDataBase)-1))+"0930'  "
	cQueryD += " AND RA_CC IN('61501','61502') AND RA_DEMISSA > '"+cValToChar((Year(dDataBase)-1))+"0930' AND D_E_L_E_T_ = ' '
	cQueryD += " ) AS SRA ) AS TotAtvD3
	cQueryD += "      UNION ALL
	cQueryD += "        SELECT 0 as TotAtvD1 , 0 as TotAtvD2, 0 as TotAtvD3, COUNT(*) as TotAtvD4 FROM (
	cQueryD += "        SELECT
	cQueryD += "               RA_MAT AS MATRICULA
	cQueryD += " FROM (
	cQueryD += " SELECT * FROM "+RetSqlName("SRA")+" WHERE RA_SITFOLH IN (' ','A','F') "
	cQueryD += " AND RA_CC IN('61501','61502') AND RA_ADMISSA <= '"+cValToChar((Year(dDataBase)-1))+"1231' AND RA_DEMISSA = ' '  AND D_E_L_E_T_ = ' '
	cQueryD += " UNION ALL
	cQueryD += " SELECT * FROM "+RetSqlName("SRA")+" WHERE RA_SITFOLH IN ('D')  "
	cQueryD += " AND RA_ADMISSA <= '"+cValToChar((Year(dDataBase)-1))+"1231'  "
	cQueryD += " AND RA_CC IN('61501','61502') AND RA_DEMISSA > '"+cValToChar((Year(dDataBase)-1))+"1231' AND D_E_L_E_T_ = ' '
	cQueryD += " ) AS SRA ) AS TotAtvD4 ) AS TOT



	MpSysOpenQuery(cQuery , "ativFun")
	MpSysOpenQuery(cQueryD, "ativDir")

	cDados += SubStr(cCgc,1,8)+";"+SubStr(cCgc,9,4)+";"+SubStr(cCgc,13,2)+";"+Padr(AllTrim(SM0->M0_NOME),55)+";"+Padr(AllTrim(SM0->M0_NOME),55)+";"+Padr(cSite,70)+";" // As 6 primeiras posições
	cDados += AllTrim(SM0->M0_ESTCOB)+";"+Padr(AllTrim(SM0->M0_CIDCOB),45)+";;"+SubStr(AllTrim(SM0->M0_ENDCOB),1,3)+";"+SubStr(AllTrim(SM0->M0_ENDCOB),4,Len(SM0->M0_ENDCOB))+";"+AllTrim(cNumSede)+";" //da 7 a 12
	cDados += ";"+AllTrim(SM0->M0_BAIRCOB)+";"+AllTrim(SM0->M0_CEPCOB)+";"+SubStr(SM0->M0_TEL,1,2)+";"+SubStr(SM0->M0_TEL,4,11)+";"+MV_PAR01+";"+MV_PAR02+";"+EncodeUTF8(MV_PAR03)+";"+SubStr(SM0->M0_CNAE,1,4)+";"+SubStr(SM0->M0_CNAE,5,1)+";" //da 13 a 19
	cDados += SubStr(cCgc,9,4)+";"+SubStr(cCgc,13,2)+";"+AllTrim(SM0->M0_ESTCOB)+";"+Padr(AllTrim(SM0->M0_CIDCOB),45)+";;"+SubStr(AllTrim(SM0->M0_ENDCOB),1,3)+";"+SubStr(AllTrim(SM0->M0_ENDCOB),4,Len(SM0->M0_ENDCOB))+";"+AllTrim(cNumSede)+";"
	cDados += ";"+AllTrim(SM0->M0_BAIRCOB)+";"+AllTrim(SM0->M0_CEPCOB)+";"+SubStr(SM0->M0_TEL,1,2)+";"+SubStr(SM0->M0_TEL,4,11)+";"+MV_PAR04+";"+EncodeUTF8(MV_PAR05)+";"+EncodeUTF8(MV_PAR06)+";"
	cDados += MV_PAR07+";"+MV_PAR08+";"+MV_PAR09+";"+MV_PAR10+";"
	cDados += MV_PAR11+";"+MV_PAR12+";"+cValToChar(Month(dDataBase))+cValToChar(Year(dDataBase))+";"+SubStr(cCgc,1,8)+";"+SubStr(cCgc,9,4)+";"+SubStr(cCgc,13,2)+";"+SubStr(cCgc,1,8)+";"+SubStr(cCgc,9,4)+";"+SubStr(cCgc,13,2)+";"+SubStr(cCgc,1,8)+";"+SubStr(cCgc,9,4)+";"+SubStr(cCgc,13,2)+";"
	cDados += MV_PAR13+";"+MV_PAR14+";"+MV_PAR15+";"+MV_PAR16+";;;;"+cValToChar(ativFun->TotAtvF1)+";"+cValToChar(ativDir->TotAtvD1)+";0;0;"+cValToChar(ativFun->TotAtvF2)+";"+cValToChar(ativDir->TotAtvD2)+";0;0;"+cValToChar(ativFun->TotAtvF3)+";"+cValToChar(ativDir->TotAtvD3)+";0;0;"+cValToChar(ativFun->TotAtvF4)+";"+cValToChar(ativDir->TotAtvD4)+";0;0;"

	ativDir->(DbCloseArea())
	ativFun->(DbCloseArea())
	cQuery  := ''
	cQueryD := ''

	cQuery += " Select Floor(Sum(D2_VALBRUT)) as brutoTot, Floor(Sum(D2_TOTAL *(D2_COMIS1/100))) as comisTot  From "+RetSqlName("SD2")+" WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND YEAR(D2_EMISSAO) = "+cValToChar(YEAR(dDataBase)-1)+"  "
	MpSysOpenQuery(cQuery , "valbrut")

	cQueryD += " Select Floor(Sum(E1_VALOR)) as naturTot From "+RetSqlName("SE1")+" WHERE D_E_L_E_T_ = ' ' "
	cQueryD += " AND YEAR(E1_EMISSAO) = "+cValToChar(YEAR(dDataBase)-1)+" AND E1_NATUREZ = '2053'  "
	MpSysOpenQuery(cQueryD , "naturTot")

	cQueryA := " Select Floor(Sum(case when E5_RECPAG = 'R' THEN E5_VLJUROS ELSE 0 END)) as somarec, "
	cQueryA += " Floor(Sum(case when E5_RECPAG = 'P' THEN E5_VLDESCO ELSE 0 END)) as somapag "
	cQueryA += " From "+RetSqlName("SE5")+" WHERE D_E_L_E_T_ = ' ' "
	cQueryA += " AND YEAR(E5_DATA) = "+cValToChar(YEAR(dDataBase)-1)+"  "

	MpSysOpenQuery(cQueryA , "sumpagrec")
 
	cPorcen := " SELECT "
	cPorcen += "    ROUND((Fisica.quantidade_F * 100.0 / Total.total)) AS porcentagem_F, "
	cPorcen += "    ROUND((Juridica.quantidade_J * 100.0 / Total.total)) AS porcentagem_J, "
	cPorcen += "    ROUND((JuridicaDif.quantidade_Jd * 100.0 / Total.total)) AS porcentagem_Jd "
	cPorcen += " FROM "
	cPorcen += "    (SELECT COUNT(*) AS total "
	cPorcen += "     FROM SD2010 SD2 "
	cPorcen += "     INNER JOIN SA1010 SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA "
	cPorcen += "     WHERE YEAR(SD2.D2_EMISSAO) = 2023 AND SD2.D_E_L_E_T_ = ' ') AS Total, "
	cPorcen += "    (SELECT COUNT(*) AS quantidade_F "
	cPorcen += "     FROM SD2010 SD2 "
	cPorcen += "     INNER JOIN SA1010 SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA "
	cPorcen += "     WHERE YEAR(SD2.D2_EMISSAO) = 2023 AND SD2.D_E_L_E_T_ = ' ' AND SA1.A1_PESSOA = 'F') AS Fisica, "
	cPorcen += "    (SELECT COUNT(*) AS quantidade_J "
	cPorcen += "     FROM SD2010 SD2 "
	cPorcen += "     INNER JOIN SA1010 SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA "
	cPorcen += "     WHERE YEAR(SD2.D2_EMISSAO) = 2023 AND SD2.D_E_L_E_T_ = ' ' AND SA1.A1_PESSOA = 'J' AND SA1.A1_TPESSOA = ' ') AS Juridica, "
	cPorcen += "    (SELECT COUNT(*) AS quantidade_Jd "
	cPorcen += "     FROM SD2010 SD2 "
	cPorcen += "     INNER JOIN SA1010 SA1 ON SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA "
	cPorcen += "     WHERE YEAR(SD2.D2_EMISSAO) = 2023 AND SD2.D_E_L_E_T_ = ' ' AND SA1.A1_PESSOA = 'J' AND SA1.A1_TPESSOA <> ' ') AS JuridicaDif; "

	MpSysOpenQuery(cPorcen , "QryPorcen")

	cQueryctt := " "
	cQueryctt += " "
	cQueryctt += " "
	cQueryctt += " "

	MpSysOpenQuery(cQueryctt , "sumpagrec")

 
	cDados += cValToChar(valbrut->brutoTot)+";"+cValToChar(valbrut->comisTot)+";0;0;0;0;vendCancel;icmsSObreVend;PISPASEP;outros impostos;"
	cDados += cValToChar(naturTot->naturTot)+";"+cValToChar(sumpagrec->somarec+sumpagrec->somapag)+";0;CR;CS;CT;CU;CV;0;"
	cDados += cValToChar(QryPorcen->porcentagem_J)+";"+cValToChar(QryPorcen->porcentagem_Jd)+";"+cValToChar(QryPorcen->porcentagem_F)+";"

	valbrut->(DbCloseArea())
	naturTot->(DbCloseArea())
	sumpagrec->(DbCloseArea())
	QryPorcen->(DbCloseArea())
	cQuery  := ''
	cQueryD := ''

	cQuery += " Select Floor(Sum(D1_VALOR)) as brutoTot From "+RetSqlName("SD1")+" WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND YEAR(D1_EMISSAO) = "+cValToChar(YEAR(dDataBase)-1)+"  "
	MpSysOpenQuery(cQuery , "valbrut")

	cDados += "DA;0;0;DD;DE;0;0;DH;DI;0;0;;;"

	cDados += +CHR(13)+CHR(10) 	// Pular a linha+

	SM0->(DbGoTop())

	cArquivo:= cCaminho+"EXPIBGE"+DTOS(Date())+".CSV"
	nHandle := fcreate(cArquivo)
	If nHandle != -1
		FWrite(nHandle, cDados)
		FClose(nHandle)
	EndIf

	RestArea(aArea)
Return
