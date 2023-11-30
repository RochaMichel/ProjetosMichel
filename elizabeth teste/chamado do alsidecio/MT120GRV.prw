#include "Protheus.ch"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*
 Bloqueio de alteração do pedido de compra, apenas o aprovador que bloqueou pode desbloquear o pedido 
 para alteração. 
 Data: 19/05/2017
*/

User Function MT120GRV
	Local cNum  	:= PARAMIXB[1]
	//Local lInclui  	:= PARAMIXB[2]
	Local lAltera 	:= PARAMIXB[3]
	Local lRet		:= .T.
	Local cUsrApr	:= " "
	//Local cQuery	:= " "
	//Local cCC		:= " "
	//Local nVar		:= 0
	//Local cGrp		:= " "
	If lAltera
		If Posicione("SC7",1,xFilial("SC7")+cNum,"C7_XBLQAPR")=="S"
			cUsrApr := Posicione("SC7",1,xFilial("SC7")+cNum,"C7_XBLQUSR")
			cUsrApr := UsrRetName(cUsrApr)
			lRet 	:= .F.
			MsgAlert("ATENÇÃO! Este pedido foi bloqueado pelo aprovador "+cUsrApr+", e só o mesmo poderá desbloquea-lo!")
		Endif
		
	EndIf
/*
	If lInclui .OR. lAltera

		cCC		:= Posicione("SC7",1,xFilial("SC7")+cNum,"C7_CC")
		cGrp	:= 	Posicione("SC7",1,xFilial("SC7")+cNum,"C7_APROV")
		cQuery := " select NVL(count(DBL_CC),0) as QTD from "+ RetsqlName("DBL")
		cQuery += " where d_e_l_e_t_ <> '*' "
		cQuery += " and DBL_FILIAL = '"+xFilial("SC7")+"' "
		cQuery += " and DBL_CC = '"+cCC+"' "

		TCQUERY cQuery NEW ALIAS "TMPED"
		dbSelectArea("TMPED")
		TMPED->(dbGotop())
		nVar := TMPED->QTD
		TMPED->(dbCloseArea())

		If nVar == 0
			lRet 	:= .F.
			MsgInfo("ATENÇÃO! O centro de custo não está vinvulado a um grupo de aprovação.Favor cadastrarum grupo de aprovacao para este CC.")
		else
			cQuery := " select NVL(count(AL_COD),0) as QTD from "+ RetsqlName("SAL")
			cQuery += " where d_e_l_e_t_ <> '*' "
			cQuery += " and AL_FILIAL = '"+xFilial("SC7")+"' "
			cQuery += " and AL_COD = '"+cGrp+"' "
			cQuery += " and AL_DOCPC = 'T' and AL_DOCIP = 'T' "

			TCQUERY cQuery NEW ALIAS "TMPAL"
			dbSelectArea("TMPAL")
			TMPAL->(dbGotop())
			nVar := TMPAL->QTD
			TMPAL->(dbCloseArea())
			If nVar == 0
				lRet 	:= .F.
				MsgInfo("ATENÇÃO! O centro de custo não está vinvulado a um grupo de aprovação.Favor cadastrarum grupo de aprovacao para este CC.")
			endif
		endif

	EndIf
*/
Return lRet
