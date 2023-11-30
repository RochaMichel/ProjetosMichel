#Include 'Totvs.ch'


User Function SolPdLib( cFilInfo, cSolicit )
    Local aArea         := GetArea()
    Local aCabPc        := {}
    Local aItePc        := {}
    Local aItens        := {}
    Local cNumPedC      := ""
    Local ciErro        := ""
    Local cContato      := ""
    Local sX            :=  0
    Local lOk           := .F.
    PRIVATE lMsErroAuto := .F.

    DbSelectArea("SC1")
    SC1->(DbSetOrder(1))
    If SC1->(DbSeek(cFilInfo+cSolicit))

        cNumPedC := GetSxeNum("SC7","C7_NUM")
        cContato := Posicione("SA2",1,cFilInfo+SC1->(C1_FORNECE+C1_LOJA),"A2_CONTATO")

    	**/*TABELA SC7 CABE�ALHO DO PEDIDO DE COMPRA*/**
    	aAdd(aCabPc,{"C7_FILIAL"  	,Padr(SC1->C1_FILIAL ,TamSx3("C7_FILIAL")[1])            ,Nil}) //01
    	aAdd(aCabPc,{"C7_TIPO"  	,Padr("1"            ,TamSx3("C7_TIPO")[1]) 			 ,Nil}) //02
    	aAdd(aCabPc,{"C7_NUM"     	,Padr(cNumPedC       ,TamSx3("C7_NUM")[1]) 			   	 ,Nil}) //03
    	aAdd(aCabPc,{"C7_EMISSAO"   ,Padr(SC1->C1_EMISSAO,TamSx3("C7_EMISSAO")[1])       	 ,Nil}) //04
    	aAdd(aCabPc,{"C7_FORNECE"   ,Padr(SC1->C1_FORNECE,TamSx3("C7_FORNECE")[1])    		 ,Nil}) //05
    	aAdd(aCabPc,{"C7_LOJA"	    ,Padr(SC1->C1_LOJA   ,TamSx3("C7_LOJA")[1])       		 ,Nil}) //06
    	aAdd(aCabPc,{"C7_COND"	    ,Padr(SC1->C1_CONDPAG,TamSx3("C7_COND")[1])       		 ,Nil}) //07
    	aAdd(aCabPc,{"C7_CONTATO"	,Padr(cContato       ,TamSx3("C7_CONTATO")[1])           ,Nil}) //08
    	aAdd(aCabPc,{"C7_FILENT" 	,Padr(SC1->C1_FILENT ,TamSx3("C7_FILENT")[1])   		 ,Nil}) //09
    
        While SC1->(!Eof()) .And. SC1->(C1_FILIAL+C1_NUM) == AllTrim(cFilInfo+cSolicit)

            **/*TABELA SC7 ITENS DO PEDIDO DE COMPRA*/**   	    
            aItePc := {}
    	    aAdd(aItePc,{"C7_ITEM"   	,Padr(SC1->C1_ITEM   ,TamSx3("C7_ITEM")[1])		     ,Nil}) //01
    	    aAdd(aItePc,{"C7_PRODUTO"	,Padr(SC1->C1_PRODUTO,TamSx3("C7_PRODUTO")[1])		 ,Nil}) //02
    	    aAdd(aItePc,{"C7_UM"      	,Padr(SC1->C1_UM     ,TamSx3("C7_UM")[1])            ,Nil}) //03
    	    aAdd(aItePc,{"C7_QUANT"  	,SC1->C1_QUANT 	                                     ,Nil}) //04
    	    aAdd(aItePc,{"C7_PRECO"  	,SC1->C1_PRECO                              		 ,Nil}) //05
    	    aAdd(aItePc,{"C7_TOTAL"   	,SC1->C1_TOTAL                                       ,Nil}) //06
    	    aAdd(aItePc,{"C7_QUJE"   	,0                                                   ,Nil}) //07
    	    aAdd(aItePc,{"C7_QTDACLA"   ,0                                                   ,Nil}) //08
    	    aAdd(aItePc,{"C7_CONTRA"    ,Padr(""             ,TamSx3("C7_CONTRA")[1])        ,Nil}) //09
    	    aAdd(aItens,aClone(aItePC))
            SC1->(DbSkip())

        End

    	Begin Transaction

    	    MsExecAuto({|a,b,c,d| Mata120(a,b,c,d)},1,aCabPc,aItens,3)

    	    If lMsErroAuto
    	    	ConOut("Pedido N�o Gerado " + alltrim(cNumPedc))
    	    	aiErro := GetAutoGRLog()
    	    	For sX := 1 To Len(aiErro)
    	    		ciErro += aiErro[sX] + Chr(13)+Chr(10)
    	    	Next sX
    	    	ConOut(ciErro)
    	    	DisarmTransaction()
    	    Else
    	    	lOK := .T.
    	    	ConOut("Pedido Gerado com Sucesso " + alltrim(cNumPedc))
    	    EndIf

    	End Transaction

    EndIf

    RestArea(aArea)

Return lOk
