#Include "TOTVS.ch"
#INCLUDE "TOPCONN.CH"

user function FINF002()

	Local _cQuery := ""

	RpcSetType(3)
	RpcSetEnv( "01", '020201',,,'FIN')

	_cQuery := " SELECT e1_filial,e1_prefixo,e1_num,e1_parcela,e1_tipo,e1_cliente,e1_loja,e1_portado,e1_boleto "
	_cQuery += " FROM "+RetsqlName("SE1") + " E1 "
	_cQuery += " WHERE e1_saldo > 0 AND e1_tipo NOT IN ('NCC','RA','AB-') AND e1.d_e_l_e_t_ <> '*' "
    _cQuery += " and E1_SALDO = E1_VALOR and E1_EMISSAO >= '20210501' and e1.e1_vencrea >='"+DTOS(DATE())+"' "
	_cQuery += " and E1_PREFIXO = '1  ' "
	//_cQuery += " and E1_NUM = '000098178' "
	_cQuery += " AND e1_filial BETWEEN '020101' AND '020204' AND e1_portado in ('004','001','756','341','104','237','033','637') "
	_cQuery += " ORDER BY e1_portado "
    
	TCQUERY _cQuery NEW ALIAS "TMPBOL"

	DBSELECTAREA("TMPBOL")
	TMPBOL->(DBGOTOP())

	While !TMPBOL->(EOF())

		RpcSetType(3)
		RpcSetEnv( "01", TMPBOL->E1_FILIAL,,,'FIN')
		//Verifica geração do boleto através do campo E1_BOLETO - 02/05/2022
		//If Posicione("SE1",1,TMPBOL->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA), "E1_BOLETO") <> '1'
		If TMPBOL->E1_BOLETO <> '1'
			If TMPBOL->E1_PORTADO == '004'
				StartJob("U_BLTBNB",GetEnvServer(),.F.,TMPBOL->E1_FILIAL,TMPBOL->E1_CLIENTE,TMPBOL->E1_LOJA,TMPBOL->E1_NUM,"","","","", TMPBOL->E1_PARCELA)
			ElseIf TMPBOL->E1_PORTADO == '237'
				u_B231WS(TMPBOL->E1_FILIAL,TMPBOL->E1_NUM,TMPBOL->E1_PREFIXO,TMPBOL->E1_CLIENTE,TMPBOL->E1_LOJA,TMPBOL->E1_PARCELA)
			elseif TMPBOL->E1_PORTADO == '341'
				StartJob("U_EXB341WS",GetEnvServer(),.F.,TMPBOL->E1_FILIAL,TMPBOL->E1_NUM,TMPBOL->E1_PREFIXO,TMPBOL->E1_CLIENTE,TMPBOL->E1_LOJA,TMPBOL->E1_PARCELA)	
			elseif TMPBOL->E1_PORTADO == '033'
				StartJob("U_EXB033WS",GetEnvServer(),.F.,TMPBOL->E1_FILIAL,TMPBOL->E1_NUM,TMPBOL->E1_PREFIXO,TMPBOL->E1_CLIENTE,TMPBOL->E1_LOJA,TMPBOL->E1_PARCELA)
			elseif TMPBOL->E1_PORTADO == '637'
				StartJob("U_EX637WS",GetEnvServer(),.F.,TMPBOL->E1_FILIAL,TMPBOL->E1_NUM,TMPBOL->E1_PREFIXO,TMPBOL->E1_CLIENTE,TMPBOL->E1_LOJA,TMPBOL->E1_PARCELA)	
			EndIf	
		Endif

		if !(File("\web\ws\boleto\"+MD5(ALLTRIM(TMPBOL->E1_FILIAL+ TMPBOL->E1_NUM+ TMPBOL->E1_CLIENTE+ TMPBOL->E1_LOJA+ALLTRIM( TMPBOL->E1_PARCELA)))+".pdf"))
			//If TMPBOL->E1_PORTADO == '237'
			//	u_B231WS(TMPBOL->E1_FILIAL,TMPBOL->E1_NUM,TMPBOL->E1_PREFIXO,TMPBOL->E1_CLIENTE,TMPBOL->E1_LOJA,TMPBOL->E1_PARCELA)
			//elseif TMPBOL->E1_PORTADO == '004'
				//U_BLTBNB(TMPBOL->E1_FILIAL,TMPBOL->E1_CLIENTE,TMPBOL->E1_LOJA,TMPBOL->E1_NUM,"","","","", TMPBOL->E1_PARCELA)
			//	StartJob("U_BLTBNB",GetEnvServer(),.F.,TMPBOL->E1_FILIAL,TMPBOL->E1_CLIENTE,TMPBOL->E1_LOJA,TMPBOL->E1_NUM,"","","","", TMPBOL->E1_PARCELA)
			//elseif TMPBOL->E1_PORTADO == '001'
			if TMPBOL->E1_PORTADO == '001'
				U_B001WS(TMPBOL->E1_FILIAL,TMPBOL->E1_NUM,TMPBOL->E1_PREFIXO,TMPBOL->E1_CLIENTE,TMPBOL->E1_LOJA,TMPBOL->E1_PARCELA)
			elseif TMPBOL->E1_PORTADO == '756'
				U_B756WS(TMPBOL->E1_FILIAL,TMPBOL->E1_NUM,TMPBOL->E1_PREFIXO,TMPBOL->E1_CLIENTE,TMPBOL->E1_LOJA,TMPBOL->E1_PARCELA)
			elseif TMPBOL->E1_PORTADO == '637' 
				U_B0SOFWS(TMPBOL->E1_FILIAL,TMPBOL->E1_NUM,TMPBOL->E1_PREFIXO,TMPBOL->E1_CLIENTE,TMPBOL->E1_LOJA,TMPBOL->E1_PARCELA)
			//elseif TMPBOL->E1_PORTADO == '341'
				//U_B341WS(TMPBOL->E1_FILIAL,TMPBOL->E1_NUM,TMPBOL->E1_PREFIXO,TMPBOL->E1_CLIENTE,TMPBOL->E1_LOJA,TMPBOL->E1_PARCELA)
			//	StartJob("U_B341WS",GetEnvServer(),.F.,TMPBOL->E1_FILIAL,TMPBOL->E1_NUM,TMPBOL->E1_PREFIXO,TMPBOL->E1_CLIENTE,TMPBOL->E1_LOJA,TMPBOL->E1_PARCELA)
			elseif TMPBOL->E1_PORTADO == '104'
				U_B104WS(TMPBOL->E1_FILIAL,TMPBOL->E1_NUM,TMPBOL->E1_PREFIXO,TMPBOL->E1_CLIENTE,TMPBOL->E1_LOJA,TMPBOL->E1_PARCELA)
			endif
		endif
		TMPBOL->(dbSkip())
	EndDo
    TMPBOL->(DBCLOSEAREA())

	RpcClearEnv()

Return

/*
user function FINF002A()

	Local _cQuery := ""

	RpcSetType(3)
	RpcSetEnv( "01", '020201',,,'FIN')

	_cQuery := " SELECT e1_filial,e1_prefixo,e1_num,e1_parcela,e1_cliente,e1_loja,e1_portado "
	_cQuery += " FROM "+RetsqlName("SE1") + " E1 "
	_cQuery += " WHERE e1_saldo > 0 AND e1_tipo NOT IN ('NCC','RA','AB-') AND e1.d_e_l_e_t_ <> '*' "
    _cQuery += " and E1_SALDO = E1_VALOR and E1_EMISSAO >= '20210501' and e1.e1_vencrea >='"+DTOS(DATE())+"' "
	_cQuery += " AND e1_filial BETWEEN '020101' AND '020204' AND e1_portado = '004' "//in ('004','001','756','341','104','237')"
	_cQuery += " ORDER BY e1_portado "
    
	TCQUERY _cQuery NEW ALIAS "TMPBOL"

	DBSELECTAREA("TMPBOL")
	TMPBOL->(DBGOTOP())

	While !TMPBOL->(EOF())

		RpcSetType(3)
		RpcSetEnv( "01", TMPBOL->E1_FILIAL,,,'FIN')
		if !(File("\web\ws\boleto\"+MD5(ALLTRIM(TMPBOL->E1_FILIAL+ TMPBOL->E1_NUM+ TMPBOL->E1_CLIENTE+ TMPBOL->E1_LOJA+ALLTRIM( TMPBOL->E1_PARCELA)))+".pdf"))
			//elseif TMPBOL->E1_PORTADO == '004'
			U_BLTBNB(TMPBOL->E1_FILIAL,TMPBOL->E1_CLIENTE,TMPBOL->E1_LOJA,TMPBOL->E1_NUM,"","","","", TMPBOL->E1_PARCELA)
 
		endif
		TMPBOL->(dbSkip())
	EndDo
    TMPBOL->(DBCLOSEAREA())
	RpcClearEnv()

Return

user function FINF002B()

	Local _cQuery := ""

	RpcSetType(3)
	RpcSetEnv( "01", '020201',,,'FIN')

	_cQuery := " SELECT e1_filial,e1_prefixo,e1_num,e1_parcela,e1_cliente,e1_loja,e1_portado "
	_cQuery += " FROM "+RetsqlName("SE1") + " E1 "
	_cQuery += " WHERE e1_saldo > 0 AND e1_tipo NOT IN ('NCC','RA','AB-') AND e1.d_e_l_e_t_ <> '*' "
    _cQuery += " and E1_SALDO = E1_VALOR and E1_EMISSAO >= '20210501' and e1.e1_vencrea >='"+DTOS(DATE())+"' "
	_cQuery += " AND e1_filial BETWEEN '020101' AND '020204' AND e1_portado = '104' " //in ('004','001','756','341','104','237')"
	_cQuery += " ORDER BY e1_portado "
    
	TCQUERY _cQuery NEW ALIAS "TMPBOL"

	DBSELECTAREA("TMPBOL")
	TMPBOL->(DBGOTOP())

	While !TMPBOL->(EOF())

		RpcSetType(3)
		RpcSetEnv( "01", TMPBOL->E1_FILIAL,,,'FIN')
		if !(File("\web\ws\boleto\"+MD5(ALLTRIM(TMPBOL->E1_FILIAL+ TMPBOL->E1_NUM+ TMPBOL->E1_CLIENTE+ TMPBOL->E1_LOJA+ALLTRIM( TMPBOL->E1_PARCELA)))+".pdf"))

			//elseif TMPBOL->E1_PORTADO == '104'
			U_B104WS(TMPBOL->E1_FILIAL,TMPBOL->E1_NUM,TMPBOL->E1_PREFIXO,TMPBOL->E1_CLIENTE,TMPBOL->E1_LOJA,TMPBOL->E1_PARCELA)
 
		endif
		TMPBOL->(dbSkip())
	EndDo
    TMPBOL->(DBCLOSEAREA())
	RpcClearEnv()

Return

user function FINF002C()

	Local _cQuery := ""

	RpcSetType(3)
	RpcSetEnv( "01", '020201',,,'FIN')

	_cQuery := " SELECT e1_filial,e1_prefixo,e1_num,e1_parcela,e1_cliente,e1_loja,e1_portado "
	_cQuery += " FROM "+RetsqlName("SE1") + " E1 "
	_cQuery += " WHERE e1_saldo > 0 AND e1_tipo NOT IN ('NCC','RA','AB-') AND e1.d_e_l_e_t_ <> '*' "
    _cQuery += " and E1_SALDO = E1_VALOR and E1_EMISSAO >= '20210501' and e1.e1_vencrea >='"+DTOS(DATE())+"' "
	_cQuery += " AND e1_filial BETWEEN '020101' AND '020204' AND e1_portado = '237' " //in ('004','001','756','341','104','237')"
	_cQuery += " ORDER BY e1_portado "
    
	TCQUERY _cQuery NEW ALIAS "TMPBOL"

	DBSELECTAREA("TMPBOL")
	TMPBOL->(DBGOTOP())

	While !TMPBOL->(EOF())

		RpcSetType(3)
		RpcSetEnv( "01", TMPBOL->E1_FILIAL,,,'FIN')
		if !(File("\web\ws\boleto\"+MD5(ALLTRIM(TMPBOL->E1_FILIAL+ TMPBOL->E1_NUM+ TMPBOL->E1_CLIENTE+ TMPBOL->E1_LOJA+ALLTRIM( TMPBOL->E1_PARCELA)))+".pdf"))

			//If TMPBOL->E1_PORTADO == '237'
			u_B231WS(TMPBOL->E1_FILIAL,TMPBOL->E1_NUM,TMPBOL->E1_PREFIXO,TMPBOL->E1_CLIENTE,TMPBOL->E1_LOJA,TMPBOL->E1_PARCELA)
			 
		endif
		TMPBOL->(dbSkip())
	EndDo
    TMPBOL->(DBCLOSEAREA())
	RpcClearEnv()

Return

user function FINF002D()

	Local _cQuery := ""

	RpcSetType(3)
	RpcSetEnv( "01", '020201',,,'FIN')

	_cQuery := " SELECT e1_filial,e1_prefixo,e1_num,e1_parcela,e1_cliente,e1_loja,e1_portado "
	_cQuery += " FROM "+RetsqlName("SE1") + " E1 "
	_cQuery += " WHERE e1_saldo > 0 AND e1_tipo NOT IN ('NCC','RA','AB-') AND e1.d_e_l_e_t_ <> '*' "
    _cQuery += " and E1_SALDO = E1_VALOR and E1_EMISSAO >= '20210501' and e1.e1_vencrea >='"+DTOS(DATE())+"' "
	_cQuery += " AND e1_filial BETWEEN '020101' AND '020204' AND e1_portado = '341' "//in ('004','001','756','341','104','237')"
	_cQuery += " ORDER BY e1_portado "
    
	TCQUERY _cQuery NEW ALIAS "TMPBOL"

	DBSELECTAREA("TMPBOL")
	TMPBOL->(DBGOTOP())

	While !TMPBOL->(EOF())

		RpcSetType(3)
		RpcSetEnv( "01", TMPBOL->E1_FILIAL,,,'FIN')
		if !(File("\web\ws\boleto\"+MD5(ALLTRIM(TMPBOL->E1_FILIAL+ TMPBOL->E1_NUM+ TMPBOL->E1_CLIENTE+ TMPBOL->E1_LOJA+ALLTRIM( TMPBOL->E1_PARCELA)))+".pdf"))

			//elseif TMPBOL->E1_PORTADO == '341'
			U_B341WS(TMPBOL->E1_FILIAL,TMPBOL->E1_NUM,TMPBOL->E1_PREFIXO,TMPBOL->E1_CLIENTE,TMPBOL->E1_LOJA,TMPBOL->E1_PARCELA)
			
		endif
		TMPBOL->(dbSkip())
	EndDo
    TMPBOL->(DBCLOSEAREA())
	RpcClearEnv()

Return

user function FINF002E()

	Local _cQuery := ""

	RpcSetType(3)
	RpcSetEnv( "01", '020201',,,'FIN')

	_cQuery := " SELECT e1_filial,e1_prefixo,e1_num,e1_parcela,e1_cliente,e1_loja,e1_portado "
	_cQuery += " FROM "+RetsqlName("SE1") + " E1 "
	_cQuery += " WHERE e1_saldo > 0 AND e1_tipo NOT IN ('NCC','RA','AB-') AND e1.d_e_l_e_t_ <> '*' "
    _cQuery += " and E1_SALDO = E1_VALOR and E1_EMISSAO >= '20210501' and e1.e1_vencrea >='"+DTOS(DATE())+"' "
	_cQuery += " AND e1_filial BETWEEN '020101' AND '020204' AND e1_portado = '756' " // in ('004','001','756','341','104','237')"
	_cQuery += " ORDER BY e1_portado "
    
	TCQUERY _cQuery NEW ALIAS "TMPBOL"

	DBSELECTAREA("TMPBOL")
	TMPBOL->(DBGOTOP())

	While !TMPBOL->(EOF())

		RpcSetType(3)
		RpcSetEnv( "01", TMPBOL->E1_FILIAL,,,'FIN')
		if !(File("\web\ws\boleto\"+MD5(ALLTRIM(TMPBOL->E1_FILIAL+ TMPBOL->E1_NUM+ TMPBOL->E1_CLIENTE+ TMPBOL->E1_LOJA+ALLTRIM( TMPBOL->E1_PARCELA)))+".pdf"))

			//elseif TMPBOL->E1_PORTADO == '756'
			U_B756WS(TMPBOL->E1_FILIAL,TMPBOL->E1_NUM,TMPBOL->E1_PREFIXO,TMPBOL->E1_CLIENTE,TMPBOL->E1_LOJA,TMPBOL->E1_PARCELA)
			 
		endif
		TMPBOL->(dbSkip())
	EndDo
    TMPBOL->(DBCLOSEAREA())
	RpcClearEnv()

Return
*/
/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡Æo    ³ FlagBol ³ Autor ³ Walter Rodrigo         ³ Data ³ 02/05/22 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Atualiza o campo E1_BOLETO.                                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Arquivos  ³ SE1                                                        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³UpDate    ³ Elizabeth                                                  ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FlagBol(cChave)
Local aArea := GetArea()
DbSelectArea("SE1")
DbSetOrder(1)
If DbSeek(cChave)
	RecLock("SE1", .F.)
		SE1->E1_BOLETO := '1'
	MsUnlock()
Endif
RestArea(aArea)
Return

User Function EXB341WS(_filial,_titulo,_pref,_client,_loja,_parc)
	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv("01",_filial,,,"FIN",,{})

	U_B341WS(_filial,_titulo,_pref,_client,_loja,_parc)

	RpcClearEnv()
Return

User Function EXB033WS(_filial,_titulo,_pref,_client,_loja,_parc)
	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv("01",_filial,,,"FIN",,{})

	U_B033WS(_filial,_titulo,_pref,_client,_loja,_parc)

	RpcClearEnv()
Return

User Function EX637WS(_filial,_titulo,_pref,_client,_loja,_parc)
	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv("01",_filial,,,"FIN",,{})

	U_B0SOFWS(_filial,_titulo,_pref,_client,_loja,_parc)

	RpcClearEnv()
Return
