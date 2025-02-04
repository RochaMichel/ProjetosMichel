#include 'Protheus.ch'

User Function GatPedPQ()

	if cFilAnt == GetMV('MV_XFPEDPQ',,'020101') .AND. M->C6_XPRODPQ == '2'
		M->C6_OPER := GetMv('MV_XOPPDPQ',,'39')
		ExistCpo("SX5","DJ"+M->C6_OPER)
		A410SitTrib()
		MTA410OPER(n)
	EndIf
Return " "
